module Pages.Editor exposing (Model, Msg, update, init, view, subscriptions)

import Dict exposing (Dict)
import SplitPane exposing (Orientation(..), ViewConfig, createViewConfig)
import Domain exposing (Domain, View, ViewElement, ViewItemKey(..), ViewElementKey, ViewRelationKey, ViewRelationPointKey
    , ViewRelationPoint, ViewRelationPointIndex, Edge, Container, getViewElementKeysByCondition, getElementAndItsKeys
    , getCurrentView, possibleRelationsToAdd, addRelationToView, updateViewByKey, deleteContainer
    , getViewElementsOfCurrentView, getElement, getRelationPoints, getPoint, updatePointsInRelations
    , updateRelationsInElements, updateElementsInViews, removedEdge, getViewRelationPoints
    , getEdges, getContainers, getViewRelationKeyFromViewRelationPointKey, getViewRelationKeyFromEdge
    , getElementsToAdd, getViewPointKeysByCondition)
import ViewUndoRedo exposing (UndoRedoMonacoValue, getUndoRedoMonacoValue, newRecord, mapPresent)
import EditView.ViewControl as ViewControl
import Navigation.ViewNavigation as ViewNavigation
import ContextMenu
import Browser.Dom as Dom
import FilePicker
import JsInterop exposing (initMonacoResponse, validationErrors, updateMonacoValue, saveValueToFile
    , monacoEditorInitialValue, monacoEditorSavedValue, initMonacoRequest, requestValueToSave)
import Yaml.Decode as D
import DomainDecoder exposing (rdbDecoder)
import Task
import ContainerMenu
import DomainEncoder exposing (rdbEncode)
import EditView.ModifyView as ModifyView
import Elements exposing (extendPoints, innerGrid, grid, markerDot, gridRect, renderContainerSelected
    , renderContainer, selectItemsRect, edgeBetweenContainers)
