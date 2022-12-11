module ContainerMenu.ContextMenu exposing (Model, Msg, attach, init, subscriptions, update, view)

import Browser.Events as Events
import ContainerMenu.Menu as ContainerMenu
import ContainerMenu.MenuActions exposing (Action)
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (style)
import Html.Events.Extra.Mouse as Mouse
import JsInterop exposing (onWheel)
import Json.Decode as Decode


type alias Model =
    { menuState : Maybe { position : ( Float, Float ), hover : Bool }
    , context : ContainerMenu.Model
    }


init : ContainerMenu.Model -> Model
init subModel =
    Model Nothing subModel


type Msg
    = ShowMenu String ( Float, Float )
    | EnterMenu
    | LeaveMenu
    | HideMenu
    | ContainerMenuMsg ContainerMenu.Msg


update : Msg -> Model -> ( Model, Cmd Msg, List Action )
update msg model =
    case msg of
        ShowMenu containerId pos ->
            ( { model
                | menuState = Just { position = pos, hover = True }
                , context = ContainerMenu.updateContainerId containerId model.context
              }
            , Cmd.none
            , []
            )

        HideMenu ->
            case model.menuState of
                Just m ->
                    if m.hover then
                        ( model, Cmd.none, [] )

                    else
                        ( { model | menuState = Nothing }, Cmd.none, [] )

                Nothing ->
                    ( model, Cmd.none, [] )

        EnterMenu ->
            case model.menuState of
                Just m ->
                    ( { model | menuState = Just { position = m.position, hover = True } }, Cmd.none, [] )

                Nothing ->
                    ( model, Cmd.none, [] )

        LeaveMenu ->
            case model.menuState of
                Just m ->
                    ( { model | menuState = Just { position = m.position, hover = False } }, Cmd.none, [] )

                Nothing ->
                    ( model, Cmd.none, [] )

        ContainerMenuMsg subMsg ->
            let
                ( updatedModel, cmd, actions ) =
                    ContainerMenu.update subMsg model.context

                updatedMenuState =
                    if List.isEmpty actions then
                        model.menuState

                    else
                        Nothing
            in
            ( { model | context = updatedModel, menuState = updatedMenuState }
            , cmd |> Cmd.map ContainerMenuMsg
            , actions
            )


view : Model -> Html Msg
view model =
    case model.menuState of
        Just state ->
            div
                [ style "position" "fixed"
                , style "left" ((state.position |> Tuple.first |> String.fromFloat) ++ "px")
                , style "top" ((state.position |> Tuple.second |> String.fromFloat) ++ "px")
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

        Nothing ->
            Sub.none
