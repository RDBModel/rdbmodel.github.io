module Utils exposing (..)


trimList : Int -> List a -> List a
trimList count =
    List.drop count
        >> List.reverse
        >> List.drop count
        >> List.reverse
