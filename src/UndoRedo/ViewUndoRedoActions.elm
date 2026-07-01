module UndoRedo.ViewUndoRedoActions exposing (Action(..), EditorValue, apply)

import Dict exposing (Dict)
import Domain.Domain exposing (Domain, View)
import Domain.DomainEncoder exposing (rdbEncode)
import OutPorts exposing (updateEditorValue)


type Action
    = UpdateEditorValue


type alias EditorValue =
    { views : Dict String View
    , domain : Maybe Domain
    }


apply : EditorValue -> List Action -> Cmd msg
apply editorValue =
    List.foldl (prepareOutput editorValue) Cmd.none


prepareOutput : EditorValue -> Action -> Cmd msg -> Cmd msg
prepareOutput editorValue action cmd =
    case action of
        UpdateEditorValue ->
            Cmd.batch [ updateEditorValue (rdbEncode editorValue), cmd ]
