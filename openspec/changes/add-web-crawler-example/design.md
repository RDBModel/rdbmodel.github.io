## Context

See `proposal.md` for motivation and the delta spec for requirements.

**How examples work today.** Examples are YAML files at the repo root, fetched at runtime by the editor (`Http.get`, `src/Pages/Editor.elm`) from `https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/<file>.yaml`. The landing page has one button per example (`src/Pages/Home.elm`) and one link constant per example (`src/Route.elm`) of the form `#/editor/main?link=<raw url>`. Four examples exist (Pastebin, Dropbox, Twitter, Social graph). Nothing is copied into `dist`; the published site serves the app only.

**The link names the view.** The route carries both a link and a view name, and every example link opens a view named `main`, so an example without a `main` view shows an unresolved view from the landing page.

**How views constrain the model** (`src/Domain/Validation.elm`):
- every relation key listed under a view element must be a relation declared for that same element in the domain;
- every view element key must exist in the domain;
- element keys are unique across the whole domain (actors, systems, containers and components share one namespace);
- every relation target must resolve to an existing element.

**Geometry** (`src/Domain/DomainDecoder.elm`, `src/Domain/Domain.elm:197`):
- every element is 100x50 by default; width and height are not expressible in YAML;
- `x`/`y` are the box centre;
- a parent whose children are in the same view has its centre and size recomputed from those children (5px padding left/bottom/right, 25px top for the title), so hand-tuned coordinates are needed only for elements without children in that view;
- relation routing points are optional; an empty list means auto-routing, so layouts can be authored first and tuned later.

**Source material** (`solutions/system_design/web_crawler`): one first-pass design, one scaled design, and Python for the crawler service only (`Crawler.crawl`, `Crawler.crawl_page`, `PagesDataStore`). Drafting notes: 1 billion links to crawl, refreshed about weekly (4 billion crawled per month), 500 KB per page (2 PB per month, 72 PB over three years), 1,600 crawl writes per second, 40,000 searches per second, 100 billion searches per month. The exercise forbids using an existing crawler or search engine.

## Goals / Non-Goals

**Goals:**
- A fifth worked example faithful to the source at container level, including the queues the source diagram draws.
- Demonstrate what the other examples under-sell: an asynchronous pipeline (services that talk through queues, not direct calls) and a background worker as the decomposed container.
- A minimal code change: one new file, two small edits, no new dependencies, no schema or renderer change.

**Non-Goals:**
- Components for the other eight containers. The source decomposes one container, so the example decomposes one.
- The duplicate-URL MapReduce job, robots.txt handling, or crawl scheduling policy as modelled elements. They are described, not drawn: they are not in either source diagram.
- Refactoring the example list into data. Five hardcoded examples exist; the sixth follows the same shape. Revisit when the duplication actually costs something.
- Any change to the editor, renderer, validation, schema, ports, or the button row layout.

## Decisions

### D1. Name: "Web crawler", file `web-crawler.yaml`

Matches the issue title, the source folder and the source exercise. The system is named `Web crawler` even though the domain also covers the search path, because crawling is the exercise and the search services are its consumers. Alternative "Search engine" describes the user-facing half and hides the crawl pipeline, which is the part this example exists to show. Vetoing either is a one-word change.

### D2. Three views: `main`, `initial`, `crawler-service`

| View | Shows | Why |
|------|-------|-----|
| `main` | The scaled design: client, DNS, load balancer, web server, query API, reverse index service, document service, index queue, document queue, crawler service, NoSQL database, memory cache | The flagship slice, and the landing-page target because the route opens `main` |
| `initial` | The first-pass design: client, web server, query API, reverse index service, document service, index queue, document queue, crawler service, NoSQL database | Shows one domain serving two stages of the same design |
| `crawler-service` | The crawler service decomposed, with the queues, database and websites it talks to | Shows the fourth C4 level and the asynchronous edges |

View keys are `[a-z-]+` per the schema; all three conform.

### D3. Two queues, not one

