module TestYamlParser exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Parser
import YamlParser exposing (relation, ModelRelation)

suite : Test
suite =
    describe "parse relation"
        [ test "parser" <|
            \_ ->
                Parser.run relation "- uses - container-1--component-2"
                |> Result.map (Expect.equal (ModelRelation "uses" "container-1--component-2"))
                |> Result.withDefault (Expect.fail "error")
        ]
