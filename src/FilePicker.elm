module FilePicker exposing (..)

import Html exposing (Html, div, button)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import TypedSvg.Attributes exposing ( d, viewBox, strokeWidth, stroke, fill, strokeLinecap, strokeLinejoin, width, height
    , cx, cy, r, points)
import TypedSvg.Types exposing ( Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import TypedSvg exposing (svg, path, polyline,circle)
import JsInterop exposing (openFileOpenDialog, openSaveFileDialog)
import Color

type Msg
    = OpenFile
    | SaveFile

update : Msg -> Cmd Msg
update msg =
    case msg of
        OpenFile -> openFileOpenDialog ()
        SaveFile -> openSaveFileDialog ()

view : Html Msg
view =
    div
        [ style "position" "absolute"
        , style "top" "5px"
        , style "right" "20px"
        , style "font-size" "16px"
        , style "user-select" "none"
        , style "display" "flex"
        ]
        [ button
            [ style "background-color" "white"
            , style "border" "1px solid rgba(204, 204, 204, .6)"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , onClick <| OpenFile
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
                , path [ d "M14 3v4a1 1 0 0 0 1 1h4" ] []
                , path [ d "M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z" ] []
                ]
            ]
        , button
            [ style "background-color" "white"
            , style "border" "1px solid rgba(204, 204, 204, .6)"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , onClick <| SaveFile
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
                , path [ d "M6 4h10l4 4v10a2 2 0 0 1 -2 2h-12a2 2 0 0 1 -2 -2v-12a2 2 0 0 1 2 -2" ] []
                , circle [ cx (Px 12), cy (Px 14), r (Px 2) ] []
                , polyline [ points [(14, 4), (14, 8), (8, 8), (8, 4)] ] []
                ]
            ]
        ]