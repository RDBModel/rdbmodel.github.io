module ViewControl.ViewControl exposing (Model, Msg, Action(..), view, update, getSelectedView, init)

import Html.Attributes exposing (style, class, value)
import Html.Events exposing (onClick, onInput, onFocus, onBlur)
import Html exposing (Html, div, button, input, text)
import Select
import Domain.Domain exposing (View, getViewElements)
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
init selectedView = Model selectView selectedView selectElement

type Action
    = AddElementToView (String, String)
    | ChangeView String

type Msg
    = SelectViewMsg (Select.Msg String)
    | SelectElementMsg (Select.Msg (String, String))
    | OnViewSelect (Maybe String)
    | OnElementSelect (Maybe (String, String))

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

view : Dict String View -> List (String, String) -> Model -> Html Msg
view views elements model =
    let
        viewElements = Dict.get model.selectedView views |> getViewElements
    in
    div
        [ style "position" "absolute"
        , style "display" "grid"
        , style "grid-auto-flow" "row"
        , style "grid-template-columns" "auto auto"
        , style "top" "5px"
        , style "left" "50%"
        , style "transform" "translateX(-50%)"
        , style "font-size" "16px"
        , style "user-select" "none"
        --, Mouse.onContextMenu (\_ -> NoOp)
        ]
        [ Select.view
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
