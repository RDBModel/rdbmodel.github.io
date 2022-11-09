import YAML, { YAMLMap, YAMLSeq, LineCounter } from 'yaml'
import * as monaco from 'monaco-editor'
import { Elm } from './src/Main.elm'

window.MonacoEnvironment = {
  getWorkerUrl: function (_moduleId, label) {
    return EditorWorker
  },
}

const initialValue =
`domain:
  name: Name
  description: Description
  actors:
    actor-1:
      name: Actor
      description: Description
      relations:
        - uses - container-1
  systems:
    system-1:
      name: System 1 name
      description: Description
      relations: []
      containers: {}
    system-2:
      name: System 2 name
      description: Description
      relations:
        - uses - system-1
      containers:
        container-1:
          name: container 1
          description: Description
          relations:
            - calls - container-2
            - uses - system-1
          components:
            container-1--component-1:
              name: component 1
              description: Description
              relations:
                - uses - container-1--component-2
                - calls - container-2--component-1
                - uses - system-1
            container-1--component-2:
              name: component 2
              description: Description
              relations:
                []
        container-2:
          name: container 2
          description: Description
          relations:
            []
          components:
            container-2--component-1:
              name: component 1
              description: Description
              relations:
                - uses - container-2--component-2
            container-2--component-2:
              name: component 2
              description: Description
              relations:
                []
views:
  view-1:
    elements:
      system-1:
        x: 100
        y: 100
      container-1:
        x: 200
        y: 200
        relations:
          'calls - container-2':
            - x: 300
              y: 150
          'uses - system-1': []
      container-2:
        x: 300
        y: 300
  view-2:
    elements:
      actor-1:
        x: 100
        y: 100
        relations:
          'uses - container-1': []
      container-1:
        x: 200
        y: 200`

const app = Elm.Main.init({
  node: document.getElementById("root")
})

let editor
let decorations = []

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
  })

  editor.addCommand(
    monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS,
    function () {
      app.ports.monacoEditorSavedValue.send(editor.getValue())
    }
  )

  // remove editor focus if we clicked outside of it
  document.getElementById("main-graph").addEventListener('click', (ev) => {
    if (editor.hasWidgetFocus()) {
      document.activeElement.blur()
    }
    if (ev.explicitOriginalTarget.className !== 'elm-select-input') {
      document.querySelectorAll('.elm-select-input').forEach(el => el.blur())
    }
  })

  app.ports.monacoEditorInitialValue.send(editor.getValue())
}

app.ports.initMonacoResponse.subscribe(() => initMonaco())
app.ports.updateMonacoValue.subscribe((message) => updateMonacoValue(message))
app.ports.validationErrors.subscribe((message) => {
  const newDecorators = []
  if (message !== '') showErrors(message, newDecorators)
  decorations = editor.deltaDecorations(
    decorations,
    newDecorators
  )
})
// delay monaco initialization (via Elm) test
app.ports.initMonacoRequest.send(null)

// TODO: import from ELM
const domainErrorKeys = ['Elements with empty name', 'Not existing target', 'Duplicated element key']
const yamlParseError = 'Non-unique keys in record'
function showErrors(message, newDecorators) {
  console.log(message)
  const allErrors = []
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
                allErrors.push([viewErrorKey, viewError[viewErrorKey][containerKey]])
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
            const case1 = (name === 'Elements with empty name' && isDomainOrView === 1) || name !== 'Elements with empty name'
            const case2 = (name === 'Duplicated element key' && isDomainOrView === 1) || name !== 'Duplicated element key'
            if (subValue.key.value === error && case1 && case2) {
              const { line, col } = lineCounter.linePos(subValue.key.srcToken.offset)
              newDecorators.push({
                range: new monaco.Range(line, col, line, col + error.length + 1),
                options: {
                  inlineClassName: 'error',
                  hoverMessage: { value: name }
                }
              })
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
                  inlineClassName: 'error',
                  hoverMessage: { value: name }
                }
              })
            }
          }
        } else if (subValue.value instanceof YAMLMap || subValue.value instanceof YAMLSeq) {
          populateAnalyzers(subValue.value, isDomainOrView)
        }
      }
    }
  }
}

function updateMonacoValue(message) {
  // temp fix - https://github.com/MaybeJustJames/yaml/issues/28
  const updatedMessage = message
    .replace(/relations:\n\s+\n/g, "relations: []\n")
    .replace(/containers:\n\s+\n/g, "containers: {}\n")
    .replace(/:\n\s+\n/g, ": []\n")
    .replace(/-\n\s+x:/g, "- x:")
  editor.setValue(updatedMessage)
}
