## Context

See `proposal.md` for motivation and the delta spec for requirements.

**How examples work today.** Examples are YAML files at the repo root, fetched at runtime by the editor (`Http.get`, `src/Pages/Editor.elm`) from `https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/<file>.yaml`. The landing page has one button per example (`src/Pages/Home.elm`) and one link constant per example (`src/Route.elm`) of the form `#/editor/main?link=<raw url>`. Eight examples exist (Pastebin, Dropbox, Twitter, Social graph, Web crawler, Mint, Query cache, Sales rank). Nothing is copied into `dist`; the published site serves the app only.

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

**Source material** (`solutions/system_design/scaling_aws`): one use case (a read or write request), six diagrams, and prose but no code. The stages are the source's own notation: a single box, Users+, Users++, Users+++, Users++++ (autoscaling) and Users+++++. Assumptions worth keeping: 10 million users, 1 billion writes and 100 billion reads a month, a 100:1 read to write ratio, 1 KB per write, 1 TB of new content a month and 36 TB over three years, 400 writes and 40,000 reads per second.

**What the diagrams contain, measured.** Box fills were extracted from the four distinct stage images, so the coordinates below are measured rather than estimated. The Users+ stage adds the object store and a separate database box; Users++ adds the CDN, the load balancer, the write API and the read API; Users+++ adds the memory cache, the read replicas and the replication edge. The Users++++ image is pixel-identical in structure to Users+++ (the source notes that autoscaling groups are not drawn), and Users+++++ is a collage of further options.

## Goals / Non-Goals

**Goals:**
- A ninth worked example faithful to the source, showing an incremental progression rather than two end states.
- Demonstrate what the other examples under-sell: many views of one domain, each the previous one plus a measured fix.
- A minimal code change: one new file, two small edits, no new dependencies, no schema or renderer change.

**Non-Goals:**
- The autoscaling stage as a view. The source's own note says autoscaling groups are not shown, and the image adds no elements; a copy of the previous view would be clutter.
- The Users+++++ collage (data warehouse, NoSQL, queues and workers, SQL sharding and federation). It presents alternatives, not one design, and the source introduces it with "we might consider" and "if our database grows too large".
- Component views. This is the only exercise in the series with no code, so no container is decomposed. The spec asserts the absence.
- The security steps (VPC, subnets, port rules, encryption), the static IP and the monitoring tooling. They are prose about configuration, not elements in the diagrams.
- Refactoring the example list into data. Nine hardcoded examples exist; the tenth follows the same shape.
- Any change to the editor, renderer, validation, schema, ports, or the button row layout.

## Decisions

### D1. Name: "Scaling on AWS", file `scaling-aws.yaml`, system `app` "Web application"

The domain is the exercise ("Design a system that scales to millions of users on AWS"), so the example is named after it, like "Query cache" and "Sales rank". The target system is the application itself, which is the one thing the exercise never names: it is a web application whose containers evolve. `app` "Web application" keeps the system generic, which is honest, because the source is about the scaling moves rather than a product.

### D2. Four views, one per stage that introduces elements

| View | Is | Adds |
|------|----|------|
| `single-box` | The source's first stage | Client, DNS and one web server that also runs the database |
| `users-plus` | Users+ | The object store and the database on its own box |
| `users-plus-plus` | Users++ | The CDN, the load balancer and the write/read API split |
| `main` | Users+++ | The memory cache, the read replicas and the replication edge |

The final stage is named `main` because every landing-page entry opens that view, and it is the most complete design. The earlier views keep the source's own notation (`users-plus`, `users-plus-plus`) so a reader can map a view to a stage in the source.

Alternatives considered: two views (first and last), which would drop the two middle fixes and make the progression invisible, which is the whole point of this exercise; and six views, which would duplicate Users+++ once for autoscaling and once for the further-options collage.

### D3. The single box is one container, not a web server with a database inside it

The first stage's diagram draws one box, and the prose says it runs the web server and MySQL together. Containers cannot nest inside containers, so the `single-box` view shows only `web-server`, whose description says it is the one box that also runs MySQL, and the `sql-database` container appears from the `users-plus` view onwards, where the source separates it. This keeps each view exactly as wide as its stage's diagram.

### D4. The read API's database relation moves, it does not multiply

In Users++ the read API reads the single write database: `read data - sql-database`. In Users+++ that relation is replaced by `read data - sql-read-replicas` and `read cached data - memory-cache`, because the source's stage exists to take reads off the write master ("Add logic to Web Server to separate out writes and reads"). The two relations are declared separately in the domain and drawn in different views, so no view shows the read API reading both the master and the replicas.

### D5. The object store is written by the write API and cached by the CDN

The Users+ stage has the web server storing static content in the object store, and the Users++ prose moves static content to the CDN. From the API split onwards the model puts the writing of user content on `write-api` (`store user content - object-store`) and the serving on `cdn` (`cache static content - object-store`). The stage diagrams are ambiguous about which API a curve into the object store comes from; the prose names no read of the object store by the application, and the CDN is what serves that content, so no read relation to the object store is modelled.

