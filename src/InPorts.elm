port module InPorts exposing (..)


port monacoEditorSavedValue : (String -> msg) -> Sub msg


port initMonacoRequest : (() -> msg) -> Sub msg


port requestValueToSave : (() -> msg) -> Sub msg


port onWheel : (() -> msg) -> Sub msg


port focusContainerInView : (String -> msg) -> Sub msg


port receivedFromLocalStorage : (Maybe String -> msg) -> Sub msg
