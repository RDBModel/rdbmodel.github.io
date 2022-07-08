module TestYamlParser exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Parser
import YamlParser exposing (relation, ModelRelation, relations)

suite : Test
suite =
    describe "parse relation"
        [ test "one" <|
            \_ ->
                Parser.run relation "- uses - container-1--component-2"
                |> Result.map (Expect.equal (ModelRelation "uses" "container-1--component-2"))
                |> Result.withDefault (Expect.fail "error")
        , test "many" <|
            \_ ->
                Parser.run relations "relations:\n    - uses - container-1--component-2\n    - uses - container-2--component-3\nnotes:"
                |> Debug.log "result"
                |> Result.map
                    ( Expect.equalLists
                        [ ModelRelation "uses" "container-1--component-2"
                        , ModelRelation "uses" "container-2--component-3"
                        ]
                    )
                |> Result.withDefault (Expect.fail "error")
        ]
