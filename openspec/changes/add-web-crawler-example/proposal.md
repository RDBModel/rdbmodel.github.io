## Why

Issue #30 asks for a web crawler example, the next exercise from the system-design-primer series that the existing examples are drawn from. The design is the first example in the gallery whose two stages differ by an asynchronous pipeline (queues between the crawler and the index services), and whose only decomposed container is a background worker rather than a request-serving service. That makes it the example that shows message queues and decoupled background processing, which none of the four current examples show.

## What Changes

- Add `web-crawler.yaml` at the repo root: a C4 model of a web crawler and the search it feeds, adapted from the system-design-primer `web_crawler` exercise.
- The example ships **three views**:
  - `main` - the scaled design (client, DNS, load balancer, web server, query API, reverse index service, document service, index queue, document queue, crawler service, NoSQL database, memory cache). This is what the home page button opens.
  - `initial` - the first-pass design: the same system before scaling, without DNS, load balancer and memory cache.
  - `crawler-service` - a component-level zoom into the crawler service (crawl scheduler, page fetcher, pages data store).
- Break down exactly one container into components (`crawler-service`), because it is the only container the source material actually decomposes. No components are invented for the other eight containers.
- Add a fifth example button ("Web crawler") to the landing page and its link constant to the router.
- Generalize the landing page spec requirement that enumerates the existing examples, so it no longer names a fixed list that each new example invalidates.

No behavior changes to the editor, renderer, or domain validation.

## Capabilities

### New Capabilities
<!-- none: the example gallery is an existing capability -->

### Modified Capabilities
- `home-examples`: the gallery gains the web crawler example, and the requirement listing the other examples is stated without a fixed enumeration so adding an example does not require editing it.

## Impact

- New file: `web-crawler.yaml` (repo root, served by `raw.githubusercontent.com` from `master`, like the other examples).
- `src/Route.elm`: one new `editorLinkWebCrawler` constant.
- `src/Pages/Home.elm`: fifth button.
- No Elm types, decoders, ports, or JS changes. No new dependencies. No layout change to the button row (it already wraps).
- The home page example links fetch from `master`, so the button only works after the YAML is merged and published.
