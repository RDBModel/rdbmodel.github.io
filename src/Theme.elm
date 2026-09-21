module Theme exposing (..)

{-| The Kami design language, as adapted for screen apps.

Warm parchment canvas, ink-blue accent, serif carries hierarchy, warm
neutrals only. Source: https://github.com/ypyl/folio/blob/master/DESIGN.md

A hex value lives here exactly once, as an `Rgb` triple, and is converted
to whichever colour type a call site needs. The `:root` custom properties in
`index.html` mirror these tokens for the raw-CSS layer; keep the two in sync.

-}

import Color
import Element exposing (Attribute, Color, rgb255)
import Element.Background as Background
import Element.Font as Font


type alias Rgb =
    ( Int, Int, Int )


toElement : Rgb -> Color
toElement ( r, g, b ) =
    rgb255 r g b


toSvg : Rgb -> Color.Color
toSvg ( r, g, b ) =
    Color.rgb255 r g b


toCss : Rgb -> String
toCss ( r, g, b ) =
    "rgb(" ++ String.fromInt r ++ "," ++ String.fromInt g ++ "," ++ String.fromInt b ++ ")"



-- Surfaces


parchment : Rgb
parchment =
    ( 0xF5, 0xF4, 0xED )


ivory : Rgb
ivory =
    ( 0xFA, 0xF9, 0xF5 )


warmSand : Rgb
warmSand =
    ( 0xE8, 0xE6, 0xDC )



-- Text


nearBlack : Rgb
nearBlack =
    ( 0x14, 0x14, 0x13 )


darkWarm : Rgb
darkWarm =
    ( 0x3D, 0x3D, 0x3A )


olive : Rgb
olive =
    ( 0x50, 0x4E, 0x49 )


stone : Rgb
stone =
    ( 0x6B, 0x6A, 0x64 )



-- Borders and tints


border : Rgb
border =
    ( 0xE8, 0xE6, 0xDC )


borderSoft : Rgb
borderSoft =
    ( 0xE5, 0xE3, 0xD8 )


brand : Rgb
brand =
    ( 0x1B, 0x36, 0x5D )


brandLight : Rgb
brandLight =
    ( 0x2D, 0x5A, 0x8A )


chipBg : Rgb
chipBg =
    ( 0xE4, 0xEC, 0xF5 )


{-| The one sanctioned exception to the single-accent rule: a warm warning
pair, used only for validation errors.
-}
errorBg : Rgb
errorBg =
    ( 0xF0, 0xE0, 0xD8 )


errorFg : Rgb
errorFg =
    ( 0x8B, 0x45, 0x13 )


brandTint : Rgb
brandTint =
    ( 0xEE, 0xF2, 0xF7 )



-- Typography


serifFamily : List Font.Font
serifFamily =
    [ Font.typeface "Georgia", Font.typeface "Iowan Old Style", Font.typeface "Times New Roman", Font.serif ]


sansFamily : List Font.Font
sansFamily =
    [ Font.typeface "system-ui", Font.typeface "Segoe UI", Font.typeface "Helvetica Neue", Font.sansSerif ]



-- Shared page attributes


pageAttributes : List (Attribute msg)
pageAttributes =
    [ Background.color (toElement parchment), Font.color (toElement nearBlack), Font.family sansFamily ]


headingAttributes : List (Attribute msg)
headingAttributes =
    [ Font.family serifFamily, Font.color (toElement nearBlack), Font.medium ]


cardAttributes : List (Attribute msg)
cardAttributes =
    [ Background.color (toElement ivory), Font.color (toElement darkWarm) ]
