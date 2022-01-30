port module Main exposing (..)

import Browser
import SplitPane exposing (Orientation(..), ViewConfig, createViewConfig)
import Browser.Dom as Dom
import Basics.Extra exposing (maxSafeInteger)
import Browser.Events as Events
import Json.Decode as Decode
import Yaml.Decode as D
import Html exposing (Html, div, text)
import Html.Events.Extra.Mouse as Mouse
import TypedSvg exposing (svg, defs, g)
import TypedSvg.Attributes as Attrs exposing ( class,  x, y, id)
import TypedSvg.Types exposing ( Length(..))
import TypedSvg.Core exposing (Svg, Attribute)
-- import Graph exposing (Graph, Node, Edge, NodeContext, NodeId, Adjacency)
import Zoom exposing (Zoom, OnZoom)
import Task
import Html.Attributes
import Elements exposing
    ( renderContainer, renderContainerSelected
    , markerDot, innerGrid, grid, gridRect, edgeBetweenContainers, edgeStrokeWidthExtend, gridCellSize
    )
import Html.Events.Extra.Mouse exposing (Event)
import DomainDecoder exposing (domainDecoder, viewsDecoder, relationDecoder, getNameByKey)
import Dict exposing (Dict)
import Domain exposing (..)

port messageReceiver : (String -> msg) -> Sub msg

port sendMessage : String -> Cmd msg



main : Program () Model Msg
main =
  Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }

init : () -> ( Model, Cmd Msg )
init _ =
    (Model (SplitPane.init Horizontal) Init, getElementPosition)

type alias Model =
    { pane : SplitPane.State
    , root : Root
    }


