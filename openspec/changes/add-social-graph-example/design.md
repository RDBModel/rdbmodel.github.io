## Context

**How examples work today.** Three examples (Pastebin, Dropbox, Twitter) are YAML files at the repo root, fetched at runtime by the editor (`Http.get`, `src/Pages/Editor.elm`) from `https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/<file>.yaml`. The landing page has one button per example (`src/Pages/Home.elm`), and one link constant per example (`src/Route.elm`) of the form `#/editor/main?link=<raw url>`. Nothing is copied into `dist`; the served page only publishes the app.

**The link names the view.** The route carries both a link and a view name, and every existing example link opens a view named `main`. An example without a `main` view shows an unresolved view when opened from the landing page.

**How views constrain the model** (`src/Domain/Validation.elm`):
- every relation key listed under a view element must be a relation declared for that same element in the domain;
- every view element key must exist in the domain;
- element keys are unique across the whole domain (actors, systems, containers, components share one namespace);
- every relation target must resolve to an existing element.

**Geometry** (`src/Domain/DomainDecoder.elm`, `src/Domain/Domain.elm:197`, `src/ViewEditor/DrawContainer.elm`):
- every element is 100x50 by default; width and height are not expressible in YAML;
- `x`/`y` are the box **centre**;
- a parent whose children are in the same view has its centre and size recomputed from those children (5px padding, 25px for the title). Hand-tuned coordinates are therefore needed only for elements without children in that view;
- relation routing points are optional; an empty list means auto-routing, so layouts can be authored first and tuned by dragging.

**Source material** (system-design-primer `solutions/system_design/social_graph`): a first-pass design, a scaled design, and Python showing three distinct responsibilities inside the user graph service. The design is deliberately graph-database-free (a stated constraint of the exercise), so Lookup Service + sharded Person Servers carry the graph.

## Goals / Non-Goals

**Goals:**
- A fourth worked example that is faithful to the source design at the container level.
- Demonstrate what the other examples under-sell: several views over one domain, a first-pass versus scaled design, and one container decomposed into components.
- A minimal code change: one new file, two small edits, no new dependencies, no schema or renderer change.

**Non-Goals:**
- Components for the other six containers. The source decomposes one container, so the example decomposes one container; inventing the rest would be noise.
- The graph-database alternative (Neo4j/GraphQL). The source excludes it by constraint.
- Refactoring the example list into data. Three hardcoded examples already exist; a fourth follows the same shape. Revisit when the duplication actually costs something.
- Any change to the editor, the renderer, validation, the schema, or the ports.
- A README or attribution section. The source is credited in the example's `domain.description`.

## Decisions

### D1. Name: "Social graph", file `social-graph.yaml`

Matches the source folder and describes the design (friend search over a connection graph). Alternative "Social network" matches the issue title but sits next to the existing **Twitter** example, which is also a social network, so the two buttons would be nearly indistinguishable. Vetoing this is a one-word change.

### D2. Three views: `main`, `initial`, `graph-service`

| View | Shows | Why |
|------|-------|-----|
| `main` | The scaled design: client, DNS, load balancer, reverse proxy, query API, user graph service, lookup service, person server, memory cache | The flagship slice, and the landing-page target because the route opens `main` |
| `initial` | The first-pass design: same client and system, but only reverse proxy, query API, user graph service, lookup service, person server | Shows one domain serving two stages of the same design - the clearest demonstration of why views exist |
| `graph-service` | The user graph service decomposed, with the lookup service and person server it talks to | Shows the fourth C4 level and nested composition |

View keys are `[a-z-]+` per the schema; all three conform.

### D3. One domain, both stages - no duplicated `search-api` container

The first-pass design's "Search API" becomes today's "Query API" once scaled; it is one role, described twice in the source. Modelling it twice would imply two systems in the domain, so the domain holds the union of elements and the `initial` view draws a subset.

Consequence: the client needs two outgoing relations - `search for a person - load-balancer` (scaled) and `search for a person - web-server` (first pass). Each view draws exactly one of them, so no view shows a contradictory route. This duplication is the price of one domain covering two stages, and it is visible in the YAML as two same-labelled relations to different targets.

### D4. Components only in the user graph service

The source's code shows three separable responsibilities, which become:

| Component key | Name | Responsibility | Relations |
|---|---|---|---|
| `bfs-traversal` | BFS traversal | Walks friend ids breadth-first, tracking visited ids and a predecessor per hop | `request adjacent people for each friend id - person-loader` |
| `person-loader` | Person loader | Resolves a person id to its shard, then fetches people by id | `resolve person server for id - lookup-service`, `fetch people by ids - person-server` |
| `path-assembler` | Path assembler | Walks the predecessor map back from the target to build the ordered path | `read predecessor map - bfs-traversal` |

Plain keys (unique in this domain), following `dropbox.yaml`, not `pastebin.yaml`'s `parent--child` prefix style.

