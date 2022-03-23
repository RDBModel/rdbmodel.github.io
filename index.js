import { YAML } from './node_modules/yaml/browser/dist/index.js';

const v = 
`domain:
  name: Name
  description: Description
  actors:
    actor-1:
      name: Actor
      description: Description
      relations:
        - uses - delivery-1
  rings:
    ring-1:
      name: Ring 1 name
      description: Description
      relations: []
      deliveries: {}
    ring-2:
      name: Ring 2 name
      description: Description
      relations:
        - uses - ring-1
      deliveries:
        delivery-1:
          name: delivery 1
          description: Description
          relations:
            - calls - delivery-2
            - uses - ring-1
          blocks:
            delivery-1--block-1:
              name: block 1
              description: Description
              relations:
                - uses - delivery-1--block-2
                - calls - delivery-2--block-1
                - uses - ring-1
            delivery-1--block-2:
              name: block 2
              description: Description
              relations:
                []
        delivery-2:
          name: delivery 2
          description: Description
          relations:
            []
          blocks:
            delivery-2--block-1:
              name: block 1
              description: Description
              relations:
                - uses - delivery-2--block-2
            delivery-2--block-2:
              name: block 2
              description: Description
              relations:
                []
views:
  view-1:
    elements:
      ring-1:
        x: 100
        y: 100
      delivery-1:
        x: 200
        y: 200
        relations:
          'calls - delivery-2':
            - x: 300
              y: 150
          'uses - ring-1': []
      delivery-2:
        x: 300
        y: 300
  view-2:
    elements:
      actor-1:
        x: 100
        y: 100
        relations:
          'uses - delivery-1': []
      delivery-1:
        x: 200
        y: 200`;

const app = Elm.Main.init({
  node: document.getElementById("root")
});

let editor;

function initMonaco() {
  editor = monaco.editor.create(document.getElementById("monaco"), {
    theme: 'vs-dark',
    value: v,
    language: 'yaml',
    wordWrap: 'off',
    automaticLayout: true,
    lineNumbers: 'off',
    glyphMargin: false,
    minimap: {
      enabled: false
    },
    scrollbar: {
      vertical: 'auto'
    }
  });

  editor.addCommand(
    monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS,
    function () {
      app.ports.monacoEditorValue.send(editor.getValue());
    }
  );

  app.ports.monacoEditorValue.send(editor.getValue());
}

require(['vs/editor/editor.main'], () => {
  app.ports.removePoint.subscribe((message) => unityOfWork(removePoint, message));
  app.ports.addPoint.subscribe((message) => unityOfWork(addPoint, message));
  app.ports.initMonacoResponse.subscribe(() => initMonaco());
  app.ports.updateElementPosition.subscribe((message) => unityOfWork(updateElementPosition, message));
  app.ports.updatePointPosition.subscribe((message) => unityOfWork(updatePointPosition, message));
  // delay monaco initialization (via Elm)
  app.ports.initMonacoRequest.send(null);
});

function removePoint(currentModel, message) {
  const elementName = message.elementKey;
  const view = message.view;
  const relationName = message.relation;
  const indexToDelete = parseInt(message.pointIndex);
  currentModel['views'][view]['elements'][elementName]['relations'][relationName].splice(indexToDelete, 1);
}

function addPoint(currentModel, message) {
  const elementName = message.elementKey;
  const view = message.view;
  const relationName = message.relation;
  const index = parseInt(message.pointIndex);
  const targetRelation = currentModel['views'][view]['elements'][elementName]['relations'][relationName];
  targetRelation.splice(index, 0, {});
  updateCoords(targetRelation[index], message.x, message.y);
}

function updateElementPosition(currentModel, message) {
  const elementName = message.elementKey;
  const view = message.view;
  const targetElement = currentModel['views'][view]['elements'][elementName];
  updateCoords(targetElement, message.x, message.y);
}

function updatePointPosition(currentModel, message) {
  const elementName = message.elementKey;
  const relationName = message.relation;
  const view = message.view;
  const index = parseInt(message.pointIndex);
  const targetRelation = currentModel['views'][view]['elements'][elementName]['relations'][relationName];
  targetRelation[index] = targetRelation[index] || {};
  updateCoords(targetRelation[index], message.x, message.y);
}

function updateCoords(item, x, y) {
  item['x'] = x;
  item['y'] = y;
}

function unityOfWork(func, message) {
  const currentModel = YAML.parse(editor.getValue());
  func(currentModel, message);
  editor.setValue(YAML.stringify(currentModel));
}
