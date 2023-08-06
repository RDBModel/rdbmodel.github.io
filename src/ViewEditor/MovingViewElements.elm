module ViewEditor.MovingViewElements exposing (getSelectedElementKeysAndDeltas, getSelectedPointKeysAndDeltas, updateElementAndPointPosition)

import Dict exposing (Dict)
import Domain.Domain exposing (ViewElement, ViewElementKey, ViewItemKey(..), ViewRelationPoint, ViewRelationPointIndex, ViewRelationPointKey)
import Navigation.ViewNavigation as ViewNavigation
import ViewEditor.Types exposing (SelectedItem, ViewEditorState)


updateElementAndPointPosition : List SelectedItem -> ( Float, Float ) -> ViewEditorState -> (Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement)
updateElementAndPointPosition selectedItems xy state =
    let
        ( roundX, roundY ) = (roundXFunc state, roundYFunc state)
        selectedElementDeltas =
            getSelectedElementKeysAndDeltas selectedItems
                |> List.filterMap (\( k, d ) -> d |> Maybe.map (Tuple.pair k))

        selectedPointsDeltas =
            getSelectedPointKeysAndDeltas selectedItems
                |> List.filterMap (\( k, d ) -> d |> Maybe.map (Tuple.pair k))

        ( shiftedX, shiftedY ) =
            ViewNavigation.shiftPosition state.viewNavigation ( state.svgElementPosition.x, state.svgElementPosition.y ) xy

        updateElementXY : ViewElementKey -> ViewElement -> ViewElement
        updateElementXY viewElementKey viewElement =
            let
                foundElement =
                    selectedElementDeltas |> List.filter (\x -> Tuple.first x == viewElementKey) |> List.head
            in
            case foundElement of
                Just ( _, ( deltaX, deltaY ) ) ->
                    { viewElement | x = (shiftedX - deltaX) |> roundX, y = (shiftedY - deltaY) |> roundY }

                Nothing ->
                    viewElement

        updatePointXY : List ( ViewRelationPointIndex, ( Float, Float ) ) -> Int -> ViewRelationPoint -> ViewRelationPoint
        updatePointXY selectedPointIndexes i viewRelationPoint =
            selectedPointIndexes
                |> List.filterMap
                    (\( pointIndex, d ) ->
                        if pointIndex == i then
                            Just d

                        else
                            Nothing
                    )
                |> List.head
                |> Maybe.map
                    (\( deltaX, deltaY ) ->
                        { viewRelationPoint | x = (shiftedX - deltaX) |> roundX, y = (shiftedY - deltaY) |> roundY }
                    )
                |> Maybe.withDefault viewRelationPoint

        updatedPoints viewElementKey =
            Dict.map
                (\relation points ->
                    let
                        updatePointXYUsingSelectedPoints =
                            selectedPointsDeltas
                                |> List.filterMap
                                    (\( ( vek, rel, pointIndex ), delta ) ->
                                        if vek == viewElementKey && rel == relation then
                                            Just ( pointIndex, delta )

                                        else
                                            Nothing
                                    )
                                |> updatePointXY
                    in
                    List.indexedMap updatePointXYUsingSelectedPoints points
                )

        updatedRelations : ViewElementKey -> ViewElement -> ViewElement
        updatedRelations viewElementKey viewElement =
            { viewElement | relations = updatedPoints viewElementKey viewElement.relations }
    in
    Dict.map
        (\viewElementKey ve ->
            updateElementXY viewElementKey ve
                |> updatedRelations viewElementKey
        )


getSelectedElementKeysAndDeltas : List SelectedItem -> List ( ViewElementKey, Maybe ( Float, Float ) )
getSelectedElementKeysAndDeltas =
    let
        extractViewElelementKeys v =
            case v.key of
                ElementKey x ->
                    Just ( x, v.delta )

                PointKey _ ->
                    Nothing
    in
    List.filterMap extractViewElelementKeys


getSelectedPointKeysAndDeltas : List SelectedItem -> List ( ViewRelationPointKey, Maybe ( Float, Float ) )
getSelectedPointKeysAndDeltas =
    let
        extractPointKeys v =
            case v.key of
                PointKey x ->
                    Just ( x, v.delta )

                ElementKey _ ->
                    Nothing
    in
    List.filterMap extractPointKeys


toNearest10 x =
    let
        remainder =
            remainderBy 10 x |> abs

        multiplier =
            x // 10
    in
    if remainder > 5 then
        multiplier * 10 + 10

    else
        multiplier * 10

toNearest5 x =
    let
        remainder =
            remainderBy 10 (x + 5) |> abs

        multiplier =
            (x + 5) // 10
    in
    if remainder > 5 then
        multiplier * 10 + 5

    else
        multiplier * 10 - 5

roundXFunc state =
    if state.viewNavigation.stickyPositioning then
        round >> toNearest10 >> toFloat

    else
        round >> toFloat

roundYFunc state =
    if state.viewNavigation.stickyPositioning then
        round >> toNearest5 >> toFloat

    else
        round >> toFloat
