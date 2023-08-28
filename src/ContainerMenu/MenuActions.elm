module ContainerMenu.MenuActions exposing (..)

import Dict exposing (Dict)
import Domain.Domain exposing (Domain, View, ViewRelationKey, addRelationToView, deleteContainer, getCurrentView, updateElementPositions, updateViewByKey)


type Action
    = SelectRelation ViewRelationKey
    | DeleteElement String


apply : Maybe Domain -> Maybe String -> Dict String View -> List Action -> Dict String View
apply domain selectedView views actions =
    actions
        |> List.foldl (modifyViews domain) (getCurrentView selectedView views)
        |> updateViewByKey selectedView views


modifyViews : Maybe Domain -> Action -> Maybe View -> Maybe View
modifyViews domain action view =
    case action of
        SelectRelation ( containerId, relation ) ->
            view
                |> addRelationToView containerId relation

        DeleteElement containerId ->
            view
                |> deleteContainer containerId
                |> updateElementPositions domain
