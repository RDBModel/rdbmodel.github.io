module Domain.DomainDecoder exposing (rdbDecoder)

import Dict exposing (Dict)
import Domain.Domain exposing (..)
import Domain.Validation exposing (validateDomain, validateViews)
import Yaml.Decode exposing (..)


rdbDecoder : Decoder ( Domain, Dict String View )
rdbDecoder =
    let
        domain =
            domainDecoder |> andThen (validateDomain >> fromResult)
    in
    map2 Tuple.pair
        domain
        viewsDecoder
        |> andThen (validateViews >> fromResult)


domainDecoder : Decoder Domain
domainDecoder =
    field "domain" internalDomainDecoder


viewsDecoder : Decoder (Dict String View)
viewsDecoder =
    field "views" internalViewsDecoder


internalDomainDecoder : Decoder Domain
internalDomainDecoder =
    map4 Domain
        (field "name" string)
        (field "description" string)
        (field "actors" (dict actorDecoder))
        (field "systems" (dict ringDecoder))


ringDecoder : Decoder Ring
ringDecoder =
    map4 Ring
        (field "name" string)
        (field "description" string)
        (field "relations" (list relationDecoder) |> maybe)
        (field "containers" (dict deliveryDecoder) |> maybe)


deliveryDecoder : Decoder Delivery
deliveryDecoder =
    map4 Delivery
        (field "name" string)
        (field "description" string)
        (field "relations" (list relationDecoder) |> maybe)
        (field "components" (dict blockDecoder) |> maybe)


blockDecoder : Decoder Block
blockDecoder =
    basicDecoder Block


actorDecoder : Decoder Actor
actorDecoder =
    basicDecoder Actor


basicDecoder : (String -> String -> Maybe (List Relation) -> a) -> Decoder a
basicDecoder constructor =
    map3 constructor
        (field "name" string)
        (field "description" string)
        (field "relations" (list relationDecoder) |> maybe)


relationDecoder : Decoder Relation
relationDecoder =
    string |> andThen (getRelationFromString >> fromResult)


internalViewsDecoder : Decoder (Dict String View)
internalViewsDecoder =
    dict viewDecoder


viewDecoder : Decoder View
viewDecoder =
    map View
        (field "elements" (dict viewElementDecoder))


viewElementDecoder : Decoder ViewElement
viewElementDecoder =
    map3 ViewElement
        (field "x" float)
        (field "y" float)
        (maybe (field "relations" (dict (list viewRelationPointDecoder) |> mapViewRelationDecoder))
            |> map (Maybe.withDefault Dict.empty)
        )


mapViewRelationDecoder : Decoder (Dict String (List ViewRelationPoint)) -> Decoder (Dict Relation (List ViewRelationPoint))
mapViewRelationDecoder =
    map convertDictKeys


convertDictKeys : Dict String (List ViewRelationPoint) -> Dict Relation (List ViewRelationPoint)
convertDictKeys dict =
    dict
        |> Dict.foldl
            (\k v newD ->
                case getRelationFromString k of
                    Ok relation ->
                        Dict.insert relation v newD

                    Err _ ->
                        newD
            )
            Dict.empty


viewRelationPointDecoder : Decoder ViewRelationPoint
viewRelationPointDecoder =
    map2 ViewRelationPoint
        (field "x" float)
        (field "y" float)


getRelationFromString : String -> Result String Relation
getRelationFromString value =
    let
        splitted =
            String.split relationSplitter value

        description =
            List.head splitted

        target =
            List.tail splitted |> Maybe.andThen List.head
    in
    case ( description, target ) of
        ( Just d, Just t ) ->
            Ok ( t, d )

        _ ->
            Err "Relations should be formatted like 'purpose - target'"