The source diagram draws one queue between the crawler service and the reverse index service and a second between the crawler service and the document service. The model keeps both (`index-queue`, `document-queue`) because collapsing them into one shared queue would change the design: the two consumers have different throughput and failure characteristics, and the diagram is explicit. Cost: two near-identical containers and two near-identical relation labels.

### D4. One domain, both stages - no duplicated containers

The initial and scaled designs differ only by additions (DNS, load balancer, memory cache) and by which element the client talks to. Every container that exists in the first pass survives into the scaled design, so the domain holds the union and the `initial` view draws a subset. The client therefore needs two outbound relations - `search for a term - web-server` (initial) and `search for a term - load-balancer` (scaled) - and each view draws exactly one of them, as the social graph example does.

### D5. Components only in the crawler service

The source's Python maps to three components:

| Component key | Name | Responsibility | Relations |
|---|---|---|---|
| `crawl-scheduler` | Crawl loop | Takes the top-ranked link from `links_to_crawl`, checks whether a similar page was already crawled, lowers the priority of a duplicate, otherwise hands the page to the fetcher | `read top link and lower duplicate priority - pages-data-store`, `crawl the page - page-fetcher` |
| `page-fetcher` | Page fetcher | Fetches the page contents and child urls, builds the page signature, emits indexing and document jobs | `fetch page contents - websites`, `enqueue page for indexing - index-queue`, `enqueue page for documents - document-queue`, `store the page signature - pages-data-store` |
| `pages-data-store` | Pages data store | The abstraction over the key-value database for `links_to_crawl` and `crawled_links` | `read and write links to crawl - nosql-database` |

Duplicate detection (Jaccard index / cosine similarity, `RemoveDuplicateUrls`) is folded into `crawl-scheduler` rather than given a fourth component: the source discusses it in prose and a MapReduce job, not as a class.

Reading the top link and lowering the priority of a duplicate are one relation, not two. They are two methods in the source (`extract_max_priority_page`, `reduce_priority_link_to_crawl`), but they connect the same two boxes, and the renderer draws no relation label on the canvas, so two edges would overlap into one indistinguishable line. One relation labelled for both methods keeps the interaction visible.

The container-level relations `crawler-service -> index-queue`, `-> document-queue` and `-> nosql-database` stay in the domain because the `main` and `initial` views draw them at container level. In the `crawler-service` view the container element declares no relations of its own - its components carry the edges - so the zoomed view does not draw container and component edges on top of each other.

### D6. `websites` is the one element not in the source's container diagram

The crawler has nothing to crawl without the web it fetches from. The source treats the internet as an unstated input (the diagram starts at the crawler service), so `websites` is declared as an external system and drawn only in the `crawler-service` view, as the target of `fetch page contents`. It is deliberately absent from `main` and `initial`, which follow both source diagrams exactly. Alternative: leave it out and give `page-fetcher` no source; that would make the component view a dead end.

### D7. The domain in outline

```
actors
  client                       search for a term - web-server     [initial]
                               resolve connection - dns           [main]
                               search for a term - load-balancer  [main]
systems
  dns                          (external, no containers)
  websites                     (external, no containers)
  web-crawler  "Web crawler"
    containers
      load-balancer            forward requests - web-server                  [main]
      web-server               search request - query-api                     [main, initial]
      query-api                match query terms - reverse-index-service      [main, initial]
                               read titles and snippets - document-service    [main, initial]
                               read cached results - memory-cache             [main]
      reverse-index-service    (receives jobs from the index queue)
      document-service         (receives jobs from the document queue)
      index-queue              deliver index jobs - reverse-index-service     [main, initial]
      document-queue           deliver document jobs - document-service       [main, initial]
      crawler-service          enqueue pages to index - index-queue           [main, initial]
                               enqueue pages to document - document-queue     [main, initial]
                               read and write crawl state - nosql-database    [main, initial]
        components
          crawl-scheduler      read top link and lower duplicate priority - pages-data-store
                               crawl the page - page-fetcher
          page-fetcher         fetch page contents - websites
                               enqueue page for indexing - index-queue
                               enqueue page for documents - document-queue
                               store the page signature - pages-data-store
          pages-data-store     read and write links to crawl - nosql-database
      nosql-database           links_to_crawl and crawled_links (key-value store)
      memory-cache             popular query results                             [main]
```