type Msg
    = ZoomMsg OnZoom
    | Resize
    | ReceiveElementPosition (Result Dom.Error Dom.Element)
    | DragViewElementStart ViewElementKey ( Float, Float )
    | ClickEdgeStart ViewRelationKey ( Float, Float )
    | DragPointStart ViewRelationPointKey ( Float, Float )
    | RemovePoint ViewRelationPointKey
    | DragAt ( Float, Float )
    | DragEnd
    | PaneMsg SplitPane.Msg
    | MonacoEditorValueChanged String
    | MonacoSendValue String
    | NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.root of
        Init ->
            case msg of
                ReceiveElementPosition (Ok { element }) ->
                    ( { model | root = Ready
                        { drag = Nothing
                        , pointDrag = Nothing
                        , element = element
                        , zoom = initZoom element
                        , views = Dict.empty
                        , selectedView = Nothing
                        }
                    }
                    , Cmd.none
                    )

                ReceiveElementPosition (Err _) ->
                    ( model, Cmd.none )

                PaneMsg paneMsg ->
                    ( { model | pane = SplitPane.update paneMsg model.pane }, Cmd.none )

                Resize ->
                    ( model, getElementPosition )

                _ ->  ( model, Cmd.none )
        Ready state ->
            case msg of
                ReceiveElementPosition (Ok { element }) ->
                    ( { model | root = Ready { state | element = element } }
                    , Cmd.none
                    )

                ReceiveElementPosition (Err _) ->
                    ( model, Cmd.none )

                MonacoEditorValueChanged val ->
                    let
                        domain = D.fromString domainDecoder val
                        views = D.fromString viewsDecoder val
                    in
                    case views of
                        Ok vs ->
                            ( { model | root = Ready { state | views = vs, selectedView = Dict.keys vs |> List.head } }, Cmd.none )

                        _ -> (model, Cmd.none)

                MonacoSendValue val ->
                    ( model, sendMessage val )

                Resize ->
                    ( model, getElementPosition )

                ZoomMsg zoomMsg ->
                    ( { model | root = Ready { state | zoom = Zoom.update zoomMsg state.zoom } }
                    , Cmd.none
                    )

                DragViewElementStart viewElementKey xy ->
                    let
                        (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.element.x, state.element.y) xy
                        delta = getCurrentView state.selectedView state.views
                            |> getViewElementsOfCurrentView
                            |> getElement viewElementKey
                            |> Maybe.map (\ve -> ( shiftedStartX - ve.x, shiftedStartY - ve.y ))
                            |> Maybe.withDefault ( 0, 0 )
                    in
                    ( { model | root = Ready
                        { state | drag = Just { start = xy, current = xy, index = viewElementKey, delta = delta } }
                    }
                    , Cmd.none
                    )

                DragPointStart (viewElementKey, relation, pointIndex) xy ->
                    let
                        (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.element.x, state.element.y) xy

                        delta = getCurrentView state.selectedView state.views
                            |> getViewElementsOfCurrentView
                            |> getElement viewElementKey
                            |> Maybe.map .relations
                            |> Maybe.andThen (Dict.get relation)
                            |> Maybe.map (List.drop pointIndex)
                            |> Maybe.andThen List.head
                            |> Maybe.map (\tp -> ( shiftedStartX - tp.x, shiftedStartY - tp.y ))
                            |> Maybe.withDefault ( 0, 0 )
                    in
                    ( { model | root = Ready
                        { state | pointDrag
                            = Just { start = xy, current = xy, index = (viewElementKey, relation, pointIndex), delta = delta } }
                    }
                    , Cmd.none
                    )

                RemovePoint (viewElementKey, relation, pointIndex) ->
                    let
                        removePointAtIndex list = List.take pointIndex list ++ List.drop (pointIndex + 1) list
                        
                        updatedViews =
                            updatePointsInRelations relation removePointAtIndex
                            |> updateRelationsInElements viewElementKey
                            |> updateElementsInViews state.selectedView state.views
                    in
                    ( { model | root = Ready { state | views = updatedViews } }, Cmd.none )

                ClickEdgeStart (viewElementKey, relation) xy ->
                    let
                        spxy = shiftPosition state.zoom (state.element.x, state.element.y) xy

                        currentView = getCurrentView state.selectedView state.views

                        sourceXY = currentView |> getViewElementsOfCurrentView
                            |> getElement viewElementKey
                            |> Maybe.map (\s -> (s.x, s.y))
                        
                        targetXY = currentView |> getViewElementsOfCurrentView
                            |> getElement (Tuple.first relation)
                            |> Maybe.map (\s -> (s.x, s.y))

                    in
                    case (sourceXY, targetXY, currentView) of
                        (Just sxy, Just txy, Just cv) ->
                            let
                                magicIntMax = maxSafeInteger
                                allPoints = sxy :: (getViewRelationPoints (viewElementKey, relation) cv) ++ [ txy ]

                                -- as the actual edge is wider then visible, we are extending the search area
                                extendPoints (x1, y1) (x2, y2) =
                                    let
                                        extend v1 v2 =
                                            if v1 < v2 || v1 == v2 then
                                                (v1 - edgeStrokeWidthExtend, v2 + edgeStrokeWidthExtend)
                                            else
                                                (v2 - edgeStrokeWidthExtend, v1 + edgeStrokeWidthExtend)

                                        (ux1, ux2) = extend x1 x2
                                        (uy1, uy2) = extend y1 y2
                                    in
                                    ((ux1, uy1), (ux2, uy2))

                                (_ , (insertAfterValue, _)) = 
                                    List.foldr
                                    (\currentPoint -> \(previousPoint, (insertAfterPoint, val)) ->
                                        let
                                            z = distanceToLine spxy (currentPoint , previousPoint)

                                            (extendedA, extendedPrev) = extendPoints currentPoint previousPoint
                                        in
                                        if not (isNaN z) && betweenPoints spxy (extendedA, extendedPrev) && z < val then
                                            (currentPoint, (currentPoint, z))
                                        else 
                                            (currentPoint, (insertAfterPoint, val))
                                    )
                                    (txy, (txy, magicIntMax))
                                    allPoints

                                updatedList = List.foldr
                                    (\a -> \b ->
                                        if insertAfterValue == a then
                                            a :: spxy :: b
                                        else
                                            a :: b
                                    )
                                    []
                                    allPoints
                                    |> List.drop 1
                                    |> List.reverse
                                    |> List.drop 1
                                    |> List.reverse

                                updatedPoints = \_ -> updatedList |> List.map (\(x, y) -> ViewRelationPoint x y)
                                
                                updatedViewsValue =
                                    updatedPoints
                                    |> updatePointsInRelations relation 
                                    |> updateRelationsInElements viewElementKey
                                    |> updateElementsInViews state.selectedView state.views

                            in
                            ( { model | root = Ready { state | views = updatedViewsValue } }, Cmd.none )
                        _ -> ( model, Cmd.none )

                DragAt xy ->
                    let
                        (updatedRoot, cmdMsg) = handleDragAt xy state
                    in
                    ( { model | root = updatedRoot }, cmdMsg)

                DragEnd ->
                    case (state.drag, state.pointDrag) of
                        (Just _, Nothing) ->
                            ( { model | root = Ready { state | drag = Nothing } }, Cmd.none)
                        (Nothing, Just _) ->
                            ( { model | root = Ready { state | pointDrag = Nothing } }, Cmd.none)
                        _ ->
                            ( { model | root = Ready state }, Cmd.none )

                PaneMsg paneMsg ->
                    ( { model | pane = SplitPane.update paneMsg model.pane }, Cmd.none )

                NoOp -> ( model, Cmd.none )


