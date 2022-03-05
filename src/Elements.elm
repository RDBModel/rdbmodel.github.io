module Elements exposing
     ( renderContainerSelected, renderContainer
     , markerDot, innerGrid, grid, gridRect, edgeBetweenContainers, edgeStrokeWidthExtend, gridCellSize
     , rectToSelect
     )
import TypedSvg.Core exposing (Svg, text)
import TypedSvg exposing (rect, circle, pattern, marker, g, text_)
import TypedSvg.Types exposing (Length(..), AnchorAlignment(..))
import TypedSvg.Attributes as Attrs exposing
    ( x, y, width, height, rx, cx, cy, r, id, strokeWidth, fill, stroke, strokeOpacity, transform, dominantBaseline
    , textAnchor)
import TypedSvg.Types exposing (Paint(..), CoordinateSystem(..), Opacity(..), DominantBaseline(..), Transform(..))
import Color
import TypedSvg.Core exposing (Attribute)
import Path exposing (Path)
import Shape exposing (linearCurve)
import SubPath exposing (arcLengthParameterized, arcLength)
import Domain exposing (Container)
import TypedSvg.Attributes exposing (cursor)
import TypedSvg.Types exposing (Cursor(..))

containerWidth : Float
containerWidth = 100
containerHeight : Float
containerHeight = 50
containerRadius : Float
containerRadius = 0
-- systemRadius : Float
-- systemRadius = 50
gridCellSize : Float
gridCellSize = 10


renderContainerSelected : Container -> Maybe (Attribute msg) -> Svg msg
renderContainerSelected = renderContainerInternal True

renderContainer : Container -> Maybe (Attribute msg) -> Svg msg
renderContainer = renderContainerInternal False

renderContainerInternal : Bool -> Container -> Maybe (Attribute msg) -> Svg msg
renderContainerInternal selected { name, xy } event =
    let
        (xCenter, yCenter) = xy

        updatedName a =
            if String.length name > 15 then
                String.slice 0 15 a
            else
                a

        eventToAdd = 
            case event of
                Just ev -> [ ev ]
                Nothing -> []
    in
    g []
        [ rect
            ([ x <| Px <| xCenter - containerWidth / 2
            , y <| Px <| yCenter - containerHeight / 2
            , width <| Px containerWidth
            , height <| Px containerHeight
            , rx <| Px containerRadius
            , Attrs.fill <| Paint <| Color.white
            , Attrs.stroke <| Paint <| if selected then Color.blue else Color.black
            , Attrs.strokeWidth <| Px 1
            ] ++ eventToAdd) []
        , text_
            ([ x <| Px <| xCenter
            , y <| Px <| yCenter
            , width <| Px containerWidth
            , height <| Px containerHeight
            , dominantBaseline DominantBaselineMiddle
            , textAnchor AnchorMiddle
            , cursor CursorDefault
            ] ++ eventToAdd)
            [text <| updatedName name ]
        ]

-- renderSystem : Float -> Float -> Svg msg
-- renderSystem xValue yValue = 
--     circle
--         [ cx <| Px xValue
--         , cy <| Px yValue
--         , r <| Px systemRadius
--         , Attrs.fill <| Paint <| Color.white
--         , Attrs.stroke <| Paint <| Color.black
--         , Attrs.strokeWidth <| Px 1
--         ] []

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

pointDotId : String
pointDotId = "dot"


markerDot : Svg msg
markerDot =
    marker
        [ id pointDotId
        , Attrs.refX "5"
        , Attrs.refY "5"
        , Attrs.markerWidth <| Px 10
        , Attrs.markerHeight <| Px 10
        ]
        [
            circle
                [ cx <| Px 5
                , cy <| Px 5
                , r <| Px 3
                , Attrs.fill <| Paint <| Color.white
                , Attrs.stroke <| Paint <| Color.black
                , Attrs.strokeWidth <| Px 1
                ]
                []
        ]


innerGridId : String
innerGridId = "inner-grid"


innerGrid : Float -> Svg msg
innerGrid size =
    pattern
        [ id innerGridId
        , Attrs.width <| Px size
        , Attrs.height <| Px size
        , Attrs.patternUnits CoordinateSystemUserSpaceOnUse
        ]
        [
            rect
            [ Attrs.width <| Percent 100
            , Attrs.height <| Percent 100
            , Attrs.fill PaintNone
            , Attrs.stroke <| Paint <| Color.rgb255 204 204 204
            , strokeWidth <| Px 0.5
            ]
            []
        ]

