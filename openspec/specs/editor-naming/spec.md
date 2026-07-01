## ADDED Requirements

### Requirement: Application identifiers are editor-agnostic

The codebase SHALL use editor-agnostic naming for all application-level identifiers (types, functions, ports, model fields, actions, messages, and DOM element IDs). Identifiers SHALL NOT reference "Monaco" unless they directly invoke the Monaco Editor library API.

#### Scenario: No "Monaco" in application type names
- **WHEN** reviewing Elm type aliases and custom types
- **THEN** no type name contains "Monaco" — types use "Editor" or context-appropriate generic names

#### Scenario: No "Monaco" in port names
- **WHEN** reviewing Elm port declarations in `InPorts.elm` and `OutPorts.elm`
- **THEN** no port name contains "Monaco" — ports use "Editor" terminology

#### Scenario: No "Monaco" in JS application function names
- **WHEN** reviewing application-level JavaScript functions in `index.js`
- **THEN** no function name contains "Monaco" unless it directly wraps a Monaco API call (e.g., `monaco.editor.create`)

#### Scenario: No "Monaco" in DOM element IDs used by application code
- **WHEN** reviewing HTML element IDs that serve as editor mount points
- **THEN** no element ID contains "Monaco" — IDs use generic editor terminology

#### Scenario: Library imports and API calls are preserved
- **WHEN** reviewing imports and direct Monaco API invocations
- **THEN** `import * as monaco from 'monaco-editor'` and calls like `monaco.editor.create(...)`, `monaco.Range(...)` remain unchanged

### Requirement: Identical runtime behavior after rename

The application SHALL behave identically after the rename as before. All existing functionality — YAML editing, diagram rendering, undo/redo, file open/save, localStorage persistence, validation error decorations — SHALL continue to work without regression.

#### Scenario: Editor loads and displays YAML content
- **WHEN** the application starts on the editor page
- **THEN** the code editor mounts at its DOM element and displays the initial YAML content

#### Scenario: Undo and redo function correctly
- **WHEN** the user modifies the YAML and invokes undo (Ctrl+Z) or redo (Ctrl+Y)
- **THEN** the editor content reverts or restores correctly, and the undo/redo button states update

#### Scenario: File save triggers correctly
- **WHEN** the user presses Ctrl+S or triggers save
- **THEN** the current editor value is sent to Elm and saved to file or localStorage

#### Scenario: Editor value updates propagate to the diagram
- **WHEN** the user modifies the YAML in the editor
- **THEN** the diagram on the right panel re-renders to reflect the changes
