module ViewEditor.DrawEdges exposing (drawEdge, edgeStrokeWidthExtend)

import Color
import Domain.Domain exposing (Edge, Vertex, ViewRelationKey, getViewRelationKeyFromEdge, getViewRelationKeyFromViewRelationPointKey)
import Html.Attributes
import Html.Events.Extra.Mouse as Mouse
import Navigation.ViewNavigation as ViewNavigation
import Path exposing (Path)
import Shape exposing (linearCurve)
import SubPath exposing (arcLength, arcLengthParameterized)
import TypedSvg exposing (g, title)
import TypedSvg.Attributes as Attrs
    exposing
        ( cx
        , cy
        , d
        , fill
        , id
        , rx
        , stroke
        , strokeOpacity
        , strokeWidth
        , transform
        , x
        , y
        )
import TypedSvg.Core exposing (Attribute, Svg, text)
import TypedSvg.Types
    exposing
        ( AnchorAlignment(..)
        , CoordinateSystem(..)
        , Cursor(..)
        , DominantBaseline(..)
        , Length(..)
        , LengthAdjust(..)
        , Opacity(..)
        , Paint(..)
        , Transform(..)
        )
import ViewEditor.MovingViewElements exposing (getSelectedPointKeysAndDeltas)
import ViewEditor.Msg exposing (Msg(..))
import ViewEditor.Types exposing (SelectedItem)


drawEdge : ViewNavigation.Model -> List SelectedItem -> Maybe ViewRelationKey -> Edge -> Svg Msg
drawEdge viewNavigation selectedItems relationWithCircles edge =
    let
        getSelectedPointIndex vpk =
            if getViewRelationKeyFromViewRelationPointKey vpk == getViewRelationKeyFromEdge edge then
                let
                    ( _, _, viewRelationPointIndex ) =
                        vpk
                in
                Just viewRelationPointIndex

            else
                Nothing
    in
    getSelectedPointKeysAndDeltas selectedItems
        |> List.map Tuple.first
        |> List.filterMap getSelectedPointIndex
        |> linkElement viewNavigation edge (drawCiclesAtCorner relationWithCircles edge)


linkElement : ViewNavigation.Model -> Edge -> Bool -> List Int -> Svg Msg
linkElement viewNavigation edge drawCornerCircles =
    let
        viewRelationKey =
            getViewRelationKeyFromEdge edge
    in
    if ViewNavigation.panMode viewNavigation then
        edgeBetweenContainers
            edge
            (ViewNavigation.panModeEvent viewNavigation |> List.map (Html.Attributes.map ViewNavigation))
            (\_ -> ViewNavigation.panModeEvent viewNavigation |> List.map (Html.Attributes.map ViewNavigation))
            False

    else
        edgeBetweenContainers
            edge
            [ onMouseDownEdge viewRelationKey, onMouseHoverEdge viewRelationKey, onMouseHoverLeaveEdge ]
            (onMouseDownPoint viewRelationKey)
            drawCornerCircles


drawCiclesAtCorner : Maybe ViewRelationKey -> Edge -> Bool
drawCiclesAtCorner currentRelation edge =
    case currentRelation of
        Just ( elementKey, ( targetElement, description ) ) ->
            edge.source.key == elementKey && edge.target.key == targetElement && edge.description == description

        Nothing ->
            False


onMouseDownEdge : ViewRelationKey -> Attribute Msg
onMouseDownEdge viewRelationKey =
    Mouse.onDown
        (\e ->
            case e.button of
                Mouse.MainButton ->
                    ClickEdgeStart viewRelationKey e.clientPos

                Mouse.SecondButton ->
                    RemoveEdge viewRelationKey

                _ ->
                    NoOp
        )


onMouseHoverEdge : ViewRelationKey -> Attribute Msg
onMouseHoverEdge viewRelationKey =
    Mouse.onEnter
        (\_ ->
            EdgeEnter viewRelationKey
        )


