module Error.Error exposing (ErrorLocation(..), Model, Msg, Source(..), ViewError(..), update, view)

import Browser.Dom as Dom
import Color
import Dict exposing (Dict)
import Html exposing (Html, a, br, button, div, text)
import Html.Attributes exposing (href, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Set
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


type alias Model =
    List Source


type Source
    = DomainParse String
    | DomainDecode ErrorLocation
    | ParseError Decode.Error
    | ExternalDomainDownload Http.Error
    | GetElementPosition Dom.Error


type ErrorLocation
    = DomainLocation SimpleListOfErrors
    | ViewsLocation ViewErrors


type alias ViewErrors =
    Dict String (List ViewError)


type ViewError
    = SimpleViewError SimpleListOfErrors
    | ComplexViewError ComplexListOfErrors


type alias SimpleListOfErrors =
    Dict String (List String)


type alias ComplexListOfErrors =
    Dict String (Dict String String)


type Msg
    = RemoveViewErrors String
    | RemoveErrorBySource Source


update : Msg -> Model -> Model
update msg model =
    case msg of
        RemoveErrorBySource source ->
            List.filter (\item -> item /= source) model

        RemoveViewErrors viewName ->
            let
                filterDomainDecode item =
                    case item of
                        DomainDecode (ViewsLocation viewErrors) ->
                            Dict.remove viewName viewErrors |> ViewsLocation |> DomainDecode

                        _ ->
                            item
            in
            List.map filterDomainDecode model


view : Model -> Html Msg
view errors =
    List.concatMap viewError errors
        |> List.take 3
        |> div
            [ style "position" "fixed"
            , style "bottom" "0"
            , style "right" "0"
            , style "min-width" "200px"
            ]


viewError : Source -> List (Html Msg)
viewError errorSource =
    case errorSource of
        DomainParse message ->
            [ closeButton (RemoveErrorBySource errorSource), text message ] |> wrapIntoBox |> List.singleton

        DomainDecode errorsLocation ->
            viewDecodeError errorsLocation

        ParseError err ->
            [ closeButton (RemoveErrorBySource errorSource)
            , text "Really sorry for this error. Unfortunately, you have to provide more details about the error. "
            , a [ href "https://github.com/RDBModel/rdbmodel.github.io/issues" ] [ text "Please contact the author." ]
            , text " Original error: "
            , br [] []
            , text (Decode.errorToString err)
            ]
                |> wrapIntoBox
                |> List.singleton

        ExternalDomainDownload errValue ->
            let
                errorMessage =
                    case errValue of
                        Http.BadUrl value ->
                            "Bad url is " ++ value

                        Http.Timeout ->
                            "Timeout"

                        Http.NetworkError ->
                            "Network error"

                        Http.BadStatus value ->
                            "Status is " ++ String.fromInt value

                        Http.BadBody value ->
                            "Bad boyd is " ++ value
            in
            [ closeButton (RemoveErrorBySource errorSource)
            , text ("Not able to download domain value by link. " ++ errorMessage)
            ]
                |> wrapIntoBox
                |> List.singleton

        GetElementPosition errValue ->
            let
                errorMessage =
                    case errValue of
                        Dom.NotFound value ->
                            "Not found. " ++ value
            in
            [ closeButton (RemoveErrorBySource errorSource)
            , text ("Not able to get dom element position. " ++ errorMessage)
            ]
                |> wrapIntoBox
                |> List.singleton


closeButton : Msg -> Html Msg
closeButton closeMsg =
    button
        [ style "background-color" "transparent"
        , style "border" "0"
        , style "min-height" "24px"
        , style "max-width" "26px"
        , style "padding" "0"
        , style "position" "absolute"
        , style "top" "0"
        , style "right" "0"
        , onClick closeMsg
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
            , line [ x1 (Px 18), y1 (Px 6), x2 (Px 6), y2 (Px 18) ] []
            , line [ x1 (Px 6), y1 (Px 6), x2 (Px 18), y2 (Px 18) ] []
            ]
        ]


wrapIntoBox : List (Html msg) -> Html msg
wrapIntoBox inner =
    div
        [ style "background-color" "#fecaca"
        , style "padding" "10px 30px 10px 15px"
        , style "margin" "5px"
        , style "border-radius" "5px"
        , style "position" "relative"
        ]
        inner


viewDecodeError : ErrorLocation -> List (Html Msg)
viewDecodeError errorTypes =
    case errorTypes of
        DomainLocation simpleList ->
            closeButton (errorTypes |> DomainDecode |> RemoveErrorBySource) :: showDictOfList simpleList |> wrapIntoBox |> List.singleton

        ViewsLocation simpleDict ->
            Dict.foldr showListOfViewError [] simpleDict


showListOfViewError : String -> List ViewError -> List (Html Msg) -> List (Html Msg)
showListOfViewError viewName viewErrorsType items =
    let
        errorMessage viewErrorType =
            case viewErrorType of
                SimpleViewError dictOfLists ->
                    showDictOfList dictOfLists

                ComplexViewError dictOfDicts ->
                    showDictOfDict dictOfDicts

        closeButtonRender =
            closeButton (RemoveViewErrors viewName)

        allViewErrorsRender =
            List.concatMap errorMessage viewErrorsType
    in
    (closeButtonRender :: viewNameRender viewName :: allViewErrorsRender |> wrapIntoBox) :: items


showDictOfList : Dict String (List String) -> List (Html msg)
showDictOfList values =
    Dict.toList values |> List.concatMap (\( x, y ) -> errorTypeView x :: showList y)


showDictOfDict : Dict String (Dict String String) -> List (Html msg)
showDictOfDict values =
    Dict.toList values |> List.concatMap (\( x, y ) -> errorTypeView x :: showDict y)


viewNameRender : String -> Html msg
viewNameRender name =
    div [ style "font-weight" "bolder", style "font-size" "large", style "margin-bottom" "2px" ]
        [ text name ]


errorTypeView : String -> Html msg
errorTypeView name =
    div [ style "font-weight" "bolder", style "margin-bottom" "2px" ]
        [ text name ]


showList : List String -> List (Html msg)
showList =
    Set.fromList >> Set.toList >> List.foldl (\i prev -> div [] [ text i ] :: prev) []


showDict : Dict String String -> List (Html msg)
showDict =
    Dict.foldl (\k v prev -> text (v ++ " (" ++ k ++ ")") :: prev) []
