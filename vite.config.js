import { defineConfig } from 'vite'
import { plugin as elmPlugin } from 'vite-plugin-elm'
import monacoEditorPlugin from 'vite-plugin-monaco-editor';

export default defineConfig({
  plugins: [elmPlugin({ optimize: false }), monacoEditorPlugin.default({ languageWorkers: ['editorWorkerService'] })]
})
