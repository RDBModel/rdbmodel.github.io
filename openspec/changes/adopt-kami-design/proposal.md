## Why

The RDB app looks like a bare HTML page: pure-white surfaces, cool grays, default
browser controls, blue links, an emoji-covered landing page, and a grid canvas
in neutral gray. Issue #39 asks whether the app can adopt the **Kami design
language** (as already adapted for a screen app in
[`folio/DESIGN.md`](https://github.com/ypyl/folio/blob/master/DESIGN.md)) so it
reads as a professional architecture tool rather than a prototype.

Kami compresses to one sentence: *warm parchment canvas, ink-blue accent, serif
carries hierarchy, avoid cool grays and hard shadows.* Folio has already turned
that into concrete tokens and screen-app rules. This change applies those tokens
and rules to every surface RDB owns — landing page, editor chrome, and the
diagram canvas — without changing what the app does.

## What Changes

- **Design tokens**: introduce a single source of truth for the Kami palette
  (parchment `#f5f4ed`, ivory `#faf9f5`, warm sand `#e8e6dc`, ink blue
  `#1B365D`, warm neutrals `#141413`/`#3d3d3a`/`#504e49`/`#6b6a64`, borders
  `#e8e6dc`/`#e5e3d8`) plus matching CSS custom properties for the raw-CSS layer.
- **Landing page**: replace the emoji list and default controls with a serif
  heading, muted body copy, one primary "Start" action, secondary example
  buttons, and an ivory feature panel. Every existing example entry stays.
- **Editor chrome**: warm-neutral selects, buttons, context menus, splitter, and
  undo/redo controls; ink-blue as the only accent; no pure-white surfaces.
- **Diagram canvas**: parchment background, warm hairline grid, ivory nodes with
  warm borders and near-black labels, ink-blue selection/highlight instead of
  raw `blue`/`black`/`yellow`.
- **Typography**: system serif for headings, system sans for UI chrome, per
  Kami's type rules (weights 400/500, no synthetic bold, tight headline leading).
- **Monaco theme**: a light theme whose background and tokens match parchment
  and the warm palette, so the editor pane belongs to the same page.

No behavior, schema, YAML format, or routing changes. This is presentation only.

## Capabilities

### New Capabilities

- `design-language`: The visual system of the application — which palette,
  typography, accent rule, and surface treatments every screen and the diagram
  canvas must use.

### Modified Capabilities

None. `home-examples` describes *which* examples exist and the link contract;
this change does not add, remove, or relink any example, so its requirements
stand as written.

## Impact

- **Elm**: `src/Pages/Home.elm`, `src/Pages/Editor.elm`, `src/ViewEditor/*`
  (container, edges, grid, selection), `src/ViewControl/*`, `src/ContainerMenu/*`,
  `src/SplitPanel/SplitPane.elm`, `src/UndoRedo/ViewUndoRedo.elm`,
  `src/FilePicker.elm`, `src/Error/Error.elm`. A new `src/Theme.elm` holds the
  palette.
- **JS/CSS**: `index.html` global CSS and `:root` custom properties; `index.js`
  Monaco theme registration and `meta theme-color`.
- **No dependency changes**: no web fonts are downloaded; system font stacks
  only.
- **No user-visible behavior change** beyond appearance: all routes, example
  links, editing, undo/redo, save/open, and validation stay identical.
