module ContainerMenu.Menu exposing (Model, init, Msg, update, view, updateContainerId)

import Dict exposing (Dict)
import Domain.Domain exposing (Relation)
import Html exposing (Html, div, button, text)
import Html.Attributes exposing (style)
import Domain.DomainEncoder exposing (relationToString)
import Select
import Domain.Domain exposing (ViewRelationKey)
import Html.Events exposing (onClick)

type alias SelectModel a =
    { state : Select.State
    , config : Select.Config Msg a
    }

initSelect : SelectModel ViewRelationKey
initSelect =
    SelectModel
        (Select.init "selectRelation")
        (Select.newConfig
            { onSelect = OnRelationSelect
            , toLabel = Tuple.second >> relationToString
            , filter = \v items -> items
                |> List.filter (Tuple.second
                    >> relationToString
                    >> String.toLower
                    >> String.contains (String.toLower v))
                |> Just
            , toMsg = SelectRelationMsg
            }
        |> Select.withCutoff 5
        |> Select.withEmptySearch True
        |> Select.withNotFound "No relations to add"
        |> Select.withClear False
        |> Select.withPrompt "A relation to add")

type alias Model =
    { containerId : String
    , selectRelation : SelectModel ViewRelationKey
    , possibleRelations : Dict String (List Relation)
    }

updateContainerId : String -> Model -> Model
updateContainerId containerId model = { model | containerId = containerId }

init : Dict String (List Relation) -> Model
init possibleRelations =
    Model "" initSelect possibleRelations

type MenuContext
    = Container (Dict String (List Relation))

type Msg
    = OnRelationSelect (Maybe ViewRelationKey)
    | SelectRelationMsg (Select.Msg ViewRelationKey)
    | DeleteAnElement

update : Msg -> Model -> (Model, Cmd Msg, (Maybe ViewRelationKey, Maybe String))
update msg model =
    case msg of
        OnRelationSelect maybeRelation ->
            let
                updatedRelations =
                    case maybeRelation of
                        Just (containerId, relation) ->
                            Dict.update containerId
                                (Maybe.map (List.filter (\i -> i /= relation)))
                                model.possibleRelations
                        Nothing -> model.possibleRelations
            in
            ( { model | possibleRelations = updatedRelations }
            , Cmd.none
            , Tuple.pair maybeRelation Nothing
            )
        SelectRelationMsg subMsg ->
            let
                ( updated, cmd ) =
                    Select.update
                        model.selectRelation.config
                        subMsg
                        model.selectRelation.state

                updatedSelectModel m = { m | state = updated }
            in
            ( { model | selectRelation = updatedSelectModel model.selectRelation }
            , cmd
            , Tuple.pair Nothing Nothing
            )
        DeleteAnElement ->
             ( model
            , Cmd.none
            , Tuple.pair Nothing (Just model.containerId)
            )

view : Model -> Html Msg
view model =
    div []
        [ button
            [ style "background-color" "white"
            , style "border-width" "1px 1px 0 1px"
            , style "border-style" "solid"
            , style "border-color" "rgba(204, 204, 204, .6)"
            , style "width" "100%"
            , style "min-height" "24px"
            , style "padding" "0"
            , onClick DeleteAnElement
            ]
            [ text "Delete an element" ]
        , Select.view
            model.selectRelation.config
            model.selectRelation.state
            (Dict.get model.containerId model.possibleRelations
                |> Maybe.withDefault []
                |> List.map (\x -> (model.containerId, x)))
            []
        ]
