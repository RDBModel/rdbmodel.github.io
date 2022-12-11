module ViewEditor.EditorAction exposing (apply)

import Dict exposing (Dict)
import Domain.Domain exposing (Domain, View)
import Domain.DomainEncoder exposing (rdbEncode)
import JsInterop exposing (updateMonacoValue)
import ViewEditor.Editor exposing (Action(..), Msg)
import UndoRedo.ViewUndoRedo exposing (UndoRedoMonacoValue, mapPresent, newRecord)


type alias Params msg =
    { monacoValue : UndoRedoMonacoValue MonacoValue
    , cmd : Cmd msg
    }


type alias MonacoValue =
    { views : Dict String View
    , domain : Maybe Domain
    }


apply : Params Msg -> List Action -> ( UndoRedoMonacoValue MonacoValue, Cmd Msg )
apply params actions =
    List.foldl applyActions ( params.monacoValue, params.cmd ) actions


applyActions : Action -> ( UndoRedoMonacoValue MonacoValue, Cmd Msg ) -> ( UndoRedoMonacoValue MonacoValue, Cmd Msg )
applyActions action ( monacoValue, cmd ) =
    case action of
        UpdateViews newViews ->
            let
                currentMonacoValue =
                    monacoValue.present

                newValue =
                    { currentMonacoValue | views = newViews }
            in
            ( newRecord newValue monacoValue
            , Cmd.batch
                [ cmd
                , updateMonacoValue (rdbEncode newValue)
                ]
            )

        SaveEditorState ->
            ( newRecord monacoValue.present monacoValue
            , cmd
            )

        ResetCurrentEditorState newViews ->
            let
                update a =
                    { a | views = newViews }
            in
            ( mapPresent update monacoValue
            , cmd
            )

        UpdateMonacoValue ->
            ( monacoValue
            , Cmd.batch
                [ cmd
                , updateMonacoValue (rdbEncode monacoValue.present)
                ]
            )
