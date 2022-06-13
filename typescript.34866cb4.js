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
parcelRequire.register("g5v8v", function(module, exports) {

$parcel$export(module.exports, "conf", () => $bb6543fb26bdf666$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $bb6543fb26bdf666$export$789c912f57fe164c);

var $leKFq = parcelRequire("leKFq");
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ var $bb6543fb26bdf666$var$__defProp = Object.defineProperty;
var $bb6543fb26bdf666$var$__getOwnPropDesc = Object.getOwnPropertyDescriptor;
var $bb6543fb26bdf666$var$__getOwnPropNames = Object.getOwnPropertyNames;
var $bb6543fb26bdf666$var$__hasOwnProp = Object.prototype.hasOwnProperty;
var $bb6543fb26bdf666$var$__markAsModule = (target)=>$bb6543fb26bdf666$var$__defProp(target, "__esModule", {
        value: true
    })
;
var $bb6543fb26bdf666$var$__reExport = (target, module, desc)=>{
    if (module && typeof module === "object" || typeof module === "function") {
        for (let key of $bb6543fb26bdf666$var$__getOwnPropNames(module))if (!$bb6543fb26bdf666$var$__hasOwnProp.call(target, key) && key !== "default") $bb6543fb26bdf666$var$__defProp(target, key, {
            get: ()=>module[key]
            ,
            enumerable: !(desc = $bb6543fb26bdf666$var$__getOwnPropDesc(module, key)) || desc.enumerable
        });
    }
    return target;
};
// src/fillers/monaco-editor-core.ts
var $bb6543fb26bdf666$var$monaco_editor_core_exports = {};
$bb6543fb26bdf666$var$__markAsModule($bb6543fb26bdf666$var$monaco_editor_core_exports);
$bb6543fb26bdf666$var$__reExport($bb6543fb26bdf666$var$monaco_editor_core_exports, $leKFq);
// src/basic-languages/typescript/typescript.ts
var $bb6543fb26bdf666$export$c83be1687c028fc9 = {
    wordPattern: /(-?\d*\.\d\w*)|([^\`\~\!\@\#\%\^\&\*\(\)\-\=\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g,
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
    onEnterRules: [
        {
            beforeText: /^\s*\/\*\*(?!\/)([^\*]|\*(?!\/))*$/,
            afterText: /^\s*\*\/$/,
            action: {
                indentAction: $bb6543fb26bdf666$var$monaco_editor_core_exports.languages.IndentAction.IndentOutdent,
                appendText: " * "
            }
        },
        {
            beforeText: /^\s*\/\*\*(?!\/)([^\*]|\*(?!\/))*$/,
            action: {
                indentAction: $bb6543fb26bdf666$var$monaco_editor_core_exports.languages.IndentAction.None,
                appendText: " * "
            }
        },
        {
            beforeText: /^(\t|(\ \ ))*\ \*(\ ([^\*]|\*(?!\/))*)?$/,
            action: {
                indentAction: $bb6543fb26bdf666$var$monaco_editor_core_exports.languages.IndentAction.None,
                appendText: "* "
            }
        },
        {
            beforeText: /^(\t|(\ \ ))*\ \*\/\s*$/,
            action: {
                indentAction: $bb6543fb26bdf666$var$monaco_editor_core_exports.languages.IndentAction.None,
                removeText: 1
            }
        }
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
            close: '"',
            notIn: [
                "string"
            ]
        },
        {
            open: "'",
            close: "'",
            notIn: [
                "string",
                "comment"
            ]
        },
        {
            open: "`",
            close: "`",
            notIn: [
                "string",
                "comment"
            ]
        },
        {
            open: "/**",
            close: " */",
            notIn: [
                "string"
            ]
        }
    ],
    folding: {
        markers: {
            start: new RegExp("^\\s*//\\s*#?region\\b"),
            end: new RegExp("^\\s*//\\s*#?endregion\\b")
        }
    }
};
var $bb6543fb26bdf666$export$789c912f57fe164c = {
    defaultToken: "invalid",
    tokenPostfix: ".ts",
    keywords: [
        "abstract",
        "any",
        "as",
        "asserts",
        "bigint",
        "boolean",
        "break",
        "case",
        "catch",
        "class",
        "continue",
        "const",
        "constructor",
        "debugger",
        "declare",
        "default",
        "delete",
        "do",
        "else",
        "enum",
        "export",
        "extends",
        "false",
        "finally",
        "for",
        "from",
        "function",
        "get",
        "if",
        "implements",
        "import",
        "in",
        "infer",
        "instanceof",
        "interface",
        "is",
        "keyof",
        "let",
        "module",
        "namespace",
        "never",
        "new",
        "null",
        "number",
        "object",
        "package",
        "private",
        "protected",
        "public",
        "override",
        "readonly",
        "require",
        "global",
        "return",
        "set",
        "static",
        "string",
        "super",
        "switch",
        "symbol",
        "this",
        "throw",
        "true",
        "try",
        "type",
        "typeof",
        "undefined",
        "unique",
        "unknown",
        "var",
        "void",
        "while",
        "with",
        "yield",
        "async",
        "await",
        "of"
    ],
    operators: [
        "<=",
        ">=",
        "==",
        "!=",
        "===",
        "!==",
        "=>",
        "+",
        "-",
        "**",
        "*",
        "/",
        "%",
        "++",
        "--",
        "<<",
        "</",
        ">>",
        ">>>",
        "&",
        "|",
        "^",
        "!",
        "~",
        "&&",
        "||",
        "??",
        "?",
        ":",
        "=",
        "+=",
        "-=",
        "*=",
        "**=",
        "/=",
        "%=",
        "<<=",
        ">>=",
        ">>>=",
        "&=",
        "|=",
        "^=",
        "@"
    ],
    symbols: /[=><!~?:&|+\-*\/\^%]+/,
    escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
    digits: /\d+(_+\d+)*/,
    octaldigits: /[0-7]+(_+[0-7]+)*/,
    binarydigits: /[0-1]+(_+[0-1]+)*/,
    hexdigits: /[[0-9a-fA-F]+(_+[0-9a-fA-F]+)*/,
    regexpctl: /[(){}\[\]\$\^|\-*+?\.]/,
    regexpesc: /\\(?:[bBdDfnrstvwWn0\\\/]|@regexpctl|c[A-Z]|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4})/,
    tokenizer: {
        root: [
            [
                /[{}]/,
                "delimiter.bracket"
            ],
            {
                include: "common"
            }
        ],
        common: [
            [
                /[a-z_$][\w$]*/,
                {
                    cases: {
                        "@keywords": "keyword",
                        "@default": "identifier"
                    }
                }
            ],
            [
                /[A-Z][\w\$]*/,
                "type.identifier"
            ],
            {
                include: "@whitespace"
            },
            [
                /\/(?=([^\\\/]|\\.)+\/([dgimsuy]*)(\s*)(\.|;|,|\)|\]|\}|$))/,
                {
                    token: "regexp",
                    bracket: "@open",
                    next: "@regexp"
                }
            ],
            [
                /[()\[\]]/,
                "@brackets"
            ],
            [
                /[<>](?!@symbols)/,
                "@brackets"
            ],
            [
                /!(?=([^=]|$))/,
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
                /(@digits)[eE]([\-+]?(@digits))?/,
                "number.float"
            ],
            [
                /(@digits)\.(@digits)([eE][\-+]?(@digits))?/,
                "number.float"
            ],
            [
                /0[xX](@hexdigits)n?/,
                "number.hex"
            ],
            [
                /0[oO]?(@octaldigits)n?/,
                "number.octal"
            ],
            [
                /0[bB](@binarydigits)n?/,
                "number.binary"
            ],
            [
                /(@digits)n?/,
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
                "@string_double"
            ],
            [
                /'/,
                "string",
                "@string_single"
            ],
            [
                /`/,
                "string",
                "@string_backtick"
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
                "@jsdoc"
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
        jsdoc: [
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
        regexp: [
            [
                /(\{)(\d+(?:,\d*)?)(\})/,
                [
                    "regexp.escape.control",
                    "regexp.escape.control",
                    "regexp.escape.control"
                ]
            ],
            [
                /(\[)(\^?)(?=(?:[^\]\\\/]|\\.)+)/,
                [
                    "regexp.escape.control",
                    {
                        token: "regexp.escape.control",
                        next: "@regexrange"
                    }
                ]
            ],
            [
                /(\()(\?:|\?=|\?!)/,
                [
                    "regexp.escape.control",
                    "regexp.escape.control"
                ]
            ],
            [
                /[()]/,
                "regexp.escape.control"
            ],
            [
                /@regexpctl/,
                "regexp.escape.control"
            ],
            [
                /[^\\\/]/,
                "regexp"
            ],
            [
                /@regexpesc/,
                "regexp.escape"
            ],
            [
                /\\\./,
                "regexp.invalid"
            ],
            [
                /(\/)([dgimsuy]*)/,
                [
                    {
                        token: "regexp",
                        bracket: "@close",
                        next: "@pop"
                    },
                    "keyword.other"
                ]
            ]
        ],
        regexrange: [
            [
                /-/,
                "regexp.escape.control"
            ],
            [
                /\^/,
                "regexp.invalid"
            ],
            [
                /@regexpesc/,
                "regexp.escape"
            ],
            [
                /[^\]]/,
                "regexp"
            ],
            [
                /\]/,
                {
                    token: "regexp.escape.control",
                    next: "@pop",
                    bracket: "@close"
                }
            ]
        ],
        string_double: [
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
        string_single: [
            [
                /[^\\']+/,
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
                /'/,
                "string",
                "@pop"
            ]
        ],
        string_backtick: [
            [
                /\$\{/,
                {
                    token: "delimiter.bracket",
                    next: "@bracketCounting"
                }
            ],
            [
                /[^\\`$]+/,
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
                /`/,
                "string",
                "@pop"
            ]
        ],
        bracketCounting: [
            [
                /\{/,
                "delimiter.bracket",
                "@bracketCounting"
            ],
            [
                /\}/,
                "delimiter.bracket",
                "@pop"
            ],
            {
                include: "common"
            }
        ]
    }
};

});


//# sourceMappingURL=typescript.34866cb4.js.map
