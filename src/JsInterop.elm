port module JsInterop exposing (monacoEditorInitialValue, initMonacoResponse, initMonacoRequest,
  updateMonacoValue, monacoEditorSavedValue, validationErrors)
import Json.Encode as E
import Domain exposing (Relation)
import Domain exposing (getStringFromRelation)

port monacoEditorInitialValue : (String -> msg) -> Sub msg
port monacoEditorSavedValue : (String -> msg) -> Sub msg
port initMonacoRequest : (() -> msg) -> Sub msg

port initMonacoResponse : () -> Cmd msg
port updateMonacoValue : String -> Cmd msg
port validationErrors : String -> Cmd msg
