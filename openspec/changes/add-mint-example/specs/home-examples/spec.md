## ADDED Requirements

### Requirement: Mint example models the account, transaction and budget pipeline

The mint example SHALL include an actor, an external name-resolution system, a target system holding the design's containers, and the containers named by the source design in separate boxes: the web server, the accounts API, the queue, the transaction extraction service, the category service, the budget service, the notification service, the relational database and the object store. The service that extracts transactions SHALL reach the services it drives through relations declared for it, so that the extraction path is readable from the diagram without the source prose.

#### Scenario: Container level of the scaled design is shown
- **WHEN** the mint example's `main` view is displayed
- **THEN** the client and the name-resolution system are shown outside the target system, and the content delivery network, load balancer, web server, accounts API, read API, queue, transaction extraction service, category service, budget service, notification service, relational database, read replicas, object store and memory cache are shown as containers of it

#### Scenario: Extraction is asynchronous
- **WHEN** the mint example's `main` view is displayed
- **THEN** the accounts API reaches the transaction extraction service through the queue, and not by a direct relation to that service

#### Scenario: Budget alerts leave the target system
- **WHEN** the mint example's `main` view is displayed
- **THEN** the budget service and the transaction extraction service each have a relation to the notification service

#### Scenario: Every relation drawn comes from the domain
- **WHEN** any view of the mint example is displayed
- **THEN** every drawn relation is a relation declared in the domain for the element it starts from, and targets an element that exists

### Requirement: Mint example decomposes the containers the source decomposes

The mint example SHALL provide a component-level view for each of the two containers the source material decomposes into code - the category service and the budget service - and SHALL NOT invent components for the containers the source leaves whole.

#### Scenario: Category service is decomposed
- **WHEN** the mint example's category service component view is displayed
- **THEN** the seller-to-category map, the accumulated user overrides and the categorizer are shown inside the category service, with the categorizer reaching both stores

#### Scenario: Budget service is decomposed
- **WHEN** the mint example's budget service component view is displayed
- **THEN** the budget template, the spending aggregation job and the budget alerts are shown inside the budget service, with the aggregation job reaching the category service and the alerts reaching the notification service

### Requirement: Mint example separates the write path from the read path

The mint example SHALL show the write path in both its container-level views and SHALL add the read path - the read API, the memory cache and the read replicas - only in the scaled design, so that a visitor can see why the read path exists.

#### Scenario: Multiple views are offered
- **WHEN** a visitor opens the mint example and lists its views
- **THEN** the initial design, the scaled design and the two component-level views are all selectable

#### Scenario: Initial design omits the read path
- **WHEN** the initial-design view of the mint example is displayed
- **THEN** the read API, the memory cache, the read replicas, the content delivery network, the load balancer and the name-resolution system are not part of that view
#### Scenario: Both stages show the write path
- **WHEN** the initial-design view and the scaled design view are compared
- **THEN** the web server, the accounts API, the queue, the transaction extraction service, the category service, the budget service, the notification service, the relational database and the object store appear in both
