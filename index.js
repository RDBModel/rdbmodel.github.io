

require(['vs/editor/editor.main'], () => {
    const app = Elm.Main.init({
        node: document.getElementById("root")
    });

    const editor = monaco.editor.create(document.getElementById("monaco"), {
        theme: 'vs-dark',
        model: monaco.editor.createModel("", "yaml"),
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

    app.ports.sendMessage.subscribe((message) => {
        editor.setValue(message);
    });

    editor.onDidChangeModelContent(() => {
        app.ports.messageReceiver.send(editor.getValue());
    });
});
