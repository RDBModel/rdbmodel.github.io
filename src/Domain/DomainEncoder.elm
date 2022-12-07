module Domain.DomainEncoder exposing (..)

import Yaml.Encode exposing (..)
import Domain.Domain exposing (Domain, View, Relation, Ring, ViewElement, ViewRelationPoint, relationSplitter)
import Dict exposing (Dict)
import Element.Region exposing (description)
import Domain.Domain exposing (Delivery)

rdbEncode : { a | views: Dict String View, domain: Maybe Domain } -> String
rdbEncode { views, domain } =
    case domain of
        Nothing -> ""
        Just d -> toString 2 (rdbEncoder (d, views))

rdbEncoder : (Domain, Dict String View) -> Encoder
rdbEncoder (domain, views) =
    record
        [ ("domain", domainEncoder domain)
        , ("views", dict identity viewEncoder views)
        ]

domainEncoder : Domain -> Encoder
domainEncoder domain =
    record
        [ ("name", string domain.name)
        , ("description", string domain.description)
        , ("actors", dict identity basicEncoder domain.actors)
        , ("systems", dict identity ringEncoder domain.rings)
        ]

basicEncoder : { a | name : String, description : String, relations: List Relation } -> Encoder
basicEncoder item =
    record
        [ ("name", string item.name)
        , ("description", string item.description)
        , ("relations", list relationEncoder item.relations)]

relationEncoder : Relation -> Encoder
relationEncoder =
    relationToString >> string

relationToString : Relation -> String
relationToString (target, description) =
    description ++ relationSplitter ++ target

ringEncoder : Ring -> Encoder
ringEncoder ring =
    record
        [ ("name", string ring.name)
        , ("description", string ring.description)
        , ("relations", list relationEncoder ring.relations)
        , ("containers", dict identity deliveryEncoder ring.delivery)
        ]

deliveryEncoder : Delivery -> Encoder
deliveryEncoder delivery =
    record
        [ ("name", string delivery.name)
        , ("description", string delivery.description)
        , ("relations", list relationEncoder delivery.relations)
        , ("components", dict identity basicEncoder delivery.blocks)
        ]

viewEncoder : View -> Encoder
viewEncoder view =
    record
        [ ("elements", dict identity viewElementEncoder view.elements)
        ]

viewElementEncoder : ViewElement -> Encoder
viewElementEncoder viewElement =
    if Dict.isEmpty viewElement.relations then
        record
            [ ("x", float viewElement.x)
            , ("y", float viewElement.y)
            ]
    else
        record
            [ ("x", float viewElement.x)
            , ("y", float viewElement.y)
            , ("relations", dict relationToString (list viewRelationPointEncoder) viewElement.relations)
            ]

viewRelationPointEncoder : ViewRelationPoint -> Encoder
viewRelationPointEncoder viewRelationPoint =
    record
        [ ("x", float viewRelationPoint.x)
        , ("y", float viewRelationPoint.y)
        ]
