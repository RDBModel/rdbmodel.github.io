# design-language Specification

## Purpose
Defines the visual system every screen of the application uses: the warm
parchment palette, the single ink-blue accent, the type pairing, the button
variants, and how the diagram canvas and code editor join that system. It is
the contract a visual review checks, independent of how the styles are coded.

## Requirements

### Requirement: Surfaces are warm, never pure white

Every surface the application paints - page backgrounds, panels, cards, menus,
dialog chrome - SHALL use the warm parchment family (page `#f5f4ed`, quiet
filled container `#faf9f5`, interactive surface `#e8e6dc`). No full-page or
panel surface SHALL be pure white, and the application SHALL NOT use cool-blue
grays for surfaces or borders. Depth SHALL come from a change of fill, not from
a hard drop shadow; only genuinely floating elements (menus, dialogs) may carry
a soft shadow.

#### Scenario: Landing page background is parchment

- **WHEN** the landing page is open
- **THEN** the page background colour is the parchment `#f5f4ed`, not `#ffffff` or a cool gray

#### Scenario: Editor chrome uses warm surfaces

- **WHEN** the editor page is open
- **THEN** the panels and controls around the canvas use the warm surface family, and no panel background is pure white

#### Scenario: Floating menus may carry a soft shadow

- **WHEN** a context menu is open
- **THEN** it is drawn on an ivory surface with a soft shadow, not on pure white with a hard border

### Requirement: Ink blue is the only chromatic accent

Ink blue `#1B365D` SHALL be the only chromatic colour in the application. It
SHALL mark primary actions, links, and selected or highlighted state. Every
other colour SHALL be a warm neutral or the warm border family; no second hue
(no cyan, green, purple, or non-token red/yellow) SHALL appear in resting or
interactive chrome. Highlighting an element SHALL use an ink-blue tint, not a
raw browser yellow.

#### Scenario: Primary action is ink blue

- **WHEN** the landing page is open
- **THEN** the primary action is filled with ink blue `#1B365D` and its label is the ivory surface colour

#### Scenario: Selected diagram element is ink blue

- **WHEN** an element on the canvas is selected
- **THEN** its outline is drawn in ink blue rather than the browser-default blue

#### Scenario: A highlighted element uses an ink-blue tint

- **WHEN** an element linked from the editor text is highlighted on the canvas
- **THEN** its label background is a pale ink-blue tint, not `yellow`

### Requirement: Serif carries hierarchy, sans carries chrome

Headings SHALL render in a serif family and UI chrome (buttons, select fields,
menu items, diagram labels) SHALL render in a sans family. Headings SHALL NOT
use a weight heavier than 500, body copy SHALL NOT use synthetic bold, and the
heading's space above SHALL exceed its space below.

#### Scenario: Landing heading is serif

- **WHEN** the landing page is open
- **THEN** the page heading is rendered in a serif family with a weight no heavier than 500

#### Scenario: Controls are sans

- **WHEN** any button, select field, or menu item is rendered
- **THEN** its label is rendered in a sans family

### Requirement: Two button variants

The application SHALL render buttons in exactly two variants. A primary button
SHALL have an ink-blue fill and ivory text. A secondary button SHALL have a
warm-sand fill, a warm hairline border, and dark-warm text. Both SHALL use a
consistent, modest corner radius, and SHALL NOT stack a fill, a border, and a
shadow on the same control.

#### Scenario: Landing actions separate primary from secondary

- **WHEN** the landing page is open
- **THEN** starting a new model is the primary variant and every example entry is the secondary variant

#### Scenario: Editor controls are secondary

- **WHEN** a control such as undo, redo, zoom, or add-view is rendered
- **THEN** it uses the secondary variant, and disabled controls are visibly muted

### Requirement: Diagram canvas and code editor share the palette

The diagram canvas SHALL render on the parchment background with a warm
hairline grid, ivory element boxes with warm borders and near-black labels, and
warm-neutral relation lines with near-black labels. The code editor pane SHALL
use a parchment background with syntax colours drawn from the same palette.
Neither surface SHALL be pure white, and the grid SHALL NOT be cool gray.

#### Scenario: Canvas is parchment with a warm grid

- **WHEN** a view is rendered
- **THEN** the canvas background is parchment and its grid lines are a warm neutral, not `#cccccc` cool gray

#### Scenario: Element boxes are ivory with warm borders

- **WHEN** a container, system, actor, or component is rendered
- **THEN** its box is filled with ivory, outlined with the warm border colour, and its label is near-black

#### Scenario: Editor pane matches the canvas

- **WHEN** the editor page is open
- **THEN** the code editor background is parchment and its syntax colours come from the application palette
