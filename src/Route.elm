module Route exposing (Route(..), fromUrl, editorRoute)

import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s, string)
import Url exposing (Url)

type Route
    = Home
    | Editor String

parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Editor (s "editor" </> string)
        ]

-- PUBLIC HELPERS

fromUrl : Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser

-- INTERNAL

editorRoute : String
editorRoute = "#/editor/view-1"
