module ViewControl.ViewControlActions exposing (apply, monacoValueModified)

import Browser.Navigation as Nav
import Dict exposing (Dict)
import Domain.Domain exposing (View, addElementToView, getCurrentView, updateViewByKey)
import ViewControl.ViewControl exposing (Action(..))


type alias Params =
    { position : ( Float, Float )
    , selectedView : String
    , key : Nav.Key
    }


apply : Params -> Dict String View -> List Action -> ( Dict String View, String, Cmd msg )
apply params views actions =
    List.foldl (modifyViews params) ( views, params.selectedView, Cmd.none ) actions


modifyViews : Params -> Action -> ( Dict String View, String, Cmd msg ) -> ( Dict String View, String, Cmd msg )
modifyViews params action ( views, currentView, cmd ) =
    case action of
        AddElementToView el ->
            ( getCurrentView params.selectedView views
                |> Maybe.map (\v -> addElementToView (Tuple.first el) params.position v)
                |> updateViewByKey params.selectedView views
            , currentView
            , cmd
            )

        ChangeView view ->
            case view of
                Just v ->
                    ( views
                    , v
                    , Cmd.batch [ cmd, Nav.pushUrl params.key ("/#/editor/" ++ v) ]
                    )
                Nothing ->
                    ( views
                    , ""
                    , Cmd.batch [ cmd, Nav.pushUrl params.key ("/#/editor/") ]
                    )


monacoValueModified : List Action -> Bool
monacoValueModified =
    List.foldl (\a v -> actionModifyView a |> (||) v) False


actionModifyView : Action -> Bool
actionModifyView action =
    case action of
        AddElementToView _ ->
            True

        ChangeView _ ->
            False
