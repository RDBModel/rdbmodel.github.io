

require(['vs/editor/editor.main'], () => {
  const app = Elm.Main.init({
    node: document.getElementById("root")
  });

  const editor = monaco.editor.create(document.getElementById("monaco"), {
    theme: 'vs-dark',
    value: '',
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
