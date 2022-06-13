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
parcelRequire.register("fEFwS", function(module, exports) {

$parcel$export(module.exports, "conf", () => $b65ace48625d0237$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $b65ace48625d0237$export$789c912f57fe164c);

var $leKFq = parcelRequire("leKFq");
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ var $b65ace48625d0237$var$__defProp = Object.defineProperty;
var $b65ace48625d0237$var$__getOwnPropDesc = Object.getOwnPropertyDescriptor;
var $b65ace48625d0237$var$__getOwnPropNames = Object.getOwnPropertyNames;
var $b65ace48625d0237$var$__hasOwnProp = Object.prototype.hasOwnProperty;
var $b65ace48625d0237$var$__markAsModule = (target)=>$b65ace48625d0237$var$__defProp(target, "__esModule", {
        value: true
    })
;
var $b65ace48625d0237$var$__reExport = (target, module, desc)=>{
    if (module && typeof module === "object" || typeof module === "function") {
        for (let key of $b65ace48625d0237$var$__getOwnPropNames(module))if (!$b65ace48625d0237$var$__hasOwnProp.call(target, key) && key !== "default") $b65ace48625d0237$var$__defProp(target, key, {
            get: ()=>module[key]
            ,
            enumerable: !(desc = $b65ace48625d0237$var$__getOwnPropDesc(module, key)) || desc.enumerable
        });
    }
    return target;
};
// src/fillers/monaco-editor-core.ts
var $b65ace48625d0237$var$monaco_editor_core_exports = {};
$b65ace48625d0237$var$__markAsModule($b65ace48625d0237$var$monaco_editor_core_exports);
$b65ace48625d0237$var$__reExport($b65ace48625d0237$var$monaco_editor_core_exports, $leKFq);
// src/basic-languages/xml/xml.ts
var $b65ace48625d0237$export$c83be1687c028fc9 = {
    comments: {
        blockComment: [
            "<!--",
            "-->"
        ]
    },
    brackets: [
        [
            "<",
            ">"
        ]
    ],
    autoClosingPairs: [
        {
            open: "<",
            close: ">"
        },
        {
            open: "'",
            close: "'"
        },
        {
            open: '"',
            close: '"'
        }
    ],
    surroundingPairs: [
        {
            open: "<",
            close: ">"
        },
        {
            open: "'",
            close: "'"
        },
        {
            open: '"',
            close: '"'
        }
    ],
    onEnterRules: [
        {
            beforeText: new RegExp(`<([_:\\w][_:\\w-.\\d]*)([^/>]*(?!/)>)[^<]*$`, "i"),
            afterText: /^<\/([_:\w][_:\w-.\d]*)\s*>$/i,
            action: {
                indentAction: $b65ace48625d0237$var$monaco_editor_core_exports.languages.IndentAction.IndentOutdent
            }
        },
        {
            beforeText: new RegExp(`<(\\w[\\w\\d]*)([^/>]*(?!/)>)[^<]*$`, "i"),
            action: {
                indentAction: $b65ace48625d0237$var$monaco_editor_core_exports.languages.IndentAction.Indent
            }
        }
    ]
};
var $b65ace48625d0237$export$789c912f57fe164c = {
    defaultToken: "",
    tokenPostfix: ".xml",
    ignoreCase: true,
    qualifiedName: /(?:[\w\.\-]+:)?[\w\.\-]+/,
    tokenizer: {
        root: [
            [
                /[^<&]+/,
                ""
            ],
            {
                include: "@whitespace"
            },
            [
                /(<)(@qualifiedName)/,
                [
                    {
                        token: "delimiter"
                    },
                    {
                        token: "tag",
                        next: "@tag"
                    }
                ]
            ],
            [
                /(<\/)(@qualifiedName)(\s*)(>)/,
                [
                    {
                        token: "delimiter"
                    },
                    {
                        token: "tag"
                    },
                    "",
                    {
                        token: "delimiter"
                    }
                ]
            ],
            [
                /(<\?)(@qualifiedName)/,
                [
                    {
                        token: "delimiter"
                    },
                    {
                        token: "metatag",
                        next: "@tag"
                    }
                ]
            ],
            [
                /(<\!)(@qualifiedName)/,
                [
                    {
                        token: "delimiter"
                    },
                    {
                        token: "metatag",
                        next: "@tag"
                    }
                ]
            ],
            [
                /<\!\[CDATA\[/,
                {
                    token: "delimiter.cdata",
                    next: "@cdata"
                }
            ],
            [
                /&\w+;/,
                "string.escape"
            ]
        ],
        cdata: [
            [
                /[^\]]+/,
                ""
            ],
            [
                /\]\]>/,
                {
                    token: "delimiter.cdata",
                    next: "@pop"
                }
            ],
            [
                /\]/,
                ""
            ]
        ],
        tag: [
            [
                /[ \t\r\n]+/,
                ""
            ],
            [
                /(@qualifiedName)(\s*=\s*)("[^"]*"|'[^']*')/,
                [
                    "attribute.name",
                    "",
                    "attribute.value"
                ]
            ],
            [
                /(@qualifiedName)(\s*=\s*)("[^">?\/]*|'[^'>?\/]*)(?=[\?\/]\>)/,
                [
                    "attribute.name",
                    "",
                    "attribute.value"
                ]
            ],
            [
                /(@qualifiedName)(\s*=\s*)("[^">]*|'[^'>]*)/,
                [
                    "attribute.name",
                    "",
                    "attribute.value"
                ]
            ],
            [
                /@qualifiedName/,
                "attribute.name"
            ],
            [
                /\?>/,
                {
                    token: "delimiter",
                    next: "@pop"
                }
            ],
            [
                /(\/)(>)/,
                [
                    {
                        token: "tag"
                    },
                    {
                        token: "delimiter",
                        next: "@pop"
                    }
                ]
            ],
            [
                />/,
                {
                    token: "delimiter",
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
                /<!--/,
                {
                    token: "comment",
                    next: "@comment"
                }
            ]
        ],
        comment: [
            [
                /[^<\-]+/,
                "comment.content"
            ],
            [
                /-->/,
                {
                    token: "comment",
                    next: "@pop"
                }
            ],
            [
                /<!--/,
                "comment.content.invalid"
            ],
            [
                /[<\-]/,
                "comment.content"
            ]
        ]
    }
};

});


//# sourceMappingURL=xml.f64977cb.js.map
