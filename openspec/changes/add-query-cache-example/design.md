## Context

See `proposal.md` for motivation and the delta spec for requirements.

**How examples work today.** Examples are YAML files at the repo root, fetched at runtime by the editor (`Http.get`, `src/Pages/Editor.elm`) from `https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/<file>.yaml`. The landing page has one button per example (`src/Pages/Home.elm`) and one link constant per example (`src/Route.elm`) of the form `#/editor/main?link=<raw url>`. Six examples exist (Pastebin, Dropbox, Twitter, Social graph, Web crawler, Mint). Nothing is copied into `dist`; the published site serves the app only.

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
- relation routing points are optional; an empty list means auto-routing.

**Source material** (`solutions/system_design/query_cache`): one first-pass design, one scaled design that adds DNS and a load balancer, and Python for the query API (`QueryApi.parse_query`, `process_query`) and for the cache (`Cache`, `Node`, `LinkedList` with `move_to_front`, `append_to_front`, `remove_from_tail`). Assumptions worth keeping: 10 million users, 10 billion queries a month, 4,000 requests per second, 270 bytes per cache entry (50-byte query, 20-byte title, 200-byte snippet), 2.7 TB a month if every query were stored, LRU eviction, a TTL to refresh entries when page contents or page rank change.

**Relationship to the web crawler example.** Both exercises model a query API over a reverse index service, a document service and a memory cache. The web crawler example shows that search path as the consumer of the crawl pipeline; this example shows it as the subject, with the cache-aside path and the cache internals.

## Goals / Non-Goals

**Goals:**
- A seventh worked example faithful to the source at container level, both stages.
- Demonstrate what the other examples under-sell: a cache-aside read path and a container decomposed into a data structure and the policy over it.
- A minimal code change: one new file, two small edits, no new dependencies, no schema or renderer change.

**Non-Goals:**
- The sharded cache cluster. The source discusses three ways to spread the cache over many machines and consistent hashing, but neither diagram draws it; it stays in the memory cache's description.
- The `Node` class as its own component. It is the entry type both structures operate on, not a behaviour.
- Components for the query API. The source gives it code, but it is two methods (parse, then the cache-aside read) whose behaviour is the search path the container-level views already draw. The cache is the container the exercise is about.
- Modelling the stacked boxes of the scaled diagram as several instances. The schema has no instance count; horizontal scaling is described in prose.
- Refactoring the example list into data. Seven hardcoded examples exist; the eighth follows the same shape.
- Any change to the editor, renderer, validation, schema, ports, or the button row layout.

## Decisions

### D1. Name: "Query cache", file `query-cache.yaml`, system `search` "Search service"

The issue calls it a key-value store for a search engine, and the source folder is `query_cache`. "Query cache" names the subject of the exercise, which is the cache. The target system is `Search service` because the containers that own the path are the web server, the query API and the two index services, and only one of them is the cache. Alternative "Search cache" reads as a caching proxy rather than a cache over query results.

### D2. Three views: `main`, `initial`, `memory-cache`

| View | Shows | Why |
|------|-------|-----|
| `main` | The scaled design: client, DNS, load balancer, web server, query API, reverse index service, document service, memory cache | The flagship slice, and the landing-page target because the route opens `main` |
| `initial` | The search path before scaling: client, web server, query API, reverse index service, document service, memory cache | Shows one domain serving two stages |
| `memory-cache` | The cache with its three components | The container the source decomposes, and the point of the exercise |

View keys are `[a-z-]+` per the schema; all three conform.

### D3. The two stages differ by DNS and the load balancer, and nothing else

Drawing both stages is still worth three more elements of YAML: the difference between the source diagrams is exactly the two boxes that make the initial design single-machine and the scaled design a pool, and the second diagram draws every server as a stack of copies. The schema cannot express "three web servers", so the pools live in the descriptions ("runs as a pool behind the load balancer") and the views show one box each. The alternative - one view - would drop the exercise's first scaling step, which is the part an interviewer asks about.

### D4. Components of the memory cache

| Component key | Name | Responsibility | Relations |
|---|---|---|---|
| `query-lookup` | Key lookup table | A hash table from the query to the list entry that holds its results, so a hit does not walk the list | `point at the list entry of each query - lru-list` |
| `lru-list` | LRU list | Doubly-linked list of cached entries: new and touched entries move to the head, expired entries leave from the tail | (none) |
| `cache-policy` | Cache policy | Serves a get by moving the entry to the front, serves a set by adding or updating at the front, evicts the tail when the cache is at capacity, and lets a TTL expire entries when page contents or rank change | `look the query up in the table - query-lookup`, `move, add and evict entries - lru-list` |

Ordering a get and a set as one relation each was rejected: they connect the same two boxes and the renderer draws no relation label on the canvas, so two edges would overlap into one indistinguishable line. One relation naming both keeps the interaction visible.

