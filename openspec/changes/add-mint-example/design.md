## Context

See `proposal.md` for motivation and the delta spec for requirements.

**How examples work today.** Examples are YAML files at the repo root, fetched at runtime by the editor (`Http.get`, `src/Pages/Editor.elm`) from `https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/<file>.yaml`. The landing page has one button per example (`src/Pages/Home.elm`) and one link constant per example (`src/Route.elm`) of the form `#/editor/main?link=<raw url>`. Five examples exist (Pastebin, Dropbox, Twitter, Social graph, Web crawler). Nothing is copied into `dist`; the published site serves the app only.

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

**Source material** (`solutions/system_design/mint`): one first-pass design, one scaled design, and Python for two containers - the category service (`DefaultCategories`, `seller_category_map`, `Categorizer`) and the budget service (`Budget.create_budget_template`, `override_category_budget`, `SpendingByCategory` as a MapReduce job with mapper, reducer and `handle_budget_notifications`). Assumptions worth keeping: 10 million users, 30 million accounts, 5 billion transactions a month, 500 million reads a month, 10:1 write to read, ~50 bytes per transaction, 250 GB of new content a month and 9 TB over three years, 2,000 writes and 200 reads per second, 50,000 sellers and a 12 MB seller dictionary.

## Goals / Non-Goals

**Goals:**
- A sixth worked example faithful to the source at container level, both stages.
- Demonstrate what the other examples under-sell: a write path and a read path that are split on purpose, and a batch job (MapReduce) inside a container.
- A minimal code change: one new file, two small edits, no new dependencies, no schema or renderer change.

**Non-Goals:**
- Components for the containers the source leaves whole (web server, accounts API, read API, extraction service, notification service). The source decomposes two containers, so the example decomposes two.
- The financial institution the extractor pulls from. The source prose names it, neither source diagram draws it, and unlike the web crawler's `websites` no component view needs it as an edge target. It stays in the extraction service's description.
- The MapReduce data-warehouse alternative (Redshift/BigQuery) and the sharding/federation patterns the source lists as further scaling steps. They are prose, and they belong to a third stage the example does not model.
- Refactoring the example list into data. Six hardcoded examples exist; the seventh follows the same shape.
- Any change to the editor, renderer, validation, schema, ports, or the button row layout.

## Decisions

### D1. Name: "Mint", file `mint.yaml`, system key `mint`

Names the product like the Twitter and Pastebin examples, and matches the source folder. The domain is personal finance aggregation, but the product name is what the issue asks for and what the source calls the design.

### D2. Four views: `main`, `initial`, `category-service`, `budget-service`

| View | Shows | Why |
|------|-------|-----|
| `main` | The scaled design: client, DNS, CDN, load balancer, web server, accounts API, read API, queue, transaction extraction service, category service, budget service, notification service, SQL database, SQL read replicas, object store, memory cache | The flagship slice, and the landing-page target because the route opens `main` |
| `initial` | The write path before the read path was split out: client, web server, accounts API, queue, transaction extraction service, category service, budget service, notification service, SQL database, object store | Shows one domain serving two stages, and makes the read path's arrival visible |
| `category-service` | The category service with its three components | The source gives it code (`Categorizer`, the seeded map, the override heap) |
| `budget-service` | The budget service with its three components, plus the category service and notification service it talks to | The source gives it code, and it is the only container in the gallery whose internals include a batch job |

View keys are `[a-z-]+` per the schema; all four conform.

### D3. The SQL database is one container across both stages

The initial diagram draws a single "SQL" store; the scaled diagram draws "SQL Write Master-Slave" and "SQL Read Replicas". The write cluster is the initial store with a role spelled out, so the domain holds one `sql-database` container (used by both stages) plus `sql-read-replicas` (scaled only), and `sql-database` carries the `replicate writes - sql-read-replicas` relation. Modelling the write master-slave as a second container would imply two databases in the domain, which the source does not have.

### D4. Components only in the two containers the source decomposes

