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
parcelRequire.register("7cfTk", function(module, exports) {

$parcel$export(module.exports, "conf", () => $53d5fb12bf1aca93$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $53d5fb12bf1aca93$export$789c912f57fe164c);

var $leKFq = parcelRequire("leKFq");
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ var $53d5fb12bf1aca93$var$__defProp = Object.defineProperty;
var $53d5fb12bf1aca93$var$__getOwnPropDesc = Object.getOwnPropertyDescriptor;
var $53d5fb12bf1aca93$var$__getOwnPropNames = Object.getOwnPropertyNames;
var $53d5fb12bf1aca93$var$__hasOwnProp = Object.prototype.hasOwnProperty;
var $53d5fb12bf1aca93$var$__markAsModule = (target)=>$53d5fb12bf1aca93$var$__defProp(target, "__esModule", {
        value: true
    })
;
var $53d5fb12bf1aca93$var$__reExport = (target, module, desc)=>{
    if (module && typeof module === "object" || typeof module === "function") {
        for (let key of $53d5fb12bf1aca93$var$__getOwnPropNames(module))if (!$53d5fb12bf1aca93$var$__hasOwnProp.call(target, key) && key !== "default") $53d5fb12bf1aca93$var$__defProp(target, key, {
            get: ()=>module[key]
            ,
            enumerable: !(desc = $53d5fb12bf1aca93$var$__getOwnPropDesc(module, key)) || desc.enumerable
        });
    }
    return target;
};
// src/fillers/monaco-editor-core.ts
var $53d5fb12bf1aca93$var$monaco_editor_core_exports = {};
$53d5fb12bf1aca93$var$__markAsModule($53d5fb12bf1aca93$var$monaco_editor_core_exports);
$53d5fb12bf1aca93$var$__reExport($53d5fb12bf1aca93$var$monaco_editor_core_exports, $leKFq);
// src/basic-languages/python/python.ts
var $53d5fb12bf1aca93$export$c83be1687c028fc9 = {
    comments: {
        lineComment: "#",
        blockComment: [
            "'''",
            "'''"
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
    onEnterRules: [
        {
            beforeText: new RegExp("^\\s*(?:def|class|for|if|elif|else|while|try|with|finally|except|async).*?:\\s*$"),
            action: {
                indentAction: $53d5fb12bf1aca93$var$monaco_editor_core_exports.languages.IndentAction.Indent
            }
        }
    ],
    folding: {
        offSide: true,
        markers: {
            start: new RegExp("^\\s*#region\\b"),
            end: new RegExp("^\\s*#endregion\\b")
        }
    }
};
var $53d5fb12bf1aca93$export$789c912f57fe164c = {
    defaultToken: "",
    tokenPostfix: ".python",
    keywords: [
        "False",
        "None",
        "True",
        "and",
        "as",
        "assert",
        "async",
        "await",
        "break",
        "class",
        "continue",
        "def",
        "del",
        "elif",
        "else",
        "except",
        "exec",
        "finally",
        "for",
        "from",
        "global",
        "if",
        "import",
        "in",
        "is",
        "lambda",
        "nonlocal",
        "not",
        "or",
        "pass",
        "print",
        "raise",
        "return",
        "try",
        "while",
        "with",
        "yield",
        "int",
        "float",
        "long",
        "complex",
        "hex",
        "abs",
        "all",
        "any",
        "apply",
        "basestring",
        "bin",
        "bool",
        "buffer",
        "bytearray",
        "callable",
        "chr",
        "classmethod",
        "cmp",
        "coerce",
        "compile",
        "complex",
        "delattr",
        "dict",
        "dir",
        "divmod",
        "enumerate",
        "eval",
        "execfile",
        "file",
        "filter",
        "format",
        "frozenset",
        "getattr",
        "globals",
        "hasattr",
        "hash",
        "help",
        "id",
        "input",
        "intern",
        "isinstance",
        "issubclass",
        "iter",
        "len",
        "locals",
        "list",
        "map",
        "max",
        "memoryview",
        "min",
        "next",
        "object",
        "oct",
        "open",
        "ord",
        "pow",
        "print",
        "property",
        "reversed",
        "range",
        "raw_input",
        "reduce",
        "reload",
        "repr",
        "reversed",
        "round",
        "self",
        "set",
        "setattr",
        "slice",
        "sorted",
        "staticmethod",
        "str",
        "sum",
        "super",
        "tuple",
        "type",
        "unichr",
        "unicode",
        "vars",
        "xrange",
        "zip",
        "__dict__",
        "__methods__",
        "__members__",
        "__class__",
        "__bases__",
        "__name__",
        "__mro__",
        "__subclasses__",
        "__init__",
        "__import__"
    ],
    brackets: [
        {
            open: "{",
            close: "}",
            token: "delimiter.curly"
        },
        {
            open: "[",
            close: "]",
            token: "delimiter.bracket"
        },
        {
            open: "(",
            close: ")",
            token: "delimiter.parenthesis"
        }
    ],
    tokenizer: {
        root: [
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
                /[{}\[\]()]/,
                "@brackets"
            ],
            [
                /@[a-zA-Z_]\w*/,
                "tag"
            ],
            [
                /[a-zA-Z_]\w*/,
                {
                    cases: {
                        "@keywords": "keyword",
                        "@default": "identifier"
                    }
                }
            ]
        ],
        whitespace: [
            [
                /\s+/,
                "white"
            ],
            [
                /(^#.*$)/,
                "comment"
            ],
            [
                /'''/,
                "string",
                "@endDocString"
            ],
            [
                /"""/,
                "string",
                "@endDblDocString"
            ]
        ],
        endDocString: [
            [
                /[^']+/,
                "string"
            ],
            [
                /\\'/,
                "string"
            ],
            [
                /'''/,
                "string",
                "@popall"
            ],
            [
                /'/,
                "string"
            ]
        ],
        endDblDocString: [
            [
                /[^"]+/,
                "string"
            ],
            [
                /\\"/,
                "string"
            ],
            [
                /"""/,
                "string",
                "@popall"
            ],
            [
                /"/,
                "string"
            ]
        ],
        numbers: [
            [
                /-?0x([abcdef]|[ABCDEF]|\d)+[lL]?/,
                "number.hex"
            ],
            [
                /-?(\d*\.)?\d+([eE][+\-]?\d+)?[jJ]?[lL]?/,
                "number"
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


//# sourceMappingURL=python.1e0661d2.js.map
