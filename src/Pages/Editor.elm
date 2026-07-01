module Pages.Editor exposing (Model, Msg, changeSelectedView, init, subscriptions, update, view)

import Browser exposing (Document)
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Color
import Dict exposing (Dict)
import Domain.Domain exposing (ViewItemKey(..))
import Domain.DomainDecoder exposing (rdbDecoder)
import Domain.DomainEncoder exposing (rdbEncode)
import Domain.Validation exposing (errorDomainDecoder)
import Error.Error as Error exposing (Source(..))
import FilePicker
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Http
import InPorts exposing (editorValueSaved, initEditorRequest, receivedFromLocalStorage, requestValueToSave)
import Json.Decode as JsonDecoder
import OutPorts
    exposing
        ( getFromLocalStorage
        , initEditorResponse
        , saveToLocalStorage
        , saveValueToFile
        , validationErrors
        )
import SaveDomain.SaveDomain as SaveDomain
import Session exposing (Session)
import SplitPanel.SplitPane as SplitPane exposing (Orientation(..), State, ViewConfig, createViewConfig)
import Task
import TypedSvg exposing (line, path, svg)
import TypedSvg.Attributes
    exposing
        ( d
        , fill
        , height
        , id
        , stroke
        , strokeLinecap
        , strokeLinejoin
        , strokeWidth
        , viewBox
        , width
        , x1
        , x2
        , y1
        , y2
        )
