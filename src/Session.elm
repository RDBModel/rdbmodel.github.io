module Session exposing (Session)

import Browser.Navigation as Nav


type alias Session =
    { isFileSystemSupported : Bool
    , version : String
    , key : Nav.Key
    }
