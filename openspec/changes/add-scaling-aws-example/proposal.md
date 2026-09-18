## Why

Issue #35 asks for the "scales to millions of users on AWS" example, the last exercise in the system-design-primer series the gallery is drawn from. It is the only exercise that documents a *progression*: six stages, each one a response to a measured bottleneck, from one box to a read path split from the write path. The gallery's other examples show two stages; this one is what the tool's view model is for, and it is how the source teaches scaling.

## What Changes

- Add `scaling-aws.yaml` at the repo root: a C4 model of a web application scaled from one box to millions of users, adapted from the system-design-primer `scaling_aws` exercise.
- The example ships **four container-level views**, one per distinct stage in the source:
  - `main` - the final stage (the source's Users+++): the API tier, the memory cache and the read replicas. This is what the home page button opens.
  - `users-plus-plus` - the stage before it: the load balancer, the CDN and the write/read API split.
  - `users-plus` - the stage before that: static content in the object store and the database on its own box.
  - `single-box` - the first stage: one box serving the web application and the database.
- The example has **no component-level view**: the source material for this exercise contains no code, so no container is decomposed. This is a first for the gallery and is asserted in the spec.
- Do not model the fourth stage (autoscaling) as a view: the source draws no additional elements for it, and says so. Do not model the fifth (the further-options collage of data warehouse, NoSQL and queues), which presents alternatives rather than one design.
- Add a ninth example button ("Scaling on AWS") to the landing page and its link constant to the router.

No behavior changes to the editor, renderer, or domain validation.

## Capabilities

### New Capabilities
<!-- none: the example gallery is an existing capability -->

### Modified Capabilities
- `home-examples`: the gallery gains the scaling example, whose model must show the source's stage progression, separate the read path in its final stage, and remain container-level throughout.

## Impact

- New file: `scaling-aws.yaml` (repo root, served by `raw.githubusercontent.com` from `master`, like the other examples).
- `src/Route.elm`: one new `editorLinkScalingAws` constant.
- `src/Pages/Home.elm`: ninth button.
- No Elm types, decoders, ports, or JS changes. No new dependencies. No layout change to the button row (it already wraps).
- The home page example links fetch from `master`, so the button only works after the YAML is merged and published.
