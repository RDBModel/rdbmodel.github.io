module Main exposing (..)

import Browser exposing (element)
import IntDict
import Browser.Dom as Dom
import Basics.Extra exposing (maxSafeInteger)
import Browser.Events as Events
import Color
import Json.Decode as Decode
import Path exposing (Path)
import SubPath exposing (SubPath)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Html.Events.Extra.Mouse as Mouse
import TypedSvg exposing (rect, svg, defs, marker, polygon, g, pattern, line, circle)
import TypedSvg.Attributes as Attrs exposing
    ( height, width, class, cursor, x, y, cx, cy, fill, r, points, id, orient, markerWidth, markerHeight, refX, refY
    , strokeWidth, rx, x1, y1, x2, y2, stroke, markerEnd, transform)
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
import Math.Vector2 as Vec
import TypedSvg.Attributes exposing (strokeOpacity)
import TypedSvg.Attributes exposing (offset)

main : Program () Model Msg
main =
  Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }

type Model
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

    -- If you immediately show the graph when moving from `Init` to `Ready`,
    -- you will briefly see the nodes in the upper left corner before the first
    -- simulation tick positions them in the center. To avoid this sudden jump,
    -- `showGraph` is initialized with `False` and set to `True` with the first
    -- `Tick`.
    , showGraph : Bool
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
    | NoOp

elementId : String
elementId =
    "exercise-graph"

getElementPosition : Cmd Msg
getElementPosition =
    Task.attempt ReceiveElementPosition (Dom.getElement elementId)

init : () -> ( Model, Cmd Msg )
init _ =
    ( Init (Graph.fromNodesAndEdges
            [ Node 0 <| Container "" (150, 125)
            , Node 1 <| Container "" (550, 125)
            ]
            [ Edge 0 1 <| SubPathEdge [(350, 150)]
            ]), getElementPosition )

