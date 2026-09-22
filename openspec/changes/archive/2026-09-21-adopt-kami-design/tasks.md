## 1. Palette and global CSS

- [x] 1.1 Add `src/Theme.elm` exporting the Kami tokens as `Rgb` triples plus `toElement`, `toSvg`, `toCss`, and a serif/sans font stack. Verify: `npx elm make src/Main.elm --output=/dev/null` compiles.
- [x] 1.2 Add `:root` CSS variables and body background/font/colour to `index.html`, restarting every cool gray and `white` (button, select, scrollbar, error, highlight). Verify: grep `index.html` for `#ffffff`, `white`, `#cccccc`, `#e9e9e9`, `yellow` returns no surface value.
- [x] 1.3 Add `<meta name="theme-color" content="#1B365D">` and remove the transparent favicon placeholder if it paints white. Verify: read the head of the page in the browser.

## 2. Landing page

- [x] 2.1 Rewrite `src/Pages/Home.elm` layout on parchment with a serif heading, muted body copy, and no emoji. Verify: the page renders on `#f5f4ed` and the heading computes to a serif family.
- [x] 2.2 Render the start action as the primary variant and every example entry as the secondary variant, keeping all `Route.editorLink*` targets and labels. Verify: all example entries are listed and each opens its model.
- [x] 2.3 Render the feature copy as an ivory grid of title + one-line entries. Verify: the rendered grid has no overlapping boxes or clipped text at 1440x900 and 900x700.

## 3. Diagram canvas

- [x] 3.1 Set the canvas background to parchment and recolour the minor/major grid to warm neutrals in `src/ViewEditor/SvgView.elm`. Verify: the rendered `#main-graph` computed background is `#f5f4ed` and no grid stroke is `#cccccc`.
- [x] 3.2 Recolour node fill, stroke, label background, selection, and highlight in `src/ViewEditor/DrawContainer.elm`. Verify: a node `rect` has ivory fill and an olive stroke, and selection uses `#1B365D`.
- [x] 3.3 Recolour edges, relation labels, corner handles, and the point marker in `src/ViewEditor/DrawEdges.elm` and `src/ViewEditor/SvgView.elm`. Verify: drawn edges use a warm dark stroke, not pure black.
- [x] 3.4 Recolour the navigation, add-view, context-menu, and splitter chrome (`src/Navigation/ViewNavigation.elm`, `src/ViewControl/*.elm`, `src/ContainerMenu/*.elm`, `src/SplitPanel/SplitPane.elm`) to warm surfaces and the two button variants. Verify: no inline `white` or `#cccccc` background remains in those files.

## 4. Editor pane

- [x] 4.1 Register a parchment Monaco theme in `index.js` and create the editor with it. Verify: the editor pane background reads `#f5f4ed` and YAML is still editable and validated.
- [x] 4.2 Check `src/UndoRedo/ViewUndoRedo.elm` and `src/FilePicker.elm` disabled/hover states against the new global button CSS. Verify: disabled controls are visibly muted and enabled ones are legible.

## 5. Verification

- [x] 5.1 `npm run build` succeeds with zero Elm compile errors.
- [x] 5.2 Run the app and screenshot the landing page and an example editor at 1440x900; confirm the palette, serif heading, primary/secondary buttons, parchment canvas.
- [x] 5.3 Read rendered geometry: assert no two diagram node `rect` boxes overlap and no edge path crosses a box in the opened example, and that the landing grid has no overlapping cards.
- [x] 5.4 Grep the tree for the retired colours (`Color.blue`, `Color.black`, `Color.white`, `"yellow"`, `#cccccc`, `rgba(204, 204, 204`, `"white"`) in `src/` and `index.html`; expectation: only the `:root`/`Theme.elm` definitions and the sanctioned palette remain.
- [x] 5.5 Confirm the `index.html` `:root` hex set matches `Theme.elm` token for token.

## 6. Post-deploy check

- [x] 6.1 After the GitHub Pages deploy, open the live landing page and an example editor and confirm the parchment palette, serif heading, primary/secondary buttons, and parchment canvas are all served from the published build.
