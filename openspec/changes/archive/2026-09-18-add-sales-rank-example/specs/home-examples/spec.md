## ADDED Requirements

### Requirement: Sales rank example models the hourly ranking job

The sales rank example SHALL include an actor, an external name-resolution system, a target system holding the design's containers, and the containers the source names in separate boxes: the web server, the sales API, the read API, the sales rank service, the relational database and the object store. The sales rank service SHALL read the raw transaction logs from the object store and write the ranking to the database, so that the batch job's input and output are both visible.

#### Scenario: Container level of the scaled design is shown
- **WHEN** the sales rank example's `main` view is displayed
- **THEN** the client and the name-resolution system are shown outside the target system, and the content delivery network, load balancer, web server, sales API, read API, sales rank service, memory cache, relational database, read replicas and object store are shown as containers of it

#### Scenario: Ranking job has a visible input and output
- **WHEN** the sales rank example's `main` view is displayed
- **THEN** the sales rank service has a relation to the object store and a relation to the relational database

#### Scenario: Read path is separate from the batch job
- **WHEN** the sales rank example's `main` view is displayed
- **THEN** the read API reaches the memory cache and the read replicas, and has no relation to the sales rank service

#### Scenario: Every relation drawn comes from the domain
- **WHEN** any view of the sales rank example is displayed
- **THEN** every drawn relation is a relation declared in the domain for the element it starts from, and targets an element that exists

### Requirement: Sales rank example decomposes the ranking job

The sales rank example SHALL provide a component-level view of the sales rank service, because it is the only container the source material decomposes. The view SHALL show the weekly window, the step that totals quantity by category and product, and the step that sorts the totals, and SHALL NOT invent components for the other containers.

#### Scenario: Ranking job components are shown inside the service
- **WHEN** the sales rank example's sales rank service component view is displayed
- **THEN** the weekly window, the quantity totals and the distributed sort are shown inside the sales rank service container

#### Scenario: Both steps of the job are visible
- **WHEN** the sales rank service component view is displayed
- **THEN** the quantity totals reach the weekly window and the object store, and the distributed sort reaches the quantity totals and the relational database

### Requirement: Sales rank example shows the design at two stages

The sales rank example SHALL provide two container-level views - the initial design and the scaled design - plus the component-level view, so that a visitor can see one domain represented at different levels and stages.

#### Scenario: Multiple views are offered
- **WHEN** a visitor opens the sales rank example and lists its views
- **THEN** the initial design, the scaled design and the component-level view are all selectable

#### Scenario: Initial design omits the scaled-only elements
- **WHEN** the initial-design view of the sales rank example is displayed
- **THEN** the name-resolution system, the content delivery network, the load balancer, the memory cache and the read replicas are not part of that view

#### Scenario: Both stages show the ranking job and the write path
- **WHEN** the initial-design view and the scaled design view are compared
- **THEN** the web server, the sales API, the read API, the sales rank service, the relational database and the object store appear in both
