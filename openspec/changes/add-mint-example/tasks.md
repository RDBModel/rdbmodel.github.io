## 1. Author the example model

- [x] 1.1 Create `mint.yaml` at the repo root with the domain outline from design.md D6: `domain.name`, `domain.description` (credits the source and explains the write path versus the added read path), the `client` actor with its four relations, the `dns` external system, and the `mint` system with its thirteen containers - `load-balancer`, `cdn`, `web-server`, `accounts-api`, `read-api`, `queue`, `transaction-extraction-service`, `category-service`, `budget-service`, `notification-service`, `sql-database`, `sql-read-replicas`, `object-store`, `memory-cache` - each with a name, a description taken from the source prose, and its container-level relations. Verify no parse or validation error appears when the file is opened in the editor.
- [x] 1.2 Add the three components of `category-service` (`seller-category-map`, `crowd-overrides`, `categorizer`) and the three of `budget-service` (`budget-template`, `spending-aggregation`, `budget-alerts`) with their descriptions and relations per design.md D4. Verify no "Not existing target" or "Duplicated element key" error is reported.
- [x] 1.3 Add the `main` view with the sixteen elements plus the system from design.md D7, listing under each element exactly the relations marked `[main]` in D6. Verify every element and every relation renders, and no "Not existing element in domain" or "Not existing relation in domain" error is reported.
- [x] 1.4 Add the `initial` view with its ten elements plus the system, listing the relations marked `[initial]`. Verify the view renders without the read API, the memory cache, the read replicas, the CDN, the load balancer and DNS.
- [x] 1.5 Add the `category-service` view with the system, the `category-service` container, its three components and the relations from D4, with the container element listing no relations of its own. Verify the components draw inside the container box and the categorizer's edges reach both stores.
- [x] 1.6 Add the `budget-service` view with the system, the `budget-service` container, its three components, the `category-service` and `notification-service` containers, and the component relations from D4. Verify the aggregation job's edge reaches the category service and the alerts' edge reaches the notification service.

## 2. Tune the layouts

- [x] 2.1 Open `main`, adjust the coordinates from design.md D7 and add relation routing points where edges cross boxes or each other, then confirm the layout is legible at default zoom and that no edge label overlaps a box.
- [x] 2.2 Tune the `initial`, `category-service` and `budget-service` views the same way, confirming that in `budget-service` the aggregation job's edge to the category service does not cross the budget template box.
- [x] 2.3 Confirm the system box in each view encloses exactly the elements of that view (no stray gap large enough to misplace an edge), remembering that parent coordinates are recomputed from the children present in the view.

## 3. Wire up the landing page

- [x] 3.1 Add `editorLinkMint` to `src/Route.elm` alongside the existing link constants, exposing it in the module's export list. Verify `npm run build` completes with no Elm compile error.
- [x] 3.2 Add the "Mint" button to `src/Pages/Home.elm` and confirm the landing page shows six example buttons plus the starter model.
- [x] 3.3 Confirm at a narrow window width (about 800px) that the sixth button wraps with no clipping and no horizontal scrolling, so the existing `home-examples` width requirement still holds.

## 4. Verify end to end

- [x] 4.1 Run `npm run dev` and open `#/editor/main?link=/mint.yaml` to prove the model loads from a plain URL without depending on the published `master` copy.
- [x] 4.2 Switch between all four views from the view control and confirm each renders its own element set with no validation errors.
- [x] 4.3 Confirm that opening the editor with no link still loads the locally stored or starter model, so the new example has not changed default loading.
- [ ] 4.4 After merging, confirm the landing page button opens the example from the published URL and that the domain survives a browser reload from local storage.
