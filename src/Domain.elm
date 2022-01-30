module Domain exposing (..)
import Dict exposing (Dict)

type alias Container =
  { name : String
  , xy : (Float, Float)
  }

type alias Edge = 
  { source : Container
  , target : Container
  , points : List (Float, Float)
  , description : String
  }

type alias ViewElementKey = String


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

type alias Relation = (String, String)

type alias View =
  { elements: Dict ViewElementKey ViewElement
  }

type alias ViewElement = 
  { x : Float
  , y : Float
  , relations : Dict Relation (List ViewRelationPoint)
  }

type alias ViewRelationPointIndex = Int

type alias ViewRelationPoint =
  { x : Float
  , y : Float
  }

type alias ViewRelationKey = (ViewElementKey, Relation)
type alias ViewRelationPointKey = (ViewElementKey, Relation, ViewRelationPointIndex)


getSourceAndTargetElements : ViewRelationKey -> View -> (Maybe ViewElement, Maybe ViewElement)
getSourceAndTargetElements (viewElementKey, relation) view =
    let
        source = Dict.get viewElementKey view.elements
        target = Dict.get (Tuple.first relation) view.elements
    in
    Tuple.pair source target

getViewRelationPoints : ViewRelationKey -> View -> List (Float, Float)
getViewRelationPoints (viewElementKey, relation) view =
    Dict.get viewElementKey view.elements
        |> Maybe.map .relations
        |> Maybe.andThen (Dict.get relation)
        |> Maybe.map (List.map (\p -> Tuple.pair p.x p.y))
        |> Maybe.withDefault []

getEdges : View -> List Edge
getEdges currentView =
    let
        getTargetElement key = Dict.get key currentView.elements

        getTargetAndPoints : (ViewElementKey, ViewElement) -> List Edge
        getTargetAndPoints (viewElementKey, viewElement) =
            let
                source = Tuple.pair viewElement.x viewElement.y
                sourceContainer = Container viewElementKey source
            in
            Dict.toList viewElement.relations
                |> List.filterMap (\(relation, points) ->
                    Tuple.first relation |> getTargetElement |> Maybe.map (\te -> (relation, te, points))
                )
                |> List.map (\(relation, targetElement, points) ->
                    let
                        convertedViewRelationPoints =
                            points |> List.map (\vrp -> Tuple.pair vrp.x vrp.y)
                        
                        target = Tuple.pair targetElement.x targetElement.y
                        targetElementKey = Tuple.first relation
                        description = Tuple.second relation
                        targetContainer =  Container targetElementKey target
                    in
                    Edge sourceContainer targetContainer convertedViewRelationPoints description
                )
    in
    Dict.toList currentView.elements
        |> List.concatMap getTargetAndPoints


getContainers : View -> List Container
getContainers currentView =
    Dict.toList currentView.elements
        |> List.map (\(viewElementKey, viewElement) -> Container viewElementKey (Tuple.pair viewElement.x viewElement.y))

updateElementsInViews : Maybe String -> Dict String View -> (Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement) -> Dict String View
updateElementsInViews selectedView views updateElements =
    case selectedView of
        Just sv ->
            Dict.update sv (Maybe.map (\v -> { v | elements = updateElements v.elements } )) views
        Nothing -> views

updateRelationsInElements : ViewElementKey ->  (Dict Relation (List ViewRelationPoint) -> Dict Relation (List ViewRelationPoint)) -> Dict ViewElementKey ViewElement -> Dict ViewElementKey ViewElement
updateRelationsInElements viewElementKey updatedRelationsFunc =
    Dict.update viewElementKey <| Maybe.map (\ve -> { ve | relations = updatedRelationsFunc ve.relations } )


updatePointsInRelations : Relation -> (List ViewRelationPoint -> List ViewRelationPoint) -> Dict Relation (List ViewRelationPoint) -> Dict Relation (List ViewRelationPoint)
updatePointsInRelations relation updatedPoints =
    Dict.update relation <| Maybe.map updatedPoints


getViewElementsOfCurrentView : Maybe View -> Maybe (Dict ViewElementKey ViewElement)
getViewElementsOfCurrentView =
    Maybe.map .elements


getCurrentView : Maybe String -> Dict String View -> Maybe View
getCurrentView selectedView views = selectedView |> Maybe.andThen (\sv -> Dict.get sv views)


getElement : ViewElementKey -> Maybe (Dict ViewElementKey ViewElement) -> Maybe ViewElement
getElement viewElementKey =
    Maybe.andThen (Dict.get viewElementKey)