import Basics.Extra exposing (maxSafeInteger)
import Utils exposing (trimList)
import Session exposing (Session)
import Browser exposing (Document)
import Html exposing (text)
import Html exposing (Html, div, text, a)
import Html.Attributes exposing (href, style)
import TypedSvg.Attributes as Attrs exposing ( class, x, y, id, d, r, x1, x2, y1, y2)
import TypedSvg.Core exposing (Svg, Attribute)
import Html.Events.Extra.Mouse as Mouse exposing (Event)
import TypedSvg exposing (svg, defs, g)
import TypedSvg.Types exposing ( Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import Browser.Events as Events
import Json.Decode as Decode

type alias Model =
    { session : Session
    , pane : SplitPane.State
    , viewEditor : ViewEditor
    , monacoValue : UndoRedoMonacoValue MonacoValue
    , viewControl : ViewControl.Model
    , showOpenFileButton : Bool
    , toReload : Bool
    , errors : String
    }

type ViewEditor
    = Init
    | Ready ViewEditorState

type alias MonacoValue =
    { views : Dict String View
    , domain : Maybe Domain
    }

type alias ViewEditorState =
    { drag : Maybe Drag
    -- , zoom : Zoom
    , viewNavigation : ViewNavigation.Model
    , viewUndoRedo : ViewUndoRedo.Model
    , svgElementPosition : Element
    , brush : Maybe Brush
    , selectedItems : List SelectedItem
    , containerMenu : ContextMenu.Model
    }

type alias Brush =
    { end : ( Float, Float ) -- current mouse position
    , start : ( Float, Float ) -- start mouse position
    }

-- Select information
type alias Drag =
    { current : ( Float, Float ) -- current mouse position
    , start : ( Float, Float ) -- start mouse position
    }

type alias SelectedItem =
    { key : ViewItemKey -- selected node id or point index
    , delta : Maybe (Float, Float) -- delta between start and node center to do ajustment during movement
    }

-- SVG element position and size in DOM
type alias Element =
    { height : Float
    , width : Float
    , x : Float
    , y : Float
    }

init : Session -> String -> ( Model, Cmd Msg )
init session selectedView =
    ( Model
        session
        (SplitPane.init Horizontal)
        Init
        (getUndoRedoMonacoValue getMonacoValue)
        (ViewControl.init selectedView)
        False
        True
        ""
    , Task.attempt ReceiveMonacoElementPosition (Dom.getElement "monaco")
    )

getMonacoValue : MonacoValue
getMonacoValue =
    MonacoValue Dict.empty Nothing

type Msg
    = ViewNavigation ViewNavigation.Msg
    | Resize
    | ReceiveElementPosition (Result Dom.Error Dom.Element)
    | ReceiveMonacoElementPosition (Result Dom.Error Dom.Element)
    | DragViewElementStart ViewElementKey ( Float, Float )
    | ClickEdgeStart ViewRelationKey ( Float, Float )
    | RemoveEdge ViewRelationKey
    | DragPointStart ViewRelationPointKey ( Float, Float )
    | RemovePoint ViewRelationPointKey
    | MouseMove ( Float, Float )
    | MouseMoveEnd
    | PaneMsg SplitPane.Msg
    | MonacoEditorInitialValueReceived String
    | MonacoEditorValueReceived String
    | InitMonacoRequestReceived ()
    | SelectItemsStart (Float, Float)
    | ViewControl ViewControl.Msg
    | FilePicker FilePicker.Msg
    | RequestValueToSave ()
    | ViewUndoRedo ViewUndoRedo.Msg
    | ContainerContextMenu ContextMenu.Msg
    | NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveMonacoElementPosition (Ok _ ) ->
            ( model
            , initMonacoResponse ()
            )

        MonacoEditorValueReceived val ->
            case D.fromString rdbDecoder val of
                Ok (domain, views) ->
                    let
                        newModel =
                            { model
                            | errors = ""
                            , monacoValue =
                                let
                                    currentMonacoValue = model.monacoValue.present
                                    updatedMonacoValue =
                                        { currentMonacoValue
                                        | domain = Just domain
                                        , views = views
                                        }
                                in
                                newRecord updatedMonacoValue model.monacoValue
                            }
                    in
                    ( newModel
                    , Cmd.batch [getElementPosition, validationErrors ""]
                    )

                Err err ->
                    case err of
                        D.Parsing errMsg ->
                            ( model, validationErrors errMsg )
                        D.Decoding errMsg ->
                            ( model, validationErrors errMsg )

        MonacoEditorInitialValueReceived val ->
            case D.fromString rdbDecoder val of
                Ok (domain, views) ->
                    let
                        newMonacoValue a =
                            { a
                            | domain = Just domain
                            , views = views
                            }

                        newModel =
                            { model
                            | errors = ""
                            , showOpenFileButton = True
                            , monacoValue = mapPresent newMonacoValue model.monacoValue
                            }
                    in
                    ( newModel
                    , Cmd.batch [getElementPosition, validationErrors ""]
                    )

                Err err ->
                    case err of
                        D.Parsing errMsg ->
                            ( model, validationErrors errMsg )
                        D.Decoding errMsg ->
                            ( model, validationErrors errMsg )

        ReceiveElementPosition (Err _) ->
        -- TODO:
            ( model, Cmd.none )

        _ ->
            case model.viewEditor of
                Init ->
                    case msg of
                        ReceiveElementPosition (Ok { element }) ->
                            let
                                views = model.monacoValue.present.views

                                selectedView = ViewControl.getSelectedView model.viewControl

                                getPossibleRelations =
                                    getCurrentView selectedView views
                                        |> Maybe.map2 (\d v -> possibleRelationsToAdd (d, v)) model.monacoValue.present.domain
                                        |> Maybe.withDefault Dict.empty
                            in
                            ( { model
                            | viewEditor = Ready
                                { drag = Nothing
                                , svgElementPosition = element
                                , viewNavigation = ViewNavigation.init element
                                , viewUndoRedo = ViewUndoRedo.init
                                , brush = Nothing
                                , selectedItems = []
                                , containerMenu = ContainerMenu.init getPossibleRelations |> ContextMenu.init
                                }
                            }
                            , Cmd.none
                            )

                        InitMonacoRequestReceived _ ->
                            (model, initMonacoResponse ())

                        PaneMsg paneMsg ->
                            ( { model | pane = SplitPane.update paneMsg model.pane }
                            , Cmd.none )

                        Resize ->
                            ( model, getElementPosition )

                        _ ->  ( model, Cmd.none )
                Ready state ->
                    case msg of
                        ContainerContextMenu subMsg ->
                            let
                                (updatedModel, cmd, (selectResult, containerIdToDelete)) = ContextMenu.update subMsg state.containerMenu

                                selectedView = ViewControl.getSelectedView model.viewControl
                                currentMonacoValue = model.monacoValue.present
                                newViewsWithRelation =
                                    case selectResult of
                                        Just (containerId, relation) ->
                                            getCurrentView selectedView currentMonacoValue.views
                                                    |> addRelationToView containerId relation
                                                    |> updateViewByKey selectedView currentMonacoValue.views
                                        Nothing -> currentMonacoValue.views

                                newViewsWithRemovedContainer =
                                    case containerIdToDelete of
                                        Just containerId ->
                                            getCurrentView selectedView newViewsWithRelation
                                                |> deleteContainer containerId
                                                |> updateViewByKey selectedView newViewsWithRelation
                                        Nothing -> newViewsWithRelation

                                updatedMonacoValue = { currentMonacoValue | views = newViewsWithRemovedContainer }

                                newMonacoValue =
                                    case (selectResult, containerIdToDelete) of
                                        (Just _, Nothing) ->
                                            newRecord updatedMonacoValue model.monacoValue
                                        (Nothing, Just _) ->
                                            newRecord updatedMonacoValue model.monacoValue
                                        _ -> model.monacoValue
                            in
                            ( { model
                            | viewEditor = Ready { state | containerMenu = updatedModel }
                            , monacoValue = newMonacoValue
                            }
                            , Cmd.batch
                                [ cmd |> Cmd.map ContainerContextMenu
                                , updateMonacoValue (rdbEncode updatedMonacoValue)
                                ]
                            )

                        RequestValueToSave _ ->
                            ( model, saveValueToFile (rdbEncode model.monacoValue.present))

                        FilePicker subMsg ->
                            let
                                cmd = FilePicker.update subMsg
                            in
                            (model, cmd |> Cmd.map FilePicker)

                        ViewControl subMsg ->
                            let
                                ( updated, cmd, actions ) = ViewControl.update subMsg model.viewControl

                                ( newMonacoValue, updatedViewEditor, finalCmds ) =
                                    if ModifyView.monacoValueModified actions then
                                        let
                                            selectedView = ViewControl.getSelectedView model.viewControl
                                            currentMonacoValue = model.monacoValue.present
                                            elementPosition = ViewNavigation.getPositionForNewElement state.viewNavigation state.svgElementPosition

                                            params =
                                                { position = elementPosition
                                                , selectedView = selectedView
                                                , key = model.session.key
                                                }
                                            ( newViews, cmds ) =
                                                ModifyView.update params currentMonacoValue.views actions
                                            updatedMonacoValue = { currentMonacoValue | views = newViews }

                                            getPossibleRelations =
                                                getCurrentView selectedView newViews
                                                    |> Maybe.map2 (\d v -> possibleRelationsToAdd (d, v)) model.monacoValue.present.domain
                                                    |> Maybe.withDefault Dict.empty
                                        in
                                        ( newRecord updatedMonacoValue model.monacoValue
                                        , Ready { state | containerMenu = ContainerMenu.init getPossibleRelations |> ContextMenu.init }
                                        , Cmd.batch
                                            [ cmd |> Cmd.map ViewControl
                                            , cmds
                                            , updateMonacoValue ( rdbEncode updatedMonacoValue )
                                            ]
                                        )
                                    else
                                        ( model.monacoValue
                                        , model.viewEditor
                                        , cmd |> Cmd.map ViewControl
                                        )
                            in
                            ( { model
                            | viewControl = updated
                            , toReload = False
                            , monacoValue = newMonacoValue
                            , viewEditor = updatedViewEditor
                            }
                            , finalCmds
                            )

                        SelectItemsStart xy ->
                            let
                                shiftedXY = ViewNavigation.shiftPosition state.viewNavigation (0, 0) xy
                            in
                            (   { model | viewEditor = Ready { state | brush = Just <| Brush shiftedXY shiftedXY }
                                }
                            , Cmd.none
                            )

                        ViewUndoRedo subMsg ->
                            let
                                ( subModel, updatedMonacoValue, renew ) = ViewUndoRedo.update model.monacoValue subMsg state.viewUndoRedo
                            in
                            ( { model
                            | viewEditor = Ready { state | viewUndoRedo = subModel }
                            , monacoValue = updatedMonacoValue }
                            , if renew then
                                updateMonacoValue (rdbEncode updatedMonacoValue.present)
                            else
                                Cmd.none
                            )

                        ReceiveElementPosition (Ok { element }) ->
                            ( { model | viewEditor = Ready { state | svgElementPosition = element } }
                            , Cmd.none
                            )

                        Resize ->
                            ( model, getElementPosition )

                        DragViewElementStart viewElementKey xy ->
                            let
                                (shiftedStartX, shiftedStartY) = ViewNavigation.shiftPosition state.viewNavigation (state.svgElementPosition.x, state.svgElementPosition.y) xy

                                selectedElementKeys = getSelectedElementKeysAndDeltas state.selectedItems
                                    |> List.map Tuple.first

                                isWithinAlreadySelected = selectedElementKeys
                                    |> List.member viewElementKey

                                selectedView = ViewControl.getSelectedView model.viewControl

                                elementsOfCurrentView = getCurrentView selectedView model.monacoValue.present.views
                                    |> getViewElementsOfCurrentView

                                updatedSelectedItems =
                                    if List.isEmpty state.selectedItems || not isWithinAlreadySelected then
                                        elementsOfCurrentView
                                            |> getElement viewElementKey
                                            |> Maybe.map (\ve -> ( shiftedStartX - ve.x, shiftedStartY - ve.y ))
                                            |> SelectedItem (ElementKey viewElementKey)
                                            |> List.singleton
                                    else
                                        updateSelectedItemsDeltas elementsOfCurrentView (shiftedStartX, shiftedStartY) state.selectedItems
                            in
                            (   { model
                                | viewEditor = Ready
                                    { state
                                    | drag = Just { start = xy, current = xy }
                                    , selectedItems = updatedSelectedItems
                                    }
                                , monacoValue = newRecord model.monacoValue.present model.monacoValue
                                }
                            , Cmd.none
                            )

                        DragPointStart viewRelationPointKey xy ->
                            let
                                (viewElementKey, relation, pointIndex) = viewRelationPointKey
                                (shiftedStartX, shiftedStartY) = ViewNavigation.shiftPosition state.viewNavigation (state.svgElementPosition.x, state.svgElementPosition.y) xy

                                selectedPointKeys = getSelectedPointKeysAndDeltas state.selectedItems
                                    |> List.map Tuple.first

                                isWithinAlreadySelected = selectedPointKeys
                                    |> List.member viewRelationPointKey

                                selectedView = ViewControl.getSelectedView model.viewControl

                                elementsOfCurrentView = getCurrentView selectedView model.monacoValue.present.views
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
                                        updateSelectedItemsDeltas elementsOfCurrentView (shiftedStartX, shiftedStartY) state.selectedItems
                            in
                            (   { model
                                | viewEditor = Ready
                                    { state
                                    | drag = Just { start = xy, current = xy }
                                    , selectedItems = updatedSelectedItems
                                    }
                                , monacoValue = newRecord model.monacoValue.present model.monacoValue
                                }
                            , Cmd.none
                            )

                        RemovePoint (viewElementKey, relation, pointIndex) ->
                            let
                                removePointAtIndex list = List.take pointIndex list ++ List.drop (pointIndex + 1) list

                                selectedView = ViewControl.getSelectedView model.viewControl

                                currentMonacoValue = model.monacoValue.present

                                updatedViews =
                                    updatePointsInRelations relation removePointAtIndex
                                    |> updateRelationsInElements viewElementKey
                                    |> updateElementsInViews selectedView currentMonacoValue.views

                                updatedPresentMonacoValue =
                                    { currentMonacoValue | views = updatedViews }
                            in
                            ( { model
                            | monacoValue = newRecord updatedPresentMonacoValue model.monacoValue
                            }
                            , updateMonacoValue (rdbEncode updatedPresentMonacoValue)
                            )

                        RemoveEdge viewRelationKey ->
                            let
                                selectedView = ViewControl.getSelectedView model.viewControl

                                currentView = getCurrentView selectedView model.monacoValue.present.views
                                currentMonacoValue = model.monacoValue.present

                                updatedViews = currentView
                                    |> Maybe.map (removedEdge viewRelationKey)
                                    |> updateViewByKey selectedView currentMonacoValue.views

                                updatedPresentMonacoValue =
                                    { currentMonacoValue | views = updatedViews }

                                getPossibleRelations =
                                    getCurrentView selectedView updatedViews
                                        |> Maybe.map2 (\d v -> possibleRelationsToAdd (d, v)) model.monacoValue.present.domain
                                        |> Maybe.withDefault Dict.empty

                                updatedViewEditor =
                                    Ready { state | containerMenu = ContainerMenu.init getPossibleRelations |> ContextMenu.init }
                            in
                            (   { model
                                | monacoValue = newRecord updatedPresentMonacoValue model.monacoValue
                                , viewEditor = updatedViewEditor
                                }
                            , updateMonacoValue (rdbEncode updatedPresentMonacoValue)
                            )
                        ClickEdgeStart (viewElementKey, relation) xy ->
                            let
                                spxy = ViewNavigation.shiftPosition state.viewNavigation (state.svgElementPosition.x, state.svgElementPosition.y) xy

                                selectedView = ViewControl.getSelectedView model.viewControl

                                currentView = getCurrentView selectedView model.monacoValue.present.views

                                sourceXY = currentView |> getViewElementsOfCurrentView
                                    |> getElement viewElementKey
                                    |> Maybe.map (\s -> (s.x, s.y))

                                targetXY = currentView |> getViewElementsOfCurrentView
                                    |> getElement (Tuple.first relation)
                                    |> Maybe.map (\s -> (s.x, s.y))
                            in
                            case (sourceXY, targetXY, currentView) of
                                (Just sxy, Just txy, Just cv) ->
                                    let
                                        allPoints = sxy :: (getViewRelationPoints (viewElementKey, relation) cv) ++ [ txy ]

                                        (_ , (insertAfterValue, _)) =
                                            List.foldr
                                            (\currentPoint -> \(previousPoint, (insertAfterPoint, val)) ->
                                                let
                                                    z = distanceToLine spxy (currentPoint , previousPoint)

                                                    (extendedA, extendedPrev) = extendPoints currentPoint previousPoint
                                                in
                                                if not (isNaN z) && betweenPoints spxy (extendedA, extendedPrev) && z < val then
                                                    (currentPoint, (currentPoint, z))
                                                else
                                                    (currentPoint, (insertAfterPoint, val))
                                            )
                                            (txy, (txy, maxSafeInteger))
                                            allPoints

                                        (listWithNewPoint, indexOfNewPoint, _ ) = List.foldr
                                            (\a -> \(b, i, found) ->
                                                if insertAfterValue == a then
                                                    (a :: spxy :: b, i, True)
                                                else
                                                    (a :: b, if found then i else i + 1, found)
                                            )
                                            ([], 0, False)
                                            allPoints

                                        updatedList = listWithNewPoint |> trimList 1

                                        updatedPoints = \_ -> updatedList |> List.map (\(x, y) -> ViewRelationPoint x y)

                                        updatedViewsValue =
                                            updatedPoints
                                            |> updatePointsInRelations relation
                                            |> updateRelationsInElements viewElementKey
                                            |> updateElementsInViews selectedView model.monacoValue.present.views

                                        currentMonacoValue = model.monacoValue.present

                                        updatedPresentMonacoValue =
                                            { currentMonacoValue | views = updatedViewsValue }
                                    in
                                    (   { model
                                        | monacoValue = newRecord updatedPresentMonacoValue model.monacoValue
                                        }
                                    , updateMonacoValue (rdbEncode updatedPresentMonacoValue)
                                    )
                                _ -> ( model, Cmd.none )

                        MouseMove xy ->
                            let
                                selectedViewKey = ViewControl.getSelectedView model.viewControl
                                selectedView = getCurrentView selectedViewKey model.monacoValue.present.views
                                updatedViewEditor = handleMouseMove xy state selectedView

                                updatedViews =
                                    case (state.brush, state.drag) of
                                        (Nothing, Just _ ) ->
                                            updateElementAndPointPosition state.selectedItems xy state
                                                |> updateElementsInViews selectedViewKey model.monacoValue.present.views
                                        _ ->
                                            model.monacoValue.present.views

                                updatedPresentMonacoValue a =
                                    { a | views = updatedViews }
                            in
                            (   { model
                                | viewEditor = updatedViewEditor
                                , monacoValue = mapPresent updatedPresentMonacoValue model.monacoValue
                                }
                            , Cmd.none)

                        MouseMoveEnd ->
                            case state.brush of
                                Just _ ->
                                    ( { model | viewEditor = Ready { state | brush = Nothing } }
                                    , Cmd.none
                                    )
                                Nothing ->
                                    case state.drag of
                                        Just _ ->
                                            (   { model | viewEditor = Ready { state | drag = Nothing, selectedItems = [] }
                                                }
                                            , updateMonacoValue (rdbEncode model.monacoValue.present)
                                            )
                                        _ ->
                                            ( model, Cmd.none )

                        PaneMsg paneMsg ->
                            ( { model | pane = SplitPane.update paneMsg model.pane }
                            , Cmd.none
                            )

                        ViewNavigation subMsg ->
                            let
                                ( updated, cmd ) = ViewNavigation.update subMsg state.viewNavigation
                            in
                            ( { model
                            | viewEditor = Ready { state | viewNavigation = updated }
                            }
                            , cmd |> Cmd.map ViewNavigation )

                        _ -> ( model, Cmd.none )

getElementPosition : Cmd Msg
getElementPosition =
    Task.attempt ReceiveElementPosition (Dom.getElement elementId)

elementId : String
elementId =
    "main-graph"

getSelectedElementKeysAndDeltas : List SelectedItem -> List (ViewElementKey, Maybe (Float, Float))
getSelectedElementKeysAndDeltas =
    let
        extractViewElelementKeys v =
            case v.key of
                ElementKey x -> Just (x, v.delta)
                PointKey _ -> Nothing
    in
    List.filterMap extractViewElelementKeys


updateSelectedItemsDeltas : Maybe (Dict ViewElementKey ViewElement) -> (Float, Float) -> List SelectedItem -> List SelectedItem
updateSelectedItemsDeltas viewElementsOfCurrentView (shiftedStartX, shiftedStartY) selectedItems =
    let
        selectedPointKeys = getSelectedPointKeysAndDeltas selectedItems
            |> List.map Tuple.first

        selectedElementKeys = getSelectedElementKeysAndDeltas selectedItems
            |> List.map Tuple.first

        elementIsWithinAlreadySelected vek _ =
            List.member vek selectedElementKeys

        pointIsWithinAlreadySelected vpk =
            List.member vpk selectedPointKeys
        selectedElementsWithDeltas = viewElementsOfCurrentView
            |> Maybe.map (Dict.filter elementIsWithinAlreadySelected)
            |> Maybe.map Dict.toList
            |> Maybe.withDefault []
            |> List.map (\(vek, ve) -> SelectedItem (ElementKey vek) (Just ( shiftedStartX - ve.x, shiftedStartY - ve.y )))
        selectedPointsWithDeltas = viewElementsOfCurrentView
            |> Maybe.map Dict.toList
            |> Maybe.withDefault []
            |> List.concatMap (\(vek, ve) -> ve.relations |> Dict.toList |> List.map (Tuple.pair vek))
            |> List.concatMap (\(vek, (r, points) ) -> points |> List.indexedMap (\i point -> ((vek, r, i), point)))
            |> List.filter (\(vpk, _) -> pointIsWithinAlreadySelected vpk)
            |> List.map (\(vpk, point) -> SelectedItem (PointKey vpk) (Just ( shiftedStartX - point.x, shiftedStartY - point.y )))
    in
        selectedElementsWithDeltas ++ selectedPointsWithDeltas

getSelectedPointKeysAndDeltas : List SelectedItem -> List (ViewRelationPointKey, Maybe(Float, Float))
getSelectedPointKeysAndDeltas =
    let
        extractPointKeys v =
            case v.key of
                PointKey x -> Just (x, v.delta)
                ElementKey _ -> Nothing
    in
    List.filterMap extractPointKeys

{-| calculate distance to the line created by two points
it is not work good as it is required to calculcate distance to line segment
not line
TODO
-}
distanceToLine : (Float, Float) -> ((Float, Float), (Float, Float)) -> Float
distanceToLine (x, y) ((x1, y1), (x2, y2)) =
    -- distance to the line
    abs ((x2 - x1) * (y1 - y) - (x1 - x) * (y2 - y1)) / sqrt ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))

