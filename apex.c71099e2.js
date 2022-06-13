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
parcelRequire.register("2o8zk", function(module, exports) {

$parcel$export(module.exports, "conf", () => $1bd4783e65ea07b9$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $1bd4783e65ea07b9$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/apex/apex.ts
var $1bd4783e65ea07b9$export$c83be1687c028fc9 = {
    wordPattern: /(-?\d*\.\d\w*)|([^\`\~\!\#\%\^\&\*\(\)\-\=\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g,
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
        },
        {
            open: "<",
            close: ">"
        }
    ],
    folding: {
        markers: {
            start: new RegExp("^\\s*//\\s*(?:(?:#?region\\b)|(?:<editor-fold\\b))"),
            end: new RegExp("^\\s*//\\s*(?:(?:#?endregion\\b)|(?:</editor-fold>))")
        }
    }
};
var $1bd4783e65ea07b9$var$keywords = [
    "abstract",
    "activate",
    "and",
    "any",
    "array",
    "as",
    "asc",
    "assert",
    "autonomous",
    "begin",
    "bigdecimal",
    "blob",
    "boolean",
    "break",
    "bulk",
    "by",
    "case",
    "cast",
    "catch",
    "char",
    "class",
    "collect",
    "commit",
    "const",
    "continue",
    "convertcurrency",
    "decimal",
    "default",
    "delete",
    "desc",
    "do",
    "double",
    "else",
    "end",
    "enum",
    "exception",
    "exit",
    "export",
    "extends",
    "false",
    "final",
    "finally",
    "float",
    "for",
    "from",
    "future",
    "get",
    "global",
    "goto",
    "group",
    "having",
    "hint",
    "if",
    "implements",
    "import",
    "in",
    "inner",
    "insert",
    "instanceof",
    "int",
    "interface",
    "into",
    "join",
    "last_90_days",
    "last_month",
    "last_n_days",
    "last_week",
    "like",
    "limit",
    "list",
    "long",
    "loop",
    "map",
    "merge",
    "native",
    "new",
    "next_90_days",
    "next_month",
    "next_n_days",
    "next_week",
    "not",
    "null",
    "nulls",
    "number",
    "object",
    "of",
    "on",
    "or",
    "outer",
    "override",
    "package",
    "parallel",
    "pragma",
    "private",
    "protected",
    "public",
    "retrieve",
    "return",
    "returning",
    "rollback",
    "savepoint",
    "search",
    "select",
    "set",
    "short",
    "sort",
    "stat",
    "static",
    "strictfp",
    "super",
    "switch",
    "synchronized",
    "system",
    "testmethod",
    "then",
    "this",
    "this_month",
    "this_week",
    "throw",
    "throws",
    "today",
    "tolabel",
    "tomorrow",
    "transaction",
    "transient",
    "trigger",
    "true",
    "try",
    "type",
    "undelete",
    "update",
    "upsert",
    "using",
    "virtual",
    "void",
    "volatile",
    "webservice",
    "when",
    "where",
    "while",
    "yesterday"
];
var $1bd4783e65ea07b9$var$uppercaseFirstLetter = (lowercase)=>lowercase.charAt(0).toUpperCase() + lowercase.substr(1)
;
var $1bd4783e65ea07b9$var$keywordsWithCaseVariations = [];
$1bd4783e65ea07b9$var$keywords.forEach((lowercase)=>{
    $1bd4783e65ea07b9$var$keywordsWithCaseVariations.push(lowercase);
    $1bd4783e65ea07b9$var$keywordsWithCaseVariations.push(lowercase.toUpperCase());
    $1bd4783e65ea07b9$var$keywordsWithCaseVariations.push($1bd4783e65ea07b9$var$uppercaseFirstLetter(lowercase));
});
var $1bd4783e65ea07b9$export$789c912f57fe164c = {
    defaultToken: "",
    tokenPostfix: ".apex",
    keywords: $1bd4783e65ea07b9$var$keywordsWithCaseVariations,
    operators: [
        "=",
        ">",
        "<",
        "!",
        "~",
        "?",
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
    digits: /\d+(_+\d+)*/,
    octaldigits: /[0-7]+(_+[0-7]+)*/,
    binarydigits: /[0-1]+(_+[0-1]+)*/,
    hexdigits: /[[0-9a-fA-F]+(_+[0-9a-fA-F]+)*/,
    tokenizer: {
        root: [
            [
                /[a-z_$][\w$]*/,
                {
                    cases: {
                        "@keywords": {
                            token: "keyword.$0"
                        },
                        "@default": "identifier"
                    }
                }
            ],
            [
                /[A-Z][\w\$]*/,
                {
                    cases: {
                        "@keywords": {
                            token: "keyword.$0"
                        },
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
                /@\s*[a-zA-Z_\$][\w\$]*/,
                "annotation"
            ],
            [
                /(@digits)[eE]([\-+]?(@digits))?[fFdD]?/,
                "number.float"
            ],
            [
                /(@digits)\.(@digits)([eE][\-+]?(@digits))?[fFdD]?/,
                "number.float"
            ],
            [
                /(@digits)[fFdD]/,
                "number.float"
            ],
            [
                /(@digits)[lL]?/,
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
                "@apexdoc"
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
        apexdoc: [
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


//# sourceMappingURL=apex.c71099e2.js.map
