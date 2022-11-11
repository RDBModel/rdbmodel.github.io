port module JsInterop exposing (..)

port monacoEditorInitialValue : (String -> msg) -> Sub msg
port monacoEditorSavedValue : (String -> msg) -> Sub msg
port initMonacoRequest : (() -> msg) -> Sub msg

port initMonacoResponse : () -> Cmd msg
port updateMonacoValue : String -> Cmd msg
port validationErrors : String -> Cmd msg
port openFileOpenDialog : () -> Cmd msg
