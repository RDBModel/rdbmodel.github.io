# Welcome to the RDB Model!

This web application allows you to create and visualize software architecture using a simplified version of the C4 model. You can create and edit yaml files that represent the domain of your application. It's important to note that while there is only one domain that represents the architecture, but it is possible to create multiple views of this domain to better understand and communicate the relationships within a software system(s).

Views allow to see the connections between actors, systems, containers, and their components. It is possible to layout the elements and edges of a view, that allowing to arrange and present the software architecture in a clear and visually appealing way. Other features like zoom, scroll, and navigate through the selected view, are allowing to easily explore and understand the software architecture in greater detail.

This app also helps you during the editing process by highlighting any inconsistencies in the model and views using error messages. This ensures that the software architecture is clear and consistent.

The C4 model is a powerful tool for understanding and communicating the structure of a software system, and is typically used to represent the domain of the application. There are the four main types of entities in the C4 model: actors, systems, containers, and components. Systems in the C4 model usually represent applications or services that bring value to the end users, while containers are units that can usually be deployed independently. Components, on the other hand, are buildable packages that are usually represented as artifacts in the file system.

Whether you're a seasoned software architect or just starting out, our application makes it easy to design and understand your software architecture. Start creating your C4 model with the RDB Model Web Application today!

# Getting started

1. Start with minimal domain in the editor:

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

2. Add all actors and systems. Usually there is only one target system that is managed by your company/team. All others system acts as external systems (so you have no information about their contains/components) and the target system is using or used by such external systems.

3. Add all relations between actors, external systems and the target system. Actors use the target system and they are clients. One type of external systems can use the target system and other type of external systems can be used by the target system.

4. Add all containers of the target system (units that are deployed or can be deployed independently).

5. Add all relations between containers, e.g. web service is using database.

6. Add all components of created containers (buildable packages, dlls, database schemas, jars).

7. Add all relations between components

8. Start creating views after domain. It is possible to create views vie editor and also via graphical interface.
