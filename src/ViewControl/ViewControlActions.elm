module ViewControl.ViewControlActions exposing (update, monacoValueModified)

import ViewControl.ViewControl exposing (Action(..))
import Dict exposing (Dict)
import Domain exposing (View, addElementToView, getCurrentView, updateViewByKey)
import Browser.Navigation as Nav

type alias Params =
    { position : (Float, Float)
    , selectedView : String
    , key : Nav.Key
    }

update : Params -> Dict String View -> List Action -> ( Dict String View, Cmd msg )
update params views actions =
    List.foldl (modifyViews params) ( views, Cmd.none ) actions

modifyViews : Params -> Action -> ( Dict String View, Cmd msg ) -> ( Dict String View, Cmd msg )
modifyViews params action ( views, cmd ) =
    case action of
        AddElementToView el ->
            ( getCurrentView params.selectedView views
                |> Maybe.map (\v -> addElementToView (Tuple.first el) params.position v)
                |> updateViewByKey params.selectedView views
            , cmd
            )
        NewView viewName ->
            ( Dict.insert viewName { elements = Dict.empty } views
            , cmd
            )
        ChangeView view ->
            ( views
            , Cmd.batch [ cmd, Nav.pushUrl params.key ("/#/editor/" ++ view) ]
            )

monacoValueModified : List Action -> Bool
monacoValueModified =
    List.foldl (\a v -> actionModifyView a |> (||) v ) False

actionModifyView : Action -> Bool
actionModifyView action =
    case action of
        AddElementToView _ -> True
        NewView _ -> True
        ChangeView _ -> False
