import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// In dev (npm run dev), proxy /auth and /app to your local docker-compose stack
// on http://localhost (nginx). Override with VITE_BACKEND_ORIGIN.
const backend = process.env.VITE_BACKEND_ORIGIN || 'http://localhost';

export default defineConfig({
    plugins: [react()],
    server: {
        port: 5173,
        proxy: {
            '/auth': { target: backend, changeOrigin: true },
            '/app':  { target: backend, changeOrigin: true },
        },
    },
    build: {
        outDir: 'dist',
        sourcemap: false,
        target: 'es2020',
    },
});
