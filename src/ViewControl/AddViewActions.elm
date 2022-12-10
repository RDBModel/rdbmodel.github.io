module ViewControl.AddViewActions exposing (..)

import ViewControl.AddView exposing (Action(..))
import Dict exposing (Dict)
import Domain.Domain exposing (View)
import Browser.Navigation as Nav

type alias Params =
    { position : (Float, Float)
    , selectedView : String
    , key : Nav.Key
    }

apply : Dict String View -> List Action -> ( Dict String View, Cmd msg )
apply views actions =
    List.foldl modifyViews ( views, Cmd.none ) actions

modifyViews : Action -> ( Dict String View, Cmd msg ) -> ( Dict String View, Cmd msg )
modifyViews action ( views, cmd ) =
    case action of
        NewView viewName ->
            ( Dict.insert viewName { elements = Dict.empty } views
            , cmd
            )

monacoValueModified : List Action -> Bool
monacoValueModified =
    List.foldl (\a v -> actionModifyView a |> (||) v ) False

actionModifyView : Action -> Bool
actionModifyView action =
    case action of
        NewView _ -> True
