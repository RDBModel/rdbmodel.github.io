module Main exposing (..)

import Browser exposing (element)
import Browser.Dom as Dom
import Browser.Events as Events
import Color
import Json.Decode as Decode
import SubPath exposing (SubPath)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Html.Events.Extra.Mouse as Mouse
import TypedSvg exposing (rect, svg, defs, marker, polygon, g, pattern, line, circle)
import TypedSvg.Attributes as Attrs exposing
    ( height, width, class, cursor, x, y, cx, cy, fill, r, points, id, orient, markerWidth, markerHeight, refX, refY
    , strokeWidth, rx, x1, y1, x2, y2, stroke, markerEnd)
import TypedSvg.Types exposing (CoordinateSystem(..), Opacity(..), Paint(..), Length(..), Cursor(..), DominantBaseline(..))
import TypedSvg.Core exposing (Svg, Attribute)
import Graph exposing (Graph, Node, Edge, NodeContext, NodeId)
import Zoom exposing (Zoom, OnZoom)
import Task
import Html exposing (source)
import Force exposing (State)
import Shape exposing (linearCurve)
import SubPath exposing (arcLengthParameterized)
import SubPath exposing (arcLength)
import Math.Vector2 as Vec

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
    { drag : Maybe Drag
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
type alias Drag =
    { current : ( Float, Float ) -- current mouse position
    , index : NodeId -- selected node id
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
    | DragAt ( Float, Float )
    | DragEnd ( Float, Float )

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
                    (Decode.map (.clientPos >> DragAt) Mouse.eventDecoder)
                , Events.onMouseUp
                    (Decode.map (.clientPos >> DragEnd) Mouse.eventDecoder)
                ]

        readySubscriptions : ReadyState -> Sub Msg
        readySubscriptions { drag, zoom } =
            Sub.batch
                [ Zoom.subscriptions zoom ZoomMsg
                , case drag of
                    Nothing ->
                        Sub.none

                    Just _ ->
                        dragSubscriptions
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

    ( DragStart _ _, Init _ ) ->
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
                    allPoints = sxy :: edge.label.points ++ [ txy ]

                    (_ , (insertAfterValue, _)) = 
                        List.foldr
                        (\a -> \(prev, (insertAfter, val)) ->
                            let
                                z = dist spxy (a , prev) |> Debug.log "distance"
                            in
                            if not (isNaN z) && z < val then
                                (a, (a, z)) |> Debug.log "change"
                            else 
                                (a, (insertAfter, val)) |> Debug.log "keep"
                        )
                        (txy, (txy, 10000))
                        allPoints
                        |> Debug.log "insertBeforeValue"

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
                ( Ready { state | graph = updatedGraph }, Cmd.none )
            _ -> ( model, Cmd.none )

    ( DragSubPathStart _ _, Init _ ) ->
        ( model, Cmd.none )

    ( DragAt xy, Ready state ) ->
        handleDragAt xy state

    ( DragAt _, Init _ ) ->
        ( model, Cmd.none )

    ( DragEnd xy, Ready state ) ->
        case state.drag of
            Just { index } ->
                ( Ready
                    { state
                        | drag = Nothing
                    }
                , Cmd.none
                )

            Nothing ->
                ( Ready state, Cmd.none )

    ( DragEnd _, Init _ ) ->
        ( model, Cmd.none )


dist : (Float, Float) -> ((Float, Float), (Float, Float)) -> Float
dist (x, y) ((x1, y1), (x2, y2)) =
    abs ((x2 - x1) * (y1 - y) - (x1 - x) * (y2 - y1)) / sqrt ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))

{-| check if point on segment. First parameter - point coordinates,
second is coordinates of segment (start, end)
-}
checkPointOnSegment : (Float, Float) -> ((Float, Float), (Float, Float)) -> Float
checkPointOnSegment (x, y) ((x1, y1), (x2, y2)) =
    let
        cross a b = Vec.getX a * Vec.getY b - Vec.getY a * Vec.getX b

        vecC = Vec.vec2 x y
        vecA = Vec.vec2 x1 y1
        vecB = Vec.vec2 x2 y2

        vecAC = Vec.sub vecC vecA
        vecAB = Vec.sub vecB vecA
    in
    cross vecAB vecAC
    -- if not collinear then return false as point cannot be on segment
    -- if cross vecAB vecAC == 0 |> Debug.log "cross" then
    --     let
    --         -- calculate the dotproduct of (AB, AC) and (AB, AB) to see point is now on the segment
    --         dotAB = Vec.dot vecAB vecAB
    --         dotAC = Vec.dot vecAB vecAC
    --     in
    --     if dotAC == 0 || dotAC == dotAB then
    --         -- on end points of segment
    --         True
    --     else if dotAC > 0 && dotAC < dotAB then
    --         -- on segment
    --         True
    --     else
    --         False
    -- else
    --     False

