module FilePicker exposing (..)

import Color
import Html exposing (Html, button, div)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import JsInterop exposing (openFileOpenDialog, openSaveFileDialog, tryToSaveCurrentEditorValue)
import SaveDomain.SaveDomain as SaveDomain
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
import Html.Attributes exposing (title)
import Html.Attributes exposing (type_)


type Msg
    = OpenFile
    | SaveFile
    | SaveToLocalStorage


update : Msg -> Cmd Msg
update msg =
    case msg of
        OpenFile ->
            openFileOpenDialog ()

        SaveFile ->
            openSaveFileDialog ()

        SaveToLocalStorage ->
            tryToSaveCurrentEditorValue ()


view : Html Msg
view =
    div
        [ style "position" "absolute"
        , style "top" "5px"
        , style "right" "20px"
        , style "font-size" "16px"
        , style "user-select" "none"
        , style "display" "flex"
        ]
        [ button
            [ style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , title "Load domain from file system"
            , type_ "button"
            , onClick <| OpenFile
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
                , path [ d "M14 3v4a1 1 0 0 0 1 1h4" ] []
                , path [ d "M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z" ] []
                , path [ d "M12 17v-6" ] []
                , path [ d "M9.5 14.5l2.5 2.5l2.5 -2.5" ] []
                ]
            ]
        , button
            [ style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , title "Save domain to file system"
            , type_ "button"
            , onClick <| SaveFile
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
                , path [ d "M14 3v4a1 1 0 0 0 1 1h4" ] []
                , path [ d "M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z" ] []
                , path [ d "M12 11v6" ] []
                , path [ d "M9.5 13.5l2.5 -2.5l2.5 2.5" ] []
                ]
            ]
        , SaveDomain.view SaveToLocalStorage
        ]
