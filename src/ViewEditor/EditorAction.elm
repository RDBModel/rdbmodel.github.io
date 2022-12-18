module ViewEditor.EditorAction exposing (apply)

import Dict exposing (Dict)
import Domain.Domain exposing (Domain, View)
import Domain.DomainEncoder exposing (rdbEncode)
import Error.Error as Error
import JsInterop exposing (updateMonacoValue)
import UndoRedo.ViewUndoRedo exposing (UndoRedoMonacoValue, mapPresent, newRecord)
import ViewEditor.Editor exposing (Action(..), Msg)


type alias Params msg =
    { monacoValue : UndoRedoMonacoValue MonacoValue
    , cmd : Cmd msg
    , errors : Error.Model
    }


type alias MonacoValue =
    { views : Dict String View
    , domain : Maybe Domain
    }


apply : Params Msg -> List Action -> Params Msg
apply params actions =
    List.foldl applyActions params actions


applyActions : Action -> Params Msg -> Params Msg
applyActions action { monacoValue, cmd, errors } =
    case action of
        UpdateViews newViews ->
            let
                currentMonacoValue =
                    monacoValue.present

                newValue =
                    { currentMonacoValue | views = newViews }
            in
            { monacoValue = newRecord newValue monacoValue
            , cmd =
                Cmd.batch
                    [ cmd
                    , updateMonacoValue (rdbEncode newValue)
                    ]
            , errors = errors
            }

        SaveEditorState ->
            { monacoValue = newRecord monacoValue.present monacoValue
            , cmd = cmd
            , errors = errors
            }

        ResetCurrentEditorState newViews ->
            let
                update a =
                    { a | views = newViews }
            in
            { monacoValue = mapPresent update monacoValue
            , cmd = cmd
            , errors = errors
            }

        UpdateMonacoValue ->
            { monacoValue = monacoValue
            , cmd =
                Cmd.batch
                    [ cmd
                    , updateMonacoValue (rdbEncode monacoValue.present)
                    ]
            , errors = errors
            }

        PushDomError errValue ->
            { monacoValue = monacoValue
            , cmd = cmd
            , errors = Error.GetElementPosition errValue :: errors
            }
