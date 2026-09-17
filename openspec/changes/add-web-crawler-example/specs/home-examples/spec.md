## ADDED Requirements

### Requirement: Web crawler example models the crawl and search pipeline

The web crawler example SHALL include an actor, an external name-resolution system, a target system holding the design's containers, and at least one container decomposed into components. The reverse index service, the document service and the crawler service SHALL be shown as separate containers connected by queues, so that the crawl path is visible as decoupled background work rather than as direct calls between the services.

#### Scenario: Container level of the scaled design is shown
- **WHEN** the web crawler example's `main` view is displayed
- **THEN** the client and the name-resolution system are shown outside the target system, and the load balancer, web server, query API, reverse index service, document service, index queue, document queue, crawler service, key-value database and memory cache are shown as containers of it

#### Scenario: Crawl path is decoupled
- **WHEN** the web crawler example's `main` view is displayed
- **THEN** the crawler service reaches the reverse index service and the document service through the queues, and not by a direct relation to either service

#### Scenario: One container is decomposed into components
- **WHEN** the web crawler example's component view is displayed
- **THEN** the crawler service is shown with its components drawn inside it - a scheduler, a page fetcher and a crawl state store - and the database, the queues and the crawled websites it depends on are shown alongside

#### Scenario: Every relation drawn comes from the domain
- **WHEN** any view of the web crawler example is displayed
- **THEN** every drawn relation is a relation declared in the domain for the element it starts from, and targets an element that exists

### Requirement: Web crawler example shows the design at two stages

The web crawler example SHALL provide at least two container-level views - the initial design and the scaled design - plus at least one component-level view, so that a visitor can see one domain represented at different levels and stages.

#### Scenario: Multiple views are offered
- **WHEN** a visitor opens the web crawler example and lists its views
- **THEN** the initial design, the scaled design and a component-level view are all selectable

#### Scenario: Initial design omits scaled-only elements
- **WHEN** the initial-design view of the web crawler example is displayed
- **THEN** the load balancer, the memory cache and the name-resolution system are not part of that view

#### Scenario: Both stages show the same pipeline containers
- **WHEN** the initial-design view and the scaled design view are compared
- **THEN** the query API, reverse index service, document service, queues, crawler service and key-value database appear in both

## MODIFIED Requirements

### Requirement: Landing page presents worked examples

The landing page SHALL present each worked example as a named entry, and selecting an entry SHALL open the editor with that example's model loaded in place of the starter model or any previously stored model. Adding a new example SHALL NOT remove or replace any example already offered.

#### Scenario: Example entry opens its own model
- **WHEN** a visitor selects an example entry on the landing page
- **THEN** the editor opens with that example's model loaded and its diagram rendered

#### Scenario: Existing examples remain available
- **WHEN** a visitor views the landing page
- **THEN** every example offered before the current change is still offered alongside any newly added example

#### Scenario: Starter model still offered
- **WHEN** a visitor selects the option to start a new model
- **THEN** the editor opens with the minimal starter model
