module ViewEditor.SvgView exposing (..)

import Color
import ContainerMenu.ContextMenu as ContextMenu
import Dict exposing (Dict)
import Domain.Domain exposing (Domain, View, getContainers, getCurrentView, getEdges, getElementsKeysAndNames, possibleRelationsToAdd)
import Html exposing (Html, text)
import Html.Attributes
import Html.Events.Extra.Mouse as Mouse
import Navigation.ViewNavigation as ViewNavigation
import TypedSvg exposing (circle, defs, g, marker, pattern, rect, svg)
import TypedSvg.Attributes as Attrs
    exposing
        ( class
        , cx
        , cy
        , d
        , fill
        , fillOpacity
        , height
        , id
        , r
        , stroke
        , strokeWidth
        , width
        , x
        , x1
        , x2
        , y
        , y1
        , y2
        )
import TypedSvg.Core exposing (Attribute, Svg)
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
import ViewControl.AddView as AddView
import ViewControl.ViewControl as ViewControl
import ViewEditor.DrawContainer exposing (drawContainer, mouseDownMain)
import ViewEditor.DrawEdges exposing (drawEdge)
import ViewEditor.Msg exposing (Msg(..))
import ViewEditor.Types exposing (ViewEditorState)


type alias MonacoState =
    { views : Dict String View
    , domain : Maybe Domain
    }


svgView : MonacoState -> ViewEditorState -> List (Html Msg)
svgView { views, domain } viewEditorState =
    let
        { viewNavigation, viewControl } =
            viewEditorState

        rectNavigationEvents =
            ViewNavigation.gridRectEvents viewNavigation |> List.map (Html.Attributes.map ViewNavigation)

        ( currentView, currentControl ) =
            case ( getCurrentView viewEditorState.selectedView views, domain ) of
                ( Just v, Just d ) ->
                    ( renderCurrentView ( v, d ) viewEditorState, ViewControl.view viewEditorState.selectedView views (getElementsKeysAndNames d) viewControl |> Html.map ViewControl )

                _ ->
                    ( text "", text "" )

        gridRectEvents =
            if ViewNavigation.panMode viewNavigation then
                rectNavigationEvents

            else
                mouseDownMain SelectItemsStart :: rectNavigationEvents

        transform10 =
            ViewNavigation.getScale viewNavigation |> (*) 10

        transform100 =
            transform10 * 10

        getXY =
            ViewNavigation.getTranslate viewNavigation
                |> (\t -> ( floatRemainderBy transform100 t.x, floatRemainderBy transform100 t.y ))
    in
    [ emptySvg
        [ defs []
            [ innerGrid transform10
            , grid getXY transform100
            , markerDot -- for circle in edges
            ]
        , gridRect gridRectEvents
        , g
            [ ViewNavigation.zoomTransformAttr viewEditorState.viewNavigation |> Html.Attributes.map ViewNavigation ]
            [ currentView
            , renderSelectRect viewEditorState
            ]
        ]
    , currentControl
    , ViewNavigation.view viewEditorState.viewNavigation |> Html.map ViewNavigation
    , AddView.view viewEditorState.addView |> Html.map AddView
    , ContextMenu.view viewEditorState.containerMenu |> Html.map ContainerContextMenu
    ]


pointDotId : String
pointDotId =
    "dot"


markerDot : Svg msg
markerDot =
    marker
        [ id pointDotId
        , Attrs.refX "5"
        , Attrs.refY "5"
        , Attrs.markerWidth <| Px 10
        , Attrs.markerHeight <| Px 10
        ]
        [ circle
            [ cx <| Px 5
            , cy <| Px 5
            , r <| Px 3
            , Attrs.fill <| Paint <| Color.white
            , Attrs.stroke <| Paint <| Color.black
            , Attrs.strokeWidth <| Px 1
            ]
            []
        ]


renderSelectRect : ViewEditorState -> Svg Msg
renderSelectRect model =
    case model.brush of
        Just { start, end } ->
            selectItemsRect start end

        Nothing ->
            text ""


selectItemsRect : ( Float, Float ) -> ( Float, Float ) -> Svg msg
selectItemsRect start end =
    let
        ( x1, y1 ) =
            start

        ( x2, y2 ) =
            end

        width =
            abs <| (Tuple.first end - Tuple.first start)

        height =
            abs <| (Tuple.second end - Tuple.second start)
    in
    rectToSelect ( min x1 x2, min y1 y2 ) ( width, height )


rectToSelect : ( Float, Float ) -> ( Float, Float ) -> Svg msg
rectToSelect ( xValue, yValue ) ( w, h ) =
    rect
        [ x <| Px <| xValue
        , fill <| Paint <| Color.blue
        , fillOpacity <| Opacity 0.3
        , y <| Px <| yValue
        , stroke <| Paint <| Color.white
        , width <| Px <| w
        , height <| Px <| h
        ]
        []


renderCurrentView : ( View, Domain ) -> ViewEditorState -> Svg Msg
renderCurrentView ( v, domain ) model =
    let
        { selectedItems, viewNavigation } =
            model

        getPossibleRelations =
            possibleRelationsToAdd ( domain, v )
    in
    g []
        [ getEdges ( domain, v )
            |> List.map (drawEdge viewNavigation selectedItems model.currentMouseOverRelation)
            |> g [ class [ "links" ] ]
        , getContainers ( domain, v )
            |> List.map (drawContainer model.highlightedElement viewNavigation selectedItems getPossibleRelations)
            |> g [ class [ "nodes" ] ]
        ]


floatRemainderBy : Float -> Float -> Float
floatRemainderBy divisor n =
    n - toFloat (truncate (n / divisor)) * divisor


emptySvg : List (Svg Msg) -> Html Msg
emptySvg =
    svg
        [ id "main-graph"
        , Attrs.width <| Percent 100
        , Attrs.height <| Percent 100
        , Mouse.onContextMenu (\_ -> NoOp)
        ]


innerGridId : String
innerGridId =
    "inner-grid"


innerGrid : Float -> Svg msg
innerGrid size =
    pattern
        [ id innerGridId
        , Attrs.width <| Px size
        , Attrs.height <| Px size
        , Attrs.patternUnits CoordinateSystemUserSpaceOnUse
        ]
        [ rect
            [ Attrs.width <| Percent 100
            , Attrs.height <| Percent 100
            , Attrs.fill PaintNone
            , Attrs.stroke <| Paint <| Color.rgb255 204 204 204
            , strokeWidth <| Px 0.5
            ]
            []
        ]


gridId : String
gridId =
    "grid"


grid : ( Float, Float ) -> Float -> Svg msg
grid ( x, y ) size =
    pattern
        [ id gridId
        , Attrs.width <| Px size
        , Attrs.height <| Px size
        , Attrs.x <| Px x
        , Attrs.y <| Px y
        , Attrs.patternUnits CoordinateSystemUserSpaceOnUse
        ]
        [ rect
            [ Attrs.width <| Percent 100
            , Attrs.height <| Percent 100
            , Attrs.fill <| Reference innerGridId
            , Attrs.stroke <| Paint <| Color.rgb255 204 204 204
            , strokeWidth <| Px 1.5
            ]
            []
        ]


gridRect : List (Attribute msg) -> Svg msg
gridRect events =
    rect
        ([ Attrs.width <| Percent 100
         , Attrs.height <| Percent 100
         , fill <| Reference gridId

         --, cursor CursorMove
         ]
            ++ events
        )
        []
