module ViewEditor.Msg exposing (Msg(..))

import Browser.Dom as Dom
import ContainerMenu.ContextMenu as ContextMenu
import Domain.Domain exposing (ViewElementKey, ViewRelationKey, ViewRelationPointKey)
import Navigation.ViewNavigation as ViewNavigation
import ViewControl.AddView as AddView
import ViewControl.ViewControl as ViewControl


type Msg
    = ViewNavigation ViewNavigation.Msg
    | Resize
    | ReceiveElementPosition (Result Dom.Error Dom.Element)
    | DragViewElementStart ViewElementKey ( Float, Float )
    | ClickEdgeStart ViewRelationKey ( Float, Float )
    | RemoveEdge ViewRelationKey
    | DragPointStart ViewRelationPointKey ( Float, Float )
    | RemovePoint ViewRelationPointKey
    | MouseMove ( Float, Float )
    | EdgeEnter ViewRelationKey
    | EdgeLeave
    | MouseMoveEnd
    | SelectItemsStart ( Float, Float )
    | ViewControl ViewControl.Msg
    | AddView AddView.Msg
    | ContainerContextMenu ContextMenu.Msg
    | FocusContainer String
    | NoOp
