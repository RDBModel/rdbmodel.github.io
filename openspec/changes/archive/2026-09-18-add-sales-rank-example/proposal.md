## Why

Issue #34 asks for the Amazon sales rank example, the next exercise from the system-design-primer series the existing examples are drawn from. It is the first example whose subject is an hourly batch job writing a ranked result: the source gives code for a multi-step MapReduce whose second step sorts by units sold, and it is the first example where the write path and the read path meet in one aggregate table that the batch job produces. The gallery shows a batch job inside the budget service, but not a job whose whole purpose is to produce the table the read path serves.

## What Changes

- Add `sales-rank.yaml` at the repo root: a C4 model of Amazon's sales rank by category, adapted from the system-design-primer `sales_rank` exercise.
- The example ships **three views**:
  - `main` - the scaled design (client, DNS, CDN, load balancer, web server, sales API, read API, sales rank service, memory cache, SQL database, SQL read replicas, object store). This is what the home page button opens.
  - `initial` - the first-pass design: the same feature without DNS, the CDN, the load balancer, the memory cache and the read replicas.
  - `sales-rank-service` - a component-level zoom into the ranking job (the weekly window, the quantity totals and the distributed sort).
- Break down exactly the container the source material decomposes (the sales rank service) and no others.
- Add an eighth example button ("Sales rank") to the landing page and its link constant to the router.

No behavior changes to the editor, renderer, or domain validation.

## Capabilities

### New Capabilities
<!-- none: the example gallery is an existing capability -->

### Modified Capabilities
- `home-examples`: the gallery gains the sales rank example, whose model must show the hourly ranking job and the read path it feeds at both stages, and one container decomposed into components.

## Impact

- New file: `sales-rank.yaml` (repo root, served by `raw.githubusercontent.com` from `master`, like the other examples).
- `src/Route.elm`: one new `editorLinkSalesRank` constant.
- `src/Pages/Home.elm`: eighth button.
- No Elm types, decoders, ports, or JS changes. No new dependencies. No layout change to the button row (it already wraps).
- The home page example links fetch from `master`, so the button only works after the YAML is merged and published.
