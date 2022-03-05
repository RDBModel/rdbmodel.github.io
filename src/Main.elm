port module Main exposing (..)

import Browser
import SplitPane exposing (Orientation(..), ViewConfig, createViewConfig)
import Browser.Dom as Dom
import Basics.Extra exposing (maxSafeInteger)
import Browser.Events as Events
import Json.Decode as Decode
import Yaml.Decode as D
import Html exposing (Html, div, text)
import Html.Events.Extra.Mouse as Mouse
import TypedSvg exposing (svg, defs, g)
import TypedSvg.Attributes as Attrs exposing ( class,  x, y, id)
import TypedSvg.Types exposing ( Length(..))
import TypedSvg.Core exposing (Svg, Attribute)
-- import Graph exposing (Graph, Node, Edge, NodeContext, NodeId, Adjacency)
import Zoom exposing (Zoom, OnZoom)
import Task
import Html.Attributes
import Elements exposing
    ( renderContainer, renderContainerSelected
    , markerDot, innerGrid, grid, gridRect, edgeBetweenContainers, edgeStrokeWidthExtend, gridCellSize
    )
import Html.Events.Extra.Mouse exposing (Event)
import DomainDecoder exposing (..)
import Dict exposing (Dict)
import Domain exposing (..)

port messageReceiver : (String -> msg) -> Sub msg

port sendMessage : String -> Cmd msg



main : Program () Model Msg
main =
  Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }

init : () -> ( Model, Cmd Msg )
init _ =
    (Model (SplitPane.init Horizontal) Init "", getElementPosition)

type alias Model =
    { pane : SplitPane.State
    , root : Root
    , errors : String
    }


