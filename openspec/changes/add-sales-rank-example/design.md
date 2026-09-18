## Context

See `proposal.md` for motivation and the delta spec for requirements.

**How examples work today.** Examples are YAML files at the repo root, fetched at runtime by the editor (`Http.get`, `src/Pages/Editor.elm`) from `https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/<file>.yaml`. The landing page has one button per example (`src/Pages/Home.elm`) and one link constant per example (`src/Route.elm`) of the form `#/editor/main?link=<raw url>`. Seven examples exist (Pastebin, Dropbox, Twitter, Social graph, Web crawler, Mint, Query cache). Nothing is copied into `dist`; the published site serves the app only.

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

**Source material** (`solutions/system_design/sales_rank`): one first-pass design, one scaled design, and Python for one container - the sales rank service (`SalesRanker`, a two-step MapReduce with `within_past_week`, `mapper`, `reducer`, `mapper_sort`, `reducer_identity`). Assumptions worth keeping: 10 million products, 1,000 categories, 1 billion transactions and 100 billion reads a month, a 100:1 read to write ratio, 400 writes and 40,000 reads per second, 40 bytes per transaction, 40 GB of new content a month and 1.44 TB over three years, results updated hourly.

**One place where the source disagrees with itself.** The prose says static content is served from the object store "which is cached on the CDN", as in the mint example. In the scaled diagram the long curve down the right side appears to land on the SQL read replicas instead. Serving static content from the read replicas is not a design that exists, so the model follows the prose: the CDN reads the object store. See D5.

## Goals / Non-Goals

**Goals:**
- An eighth worked example faithful to the source at container level, both stages.
- Demonstrate what the other examples under-sell: a batch job whose output is the table the read path serves, and a read path that never touches the writer.
- A minimal code change: one new file, two small edits, no new dependencies, no schema or renderer change.

**Non-Goals:**
- The general e-commerce site. The source scopes it out explicitly; the sales API is drawn as the source of transactions and nothing more.
- The data warehouse alternative (Redshift, BigQuery), the NoSQL move and the SQL scaling patterns the source lists as further steps. They are prose, and they belong to a third stage the example does not model.
- Components for the sales API and the read API. The source gives them no code.
- Refactoring the example list into data. Eight hardcoded examples exist; the ninth follows the same shape.
- Any change to the editor, renderer, validation, schema, ports, or the button row layout.

## Decisions

### D1. Name: "Sales rank", file `sales-rank.yaml`, system `amazon` "Amazon"

The domain is the feature the source designs ("Design Amazon's sales rank by category feature"), so the example is named for the feature, like "Social graph" and "Query cache". The target system is `Amazon` because its containers are the sales API, the read API and the sales rank service of one storefront, and naming the system "Sales rank" would collide with the container `sales-rank-service`.

### D2. Three views: `main`, `initial`, `sales-rank-service`

| View | Shows | Why |
|------|-------|-----|
| `main` | The scaled design: client, DNS, CDN, load balancer, web server, sales API, read API, sales rank service, memory cache, SQL database, SQL read replicas, object store | The flagship slice, and the landing-page target because the route opens `main` |
| `initial` | The feature before scaling: client, web server, sales API, read API, sales rank service, SQL database, object store | Shows one domain serving two stages |
| `sales-rank-service` | The ranking job with its three components, plus the object store and the database it reads and writes | The container the source decomposes, and the point of the exercise |

View keys are `[a-z-]+` per the schema; all three conform.

### D3. One SQL container across both stages, as in the mint example

The initial diagram draws a single "SQL" store; the scaled diagram draws "SQL Write Master-Slave" and "SQL Read Replicas". The write cluster is the initial store with a role spelled out, so the domain holds one `sql-database` container used by both stages plus `sql-read-replicas` for the scaled read path, and `sql-database` carries the `replicate writes - sql-read-replicas` relation. The mint example made the same call for the same reason.

### D4. Components of the sales rank service

| Component key | Name | Responsibility | Relations |
|---|---|---|---|
| `weekly-window` | Weekly window | Keeps only the transactions of the past week, so the ranking covers a rolling week and the hourly job stays cheap | (none) |
| `quantity-totals` | Quantity totals | The first MapReduce step: emits `(category, product)` with the quantity sold and sums it, giving each product's units sold in each category for the week | `keep only the past week - weekly-window`, `read the raw log entries - object-store` |
| `distributed-sort` | Distributed sort | The second MapReduce step: re-keys each total by `(category, quantity)` so the shuffle sorts products by units sold within a category, and the identity reducer writes the ranked list | `rank the totals - quantity-totals`, `write the sales rank - sql-database` |

`SalesRanker` is one class, so the split is an interpretation of its two `steps()`; naming the components after the two jobs and the one shared filter is the shape the source's own method names suggest. The container-level relations `sales-rank-service -> object-store` and `-> sql-database` stay in the domain because the `main` and `initial` views draw them at container level. In the component view the container element declares no relations of its own - its components carry the edges - so the zoomed view does not draw container and component edges on top of each other.

### D5. The CDN reads the object store, following the prose over the diagram

The scaled diagram's long curve down the right side appears to terminate at the SQL read replicas. The prose says static content is "served from the Object Store such as S3, which is cached on the CDN", and the mint example models it that way. A CDN with the read replicas as its origin is not a design, so the model has `cdn -> object-store` and no relation from the CDN to the replicas. This is recorded here rather than followed, because the diagram looks like a drawing slip: its curve passes under the object store before rising to the replicas.