The `[main]`/`[initial]` markers name the views that draw each relation; the domain declares all of them. Both stages draw the whole pipeline (query API, both services, both queues, crawler service, key-value database); only the edges change.

### D8. Layout seeded from the source diagrams

Coordinates are box centres read off the source images (scaled design 1078x1304, first pass 1014x912). Parents whose children appear in the same view need no meaningful coordinates - the app recomputes them - so they are listed as derived.

`main`:

| Element | x | y |
|---|---|---|
| client | 327 | 92 |
| dns | 672 | 88 |
| load-balancer | 397 | 310 |
| web-server | 397 | 505 |
| query-api | 147 | 792 |
| reverse-index-service | 397 | 717 |
| document-service | 397 | 860 |
| index-queue | 650 | 717 |
| document-queue | 650 | 860 |
| crawler-service | 905 | 792 |
| nosql-database | 640 | 1177 |
| memory-cache | 420 | 1012 |
| web-crawler (system) | derived | derived |

`initial`:

| Element | x | y |
|---|---|---|
| client | 487 | 92 |
| web-server | 487 | 285 |
| query-api | 150 | 537 |
| reverse-index-service | 399 | 491 |
| document-service | 399 | 591 |
| index-queue | 640 | 491 |
| document-queue | 640 | 591 |
| crawler-service | 867 | 537 |
| nosql-database | 492 | 785 |
| web-crawler (system) | derived | derived |

`crawler-service` (hand-authored, no source diagram):

| Element | x | y |
|---|---|---|
| websites | 450 | 120 |
| crawl-scheduler | 250 | 400 |
| page-fetcher | 480 | 400 |
| pages-data-store | 250 | 540 |
| index-queue | 800 | 380 |
| document-queue | 800 | 500 |
| nosql-database | 800 | 640 |
| crawler-service (container) | derived | derived |
| web-crawler (system) | derived | derived |

All relation routing points start empty and get tuned where an edge crosses a box or another edge. The component view is the only one whose layout is authored rather than copied from a source diagram, so its coordinates are the ones most likely to move.

### D9. Landing page: a fifth button, no layout change

The button row is already a `wrappedRow` with `paddingXY 30 20` per button, added when the fourth example landed. A fifth button ("Web crawler", ~215px) pushes the row past the landing page's ~760px content column, so the row wraps to two lines. That is the behaviour the existing `home-examples` requirement asks for ("wrap onto further lines, every entry fully visible"), so no code or style change beyond the button itself. Alternative: shrink the padding again; rejected because the row already wraps and the second line is now the expected steady state with five examples.

## Risks / Trade-offs

- **The button cannot be exercised before merge.** Example links fetch from `master`, so a 404 ("Not able to download domain value by link") is expected until the YAML is merged. Verify locally by opening `#/editor/main?link=/web-crawler.yaml` against the dev server, which serves root files.
- **Two nearly identical queues can read as copy-paste.** Mitigated by the names (`index-queue`, `document-queue`) and by the descriptions naming each consumer; accepted because the source diagram is explicit about two queues.
- **`websites` appears in only one view.** A reader who opens `main` first sees `page-fetcher`'s target in the component view only. Accepted: it keeps both container views faithful to the source diagrams, and views are slices by design.
- **Five buttons wrap to two lines on the landing page.** Accepted, and already the required behaviour; no test or style change is needed.
- **`initial` and `main` differ by only three elements and one client edge.** A reader may ask why two views exist. That is the point - the example shows the same domain at two stages - and the descriptions state it.
- **Component names are an interpretation.** The source has classes, not a component diagram. A reader who disagrees can rename three keys without touching the layout.

## Migration Plan

None. The change is additive: one new YAML document and two Elm edits. Rollback is deleting the file and reverting the two edits; no stored model or schema changes, and no existing example is touched.
