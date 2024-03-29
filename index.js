import YAML, { YAMLMap, YAMLSeq, LineCounter } from 'yaml'
import * as monaco from 'monaco-editor'
import { Elm } from './src/Main.elm'
import { setDiagnosticsOptions } from 'monaco-yaml'

const version = '0.3.5'

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: [window.showOpenFilePicker !== undefined, version]
})

let editor
let model
let decorations = []
let currentElements = []

function initMonaco(initialValue) {
  if (editor != null) {
    model.dispose()
    editor.dispose()
  }

  const modelUri = monaco.Uri.parse('internal.yaml');

  setDiagnosticsOptions({
    enableSchemaRequest: true,
    hover: true,
    completion: true,
    validate: true,
    format: true,
    schemas: [{
      uri: 'https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/schema.json',
      fileMatch: [String(modelUri)],
    }],
  });
  model = monaco.editor.createModel(modifyYamlValue(initialValue), 'yaml', modelUri)
  editor = monaco.editor.create(document.getElementById('monaco'), {
    // theme: 'vs-dark',
    automaticLayout: true,
    model: model,
    //value: modifyYamlValue(initialValue),
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
  })

  editor.addCommand(
    monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS,
    function () {
      app.ports.monacoEditorSavedValue.send(editor.getValue())
    }
  )

  editor.onMouseDown(function (e) {
    const position = e.target.position;
    const lineContent = editor.getModel().getLineContent(position.lineNumber);
    const foundElement = currentElements.find(el => lineContent.trim() === el + ':')
    if (foundElement) {
      app.ports.focusContainerInView.send(foundElement)
    }
  });

  editor.onMouseUp(function () {
    app.ports.unfocusContainerInView.send(null)
  })

  // remove editor focus if we clicked outside of it
  document.getElementById('main-graph').parentNode.parentNode.addEventListener('click', (ev) => {
    if (editor.hasWidgetFocus()) {
      // TODO cover clicks on button
      document.activeElement.blur()
      app.ports.monacoEditorSavedValue.send(editor.getValue())
    }
    if (ev.target.className !== 'elm-select-input') {
      document.querySelectorAll('.elm-select-input').forEach(el => el.blur())
    }
  })
}

app.ports.zoomMsgReceived.subscribe(() => {
  app.ports.onWheel.send(null)
})
app.ports.focusContainerInEditor.subscribe((viewElementKey) => {
  // Get the editor's model
  const model = editor.getModel()

  if (model) {
      // Search for the text within the model
      const matches = model.findMatches(viewElementKey + ":", true, false, true, null, true)

      if (matches.length > 0) {
          const match = matches[0] // Assuming you want to focus on the first match
          const position = match.range.getStartPosition()

          // Use the revealPosition method to focus on the specified position
          editor.revealPosition(position, monaco.editor.ScrollType.Immediate)

          // Create a decoration range using the match range
          const decorationRange = {
            startLineNumber: match.range.startLineNumber,
            startColumn: match.range.startColumn,
            endLineNumber: match.range.endLineNumber,
            endColumn: match.range.endColumn
          };

          // Define the decoration options (e.g., background color)
          const decorationOptions = {
              isWholeLine: false,
              className: 'highlighted-text' // CSS class for styling
          };

          // Add the decoration to the editor's model
          editor.deltaDecorations(decorations, [{
              range: decorationRange,
              options: decorationOptions
          }]);
      }
  }
})
app.ports.openFileOpenDialog.subscribe(async () => await showFilePicker())
app.ports.openSaveFileDialog.subscribe(() => app.ports.requestValueToSave.send(null))
app.ports.saveValueToFile.subscribe(async (value) => await showFileSaveDialog(value))

app.ports.initMonacoResponse.subscribe((message) => initMonaco(message))
app.ports.tryToSaveCurrentEditorValue.subscribe(() => app.ports.monacoEditorSavedValue.send(editor.getValue()))
app.ports.updateMonacoValue.subscribe((message) => updateMonacoValue(message))
app.ports.validationErrors.subscribe((message) => {
  const newDecorators = []
  if (message !== '') showErrors(message, newDecorators)
  decorations = editor.deltaDecorations(
    decorations,
    newDecorators
  )
})
app.ports.saveToLocalStorage.subscribe((value) => saveToLocalStorage(value))
app.ports.getFromLocalStorage.subscribe(() => getFromLocalStorage())
app.ports.shareElementsAtCurrentView.subscribe((message) => currentElements = message)
// delay monaco initialization (via Elm) test
// TODO: remove?
// app.ports.initMonacoRequest.send(null)

