module ViewEditor.Editor exposing (Action(..), Model, changeSelectedView, getSelectedView, getSvgElementPosition, init, isInitState, subscriptions, update, view)

import Basics.Extra exposing (maxSafeInteger)
import Browser.Dom as Dom
import Browser.Events as Events
import ContainerMenu.ContextMenu as ContextMenu
import ContainerMenu.Menu
import ContainerMenu.MenuActions as MenuActions
import Dict exposing (Dict)
import Domain.Domain
    exposing
        ( View
        , ViewElement
        , ViewElementKey
        , ViewItemKey(..)
        , ViewRelationPoint
        , getCurrentView
        , getElement
        , getElementAndItsKeys
        , getPoint
        , getRelationPoints
        , getViewElementKeysByCondition
        , getViewElements
        , getViewElementsOfCurrentView
        , getViewPointKeysByCondition
        , getViewRelationPoints
        , removedEdge
        , updateElementsInViews
        , updatePointsInRelations
        , updateRelationsInElements
        , updateViewByKey
        )
import Html exposing (Html, a, div)
import Html.Attributes
import Html.Events.Extra.Mouse as Mouse
import JsInterop exposing (focusContainer, shareElementsAtCurrentView)
import Json.Decode as Decode
import Navigation.ViewNavigation as ViewNavigation
import SplitPanel.SplitPane exposing (Orientation(..))
import Task
import TypedSvg.Attributes exposing (r, x, x1, x2, y, y1, y2)
import TypedSvg.Types exposing (Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import ViewControl.AddView as AddView
import ViewControl.AddViewActions as AddViewActions
import ViewControl.ViewControl as ViewControl
import ViewControl.ViewControlActions as ViewControlActions
import ViewEditor.MovingViewElements exposing (getSelectedElementKeysAndDeltas, getSelectedPointKeysAndDeltas, updateElementAndPointPosition)
import ViewEditor.Msg exposing (Msg(..))
import ViewEditor.SvgView exposing (MonacoState, emptySvg, svgView)
import ViewEditor.Types exposing (Brush, SelectedItem, ViewEditorState)
import ViewEditor.DrawEdges exposing (edgeStrokeWidthExtend)


type Model
    = Init (Maybe String)
    | Ready ViewEditorState


isInitState : Model -> Bool
isInitState model =
    case model of
        Init _ ->
            True

        _ ->
            False


init : Maybe String -> Model
init selectedView =
    Init selectedView


type Action
    = UpdateViews (Dict String View)
    | SaveEditorState
    | ResetCurrentEditorState (Dict String View)
    | UpdateMonacoValue
    | PushDomError Dom.Error
    | ChangeView (Maybe String)


update : Dict String View -> Msg -> Model -> ( Model, Cmd Msg, List Action )
update views msg model =
    case ( model, msg ) of
        ( Init selectedView, ReceiveElementPosition (Ok { element }) ) ->
            let
                elementsKeysOfCurrentView =
                    getCurrentView selectedView views
                        |> getViewElements
            in
            ( Ready
                { drag = Nothing
                , svgElementPosition = element
                , viewNavigation = ViewNavigation.init element
                , addView = AddView.init
                , viewControl = ViewControl.init
                , selectedView = selectedView
                , brush = Nothing
                , selectedItems = []
                , containerMenu = ContainerMenu.Menu.init |> ContextMenu.init
                , currentMouseOverRelation = Nothing
                }
            , shareElementsAtCurrentView elementsKeysOfCurrentView |> Cmd.map ViewControl
            , []
            )

        ( Ready state, ReceiveElementPosition (Ok { element }) ) ->
            ( Ready { state | svgElementPosition = element }
            , Cmd.none
            , []
            )

        ( _, ReceiveElementPosition (Err errValue) ) ->
            ( model, Cmd.none, [ PushDomError errValue ] )

        ( Ready state, ContainerContextMenu subMsg ) ->
            let
                ( updatedModel, cmd, actions ) =
                    ContextMenu.update subMsg state.containerMenu

                updatedViews =
                    MenuActions.apply state.selectedView views actions
            in
            ( Ready { state | containerMenu = updatedModel }
            , cmd |> Cmd.map ContainerContextMenu
            , UpdateViews updatedViews |> List.singleton
            )

        ( Ready state, ViewControl subMsg ) ->
            let
                ( updated, cmd, actions ) =
                    ViewControl.update subMsg state.viewControl

                elementPosition =
                    ViewNavigation.getPositionForNewElement state.viewNavigation state.svgElementPosition

                params =
                    { position = elementPosition
                    , selectedView = state.selectedView
                    }

                ( newViews, selectedView ) =
                    ViewControlActions.apply params views actions

                elementsKeysOfCurrentView =
                    getCurrentView selectedView views
                        |> getViewElements

                ( updatedViewEditor, finalCmds, newActions ) =
                    ( Ready
                        { state
                            | viewControl = updated
                            , selectedView = selectedView
                        }
                    , if ViewControlActions.monacoValueModified actions || state.selectedView == selectedView then
                        cmd |> Cmd.map ViewControl

                      else
                        Cmd.batch [ cmd, shareElementsAtCurrentView elementsKeysOfCurrentView ] |> Cmd.map ViewControl
                    , if ViewControlActions.monacoValueModified actions then
                        [ UpdateViews newViews ]

                      else if state.selectedView == selectedView then
                        []

                      else
                        [ ChangeView selectedView ]
                    )
            in
            ( updatedViewEditor
            , finalCmds
            , newActions
            )

        ( Ready state, AddView subMsg ) ->
            let
                ( updated, cmd, actions ) =
                    AddView.update subMsg state.addView

                ( newViews, cmds, newViewId ) =
                    AddViewActions.apply views actions

                ( updatedViewEditor, finalCmds, newActions ) =
                    if AddViewActions.monacoValueModified actions then
                        ( Ready
                            { state
                                | addView = updated
                                , selectedView = Just newViewId
                            }
                        , Cmd.batch
                            [ cmd |> Cmd.map AddView
                            , cmds
                            ]
                        , [ UpdateViews newViews, ChangeView (Just newViewId) ]
                        )

                    else
                        ( Ready
                            { state
                                | addView = updated
                            }
                        , Cmd.batch
                            [ cmd |> Cmd.map AddView
                            , cmds
                            ]
                        , []
                        )
            in
            ( updatedViewEditor
            , finalCmds
            , newActions
            )

        ( Ready state, SelectItemsStart xy ) ->
            let
                shiftedXY =
                    ViewNavigation.shiftPosition state.viewNavigation ( state.svgElementPosition.x, state.svgElementPosition.y ) xy
            in
            ( Ready { state | brush = Just <| Brush shiftedXY shiftedXY }
            , Cmd.none
            , []
            )

        ( _, Resize ) ->
            ( model, getSvgElementPosition, [] )

        ( Ready state, DragViewElementStart viewElementKey xy ) ->
            let
                ( shiftedStartX, shiftedStartY ) =
                    ViewNavigation.shiftPosition state.viewNavigation ( state.svgElementPosition.x, state.svgElementPosition.y ) xy

                selectedElementKeys =
                    getSelectedElementKeysAndDeltas state.selectedItems
                        |> List.map Tuple.first

                isWithinAlreadySelected =
                    selectedElementKeys
                        |> List.member viewElementKey

                elementsOfCurrentView =
                    getCurrentView state.selectedView views
                        |> getViewElementsOfCurrentView

                updatedSelectedItems =
                    if List.isEmpty state.selectedItems || not isWithinAlreadySelected then
                        elementsOfCurrentView
                            |> getElement viewElementKey
                            |> Maybe.map (\ve -> ( shiftedStartX - ve.x, shiftedStartY - ve.y ))
                            |> SelectedItem (ElementKey viewElementKey)
                            |> List.singleton

                    else
                        updateSelectedItemsDeltas elementsOfCurrentView ( shiftedStartX, shiftedStartY ) state.selectedItems
            in
            ( Ready
                { state
                    | drag = Just { start = xy, current = xy }
                    , selectedItems = updatedSelectedItems
                }
            , Cmd.none
            , SaveEditorState |> List.singleton
            )

        ( Ready state, DragPointStart viewRelationPointKey xy ) ->
            let
                ( viewElementKey, relation, pointIndex ) =
                    viewRelationPointKey

                ( shiftedStartX, shiftedStartY ) =
                    ViewNavigation.shiftPosition state.viewNavigation ( state.svgElementPosition.x, state.svgElementPosition.y ) xy

                selectedPointKeys =
                    getSelectedPointKeysAndDeltas state.selectedItems
                        |> List.map Tuple.first

                isWithinAlreadySelected =
                    selectedPointKeys
                        |> List.member viewRelationPointKey

                elementsOfCurrentView =
                    getCurrentView state.selectedView views
                        |> getViewElementsOfCurrentView

                updatedSelectedItems =
                    if List.isEmpty state.selectedItems || not isWithinAlreadySelected then
                        elementsOfCurrentView
                            |> getElement viewElementKey
                            |> getRelationPoints relation
                            |> getPoint pointIndex
                            |> Maybe.map (\tp -> ( shiftedStartX - tp.x, shiftedStartY - tp.y ))
                            |> SelectedItem (PointKey viewRelationPointKey)
                            |> List.singleton

                    else
                        updateSelectedItemsDeltas elementsOfCurrentView ( shiftedStartX, shiftedStartY ) state.selectedItems
            in
            ( Ready
                { state
                    | drag = Just { start = xy, current = xy }
                    , selectedItems = updatedSelectedItems
                }
            , Cmd.none
            , SaveEditorState |> List.singleton
            )

        ( Ready state, RemovePoint ( viewElementKey, relation, pointIndex ) ) ->
            let
                removePointAtIndex list =
                    List.take pointIndex list ++ List.drop (pointIndex + 1) list

                updatedViews =
                    updatePointsInRelations relation removePointAtIndex
                        |> updateRelationsInElements viewElementKey
                        |> updateElementsInViews state.selectedView views
            in
            ( model
            , Cmd.none
            , [ UpdateViews updatedViews ]
            )

        ( Ready state, RemoveEdge viewRelationKey ) ->
            let
                currentView =
                    getCurrentView state.selectedView views

                updatedViews =
                    currentView
                        |> Maybe.map (removedEdge viewRelationKey)
                        |> updateViewByKey state.selectedView views
            in
            ( model
            , Cmd.none
            , [ UpdateViews updatedViews ]
            )

        ( Ready state, ClickEdgeStart ( viewElementKey, relation ) xy ) ->
            let
                spxy =
                    ViewNavigation.shiftPosition state.viewNavigation ( state.svgElementPosition.x, state.svgElementPosition.y ) xy

                currentView =
                    getCurrentView state.selectedView views

                sourceXY =
                    currentView
                        |> getViewElementsOfCurrentView
                        |> getElement viewElementKey
                        |> Maybe.map (\s -> ( s.x, s.y ))

                targetXY =
                    currentView
                        |> getViewElementsOfCurrentView
                        |> getElement (Tuple.first relation)
                        |> Maybe.map (\s -> ( s.x, s.y ))
            in
            case ( sourceXY, targetXY, currentView ) of
                ( Just sxy, Just txy, Just cv ) ->
                    let
                        allPoints =
                            sxy :: getViewRelationPoints ( viewElementKey, relation ) cv ++ [ txy ]

                        ( _, ( insertAfterValue, _ ) ) =
                            List.foldr
                                (\currentPoint ->
                                    \( previousPoint, ( insertAfterPoint, val ) ) ->
                                        let
                                            z =
                                                distanceToLine spxy ( currentPoint, previousPoint )

                                            ( extendedA, extendedPrev ) =
                                                extendPoints currentPoint previousPoint
                                        in
                                        if not (isNaN z) && betweenPoints spxy ( extendedA, extendedPrev ) && z < val then
                                            ( currentPoint, ( currentPoint, z ) )

                                        else
                                            ( currentPoint, ( insertAfterPoint, val ) )
                                )
                                ( txy, ( txy, maxSafeInteger ) )
                                allPoints

                        ( listWithNewPoint, _, _ ) =
                            List.foldr
                                (\a ->
                                    \( b, i, found ) ->
                                        if insertAfterValue == a then
                                            ( a :: spxy :: b, i, True )

                                        else
                                            ( a :: b
                                            , if found then
                                                i

                                              else
                                                i + 1
                                            , found
                                            )
                                )
                                ( [], 0, False )
                                allPoints

                        updatedList =
                            listWithNewPoint |> trimList 1

                        updatedPoints =
                            \_ -> updatedList |> List.map (\( x, y ) -> ViewRelationPoint x y)

                        updatedViewsValue =
                            updatedPoints
                                |> updatePointsInRelations relation
                                |> updateRelationsInElements viewElementKey
                                |> updateElementsInViews state.selectedView views
                    in
                    ( model
                    , Cmd.none
                    , [ UpdateViews updatedViewsValue ]
                    )

                _ ->
                    -- TODO
                    ( model, Cmd.none, [] )

        ( Ready state, EdgeEnter viewRelationKey ) ->
            ( Ready { state | currentMouseOverRelation = Just viewRelationKey }
            , Cmd.none
            , []
            )

        ( Ready state, EdgeLeave ) ->
            ( Ready { state | currentMouseOverRelation = Nothing }
            , Cmd.none
            , []
            )

        ( Ready state, MouseMove xy ) ->
            let
                selectedViewKey =
                    getCurrentView state.selectedView views

                updatedViewEditor =
                    selectedViewKey
                        |> handleMouseMove xy state

                updatedViews =
                    case ( state.brush, state.drag ) of
                        ( Nothing, Just _ ) ->
                            updateElementAndPointPosition state.selectedItems xy state
                                |> updateElementsInViews state.selectedView views

                        _ ->
                            views
            in
            ( updatedViewEditor
            , Cmd.none
            , ResetCurrentEditorState updatedViews |> List.singleton
            )

        ( Ready state, MouseMoveEnd ) ->
            case state.brush of
                Just _ ->
                    ( Ready { state | brush = Nothing }
                    , Cmd.none
                    , []
                    )

                Nothing ->
                    case state.drag of
                        Just _ ->
                            ( Ready { state | drag = Nothing, selectedItems = [] }
                            , Cmd.none
                            , UpdateMonacoValue |> List.singleton
                            )

                        _ ->
                            ( model, Cmd.none, [] )

        ( Ready state, ViewNavigation subMsg ) ->
            let
                ( updated, cmd ) =
                    ViewNavigation.update subMsg state.viewNavigation
            in
            ( Ready { state | viewNavigation = updated }
            , cmd |> Cmd.map ViewNavigation
            , []
            )

        ( Ready state, FocusContainer containerKey ) ->
            let
                navigationModel =
                    getCurrentView state.selectedView views
                        |> getViewElementsOfCurrentView
                        |> Maybe.andThen (Dict.get containerKey)
                        |> Maybe.map (\el -> ViewNavigation.centralize ( el.x, el.y ) state.svgElementPosition state.viewNavigation)
            in
            case navigationModel of
                Just m ->
                    ( Ready { state | viewNavigation = m }, Cmd.none, [] )

                Nothing ->
                    ( model, Cmd.none, [] )

        _ ->
            ( model, Cmd.none, [] )


getSvgElementPosition : Cmd Msg
getSvgElementPosition =
    Task.attempt ReceiveElementPosition (Dom.getElement "main-graph")


updateSelectedItemsDeltas : Maybe (Dict ViewElementKey ViewElement) -> ( Float, Float ) -> List SelectedItem -> List SelectedItem
updateSelectedItemsDeltas viewElementsOfCurrentView ( shiftedStartX, shiftedStartY ) selectedItems =
    let
        selectedPointKeys =
            getSelectedPointKeysAndDeltas selectedItems
                |> List.map Tuple.first

        selectedElementKeys =
            getSelectedElementKeysAndDeltas selectedItems
                |> List.map Tuple.first

        elementIsWithinAlreadySelected vek _ =
            List.member vek selectedElementKeys

        pointIsWithinAlreadySelected vpk =
            List.member vpk selectedPointKeys

        selectedElementsWithDeltas =
            viewElementsOfCurrentView
                |> Maybe.map (Dict.filter elementIsWithinAlreadySelected)
                |> Maybe.map Dict.toList
                |> Maybe.withDefault []
                |> List.map (\( vek, ve ) -> SelectedItem (ElementKey vek) (Just ( shiftedStartX - ve.x, shiftedStartY - ve.y )))

        selectedPointsWithDeltas =
            viewElementsOfCurrentView
                |> Maybe.map Dict.toList
                |> Maybe.withDefault []
                |> List.concatMap (\( vek, ve ) -> ve.relations |> Dict.toList |> List.map (Tuple.pair vek))
                |> List.concatMap (\( vek, ( r, points ) ) -> points |> List.indexedMap (\i point -> ( ( vek, r, i ), point )))
                |> List.filter (\( vpk, _ ) -> pointIsWithinAlreadySelected vpk)
                |> List.map (\( vpk, point ) -> SelectedItem (PointKey vpk) (Just ( shiftedStartX - point.x, shiftedStartY - point.y )))
    in
    selectedElementsWithDeltas ++ selectedPointsWithDeltas


{-| calculate distance to the line created by two points
it is not work good as it is required to calculcate distance to line segment
not line
TODO
-}
distanceToLine : ( Float, Float ) -> ( ( Float, Float ), ( Float, Float ) ) -> Float
distanceToLine ( x, y ) ( ( x1, y1 ), ( x2, y2 ) ) =
    -- distance to the line
    abs ((x2 - x1) * (y1 - y) - (x1 - x) * (y2 - y1)) / sqrt ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))


