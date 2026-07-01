## Why

The codebase uses "Monaco" in ~135 variable, type, function, port, and HTML ID names — coupling application concepts to a specific editor library. This makes the code harder to understand (the undo system stores an "UndoRedoMonacoValue" that has nothing to do with an editor) and creates friction if the editor library ever changes. Renaming to generic "editor" terms decouples the application from its editor implementation and improves code clarity.

## What Changes

- Rename all application-level identifiers containing "Monaco" to use "Editor" or generic equivalents
- Elm ports: `monacoEditorSavedValue` → `editorValueSaved`, `initMonacoRequest`/`initMonacoResponse` → `initEditorRequest`/`initEditorResponse`, `updateMonacoValue` → `updateEditorValue`
- Elm types: `MonacoValue` → `EditorValue`, `UndoRedoMonacoValue` → `UndoRedoEditorValue`, `MonacoState` → `EditorState`
- Elm actions/messages: `UpdateMonacoValue` → `UpdateEditorValue`, `MonacoEditorValueReceived` → `EditorValueReceived`
- Elm functions: `monacoViewPart` → `editorViewPart`, `monacoValueModified` → `editorValueModified`, `getMonacoValue` → `getInitialEditorValue`
- Model fields: `monacoValue` → `editorValue`, `monacoModel` → `editorModel`
- JS functions: `initMonaco()` → `initEditor()`, `updateMonacoValue()` → `updateEditorValue()`
- HTML element ID: `"monaco"` → `"code-editor"`
- Library imports and API calls (`import * as monaco`, `monaco.editor.create`, etc.) remain unchanged — these are legitimate references to the Monaco library

## Capabilities

### New Capabilities

- `editor-naming`: Application code uses editor-agnostic naming conventions, decoupling identifiers from the specific editor library implementation.

### Modified Capabilities

None. This is a pure refactoring — no functional or behavioral changes.

## Impact

- **11 source files** across Elm and JS layers (see design.md for full mapping)
- **Port boundary risk**: Elm port names must match JS side exactly — no compiler guard for mismatches. Requires coordinated rename across `InPorts.elm`, `OutPorts.elm`, `index.js`, and all subscription/send sites.
- **DOM element ID**: `id="monaco"` used in both Elm (`Dom.getElement`) and JS (`document.getElementById`) must change together.
- **No dependency changes**: `monaco-editor`, `monaco-yaml`, `vite-plugin-monaco-editor` packages stay as-is.
- **No user-facing change**: The application behaves identically before and after.
