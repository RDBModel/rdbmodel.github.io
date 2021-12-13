module DomainDecoder exposing (domainDecoder, Domain, Actor, Relation, Ring, Delivery, Block)

import Yaml.Decode exposing (..)
import Dict exposing (Dict)

type alias Domain =
  { name : String
  , description : String
  , actors : Dict String Actor
  , rings : Dict String Ring
  }

type alias Actor = 
  { name : String
  , description : String
  , relations : List Relation
  }

type alias Ring =
  { name : String
  , description : String
  , relations : List Relation
  , delivery : Dict String Delivery
  }

type alias Delivery =
  { name : String
  , description : String
  , relations : List Relation
  , blocks : Dict String Block
  }

type alias Block =
  { name : String
  , description : String
  , relations : List Relation
  }

type alias Relation =
  { target : String
  , description : String
  }

domainDecoder : Decoder Domain
domainDecoder = field "domain" internalDomainDecoder

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


getRelationFromString : String -> Result String Relation
getRelationFromString value =
  let
    splitted = String.split " - " value

    description = List.head splitted

    target = List.tail splitted |> Maybe.andThen List.head
  in
  case (description, target) of
    ( Just d, Just t) ->
      Ok (Relation t d)
    _ ->
      Err "Relations should be formated like 'purpose - target'"
