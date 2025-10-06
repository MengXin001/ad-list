import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import AutoImport from "unplugin-auto-import/vite";
import Components from "unplugin-vue-components/vite";
import { viteStaticCopy } from "vite-plugin-static-copy";

export default defineConfig({
  plugins: [
    vue(),
    AutoImport({}),
    Components({}),
    viteStaticCopy({
      targets: [
        {
          src: "list/**/*",
          dest: "list",
        },
      ],
    }),
  ],
});
