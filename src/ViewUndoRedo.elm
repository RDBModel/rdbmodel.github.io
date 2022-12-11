module ViewUndoRedo exposing (Model, Msg, UndoRedoMonacoValue, getUndoRedoMonacoValue, init, mapPresent, newRecord, subscriptions, update, view)

import Browser.Events as Events
import Color
import Html exposing (Html, button, div)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import TypedSvg exposing (path, svg)
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
        )
import TypedSvg.Types exposing (Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import UndoList exposing (UndoList)


type alias Model =
    { ctrlIsDown : Bool
    }


init : Model
init =
    Model False


getUndoRedoMonacoValue : a -> UndoRedoMonacoValue a
getUndoRedoMonacoValue a =
    a |> UndoList.fresh


newRecord : a -> UndoRedoMonacoValue a -> UndoRedoMonacoValue a
newRecord a previous =
    UndoList.new a previous


mapPresent : (a -> a) -> UndoRedoMonacoValue a -> UndoRedoMonacoValue a
mapPresent a current =
    UndoList.mapPresent a current


type alias UndoRedoMonacoValue a =
    UndoList a


type Msg
    = Undo
    | Redo
    | NoOp
    | SetCtrlIsDown Bool


update : UndoRedoMonacoValue a -> Msg -> Model -> ( Model, UndoRedoMonacoValue a, Bool )
update targetValue msg model =
    case msg of
        Undo ->
            ( model, UndoList.undo targetValue, True )

        Redo ->
            ( model, UndoList.redo targetValue, True )

        SetCtrlIsDown value ->
            ( { model | ctrlIsDown = value }, targetValue, False )

        NoOp ->
            ( model, targetValue, False )


view : Html Msg
view =
    div
        [ style "position" "absolute"
        , style "width" "50px"
        , style "display" "flex"
        , style "justify-content" "space-between"
        , style "bottom" "5px"
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
            , style "padding" "0"
            , onClick Undo
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
                , path [ d "M9 13l-4 -4l4 -4m-4 4h11a4 4 0 0 1 0 8h-1" ] []
                ]
            ]
        , button
            [ style "background-color" "white"
            , style "border" "1px solid rgba(204, 204, 204, .6)"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , onClick Redo
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
                , path [ d "M15 13l4 -4l-4 -4m4 4h-11a4 4 0 0 0 0 8h1" ] []
                ]
            ]
        ]


keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string


setCtrlState : Decode.Decoder String -> Decode.Decoder Msg
setCtrlState =
    Decode.map
        (\key ->
            if key == "Control" then
                SetCtrlIsDown False

            else
                NoOp
        )


setCtrlAndOtherState : Model -> Decode.Decoder String -> Decode.Decoder Msg
setCtrlAndOtherState model =
    Decode.map
        (\key ->
            if key == "Control" then
                SetCtrlIsDown True

            else if key == "z" && model.ctrlIsDown then
                Undo

            else if key == "y" && model.ctrlIsDown then
                Redo

            else
                NoOp
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Events.onKeyDown (keyDecoder |> setCtrlAndOtherState model)
        , Events.onKeyUp (keyDecoder |> setCtrlState)
        ]
