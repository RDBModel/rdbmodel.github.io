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
import TypedSvg exposing (svg, defs, g)
import Html.Events.Extra.Mouse as Mouse exposing (Event)
import Task
import TypedSvg.Attributes as Attrs exposing ( class, x, y, id, d, r, x1, x2, y1, y2)
import TypedSvg.Types exposing ( Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import TypedSvg.Core exposing (Svg, Attribute)
import Zoom exposing (Zoom, OnZoom)
import Elements exposing
    ( renderContainer, renderContainerSelected, markerDot, innerGrid, grid, gridRect, edgeBetweenContainers
    , selectItemsRect, extendPoints
    )
import DomainDecoder exposing (..)
import Dict exposing (Dict)
import Domain exposing (..)
import Url exposing (Url)
import Route exposing (Route)
import JsInterop exposing (initMonacoResponse, monacoEditorInitialValue, initMonacoRequest
    , updateMonacoValue, monacoEditorSavedValue, validationErrors, requestValueToSave, saveValueToFile
    , zoomMsgReceived)
import Index exposing (index)
import Scale exposing (domain)
import ViewControl
import Utils exposing (trimList)
import ViewNavigation
import DomainEncoder exposing (rdbEncode)
import FilePicker
import ViewUndoRedo exposing (UndoRedoMonacoValue, getUndoRedoMonacoValue, newRecord, mapPresent)
import ContextMenu
import DomainEncoder exposing (relationToString)
import ContainerMenu

-- MAIN

main : Program Bool Model Msg
main =
  Browser.application
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    , onUrlRequest = ClickedLink
    , onUrlChange = ChangedUrl
    }

init : Bool -> Url -> Nav.Key -> ( Model, Cmd Msg )
init isFileSystemSupported url navKey  =
    changeRouteTo (Route.fromUrl url) isFileSystemSupported navKey

-- MODEL

type Model
    = Home Bool Nav.Key
    | Editor Bool Nav.Key EditorsModel

type alias EditorsModel =
    { pane : SplitPane.State
    , viewEditor : ViewEditor
    , monacoValue : UndoRedoMonacoValue MonacoValue
    , viewControl : ViewControl.Model
    , showOpenFileButton : Bool
    , toReload : Bool
    , errors : String
    }

type ViewEditor
    = Init
    | Ready ViewEditorState

type alias MonacoValue =
    { views : Dict String View
    , domain : Maybe Domain
    }

