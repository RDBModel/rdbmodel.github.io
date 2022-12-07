module Pages.Editor exposing (Model, Msg, update, init, view, subscriptions)

import Dict exposing (Dict)
import SplitPanel.SplitPane as SplitPane exposing (Orientation(..), ViewConfig, State, createViewConfig)
import Domain.Domain exposing (Domain, View, ViewItemKey(..))
import ViewUndoRedo exposing (UndoRedoMonacoValue, getUndoRedoMonacoValue, newRecord, mapPresent)
import Browser.Dom as Dom
import FilePicker
import JsInterop exposing (initMonacoResponse, validationErrors, updateMonacoValue, saveValueToFile
    , monacoEditorInitialValue, monacoEditorSavedValue, initMonacoRequest, requestValueToSave)
import Yaml.Decode as D
import Domain.DomainDecoder exposing (rdbDecoder)
import Task
import Domain.DomainEncoder exposing (rdbEncode)
import Session exposing (Session)
import Browser exposing (Document)
import Html exposing (text)
import Html exposing (Html, div, text, a)
import Html.Attributes exposing (style)
import TypedSvg.Attributes exposing (id)
import TypedSvg.Types exposing ( Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import ViewEditor.Editor as ViewEditor
import ViewEditor.EditorAction as ViewEditorActions

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

type alias MonacoValue =
    { views : Dict String View
    , domain : Maybe Domain
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
        ReceiveMonacoElementPosition (Ok _ ) ->
            ( model
            , initMonacoResponse ()
            )

        ReceiveMonacoElementPosition (Err _ ) ->
            -- TODO
            ( model
            , Cmd.none
            )

        PaneMsg paneMsg ->
            ( { model | pane = SplitPane.update paneMsg model.pane }
            , Cmd.none )

        MonacoEditorValueReceived val ->
            case D.fromString rdbDecoder val of
                Ok (domain, views) ->
                    let
                        newModel =
                            { model
                            | errors = ""
                            , monacoValue =
                                let
                                    currentMonacoValue = model.monacoValue.present
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
                Ok (domain, views) ->
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
            (model, initMonacoResponse ())

        RequestValueToSave _ ->
            ( model, saveValueToFile (rdbEncode model.monacoValue.present) )

        ViewEditorMsg subMsg ->
            let
                ( updated, cmd, actions ) = ViewEditor.update model.session model.monacoValue.present subMsg model.viewEditor

                ( newMonacoModel, updatedCmds ) = ViewEditorActions.apply { monacoValue = model.monacoValue, cmd = cmd } actions
            in
            ( { model | viewEditor = updated, monacoValue = newMonacoModel, toReload = False }
            , updatedCmds |> Cmd.map ViewEditorMsg
            )

        FilePicker subMsg ->
            let
                cmd = FilePicker.update subMsg
            in
            (model, cmd |> Cmd.map FilePicker)

        ViewUndoRedo subMsg ->
            let
                ( subModel, updatedMonacoValue, renew ) = ViewUndoRedo.update model.monacoValue subMsg model.viewUndoRedo
            in
            ( { model
            | viewUndoRedo = subModel
            , monacoValue = updatedMonacoValue }
            , if renew then
                updateMonacoValue (rdbEncode updatedMonacoValue.present)
            else
                Cmd.none
            )

view : Model -> Document Msg
view model =
    let
        { pane, viewEditor, monacoValue } = model
    in
    { title = "RDB Model Editor"
    , body =
        [ div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
            [ SplitPane.view
                viewConfig
                ( div [ Html.Attributes.style "width" "100%", Html.Attributes.style "height" "100%" ]
                    [ ViewEditor.view monacoValue.present viewEditor |> Html.map ViewEditorMsg
                    , ViewUndoRedo.view |> Html.map ViewUndoRedo
                    ]
                )
                (monacoViewPart (model.showOpenFileButton && model.session.isFileSystemSupported))
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
