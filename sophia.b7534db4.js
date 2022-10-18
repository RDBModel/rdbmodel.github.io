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
parcelRequire.register("7dFT3", function(module, exports) {

$parcel$export(module.exports, "conf", () => $541a3d30963b40ac$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $541a3d30963b40ac$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/sophia/sophia.ts
var $541a3d30963b40ac$export$c83be1687c028fc9 = {
    comments: {
        lineComment: "//",
        blockComment: [
            "/*",
            "*/"
        ]
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
        ],
        [
            "<",
            ">"
        ]
    ],
    autoClosingPairs: [
        {
            open: '"',
            close: '"',
            notIn: [
                "string",
                "comment"
            ]
        },
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
        }
    ]
};
var $541a3d30963b40ac$export$789c912f57fe164c = {
    defaultToken: "",
    tokenPostfix: ".aes",
    brackets: [
        {
            token: "delimiter.curly",
            open: "{",
            close: "}"
        },
        {
            token: "delimiter.parenthesis",
            open: "(",
            close: ")"
        },
        {
            token: "delimiter.square",
            open: "[",
            close: "]"
        },
        {
            token: "delimiter.angle",
            open: "<",
            close: ">"
        }
    ],
    keywords: [
        "contract",
        "library",
        "entrypoint",
        "function",
        "stateful",
        "state",
        "hash",
        "signature",
        "tuple",
        "list",
        "address",
        "string",
        "bool",
        "int",
        "record",
        "datatype",
        "type",
        "option",
        "oracle",
        "oracle_query",
        "Call",
        "Bits",
        "Bytes",
        "Oracle",
        "String",
        "Crypto",
        "Address",
        "Auth",
        "Chain",
        "None",
        "Some",
        "bits",
        "bytes",
        "event",
        "let",
        "map",
        "private",
        "public",
        "true",
        "false",
        "var",
        "if",
        "else",
        "throw"
    ],
    operators: [
        "=",
        ">",
        "<",
        "!",
        "~",
        "?",
        "::",
        ":",
        "==",
        "<=",
        ">=",
        "!=",
        "&&",
        "||",
        "++",
        "--",
        "+",
        "-",
        "*",
        "/",
        "&",
        "|",
        "^",
        "%",
        "<<",
        ">>",
        ">>>",
        "+=",
        "-=",
        "*=",
        "/=",
        "&=",
        "|=",
        "^=",
        "%=",
        "<<=",
        ">>=",
        ">>>="
    ],
    symbols: /[=><!~?:&|+\-*\/\^%]+/,
    escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
    integersuffix: /(ll|LL|u|U|l|L)?(ll|LL|u|U|l|L)?/,
    floatsuffix: /[fFlL]?/,
    tokenizer: {
        root: [
            [
                /[a-zA-Z_]\w*/,
                {
                    cases: {
                        "@keywords": {
                            token: "keyword.$0"
                        },
                        "@default": "identifier"
                    }
                }
            ],
            {
                include: "@whitespace"
            },
            [
                /\[\[.*\]\]/,
                "annotation"
            ],
            [
                /^\s*#\w+/,
                "keyword"
            ],
            [
                /int\d*/,
                "keyword"
            ],
            [
                /[{}()\[\]]/,
                "@brackets"
            ],
            [
                /[<>](?!@symbols)/,
                "@brackets"
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
                /\d*\d+[eE]([\-+]?\d+)?(@floatsuffix)/,
                "number.float"
            ],
            [
                /\d*\.\d+([eE][\-+]?\d+)?(@floatsuffix)/,
                "number.float"
            ],
            [
                /0[xX][0-9a-fA-F']*[0-9a-fA-F](@integersuffix)/,
                "number.hex"
            ],
            [
                /0[0-7']*[0-7](@integersuffix)/,
                "number.octal"
            ],
            [
                /0[bB][0-1']*[0-1](@integersuffix)/,
                "number.binary"
            ],
            [
                /\d[\d']*\d(@integersuffix)/,
                "number"
            ],
            [
                /\d(@integersuffix)/,
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
            ],
            [
                /'[^\\']'/,
                "string"
            ],
            [
                /(')(@escapes)(')/,
                [
                    "string",
                    "string.escape",
                    "string"
                ]
            ],
            [
                /'/,
                "string.invalid"
            ]
        ],
        whitespace: [
            [
                /[ \t\r\n]+/,
                ""
            ],
            [
                /\/\*\*(?!\/)/,
                "comment.doc",
                "@doccomment"
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
        doccomment: [
            [
                /[^\/*]+/,
                "comment.doc"
            ],
            [
                /\*\//,
                "comment.doc",
                "@pop"
            ],
            [
                /[\/*]/,
                "comment.doc"
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


//# sourceMappingURL=sophia.b7534db4.js.map