// TODO: import from ELM
const domainErrorKeys = ['Elements with empty name', 'Not existing target', 'Duplicated element key']
const viewsErrorKeys = ['Not existing element in domain', 'Not existing relation in domain']
const yamlParseError = ['Non-unique keys in record']
function showErrors(message, newDecorators) {
  const allErrors = []
  console.error(message)
  if (message.includes(yamlParseError)) {
    const elementName = message.split(`${yamlParseError}:`)[1].trim()
    allErrors.push([yamlParseError, elementName])
  } else {
    const parsedMessage = JSON.parse(message)
    for (const key in parsedMessage) {
      if (domainErrorKeys.includes(key)) {
        for (const error of parsedMessage[key]) {
          allErrors.push([key, error])
        }
      } else {
        const viewName = key
        for (const viewError of parsedMessage[viewName]) {
          for (const viewErrorKey in viewError) {
            if (viewErrorKey === 'Not existing element in domain') {
              for (const error of viewError[viewErrorKey]) {
                allErrors.push([viewErrorKey, error])
              }
            } else if (viewErrorKey === 'Not existing relation in domain') {
              for (const containerKey in viewError[viewErrorKey]) {
                console.log(viewError[viewErrorKey])
                for (const relation of viewError[viewErrorKey][containerKey]) {
                  allErrors.push([viewErrorKey, relation])
                }
              }
            }
          }
        }
      }
    }
  }
  const value = editor.getValue()
  const lineCounter = new LineCounter()
  const currentDocument = YAML.parseDocument(value, { lineCounter: lineCounter, keepSourceTokens: true })
  console.dir(allErrors, {depth: null})
  console.dir(currentDocument, {depth: null})

  const content = currentDocument.contents

  populateAnalyzers(content, 0)

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
            const domainError = domainErrorKeys.indexOf(name) > -1
            if (subValue.key.value === error && domainError && isDomainOrView === 1) {
              pushDecorator(subValue.key.srcToken.offset, error, name)
            }
            const viewsError = viewsErrorKeys.indexOf(name) > -1
            if (subValue.key.value === error && viewsError && isDomainOrView === 2) {
              pushDecorator(subValue.key.srcToken.offset, error, name)
            }
            if (subValue.key.value === error && !viewsError && !domainError) {
              pushDecorator(subValue.key.srcToken.offset, error, name)
            }
          }
        }
        if (subValue instanceof YAMLMap) {
          populateAnalyzers(subValue, isDomainOrView)
        } else if ('type' in subValue && subValue.type === 'PLAIN') {
          for (const [name, error] of allErrors) {
            const domainError = domainErrorKeys.indexOf(name) > -1
            if (subValue.value === error && domainError && isDomainOrView === 1) {
              pushDecorator(subValue.srcToken.offset, error, name)
            }
            const viewsError = viewsErrorKeys.indexOf(name) > -1
            if (subValue.value === error && viewsError && isDomainOrView === 2) {
              pushDecorator(subValue.srcToken.offset, error, name)
            }
            if (subValue.value === error && !viewsError && !domainError) {
              pushDecorator(subValue.srcToken.offset, error, name)
            }
          }
        } else if (subValue.value instanceof YAMLMap || subValue.value instanceof YAMLSeq) {
          populateAnalyzers(subValue.value, isDomainOrView)
        }
      }
    }
  }

  function pushDecorator (offset, error, name) {
    const { line, col } = lineCounter.linePos(offset)
    newDecorators.push({
      range: new monaco.Range(line, col, line, col + error.length + 1),
      options: {
        inlineClassName: 'error',
        hoverMessage: { value: name }
      }
    })
  }
}

function updateMonacoValue(message) {
  editor.setValue(modifyYamlValue(message))
}

async function showFilePicker() {
  const file = await window.showOpenFilePicker({
    types: [
      {
        description: 'Yaml',
        accept: {
          'yaml/*': ['.yaml', '.yml']
        }
      },
    ],
    excludeAcceptAllOption: true,
    multiple: false
  })

  // Track the dir in history.state
  const state = history.state || {}
  state.currentFile = file[0]
  history.replaceState(state, '')
  const content = (await readFileAsync(await state.currentFile.getFile())).replace(/\r/g, '')
  editor.setValue(content)
  app.ports.monacoEditorSavedValue.send(content)
}

function readFileAsync(file) {
  return new Promise((resolve, reject) => {
    let reader = new FileReader()
    reader.onload = () => {
      resolve(reader.result)
    };
    reader.onerror = reject
    reader.readAsText(file)
  })
}

function modifyYamlValue(value) {
  // temp fix - https://github.com/MaybeJustJames/yaml/issues/28
  return value
    // .replace(/relations:\n\s+\n/g, 'relations: []\n')
    // .replace(/relations:\n\s+$/, 'relations: []\n')
    // .replace(/containers:\n\s+\n/g, 'containers: {}\n')
    // .replace(/containers:\n\s+$/, 'containers: {}\n')
    // .replace(/elements:\n\s+\n/, 'elements: {}\n')
    // .replace(/elements:\n\s+$/, 'elements: {}\n')
    // .replace(/views:\n\s+$/, 'views: {}\n')
    // .replace(/:\n\s+\n/g, ': []\n')
    // .replace(/:\n\s+$/, ': []\n')
    // .replace(/-\n\s+x:/g, '- x:')
}

async function showFileSaveDialog(value) {
  const newHandle = await window.showSaveFilePicker()

  const writableStream = await newHandle.createWritable({types: [{
    description: 'Yaml',
    accept: {'text/plain': ['.yaml']},
  }]});

  const blob = new Blob([modifyYamlValue(value)], {
    type: 'text/plain',
  });

  await writableStream.write(blob)
  await writableStream.close()
}

const localStorageKey = 'rdb-model-current-domain'

function saveToLocalStorage(value) {
  localStorage.setItem(localStorageKey, value)
}

function getFromLocalStorage() {
  const value = localStorage.getItem(localStorageKey)
  app.ports.receivedFromLocalStorage.send(value)
}