| Container | Component key | Name | Responsibility | Relations |
|---|---|---|---|---|
| `category-service` | `seller-category-map` | Seller category map | The seeded dictionary of about 50,000 sellers to categories, roughly 12 MB | (none) |
| | `crowd-overrides` | Crowd overrides | The per-seller heap of manual category overrides users have made, most common first | `seed the map with the winning override - seller-category-map` |
| | `categorizer` | Categorizer | Looks the transaction's seller up in the seeded map; on a miss takes the winning crowd override and seeds the map with it | `look up the seller category - seller-category-map`, `fall back to the most common override - crowd-overrides` |
| `budget-service` | `budget-template` | Budget template | Builds the default category amounts from the user's income tier and keeps only the categories the user overrides | (none) |
| | `spending-aggregation` | Spending aggregation | The MapReduce job: the mapper parses raw transaction logs and turns each seller into a category, the reducer sums the amounts into monthly spending per category | `categorize each transaction - category-service`, `compare the monthly total with the budget - budget-template`, `report a category near or over its budget - budget-alerts` |
| | `budget-alerts` | Budget alerts | Calls the notification service when a category is nearing or past its budget | `send the budget notification - notification-service` |

`handle_budget_notifications` is a method of the MapReduce job in the source; it becomes its own component so that the component that sends notifications is not the same one that computes totals, which is the split the source's own naming suggests.

Container-level relations stay on the containers, because the `main` and `initial` views draw them at container level. In the component views the container element declares no relations of its own - its components carry the edges - so the zoomed views do not draw container and component edges on top of each other.

The `budget-service` view shows `category-service` and `notification-service` as whole containers, at container level, because that is where the components' outgoing edges land. It does not decompose them a second time.

### D5. One relation per container pair

`transaction-extraction-service` drives `category-service` and `budget-service`, each with one relation (`categorize transactions`, `update monthly spending`), and both the extraction service and the budget service notify through `notification-service`, each with its own relation because the source describes two different notifications (extraction finished, budget approached). No two relations in this example connect the same ordered pair, so no two edges overlap into one line.

### D6. The domain in outline

```
actors
  client                       connect an account - web-server          [initial]
                               use the site - load-balancer             [main]
                               resolve connection - dns                 [main]
                               load static content - cdn                [main]
systems
  dns                          (external, no containers)
  mint  "Mint"
    containers
      load-balancer            forward requests - web-server                    [main]
      cdn                      cache static content - object-store               [main]
      web-server               account and transaction request - accounts-api    [main, initial]
                               read request - read-api                          [main]
      accounts-api             place extraction job - queue                     [main, initial]
                               store account info - sql-database                [main, initial]
      read-api                 read cached transactions and summaries - memory-cache  [main]
                               read transactions - sql-read-replicas            [main]
      queue                    deliver extraction jobs - transaction-extraction-service  [main, initial]
      transaction-extraction-service
                               categorize transactions - category-service      [main, initial]
                               update monthly spending - budget-service        [main, initial]
                               notify when extraction completes - notification-service  [main, initial]
                               store raw transaction logs - object-store       [main, initial]
                               store categorized transactions - sql-database   [main, initial]
        (no components)
      category-service         (receives calls from the extraction service)
        components
          seller-category-map  (none)
          crowd-overrides      seed the map with the winning override - seller-category-map
          categorizer          look up the seller category - seller-category-map
                               fall back to the most common override - crowd-overrides
      budget-service           send budget alert - notification-service        [main, initial]
        components
          budget-template      (none)
          spending-aggregation categorize each transaction - category-service
                               compare the monthly total with the budget - budget-template
                               report a category near or over its budget - budget-alerts
          budget-alerts        send the budget notification - notification-service
      notification-service     (receives notifications, sends them over a queue)
      sql-database             replicate writes - sql-read-replicas             [main]
      sql-read-replicas        (serves reads the cache misses)
      object-store             (raw transaction logs and static content)
      memory-cache             (caches sessions, summaries and recent transactions)  [main]
```

The `[main]`/`[initial]` markers name the views that draw each relation; the domain declares all of them.