{-| is it enough to put the point ?
-}
betweenPoints : (Float, Float) -> ((Float, Float), (Float, Float)) -> Bool
betweenPoints (x, y) ((x1, y1), (x2, y2)) =
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

handleMouseMove : ( Float, Float ) -> ViewEditorState -> Maybe View -> ViewEditor
handleMouseMove xy ({ drag, brush } as state) currentView =
    case brush of
        Just b ->
            let
                shiftedXY = ViewNavigation.shiftPosition state.viewNavigation (0, 0) xy
                updatedBrush = { b | end = shiftedXY }
                elementKeysWithinBrush = currentView
                    |> getViewElementsOfCurrentView
                    |> getViewElementKeysByCondition (elementWithinBrush updatedBrush)
                    |> List.map (\i -> SelectedItem (ElementKey i) Nothing)

                pointKeysWithinBrush = currentView
                    |> getViewElementsOfCurrentView
                    |> getElementAndItsKeys
                    |> List.concatMap (\(k, v) -> v.relations |> Dict.toList |> List.map (\(relation, points) -> (k, relation, points)))
                    |> List.concatMap (\(k, relation, points) -> points |> getViewPointKeysByCondition (pointWithinBrush updatedBrush) |> List.map (\pointIndex -> (k, relation, pointIndex)))
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
elementWithinBrush { start, end } _ {x , y} =
    let
        (startX1, startY1) = start
        (endX2, endY2) = end
    in
    x > min startX1 endX2 && x < max startX1 endX2
        && y > min startY1 endY2 && y < max startY1 endY2

