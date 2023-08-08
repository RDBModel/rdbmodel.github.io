module Navigation.ViewNavigation exposing
    ( Model
    , Msg
    , centralize
    , getPositionForNewElement
    , getScale
    , getTranslate
    , gridRectEvents
    , init
    , panMode
    , panModeEvent
    , shiftPosition
    , subscriptions
    , update
    , view
    , zoomTransformAttr
    )

import Browser.Events as Events
import Html exposing (Attribute, Html, button, div)
import Html.Attributes exposing (style, title, type_)
import Html.Events exposing (onClick)
import JsInterop exposing (zoomMsgReceived)
import Json.Decode as Decode
import TypedSvg exposing (circle, line, path, svg)
import TypedSvg.Attributes
    exposing
        ( cx
        , cy
        , d
        , fill
        , height
        , r
        , stroke
        , strokeLinecap
        , strokeLinejoin
        , strokeWidth
        , viewBox
        , width
        , x1
        , x2
        , y1
        , y2
        )
import TypedSvg.Types exposing (Length(..), Paint(..), StrokeLinecap(..), StrokeLinejoin(..))
import Zoom exposing (OnZoom, Zoom)


type alias Model =
    { ctrlIsDown : Bool
    , zoom : Zoom
    , stickyPositioning : Bool
    }


init : { height : Float, width : Float, x : Float, y : Float } -> Model
init element =
    Model False (initZoom element) False


initZoom : { height : Float, width : Float, x : Float, y : Float } -> Zoom
initZoom element =
    Zoom.init { width = element.width, height = element.height }
        |> Zoom.scaleExtent 0.1 2


type ZoomDirection
    = In
    | Out


