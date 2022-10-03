module DomainDecoder exposing (rdbDecoder)

import Yaml.Decode exposing (..)
import Domain exposing (..)
import Dict exposing (Dict)
import Validation exposing (validateViews, validateDomain)

rdbDecoder : Decoder (Domain, Dict String View)
rdbDecoder =
  let
    domain = domainDecoder |> andThen (validateDomain >> fromResult)
  in
  map2 Tuple.pair
    domain
    viewsDecoder
  |> andThen (validateViews >> fromResult)

domainDecoder : Decoder Domain
domainDecoder = field "domain" internalDomainDecoder

viewsDecoder : Decoder (Dict String View)
viewsDecoder = field "views" internalViewsDecoder

internalDomainDecoder : Decoder Domain
internalDomainDecoder =
  map4 Domain
    (field "name" string)
    (field "description" string)
    (field "actors" (dict actorDecoder))
    (field "rings" (dict ringDecoder))

ringDecoder : Decoder Ring
ringDecoder =
  map4 Ring
    (field "name" string)
    (field "description" string)
    (field "relations" (list relationDecoder))
    (field "deliveries" (dict deliveryDecoder))

deliveryDecoder : Decoder Delivery
deliveryDecoder =
  map4 Delivery
    (field "name" string)
    (field "description" string)
    (field "relations" (list relationDecoder))
    (field "blocks" (dict blockDecoder))

blockDecoder : Decoder Block
blockDecoder =
  basicDecoder Block

actorDecoder : Decoder Actor
actorDecoder =
  basicDecoder Actor

basicDecoder : (String -> String -> List Relation -> a) -> Decoder a
basicDecoder constructor =
  map3 constructor
    (field "name" string)
    (field "description" string)
    (field "relations" (list relationDecoder))


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
      |> map (Maybe.withDefault Dict.empty))


mapViewRelationDecoder : Decoder (Dict String (List ViewRelationPoint)) -> Decoder (Dict Relation (List ViewRelationPoint))
mapViewRelationDecoder = map convertDictKeys


convertDictKeys : Dict String (List ViewRelationPoint) -> Dict Relation (List ViewRelationPoint)
convertDictKeys dict =
  dict |> Dict.foldl
    (\k v newD ->
      case getRelationFromString k of
        Ok relation ->
          Dict.insert relation v newD
        Err _ -> newD
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
    splitted = String.split relationSplitter value

    description = List.head splitted

    target = List.tail splitted |> Maybe.andThen List.head
  in
  case (description, target) of
    ( Just d, Just t) ->
      Ok (t, d)
    _ ->
      Err "Relations should be formatted like 'purpose - target'"


getNameByKey : Domain -> String -> Maybe String
getNameByKey domain key =
  Dict.get key domain.rings
    |> Maybe.map (\i -> Just i.name)
    |> Maybe.withDefault
      ( Dict.values domain.rings
        |> List.filterMap (\i -> Dict.get key i.delivery |> Maybe.map .name)
        |> List.head
        |> Maybe.map (\i -> Just i)
        |> Maybe.withDefault
          ( Dict.values domain.rings
            |> List.concatMap (\i -> Dict.values i.delivery)
            |> List.filterMap (\i -> Dict.get key i.blocks |> Maybe.map .name)
            |> List.head
          )
      )
