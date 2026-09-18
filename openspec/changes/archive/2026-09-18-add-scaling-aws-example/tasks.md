## 1. Author the example model

- [x] 1.1 Create `scaling-aws.yaml` at the repo root with the domain outline from design.md D6: `domain.name`, `domain.description` (credits the source and explains the stage progression), the `client` actor with its four relations, the `dns` external system, and the `app` system with its nine containers - `web-server`, `load-balancer`, `cdn`, `write-api`, `read-api`, `sql-database`, `sql-read-replicas`, `memory-cache`, `object-store` - each with a name, a description taken from the source prose, and its container-level relations. Verify no parse or validation error appears when the file is opened in the editor.
- [x] 1.2 Add the `single-box` view with the client, DNS and the web server from design.md D7, listing the relations marked for that stage in D6. Verify the view renders with one container and no database, object store, CDN or load balancer.
- [x] 1.3 Add the `users-plus` view with its five elements plus the system, listing its stage's relations. Verify the view renders with the object store and the separate database and nothing from the later stages.
- [x] 1.4 Add the `users-plus-plus` view with its nine elements plus the system, listing its stage's relations. Verify the view renders with the load balancer, the CDN, the write API and the read API, and without the memory cache and the read replicas.
- [x] 1.5 Add the `main` view with its eleven elements plus the system, listing the relations marked `[main]` in D6, including `read-api -> memory-cache`, `read-api -> sql-read-replicas` and `sql-database -> sql-read-replicas`, and excluding `read-api -> sql-database`. Verify every element and every relation renders, and no "Not existing element in domain" or "Not existing relation in domain" error is reported.

## 2. Tune the layouts

- [x] 2.1 Open `main`, adjust the coordinates from design.md D7 and add relation routing points where edges cross boxes or each other, then confirm the layout is legible at default zoom.
- [x] 2.2 Tune the `users-plus-plus`, `users-plus` and `single-box` views the same way, confirming in `users-plus-plus` that the write API's edge to the object store and the read API's edge to the database do not cross a box.
- [x] 2.3 Confirm the system box in each view encloses exactly the elements of that view (no stray gap large enough to misplace an edge), remembering that parent coordinates are recomputed from the children present in the view.

## 3. Wire up the landing page

- [x] 3.1 Add `editorLinkScalingAws` to `src/Route.elm` alongside the existing link constants, exposing it in the module's export list. Verify `npm run build` completes with no Elm compile error.
- [x] 3.2 Add the "Scaling on AWS" button to `src/Pages/Home.elm` and confirm the landing page shows nine example buttons plus the starter model.
- [x] 3.3 Confirm at a narrow window width (about 800px) that the ninth button wraps with no clipping and no horizontal scrolling, so the existing `home-examples` width requirement still holds.

## 4. Verify end to end

- [x] 4.1 Run `npm run dev` and open `#/editor/main?link=/scaling-aws.yaml` to prove the model loads from a plain URL without depending on the published `master` copy.
- [x] 4.2 Switch between all four views from the view control and confirm each renders its own element set with no validation errors.
- [x] 4.3 Confirm that opening the editor with no link still loads the locally stored or starter model, so the new example has not changed default loading.
- [ ] 4.4 After merging, confirm the landing page button opens the example from the published URL and that the domain survives a browser reload from local storage.
