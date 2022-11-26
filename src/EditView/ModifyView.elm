module EditView.ModifyView exposing (updateViews)

import EditView.ViewControl exposing (Action(..))
import Dict exposing (Dict)
import Domain exposing (View, addElementToView, getCurrentView, updateViewByKey)

updateViews : (Float, Float) -> String -> Dict String View -> List Action -> Dict String View
updateViews positionForNewElement selectedView views actions =
    List.foldl (modifyViews positionForNewElement selectedView) views actions

modifyViews : (Float, Float) -> String -> Action -> Dict String View -> Dict String View
modifyViews position selectedView action views =
    case action of
        AddElementToView el ->
            getCurrentView selectedView views
            |> Maybe.map (\v -> addElementToView (Tuple.first el) position v)
            |> updateViewByKey selectedView views
        NewView viewName ->
            views
