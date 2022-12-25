port module JsInterop exposing (..)


port monacoEditorSavedValue : (String -> msg) -> Sub msg


port initMonacoRequest : (() -> msg) -> Sub msg


port requestValueToSave : (() -> msg) -> Sub msg


port onWheel : (() -> msg) -> Sub msg


port initMonacoResponse : String -> Cmd msg


port zoomMsgReceived : () -> Cmd msg


port updateMonacoValue : String -> Cmd msg


port validationErrors : String -> Cmd msg


port openFileOpenDialog : () -> Cmd msg


port openSaveFileDialog : () -> Cmd msg


port saveValueToFile : String -> Cmd msg


port saveToLocalStorage : String -> Cmd msg


port getFromLocalStorage : () -> Cmd msg


port receivedFromLocalStorage : (Maybe String -> msg) -> Sub msg
