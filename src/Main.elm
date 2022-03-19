module Main exposing (..)

import Basics.Extra exposing (maxSafeInteger)
import SplitPane exposing (Orientation(..), ViewConfig, createViewConfig)
import Browser exposing (Document)
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Browser.Events as Events
import Json.Decode as Decode
import Yaml.Decode as D
import Html exposing (Html, div, text, a)
import Html.Attributes exposing (href, style)
import Html.Events.Extra.Mouse as Mouse exposing (Event)
import TypedSvg exposing (svg, defs, g)
import TypedSvg.Attributes as Attrs exposing ( class,  x, y, id)
import TypedSvg.Types exposing ( Length(..))
import TypedSvg.Core exposing (Svg, Attribute)
-- import Graph exposing (Graph, Node, Edge, NodeContext, NodeId, Adjacency)
import Zoom exposing (Zoom, OnZoom)
import Task
import Elements exposing
    ( renderContainer, renderContainerSelected
    , markerDot, innerGrid, grid, gridRect, edgeBetweenContainers, edgeStrokeWidthExtend, gridCellSize
    , selectItemsRect
    )
import DomainDecoder exposing (..)
import Dict exposing (Dict)
import Domain exposing (..)
import Url exposing (Url)
import Route exposing (Route)
import JsInterop exposing (initMonacoResponse, removePoint, encodeRemovePoint, monacoEditorValue, initMonacoRequest
    , RemovePointMessage, PointMessage, encodePointMessage, addPoint, UpdateElementPositionMessage, updateElementPosition
    , encodeUpdateElementPosition, updatePointPosition)
import Index exposing (index)


initMonaco : Cmd Msg
initMonaco = initMonacoResponse ()

main : Program () Model Msg
main =
  Browser.application
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    , onUrlRequest = ClickedLink
    , onUrlChange = ChangedUrl
    }

init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey  =
    changeRouteTo (Route.fromUrl url) navKey


getNavKey : Model -> Nav.Key
getNavKey model =
    case model of
        Home key -> key
        Editor key _ -> key

changeRouteTo : Maybe Route -> Nav.Key -> ( Model, Cmd Msg )
changeRouteTo maybeRoute key =
    case maybeRoute of
        Nothing ->
            ( Home key, Cmd.none )

        Just Route.Home ->
            ( Home key, Cmd.none )

        Just Route.Editor ->
            ( Editor key (EditorModel (SplitPane.init Horizontal) Init ""), Cmd.batch [ getElementPosition, initMonaco ] )


type alias EditorModel =
    { pane : SplitPane.State
    , root : Root
    , errors : String
    }

type Model
    = Home Nav.Key
    | Editor Nav.Key EditorModel



