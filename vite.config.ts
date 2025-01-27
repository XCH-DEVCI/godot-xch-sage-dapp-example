import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
        output: {
            manualChunks: {
                vendor: ['react', 'react-dom'], // Split React-related code into a separate chunk
            },
        },
    },
    chunkSizeWarningLimit: 100000, // Optional: Adjust warning limit
},
})
