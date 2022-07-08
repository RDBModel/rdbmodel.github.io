module YamlParser exposing (..)
import Parser as P exposing (Parser, chompUntil, succeed, symbol, getChompedString, loop
    , spaces, (|.), (|=), chompUntilEndOr, Step(..), oneOf, map, getIndent, keyword, end)
import Dict

type Value
  = String_ String
  | Float_ Float
  | Int_ Int
  | List_ (List Value)
  | Record_ (Dict.Dict String Value)
  | Bool_ Bool
  | Null_

type alias Property =
  ( String, Value )

type alias ModelRelation =
    { description : String
    , target : String
    }

relation : Parser ModelRelation
relation =
    succeed ModelRelation
        |. spaces
        |= getChompedString (chompUntil " - ")
        |. spaces
        |. symbol "-"
        |. spaces
        |= getChompedString (chompUntilEndOr "\n")

relations: Parser (List ModelRelation)
relations =
    succeed identity
        |. spaces
        |. keyword "relations"
        |. symbol ":"
        |= P.andThen list P.getCol
        
        --loop (0, []) (ifProgress relation)


type alias OffsetState =
    { indent : Int
    , value : ModelRelation
    }

ifProgress : Parser ModelRelation -> ( Int, (List ModelRelation) ) -> Parser (Step (Int, (List ModelRelation) ) (List ModelRelation))
ifProgress parser ( prevIndent, currentRelations) =
    succeed OffsetState
        |= getIndent
        |= oneOf
            [ parser
            , end
            ]
        |> map (\{ indent, value } ->
            let
                _ = Debug.log "indent" indent
                _ = Debug.log "value" value
            in
            if prevIndent <= indent then
                Loop ( indent, value :: currentRelations)
            else
                Done (List.reverse currentRelations)
            )


list : Int -> P.Parser Value
list indent =
  let
    confirmed value_ =
      P.succeed List_
        |= P.loop [ value_ ] (listStep indent)
  in
  listElement indent
    |> P.andThen confirmed


listElement : Int -> P.Parser Value
listElement indent =
  P.succeed identity 
    |. listElementBegin
    |= listElementValue indent

listElementBegin : P.Parser ()
listElementBegin = 
  P.oneOf 
    [ P.symbol "- "
    , P.symbol "-\n"
    ]


listElementValue : Int -> P.Parser Value
listElementValue indent =
  indented indent
    { smaller = 
        P.succeed Null_
    , exactly =
        P.succeed Null_
    , larger = \indent_ ->
        relation
    , ending = 
        P.succeed Null_
    }

listStep : Int -> List Value -> P.Parser (P.Step (List Value) (List Value))
listStep indent values =
  let finish = P.Done (List.reverse values)
      next value_ = P.Loop (value_ :: values)
  in
  indented indent
    { smaller = 
        P.succeed finish
    , exactly = 
        P.oneOf
          [ P.succeed next
              |= listElement indent
          , P.succeed finish -- for lists on the same indentation level as the parent record 
          ]
    , larger = \_ -> 
        P.problem "I was looking for the next element but didn't find one."
    , ending = 
        P.succeed finish
    }


indented : Int -> { smaller : P.Parser a, exactly : P.Parser a, larger : Int -> P.Parser a, ending : P.Parser a } -> P.Parser a
indented indent next =
  let check actual =
        P.oneOf
          [ P.andThen (\_ -> next.ending) P.end
          , P.andThen (\_ -> next.ending) (P.symbol "\n...\n")
          , if actual == indent then next.exactly
            else if actual > indent then next.larger actual
            else next.smaller
          ]
  in
  P.succeed identity
    |. whitespace
    |= P.getCol
    |> P.andThen check

whitespace : P.Parser ()
whitespace =
  let
    step _ =
      P.oneOf
        [ P.succeed (P.Loop ()) 
            |. comment
        , P.succeed (P.Loop ()) 
            |. P.chompIf isSpace
        , P.succeed (P.Loop ()) 
            |. P.chompIf isNewLine
        , P.succeed (P.Done ())
        ]
  in
  P.loop () step

comment : P.Parser ()
comment =
  P.succeed ()
    |. P.symbol " #"
    |. P.chompUntilEndOr "\n"

isSpace : Char -> Bool
isSpace =
  is ' '

isNewLine : Char -> Bool
isNewLine =
  is '\n'

is : Char -> Char -> Bool
is searched char =
  char == searched