type Msg
    = ZoomMsg OnZoom
    | Resize
    | ReceiveElementPosition (Result Dom.Error Dom.Element)
    | DragViewElementStart ViewElementKey ( Float, Float )
    | ClickEdgeStart ViewRelationKey ( Float, Float )
    | DragPointStart ViewRelationPointKey ( Float, Float )
    | RemovePoint ViewRelationPointKey
    | MouseMove ( Float, Float )
    | MouseMoveEnd
    | PaneMsg SplitPane.Msg
    | MonacoEditorValueReceived String
    | InitMonacoRequestReceived ()
    | SetPanMode Bool
    | SelectItemsStart (Float, Float)
    | NoOp
    | ClickedLink Browser.UrlRequest
    | ChangedUrl Url

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (msg, model) of
        (ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (getNavKey model) (Url.toString url)
                    )

                Browser.External href ->
                    let
                        _ = Debug.log "href" href
                    in
                    ( model
                    , Nav.load href
                    )

        (ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) (getNavKey model)

        (_, Home _) ->
            (model, Cmd.none)
        (_, Editor navKey editorModel ) ->
            case editorModel.root of
                Init ->
                    case msg of
                        ReceiveElementPosition (Ok { element }) ->
                            ( { editorModel | root = Ready
                                { drag = Nothing
                                , element = element
                                , zoom = initZoom element
                                , views = Dict.empty
                                , selectedView = Nothing
                                , panMode = False
                                , brush = Nothing
                                , selectedItems = []
                                , domain = Nothing
                                }
                            } |> Editor navKey
                            , Cmd.none
                            )

                        ReceiveElementPosition (Err _) ->
                            ( model, Cmd.none )

                        PaneMsg paneMsg ->
                            ( { editorModel | pane = SplitPane.update paneMsg editorModel.pane } |> Editor navKey, Cmd.none )

                        Resize ->
                            ( model, getElementPosition )

                        _ ->  ( model, Cmd.none )
                Ready state ->
                    case msg of
                        SelectItemsStart xy ->
                            let
                                shiftedXY = shiftPosition state.zoom (0, 0) xy
                            in
                            ( { editorModel | root = Ready { state | brush = Just <| Brush shiftedXY shiftedXY }  } |> Editor navKey
                            , Cmd.none
                            )

                        SetPanMode value ->
                            ( { editorModel | root = Ready { state | panMode = value } } |> Editor navKey
                            , Cmd.none
                            )

                        ReceiveElementPosition (Ok { element }) ->
                            ( { editorModel | root = Ready { state | element = element } } |> Editor navKey
                            , Cmd.none 
                            )

                        ReceiveElementPosition (Err _) ->
                            ( model, Cmd.none )

                        InitMonacoRequestReceived _ ->
                            (model, initMonaco)

                        MonacoEditorValueReceived val ->
                            case D.fromString rdbDecoder val of
                                Ok (domain, views) ->
                                    (   { editorModel
                                        | errors = ""
                                        , root = Ready { state | views = views, domain = Just domain, selectedView = Dict.keys views |> List.head }
                                        } |> Editor navKey
                                    , Cmd.none
                                    )

                                Err err ->
                                    case err of
                                        D.Parsing errMsg -> ( { editorModel | errors = errMsg } |> Editor navKey, Cmd.none)
                                        D.Decoding errMsg -> ( { editorModel | errors = errMsg } |> Editor navKey, Cmd.none)

                        Resize ->
                            ( model, getElementPosition )

                        ZoomMsg zoomMsg ->
                            ( { editorModel | root = Ready { state | zoom = Zoom.update zoomMsg state.zoom } } |> Editor navKey
                            , Cmd.none
                            )

                        DragViewElementStart viewElementKey xy ->
                            let
                                (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.element.x, state.element.y) xy

                                selectedElementKeys = getSelectedElementKeysAndDeltas state.selectedItems
                                    |> List.map Tuple.first

                                isWithinAlreadySelected = selectedElementKeys
                                    |> List.member viewElementKey

                                elementsOfCurrentView = getCurrentView state.selectedView state.views
                                    |> getViewElementsOfCurrentView

                                updatedSelectedItems = 
                                    if List.isEmpty state.selectedItems || not isWithinAlreadySelected then
                                        elementsOfCurrentView
                                            |> getElement viewElementKey
                                            |> Maybe.map (\ve -> ( shiftedStartX - ve.x, shiftedStartY - ve.y ))
                                            |> SelectedItem (ElementKey viewElementKey)
                                            |> List.singleton
                                    else
                                        updateSelectedItemsDeltas elementsOfCurrentView (shiftedStartX, shiftedStartY) state.selectedItems
                            in
                            ( { editorModel | root = Ready
                                { state
                                | drag = Just { start = xy, current = xy }
                                , selectedItems = updatedSelectedItems
                                }
                            } |> Editor navKey
                            , Cmd.none
                            )

                        DragPointStart viewRelationPointKey xy ->
                            let
                                (viewElementKey, relation, pointIndex) = viewRelationPointKey
                                (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.element.x, state.element.y) xy

                                selectedPointKeys = getSelectedPointKeysAndDeltas state.selectedItems
                                    |> List.map Tuple.first

                                isWithinAlreadySelected = selectedPointKeys
                                    |> List.member viewRelationPointKey

                                elementsOfCurrentView = getCurrentView state.selectedView state.views
                                    |> getViewElementsOfCurrentView

                                updatedSelectedItems = 
                                    if List.isEmpty state.selectedItems || not isWithinAlreadySelected then
                                        elementsOfCurrentView
                                            |> getElement viewElementKey
                                            |> getRelationPoints relation
                                            |> getPoint pointIndex
                                            |> Maybe.map (\tp -> ( shiftedStartX - tp.x, shiftedStartY - tp.y ))
                                            |> SelectedItem (PointKey viewRelationPointKey)
                                            |> List.singleton
                                    else
                                        updateSelectedItemsDeltas elementsOfCurrentView (shiftedStartX, shiftedStartY) state.selectedItems
                            in
                            ( { editorModel | root = Ready
                                { state
                                | drag = Just { start = xy, current = xy }
                                , selectedItems = updatedSelectedItems
                                }
                            } |> Editor navKey
                            , Cmd.none
                            )

                        RemovePoint (viewElementKey, relation, pointIndex) ->
                            let
                                removePointAtIndex list = List.take pointIndex list ++ List.drop (pointIndex + 1) list
                                
                                updatedViews =
                                    updatePointsInRelations relation removePointAtIndex
                                    |> updateRelationsInElements viewElementKey
                                    |> updateElementsInViews state.selectedView state.views

                                removePointMessage = RemovePointMessage viewElementKey relation pointIndex
                            in
                            ( { editorModel | root = Ready { state | views = updatedViews } } |> Editor navKey
                            , removePointMessage |> encodeRemovePoint |> removePoint -- (viewElementKey ++ "|" ++ getStringFromRelation relation ++ "|del|" ++ String.fromInt pointIndex )
                            )

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

                                        (listWithNewPoint, indexOfNewPoint, _ ) = List.foldr
                                            (\a -> \(b, i, found) ->
                                                if insertAfterValue == a then
                                                    (a :: spxy :: b, i, True)
                                                else
                                                    (a :: b, if found then i else i + 1, found)
                                            )
                                            ([], 0, False)
                                            allPoints

                                        updatedList = listWithNewPoint
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

                                        addPointMessage = PointMessage viewElementKey relation (List.length updatedList - indexOfNewPoint) spxy

                                    in
                                    ( { editorModel | root = Ready { state | views = updatedViewsValue } } |> Editor navKey
                                    , addPointMessage |> encodePointMessage |> addPoint
                                    )
                                _ -> ( model, Cmd.none )

                        MouseMove xy ->
                            let
                                (updatedRoot, cmdMsg) = handleMouseMove xy state
                            in
                            ( { editorModel | root = updatedRoot } |> Editor navKey, cmdMsg)

                        MouseMoveEnd ->
                            case state.brush of 
                                Just _ ->
                                    ( { editorModel | root = Ready { state | brush = Nothing } } |> Editor navKey
                                    , Cmd.none
                                    )
                                Nothing ->
                                    case state.drag of
                                        Just _ ->
                                            ( { editorModel | root = Ready { state | drag = Nothing, selectedItems = [] } } |> Editor navKey
                                            , updateMonacoValues state.selectedView state.views state.selectedItems
                                            )
                                        _ ->
                                            ( model, Cmd.none )

                        PaneMsg paneMsg ->
                            ( { editorModel | pane = SplitPane.update paneMsg editorModel.pane } |> Editor navKey
                            , Cmd.none
                            )

                        _ -> ( model, Cmd.none )

