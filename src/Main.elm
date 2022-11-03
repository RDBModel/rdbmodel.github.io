module Main exposing (..)

import Basics.Extra exposing (maxSafeInteger)
import SplitPane exposing (Orientation(..), ViewConfig, createViewConfig)
import Browser exposing (Document)
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Browser.Events as Events
import Json.Decode as Decode
import Yaml.Decode as D
import Html exposing (Html, div, text, a, button)
import Html.Attributes exposing (href, style)
import Html.Events
import TypedSvg exposing (svg, defs, g, path, circle, line)
import Html.Events.Extra.Mouse as Mouse exposing (Event)
import Task
import TypedSvg.Attributes as Attrs exposing ( class, x, y, id, d, viewBox, strokeWidth, stroke, fill, strokeLinecap, strokeLinejoin,
    cx, cy, r, x1, x2, y1, y2, width, height)
import TypedSvg.Types exposing ( Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import TypedSvg.Core exposing (Svg, Attribute)
import Zoom exposing (Zoom, OnZoom)
import Elements exposing
    ( renderContainer, renderContainerSelected
    , markerDot, innerGrid, grid, gridRect, edgeBetweenContainers, gridCellSize
    , selectItemsRect, extendPoints
    )
import DomainDecoder exposing (..)
import Dict exposing (Dict)
import Domain exposing (..)
import Url exposing (Url)
import Route exposing (Route)
import JsInterop exposing (initMonacoResponse, removePoint, encodeRemovePoint, monacoEditorValue, initMonacoRequest
    , RemovePointMessage, PointMessage, encodePointMessage, addPoint, UpdateElementPositionMessage, updateElementPosition
    , encodeUpdateElementPosition, updatePointPosition, updateMonacoValue, monacoEditorSavedValue)
import Index exposing (index)
import UndoList exposing (UndoList)
import Scale exposing (domain)
import JsInterop exposing (validationErrors)
import ViewControl
import Utils exposing (trimList)
import ViewNavigation

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

        Just (Route.Editor selectedView) ->
            ( Editor key (getEditorsModel selectedView), getMonacoElementPosition )

getEditorsModel : String -> EditorsModel
getEditorsModel selectedView =
    EditorsModel
        (SplitPane.init Horizontal)
        Init
        getUndoRedoMonacoValue
        (ViewControl.init selectedView)
        True
        ""

getUndoRedoMonacoValue : UndoRedoMonacoValue
getUndoRedoMonacoValue =
    MonacoValue Dict.empty Nothing "" |> UndoList.fresh

type alias EditorsModel =
    { pane : SplitPane.State
    , viewEditor : ViewEditor
    , monacoValue : UndoRedoMonacoValue
    , viewControl : ViewControl.Model
    , toReload : Bool
    , errors : String
    }

type alias MonacoValue =
    { views : Dict String View
    , domain : Maybe Domain
    , value : String
    }

type alias UndoRedoMonacoValue = UndoList MonacoValue

type Model
    = Home Nav.Key
    | Editor Nav.Key EditorsModel

type ZoomDirection
    = In
    | Out

type Msg
    = ZoomMsg OnZoom
    | ViewNavigation ViewNavigation.Msg
    | Resize
    | ReceiveElementPosition (Result Dom.Error Dom.Element)
    | ReceiveMonacoElementPosition (Result Dom.Error Dom.Element)
    | DragViewElementStart ViewElementKey ( Float, Float )
    | ClickEdgeStart ViewRelationKey ( Float, Float )
    | DragPointStart ViewRelationPointKey ( Float, Float )
    | RemovePoint ViewRelationPointKey
    | MouseMove ( Float, Float )
    | MouseMoveEnd
    | PaneMsg SplitPane.Msg
    | MonacoEditorValueReceived Bool String
    | InitMonacoRequestReceived ()
    | SetCtrlIsDown Bool
    | SelectItemsStart (Float, Float)
    | NoOp
    | ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | Undo
    | Redo
    | ViewControl ViewControl.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (msg, model) of
        (ReceiveMonacoElementPosition (Ok _ ), _) ->
            ( model
            , initMonaco
            )

        (ReceiveMonacoElementPosition (Err _), _) ->
            ( model, Cmd.none )

        (ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (getNavKey model) (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        (ChangedUrl url, Home _ ) ->
            changeRouteTo (Route.fromUrl url) (getNavKey model)

        (ChangedUrl url, Editor navKey editorModel) ->
            if editorModel.toReload then
                changeRouteTo (Route.fromUrl url) (getNavKey model)
            else
                (Editor navKey { editorModel | toReload = True }, Cmd.none)

        (_, Home _) ->
            (model, Cmd.none)

        (MonacoEditorValueReceived isNewState val, Editor navKey editorsModel) ->
            case D.fromString rdbDecoder val of
                Ok (domain, views) ->
                    let
                        newMonacoValue a =
                            { a
                            | domain = Just domain
                            , views = views
                            , value = val
                            }
                        newModel =
                            { editorsModel
                            | errors = ""
                            , monacoValue =
                                if isNewState then
                                    let
                                        currentMonacoValue = editorsModel.monacoValue.present
                                        updatedMonacoValue =
                                            { currentMonacoValue
                                            |  domain = Just domain
                                            , views = views
                                            , value = val
                                            }
                                    in
                                    UndoList.new updatedMonacoValue editorsModel.monacoValue
                                else
                                    UndoList.mapPresent newMonacoValue editorsModel.monacoValue
                            }
                    in
                    ( Editor navKey newModel
                    , Cmd.batch [getElementPosition, validationErrors ""]
                    )

                Err err ->
                    case err of
                        D.Parsing errMsg ->
                            ( model, validationErrors errMsg )
                        D.Decoding errMsg ->
                            ( model, validationErrors errMsg )

        (ReceiveElementPosition (Err _), _ ) ->
            ( model, Cmd.none )

        (_, Editor navKey editorModel ) ->
            let
                toEditor = Editor navKey
            in
            case editorModel.viewEditor of
                Init ->
                    case msg of
                        ReceiveElementPosition (Ok { element }) ->
                            let
                                initialZoom = initZoom element
                            in
                            ( { editorModel
                            | viewEditor = Ready
                                { drag = Nothing
                                , element = element
                                , zoom = initialZoom
                                , viewNavigation = ViewNavigation.init initialZoom
                                , ctrlIsDown = False
                                , brush = Nothing
                                , selectedItems = []
                                }
                            } |> toEditor
                            , Cmd.none
                            )

                        InitMonacoRequestReceived _ ->
                            (model, initMonaco)

                        PaneMsg paneMsg ->
                            ( { editorModel | pane = SplitPane.update paneMsg editorModel.pane } |> toEditor
                            , Cmd.none )

                        Resize ->
                            ( model, getElementPosition )

                        _ ->  ( model, Cmd.none )
                Ready state ->
                    case msg of
                        ViewControl subMsg ->
                            let
                                ( updated, cmd ) = ViewControl.update subMsg editorModel.viewControl

                                finalCmds =
                                    if ViewControl.selectedViewChanged updated then
                                        Cmd.batch
                                            [ cmd |> Cmd.map ViewControl
                                            , Nav.pushUrl (getNavKey model) ("/#/editor/" ++ ViewControl.getSelectedView editorModel.viewControl)
                                            ]
                                    else
                                        cmd |> Cmd.map ViewControl
                            in
                            ( { editorModel | viewControl = updated, toReload = ViewControl.selectedViewChanged updated |> not } |> toEditor
                            , finalCmds
                            )

                        SelectItemsStart xy ->
                            let
                                shiftedXY = shiftPosition state.zoom (0, 0) xy
                            in
                            (   { editorModel | viewEditor = Ready { state | brush = Just <| Brush shiftedXY shiftedXY }
                                } |> toEditor
                            , Cmd.none
                            )

                        SetCtrlIsDown value ->
                            ( { editorModel | viewEditor = Ready { state | ctrlIsDown = value } } |> toEditor
                            , Cmd.none
                            )

                        Undo->
                            let
                                newModel =
                                    { editorModel
                                    | monacoValue = if state.ctrlIsDown then UndoList.undo editorModel.monacoValue else editorModel.monacoValue
                                    }
                            in
                            ( toEditor newModel
                            , updateMonacoValue newModel.monacoValue.present.value
                            )

                        Redo->
                            let
                                newModel =
                                    { editorModel
                                    | monacoValue = if state.ctrlIsDown then UndoList.redo editorModel.monacoValue else editorModel.monacoValue
                                    }
                            in
                            ( toEditor newModel
                            , updateMonacoValue newModel.monacoValue.present.value
                            )

                        ReceiveElementPosition (Ok { element }) ->
                            ({ editorModel | viewEditor = Ready { state | element = element } } |> toEditor
                            , Cmd.none
                            )

                        Resize ->
                            ( model, getElementPosition )

                        ZoomMsg zoomMsg ->
                            (   { editorModel | viewEditor = Ready { state | zoom = Zoom.update zoomMsg state.zoom }
                                } |> toEditor
                            , Cmd.none
                            )

                        DragViewElementStart viewElementKey xy ->
                            let
                                currentModel = editorModel

                                (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.element.x, state.element.y) xy

                                selectedElementKeys = getSelectedElementKeysAndDeltas state.selectedItems
                                    |> List.map Tuple.first

                                isWithinAlreadySelected = selectedElementKeys
                                    |> List.member viewElementKey

                                selectedView = ViewControl.getSelectedView currentModel.viewControl

                                elementsOfCurrentView = getCurrentView selectedView currentModel.monacoValue.present.views
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
                            (   { editorModel
                                | viewEditor = Ready
                                    { state
                                    | drag = Just { start = xy, current = xy }
                                    , selectedItems = updatedSelectedItems
                                    }
                                , monacoValue = UndoList.new editorModel.monacoValue.present editorModel.monacoValue
                                } |> toEditor
                            , Cmd.none
                            )

                        DragPointStart viewRelationPointKey xy ->
                            let
                                currentModel = editorModel

                                (viewElementKey, relation, pointIndex) = viewRelationPointKey
                                (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.element.x, state.element.y) xy

                                selectedPointKeys = getSelectedPointKeysAndDeltas state.selectedItems
                                    |> List.map Tuple.first

                                isWithinAlreadySelected = selectedPointKeys
                                    |> List.member viewRelationPointKey

                                selectedView = ViewControl.getSelectedView currentModel.viewControl

                                elementsOfCurrentView = getCurrentView selectedView currentModel.monacoValue.present.views
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
                            (   { editorModel
                                | viewEditor = Ready
                                    { state
                                    | drag = Just { start = xy, current = xy }
                                    , selectedItems = updatedSelectedItems
                                    }
                                , monacoValue = UndoList.new editorModel.monacoValue.present editorModel.monacoValue
                                } |> toEditor
                            , Cmd.none
                            )

                        RemovePoint (viewElementKey, relation, pointIndex) ->
                            let
                                removePointAtIndex list = List.take pointIndex list ++ List.drop (pointIndex + 1) list

                                selectedView = ViewControl.getSelectedView editorModel.viewControl

                                updatedViews =
                                    updatePointsInRelations relation removePointAtIndex
                                    |> updateRelationsInElements viewElementKey
                                    |> updateElementsInViews selectedView editorModel.monacoValue.present.views

                                removePointMessage =
                                    RemovePointMessage selectedView viewElementKey relation pointIndex
                                        |> encodeRemovePoint |> removePoint

                                currentMonacoValue = editorModel.monacoValue.present
                                updatedPresentMonacoValue =
                                    { currentMonacoValue | views = updatedViews }
                            in
                            (   { editorModel
                                | monacoValue = UndoList.new updatedPresentMonacoValue editorModel.monacoValue
                                } |> toEditor
                            , removePointMessage
                            )

                        ClickEdgeStart (viewElementKey, relation) xy ->
                            let
                                spxy = shiftPosition state.zoom (state.element.x, state.element.y) xy

                                selectedView = ViewControl.getSelectedView editorModel.viewControl

                                currentView = getCurrentView selectedView editorModel.monacoValue.present.views

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
                                        allPoints = sxy :: (getViewRelationPoints (viewElementKey, relation) cv) ++ [ txy ]

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
                                            (txy, (txy, maxSafeInteger))
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

                                        updatedList = listWithNewPoint |> trimList 1

                                        updatedPoints = \_ -> updatedList |> List.map (\(x, y) -> ViewRelationPoint x y)

                                        updatedViewsValue =
                                            updatedPoints
                                            |> updatePointsInRelations relation
                                            |> updateRelationsInElements viewElementKey
                                            |> updateElementsInViews selectedView editorModel.monacoValue.present.views

                                        addPointMessage =
                                            PointMessage selectedView viewElementKey relation (List.length updatedList - indexOfNewPoint) spxy
                                                |> encodePointMessage |> addPoint

                                        currentMonacoValue = editorModel.monacoValue.present
                                        updatedPresentMonacoValue =
                                            { currentMonacoValue | views = updatedViewsValue }
                                    in
                                    (   { editorModel
                                        | monacoValue = UndoList.new updatedPresentMonacoValue editorModel.monacoValue
                                        } |> toEditor
                                    , addPointMessage
                                    )
                                _ -> ( model, Cmd.none )

                        MouseMove xy ->
                            let
                                selectedViewKey = ViewControl.getSelectedView editorModel.viewControl
                                selectedView = getCurrentView selectedViewKey editorModel.monacoValue.present.views
                                updatedViewEditor = handleMouseMove xy state selectedView

                                updatedViews =
                                    case (state.brush, state.drag) of
                                        (Nothing, Just _ ) ->
                                            updateElementAndPointPosition state.selectedItems xy state
                                                |> updateElementsInViews selectedViewKey editorModel.monacoValue.present.views
                                        _ ->
                                            editorModel.monacoValue.present.views

                                updatedPresentMonacoValue a =
                                    { a | views = updatedViews }
                            in
                            (   { editorModel
                                | viewEditor = updatedViewEditor
                                , monacoValue = UndoList.mapPresent updatedPresentMonacoValue editorModel.monacoValue
                                } |> toEditor
                            , Cmd.none)

                        MouseMoveEnd ->
                            case state.brush of
                                Just _ ->
                                    ( { editorModel | viewEditor = Ready { state | brush = Nothing } } |> toEditor
                                    , Cmd.none
                                    )
                                Nothing ->
                                    case state.drag of
                                        Just _ ->
                                            (   { editorModel | viewEditor = Ready { state | drag = Nothing, selectedItems = [] }
                                                } |> toEditor
                                            , updateMonacoValues (ViewControl.getSelectedView editorModel.viewControl) editorModel.monacoValue.present.views state.selectedItems
                                            )
                                        _ ->
                                            ( model, Cmd.none )

                        PaneMsg paneMsg ->
                            ( { editorModel | pane = SplitPane.update paneMsg editorModel.pane } |> toEditor
                            , Cmd.none
                            )

                        ViewNavigation subMsg ->
                            let
                                ( updated, cmd ) = ViewNavigation.update state.zoom subMsg state.viewNavigation
                            in
                            ( { editorModel
                            | viewEditor = Ready { state | viewNavigation = updated, zoom = updated.newZoom, ctrlIsDown = updated.ctrlIsDown }
                            } |> toEditor, cmd |> Cmd.map ViewNavigation )

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

updateMonacoValues : String -> Dict String View -> List SelectedItem -> Cmd msg
updateMonacoValues selectedView views selectedItems =
    let
        createMessage (elementKey, element) =
            UpdateElementPositionMessage selectedView elementKey (element.x, element.y)

        createPointMessage (viewRelationPointKey, viewRelationPoint) =
            let
                (viewElementKey, relation, viewRelationPointIndex) = viewRelationPointKey
            in
            PointMessage selectedView viewElementKey relation viewRelationPointIndex (viewRelationPoint.x, viewRelationPoint.y)
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
        Editor _ editorModel ->
            let
                { pane, viewEditor, monacoValue, viewControl } = editorModel
                { domain, views } = monacoValue.present
                graphics =
                    case viewEditor of
                        Init -> [ text "" ]
                        Ready state -> (svgView (views, domain) viewControl state)
            in
            { title = "RDB Model Editor"
            , body =
                [ div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
                    [ SplitPane.view
                        viewConfig
                        (div [ id elementId, Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%", Html.Attributes.style "position" "relative" ] graphics )
                        (div [ id "monaco", Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%"] [])
                        pane
                    , div [ style "position" "fixed", style "bottom" "0", style "left" "0", style "font-size" "9px" ] [ text "v0.0.1"]
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

        readySubscriptions : ViewEditorState -> Sub Msg
        readySubscriptions { zoom, brush, drag } =
            Sub.batch
                [ Zoom.subscriptions zoom ZoomMsg
                , case (brush, drag) of
                    (Nothing, Nothing) -> Sub.none
                    _ -> dragSubscriptions
                ]
    in
    Sub.batch
        [ case model of
            Home _ -> Sub.none
            Editor _ { viewEditor } ->
                case viewEditor of
                    Init ->
                        Sub.none

                    Ready state ->
                        readySubscriptions state
        , Events.onResize (\_ -> \_ -> Resize)
        , Events.onKeyDown (keyDecoder |> setCtrlAndOtherState True)
        , Events.onKeyUp (keyDecoder |> setCtrlState False)
        , case model of
            Home _ -> Sub.none
            Editor _ { pane } ->
                Sub.map PaneMsg <| SplitPane.subscriptions pane
        , monacoEditorValue <| MonacoEditorValueReceived False
        , monacoEditorSavedValue <| MonacoEditorValueReceived True
        , initMonacoRequest InitMonacoRequestReceived
        ]

keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string

setCtrlAndOtherState : Bool -> Decode.Decoder String -> Decode.Decoder Msg
setCtrlAndOtherState value =
    Decode.map (\key ->
        if key == "Control" then
            SetCtrlIsDown value
        else if key == "z" then
            Undo
        else if key == "y" then
            Redo
        else
            NoOp)

setCtrlState : Bool -> Decode.Decoder String -> Decode.Decoder Msg
setCtrlState value =
    Decode.map (\key ->
        if key == "Control" then
            SetCtrlIsDown value
        else
            NoOp)

type ViewEditor
    = Init
    | Ready ViewEditorState

type alias SubPathEdge =
    { points : List (Float, Float)
    }

type alias ViewEditorState =
    { drag : Maybe Drag
    , zoom : Zoom
    , viewNavigation : ViewNavigation.Model
    -- The position and dimensions of the svg element.
    , element : Element
    , ctrlIsDown : Bool
    , brush : Maybe Brush
    , selectedItems : List SelectedItem
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


getMonacoElementPosition : Cmd Msg
getMonacoElementPosition =
    Task.attempt ReceiveMonacoElementPosition (Dom.getElement "monaco")


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

handleMouseMove : ( Float, Float ) -> ViewEditorState -> Maybe View -> ViewEditor
handleMouseMove xy ({ drag, brush } as state) currentView =
    case brush of
        Just b ->
            let
                shiftedXY = shiftPosition state.zoom (0, 0) xy
                updatedBrush = { b | end = shiftedXY }
                elementKeysWithinBrush = currentView
                    |> getViewElementsOfCurrentView
                    |> getViewElementKeysByCondition (elementWithinBrush updatedBrush)
                    |> List.map (\i -> SelectedItem (ElementKey i) Nothing)

                pointKeysWithinBrush = currentView
                    |> getViewElementsOfCurrentView
                    |> getElementAndItsKeys
                    |> List.concatMap (\(k, v) -> v.relations |> Dict.toList |> List.map (\(relation, points) -> (k, relation, points)))
                    |> List.concatMap (\(k, relation, points) -> points |> getViewPointKeysByCondition (pointWithinBrush updatedBrush) |> List.map (\pointIndex -> (k, relation, pointIndex)))
                    |> List.map (\i -> SelectedItem (PointKey i) Nothing)
            in
            Ready { state | brush = Just updatedBrush, selectedItems = elementKeysWithinBrush ++ pointKeysWithinBrush }
        Nothing ->
            case drag of
                Just { start } ->
                    Ready { state | drag = Just { start = start, current = xy } }

                _ ->
                    Ready state


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

updateElementAndPointPosition : List SelectedItem -> ( Float, Float ) -> ViewEditorState -> (Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement)
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
    in
    Dict.map (\viewElementKey ve ->
        updateElementXY viewElementKey ve
        |> updatedRelations viewElementKey
    )

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

svgView : (Dict String View, Maybe Domain) -> ViewControl.Model -> ViewEditorState -> List (Html Msg)
svgView (views, domain) viewControlModel viewEditorState =
    let
        { zoom, ctrlIsDown } = viewEditorState
        selectItemsEvents : Attribute Msg
        selectItemsEvents =
            mouseDownMain SelectItemsStart

        selectedView = ViewControl.getSelectedView viewControlModel

        gridRectEvents : List (Attribute Msg)
        gridRectEvents =
            [Zoom.onDoubleClick zoom ZoomMsg, Zoom.onWheel zoom ZoomMsg]
                ++ (if ctrlIsDown then Zoom.onDrag zoom ZoomMsg else [selectItemsEvents])

        zoomTransformAttr : Attribute Msg
        zoomTransformAttr =
            Zoom.transform zoom

        transform10 =
            zoom |> Zoom.asRecord |> .scale |> (*) 10

        transform100 = transform10 * 10

        getXY =
            zoom
            |> Zoom.asRecord
            |> .translate
            |> (\t -> (floatRemainderBy transform100 t.x, floatRemainderBy transform100 t.y))

        ( x, y ) = getXY
    in
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
            [ renderCurrentView (views, domain, selectedView) viewEditorState
            , renderSelectRect viewEditorState
            ]
        ]
    , ViewControl.view views (getElementsToAdd domain) viewControlModel |> Html.map ViewControl
    , ViewNavigation.view viewEditorState.viewNavigation |> Html.map ViewNavigation
    ]


-- Grid comes from https://gist.github.com/leonardfischer/fc4d1086c64b2c1324c93dcd0beed004

renderSelectRect : ViewEditorState -> Svg Msg
renderSelectRect model =
    case model.brush of
        Just { start, end } ->
            selectItemsRect start end
        Nothing ->
            text ""


renderCurrentView : (Dict String View, Maybe Domain, String) -> ViewEditorState -> Svg Msg
renderCurrentView (views, domain, selectedView) model =
    let
        { ctrlIsDown, selectedItems, zoom } = model
    in
    case (getCurrentView selectedView views, domain) of
        (Just v, Just d) ->
            g []
                [ getEdges (d, v)
                    |> List.map (drawEdge zoom ctrlIsDown selectedItems)
                    |> g [ class [ "links" ] ]
                , getContainers (d, v)
                    |> List.map (drawContainer zoom ctrlIsDown selectedItems)
                    |> g [ class [ "nodes" ] ]
                ]
        _ -> text ""

drawEdge : Zoom -> Bool -> List SelectedItem -> Edge -> Svg Msg
drawEdge zoom panMode selectedItems edge =
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
        |> linkElement zoom panMode edge

drawContainer : Zoom -> Bool -> List SelectedItem -> Container -> Svg Msg
drawContainer zoom panMode selectedItems container =
    let
        mouseDownAttr =
            if panMode then
                Zoom.onDrag zoom ZoomMsg
            else
                [ mouseDownMain (DragViewElementStart container.key) ]
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

linkElement : Zoom -> Bool -> Edge -> List Int -> Svg Msg
linkElement zoom panMode edge =
    let
        viewRelationKey = getViewRelationKeyFromEdge edge
    in
    edgeBetweenContainers
        edge
        (noOpIfPanMode zoom panMode <| mouseDownMain (ClickEdgeStart viewRelationKey))
        (if panMode then (\_ -> Zoom.onDrag zoom ZoomMsg) else onMouseDownPoint viewRelationKey)


noOpIfPanMode : Zoom -> Bool -> Attribute Msg -> List (Attribute Msg)
noOpIfPanMode zoom panMode ev =
    if panMode then
        Zoom.onDrag zoom ZoomMsg
    else
        [ev]

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

onMouseDownPoint : ViewRelationKey -> Int -> List (Attribute Msg)
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
    |> List.singleton
