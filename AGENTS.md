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

### Feature Workflow

Every feature starts from a GitHub issue (`gh issue list --repo RDBModel/rdbmodel.github.io`) and runs through OpenSpec. Work happens on `master`. The skills are in `.pi/skills/openspec-*`; the CLI is `openspec`.

**1. Explore** — read the issue, the source material it links, and the code the change touches. For an example, that means `src/Route.elm`, `src/Pages/Home.elm`, an existing example YAML, and the matching spec under `openspec/specs/`. Look for an archived change of the same shape in `openspec/changes/archive/` and reuse its decisions.

**2. Propose** — create the change and fill every artifact before writing code:

```bash
openspec new change <kebab-name>
openspec status --change <name> --json          # artifact order and paths
openspec instructions <artifact> --change <name> --json   # template + rules
openspec validate <name> --strict
```

Artifacts in dependency order: `proposal.md` (why, capabilities), `specs/<capability>/spec.md` (delta: ADDED/MODIFIED/REMOVED requirements, each with scenarios), `design.md` (decisions with alternatives, risks), `tasks.md` (numbered checkboxes, each stating how to verify). Reuse an existing capability path; only add a new one when nothing covers the behaviour.

**3. Apply** — work the tasks in order and tick `- [ ]` to `- [x]` as each one lands. Verify in the running app (`npm run dev`, then `playwright-cli`), not just by reading code. Three things that waste time if forgotten:

- The editor caches the model in `localStorage`. After editing a YAML example, close and reopen the browser (or clear storage and open a fresh page); a plain reload keeps serving the cached model.
- Stop the dev server before `openspec archive`. On Windows the Vite file watcher holds a lock and the archive move fails with `EPERM`; the spec sync silently rolls back with it.
- Check layout against geometry, not screenshots: read the rendered `rect` and `path` bounding boxes out of the SVG and assert no two boxes overlap and no edge crosses a box. Seed coordinates from the source diagram when one exists.

**4. Archive** — `openspec archive <name> --yes` writes the delta into `openspec/specs/` and moves the change to `openspec/changes/archive/YYYY-MM-DD-<name>/`. Mark the archived `tasks.md` complete once the post-deploy check passes.

**5. Publish** — commit in the project's order (implementation, then archive, then task ticks), then `git push origin master`. The `githubpage.yaml` workflow builds `dist` and pushes it to `gh-pages`; example YAML is fetched raw from `master`, so both halves ship with the same push. Wait for the run (`gh run watch <id> --exit-status`), then verify on the live site. The Pages CDN can serve a stale `index.html` for a minute after deploy.

**6. Close the issue** — comment with what shipped, the verification, and the URL, then `gh issue close <n> --reason completed`. See the issue #30 and #32 comments for the house style.

`.playwright-cli/` is scratch output and is gitignored; leave it out of commits.

### Elm Conventions

- Module names follow directory structure (e.g., `src/Domain/Validation.elm` → `Domain.Validation`)
- Strong use of opaque types and custom types for domain modelling
- `mdgriffith/elm-ui` for declarative layout (no raw CSS/HTML in Elm views)
- Custom YAML parser (`src/Yaml/Parser/`) — be aware this is a custom implementation, not the JS `yaml` library
