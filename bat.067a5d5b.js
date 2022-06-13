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
parcelRequire.register("17Pnp", function(module, exports) {

$parcel$export(module.exports, "conf", () => $0d1e4c3092dcfd42$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $0d1e4c3092dcfd42$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/bat/bat.ts
var $0d1e4c3092dcfd42$export$c83be1687c028fc9 = {
    comments: {
        lineComment: "REM"
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
    folding: {
        markers: {
            start: new RegExp("^\\s*(::\\s*|REM\\s+)#region"),
            end: new RegExp("^\\s*(::\\s*|REM\\s+)#endregion")
        }
    }
};
var $0d1e4c3092dcfd42$export$789c912f57fe164c = {
    defaultToken: "",
    ignoreCase: true,
    tokenPostfix: ".bat",
    brackets: [
        {
            token: "delimiter.bracket",
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
        }
    ],
    keywords: /call|defined|echo|errorlevel|exist|for|goto|if|pause|set|shift|start|title|not|pushd|popd/,
    symbols: /[=><!~?&|+\-*\/\^;\.,]+/,
    escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
    tokenizer: {
        root: [
            [
                /^(\s*)(rem(?:\s.*|))$/,
                [
                    "",
                    "comment"
                ]
            ],
            [
                /(\@?)(@keywords)(?!\w)/,
                [
                    {
                        token: "keyword"
                    },
                    {
                        token: "keyword.$2"
                    }
                ]
            ],
            [
                /[ \t\r\n]+/,
                ""
            ],
            [
                /setlocal(?!\w)/,
                "keyword.tag-setlocal"
            ],
            [
                /endlocal(?!\w)/,
                "keyword.tag-setlocal"
            ],
            [
                /[a-zA-Z_]\w*/,
                ""
            ],
            [
                /:\w*/,
                "metatag"
            ],
            [
                /%[^%]+%/,
                "variable"
            ],
            [
                /%%[\w]+(?!\w)/,
                "variable"
            ],
            [
                /[{}()\[\]]/,
                "@brackets"
            ],
            [
                /@symbols/,
                "delimiter"
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
                /\d+/,
                "number"
            ],
            [
                /[;,.]/,
                "delimiter"
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
        string: [
            [
                /[^\\"'%]+/,
                {
                    cases: {
                        "@eos": {
                            token: "string",
                            next: "@popall"
                        },
                        "@default": "string"
                    }
                }
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
                /%[\w ]+%/,
                "variable"
            ],
            [
                /%%[\w]+(?!\w)/,
                "variable"
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
            ],
            [
                /$/,
                "string",
                "@popall"
            ]
        ]
    }
};

});


//# sourceMappingURL=bat.067a5d5b.js.map
