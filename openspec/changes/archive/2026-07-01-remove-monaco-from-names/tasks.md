## 1. Port layer (Elm↔JS contract)

- [x] 1.1 Rename ports in `InPorts.elm`: `monacoEditorSavedValue` → `editorValueSaved`, `initMonacoRequest` → `initEditorRequest`
- [x] 1.2 Rename ports in `OutPorts.elm`: `initMonacoResponse` → `initEditorResponse`, `updateMonacoValue` → `updateEditorValue`
- [x] 1.3 Rename port subscription/send sites in `index.js` to match new port names
- [x] 1.4 Verify port wiring by running the app and checking editor ↔ Elm communication

## 2. Core type renames (foundation for all other modules)

- [x] 2.1 Rename `MonacoValue` → `EditorValue` in `ViewUndoRedoActions.elm` (type alias and all usage sites)
- [x] 2.2 Rename `MonacoValue` → `EditorValue` in `EditorAction.elm` (type alias and all usage sites, including `Params` record field `monacoValue` → `editorValue`)
- [x] 2.3 Rename `UndoRedoMonacoValue` → `UndoRedoEditorValue` in `ViewUndoRedo.elm` (type alias, module exports, function `getUndoRedoMonacoValue` → `getUndoRedoEditorValue`, local usages)
- [x] 2.4 Rename `MonacoState` → `EditorState` in `SvgView.elm` (type alias and function signature `svgView`)
- [x] 2.5 Rename `UpdateMonacoValue` → `UpdateEditorValue` action in `Editor.elm`

## 3. JS application layer

- [x] 3.1 Rename `initMonaco()` → `initEditor()` in `index.js`
- [x] 3.2 Rename `updateMonacoValue()` → `updateEditorValue()` in `index.js`
- [x] 3.3 Rename DOM element ID from `"monaco"` to `"code-editor"` in `index.js` (`getElementById`)
- [x] 3.4 Keep all `monaco.*` library API calls unchanged (`monaco.editor.create`, `monaco.Range`, `monaco.Uri`, `monaco.KeyMod`, `monaco.KeyCode`)

## 4. ViewControl layer

- [x] 4.1 Rename `monacoValueModified` → `editorValueModified` in `ViewControlActions.elm` (function and module export)
- [x] 4.2 Rename `monacoValueModified` → `editorValueModified` in `AddViewActions.elm` (function and module export)

## 5. ViewEditor layer

- [x] 5.1 Update `Editor.elm`: rename all local bindings (`monacoModel` → `editorModel`, `monacoValue` → `editorValue`, `currentMonacoValue` → `currentEditorValue`, `newMonacoValue` → `newEditorValue`, `updatedMonacoValue` → `updatedEditorValue`)
- [x] 5.2 Rename `monacoViewPart` → `editorViewPart` in `Editor.elm`
- [x] 5.3 Rename messages: `MonacoEditorValueReceived` → `EditorValueReceived`, `ReceiveMonacoElementPosition` → `ReceiveEditorElementPosition`, `InitMonacoRequestReceived` → `InitEditorRequestReceived`
- [x] 5.4 Update `Editor.elm` imports to match renamed exports from all dependency modules
- [x] 5.5 Rename DOM element ID `"monaco"` → `"code-editor"` in Elm (`div [ id "monaco" ...]` and `Dom.getElement "monaco"`)

## 6. Main Editor page integration

- [x] 6.1 Update `Editor.elm` model field `monacoValue` → `editorValue` throughout (pattern matches, record updates, function arguments)
- [x] 6.2 Verify all imports resolve correctly after rename (no dangling references to old names)

## 7. Verification

- [x] 7.1 Run a full-text search for any remaining "monaco" in application code (excluding library imports, API calls, config, and docs) — expectation: zero occurrences
- [x] 7.2 Build the application (`npm run build`) and verify zero compilation errors
- [x] 7.3 Run `npm run dev` and smoke-test: editor loads, YAML editing works, diagram renders, undo/redo functions, Ctrl+S triggers save
