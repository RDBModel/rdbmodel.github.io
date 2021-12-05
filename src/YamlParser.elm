module YamlParser exposing (..)
import Parser exposing (Parser, chompUntil, succeed, symbol, getChompedString, chompWhile
    , spaces, (|.), (|=), chompUntilEndOr)

type alias ModelRelation =
    { description : String
    , target : String
    }

relation : Parser ModelRelation
relation =
    succeed ModelRelation
        |. spaces
        |. symbol "-"
        |. spaces
        |= getChompedString (chompUntil " - ")
        |. spaces
        |. symbol "-"
        |. spaces
        |= getChompedString (chompUntilEndOr "\n")
