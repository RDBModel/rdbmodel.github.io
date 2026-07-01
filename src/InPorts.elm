port module InPorts exposing (..)


port editorValueSaved : (String -> msg) -> Sub msg


port initEditorRequest : (() -> msg) -> Sub msg


port requestValueToSave : (() -> msg) -> Sub msg


port onWheel : (() -> msg) -> Sub msg


port focusContainerInView : (String -> msg) -> Sub msg


port unfocusContainerInView : (() -> msg) -> Sub msg


port receivedFromLocalStorage : (Maybe String -> msg) -> Sub msg
