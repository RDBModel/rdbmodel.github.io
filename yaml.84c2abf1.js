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
parcelRequire.register("18RR9", function(module, exports) {

$parcel$export(module.exports, "conf", () => $0d5050874d49e2c6$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $0d5050874d49e2c6$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/yaml/yaml.ts
var $0d5050874d49e2c6$export$c83be1687c028fc9 = {
    comments: {
        lineComment: "#"
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
    ],
    folding: {
        offSide: true
    }
};
var $0d5050874d49e2c6$export$789c912f57fe164c = {
    tokenPostfix: ".yaml",
    brackets: [
        {
            token: "delimiter.bracket",
            open: "{",
            close: "}"
        },
        {
            token: "delimiter.square",
            open: "[",
            close: "]"
        }
    ],
    keywords: [
        "true",
        "True",
        "TRUE",
        "false",
        "False",
        "FALSE",
        "null",
        "Null",
        "Null",
        "~"
    ],
    numberInteger: /(?:0|[+-]?[0-9]+)/,
    numberFloat: /(?:0|[+-]?[0-9]+)(?:\.[0-9]+)?(?:e[-+][1-9][0-9]*)?/,
    numberOctal: /0o[0-7]+/,
    numberHex: /0x[0-9a-fA-F]+/,
    numberInfinity: /[+-]?\.(?:inf|Inf|INF)/,
    numberNaN: /\.(?:nan|Nan|NAN)/,
    numberDate: /\d{4}-\d\d-\d\d([Tt ]\d\d:\d\d:\d\d(\.\d+)?(( ?[+-]\d\d?(:\d\d)?)|Z)?)?/,
    escapes: /\\(?:[btnfr\\"']|[0-7][0-7]?|[0-3][0-7]{2})/,
    tokenizer: {
        root: [
            {
                include: "@whitespace"
            },
            {
                include: "@comment"
            },
            [
                /%[^ ]+.*$/,
                "meta.directive"
            ],
            [
                /---/,
                "operators.directivesEnd"
            ],
            [
                /\.{3}/,
                "operators.documentEnd"
            ],
            [
                /[-?:](?= )/,
                "operators"
            ],
            {
                include: "@anchor"
            },
            {
                include: "@tagHandle"
            },
            {
                include: "@flowCollections"
            },
            {
                include: "@blockStyle"
            },
            [
                /@numberInteger(?![ \t]*\S+)/,
                "number"
            ],
            [
                /@numberFloat(?![ \t]*\S+)/,
                "number.float"
            ],
            [
                /@numberOctal(?![ \t]*\S+)/,
                "number.octal"
            ],
            [
                /@numberHex(?![ \t]*\S+)/,
                "number.hex"
            ],
            [
                /@numberInfinity(?![ \t]*\S+)/,
                "number.infinity"
            ],
            [
                /@numberNaN(?![ \t]*\S+)/,
                "number.nan"
            ],
            [
                /@numberDate(?![ \t]*\S+)/,
                "number.date"
            ],
            [
                /(".*?"|'.*?'|.*?)([ \t]*)(:)( |$)/,
                [
                    "type",
                    "white",
                    "operators",
                    "white"
                ]
            ],
            {
                include: "@flowScalars"
            },
            [
                /[^#]+/,
                {
                    cases: {
                        "@keywords": "keyword",
                        "@default": "string"
                    }
                }
            ]
        ],
        object: [
            {
                include: "@whitespace"
            },
            {
                include: "@comment"
            },
            [
                /\}/,
                "@brackets",
                "@pop"
            ],
            [
                /,/,
                "delimiter.comma"
            ],
            [
                /:(?= )/,
                "operators"
            ],
            [
                /(?:".*?"|'.*?'|[^,\{\[]+?)(?=: )/,
                "type"
            ],
            {
                include: "@flowCollections"
            },
            {
                include: "@flowScalars"
            },
            {
                include: "@tagHandle"
            },
            {
                include: "@anchor"
            },
            {
                include: "@flowNumber"
            },
            [
                /[^\},]+/,
                {
                    cases: {
                        "@keywords": "keyword",
                        "@default": "string"
                    }
                }
            ]
        ],
        array: [
            {
                include: "@whitespace"
            },
            {
                include: "@comment"
            },
            [
                /\]/,
                "@brackets",
                "@pop"
            ],
            [
                /,/,
                "delimiter.comma"
            ],
            {
                include: "@flowCollections"
            },
            {
                include: "@flowScalars"
            },
            {
                include: "@tagHandle"
            },
            {
                include: "@anchor"
            },
            {
                include: "@flowNumber"
            },
            [
                /[^\],]+/,
                {
                    cases: {
                        "@keywords": "keyword",
                        "@default": "string"
                    }
                }
            ]
        ],
        multiString: [
            [
                /^( +).+$/,
                "string",
                "@multiStringContinued.$1"
            ]
        ],
        multiStringContinued: [
            [
                /^( *).+$/,
                {
                    cases: {
                        "$1==$S2": "string",
                        "@default": {
                            token: "@rematch",
                            next: "@popall"
                        }
                    }
                }
            ]
        ],
        whitespace: [
            [
                /[ \t\r\n]+/,
                "white"
            ]
        ],
        comment: [
            [
                /#.*$/,
                "comment"
            ]
        ],
        flowCollections: [
            [
                /\[/,
                "@brackets",
                "@array"
            ],
            [
                /\{/,
                "@brackets",
                "@object"
            ]
        ],
        flowScalars: [
            [
                /"([^"\\]|\\.)*$/,
                "string.invalid"
            ],
            [
                /'([^'\\]|\\.)*$/,
                "string.invalid"
            ],
            [
                /'[^']*'/,
                "string"
            ],
            [
                /"/,
                "string",
                "@doubleQuotedString"
            ]
        ],
        doubleQuotedString: [
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
        ],
        blockStyle: [
            [
                /[>|][0-9]*[+-]?$/,
                "operators",
                "@multiString"
            ]
        ],
        flowNumber: [
            [
                /@numberInteger(?=[ \t]*[,\]\}])/,
                "number"
            ],
            [
                /@numberFloat(?=[ \t]*[,\]\}])/,
                "number.float"
            ],
            [
                /@numberOctal(?=[ \t]*[,\]\}])/,
                "number.octal"
            ],
            [
                /@numberHex(?=[ \t]*[,\]\}])/,
                "number.hex"
            ],
            [
                /@numberInfinity(?=[ \t]*[,\]\}])/,
                "number.infinity"
            ],
            [
                /@numberNaN(?=[ \t]*[,\]\}])/,
                "number.nan"
            ],
            [
                /@numberDate(?=[ \t]*[,\]\}])/,
                "number.date"
            ]
        ],
        tagHandle: [
            [
                /\![^ ]*/,
                "tag"
            ]
        ],
        anchor: [
            [
                /[&*][^ ]+/,
                "namespace"
            ]
        ]
    }
};

});


//# sourceMappingURL=yaml.84c2abf1.js.map
