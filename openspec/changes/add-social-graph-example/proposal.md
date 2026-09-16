## Why

The landing page is the first thing a visitor sees, and it currently offers three worked examples (Pastebin, Dropbox, Twitter). Issue #32 asks for a fourth: the social network / social graph design from the system-design-primer exercise. That design is the strongest teaching example available because the source material documents the same system twice - a first-pass design and a scaled one - which is exactly what this tool's multi-view model is for. A new example that only showed containers would under-sell the tool.

## What Changes

- Add `social-graph.yaml` at the repo root: a C4 model of friend search over a social network connection graph, adapted from the system-design-primer `social_graph` exercise.
- The example ships **three views**:
  - `main` - the scaled design (client, DNS, load balancer, reverse proxy, query API, user graph service, lookup service, person server, memory cache). This is what the home page button opens.
  - `initial` - the first-pass design before scaling: the same containers minus load balancer, DNS and cache.
  - `graph-service` - a component-level zoom into the user graph service (BFS traversal, person loading, path assembly).
- Break down exactly one container into components (`user-graph-service`), because it is the only container the source material actually decomposes (traversal, lookup, path assembly). No components are invented for the other six containers.
- Add a fourth example button ("Social graph") to the landing page and its link constant to the router.
- Make the example button row wrap instead of overflowing once four buttons are present.

No behavior changes to the editor, renderer, or domain validation.

## Capabilities

### New Capabilities
- `home-examples`: the landing page's gallery of worked examples - which examples are offered, and the contract that each one is a YAML model published at a stable URL that opens in the editor on a named view.

### Modified Capabilities
<!-- none: editor, rendering, and validation behavior are unchanged -->

## Impact

- New file: `social-graph.yaml` (repo root, served by `raw.githubusercontent.com` from `master`, like the other examples).
- `src/Route.elm`: one new `editorLinkSocialGraph` constant.
- `src/Pages/Home.elm`: fourth button, and the button row changed to a wrapped row.
- No Elm types, decoders, ports, or JS changes. No new dependencies.
- The home page example links fetch from `master`, so the button only works after the YAML is merged and published.
