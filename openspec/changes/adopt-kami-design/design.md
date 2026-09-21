## Context

See `proposal.md` for motivation. The constraints that shape the approach:

- The app mixes three styling layers: elm-ui (`Element` attributes), raw
  `Html.Attributes.style` strings inside elm-ui and SVG code, and global CSS in
  `index.html`. There is no existing theme module and no CSS variable layer.
- Colours are currently scattered as `Color.blue`, `Color.black`, `Color.white`,
  `"white"`, `"yellow"`, `#cccccc`, and `rgba(204, 204, 204, .6)`.
- elm-ui's `Element.Color` is an opaque type distinct from `avh4/elm-color`'s
  `Color.Color`, which TypedSvg needs. The existing code bridges them with a
  local `mapColor` in `Home.elm`.
- Monaco is themed with its built-in `vs` theme; there is no custom theme.
- The app must keep working offline: no downloadable web fonts.

## Goals / Non-Goals

**Goals:**

- One palette definition that both Elm and the global CSS derive from, so the
  two layers cannot drift silently.
- Apply it to the landing page, editor chrome, and diagram canvas.
- Keep the diff mechanical where possible: change colour values, not layout or
  behaviour.

**Non-Goals:**

- No dark theme (Kami's dark tokens exist but the app has no theme switch).
- No downloadable fonts; system stacks only.
- No change to YAML, routing, examples, ports, or any interaction.
- No component library or CSS framework.

## Decisions

### Decision 1: A `src/Theme.elm` module holds the palette as `( Int, Int, Int )` triples

The module exposes each Kami token once as a `Rgb` triple plus three
converters: `toElement` (elm-ui), `toSvg` (TypedSvg/avh4), and `toCss` (raw
style strings). Call sites become `Theme.toElement Theme.parchment` or
`Theme.toCss Theme.brand`.

The alternative — three parallel lists of typed colours (`Element.Color`,
`Color.Color`, `String`) — is what causes drift. One triple plus converters
means a hex value appears exactly once in Elm.

The alternative — no module, keep literals inline — was rejected: the palette
would then live in ~8 files.

### Decision 2: Global CSS uses `:root` variables mirroring the same tokens

`index.html` styles that Elm cannot reach (native `button`, `select`, scrollbar,
error decoration, `body`) read `var(--parchment)` etc. The variables are the
only other place a hex appears, and a comment in both files states that
`Theme.elm` and the `:root` block mirror each other.

The alternative — generate the CSS variables from Elm — is not possible
without a build step; not worth it for a fixed palette.

### Decision 3: System font stacks, serif for headings

`body` gets `system-ui`/`Segoe UI` sans; headings get
`Georgia, 'Iowan Old Style', 'Times New Roman', serif` via elm-ui
`Font.family`. Kami's serif-first typography is what makes paper feel like
paper, and a system serif needs no download. Folio deferred serif because its
type system is a document system; RDB's headings are a handful of elements, so
the risk is small.

### Decision 4: The landing page copy drops emoji and becomes a feature grid

The emoji-per-paragraph list is the single strongest signal of the old look.
The copy keeps its meaning but is regrouped into short feature entries
(title + one line) rendered as ivory cards. Example entries keep their exact
labels and links (`Route.editorLink*`), so `home-examples` is untouched.

### Decision 5: Diagram colours map to tokens, structure unchanged

| Current | Token |
|---|---|
| `Color.white` node fill, label background | ivory `#faf9f5` |
| `Color.black` node/edge stroke | dark warm `#3d3d3a` |
| `Color.blue` selection / corner handle | brand `#1B365D` |
| `"yellow"` highlighted label background | brand tint `#EEF2F7` |
| `#cccccc` grid lines | border soft `#e5e3d8` (minor), stone at low opacity (major) |
| canvas / svg background | parchment `#f5f4ed` |

No geometry, hit area, or routing changes — only paint values.

### Decision 6: Monaco gets a custom light theme registered before `create`

`monaco.editor.defineTheme('rdb-parchment', …)` sets `editor.background` to
parchment and maps YAML token scopes to the palette. The editor is created with
`theme: 'rdb-parchment'`. If the theme id is ever missing, Monaco falls back to
`vs`, so this cannot break editing.

### Decision 7: Highlight/selection colour is a pale brand tint, not `yellow`

The current `yellow` highlight for the element linked from the text editor is
the only non-blue chromatic colour in the app and violates the one-accent rule.
It becomes `--brand-tint`, which still reads as "this one".

## Risks / Trade-offs

- **[Risk] `Theme.elm` and `:root` drift** → Mitigation: both carry a comment
  naming the other as the mirror; the tasks include a check that the hex set in
  `index.html` matches `Theme.elm`.
- **[Risk] Low-contrast borders make diagram boxes hard to see on parchment** →
  Mitigation: node borders use `--olive` (a mid warm gray), not `--border`, so
  they stay visible; verified by reading the rendered `rect` stroke and by
  screenshot.
- **[Risk] Monaco theme token scopes differ from expectation (YAML may use
  `type`/`string` rather than `keyword`)** → Mitigation: base theme is `vs` with
  `inherit: true`, so unmapped scopes keep readable defaults; verified visually.
- **[Trade-off] Landing copy changes** — meaning preserved but wording
  shortened. If the original wording matters, it can be restored without
  touching the design tokens.
- **[Trade-off] No dark mode** — the palette is light-only, matching today's
  app. Kami's dark tokens are left unused.

## Migration Plan

Single deploy: the change is presentation-only and gated by the GitHub Pages
workflow like any other push to `master`. Rollback is `git revert`; no data,
schema, or storage migration is involved.