pointWithinBrush : Brush -> ViewRelationPoint -> Bool
pointWithinBrush { start, end } {x , y} =
    let
        (startX1, startY1) = start
        (endX2, endY2) = end
    in
    x > min startX1 endX2 && x < max startX1 endX2
        && y > min startY1 endY2 && y < max startY1 endY2

updateElementAndPointPosition : List SelectedItem -> ( Float, Float ) -> ViewEditorState -> (Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement)
updateElementAndPointPosition selectedItems xy state =
    let
        selectedElementDeltas = getSelectedElementKeysAndDeltas selectedItems
            |> List.filterMap (\(k, d) -> d |> Maybe.map (Tuple.pair k))

        selectedPointsDeltas = getSelectedPointKeysAndDeltas selectedItems
            |> List.filterMap (\(k, d) -> d |> Maybe.map (Tuple.pair k))

        (shiftedX, shiftedY) = ViewNavigation.shiftPosition state.viewNavigation (state.svgElementPosition.x, state.svgElementPosition.y) xy
        updateElementXY : ViewElementKey -> ViewElement -> ViewElement
        updateElementXY viewElementKey viewElement =
            let
                foundElement = selectedElementDeltas |> List.filter (\x -> Tuple.first x == viewElementKey) |> List.head
            in
            case foundElement of
                Just (_, (deltaX, deltaY)) ->
                    { viewElement | x = shiftedX - deltaX, y = shiftedY - deltaY }
                Nothing -> viewElement

        updatePointXY : List (ViewRelationPointIndex, (Float, Float)) -> Int -> ViewRelationPoint -> ViewRelationPoint
        updatePointXY selectedPointIndexes i viewRelationPoint =
            selectedPointIndexes
                |> List.filterMap (\(pointIndex, d) ->
                    if pointIndex == i then
                        Just d
                    else
                        Nothing)
                |> List.head
                |> Maybe.map (\(deltaX, deltaY) ->
                    { viewRelationPoint | x = shiftedX - deltaX, y = shiftedY - deltaY }
                )
                |> Maybe.withDefault viewRelationPoint

        updatedPoints viewElementKey =
            Dict.map (\relation points ->
                let
                    updatePointXYUsingSelectedPoints = selectedPointsDeltas
                        |> List.filterMap (\((vek, rel, pointIndex), delta) ->
                            if vek == viewElementKey && rel == relation then
                                Just (pointIndex, delta)
                            else
                                Nothing
                        )
                        |> updatePointXY
                in
                List.indexedMap updatePointXYUsingSelectedPoints points
            )

        updatedRelations : ViewElementKey -> ViewElement -> ViewElement
        updatedRelations viewElementKey viewElement =
            { viewElement | relations = updatedPoints viewElementKey viewElement.relations}
    in
    Dict.map (\viewElementKey ve ->
        updateElementXY viewElementKey ve
        |> updatedRelations viewElementKey
    )


