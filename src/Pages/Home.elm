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
        , padding
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
import Route exposing (editorRoute)


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
    el [ centerX, height <| px 120, paddingXY 0 15 ] editorButton


editorButton : Element msg
editorButton =
    el [ centerX, centerY ] <|
        link [ Color.lightBlue |> mapColor |> Background.color, rounded 5 ]
            { url = "/" ++ editorRoute
            , label = el [ paddingXY 150 20, defaultFontSize ] <| text "See the demo ☀️"
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


mainPart : Element msg
mainPart =
    textColumn [ centerX ]
        [ paragraph [ paddingXY 0 15, justify ] [ text "Welcome to the RDB Model Web Application!" ]
        , paragraph [ paddingXY 0 15, justify ] [ text "This application allows you to create and visualize software architecture using a simplified version of the C4 model. With our intuitive interface, you can easily create and edit existing yaml files that represent the domain of your application using the C4 model. It's important to note that while there is only one C4 model or domain, you can create multiple views of this model to better understand and communicate the relationships within your software system." ]
        , paragraph [ paddingXY 0 15, justify ] [ text "Using our graphical interface, you can create and edit views of your model by selecting a sub-model. These views allow you to see the connections between actors, systems, containers, and their components, making it easy to understand the relationships within your software system. You can also layout the elements and edges of your view using our interface, allowing you to easily arrange and present your software architecture in a clear and visually appealing way. Our interface also enables you to zoom, scroll, and navigate through the selected view, allowing you to easily explore and understand your software architecture in greater detail." ]
        , paragraph [ paddingXY 0 15, justify ] [ text "The RDB Model Web Application also helps you during the editing process by highlighting any inconsistencies in the model and views using error messages. This ensures that your software architecture is clear and consistent, making it easier to understand and communicate to others." ]
        , paragraph [ paddingXY 0 15, justify ] [ text "The C4 model is a powerful tool for understanding and communicating the structure of your software system, and is typically used to represent the domain of the application. Our application supports the four main types of entities in the C4 model: actors, systems, containers, and components. Systems in the C4 model usually represent applications or services that bring value to the end users, while containers are units that can usually be deployed independently. Components, on the other hand, are buildable packages that are usually represented as artifacts in the file system." ]
        , paragraph [ paddingXY 0 15, justify ] [ text "Whether you're a seasoned software architect or just starting out, our application makes it easy to design and understand your software architecture. Start creating your C4 model with the RDB Model Web Application today!" ]
        ]


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
