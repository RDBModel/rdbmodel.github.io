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
parcelRequire.register("gt9P5", function(module, exports) {

$parcel$export(module.exports, "conf", () => $bfd6f9701f4e52c9$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $bfd6f9701f4e52c9$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/pla/pla.ts
var $bfd6f9701f4e52c9$export$c83be1687c028fc9 = {
    comments: {
        lineComment: "#"
    },
    brackets: [
        [
            "[",
            "]"
        ],
        [
            "<",
            ">"
        ],
        [
            "(",
            ")"
        ]
    ],
    autoClosingPairs: [
        {
            open: "[",
            close: "]"
        },
        {
            open: "<",
            close: ">"
        },
        {
            open: "(",
            close: ")"
        }
    ],
    surroundingPairs: [
        {
            open: "[",
            close: "]"
        },
        {
            open: "<",
            close: ">"
        },
        {
            open: "(",
            close: ")"
        }
    ]
};
var $bfd6f9701f4e52c9$export$789c912f57fe164c = {
    defaultToken: "",
    tokenPostfix: ".pla",
    brackets: [
        {
            open: "[",
            close: "]",
            token: "delimiter.square"
        },
        {
            open: "<",
            close: ">",
            token: "delimiter.angle"
        },
        {
            open: "(",
            close: ")",
            token: "delimiter.parenthesis"
        }
    ],
    keywords: [
        ".i",
        ".o",
        ".mv",
        ".ilb",
        ".ob",
        ".label",
        ".type",
        ".phase",
        ".pair",
        ".symbolic",
        ".symbolic-output",
        ".kiss",
        ".p",
        ".e",
        ".end"
    ],
    comment: /#.*$/,
    identifier: /[a-zA-Z]+[a-zA-Z0-9_\-]*/,
    plaContent: /[01\-~\|]+/,
    tokenizer: {
        root: [
            {
                include: "@whitespace"
            },
            [
                /@comment/,
                "comment"
            ],
            [
                /\.([a-zA-Z_\-]+)/,
                {
                    cases: {
                        "@eos": {
                            token: "keyword.$1"
                        },
                        "@keywords": {
                            cases: {
                                ".type": {
                                    token: "keyword.$1",
                                    next: "@type"
                                },
                                "@default": {
                                    token: "keyword.$1",
                                    next: "@keywordArg"
                                }
                            }
                        },
                        "@default": {
                            token: "keyword.$1"
                        }
                    }
                }
            ],
            [
                /@identifier/,
                "identifier"
            ],
            [
                /@plaContent/,
                "string"
            ]
        ],
        whitespace: [
            [
                /[ \t\r\n]+/,
                ""
            ]
        ],
        type: [
            {
                include: "@whitespace"
            },
            [
                /\w+/,
                {
                    token: "type",
                    next: "@pop"
                }
            ]
        ],
        keywordArg: [
            [
                /[ \t\r\n]+/,
                {
                    cases: {
                        "@eos": {
                            token: "",
                            next: "@pop"
                        },
                        "@default": ""
                    }
                }
            ],
            [
                /@comment/,
                "comment",
                "@pop"
            ],
            [
                /[<>()\[\]]/,
                {
                    cases: {
                        "@eos": {
                            token: "@brackets",
                            next: "@pop"
                        },
                        "@default": "@brackets"
                    }
                }
            ],
            [
                /\-?\d+/,
                {
                    cases: {
                        "@eos": {
                            token: "number",
                            next: "@pop"
                        },
                        "@default": "number"
                    }
                }
            ],
            [
                /@identifier/,
                {
                    cases: {
                        "@eos": {
                            token: "identifier",
                            next: "@pop"
                        },
                        "@default": "identifier"
                    }
                }
            ],
            [
                /[;=]/,
                {
                    cases: {
                        "@eos": {
                            token: "delimiter",
                            next: "@pop"
                        },
                        "@default": "delimiter"
                    }
                }
            ]
        ]
    }
};

});


//# sourceMappingURL=pla.64c030ea.js.map
