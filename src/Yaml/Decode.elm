module Yaml.Decode exposing
    ( Decoder
    , fromString, Value, Error(..), fromValue, errorToString
    , string, bool, int, float, null
    , nullable, list, dict
    , field, at
    , oneOf, maybe
    , map, map2, map3, map4, map5, map6, map7, map8, andMap
    , lazy, value, fail, succeed, andThen
    , fromResult, fromMaybe
    )

{-| Turn [YAML](https://yaml.org) into Elm values. The library is structured in a similar way
to `Json.Decode`, so if you haven't worked with decoders before, reading through
[the guide](https://guide.elm-lang.org/effects/json.html) may be helpful.


## Table of Contents

  - **Primitives**: [int](#int), [string](#string), [bool](#bool), [float](#float), [null](#null)
  - **Data Structures**: [nullable](#nullable), [list](#list), [dict](#dict)
  - **Record Primitives**: [field](#field), [at](#at)
  - **Inconsistent Structure**: [oneOf](#oneOf), [maybe](#maybe)
  - **Maps**: [map](#map), [map2](#map2), [map3](#map3), [map4](#map4), [map5](#map5), [map6](#map6), [map7](#map7), [map8](#map8), [andMap](#andMap)
  - **Fancy Decoding**: [lazy](#lazy), [value](#value), [fail](#fail), [succeed](#succeed), [andThen](#andThen)
  - **Conversions**: [fromResult](#fromResult), [fromMaybe](#fromMaybe)

@docs Decoder


# Run Decoders

@docs fromString, Value, Error, fromValue, errorToString


# Primitives

@docs string, bool, int, float, null


# Data Structures

@docs nullable, list, dict


# Record Primitives

@docs field, at


# Inconsistent Structure

@docs oneOf, maybe


# Maps

@docs map, map2, map3, map4, map5, map6, map7, map8, andMap


# Fancy Decoding

@docs lazy, value, fail, succeed, andThen


# Conversions

@docs fromResult, fromMaybe

-}

import Dict
import Yaml.Parser as Yaml
import Yaml.Parser.Ast as Ast


{-| A value that knows how to decode YAML.

There is a whole section in guide.elm-lang.org about decoders,
so [check it out](https://guide.elm-lang.org/effects/json.html)
for a more comprehensive introduction!

-}
type Decoder a
    = Decoder (Yaml.Value -> Result Error a)



-- RUN DECODERS


{-| Represents a YAML tree.
-}
type alias Value =
    Yaml.Value


{-| A structured error describing how a decoder failed.
-}
type Error
    = Parsing String
    | Decoding String


{-| Decode a given string into an Elm value based on the
provided `Decoder`. This will fail if the string is not
well-formed YAML or if the `Decoder` doesn't match the
input.

    fromString int "4" --> Ok 4

    fromString int "hello" --> Err (Decoding "Expected int, got: \"hello\" (string)")

-}
fromString : Decoder a -> String -> Result Error a
fromString decoder raw =
    case Yaml.fromString raw of
        Ok v ->
            fromValue decoder v

        Err error ->
            Err (Parsing error)


{-| Run a `Decoder` on a Yaml `Value`.
-}
fromValue : Decoder a -> Value -> Result Error a
fromValue (Decoder decoder) v =
    decoder v


{-| Convert a structured error into a `String` that is nice for debugging.
-}
errorToString : Error -> String
errorToString e =
    case e of
        Parsing msg ->
            "Error in parsing: " ++ msg

        Decoding msg ->
            "Error in decoding: " ++ msg



-- PRIMITIVES


{-| Decode a YAML string into an Elm `String`.

    fromString string "true"
    --> Err (Decoding "Expected string, got: True (bool)")

    fromString string "'true'" --> Ok "true"

    fromString string "42"
    --> Err (Decoding "Expected string, got: 42 (int)")

    fromString string "'42'" --> Ok "42"

    fromString string "hello" --> Ok "hello"

    fromString string "hello: 42"
    --> Err (Decoding "Expected string, got: { hello: 42 (int) } (map)")

-}
string : Decoder String
string =
    Decoder <|
        \v ->
            case v of
                Ast.String_ string_ ->
                    Ok string_

                Ast.Null_ ->
                    Ok ""

                _ ->
                    decodeError "string" v


{-| Decode a YAML boolean into an Elm `Bool`.

    fromString bool "true" --> Ok True

    fromString bool "'true'"
    --> Err (Decoding "Expected bool, got: \"true\" (string)")

    fromString bool "42"
    --> Err (Decoding "Expected bool, got: 42 (int)")

    fromString bool "hello"
    --> Err (Decoding "Expected bool, got: \"hello\" (string)")

    fromString bool "hello: 42"
    --> Err (Decoding "Expected bool, got: { hello: 42 (int) } (map)")

-}
bool : Decoder Bool
bool =
    Decoder <|
        \v ->
            case v of
                Ast.Bool_ bool_ ->
                    Ok bool_

                _ ->
                    decodeError "bool" v


{-| Decode a YAML number into an Elm `Int`.

    fromString int "true"
    --> Err (Decoding "Expected int, got: True (bool)")

    fromString int "'true'"
    --> Err (Decoding "Expected int, got: \"true\" (string)")

    fromString int "42"        --> Ok 42

    fromString int "'42'"
    --> Err (Decoding "Expected int, got: \"42\" (string)")

    fromString int "3.14"
    --> Err (Decoding "Expected int, got: 3.14 (float)")

    fromString int "hello"
    --> Err (Decoding "Expected int, got: \"hello\" (string)")

    fromString int "hello: 42"
    --> Err (Decoding "Expected int, got: { hello: 42 (int) } (map)")

-}
int : Decoder Int
int =
    Decoder <|
        \v ->
            case v of
                Ast.Int_ int_ ->
                    Ok int_

                _ ->
                    decodeError "int" v


{-| Decode a YAML number into an Elm `Float`.

    fromString float "true"
    --> Err (Decoding "Expected float, got: True (bool)")

    fromString float "'true'"
    --> Err (Decoding "Expected float, got: \"true\" (string)")

    fromString float "42" --> Ok 42

    fromString float "'42'"
    --> Err (Decoding "Expected float, got: \"42\" (string)")

    fromString float "3.14" --> Ok 3.14

    fromString float "hello"
    --> Err (Decoding "Expected float, got: \"hello\" (string)")

    fromString float "hello: 42"
    --> Err (Decoding "Expected float, got: { hello: 42 (int) } (map)")

-}
float : Decoder Float
float =
    Decoder <|
        \v ->
            case v of
                Ast.Float_ float_ ->
                    Ok float_

                Ast.Int_ int_ ->
                    Ok (toFloat int_)

                _ ->
                    decodeError "float" v


{-| Decode a YAML null value into [Nothing](elm/core/latest/Maybe).

    fromString null "" --> Ok Nothing

    fromString null "null" --> Ok Nothing

    fromString null "true"
    --> Err (Decoding "Expected null, got: True (bool)")

    fromString null "42"
    --> Err (Decoding "Expected null, got: 42 (int)")

    fromString null "hello: 42"
    --> Err (Decoding "Expected null, got: { hello: 42 (int) } (map)")

-}
null : Decoder (Maybe a)
null =
    Decoder <|
        \v ->
            case v of
                Ast.Null_ ->
                    Ok Maybe.Nothing

                _ ->
                    decodeError "null" v


{-| Decode a nullable YAML value into an Elm value.

    fromString (nullable int) "42" --> Ok (Just 42)

    fromString (nullable int) "3.14"
    --> Err (Decoding "Expected int, got: 3.14 (float)")

    fromString (nullable int) "null" --> Ok Nothing

    fromString (nullable int) "true"
    --> Err (Decoding "Expected int, got: True (bool)")

-}
nullable : Decoder a -> Decoder (Maybe a)
nullable decoder =
    Decoder <|
        \v ->
            case v of
                Ast.Null_ ->
                    Ok Nothing

                other ->
                    Result.map Just (fromValue decoder other)


{-| Decode a YAML array into an Elm `List`.

    fromString (list int) "[1,2,3]" --> Ok [ 1, 2, 3 ]

    fromString (list bool) "[ true, false ]" --> Ok [ True, False ]

    fromString (list float) "true"
    --> Err (Decoding "Expected list, got: True (bool)")

-}
list : Decoder a -> Decoder (List a)
list decoder =
    Decoder <|
        \v ->
            case v of
                Ast.List_ list_ ->
                    singleResult (List.map (fromValue decoder) list_)

                Ast.Null_ ->
                    Ok []

                _ ->
                    decodeError "list" v


{-| Decode a YAML record into an Elm `Dict`.

    import Dict exposing (Dict)

    fromString (dict int) "{ alice: 42, bob: 99 }"
    --> Ok (Dict.fromList [ ( "alice", 42 ), ( "bob", 99 ) ])

    fromString (dict string) "42"
    --> Err (Decoding "Expected record, got: 42 (int)")

-}
dict : Decoder a -> Decoder (Dict.Dict String a)
dict decoder =
    Decoder <|
        \v ->
            case v of
                Ast.Record_ properties ->
                    properties
                        |> Dict.toList
                        |> List.map (\( key, val ) -> ( key, fromValue decoder val ))
                        |> List.filterMap
                            (\( key, val ) ->
                                case val of
                                    Ok val_ ->
                                        Just ( key, val_ )

                                    _ ->
                                        Nothing
                            )
                        |> Dict.fromList
                        |> Ok

                _ ->
                    decodeError "record" v



-- RECORD PRIMITIVES


{-| Decode a YAML record, requiring a particular field.

    fromString (field "x" int) "{ x: 3 }" --> Ok 3

    fromString (field "x" int) "{ x: 3, y: 4 }" --> Ok 3

    fromString (field "x" int) "{ x: true }" --> Err (Decoding "Expected int, got: True (bool)")

    fromString (field "x" int) "{ y: 4 }" --> Err (Decoding "Expected property: x")

    fromString (field "name" string) "{ name: Tom }" --> Ok "Tom"

The record _can_ have other fields. Lots of them! The only thing this decoder
cares about is if `x` is present and that the value there can be decoded.

Check out [`mapN`](#map2) and [`andMap`](#andMap) to see how to decode multiple fields!

-}
field : String -> Decoder a -> Decoder a
field name decoder =
    Decoder <|
        \v ->
            find [ name ] decoder v


{-| Decode a nested YAML record, requiring certain fields.

    yaml : String
    yaml = """{ person: { name: Tom, age: 42 } }"""

    fromString (at ["person", "name"] string) yaml --> Ok "Tom"

    fromString (at ["person", "age"] int) yaml     --> Ok 42

    fromString (at ["not", "here"] int) yaml --> Err (Decoding "Expected property: not")

This is really just shorthand for `field`. Equivalent to
saying things like:

    fromString (field "person" (field "name" string)) yaml
    --> fromString (at [ "person", "name" ] string) yaml

-}
at : List String -> Decoder a -> Decoder a
at names decoder =
    Decoder <|
        \v ->
            find names decoder v



-- FANCY DECODING


{-| Decode YAML with a recursive (nested) structure.

An example is nested comments:

    type alias Comment =
      { comment : String
      , responses : Responses
      }

    type Responses = Responses (List Comment)

    comment : Decoder Comment
    comment =
      map2 Comment
        (field "comment" string)
        (field "responses" (map Responses (list (lazy (\_ -> comment)))))

    yaml : String
    yaml = "{ comment: 'hello world', responses: [ {comment: 'hello', responses: [] } ] }"

    fromString comment yaml
    --> Ok { comment = "'hello world'", responses = Responses [{ comment = "'hello'", responses = Responses [] }] }

By using `lazy` you make sure that the decoder only expands
to be as deep as the YAML structure. You can read more about
recursive data structures
[here](https://github.com/elm/compiler/blob/master/hints/recursive-alias.md).

-}
lazy : (() -> Decoder a) -> Decoder a
lazy t =
    succeed () |> andThen t


{-| Do not do anything with a YAML value, just bring it into
Elm as a `Value`. This can be useful if you have particularly
complex data that you would like to deal with later. Or if you
are going to send it out of a port and do not care about its
structure.
-}
value : Decoder Value
value =
    Decoder <|
        \v ->
            Ok v


{-| Ignore the YAML and produce a given Elm value.

    fromString (succeed 42) "true" --> Ok 42

    fromString (succeed 42) "[]" --> Ok 42

    fromString (succeed 42) "{ " |> Result.toMaybe --> Nothing -- Long parsing error

-}
succeed : a -> Decoder a
succeed v =
    Decoder <|
        \_ ->
            Ok v


{-| Ignore the YAML and make the decoder fail. This is handy
when used with `oneOf` or `andThen` where you want to give a
custom error message in some case.

See the [andThen](#andThen) docs for an example.

-}
fail : String -> Decoder a
fail error =
    Decoder <|
        \_ ->
            Err (Decoding error)


{-| Create decoders that depend on previous results.

For example, if you decoding depends on a `version`
field:

    type alias Info =
        { data: Int }

    info : Decoder Info
    info =
        field "version" int
            |> andThen infoHelp

    -- infoHelp takes the "version" integer as its argument
    infoHelp : Int -> Decoder Info
    infoHelp version =
        case version of
            4 ->
                infoDecoder4
            3 ->
                infoDecoder3
            _ ->
                fail ("Version "
                        ++ String.fromInt version
                        ++ " is not supported.")

    infoDecoder4 : Decoder Info
    infoDecoder4 =
        map Info (field "v4data" int)

    infoDecoder3 : Decoder Info
    infoDecoder3 =
        map (Info << String.length) (field "v3data" string)

    fromString info "{ version: 3, v3data: test }"
    --> Ok (Info 4)

    fromString info "{ version: 4, v4data: 5 }"
    --> Ok (Info 5)

    fromString info "{ version: 1 }"
    --> Err (Decoding "Version 1 is not supported.")

-}
andThen : (a -> Decoder b) -> Decoder a -> Decoder b
andThen next decoder =
    Decoder <|
        \v0 ->
            case fromValue decoder v0 of
                Ok a ->
                    fromValue (next a) v0

                Err err ->
                    Err err



-- INCONSISTENT STRUCTURE


{-| Makes its argument optional.
A decoder which returns `Nothing` when it fails.

Helpful when dealing with optional fields: you probably want to
use `maybe` outside `field` or `at`. Here are a few examples:

    yaml : String
    yaml = "{ name: Stacy, age: 27, temperature: 37.6 }"

    fromString (maybe (field "age" int)) yaml      --> Ok (Just 27)

    fromString (maybe (field "height" float)) yaml --> Ok Nothing

These two examples decode to `Nothing` if a field does not exist.
They say there _may_ be an `age` field, if it exists it _must_
be an integer. And there _may_ be a `height` field, if it exists
it _must_ be a `Float`.

You can also decode to `Nothing` if a field is a different type:

    fromString (field "temperature" (maybe string)) yaml --> Ok Nothing

    fromString (field "age" (maybe int)) yaml --> Ok (Just 27)

These two examples say you _must_ have `temperature` and
`age` fields and the content _may_ be integers.

-}
maybe : Decoder a -> Decoder (Maybe a)
maybe decoder =
    Decoder <|
        \v ->
            case fromValue decoder v of
                Ok a ->
                    Ok (Just a)

                Err _ ->
                    Ok Nothing


{-| Try a list of different decoders. Pick the first working one.
This can be useful if the YAML comes in different formats. For
example, if you want to read an array of numbers but some of them
are `null`.

    fromString (oneOf [ field "a" int, field "b" int ]) "{a: 42}" --> Ok 42

    fromString (oneOf [ field "a" int, field "b" int ]) "{b: 3}" --> Ok 3

    fromString (oneOf [ field "a" int, field "b" int ]) "true" --> Err (Decoding "Empty")

-}
oneOf : List (Decoder a) -> Decoder a
oneOf ds =
    List.foldr or (fail "Empty") ds


{-| Choose between (try out) two decoders.
-}
or : Decoder a -> Decoder a -> Decoder a
or lp rp =
    Decoder <|
        \v ->
            case fromValue lp v of
                Ok a ->
                    Ok a

                Err _ ->
                    fromValue rp v



-- MAPS


{-| Transform the result of a decoder. For example,
get the length of a string:

    stringLength : Decoder Int
    stringLength =
      map String.length string

    fromString stringLength "hello" --> Ok 5

`map` runs the decoder (`string` in the example above) and
gives the result to the function (`String.length` in the
example above).

-}
map : (a -> b) -> Decoder a -> Decoder b
map func (Decoder a) =
    Decoder <|
        \v0 ->
            case a v0 of
                Err err ->
                    Err err

                Ok av ->
                    Ok (func av)


{-| Try two decoders and then combine the result. You can use this to
decode records with 2 fields:

    type alias Point = { x : Float, y : Float }

    point : Decoder Point
    point =
      map2 Point
         (field "x" float)
         (field "y" float)

    fromString point "{x: 1.2, y: 2.5}" --> Ok { x = 1.2, y = 2.5 }

`map2` runs each decoder in order and privides the results to the
function (taking 2 arguments; the `Point` constructor in the example
above).

-}
map2 : (a -> b -> c) -> Decoder a -> Decoder b -> Decoder c
map2 func (Decoder a) (Decoder b) =
    Decoder <|
        \v0 ->
            case a v0 of
                Err err1 ->
                    Err err1

                Ok av ->
                    case b v0 of
                        Err err2 ->
                            Err err2

                        Ok bv ->
                            Ok (func av bv)


{-| Try three decoders and then combine the result.
-}
map3 : (a -> b -> c -> d) -> Decoder a -> Decoder b -> Decoder c -> Decoder d
map3 func (Decoder a) (Decoder b) (Decoder c) =
    Decoder <|
        \v0 ->
            case a v0 of
                Err err1 ->
                    Err err1

                Ok av ->
                    case b v0 of
                        Err err2 ->
                            Err err2

                        Ok bv ->
                            case c v0 of
                                Err err3 ->
                                    Err err3

                                Ok cv ->
                                    Ok (func av bv cv)


{-| Try four decoders and then combine the result.
-}
map4 : (a -> b -> c -> d -> e) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e
map4 func (Decoder a) (Decoder b) (Decoder c) (Decoder d) =
    Decoder <|
        \v0 ->
            case a v0 of
                Err err1 ->
                    Err err1

                Ok av ->
                    case b v0 of
                        Err err2 ->
                            Err err2

                        Ok bv ->
                            case c v0 of
                                Err err3 ->
                                    Err err3

                                Ok cv ->
                                    case d v0 of
                                        Err err4 ->
                                            Err err4

                                        Ok dv ->
                                            Ok (func av bv cv dv)


{-| Try five decoders and then combine the result.
-}
map5 : (a -> b -> c -> d -> e -> f) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f
map5 func (Decoder a) (Decoder b) (Decoder c) (Decoder d) (Decoder e) =
    Decoder <|
        \v0 ->
            case a v0 of
                Err err1 ->
                    Err err1

                Ok av ->
                    case b v0 of
                        Err err2 ->
                            Err err2

                        Ok bv ->
                            case c v0 of
                                Err err3 ->
                                    Err err3

                                Ok cv ->
                                    case d v0 of
                                        Err err4 ->
                                            Err err4

                                        Ok dv ->
                                            case e v0 of
                                                Err err5 ->
                                                    Err err5

                                                Ok ev ->
                                                    Ok (func av bv cv dv ev)


{-| Try six decoders and then combine the result.
-}
map6 : (a -> b -> c -> d -> e -> f -> g) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g
map6 func (Decoder a) (Decoder b) (Decoder c) (Decoder d) (Decoder e) (Decoder f) =
    Decoder <|
        \v0 ->
            case a v0 of
                Err err1 ->
                    Err err1

                Ok av ->
                    case b v0 of
                        Err err2 ->
                            Err err2

                        Ok bv ->
                            case c v0 of
                                Err err3 ->
                                    Err err3

                                Ok cv ->
                                    case d v0 of
                                        Err err4 ->
                                            Err err4

                                        Ok dv ->
                                            case e v0 of
                                                Err err5 ->
                                                    Err err5

                                                Ok ev ->
                                                    case f v0 of
                                                        Err err6 ->
                                                            Err err6

                                                        Ok fv ->
                                                            Ok (func av bv cv dv ev fv)


{-| Try seven decoders and then combine the result.
-}
map7 : (a -> b -> c -> d -> e -> f -> g -> h) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h
map7 func (Decoder a) (Decoder b) (Decoder c) (Decoder d) (Decoder e) (Decoder f) (Decoder g) =
    Decoder <|
        \v0 ->
            case a v0 of
                Err err1 ->
                    Err err1

                Ok av ->
                    case b v0 of
                        Err err2 ->
                            Err err2

                        Ok bv ->
                            case c v0 of
                                Err err3 ->
                                    Err err3

                                Ok cv ->
                                    case d v0 of
                                        Err err4 ->
                                            Err err4

                                        Ok dv ->
                                            case e v0 of
                                                Err err5 ->
                                                    Err err5

                                                Ok ev ->
                                                    case f v0 of
                                                        Err err6 ->
                                                            Err err6

                                                        Ok fv ->
                                                            case g v0 of
                                                                Err err7 ->
                                                                    Err err7

                                                                Ok gv ->
                                                                    Ok (func av bv cv dv ev fv gv)


{-| Try eight decoders and then combine the result.
-}
map8 : (a -> b -> c -> d -> e -> f -> g -> h -> i) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder i
map8 func (Decoder a) (Decoder b) (Decoder c) (Decoder d) (Decoder e) (Decoder f) (Decoder g) (Decoder h) =
    Decoder <|
        \v0 ->
            case a v0 of
                Err err1 ->
                    Err err1

                Ok av ->
                    case b v0 of
                        Err err2 ->
                            Err err2

                        Ok bv ->
                            case c v0 of
                                Err err3 ->
                                    Err err3

                                Ok cv ->
                                    case d v0 of
                                        Err err4 ->
                                            Err err4

                                        Ok dv ->
                                            case e v0 of
                                                Err err5 ->
                                                    Err err5

                                                Ok ev ->
                                                    case f v0 of
                                                        Err err6 ->
                                                            Err err6

                                                        Ok fv ->
                                                            case g v0 of
                                                                Err err7 ->
                                                                    Err err7

                                                                Ok gv ->
                                                                    case h v0 of
                                                                        Err err8 ->
                                                                            Err err8

                                                                        Ok hv ->
                                                                            Ok (func av bv cv dv ev fv gv hv)


{-| Can be useful when decoding large objects incrementally.

For example, this can be used to to [`mapN`](#map2) for any number of arguments. See the
[documentation for `Json.Decode.Extra.andMap`](https://github.com/elm-community/json-extra/blob/master/docs/andMap.md) for a
thorough explanation of how to use `andMap`.

    -- map4
    sumFields : Decoder Int
    sumFields =
      succeed (\a b c d -> a + b + c + d)
        |> andMap (field "a" int)
        |> andMap (field "b" int)
        |> andMap (field "c" int)
        |> andMap (field "d" int)

    fromString sumFields "{a: 2, b: 5, c: -3, d: 9}" --> Ok 13

-}
andMap : Decoder a -> Decoder (a -> b) -> Decoder b
andMap =
    map2 (|>)



-- CONVERSIONS


{-| Convert a Result into a decoder.

This can be useful when you want to use functions that operate on `Result` in decoders,
in combination with [`andThen`](#andThen).

    validate : String -> Result String String
    validate s =
        case s of
            "" -> Err "is empty"
            _ -> Ok s

    fromString (string |> andThen (validate >> fromResult)) "\"not empty\"" --> Ok "not empty"

    fromString (string |> andThen (validate >> fromResult)) "" --> Err (Decoding "is empty")

-}
fromResult : Result String a -> Decoder a
fromResult result =
    case result of
        Ok val ->
            succeed val

        Err err ->
            fail err


{-| Convert a Maybe into a decoder.

This can be useful when you want to use functions that operate on `Maybe` in decoders,
in combination with [`andThen`](#andThen).

    fromString (string |> andThen (String.toInt >> fromMaybe "Not an int")) "\"42\"" --> Ok 42

    fromString (string |> andThen (String.toInt >> fromMaybe "Not an int")) "" --> Err (Decoding "Not an int")

-}
fromMaybe : String -> Maybe a -> Decoder a
fromMaybe err mby =
    case mby of
        Just v ->
            succeed v

        _ ->
            fail err



-- INTERNAL


singleResult : List (Result Error a) -> Result Error (List a)
singleResult =
    let
        each v r =
            case r of
                Err _ ->
                    r

                Ok vs ->
                    case v of
                        Ok vok ->
                            Ok (vok :: vs)

                        Err err ->
                            Err err
    in
    List.foldl each (Ok []) >> Result.map List.reverse


find : List String -> Decoder a -> Ast.Value -> Result Error a
find names decoder v0 =
    case names of
        name :: rest ->
            case v0 of
                Ast.Record_ properties ->
                    case Dict.get name properties of
                        Just v1 ->
                            find rest decoder v1

                        Nothing ->
                            Err (Decoding <| "Expected property: " ++ name)

                _ ->
                    Err (Decoding "Expected record")

        [] ->
            fromValue decoder v0


decodeError : String -> Ast.Value -> Result Error a
decodeError expected got =
    Err
        (Decoding
            ("Expected "
                ++ expected
                ++ ", got: "
                ++ Ast.toString got
            )
        )
