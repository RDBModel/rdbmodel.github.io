module Pages.EditorUIAction exposing (apply)

import Dict exposing (Dict)
import Domain exposing (View, Domain)
import Pages.EditorUI exposing (Action(..), Msg)
import ViewUndoRedo exposing (newRecord)
import ViewUndoRedo exposing (UndoRedoMonacoValue)
import JsInterop exposing (updateMonacoValue)
import DomainEncoder exposing (rdbEncode)
import ViewUndoRedo exposing (mapPresent)

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
                currentMonacoValue = monacoValue.present
                newValue = { currentMonacoValue | views = newViews }
            in
            ( newRecord newValue monacoValue
            , Cmd.batch
                [ cmd
                , updateMonacoValue ( rdbEncode newValue )
                ]
            )

        SaveEditorState ->
            ( newRecord monacoValue.present monacoValue
            , cmd
            )

        ResetCurrentEditorState newViews ->
            let
                update a = { a | views = newViews }
            in
            ( mapPresent update monacoValue
            , cmd
            )

        UpdateMonacoValue ->
            ( monacoValue
            , Cmd.batch
                [ cmd
                , updateMonacoValue ( rdbEncode monacoValue.present )
                ]
            )
