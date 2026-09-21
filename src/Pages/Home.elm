module Pages.Home exposing (view)

import Element
    exposing
        ( Element
        , alignRight
        , centerX
        , column
        , el
        , fill
        , image
        , link
        , maximum
        , paddingXY
        , paragraph
        , px
        , row
        , spacing
        , spacingXY
        , text
        , wrappedRow
        )
import Element.Background as Background
import Element.Border as Border exposing (rounded)
import Element.Font as Font
import Html exposing (Html)
import Route exposing (editorLinkDropbox, editorLinkInit, editorLinkMint, editorLinkPastebin, editorLinkQueryCache, editorLinkSalesRank, editorLinkScalingAws, editorLinkSocialGraph, editorLinkTwitter, editorLinkWebCrawler)
import Theme


view : Html msg
view =
    Element.layout Theme.pageAttributes indexMain


indexMain : Element msg
indexMain =
    el [ widthFill, Element.height fill ] <| page


widthFill : Element.Attribute msg
widthFill =
    Element.width fill


page : Element msg
page =
    column
        [ Element.width (maximum 980 fill)
        , centerX
        , paddingXY 24 56
        , spacing 36
        ]
        [ header
        , hero
        , previewRow
        , featureGrid
        , actions
        , footer
        ]


header : Element msg
header =
    row [ widthFill, spacing 24 ]
        [ el (Theme.headingAttributes ++ [ Font.size 44 ]) <| text "RDB modeling"
        , el [ alignRight, Element.paddingXY 0 14 ] <|
            link [ Font.color (Theme.toElement Theme.brand), Font.size 16 ]
                { label = text "Source ↗", url = "https://github.com/RDBModel/rdbmodel.github.io" }
        ]


hero : Element msg
hero =
    column [ widthFill, spacing 12 ]
        [ paragraph [ Font.size 20, Font.color (Theme.toElement Theme.darkWarm) ]
            [ text "Design and communicate software architecture with a simplified version of the C4 model. Describe your domain in YAML and see it as live diagrams." ]
        ]


previewRow : Element msg
previewRow =
    row [ widthFill, spacing 16 ]
        [ previewCard "Diagram" "[VITE_PLUGIN_ELM_ASSET:/src/img/diagram.gif]"
        , previewCard "Editor" "[VITE_PLUGIN_ELM_ASSET:/src/img/editor.gif]"
        ]


previewCard : String -> String -> Element msg
previewCard label src =
    column
        [ Element.width (Element.fillPortion 1)
        , spacing 8
        ]
        [ el [ Font.size 12, Font.color (Theme.toElement Theme.stone) ] (text label)
        , el
            ([ widthFill
             , Element.padding 8
             , Border.color (Theme.toElement Theme.border)
             , Border.width 1
             , rounded 8
             ]
                ++ Theme.cardAttributes
            )
            (image [ widthFill ] { src = src, description = label })
        ]


featureGrid : Element msg
featureGrid =
    wrappedRow [ widthFill, spacing 12 ]
        [ featureCard "Written in YAML" "A short, readable document describes actors, systems, containers and components."
        , featureCard "Many views" "Create as many views of the domain as you need to explain the system."
        , featureCard "Interactive canvas" "Lay out elements and relations, zoom, pan and move between views."
        , featureCard "Validation" "Inconsistencies in the model and its views are highlighted in the document."
        , featureCard "The C4 model" "Actors, systems, containers and components, in the shape the C4 model defines."
        , featureCard "Start anywhere" "Open one of the worked examples and adapt it to your own architecture."
        ]


featureCard : String -> String -> Element msg
featureCard title body =
    column
        ([ Element.width (px 296)
         , Element.padding 18
         , spacing 6
         , rounded 8
         ]
            ++ Theme.cardAttributes
        )
        [ el [ Font.family Theme.serifFamily, Font.size 18, Font.medium, Font.color (Theme.toElement Theme.nearBlack) ] <|
            text title
        , paragraph [ Font.size 14, Font.color (Theme.toElement Theme.olive) ] [ text body ]
        ]


actions : Element msg
actions =
    column [ widthFill, spacingXY 0 20, Element.paddingXY 0 8 ]
        [ primaryButton ( "Start a new model", editorLinkInit )
        , column [ spacing 12 ]
            [ el [ Font.size 14, Font.color (Theme.toElement Theme.stone) ] <| text "Or open a worked example"
            , wrappedRow [ spacing 10 ]
                [ secondaryButton ( "Pastebin", editorLinkPastebin )
                , secondaryButton ( "Dropbox", editorLinkDropbox )
                , secondaryButton ( "Twitter", editorLinkTwitter )
                , secondaryButton ( "Social graph", editorLinkSocialGraph )
                , secondaryButton ( "Web crawler", editorLinkWebCrawler )
                , secondaryButton ( "Mint", editorLinkMint )
                , secondaryButton ( "Query cache", editorLinkQueryCache )
                , secondaryButton ( "Sales rank", editorLinkSalesRank )
                , secondaryButton ( "Scaling on AWS", editorLinkScalingAws )
                ]
            ]
        ]


primaryButton : ( String, String ) -> Element msg
primaryButton ( label, lnk ) =
    link
        [ Background.color (Theme.toElement Theme.brand)
        , Font.color (Theme.toElement Theme.ivory)
        , Font.size 17
        , Font.medium
        , rounded 8
        , paddingXY 22 13
        ]
        { url = "/" ++ lnk, label = text label }


secondaryButton : ( String, String ) -> Element msg
secondaryButton ( label, lnk ) =
    link
        [ Background.color (Theme.toElement Theme.warmSand)
        , Border.color (Theme.toElement Theme.border)
        , Border.width 1
        , Font.color (Theme.toElement Theme.darkWarm)
        , Font.size 15
        , rounded 8
        , paddingXY 14 9
        ]
        { url = "/" ++ lnk, label = text label }


footer : Element msg
footer =
    row [ widthFill, Border.widthEach { top = 1, bottom = 0, left = 0, right = 0 }, Border.color (Theme.toElement Theme.border), Element.paddingXY 0 20 ]
        [ paragraph [ Font.size 14, Font.color (Theme.toElement Theme.stone) ]
            [ text "created by "
            , link [ Font.color (Theme.toElement Theme.brand) ] { label = text "Yauhen Pyl", url = "https://www.linkedin.com/in/yauhenpyl/" }
            ]
        , paragraph [ alignRight, Element.width (Element.shrink), Font.size 14, Font.color (Theme.toElement Theme.stone) ]
            [ text "written in "
            , link [ Font.color (Theme.toElement Theme.brand) ] { label = text "Elm", url = "https://elm-lang.org/" }
            ]
        ]