updateSelectedItemsDeltas : Maybe (Dict ViewElementKey ViewElement) -> (Float, Float) -> List SelectedItem -> List SelectedItem
updateSelectedItemsDeltas viewElementsOfCurrentView (shiftedStartX, shiftedStartY) selectedItems =
    let
        selectedPointKeys = getSelectedPointKeysAndDeltas selectedItems
            |> List.map Tuple.first

        selectedElementKeys = getSelectedElementKeysAndDeltas selectedItems
            |> List.map Tuple.first

        elementIsWithinAlreadySelected vek _ =
            List.member vek selectedElementKeys

        pointIsWithinAlreadySelected vpk =
            List.member vpk selectedPointKeys
        selectedElementsWithDeltas = viewElementsOfCurrentView
            |> Maybe.map (Dict.filter elementIsWithinAlreadySelected)
            |> Maybe.map Dict.toList
            |> Maybe.withDefault []
            |> List.map (\(vek, ve) -> SelectedItem (ElementKey vek) (Just ( shiftedStartX - ve.x, shiftedStartY - ve.y )))
        selectedPointsWithDeltas = viewElementsOfCurrentView
            |> Maybe.map Dict.toList
            |> Maybe.withDefault []
            |> List.concatMap (\(vek, ve) -> ve.relations |> Dict.toList |> List.map (Tuple.pair vek))
            |> List.concatMap (\(vek, (r, points) ) -> points |> List.indexedMap (\i point -> ((vek, r, i), point)))
            |> List.filter (\(vpk, _) -> pointIsWithinAlreadySelected vpk)
            |> List.map (\(vpk, point) -> SelectedItem (PointKey vpk) (Just ( shiftedStartX - point.x, shiftedStartY - point.y )))
    in
        selectedElementsWithDeltas ++ selectedPointsWithDeltas

