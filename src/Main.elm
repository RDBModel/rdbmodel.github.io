port module Main exposing (..)

import Browser exposing (element)
import IntDict
import SplitPane exposing (Orientation(..), ViewConfig, createViewConfig)
import Browser.Dom as Dom
import Basics.Extra exposing (maxSafeInteger)
import Browser.Events as Events
import Json.Decode as Decode
import Html exposing (Html, button, div, text)
import Html.Events.Extra.Mouse as Mouse
import TypedSvg exposing (svg, defs, g)
import TypedSvg.Attributes as Attrs exposing
    ( class,  x, y, points, id, x1, y1, x2, y2)
import TypedSvg.Types exposing
    ( CoordinateSystem(..), Transform(..), Opacity(..), Paint(..), Length(..)
    , Cursor(..), DominantBaseline(..))
import TypedSvg.Core exposing (Svg, Attribute)
import Graph exposing (Graph, Node, Edge, NodeContext, NodeId, Adjacency)
import Zoom exposing (Zoom, OnZoom)
import Task
import Html exposing (source)
import Shape exposing (linearCurve)
import SubPath exposing (arcLengthParameterized)
import SubPath exposing (arcLength)
import TypedSvg.Attributes exposing (strokeOpacity)
import TypedSvg.Attributes exposing (offset)
import Html.Attributes
import Elements exposing
    ( containerWidth, containerHeight, renderContainer, renderContainerSelected, circleDot
    , markerDot, innerGrid, grid, gridRect, edgeBetweenContainers, edgeStrokeWidthExtend, gridCellSize
    )
import Html.Events.Extra.Mouse exposing (Event)

port messageReceiver : (String -> msg) -> Sub msg

port sendMessage : String -> Cmd msg

main : Program () Model Msg
main =
  Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }

type alias Model =
    { pane : SplitPane.State
    , graph : GraphModel
    , value : String
    }
    
type GraphModel
    = Init (Graph Container SubPathEdge)
    | Ready ReadyState

type alias Container =
    { name : String
    , xy : (Float, Float)
    }

type alias SubPathEdge = 
    { points : List (Float, Float)
    }

type alias ReadyState =
    { drag : Maybe (Drag NodeId)
    , pointDrag : Maybe (Drag (NodeId, NodeId, Int))
    , graph : Graph Container SubPathEdge
    , zoom : Zoom

    -- The position and dimensions of the svg element.
    , element : Element
    }

-- Select information
type alias Drag a =
    { current : ( Float, Float ) -- current mouse position
    , index : a -- selected node id orpoint index
    , start : ( Float, Float ) -- start mouse position
    , delta : ( Float, Float ) -- delta between start and node center to do ajustment during movement
    }


-- SVG element position and size in DOM
type alias Element =
    { height : Float
    , width : Float
    , x : Float
    , y : Float
    }


type Msg
    = ZoomMsg OnZoom
    | Resize Int Int
    | ReceiveElementPosition (Result Dom.Error Dom.Element)
    | DragStart NodeId ( Float, Float )
    | DragSubPathStart (Edge SubPathEdge) ( Float, Float )
    | DragPointStart Int (Edge SubPathEdge) ( Float, Float )
    | RemovePoint Int (Edge SubPathEdge)
    | DragAt ( Float, Float )
    | DragEnd ( Float, Float )
    | PaneMsg SplitPane.Msg
    | MonacoEditorValueChanged String
    | MonacoSendValue String
    | NoOp

elementId : String
elementId =
    "main-graph"

getElementPosition : Cmd Msg
getElementPosition =
    Task.attempt ReceiveElementPosition (Dom.getElement elementId)

init : () -> ( Model, Cmd Msg )
init _ =
    let
        splitPanelState = SplitPane.init Horizontal
        initModel = Init
            <| Graph.fromNodesAndEdges
                [ Node 0 <| Container "" (150, 125)
                , Node 1 <| Container "" (550, 125)
                ]
                [ Edge 0 1 <| SubPathEdge [(350, 150)]
                ]
    in
    (Model splitPanelState initModel "", getElementPosition)

