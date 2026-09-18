## Why

Issue #31 asks for the Mint design, the next exercise from the system-design-primer series the existing examples are drawn from. It is the first example whose two stages differ by a read path added later: the initial design is write-heavy (2,000 transaction writes against 200 reads per second) and the scaled design introduces a read API, a memory cache, read replicas and a CDN around it. It is also the first example where the source decomposes two containers rather than one, and the first with a batch job (MapReduce) as a container's inner structure. The gallery currently shows queues and a background worker, but no read/write split and no batch processing.

## What Changes

- Add `mint.yaml` at the repo root: a C4 model of a personal finance aggregator, adapted from the system-design-primer `mint` exercise.
- The example ships **four views**:
  - `main` - the scaled design (client, DNS, CDN, load balancer, web server, accounts API, read API, queue, transaction extraction service, category service, budget service, notification service, SQL database, SQL read replicas, object store, memory cache). This is what the home page button opens.
  - `initial` - the first-pass design: the write path before the read path was split out, without DNS, CDN, load balancer, read API, memory cache and read replicas.
  - `category-service` - a component-level zoom into the category service (seller-to-category map, crowd overrides, categorizer).
  - `budget-service` - a component-level zoom into the budget service (budget template, spending aggregation job, budget alerts).
- Break down exactly the two containers the source material decomposes into classes, and no others.
- Add a sixth example button ("Mint") to the landing page and its link constant to the router.

No behavior changes to the editor, renderer, or domain validation.

## Capabilities

### New Capabilities
<!-- none: the example gallery is an existing capability -->

### Modified Capabilities
- `home-examples`: the gallery gains the Mint example, whose model must show the write path at both stages and one container decomposed into components.

## Impact

- New file: `mint.yaml` (repo root, served by `raw.githubusercontent.com` from `master`, like the other examples).
- `src/Route.elm`: one new `editorLinkMint` constant.
- `src/Pages/Home.elm`: sixth button.
- No Elm types, decoders, ports, or JS changes. No new dependencies. No layout change to the button row (it already wraps).
- The home page example links fetch from `master`, so the button only works after the YAML is merged and published.
