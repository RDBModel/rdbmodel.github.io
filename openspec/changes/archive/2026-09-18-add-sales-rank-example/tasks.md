## 1. Author the example model

- [x] 1.1 Create `sales-rank.yaml` at the repo root with the domain outline from design.md D7: `domain.name`, `domain.description` (credits the source and explains the initial versus the scaled stage), the `client` actor with its four relations, the `dns` external system, and the `amazon` system with its ten containers - `load-balancer`, `cdn`, `web-server`, `sales-api`, `read-api`, `sales-rank-service`, `memory-cache`, `sql-database`, `sql-read-replicas`, `object-store` - each with a name, a description taken from the source prose, and its container-level relations. Verify no parse or validation error appears when the file is opened in the editor.
- [x] 1.2 Add the three components of `sales-rank-service` (`weekly-window`, `quantity-totals`, `distributed-sort`) with their descriptions and relations per design.md D4. Verify no "Not existing target" or "Duplicated element key" error is reported.
- [x] 1.3 Add the `main` view with its twelve elements plus the system from design.md D8, listing under each element exactly the relations marked `[main]` in D7. Verify every element and every relation renders, and no "Not existing element in domain" or "Not existing relation in domain" error is reported.
- [x] 1.4 Add the `initial` view with its seven elements plus the system, listing the relations marked `[initial]`. Verify the view renders without DNS, the CDN, the load balancer, the memory cache and the read replicas.
- [x] 1.5 Add the `sales-rank-service` view with the system, the `sales-rank-service` container, its three components, the `object-store` and `sql-database` containers, and the component relations from D4, with the container element listing no relations of its own. Verify the components draw inside the container box, the totals step's edge reaches the object store and the sort step's edge reaches the database.

## 2. Tune the layouts

- [x] 2.1 Open `main`, adjust the coordinates from design.md D8 and add relation routing points where edges cross boxes or each other, then confirm the layout is legible at default zoom.
- [x] 2.2 Tune the `initial` and `sales-rank-service` views the same way, confirming in `sales-rank-service` that the totals step's edge to the object store does not cross the weekly window box.
- [x] 2.3 Confirm the system box in each view encloses exactly the elements of that view (no stray gap large enough to misplace an edge), remembering that parent coordinates are recomputed from the children present in the view.

## 3. Wire up the landing page

- [x] 3.1 Add `editorLinkSalesRank` to `src/Route.elm` alongside the existing link constants, exposing it in the module's export list. Verify `npm run build` completes with no Elm compile error.
- [x] 3.2 Add the "Sales rank" button to `src/Pages/Home.elm` and confirm the landing page shows eight example buttons plus the starter model.
- [x] 3.3 Confirm at a narrow window width (about 800px) that the eighth button wraps with no clipping and no horizontal scrolling, so the existing `home-examples` width requirement still holds.

## 4. Verify end to end

- [x] 4.1 Run `npm run dev` and open `#/editor/main?link=/sales-rank.yaml` to prove the model loads from a plain URL without depending on the published `master` copy.
- [x] 4.2 Switch between all three views from the view control and confirm each renders its own element set with no validation errors.
- [x] 4.3 Confirm that opening the editor with no link still loads the locally stored or starter model, so the new example has not changed default loading.
- [x] 4.4 After merging, confirm the landing page button opens the example from the published URL and that the domain survives a browser reload from local storage.
