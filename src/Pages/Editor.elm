module Pages.Editor exposing (Model, Msg, init, subscriptions, update, view)

import Browser exposing (Document)
import Browser.Dom as Dom
import Color
import Dict exposing (Dict)
import Domain.Domain exposing (Domain, View, ViewItemKey(..))
import Domain.DomainDecoder exposing (rdbDecoder)
import Domain.DomainEncoder exposing (rdbEncode)
import FilePicker
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (style)
import JsInterop
    exposing
        ( initMonacoRequest
        , initMonacoResponse
        , monacoEditorInitialValue
        , monacoEditorSavedValue
        , requestValueToSave
        , saveValueToFile
        , updateMonacoValue
        , validationErrors
        )
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
import UndoRedo.ViewUndoRedo as ViewUndoRedo exposing (UndoRedoMonacoValue, getUndoRedoMonacoValue, mapPresent, newRecord)
import UndoRedo.ViewUndoRedoActions as ViewUndoRedoActions exposing (MonacoValue)
import ViewEditor.Editor as ViewEditor
import ViewEditor.EditorAction as ViewEditorActions
import Yaml.Decode as D


type alias Model =
    { session : Session
    , pane : State
    , viewEditor : ViewEditor.Model
    , monacoValue : UndoRedoMonacoValue MonacoValue
    , viewUndoRedo : ViewUndoRedo.Model
    , showOpenFileButton : Bool
    , toReload : Bool
    , errors : String
    }


init : Session -> String -> ( Model, Cmd Msg )
init session selectedView =
    ( Model
        session
        (SplitPane.init Horizontal)
        (ViewEditor.init selectedView)
        (getUndoRedoMonacoValue getMonacoValue)
        ViewUndoRedo.init
        False
        True
        ""
    , Task.attempt ReceiveMonacoElementPosition (Dom.getElement "monaco")
    )


getMonacoValue : MonacoValue
getMonacoValue =
    MonacoValue Dict.empty Nothing


type Msg
    = MonacoEditorValueReceived String
    | ReceiveMonacoElementPosition (Result Dom.Error Dom.Element)
    | MonacoEditorInitialValueReceived String
    | ViewEditorMsg ViewEditor.Msg
    | PaneMsg SplitPane.Msg
    | InitMonacoRequestReceived ()
    | RequestValueToSave ()
    | FilePicker FilePicker.Msg
    | ViewUndoRedo ViewUndoRedo.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveMonacoElementPosition (Ok _) ->
            ( model
            , initMonacoResponse ()
            )

        ReceiveMonacoElementPosition (Err _) ->
            -- TODO
            ( model
            , Cmd.none
            )

        PaneMsg paneMsg ->
            ( { model | pane = SplitPane.update paneMsg model.pane }
            , Cmd.none
            )

        MonacoEditorValueReceived val ->
            case D.fromString rdbDecoder val of
                Ok ( domain, views ) ->
                    let
                        newModel =
                            { model
                                | errors = ""
                                , monacoValue =
                                    let
                                        currentMonacoValue =
                                            model.monacoValue.present

                                        updatedMonacoValue =
                                            { currentMonacoValue
                                                | domain = Just domain
                                                , views = views
                                            }
                                    in
                                    newRecord updatedMonacoValue model.monacoValue
                            }
                    in
                    ( newModel
                    , Cmd.batch
                        [ ViewEditor.getElementPosition |> Cmd.map ViewEditorMsg
                        , validationErrors ""
                        ]
                    )

                Err err ->
                    case err of
                        D.Parsing errMsg ->
                            ( model, validationErrors errMsg )

                        D.Decoding errMsg ->
                            ( model, validationErrors errMsg )

        MonacoEditorInitialValueReceived val ->
            case D.fromString rdbDecoder val of
                Ok ( domain, views ) ->
                    let
                        newMonacoValue a =
                            { a
                                | domain = Just domain
                                , views = views
                            }

                        newModel =
                            { model
                                | errors = ""
                                , showOpenFileButton = True
                                , monacoValue = mapPresent newMonacoValue model.monacoValue
                            }
                    in
                    ( newModel
                    , Cmd.batch
                        [ ViewEditor.getElementPosition |> Cmd.map ViewEditorMsg
                        , validationErrors ""
                        ]
                    )

                Err err ->
                    case err of
                        D.Parsing errMsg ->
                            ( model, validationErrors errMsg )

                        D.Decoding errMsg ->
                            ( model, validationErrors errMsg )

        InitMonacoRequestReceived _ ->
            ( model, initMonacoResponse () )

        RequestValueToSave _ ->
            ( model, saveValueToFile (rdbEncode model.monacoValue.present) )

        ViewEditorMsg subMsg ->
            let
                ( updated, cmd, actions ) =
                    ViewEditor.update model.session model.monacoValue.present subMsg model.viewEditor

                ( newMonacoModel, updatedCmds ) =
                    ViewEditorActions.apply { monacoValue = model.monacoValue, cmd = cmd } actions
            in
            ( { model | viewEditor = updated, monacoValue = newMonacoModel, toReload = False }
            , updatedCmds |> Cmd.map ViewEditorMsg
            )

        FilePicker subMsg ->
            let
                cmd =
                    FilePicker.update subMsg
            in
            ( model, cmd |> Cmd.map FilePicker )

        ViewUndoRedo subMsg ->
            let
                ( subModel, updatedMonacoValue, actions ) =
                    ViewUndoRedo.update model.monacoValue subMsg model.viewUndoRedo
            in
            ( { model
                | viewUndoRedo = subModel
                , monacoValue = updatedMonacoValue
              }
            , ViewUndoRedoActions.apply updatedMonacoValue.present actions
            )


view : Model -> Document Msg
view model =
    let
        { pane, viewEditor, monacoValue } =
            model
    in
    { title = "RDB Model Editor"
    , body =
        [ div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
            [ SplitPane.view
                viewConfig
                (div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
                    [ ViewEditor.view monacoValue.present viewEditor |> Html.map ViewEditorMsg
                    , ViewUndoRedo.view |> Html.map ViewUndoRedo
                    ]
                )
                (monacoViewPart (model.showOpenFileButton && model.session.isFileSystemSupported) (ViewEditor.isInitState model.viewEditor))
                pane
            , div [ style "position" "fixed", style "bottom" "0", style "left" "0", style "font-size" "9px" ] [ text "v0.0.1" ]
            ]
        ]
    }


viewConfig : ViewConfig Msg
viewConfig =
    createViewConfig
        { toMsg = PaneMsg
        , customSplitter = Nothing
        }


monacoViewPart : Bool -> Bool -> Html Msg
monacoViewPart showButton showLoading =
    div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
        [ div [ id "monaco", Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
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
        , if showButton then
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
        , monacoEditorInitialValue <| MonacoEditorInitialValueReceived
        , monacoEditorSavedValue <| MonacoEditorValueReceived
        , initMonacoRequest InitMonacoRequestReceived
        , requestValueToSave RequestValueToSave
        ]
