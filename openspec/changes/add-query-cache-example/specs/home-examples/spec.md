## ADDED Requirements

### Requirement: Query cache example models the cache-aside search path

The query cache example SHALL include an actor, an external name-resolution system, a target system holding the design's containers, and the containers the source names in separate boxes: the reverse proxy, the query API, the reverse index service, the document service and the memory cache. The query API SHALL reach the cache, the reverse index service and the document service with relations of its own, so that the cache-aside path is readable from the diagram.

#### Scenario: Container level of the scaled design is shown
- **WHEN** the query cache example's `main` view is displayed
- **THEN** the client and the name-resolution system are shown outside the target system, and the load balancer, web server, query API, reverse index service, document service and memory cache are shown as containers of it

#### Scenario: Cache-aside path is shown
- **WHEN** the query cache example's `main` view is displayed
- **THEN** the query API has one relation to the memory cache, one to the reverse index service and one to the document service, and no edge connects the memory cache to either service

#### Scenario: Every relation drawn comes from the domain
- **WHEN** any view of the query cache example is displayed
- **THEN** every drawn relation is a relation declared in the domain for the element it starts from, and targets an element that exists

### Requirement: Query cache example decomposes the memory cache

The query cache example SHALL provide a component-level view of the memory cache, because the cache is the only container the source material decomposes. The view SHALL show a key lookup table, a least-recently-used list and the policy that drives both, and SHALL NOT invent components for the other containers.

#### Scenario: Cache components are shown inside the cache
- **WHEN** the query cache example's memory cache component view is displayed
- **THEN** the key lookup table, the least-recently-used list and the cache policy are shown inside the memory cache container

#### Scenario: Policy drives both structures
- **WHEN** the memory cache component view is displayed
- **THEN** the cache policy reaches both the lookup table and the list, and the lookup table reaches the list

### Requirement: Query cache example shows the design at two stages

The query cache example SHALL provide two container-level views - the initial design and the scaled design - plus the component-level view, so that a visitor can see one domain represented at different levels and stages.

#### Scenario: Multiple views are offered
- **WHEN** a visitor opens the query cache example and lists its views
- **THEN** the initial design, the scaled design and the component-level view are all selectable

#### Scenario: Initial design omits the scaled-only elements
- **WHEN** the initial-design view of the query cache example is displayed
- **THEN** the name-resolution system and the load balancer are not part of that view

#### Scenario: Both stages show the search path
- **WHEN** the initial-design view and the scaled design view are compared
- **THEN** the web server, the query API, the reverse index service, the document service and the memory cache appear in both