onMouseHoverLeaveEdge : Attribute Msg
onMouseHoverLeaveEdge =
    Mouse.onLeave
        (\_ ->
            EdgeLeave
        )


onMouseDownPoint : ViewRelationKey -> Int -> List (Attribute Msg)
onMouseDownPoint ( viewRelationElementKey, relation ) index =
    let
        viewRelationPointKey =
            ( viewRelationElementKey, relation, index )
    in
    [ Mouse.onDown
        (\e ->
            case e.button of
                Mouse.MainButton ->
                    DragPointStart viewRelationPointKey e.clientPos

                Mouse.SecondButton ->
                    RemovePoint viewRelationPointKey

                _ ->
                    NoOp
        )
    , Mouse.onEnter
        (\_ ->
            EdgeEnter ( viewRelationElementKey, relation )
        )
    , Mouse.onLeave
        (\_ ->
            EdgeLeave
        )
    ]


edgeBetweenContainers : Edge -> List (Attribute msg) -> (Int -> List (Attribute msg)) -> Bool -> List Int -> Svg msg
edgeBetweenContainers edge addPointEvent removeOrDragPointEvent drawCornerCircles selectedIndexes =
    let
        points =
            edge.points |> filterPointsUnderContainer edge.source edge.target

        ( sx, sy ) =
            edge.source.xy

        ( tx, ty ) =
            edge.target.xy

        ( lastPointX, lastPointY ) =
            points
                |> List.reverse
                |> List.head
                |> Maybe.withDefault edge.source.xy

        ( firstPointX, firstPointY ) =
            points
                |> List.head
                |> Maybe.withDefault edge.target.xy

        ( conTargetWidth, conTargetHeight ) =
            edge.target.wh

        ( conSourceWidth, conSourceHeight ) =
            edge.source.wh

        -- half of rect
        ( rxTarget, ryTarget ) =
            ( conTargetWidth / 2, conTargetHeight / 2 )

        ( rxSource, rySource ) =
            ( conSourceWidth / 2, conSourceHeight / 2 )

        -- size of sides of big triangle create by dots
        ( xLast, yLast ) =
            ( (lastPointX - tx) |> abs, (lastPointY - ty) |> abs )

        ( xFirst, yFirst ) =
            ( (firstPointX - sx) |> abs, (firstPointY - sy) |> abs )

        -- if the line crosses the rect in the top or bottom
        -- otherwise it crosses left or right borders or rect
        topBottomLast =
            yLast / xLast > ryTarget / rxTarget

        topBottomFirst =
            yFirst / xFirst > rySource / rxSource

        -- intersection between a line (acenter of target container and the last point) and a rect that represents the target cotnainer
        updatedLastPointXY =
            let
                temp =
                    if topBottomLast then
                        ryTarget / yLast

                    else
                        rxTarget / xLast
            in
            ( (lastPointX - tx) * temp + tx, (lastPointY - ty) * temp + ty )

        updatedFirstPointXY =
            let
                temp =
                    if topBottomFirst then
                        rySource / yFirst

                    else
                        rxSource / xFirst
            in
            ( (firstPointX - sx) * temp + sx, (firstPointY - sy) * temp + sy )

        preparedPoints =
            updatedFirstPointXY :: points ++ [ updatedLastPointXY ]

        curve =
            linearCurve preparedPoints

        -- magic offset for ➤ symbol
        magicOffset =
            9

        curveLength =
            curve |> arcLengthParameterized 1.0e-4 |> arcLength

        -- offset based on aspect ratio
        offset =
            curveLength - magicOffset

        idValue =
            "from-" ++ edge.source.name ++ "-to-" ++ edge.target.name

        strokeWidthValue =
            1

        tooltip =
            String.join " " [ "'" ++ edge.source.name ++ "'", edge.description, "'" ++ edge.target.name ++ "'" ]
    in
    if containerWithinContainer edge.source edge.target then
        g [] []

    else
        g []
            [ SubPath.element curve
                [ id idValue
                , strokeWidth <| Px strokeWidthValue
                , stroke <| Paint <| Color.black
                , fill <| PaintNone
                ]
            , TypedSvg.path
                ([ d (curve |> SubPath.toString)
                 , strokeWidth <| Px (strokeWidthValue + edgeStrokeWidthExtend)
                 , stroke <| Paint <| Color.black
                 , strokeOpacity <| Opacity 0
                 , fill <| PaintNone
                 ]
                    ++ addPointEvent
                )
                [ title [] [ text tooltip ] ]
            , TypedSvg.text_ []
                [ TypedSvg.textPath
                    [ Attrs.xlinkHref ("#" ++ idValue)
                    , Attrs.startOffset <| String.fromFloat offset
                    , Attrs.dominantBaseline DominantBaselineCentral
                    , Attrs.fontSize <| Px 10
                    , Attrs.style "user-select: none;" --forbid to select arrow as text
                    ]
                    [ text "➤" ]
                ]
            , if drawCornerCircles || not (List.isEmpty selectedIndexes) then
                g [] <|
                    List.indexedMap
                        (\i ( dx, dy ) ->
                            let
                                eventToAdd =
                                    removeOrDragPointEvent i
                            in
                            TypedSvg.path
                                ([ d (circleDot |> Path.toString)
                                 , fill (Paint Color.white)
                                 , stroke
                                    (Paint <|
                                        if List.member i selectedIndexes then
                                            Color.blue

                                        else
                                            Color.black
                                    )
                                 , transform [ Translate dx dy ]
                                 ]
                                    ++ eventToAdd
                                )
                                [ title [] [ text tooltip ] ]
                        )
                        points

              else
                g [] []
            ]


