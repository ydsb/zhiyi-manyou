# 核心接口压测基线

使用 `scripts/baseline.ps1` 对已启动的后端执行轻量基线，默认覆盖 50、200、500 个并发 worker。
脚本只依赖 PowerShell，避免额外安装压测工具；正式验收时应在与生产相同的机器、数据库和数据量下重复执行。

```powershell
powershell -ExecutionPolicy Bypass -File scripts/baseline.ps1 -BaseUrl http://localhost:8080 -Path /api/health
```

| 并发 | 请求数 | 错误数 | P50(ms) | P95(ms) | P99(ms) |
|---:|---:|---:|---:|---:|---:|
| 50 | 待实测 | 待实测 | 待实测 | 待实测 | 待实测 |
| 200 | 待实测 | 待实测 | 待实测 | 待实测 | 待实测 |
| 500 | 待实测 | 待实测 | 待实测 | 待实测 | 待实测 |

真实业务接口需要登录令牌时，可通过 `-Path` 指向匿名健康检查之外的读接口，并在脚本中按部署环境补充 Authorization 头。
