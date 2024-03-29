module Domain.Validation exposing (errorDomainDecoder, validateDomain, validateViews)

import Dict exposing (Dict)
import Domain.Domain exposing (..)
import Error.Error exposing (ErrorLocation(..), Source(..), ViewError(..))
import Json.Decode as Decode exposing (Decoder)
import Json.Encode exposing (dict, encode, list, string)
import Set exposing (..)


validateDomain : Domain -> Result String Domain
validateDomain domain =
    let
        elementKeysAndNames =
            domain |> getElementsKeysAndNames

        elementKeys =
            elementKeysAndNames |> List.map Tuple.first

        relations =
            getRelations domain |> List.map Tuple.second

        nonExistingTarget =
            let
                nonExistingTargetInRelation currentRelation result =
                    if List.member (Tuple.first currentRelation) elementKeys then
                        result

                    else
                        getStringFromRelation currentRelation :: result
            in
            List.foldl nonExistingTargetInRelation [] relations

        emptyNames =
            elementKeysAndNames
                |> List.filterMap
                    (\( k, name ) ->
                        if String.isEmpty name then
                            Just k

                        else
                            Nothing
                    )

        duplicatedElements =
            elementKeys
                |> duplicates

        finalResult =
            [ ( "Elements with empty name", emptyNames )
            , ( "Not existing target", nonExistingTarget )
            , ( "Duplicated element key", duplicatedElements )
            ]
                |> List.filter (\( _, v ) -> List.isEmpty v |> not)
                |> Dict.fromList
                |> dict identity (list string)
                |> encode 0
    in
    if finalResult == "{}" then
        Ok domain

    else
        Err finalResult


duplicates : List comparable -> List comparable
duplicates list =
    let
        internalDuplicates elem ( unique, dup ) =
            if List.member elem unique then
                ( unique, elem :: dup )

            else
                ( elem :: unique, dup )
    in
    List.foldr internalDuplicates ( [], [] ) list |> Tuple.second


validateViews : ( Domain, Dict String View ) -> Result String ( Domain, Dict String View )
validateViews ( domain, views ) =
    let
        domainElementNames =
            getUniqueElementsKeys domain

        domainRelations =
            getUniqueRelations domain

        validateResult =
            Dict.map
                (\_ v ->
                    let
                        viewElementNames =
                            getViewElementKeys v

                        viewRelations =
                            getViewRelations v

                        elementsErrors =
                            Set.diff viewElementNames domainElementNames
                                |> Set.toList

                        relationErrors : Dict String (List String)
                        relationErrors =
                            Set.diff viewRelations domainRelations
                                |> Set.toList
                                |> fromListToDictOfList
                                |> Dict.map (\_ relations -> List.map getStringFromRelation relations)
                    in
                    if (elementsErrors |> List.isEmpty |> not) && (relationErrors |> Dict.isEmpty |> not) then
                        [ Dict.singleton "Not existing element in domain" (elementsErrors |> list string)
                        , Dict.singleton "Not existing relation in domain" (relationErrors |> dict identity (list string))
                        ]

                    else if elementsErrors |> List.isEmpty |> not then
                        [ Dict.singleton "Not existing element in domain" (elementsErrors |> list string)
                        ]

                    else if relationErrors |> Dict.isEmpty |> not then
                        [ Dict.singleton "Not existing relation in domain" (relationErrors |> dict identity (list string))
                        ]

                    else
                        []
                )
                views
                |> Dict.filter (\_ v -> List.isEmpty v |> not)
                |> dict identity (list (dict identity identity))
                |> encode 0
    in
    if validateResult == "{}" then
        Ok ( domain, views )

    else
        Err validateResult


fromListToDictOfList : List ( comparable, a ) -> Dict comparable (List a)
fromListToDictOfList items =
    let
        addNewValueFunc newValue list =
            Maybe.map ((::) newValue) list

        reductFunc ( key, value ) dict =
            if Dict.member key dict then
                Dict.update key (addNewValueFunc value) dict

            else
                Dict.insert key [ value ] dict
    in
    List.foldl reductFunc Dict.empty items


getViewElementKeys : View -> Set String
getViewElementKeys view =
    Dict.keys view.elements |> Set.fromList


getViewRelations : View -> Set ( String, Relation )
getViewRelations view =
    Dict.toList view.elements |> List.map (\( k, element ) -> element.relations |> Dict.keys |> List.map (\x -> ( k, x ))) |> List.concat |> Set.fromList


getUniqueElementsKeys : Domain -> Set String
getUniqueElementsKeys =
    getElementsKeysAndNames >> List.map Tuple.first >> Set.fromList



-- TODO relation is not enough, it should include source also as there are possible duplications


getRelations : Domain -> List ( String, Relation )
getRelations domain =
    let
        extractFromNode _ key data =
            data.relations |> Maybe.withDefault [] |> List.map (\x -> ( key, x )) |> Just
    in
    extractRelations domain.actors
        ++ (extractDataFromAllNodes domain.elements extractFromNode |> List.concat)


extractRelations : Dict String Data -> List ( String, Relation )
extractRelations actors =
    Dict.toList actors |> List.map (\( k, actor ) -> actor.relations |> Maybe.withDefault [] |> List.map (\x -> ( k, x ))) |> List.concat


getUniqueRelations : Domain -> Set ( String, Relation )
getUniqueRelations =
    getRelations >> Set.fromList


errorDomainDecoder : Decoder Source
errorDomainDecoder =
    Decode.oneOf
        [ Decode.string |> Decode.list |> Decode.dict |> Decode.map DomainLocation
        , Decode.oneOf
            [ Decode.string |> Decode.list |> Decode.dict |> Decode.map SimpleViewError
            , Decode.string |> Decode.list |> Decode.dict |> Decode.dict |> Decode.map ComplexViewError
            ]
            |> Decode.list
            |> Decode.dict
            |> Decode.map ViewsLocation
        ]
        |> Decode.map DomainDecode