updateMonacoValues : Maybe String -> Dict String View -> List SelectedItem -> Cmd msg
updateMonacoValues selectedView views selectedItems =
    let
        createMessage (elementKey, element) =
            UpdateElementPositionMessage elementKey (element.x, element.y)

        createPointMessage (viewRelationPointKey, viewRelationPoint) =
            let
                (viewElementKey, relation, viewRelationPointIndex) = viewRelationPointKey
            in
            PointMessage viewElementKey relation viewRelationPointIndex (viewRelationPoint.x, viewRelationPoint.y)
        viewElements =
            getCurrentView selectedView views
            |> getViewElementsOfCurrentView

        currentViewElementsXY = viewElements
            |> getElements (getSelectedElementKeysAndDeltas selectedItems |> List.map Tuple.first)

        currentRelationPointXY = viewElements
            |> getPoints (getSelectedPointKeysAndDeltas selectedItems |> List.map Tuple.first)
        
        updateElementPositionMessages = currentViewElementsXY
            |> List.map (createMessage >> encodeUpdateElementPosition >> updateElementPosition)

        updateElementPointsPositionMessages = currentRelationPointXY
            |> List.map (createPointMessage >> encodePointMessage >> updatePointPosition)
    in
    (updateElementPositionMessages ++ updateElementPointsPositionMessages)
        |> Cmd.batch

