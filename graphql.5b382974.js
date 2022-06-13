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
parcelRequire.register("44ON1", function(module, exports) {

$parcel$export(module.exports, "conf", () => $2f7eeef0d7157e4a$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $2f7eeef0d7157e4a$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/graphql/graphql.ts
var $2f7eeef0d7157e4a$export$c83be1687c028fc9 = {
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
            open: '"""',
            close: '"""',
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
            open: '"""',
            close: '"""'
        },
        {
            open: '"',
            close: '"'
        }
    ],
    folding: {
        offSide: true
    }
};
var $2f7eeef0d7157e4a$export$789c912f57fe164c = {
    defaultToken: "invalid",
    tokenPostfix: ".gql",
    keywords: [
        "null",
        "true",
        "false",
        "query",
        "mutation",
        "subscription",
        "extend",
        "schema",
        "directive",
        "scalar",
        "type",
        "interface",
        "union",
        "enum",
        "input",
        "implements",
        "fragment",
        "on"
    ],
    typeKeywords: [
        "Int",
        "Float",
        "String",
        "Boolean",
        "ID"
    ],
    directiveLocations: [
        "SCHEMA",
        "SCALAR",
        "OBJECT",
        "FIELD_DEFINITION",
        "ARGUMENT_DEFINITION",
        "INTERFACE",
        "UNION",
        "ENUM",
        "ENUM_VALUE",
        "INPUT_OBJECT",
        "INPUT_FIELD_DEFINITION",
        "QUERY",
        "MUTATION",
        "SUBSCRIPTION",
        "FIELD",
        "FRAGMENT_DEFINITION",
        "FRAGMENT_SPREAD",
        "INLINE_FRAGMENT",
        "VARIABLE_DEFINITION"
    ],
    operators: [
        "=",
        "!",
        "?",
        ":",
        "&",
        "|"
    ],
    symbols: /[=!?:&|]+/,
    escapes: /\\(?:["\\\/bfnrt]|u[0-9A-Fa-f]{4})/,
    tokenizer: {
        root: [
            [
                /[a-z_][\w$]*/,
                {
                    cases: {
                        "@keywords": "keyword",
                        "@default": "key.identifier"
                    }
                }
            ],
            [
                /[$][\w$]*/,
                {
                    cases: {
                        "@keywords": "keyword",
                        "@default": "argument.identifier"
                    }
                }
            ],
            [
                /[A-Z][\w\$]*/,
                {
                    cases: {
                        "@typeKeywords": "keyword",
                        "@default": "type.identifier"
                    }
                }
            ],
            {
                include: "@whitespace"
            },
            [
                /[{}()\[\]]/,
                "@brackets"
            ],
            [
                /@symbols/,
                {
                    cases: {
                        "@operators": "operator",
                        "@default": ""
                    }
                }
            ],
            [
                /@\s*[a-zA-Z_\$][\w\$]*/,
                {
                    token: "annotation",
                    log: "annotation token: $0"
                }
            ],
            [
                /\d*\.\d+([eE][\-+]?\d+)?/,
                "number.float"
            ],
            [
                /0[xX][0-9a-fA-F]+/,
                "number.hex"
            ],
            [
                /\d+/,
                "number"
            ],
            [
                /[;,.]/,
                "delimiter"
            ],
            [
                /"""/,
                {
                    token: "string",
                    next: "@mlstring",
                    nextEmbedded: "markdown"
                }
            ],
            [
                /"([^"\\]|\\.)*$/,
                "string.invalid"
            ],
            [
                /"/,
                {
                    token: "string.quote",
                    bracket: "@open",
                    next: "@string"
                }
            ]
        ],
        mlstring: [
            [
                /[^"]+/,
                "string"
            ],
            [
                '"""',
                {
                    token: "string",
                    next: "@pop",
                    nextEmbedded: "@pop"
                }
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
                {
                    token: "string.quote",
                    bracket: "@close",
                    next: "@pop"
                }
            ]
        ],
        whitespace: [
            [
                /[ \t\r\n]+/,
                ""
            ],
            [
                /#.*$/,
                "comment"
            ]
        ]
    }
};

});


//# sourceMappingURL=graphql.5b382974.js.map
