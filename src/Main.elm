module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html
import Pages.Editor as Editor
import Pages.Home as Home
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)


main : Program ( Bool, String ) Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }


init : ( Bool, String ) -> Url -> Nav.Key -> ( Model, Cmd Msg )
init ( isFileSystemSupported, version ) url navKey =
    changeRouteTo (Route.fromUrl url) (Session isFileSystemSupported version navKey)


type Model
    = Home Session
    | Editor Editor.Model


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | EditorMsg Editor.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (getNavKey model) (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, Home session ) ->
            changeRouteTo (Route.fromUrl url) session

        ( ChangedUrl url, Editor editorModel ) ->
            let
                newRoute =
                    Route.fromUrl url
            in
            case newRoute of
                Just (Route.Editor selectedView _) ->
                    ( Editor (Editor.changeSelectedView selectedView editorModel)
                    , Cmd.none
                    )

                _ ->
                    changeRouteTo newRoute editorModel.session

        ( EditorMsg subMsg, Editor subModel ) ->
            let
                ( updatedSubModel, subCmd ) =
                    Editor.update subMsg subModel
            in
            ( Editor updatedSubModel, Cmd.map EditorMsg subCmd )

        ( _, Home _ ) ->
            ( model, Cmd.none )


getNavKey : Model -> Nav.Key
getNavKey model =
    case model of
        Home { key } ->
            key

        Editor { session } ->
            session.key


changeRouteTo : Maybe Route -> Session -> ( Model, Cmd Msg )
changeRouteTo maybeRoute session =
    case maybeRoute of
        Nothing ->
            ( Home session, Cmd.none )

        Just Route.Home ->
            ( Home session, Cmd.none )

        Just (Route.Editor selectedView link) ->
            let
                ( subModel, subCmd ) =
                    Editor.init session selectedView link
            in
            ( Editor subModel
            , Cmd.map EditorMsg subCmd
            )


view : Model -> Document Msg
view model =
    case model of
        Home _ ->
            { title = "RDB Model"
            , body = [ Home.view ]
            }

        Editor editorModel ->
            let
                viewPage toMsg config =
                    let
                        { title, body } =
                            config
                    in
                    { title = title
                    , body = List.map (Html.map toMsg) body
                    }
            in
            viewPage EditorMsg (Editor.view editorModel)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Home _ ->
            Sub.none

        Editor editorModel ->
            Editor.subscriptions editorModel |> Sub.map EditorMsg
