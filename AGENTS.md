## RDB Model

A single-page web application for creating and visualising **C4 model** software architecture diagrams. You define your architecture in YAML and see live-rendered diagrams (actors, systems, containers, components, and relationships).

### Tech Stack

| Layer | Technology |
|-------|-----------|
| **App** | Elm 0.19.1 (The Elm Architecture) |
| **Build** | Vite with `vite-plugin-elm` |
| **Code Editor** | Monaco Editor 0.40 + `monaco-yaml` (YAML schema validation) |
| **YAML** | `yaml` (JS, for error decorations) + custom Elm YAML parser |
| **Visualisation** | SVG via `elm-community/typed-svg`, `gampleman/elm-visualization` |
| **UI** | `mdgriffith/elm-ui` |
| **Dev Container** | Node 16 with Elm toolchain pre-installed |

### Architecture

```
index.js ──ports──▶ Elm (Main.elm) ──▶ Pages (Home / Editor)
    ▲                    ▲
    │                    │
 Monaco Editor    Elm SVG rendering
 (left panel)     (right panel)
```

- **`index.js`** — JS entry point. Initialises Monaco editor, manages YAML error decorations via ports, handles File System Access API (open/save), and localStorage persistence.
- **`src/Main.elm`** — Elm SPA entry. Two routes: `Home` (landing page) and `Editor` (the main workspace).
- **`src/Pages/Editor.elm`** — Main editor page. Orchestrates the split-pane layout, YAML editing, domain model, views, and undo/redo.
- **`src/Domain/`** — Core domain types (`Domain.elm`), JSON/YAML decode/encode (`DomainDecoder.elm`, `DomainEncoder.elm`), and domain validation (`Validation.elm`). The `Domain` model is a tree: actors/flat, systems → containers → components (nested).
- **`src/Yaml/`** — Custom YAML parser and encoder written in Elm, used for the in-Elm YAML model that drives the SVG visualisation (separate from the Monaco YAML used for the editor).
- **`src/ViewEditor/`** — SVG rendering of C4 diagrams: drawing containers, edges (with arbitrary routing points), zoom/pan, and drag-to-move.
- **`src/ViewControl/`** — View management (CRUD views, filtering elements).
- **`src/ContainerMenu/`** — Right-click context menus on diagram elements.
- **`src/SplitPanel/`** — Custom split-pane component with draggable divider, bounds, and percentage-based layout.
- **`src/UndoRedo/`** — Undo/redo stack for view element positions.
- **`src/Navigation/`** — View-to-view navigation (panning to specific containers).

### Communication Flow (Elm ↔ JS)

Elm **ports** (`InPorts.elm`, `OutPorts.elm`) bridge JS and Elm:
- **JS → Elm**: editor value changes, file open/save requests, localStorage retrieval, zoom events, container focus
- **Elm → JS**: initialise Monaco, update editor value, send validation errors (for decoration), save to localStorage, trigger file dialogs

### Key Files

| File | Purpose |
|------|---------|
| `index.html` | HTML shell + CSS for Monaco decorations, select inputs, buttons |
| `index.js` | JS glue — Monaco init, error decoration, file I/O, ports wiring |
| `vite.config.js` | Vite config with Elm and Monaco editor plugins |
| `schema.json` | JSON Schema for C4 model YAML (used by monaco-yaml for validation/intellisense) |
| `elm.json` | Elm dependencies and source directories |
| `example.yaml` / `dropbox.yaml` / `twitter.yaml` / `pastebin.yaml` / `init.yaml` | Example C4 model YAML files |

### Running Locally

```bash
npm install
npm run dev     # Vite dev server
npm run build   # Production build
```

The dev container (`.devcontainer/`) handles the Elm toolchain automatically via Docker.

### Elm Conventions

- Module names follow directory structure (e.g., `src/Domain/Validation.elm` → `Domain.Validation`)
- Strong use of opaque types and custom types for domain modelling
- `mdgriffith/elm-ui` for declarative layout (no raw CSS/HTML in Elm views)
- Custom YAML parser (`src/Yaml/Parser/`) — be aware this is a custom implementation, not the JS `yaml` library
