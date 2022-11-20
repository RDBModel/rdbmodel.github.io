module ContainerMenu exposing (..)
import Dict exposing (Dict)
import Domain exposing (Relation)
import Html exposing (Html)
import DomainEncoder exposing (relationToString)
import Select

type alias SelectModel a =
    { state : Select.State
    , config : Select.Config Msg a
    }

initSelect : SelectModel Relation
initSelect =
    SelectModel
        (Select.init "selectRelation")
        (Select.newConfig
            { onSelect = OnRelationSelect
            , toLabel = relationToString
            , filter = \v items -> items
                |> List.filter (\i -> i
                    |> relationToString
                    |> String.toLower
                    |> String.contains ( v |> String.toLower))
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
    , selectRelation : SelectModel Relation
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
    = OnRelationSelect (Maybe Relation)
    | SelectRelationMsg (Select.Msg Relation)

update : Msg -> Model -> (Model, Cmd Msg, Maybe Relation)
update msg model =
    case msg of
        OnRelationSelect maybeRelation ->
            ( model
            , Cmd.none
            , maybeRelation
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
            , Nothing
            )

view : Model -> Html Msg
view model =
    Select.view
        model.selectRelation.config
        model.selectRelation.state
        (Dict.get model.containerId model.possibleRelations |> Maybe.withDefault [])
        []