initZoom : Element -> Zoom
initZoom element =
    Zoom.init { width = element.width, height = element.height }
        |> Zoom.scaleExtent 0.1 2


floatRemainderBy : Float -> Float -> Float
floatRemainderBy divisor n =
  n - toFloat(truncate (n / divisor)) * divisor


handleDragAt : ( Float, Float ) -> ReadyState -> ( Model, Cmd Msg )
handleDragAt xy ({ drag } as state) =
    case drag of
        Just { start, index, delta } ->
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

        Nothing ->
            ( Ready state, Cmd.none )


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
                        ( state.element.x, state.element.y )
                        xy
                    )
                    nodeCtx
                )
            )
        )
        state.graph


updateNode : ( Float, Float ) -> ( Float, Float ) -> NodeContext Container SubPathEdge -> NodeContext Container SubPathEdge
updateNode (dx, dy) ( x, y ) nodeCtx =
    let
        nodeValue =
            nodeCtx.node.label
    in
    updateContextWithValue nodeCtx {nodeValue | xy = (x - dx, y - dy)}


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
shiftPosition : Zoom -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
shiftPosition zoom ( elementX, elementY ) ( clientX, clientY ) =
    let
        zoomRecord =
            Zoom.asRecord zoom
    in
    ( (clientX - zoomRecord.translate.x - elementX) / zoomRecord.scale
    , (clientY - zoomRecord.translate.y - elementY) / zoomRecord.scale
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
    svg
        [ id elementId
        , Attrs.width <| Percent 100
        , Attrs.height <| Percent 100
        ]
        [ defs []
            [ innerGrid transform10
            , grid x y transform100
            ]
        , rect
            ([ Attrs.width <| Percent 100
            , Attrs.height <| Percent 100
            , fill <| Reference gridId
            , cursor CursorMove
            ] ++ zoomEvents) []
        , g
            [ zoomTransformAttr ]
            [ renderGraph model
            ]
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

        Ready { drag, graph, showGraph } ->
            if showGraph then
                g
                    []
                    [ Graph.edges graph
                        |> List.map (linkElement graph)
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

linkElement : Graph Container SubPathEdge -> Edge SubPathEdge -> Svg Msg
linkElement graph edge =
    let
        source =
            Graph.get edge.from graph

        target =
            Graph.get edge.to graph
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
                curve =
                    linearCurve
                        <| (sx, sy) :: points ++ [ (tx, ty) ]

                -- half of rect
                ry = containerHeight / 2
                rx = containerWidth / 2

                -- size of sides of big triangle create by dots
                x = (cx - tx) |> abs
                y = (cy - ty) |> abs

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
                    if topBottom then
                        curveLength - distanceXY * ry / y - magicOffset
                    else
                        curveLength - distanceXY * rx / x - magicOffset

                idValue =
                    "from-" ++ String.fromInt (sourceNode.node.id) ++ "-to-" ++ String.fromInt (targetNode.node.id)
            in
                g []
                [ SubPath.element curve
                    [ id idValue
                    , strokeWidth <| Px 1
                    , stroke <| Paint <| Color.black
                    , fill <| PaintNone
                    , onMouseDownSubPath edge
                    ]
                , TypedSvg.text_ []
                    [
                        TypedSvg.textPath
                            [ Attrs.xlinkHref ("#" ++ idValue)
                            , Attrs.startOffset <| String.fromFloat offset
                            , Attrs.dominantBaseline DominantBaselineCentral
                            , Attrs.fontSize <| Px 10
                            ]
                            [ text "➤" ]
                    ]
                ]
        _ -> text ""

onMouseDownSubPath : Edge SubPathEdge -> Attribute Msg
onMouseDownSubPath edge =
    Mouse.onDown (.clientPos >> DragSubPathStart edge)

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

{-| This is the event handler that handles clicks on the vertices (nodes).

The event catches the `clientPos`, which is a tuple with the
`MouseEvent.clientX` and `MouseEvent.clientY` values. These coordinates are
relative to the client area (browser viewport).

If the graph is positioned anywhere else than at the coordinates `(0, 0)`, the
svg element position must be subtracted when setting the node position. This is
handled in the update function by calling the `shiftPosition` function.

-}
onMouseDown : NodeId -> Attribute Msg
onMouseDown index =
    Mouse.onDown (.clientPos >> DragStart index)

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
        , onMouseDown nodeId
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
