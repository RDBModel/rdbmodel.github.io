module ContextMenu exposing (..)

import Html.Events.Extra.Mouse as Mouse
import Html exposing (Attribute, text, div, Html)
import Html.Attributes exposing (style)
import Browser.Events as Events
import Json.Decode as Decode
import ContainerMenu
import JsInterop exposing (onWheel)
import Domain exposing (ViewRelationKey)

type alias Model =
    { menuState : Maybe { position : (Float, Float), hover : Bool }
    , context : ContainerMenu.Model
    }

init : ContainerMenu.Model -> Model
init subModel =
    Model Nothing subModel

type Msg
    = ShowMenu String (Float, Float)
    | EnterMenu
    | LeaveMenu
    | HideMenu
    | ContainerMenuMsg ContainerMenu.Msg

update : Msg -> Model -> (Model, Cmd Msg, (Maybe ViewRelationKey, Maybe String))
update msg model =
    case msg of
        ShowMenu containerId pos ->
            ( { model
            | menuState = Just { position = pos, hover = True }
            , context = ContainerMenu.updateContainerId containerId model.context
            }
            , Cmd.none
            , Tuple.pair Nothing Nothing )
        HideMenu ->
            case model.menuState of
                Just m ->
                    if m.hover then
                        ( model, Cmd.none, Tuple.pair Nothing Nothing )
                    else
                        ( { model | menuState = Nothing }, Cmd.none, Tuple.pair Nothing Nothing )
                Nothing -> ( model, Cmd.none, Tuple.pair Nothing Nothing )
        EnterMenu ->
            case model.menuState of
                Just m ->
                    ( { model | menuState = Just { position = m.position, hover = True } }, Cmd.none, Tuple.pair Nothing Nothing )
                Nothing ->
                    ( model, Cmd.none, Tuple.pair Nothing Nothing )
        LeaveMenu ->
            case model.menuState of
                Just m ->
                    ( { model | menuState = Just { position = m.position, hover = False } }, Cmd.none, Tuple.pair Nothing Nothing )
                Nothing ->
                    ( model, Cmd.none, Tuple.pair Nothing Nothing )
        ContainerMenuMsg subMsg ->
            let
                (updatedModel, cmd, (maybeRelation, maybeContainerIdToDelete)) =
                    ContainerMenu.update subMsg model.context

                updatedMenuState = case (maybeRelation, maybeContainerIdToDelete) of
                    (Just _, Nothing) -> Nothing
                    (Nothing, Just _) -> Nothing
                    _ -> model.menuState
            in
            ( { model | context = updatedModel, menuState = updatedMenuState }
            , cmd |> Cmd.map ContainerMenuMsg
            , (maybeRelation, maybeContainerIdToDelete)
            )

view : Model -> Html Msg
view model =
    case model.menuState of
        Just state ->
            div
                [ style "position" "fixed"
                , style "left" ( (state.position |> Tuple.first |> String.fromFloat) ++ "px" )
                , style "top" ( (state.position |> Tuple.second |> String.fromFloat) ++ "px" )
                , Mouse.onEnter (\_ -> EnterMenu)
                , Mouse.onLeave (\_ -> LeaveMenu)
                ]
                [ ContainerMenu.view model.context |> Html.map ContainerMenuMsg ]
        Nothing ->
            text ""

attach : String -> Attribute Msg
attach containerId =
    Mouse.onContextMenu (\event -> ShowMenu containerId event.clientPos)

subscriptions : Model -> Sub Msg
subscriptions model =
    case model.menuState of
        Just _ ->
            Sub.batch
                [ Events.onMouseDown (Decode.succeed HideMenu)
                , onWheel (\_ -> HideMenu)
                ]
        Nothing -> Sub.none