view : Model -> Document Msg
view model =
    case model of
        Home _ ->
            { title = "RDB Model"
            , body = [ index ]
            }
        Editor _ { pane, root } ->
            { title = "RDB Model Editor"
            , body =
                [ div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
                    [ SplitPane.view
                        viewConfig
                        (svgView root)
                        (div [ id "monaco", Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%"] [])
                        pane
                    ]
                ]
            }

subscriptions : Model -> Sub Msg
subscriptions model =
    let
        dragSubscriptions : Sub Msg
        dragSubscriptions =
            Sub.batch
                [ Events.onMouseMove
                    (Decode.map (.clientPos >> MouseMove) Mouse.eventDecoder)
                , Events.onMouseUp
                    (Decode.map (\_ -> MouseMoveEnd) Mouse.eventDecoder)
                ]

        readySubscriptions : AppState -> Sub Msg
        readySubscriptions { zoom, brush, drag } =
            Sub.batch
                [ Zoom.subscriptions zoom ZoomMsg
                , case (brush, drag) of
                    (Nothing, Nothing) -> Sub.none
                    _ ->
                        dragSubscriptions
                ]
    in
    Sub.batch
        [ case model of 
            Home _ -> Sub.none
            Editor _ { root } ->
                case root of
                    Init ->
                        Sub.none

                    Ready state ->
                        readySubscriptions state
        , Events.onResize (\_ -> \_ -> Resize)
        , Events.onKeyDown (keyDecoder |> setPanMode True)
        , Events.onKeyUp (keyDecoder |> setPanMode False)
        , case model of 
            Home _ -> Sub.none
            Editor _ { pane } ->
                Sub.map PaneMsg <| SplitPane.subscriptions pane
        , monacoEditorValue MonacoEditorValueReceived
        , initMonacoRequest InitMonacoRequestReceived
        ]




keyDecoder : Decode.Decoder String
keyDecoder =
  Decode.field "key" Decode.string

setPanMode : Bool -> Decode.Decoder String -> Decode.Decoder Msg
setPanMode value =
    Decode.map (\key -> if key == "Control" then SetPanMode value else NoOp)

type Root
    = Init
    | Ready AppState

type alias SubPathEdge = 
    { points : List (Float, Float)
    }

type alias AppState =
    { drag : Maybe Drag
    -- , graph : Graph Container SubPathEdge
    , views : Dict String View
    , selectedView : Maybe String
    , zoom : Zoom
    -- The position and dimensions of the svg element.
    , element : Element
    , panMode : Bool
    , brush : Maybe Brush
    , selectedItems : List SelectedItem
    , domain : Maybe Domain
    }

type alias Brush =
    { end : ( Float, Float ) -- current mouse position
    , start : ( Float, Float ) -- start mouse position
    }

-- Select information
type alias Drag =
    { current : ( Float, Float ) -- current mouse position
    , start : ( Float, Float ) -- start mouse position
    }

type alias SelectedItem =
    { key : ViewItemKey -- selected node id or point index
    , delta : Maybe (Float, Float) -- delta between start and node center to do ajustment during movement
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

handleMouseMove : ( Float, Float ) -> AppState -> ( Root, Cmd Msg )
handleMouseMove xy ({ drag, brush, selectedItems } as state) =
    case brush of
        Just b ->
            let
                shiftedXY = shiftPosition state.zoom (0, 0) xy
                updatedBrush = { b | end = shiftedXY }
                elementKeysWithinBrush = getCurrentView state.selectedView state.views
                    |> getViewElementsOfCurrentView
                    |> getViewElementKeysByCondition (elementWithinBrush updatedBrush)
                    |> List.map (\i -> SelectedItem (ElementKey i) Nothing)

                pointKeysWithinBrush = getCurrentView state.selectedView state.views
                    |> getViewElementsOfCurrentView
                    |> getElementAndItsKeys
                    |> List.concatMap (\(k, v) -> v.relations |> Dict.toList |> List.map (\(relation, points) -> (k, relation, points)))
                    |> List.concatMap (\(k, relation, points) -> points |> getViewPointKeysByCondition (pointWithinBrush updatedBrush) |> List.map (\pointIndex -> (k, relation, pointIndex)))
                    |> List.map (\i -> SelectedItem (PointKey i) Nothing)
            in
            ( Ready { state | brush = Just updatedBrush, selectedItems = elementKeysWithinBrush ++ pointKeysWithinBrush }
            , Cmd.none
            )
        Nothing ->
            case drag of
                Just { start } ->
                    ( Ready
                        { state
                            | drag = Just { start = start, current = xy }
                            , views = updateElementAndPointPosition selectedItems xy state
                        }
                    , Cmd.none
                    )

                _ ->
                    ( Ready state, Cmd.none )


elementWithinBrush : Brush -> ViewElementKey -> ViewElement -> Bool
elementWithinBrush { start, end } _ {x , y} =
    let
        (startX1, startY1) = start
        (endX2, endY2) = end
    in
    x > min startX1 endX2 && x < max startX1 endX2
        && y > min startY1 endY2 && y < max startY1 endY2

pointWithinBrush : Brush -> ViewRelationPoint -> Bool
pointWithinBrush { start, end } {x , y} =
    let
        (startX1, startY1) = start
        (endX2, endY2) = end
    in
    x > min startX1 endX2 && x < max startX1 endX2
        && y > min startY1 endY2 && y < max startY1 endY2

updateElementAndPointPosition : List SelectedItem -> ( Float, Float ) -> AppState -> Dict String View
updateElementAndPointPosition selectedItems xy state =
    let
        selectedElementDeltas = getSelectedElementKeysAndDeltas selectedItems
            |> List.filterMap (\(k, d) -> d |> Maybe.map (Tuple.pair k))

        selectedPointsDeltas = getSelectedPointKeysAndDeltas selectedItems
            |> List.filterMap (\(k, d) -> d |> Maybe.map (Tuple.pair k))

        (shiftedX, shiftedY) = shiftPosition state.zoom (state.element.x, state.element.y) xy
        updateElementXY : ViewElementKey -> ViewElement -> ViewElement
        updateElementXY viewElementKey viewElement =
            let
                foundElement = selectedElementDeltas |> List.filter (\x -> Tuple.first x == viewElementKey) |> List.head
            in
            case foundElement of
                Just (_, (deltaX, deltaY)) ->
                    { viewElement | x = shiftedX - deltaX, y = shiftedY - deltaY }
                Nothing -> viewElement

        updatePointXY : List (ViewRelationPointIndex, (Float, Float)) -> Int -> ViewRelationPoint -> ViewRelationPoint
        updatePointXY selectedPointIndexes i viewRelationPoint =
            selectedPointIndexes
                |> List.filterMap (\(pointIndex, d) ->
                    if pointIndex == i then
                        Just d
                    else
                        Nothing)
                |> List.head
                |> Maybe.map (\(deltaX, deltaY) ->
                    { viewRelationPoint | x = shiftedX - deltaX, y = shiftedY - deltaY }
                )
                |> Maybe.withDefault viewRelationPoint

        updatedPoints viewElementKey =
            Dict.map (\relation points ->
                let
                    updatePointXYUsingSelectedPoints = selectedPointsDeltas
                        |> List.filterMap (\((vek, rel, pointIndex), delta) ->
                            if vek == viewElementKey && rel == relation then
                                Just (pointIndex, delta)
                            else
                                Nothing
                        )
                        |> updatePointXY
                in
                List.indexedMap updatePointXYUsingSelectedPoints points
            )

        updatedRelations : ViewElementKey -> ViewElement -> ViewElement
        updatedRelations viewElementKey viewElement =
            { viewElement | relations = updatedPoints viewElementKey viewElement.relations}

        updatedElements : Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement
        updatedElements =
            Dict.map (\viewElementKey ve ->
                updateElementXY viewElementKey ve
                |> updatedRelations viewElementKey 
            )
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
        selectItemsEvents : Attribute Msg
        selectItemsEvents = 
            mouseDownMain SelectItemsStart

        gridRectEvents : List (Attribute Msg)
        gridRectEvents =
            case model of
                Init ->
                    []

                Ready { zoom, panMode } ->
                    [Zoom.onDoubleClick zoom ZoomMsg, Zoom.onWheel zoom ZoomMsg] 
                        ++ (if panMode then Zoom.onDrag zoom ZoomMsg else [selectItemsEvents])

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
    div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
    [ svg
        [ id elementId
        , Attrs.width <| Percent 100
        , Attrs.height <| Percent 100
        -- TODO Disable right click menu
        , Mouse.onContextMenu (\_ -> NoOp)
        ]
        [ defs []
            [ innerGrid transform10
            , grid x y transform100
            , markerDot -- for circle in edges
            ]
        , gridRect gridRectEvents
        , g
            [ zoomTransformAttr ]
            [ renderCurrentView model
            , renderSelectRect model
            ]
        ]
    , div [ style "position" "fixed", style "bottom" "0", style "left" "0", style "font-size" "9px" ] [ text "v0.0.1"]
    ]
        


-- Grid comes from https://gist.github.com/leonardfischer/fc4d1086c64b2c1324c93dcd0beed004

renderSelectRect : Root -> Svg Msg
renderSelectRect model =
    case model of
        Init ->
            text ""

        Ready { brush } ->
            case brush of
                Just { start, end } ->
                    selectItemsRect start end
                Nothing ->
                    text ""


renderCurrentView : Root -> Svg Msg
renderCurrentView model =
    case model of
        Init ->
            text ""

        Ready { views, selectedView, panMode, selectedItems, domain } ->
            case (getCurrentView selectedView views, domain) of
                (Just v, Just d) ->
                    g []
                        [ getEdges (d, v)
                            -- |> Debug.todo "called at each rendering and can be cashed?"
                            |> List.map (drawEdge panMode selectedItems)
                            |> g [ class [ "links" ] ]
                        , getContainers (d, v)
                            |> List.map (drawContainer panMode selectedItems)
                            |> g [ class [ "nodes" ] ]
                        ]
                _ -> text ""

drawEdge : Bool -> List SelectedItem -> Edge -> Svg Msg
drawEdge panMode selectedItems edge =
    let
        getSelectedPointIndex vpk =
            if getViewRelationKeyFromViewRelationPointKey vpk == getViewRelationKeyFromEdge edge then
                let
                    (_, _, viewRelationPointIndex) = vpk
                in
                Just viewRelationPointIndex
            else
                Nothing
    in
    getSelectedPointKeysAndDeltas selectedItems
        |> List.map Tuple.first
        |> List.filterMap getSelectedPointIndex
        |> linkElement panMode edge

drawContainer : Bool -> List SelectedItem -> Container -> Svg Msg
drawContainer panMode selectedItems container =
    let
        mouseDownAttr =
            if panMode then
                Nothing
            else
                Just <| mouseDownMain (DragViewElementStart container.key)
        selectedElements = getSelectedElementKeysAndDeltas selectedItems
            |> List.map Tuple.first
    in
    if List.member container.key selectedElements then
        renderContainerSelected container mouseDownAttr
    else
        renderContainer container mouseDownAttr


getSelectedElementKeysAndDeltas : List SelectedItem -> List (ViewElementKey, Maybe (Float, Float))
getSelectedElementKeysAndDeltas =
    let
        extractViewElelementKeys v = 
            case v.key of
                ElementKey x -> Just (x, v.delta)
                PointKey _ -> Nothing
    in
    List.filterMap extractViewElelementKeys

getSelectedPointKeysAndDeltas : List SelectedItem -> List (ViewRelationPointKey, Maybe(Float, Float))
getSelectedPointKeysAndDeltas =
    let
        extractPointKeys v = 
            case v.key of
                PointKey x -> Just (x, v.delta)
                ElementKey _ -> Nothing
    in
    List.filterMap extractPointKeys

linkElement : Bool -> Edge -> List Int -> Svg Msg
linkElement panMode edge =
    let
        viewRelationKey = getViewRelationKeyFromEdge edge
    in
    edgeBetweenContainers
        edge
        (noOpIfPanMode panMode <| mouseDownMain (ClickEdgeStart viewRelationKey))
        (if panMode then Nothing else Just (onMouseDownPoint viewRelationKey))


noOpIfPanMode : Bool -> Attribute Msg -> Maybe (Attribute Msg)
noOpIfPanMode panMode ev =
    if panMode then
        Nothing
    else
        Just ev

onlyMainButton : Event -> Maybe (Float, Float)
onlyMainButton e =
    case e.button of
        Mouse.MainButton -> Just e.clientPos
        _ -> Nothing

mouseDownMain : ((Float, Float) -> Msg) -> Attribute Msg
mouseDownMain msg =
    Mouse.onDown <|
        onlyMainButton
        >> Maybe.map msg
        >> Maybe.withDefault NoOp

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
