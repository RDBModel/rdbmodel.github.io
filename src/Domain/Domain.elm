module Domain.Domain exposing (..)

import Dict exposing (Dict)
import Scale exposing (domain)
import Array exposing (Array)


type alias Domain =
    { name : String
    , description : Maybe String
    , actors : Dict String Data
    , elements : Dict String Node
    }


type Node
    = Parent Data (Dict String Node)
    | Leaf Data


type alias Data =
    { name : String
    , description : Maybe String
    , relations : Maybe (List Relation)
    }


type alias Relation =
    ( String, String )


type alias View =
    { elements : Dict ViewElementKey ViewElement
    }


type alias ViewElementKey =
    String


type alias ViewElement =
    { x : Float
    , y : Float
    , relations : Dict Relation (List ViewRelationPoint)
    }


type alias ViewRelationPoint =
    { x : Float
    , y : Float
    }


type alias Vertex =
    { name : String
    , key : String
    , description : Maybe String
    , xy : ( Float, Float )
    }


type alias Edge =
    { source : Vertex
    , target : Vertex
    , points : List ( Float, Float )
    , description : String
    }


type alias ViewRelationPointKey =
    ( ViewElementKey, Relation, ViewRelationPointIndex )


type alias ViewRelationPointIndex =
    Int


type alias ViewRelationKey =
    ( ViewElementKey, Relation )


type ViewItemKey
    = ElementKey ViewElementKey
    | PointKey ViewRelationPointKey


getSourceAndTargetElements : ViewRelationKey -> View -> ( Maybe ViewElement, Maybe ViewElement )
getSourceAndTargetElements ( viewElementKey, relation ) view =
    let
        source =
            Dict.get viewElementKey view.elements

        target =
            Dict.get (Tuple.first relation) view.elements
    in
    Tuple.pair source target


getViewRelationPoints : ViewRelationKey -> View -> List ( Float, Float )
getViewRelationPoints ( viewElementKey, relation ) view =
    Dict.get viewElementKey view.elements
        |> Maybe.map .relations
        |> Maybe.andThen (Dict.get relation)
        |> Maybe.map (List.map (\p -> Tuple.pair p.x p.y))
        |> Maybe.withDefault []


getEdges : ( Domain, View ) -> List Edge
getEdges ( domain, currentView ) =
    let
        getTargetElement key =
            Dict.get key currentView.elements

        getTargetAndPoints : ( ViewElementKey, ViewElement ) -> List Edge
        getTargetAndPoints ( viewElementKey, viewElement ) =
            let
                source =
                    Tuple.pair viewElement.x viewElement.y

                elementsNamesAndDescriptions =
                    getElementsNamesAndDescriptions domain

                sourceNameAndDescription =
                    getNameAndDescriptionByKey viewElementKey elementsNamesAndDescriptions
            in
            case sourceNameAndDescription of
                Just ( sourceName, sourceDescription ) ->
                    let
                        sourceContainer =
                            Vertex sourceName viewElementKey sourceDescription source
                    in
                    Dict.toList viewElement.relations
                        |> List.filterMap
                            (\( relation, points ) ->
                                Tuple.first relation |> getTargetElement |> Maybe.map (\te -> ( relation, te, points ))
                            )
                        |> List.filterMap
                            (\( relation, targetElement, points ) ->
                                let
                                    convertedViewRelationPoints =
                                        points |> List.map (\vrp -> Tuple.pair vrp.x vrp.y)

                                    target =
                                        Tuple.pair targetElement.x targetElement.y

                                    targetElementKey =
                                        Tuple.first relation

                                    description =
                                        Tuple.second relation
                                in
                                elementsNamesAndDescriptions
                                    |> getNameAndDescriptionByKey targetElementKey
                                    |> Maybe.map
                                        (\( targetName, targetDescription ) ->
                                            let
                                                targetContainer =
                                                    Vertex targetName targetElementKey targetDescription target
                                            in
                                            Edge sourceContainer targetContainer convertedViewRelationPoints description
                                        )
                            )

                Nothing ->
                    []
    in
    Dict.toList currentView.elements
        |> List.concatMap getTargetAndPoints


getContainers : ( Domain, View ) -> List Vertex
getContainers ( domain, currentView ) =
    let
        elementsNamesAndDescriptions =
            getElementsNamesAndDescriptions domain
    in
    Dict.toList currentView.elements
        |> List.filterMap
            (\( viewElementKey, viewElement ) ->
                elementsNamesAndDescriptions
                    |> getNameAndDescriptionByKey viewElementKey
                    |> Maybe.map (\( name, description ) -> Vertex name viewElementKey description (Tuple.pair viewElement.x viewElement.y))
            )


updateElementsInViews : Maybe String -> Dict String View -> (Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement) -> Dict String View
updateElementsInViews selectedView views updateElements =
    selectedView
        |> Maybe.map (\view -> Dict.update view (Maybe.map (\v -> { v | elements = updateElements v.elements })) views)
        |> Maybe.withDefault views