gridId : String
gridId = "grid"

grid : Float -> Float -> Float -> Svg msg
grid x y size =
    pattern
        [ id gridId
        , Attrs.width <| Px size
        , Attrs.height <| Px size
        , Attrs.x <| Px x
        , Attrs.y <| Px y
        , Attrs.patternUnits CoordinateSystemUserSpaceOnUse
        ]
        [
            rect
            [ Attrs.width <| Percent 100
            , Attrs.height <| Percent 100
            , Attrs.fill <| Reference innerGridId
            , Attrs.stroke <| Paint <| Color.rgb255 204 204 204
            , strokeWidth <| Px 1.5
            ]
            []
        ]


gridRect : List (Attribute msg) -> Svg msg
gridRect events =
    rect
        ([ Attrs.width <| Percent 100
        , Attrs.height <| Percent 100
        , fill <| Reference gridId
        --, cursor CursorMove
        ] ++ events) []

edgeStrokeWidthExtend : number
edgeStrokeWidthExtend = 3

edgeBetweenContainers edge selectedIndexes addPointEvent removeOrDragPointEvent =
     let
        points = edge.points
        (sx, sy) = edge.source.xy
        (tx, ty) = edge.target.xy

        (cx, cy) = points
            |> List.reverse
            |> List.head
            |> Maybe.withDefault edge.source.xy

        preparedPoints = (sx, sy) :: points ++ [ (tx, ty) ]
        curve = linearCurve preparedPoints

        -- half of rect
        (rx, ry) = (containerWidth / 2, containerHeight / 2)

        -- size of sides of big triangle create by dots
        (x, y) = ((cx - tx) |> abs, (cy - ty) |> abs)

        -- if the line crosses the rect in the top or bottom
        -- otherwise it crosses left or right borders or rect
        topBottom = y / x > ry / rx

        -- distance between start and end dots
        distanceXY = sqrt (x * x + y * y)

        -- magic offset for ➤ symbol
        magicOffset = 9

        curveLength = curve |> arcLengthParameterized 1e-4 |> arcLength

        -- offset based on aspect ratio
        offset =
            let
                temp = if topBottom then ry / y else rx / x
            in
            curveLength - distanceXY * temp - magicOffset

        idValue =
            "from-" ++ edge.source.name ++ "-to-" ++ edge.target.name

        strokeWidthValue = 1

        addPointEventToAdd =
            case addPointEvent of
                Just ev -> [ ev ]
                Nothing -> []
    in
    g []
        [ SubPath.element curve
                [ id idValue
                , strokeWidth <| Px strokeWidthValue
                , stroke <| Paint <| Color.black
                , fill <| PaintNone
                ]
        , SubPath.element curve
                ([ strokeWidth <| Px (strokeWidthValue + edgeStrokeWidthExtend)
                , stroke <| Paint <| Color.black
                , strokeOpacity <| Opacity 0
                , fill <| PaintNone
                ] ++ addPointEventToAdd)
        , TypedSvg.text_ []
            [
                TypedSvg.textPath
                    [ Attrs.xlinkHref ("#" ++ idValue)
                    , Attrs.startOffset <| String.fromFloat offset
                    , Attrs.dominantBaseline DominantBaselineCentral
                    , Attrs.fontSize <| Px 10
                    , Attrs.style "user-select: none;" --forbid to select arrow as text
                    ]
                    [ text "➤" ]
            ]
        , g [] <| List.indexedMap
            (\i -> \(dx, dy ) ->
                let
                    eventToAdd = 
                        case removeOrDragPointEvent of
                            Just ev -> [ ev i]
                            Nothing -> []
                in
                Path.element circleDot
                    ([ fill (Paint Color.white)
                    , stroke (Paint <| if List.member i selectedIndexes then Color.blue else Color.black
                    )
                    , transform [ Translate dx dy ]
                    ] ++ eventToAdd)) points
        ]


rectToSelect : (Float, Float) -> (Float, Float) -> Svg msg
rectToSelect (xValue, yValue) (w, h) =
    rect [x <| Px <| xValue
    , y <| Px <| yValue
    , width <| Px <| w
    , height <| Px <| h] []
