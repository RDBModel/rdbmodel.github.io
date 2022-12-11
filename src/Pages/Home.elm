module Pages.Home exposing (view)

import Color
import Element
    exposing
        ( Element
        , alignRight
        , alpha
        , centerX
        , centerY
        , column
        , el
        , fill
        , height
        , image
        , link
        , padding
        , paddingXY
        , paragraph
        , px
        , rgba
        , row
        , shrink
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Border exposing (rounded)
import Element.Font as Font
import Html exposing (Html)
import Route exposing (editorRoute)


view : Html msg
view =
    Element.layout [] indexMain


indexMain : Element msg
indexMain =
    column [ width fill, height fill ]
        [ header
        , body
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


body : Element msg
body =
    column [ width fill ]
        [ diagram
        , editor
        ]


blockPadding : Element.Attribute msg
blockPadding =
    padding 10



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
        , yamlItem "☝ Systems are runnable applications, aka Software systems"
        , yamlItem "☝ Containers are deployable units, aka Containers"
        , yamlItem "☝ Components are buildable packages, aka Components"
        , yamlItem "See 🔎 connections between actors, systems, containers, and components"

        -- , text "Save models in SVG format"
        , yamlItem "Layout selected view elements and edges manually"
        , yamlItem "Check elements and edges descriptions"
        , yamlItem "Zoom, scroll, and navigate through the view"
        ]


diagram : Element msg
diagram =
    row [ width fill, blockPadding ]
        [ el [ width shrink ] (image [] { src = "[VITE_PLUGIN_ELM_ASSET:/src/img/diagram.gif]", description = "diagram" })
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
    Color.toRgba >> (\{ red, green, blue, alpha } -> rgba red green blue alpha)


editor : Element msg
editor =
    row [ width fill, blockPadding ]
        [ el [ width fill ] editorDescription
        , el [ width shrink ] (image [] { src = "[VITE_PLUGIN_ELM_ASSET:/src/img/editor.gif]", description = "editor" })
        ]


editorLink : Element msg
editorLink =
    el [ width fill, height <| px 120, blockPadding ] editorButton


editorButton : Element msg
editorButton =
    el [ centerX, centerY ] <|
        link [ Color.lightBlue |> mapColor |> Background.color, rounded 5 ]
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
defaultSpacing =
    spacing 20


defaultPadding : Element.Attribute msg
defaultPadding =
    padding 30


defaultFontSize : Element.Attr decorative msg
defaultFontSize =
    Font.size 28
