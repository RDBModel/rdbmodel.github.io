port module OutPorts exposing (..)


port initEditorResponse : String -> Cmd msg


port zoomMsgReceived : () -> Cmd msg


port updateEditorValue : String -> Cmd msg


port validationErrors : String -> Cmd msg


port openFileOpenDialog : () -> Cmd msg


port openSaveFileDialog : () -> Cmd msg


port saveValueToFile : String -> Cmd msg


port saveToLocalStorage : String -> Cmd msg


port getFromLocalStorage : () -> Cmd msg


port tryToSaveCurrentEditorValue : () -> Cmd msg


port shareElementsAtCurrentView : List String -> Cmd msg


port focusContainerInEditor : String -> Cmd msg