type Msg
    = DoZoom ZoomDirection
    | SetCtrlToggle
    | SetCtrl Bool
    | ZoomMsg OnZoom
    | SetSticky Bool
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoZoom direction ->
            let
                scaleValue =
                    case direction of
                        In ->
                            1.2

                        Out ->
                            0.8

                current =
                    Zoom.asRecord model.zoom

                newZoom =
                    Zoom.setTransform Zoom.instantly { scale = current.scale * scaleValue, translate = current.translate } model.zoom
            in
            ( { model | zoom = newZoom }, Cmd.none )

        SetCtrlToggle ->
            ( { model | ctrlIsDown = model.ctrlIsDown |> not }
            , Cmd.none
            )

        SetCtrl value ->
            ( { model | ctrlIsDown = value }
            , Cmd.none
            )

        ZoomMsg zoomMsg ->
            ( { model | zoom = Zoom.update zoomMsg model.zoom }
            , zoomMsgReceived ()
            )

        SetSticky value ->
            ( { model | stickyPositioning = value }
            , zoomMsgReceived ()
            )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        backgroundColorForStickyButton =
            if model.stickyPositioning then
                "#cccccc"
            else
                "white"

        backgroundColorForMoveButton =
            if model.ctrlIsDown then
                "#cccccc"

            else
                "white"
    in
    div
        [ style "position" "absolute"
        , style "bottom" "10px"
        , style "right" "5px"
        , style "font-size" "16px"
        , style "user-select" "none"
        , style "display" "flex"
        , style "flex-direction" "column"

        --, Mouse.onContextMenu (\_ -> NoOp)
        ]
        [ button
            [ style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , title "Zoom in"
            , type_ "button"
            , onClick <| DoZoom In
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , fill PaintNone
                , strokeLinecap StrokeLinecapRound
                , strokeLinejoin StrokeLinejoinRound
                ]
                [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                , circle [ cx (Px 10), cy (Px 10), r (Px 7) ] []
                , line [ x1 (Px 7), y1 (Px 10), x2 (Px 13), y2 (Px 10) ] []
                , line [ x1 (Px 10), y1 (Px 7), x2 (Px 10), y2 (Px 13) ] []
                , line [ x1 (Px 21), y1 (Px 21), x2 (Px 15), y2 (Px 15) ] []
                ]
            ]
        , button
            [ style "border-width" "0 1px 1px 1px"
            , style "border-style" "solid"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , title "Zoom out"
            , type_ "button"
            , onClick <| DoZoom Out
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , fill PaintNone
                , strokeLinecap StrokeLinecapRound
                , strokeLinejoin StrokeLinejoinRound
                ]
                [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                , circle [ cx (Px 10), cy (Px 10), r (Px 7) ] []
                , line [ x1 (Px 7), y1 (Px 10), x2 (Px 13), y2 (Px 10) ] []
                , line [ x1 (Px 21), y1 (Px 21), x2 (Px 15), y2 (Px 15) ] []
                ]
            ]
        , button
            [ style "background-color" backgroundColorForMoveButton
            , style "border-width" "0 1px 1px 1px"
            , style "border-style" "solid"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , title "Set navigate view mode"
            , type_ "button"
            , onClick <| SetCtrlToggle
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , fill PaintNone
                , strokeLinecap StrokeLinecapRound
                , strokeLinejoin StrokeLinejoinRound
                ]
                [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                , path [ d "M18 9l3 3l-3 3" ] []
                , path [ d "M15 12h6" ] []
                , path [ d "M6 9l-3 3l3 3" ] []
                , path [ d "M3 12h6" ] []
                , path [ d "M9 18l3 3l3 -3" ] []
                , path [ d "M12 15v6" ] []
                , path [ d "M15 6l-3 -3l-3 3" ] []
                , path [ d "M12 3v6" ] []
                ]
            ]
        , button
            [ style "background-color" backgroundColorForStickyButton
            , style "border-width" "0 1px 1px 1px"
            , style "border-style" "solid"
            , style "min-height" "24px"
            , style "min-width" "24px"
            , style "padding" "0"
            , title "Stick elements to the grid"
            , type_ "button"
            , onClick <| SetSticky ( not (model.stickyPositioning))
            ]
            [ svg
                [ style "vertical-align" "middle"
                , width <| Px 24
                , height <| Px 24
                , viewBox 0 0 24 24
                , strokeWidth <| Px 1
                , fill PaintNone
                , strokeLinecap StrokeLinecapRound
                , strokeLinejoin StrokeLinejoinRound
                ]
                [ path [ stroke PaintNone, d "M0 0h24v24H0z", fill PaintNone ] []
                , path [ d "M18 6m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" ] []
                , path [ d "M6 12m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" ] []
                , path [ d "M6 18m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" ] []
                , path [ d "M18 18m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" ] []
                , path [ d "M8 18h8" ] []
                , path [ d "M18 20v1" ] []
                , path [ d "M18 3v1" ] []
                , path [ d "M6 20v1" ] []
                , path [ d "M6 10v-7" ] []
                , path [ d "M12 3v18" ] []
                , path [ d "M18 8v8" ] []
                , path [ d "M8 12h13" ] []
                , path [ d "M21 6h-1" ] []
                , path [ d "M16 6h-13" ] []
                , path [ d "M3 12h1" ] []
                , path [ d "M20 18h1" ] []
                , path [ d "M3 18h1" ] []
                , path [ d "M6 14v2" ] []
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Events.onKeyDown (keyDecoder |> setCtrlState True)
        , Events.onKeyUp (keyDecoder |> setCtrlState False)
        , Zoom.subscriptions model.zoom ZoomMsg
        ]


setCtrlState : Bool -> Decode.Decoder String -> Decode.Decoder Msg
setCtrlState value =
    Decode.map
        (\key ->
            if key == "Control" then
                SetCtrl value

            else
                NoOp
        )


keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string


gridRectEvents : Model -> List (Attribute Msg)
gridRectEvents model =
    [ Zoom.onDoubleClick model.zoom ZoomMsg, Zoom.onWheel model.zoom ZoomMsg ]
        ++ (if model.ctrlIsDown then
                panModeEvent model

            else
                []
           )


panModeEvent : Model -> List (Attribute Msg)
panModeEvent model =
    Zoom.onDrag model.zoom ZoomMsg


getScale : Model -> Float
getScale model =
    model.zoom |> Zoom.asRecord |> .scale


getTranslate : Model -> { x : Float, y : Float }
getTranslate model =
    model.zoom |> Zoom.asRecord |> .translate


zoomTransformAttr : Model -> Attribute Msg
zoomTransformAttr model =
    Zoom.transform model.zoom


{-| The mouse events for drag start, drag at and drag end read the client
position of the cursor, which is relative to the browser viewport. However,
the node positions are relative to the svg viewport. This function adjusts the
coordinates accordingly. It also takes the current zoom level and position
into consideration.
-}
shiftPosition : Model -> ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
shiftPosition model ( elementX, elementY ) ( clientX, clientY ) =
    let
        zoomRecord =
            Zoom.asRecord model.zoom
    in
    ( (clientX - zoomRecord.translate.x - elementX) / zoomRecord.scale
    , (clientY - zoomRecord.translate.y - elementY) / zoomRecord.scale
    )


getPositionForNewElement : Model -> { height : Float, width : Float, x : Float, y : Float } -> ( Float, Float )
getPositionForNewElement model svgElement =
    let
        record =
            Zoom.asRecord model.zoom

        ( initY, initX ) =
            ( svgElement.height / 2, svgElement.width / 2 )
    in
    ( initX - record.scale * record.translate.x, initY - record.scale * record.translate.y )


panMode : Model -> Bool
panMode model =
    model.ctrlIsDown


centralize : ( Float, Float ) -> { height : Float, width : Float, x : Float, y : Float } -> Model -> Model
centralize ( x, y ) svgElement model =
    let
        current =
            Zoom.asRecord model.zoom

        ( initY, initX ) =
            ( svgElement.height/2, svgElement.width/2 )

        newZoom =
            Zoom.setTransform Zoom.instantly { scale = current.scale, translate = { x = initX - x * current.scale, y = initY - y * current.scale } } model.zoom
    in
    { model | zoom = newZoom }