type Msg
    = ZoomMsg OnZoom
    | Resize
    | ReceiveElementPosition (Result Dom.Error Dom.Element)
    | DragViewElementStart ViewElementKey ( Float, Float )
    | ClickEdgeStart ViewRelationKey ( Float, Float )
    | DragPointStart ViewRelationPointKey ( Float, Float )
    | RemovePoint ViewRelationPointKey
    | DragAt ( Float, Float )
    | DragEnd
    | PaneMsg SplitPane.Msg
    | MonacoEditorValueChanged String
    | MonacoSendValue String
    | SetPanMode Bool
    | SelectItemsStart (Float, Float)
    | NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.root of
        Init ->
            case msg of
                ReceiveElementPosition (Ok { element }) ->
                    ( { model | root = Ready
                        { drag = Nothing
                        , element = element
                        , zoom = initZoom element
                        , views = Dict.empty
                        , selectedView = Nothing
                        , panMode = False
                        }
                    }
                    , Cmd.none
                    )

                ReceiveElementPosition (Err _) ->
                    ( model, Cmd.none )

                PaneMsg paneMsg ->
                    ( { model | pane = SplitPane.update paneMsg model.pane }, Cmd.none )

                Resize ->
                    ( model, getElementPosition )

                _ ->  ( model, Cmd.none )
        Ready state ->
            case msg of
                SelectItemsStart (x, y) ->
                    ( model
                    , Cmd.none
                    )
                SetPanMode value ->
                    ( { model | root = Ready { state | panMode = value } }
                    , Cmd.none
                    )

                ReceiveElementPosition (Ok { element }) ->
                    ( { model | root = Ready { state | element = element } }
                    , Cmd.none
                    )

                ReceiveElementPosition (Err _) ->
                    ( model, Cmd.none )

                MonacoEditorValueChanged val ->
                    let
                        rdb = D.fromString rdbDecoder val
                    in
                    case rdb of
                        Ok (domain, views) ->
                            ( { model | errors = "", root = Ready { state | views = views, selectedView = Dict.keys views |> List.head } }, Cmd.none )

                        Err err ->
                            case err of
                                D.Parsing errMsg -> ( { model | errors = errMsg }, Cmd.none)
                                D.Decoding errMsg -> ( { model | errors = errMsg }, Cmd.none)

                MonacoSendValue val ->
                    ( model, sendMessage val )

                Resize ->
                    ( model, getElementPosition )

                ZoomMsg zoomMsg ->
                    ( { model | root = Ready { state | zoom = Zoom.update zoomMsg state.zoom } }
                    , Cmd.none
                    )

                DragViewElementStart viewElementKey xy ->
                    let
                        (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.element.x, state.element.y) xy
                        delta = getCurrentView state.selectedView state.views
                            |> getViewElementsOfCurrentView
                            |> getElement viewElementKey
                            |> Maybe.map (\ve -> ( shiftedStartX - ve.x, shiftedStartY - ve.y ))
                            |> Maybe.withDefault ( 0, 0 )
                    in
                    ( { model | root = Ready
                        { state | drag = Just { start = xy, current = xy, selectedItems = [SelectedItem (ElementKey viewElementKey) delta] } }
                    }
                    , Cmd.none
                    )

                DragPointStart viewRelationPointKey xy ->
                    let
                        (viewElementKey, relation, pointIndex) = viewRelationPointKey
                        (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.element.x, state.element.y) xy

                        delta = getCurrentView state.selectedView state.views
                            |> getViewElementsOfCurrentView
                            |> getElement viewElementKey
                            |> getRelationPoints relation
                            |> getPoint pointIndex
                            |> Maybe.map (\tp -> ( shiftedStartX - tp.x, shiftedStartY - tp.y ))
                            |> Maybe.withDefault ( 0, 0 )
                    in
                    ( { model | root = Ready
                        { state | drag
                            = Just { start = xy, current = xy, selectedItems = [SelectedItem (PointKey viewRelationPointKey) delta] } }
                    }
                    , Cmd.none
                    )

                RemovePoint (viewElementKey, relation, pointIndex) ->
                    let
                        removePointAtIndex list = List.take pointIndex list ++ List.drop (pointIndex + 1) list
                        
                        updatedViews =
                            updatePointsInRelations relation removePointAtIndex
                            |> updateRelationsInElements viewElementKey
                            |> updateElementsInViews state.selectedView state.views
                    in
                    ( { model | root = Ready { state | views = updatedViews } }
                    , sendMessage (viewElementKey ++ "|" ++ getStringFromRelation relation ++ "|del|" ++ String.fromInt pointIndex )
                    )

                ClickEdgeStart (viewElementKey, relation) xy ->
                    let
                        spxy = shiftPosition state.zoom (state.element.x, state.element.y) xy

                        currentView = getCurrentView state.selectedView state.views

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
                                magicIntMax = maxSafeInteger
                                allPoints = sxy :: (getViewRelationPoints (viewElementKey, relation) cv) ++ [ txy ]

                                -- as the actual edge is wider then visible, we are extending the search area
                                extendPoints (x1, y1) (x2, y2) =
                                    let
                                        extend v1 v2 =
                                            if v1 < v2 || v1 == v2 then
                                                (v1 - edgeStrokeWidthExtend, v2 + edgeStrokeWidthExtend)
                                            else
                                                (v2 - edgeStrokeWidthExtend, v1 + edgeStrokeWidthExtend)

                                        (ux1, ux2) = extend x1 x2
                                        (uy1, uy2) = extend y1 y2
                                    in
                                    ((ux1, uy1), (ux2, uy2))

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
                                    (txy, (txy, magicIntMax))
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

                                updatedList = listWithNewPoint
                                    |> List.drop 1
                                    |> List.reverse
                                    |> List.drop 1
                                    |> List.reverse

                                updatedPoints = \_ -> updatedList |> List.map (\(x, y) -> ViewRelationPoint x y)
                                
                                updatedViewsValue =
                                    updatedPoints
                                    |> updatePointsInRelations relation 
                                    |> updateRelationsInElements viewElementKey
                                    |> updateElementsInViews state.selectedView state.views

                            in
                            ( { model | root = Ready { state | views = updatedViewsValue } }
                            ,  sendMessage (viewElementKey ++ "|" ++ getStringFromRelation relation ++ "|add|" ++ String.fromInt (List.length updatedList - indexOfNewPoint)
                                    ++ "|" ++ String.fromFloat (Tuple.first spxy) ++ "," ++ String.fromFloat (Tuple.second spxy))
                            )
                        _ -> ( model, Cmd.none )

                DragAt xy ->
                    let
                        (updatedRoot, cmdMsg) = handleDragAt xy state
                    in
                    ( { model | root = updatedRoot }, cmdMsg)

                DragEnd ->
                    case state.drag of
                        Just { selectedItems } ->
                            let
                                createMessage (elementKey, element) =
                                    elementKey ++ "|" ++ String.fromFloat element.x ++ "," ++ String.fromFloat element.y

                                createPointMessage (viewRelationPointKey, viewRelationPoint) =
                                    let
                                        (viewElementKey, relation, viewRelationPointIndex) = viewRelationPointKey
                                        x = viewRelationPoint.x
                                        y = viewRelationPoint.y
                                    in
                                    viewElementKey ++ "|" ++ getStringFromRelation relation ++ "|" ++ String.fromInt viewRelationPointIndex
                                        ++ "|" ++ String.fromFloat x ++ "," ++ String.fromFloat y
                                viewElements =
                                    getCurrentView state.selectedView state.views
                                    |> getViewElementsOfCurrentView
                                
                                currentViewElementsXY = viewElements
                                    |> getElements (getSelectedElementKeysAndDeltas selectedItems |> List.map Tuple.first)

                                currentRelationPointXY = viewElements
                                    |> getPoints (getSelectedPointKeysAndDeltas selectedItems |> List.map Tuple.first)
                                
                                updateElementPositionMessages = currentViewElementsXY
                                    |> List.map (createMessage >> sendMessage)
                                
                                updateElementPointsPositionMessages = currentRelationPointXY
                                    |> List.map (createPointMessage >> sendMessage)
                                    
                                allMessages = (updateElementPositionMessages ++ updateElementPointsPositionMessages)
                                    |> Cmd.batch

                            in
                            ( { model | root = Ready { state | drag = Nothing } }
                            , allMessages
                            )
                        _ ->
                            ( { model | root = Ready state }, Cmd.none )

                PaneMsg paneMsg ->
                    ( { model | pane = SplitPane.update paneMsg model.pane }, Cmd.none )

                NoOp -> ( model, Cmd.none )