updateRelationsInElements : ViewElementKey -> (Dict Relation (List ViewRelationPoint) -> Dict Relation (List ViewRelationPoint)) -> Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement
updateRelationsInElements viewElementKey updatedRelationsFunc =
    Dict.update viewElementKey <| Maybe.map (\ve -> { ve | relations = updatedRelationsFunc ve.relations })


updatePointsInRelations : Relation -> (List ViewRelationPoint -> List ViewRelationPoint) -> Dict Relation (List ViewRelationPoint) -> Dict Relation (List ViewRelationPoint)
updatePointsInRelations relation updatedPoints =
    Dict.update relation <| Maybe.map updatedPoints


getViewElementsOfCurrentView : Maybe View -> Maybe (Dict ViewElementKey ViewElement)
getViewElementsOfCurrentView =
    Maybe.map .elements


getViewElementKeysByCondition : (ViewElementKey -> ViewElement -> Bool) -> Maybe (Dict ViewElementKey ViewElement) -> List ViewElementKey
getViewElementKeysByCondition condition =
    Maybe.map (Dict.filter condition >> Dict.keys) >> Maybe.withDefault []


getElementAndItsKeys : Maybe (Dict ViewElementKey ViewElement) -> List ( ViewElementKey, ViewElement )
getElementAndItsKeys =
    Maybe.map Dict.toList >> Maybe.withDefault []


getCurrentView : Maybe String -> Dict String View -> Maybe View
getCurrentView selectedView views =
    selectedView |> Maybe.andThen (\v -> Dict.get v views)


getElement : ViewElementKey -> Maybe (Dict ViewElementKey ViewElement) -> Maybe ViewElement
getElement viewElementKey =
    Maybe.andThen (Dict.get viewElementKey)


getElements : List ViewElementKey -> Maybe (Dict ViewElementKey ViewElement) -> List ( ViewElementKey, ViewElement )
getElements viewElementKeys maybeDict =
    case maybeDict of
        Just dict ->
            viewElementKeys |> List.filterMap (\vek -> Dict.get vek dict |> Maybe.map (\el -> ( vek, el )))

        Nothing ->
            []


getRelationPoints : Relation -> Maybe ViewElement -> Maybe (List ViewRelationPoint)
getRelationPoints relation =
    Maybe.map .relations >> Maybe.andThen (Dict.get relation)


getViewPointKeysByCondition : (ViewRelationPoint -> Bool) -> List ViewRelationPoint -> List ViewRelationPointIndex
getViewPointKeysByCondition condition =
    List.indexedMap (\i point -> ( i, point ))
        >> List.filterMap
            (\( i, point ) ->
                if condition point then
                    Just i

                else
                    Nothing
            )


getPoints : List ViewRelationPointKey -> Maybe (Dict ViewElementKey ViewElement) -> List ( ViewRelationPointKey, ViewRelationPoint )
getPoints relationPointKeys maybeDict =
    case maybeDict of
        Just dict ->
            relationPointKeys
                |> List.filterMap
                    (\( vek, relation, index ) ->
                        Dict.get vek dict
                            |> Maybe.andThen (\el -> el.relations |> Dict.get relation)
                            |> Maybe.map (List.drop index)
                            |> Maybe.andThen List.head
                            |> Maybe.map (\p -> ( ( vek, relation, index ), p ))
                    )

        Nothing ->
            []


getPoint : Int -> Maybe (List ViewRelationPoint) -> Maybe ViewRelationPoint
getPoint index =
    Maybe.map (List.drop index) >> Maybe.andThen List.head


relationSplitter : String
relationSplitter =
    " - "


getStringFromRelation : Relation -> String
getStringFromRelation relation =
    Tuple.second relation ++ relationSplitter ++ Tuple.first relation


getViewRelationKeyFromEdge : Edge -> ViewRelationKey
getViewRelationKeyFromEdge edge =
    ( edge.source.key, ( edge.target.key, edge.description ) )


getViewRelationKeyFromViewRelationPointKey : ViewRelationPointKey -> ViewRelationKey
getViewRelationKeyFromViewRelationPointKey ( viewElementKey, relation, viewRelationPointIndex ) =
    ( viewElementKey, relation )


getNameAndDescriptionByKey : ViewElementKey -> List ( String, String, Maybe String ) -> Maybe ( String, Maybe String )
getNameAndDescriptionByKey viewElementKey =
    List.filterMap
        (\( k, name, description ) ->
            if k == viewElementKey then
                Just ( name, description )

            else
                Nothing
        )
        >> List.head


getElementsKeysAndNames : Domain -> List ( String, String )
getElementsKeysAndNames domain =
    let
        extractFromNode key data =
            ( key, data.name )
    in
    extractKeyAndNameFromData domain.actors
        ++ extractDataFromAllNodes domain.elements extractFromNode


