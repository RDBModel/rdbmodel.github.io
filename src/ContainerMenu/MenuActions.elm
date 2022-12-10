module ContainerMenu.MenuActions exposing (..)

import Domain.Domain exposing (ViewRelationKey)
import Dict exposing (Dict)
import Domain.Domain exposing (View, getCurrentView, addRelationToView, updateViewByKey, deleteContainer)

type Action
    = SelectRelation ViewRelationKey
    | DeleteElement String

apply : String -> Dict String View -> List Action -> Dict String View
apply selectedView views actions =
    List.foldl (modifyViews selectedView) views actions

modifyViews : String -> Action -> Dict String View -> Dict String View
modifyViews selectedView action views =
    case action of
        SelectRelation ( containerId, relation ) ->
            getCurrentView selectedView views
                |> addRelationToView containerId relation
                |> updateViewByKey selectedView views

        DeleteElement containerId ->
            getCurrentView selectedView views
                |> deleteContainer containerId
                |> updateViewByKey selectedView views
