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

require(['vs/editor/editor.main'], () => {
  const app = Elm.Main.init({
    node: document.getElementById("root")
  });

  const editor = monaco.editor.create(document.getElementById("monaco"), {
    theme: 'vs-dark',
    value: v,
    language: 'yaml',
    wordWrap: 'on',
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

  app.ports.sendMessage.subscribe((message) => {
    editor.setValue(message);
  });
});
