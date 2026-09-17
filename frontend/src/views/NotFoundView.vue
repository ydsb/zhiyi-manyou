<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()
</script>

<template>
  <div class="nf">
    <div class="nf__box">
      <div class="nf__pixels" aria-hidden="true">
        <i v-for="n in 9" :key="n" class="zy-pixel-block"
           :style="{ background: n % 4 === 0 ? 'var(--zy-accent)' : 'var(--zy-primary-light)' }"></i>
      </div>
      <h1 class="nf__code">404</h1>
      <p class="nf__text">这个驿站不存在，或者你走错了漫游路线。</p>
      <el-button type="primary" @click="router.push('/dashboard')">回到数字档案</el-button>
    </div>
  </div>
</template>

<style scoped>
.nf {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: var(--zy-bg-page);
}

.nf__box {
  text-align: center;
}

.nf__pixels {
  display: grid;
  grid-template-columns: repeat(3, 14px);
  gap: 4px;
  justify-content: center;
  margin-bottom: 22px;
}

.nf__pixels .zy-pixel-block {
  width: 14px;
  height: 14px;
}

.nf__code {
  margin: 0 0 8px;
  font-size: 56px;
  letter-spacing: 0.06em;
  color: var(--zy-primary-dark);
}

.nf__text {
  margin: 0 0 22px;
  font-size: 13.5px;
  color: var(--zy-text-secondary);
}
</style>
