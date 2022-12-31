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
    case domain.description of
        Just f ->
            record
                [ ( "name", string domain.name )
                , ( "description", string f )
                , ( "actors", dict identity basicEncoder domain.actors )
                , ( "systems", dict identity ringEncoder domain.rings )
                ]

        Nothing ->
            record
                [ ( "name", string domain.name )
                , ( "actors", dict identity basicEncoder domain.actors )
                , ( "systems", dict identity ringEncoder domain.rings )
                ]


basicEncoder : { a | name : String, description : Maybe String, relations : Maybe (List Relation) } -> Encoder
basicEncoder item =
    case ( item.relations, item.description ) of
        ( Just relations, Just description ) ->
            record
                [ ( "name", string item.name )
                , ( "description", string description )
                , ( "relations", list relationEncoder relations )
                ]

        ( Nothing, Just description ) ->
            record
                [ ( "name", string item.name )
                , ( "description", string description )
                ]

        ( Just relations, Nothing ) ->
            record
                [ ( "name", string item.name )
                , ( "relations", list relationEncoder relations )
                ]

        ( Nothing, Nothing ) ->
            record
                [ ( "name", string item.name )
                ]


relationEncoder : Relation -> Encoder
relationEncoder =
    relationToString >> string


relationToString : Relation -> String
relationToString ( target, description ) =
    description ++ relationSplitter ++ target


ringEncoder : Ring -> Encoder
ringEncoder ring =
    case ( ring.relations, ring.delivery, ring.description ) of
        ( Just relations, Just deliveries, Just description ) ->
            record
                [ ( "name", string ring.name )
                , ( "description", string description )
                , ( "relations", list relationEncoder relations )
                , ( "containers", dict identity deliveryEncoder deliveries )
                ]

        ( Nothing, Just deliveries, Just description ) ->
            record
                [ ( "name", string ring.name )
                , ( "description", string description )
                , ( "containers", dict identity deliveryEncoder deliveries )
                ]

        ( Just relations, Nothing, Just description ) ->
            record
                [ ( "name", string ring.name )
                , ( "description", string description )
                , ( "relations", list relationEncoder relations )
                ]

        ( Nothing, Nothing, Just description ) ->
            record
                [ ( "name", string ring.name )
                , ( "description", string description )
                ]

        ( Just relations, Just deliveries, Nothing ) ->
            record
                [ ( "name", string ring.name )
                , ( "relations", list relationEncoder relations )
                , ( "containers", dict identity deliveryEncoder deliveries )
                ]

        ( Nothing, Just deliveries, Nothing ) ->
            record
                [ ( "name", string ring.name )
                , ( "containers", dict identity deliveryEncoder deliveries )
                ]

        ( Just relations, Nothing, Nothing ) ->
            record
                [ ( "name", string ring.name )
                , ( "relations", list relationEncoder relations )
                ]

        ( Nothing, Nothing, Nothing ) ->
            record
                [ ( "name", string ring.name )
                ]


deliveryEncoder : Delivery -> Encoder
deliveryEncoder delivery =
    case ( delivery.relations, delivery.blocks, delivery.description ) of
        ( Just relations, Just blocks, Just description ) ->
            record
                [ ( "name", string delivery.name )
                , ( "description", string description )
                , ( "relations", list relationEncoder relations )
                , ( "components", dict identity basicEncoder blocks )
                ]

        ( Nothing, Just blocks, Just description ) ->
            record
                [ ( "name", string delivery.name )
                , ( "description", string description )
                , ( "components", dict identity basicEncoder blocks )
                ]

        ( Just relations, Nothing, Just description ) ->
            record
                [ ( "name", string delivery.name )
                , ( "description", string description )
                , ( "relations", list relationEncoder relations )
                ]

        ( Nothing, Nothing, Just description ) ->
            record
                [ ( "name", string delivery.name )
                , ( "description", string description )
                ]

        ( Just relations, Just blocks, Nothing ) ->
            record
                [ ( "name", string delivery.name )
                , ( "relations", list relationEncoder relations )
                , ( "components", dict identity basicEncoder blocks )
                ]

        ( Nothing, Just blocks, Nothing ) ->
            record
                [ ( "name", string delivery.name )
                , ( "components", dict identity basicEncoder blocks )
                ]

        ( Just relations, Nothing, Nothing ) ->
            record
                [ ( "name", string delivery.name )
                , ( "relations", list relationEncoder relations )
                ]

        ( Nothing, Nothing, Nothing ) ->
            record
                [ ( "name", string delivery.name )
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
