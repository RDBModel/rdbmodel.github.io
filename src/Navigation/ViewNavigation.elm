module Navigation.ViewNavigation exposing
    ( Model
    , Msg
    , getPositionForNewElement
    , getScale
    , getTranslate
    , gridRectEvents
    , init
    , panMode
    , panModeEvent
    , shiftPosition
    , subscriptions
    , update
    , view
    , zoomTransformAttr
    )

import Browser.Events as Events
import Html exposing (Attribute, Html, button, div)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import JsInterop exposing (zoomMsgReceived)
import Json.Decode as Decode
import TypedSvg exposing (circle, line, path, svg)
import TypedSvg.Attributes
    exposing
        ( cx
        , cy
        , d
        , fill
        , height
        , r
        , stroke
        , strokeLinecap
        , strokeLinejoin
        , strokeWidth
        , viewBox
        , width
        , x1
        , x2
        , y1
        , y2
        )
import TypedSvg.Types exposing (Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import Zoom exposing (OnZoom, Zoom)
import Html.Attributes exposing (title)
import Html.Attributes exposing (type_)


type alias Model =
    { ctrlIsDown : Bool
    , zoom : Zoom
    }


init : { height : Float, width : Float, x : Float, y : Float } -> Model
init element =
    Model False (initZoom element)


initZoom : { height : Float, width : Float, x : Float, y : Float } -> Zoom
initZoom element =
    Zoom.init { width = element.width, height = element.height }
        |> Zoom.scaleExtent 0.1 2


type ZoomDirection
    = In
    | Out


type Msg
    = DoZoom ZoomDirection
    | SetCtrlIsDown Bool
    | ZoomMsg OnZoom
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoZoom direction ->
            let
                scaleValue =
                    case direction of
                        In ->
                            1.2

                        Out ->
                            0.8

                current =
                    Zoom.asRecord model.zoom

                newZoom =
                    Zoom.setTransform Zoom.instantly { scale = current.scale * scaleValue, translate = current.translate } model.zoom
            in
            ( { model | zoom = newZoom }, Cmd.none )

        SetCtrlIsDown value ->
            ( { model | ctrlIsDown = value }
            , Cmd.none
            )

        ZoomMsg zoomMsg ->
            ( { model | zoom = Zoom.update zoomMsg model.zoom }
            , zoomMsgReceived ()
            )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        ( backgroundColorForMoveButton, backgroundColorForDefaultButton ) =
            if model.ctrlIsDown then
                ( "#cccccc", "white" )

            else
                ( "white", "#cccccc" )
    in
    div
        [ style "position" "absolute"
        , style "bottom" "10px"
        , style "right" "5px"
        , style "font-size" "16px"
        , style "user-select" "none"
        , style "display" "flex"
        , style "flex-direction" "column"

        --, Mouse.onContextMenu (\_ -> NoOp)
        ]
        [ button
            [ style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , title "Zoom in"
            , type_ "button"
            , onClick <| DoZoom In
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , fill PaintNone
                , strokeLinecap StrokeLinecapRound
                , strokeLinejoin StrokeLinejoinRound
                ]
                [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                , circle [ cx (Px 10), cy (Px 10), r (Px 7) ] []
                , line [ x1 (Px 7), y1 (Px 10), x2 (Px 13), y2 (Px 10) ] []
                , line [ x1 (Px 10), y1 (Px 7), x2 (Px 10), y2 (Px 13) ] []
                , line [ x1 (Px 21), y1 (Px 21), x2 (Px 15), y2 (Px 15) ] []
                ]
            ]
        , button
            [ style "border-width" "0 1px 1px 1px"
            , style "border-style" "solid"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , title "Zoom out"
            , type_ "button"
            , onClick <| DoZoom Out
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , fill PaintNone
                , strokeLinecap StrokeLinecapRound
                , strokeLinejoin StrokeLinejoinRound
                ]
                [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                , circle [ cx (Px 10), cy (Px 10), r (Px 7) ] []
                , line [ x1 (Px 7), y1 (Px 10), x2 (Px 13), y2 (Px 10) ] []
                , line [ x1 (Px 21), y1 (Px 21), x2 (Px 15), y2 (Px 15) ] []
                ]
            ]
        , button
            [ style "background-color" backgroundColorForDefaultButton
            , style "border-width" "0 1px 1px 1px"
            , style "border-style" "solid"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , title "Set edit view mode"
            , type_ "button"
            , onClick <| SetCtrlIsDown False
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , fill PaintNone
                , strokeLinecap StrokeLinecapRound
                , strokeLinejoin StrokeLinejoinRound
                ]
                [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                , path [ d "M6 6l4.153 11.793a0.365 .365 0 0 0 .331 .207a0.366 .366 0 0 0 .332 -.207l2.184 -4.793l4.787 -1.994a0.355 .355 0 0 0 .213 -.323a0.355 .355 0 0 0 -.213 -.323l-11.787 -4.36z" ] []
                , path [ d "M13.5 13.5l4.5 4.5" ] []
                ]
            ]
        , button
            [ style "background-color" backgroundColorForMoveButton
            , style "border-width" "0 1px 1px 1px"
            , style "border-style" "solid"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , title "Set navigate view mode"
            , type_ "button"
            , onClick <| SetCtrlIsDown True
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , fill PaintNone
                , strokeLinecap StrokeLinecapRound
                , strokeLinejoin StrokeLinejoinRound
                ]
                [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                , path [ d "M18 9l3 3l-3 3" ] []
                , path [ d "M15 12h6" ] []
                , path [ d "M6 9l-3 3l3 3" ] []
                , path [ d "M3 12h6" ] []
                , path [ d "M9 18l3 3l3 -3" ] []
                , path [ d "M12 15v6" ] []
                , path [ d "M15 6l-3 -3l-3 3" ] []
                , path [ d "M12 3v6" ] []
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Events.onKeyDown (keyDecoder |> setCtrlState True)
        , Events.onKeyUp (keyDecoder |> setCtrlState False)
        , Zoom.subscriptions model.zoom ZoomMsg
        ]


