import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

// En desarrollo, las llamadas a /api se envían al servidor Node (puerto 3001)
export default defineConfig({
  base: '/NEXO-CEMACO/',
  plugins: [react(), tailwindcss()],
  server: {
    port: 5173,
    proxy: { '/api': 'http://localhost:3001' },
  },
});