view : Model -> Html Msg
view { pane, root } =
    div []
        [ SplitPane.view
            viewConfig
            (svgView root)
            (div [ id "monaco", Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%"] [])
            pane
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
    let
        dragSubscriptions : Sub Msg
        dragSubscriptions =
            Sub.batch
                [ Events.onMouseMove
                    (Decode.map (.clientPos >> DragAt) Mouse.eventDecoder)
                , Events.onMouseUp
                    (Decode.map (\_ -> DragEnd) Mouse.eventDecoder)
                ]

        readySubscriptions : AppState -> Sub Msg
        readySubscriptions { drag, zoom } =
            Sub.batch
                [ Zoom.subscriptions zoom ZoomMsg
                , case drag of
                    Just _ ->
                        dragSubscriptions

                    _ ->
                        Sub.none
                ]
    in
    Sub.batch
        [ case model.root of
            Init ->
                Sub.none

            Ready state ->
                readySubscriptions state
        , Events.onResize (\_ -> \_ -> Resize)
        , Events.onKeyDown (keyDecoder |> setPanMode True)
        , Events.onKeyUp (keyDecoder |> setPanMode False)
        , Sub.map PaneMsg <| SplitPane.subscriptions model.pane
        , messageReceiver MonacoEditorValueChanged
        ]

keyDecoder : Decode.Decoder String
keyDecoder =
  Decode.field "key" Decode.string

setPanMode : Bool -> Decode.Decoder String -> Decode.Decoder Msg
setPanMode value =
    Decode.map (\key -> if key == "Control" then SetPanMode value else NoOp)

type Root
    = Init
    | Ready AppState

type alias SubPathEdge = 
    { points : List (Float, Float)
    }

type alias AppState =
    { drag : Maybe Drag
    -- , graph : Graph Container SubPathEdge
    , views : Dict String View
    , selectedView : Maybe String
    , zoom : Zoom
    -- The position and dimensions of the svg element.
    , element : Element
    , panMode : Bool
    }

type alias Brush =
    { current : ( Float, Float ) -- current mouse position
    , start : ( Float, Float ) -- start mouse position
    }

-- Select information
type alias Drag =
    { current : ( Float, Float ) -- current mouse position
    , selectedItems : List SelectedItem 
    , start : ( Float, Float ) -- start mouse position
    }

type alias SelectedItem =
    { key : ViewItemKey -- selected node id or point index
    , delta : (Float, Float) -- delta between start and node center to do ajustment during movement
    }

-- SVG element position and size in DOM
type alias Element =
    { height : Float
    , width : Float
    , x : Float
    , y : Float
    }

elementId : String
elementId =
    "main-graph"

getElementPosition : Cmd Msg
getElementPosition =
    Task.attempt ReceiveElementPosition (Dom.getElement elementId)


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

{-| calculate distance to the line created by two points
it is not work good as it is required to calculcate distance to line segment
not line
TODO
-}
distanceToLine : (Float, Float) -> ((Float, Float), (Float, Float)) -> Float
distanceToLine (x, y) ((x1, y1), (x2, y2)) =
    -- distance to the line
    abs ((x2 - x1) * (y1 - y) - (x1 - x) * (y2 - y1)) / sqrt ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))

initZoom : Element -> Zoom
initZoom element =
    Zoom.init { width = element.width, height = element.height }
        |> Zoom.scaleExtent 0.1 2

floatRemainderBy : Float -> Float -> Float
floatRemainderBy divisor n =
  n - toFloat(truncate (n / divisor)) * divisor

handleDragAt : ( Float, Float ) -> AppState -> ( Root, Cmd Msg )
handleDragAt xy ({ drag } as state) =
    case drag of
        Just { start, selectedItems } ->
            ( Ready
                { state
                    | drag = Just { start = start, current = xy, selectedItems = selectedItems }
                    , views = updateElementAndPointPosition selectedItems xy state
                }
            , Cmd.none
            )

        _ ->
            ( Ready state, Cmd.none )


updateElementAndPointPosition : List SelectedItem -> ( Float, Float ) -> AppState -> Dict String View
updateElementAndPointPosition selectedItems xy state =
    let
        selectedElementDeltas = getSelectedElementKeysAndDeltas selectedItems

        selectedPointsDeltas = getSelectedPointKeysAndDeltas selectedItems

        (shiftedX, shiftedY) = shiftPosition state.zoom (state.element.x, state.element.y) xy
        updateElementXY : ViewElementKey -> ViewElement -> ViewElement
        updateElementXY viewElementKey viewElement =
            let
                foundElement = selectedElementDeltas |> List.filter (\x -> Tuple.first x == viewElementKey) |> List.head
            in
            case foundElement of
                Just (_, (deltaX, deltaY)) ->
                    { viewElement | x = shiftedX - deltaX, y = shiftedY - deltaY }
                Nothing -> viewElement

        updatePointXY pointIndex (deltaX, deltaY) i viewRelationPoint =
            if i == pointIndex then
                { viewRelationPoint | x = shiftedX - deltaX, y = shiftedY - deltaY }
            else
                viewRelationPoint

        updatePoints viewElementKey =
            Dict.map (\relation points ->
            let
                selectedPointIndex = selectedPointsDeltas
                    |> List.filterMap (\((vek, rel, pointIndex), delta) ->
                        if vek == viewElementKey && rel == relation then
                            Just (pointIndex, delta)
                        else
                            Nothing
                    )
                    |> List.head
            in
            case selectedPointIndex of
                Just (i, delta) ->
                    List.indexedMap (updatePointXY i delta) points
                Nothing -> points
            )

        updatedRelations : ViewElementKey -> ViewElement -> ViewElement
        updatedRelations viewElementKey viewElement =
            { viewElement | relations = updatePoints viewElementKey viewElement.relations}

        updatedElements : Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement
        updatedElements =
            Dict.map (\viewElementKey ve ->
                updateElementXY viewElementKey ve
                |> updatedRelations viewElementKey 
            )
    in
    updateElementsInViews state.selectedView state.views updatedElements

{-| The mouse events for drag start, drag at and drag end read the client
position of the cursor, which is relative to the browser viewport. However,
the node positions are relative to the svg viewport. This function adjusts the
coordinates accordingly. It also takes the current zoom level and position
into consideration.
-}
shiftPosition : Zoom -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
shiftPosition zoom (elementX, elementY) ( clientX, clientY ) =
    let
        zoomRecord =
            Zoom.asRecord zoom
    in
    ( (clientX - zoomRecord.translate.x - elementX) / zoomRecord.scale
    , (clientY - zoomRecord.translate.y - elementY) / zoomRecord.scale
    )

viewConfig : ViewConfig Msg
viewConfig =
    createViewConfig
        { toMsg = PaneMsg
        , customSplitter = Nothing
        }

svgView : Root -> Html Msg
svgView model =
    let
        selectItemsEvents : Attribute Msg
        selectItemsEvents = 
            mouseDownMain SelectItemsStart

        gridRectEvents : List (Attribute Msg)
        gridRectEvents =
            case model of
                Init ->
                    []

                Ready { zoom, panMode } ->
                    [Zoom.onDoubleClick zoom ZoomMsg, Zoom.onWheel zoom ZoomMsg] 
                        ++ (if panMode then Zoom.onDrag zoom ZoomMsg else [selectItemsEvents])

        zoomTransformAttr : Attribute Msg
        zoomTransformAttr =
            case model of
                Init ->
                    class []

                Ready { zoom } ->
                    Zoom.transform zoom

        transform10 = 
            case model of
                Init -> gridCellSize
                Ready { zoom } ->
                    zoom |> Zoom.asRecord |> .scale |> (*) 10

        transform100 = transform10 * 10

        getXY =
            case model of
                Init -> ( 0, 0 )
                Ready { zoom } ->
                    zoom
                        |> Zoom.asRecord
                        |> .translate
                        |> (\t -> (floatRemainderBy transform100 t.x, floatRemainderBy transform100 t.y))

        ( x, y ) = getXY
    in
    svg
        [ id elementId
        , Attrs.width <| Percent 100
        , Attrs.height <| Percent 100
        -- TODO Disable right click menu
        , Mouse.onContextMenu (\_ -> NoOp)
        ]
        [ defs []
            [ innerGrid transform10
            , grid x y transform100
            , markerDot -- for circle in edges
            ]
        , gridRect gridRectEvents
        , g
            [ zoomTransformAttr ]
            [ renderCurrentView model
            ]
        ]


-- Grid comes from https://gist.github.com/leonardfischer/fc4d1086c64b2c1324c93dcd0beed004


renderCurrentView : Root -> Svg Msg
renderCurrentView model =
    case model of
        Init ->
            text ""

        Ready { drag, views, selectedView, panMode } ->
            case getCurrentView selectedView views of
                Just v ->
                    g []
                        [ getEdges v
                            -- |> Debug.todo "called at each rendering and can be cashed?"
                            |> List.map
                                (\edge ->
                                    let
                                        viewRelationKey = Tuple.pair edge.source.name (edge.target.name, edge.description)
                                    in
                                    case drag of
                                        Just { selectedItems } ->
                                            let
                                                selectedPoints = getSelectedPointKeysAndDeltas selectedItems
                                                    |> List.map Tuple.first

                                                selectedPointIndexes = selectedPoints
                                                    |> List.filterMap (\(viewElementKey, relation, viewRelationPointIndex) ->
                                                        let
                                                            targetName = Tuple.first relation
                                                            descriptionOfRelation = Tuple.second relation
                                                        in
                                                        if edge.source.name == viewElementKey && edge.target.name == targetName && edge.description == descriptionOfRelation then
                                                            Just viewRelationPointIndex
                                                        else
                                                            Nothing
                                                    )
                                            in
                                            linkElement panMode viewRelationKey selectedPointIndexes edge

                                        Nothing ->
                                            linkElement panMode viewRelationKey [] edge
                                )
                            |> g [ class [ "links" ] ]
                        , getContainers v
                            |> List.map (drawContainer panMode drag)
                            |> g [ class [ "nodes" ] ]
                        ]
                Nothing -> text ""

drawContainer : Bool -> Maybe Drag -> Container -> Svg Msg
drawContainer panMode drag container =
    let
        mouseDownAttr =
            if panMode then
                Nothing
            else
                Just <| mouseDownMain (DragViewElementStart container.name)
    in
    case drag of
        Just { selectedItems } ->
            let
                selectedElements = getSelectedElementKeysAndDeltas selectedItems
                    |> List.map Tuple.first
            in
            if List.member container.name selectedElements then
                renderContainerSelected container mouseDownAttr
            else
                renderContainer container mouseDownAttr
        Nothing ->
            renderContainer container mouseDownAttr


getSelectedElementKeysAndDeltas : List SelectedItem -> List (ViewElementKey, (Float, Float))
getSelectedElementKeysAndDeltas =
    let
        extractViewElelementKeys v = 
            case v.key of
                ElementKey x -> Just (x, v.delta)
                PointKey _ -> Nothing
    in
    List.filterMap extractViewElelementKeys

getSelectedPointKeysAndDeltas : List SelectedItem -> List (ViewRelationPointKey, (Float, Float))
getSelectedPointKeysAndDeltas =
    let
        extractPointKeys v = 
            case v.key of
                PointKey x -> Just (x, v.delta)
                ElementKey _ -> Nothing
    in
    List.filterMap extractPointKeys

linkElement : Bool -> ViewRelationKey -> List Int -> Edge -> Svg Msg
linkElement panMode viewRelationKey selectedIndexes edge =
    edgeBetweenContainers
        edge
        selectedIndexes
        (noOpIfPanMode panMode <| mouseDownMain (ClickEdgeStart viewRelationKey))
        (if panMode then Nothing else Just (onMouseDownPoint viewRelationKey))


noOpIfPanMode : Bool -> Attribute Msg -> Maybe (Attribute Msg)
noOpIfPanMode panMode ev =
    if panMode then
        Nothing
    else
        Just ev

onlyMainButton : Event -> Maybe (Float, Float)
onlyMainButton e =
    case e.button of
        Mouse.MainButton -> Just e.clientPos
        _ -> Nothing

mouseDownMain : ((Float, Float) -> Msg) -> Attribute Msg
mouseDownMain msg =
    Mouse.onDown <|
        onlyMainButton
        >> Maybe.map msg
        >> Maybe.withDefault NoOp

onMouseDownPoint : ViewRelationKey -> Int -> Attribute Msg
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
