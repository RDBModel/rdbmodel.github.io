module Pages.Home exposing (view)

import Color
import Element
    exposing
        ( Element
        , alignRight
        , alpha
        , centerX
        , centerY
        , el
        , fill
        , fillPortion
        , height
        , image
        , link
        , paddingXY
        , paragraph
        , px
        , rgba
        , row
        , shrink
        , spacing
        , text
        , textColumn
        , width
        )
import Element.Background as Background
import Element.Border exposing (rounded)
import Element.Font as Font exposing (justify)
import Html exposing (Html)
import Route exposing (editorLinkPastebin)
import Route exposing (editorLinkInit)


view : Html msg
view =
    Element.layout [] indexMain


indexMain : Element msg
indexMain =
    el [ width fill, height fill ]
        mainPartShort


header : Element msg
header =
    row [ centerX, height <| px 50, spacing 20 ]
        [ el [ Font.size 32 ] <| text "RDB modeling"
        , el [ defaultFontSize, Font.light ] <| text "...a way to simplify your C4 model"
        , link [ Color.blue |> mapColor |> Font.color, alignRight, Font.size 22 ] { label = text "[Source]", url = "https://github.com/RDBModel/rdbmodel.github.io" }
        ]


mapColor : Color.Color -> Element.Color
mapColor =
    Color.toRgba >> (\{ red, green, blue, alpha } -> rgba red green blue alpha)


editorLink : Element msg
editorLink =
    row [ spacing 10 ]
        [ el [ centerX, height <| px 120, paddingXY 0 15 ] (editorButton ("See the demo ☀️", editorLinkPastebin))
        , el [ centerX, height <| px 120, paddingXY 0 15 ] (editorButton ("Or start new 🎉", editorLinkInit))
        ]


editorButton : (String, String) -> Element msg
editorButton (txt, lnk) =
    el [ centerX, centerY ] <|
        link [ Color.lightBlue |> mapColor |> Background.color, rounded 5 ]
            { url = "/" ++ lnk
            , label = el [ paddingXY 50 20, defaultFontSize ] <| text txt
            }



footer : Element msg
footer =
    row [ centerX, paddingXY 0 15 ]
        [ paragraph []
            [ text "created by "
            , link [ Color.blue |> mapColor |> Font.color ] { label = text "Yauhen Pyl", url = "https://www.linkedin.com/in/yauhenpyl/" }
            ]
        , paragraph [ alignRight, width shrink ]
            [ text "written in ❤️ "
            , link [ Color.blue |> mapColor |> Font.color ] { label = text "Elm lang", url = "https://elm-lang.org/" }
            ]
        ]


defaultFontSize : Element.Attr decorative msg
defaultFontSize =
    Font.size 28


mainPartShort : Element msg
mainPartShort =
    textColumn [ centerX ]
        [ header
        , paragraph [ paddingXY 0 15 ] [ text "😎 This application allows you to create and visualize software architecture using a simplified version of the C4 model" ]
        , row [ spacing 15, paddingXY 0 15 ]
            [ el [ width (fillPortion 2) ] (image [ width fill ] { src = "[VITE_PLUGIN_ELM_ASSET:/src/img/diagram.gif]", description = "diagram" })
            , el [ width (fillPortion 2) ] (image [ width fill ] { src = "[VITE_PLUGIN_ELM_ASSET:/src/img/editor.gif]", description = "editor" })
            ]
        , paragraph [ paddingXY 0 15 ] [ text "✍ Our intuitive interface makes it easy to create and edit yaml files that represent the domain of your application" ]
        , paragraph [ paddingXY 0 15 ] [ text "\u{1FA9F} You can create multiple views of your model to better understand and communicate the relationships within your software system" ]
        , paragraph [ paddingXY 0 15 ] [ text "🔎 Our graphical interface enables you to create and edit views, layout elements and edges, zoom, scroll, and navigate through the selected view" ]
        , paragraph [ paddingXY 0 15 ] [ text "💣 Our application highlights any inconsistencies in the model and views using error messages, ensuring your software architecture is clear and consistent" ]
        , paragraph [ paddingXY 0 15 ] [ text "☝ The C4 model is a powerful tool for understanding and communicating the structure of your software system, and our application supports the four main types of entities in the model: actors, systems, containers, and components" ]
        , paragraph [ paddingXY 0 15 ] [ text "👨\u{200D}🔬 Whether you're a seasoned software architect or just starting out, our application makes it easy to design and understand your software architecture" ]
        , paragraph [ paddingXY 0 15 ] [ text "🎉 Start creating your C4 model with the RDB Model Web Application today!" ]
        , editorLink
        , footer
        ]
