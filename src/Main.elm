module Main exposing (..)

import Browser exposing (element)
import Browser.Dom as Dom
import Browser.Events as Events
import Color
import SubPath exposing (SubPath)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import TypedSvg exposing (rect, svg, defs, marker, polygon, g, pattern)
import TypedSvg.Attributes as Attrs exposing
    ( height, width, class, cursor, x, y, cx, cy, fill, r, points, id, orient, markerWidth, markerHeight, refX, refY
    , strokeWidth, rx)
import TypedSvg.Types exposing (CoordinateSystem(..), Opacity(..), Paint(..), Length(..), Cursor(..))
import TypedSvg.Core exposing (Svg, Attribute)
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


floatRemainderBy : Float -> Float -> Float
floatRemainderBy divisor n =
  n - toFloat(truncate (n / divisor)) * divisor


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
                Init _ -> 10
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
            [ arrowhead
            , innerGrid transform10
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

        Ready { graph, showGraph } ->
            if showGraph then
                g []
                    [ renderElement 0 0
                    , renderElement 50 50
                    , renderSystem 200 200
                    ]

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

renderElement : Float -> Float -> Svg msg
renderElement xValue yValue = 
    rect
        [ x <| Px xValue
        , y <| Px yValue
        , width <| Px 120
        , height <| Px 60
        , rx <| Px 5
        , Attrs.fill <| Paint <| Color.white
        , Attrs.stroke <| Paint <| Color.black
        , Attrs.strokeWidth <| Px 1
        ] []


renderSystem : Float -> Float -> Svg msg
renderSystem xValue yValue = 
    circle
        [ cx <| Px xValue
        , cy <| Px yValue
        , r <| Px 60
        , Attrs.fill <| Paint <| Color.white
        , Attrs.stroke <| Paint <| Color.black
        , Attrs.strokeWidth <| Px 1
        ] []