type alias ViewEditorState =
    { drag : Maybe Drag
    , zoom : Zoom
    , viewNavigation : ViewNavigation.Model
    , viewUndoRedo : ViewUndoRedo.Model
    , svgElementPosition : Element
    , ctrlIsDown : Bool
    , brush : Maybe Brush
    , selectedItems : List SelectedItem
    , containerMenu : ContextMenu.Model
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

-- UPDATE

type Msg
    = ZoomMsg OnZoom
    | ViewNavigation ViewNavigation.Msg
    | Resize
    | ReceiveElementPosition (Result Dom.Error Dom.Element)
    | ReceiveMonacoElementPosition (Result Dom.Error Dom.Element)
    | DragViewElementStart ViewElementKey ( Float, Float )
    | ClickEdgeStart ViewRelationKey ( Float, Float )
    | RemoveEdge ViewRelationKey
    | DragPointStart ViewRelationPointKey ( Float, Float )
    | RemovePoint ViewRelationPointKey
    | MouseMove ( Float, Float )
    | MouseMoveEnd
    | PaneMsg SplitPane.Msg
    | MonacoEditorInitialValueReceived String
    | MonacoEditorValueReceived String
    | InitMonacoRequestReceived ()
    | SetCtrlIsDown Bool
    | SelectItemsStart (Float, Float)
    | NoOp
    | ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | ViewControl ViewControl.Msg
    | FilePicker FilePicker.Msg
    | RequestValueToSave ()
    | ViewUndoRedo ViewUndoRedo.Msg
    | ContainerContextMenu ContextMenu.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (msg, model) of
        (ReceiveMonacoElementPosition (Ok _ ), _) ->
            ( model
            , initMonaco
            )

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

        (ChangedUrl url, Home isFileSystemSupported _ ) ->
            changeRouteTo (Route.fromUrl url) isFileSystemSupported (getNavKey model)

        (ChangedUrl url, Editor isFileSystemSupported navKey editorModel) ->
            if editorModel.toReload then
                changeRouteTo (Route.fromUrl url) isFileSystemSupported (getNavKey model)
            else
                (Editor isFileSystemSupported navKey { editorModel | toReload = True }, Cmd.none)

        (_, Home _ _) ->
            (model, Cmd.none)

        (MonacoEditorValueReceived val, Editor isFileSystemSupported navKey editorModel) ->
            case D.fromString rdbDecoder val of
                Ok (domain, views) ->
                    let
                        newModel =
                            { editorModel
                            | errors = ""
                            , monacoValue =
                                let
                                    currentMonacoValue = editorModel.monacoValue.present
                                    updatedMonacoValue =
                                        { currentMonacoValue
                                        | domain = Just domain
                                        , views = views
                                        }
                                in
                                newRecord updatedMonacoValue editorModel.monacoValue
                            }
                    in
                    ( Editor isFileSystemSupported navKey newModel
                    , Cmd.batch [getElementPosition, validationErrors ""]
                    )

                Err err ->
                    case err of
                        D.Parsing errMsg ->
                            ( model, validationErrors errMsg )
                        D.Decoding errMsg ->
                            ( model, validationErrors errMsg )

        (MonacoEditorInitialValueReceived val, Editor isFileSystemSupported navKey editorModel) ->
            case D.fromString rdbDecoder val of
                Ok (domain, views) ->
                    let
                        newMonacoValue a =
                            { a
                            | domain = Just domain
                            , views = views
                            }

                        newModel =
                            { editorModel
                            | errors = ""
                            , showOpenFileButton = True
                            , monacoValue = mapPresent newMonacoValue editorModel.monacoValue
                            }
                    in
                    ( Editor isFileSystemSupported navKey newModel
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

        (_, Editor isFileSystemSupported navKey editorModel ) ->
            let
                toEditor = Editor isFileSystemSupported navKey
            in
            case editorModel.viewEditor of
                Init ->
                    case msg of
                        ReceiveElementPosition (Ok { element }) ->
                            let
                                initialZoom = initZoom element

                                views = editorModel.monacoValue.present.views

                                selectedView = ViewControl.getSelectedView editorModel.viewControl

                                getPossibleRelations =
                                    getCurrentView selectedView views
                                        |> Maybe.map2 (\d v -> possibleRelationsToAdd (d, v)) editorModel.monacoValue.present.domain
                                        |> Maybe.withDefault Dict.empty
                            in
                            ( { editorModel
                            | viewEditor = Ready
                                { drag = Nothing
                                , svgElementPosition = element
                                , zoom = initialZoom
                                , viewNavigation = ViewNavigation.init initialZoom
                                , viewUndoRedo = ViewUndoRedo.init
                                , ctrlIsDown = False
                                , brush = Nothing
                                , selectedItems = []
                                , containerMenu = ContainerMenu.init getPossibleRelations |> ContextMenu.init
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
                        ContainerContextMenu subMsg ->
                            let
                                (updatedModel, cmd, selectResult) = ContextMenu.update subMsg state.containerMenu

                                selectedView = ViewControl.getSelectedView editorModel.viewControl
                                currentMonacoValue = editorModel.monacoValue.present
                                newViews =
                                    case selectResult of
                                        Just (containerId, relation) ->
                                            getCurrentView selectedView editorModel.monacoValue.present.views
                                                    |> addRelationToView containerId relation
                                                    |> updateViewByKey selectedView editorModel.monacoValue.present.views
                                        Nothing -> editorModel.monacoValue.present.views

                                updatedMonacoValue = { currentMonacoValue | views = newViews }

                                newMonacoValue =
                                    case selectResult of
                                        Just _ ->
                                            newRecord updatedMonacoValue editorModel.monacoValue
                                        Nothing -> editorModel.monacoValue
                            in
                            ( { editorModel
                            | viewEditor = Ready { state
                                | containerMenu = updatedModel
                                }
                            , monacoValue = newMonacoValue
                            } |> toEditor
                            , Cmd.batch
                                [ cmd |> Cmd.map ContainerContextMenu
                                , updateMonacoValue (rdbEncode updatedMonacoValue)
                                ]
                            )

                        RequestValueToSave _ ->
                            ( model, saveValueToFile (rdbEncode editorModel.monacoValue.present))

                        FilePicker subMsg ->
                            let
                                cmd = FilePicker.update subMsg
                            in
                            (model, cmd |> Cmd.map FilePicker)

                        ViewControl subMsg ->
                            let
                                ( updated, cmd, elementToAdd ) = ViewControl.update subMsg editorModel.viewControl

                                selectedView = ViewControl.getSelectedView editorModel.viewControl
                                currentMonacoValue = editorModel.monacoValue.present

                                newViews =
                                    case elementToAdd of
                                        Just v ->
                                            getCurrentView selectedView currentMonacoValue.views
                                                    |> addElementToView (Tuple.first v) (getPositionForNewElement state.svgElementPosition state.zoom)
                                                    |> updateViewByKey selectedView currentMonacoValue.views
                                        Nothing -> currentMonacoValue.views

                                newMonacoValue =
                                    case elementToAdd of
                                        Just _ ->
                                            let
                                                updatedMonacoValue = { currentMonacoValue | views = newViews }
                                            in
                                            newRecord updatedMonacoValue editorModel.monacoValue
                                        Nothing -> editorModel.monacoValue

                                finalCmds =
                                    if ViewControl.selectedViewChanged updated then
                                        Cmd.batch
                                            [ cmd |> Cmd.map ViewControl
                                            , Nav.pushUrl (getNavKey model) ("/#/editor/" ++ ViewControl.getSelectedView editorModel.viewControl)
                                            ]
                                    else
                                        cmd |> Cmd.map ViewControl

                                getPossibleRelations =
                                    getCurrentView selectedView newViews
                                        |> Maybe.map2 (\d v -> possibleRelationsToAdd (d, v)) editorModel.monacoValue.present.domain
                                        |> Maybe.withDefault Dict.empty

                                updatedViewEditor =
                                    Ready { state | containerMenu = ContainerMenu.init getPossibleRelations |> ContextMenu.init }
                            in
                            ( { editorModel
                            | viewControl = updated
                            , toReload = ViewControl.selectedViewChanged updated |> not
                            , monacoValue = newMonacoValue
                            , viewEditor = updatedViewEditor
                            } |> toEditor
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

                        ViewUndoRedo subMsg ->
                            let
                                (subModel, updatedMonacoValue) = ViewUndoRedo.update editorModel.monacoValue subMsg state.viewUndoRedo
                            in
                            ( { editorModel
                            | viewEditor = Ready { state | viewUndoRedo = subModel }
                            , monacoValue = updatedMonacoValue } |> toEditor
                            , updateMonacoValue (rdbEncode updatedMonacoValue.present)
                            )

                        ReceiveElementPosition (Ok { element }) ->
                            ({ editorModel | viewEditor = Ready { state | svgElementPosition = element } } |> toEditor
                            , Cmd.none
                            )

                        Resize ->
                            ( model, getElementPosition )

                        ZoomMsg zoomMsg ->
                            (   { editorModel | viewEditor = Ready { state | zoom = Zoom.update zoomMsg state.zoom }
                                } |> toEditor
                            , zoomMsgReceived ()
                            )

                        DragViewElementStart viewElementKey xy ->
                            let
                                currentModel = editorModel

                                (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.svgElementPosition.x, state.svgElementPosition.y) xy

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
                                , monacoValue = newRecord editorModel.monacoValue.present editorModel.monacoValue
                                } |> toEditor
                            , Cmd.none
                            )

                        DragPointStart viewRelationPointKey xy ->
                            let
                                currentModel = editorModel

                                (viewElementKey, relation, pointIndex) = viewRelationPointKey
                                (shiftedStartX, shiftedStartY) = shiftPosition state.zoom (state.svgElementPosition.x, state.svgElementPosition.y) xy

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
                                , monacoValue = newRecord editorModel.monacoValue.present editorModel.monacoValue
                                } |> toEditor
                            , Cmd.none
                            )

                        RemovePoint (viewElementKey, relation, pointIndex) ->
                            let
                                removePointAtIndex list = List.take pointIndex list ++ List.drop (pointIndex + 1) list

                                selectedView = ViewControl.getSelectedView editorModel.viewControl

                                currentMonacoValue = editorModel.monacoValue.present

                                updatedViews =
                                    updatePointsInRelations relation removePointAtIndex
                                    |> updateRelationsInElements viewElementKey
                                    |> updateElementsInViews selectedView currentMonacoValue.views

                                updatedPresentMonacoValue =
                                    { currentMonacoValue | views = updatedViews }
                            in
                            (   { editorModel
                                | monacoValue = newRecord updatedPresentMonacoValue editorModel.monacoValue
                                } |> toEditor
                            , updateMonacoValue (rdbEncode updatedPresentMonacoValue)
                            )

                        RemoveEdge viewRelationKey ->
                            let
                                selectedView = ViewControl.getSelectedView editorModel.viewControl

                                currentView = getCurrentView selectedView editorModel.monacoValue.present.views
                                currentMonacoValue = editorModel.monacoValue.present

                                updatedViews = currentView
                                    |> Maybe.map (removedEdge viewRelationKey)
                                    |> updateViewByKey selectedView currentMonacoValue.views

                                updatedPresentMonacoValue =
                                    { currentMonacoValue | views = updatedViews }

                                getPossibleRelations =
                                    getCurrentView selectedView updatedViews
                                        |> Maybe.map2 (\d v -> possibleRelationsToAdd (d, v)) editorModel.monacoValue.present.domain
                                        |> Maybe.withDefault Dict.empty

                                updatedViewEditor =
                                    Ready { state | containerMenu = ContainerMenu.init getPossibleRelations |> ContextMenu.init }
                            in
                            (   { editorModel
                                | monacoValue = newRecord updatedPresentMonacoValue editorModel.monacoValue
                                , viewEditor = updatedViewEditor
                                } |> toEditor
                            , updateMonacoValue (rdbEncode updatedPresentMonacoValue)
                            )
                        ClickEdgeStart (viewElementKey, relation) xy ->
                            let
                                spxy = shiftPosition state.zoom (state.svgElementPosition.x, state.svgElementPosition.y) xy

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

                                        currentMonacoValue = editorModel.monacoValue.present

                                        updatedPresentMonacoValue =
                                            { currentMonacoValue | views = updatedViewsValue }
                                    in
                                    (   { editorModel
                                        | monacoValue = newRecord updatedPresentMonacoValue editorModel.monacoValue
                                        } |> toEditor
                                    , updateMonacoValue (rdbEncode updatedPresentMonacoValue)
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
                                , monacoValue = mapPresent updatedPresentMonacoValue editorModel.monacoValue
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
                                            , updateMonacoValue (rdbEncode editorModel.monacoValue.present)
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

getNavKey : Model -> Nav.Key
getNavKey model =
    case model of
        Home _ key -> key
        Editor _ key _ -> key

changeRouteTo : Maybe Route -> Bool -> Nav.Key -> ( Model, Cmd Msg )
changeRouteTo maybeRoute isFileSystemSupported key =
    case maybeRoute of
        Nothing ->
            ( Home isFileSystemSupported key, Cmd.none )

        Just Route.Home ->
            ( Home isFileSystemSupported key, Cmd.none )

        Just (Route.Editor selectedView) ->
            ( Editor isFileSystemSupported key (getEditorsModel selectedView)
            , Task.attempt ReceiveMonacoElementPosition (Dom.getElement "monaco")
            )

getEditorsModel : String -> EditorsModel
getEditorsModel selectedView =
    EditorsModel
        (SplitPane.init Horizontal)
        Init
        (getUndoRedoMonacoValue getMonacoValue)
        (ViewControl.init selectedView)
        False
        True
        ""

getMonacoValue : MonacoValue
getMonacoValue =
    MonacoValue Dict.empty Nothing

initMonaco : Cmd Msg
initMonaco = initMonacoResponse ()

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

view : Model -> Document Msg
view model =
    case model of
        Home _ _ ->
            { title = "RDB Model"
            , body = [ index ]
            }
        Editor isFileSystemSupported _ editorModel ->
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
                        (monacoViewPart (editorModel.showOpenFileButton && isFileSystemSupported))
                        pane
                    , div [ style "position" "fixed", style "bottom" "0", style "left" "0", style "font-size" "9px" ] [ text "v0.0.1"]
                    ]
                ]
            }