The container-level relation `query-api -> memory-cache` stays in the domain because the `main` and `initial` views draw it at container level. In the `memory-cache` view the container element declares no relations of its own - its components carry the edges - so the zoomed view does not draw container and component edges on top of each other.

### D5. One relation for the whole cache-aside path

The source's read path is one interaction from the query API's point of view: look in the cache, and on a miss read the index service and the document service and fill the cache. The query API therefore has three relations - `search the reverse index`, `read titles and snippets`, `read and fill cached results` - and the fill and the read are one relation rather than two, because a read relation and a fill relation between the same two boxes would overlap into one line.

### D6. The domain in outline

```
actors
  client                       send a search - web-server        [initial]
                               resolve connection - dns          [main]
                               send a search - load-balancer     [main]
systems
  dns                          (external, no containers)
  search  "Search service"
    containers
      load-balancer            forward requests - web-server                  [main]
      web-server               search request - query-api                     [main, initial]
      query-api                search the reverse index - reverse-index-service [main, initial]
                               read titles and snippets - document-service    [main, initial]
                               read and fill cached results - memory-cache    [main, initial]
      reverse-index-service    (ranks the matching documents)
      document-service         (returns the static titles and snippets)
      memory-cache             (serves the popular queries, evicting by LRU)
        components
          query-lookup         point at the list entry of each query - lru-list
          lru-list             (none)
          cache-policy         look the query up in the table - query-lookup
                               move, add and evict entries - lru-list
```

The `[main]`/`[initial]` markers name the views that draw each relation; the domain declares all of them. Both stages draw the whole search path; only the client's entry point and DNS differ.

Descriptions are adapted from the source prose and carry the numbers worth keeping (10 million users, 10 billion queries a month, 4,000 requests per second, 270 bytes per entry, 2.7 TB a month, 250 microseconds to read 1 MB from memory).

### D7. Layout seeded from the source diagrams

Coordinates are box centres read off the source images (scaled design 542x1096, first pass 490x812). Parents whose children appear in the same view are listed as derived.

`main`:

| Element | x | y |
|---|---|---|
| client | 150 | 65 |
| dns | 400 | 65 |
| load-balancer | 265 | 290 |
| web-server | 265 | 490 |
| query-api | 135 | 730 |
| reverse-index-service | 410 | 680 |
| document-service | 410 | 805 |
| memory-cache | 260 | 970 |
| search (system) | derived | derived |

`initial`:

| Element | x | y |
|---|---|---|
| client | 230 | 75 |
| web-server | 245 | 275 |
| query-api | 120 | 512 |
| reverse-index-service | 370 | 466 |
| document-service | 370 | 557 |
| memory-cache | 245 | 740 |
| search (system) | derived | derived |

`memory-cache` (hand-authored):

| Element | x | y |
|---|---|---|
| cache-policy | 250 | 400 |
| query-lookup | 500 | 340 |
| lru-list | 500 | 500 |
| memory-cache (container) | derived | derived |
| search (system) | derived | derived |

All relation routing points start empty and get tuned where an edge crosses a box or another edge. These views are sparse compared with the mint and web crawler examples, so few routing points are expected.

### D8. Landing page: a seventh button, no layout change

The button row is already a `wrappedRow` with `paddingXY 30 20` per button. A seventh button ("Query cache", ~190px) pushes the row wider, and it wraps the same way it does with six. No code or style change beyond the button itself.

## Risks / Trade-offs

- **The button cannot be exercised before merge.** Example links fetch from `master`, so a 404 ("Not able to download domain value by link") is expected until the YAML is merged. Verify locally by opening `#/editor/main?link=/query-cache.yaml` against the dev server, which serves root files.
- **Two examples share a search front end.** The web crawler example also draws a query API over the reverse index service, the document service and a memory cache. Mitigated by what each example adds: the crawler shows the crawl pipeline and the queues, this one shows the cache-aside path and the cache internals. A reader who opens both sees the same path twice, which is honest about the source material.
- **The two stages differ by two elements.** A reader may ask why the initial view exists. The answer is the load balancer - the first scaling step, and the one the source's own step 4 opens with - and the descriptions state it.
- **Horizontal scaling is invisible.** The scaled diagram draws pools of servers; the model draws one box each. Accepted: the schema has no counts, and the descriptions carry the "pool behind the load balancer" wording.
- **Component names are an interpretation.** The source has classes (`Cache`, `LinkedList`, and a dict) rather than a component diagram. A reader who disagrees can rename three keys without touching the layout.

## Migration Plan

None. The change is additive: one new YAML document and two Elm edits. Rollback is deleting the file and reverting the two edits; no stored model or schema changes, and no existing example is touched.
