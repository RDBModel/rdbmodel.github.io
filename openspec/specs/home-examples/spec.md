## Purpose

Defines the gallery of worked example models offered on the landing page: which examples exist, what each one must contain to be worth showing, and the link contract that lets a visitor open, share, and bookmark a single example view.

## Requirements

### Requirement: Landing page presents worked examples

The landing page SHALL present each worked example as a named entry, and selecting an entry SHALL open the editor with that example's model loaded in place of the starter model or any previously stored model.

#### Scenario: Example entry opens its own model
- **WHEN** a visitor selects an example entry on the landing page
- **THEN** the editor opens with that example's model loaded and its diagram rendered

#### Scenario: Existing examples remain available
- **WHEN** a visitor views the landing page
- **THEN** the Pastebin, Dropbox and Twitter examples are offered alongside any newly added example

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