view : Model -> Document Msg
view model =
    let
        { pane, viewEditor, monacoValue, viewControl } = model
        { domain, views } = monacoValue.present
        graphics =
            case viewEditor of
                Init -> [ text "" ]
                Ready state -> (svgView (views, domain) viewControl state)
    in
    { title = "RDB Model Editor"
    , body =
        [ div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
            [ SplitPane.view
                viewConfig
                (div [ id elementId, Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%", Html.Attributes.style "position" "relative" ] graphics )
                (monacoViewPart (model.showOpenFileButton && model.session.isFileSystemSupported))
                pane
            , div [ style "position" "fixed", style "bottom" "0", style "left" "0", style "font-size" "9px" ] [ text "v0.0.1"]
            ]
        ]
    }

viewConfig : ViewConfig Msg
viewConfig =
    createViewConfig
        { toMsg = PaneMsg
        , customSplitter = Nothing
        }

monacoViewPart : Bool -> Html Msg
monacoViewPart showButton =
    div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
    [ div [ id "monaco", Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ] []
    , if showButton then FilePicker.view |> Html.map FilePicker else text ""
    ]

svgView : (Dict String View, Maybe Domain) -> ViewControl.Model -> ViewEditorState -> List (Html Msg)
svgView (views, domain) viewControlModel viewEditorState =
    let
        { viewNavigation } = viewEditorState

        rectNavigationEvents = ViewNavigation.gridRectEvents viewNavigation |> List.map (Html.Attributes.map ViewNavigation)

        selectedView = ViewControl.getSelectedView viewControlModel

        gridRectEvents : List (Attribute Msg)
        gridRectEvents =
            if ViewNavigation.panMode viewNavigation then
                rectNavigationEvents
            else
                mouseDownMain SelectItemsStart :: rectNavigationEvents

        transform10 =
            ViewNavigation.getScale viewNavigation |> (*) 10

        transform100 = transform10 * 10

        getXY =
            ViewNavigation.getTranslate viewNavigation
            |> (\t -> (floatRemainderBy transform100 t.x, floatRemainderBy transform100 t.y))
    in
    [ svg
        [ id elementId
        , Attrs.width <| Percent 100
        , Attrs.height <| Percent 100
        -- TODO Disable right click menu
        , Mouse.onContextMenu (\_ -> NoOp)
        ]
        [ defs []
            [ innerGrid transform10
            , grid getXY transform100
            , markerDot -- for circle in edges
            ]
        , gridRect gridRectEvents
        , g
            [ ViewNavigation.zoomTransformAttr viewEditorState.viewNavigation |> Html.Attributes.map ViewNavigation ]
            [ renderCurrentView (views, domain, selectedView) viewEditorState
            , renderSelectRect viewEditorState
            ]
        ]
    , ViewControl.view views (getElementsToAdd domain) viewControlModel |> Html.map ViewControl
    , ViewNavigation.view viewEditorState.viewNavigation |> Html.map ViewNavigation
    , ViewUndoRedo.view |> Html.map ViewUndoRedo
    , ContextMenu.view viewEditorState.containerMenu |> Html.map ContainerContextMenu
    ]

mouseDownMain : ((Float, Float) -> Msg) -> Attribute Msg
mouseDownMain msg =
    Mouse.onDown <|
        onlyMainButton
        >> Maybe.map msg
        >> Maybe.withDefault NoOp

onlyMainButton : Event -> Maybe (Float, Float)
onlyMainButton e =
    case e.button of
        Mouse.MainButton -> Just e.clientPos
        _ -> Nothing

floatRemainderBy : Float -> Float -> Float
floatRemainderBy divisor n =
  n - toFloat(truncate (n / divisor)) * divisor

renderCurrentView : (Dict String View, Maybe Domain, String) -> ViewEditorState -> Svg Msg
renderCurrentView (views, domain, selectedView) model =
    let
        { selectedItems, viewNavigation } = model
    in
    case (getCurrentView selectedView views, domain) of
        (Just v, Just d) ->
            g []
                [ getEdges (d, v)
                    |> List.map (drawEdge viewNavigation selectedItems)
                    |> g [ class [ "links" ] ]
                , getContainers (d, v)
                    |> List.map (drawContainer viewNavigation selectedItems)
                    |> g [ class [ "nodes" ] ]
                ]
        _ -> text ""

renderSelectRect : ViewEditorState -> Svg Msg
renderSelectRect model =
    case model.brush of
        Just { start, end } ->
            selectItemsRect start end
        Nothing ->
            text ""

drawEdge : ViewNavigation.Model -> List SelectedItem -> Edge -> Svg Msg
drawEdge viewNavigation selectedItems edge =
    let
        getSelectedPointIndex vpk =
            if getViewRelationKeyFromViewRelationPointKey vpk == getViewRelationKeyFromEdge edge then
                let
                    (_, _, viewRelationPointIndex) = vpk
                in
                Just viewRelationPointIndex
            else
                Nothing
    in
    getSelectedPointKeysAndDeltas selectedItems
        |> List.map Tuple.first
        |> List.filterMap getSelectedPointIndex
        |> linkElement viewNavigation edge

linkElement : ViewNavigation.Model -> Edge -> List Int -> Svg Msg
linkElement viewNavigation edge =
    let
        viewRelationKey = getViewRelationKeyFromEdge edge
    in
    if ViewNavigation.panMode viewNavigation then
        edgeBetweenContainers
            edge
            (ViewNavigation.panModeEvent viewNavigation |> List.map (Html.Attributes.map ViewNavigation))
            (\_ -> ViewNavigation.panModeEvent viewNavigation |> List.map (Html.Attributes.map ViewNavigation))
    else
        edgeBetweenContainers
            edge
            (onMouseDownEdge viewRelationKey |> List.singleton)
            (onMouseDownPoint viewRelationKey)

onMouseDownEdge : ViewRelationKey -> Attribute Msg
onMouseDownEdge viewRelationKey =
    Mouse.onDown
        (\e ->
            case e.button of
                Mouse.MainButton -> ClickEdgeStart viewRelationKey e.clientPos
                Mouse.SecondButton -> RemoveEdge viewRelationKey
                _ -> NoOp
        )

onMouseDownPoint : ViewRelationKey -> Int -> List (Attribute Msg)
onMouseDownPoint (viewRelationElementKey, relation) index =
    let
        viewRelationPointKey = (viewRelationElementKey, relation, index)
    in
    Mouse.onDown
        (\e ->
            case e.button of
                Mouse.MainButton -> DragPointStart viewRelationPointKey e.clientPos
                Mouse.SecondButton -> RemovePoint viewRelationPointKey
                _ -> NoOp
        )
    |> List.singleton

drawContainer : ViewNavigation.Model -> List SelectedItem -> Container -> Svg Msg
drawContainer viewNavigation selectedItems container =
    let
        mouseDownAttr =
            if ViewNavigation.panMode viewNavigation then
                ViewNavigation.panModeEvent viewNavigation |> List.map ( Html.Attributes.map ViewNavigation )
            else
                [ mouseDownMain (DragViewElementStart container.key) ]

        selectedElements = getSelectedElementKeysAndDeltas selectedItems
            |> List.map Tuple.first

        renderContainerFunc =
            if List.member container.key selectedElements then
                renderContainerSelected
            else
                renderContainer

        contextMenuAttr = container.key
            |> ContextMenu.attach
            |> Html.Attributes.map ContainerContextMenu
            |> List.singleton
    in
    renderContainerFunc container (mouseDownAttr ++ contextMenuAttr)


subscriptions : Model -> Sub Msg
subscriptions model =
  let
    dragSubscriptions : Sub Msg
    dragSubscriptions =
      Sub.batch
        [ Events.onMouseMove
          (Decode.map (.clientPos >> MouseMove) Mouse.eventDecoder)
        , Events.onMouseUp
          (Decode.map (\_ -> MouseMoveEnd) Mouse.eventDecoder)
        ]

    readySubscriptions : ViewEditorState -> Sub Msg
    readySubscriptions { viewNavigation, brush, drag } =
      Sub.batch
        [ ViewNavigation.subscriptions viewNavigation |> Sub.map ViewNavigation
        , case (brush, drag) of
          (Nothing, Nothing) -> Sub.none
          _ -> dragSubscriptions
        ]
  in
  Sub.batch
    [ case model.viewEditor of
        Init ->
            Sub.none

        Ready state ->
            Sub.batch
                [ readySubscriptions state
                , ViewUndoRedo.subscriptions state.viewUndoRedo |> Sub.map ViewUndoRedo
                , ContextMenu.subscriptions state.containerMenu |> Sub.map ContainerContextMenu
                , ViewControl.subscriptions |> Sub.map ViewControl
                ]
    , Events.onResize (\_ _ -> Resize)
    , Sub.map PaneMsg <| SplitPane.subscriptions model.pane
    , monacoEditorInitialValue <| MonacoEditorInitialValueReceived
    , monacoEditorSavedValue <| MonacoEditorValueReceived
    , initMonacoRequest InitMonacoRequestReceived
    , requestValueToSave RequestValueToSave
    ]
