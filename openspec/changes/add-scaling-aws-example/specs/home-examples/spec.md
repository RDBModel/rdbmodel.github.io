## ADDED Requirements

### Requirement: Scaling example shows every stage of the source's progression

The scaling example SHALL include an actor, an external name-resolution system and a target system holding the design's containers, and SHALL provide one container-level view for each stage of the source material that introduces elements: one box, the object store and the separate database, the API tier behind a load balancer and a CDN, and the memory cache with the read replicas. Each view SHALL contain exactly the elements of its stage, so that a visitor can step through the progression.

#### Scenario: First stage is a single box
- **WHEN** the `single-box` view is displayed
- **THEN** the client and the name-resolution system are outside the target system and one web server is inside it, and no database, object store, CDN or load balancer is part of the view

#### Scenario: Middle stages add one layer at a time
- **WHEN** the `users-plus` view is displayed
- **THEN** the web server, the relational database and the object store are shown, and the CDN, the load balancer and the API containers are not
- **WHEN** the `users-plus-plus` view is displayed
- **THEN** the CDN, the load balancer, the write API and the read API are shown in addition to those elements, and the memory cache and the read replicas are not

#### Scenario: Final stage is the scaled design
- **WHEN** the `main` view is displayed
- **THEN** the memory cache and the read replicas are shown alongside every element of the previous stage except the read API's relation to the write database

#### Scenario: Every relation drawn comes from the domain
- **WHEN** any view of the scaling example is displayed
- **THEN** every drawn relation is a relation declared in the domain for the element it starts from, and targets an element that exists

### Requirement: Scaling example separates the read path in its final stage

In the scaling example's final stage the write path SHALL write the database and the object store, and the read path SHALL read the memory cache and the read replicas, so that the split the stage exists to show is visible in the diagram.

#### Scenario: Write path writes both stores
- **WHEN** the `main` view is displayed
- **THEN** the write API has a relation to the relational database and a relation to the object store

#### Scenario: Read path reads the cache and the replicas
- **WHEN** the `main` view is displayed
- **THEN** the read API has a relation to the memory cache and a relation to the read replicas, and its relation to the write database is drawn only in the earlier stage

### Requirement: Scaling example stays at container level

The scaling example's container-level views SHALL NOT be accompanied by component-level views, because the source material for this exercise decomposes no container. Every view SHALL show only actors, systems and containers.

#### Scenario: No components in any view
- **WHEN** a visitor opens the scaling example and lists its views
- **THEN** the views are the four container-level stages, and no view shows a component inside a container