viewConfig : ViewConfig Msg
viewConfig =
    createViewConfig
        { toMsg = PaneMsg
        , customSplitter = Nothing
        }

monacoViewPart : Bool -> Html Msg
monacoViewPart showButton =
    div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
    [ div [ id "monaco", Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ] []
    , if showButton then FilePicker.view |> Html.map FilePicker else text ""
    ]

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

        (shiftedX, shiftedY) = shiftPosition state.zoom (state.svgElementPosition.x, state.svgElementPosition.y) xy
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
    , ViewUndoRedo.view |> Html.map ViewUndoRedo
    , ContextMenu.view viewEditorState.containerMenu |> Html.map ContainerContextMenu
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

        renderContainerFunc =
            if List.member container.key selectedElements then
                renderContainerSelected
            else
                renderContainer

        contextMenuAttr = container.key
            |> ContextMenu.attach
            |> Html.Attributes.map ContainerContextMenu
            |> List.singleton
    in
    renderContainerFunc container (mouseDownAttr ++ contextMenuAttr)

mouseDownMain : ((Float, Float) -> Msg) -> Attribute Msg
mouseDownMain msg =
    Mouse.onDown <|
        onlyMainButton
        >> Maybe.map msg
        >> Maybe.withDefault NoOp

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
        (noOpIfPanMode zoom panMode <| onMouseDownEdge viewRelationKey)
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

