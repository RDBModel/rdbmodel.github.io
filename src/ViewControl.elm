module ViewControl exposing (Model, view, update, getSelectedView, init, selectedViewChanged, Msg)

import Html.Attributes exposing (style)
import Html exposing (Html, div)
import Select
import Domain exposing (View, getViewElements)
import Dict exposing (Dict)

type alias SelectModel a =
    { state : Select.State
    , config : Select.Config Msg a
    }

type alias Model =
    { selectView : SelectModel String
    , selectedView : String
    , selectElement : SelectModel (String, String)
    , viewChanged : Bool
    , elementToAdd : Maybe (String, String)
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
init selectedView = Model selectView selectedView selectElement False Nothing

type Msg
    = SelectViewMsg (Select.Msg String)
    | SelectElementMsg (Select.Msg (String, String))
    | OnViewSelect (Maybe String)
    | OnElementSelect (Maybe (String, String))

view : Dict String View -> List (String, String) -> Model -> Html Msg
view views elements model =
    let
        viewElements = Dict.get model.selectedView views |> getViewElements
    in
    div
        [ style "position" "absolute"
        , style "width" "310px"
        , style "display" "flex"
        , style "justify-content" "space-between"
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

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model  =
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
            ,  cmd
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
            ,  cmd
            )
        OnViewSelect maybeView ->
            let
                selected =
                    maybeView
                        |> Maybe.withDefault model.selectedView
            in
            ( { model | selectedView = selected, viewChanged = selected /= model.selectedView }
            , Cmd.none
            )
        OnElementSelect maybeElement ->
            ( { model | elementToAdd = maybeElement }
            , Cmd.none
            )

selectedViewChanged : Model -> Bool
selectedViewChanged model = model.viewChanged

getSelectedView : Model -> String
getSelectedView model = model.selectedView
