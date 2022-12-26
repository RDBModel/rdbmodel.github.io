module ViewControl.AddViewActions exposing (..)

import Dict exposing (Dict)
import Domain.Domain exposing (View)
import ViewControl.AddView exposing (Action(..))


apply : Dict String View -> List Action -> ( Dict String View, Cmd msg, String )
apply views actions =
    List.foldl modifyViews ( views, Cmd.none, "" ) actions


modifyViews : Action -> ( Dict String View, Cmd msg, String ) -> ( Dict String View, Cmd msg, String )
modifyViews action ( views, cmd, _ ) =
    case action of
        NewView viewName ->
            ( Dict.insert viewName { elements = Dict.empty } views
            , cmd
            , viewName
            )


monacoValueModified : List Action -> Bool
monacoValueModified =
    List.foldl (\a v -> actionModifyView a |> (||) v) False


actionModifyView : Action -> Bool
actionModifyView action =
    case action of
        NewView _ ->
            True
