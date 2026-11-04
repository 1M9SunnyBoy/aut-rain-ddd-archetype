#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 配置 React 构建、本地 API 代理与 Vitest 测试环境。
 * author: zzy
 * created: 2026-10-19
 */
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  // 固定开发端口，冲突时直接失败；仅开发服务器将 /api 转发到本机后端。
  server: { port: 5137, strictPort: true, proxy: { '/api': 'http://127.0.0.1:8080' } },
  test: { environment: 'jsdom', setupFiles: ['./src/test/setup.ts'] },
});