onMouseDownEdge : ViewRelationKey -> Attribute Msg
onMouseDownEdge viewRelationKey =
    Mouse.onDown
        (\e ->
            case e.button of
                Mouse.MainButton -> ClickEdgeStart viewRelationKey e.clientPos
                Mouse.SecondButton -> RemoveEdge viewRelationKey
                _ -> NoOp
        )

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


getPositionForNewElement : Element -> Zoom -> (Float, Float)
getPositionForNewElement svgElement zoom =
  let
    record = Zoom.asRecord zoom

    (initY, initX) = ((svgElement.height - svgElement.y)/2, (svgElement.width - svgElement.x)/2)
  in
  ( initX - record.scale * record.translate.x, initY - record.scale * record.translate.y)

-- SUBSCRIPTIONS

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
      Home _ _ -> Sub.none
      Editor _ _ { viewEditor } ->
        case viewEditor of
          Init ->
            Sub.none

          Ready state ->
            Sub.batch
              [ readySubscriptions state
              , (ViewUndoRedo.subscriptions state.viewUndoRedo) |> Sub.map ViewUndoRedo
              , ContextMenu.subscriptions |> Sub.map ContainerContextMenu
              ]
    , Events.onResize (\_ -> \_ -> Resize)
    , Events.onKeyDown (keyDecoder |> setCtrlState True)
    , Events.onKeyUp (keyDecoder |> setCtrlState False)
    , case model of
      Home _ _ -> Sub.none
      Editor _ _ { pane } ->
        Sub.map PaneMsg <| SplitPane.subscriptions pane
    , monacoEditorInitialValue <| MonacoEditorInitialValueReceived
    , monacoEditorSavedValue <| MonacoEditorValueReceived
    , initMonacoRequest InitMonacoRequestReceived
    , requestValueToSave RequestValueToSave
    ]

setCtrlState : Bool -> Decode.Decoder String -> Decode.Decoder Msg
setCtrlState value =
    Decode.map (\key ->
        if key == "Control" then
            SetCtrlIsDown value
        else
            NoOp)

keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string