import TypedSvg.Types exposing (Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import UndoRedo.ViewUndoRedo as ViewUndoRedo exposing (UndoRedoEditorValue, getUndoRedoEditorValue, newRecord)
import UndoRedo.ViewUndoRedoActions as ViewUndoRedoActions exposing (EditorValue)
import ViewEditor.Editor as ViewEditor
import ViewEditor.EditorAction as ViewEditorActions
import ViewEditor.Msg as ViewEditorMsg
import Yaml.Decode as D


type alias Model =
    { session : Session
    , pane : State
    , viewEditor : ViewEditor.Model
    , editorValue : UndoRedoEditorValue EditorValue
    , viewUndoRedo : ViewUndoRedo.Model
    , errors : Error.Model
    }


init : Session -> Maybe String -> Maybe String -> ( Model, Cmd Msg )
init session selectedView link =
    ( Model
        session
        (SplitPane.init Horizontal)
        (ViewEditor.init selectedView)
        (getUndoRedoEditorValue getInitialEditorValue)
        ViewUndoRedo.init
        []
    , Task.attempt (ReceiveEditorElementPosition link) (Dom.getElement "code-editor")
    )


getInitialEditorValue : EditorValue
getInitialEditorValue =
    EditorValue Dict.empty Nothing


type Msg
    = EditorValueReceived String
    | ReceiveEditorElementPosition (Maybe String) (Result Dom.Error Dom.Element)
    | ViewEditorMsg ViewEditorMsg.Msg
    | PaneMsg SplitPane.Msg
    | InitEditorRequestReceived ()
    | RequestValueToSave ()
    | FilePicker FilePicker.Msg
    | ViewUndoRedo ViewUndoRedo.Msg
    | GetDomainFromExternal (Result Http.Error String)
    | ErrorMsg Error.Msg
    | ReceivedFromLocalStorage (Maybe String)
    | ClickSaveDomain


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetDomainFromExternal (Ok val) ->
            case D.fromString rdbDecoder val of
                Ok ( domain, views ) ->
                    let
                        editorModel =
                            EditorValue views (Just domain)

                        newModel =
                            { model
                                | errors = []
                                , editorValue = editorModel |> getUndoRedoEditorValue
                            }
                    in
                    ( newModel
                    , Cmd.batch
                        [ initEditorResponse (rdbEncode editorModel)
                        , saveToLocalStorage val
                        , selectedViewNameUrlChange model views
                        , ViewEditor.getSvgElementPosition |> Cmd.map ViewEditorMsg
                        ]
                    )

                Err err ->
                    showError err model

        GetDomainFromExternal (Err errValue) ->
            ( { model | errors = Error.ExternalDomainDownload errValue |> List.singleton }, Cmd.none )

        ReceiveEditorElementPosition link (Ok _) ->
            ( model
            , case link of
                Just l ->
                    Http.get
                        { url = l
                        , expect = Http.expectString GetDomainFromExternal
                        }

                Nothing ->
                    getFromLocalStorage ()
            )

        ReceiveEditorElementPosition _ (Err errValue) ->
            ( { model | errors = Error.GetElementPosition errValue |> List.singleton }, Cmd.none )

        PaneMsg paneMsg ->
            ( { model | pane = SplitPane.update paneMsg model.pane }
            , ViewEditor.getSvgElementPosition |> Cmd.map ViewEditorMsg
            )

        EditorValueReceived val ->
            let
                cleaned =
                    String.replace "\u{000D}\n" "\n" val
            in
            case D.fromString rdbDecoder cleaned of
                Ok ( domain, views ) ->
                    let
                        newEditorValue =
                            let
                                currentEditorValue =
                                    model.editorValue.present

                                updatedEditorValue =
                                    { currentEditorValue
                                        | domain = Just domain
                                        , views = views
                                    }
                            in
                            newRecord updatedEditorValue model.editorValue

                        newModel =
                            { model
                                | errors = []
                                , editorValue = newEditorValue
                            }
                    in
                    ( newModel
                    , Cmd.batch
                        [ ViewEditor.getSvgElementPosition |> Cmd.map ViewEditorMsg
                        , validationErrors ""
                        , selectedViewNameUrlChange model views
                        , saveToLocalStorage (rdbEncode newModel.editorValue.present)
                        ]
                    )

                Err err ->
                    showError err model

        InitEditorRequestReceived _ ->
            ( model, initEditorResponse "" )

        RequestValueToSave _ ->
            ( model, saveValueToFile (rdbEncode model.editorValue.present) )

        ViewEditorMsg subMsg ->
            let
                ( updated, cmd, actions ) =
                    ViewEditor.update model.editorValue.present.domain model.editorValue.present.views subMsg model.viewEditor

                updatedValues =
                    ViewEditorActions.apply model.session.key { editorValue = model.editorValue, cmd = cmd, errors = model.errors } actions
            in
            ( { model
                | viewEditor = updated
                , editorValue = updatedValues.editorValue
                , errors = updatedValues.errors
              }
            , updatedValues.cmd |> Cmd.map ViewEditorMsg
            )

        FilePicker subMsg ->
            let
                cmd =
                    FilePicker.update subMsg
            in
            ( model, cmd |> Cmd.map FilePicker )

        ViewUndoRedo subMsg ->
            let
                ( subModel, updatedEditorValue, actions ) =
                    ViewUndoRedo.update model.editorValue subMsg model.viewUndoRedo
            in
            ( { model
                | viewUndoRedo = subModel
                , editorValue = updatedEditorValue
              }
            , ViewUndoRedoActions.apply updatedEditorValue.present actions
            )

        ErrorMsg subMsg ->
            ( { model | errors = Error.update subMsg model.errors }
            , Cmd.none
            )

        ReceivedFromLocalStorage domainValue ->
            case domainValue of
                Just val ->
                    case D.fromString rdbDecoder val of
                        Ok ( domain, views ) ->
                            let
                                editorModel =
                                    EditorValue views (Just domain)

                                newModel =
                                    { model
                                        | errors = []
                                        , editorValue = editorModel |> getUndoRedoEditorValue
                                    }
                            in
                            ( newModel
                            , Cmd.batch
                                [ initEditorResponse (rdbEncode editorModel)
                                , ViewEditor.getSvgElementPosition |> Cmd.map ViewEditorMsg
                                , Nav.replaceUrl model.session.key ("/#/editor/" ++ (ViewEditor.getSelectedView model.viewEditor |> Maybe.withDefault ""))
                                ]
                            )

                        Err err ->
                            showError err model

                Nothing ->
                    ( model
                    , Cmd.batch
                        [ initEditorResponse ""
                        , ViewEditor.getSvgElementPosition |> Cmd.map ViewEditorMsg
                        ]
                    )

        ClickSaveDomain ->
            ( model
            , saveToLocalStorage (rdbEncode model.editorValue.present)
            )


selectedViewNameUrlChange : { a | viewEditor : ViewEditor.Model, session : { b | key : Nav.Key } } -> Dict String v -> Cmd msg
selectedViewNameUrlChange model views =
    let
        currentSelectedView =
            ViewEditor.getSelectedView model.viewEditor

        updatedSelectedView =
            case currentSelectedView of
                Just v ->
                    if Dict.member v views then
                        Just v

                    else
                        Dict.keys views |> List.head

                Nothing ->
                    Dict.keys views |> List.head
    in
    case updatedSelectedView of
        Just v ->
            if Dict.member v views then
                Nav.replaceUrl model.session.key ("/#/editor/" ++ v)

            else
                Nav.replaceUrl model.session.key "/#/editor/"

        Nothing ->
            Nav.replaceUrl model.session.key "/#/editor/"


showError : D.Error -> Model -> ( Model, Cmd Msg )
showError err model =
    case err of
        D.Parsing errMsg ->
            ( { model | errors = DomainParse errMsg |> List.singleton }, validationErrors errMsg )

        D.Decoding errMsg ->
            case JsonDecoder.decodeString errorDomainDecoder errMsg of
                Ok parsedErrors ->
                    ( { model | errors = parsedErrors |> List.singleton }, validationErrors errMsg )

                Err decodeErr ->
                    ( { model | errors = ParseError decodeErr |> List.singleton }, validationErrors errMsg )


view : Model -> Document Msg
view model =
    let
        { pane, viewEditor, editorValue } =
            model
    in
    { title = "RDB Model Editor"
    , body =
        [ div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
            [ SplitPane.view
                viewConfig
                (editorViewPart model.session.isFileSystemSupported (ViewEditor.isInitState model.viewEditor))
                (div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
                    [ ViewEditor.view editorValue.present viewEditor |> Html.map ViewEditorMsg
                    , ViewUndoRedo.view model.editorValue |> Html.map ViewUndoRedo
                    , div
                        [ style "position" "absolute"
                        , style "top" "5px"
                        , style "right" "5px"
                        , style "font-size" "16px"
                        , style "user-select" "none"
                        , style "display" "flex"
                        ]
                        [ SaveDomain.view ClickSaveDomain ]
                    ]
                )
                pane
            , div [ style "position" "fixed", style "bottom" "0", style "left" "0", style "font-size" "9px" ] [ text <| "v" ++ model.session.version ]
            , Error.view model.errors |> Html.map ErrorMsg
            ]
        ]
    }


viewConfig : ViewConfig Msg
viewConfig =
    createViewConfig
        { toMsg = PaneMsg
        , customSplitter = Nothing
        }


editorViewPart : Bool -> Bool -> Html Msg
editorViewPart showFileButton showLoading =
    div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
        [ div [ id "code-editor", Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
            [ if showLoading then
                svg
                    [ style "vertical-align" "middle"
                    , style "top" "50%"
                    , style "left" "50%"
                    , style "transform" "translate(-50%,-50%)"
                    , style "position" "absolute"
                    , width <| Px 24
                    , height <| Px 24
                    , viewBox 0 0 24 24
                    , strokeWidth <| Px 1
                    , stroke (Paint Color.black)
                    , fill PaintNone
                    , strokeLinecap StrokeLinecapRound
                    , strokeLinejoin StrokeLinejoinRound
                    ]
                    [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                    , path [ d "M9 4.55a8 8 0 0 1 6 14.9m0 -4.45v5h5" ] []
                    , line [ x1 (Px 5.63), y1 (Px 7.16), x2 (Px 5.63), y2 (Px 7.17) ] []
                    , line [ x1 (Px 4.06), y1 (Px 11), x2 (Px 4.06), y2 (Px 11.01) ] []
                    , line [ x1 (Px 4.63), y1 (Px 15.1), x2 (Px 4.63), y2 (Px 15.11) ] []
                    , line [ x1 (Px 7.16), y1 (Px 18.37), x2 (Px 7.16), y2 (Px 18.38) ] []
                    , line [ x1 (Px 11), y1 (Px 19.94), x2 (Px 11), y2 (Px 19.95) ] []
                    ]

              else
                text ""
            ]
        , if showFileButton then
            FilePicker.view |> Html.map FilePicker

          else
            text ""
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ ViewEditor.subscriptions model.viewEditor |> Sub.map ViewEditorMsg
        , ViewUndoRedo.subscriptions model.viewUndoRedo |> Sub.map ViewUndoRedo
        , Sub.map PaneMsg <| SplitPane.subscriptions model.pane
        , editorValueSaved <| EditorValueReceived
        , initEditorRequest InitEditorRequestReceived
        , requestValueToSave RequestValueToSave
        , receivedFromLocalStorage ReceivedFromLocalStorage
        ]


changeSelectedView : Maybe String -> Model -> Model
changeSelectedView selectedView model =
    { model | viewEditor = ViewEditor.changeSelectedView selectedView model.viewEditor }