subscriptions : Model -> Sub Msg
subscriptions model =
    let
        dragSubscriptions : Sub Msg
        dragSubscriptions =
            Sub.batch
                [ Events.onMouseMove
                    (Decode.map (.clientPos >> DragAt) Mouse.eventDecoder)
                , Events.onMouseUp
                    (Decode.map (.clientPos >> DragEnd) Mouse.eventDecoder)
                ]

        readySubscriptions : ReadyState -> Sub Msg
        readySubscriptions { drag, pointDrag, zoom } =
            Sub.batch
                [ Zoom.subscriptions zoom ZoomMsg
                , case (drag, pointDrag) of
                    (Just _, Nothing) ->
                        dragSubscriptions

                    (Nothing, Just _) ->
                        dragSubscriptions

                    _ ->
                        Sub.none
                ]
    in
    Sub.batch
        [ case model.graph of
            Init _ ->
                Sub.none

            Ready state ->
                readySubscriptions state
        , Events.onResize Resize
        , Sub.map PaneMsg <| SplitPane.subscriptions model.pane
        , messageReceiver MonacoEditorValueChanged
        ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.graph ) of
        ( MonacoEditorValueChanged val, _) ->
            ( { model | value = val }, Cmd.none )

        ( MonacoSendValue val, _) ->
            ( model, sendMessage val )

        ( Resize _ _, _ ) ->
                ( model, getElementPosition )

        ( ZoomMsg zoomMsg, Ready state ) ->
            ( { model | graph = Ready { state | zoom = Zoom.update zoomMsg state.zoom } }
            , Cmd.none
            )

        ( ZoomMsg _, Init _ ) ->
            ( model, Cmd.none )

        ( ReceiveElementPosition (Ok { element }), _ ) ->
            let
                extractGraph = case model.graph of
                    Init gr -> gr
                    Ready { graph } -> graph
            in
            ( { model | graph = Ready
                { drag = Nothing
                , pointDrag = Nothing
                , element = element
                , graph = extractGraph
                , zoom = initZoom element
                }
            }
            , Cmd.none
            )

        ( ReceiveElementPosition (Err _), _ ) ->
            ( model, Cmd.none )

        ( DragStart index xy, Ready state ) ->
            let
                nodeCtx = Graph.get index state.graph

                (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.element.x, state.element.y) xy

                delta =
                    case nodeCtx of
                        Just ctx ->
                            let
                                (x, y) = ctx.node.label.xy
                            in
                            ( shiftedStartX - x
                            , shiftedStartY - y
                            )

                        Nothing ->
                            (0, 0)
            in
            ( { model | graph = Ready
                { state
                    | drag =
                        Just
                            { start = xy
                            , current = xy
                            , index = index
                            , delta = delta
                            }
                }
            }
            , Cmd.none
            )

        ( DragPointStart index edge xy, Ready state ) ->
            let
                points = edge.label.points

                targetPoint = List.drop index points |> List.head

                (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.element.x, state.element.y) xy

                delta =
                    case targetPoint of
                        Just (x, y) ->
                            ( shiftedStartX - x
                            , shiftedStartY - y
                            )

                        Nothing ->
                            (0, 0)
            in
            ( { model | graph = Ready
                { state
                    | pointDrag =
                        Just
                            { start = xy
                            , current = xy
                            , index = (edge.from, edge.to, index)
                            , delta = delta
                            }
                }
            }
            , Cmd.none
            )

        (RemovePoint index edge, Ready state ) ->
            let
                updatedGraph = Graph.mapEdges
                    (\e ->
                        if e == edge.label then
                            let
                                updatedList =
                                    List.take index e.points
                                    ++
                                    List.drop (index + 1) e.points
                            in
                            SubPathEdge updatedList
                        else
                            e
                    )
                    state.graph

            in
            ( { model | graph = Ready { state | graph = updatedGraph } }, Cmd.none )

        (RemovePoint _ _, Init _ ) ->
            ( model, Cmd.none )

        ( DragStart _ _, Init _ ) ->
            ( model, Cmd.none )

        ( DragPointStart _ _ _, Init _ ) ->
            ( model, Cmd.none )

        ( DragSubPathStart edge xy, Ready state ) ->
            let
                spxy = shiftPosition state.zoom (state.element.x, state.element.y) xy
                sourceXY = Graph.get edge.from state.graph |> Maybe.map (\ctx -> ctx.node.label.xy)
                targetXY = Graph.get edge.to state.graph |> Maybe.map (\ctx -> ctx.node.label.xy)
            in
            case (sourceXY, targetXY) of
                (Just sxy, Just txy) ->
                    let
                        magicIntMax = maxSafeInteger
                        allPoints = sxy :: edge.label.points ++ [ txy ]

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

                        updatedList = List.foldr
                            (\a -> \b ->
                                if insertAfterValue == a then
                                    a :: spxy :: b
                                else
                                    a :: b
                            )
                            []
                            allPoints
                            |> List.drop 1
                            |> List.reverse
                            |> List.drop 1
                            |> List.reverse

                        updatedGraph = Graph.mapEdges
                            (\e ->
                                if e == edge.label then
                                    SubPathEdge updatedList
                                else
                                    e
                            )
                            state.graph

                    in
                    ( { model | graph = Ready { state | graph = updatedGraph } }, Cmd.none )
                _ -> ( model, Cmd.none )

        ( DragSubPathStart _ _, Init _ ) ->
            ( model, Cmd.none )

        ( DragAt xy, Ready state ) ->
            let
                (updateGraphModel, cmdMsg) = handleDragAt xy state
            in
            ( { model | graph = updateGraphModel }, cmdMsg)

        ( DragAt _, Init _ ) ->
            ( model, Cmd.none )

        ( DragEnd _, Ready state ) ->
            case (state.drag, state.pointDrag) of
                (Just _, Nothing) ->
                    ( { model | graph = Ready { state| drag = Nothing } }, Cmd.none)
                (Nothing, Just _) ->
                    ( { model | graph = Ready { state | pointDrag = Nothing } }, Cmd.none)
                _ ->
                    ( { model | graph = Ready state }, Cmd.none )

        ( DragEnd _, Init _ ) ->
            ( model, Cmd.none )

        (PaneMsg paneMsg, _ ) ->
            ( { model | pane = SplitPane.update paneMsg model.pane }, Cmd.none )

        ( NoOp, _) -> ( model, Cmd.none )

