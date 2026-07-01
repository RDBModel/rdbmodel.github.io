## Context

The RDB application uses Monaco Editor for its YAML code editor. The word "Monaco" appears in ~135 locations across 11 source files — not just in library imports (which are legitimate), but in application-level names: Elm types, port names, model fields, JS function names, and a DOM element ID.

This creates unnecessary coupling between the application's naming and a specific editor implementation. The most egregious example is `UndoRedoMonacoValue`, a generic undo/redo wrapper (`UndoList a`) named as if it inherently belongs to Monaco.

The rename is purely cosmetic — no behavior changes, no library swaps, no architecture changes. It prepares the codebase for a potential future editor swap (e.g., CodeMirror) but does not implement one.

## Goals / Non-Goals

**Goals:**
- Rename all application-level identifiers from "Monaco" to "Editor" (or context-appropriate generic names)
- Keep library imports and Monaco API calls (`monaco.editor.create`, `monaco.Range`, etc.) unchanged
- Preserve identical runtime behavior — the app must work exactly as before

**Non-Goals:**
- Abstracting the editor behind an interface/facade
- Swapping Monaco for another editor library
- Changing any functional behavior or UI
- Renaming npm packages or build tool plugin references

## Decisions

### Decision 1: Use "Editor" as the replacement term

**Rationale**: The thing being named is the code editor panel and its state. "Editor" is descriptive, generic, and already used elsewhere in the codebase (e.g., `ViewEditor/`, `Editor.elm`). Alternatives considered:

| Term | Verdict |
|------|---------|
| `Editor` | ✅ Chosen — clear, established in codebase |
| `CodeEditor` | Verbose, adds noise without disambiguation |
| `Source` | Too generic — the "source" is YAML, but these names refer to the editor widget + its runtime state |
| `Document` | Ambiguous — could mean the YAML document or a browser document |

### Decision 2: Rename in a single pass, not incrementally

**Rationale**: Port names are string-based contracts between Elm and JS. Renaming a port in Elm but forgetting the JS side (or vice versa) breaks the app silently. A single coordinated pass minimizes the window of inconsistency. The change is mechanical enough to batch safely.

### Decision 3: Rename the DOM element ID from `"monaco"` to `"code-editor"`

The `id="monaco"` div is the mount point for the Monaco editor instance. Three references must change together:
- HTML in Elm: `div [ id "monaco", ... ]` in `Editor.elm`
- JS: `document.getElementById('monaco')` in `index.js`
- Elm DOM query: `Dom.getElement "monaco"` in `Editor.elm`

### Decision 4: Keep `monaco` as the JS import namespace

`import * as monaco from 'monaco-editor'` stays. This is a legitimate reference to the library. Renaming it to `import * as editor` would be misleading — it's specifically the Monaco API.

### Decision 5: No abstraction layer introduced

While a future editor swap would benefit from an abstraction (e.g., an `EditorProvider` interface), that's out of scope. The goal here is only to stop using "Monaco" as a name for non-Monaco concepts.

## Complete rename mapping

### Ports (InPorts.elm + OutPorts.elm + index.js)

| Old | New |
|-----|-----|
| `monacoEditorSavedValue` | `editorValueSaved` |
| `initMonacoRequest` | `initEditorRequest` |
| `initMonacoResponse` | `initEditorResponse` |
| `updateMonacoValue` | `updateEditorValue` |

### Elm types

| File | Old | New |
|------|-----|-----|
| ViewUndoRedoActions.elm | `MonacoValue` | `EditorValue` |
| EditorAction.elm | `MonacoValue` | `EditorValue` |
| ViewUndoRedo.elm | `UndoRedoMonacoValue` | `UndoRedoEditorValue` |
| SvgView.elm | `MonacoState` | `EditorState` |
| Editor.elm | `MonacoState` (import) | `EditorState` |

### Elm functions

| Old | New |
|-----|-----|
| `getUndoRedoMonacoValue` | `getUndoRedoEditorValue` |
| `getMonacoValue` | `getInitialEditorValue` |
| `monacoViewPart` | `editorViewPart` |
| `monacoValueModified` | `editorValueModified` |
| `updateMonacoValue` (JS) | `updateEditorValue` (JS) |
| `initMonaco` (JS) | `initEditor` (JS) |

### Elm actions/messages

| Old | New |
|-----|-----|
| `UpdateMonacoValue` | `UpdateEditorValue` |
| `MonacoEditorValueReceived` | `EditorValueReceived` |
| `ReceiveMonacoElementPosition` | `ReceiveEditorElementPosition` |
| `InitMonacoRequestReceived` | `InitEditorRequestReceived` |

### Model fields and variables

| Old | New |
|-----|-----|
| `monacoValue` (model field) | `editorValue` |
| `monacoModel` (local binding) | `editorModel` |
| `currentMonacoValue` (local) | `currentEditorValue` |
| `newMonacoValue` (local) | `newEditorValue` |
| `updatedMonacoValue` (local) | `updatedEditorValue` |

### HTML element ID

| Old | New |
|-----|-----|
| `id "monaco"` | `id "code-editor"` |

### Module exports that change

| Module | Old export | New export |
|--------|-----------|------------|
| ViewUndoRedo | `UndoRedoMonacoValue`, `getUndoRedoMonacoValue` | `UndoRedoEditorValue`, `getUndoRedoEditorValue` |
| ViewUndoRedoActions | `MonacoValue` | `EditorValue` |
| EditorAction | `MonacoValue` | `EditorValue` |
| SvgView | `MonacoState` | `EditorState` |
| InPorts | `monacoEditorSavedValue`, `initMonacoRequest` | `editorValueSaved`, `initEditorRequest` |
| OutPorts | `initMonacoResponse`, `updateMonacoValue` | `initEditorResponse`, `updateEditorValue` |
| Editor | `UpdateMonacoValue` (Action) | `UpdateEditorValue` (Action) |
| ViewControlActions | `monacoValueModified` | `editorValueModified` |
| AddViewActions | `monacoValueModified` | `editorValueModified` |

## Risks / Trade-offs

- **[Risk] Port name mismatch breaks the app silently** → **Mitigation**: Port renames are the first task, done carefully with a grep audit before and after. The app is tested after the rename to verify editor ↔ Elm communication still works (editor loads, undo/redo functions, file save triggers).

- **[Risk] DOM element ID mismatch** → **Mitigation**: The `"monaco"` → `"code-editor"` change touches three locations (one JS, two Elm). In the worst case, the Monaco editor fails to mount, which is highly visible.

- **[Risk] Large diff may conflict with other in-flight changes** → **Mitigation**: This is the only active change. The rename is mechanical — conflicts would be trivial to resolve.

- **[Trade-off] `EditorValue` is still somewhat coupled** — it describes `{ views, domain }`, which is the application's entire data model, not just editor state. But it's the value that flows through the editor (serialized as YAML), so the name is reasonable. A deeper rename (e.g., `Document`, `Model`) is out of scope.

## Open Questions

None. The rename mapping is complete and deterministic.