### D6. The read path and the batch job do not touch

The read API reads the `sales_rank` table (from the memory cache, then the read replicas) and never calls the sales rank service. The batch job writes the table and never serves a request. The two sides meet only in the table, which is what the example demonstrates: an hourly job decoupled from a 40,000-reads-per-second path. The domain has no relation between the read API and the sales rank service, and the delta spec asserts that absence.

### D7. The domain in outline

```
actors
  client                       view popular products - web-server      [initial]
                               resolve connection - dns                [main]
                               load static content - cdn               [main]
                               view popular products - load-balancer   [main]
systems
  dns                          (external, no containers)
  amazon  "Amazon"
    containers
      load-balancer            forward requests - web-server                    [main]
      cdn                      cache static content - object-store               [main]
      web-server               record a transaction - sales-api                 [main, initial]
                               read popular products - read-api                 [main, initial]
      sales-api                store the transaction - sql-database              [main, initial]
                               store the raw log files - object-store           [main, initial]
      read-api                 serve popular products from cache - memory-cache  [main]
                               read the sales rank - sql-read-replicas          [main]
                               read the sales rank - sql-database               [initial]
      sales-rank-service       read the raw log files - object-store            [main, initial]
                               write the sales rank - sql-database              [main, initial]
        components
          weekly-window        (none)
          quantity-totals      keep only the past week - weekly-window
                               read the raw log entries - object-store
          distributed-sort     rank the totals - quantity-totals
                               write the sales rank - sql-database
      memory-cache             (serves the popular products and their rank)
      sql-database             replicate writes - sql-read-replicas              [main]
      sql-read-replicas        (serve the read traffic the cache misses)
      object-store             (raw transaction logs and static content)
```

The `[main]`/`[initial]` markers name the views that draw each relation; the domain declares all of them. The read API reads the single SQL store in the initial stage and the read replicas in the scaled stage, which is the same two-stage pattern the mint example uses. The object store accumulates both the raw log files and the static content, which is why the sales API, the sales rank service and the CDN all reach it.

Descriptions are adapted from the source prose and carry the numbers worth keeping (10 million products, 1,000 categories, 1 billion transactions and 100 billion reads a month, 100:1 read to write, 400 writes and 40,000 reads per second, 40 bytes per transaction, 40 GB a month and 1.44 TB over three years, hourly refresh, 250 microseconds to read 1 MB from memory).

### D8. Layout seeded from the source diagrams

Coordinates are box centres read off the source images (scaled design 924x1376, first pass 692x864). Parents whose children appear in the same view are listed as derived.

`main`:

| Element | x | y |
|---|---|---|
| client | 150 | 98 |
| dns | 490 | 95 |
| cdn | 497 | 213 |
| load-balancer | 345 | 410 |
| web-server | 345 | 610 |
| sales-api | 210 | 828 |
| read-api | 470 | 828 |
| sales-rank-service | 765 | 825 |
| memory-cache | 340 | 1035 |
| sql-database | 230 | 1240 |
| sql-read-replicas | 443 | 1240 |
| object-store | 730 | 1240 |
| amazon (system) | derived | derived |

`initial`:

| Element | x | y |
|---|---|---|
| client | 330 | 75 |
| web-server | 337 | 277 |
| sales-api | 120 | 508 |
| read-api | 337 | 508 |
| sales-rank-service | 567 | 508 |
| sql-database | 228 | 733 |
| object-store | 437 | 733 |
| amazon (system) | derived | derived |

`sales-rank-service` (hand-authored):

| Element | x | y |
|---|---|---|
| weekly-window | 250 | 380 |
| quantity-totals | 250 | 500 |
| distributed-sort | 250 | 620 |
| object-store | 700 | 420 |
| sql-database | 700 | 620 |
| sales-rank-service (container) | derived | derived |
| amazon (system) | derived | derived |

All relation routing points start empty and get tuned where an edge crosses a box or another edge. The `main` view is as dense as its source diagram, so it is the most likely to need routing points.

### D9. Landing page: an eighth button, no layout change

The button row is already a `wrappedRow` with `paddingXY 30 20` per button. An eighth button ("Sales rank") makes the row wrap the same way the seventh did. No code or style change beyond the button itself.

## Risks / Trade-offs

- **The button cannot be exercised before merge.** Example links fetch from `master`, so a 404 ("Not able to download domain value by link") is expected until the YAML is merged. Verify locally by opening `#/editor/main?link=/sales-rank.yaml` against the dev server, which serves root files.
- **A divergence from the source diagram.** D5 deliberately follows the prose where the two disagree. A reader comparing the model with the diagram will see one different edge; the memory cache's and the CDN's descriptions state what each caches.
- **The `main` view is dense.** Twelve elements and fourteen relations, with the crossing edges the source diagram has. Mitigated by seeding coordinates from the source and by checking that no edge crosses a box.
- **Component names are an interpretation.** The source has one class with two `steps()`. A reader who disagrees can rename three keys without touching the layout.
- **Two examples now decompose a MapReduce job.** The mint budget service and this one. They differ in what the job is for (monthly spending against a budget versus a ranked table the read path serves) and in the sort step, which only this one has.

## Migration Plan

None. The change is additive: one new YAML document and two Elm edits. Rollback is deleting the file and reverting the two edits; no stored model or schema changes, and no existing example is touched.
