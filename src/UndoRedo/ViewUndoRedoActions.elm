module UndoRedo.ViewUndoRedoActions exposing (Action(..), MonacoValue, apply)

import Dict exposing (Dict)
import Domain.Domain exposing (Domain, View)
import Domain.DomainEncoder exposing (rdbEncode)
import JsInterop exposing (updateMonacoValue)


type Action
    = UpdateMonacoValue


type alias MonacoValue =
    { views : Dict String View
    , domain : Maybe Domain
    }


apply : MonacoValue -> List Action -> Cmd msg
apply monacoValue =
    List.foldl (prepareOutput monacoValue) Cmd.none


prepareOutput : MonacoValue -> Action -> Cmd msg -> Cmd msg
prepareOutput monacoValue action cmd =
    case action of
        UpdateMonacoValue ->
            Cmd.batch [ updateMonacoValue (rdbEncode monacoValue), cmd ]
