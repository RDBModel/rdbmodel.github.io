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
parcelRequire.register("2NpkF", function(module, exports) {

$parcel$export(module.exports, "conf", () => $2093ced44bdd8a22$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $2093ced44bdd8a22$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/lua/lua.ts
var $2093ced44bdd8a22$export$c83be1687c028fc9 = {
    comments: {
        lineComment: "--",
        blockComment: [
            "--[[",
            "]]"
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
        ]
    ],
    autoClosingPairs: [
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
    ]
};
var $2093ced44bdd8a22$export$789c912f57fe164c = {
    defaultToken: "",
    tokenPostfix: ".lua",
    keywords: [
        "and",
        "break",
        "do",
        "else",
        "elseif",
        "end",
        "false",
        "for",
        "function",
        "goto",
        "if",
        "in",
        "local",
        "nil",
        "not",
        "or",
        "repeat",
        "return",
        "then",
        "true",
        "until",
        "while"
    ],
    brackets: [
        {
            token: "delimiter.bracket",
            open: "{",
            close: "}"
        },
        {
            token: "delimiter.array",
            open: "[",
            close: "]"
        },
        {
            token: "delimiter.parenthesis",
            open: "(",
            close: ")"
        }
    ],
    operators: [
        "+",
        "-",
        "*",
        "/",
        "%",
        "^",
        "#",
        "==",
        "~=",
        "<=",
        ">=",
        "<",
        ">",
        "=",
        ";",
        ":",
        ",",
        ".",
        "..",
        "..."
    ],
    symbols: /[=><!~?:&|+\-*\/\^%]+/,
    escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
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
                /(,)(\s*)([a-zA-Z_]\w*)(\s*)(:)(?!:)/,
                [
                    "delimiter",
                    "",
                    "key",
                    "",
                    "delimiter"
                ]
            ],
            [
                /({)(\s*)([a-zA-Z_]\w*)(\s*)(:)(?!:)/,
                [
                    "@brackets",
                    "",
                    "key",
                    "",
                    "delimiter"
                ]
            ],
            [
                /[{}()\[\]]/,
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
                /\d*\.\d+([eE][\-+]?\d+)?/,
                "number.float"
            ],
            [
                /0[xX][0-9a-fA-F_]*[0-9a-fA-F]/,
                "number.hex"
            ],
            [
                /\d+?/,
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
                /'([^'\\]|\\.)*$/,
                "string.invalid"
            ],
            [
                /"/,
                "string",
                '@string."'
            ],
            [
                /'/,
                "string",
                "@string.'"
            ]
        ],
        whitespace: [
            [
                /[ \t\r\n]+/,
                ""
            ],
            [
                /--\[([=]*)\[/,
                "comment",
                "@comment.$1"
            ],
            [
                /--.*$/,
                "comment"
            ]
        ],
        comment: [
            [
                /[^\]]+/,
                "comment"
            ],
            [
                /\]([=]*)\]/,
                {
                    cases: {
                        "$1==$S2": {
                            token: "comment",
                            next: "@pop"
                        },
                        "@default": "comment"
                    }
                }
            ],
            [
                /./,
                "comment"
            ]
        ],
        string: [
            [
                /[^\\"']+/,
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
                /["']/,
                {
                    cases: {
                        "$#==$S2": {
                            token: "string",
                            next: "@pop"
                        },
                        "@default": "string"
                    }
                }
            ]
        ]
    }
};

});


//# sourceMappingURL=lua.74bcc449.js.map