containerWithinContainer : Vertex -> Vertex -> Bool
containerWithinContainer source target =
    let
        ( x, y ) =
            source.xy

        ( w, h ) =
            source.wh

        x1 =
            x - w / 2

        x2 =
            x + w / 2

        y1 =
            y - h / 2

        y2 =
            y + h / 2
    in
    pointWithinContainer target ( x1, y1 )
        || pointWithinContainer target ( x2, y1 )
        || pointWithinContainer target ( x1, y2 )
        || pointWithinContainer target ( x2, y2 )


pointWithinContainer : Vertex -> ( Float, Float ) -> Bool
pointWithinContainer vertex ( tx, ty ) =
    let
        ( x, y ) =
            vertex.xy

        ( w, h ) =
            vertex.wh

        x1 =
            x - w / 2

        x2 =
            x + w / 2

        y1 =
            y - h / 2

        y2 =
            y + h / 2
    in
    min x1 x2 <= tx && tx <= max x1 x2 && min y1 y2 <= ty && ty <= max y1 y2


filterPointsUnderContainer : Vertex -> Vertex -> List ( Float, Float ) -> List ( Float, Float )
filterPointsUnderContainer source target =
    List.foldl
        (\point result ->
            if List.isEmpty result && pointUnderRect source point then
                result

            else
                point :: result
        )
        []
        >> List.foldl
            (\point result ->
                if List.isEmpty result && pointUnderRect target point then
                    result

                else
                    point :: result
            )
            []


pointUnderRect : Vertex -> ( Float, Float ) -> Bool
pointUnderRect vertex ( px, py ) =
    let
        ( x, y ) =
            vertex.xy

        ( containerWidth, containerHeight ) =
            vertex.wh
    in
    px
        > (x - containerWidth / 2)
        && px
        < (x + containerWidth / 2)
        && py
        > (y - containerHeight / 2)
        && py
        < (y + containerHeight / 2)


edgeStrokeWidthExtend : number
edgeStrokeWidthExtend =
    3


circleDot : Path
circleDot =
    Shape.arc
        { innerRadius = 0
        , outerRadius = 3
        , cornerRadius = 0
        , startAngle = 0
        , endAngle = 2 * pi
        , padAngle = 0
        , padRadius = 0
        }