Descriptions are adapted from the source prose and carry the numbers worth keeping (10 million users, 30 million accounts, 5 billion transactions a month, 2,000 writes and 200 reads per second, 250 GB a month and 9 TB over three years, 50,000 sellers, 12 MB dictionary).

### D7. Layout seeded from the source diagrams

Coordinates are box centres read off the source images (scaled design 1308x1332, first pass 978x912). Parents whose children appear in the same view are listed as derived.

`main`:

| Element | x | y |
|---|---|---|
| client | 495 | 90 |
| dns | 830 | 85 |
| cdn | 830 | 215 |
| load-balancer | 565 | 315 |
| web-server | 565 | 510 |
| category-service | 165 | 640 |
| budget-service | 165 | 755 |
| notification-service | 165 | 875 |
| transaction-extraction-service | 390 | 770 |
| queue | 615 | 770 |
| accounts-api | 880 | 770 |
| read-api | 1105 | 770 |
| memory-cache | 930 | 1010 |
| sql-database | 390 | 1180 |
| sql-read-replicas | 590 | 1180 |
| object-store | 790 | 1180 |
| mint (system) | derived | derived |

`initial`:

| Element | x | y |
|---|---|---|
| client | 485 | 92 |
| web-server | 485 | 287 |
| category-service | 150 | 437 |
| budget-service | 150 | 525 |
| notification-service | 150 | 613 |
| transaction-extraction-service | 380 | 525 |
| queue | 605 | 525 |
| accounts-api | 825 | 525 |
| sql-database | 485 | 792 |
| object-store | 682 | 792 |
| mint (system) | derived | derived |

`category-service` (hand-authored):

| Element | x | y |
|---|---|---|
| categorizer | 250 | 400 |
| seller-category-map | 500 | 340 |
| crowd-overrides | 500 | 470 |
| category-service (container) | derived | derived |
| mint (system) | derived | derived |

`budget-service` (hand-authored):

| Element | x | y |
|---|---|---|
| budget-template | 250 | 380 |
| spending-aggregation | 250 | 500 |
| budget-alerts | 250 | 620 |
| category-service | 700 | 400 |
| notification-service | 700 | 620 |
| budget-service (container) | derived | derived |
| mint (system) | derived | derived |

All relation routing points start empty and get tuned where an edge crosses a box or another edge. The `main` and `initial` views are as dense as their source diagrams, so these are the two most likely to need routing points.

### D8. Landing page: a sixth button, no layout change

The button row is already a `wrappedRow` with `paddingXY 30 20` per button. A sixth button ("Mint", ~140px) makes the row wrap onto a third line at 1440px, which is the behaviour the existing `home-examples` requirement asks for. No code or style change beyond the button itself.

## Risks / Trade-offs

- **The button cannot be exercised before merge.** Example links fetch from `master`, so a 404 ("Not able to download domain value by link") is expected until the YAML is merged. Verify locally by opening `#/editor/main?link=/mint.yaml` against the dev server, which serves root files.
- **The `main` view is dense.** Sixteen elements and twenty-one relations, with the crossing edges the source diagram itself has. Mitigated by seeding coordinates from the source and by checking that no edge crosses a box; accepted because trimming relations would misrepresent the design.
- **Splitting storage between stages can read as inconsistency.** A reader who compares `initial` and `main` sees one SQL box become two. The `sql-database` description says it is the write master-slave pair and that reads move to the replicas; accepted because the alternative (two containers for one role) misrepresents the domain.
- **Two component views, not one.** More YAML than the earlier examples. Accepted because the source decomposes two containers, and a view per container is cheaper than explaining why one was skipped.
- **Component names are an interpretation.** The source has classes, not a component diagram. `budget-alerts` in particular is a method promoted to a component. A reader who disagrees can rename the keys without touching the layout.

## Migration Plan

None. The change is additive: one new YAML document and two Elm edits. Rollback is deleting the file and reverting the two edits; no stored model or schema changes, and no existing example is touched.
