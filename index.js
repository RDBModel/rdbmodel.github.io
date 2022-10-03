import YAML, { YAMLMap, YAMLSeq } from 'yaml';
import EditorWorker from 'url:monaco-editor/esm/vs/editor/editor.worker.js';
import * as monaco from 'monaco-editor';
import { Elm } from './src/Main.elm';

import diagramGif from 'url:./src/img/diagram.gif';
import editorGif from 'url:./src/img/editor.gif';

window.MonacoEnvironment = {
	getWorkerUrl: function (_moduleId, label) {
    return EditorWorker;
  },
};

const initialValue =
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
  node: document.getElementById("root"),
  flags: [diagramGif, editorGif]
});

let editor;
let decorations = [];

function initMonaco() {
  if (editor != null) {
    editor.dispose()
  }
  editor = monaco.editor.create(document.getElementById("monaco"), {
    // theme: 'vs-dark',
    value: YAML.stringify(YAML.parse(initialValue.trim())),
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
      app.ports.monacoEditorSavedValue.send(editor.getValue());
    }
  );

  // remove editor focus if we clicked outside of it
  document.getElementById("main-graph").addEventListener('click', (ev) => {
    if (editor.hasWidgetFocus()) {
      document.activeElement.blur();
    }
  })

  app.ports.monacoEditorValue.send(editor.getValue());
}

app.ports.removePoint.subscribe((message) => unityOfWork(removePoint, message));
app.ports.addPoint.subscribe((message) => unityOfWork(addPoint, message));
app.ports.initMonacoResponse.subscribe(() => initMonaco());
app.ports.updateElementPosition.subscribe((message) => unityOfWork(updateElementPosition, message));
app.ports.updatePointPosition.subscribe((message) => unityOfWork(updatePointPosition, message));
app.ports.updateMonacoValue.subscribe((message) => updateMonacoValue(message));
app.ports.validationErrors.subscribe((message) => {
  const newDecorators = []
  if (message !== '') showErrors(message, newDecorators);
  decorations = editor.deltaDecorations(
    decorations,
    newDecorators
  );
});
// delay monaco initialization (via Elm)
app.ports.initMonacoRequest.send(null);

function showErrors(message, newDecorators) {
  console.log(message)
  // todo: as we are receiving yaml here, need to parse it using yaml
  const parsed = YAML.parse(message)

  // const allErrors = []
  // for (const key in parsed) {
  //   allErrors.push([key, error])
  // }
  // if (message.indexOf('Non-unique keys in record:') > -1) {

  // } else {
  //   const errorsByType = message.split(';');
  //   for (const errorByType of errorsByType) {
  //     const splittedErrorByType = errorByType.split(':')
  //     if (splittedErrorByType.length === 3) {
  //       const [viewName, name, errors] = errorByType.split(':');
  //       const splittedErrors = [...new Set(errors.split(','))];
  //       for (const error of splittedErrors) {
  //         allErrors.push([name, error])
  //       }
  //     } else if (splittedErrorByType.length === 2) {
  //       const [name, errors] = errorByType.split(':');
  //       const splittedErrors = [...new Set(errors.split(','))];
  //       for (const error of splittedErrors) {
  //         allErrors.push([name, error])
  //       }
  //     } else {
  //       console.log('Unsupported error')
  //       console.error(errorByType)
  //     }
  //   }
  // }
  // const value = editor.getValue();
  // const lineCounter = new YAML.LineCounter();
  // const currentDocument = YAML.parseDocument(value, { lineCounter: lineCounter, keepSourceTokens: true });
  // console.dir(allErrors, {depth: null})
  // console.dir(currentDocument, {depth: null})

  // const content = currentDocument.contents

  // populateAnalyzers(content, 0)

  function populateAnalyzers (value, isDomainOrView) {
    if ('items' in value) {
      for (const subValue of value.items) {
        if ('key' in subValue && subValue.key.type === 'PLAIN') {
          if (subValue.key.value === 'domain') {
            isDomainOrView = 1
          } else if (subValue.key.value === 'views') {
            isDomainOrView = 2
          }
          for (const [name, error] of allErrors) {
            const case1 = (name === 'Elements with empty names' && isDomainOrView === 1) || name !== 'Elements with empty names'
            const case2 = (name === 'Duplicated element keys' && isDomainOrView === 1) || name !== 'Duplicated element keys'
            if (subValue.key.value === error && case1 && case2) {
              const { line, col } = lineCounter.linePos(subValue.key.srcToken.offset)
              newDecorators.push({
                range: new monaco.Range(line, col, line, col + error.length + 1),
                options: {
                  inlineClassName: 'myInlineDecoration',
                  hoverMessage: { value: name }
                }
              });
            }
          }
        }
        if (subValue instanceof YAMLMap) {
          populateAnalyzers(subValue, isDomainOrView)
        } else if ('type' in subValue && subValue.type === 'PLAIN') {
          for (const [name, error] of allErrors) {
            if (subValue.value === error) {
              console.log(subValue.value)
              const { line, col } = lineCounter.linePos(subValue.srcToken.offset)
              newDecorators.push({
                range: new monaco.Range(line, col, line, col + error.length + 1),
                options: {
                  inlineClassName: 'myInlineDecoration',
                  hoverMessage: { value: name }
                }
              });
            }
          }
        } else if (subValue.value instanceof YAMLMap || subValue.value instanceof YAMLSeq) {
          populateAnalyzers(subValue.value, isDomainOrView)
        }
      }
    }
  }
}

function updateMonacoValue( message) {
  editor.setValue(message);
}

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
  const newModel = YAML.stringify(currentModel)
  editor.setValue(newModel);
  app.ports.monacoEditorValue.send(newModel);
}
