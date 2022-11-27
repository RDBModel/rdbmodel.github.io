module EditView.ViewControl exposing (Model, Msg, Action(..), view, update, getSelectedView, init
    , subscriptions)

import Html.Attributes exposing (style, class, value)
import Html.Events exposing (onClick, onInput, onFocus, onBlur)
import Html exposing (Html, div, button, input, text)
import Select
import Domain exposing (View, getViewElements)
import Dict exposing (Dict)
import TypedSvg exposing (svg, path, line)
import TypedSvg.Attributes exposing ( d, viewBox, strokeWidth, stroke, fill, strokeLinecap, strokeLinejoin,
    x1, x2, y1, y2, width, height)
import TypedSvg.Types exposing ( Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import Color
import Browser.Events as Events
import Json.Decode as Decode

type alias SelectModel a =
    { state : Select.State
    , config : Select.Config Msg a
    }

type alias Model =
    { selectView : SelectModel String
    , selectedView : String
    , selectElement : SelectModel (String, String)
    , addNewViewBoxVisible : Bool
    , newViewIdTemp : String
    , newViewInputIsInFocus : Bool
    }

selectView : SelectModel String
selectView =
    SelectModel
        (Select.init "selectView")
        (Select.newConfig
            { onSelect = OnViewSelect
            , toLabel = identity
            , filter = \v items -> items |> List.filter (\val -> val |> String.toLower |> String.contains (String.toLower v)) |> Just
            , toMsg = SelectViewMsg
            }
        |> Select.withCutoff 12
        |> Select.withEmptySearch True
        |> Select.withNotFound "No matches"
        |> Select.withClear False
        |> Select.withPrompt "Select a view")

selectElement : SelectModel (String, String)
selectElement =
    SelectModel
        (Select.init "selectElement")
        (Select.newConfig
            { onSelect = OnElementSelect
            , toLabel = \(key, value) -> (value ++ " (" ++ key ++ ")")
            , filter = \v items -> items |> List.filter (\(k, val) -> k ++ val |> String.toLower |> String.contains (String.toLower v)) |> Just
            , toMsg = SelectElementMsg
            }
        |> Select.withCutoff 12
        |> Select.withEmptySearch True
        |> Select.withNotFound "No matches"
        |> Select.withClear False
        |> Select.withPrompt "An element to add")

init : String -> Model
init selectedView = Model selectView selectedView selectElement False "" False

type Action
    = NewView String
    | AddElementToView (String, String)
    | ChangeView String

type Msg
    = SelectViewMsg (Select.Msg String)
    | SelectElementMsg (Select.Msg (String, String))
    | OnViewSelect (Maybe String)
    | OnElementSelect (Maybe (String, String))
    | AddView
    | NewViewId String
    | EnterIsClicked
    | InputFocused
    | InputBlur
    | NoOp

update : Msg -> Model -> ( Model, Cmd Msg, List Action )
update msg model =
    case msg of
        SelectViewMsg subMsg ->
            let
                ( updated, cmd ) =
                    Select.update
                        model.selectView.config
                        subMsg
                        model.selectView.state

                updatedSelectModel m = { m | state = updated }
            in
            ( { model | selectView = updatedSelectModel model.selectView }
            , cmd
            , []
            )
        SelectElementMsg subMsg ->
            let
                ( updated, cmd ) =
                    Select.update
                        model.selectElement.config
                        subMsg
                        model.selectElement.state

                updatedSelectModel m = { m | state = updated }
            in
            ( { model | selectElement = updatedSelectModel model.selectElement }
            , cmd
            , []
            )
        OnViewSelect maybeView ->
            let
                selected =
                    maybeView
                        |> Maybe.withDefault model.selectedView
            in
            ( { model | selectedView = selected }
            , Cmd.none
            , [ ChangeView selected ]
            )
        OnElementSelect maybeElement ->
            ( model
            , Cmd.none
            , maybeElement |> Maybe.map AddElementToView |> Maybe.map List.singleton |> Maybe.withDefault []
            )
        AddView ->
            ( { model | addNewViewBoxVisible = model.addNewViewBoxVisible |> not }, Cmd.none, [] )
        NewViewId value ->
            ( { model | newViewIdTemp = value }, Cmd.none, [] )
        EnterIsClicked ->
            ( { model | newViewIdTemp = "", addNewViewBoxVisible = False }, Cmd.none
            , if model.newViewInputIsInFocus then
                [ NewView model.newViewIdTemp ]
            else
                []
            )
        InputFocused ->
            ( { model | newViewInputIsInFocus = True }, Cmd.none, [] )
        InputBlur ->
            ( { model | newViewInputIsInFocus = False }, Cmd.none, [] )
        NoOp -> ( model, Cmd.none, [] )

view : Dict String View -> List (String, String) -> Model -> Html Msg
view views elements model =
    let
        viewElements = Dict.get model.selectedView views |> getViewElements
    in
    div
        [ style "position" "absolute"
        , style "display" "grid" -- grid-template-columns: repeat(3, 1fr);
        , style "grid-auto-flow" "row"
        , style "grid-template-columns" "24px auto auto"
        , style "top" "5px"
        , style "left" "50%"
        , style "transform" "translateX(-50%)"
        , style "font-size" "16px"
        , style "user-select" "none"
        --, Mouse.onContextMenu (\_ -> NoOp)
        ]
        [ button
            [ style "background-color" "white"
            , style "border" "1px solid rgba(204, 204, 204, .6)"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "max-width" "24px"
            , style "padding" "0"
            , style "grid-column" "1"
            , style "grid-row" "1"
            , onClick AddView
            ]
            [ svg
                [ style "vertical-align" "middle"
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
                , line [ x1 (Px 12), y1 (Px 5), x2 (Px 12), y2 (Px 19)] []
                , line [ x1 (Px 5), y1 (Px 12), x2 (Px 19), y2 (Px 12)] []
                ]
            ]
        , if model.addNewViewBoxVisible then
            input
                    [ style "background-color" "white"
                    , style "border" "1px solid rgba(204, 204, 204, .6)"
                    , class "elm-select-input"
                    , style "margin-top" "2px"
                    , style "min-height" "20px"
                    , style "grid-column" "1/3"
                    , style "grid-row" "2"
                    , onInput NewViewId
                    , onFocus InputFocused
                    , onBlur InputBlur
                    , value model.newViewIdTemp
                    ] []
            else
                text ""
        , Select.view
            model.selectView.config
            model.selectView.state
            (Dict.keys views)
            [model.selectedView]
        , Select.view
            model.selectElement.config
            model.selectElement.state
            ( elements |> List.filter (\(key, _) -> List.member key viewElements |> not) )
            []
        ]

getSelectedView : Model -> String
getSelectedView model = model.selectedView

subscriptions : Sub Msg
subscriptions =
    Events.onKeyDown (keyDecoder |> enterButton)

enterButton : Decode.Decoder String -> Decode.Decoder Msg
enterButton =
    Decode.map (\key ->
        if key == "Enter" then
            EnterIsClicked
        else
            NoOp)

keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string
