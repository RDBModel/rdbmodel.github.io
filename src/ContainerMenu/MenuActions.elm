module ContainerMenu.MenuActions exposing (..)

import Dict exposing (Dict)
import Domain.Domain exposing (View, ViewRelationKey, addRelationToView, deleteContainer, getCurrentView, updateViewByKey)


type Action
    = SelectRelation ViewRelationKey
    | DeleteElement String


apply : Maybe String -> Dict String View -> List Action -> Dict String View
apply selectedView views actions =
    actions
        |> List.foldl modifyViews (getCurrentView selectedView views)
        |> updateViewByKey selectedView views


modifyViews : Action -> Maybe View -> Maybe View
modifyViews action view =
    case action of
        SelectRelation ( containerId, relation ) ->
            view
                |> addRelationToView containerId relation

        DeleteElement containerId ->
            view
                |> deleteContainer containerId