setCtrlState : Bool -> Decode.Decoder String -> Decode.Decoder Msg
setCtrlState value =
    Decode.map
        (\key ->
            if key == "Control" then
                SetCtrlIsDown value

            else
                NoOp
        )


keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string


gridRectEvents : Model -> List (Attribute Msg)
gridRectEvents model =
    [ Zoom.onDoubleClick model.zoom ZoomMsg, Zoom.onWheel model.zoom ZoomMsg ]
        ++ (if model.ctrlIsDown then
                panModeEvent model

            else
                []
           )


panModeEvent : Model -> List (Attribute Msg)
panModeEvent model =
    Zoom.onDrag model.zoom ZoomMsg


getScale : Model -> Float
getScale model =
    model.zoom |> Zoom.asRecord |> .scale


getTranslate : Model -> { x : Float, y : Float }
getTranslate model =
    model.zoom |> Zoom.asRecord |> .translate


zoomTransformAttr : Model -> Attribute Msg
zoomTransformAttr model =
    Zoom.transform model.zoom


{-| The mouse events for drag start, drag at and drag end read the client
position of the cursor, which is relative to the browser viewport. However,
the node positions are relative to the svg viewport. This function adjusts the
coordinates accordingly. It also takes the current zoom level and position
into consideration.
-}
shiftPosition : Model -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
shiftPosition model ( elementX, elementY ) ( clientX, clientY ) =
    let
        zoomRecord =
            Zoom.asRecord model.zoom
    in
    ( (clientX - zoomRecord.translate.x - elementX) / zoomRecord.scale
    , (clientY - zoomRecord.translate.y - elementY) / zoomRecord.scale
    )


getPositionForNewElement : Model -> { height : Float, width : Float, x : Float, y : Float } -> ( Float, Float )
getPositionForNewElement model svgElement =
    let
        record =
            Zoom.asRecord model.zoom

        ( initY, initX ) =
            ( svgElement.height / 2, svgElement.width / 2 )
    in
    ( initX - record.scale * record.translate.x, initY - record.scale * record.translate.y )


panMode : Model -> Bool
panMode model =
    model.ctrlIsDown
