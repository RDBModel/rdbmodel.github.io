module ViewEditor.EditorAction exposing (apply)

import Browser.Navigation as Nav
import Dict exposing (Dict)
import Domain.Domain exposing (Domain, View)
import Domain.DomainEncoder exposing (rdbEncode)
import Error.Error as Error
import JsInterop exposing (updateMonacoValue)
import UndoRedo.ViewUndoRedo exposing (UndoRedoMonacoValue, mapPresent, newRecord)
import ViewEditor.Editor exposing (Action(..))
import ViewEditor.Msg exposing (Msg)


type alias Params msg =
    { monacoValue : UndoRedoMonacoValue MonacoValue
    , cmd : Cmd msg
    , errors : Error.Model
    }


type alias MonacoValue =
    { views : Dict String View
    , domain : Maybe Domain
    }


apply : Nav.Key -> Params Msg -> List Action -> Params Msg
apply key params actions =
    List.foldl (applyActions key) params actions


applyActions : Nav.Key -> Action -> Params Msg -> Params Msg
applyActions key action { monacoValue, cmd, errors } =
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

        ChangeView view ->
            { monacoValue = monacoValue
            , cmd =
                Cmd.batch
                    [ cmd
                    , Nav.pushUrl key ("/#/editor/" ++ (view |> Maybe.withDefault ""))
                    ]
            , errors = errors
            }
