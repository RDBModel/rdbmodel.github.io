function $parcel$export(e, n, v, s) {
  Object.defineProperty(e, n, {get: v, set: s, enumerable: true, configurable: true});
}
var $parcel$global =
typeof globalThis !== 'undefined'
  ? globalThis
  : typeof self !== 'undefined'
  ? self
  : typeof window !== 'undefined'
  ? window
  : typeof global !== 'undefined'
  ? global
  : {};
var parcelRequire = $parcel$global["parcelRequiref17b"];
parcelRequire.register("4pmMk", function(module, exports) {

$parcel$export(module.exports, "conf", () => $335b2a8e4188d2b3$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $335b2a8e4188d2b3$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/less/less.ts
var $335b2a8e4188d2b3$export$c83be1687c028fc9 = {
    wordPattern: /(#?-?\d*\.\d\w*%?)|([@#!.:]?[\w-?]+%?)|[@#!.]/g,
    comments: {
        blockComment: [
            "/*",
            "*/"
        ],
        lineComment: "//"
    },
    brackets: [
        [
            "{",
            "}"
        ],
        [
            "[",
            "]"
        ],
        [
            "(",
            ")"
        ]
    ],
    autoClosingPairs: [
        {
            open: "{",
            close: "}",
            notIn: [
                "string",
                "comment"
            ]
        },
        {
            open: "[",
            close: "]",
            notIn: [
                "string",
                "comment"
            ]
        },
        {
            open: "(",
            close: ")",
            notIn: [
                "string",
                "comment"
            ]
        },
        {
            open: '"',
            close: '"',
            notIn: [
                "string",
                "comment"
            ]
        },
        {
            open: "'",
            close: "'",
            notIn: [
                "string",
                "comment"
            ]
        }
    ],
    surroundingPairs: [
        {
            open: "{",
            close: "}"
        },
        {
            open: "[",
            close: "]"
        },
        {
            open: "(",
            close: ")"
        },
        {
            open: '"',
            close: '"'
        },
        {
            open: "'",
            close: "'"
        }
    ],
    folding: {
        markers: {
            start: new RegExp("^\\s*\\/\\*\\s*#region\\b\\s*(.*?)\\s*\\*\\/"),
            end: new RegExp("^\\s*\\/\\*\\s*#endregion\\b.*\\*\\/")
        }
    }
};
var $335b2a8e4188d2b3$export$789c912f57fe164c = {
    defaultToken: "",
    tokenPostfix: ".less",
    identifier: "-?-?([a-zA-Z]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))([\\w\\-]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))*",
    identifierPlus: "-?-?([a-zA-Z:.]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))([\\w\\-:.]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))*",
    brackets: [
        {
            open: "{",
            close: "}",
            token: "delimiter.curly"
        },
        {
            open: "[",
            close: "]",
            token: "delimiter.bracket"
        },
        {
            open: "(",
            close: ")",
            token: "delimiter.parenthesis"
        },
        {
            open: "<",
            close: ">",
            token: "delimiter.angle"
        }
    ],
    tokenizer: {
        root: [
            {
                include: "@nestedJSBegin"
            },
            [
                "[ \\t\\r\\n]+",
                ""
            ],
            {
                include: "@comments"
            },
            {
                include: "@keyword"
            },
            {
                include: "@strings"
            },
            {
                include: "@numbers"
            },
            [
                "[*_]?[a-zA-Z\\-\\s]+(?=:.*(;|(\\\\$)))",
                "attribute.name",
                "@attribute"
            ],
            [
                "url(\\-prefix)?\\(",
                {
                    token: "tag",
                    next: "@urldeclaration"
                }
            ],
            [
                "[{}()\\[\\]]",
                "@brackets"
            ],
            [
                "[,:;]",
                "delimiter"
            ],
            [
                "#@identifierPlus",
                "tag.id"
            ],
            [
                "&",
                "tag"
            ],
            [
                "\\.@identifierPlus(?=\\()",
                "tag.class",
                "@attribute"
            ],
            [
                "\\.@identifierPlus",
                "tag.class"
            ],
            [
                "@identifierPlus",
                "tag"
            ],
            {
                include: "@operators"
            },
            [
                "@(@identifier(?=[:,\\)]))",
                "variable",
                "@attribute"
            ],
            [
                "@(@identifier)",
                "variable"
            ],
            [
                "@",
                "key",
                "@atRules"
            ]
        ],
        nestedJSBegin: [
            [
                "``",
                "delimiter.backtick"
            ],
            [
                "`",
                {
                    token: "delimiter.backtick",
                    next: "@nestedJSEnd",
                    nextEmbedded: "text/javascript"
                }
            ]
        ],
        nestedJSEnd: [
            [
                "`",
                {
                    token: "delimiter.backtick",
                    next: "@pop",
                    nextEmbedded: "@pop"
                }
            ]
        ],
        operators: [
            [
                "[<>=\\+\\-\\*\\/\\^\\|\\~]",
                "operator"
            ]
        ],
        keyword: [
            [
                "(@[\\s]*import|![\\s]*important|true|false|when|iscolor|isnumber|isstring|iskeyword|isurl|ispixel|ispercentage|isem|hue|saturation|lightness|alpha|lighten|darken|saturate|desaturate|fadein|fadeout|fade|spin|mix|round|ceil|floor|percentage)\\b",
                "keyword"
            ]
        ],
        urldeclaration: [
            {
                include: "@strings"
            },
            [
                "[^)\r\n]+",
                "string"
            ],
            [
                "\\)",
                {
                    token: "tag",
                    next: "@pop"
                }
            ]
        ],
        attribute: [
            {
                include: "@nestedJSBegin"
            },
            {
                include: "@comments"
            },
            {
                include: "@strings"
            },
            {
                include: "@numbers"
            },
            {
                include: "@keyword"
            },
            [
                "[a-zA-Z\\-]+(?=\\()",
                "attribute.value",
                "@attribute"
            ],
            [
                ">",
                "operator",
                "@pop"
            ],
            [
                "@identifier",
                "attribute.value"
            ],
            {
                include: "@operators"
            },
            [
                "@(@identifier)",
                "variable"
            ],
            [
                "[)\\}]",
                "@brackets",
                "@pop"
            ],
            [
                "[{}()\\[\\]>]",
                "@brackets"
            ],
            [
                "[;]",
                "delimiter",
                "@pop"
            ],
            [
                "[,=:]",
                "delimiter"
            ],
            [
                "\\s",
                ""
            ],
            [
                ".",
                "attribute.value"
            ]
        ],
        comments: [
            [
                "\\/\\*",
                "comment",
                "@comment"
            ],
            [
                "\\/\\/+.*",
                "comment"
            ]
        ],
        comment: [
            [
                "\\*\\/",
                "comment",
                "@pop"
            ],
            [
                ".",
                "comment"
            ]
        ],
        numbers: [
            [
                "(\\d*\\.)?\\d+([eE][\\-+]?\\d+)?",
                {
                    token: "attribute.value.number",
                    next: "@units"
                }
            ],
            [
                "#[0-9a-fA-F_]+(?!\\w)",
                "attribute.value.hex"
            ]
        ],
        units: [
            [
                "(em|ex|ch|rem|vmin|vmax|vw|vh|vm|cm|mm|in|px|pt|pc|deg|grad|rad|turn|s|ms|Hz|kHz|%)?",
                "attribute.value.unit",
                "@pop"
            ]
        ],
        strings: [
            [
                '~?"',
                {
                    token: "string.delimiter",
                    next: "@stringsEndDoubleQuote"
                }
            ],
            [
                "~?'",
                {
                    token: "string.delimiter",
                    next: "@stringsEndQuote"
                }
            ]
        ],
        stringsEndDoubleQuote: [
            [
                '\\\\"',
                "string"
            ],
            [
                '"',
                {
                    token: "string.delimiter",
                    next: "@popall"
                }
            ],
            [
                ".",
                "string"
            ]
        ],
        stringsEndQuote: [
            [
                "\\\\'",
                "string"
            ],
            [
                "'",
                {
                    token: "string.delimiter",
                    next: "@popall"
                }
            ],
            [
                ".",
                "string"
            ]
        ],
        atRules: [
            {
                include: "@comments"
            },
            {
                include: "@strings"
            },
            [
                "[()]",
                "delimiter"
            ],
            [
                "[\\{;]",
                "delimiter",
                "@pop"
            ],
            [
                ".",
                "key"
            ]
        ]
    }
};

});


//# sourceMappingURL=less.4323ec77.js.map
