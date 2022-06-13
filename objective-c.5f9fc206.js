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
parcelRequire.register("6C3pB", function(module, exports) {

$parcel$export(module.exports, "conf", () => $4d08f03a730a5fe1$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $4d08f03a730a5fe1$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/objective-c/objective-c.ts
var $4d08f03a730a5fe1$export$c83be1687c028fc9 = {
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
        }
    ]
};
var $4d08f03a730a5fe1$export$789c912f57fe164c = {
    defaultToken: "",
    tokenPostfix: ".objective-c",
    keywords: [
        "#import",
        "#include",
        "#define",
        "#else",
        "#endif",
        "#if",
        "#ifdef",
        "#ifndef",
        "#ident",
        "#undef",
        "@class",
        "@defs",
        "@dynamic",
        "@encode",
        "@end",
        "@implementation",
        "@interface",
        "@package",
        "@private",
        "@protected",
        "@property",
        "@protocol",
        "@public",
        "@selector",
        "@synthesize",
        "__declspec",
        "assign",
        "auto",
        "BOOL",
        "break",
        "bycopy",
        "byref",
        "case",
        "char",
        "Class",
        "const",
        "copy",
        "continue",
        "default",
        "do",
        "double",
        "else",
        "enum",
        "extern",
        "FALSE",
        "false",
        "float",
        "for",
        "goto",
        "if",
        "in",
        "int",
        "id",
        "inout",
        "IMP",
        "long",
        "nil",
        "nonatomic",
        "NULL",
        "oneway",
        "out",
        "private",
        "public",
        "protected",
        "readwrite",
        "readonly",
        "register",
        "return",
        "SEL",
        "self",
        "short",
        "signed",
        "sizeof",
        "static",
        "struct",
        "super",
        "switch",
        "typedef",
        "TRUE",
        "true",
        "union",
        "unsigned",
        "volatile",
        "void",
        "while"
    ],
    decpart: /\d(_?\d)*/,
    decimal: /0|@decpart/,
    tokenizer: {
        root: [
            {
                include: "@comments"
            },
            {
                include: "@whitespace"
            },
            {
                include: "@numbers"
            },
            {
                include: "@strings"
            },
            [
                /[,:;]/,
                "delimiter"
            ],
            [
                /[{}\[\]()<>]/,
                "@brackets"
            ],
            [
                /[a-zA-Z@#]\w*/,
                {
                    cases: {
                        "@keywords": "keyword",
                        "@default": "identifier"
                    }
                }
            ],
            [
                /[<>=\\+\\-\\*\\/\\^\\|\\~,]|and\\b|or\\b|not\\b]/,
                "operator"
            ]
        ],
        whitespace: [
            [
                /\s+/,
                "white"
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
                /0[xX][0-9a-fA-F]*(_?[0-9a-fA-F])*/,
                "number.hex"
            ],
            [
                /@decimal((\.@decpart)?([eE][\-+]?@decpart)?)[fF]*/,
                {
                    cases: {
                        "(\\d)*": "number",
                        $0: "number.float"
                    }
                }
            ]
        ],
        strings: [
            [
                /'$/,
                "string.escape",
                "@popall"
            ],
            [
                /'/,
                "string.escape",
                "@stringBody"
            ],
            [
                /"$/,
                "string.escape",
                "@popall"
            ],
            [
                /"/,
                "string.escape",
                "@dblStringBody"
            ]
        ],
        stringBody: [
            [
                /[^\\']+$/,
                "string",
                "@popall"
            ],
            [
                /[^\\']+/,
                "string"
            ],
            [
                /\\./,
                "string"
            ],
            [
                /'/,
                "string.escape",
                "@popall"
            ],
            [
                /\\$/,
                "string"
            ]
        ],
        dblStringBody: [
            [
                /[^\\"]+$/,
                "string",
                "@popall"
            ],
            [
                /[^\\"]+/,
                "string"
            ],
            [
                /\\./,
                "string"
            ],
            [
                /"/,
                "string.escape",
                "@popall"
            ],
            [
                /\\$/,
                "string"
            ]
        ]
    }
};

});


//# sourceMappingURL=objective-c.5f9fc206.js.map
