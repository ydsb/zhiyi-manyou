import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// 知驿·漫游 前端构建配置
// 文档：https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],

  resolve: {
    // preserveSymlinks=true 让 Vite 跳过 Windows 上的"真实路径"探测
    // （内部会 exec `net use` 子进程）。在受限/沙箱环境下该子进程会被拒绝
    // 并报 spawn EPERM，开启本项即可绕开；本项目没有符号链接依赖，无副作用。
    preserveSymlinks: true,
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },

  server: {
    /*
     * 监听所有网卡，使同一局域网内的其他设备（手机、同学电脑）可以访问。
     *
     * 绑 127.0.0.1 时只有本机能打开；改成 '0.0.0.0' 后
     * 局域网内用 http://<本机IP>:5173 即可访问。
     *
     * 代理目标是 localhost:8080 —— 代理在**本机**执行，
     * 所以这里用 localhost 就是对的，不要改成局域网 IP。
     *
     * 安全提醒：0.0.0.0 意味着同网段任何设备都能访问，仅适合开发/答辩演示，
     * 不要在有陌生设备的公共网络里长期开着。
     */
    host: '0.0.0.0',
    port: 5173,
    strictPort: false,
    open: false,
    /*
     * Vite 5 起有 host check（防 DNS rebinding）：请求的 Host 头若不在允许列表，
     * 会直接回 403 "Blocked request. This host is not allowed."。
     *
     * 实测 Vite 8 对「Host 是纯 IP」是放行的，所以用 http://10.x.x.x:5173
     * 访问目前不会触发它。但这里仍然显式放开，原因有二：
     *   1. 依赖"默认放行 IP"是隐式行为，Vite 改一版就可能失效，
     *      而失效时的报错是 403，很容易被误判成后端问题（我们刚在 CORS 上踩过一次）；
     *   2. 若之后用主机名（mDNS、hosts 文件、内网 DNS）访问，
     *      纯 IP 放行规则就盖不住了。
     *
     * 注意 allowedHosts 只接受域名，不接受 IP（配 '10.51.101.24' 是无效的），
     * 所以这里用 true 表示接受任意 Host。
     *
     * 安全性权衡：本项仅用于**局域网开发/演示**。DNS rebinding 的实际风险是
     * 外部网页通过解析到 127.0.0.1 的域名读你本机服务，而本服务本身要求登录、
     * 且只在可信局域网内可达，风险可接受。公网部署时不要开这一项。
     */
    allowedHosts: true,
    // 开发环境把 /api 代理到后端，避免跨域并保持与生产一致的相对路径
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/actuator': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    }
  },

  build: {
    outDir: 'dist',
    sourcemap: false,
    chunkSizeWarningLimit: 1500,
    rollupOptions: {
      output: {
        // Vite 8 使用 rolldown，manualChunks 必须是函数形式（对象形式已不支持）
        manualChunks(id: string) {
          if (id.includes('node_modules')) {
            if (id.includes('echarts') || id.includes('zrender')) return 'charts'
            if (id.includes('element-plus') || id.includes('@element-plus')) return 'element'
            if (id.includes('/vue/') || id.includes('vue-router') || id.includes('pinia')) return 'vue'
          }
          return undefined
        }
      }
    }
  }
})
