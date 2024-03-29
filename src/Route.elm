module Route exposing (Route(..), editorLinkPastebin, editorLinkInit, editorLinkDropbox, fromUrl, editorLinkTwitter)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s, string)
import Url.Parser.Query as Query


type Route
    = Home
    | Editor (Maybe String) (Maybe String)


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Editor (s "editor" </> (string |> Parser.map Just) <?> Query.string "link")
        , Parser.map (Editor Nothing) (s "editor" <?> Query.string "link")
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    let
        ( path, query ) =
            parseFragment url.fragment
    in
    { url | path = Maybe.withDefault "" path, query = query, fragment = Nothing }
        |> Parser.parse parser


parseFragment : Maybe String -> ( Maybe String, Maybe String )
parseFragment value =
    let
        splitted =
            value |> Maybe.map (String.split "?")

        path =
            splitted |> Maybe.andThen List.head

        query =
            splitted |> Maybe.andThen List.tail |> Maybe.andThen List.head
    in
    ( path, query )


editorLinkPastebin : String
editorLinkPastebin =
    "#/editor/main?link=https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/pastebin.yaml"


editorLinkDropbox : String
editorLinkDropbox =
    "#/editor/main?link=https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/dropbox.yaml"

editorLinkTwitter : String
editorLinkTwitter =
    "#/editor/main?link=https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/twitter.yaml"


editorLinkInit : String
editorLinkInit =
    "#/editor/main?link=https://raw.githubusercontent.com/RDBModel/rdbmodel.github.io/master/init.yaml"
