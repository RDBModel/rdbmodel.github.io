module Yaml.Parser.Ast exposing (Property, Value(..), fold, fromString, map, toString)

import Dict exposing (Dict)



-- AST


{-| -}
type Value
    = String_ String
    | Float_ Float
    | Int_ Int
    | List_ (List Value)
    | Record_ (Dict String Value)
    | Bool_ Bool
    | Null_
    | Anchor_ String Value
    | Alias_ String


{-| -}
type alias Property =
    ( String, Value )


{-| -}
fromString : String -> Value
fromString string =
    let
        trimmed =
            String.trim string

        sign : ( Float, String )
        sign =
            if String.length trimmed > 1 then
                case String.left 1 trimmed of
                    "-" ->
                        ( -1, String.dropLeft 1 trimmed )

                    "+" ->
                        ( 1, String.dropLeft 1 trimmed )

                    _ ->
                        ( 1, trimmed )

            else
                ( 1, trimmed )
    in
    case sign of
        ( _, "" ) ->
            Null_

        ( _, "~" ) ->
            Null_

        ( _, "null" ) ->
            Null_

        ( _, "Null" ) ->
            Null_

        ( _, "NULL" ) ->
            Null_

        ( _, "true" ) ->
            Bool_ True

        ( _, "True" ) ->
            Bool_ True

        ( _, "TRUE" ) ->
            Bool_ True

        ( _, "on" ) ->
            Bool_ True

        ( _, "On" ) ->
            Bool_ True

        ( _, "ON" ) ->
            Bool_ True

        ( _, "y" ) ->
            Bool_ True

        ( _, "Y" ) ->
            Bool_ True

        ( _, "yes" ) ->
            Bool_ True

        ( _, "Yes" ) ->
            Bool_ True

        ( _, "YES" ) ->
            Bool_ True

        ( _, "false" ) ->
            Bool_ False

        ( _, "False" ) ->
            Bool_ False

        ( _, "FALSE" ) ->
            Bool_ False

        ( _, "off" ) ->
            Bool_ False

        ( _, "Off" ) ->
            Bool_ False

        ( _, "OFF" ) ->
            Bool_ False

        ( _, "n" ) ->
            Bool_ False

        ( _, "N" ) ->
            Bool_ False

        ( _, "no" ) ->
            Bool_ False

        ( _, "No" ) ->
            Bool_ False

        ( _, "NO" ) ->
            Bool_ False

        ( _, ".nan" ) ->
            Float_ (0 / 0)

        ( _, ".NaN" ) ->
            Float_ (0 / 0)

        ( _, ".NAN" ) ->
            Float_ (0 / 0)

        ( mult, ".inf" ) ->
            Float_ (mult * 1 / 0)

        ( mult, ".Inf" ) ->
            Float_ (mult * 1 / 0)

        ( mult, ".INF" ) ->
            Float_ (mult * 1 / 0)

        _ ->
            case String.toInt trimmed of
                Just int ->
                    Int_ int

                Nothing ->
                    case String.toFloat trimmed of
                        Just float ->
                            Float_ float

                        Nothing ->
                            String_ (String.trim trimmed)



-- DISPLAY


{-| -}
toString : Value -> String
toString value =
    case value of
        String_ string ->
            "\"" ++ string ++ "\" (string)"

        Float_ float ->
            String.fromFloat float ++ " (float)"

        Int_ int ->
            String.fromInt int ++ " (int)"

        List_ list ->
            "[ " ++ String.join ", " (List.map toString list) ++ " ] (list)"

        Record_ properties ->
            "{ " ++ String.join ", " (List.map toStringProperty (Dict.toList properties)) ++ " } (map)"

        Bool_ True ->
            "True (bool)"

        Bool_ False ->
            "False (bool)"

        Null_ ->
            "Null"

        Anchor_ name r_val ->
            "&" ++ name ++ " " ++ toString r_val

        Alias_ name ->
            "*" ++ name


toStringProperty : Property -> String
toStringProperty ( name, value ) =
    name ++ ": " ++ toString value


fold : (Value -> b -> b) -> Value -> b -> b
fold f value z =
    case value of
        String_ _ ->
            f value z

        Float_ _ ->
            f value z

        Int_ _ ->
            f value z

        Bool_ _ ->
            f value z

        Null_ ->
            f value z

        Alias_ _ ->
            f value z

        List_ l ->
            f value (List.foldl (fold f) z l)

        Record_ r ->
            f value (List.foldl (fold f) z (Dict.values r))

        Anchor_ nm a ->
            f value (fold f a z)


map : (Value -> Value) -> Value -> Value
map f value =
    case value of
        String_ _ ->
            f value

        Float_ _ ->
            f value

        Int_ _ ->
            f value

        Bool_ _ ->
            f value

        Null_ ->
            f value

        Alias_ _ ->
            f value

        List_ l ->
            f (List_ (List.map (map f) l))

        Record_ r ->
            f (Record_ <| Dict.fromList (List.map (\( k, v ) -> ( k, map f v )) (Dict.toList r)))

        Anchor_ name a ->
            f (Anchor_ name (map f a))
