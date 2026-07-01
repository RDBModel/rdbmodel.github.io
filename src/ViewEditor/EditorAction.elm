module ViewEditor.EditorAction exposing (apply)

import Browser.Navigation as Nav
import Dict exposing (Dict)
import Domain.Domain exposing (Domain, View)
import Domain.DomainEncoder exposing (rdbEncode)
import Error.Error as Error
import OutPorts exposing (updateEditorValue)
import UndoRedo.ViewUndoRedo exposing (UndoRedoEditorValue, mapPresent, newRecord)
import ViewEditor.Editor exposing (Action(..))
import ViewEditor.Msg exposing (Msg)


type alias Params msg =
    { editorValue : UndoRedoEditorValue EditorValue
    , cmd : Cmd msg
    , errors : Error.Model
    }


type alias EditorValue =
    { views : Dict String View
    , domain : Maybe Domain
    }


apply : Nav.Key -> Params Msg -> List Action -> Params Msg
apply key params actions =
    List.foldl (applyActions key) params actions


applyActions : Nav.Key -> Action -> Params Msg -> Params Msg
applyActions key action { editorValue, cmd, errors } =
    case action of
        UpdateViews newViews ->
            let
                currentEditorValue =
                    editorValue.present

                newValue =
                    { currentEditorValue | views = newViews }
            in
            { editorValue = newRecord newValue editorValue
            , cmd =
                Cmd.batch
                    [ cmd
                    , updateEditorValue (rdbEncode newValue)
                    ]
            , errors = errors
            }

        SaveEditorState ->
            { editorValue = newRecord editorValue.present editorValue
            , cmd = cmd
            , errors = errors
            }

        ResetCurrentEditorState newViews ->
            let
                update a =
                    { a | views = newViews }
            in
            { editorValue = mapPresent update editorValue
            , cmd = cmd
            , errors = errors
            }

        UpdateEditorValue ->
            { editorValue = editorValue
            , cmd =
                Cmd.batch
                    [ cmd
                    , updateEditorValue (rdbEncode editorValue.present)
                    ]
            , errors = errors
            }

        PushDomError errValue ->
            { editorValue = editorValue
            , cmd = cmd
            , errors = Error.GetElementPosition errValue :: errors
            }

        ChangeView view ->
            { editorValue = editorValue
            , cmd =
                Cmd.batch
                    [ cmd
                    , Nav.pushUrl key ("/#/editor/" ++ (view |> Maybe.withDefault ""))
                    ]
            , errors = errors
            }