The container-level relations `user-graph-service -> lookup-service` and `user-graph-service -> person-server` stay in the domain too, because the `main` view needs to draw them at container level. In `graph-service` the container element declares no relations of its own - its components carry the edges - so the zoomed view does not draw container edges and component edges on top of each other.

### D5. The domain in outline

```
actors
  client                       resolve connection - dns            [main]
                               search for a person - load-balancer [main]
                               search for a person - web-server    [initial]
systems
  dns                          (external, no containers)
  social-graph   "Social graph"
    containers
      load-balancer            forward requests - web-server            [main]
      web-server               friend search request - query-api        [main, initial]
      query-api                query connection path - user-graph-service [main, initial]
                               read cached person data - memory-cache   [main]
      user-graph-service       resolve person server for id - lookup-service [main, initial]
                               fetch people by ids - person-server      [main, initial]
        components
          bfs-traversal        request adjacent people for each friend id - person-loader
          person-loader        resolve person server for id - lookup-service
                               fetch people by ids - person-server
          path-assembler       read predecessor map - bfs-traversal
      lookup-service           maps a person id to the person server holding it (sharding key)
      person-server            sharded people and friend ids - 100M users, ~50 friends each
      memory-cache             person data and partial traversals
```

The `[main]`/`[initial]` markers name the views that draw each relation; the domain declares all of them.

Descriptions are adapted from the source prose and carry the numbers worth keeping (100M users, ~50 friends each, 5B edges, 400 searches/second, unweighted graph). The `domain.description` states the source and explains that `initial` precedes `main`.

### D6. Layout seeded from the source diagrams, then tuned by dragging

Coordinates below are box centres read off the source images (scaled design 774x1042, first pass 734x594). Parents whose children appear in the same view need no meaningful coordinates - the app recomputes them - so they are listed as derived.

`main`:

| Element | x | y |
|---|---|---|
| client | 175 | 75 |
| dns | 535 | 75 |
| load-balancer | 245 | 265 |
| web-server | 245 | 460 |
| query-api | 120 | 720 |
| user-graph-service | 380 | 735 |
| lookup-service | 640 | 680 |
| person-server | 640 | 800 |
| memory-cache | 250 | 945 |
| social-graph (system) | derived | derived |

`initial`: client (215, 70), web-server (250, 272), query-api (130, 510), user-graph-service (372, 460), lookup-service (630, 405), person-server (625, 517).

`graph-service`: bfs-traversal (300, 330), person-loader (300, 400), path-assembler (300, 470), lookup-service (600, 330), person-server (600, 470).

All relation routing points start empty and get tuned by dragging where two edges cross or where an edge crosses a box.

### D7. Landing page: a fourth button, less padding, in a wrapped row

Measured in the browser, not assumed:

- The four buttons total 883px at the original `paddingXY 50 20`, so they never fit the landing page's content column, which is about 760px wide (set by the demo image row) at every viewport width. At 1440px the fourth button already overflowed the column; at 800px the page gained horizontal scroll (`scrollWidth` 908 against a 800px viewport).
- `wrappedRow` alone fixes the overflow but the second line reads badly, because the per-button `centerX` wrappers absorb the free space of their line and stretch (one measured 750px wide).

Decision: wrap the row in `wrappedRow`, drop `centerX` from the per-button wrappers, and reduce button padding from `paddingXY 50 20` to `paddingXY 30 20`. Four buttons then total 723px and share one line from 800px up, and wrap without clipping below that. The padding change slightly tightens the three existing buttons; accepted because it is one number instead of a wider content column.

Attempted and rejected: `width (fill |> maximum 900)` on the row. Inside this shrink-to-content column `fill` resolves to the column's own width, which made the row narrower and wrapped it at every width.

## Risks / Trade-offs

- **The button cannot be exercised before merge.** Example links fetch from `master`, so a 404 ("Not able to download domain value by link") is expected until the YAML is merged. Verify locally first by opening `#/editor/main?link=/social-graph.yaml` against the dev server, which serves root files.
- **Two-stage modelling can read as inconsistency.** A reader who opens `main` and `initial` sees `load-balancer` and `memory-cache` in one and not the other, and the client with two outbound relations in the YAML. Mitigated by the view names and the domain description; accepted because the alternative (duplicate containers per stage) misrepresents the system.
- **Three views means three hand-tuned layouts.** Each is small (7-10 elements), and the source diagrams seed them; the tuning is dragging, not arithmetic.
- **`wrappedRow` and the per-button `centerX` wrappers interact badly.** Resolved by dropping `centerX` from the wrappers; the row's position is now set by the content column, which is itself centred.
- **Components are an interpretation.** The source has code, not a component diagram. The three components are named after the code's responsibilities; a reader who disagrees can rename three keys without touching the layout.
