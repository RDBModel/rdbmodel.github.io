## 1. Author the example model

- [x] 1.1 Create `social-graph.yaml` at the repo root with the domain outline from design.md D5: `domain.name`, `domain.description` (credits the source and explains the initial-versus-scaled stages), the `client` actor with its three relations, the `dns` system, and the `social-graph` system with its seven containers, each with a name, a description taken from the source prose, and its relations. Verify the file parses by opening the app and confirming no parse error appears in the editor.
- [x] 1.2 Add the three components of `user-graph-service` (`bfs-traversal`, `person-loader`, `path-assembler`) with their descriptions and relations per design.md D4, and add the container-level `user-graph-service` relations to `lookup-service` and `person-server`. Verify no "Not existing target" or "Duplicated element key" error is reported.
- [x] 1.3 Add the `main` view with the ten elements and the seed coordinates from design.md D6, listing under each element exactly the relations marked `[main]` in D5. Verify every element and every relation renders, and no "Not existing element in domain" or "Not existing relation in domain" error is reported.
- [x] 1.4 Add the `initial` view with its six elements, listing the relations marked `[initial]`. Verify the view renders without the load balancer, the memory cache and DNS.
- [x] 1.5 Add the `graph-service` view with the system, `user-graph-service`, its three components, `lookup-service` and `person-server`, the container element listing no relations of its own, and the component relations from D4. Verify the components draw inside the user graph service box and their edges reach the lookup service and person server.

## 2. Tune the layouts

- [x] 2.1 Open `main`, drag elements and add relation routing points where edges cross boxes or each other, then confirm the layout is legible at default zoom and that no edge label overlaps a box.
- [x] 2.2 Tune the `initial` and `graph-service` views the same way, confirming at least one edge in each view reaches a target outside its source's box without crossing another box.
- [x] 2.3 Confirm the system box in each view encloses exactly the elements of that view (no stray gap large enough to misplace an edge), remembering that parent coordinates are recomputed from the children present in the view.

## 3. Wire up the landing page

- [x] 3.1 Add `editorLinkSocialGraph` to `src/Route.elm` alongside the existing link constants, exposing it in the module's export list. Verify `npm run build` completes with no Elm compile error.
- [x] 3.2 Add the "Social graph" button to `src/Pages/Home.elm` and confirm the landing page shows four example buttons plus the starter model.
- [x] 3.3 Change the button row to a wrapped row per design.md D7 and confirm at a narrow window width that no button is clipped or forced into horizontal scrolling, and that the buttons stay centred.

## 4. Verify end to end

- [x] 4.1 Run `npm run dev` and open `#/editor/main?link=/social-graph.yaml` to prove the model loads from a plain URL without depending on the published `master` copy.
- [x] 4.2 Switch between all three views from the view control and confirm each renders its own element set with no validation errors.
- [x] 4.3 Confirm that opening the editor with no link still loads the locally stored or starter model, so the new example has not changed default loading.
- [ ] 4.4 After merging, confirm the landing page button opens the example from the published URL and that the domain survives a browser reload from local storage.
