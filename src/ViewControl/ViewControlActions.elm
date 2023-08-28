module ViewControl.ViewControlActions exposing (apply, monacoValueModified)

import Dict exposing (Dict)
import Domain.Domain exposing (Domain, View, addElementToView, getCurrentView, updateViewByKey)
import ViewControl.ViewControl exposing (Action(..))
import ViewEditor.DrawContainer exposing (containerHeight, containerWidth)


type alias Params =
    { defaultPositions : ( Float, Float )
    , selectedView : Maybe String
    }


apply : Maybe Domain -> Params -> Dict String View -> List Action -> ( Dict String View, Maybe String )
apply domain params views actions =
    List.foldl (modifyViews domain params) ( views, params.selectedView ) actions


modifyViews : Maybe Domain -> Params -> Action -> ( Dict String View, Maybe String ) -> ( Dict String View, Maybe String )
modifyViews domain params action ( views, currentView ) =
    case action of
        AddElementToView el ->
            ( getCurrentView params.selectedView views
                |> Maybe.map (\v -> addElementToView domain (Tuple.first el) params.defaultPositions ( containerWidth, containerHeight ) v)
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