getElementsNamesAndDescriptions : Domain -> List ( String, String, Maybe String )
getElementsNamesAndDescriptions domain =
    let
        extractFromNode key data =
            ( key, data.name, data.description )
    in
    extractKeyAndNameAndDescription domain.actors
        ++ extractDataFromAllNodes domain.elements extractFromNode


extractKeyAndNameFromData : Dict String Data -> List ( String, String )
extractKeyAndNameFromData =
    Dict.map (\k v -> ( k, v.name )) >> Dict.values


extractKeyAndName : Dict String Node -> List ( String, String )
extractKeyAndName =
    Dict.map (\k v -> ( k, extractName v )) >> Dict.values


extractName : Node -> String
extractName node =
    case node of
        Parent d _ ->
            d.name

        Leaf l ->
            l.name


extractKeyAndNameAndDescription : Dict String { a | name : String, description : Maybe String } -> List ( String, String, Maybe String )
extractKeyAndNameAndDescription =
    Dict.map (\k v -> ( k, v.name, v.description )) >> Dict.values


getViewElements : Maybe View -> List String
getViewElements view =
    Maybe.map .elements view
        |> Maybe.withDefault Dict.empty
        |> Dict.keys


addElementToView : String -> ( Float, Float ) -> View -> View
addElementToView key ( x, y ) v =
    { v | elements = Dict.insert key (ViewElement x y Dict.empty) v.elements }


addRelationToView : String -> Relation -> Maybe View -> Maybe View
addRelationToView containerId relation =
    let
        newElements : View -> Dict ViewElementKey ViewElement
        newElements v =
            Dict.update containerId
                (Maybe.map (\el -> { el | relations = Dict.insert relation [] el.relations }))
                v.elements
    in
    Maybe.map (\v -> { v | elements = newElements v })


deleteContainer : String -> Maybe View -> Maybe View
deleteContainer containerId =
    let
        withoutContainer : View -> Dict ViewElementKey ViewElement
        withoutContainer v =
            Dict.remove containerId v.elements

        cleanUpRelations =
            Dict.map (\_ el -> { el | relations = Dict.filter (\r _ -> Tuple.first r /= containerId) el.relations })
    in
    Maybe.map (\v -> { v | elements = v |> withoutContainer |> cleanUpRelations })


updateViewByKey : Maybe String -> Dict String View -> Maybe View -> Dict String View
updateViewByKey key views maybeView =
    case key of
        Just v ->
            Dict.update v (\_ -> maybeView) views

        Nothing ->
            views


possibleRelationsToAdd : ( Domain, View ) -> Dict String (List Relation)
possibleRelationsToAdd ( domain, view ) =
    let
        existingElementsInView =
            view.elements |> Dict.keys

        existingRelationsInView =
            view.elements
                |> Dict.map (\_ v -> v.relations |> Dict.keys)

        allPossibleRelationsForActors =
            domain.actors |> Dict.map (\_ v -> v.relations |> Maybe.withDefault [])

        extractData key data =
            ( key, data.relations |> Maybe.withDefault [] )

        allPossibleRelations =
            allPossibleRelationsForActors
                |> Dict.union (extractDataFromAllNodes domain.elements extractData |> Dict.fromList)

        onlyNonExistingRelation key candidate =
            Dict.get key existingRelationsInView
                |> Maybe.withDefault []
                |> List.member candidate
                |> not

        onlyRelationWithExistingTarget _ candidate =
            existingElementsInView |> List.member (candidate |> Tuple.first)
    in
    existingRelationsInView
        |> Dict.intersect allPossibleRelations
        |> Dict.map (onlyRelationWithExistingTarget >> List.filter)
        |> Dict.map (onlyNonExistingRelation >> List.filter)
        |> Dict.filter (\_ v -> List.isEmpty v |> not)


removedEdge : ViewRelationKey -> View -> View
removedEdge ( viewElementKey, relation ) view =
    let
        updatedElements =
            view.elements
                |> Dict.update viewElementKey
                    (Maybe.map (\el -> { el | relations = Dict.remove relation el.relations }))
    in
    { view | elements = updatedElements }


extractDataFromAllNodes : Dict String Node -> (String -> Data -> a) -> List a
extractDataFromAllNodes nodes extractFunc =
    let
        goDeep key node =
            case node of
                Parent data children ->
                    extractFunc key data :: extractDataFromAllNodes children extractFunc

                Leaf data ->
                    extractFunc key data |> List.singleton
    in
    Dict.foldl (\k n result -> goDeep k n |> List.append result) [] nodes

levelChildrenNames : Array String
levelChildrenNames =
    [ "containers", "components" ] |> Array.fromList

getName level =
    Array.get level levelChildrenNames |> Maybe.withDefault ("elements" ++ String.fromInt level)
