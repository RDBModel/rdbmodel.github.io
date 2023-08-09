module ViewEditor.DrawContainer exposing (drawContainer, containerWidth, containerHeight, mouseDownMain)

import ContainerMenu.ContextMenu as ContextMenu
import Dict exposing (Dict)
import Domain.Domain exposing (Vertex)
import Html.Attributes
import Html.Events.Extra.Mouse as Mouse exposing (Event)
import Navigation.ViewNavigation as ViewNavigation
import TypedSvg.Core exposing (Attribute, Svg)
import ViewEditor.MovingViewElements exposing (getSelectedElementKeysAndDeltas)
import ViewEditor.Msg exposing (Msg(..))
import ViewEditor.Types exposing (SelectedItem)
import Color
import Domain.Domain exposing (Edge, Vertex)
import Html exposing (div)
import Html.Attributes exposing (style)
import Path exposing (Path)
import Shape exposing (linearCurve)
import SubPath exposing (arcLength, arcLengthParameterized)
import TypedSvg exposing (circle, g, marker, pattern, rect, title)
import TypedSvg.Attributes as Attrs
    exposing
        ( cursor
        , cx
        , cy
        , d
        , fill
        , fillOpacity
        , height
        , id
        , r
        , rx
        , stroke
        , strokeOpacity
        , strokeWidth
        , transform
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
renderContainerInternal selected { key, name, description, xy } events =
    let
        ( xCenter, yCenter ) =
            xy

        tooltip =
            case description of
                Just d ->
                    d

                Nothing ->
                    key
    in
    g events
        [ rect
            [ x <| Px <| xCenter - containerWidth / 2
            , y <| Px <| yCenter - containerHeight / 2
            , width <| Px containerWidth
            , height <| Px containerHeight
            , rx <| Px containerRadius
            , Attrs.fill <| Paint <| Color.white
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
            [ x <| Px <| xCenter - containerWidth / 2
            , y <| Px <| yCenter - containerHeight / 2
            , width <| Px containerWidth
            , height <| Px containerHeight
            , cursor CursorDefault
            ]
            [ div
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
                    ] [ text name ] ]
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