subscriptions : Model -> Sub Msg
subscriptions model =
    let
        dragSubscriptions : Sub Msg
        dragSubscriptions =
            Sub.batch
                [ Events.onMouseMove
                    (Decode.map (.offsetPos >> DragAt) Mouse.eventDecoder)
                , Events.onMouseUp
                    (Decode.map (.offsetPos >> DragEnd) Mouse.eventDecoder)
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
        [ case model of
            Init _ ->
                Sub.none

            Ready state ->
                readySubscriptions state
        , Events.onResize Resize
        ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case ( msg, model ) of
    ( Resize _ _, _ ) ->
            ( model, getElementPosition )

    ( ZoomMsg zoomMsg, Ready state ) ->
        ( Ready { state | zoom = Zoom.update zoomMsg state.zoom }
        , Cmd.none
        )

    ( ZoomMsg _, Init _ ) ->
        ( model, Cmd.none )

    ( ReceiveElementPosition (Ok { element }), Init graph ) ->
        -- When we get the svg element position and dimensions, we are
        -- ready to initialize the simulation and the zoom, but we cannot
        -- show the graph yet. If we did, we would see a noticable jump.
        ( Ready
            { drag = Nothing
            , pointDrag = Nothing
            , element = element
            , graph = graph
            , showGraph = True
            , zoom = initZoom element
            }
        , Cmd.none
        )

    ( ReceiveElementPosition (Ok { element }), Ready state ) ->
        ( Ready
            { drag = Nothing
            , pointDrag = Nothing
            , element = element
            , graph = state.graph
            , showGraph = True
            , zoom = initZoom element
            }
        , Cmd.none
        )

    ( ReceiveElementPosition (Err _), _ ) ->
        ( model, Cmd.none )

    ( DragStart index xy, Ready state ) ->
        let
            nodeCtx = Graph.get index state.graph

            (shiftedStartX, shiftedStartY) = shiftPosition state.zoom xy

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
        ( Ready
            { state
                | drag =
                    Just
                        { start = xy
                        , current = xy
                        , index = index
                        , delta = delta
                        }
            }
        , Cmd.none
        )

    ( DragPointStart index edge xy, Ready state ) ->
        let
            points = edge.label.points

            targetPoint = List.drop index points |> List.head

            (shiftedStartX, shiftedStartY) = shiftPosition state.zoom xy

            delta =
                case targetPoint of
                    Just (x, y) ->
                        ( shiftedStartX - x
                        , shiftedStartY - y
                        )

                    Nothing ->
                        (0, 0)
        in
        ( Ready
            { state
                | pointDrag =
                    Just
                        { start = xy
                        , current = xy
                        , index = (edge.from, edge.to, index)
                        , delta = delta
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
        ( Ready { state | graph = updatedGraph }, Cmd.none )

    (RemovePoint _ _, Init _ ) ->
        ( model, Cmd.none )

    ( DragStart _ _, Init _ ) ->
        ( model, Cmd.none )

    ( DragPointStart _ _ _, Init _ ) ->
        ( model, Cmd.none )

    ( DragSubPathStart edge xy, Ready state ) ->
        let
            spxy = shiftPosition state.zoom xy
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
                        |> Debug.log "updated"
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
                ( Ready { state | graph = updatedGraph }, Cmd.none )
            _ -> ( model, Cmd.none )

    ( DragSubPathStart _ _, Init _ ) ->
        ( model, Cmd.none )

    ( DragAt xy, Ready state ) ->
        handleDragAt xy state

    ( DragAt _, Init _ ) ->
        ( model, Cmd.none )

    ( DragEnd xy, Ready state ) ->
        case (state.drag, state.pointDrag) of
            (Just _, Nothing) ->
                ( Ready { state| drag = Nothing }, Cmd.none)
            (Nothing, Just _) ->
                ( Ready
                    { state | pointDrag = Nothing }, Cmd.none)
            _ ->
                ( Ready state, Cmd.none )

    ( DragEnd _, Init _ ) ->
        ( model, Cmd.none )

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


handleDragAt : ( Float, Float ) -> ReadyState -> ( Model, Cmd Msg )
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
        updatedEdges =
            IntDict.update nodeId
                (Maybe.map
                    (\spe ->
                        let
                            updateXy i currentXY =
                                if i == index then
                                    (x - dx, y - dy)
                                else
                                    currentXY
                        in
                        { spe | points = List.indexedMap updateXy spe.points }
                    )
                )
    in
    nodeCtx.outgoing |> updatedEdges |> updateContextWithOutgoing nodeCtx


updateNode : ( Float, Float ) -> ( Float, Float ) -> NodeContext Container SubPathEdge -> NodeContext Container SubPathEdge
updateNode (dx, dy) ( x, y ) nodeCtx =
    let
        nodeValue =
            nodeCtx.node.label
    in
    updateContextWithValue nodeCtx {nodeValue | xy = (x - dx, y - dy)}

updateContextWithOutgoing : NodeContext Container SubPathEdge -> (Adjacency SubPathEdge) -> NodeContext Container SubPathEdge
updateContextWithOutgoing nodeCtx value =
    let
        node =
            nodeCtx.node
    in
    { nodeCtx | outgoing = value }

updateContextWithValue : NodeContext Container SubPathEdge -> Container -> NodeContext Container SubPathEdge
updateContextWithValue nodeCtx value =
    let
        node =
            nodeCtx.node
    in
    { nodeCtx | node = { node | label = value } }


{-| The mouse events for drag start, drag at and drag end read the client
position of the cursor, which is relative to the browser viewport. However,
the node positions are relative to the svg viewport. This function adjusts the
coordinates accordingly. It also takes the current zoom level and position
into consideration.
-}
shiftPosition : Zoom -> ( Float, Float ) -> ( Float, Float )
shiftPosition zoom ( clientX, clientY ) =
    let
        zoomRecord =
            Zoom.asRecord zoom
    in
    ( (clientX - zoomRecord.translate.x) / zoomRecord.scale
    , (clientY - zoomRecord.translate.y) / zoomRecord.scale
    )


type XY
    = X
    | Y

view : Model -> Html Msg
view model =
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

        getXY xy =
            case model of
                Init _ -> 0
                Ready { zoom } ->
                    zoom
                        |> Zoom.asRecord
                        |> .translate
                        |> (\t -> case xy of
                                X -> t.x
                                Y -> t.y
                            )
                        |> floatRemainderBy transform100

        x = getXY X

        y = getXY Y
    in
    div []
        [ svg
            [ id elementId
            , Attrs.width <| Percent 100
            , Attrs.height <| Percent 100
            , Mouse.onContextMenu (\e -> NoOp)
            ]
            [ defs []
                [ innerGrid transform10
                , grid x y transform100
                , markerDot -- for circle in edges
                ]
            , rect
                ([ Attrs.width <| Percent 100
                , Attrs.height <| Percent 100
                , fill <| Reference gridId
                --, cursor CursorMove
                ] ++ zoomEvents) []
            , g
                [ zoomTransformAttr ]
                [ renderGraph model
                ]
            ]
        , monaco [] []
        ]

pointDotId : String
pointDotId = "dot"

markerDot : Svg msg
markerDot =
    marker
        [ id pointDotId
        , Attrs.refX "5"
        , Attrs.refY "5"
        , Attrs.markerWidth <| Px 10
        , Attrs.markerHeight <| Px 10
        ]
        [
            circle
                [ cx <| Px 5
                , cy <| Px 5
                , r <| Px 3
                , Attrs.fill <| Paint <| Color.white
                , Attrs.stroke <| Paint <| Color.black
                , Attrs.strokeWidth <| Px 1
                ]
                []
        ]

innerGridId : String
innerGridId = "inner-grid"


innerGrid : Float -> Svg msg
innerGrid size =
    pattern
        [ id innerGridId
        , Attrs.width <| Px size
        , Attrs.height <| Px size
        , Attrs.patternUnits CoordinateSystemUserSpaceOnUse
        ]
        [
            rect
            [ Attrs.width <| Percent 100
            , Attrs.height <| Percent 100
            , Attrs.fill PaintNone
            , Attrs.stroke <| Paint <| Color.rgb255 204 204 204
            , strokeWidth <| Px 0.5
            ]
            []
        ]


-- Grid comes from https://gist.github.com/leonardfischer/fc4d1086c64b2c1324c93dcd0beed004
gridId : String
gridId = "grid"

grid : Float -> Float -> Float -> Svg msg
grid x y size =
    pattern
        [ id gridId
        , Attrs.width <| Px size
        , Attrs.height <| Px size
        , Attrs.x <| Px x
        , Attrs.y <| Px y
        , Attrs.patternUnits CoordinateSystemUserSpaceOnUse
        ]
        [
            rect
            [ Attrs.width <| Percent 100
            , Attrs.height <| Percent 100
            , Attrs.fill <| Reference innerGridId
            , Attrs.stroke <| Paint <| Color.rgb255 204 204 204
            , strokeWidth <| Px 1.5
            ]
            []
        ]

renderGraph : Model -> Svg Msg
renderGraph model =
    case model of
        Init _ ->
            text ""

        Ready { drag, pointDrag, graph, showGraph } ->
            if showGraph then
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
                        |> List.map (\n -> 
                            case drag of
                                Just { index } ->
                                    nodeElement (index == n.id) n
                                Nothing ->
                                    nodeElement False n
                        )
                        |> g [ class [ "nodes" ] ]
                    ]

            else
                text ""


nodeElement : Bool -> Node Container -> Svg Msg
nodeElement selected node =
    let
        (x , y) = node.label.xy
    in
    renderContainer node.id selected x y

linkElement : Maybe Int -> Graph Container SubPathEdge -> Edge SubPathEdge -> Svg Msg
linkElement selectedIndex graph edge =
    let
        (source, target) = (Graph.get edge.from graph, Graph.get edge.to graph)
    in
    case (source, target) of
        (Just sourceNode, Just targetNode) ->
            let
                points = edge.label.points
                (sx, sy) = sourceNode.node.label.xy
                (tx, ty) = targetNode.node.label.xy

                (cx, cy) = points
                    |> List.reverse
                    |> List.head
                    |> Maybe.withDefault sourceNode.node.label.xy

                preparedPoints = (sx, sy) :: points ++ [ (tx, ty) ]
                curve = linearCurve preparedPoints

                -- half of rect
                (rx, ry) = (containerWidth / 2, containerHeight / 2)

                -- size of sides of big triangle create by dots
                (x, y) = ((cx - tx) |> abs, (cy - ty) |> abs)

                -- if the line crosses the rect in the top or bottom
                -- otherwise it crosses left or right borders or rect
                topBottom = y / x > ry / rx

                -- distance between start and end dots
                distanceXY = sqrt (x * x + y * y)

                -- magic offset for ➤ symbol
                magicOffset = 9

                curveLength = curve |> arcLengthParameterized 1e-4 |> arcLength

                -- offset based on aspect ratio
                offset =
                    let
                        temp = if topBottom then ry / y else rx / x
                    in
                    curveLength - distanceXY * temp - magicOffset

                idValue =
                    "from-" ++ String.fromInt (sourceNode.node.id) ++ "-to-" ++ String.fromInt (targetNode.node.id)

                strokeWidthValue = 1
            in
                g []
                    [ SubPath.element curve
                            [ id idValue
                            , strokeWidth <| Px strokeWidthValue
                            , stroke <| Paint <| Color.black
                            , fill <| PaintNone
                            ]
                    , SubPath.element curve
                            [ strokeWidth <| Px (strokeWidthValue + edgeStrokeWidthExtend)
                            , stroke <| Paint <| Color.black
                            , strokeOpacity <| Opacity 0
                            , fill <| PaintNone
                            , Mouse.onDown (.offsetPos >> DragSubPathStart edge)
                            ]
                    , TypedSvg.text_ []
                        [
                            TypedSvg.textPath
                                [ Attrs.xlinkHref ("#" ++ idValue)
                                , Attrs.startOffset <| String.fromFloat offset
                                , Attrs.dominantBaseline DominantBaselineCentral
                                , Attrs.fontSize <| Px 10
                                , Attrs.style "user-select: none;" --forbid to select arrow as text
                                ]
                                [ text "➤" ]
                        ]
                    , g [] <| List.indexedMap
                        (\i -> \(dx, dy ) ->
                            Path.element circleDot
                                [ fill (Paint Color.white)
                                , stroke (Paint <| case selectedIndex of
                                    Just ind ->
                                        if ind == i then Color.blue else Color.black
                                    Nothing -> Color.black
                                )
                                , transform [ Translate dx dy ]
                                , onMouseDownPoint i edge
                                ]) points

                    ]
        _ -> text ""

circleDot : Path
circleDot =
    Shape.arc
        { innerRadius = 0
        , outerRadius = 3
        , cornerRadius = 0
        , startAngle = 0
        , endAngle = 2 * pi
        , padAngle = 0
        , padRadius = 0
        }

edgeStrokeWidthExtend = 3

onMouseDownPoint : Int -> Edge SubPathEdge -> Attribute Msg
onMouseDownPoint index edge =
    Mouse.onDown
        (\e ->
            case e.button of
                Mouse.MainButton -> DragPointStart index edge e.offsetPos
                Mouse.SecondButton -> RemovePoint index edge
                _ -> NoOp
        )


edgeColor : Paint
edgeColor =
    Paint <| Color.rgb255 180 180 180


containerWidth : Float
containerWidth = 100
containerHeight : Float
containerHeight = 50
containerRadius : Float
containerRadius = 0
systemRadius : Float
systemRadius = 50
gridCellSize : Float
gridCellSize = 10

renderContainer : NodeId -> Bool -> Float -> Float -> Svg Msg
renderContainer nodeId selected xCenter yCenter = 
    rect
        [ x <| Px <| xCenter - containerWidth / 2
        , y <| Px <| yCenter - containerHeight / 2
        , width <| Px containerWidth
        , height <| Px containerHeight
        , rx <| Px containerRadius
        , Attrs.fill <| Paint <| Color.white
        , Attrs.stroke <| Paint <| if selected then Color.blue else Color.black
        , Attrs.strokeWidth <| Px 1
        , Mouse.onDown (.offsetPos >> DragStart nodeId)
        ] []


renderSystem : Float -> Float -> Svg Msg
renderSystem xValue yValue = 
    circle
        [ cx <| Px xValue
        , cy <| Px yValue
        , r <| Px systemRadius
        , Attrs.fill <| Paint <| Color.white
        , Attrs.stroke <| Paint <| Color.black
        , Attrs.strokeWidth <| Px 1
        ] []


monaco : List (Attribute a) -> List (Html a) -> Html a
monaco =
    Html.node "wc-monaco-editor"
