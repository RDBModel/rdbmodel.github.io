module ViewEditor.Types exposing (SelectedItem, ViewEditorState, Brush)
import Domain.Domain exposing (ViewItemKey)
import ViewControl.ViewControl as ViewControl
import ViewControl.AddView as AddView
import Navigation.ViewNavigation as ViewNavigation
import ContainerMenu.ContextMenu as ContextMenu
import Domain.Domain exposing (ViewRelationKey)

type alias ViewEditorState =
    { drag : Maybe Drag
    , viewNavigation : ViewNavigation.Model
    , viewControl : ViewControl.Model
    , selectedView : Maybe String
    , addView : AddView.Model
    , svgElementPosition : Element
    , brush : Maybe Brush
    , selectedItems : List SelectedItem
    , containerMenu : ContextMenu.Model
    , currentMouseOverRelation : Maybe ViewRelationKey
    , highlightedElement : Maybe String
    }

type alias Element =
    { height : Float
    , width : Float
    , x : Float
    , y : Float
    }

type alias Drag =
    { current : ( Float, Float ) -- current mouse position
    , start : ( Float, Float ) -- start mouse position
    }


type alias SelectedItem =
    { key : ViewItemKey -- selected node id or point index
    , delta : Maybe ( Float, Float ) -- delta between start and node center to do ajustment during movement
    }

type alias Brush =
    { end : ( Float, Float ) -- current mouse position
    , start : ( Float, Float ) -- start mouse position
    }
