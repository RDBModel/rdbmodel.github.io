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
