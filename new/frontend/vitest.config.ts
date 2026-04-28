import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    css: false,
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      include: [
        'src/lib/format.ts',
        'src/lib/ara-helpers.ts',
        'src/lib/utils.ts',
        'src/lib/validation/**/*.ts',
      ],
      exclude: [
        'src/**/*.{test,spec}.{ts,tsx}',
      ],
      // Coverage thresholds per docs/SHIP_PLAN.md Item 7 (frontend ≥ 70%).
      // Scoped to pure-logic modules under src/lib until React component
      // tests catch up. The shadcn baseline + react-query wiring + okta
      // config + api client are intentionally outside this scope.
      thresholds: {
        lines: 70,
        statements: 70,
        functions: 70,
        branches: 70,
      },
    },
  },
})