view : Model -> Html Msg
view { pane, root } =
    div []
        [ SplitPane.view
            viewConfig
            (svgView root)
            (div [ id "monaco", Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%"] [])
            pane
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
    let
        dragSubscriptions : Sub Msg
        dragSubscriptions =
            Sub.batch
                [ Events.onMouseMove
                    (Decode.map (.clientPos >> DragAt) Mouse.eventDecoder)
                , Events.onMouseUp
                    (Decode.map (\_ -> DragEnd) Mouse.eventDecoder)
                ]

        readySubscriptions : AppState -> Sub Msg
        readySubscriptions { drag, pointDrag, zoom } =
            Sub.batch
                [ Zoom.subscriptions zoom ZoomMsg
                , case (drag, pointDrag) of
                    (Just _, Nothing) ->
                        dragSubscriptions

                    (Nothing, Just _) ->
                        dragSubscriptions

                    _ ->
                        Sub.none
                ]
    in
    Sub.batch
        [ case model.root of
            Init ->
                Sub.none

            Ready state ->
                readySubscriptions state
        , Events.onResize (\_ -> \_ -> Resize)
        , Sub.map PaneMsg <| SplitPane.subscriptions model.pane
        , messageReceiver MonacoEditorValueChanged
        ]

type Root
    = Init
    | Ready AppState

type alias SubPathEdge = 
    { points : List (Float, Float)
    }

type alias AppState =
    { drag : Maybe (Drag ViewElementKey)
    , pointDrag : Maybe (Drag ViewRelationPointKey)
    -- , graph : Graph Container SubPathEdge
    , views : Dict String View
    , selectedView : Maybe String
    , zoom : Zoom
    -- The position and dimensions of the svg element.
    , element : Element
    }



-- Select information
type alias Drag a =
    { current : ( Float, Float ) -- current mouse position
    , index : a -- selected node id or point index
    , start : ( Float, Float ) -- start mouse position
    , delta : ( Float, Float ) -- delta between start and node center to do ajustment during movement
    }

-- SVG element position and size in DOM
type alias Element =
    { height : Float
    , width : Float
    , x : Float
    , y : Float
    }

elementId : String
elementId =
    "main-graph"

getElementPosition : Cmd Msg
getElementPosition =
    Task.attempt ReceiveElementPosition (Dom.getElement elementId)


{-| is it enough to put the point ?
-}
betweenPoints : (Float, Float) -> ((Float, Float), (Float, Float)) -> Bool
betweenPoints (x, y) ((x1, y1), (x2, y2)) =
    let
        isBetween v v1 v2 =
            if v1 < v2 then
                v1 < v && v < v2
            else if v1 == v2 then
                v1 == v && v == v2
            else
                v2 < v && v < v1
    in
    isBetween x x1 x2 && isBetween y y1 y2

{-| calculate distance to the line created by two points
it is not work good as it is required to calculcate distance to line segment
not line
TODO
-}
distanceToLine : (Float, Float) -> ((Float, Float), (Float, Float)) -> Float
distanceToLine (x, y) ((x1, y1), (x2, y2)) =
    -- distance to the line
    abs ((x2 - x1) * (y1 - y) - (x1 - x) * (y2 - y1)) / sqrt ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))

initZoom : Element -> Zoom
initZoom element =
    Zoom.init { width = element.width, height = element.height }
        |> Zoom.scaleExtent 0.1 2

floatRemainderBy : Float -> Float -> Float
floatRemainderBy divisor n =
  n - toFloat(truncate (n / divisor)) * divisor

handleDragAt : ( Float, Float ) -> AppState -> ( Root, Cmd Msg )
handleDragAt xy ({ drag, pointDrag } as state) =
    case (drag, pointDrag) of
        (Just { start, index, delta }, Nothing) ->
            ( Ready
                { state
                    | drag = Just { start = start, current = xy, index = index, delta = delta }
                    , views = updateElementPosition delta index xy state
                }
            , Cmd.none
            )

        (Nothing, Just { start, index, delta }) ->
            ( Ready
                { state
                    | pointDrag = Just { start = start, current = xy, index = index, delta = delta}
                    , views = updatePointPosition delta index xy state
                }
            , Cmd.none
            )

        _ ->
            ( Ready state, Cmd.none )


updatePointPosition : (Float, Float) -> ViewRelationPointKey -> ( Float, Float ) -> AppState -> Dict String View
updatePointPosition (deltaX, deltaY) (viewElementKey, relation, viewRelationPointIndex) xy state =
    let
        (shiftedX, shiftedY) = shiftPosition state.zoom (state.element.x, state.element.y) xy
        updateXY i viewRelationPoint =
            if i == viewRelationPointIndex then
                { viewRelationPoint | x = shiftedX - deltaX, y = shiftedY - deltaY }
            else
                viewRelationPoint

        updatedPoints = List.indexedMap updateXY
    in
    updatePointsInRelations relation updatedPoints
    |> updateRelationsInElements viewElementKey 
    |> updateElementsInViews state.selectedView state.views

updateElementPosition : (Float, Float) -> ViewElementKey -> ( Float, Float ) -> AppState -> Dict String View
updateElementPosition (deltaX, deltaY) viewElementKey xy state =
    let
        (shiftedX, shiftedY) = shiftPosition state.zoom (state.element.x, state.element.y) xy
        updatedElements : Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement
        updatedElements =
            Dict.update viewElementKey <| Maybe.map (\ve -> { ve | x = shiftedX - deltaX, y = shiftedY - deltaY } )
    in
    updateElementsInViews state.selectedView state.views updatedElements

{-| The mouse events for drag start, drag at and drag end read the client
position of the cursor, which is relative to the browser viewport. However,
the node positions are relative to the svg viewport. This function adjusts the
coordinates accordingly. It also takes the current zoom level and position
into consideration.
-}
shiftPosition : Zoom -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
shiftPosition zoom (elementX, elementY) ( clientX, clientY ) =
    let
        zoomRecord =
            Zoom.asRecord zoom
    in
    ( (clientX - zoomRecord.translate.x - elementX) / zoomRecord.scale
    , (clientY - zoomRecord.translate.y - elementY) / zoomRecord.scale
    )

viewConfig : ViewConfig Msg
viewConfig =
    createViewConfig
        { toMsg = PaneMsg
        , customSplitter = Nothing
        }

svgView : Root -> Html Msg
svgView model =
    let
        zoomEvents : List (Attribute Msg)
        zoomEvents =
            case model of
                Init ->
                    []

                Ready { zoom } ->
                    Zoom.events zoom ZoomMsg
        zoomTransformAttr : Attribute Msg
        zoomTransformAttr =
            case model of
                Init ->
                    class []

                Ready { zoom } ->
                    Zoom.transform zoom

        transform10 = 
            case model of
                Init -> gridCellSize
                Ready { zoom } ->
                    zoom |> Zoom.asRecord |> .scale |> (*) 10

        transform100 = transform10 * 10

        getXY =
            case model of
                Init -> ( 0, 0 )
                Ready { zoom } ->
                    zoom
                        |> Zoom.asRecord
                        |> .translate
                        |> (\t -> (floatRemainderBy transform100 t.x, floatRemainderBy transform100 t.y))

        ( x, y ) = getXY
    in
    svg
        [ id elementId
        , Attrs.width <| Percent 100
        , Attrs.height <| Percent 100
        -- TODO Disable right click menu
        --, Mouse.onContextMenu (\_ -> NoOp)
        ]
        [ defs []
            [ innerGrid transform10
            , grid x y transform100
            , markerDot -- for circle in edges
            ]
        , gridRect zoomEvents
        , g
            [ zoomTransformAttr ]
            [ renderGraph model
            ]
        ]


-- Grid comes from https://gist.github.com/leonardfischer/fc4d1086c64b2c1324c93dcd0beed004


renderGraph : Root -> Svg Msg
renderGraph model =
    case model of
        Init ->
            text ""

        Ready { drag, pointDrag, views, selectedView } ->
            case getCurrentView selectedView views of
                Just v ->
                    g []
                        [ getEdges v
                            |> Debug.todo "called at each rendering and can be cashed?"
                            |> List.map
                                (\edge ->
                                    let
                                        viewRelationKey = Tuple.pair edge.source.name (edge.target.name, edge.description)
                                    in
                                    case pointDrag of
                                        Just { index } ->
                                            let
                                                (viewElementKey, relation, viewRelationPointIndex) = index
                                                targetName = Tuple.first relation
                                            in
                                            if edge.source.name == viewElementKey && edge.target.name == targetName then
                                                linkElement viewRelationKey (Just viewRelationPointIndex) edge
                                            else
                                                linkElement viewRelationKey Nothing edge
                                        Nothing ->
                                            linkElement viewRelationKey Nothing edge
                                )
                            |> g [ class [ "links" ] ]
                        , getContainers v
                            |> List.map (drawContainer drag)
                            |> g [ class [ "nodes" ] ]
                        ]
                Nothing -> text ""

drawContainer : Maybe (Drag ViewElementKey) -> Container -> Svg Msg
drawContainer drag container =
    let
        mouseDownAttr
            = Mouse.onDown
            <| onlyMainButton
            >> Maybe.map (DragViewElementStart container.name)
            >> Maybe.withDefault NoOp
    in
    case drag of
        Just { index } ->
            if index == container.name then
                renderContainerSelected container mouseDownAttr
            else
                renderContainer container mouseDownAttr
        Nothing ->
            renderContainer container mouseDownAttr

linkElement : ViewRelationKey -> Maybe Int -> Edge -> Svg Msg
linkElement viewRelationKey selectedIndex edge =
    edgeBetweenContainers
        edge
        selectedIndex
        (Mouse.onDown <| onlyMainButton >> Maybe.map (ClickEdgeStart viewRelationKey) >> Maybe.withDefault NoOp)
        (onMouseDownPoint viewRelationKey)

onlyMainButton : Event -> Maybe (Float, Float)
onlyMainButton e =
    case e.button of
        Mouse.MainButton -> Just e.clientPos
        _ -> Nothing

onMouseDownPoint : ViewRelationKey -> Int -> Attribute Msg
onMouseDownPoint (viewRelationElementKey, relation) index =
    let
        viewRelationPointKey = (viewRelationElementKey, relation, index)
    in
    Mouse.onDown
        (\e ->
            case e.button of
                Mouse.MainButton -> DragPointStart viewRelationPointKey e.clientPos
                Mouse.SecondButton -> RemovePoint viewRelationPointKey
                _ -> NoOp
        )
