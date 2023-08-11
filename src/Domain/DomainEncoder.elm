module Domain.DomainEncoder exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Domain.Domain exposing (Data, Domain, Node(..), Relation, View, ViewElement, ViewRelationPoint, getName, relationSplitter)
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
                , ( "actors", dict identity dataEncoder domain.actors )
                , ( "systems", dict identity (nodeEncoder 0) domain.elements )
                ]

        Nothing ->
            record
                [ ( "name", string domain.name )
                , ( "actors", dict identity dataEncoder domain.actors )
                , ( "systems", dict identity (nodeEncoder 0) domain.elements )
                ]


nodeEncoder : Int -> Node -> Encoder
nodeEncoder level node =
    case node of
        Parent data children ->
            dataWithChildrenEncoder level data children

        Leaf data ->
            dataEncoder data


dataWithChildrenEncoder : Int -> Data -> Dict String Node -> Encoder
dataWithChildrenEncoder level data children =
    case getName level of
        Just name ->
            case ( data.description, data.relations ) of
                ( Just description, Just relations ) ->
                    record
                        [ ( "name", string data.name )
                        , ( "description", string description )
                        , ( "relations", list relationEncoder relations )
                        , ( name, dict identity (nodeEncoder (level + 1)) children )
                        ]

                ( Nothing, Just relations ) ->
                    record
                        [ ( "name", string data.name )
                        , ( "relations", list relationEncoder relations )
                        , ( name, dict identity (nodeEncoder (level + 1)) children )
                        ]

                ( Just description, Nothing ) ->
                    record
                        [ ( "name", string data.name )
                        , ( "description", string description )
                        , ( name, dict identity (nodeEncoder (level + 1)) children )
                        ]

                ( Nothing, Nothing ) ->
                    record
                        [ ( "name", string data.name )
                        , ( name, dict identity (nodeEncoder (level + 1)) children )
                        ]
        Nothing ->
            dataEncoder data


dataEncoder : Data -> Encoder
dataEncoder data =
    case ( data.description, data.relations ) of
        ( Just description, Just relations ) ->
            record
                [ ( "name", string data.name )
                , ( "description", string description )
                , ( "relations", list relationEncoder relations )
                ]

        ( Nothing, Just relations ) ->
            record
                [ ( "name", string data.name )
                , ( "relations", list relationEncoder relations )
                ]

        ( Just description, Nothing ) ->
            record
                [ ( "name", string data.name )
                , ( "description", string description )
                ]

        ( Nothing, Nothing ) ->
            record
                [ ( "name", string data.name )
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
