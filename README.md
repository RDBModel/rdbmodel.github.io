# RDB Model

This web application simplifies creating and visualizing software architecture using a C4 model variant. You can edit YAML files to represent your application's domain. You can create multiple views to understand and communicate relationships within the software system.

## Functionality Highlights

- Create and edit YAML files representing the software architecture domain.
- Generate multiple views to visualize connections between actors, systems, containers, and components.
- Layout elements and edges for clear, visually appealing architecture representations.
- Features like zoom, scroll, and navigation enhance exploration of the software architecture.
- Error highlighting ensures consistency and clarity during the editing process.

## C4 Model Overview

The C4 model represents software systems through four main entities: actors, systems, containers, and components.

- **Actors:** Represent users or external systems interacting with the software.
- **Systems:** Represent applications or services providing value to users.
- **Containers:** Deployable units that can operate independently.
- **Components:** Buildable packages, like artifacts in a file system.

## Getting Started

1. Start with a minimal domain in the editor:

```yaml
domain:
  name: Name
  actors:
    actor-1:
      name: Actor
      relations:
        - uses - system-1
  systems:
    system-1:
      name: System 1
      containers:
        container-1:
          name: container 1
          components:
            container-1--component-1:
              name: component 1
```

2. Add actors, systems, and relations.
3. Define containers and their relations.
4. Add components to containers and specify relations.
5. Create views to visualize the architecture.

Start designing your C4 model with the RDB Model Web Application today!
