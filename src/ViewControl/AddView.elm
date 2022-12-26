module ViewControl.AddView exposing (Action(..), Model, Msg, init, subscriptions, update, view)

import Browser.Events as Events
import Color
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (class, style, value)
import Html.Events exposing (onBlur, onClick, onFocus, onInput)
import Json.Decode as Decode
import TypedSvg exposing (line, path, svg)
import TypedSvg.Attributes
    exposing
        ( d
        , fill
        , height
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
import Html.Attributes exposing (title)
import Html.Attributes exposing (type_)


type alias Model =
    { addNewViewBoxVisible : Bool
    , newViewIdTemp : String
    , newViewInputIsInFocus : Bool
    }


init : Model
init =
    Model False "" False


type Msg
    = AddView
    | NewViewId String
    | EnterIsClicked
    | InputFocused
    | InputBlur
    | NoOp


type Action
    = NewView String


update : Msg -> Model -> ( Model, Cmd Msg, List Action )
update msg model =
    case msg of
        AddView ->
            ( { model | addNewViewBoxVisible = model.addNewViewBoxVisible |> not }, Cmd.none, [] )

        NewViewId value ->
            ( { model | newViewIdTemp = value }, Cmd.none, [] )

        EnterIsClicked ->
            ( { model | newViewIdTemp = "", addNewViewBoxVisible = False }
            , Cmd.none
            , if model.newViewInputIsInFocus then
                [ NewView model.newViewIdTemp ]

              else
                []
            )

        InputFocused ->
            ( { model | newViewInputIsInFocus = True }, Cmd.none, [] )

        InputBlur ->
            ( { model | newViewInputIsInFocus = False }, Cmd.none, [] )

        NoOp ->
            ( model, Cmd.none, [] )


view : Model -> Html Msg
view model =
    div
        [ style "position" "absolute"
        , style "display" "grid"
        , style "top" "5px"
        , style "left" "5px"
        , style "font-size" "16px"
        , style "user-select" "none"

        --, Mouse.onContextMenu (\_ -> NoOp)
        ]
        [ button
            [ style "background-color" "white"
            , style "border" "1px solid rgba(204, 204, 204, .6)"
            , style "min-height" "24px"
            , style "max-width" "26px"
            , style "padding" "0"
            , title "Create new view for domain"
            , type_ "button"
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
                , line [ x1 (Px 12), y1 (Px 5), x2 (Px 12), y2 (Px 19) ] []
                , line [ x1 (Px 5), y1 (Px 12), x2 (Px 19), y2 (Px 12) ] []
                ]
            ]
        , if model.addNewViewBoxVisible then
            input
                [ style "background-color" "white"
                , style "border" "1px solid rgba(204, 204, 204, .6)"
                , class "elm-select-input"
                , style "margin-top" "2px"
                , style "min-height" "20px"
                , onInput NewViewId
                , onFocus InputFocused
                , onBlur InputBlur
                , value model.newViewIdTemp
                ]
                []

          else
            text ""
        ]


subscriptions : Sub Msg
subscriptions =
    Events.onKeyDown (keyDecoder |> enterButton)


enterButton : Decode.Decoder String -> Decode.Decoder Msg
enterButton =
    Decode.map
        (\key ->
            if key == "Enter" then
                EnterIsClicked

            else
                NoOp
        )


keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string
