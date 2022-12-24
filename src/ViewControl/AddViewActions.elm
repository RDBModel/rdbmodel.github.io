module ViewControl.AddViewActions exposing (..)

import Browser.Navigation as Nav
import Dict exposing (Dict)
import Domain.Domain exposing (View)
import ViewControl.AddView exposing (Action(..))


type alias Params =
    { position : ( Float, Float )
    , selectedView : Maybe String
    , key : Nav.Key
    }


apply : Dict String View -> Maybe String -> List Action -> ( Dict String View, Cmd msg, Maybe String )
apply views currentSelectedView actions =
    List.foldl modifyViews ( views, Cmd.none, currentSelectedView ) actions


modifyViews : Action -> ( Dict String View, Cmd msg, Maybe String ) -> ( Dict String View, Cmd msg, Maybe String )
modifyViews action ( views, cmd, selectedView ) =
    case action of
        NewView viewName ->
            ( Dict.insert viewName { elements = Dict.empty } views
            , cmd
            , if selectedView |> Maybe.map (\v -> Dict.member v views) |> Maybe.withDefault False then
                selectedView

              else
                Just viewName
            )


monacoValueModified : List Action -> Bool
monacoValueModified =
    List.foldl (\a v -> actionModifyView a |> (||) v) False


actionModifyView : Action -> Bool
actionModifyView action =
    case action of
        NewView _ ->
            True
