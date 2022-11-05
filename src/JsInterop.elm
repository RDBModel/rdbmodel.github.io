port module JsInterop exposing (monacoEditorInitialValue, initMonacoResponse, initMonacoRequest, RemovePointMessage
  , removePoint, encodeRemovePoint, PointMessage, encodePointMessage, addPoint, encodeUpdateElementPosition
  , UpdateElementPositionMessage, updateElementPosition, updatePointPosition, updateMonacoValue, monacoEditorSavedValue, validationErrors)
import Json.Encode as E
import Domain exposing (Relation)
import Domain exposing (getStringFromRelation)

port monacoEditorInitialValue : (String -> msg) -> Sub msg
port monacoEditorSavedValue : (String -> msg) -> Sub msg
port initMonacoRequest : (() -> msg) -> Sub msg

port updateElementPosition : E.Value -> Cmd msg
port updatePointPosition : E.Value -> Cmd msg
port initMonacoResponse : () -> Cmd msg
port removePoint : E.Value -> Cmd msg
port addPoint : E.Value -> Cmd msg
port updateMonacoValue : String -> Cmd msg
port validationErrors : String -> Cmd msg

type alias RemovePointMessage =
  { selectedView : String
  , viewElementKey : String
  , relation : Relation
  , pointIndex : Int
  }

type alias PointMessage =
  { selectedView : String
  , viewElementKey : String
  , relation : Relation
  , pointIndex : Int
  , coords : (Float, Float)
  }

type alias UpdateElementPositionMessage =
  { selectedView : String
  , viewElementKey : String
  , coords : (Float, Float)
  }

encodeRemovePoint : RemovePointMessage -> E.Value
encodeRemovePoint removePointValue =
  E.object
    [ ( "view", E.string removePointValue.selectedView)
    , ( "elementKey", E.string removePointValue.viewElementKey)
    , ( "relation", E.string (getStringFromRelation removePointValue.relation))
    , ( "pointIndex", E.int removePointValue.pointIndex)
    ]

encodePointMessage : PointMessage -> E.Value
encodePointMessage addPointValue =
  E.object
    [ ( "view", E.string addPointValue.selectedView)
    , ( "elementKey", E.string addPointValue.viewElementKey)
    , ( "relation", E.string (getStringFromRelation addPointValue.relation))
    , ( "pointIndex", E.int addPointValue.pointIndex)
    , ( "x", E.float (addPointValue.coords |> Tuple.first))
    , ( "y", E.float (addPointValue.coords |> Tuple.second))
    ]

encodeUpdateElementPosition : UpdateElementPositionMessage -> E.Value
encodeUpdateElementPosition value =
  E.object
    [ ( "view", E.string value.selectedView)
    , ( "elementKey", E.string value.viewElementKey)
    , ( "x", E.float (value.coords |> Tuple.first))
    , ( "y", E.float (value.coords |> Tuple.second))
    ]
