module Route exposing (Route(..), fromUrl, editorRoute)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s)
import Url.Parser.Query as Query
import Url exposing (Url)

type Route
    = Home
    | Editor (Maybe String)



parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Editor (s "editor" <?> Query.string "view")
        ]

-- PUBLIC HELPERS


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url

-- INTERNAL

editorRoute : String
editorRoute = "editor?view=view-1"
