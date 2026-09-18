## Purpose

Defines the gallery of worked example models offered on the landing page: which examples exist, what each one must contain to be worth showing, and the link contract that lets a visitor open, share, and bookmark a single example view.

## Requirements

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

### Requirement: Example entries link to a published document and a named view

Each example entry SHALL link to a YAML document for that example published at a stable URL, together with the name of the view to open. The URL of an opened example SHALL be shareable: opening it again in a new session SHALL load the same model and view.

#### Scenario: Shared example link reopens the same view
- **WHEN** a visitor opens an editor URL that names an example and a view
- **THEN** that example's model is loaded and that view is selected

#### Scenario: Unavailable example is reported
- **WHEN** an example's document cannot be downloaded
- **THEN** the editor reports a download failure instead of rendering an empty or stale model

### Requirement: Every example model defines the main view

An example model referenced from the landing page SHALL define a view named `main`, because the landing page entries open that view by name.

#### Scenario: Landing page entry resolves to an existing view
- **WHEN** a visitor opens an example from the landing page
- **THEN** the diagram of that example's `main` view is displayed, with no unresolved-view error

### Requirement: Example models are valid models

Every example model SHALL be a valid domain model under the schema published with the application, with no validation errors reported for its domain or for any of its views.

#### Scenario: Example loads without validation errors
- **WHEN** an example is opened in the editor
- **THEN** no domain or view validation errors are shown for that example

### Requirement: Example entries stay fully visible at any supported width

The landing page SHALL keep every example entry fully visible and selectable regardless of the number of examples offered and the supported viewport widths, rather than clipping content or forcing horizontal scrolling.

#### Scenario: Example row wraps with many examples
- **WHEN** the landing page is viewed at a width too narrow to fit all example entries in one line
- **THEN** the entries wrap onto further lines, and every entry remains fully visible and selectable

### Requirement: Social graph example models the design at container and component level

The social graph example SHALL include an actor, an external name-resolution system, a target system holding the design's containers, and at least one container decomposed into components.

#### Scenario: Container level of the scaled design is shown
- **WHEN** the social graph example's `main` view is displayed
- **THEN** the design's containers - load balancer, reverse proxy, query API, user graph service, lookup service, person server and memory cache - are shown as containers of the target system, with the client and the name-resolution system outside it

#### Scenario: One container is decomposed into components
- **WHEN** the social graph example's component view is displayed
- **THEN** the user graph service is shown with its components drawn inside it, and the person server and lookup service it depends on are shown alongside

#### Scenario: Every relation drawn comes from the domain
- **WHEN** any view of the social graph example is displayed
- **THEN** every drawn relation is a relation declared in the domain for the element it starts from, and targets an element that exists

### Requirement: Social graph example shows the design at two stages

The social graph example SHALL provide at least two container-level views - the initial design and the scaled design - plus at least one component-level view, so that a visitor can see one domain represented at different levels and stages.

#### Scenario: Multiple views are offered
- **WHEN** a visitor opens the social graph example and lists its views
- **THEN** the initial design, the scaled design and a component-level view are all selectable

#### Scenario: Initial design omits scaled-only elements
- **WHEN** the initial-design view of the social graph example is displayed
- **THEN** the load balancer, the memory cache and the name-resolution system are not part of that view

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
