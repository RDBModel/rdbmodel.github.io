import { defineConfig } from 'vite'
import { plugin as elmPlugin } from 'vite-plugin-elm'
import monacoEditorPlugin from 'vite-plugin-monaco-editor'

export default defineConfig({
  base: '/',
  plugins: [
    elmPlugin(),
    monacoEditorPlugin.default({
      languageWorkers: ['editorWorkerService'],
      customWorkers: [{label: "yaml", entry: "monaco-yaml/yaml.worker"}]
     })
  ]
})