{-| is it enough to put the point ?
-}
betweenPoints : ( Float, Float ) -> ( ( Float, Float ), ( Float, Float ) ) -> Bool
betweenPoints ( x, y ) ( ( x1, y1 ), ( x2, y2 ) ) =
    let
        isBetween v v1 v2 =
            if v1 < v2 then
                v1 < v && v < v2

            else if v1 == v2 then
                v1 == v && v == v2

            else
                v2 < v && v < v1
    in
    isBetween x x1 x2 && isBetween y y1 y2


handleMouseMove : ( Float, Float ) -> ViewEditorState -> Maybe View -> Model
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
            Ready { state | brush = Just updatedBrush, selectedItems = elementKeysWithinBrush ++ pointKeysWithinBrush }

        Nothing ->
            case drag of
                Just { start } ->
                    Ready { state | drag = Just { start = start, current = xy } }

                _ ->
                    Ready state


elementWithinBrush : Brush -> ViewElementKey -> ViewElement -> Bool
elementWithinBrush { start, end } _ { x, y } =
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


view : MonacoState -> Model -> Html Msg
view domain model =
    let
        graphics =
            case model of
                Init _ ->
                    [ emptySvg [] ]

                Ready state ->
                    svgView domain state
    in
    div
        [ Html.Attributes.style "width" "100%"
        , Html.Attributes.style "height" "100%"
        , Html.Attributes.style "position" "relative"
        ]
        graphics


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        dragSubscriptions : Sub Msg
        dragSubscriptions =
            Sub.batch
                [ Events.onMouseMove (Decode.map (.clientPos >> MouseMove) Mouse.eventDecoder)
                , Events.onMouseUp (Decode.map (\_ -> MouseMoveEnd) Mouse.eventDecoder)
                ]

        readySubscriptions : ViewEditorState -> Sub Msg
        readySubscriptions { viewNavigation, brush, drag } =
            Sub.batch
                [ ViewNavigation.subscriptions viewNavigation |> Sub.map ViewNavigation
                , case ( brush, drag ) of
                    ( Nothing, Nothing ) ->
                        Sub.none

                    _ ->
                        dragSubscriptions
                ]
    in
    Sub.batch
        [ case model of
            Init _ ->
                Sub.none

            Ready state ->
                Sub.batch
                    [ readySubscriptions state
                    , ContextMenu.subscriptions state.containerMenu |> Sub.map ContainerContextMenu
                    , AddView.subscriptions |> Sub.map AddView
                    , focusContainer FocusContainer
                    ]
        , Events.onResize (\_ _ -> Resize)
        ]


trimList : Int -> List a -> List a
trimList count =
    List.drop count
        >> List.reverse
        >> List.drop count
        >> List.reverse


getSelectedView : Model -> Maybe String
getSelectedView model =
    case model of
        Init v ->
            v

        Ready { selectedView } ->
            selectedView


changeSelectedView : Maybe String -> Model -> Model
changeSelectedView selectedView model =
    case model of
        Init _ ->
            Init selectedView

        Ready m ->
            Ready { m | selectedView = selectedView }

extendPoints : ( number, number ) -> ( number, number ) -> ( ( number, number ), ( number, number ) )
extendPoints ( x1, y1 ) ( x2, y2 ) =
    let
        extend v1 v2 =
            if v1 < v2 || v1 == v2 then
                ( v1 - edgeStrokeWidthExtend, v2 + edgeStrokeWidthExtend )

            else
                ( v2 - edgeStrokeWidthExtend, v1 + edgeStrokeWidthExtend )

        ( ux1, ux2 ) =
            extend x1 x2

        ( uy1, uy2 ) =
            extend y1 y2
    in
    ( ( ux1, uy1 ), ( ux2, uy2 ) )
