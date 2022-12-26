module ViewControl.ViewControlActions exposing (apply, monacoValueModified)

import Dict exposing (Dict)
import Domain.Domain exposing (View, addElementToView, getCurrentView, updateViewByKey)
import ViewControl.ViewControl exposing (Action(..))


type alias Params =
    { position : ( Float, Float )
    , selectedView : Maybe String
    }


apply : Params -> Dict String View -> List Action -> ( Dict String View, Maybe String )
apply params views actions =
    List.foldl (modifyViews params) ( views, params.selectedView ) actions


modifyViews : Params -> Action -> ( Dict String View, Maybe String ) -> ( Dict String View, Maybe String )
modifyViews params action ( views, currentView ) =
    case action of
        AddElementToView el ->
            ( getCurrentView params.selectedView views
                |> Maybe.map (\v -> addElementToView (Tuple.first el) params.position v)
                |> updateViewByKey params.selectedView views
            , currentView
            )

        ChangeView view ->
            case view of
                Just v ->
                    ( views
                    , Just v
                    )

                Nothing ->
                    ( views
                    , Nothing
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
