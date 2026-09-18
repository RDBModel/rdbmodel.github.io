## 1. Author the example model

- [x] 1.1 Create `query-cache.yaml` at the repo root with the domain outline from design.md D6: `domain.name`, `domain.description` (credits the source and explains the initial versus the scaled stage), the `client` actor with its three relations, the `dns` external system, and the `search` system with its six containers - `load-balancer`, `web-server`, `query-api`, `reverse-index-service`, `document-service`, `memory-cache` - each with a name, a description taken from the source prose, and its container-level relations. Verify no parse or validation error appears when the file is opened in the editor.
- [x] 1.2 Add the three components of `memory-cache` (`query-lookup`, `lru-list`, `cache-policy`) with their descriptions and relations per design.md D4. Verify no "Not existing target" or "Duplicated element key" error is reported.
- [x] 1.3 Add the `main` view with its eight elements plus the system from design.md D7, listing under each element exactly the relations marked `[main]` in D6. Verify every element and every relation renders, and no "Not existing element in domain" or "Not existing relation in domain" error is reported.
- [x] 1.4 Add the `initial` view with its six elements plus the system, listing the relations marked `[initial]`. Verify the view renders without DNS and the load balancer.
- [x] 1.5 Add the `memory-cache` view with the system, the `memory-cache` container, its three components and the relations from D4, with the container element listing no relations of its own. Verify the components draw inside the container box and the policy's edges reach both structures.

## 2. Tune the layouts

- [x] 2.1 Open `main`, adjust the coordinates from design.md D7 and add relation routing points where edges cross boxes or each other, then confirm the layout is legible at default zoom.
- [x] 2.2 Tune the `initial` and `memory-cache` views the same way, confirming in `memory-cache` that the policy's edge to the list does not cross the lookup table box.
- [x] 2.3 Confirm the system box in each view encloses exactly the elements of that view (no stray gap large enough to misplace an edge), remembering that parent coordinates are recomputed from the children present in the view.

## 3. Wire up the landing page

- [x] 3.1 Add `editorLinkQueryCache` to `src/Route.elm` alongside the existing link constants, exposing it in the module's export list. Verify `npm run build` completes with no Elm compile error.
- [x] 3.2 Add the "Query cache" button to `src/Pages/Home.elm` and confirm the landing page shows seven example buttons plus the starter model.
- [x] 3.3 Confirm at a narrow window width (about 800px) that the seventh button wraps with no clipping and no horizontal scrolling, so the existing `home-examples` width requirement still holds.

## 4. Verify end to end

- [x] 4.1 Run `npm run dev` and open `#/editor/main?link=/query-cache.yaml` to prove the model loads from a plain URL without depending on the published `master` copy.
- [x] 4.2 Switch between all three views from the view control and confirm each renders its own element set with no validation errors.
- [x] 4.3 Confirm that opening the editor with no link still loads the locally stored or starter model, so the new example has not changed default loading.
- [x] 4.4 After merging, confirm the landing page button opens the example from the published URL and that the domain survives a browser reload from local storage.
