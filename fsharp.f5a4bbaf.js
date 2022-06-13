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
parcelRequire.register("2SoAN", function(module, exports) {

$parcel$export(module.exports, "conf", () => $2183b37f17dbaf97$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $2183b37f17dbaf97$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/fsharp/fsharp.ts
var $2183b37f17dbaf97$export$c83be1687c028fc9 = {
    comments: {
        lineComment: "//",
        blockComment: [
            "(*",
            "*)"
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
            start: new RegExp("^\\s*//\\s*#region\\b|^\\s*\\(\\*\\s*#region(.*)\\*\\)"),
            end: new RegExp("^\\s*//\\s*#endregion\\b|^\\s*\\(\\*\\s*#endregion\\s*\\*\\)")
        }
    }
};
var $2183b37f17dbaf97$export$789c912f57fe164c = {
    defaultToken: "",
    tokenPostfix: ".fs",
    keywords: [
        "abstract",
        "and",
        "atomic",
        "as",
        "assert",
        "asr",
        "base",
        "begin",
        "break",
        "checked",
        "component",
        "const",
        "constraint",
        "constructor",
        "continue",
        "class",
        "default",
        "delegate",
        "do",
        "done",
        "downcast",
        "downto",
        "elif",
        "else",
        "end",
        "exception",
        "eager",
        "event",
        "external",
        "extern",
        "false",
        "finally",
        "for",
        "fun",
        "function",
        "fixed",
        "functor",
        "global",
        "if",
        "in",
        "include",
        "inherit",
        "inline",
        "interface",
        "internal",
        "land",
        "lor",
        "lsl",
        "lsr",
        "lxor",
        "lazy",
        "let",
        "match",
        "member",
        "mod",
        "module",
        "mutable",
        "namespace",
        "method",
        "mixin",
        "new",
        "not",
        "null",
        "of",
        "open",
        "or",
        "object",
        "override",
        "private",
        "parallel",
        "process",
        "protected",
        "pure",
        "public",
        "rec",
        "return",
        "static",
        "sealed",
        "struct",
        "sig",
        "then",
        "to",
        "true",
        "tailcall",
        "trait",
        "try",
        "type",
        "upcast",
        "use",
        "val",
        "void",
        "virtual",
        "volatile",
        "when",
        "while",
        "with",
        "yield"
    ],
    symbols: /[=><!~?:&|+\-*\^%;\.,\/]+/,
    escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
    integersuffix: /[uU]?[yslnLI]?/,
    floatsuffix: /[fFmM]?/,
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
                /\[<.*>\]/,
                "annotation"
            ],
            [
                /^#(if|else|endif)/,
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
                "delimiter"
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
                /0x[0-9a-fA-F]+LF/,
                "number.float"
            ],
            [
                /0x[0-9a-fA-F]+(@integersuffix)/,
                "number.hex"
            ],
            [
                /0b[0-1]+(@integersuffix)/,
                "number.bin"
            ],
            [
                /\d+(@integersuffix)/,
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
                /"""/,
                "string",
                '@string."""'
            ],
            [
                /"/,
                "string",
                '@string."'
            ],
            [
                /\@"/,
                {
                    token: "string.quote",
                    next: "@litstring"
                }
            ],
            [
                /'[^\\']'B?/,
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
                /\(\*(?!\))/,
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
                /[^*(]+/,
                "comment"
            ],
            [
                /\*\)/,
                "comment",
                "@pop"
            ],
            [
                /\*/,
                "comment"
            ],
            [
                /\(\*\)/,
                "comment"
            ],
            [
                /\(/,
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
                /("""|"B?)/,
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
        ],
        litstring: [
            [
                /[^"]+/,
                "string"
            ],
            [
                /""/,
                "string.escape"
            ],
            [
                /"/,
                {
                    token: "string.quote",
                    next: "@pop"
                }
            ]
        ]
    }
};

});


//# sourceMappingURL=fsharp.f5a4bbaf.js.map
