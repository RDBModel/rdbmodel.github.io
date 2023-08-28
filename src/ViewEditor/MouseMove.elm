module ViewEditor.MouseMove exposing (handleMouseMove)

import Dict
import Domain.Domain exposing (View, ViewElement, ViewElementKey, ViewItemKey(..), ViewRelationPoint, getElementAndItsKeys, getViewElementKeysByCondition, getViewElementsOfCurrentView, getViewPointKeysByCondition)
import Navigation.ViewNavigation as ViewNavigation
import ViewEditor.Types exposing (Brush, SelectedItem, ViewEditorState)


handleMouseMove : ( Float, Float ) -> ViewEditorState -> Maybe View -> ViewEditorState
handleMouseMove xy ({ drag, brush } as state) currentView =
    case brush of
        Just b ->
            let
                shiftedXY =
                    ViewNavigation.shiftPosition state.viewNavigation ( state.svgElementPosition.x, state.svgElementPosition.y ) xy

                updatedBrush =
                    { b | end = shiftedXY }

                elementKeysWithinBrush =
                    currentView
                        |> getViewElementsOfCurrentView
                        |> getViewElementKeysByCondition (elementWithinBrush updatedBrush)
                        |> List.map (\i -> SelectedItem (ElementKey i) Nothing)

                pointKeysWithinBrush =
                    currentView
                        |> getViewElementsOfCurrentView
                        |> getElementAndItsKeys
                        |> List.concatMap (\( k, v ) -> v.relations |> Dict.toList |> List.map (\( relation, points ) -> ( k, relation, points )))
                        |> List.concatMap (\( k, relation, points ) -> points |> getViewPointKeysByCondition (pointWithinBrush updatedBrush) |> List.map (\pointIndex -> ( k, relation, pointIndex )))
                        |> List.map (\i -> SelectedItem (PointKey i) Nothing)
            in
            { state | brush = Just updatedBrush, selectedItems = elementKeysWithinBrush ++ pointKeysWithinBrush }

        Nothing ->
            case drag of
                Just { start } ->
                    { state | drag = Just { start = start, current = xy } }

                _ ->
                    state


elementWithinBrush : Brush -> ViewElementKey -> ViewElement -> Bool
elementWithinBrush { start, end } _ { x, y, w, h } =
    let
        ( startX1, startY1 ) =
            start

        ( endX2, endY2 ) =
            end
    in
    (x - w / 2)
        > min startX1 endX2
        && (x + w / 2)
        < max startX1 endX2
        && (y - h / 2)
        > min startY1 endY2
        && (y + h / 2)
        < max startY1 endY2


pointWithinBrush : Brush -> ViewRelationPoint -> Bool
pointWithinBrush { start, end } { x, y } =
    let
        ( startX1, startY1 ) =
            start

        ( endX2, endY2 ) =
            end
    in
    x
        > min startX1 endX2
        && x
        < max startX1 endX2
        && y
        > min startY1 endY2
        && y
        < max startY1 endY2