{-| is it enough to put the point
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


handleDragAt : ( Float, Float ) -> ReadyState -> ( GraphModel, Cmd Msg )
handleDragAt xy ({ drag, pointDrag } as state) =
    case (drag, pointDrag) of
        (Just { start, index, delta }, Nothing) ->
            ( Ready
                { state
                    | drag =
                        Just
                            { start = start
                            , current = xy
                            , index = index
                            , delta = delta
                            }
                    , graph = updateNodePosition delta index xy state
                }
            , Cmd.none
            )

        (Nothing, Just { start, index, delta }) ->
            ( Ready
                { state
                    | pointDrag =
                        Just
                            { start = start
                            , current = xy
                            , index = index
                            , delta = delta
                            }
                    , graph = updatePointPosition delta index xy state
                }
            , Cmd.none
            )

        _ ->
            ( Ready state, Cmd.none )


updatePointPosition : (Float, Float) -> (NodeId, NodeId, Int) -> ( Float, Float ) -> ReadyState -> Graph Container SubPathEdge
updatePointPosition delta (fromId, toId, index) xy state =
    state.graph
        |> Graph.update
            fromId
            (Maybe.map (
                \nodeCtx ->
                    (updateOutgoingEdges
                        (toId, index)
                        delta
                        (shiftPosition
                            state.zoom
                            (state.element.x, state.element.y)
                            xy
                        )
                        nodeCtx
                    )
                )
            )

updateNodePosition : (Float, Float) -> NodeId -> ( Float, Float ) -> ReadyState -> Graph Container SubPathEdge
updateNodePosition delta index xy state =
    Graph.update
        index
        (Maybe.map (
            \nodeCtx ->
                (updateNode
                    delta
                    (shiftPosition
                        state.zoom
                        (state.element.x, state.element.y)
                        xy
                    )
                    nodeCtx
                )
            )
        )
        state.graph


updateOutgoingEdges : (NodeId, Int) -> ( Float, Float ) -> ( Float, Float ) -> NodeContext Container SubPathEdge -> NodeContext Container SubPathEdge
updateOutgoingEdges (nodeId, index) (dx, dy) ( x, y ) nodeCtx =
    let
        updateXY i currentXY =
            if i == index then
                (x - dx, y - dy)
            else
                currentXY

        updateEdgePoints spe = { spe | points = List.indexedMap updateXY spe.points }

        updatedEdges =  IntDict.update nodeId ( Maybe.map updateEdgePoints )
    in
    nodeCtx.outgoing |> updatedEdges |> updateContextWithOutgoing nodeCtx


updateNode : ( Float, Float ) -> ( Float, Float ) -> NodeContext Container SubPathEdge -> NodeContext Container SubPathEdge
updateNode (dx, dy) ( x, y ) nodeCtx =
    let
        nodeValue = nodeCtx.node.label
    in
    updateContextWithValue nodeCtx { nodeValue | xy = (x - dx, y - dy) }

updateContextWithOutgoing : NodeContext Container SubPathEdge -> (Adjacency SubPathEdge) -> NodeContext Container SubPathEdge
updateContextWithOutgoing nodeCtx value =
    { nodeCtx | outgoing = value }

updateContextWithValue : NodeContext Container SubPathEdge -> Container -> NodeContext Container SubPathEdge
updateContextWithValue nodeCtx value =
    let
        node = nodeCtx.node
    in
    { nodeCtx | node = { node | label = value } }


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


view : Model -> Html Msg
view { pane, graph } =
    div []
        [ SplitPane.view
            viewConfig
            (svgView graph)
            (div [ id "monaco", Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%"] [])
            pane
        ]

viewConfig : ViewConfig Msg
viewConfig =
    createViewConfig
        { toMsg = PaneMsg
        , customSplitter = Nothing
        }

svgView : GraphModel -> Html Msg
svgView model =
    let
        zoomEvents : List (Attribute Msg)
        zoomEvents =
            case model of
                Init _ ->
                    []

                Ready { zoom } ->
                    Zoom.events zoom ZoomMsg
        zoomTransformAttr : Attribute Msg
        zoomTransformAttr =
            case model of
                Init _ ->
                    class []

                Ready { zoom } ->
                    Zoom.transform zoom

        transform10 = 
            case model of
                Init _ -> gridCellSize
                Ready { zoom } ->
                    zoom |> Zoom.asRecord |> .scale |> (*) 10

        transform100 = transform10 * 10

        getXY =
            case model of
                Init _ -> ( 0, 0 )
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
        , Mouse.onContextMenu (\_ -> NoOp)
        ]
        [ defs []
            [ innerGrid transform10
            , grid x y transform100
            , markerDot -- for circle in edges
            ]
        , gridRect zoomEvents
        , g
            [ zoomTransformAttr ]
            [ renderGraph model
            ]
        ]


-- Grid comes from https://gist.github.com/leonardfischer/fc4d1086c64b2c1324c93dcd0beed004


renderGraph : GraphModel -> Svg Msg
renderGraph model =
    case model of
        Init _ ->
            text ""

        Ready { drag, pointDrag, graph } ->
            g []
                [ Graph.edges graph
                    |> List.map
                        (\e ->
                            case pointDrag of
                                Just { index } ->
                                    let
                                        (from, to, i) = index
                                    in
                                    if e.to == to && e.from == from then
                                        linkElement (Just i) graph e
                                    else
                                        linkElement Nothing graph e
                                Nothing ->
                                    linkElement Nothing graph e
                        )
                    |> g [ class [ "links" ] ]
                , Graph.nodes graph
                    |> List.map (drawContainer drag)
                    |> g [ class [ "nodes" ] ]
                ]


drawContainer : Maybe (Drag NodeId) -> { id : NodeId, label : { name : String, xy : (Float, Float) } } -> Svg Msg
drawContainer drag n =
    let
        mouseDownAttr
            = Mouse.onDown
            <| onlyMainButton
            >> Maybe.map (DragStart n.id)
            >> Maybe.withDefault NoOp
    in
    case drag of
        Just { index } ->
            if index == n.id then
                renderContainerSelected n.label.xy mouseDownAttr
            else
                renderContainer n.label.xy mouseDownAttr
        Nothing ->
            renderContainer n.label.xy mouseDownAttr


linkElement : Maybe Int -> Graph Container SubPathEdge -> Edge SubPathEdge -> Svg Msg
linkElement selectedIndex graph edge =
    let
        (source, target) = (Graph.get edge.from graph, Graph.get edge.to graph)
    in
    case (source, target) of
        (Just sourceNode, Just targetNode) ->
            edgeBetweenContainers
                (sourceNode, targetNode, edge)
                selectedIndex
                (Mouse.onDown <| onlyMainButton >> Maybe.map (DragSubPathStart edge) >> Maybe.withDefault NoOp)
                (onMouseDownPoint edge)
        _ -> text ""


onlyMainButton : Event -> Maybe (Float, Float)
onlyMainButton e =
    case e.button of
        Mouse.MainButton -> Just e.clientPos
        _ -> Nothing


onMouseDownPoint : Edge SubPathEdge -> Int -> Attribute Msg
onMouseDownPoint edge index =
    Mouse.onDown
        (\e ->
            case e.button of
                Mouse.MainButton -> DragPointStart index edge e.clientPos
                Mouse.SecondButton -> RemovePoint index edge
                _ -> NoOp
        )
