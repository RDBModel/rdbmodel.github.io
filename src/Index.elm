module Index exposing (index)
import Element exposing (Element, el, text, row, alignRight, fill, width, rgb255, spacing, centerY, padding, none
  , column, px, height, alignBottom, fillPortion, centerX)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Element.Input exposing (button)
import Element.Border exposing (rounded)
import Element exposing (paddingXY)
import Element exposing (link)

index : Html msg
index =
  Element.layout []
        indexMain

indexMain : Element msg
indexMain = 
  column [width fill, height fill]
    [ header
    , body
    , editorLink
    , footer
    ]

header : Element msg
header =
  row [ width fill, height <| px 50 ]
    [ text "RDB modeling"
    , el [ alignRight ] (text "Source")
    ]

body : Element msg
body = 
  column [ width fill]
    [ diagram
    , editor
    ]

diagram : Element msg
diagram =
  row [ width fill ]
  [ el [ width fill ] (text "image diagram")
  , el [ width fill ] (text "diagram description")
  ]

editor : Element msg
editor =
  row [ width fill ]
  [ el [ width fill ] (text "editor description")
  , el [ width fill ] (text "image editor")
  ]

editorLink : Element msg
editorLink =
  el [ width fill, height <| px 100 ] editorButton

blue : Element.Color
blue =
    Element.rgb255 238 238 238

editorButton : Element msg
editorButton =
  el [centerX, centerY]
  <| link [ Background.color blue, rounded 5 ]
    { url = "/editor"
    , label = el [ paddingXY 50 10 ] (text "Editor")
    }

footer : Element msg
footer =
  el [ ] (text "footer")
