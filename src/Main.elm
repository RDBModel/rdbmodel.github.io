module Main exposing (..)

import Browser
import Color
import SubPath exposing (SubPath)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import TypedSvg exposing (circle, svg)
import TypedSvg.Attributes exposing (cx, cy, fill, r, stroke, strokeWidth, viewBox)
import TypedSvg.Types exposing (Paint(..), px)
import TypedSvg.Core exposing (Svg)
import Shape

main : Program () Int Msg
main =
  Browser.sandbox { init = 0, update = update, view = view }

type Msg = Increment | Decrement

update : Msg -> number -> number
update msg model =
  case msg of
    Increment ->
      model + 1

    Decrement ->
      model - 1


myCircle : Svg msg
myCircle =
    circle
        [ cx (px 100)
        , cy (px 100)
        , r (px 30)
        , fill <| Paint Color.blue
        , strokeWidth (px 2)
        , stroke <| Paint <| Color.rgba 0.8 0 0 0.5
        ]
        []


hShape : SubPath 
hShape =
    Shape.naturalCurve
        [ ( 1, 1 )
        , ( 20, 20 )
        , ( 60, 60 )
        , ( 70, 20 )
        , ( 80, 30 )
        , ( 90, 50 )
        , ( 100, 20 )
        , ( 110, 1 )
        ]

view : Int -> Html Msg
view model =
  svg [ viewBox 0 0 800 600 ] [ SubPath.element hShape 
            [ fill PaintNone, stroke <| Paint Color.black ]  ]
