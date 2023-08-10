module ViewEditor.AddNewPointToEdge exposing (pointsWithNewPoint)

import Basics.Extra exposing (maxSafeInteger)
import Domain.Domain exposing (ViewRelationPoint)
import ViewEditor.DrawEdges exposing (edgeStrokeWidthExtend)


pointsWithNewPoint : ( Float, Float ) -> ( Float, Float ) -> List ( Float, Float ) -> ( Float, Float ) -> List ViewRelationPoint
pointsWithNewPoint pointToInsert sxy relationPoints txy =
    allPointsWithNewlyAdded pointToInsert sxy relationPoints txy |> trimList 1 |> List.map (\( x, y ) -> ViewRelationPoint x y)


trimList : Int -> List a -> List a
trimList count =
    List.drop count
        >> List.reverse
        >> List.drop count
        >> List.reverse


allPointsWithNewlyAdded : ( Float, Float ) -> ( Float, Float ) -> List ( Float, Float ) -> ( Float, Float ) -> List ( Float, Float )
allPointsWithNewlyAdded pointToInsert sxy relationPoints txy =
    let
        allPoints =
            sxy :: relationPoints ++ [ txy ]

        ( _, ( insertAfterValue, _ ) ) =
            List.foldr
                (\currentPoint ->
                    \( previousPoint, ( insertAfterPoint, val ) ) ->
                        let
                            z =
                                distanceToLine pointToInsert ( currentPoint, previousPoint )

                            ( extendedA, extendedPrev ) =
                                extendPoints currentPoint previousPoint
                        in
                        if not (isNaN z) && betweenPoints pointToInsert ( extendedA, extendedPrev ) && z < val then
                            ( currentPoint, ( currentPoint, z ) )

                        else
                            ( currentPoint, ( insertAfterPoint, val ) )
                )
                ( txy, ( txy, maxSafeInteger ) )
                allPoints

        ( listWithNewPoint, _, _ ) =
            List.foldr
                (\a ->
                    \( b, i, found ) ->
                        if insertAfterValue == a then
                            ( a :: pointToInsert :: b, i, True )

                        else
                            ( a :: b
                            , if found then
                                i

                              else
                                i + 1
                            , found
                            )
                )
                ( [], 0, False )
                allPoints
    in
    listWithNewPoint


{-| calculate distance to the line created by two points
it is not work good as it is required to calculcate distance to line segment
not line
TODO
-}
distanceToLine : ( Float, Float ) -> ( ( Float, Float ), ( Float, Float ) ) -> Float
distanceToLine ( x, y ) ( ( x1, y1 ), ( x2, y2 ) ) =
    -- distance to the line
    abs ((x2 - x1) * (y1 - y) - (x1 - x) * (y2 - y1)) / sqrt ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))


extendPoints : ( number, number ) -> ( number, number ) -> ( ( number, number ), ( number, number ) )
extendPoints ( x1, y1 ) ( x2, y2 ) =
    let
        extend v1 v2 =
            if v1 < v2 || v1 == v2 then
                ( v1 - edgeStrokeWidthExtend, v2 + edgeStrokeWidthExtend )

            else
                ( v2 - edgeStrokeWidthExtend, v1 + edgeStrokeWidthExtend )

        ( ux1, ux2 ) =
            extend x1 x2

        ( uy1, uy2 ) =
            extend y1 y2
    in
    ( ( ux1, uy1 ), ( ux2, uy2 ) )


{-| is it enough to put the point ?
-}
betweenPoints : ( Float, Float ) -> ( ( Float, Float ), ( Float, Float ) ) -> Bool
betweenPoints ( x, y ) ( ( x1, y1 ), ( x2, y2 ) ) =
    let
        isBetween v v1 v2 =
            if v1 < v2 then
                v1 < v && v < v2

            else if v1 == v2 then
                v1 == v && v == v2

            else
                v2 < v && v < v1
    in
    isBetween x x1 x2 && isBetween y y1 y2
