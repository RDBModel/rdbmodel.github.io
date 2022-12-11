module Domain.Domain exposing (..)

import Dict exposing (Dict)
import Scale exposing (domain)


type alias Domain =
    { name : String
    , description : String
    , actors : Dict String Actor
    , rings : Dict String Ring
    }


type alias Actor =
    { name : String
    , description : String
    , relations : List Relation
    }


type alias Ring =
    { name : String
    , description : String
    , relations : List Relation
    , delivery : Dict String Delivery
    }


type alias Delivery =
    { name : String
    , description : String
    , relations : List Relation
    , blocks : Dict String Block
    }


type alias Block =
    { name : String
    , description : String
    , relations : List Relation
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


type alias Container =
    { name : String
    , key : String
    , description : String
    , xy : ( Float, Float )
    }


type alias Edge =
    { source : Container
    , target : Container
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
                            Container sourceName viewElementKey sourceDescription source
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
                                                    Container targetName targetElementKey targetDescription target
                                            in
                                            Edge sourceContainer targetContainer convertedViewRelationPoints description
                                        )
                            )

                Nothing ->
                    []
    in
    Dict.toList currentView.elements
        |> List.concatMap getTargetAndPoints


getContainers : ( Domain, View ) -> List Container
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
                    |> Maybe.map (\( name, description ) -> Container name viewElementKey description (Tuple.pair viewElement.x viewElement.y))
            )


updateElementsInViews : String -> Dict String View -> (Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement) -> Dict String View
updateElementsInViews selectedView views updateElements =
    Dict.update selectedView (Maybe.map (\v -> { v | elements = updateElements v.elements })) views


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


getCurrentView : String -> Dict String View -> Maybe View
getCurrentView selectedView views =
    Dict.get selectedView views


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


getNameAndDescriptionByKey : ViewElementKey -> List ( String, String, String ) -> Maybe ( String, String )
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
    extractKeyAndName domain.actors
        ++ extractKeyAndName domain.rings
        ++ (Dict.values domain.rings |> List.map .delivery |> List.concatMap extractKeyAndName)
        ++ (Dict.values domain.rings |> List.map .delivery |> List.concatMap Dict.values |> List.map .blocks |> List.concatMap extractKeyAndName)


getElementsNamesAndDescriptions : Domain -> List ( String, String, String )
getElementsNamesAndDescriptions domain =
    extractKeyAndNameAndDescription domain.actors
        ++ extractKeyAndNameAndDescription domain.rings
        ++ (Dict.values domain.rings |> List.map .delivery |> List.concatMap extractKeyAndNameAndDescription)
        ++ (Dict.values domain.rings |> List.map .delivery |> List.concatMap Dict.values |> List.map .blocks |> List.concatMap extractKeyAndNameAndDescription)


extractKeyAndName : Dict String { a | name : String } -> List ( String, String )
extractKeyAndName =
    Dict.map (\k v -> ( k, v.name )) >> Dict.values


extractKeyAndNameAndDescription : Dict String { a | name : String, description : String } -> List ( String, String, String )
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


updateViewByKey : String -> Dict String View -> Maybe View -> Dict String View
updateViewByKey key views maybeView =
    Dict.update key (\_ -> maybeView) views


possibleRelationsToAdd : ( Domain, View ) -> Dict String (List Relation)
possibleRelationsToAdd ( domain, view ) =
    let
        existingElementsInView =
            view.elements |> Dict.keys

        existingRelationsInView =
            view.elements
                |> Dict.map (\_ v -> v.relations |> Dict.keys)

        allPossibleRelationsForActors =
            domain.actors |> Dict.map (\_ v -> v.relations)

        allPossibleRelationsForRings =
            domain.rings |> Dict.toList |> List.map (\( k, v ) -> ( k, v.relations )) |> Dict.fromList

        allPossibleRelationsForDeliveries =
            domain.rings
                |> Dict.values
                |> List.map .delivery
                |> List.concatMap Dict.toList
                |> List.map (\( k, v ) -> ( k, v.relations ))
                |> Dict.fromList

        allPossibleRelationsForBlocks =
            domain.rings
                |> Dict.values
                |> List.map .delivery
                |> List.concatMap Dict.values
                |> List.map .blocks
                |> List.concatMap Dict.toList
                |> List.map (\( k, v ) -> ( k, v.relations ))
                |> Dict.fromList

        allPossibleRelations =
            allPossibleRelationsForActors
                |> Dict.union allPossibleRelationsForRings
                |> Dict.union allPossibleRelationsForDeliveries
                |> Dict.union allPossibleRelationsForBlocks

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
