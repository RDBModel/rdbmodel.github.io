module TestDomainDecoder exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Parser
import DomainDecoder exposing (domainDecoder, viewsDecoder, View, ViewElement, ViewRelation, Relation, Delivery, Block, Ring
  , Actor, Domain)
import Yaml.Decode as D
import Dict exposing (Dict)

input = """
domain:
  name: Name
  description: Description
  actors:
    actor-1:
      name: Actor
      description: Description
      relations:
        - uses - delivery-1
  rings:
    ring-1:
      name: Ring 1 name
      description: Description
      relations: []
      deliveries: {}
    ring-2:
      name: Ring 2 name
      description: Description
      relations:
        - uses - ring-1
      deliveries:
        delivery-1:
          name: delivery 1
          description: Description
          relations:
            - calls - delivery-2
            - uses - ring-1
          blocks:
            delivery-1--block-1:
              name: block 1
              description: Description
              relations:
                - uses - delivery-1--block-2
                - calls - delivery-2--block-1
                - uses - ring-1
            delivery-1--block-2:
              name: block 2
              description: Description
              relations:
                []
        delivery-2:
          name: delivery 2
          description: Description
          relations:
            []
          blocks:
            delivery-2--block-1:
              name: block 1
              description: Description
              relations:
                - uses - delivery-2--block-2
            delivery-2--block-2:
              name: block 2
              description: Description
              relations:
                []
views:
  view-1:
    elements:
      ring-1:
        x: 100
        y: 100
      delivery-1:
        x: 200
        y: 200
        relations:
          - target: delivery-2
            points:
              - x: 300
                y: 150
          - target: ring-1
            label: uses
      delivery-2:
        x: 300
        y: 300

"""

suite : Test
suite =
    describe "parse yaml model"
        [ test "domain" <|
          \_ ->
            input
            |> D.fromString domainDecoder
            |> Expect.equal
              ( Ok 
                ( Domain
                  "Name"
                  "Description"
                  ( Dict.fromList
                    [ ( "actor-1", Actor "Actor" "Description" [ Relation "delivery-1" "uses" ] ) ])
                  ( Dict.fromList
                    [ ( "ring-1", Ring "Ring 1 name" "Description" [] Dict.empty )
                    , ( "ring-2", Ring "Ring 2 name" "Description"
                        [ Relation "ring-1" "uses" ]
                        ( Dict.fromList
                          [ ( "delivery-1", Delivery "delivery 1" "Description"
                              [ Relation "delivery-2" "calls"
                              , Relation "ring-1" "uses"
                              ]
                              ( Dict.fromList
                                [ ( "delivery-1--block-1", Block "block 1" "Description"
                                    [ Relation "delivery-1--block-2" "uses"
                                    , Relation "delivery-2--block-1" "calls"
                                    , Relation "ring-1" "uses"
                                    ]
                                  )
                                , ( "delivery-1--block-2", Block "block 2" "Description"
                                    [ ]
                                  )
                                ]
                              )
                            )
                          , ( "delivery-2", Delivery "delivery 2" "Description"
                              [ ]
                              ( Dict.fromList
                                [ ( "delivery-2--block-1", Block "block 1" "Description"
                                  [ Relation "delivery-2--block-2" "uses"
                                  ]
                                )
                                , ( "delivery-2--block-2", Block "block 2" "Description"
                                  [ ]
                                )
                                ]
                              )
                            )
                          ]
                        )
                      )
                    ]
                  )
                )
              )
        , test "view" <|
          \_ ->
            input
            |> D.fromString viewsDecoder
            |> Expect.equal
              ( Ok
                ( Dict.fromList
                  [ ( "view-1", View 
                      ( Dict.fromList 
                        [ ( "ring-1", ViewElement 100 100 Nothing )
                        , ( "delivery-1", ViewElement 200 200
                            ( Just ( Dict.fromList 
                              [ ( "calls - delivery-2--block-1", [ ViewRelation 280 280 ] )
                              , ( "uses - ring-1", [ ] )
                              ] )
                            )
                          )
                        , ( "delivery-2", ViewElement 300 300 Nothing )
                        ]
                      )
                    )
                  ]
                )
              )
        ]
