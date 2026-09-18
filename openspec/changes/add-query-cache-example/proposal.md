## Why

Issue #33 asks for the query cache example, the next exercise from the system-design-primer series the existing examples are drawn from. It is the only exercise in the series whose subject is a single data structure: the source gives code for the cache itself (a hash table over a doubly-linked list with an LRU policy) rather than for a service. The gallery already shows a memory cache as a container, but none of the existing examples opens a data structure up, and none shows a cache-aside path.

## What Changes

- Add `query-cache.yaml` at the repo root: a C4 model of the search path behind a query cache, adapted from the system-design-primer `query_cache` exercise.
- The example ships **three views**:
  - `main` - the scaled design (client, DNS, load balancer, web server, query API, reverse index service, document service, memory cache). This is what the home page button opens.
  - `initial` - the first-pass design: the same search path without DNS and the load balancer.
  - `memory-cache` - a component-level zoom into the cache (the key lookup table, the LRU list and the policy that drives them).
- Break down exactly the container the source material decomposes (the memory cache) and no others.
- Add a seventh example button ("Query cache") to the landing page and its link constant to the router.

No behavior changes to the editor, renderer, or domain validation.

## Capabilities

### New Capabilities
<!-- none: the example gallery is an existing capability -->

### Modified Capabilities
- `home-examples`: the gallery gains the query cache example, whose model must show the cache-aside search path at both stages and one container decomposed into components.

## Impact

- New file: `query-cache.yaml` (repo root, served by `raw.githubusercontent.com` from `master`, like the other examples).
- `src/Route.elm`: one new `editorLinkQueryCache` constant.
- `src/Pages/Home.elm`: seventh button.
- No Elm types, decoders, ports, or JS changes. No new dependencies. No layout change to the button row (it already wraps).
- The home page example links fetch from `master`, so the button only works after the YAML is merged and published.
