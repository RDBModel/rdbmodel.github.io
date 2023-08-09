module ViewEditor.DrawEdges exposing (drawEdge, edgeStrokeWidthExtend)

import Domain.Domain exposing (Edge, ViewRelationKey, getViewRelationKeyFromEdge, getViewRelationKeyFromViewRelationPointKey)
import Html.Attributes
import Html.Events.Extra.Mouse as Mouse
import Navigation.ViewNavigation as ViewNavigation
import TypedSvg.Core exposing (Attribute, Svg)
import ViewEditor.MovingViewElements exposing (getSelectedPointKeysAndDeltas)
import ViewEditor.Msg exposing (Msg(..))
import ViewEditor.Types exposing (SelectedItem)
import ViewEditor.DrawContainer exposing (containerWidth)
import ViewEditor.DrawContainer exposing (containerHeight)
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
import Color
import Path exposing (Path)

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
edgeBetweenContainers edge addPointEvent removeOrDragPointEvent drawCornerCircles selectedIndexes  =
    let
        points =
            edge.points |> filterPointsUnderContainer edge.source.xy edge.target.xy

        ( sx, sy ) =
            edge.source.xy

        ( tx, ty ) =
            edge.target.xy

        ( cx, cy ) =
            points
                |> List.reverse
                |> List.head
                |> Maybe.withDefault edge.source.xy

        preparedPoints =
            ( sx, sy ) :: points ++ [ ( tx, ty ) ]

        curve =
            linearCurve preparedPoints

        -- half of rect
        ( rx, ry ) =
            ( containerWidth / 2, containerHeight / 2 )

        -- size of sides of big triangle create by dots
        ( x, y ) =
            ( (cx - tx) |> abs, (cy - ty) |> abs )

        -- if the line crosses the rect in the top or bottom
        -- otherwise it crosses left or right borders or rect
        topBottom =
            y / x > ry / rx

        -- distance between start and end dots
        distanceXY =
            sqrt (x * x + y * y)

        -- magic offset for ➤ symbol
        magicOffset =
            9

        curveLength =
            curve |> arcLengthParameterized 1.0e-4 |> arcLength

        -- offset based on aspect ratio
        offset =
            let
                temp =
                    if topBottom then
                        ry / y

                    else
                        rx / x
            in
            curveLength - distanceXY * temp - magicOffset

        idValue =
            "from-" ++ edge.source.name ++ "-to-" ++ edge.target.name

        strokeWidthValue =
            1

        tooltip =
            String.join " " [ "'" ++ edge.source.name ++ "'", edge.description, "'" ++ edge.target.name ++ "'" ]
    in
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


{--
    Removing temprorary points which are under container
--}


filterPointsUnderContainer : ( Float, Float ) -> ( Float, Float ) -> List ( Float, Float ) -> List ( Float, Float )
filterPointsUnderContainer sourceXY targetXY =
    List.foldl
        (\point result ->
            if List.isEmpty result && pointUnderRect sourceXY point then
                result

            else
                point :: result
        )
        []
        >> List.foldl
            (\point result ->
                if List.isEmpty result && pointUnderRect targetXY point then
                    result

                else
                    point :: result
            )
            []




pointUnderRect : ( Float, Float ) -> ( Float, Float ) -> Bool
pointUnderRect ( x, y ) ( px, py ) =
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
