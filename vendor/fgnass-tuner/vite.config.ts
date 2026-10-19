import preact from "@preact/preset-vite";
import { defineConfig } from "vite";

export default defineConfig({
  base: "/assets/guitar-tuner/",
  plugins: [preact()],
  build: {
    outDir: "../../assets/guitar-tuner",
    emptyOutDir: true,
    rollupOptions: {
      output: {
        entryFileNames: "guitar-tuner.js",
        assetFileNames: "[name][extname]",
      },
    },
  },
});
