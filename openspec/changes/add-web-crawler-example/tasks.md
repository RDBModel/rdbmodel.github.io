## 1. Author the example model

- [x] 1.1 Create `web-crawler.yaml` at the repo root with the domain outline from design.md D7: `domain.name`, `domain.description` (credits the source and explains the initial-versus-scaled stages), the `client` actor with its three relations, the `dns` and `websites` external systems, and the `web-crawler` system with its nine containers - `load-balancer`, `web-server`, `query-api`, `reverse-index-service`, `document-service`, `index-queue`, `document-queue`, `crawler-service`, `nosql-database`, `memory-cache` - each with a name, a description taken from the source prose, and its container-level relations. Verify no parse or validation error appears when the file is opened in the editor.
- [x] 1.2 Add the three components of `crawler-service` (`crawl-scheduler`, `page-fetcher`, `pages-data-store`) with their descriptions and relations per design.md D5, and add the container-level `crawler-service` relations to `index-queue`, `document-queue` and `nosql-database`. Verify no "Not existing target" or "Duplicated element key" error is reported.
- [x] 1.3 Add the `main` view with the twelve elements plus the system from design.md D8, listing under each element exactly the relations marked `[main]` in D7. Verify every element and every relation renders, and no "Not existing element in domain" or "Not existing relation in domain" error is reported.
- [x] 1.4 Add the `initial` view with its nine elements plus the system, listing the relations marked `[initial]`. Verify the view renders without the load balancer, the memory cache and DNS.
- [x] 1.5 Add the `crawler-service` view with the system, `crawler-service`, its three components, `index-queue`, `document-queue`, `nosql-database` and `websites`, with the container element listing no relations of its own and the component relations from D5. Verify the components draw inside the crawler service box and their edges reach the queues, the database and the websites.

## 2. Tune the layouts

- [x] 2.1 Open `main`, adjust the coordinates from design.md D8 and add relation routing points where edges cross boxes or each other, then confirm the layout is legible at default zoom and that no edge label overlaps a box.
- [x] 2.2 Tune the `initial` and `crawler-service` views the same way, confirming that in `crawler-service` the `page-fetcher -> websites` edge and the `crawl-scheduler <-> page-fetcher` edges do not cross the container boundary in a misleading way.
- [x] 2.3 Confirm the system box in each view encloses exactly the elements of that view (no stray gap large enough to misplace an edge), remembering that parent coordinates are recomputed from the children present in the view.

## 3. Wire up the landing page

- [x] 3.1 Add `editorLinkWebCrawler` to `src/Route.elm` alongside the existing link constants, exposing it in the module's export list. Verify `npm run build` completes with no Elm compile error.
- [x] 3.2 Add the "Web crawler" button to `src/Pages/Home.elm` and confirm the landing page shows five example buttons plus the starter model.
- [x] 3.3 Confirm at a narrow window width (about 800px) that the fifth button wraps onto a second line with no clipping and no horizontal scrolling, so the existing `home-examples` width requirement still holds.

## 4. Verify end to end

- [x] - [x] 4.1 Run `npm run dev` and open `#/editor/main?link=/web-crawler.yaml` to prove the model loads from a plain URL without depending on the published `master` copy.
- [x] - [x] 4.2 Switch between all three views from the view control and confirm each renders its own element set with no validation errors.
- [x] - [x] 4.3 Confirm that opening the editor with no link still loads the locally stored or starter model, so the new example has not changed default loading.
- [ ] 4.4 After merging, confirm the landing page button opens the example from the published URL and that the domain survives a browser reload from local storage.
