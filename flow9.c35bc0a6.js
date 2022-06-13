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
parcelRequire.register("i2Iip", function(module, exports) {

$parcel$export(module.exports, "conf", () => $d22ac6278e5acf5b$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $d22ac6278e5acf5b$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/flow9/flow9.ts
var $d22ac6278e5acf5b$export$c83be1687c028fc9 = {
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
                "string"
            ]
        },
        {
            open: "[",
            close: "]",
            notIn: [
                "string"
            ]
        },
        {
            open: "(",
            close: ")",
            notIn: [
                "string"
            ]
        },
        {
            open: '"',
            close: '"',
            notIn: [
                "string"
            ]
        },
        {
            open: "'",
            close: "'",
            notIn: [
                "string"
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
        },
        {
            open: "<",
            close: ">"
        }
    ]
};
var $d22ac6278e5acf5b$export$789c912f57fe164c = {
    defaultToken: "",
    tokenPostfix: ".flow",
    keywords: [
        "import",
        "require",
        "export",
        "forbid",
        "native",
        "if",
        "else",
        "cast",
        "unsafe",
        "switch",
        "default"
    ],
    types: [
        "io",
        "mutable",
        "bool",
        "int",
        "double",
        "string",
        "flow",
        "void",
        "ref",
        "true",
        "false",
        "with"
    ],
    operators: [
        "=",
        ">",
        "<",
        "<=",
        ">=",
        "==",
        "!",
        "!=",
        ":=",
        "::=",
        "&&",
        "||",
        "+",
        "-",
        "*",
        "/",
        "@",
        "&",
        "%",
        ":",
        "->",
        "\\",
        "$",
        "??",
        "^"
    ],
    symbols: /[@$=><!~?:&|+\-*\\\/\^%]+/,
    escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
    tokenizer: {
        root: [
            [
                /[a-zA-Z_]\w*/,
                {
                    cases: {
                        "@keywords": "keyword",
                        "@types": "type",
                        "@default": "identifier"
                    }
                }
            ],
            {
                include: "@whitespace"
            },
            [
                /[{}()\[\]]/,
                "delimiter"
            ],
            [
                /[<>](?!@symbols)/,
                "delimiter"
            ],
            [
                /@symbols/,
                {
                    cases: {
                        "@operators": "delimiter",
                        "@default": ""
                    }
                }
            ],
            [
                /((0(x|X)[0-9a-fA-F]*)|(([0-9]+\.?[0-9]*)|(\.[0-9]+))((e|E)(\+|-)?[0-9]+)?)/,
                "number"
            ],
            [
                /[;,.]/,
                "delimiter"
            ],
            [
                /"([^"\\]|\\.)*$/,
                "string.invalid"
            ],
            [
                /"/,
                "string",
                "@string"
            ]
        ],
        whitespace: [
            [
                /[ \t\r\n]+/,
                ""
            ],
            [
                /\/\*/,
                "comment",
                "@comment"
            ],
            [
                /\/\/.*$/,
                "comment"
            ]
        ],
        comment: [
            [
                /[^\/*]+/,
                "comment"
            ],
            [
                /\*\//,
                "comment",
                "@pop"
            ],
            [
                /[\/*]/,
                "comment"
            ]
        ],
        string: [
            [
                /[^\\"]+/,
                "string"
            ],
            [
                /@escapes/,
                "string.escape"
            ],
            [
                /\\./,
                "string.escape.invalid"
            ],
            [
                /"/,
                "string",
                "@pop"
            ]
        ]
    }
};

});


//# sourceMappingURL=flow9.c35bc0a6.js.map
