module Index exposing (index)
import Element exposing (Element, el, text, row, alignRight, fill, width, spacing, centerY, padding
  , column, px, height, centerX, paddingXY, link, image, shrink, paragraph, rgba, alpha)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Element.Border exposing (rounded)
import Route exposing (editorRoute)
import Color

index : (String, String) -> Html msg
index gifLinks =
  Element.layout []
        (indexMain gifLinks)

indexMain : (String, String) -> Element msg
indexMain gifLinks = 
  column [width fill, height fill]
    [ header
    , body gifLinks
    , editorLink
    , footer
    ]

header : Element msg
header =
  row [ width fill, height <| px 50, blockPadding, spacing 20 ]
    [ el [ Font.size 32 ] <| text "RDB modeling"
    , el [ defaultFontSize, Font.light ] <| text "...a way to simplify your C4 model"
    , link [ Color.blue |> mapColor |> Font.color, alignRight, Font.size 22 ] { label = text "[Source]", url = "https://github.com/RDBModel/rdbmodel.github.io" }
    ]

body : (String, String) -> Element msg
body (diagramUrl, editorUrl)= 
  column [ width fill]
    [ diagram diagramUrl
    , editor editorUrl
    ]

blockPadding : Element.Attribute msg
blockPadding = padding 10
{- 
  View models in svg format
  Modeling diagram in realtime
  Layout model elements and edges manually
  Zoom, scroll and navigate a model
-}

yamlItem : String -> Element msg
yamlItem value =
  text ("- " ++ value)

digramDescription : Element msg
digramDescription =
  column [ defaultSpacing, defaultPadding, defaultFontSize ]
    [ yamlItem "View domain representation via view editor"
    , yamlItem "☝ Rings are runnable applications, aka Software systems"
    , yamlItem "☝ Deliveries are deployable units, aka Containers"
    , yamlItem "☝ Blocks are buildable packages, aka Components"
    , yamlItem "See 🔎 connections between actors, rings, deliveries, and blocks"
    -- , text "Save models in SVG format"
    , yamlItem "Layout selected view elements and edges manually"
    , yamlItem "Check elements and edges descriptions"
    , yamlItem "Zoom, scroll, and navigate through the view"
    ]

diagram : String -> Element msg
diagram url =
  row [ width fill, blockPadding ]
  [ el [ width shrink ] (image [] { src = url, description = "diagram" })
  , el [ width fill ] digramDescription
  ]

editorDescription : Element msg
editorDescription =
  column [ defaultSpacing, defaultPadding, defaultFontSize ]
    [ paragraph []
      [ yamlItem "Use simplified 😎"
      , link [ Color.blue |> mapColor |> Font.color ] { label = text "C4 model", url = "https://c4model.com/" }
      , text " to represent a domain"
      ]
    , yamlItem "Represent ✍ domain in YAML format"
    , paragraph []
      [ yamlItem "Modify views (domain representations) manually via 💣"
      , link [ Color.blue |> mapColor |> Font.color ] { label = text "Monaco editor", url = "https://microsoft.github.io/monaco-editor/" }
      ]
    , yamlItem "Check changes from view editor in realtime"
    , yamlItem "Use key shortcuts to save, navigate and modify the domain and views"
    , yamlItem "See validation errors in the domain and views immediately"
    , yamlItem "Use many views to represent the domain from different perspectives"
    ]


mapColor : Color.Color -> Element.Color
mapColor =
  Color.toRgba >> (\{red, green, blue, alpha} -> rgba red green blue alpha)

editor : String -> Element msg
editor url =
  row [ width fill, blockPadding ]
  [ el [ width fill ] editorDescription
  , el [ width shrink ] (image [] { src = url, description = "editor" })
  ]

editorLink : Element msg
editorLink =
  el [ width fill, height <| px 120, blockPadding ] editorButton

editorButton : Element msg
editorButton =
  el [centerX, centerY]
  <| link [ Color.lightBlue |> mapColor |> Background.color, rounded 5 ]
    { url = "/" ++ editorRoute
    , label = el [ paddingXY 150 20, defaultFontSize ] <| text "See the demo ☀️"
    }

footer : Element msg
footer =
  row [ width fill, defaultPadding ]
    [ paragraph []
      [ text "created by "
      , link [ Color.blue |> mapColor |> Font.color ] { label = text "Yauhen Pyl", url = "https://www.linkedin.com/in/yauhenpyl/" }
      ]
    , paragraph []
      [ link [ Color.blue |> mapColor |> Font.color ] { label = text "Thanks to MaybeJustJames", url = "https://github.com/MaybeJustJames/yaml" }
      ]
    , paragraph [ alignRight, width shrink ]
      [ text "written in ❤️ "
      , link [ Color.blue |> mapColor |> Font.color ] { label = text "Elm lang", url = "https://elm-lang.org/" }
      ]
    ]


defaultSpacing : Element.Attribute msg
defaultSpacing = spacing 20
defaultPadding : Element.Attribute msg
defaultPadding = padding 30
defaultFontSize : Element.Attr decorative msg
defaultFontSize = Font.size 28
