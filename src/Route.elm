module Route exposing (Route(..), fromUrl, href, replaceUrl)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Browser.Navigation as Nav
import Url exposing (Url)

type Route
    = Home
    | Editor



parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Editor (s "editor")
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url



-- INTERNAL


routeToString : Route -> String
routeToString page =
    "#/" ++ String.join "/" (routeToPieces page)


routeToPieces : Route -> List String
routeToPieces page =
    case page of
        Home ->
            []

        Editor ->
            [ "editor" ]
