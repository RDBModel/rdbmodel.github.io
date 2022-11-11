module ViewNavigation exposing (..)

import Html exposing (Html, div, button)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import TypedSvg.Attributes exposing ( d, viewBox, strokeWidth, stroke, fill, strokeLinecap, strokeLinejoin,
    cx, cy, r, x1, x2, y1, y2, width, height)
import TypedSvg.Types exposing ( Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import TypedSvg exposing (svg, path, circle, line)
import Zoom exposing (Zoom)
import Color

type alias Model =
    { ctrlIsDown : Bool
    , newZoom : Zoom
    }

init : Zoom -> Model
init zoom = Model False zoom

type ZoomDirection
    = In
    | Out

type Msg
    = DoZoom ZoomDirection
    | SetCtrlIsDown Bool

update : Zoom -> Msg -> Model -> ( Model, Cmd Msg )
update zoom msg model =
    case msg of
        DoZoom direction ->
            let
                scaleValue =
                    case direction of
                        In -> 1.2
                        Out -> 0.8
                current = Zoom.asRecord zoom
                newZoom =
                    Zoom.setTransform Zoom.instantly { scale = current.scale * scaleValue, translate = current.translate } zoom
            in
            ( { model | newZoom = newZoom }, Cmd.none )

        SetCtrlIsDown value ->
            ( { model | ctrlIsDown = value, newZoom = zoom }
            , Cmd.none
            )

view : Model -> Html Msg
view model =
    let
        (backgroundColorForMoveButton, backgroundColorForDefaultButton) =
            if model.ctrlIsDown then
                ("#d3d3d3", "white")
            else
                ("white", "#d3d3d3")
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
            [ style "background-color" "white"
            , style "border" "1px solid rgba(204, 204, 204, .6)"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , onClick <| DoZoom In
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , stroke (Paint Color.black)
                , fill PaintNone
                , strokeLinecap StrokeLinecapRound
                , strokeLinejoin StrokeLinejoinRound
                ]
                [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                , circle [ cx (Px 10), cy (Px 10), r (Px 7) ] []
                , line [ x1 (Px 7), y1 (Px 10), x2 (Px 13), y2 (Px 10)] []
                , line [ x1 (Px 10), y1 (Px 7), x2 (Px 10), y2 (Px 13)] []
                , line [ x1 (Px 21), y1 (Px 21), x2 (Px 15), y2 (Px 15)] []
                ]
            ]
        , button
            [ style "background-color" "white"
            , style "border-width" "0 1px 1px 1px"
            , style "border-style" "solid"
            , style "border-color" "rgba(204, 204, 204, .6)"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , onClick <| DoZoom Out
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , stroke (Paint Color.black)
                , fill PaintNone
                , strokeLinecap StrokeLinecapRound
                , strokeLinejoin StrokeLinejoinRound
                ]
                [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                , circle [ cx (Px 10), cy (Px 10), r (Px 7) ] []
                , line [ x1 (Px 7), y1 (Px 10), x2 (Px 13), y2 (Px 10)] []
                , line [ x1 (Px 21), y1 (Px 21), x2 (Px 15), y2 (Px 15)] []
                ]
            ]
        , button
            [ style "background-color" backgroundColorForDefaultButton
            , style "border-width" "0 1px 1px 1px"
            , style "border-style" "solid"
            , style "border-color" "rgba(204, 204, 204, .6)"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , onClick <| SetCtrlIsDown False
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , stroke (Paint Color.black)
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
            , style "border-color" "rgba(204, 204, 204, .6)"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , onClick <| SetCtrlIsDown True
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , stroke (Paint Color.black)
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
