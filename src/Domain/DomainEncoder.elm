module Domain.DomainEncoder exposing (..)

import Dict exposing (Dict)
import Domain.Domain exposing (Delivery, Domain, Relation, Ring, View, ViewElement, ViewRelationPoint, relationSplitter)
import Element.Region exposing (description)
import Yaml.Encode exposing (..)


rdbEncode : { a | views : Dict String View, domain : Maybe Domain } -> String
rdbEncode { views, domain } =
    case domain of
        Nothing ->
            ""

        Just d ->
            toString 2 (rdbEncoder ( d, views ))


rdbEncoder : ( Domain, Dict String View ) -> Encoder
rdbEncoder ( domain, views ) =
    record
        [ ( "domain", domainEncoder domain )
        , ( "views", dict identity viewEncoder views )
        ]


domainEncoder : Domain -> Encoder
domainEncoder domain =
    record
        [ ( "name", string domain.name )
        , ( "description", string domain.description )
        , ( "actors", dict identity basicEncoder domain.actors )
        , ( "systems", dict identity ringEncoder domain.rings )
        ]


basicEncoder : { a | name : String, description : String, relations : Maybe (List Relation) } -> Encoder
basicEncoder item =
    case item.relations of
        Just r ->
            record
                [ ( "name", string item.name )
                , ( "description", string item.description )
                , ( "relations", list relationEncoder r )
                ]
        Nothing ->
            record
                [ ( "name", string item.name )
                , ( "description", string item.description )
                ]


relationEncoder : Relation -> Encoder
relationEncoder =
    relationToString >> string


relationToString : Relation -> String
relationToString ( target, description ) =
    description ++ relationSplitter ++ target


ringEncoder : Ring -> Encoder
ringEncoder ring =
    case (ring.relations, ring.delivery) of
        (Just relations, Just deliveries) ->
            record
                [ ( "name", string ring.name )
                , ( "description", string ring.description )
                , ( "relations", list relationEncoder relations )
                , ( "containers", dict identity deliveryEncoder deliveries )
                ]
        (Nothing, Just deliveries) ->
            record
                [ ( "name", string ring.name )
                , ( "description", string ring.description )
                , ( "containers", dict identity deliveryEncoder deliveries )
                ]
        (Just relations, Nothing) ->
            record
                [ ( "name", string ring.name )
                , ( "description", string ring.description )
                , ( "relations", list relationEncoder relations )
                ]
        (Nothing, Nothing) ->
            record
                [ ( "name", string ring.name )
                , ( "description", string ring.description )
                ]


deliveryEncoder : Delivery -> Encoder
deliveryEncoder delivery =
    case (delivery.relations, delivery.blocks) of
        (Just relations, Just blocks) ->
            record
                [ ( "name", string delivery.name )
                , ( "description", string delivery.description )
                , ( "relations", list relationEncoder relations )
                , ( "components", dict identity basicEncoder blocks )
                ]
        (Nothing, Just blocks) ->
            record
                [ ( "name", string delivery.name )
                , ( "description", string delivery.description )
                , ( "components", dict identity basicEncoder blocks )
                ]
        (Just relations, Nothing) ->
            record
                [ ( "name", string delivery.name )
                , ( "description", string delivery.description )
                , ( "relations", list relationEncoder relations )
                ]
        (Nothing, Nothing) ->
            record
                [ ( "name", string delivery.name )
                , ( "description", string delivery.description )
                ]


viewEncoder : View -> Encoder
viewEncoder view =
    record
        [ ( "elements", dict identity viewElementEncoder view.elements )
        ]


viewElementEncoder : ViewElement -> Encoder
viewElementEncoder viewElement =
    if Dict.isEmpty viewElement.relations then
        record
            [ ( "x", float viewElement.x )
            , ( "y", float viewElement.y )
            ]

    else
        record
            [ ( "x", float viewElement.x )
            , ( "y", float viewElement.y )
            , ( "relations", dict relationToString (list viewRelationPointEncoder) viewElement.relations )
            ]


viewRelationPointEncoder : ViewRelationPoint -> Encoder
viewRelationPointEncoder viewRelationPoint =
    record
        [ ( "x", float viewRelationPoint.x )
        , ( "y", float viewRelationPoint.y )
        ]
