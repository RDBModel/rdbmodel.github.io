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
parcelRequire.register("8cNXv", function(module, exports) {

$parcel$export(module.exports, "conf", () => $5f9632834d1b25ca$export$c83be1687c028fc9);
$parcel$export(module.exports, "language", () => $5f9632834d1b25ca$export$789c912f57fe164c);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/azcli/azcli.ts
var $5f9632834d1b25ca$export$c83be1687c028fc9 = {
    comments: {
        lineComment: "#"
    }
};
var $5f9632834d1b25ca$export$789c912f57fe164c = {
    defaultToken: "keyword",
    ignoreCase: true,
    tokenPostfix: ".azcli",
    str: /[^#\s]/,
    tokenizer: {
        root: [
            {
                include: "@comment"
            },
            [
                /\s-+@str*\s*/,
                {
                    cases: {
                        "@eos": {
                            token: "key.identifier",
                            next: "@popall"
                        },
                        "@default": {
                            token: "key.identifier",
                            next: "@type"
                        }
                    }
                }
            ],
            [
                /^-+@str*\s*/,
                {
                    cases: {
                        "@eos": {
                            token: "key.identifier",
                            next: "@popall"
                        },
                        "@default": {
                            token: "key.identifier",
                            next: "@type"
                        }
                    }
                }
            ]
        ],
        type: [
            {
                include: "@comment"
            },
            [
                /-+@str*\s*/,
                {
                    cases: {
                        "@eos": {
                            token: "key.identifier",
                            next: "@popall"
                        },
                        "@default": "key.identifier"
                    }
                }
            ],
            [
                /@str+\s*/,
                {
                    cases: {
                        "@eos": {
                            token: "string",
                            next: "@popall"
                        },
                        "@default": "string"
                    }
                }
            ]
        ],
        comment: [
            [
                /#.*$/,
                {
                    cases: {
                        "@eos": {
                            token: "comment",
                            next: "@popall"
                        }
                    }
                }
            ]
        ]
    }
};

});


//# sourceMappingURL=azcli.fd845922.js.map
