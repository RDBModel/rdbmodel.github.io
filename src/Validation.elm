module Validation exposing (validateDomain, validateViews)

import Domain exposing (..)
import Dict exposing (Dict)
import Set exposing (..)
import Yaml.Encode exposing (..)

validateDomain : Domain -> Result String Domain
validateDomain domain =
  let
    forbiddenCharsInKeys = [ " ", ",", ";" ]
    elementKeysAndNames = domain |> getElementsKeysAndNames

    elementKeys = elementKeysAndNames |> List.map Tuple.first

    elementKeyContainsForbiddenChar = elementKeys
      |> List.filter (\k -> forbiddenCharsInKeys |> List.any (\f -> String.contains f k))
      |> String.join ","
      |> addPrefixIfNotEmpty "Element key contains forbidden char:"

    relations = getRelations domain |> List.map Tuple.second

    nonExistingTarget =
      let
        nonExistingTargetInRelation currentRelation result =
          if List.member (Tuple.first currentRelation) elementKeys then
            result
          else
            addComma result ++ (getStringFromRelation currentRelation)
      in
      List.foldl nonExistingTargetInRelation "" relations
        |> addPrefixIfNotEmpty "Not existing targets:"

    emptyNames = elementKeysAndNames
      |> List.filterMap (\(k, name) -> if String.isEmpty name then Just k else Nothing)
      |> String.join ","
      |> addPrefixIfNotEmpty "Elements with empty names:"
    duplicatedElements = elementKeys
      |> duplicates 
      |> String.join ","
      |> addPrefixIfNotEmpty "Duplicated element keys:"

    finalResult =
      [elementKeyContainsForbiddenChar, emptyNames, nonExistingTarget, duplicatedElements]
        |> List.filter (String.isEmpty >> not) |> String.join ";"
  in
  -- unique keys at the same level and root element are ignored by decoder -- TODO
  -- non-empty names
  -- relation targets are existing elements
  if String.isEmpty finalResult then
    Ok domain
  else
    Err finalResult

addComma : String -> String
addComma = addDelimeterIfNonEmpty ","

addPrefixIfNotEmpty : String -> String -> String
addPrefixIfNotEmpty prefix current =
  if String.isEmpty current then
    current
  else
    prefix ++ current

addDelimeterIfNonEmpty : String -> String -> String
addDelimeterIfNonEmpty delimeter current =
  if String.isEmpty current then
    current
  else
    current ++ delimeter

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

    convertRelationsToString =
      Set.foldl
        (\(source, relation) z ->
          let
            relationString = getStringFromRelation relation
          in
          addDelimeterIfNonEmpty "," z ++ source ++ " - " ++ relationString) ""

    convertElementsToString =
      Set.foldl
        (\item z -> addComma z ++ item ) ""

    validateResult = Dict.foldl
      (\k v b ->
        let
          viewElementNames = getViewElementKeys v
          viewRelations = getViewRelations v

          elementsErrors = Set.diff viewElementNames domainElementNames
            |> convertElementsToString
            |> addPrefixIfNotEmpty "Not existing element in domain:"
          relationErrors = Set.diff viewRelations domainRelations
            |> convertRelationsToString
            |> addPrefixIfNotEmpty "Not existing relation in domain:"

          finalResult = [elementsErrors, relationErrors]
            |> List.filter (String.isEmpty >> not)
            |> String.join ";"
            |> addPrefixIfNotEmpty (k ++ ":")
        in
        b ++ finalResult
      ) "" views

  in
  if String.isEmpty validateResult then
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


