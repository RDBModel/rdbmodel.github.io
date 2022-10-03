module Validation exposing (validateDomain, validateViews)

import Domain exposing (..)
import Dict exposing (Dict)
import Set exposing (..)
import Json.Encode exposing (dict, string, list, encode)

validateDomain : Domain -> Result String Domain
validateDomain domain =
  let
    elementKeysAndNames = domain |> getElementsKeysAndNames

    elementKeys = elementKeysAndNames |> List.map Tuple.first

    relations = getRelations domain |> List.map Tuple.second

    nonExistingTarget =
      let
        nonExistingTargetInRelation currentRelation result =
          if List.member (Tuple.first currentRelation) elementKeys then
            result
          else
            (getStringFromRelation currentRelation) :: result
      in
      List.foldl nonExistingTargetInRelation [] relations

    emptyNames = elementKeysAndNames
      |> List.filterMap (\(k, name) -> if String.isEmpty name then Just k else Nothing)

    duplicatedElements = elementKeys
      |> duplicates

    finalResult =
      [ ( "Elements with empty names", emptyNames ),
        ( "Not existing targets", nonExistingTarget ),
        ( "Duplicated element keys", duplicatedElements )
      ]
        |> List.filter (\(_, v) -> List.isEmpty v |> not)
        |> Dict.fromList
        |> dict identity (list string)
        |> encode 0
  in
  -- unique keys at the same level and root element are ignored by decoder -- TODO
  -- non-empty names
  -- relation targets are existing elements
  if finalResult == "{}" then
    Ok domain
  else
    Err finalResult

duplicates : List comparable -> List comparable
duplicates list =
  let
    internalDuplicates elem (unique, dup) =
      if List.member elem unique then
        (unique, elem :: dup)
      else
        (elem :: unique, dup)
  in
  List.foldr internalDuplicates ([], []) list |> Tuple.second


validateViews: (Domain, Dict String View) -> Result String (Domain, Dict String View)
validateViews (domain, views) =
  let
    domainElementNames = getUniqueElementsKeys domain
    domainRelations = getUniqueRelations domain
    validateResult = Dict.map
      (\_ v ->
        let
          viewElementNames = getViewElementKeys v
          viewRelations = getViewRelations v

          elementsErrors = Set.diff viewElementNames domainElementNames
            |> Set.toList

          relationErrors: Dict String String
          relationErrors = Set.diff viewRelations domainRelations
            |> Set.toList
            |> Dict.fromList
            |> Dict.map (\_ relation -> getStringFromRelation relation)

        in
          -- TODO do not return empty values
          if (elementsErrors |> List.isEmpty |> not) && (relationErrors |> Dict.isEmpty |> not) then
            [
              Dict.singleton "Not existing element in domain" (elementsErrors |> list string),
              Dict.singleton "Not existing relation in domain" (relationErrors |> dict identity string )
            ]
          else if elementsErrors |> List.isEmpty |> not then
            [
              Dict.singleton "Not existing element in domain" (elementsErrors |> list string)
            ]
          else if relationErrors |> Dict.isEmpty |> not then
            [
              Dict.singleton "Not existing relation in domain" (relationErrors |> dict identity string )
            ]
          else
            []
      ) views
      |> Dict.filter (\k v -> List.isEmpty v |> not)
      |> dict identity (list (dict identity identity) )
      |> encode 0
  in
  if validateResult == "{}" then
    Ok (domain, views)
  else
    Err validateResult

getViewElementKeys : View -> Set String
getViewElementKeys view =
  Dict.keys view.elements |> Set.fromList

getViewRelations : View -> Set (String, Relation)
getViewRelations view =
  Dict.toList view.elements |> List.map (\(k, element) -> element.relations |> Dict.keys |> List.map (\x -> (k, x))) |> List.concat |> Set.fromList

getUniqueElementsKeys : Domain -> Set String
getUniqueElementsKeys =
  getElementsKeysAndNames >> List.map Tuple.first >> Set.fromList

-- TODO relation is not enough, it should include source also as there are possible duplications
getRelations : Domain -> List (String, Relation)
getRelations domain =
  (Dict.toList domain.actors |> List.map (\(k, actor) -> actor.relations |> List.map (\x -> (k, x))) |> List.concat)
    ++ (Dict.toList domain.rings |> List.map (\(k, ring) -> ring.relations |> List.map (\x -> (k, x))) |> List.concat)
    ++ (Dict.values domain.rings |> List.map .delivery |> List.concatMap Dict.toList |> List.map (\(k, delivery) -> delivery.relations |> List.map (\x -> (k, x))) |> List.concat)
    ++ (Dict.values domain.rings |> List.map .delivery |> List.concatMap Dict.values |> List.map .blocks |> List.concatMap Dict.toList |> List.map (\(k, block) -> block.relations |> List.map (\x -> (k, x))) |> List.concat)

getUniqueRelations : Domain -> Set (String, Relation)
getUniqueRelations =
  getRelations >> Set.fromList
