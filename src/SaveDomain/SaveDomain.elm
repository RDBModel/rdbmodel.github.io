module SaveDomain.SaveDomain exposing (..)

import Color
import Html exposing (Html, button, div)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import JsInterop exposing (openFileOpenDialog, openSaveFileDialog)
import TypedSvg exposing (circle, path, polyline, svg)
import TypedSvg.Attributes
    exposing
        ( cx
        , cy
        , d
        , fill
        , height
        , points
        , r
        , stroke
        , strokeLinecap
        , strokeLinejoin
        , strokeWidth
        , viewBox
        , width
        )
import TypedSvg.Types exposing (Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))


view : msg -> Html msg
view event =
    button
        [ style "background-color" "white"
        , style "border" "1px solid rgba(204, 204, 204, .6)"
        , style "min-height" "24px"
        , style "min-width" "24px"
        , style "padding" "0"
        , onClick <| event
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
            , polyline [ points [ ( 14, 4 ), ( 14, 8 ), ( 8, 8 ), ( 8, 4 ) ] ] []
            ]
        ]
