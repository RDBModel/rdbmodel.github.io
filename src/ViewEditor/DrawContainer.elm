module ViewEditor.DrawContainer exposing (containerHeight, containerWidth, drawContainer, mouseDownMain)

import Color
import ContainerMenu.ContextMenu as ContextMenu
import Dict exposing (Dict)
import Domain.Domain exposing (Domain, Vertex, View, ViewElementKey, getChildrenOfNode)
import Html exposing (div)
import Html.Attributes exposing (style)
import Html.Events.Extra.Mouse as Mouse exposing (Event)
import Navigation.ViewNavigation as ViewNavigation
import TypedSvg exposing (g, rect, title)
import TypedSvg.Attributes as Attrs
    exposing
        ( cursor
        , d
        , height
        , id
        , rx
        , width
        , x
        , y
        )
import TypedSvg.Core exposing (Attribute, Svg, foreignObject, text)
import TypedSvg.Types
    exposing
        ( AnchorAlignment(..)
        , CoordinateSystem(..)
        , Cursor(..)
        , DominantBaseline(..)
        , Length(..)
        , LengthAdjust(..)
        , Opacity(..)
        , Paint(..)
        , Transform(..)
        )
import ViewEditor.MovingViewElements exposing (getSelectedElementKeysAndDeltas)
import ViewEditor.Msg exposing (Msg(..))
import ViewEditor.Types exposing (SelectedItem)


drawContainer : ViewNavigation.Model -> List SelectedItem -> Dict String (List Domain.Domain.Relation) -> Vertex -> Svg Msg
drawContainer viewNavigation selectedItems possibleContainersRelations container =
    let
        mouseDownAttr =
            if ViewNavigation.panMode viewNavigation then
                ViewNavigation.panModeEvent viewNavigation |> List.map (Html.Attributes.map ViewNavigation)

            else
                [ mouseDownMain (DragViewElementStart container.key) ]

        selectedElements =
            getSelectedElementKeysAndDeltas selectedItems
                |> List.map Tuple.first

        renderContainerFunc =
            if List.member container.key selectedElements then
                renderContainerSelected

            else
                renderContainer

        contextMenuAttr =
            Dict.get container.key possibleContainersRelations
                |> ContextMenu.attach container.key
                |> Html.Attributes.map ContainerContextMenu
                |> List.singleton
    in
    renderContainerFunc container (mouseDownAttr ++ contextMenuAttr)


mouseDownMain : (( Float, Float ) -> Msg) -> Attribute Msg
mouseDownMain msg =
    Mouse.onDown <|
        onlyMainButton
            >> Maybe.map msg
            >> Maybe.withDefault NoOp


onlyMainButton : Event -> Maybe ( Float, Float )
onlyMainButton e =
    case e.button of
        Mouse.MainButton ->
            Just e.clientPos

        _ ->
            Nothing


renderContainerSelected : Vertex -> List (Attribute msg) -> Svg msg
renderContainerSelected =
    renderContainerInternal True


renderContainer : Vertex -> List (Attribute msg) -> Svg msg
renderContainer =
    renderContainerInternal False


renderContainerInternal : Bool -> Vertex -> List (Attribute msg) -> Svg msg
renderContainerInternal selected { key, name, description, xy, wh } events =
    let
        ( xCenter, yCenter ) =
            xy

        (w, h) = wh

        tooltip =
            case description of
                Just d ->
                    d

                Nothing ->
                    key

        calculatedPosition = w /= containerWidth || h /= containerHeight

        fillValue =
            if calculatedPosition then
                PaintNone
            else
                Paint <| Color.white

        containerName =
            if calculatedPosition then
                div
                [ style "display" "flex"
                , style "justify-content" "flex-start"
                , style "align-items" "flex-start"
                , style "height" "100%"
                ]
                [ div
                    [ style "padding" "1px 3px 1px 3px"
                    , style "text-align" "center"
                    , style "max-height" "100%"
                    , style "font-size" "14px"
                    , style "border" "1px solid black"
                    , style "border-radius" "0 0 3px 0"
                    , style "background-color" "white"
                    ]
                    [ text name ]
                ]
            else
                div
                [ style "display" "flex"
                , style "justify-content" "center"
                , style "align-items" "center"
                , style "height" "100%"
                ]
                [ div
                    [ style "margin" "auto"
                    , style "padding" "1px"
                    , style "text-align" "center"
                    , style "max-height" "100%"
                    , style "font-size" "14px"
                    ]
                    [ text name ]
                ]

        yValue =
            if calculatedPosition then
                yCenter - h / 2
            else
                yCenter - h / 2
    in
    g events
        [ rect
            [ x <| Px <| xCenter - w / 2
            , y <| Px <| yValue
            , width <| Px w
            , height <| Px h
            , rx <| Px containerRadius
            , Attrs.fill <| fillValue
            , Attrs.stroke <|
                Paint <|
                    if selected then
                        Color.blue

                    else
                        Color.black
            , Attrs.strokeWidth <| Px 1
            , id key
            ]
            [ title [] [ text tooltip ] ]
        , foreignObject
            [ x <| Px <| xCenter - w / 2
            , y <| Px <| yValue
            , width <| Px w
            , height <| Px h
            , cursor CursorDefault
            ]
            [ containerName
            , title [] [ text tooltip ]
            ]
        ]


containerWidth : Float
containerWidth =
    100


containerHeight : Float
containerHeight =
    50


containerRadius : Float
containerRadius =
    0
