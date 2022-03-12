import YAML from 'yaml';
import EditorWorker from 'url:monaco-editor/esm/vs/editor/editor.worker.js';
import * as monaco from 'monaco-editor';
import { Elm } from './src/Main.elm';

window.MonacoEnvironment = {
	getWorkerUrl: function (moduleId, label) {
		return EditorWorker;
	}
};

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
        y: 300`;

const app = Elm.Main.init({
  node: document.getElementById("root")
});

const editor = monaco.editor.create(document.getElementById("monaco"), {
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
    app.ports.messageReceiver.send(editor.getValue());
  }
);

// TODO refactor
app.ports.sendMessage.subscribe((message) => {
  const currentModel = YAML.parse(editor.getValue());
  const splitted = message.split('|');
  if (splitted.length == 2) {
    // element moved
    const elementName = splitted[0];
    const xy = splitted[1].split(',');
    currentModel['views']['view-1']['elements'][elementName]['x'] = parseFloat(xy[0]);
    currentModel['views']['view-1']['elements'][elementName]['y'] = parseFloat(xy[1]);
    editor.setValue(YAML.stringify(currentModel));
  } else if (splitted.length == 4) {
    const elementName = splitted[0];
    const relationName = splitted[1];
    if (splitted[2] === 'del') {
      const indexToDelete = parseInt(splitted[3]);
      currentModel['views']['view-1']['elements'][elementName]['relations'][relationName].splice(indexToDelete, 1);
    } else {
      const index = parseInt(splitted[2]);
      const xy = splitted[3].split(',');
      if (!currentModel['views']['view-1']['elements'][elementName]['relations'][relationName][index]) {
        currentModel['views']['view-1']['elements'][elementName]['relations'][relationName][index] = {};
      }
      currentModel['views']['view-1']['elements'][elementName]['relations'][relationName][index]['x'] = parseFloat(xy[0]);
      currentModel['views']['view-1']['elements'][elementName]['relations'][relationName][index]['y'] = parseFloat(xy[1]);
    }
    editor.setValue(YAML.stringify(currentModel));
  } else if (splitted.length == 5) {
    const elementName = splitted[0];
    const relationName = splitted[1];
    const type = splitted[2];
    if (type === 'add') {
      const index = parseInt(splitted[3]);
      const xy = splitted[4].split(',');
      currentModel['views']['view-1']['elements'][elementName]['relations'][relationName].splice(index, 0, {});
      currentModel['views']['view-1']['elements'][elementName]['relations'][relationName][index]['x'] = parseFloat(xy[0]);
      currentModel['views']['view-1']['elements'][elementName]['relations'][relationName][index]['y'] = parseFloat(xy[1]);
      editor.setValue(YAML.stringify(currentModel));
    }
  }
  console.log(message)
});