### D6. The domain in outline

```
actors
  client                       resolve connection - dns                  [all stages]
                               use the service - web-server              [single-box, users-plus]
                               load static content - cdn                 [users-plus-plus, main]
                               use the service - load-balancer           [users-plus-plus, main]
systems
  dns                          (external, no containers)
  app  "Web application"
    containers
      web-server               use the database - sql-database            [users-plus]
                               store static content - object-store        [users-plus]
                               write request - write-api                  [users-plus-plus, main]
                               read request - read-api                    [users-plus-plus, main]
      load-balancer            forward requests - web-server              [users-plus-plus, main]
      cdn                      cache static content - object-store        [users-plus-plus, main]
      write-api                store data - sql-database                  [users-plus-plus, main]
                               store user content - object-store          [users-plus-plus, main]
      read-api                 read data - sql-database                   [users-plus-plus]
                               read data - sql-read-replicas              [main]
                               read cached data - memory-cache            [main]
      sql-database             replicate writes - sql-read-replicas       [main]
      sql-read-replicas        (serve the reads that leave the cache)
      memory-cache             (frequently read rows and session data)
      object-store             (user content, JS, CSS, images, videos)
```

The `[stage]` markers name the views that draw each relation; the domain declares all of them.

Descriptions are adapted from the source prose and carry the numbers worth keeping (10 million users, 1 billion writes and 100 billion reads a month, 100:1, 1 KB per write, 1 TB a month, 36 TB over three years, 400 writes and 40,000 reads per second, 250 microseconds to read 1 MB from memory) and the reasons the stage exists ("the database was taking more and more memory and CPU", "the single web server bottlenecks at peak", "we are read-heavy and the database is suffering").

### D7. Layout measured from the source diagrams

Coordinates are box centres extracted from the stage images (measured by finding each box's fill region, not by eye): first stage 494x354, Users+ 494x524, Users++ 488x1098, Users+++ 636x1322. Parents whose children appear in the same view are listed as derived.

`main` (Users+++):

| Element | x | y |
|---|---|---|
| client | 114 | 42 |
| dns | 362 | 44 |
| cdn | 362 | 171 |
| load-balancer | 245 | 400 |
| web-server | 245 | 590 |
| write-api | 118 | 808 |
| read-api | 370 | 808 |
| memory-cache | 240 | 1030 |
| sql-database | 65 | 1250 |
| sql-read-replicas | 240 | 1250 |
| object-store | 416 | 1250 |
| app (system) | derived | derived |

`users-plus-plus`:

| Element | x | y |
|---|---|---|
| client | 102 | 44 |
| dns | 351 | 43 |
| cdn | 350 | 171 |
| load-balancer | 230 | 395 |
| web-server | 219 | 579 |
| write-api | 105 | 795 |
| read-api | 341 | 789 |
| sql-database | 135 | 1032 |
| object-store | 305 | 1032 |
| app (system) | derived | derived |

`users-plus`:

| Element | x | y |
|---|---|---|
| client | 122 | 68 |
| dns | 370 | 67 |
| web-server | 242 | 267 |
| sql-database | 161 | 443 |
| object-store | 322 | 443 |
| app (system) | derived | derived |

`single-box`:

| Element | x | y |
|---|---|---|
| client | 121 | 67 |
| dns | 371 | 66 |
| web-server | 241 | 267 |
| app (system) | derived | derived |

All relation routing points start empty and get tuned where an edge crosses a box or another edge.

### D8. Landing page: a ninth button, no layout change

The button row is already a `wrappedRow` with `paddingXY 30 20` per button. A ninth button ("Scaling on AWS") makes the row wrap the same way the eighth did. No code or style change beyond the button itself.

## Risks / Trade-offs

- **The button cannot be exercised before merge.** Example links fetch from `master`, so a 404 ("Not able to download domain value by link") is expected until the YAML is merged. Verify locally by opening `#/editor/main?link=/scaling-aws.yaml` against the dev server, which serves root files.
- **Four views that overlap heavily.** Three of them are the fourth with less in it. That is the exercise's subject rather than an accident, and each view is small (3 to 11 elements), but a reader who wants only the end state should open `main`.
- **The view names use the source's notation.** `users-plus-plus` says nothing about what the stage adds. The alternative (`api-tier`, `cache-and-replicas`) reads better in the dropdown but loses the mapping to the source's stage names, which the exercise's prose leans on ("Users+", "Users++"). Vetoing this is a rename of three view keys.
- **A deliberate omission from the last stage.** Users+++++ exists as a diagram and is not modelled; the prose that goes with it lists alternatives rather than one design. Recorded in Non-Goals rather than silently dropped.
- **This example has no components.** A reader who has seen the previous examples may expect one. The spec asserts the absence so it reads as a decision.

## Migration Plan

None. The change is additive: one new YAML document and two Elm edits. Rollback is deleting the file and reverting the two edits; no stored model or schema changes, and no existing example is touched.
