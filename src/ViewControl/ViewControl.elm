module ViewControl.ViewControl exposing (Action(..), Model, Msg, init, update, view)

import Dict exposing (Dict)
import Domain.Domain exposing (View, getViewElements)
import Html exposing (Html, div)
import Html.Attributes exposing (style, value)
import Select
import TypedSvg.Types exposing (Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))


type alias SelectModel a =
    { state : Select.State
    , config : Select.Config Msg a
    }


type alias Model =
    { selectView : SelectModel String
    , selectElement : SelectModel ( String, String )
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
            |> Select.withPrompt "Select a view"
        )


selectElement : SelectModel ( String, String )
selectElement =
    SelectModel
        (Select.init "selectElement")
        (Select.newConfig
            { onSelect = OnElementSelect
            , toLabel = \( key, value ) -> value ++ " (" ++ key ++ ")"
            , filter = \v items -> items |> List.filter (\( k, val ) -> k ++ val |> String.toLower |> String.contains (String.toLower v)) |> Just
            , toMsg = SelectElementMsg
            }
            |> Select.withCutoff 12
            |> Select.withEmptySearch True
            |> Select.withNotFound "No matches"
            |> Select.withClear False
            |> Select.withPrompt "An element to add"
        )


init : Model
init =
    Model selectView selectElement


type Action
    = AddElementToView ( String, String )
    | ChangeView (Maybe String)


type Msg
    = SelectViewMsg (Select.Msg String)
    | SelectElementMsg (Select.Msg ( String, String ))
    | OnViewSelect (Maybe String)
    | OnElementSelect (Maybe ( String, String ))


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

                updatedSelectModel m =
                    { m | state = updated }
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

                updatedSelectModel m =
                    { m | state = updated }
            in
            ( { model | selectElement = updatedSelectModel model.selectElement }
            , cmd
            , []
            )

        OnViewSelect maybeView ->
            ( model
            , Cmd.none
            , [ ChangeView maybeView ]
            )

        OnElementSelect maybeElement ->
            ( model
            , Cmd.none
            , maybeElement |> Maybe.map AddElementToView |> Maybe.map List.singleton |> Maybe.withDefault []
            )


view : Maybe String -> Dict String View -> List ( String, String ) -> Model -> Html Msg
view selectedView views elements model =
    let
        viewElements =
            selectedView
                |> Maybe.map (\v -> Dict.get v views |> getViewElements)
                |> Maybe.withDefault []
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
            (selectedView |> Maybe.map List.singleton |> Maybe.withDefault [])
        , Select.view
            model.selectElement.config
            model.selectElement.state
            (elements |> List.filter (\( key, _ ) -> List.member key viewElements |> not))
            []
        ]
