module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Browser.Events as Events
import Color
import SubPath exposing (SubPath)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import TypedSvg exposing (rect, svg, defs, marker, polygon, g, line)
import TypedSvg.Attributes as Attrs exposing (class, cursor, cx, cy, fill, r, stroke, viewBox, points, id, orient, markerWidth, markerHeight, refX, refY)
import TypedSvg.Attributes.InPx exposing (height, strokeWidth, width, x, x1, x2, y, y1, y2, strokeWidth)
import TypedSvg.Types exposing (Paint(..), px, percent, Length(..), Cursor(..))
import TypedSvg.Core exposing (Svg, Attribute)
import Shape
import Scale exposing (ContinuousScale)
import Graph exposing (Graph, Node)
import Zoom exposing (Zoom, OnZoom)
import Task
import TypedSvg exposing (circle)
main : Program () Model Msg
main =
  Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }

type Model
    = Init (Graph (Node String) ())
    | Ready ReadyState

type alias ReadyState =
    { graph : Graph (Node String) ()
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

elementId : String
elementId =
    "exercise-graph"

getElementPosition : Cmd Msg
getElementPosition =
    Task.attempt ReceiveElementPosition (Dom.getElement elementId)

init : () -> ( Model, Cmd Msg )
init _ =
    ( Init (Graph.fromNodeLabelsAndEdgePairs [Node 1 "1"] []), getElementPosition )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ case model of
            Init _ ->
                Sub.none

            Ready state ->
                Zoom.subscriptions state.zoom ZoomMsg
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
            { element = element
            , graph = graph
            , showGraph = True
            , zoom = initZoom element
            }
        , Cmd.none
        )

    ( ReceiveElementPosition (Ok { element }), Ready state ) ->
        ( Ready
            { element = element
            , graph = state.graph
            , showGraph = True
            , zoom = initZoom element
            }
        , Cmd.none
        )

    ( ReceiveElementPosition (Err _), _ ) ->
        ( model, Cmd.none )

initZoom : Element -> Zoom
initZoom element =
    Zoom.init { width = element.width, height = element.height }
        |> Zoom.scaleExtent 0.1 2


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
    in
    svg
        [ id elementId
        , Attrs.width <| Percent 100
        , Attrs.height <| Percent 100
        ]
        [ defs [] [ arrowhead ]
        --- , g [] <| List.indexedMap yGridLine <| Scale.ticks yScale 10
        -- , g [] <| List.indexedMap xGridLine <| Scale.ticks xScale 20
        , rect
            ([ Attrs.width <| Percent 100
                , Attrs.height <| Percent 100
                , fill <| Paint <| Color.rgba 0 0 0 0
                , cursor CursorMove
                ]
                ++ zoomEvents
            )
            []
        , g
            [ zoomTransformAttr ]
            [ renderGraph model ]
        ]


renderGraph : Model -> Svg Msg
renderGraph model =
    case model of
        Init _ ->
            text ""

        Ready { graph, showGraph } ->
            if showGraph then
                circle [ cx (px 60), cy (px 60), r (px 50) ] []

            else
                text ""
                

arrowhead : Svg msg
arrowhead =
    marker
        [ id "arrowhead"
        , orient "auto"
        , markerWidth <| Px 8.0
        , markerHeight <| Px 6.0
        , refX "29"
        , refY "3"
        ]
        [ polygon
            [ points [ ( 0, 0 ), ( 8, 3 ), ( 0, 6 ) ]
            , fill edgeColor
            ]
            []
        ]

edgeColor : Paint
edgeColor =
    Paint <| Color.rgb255 180 180 180


xGridLine : Int -> Float -> Svg msg
xGridLine index tick =
    line
        [ y1 0
        , Attrs.y2 (percent 100)
        , x1 (Scale.convert xScale tick)
        , x2 (Scale.convert xScale tick)
        , stroke <| Paint Color.black
        , strokeWidth (Basics.max (toFloat (modBy 2 index)) 0.5)
        ]
        []


yGridLine : Int -> Float -> Svg msg
yGridLine index tick =
    line
        [ x1 0
        , Attrs.x2 (percent 100)
        , y1 (Scale.convert yScale tick)
        , y2 (Scale.convert yScale tick)
        , stroke <| Paint Color.black
        , strokeWidth (Basics.max (toFloat (modBy 2 index)) 0.5)
        ]
        []

padding : Float
padding =
    0

w : Float
w =
    1920


h : Float
h =
    1080

xScale : ContinuousScale Float
xScale =
    Scale.linear ( padding, w - padding ) ( 0, 2 )


yScale : ContinuousScale Float
yScale =
    Scale.linear ( h - padding, padding ) ( 0, 1 )
