// modules are defined as an array
// [ module function, map of requires ]
//
// map of requires is short require name -> numeric require
//
// anything defined in a previous bundle is accessed via the
// orig method which is the require for previous bundles

(function (modules, entry, mainEntry, parcelRequireName, globalName) {
  /* eslint-disable no-undef */
  var globalObject =
    typeof globalThis !== 'undefined'
      ? globalThis
      : typeof self !== 'undefined'
      ? self
      : typeof window !== 'undefined'
      ? window
      : typeof global !== 'undefined'
      ? global
      : {};
  /* eslint-enable no-undef */

  // Save the require from previous bundle to this closure if any
  var previousRequire =
    typeof globalObject[parcelRequireName] === 'function' &&
    globalObject[parcelRequireName];

  var cache = previousRequire.cache || {};
  // Do not use `require` to prevent Webpack from trying to bundle this call
  var nodeRequire =
    typeof module !== 'undefined' &&
    typeof module.require === 'function' &&
    module.require.bind(module);

  function newRequire(name, jumped) {
    if (!cache[name]) {
      if (!modules[name]) {
        // if we cannot find the module within our internal map or
        // cache jump to the current global require ie. the last bundle
        // that was added to the page.
        var currentRequire =
          typeof globalObject[parcelRequireName] === 'function' &&
          globalObject[parcelRequireName];
        if (!jumped && currentRequire) {
          return currentRequire(name, true);
        }

        // If there are other bundles on this page the require from the
        // previous one is saved to 'previousRequire'. Repeat this as
        // many times as there are bundles until the module is found or
        // we exhaust the require chain.
        if (previousRequire) {
          return previousRequire(name, true);
        }

        // Try the node require function if it exists.
        if (nodeRequire && typeof name === 'string') {
          return nodeRequire(name);
        }

        var err = new Error("Cannot find module '" + name + "'");
        err.code = 'MODULE_NOT_FOUND';
        throw err;
      }

      localRequire.resolve = resolve;
      localRequire.cache = {};

      var module = (cache[name] = new newRequire.Module(name));

      modules[name][0].call(
        module.exports,
        localRequire,
        module,
        module.exports,
        this
      );
    }

    return cache[name].exports;

    function localRequire(x) {
      var res = localRequire.resolve(x);
      return res === false ? {} : newRequire(res);
    }

    function resolve(x) {
      var id = modules[name][1][x];
      return id != null ? id : x;
    }
  }

  function Module(moduleName) {
    this.id = moduleName;
    this.bundle = newRequire;
    this.exports = {};
  }

  newRequire.isParcelRequire = true;
  newRequire.Module = Module;
  newRequire.modules = modules;
  newRequire.cache = cache;
  newRequire.parent = previousRequire;
  newRequire.register = function (id, exports) {
    modules[id] = [
      function (require, module) {
        module.exports = exports;
      },
      {},
    ];
  };

  Object.defineProperty(newRequire, 'root', {
    get: function () {
      return globalObject[parcelRequireName];
    },
  });

  globalObject[parcelRequireName] = newRequire;

  for (var i = 0; i < entry.length; i++) {
    newRequire(entry[i]);
  }

  if (mainEntry) {
    // Expose entry point to Node, AMD or browser globals
    // Based on https://github.com/ForbesLindesay/umd/blob/master/template.js
    var mainExports = newRequire(mainEntry);

    // CommonJS
    if (typeof exports === 'object' && typeof module !== 'undefined') {
      module.exports = mainExports;

      // RequireJS
    } else if (typeof define === 'function' && define.amd) {
      define(function () {
        return mainExports;
      });

      // <script>
    } else if (globalName) {
      this[globalName] = mainExports;
    }
  }
})({"6EyLb":[function(require,module,exports) {
"use strict";
var HMR_HOST = null;
var HMR_PORT = null;
var HMR_SECURE = false;
var HMR_ENV_HASH = "d6ea1d42532a7575";
module.bundle.HMR_BUNDLE_ID = "848662b65006b305";
function _toConsumableArray(arr) {
    return _arrayWithoutHoles(arr) || _iterableToArray(arr) || _unsupportedIterableToArray(arr) || _nonIterableSpread();
}
function _nonIterableSpread() {
    throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
}
function _iterableToArray(iter) {
    if (typeof Symbol !== "undefined" && iter[Symbol.iterator] != null || iter["@@iterator"] != null) return Array.from(iter);
}
function _arrayWithoutHoles(arr) {
    if (Array.isArray(arr)) return _arrayLikeToArray(arr);
}
function _createForOfIteratorHelper(o, allowArrayLike) {
    var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"];
    if (!it) {
        if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") {
            if (it) o = it;
            var i = 0;
            var F = function F() {};
            return {
                s: F,
                n: function n() {
                    if (i >= o.length) return {
                        done: true
                    };
                    return {
                        done: false,
                        value: o[i++]
                    };
                },
                e: function e(_e) {
                    throw _e;
                },
                f: F
            };
        }
        throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
    }
    var normalCompletion = true, didErr = false, err;
    return {
        s: function s() {
            it = it.call(o);
        },
        n: function n() {
            var step = it.next();
            normalCompletion = step.done;
            return step;
        },
        e: function e(_e2) {
            didErr = true;
            err = _e2;
        },
        f: function f() {
            try {
                if (!normalCompletion && it.return != null) it.return();
            } finally{
                if (didErr) throw err;
            }
        }
    };
}
function _unsupportedIterableToArray(o, minLen) {
    if (!o) return;
    if (typeof o === "string") return _arrayLikeToArray(o, minLen);
    var n = Object.prototype.toString.call(o).slice(8, -1);
    if (n === "Object" && o.constructor) n = o.constructor.name;
    if (n === "Map" || n === "Set") return Array.from(o);
    if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen);
}
function _arrayLikeToArray(arr, len) {
    if (len == null || len > arr.length) len = arr.length;
    for(var i = 0, arr2 = new Array(len); i < len; i++)arr2[i] = arr[i];
    return arr2;
}
/* global HMR_HOST, HMR_PORT, HMR_ENV_HASH, HMR_SECURE */ /*::
import type {
  HMRAsset,
  HMRMessage,
} from '@parcel/reporter-dev-server/src/HMRServer.js';
interface ParcelRequire {
  (string): mixed;
  cache: {|[string]: ParcelModule|};
  hotData: mixed;
  Module: any;
  parent: ?ParcelRequire;
  isParcelRequire: true;
  modules: {|[string]: [Function, {|[string]: string|}]|};
  HMR_BUNDLE_ID: string;
  root: ParcelRequire;
}
interface ParcelModule {
  hot: {|
    data: mixed,
    accept(cb: (Function) => void): void,
    dispose(cb: (mixed) => void): void,
    // accept(deps: Array<string> | string, cb: (Function) => void): void,
    // decline(): void,
    _acceptCallbacks: Array<(Function) => void>,
    _disposeCallbacks: Array<(mixed) => void>,
  |};
}
declare var module: {bundle: ParcelRequire, ...};
declare var HMR_HOST: string;
declare var HMR_PORT: string;
declare var HMR_ENV_HASH: string;
declare var HMR_SECURE: boolean;
*/ var OVERLAY_ID = '__parcel__error__overlay__';
var OldModule = module.bundle.Module;
function Module(moduleName) {
    OldModule.call(this, moduleName);
    this.hot = {
        data: module.bundle.hotData,
        _acceptCallbacks: [],
        _disposeCallbacks: [],
        accept: function accept(fn) {
            this._acceptCallbacks.push(fn || function() {});
        },
        dispose: function dispose(fn) {
            this._disposeCallbacks.push(fn);
        }
    };
    module.bundle.hotData = undefined;
}
module.bundle.Module = Module;
var checkedAssets, acceptedAssets, assetsToAccept /*: Array<[ParcelRequire, string]> */ ;
function getHostname() {
    return HMR_HOST || (location.protocol.indexOf('http') === 0 ? location.hostname : 'localhost');
}
function getPort() {
    return HMR_PORT || location.port;
} // eslint-disable-next-line no-redeclare
var parent = module.bundle.parent;
if ((!parent || !parent.isParcelRequire) && typeof WebSocket !== 'undefined') {
    var hostname = getHostname();
    var port = getPort();
    var protocol = HMR_SECURE || location.protocol == 'https:' && !/localhost|127.0.0.1|0.0.0.0/.test(hostname) ? 'wss' : 'ws';
    var ws = new WebSocket(protocol + '://' + hostname + (port ? ':' + port : '') + '/'); // $FlowFixMe
    ws.onmessage = function(event) {
        checkedAssets = {} /*: {|[string]: boolean|} */ ;
        acceptedAssets = {} /*: {|[string]: boolean|} */ ;
        assetsToAccept = [];
        var data = JSON.parse(event.data);
        if (data.type === 'update') {
            // Remove error overlay if there is one
            if (typeof document !== 'undefined') removeErrorOverlay();
            var assets = data.assets.filter(function(asset) {
                return asset.envHash === HMR_ENV_HASH;
            }); // Handle HMR Update
            var handled = assets.every(function(asset) {
                return asset.type === 'css' || asset.type === 'js' && hmrAcceptCheck(module.bundle.root, asset.id, asset.depsByBundle);
            });
            if (handled) {
                console.clear();
                assets.forEach(function(asset) {
                    hmrApply(module.bundle.root, asset);
                });
                for(var i = 0; i < assetsToAccept.length; i++){
                    var id = assetsToAccept[i][1];
                    if (!acceptedAssets[id]) hmrAcceptRun(assetsToAccept[i][0], id);
                }
            } else window.location.reload();
        }
        if (data.type === 'error') {
            // Log parcel errors to console
            var _iterator = _createForOfIteratorHelper(data.diagnostics.ansi), _step;
            try {
                for(_iterator.s(); !(_step = _iterator.n()).done;){
                    var ansiDiagnostic = _step.value;
                    var stack = ansiDiagnostic.codeframe ? ansiDiagnostic.codeframe : ansiDiagnostic.stack;
                    console.error('🚨 [parcel]: ' + ansiDiagnostic.message + '\n' + stack + '\n\n' + ansiDiagnostic.hints.join('\n'));
                }
            } catch (err) {
                _iterator.e(err);
            } finally{
                _iterator.f();
            }
            if (typeof document !== 'undefined') {
                // Render the fancy html overlay
                removeErrorOverlay();
                var overlay = createErrorOverlay(data.diagnostics.html); // $FlowFixMe
                document.body.appendChild(overlay);
            }
        }
    };
    ws.onerror = function(e) {
        console.error(e.message);
    };
    ws.onclose = function() {
        console.warn('[parcel] 🚨 Connection to the HMR server was lost');
    };
}
function removeErrorOverlay() {
    var overlay = document.getElementById(OVERLAY_ID);
    if (overlay) {
        overlay.remove();
        console.log('[parcel] ✨ Error resolved');
    }
}
function createErrorOverlay(diagnostics) {
    var overlay = document.createElement('div');
    overlay.id = OVERLAY_ID;
    var errorHTML = '<div style="background: black; opacity: 0.85; font-size: 16px; color: white; position: fixed; height: 100%; width: 100%; top: 0px; left: 0px; padding: 30px; font-family: Menlo, Consolas, monospace; z-index: 9999;">';
    var _iterator2 = _createForOfIteratorHelper(diagnostics), _step2;
    try {
        for(_iterator2.s(); !(_step2 = _iterator2.n()).done;){
            var diagnostic = _step2.value;
            var stack = diagnostic.codeframe ? diagnostic.codeframe : diagnostic.stack;
            errorHTML += "\n      <div>\n        <div style=\"font-size: 18px; font-weight: bold; margin-top: 20px;\">\n          \uD83D\uDEA8 ".concat(diagnostic.message, "\n        </div>\n        <pre>").concat(stack, "</pre>\n        <div>\n          ").concat(diagnostic.hints.map(function(hint) {
                return '<div>💡 ' + hint + '</div>';
            }).join(''), "\n        </div>\n        ").concat(diagnostic.documentation ? "<div>\uD83D\uDCDD <a style=\"color: violet\" href=\"".concat(diagnostic.documentation, "\" target=\"_blank\">Learn more</a></div>") : '', "\n      </div>\n    ");
        }
    } catch (err) {
        _iterator2.e(err);
    } finally{
        _iterator2.f();
    }
    errorHTML += '</div>';
    overlay.innerHTML = errorHTML;
    return overlay;
}
function getParents(bundle, id) /*: Array<[ParcelRequire, string]> */ {
    var modules = bundle.modules;
    if (!modules) return [];
    var parents = [];
    var k, d, dep;
    for(k in modules)for(d in modules[k][1]){
        dep = modules[k][1][d];
        if (dep === id || Array.isArray(dep) && dep[dep.length - 1] === id) parents.push([
            bundle,
            k
        ]);
    }
    if (bundle.parent) parents = parents.concat(getParents(bundle.parent, id));
    return parents;
}
function updateLink(link) {
    var newLink = link.cloneNode();
    newLink.onload = function() {
        if (link.parentNode !== null) // $FlowFixMe
        link.parentNode.removeChild(link);
    };
    newLink.setAttribute('href', link.getAttribute('href').split('?')[0] + '?' + Date.now()); // $FlowFixMe
    link.parentNode.insertBefore(newLink, link.nextSibling);
}
var cssTimeout = null;
function reloadCSS() {
    if (cssTimeout) return;
    cssTimeout = setTimeout(function() {
        var links = document.querySelectorAll('link[rel="stylesheet"]');
        for(var i = 0; i < links.length; i++){
            // $FlowFixMe[incompatible-type]
            var href = links[i].getAttribute('href');
            var hostname = getHostname();
            var servedFromHMRServer = hostname === 'localhost' ? new RegExp('^(https?:\\/\\/(0.0.0.0|127.0.0.1)|localhost):' + getPort()).test(href) : href.indexOf(hostname + ':' + getPort());
            var absolute = /^https?:\/\//i.test(href) && href.indexOf(window.location.origin) !== 0 && !servedFromHMRServer;
            if (!absolute) updateLink(links[i]);
        }
        cssTimeout = null;
    }, 50);
}
function hmrApply(bundle, asset) {
    var modules = bundle.modules;
    if (!modules) return;
    if (asset.type === 'css') reloadCSS();
    else if (asset.type === 'js') {
        var deps = asset.depsByBundle[bundle.HMR_BUNDLE_ID];
        if (deps) {
            if (modules[asset.id]) {
                // Remove dependencies that are removed and will become orphaned.
                // This is necessary so that if the asset is added back again, the cache is gone, and we prevent a full page reload.
                var oldDeps = modules[asset.id][1];
                for(var dep in oldDeps)if (!deps[dep] || deps[dep] !== oldDeps[dep]) {
                    var id = oldDeps[dep];
                    var parents = getParents(module.bundle.root, id);
                    if (parents.length === 1) hmrDelete(module.bundle.root, id);
                }
            }
            var fn = new Function('require', 'module', 'exports', asset.output);
            modules[asset.id] = [
                fn,
                deps
            ];
        } else if (bundle.parent) hmrApply(bundle.parent, asset);
    }
}
function hmrDelete(bundle, id1) {
    var modules = bundle.modules;
    if (!modules) return;
    if (modules[id1]) {
        // Collect dependencies that will become orphaned when this module is deleted.
        var deps = modules[id1][1];
        var orphans = [];
        for(var dep in deps){
            var parents = getParents(module.bundle.root, deps[dep]);
            if (parents.length === 1) orphans.push(deps[dep]);
        } // Delete the module. This must be done before deleting dependencies in case of circular dependencies.
        delete modules[id1];
        delete bundle.cache[id1]; // Now delete the orphans.
        orphans.forEach(function(id) {
            hmrDelete(module.bundle.root, id);
        });
    } else if (bundle.parent) hmrDelete(bundle.parent, id1);
}
function hmrAcceptCheck(bundle, id, depsByBundle) {
    if (hmrAcceptCheckOne(bundle, id, depsByBundle)) return true;
     // Traverse parents breadth first. All possible ancestries must accept the HMR update, or we'll reload.
    var parents = getParents(module.bundle.root, id);
    var accepted = false;
    while(parents.length > 0){
        var v = parents.shift();
        var a = hmrAcceptCheckOne(v[0], v[1], null);
        if (a) // If this parent accepts, stop traversing upward, but still consider siblings.
        accepted = true;
        else {
            // Otherwise, queue the parents in the next level upward.
            var p = getParents(module.bundle.root, v[1]);
            if (p.length === 0) {
                // If there are no parents, then we've reached an entry without accepting. Reload.
                accepted = false;
                break;
            }
            parents.push.apply(parents, _toConsumableArray(p));
        }
    }
    return accepted;
}
function hmrAcceptCheckOne(bundle, id, depsByBundle) {
    var modules = bundle.modules;
    if (!modules) return;
    if (depsByBundle && !depsByBundle[bundle.HMR_BUNDLE_ID]) {
        // If we reached the root bundle without finding where the asset should go,
        // there's nothing to do. Mark as "accepted" so we don't reload the page.
        if (!bundle.parent) return true;
        return hmrAcceptCheck(bundle.parent, id, depsByBundle);
    }
    if (checkedAssets[id]) return true;
    checkedAssets[id] = true;
    var cached = bundle.cache[id];
    assetsToAccept.push([
        bundle,
        id
    ]);
    if (!cached || cached.hot && cached.hot._acceptCallbacks.length) return true;
}
function hmrAcceptRun(bundle, id) {
    var cached = bundle.cache[id];
    bundle.hotData = {};
    if (cached && cached.hot) cached.hot.data = bundle.hotData;
    if (cached && cached.hot && cached.hot._disposeCallbacks.length) cached.hot._disposeCallbacks.forEach(function(cb) {
        cb(bundle.hotData);
    });
    delete bundle.cache[id];
    bundle(id);
    cached = bundle.cache[id];
    if (cached && cached.hot && cached.hot._acceptCallbacks.length) cached.hot._acceptCallbacks.forEach(function(cb) {
        var assetsToAlsoAccept = cb(function() {
            return getParents(module.bundle.root, id);
        });
        if (assetsToAlsoAccept && assetsToAccept.length) // $FlowFixMe[method-unbinding]
        assetsToAccept.push.apply(assetsToAccept, assetsToAlsoAccept);
    });
    acceptedAssets[id] = true;
}

},{}],"gCCWc":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
parcelHelpers.export(exports, "conf", ()=>conf
);
parcelHelpers.export(exports, "language", ()=>language
);
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ // src/basic-languages/julia/julia.ts
var conf = {
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
var language = {
    tokenPostfix: ".julia",
    keywords: [
        "begin",
        "while",
        "if",
        "for",
        "try",
        "return",
        "break",
        "continue",
        "function",
        "macro",
        "quote",
        "let",
        "local",
        "global",
        "const",
        "do",
        "struct",
        "module",
        "baremodule",
        "using",
        "import",
        "export",
        "end",
        "else",
        "elseif",
        "catch",
        "finally",
        "mutable",
        "primitive",
        "abstract",
        "type",
        "in",
        "isa",
        "where",
        "new"
    ],
    types: [
        "LinRange",
        "LineNumberNode",
        "LinearIndices",
        "LoadError",
        "MIME",
        "Matrix",
        "Method",
        "MethodError",
        "Missing",
        "MissingException",
        "Module",
        "NTuple",
        "NamedTuple",
        "Nothing",
        "Number",
        "OrdinalRange",
        "OutOfMemoryError",
        "OverflowError",
        "Pair",
        "PartialQuickSort",
        "PermutedDimsArray",
        "Pipe",
        "Ptr",
        "QuoteNode",
        "Rational",
        "RawFD",
        "ReadOnlyMemoryError",
        "Real",
        "ReentrantLock",
        "Ref",
        "Regex",
        "RegexMatch",
        "RoundingMode",
        "SegmentationFault",
        "Set",
        "Signed",
        "Some",
        "StackOverflowError",
        "StepRange",
        "StepRangeLen",
        "StridedArray",
        "StridedMatrix",
        "StridedVecOrMat",
        "StridedVector",
        "String",
        "StringIndexError",
        "SubArray",
        "SubString",
        "SubstitutionString",
        "Symbol",
        "SystemError",
        "Task",
        "Text",
        "TextDisplay",
        "Timer",
        "Tuple",
        "Type",
        "TypeError",
        "TypeVar",
        "UInt",
        "UInt128",
        "UInt16",
        "UInt32",
        "UInt64",
        "UInt8",
        "UndefInitializer",
        "AbstractArray",
        "UndefKeywordError",
        "AbstractChannel",
        "UndefRefError",
        "AbstractChar",
        "UndefVarError",
        "AbstractDict",
        "Union",
        "AbstractDisplay",
        "UnionAll",
        "AbstractFloat",
        "UnitRange",
        "AbstractIrrational",
        "Unsigned",
        "AbstractMatrix",
        "AbstractRange",
        "Val",
        "AbstractSet",
        "Vararg",
        "AbstractString",
        "VecElement",
        "AbstractUnitRange",
        "VecOrMat",
        "AbstractVecOrMat",
        "Vector",
        "AbstractVector",
        "VersionNumber",
        "Any",
        "WeakKeyDict",
        "ArgumentError",
        "WeakRef",
        "Array",
        "AssertionError",
        "BigFloat",
        "BigInt",
        "BitArray",
        "BitMatrix",
        "BitSet",
        "BitVector",
        "Bool",
        "BoundsError",
        "CapturedException",
        "CartesianIndex",
        "CartesianIndices",
        "Cchar",
        "Cdouble",
        "Cfloat",
        "Channel",
        "Char",
        "Cint",
        "Cintmax_t",
        "Clong",
        "Clonglong",
        "Cmd",
        "Colon",
        "Complex",
        "ComplexF16",
        "ComplexF32",
        "ComplexF64",
        "CompositeException",
        "Condition",
        "Cptrdiff_t",
        "Cshort",
        "Csize_t",
        "Cssize_t",
        "Cstring",
        "Cuchar",
        "Cuint",
        "Cuintmax_t",
        "Culong",
        "Culonglong",
        "Cushort",
        "Cvoid",
        "Cwchar_t",
        "Cwstring",
        "DataType",
        "DenseArray",
        "DenseMatrix",
        "DenseVecOrMat",
        "DenseVector",
        "Dict",
        "DimensionMismatch",
        "Dims",
        "DivideError",
        "DomainError",
        "EOFError",
        "Enum",
        "ErrorException",
        "Exception",
        "ExponentialBackOff",
        "Expr",
        "Float16",
        "Float32",
        "Float64",
        "Function",
        "GlobalRef",
        "HTML",
        "IO",
        "IOBuffer",
        "IOContext",
        "IOStream",
        "IdDict",
        "IndexCartesian",
        "IndexLinear",
        "IndexStyle",
        "InexactError",
        "InitError",
        "Int",
        "Int128",
        "Int16",
        "Int32",
        "Int64",
        "Int8",
        "Integer",
        "InterruptException",
        "InvalidStateException",
        "Irrational",
        "KeyError"
    ],
    keywordops: [
        "<:",
        ">:",
        ":",
        "=>",
        "...",
        ".",
        "->",
        "?"
    ],
    allops: /[^\w\d\s()\[\]{}"'#]+/,
    constants: [
        "true",
        "false",
        "nothing",
        "missing",
        "undef",
        "Inf",
        "pi",
        "NaN",
        "\u03C0",
        "\u212F",
        "ans",
        "PROGRAM_FILE",
        "ARGS",
        "C_NULL",
        "VERSION",
        "DEPOT_PATH",
        "LOAD_PATH"
    ],
    operators: [
        "!",
        "!=",
        "!==",
        "%",
        "&",
        "*",
        "+",
        "-",
        "/",
        "//",
        "<",
        "<<",
        "<=",
        "==",
        "===",
        "=>",
        ">",
        ">=",
        ">>",
        ">>>",
        "\\",
        "^",
        "|",
        "|>",
        "~",
        "\xF7",
        "\u2208",
        "\u2209",
        "\u220B",
        "\u220C",
        "\u2218",
        "\u221A",
        "\u221B",
        "\u2229",
        "\u222A",
        "\u2248",
        "\u2249",
        "\u2260",
        "\u2261",
        "\u2262",
        "\u2264",
        "\u2265",
        "\u2286",
        "\u2287",
        "\u2288",
        "\u2289",
        "\u228A",
        "\u228B",
        "\u22BB"
    ],
    brackets: [
        {
            open: "(",
            close: ")",
            token: "delimiter.parenthesis"
        },
        {
            open: "{",
            close: "}",
            token: "delimiter.curly"
        },
        {
            open: "[",
            close: "]",
            token: "delimiter.square"
        }
    ],
    ident: /π|ℯ|\b(?!\d)\w+\b/,
    escape: /(?:[abefnrstv\\"'\n\r]|[0-7]{1,3}|x[0-9A-Fa-f]{1,2}|u[0-9A-Fa-f]{4})/,
    escapes: /\\(?:C\-(@escape|.)|c(@escape|.)|@escape)/,
    tokenizer: {
        root: [
            [
                /(::)\s*|\b(isa)\s+/,
                "keyword",
                "@typeanno"
            ],
            [
                /\b(isa)(\s*\(@ident\s*,\s*)/,
                [
                    "keyword",
                    {
                        token: "",
                        next: "@typeanno"
                    }
                ]
            ],
            [
                /\b(type|struct)[ \t]+/,
                "keyword",
                "@typeanno"
            ],
            [
                /^\s*:@ident[!?]?/,
                "metatag"
            ],
            [
                /(return)(\s*:@ident[!?]?)/,
                [
                    "keyword",
                    "metatag"
                ]
            ],
            [
                /(\(|\[|\{|@allops)(\s*:@ident[!?]?)/,
                [
                    "",
                    "metatag"
                ]
            ],
            [
                /:\(/,
                "metatag",
                "@quote"
            ],
            [
                /r"""/,
                "regexp.delim",
                "@tregexp"
            ],
            [
                /r"/,
                "regexp.delim",
                "@sregexp"
            ],
            [
                /raw"""/,
                "string.delim",
                "@rtstring"
            ],
            [
                /[bv]?"""/,
                "string.delim",
                "@dtstring"
            ],
            [
                /raw"/,
                "string.delim",
                "@rsstring"
            ],
            [
                /[bv]?"/,
                "string.delim",
                "@dsstring"
            ],
            [
                /(@ident)\{/,
                {
                    cases: {
                        "$1@types": {
                            token: "type",
                            next: "@gen"
                        },
                        "@default": {
                            token: "type",
                            next: "@gen"
                        }
                    }
                }
            ],
            [
                /@ident[!?'']?(?=\.?\()/,
                {
                    cases: {
                        "@types": "type",
                        "@keywords": "keyword",
                        "@constants": "variable",
                        "@default": "keyword.flow"
                    }
                }
            ],
            [
                /@ident[!?']?/,
                {
                    cases: {
                        "@types": "type",
                        "@keywords": "keyword",
                        "@constants": "variable",
                        "@default": "identifier"
                    }
                }
            ],
            [
                /\$\w+/,
                "key"
            ],
            [
                /\$\(/,
                "key",
                "@paste"
            ],
            [
                /@@@ident/,
                "annotation"
            ],
            {
                include: "@whitespace"
            },
            [
                /'(?:@escapes|.)'/,
                "string.character"
            ],
            [
                /[()\[\]{}]/,
                "@brackets"
            ],
            [
                /@allops/,
                {
                    cases: {
                        "@keywordops": "keyword",
                        "@operators": "operator"
                    }
                }
            ],
            [
                /[;,]/,
                "delimiter"
            ],
            [
                /0[xX][0-9a-fA-F](_?[0-9a-fA-F])*/,
                "number.hex"
            ],
            [
                /0[_oO][0-7](_?[0-7])*/,
                "number.octal"
            ],
            [
                /0[bB][01](_?[01])*/,
                "number.binary"
            ],
            [
                /[+\-]?\d+(\.\d+)?(im?|[eE][+\-]?\d+(\.\d+)?)?/,
                "number"
            ]
        ],
        typeanno: [
            [
                /[a-zA-Z_]\w*(?:\.[a-zA-Z_]\w*)*\{/,
                "type",
                "@gen"
            ],
            [
                /([a-zA-Z_]\w*(?:\.[a-zA-Z_]\w*)*)(\s*<:\s*)/,
                [
                    "type",
                    "keyword"
                ]
            ],
            [
                /[a-zA-Z_]\w*(?:\.[a-zA-Z_]\w*)*/,
                "type",
                "@pop"
            ],
            [
                "",
                "",
                "@pop"
            ]
        ],
        gen: [
            [
                /[a-zA-Z_]\w*(?:\.[a-zA-Z_]\w*)*\{/,
                "type",
                "@push"
            ],
            [
                /[a-zA-Z_]\w*(?:\.[a-zA-Z_]\w*)*/,
                "type"
            ],
            [
                /<:/,
                "keyword"
            ],
            [
                /(\})(\s*<:\s*)/,
                [
                    "type",
                    {
                        token: "keyword",
                        next: "@pop"
                    }
                ]
            ],
            [
                /\}/,
                "type",
                "@pop"
            ],
            {
                include: "@root"
            }
        ],
        quote: [
            [
                /\$\(/,
                "key",
                "@paste"
            ],
            [
                /\(/,
                "@brackets",
                "@paren"
            ],
            [
                /\)/,
                "metatag",
                "@pop"
            ],
            {
                include: "@root"
            }
        ],
        paste: [
            [
                /:\(/,
                "metatag",
                "@quote"
            ],
            [
                /\(/,
                "@brackets",
                "@paren"
            ],
            [
                /\)/,
                "key",
                "@pop"
            ],
            {
                include: "@root"
            }
        ],
        paren: [
            [
                /\$\(/,
                "key",
                "@paste"
            ],
            [
                /:\(/,
                "metatag",
                "@quote"
            ],
            [
                /\(/,
                "@brackets",
                "@push"
            ],
            [
                /\)/,
                "@brackets",
                "@pop"
            ],
            {
                include: "@root"
            }
        ],
        sregexp: [
            [
                /^.*/,
                "invalid"
            ],
            [
                /[^\\"()\[\]{}]/,
                "regexp"
            ],
            [
                /[()\[\]{}]/,
                "@brackets"
            ],
            [
                /\\./,
                "operator.scss"
            ],
            [
                /"[imsx]*/,
                "regexp.delim",
                "@pop"
            ]
        ],
        tregexp: [
            [
                /[^\\"()\[\]{}]/,
                "regexp"
            ],
            [
                /[()\[\]{}]/,
                "@brackets"
            ],
            [
                /\\./,
                "operator.scss"
            ],
            [
                /"(?!"")/,
                "string"
            ],
            [
                /"""[imsx]*/,
                "regexp.delim",
                "@pop"
            ]
        ],
        rsstring: [
            [
                /^.*/,
                "invalid"
            ],
            [
                /[^\\"]/,
                "string"
            ],
            [
                /\\./,
                "string.escape"
            ],
            [
                /"/,
                "string.delim",
                "@pop"
            ]
        ],
        rtstring: [
            [
                /[^\\"]/,
                "string"
            ],
            [
                /\\./,
                "string.escape"
            ],
            [
                /"(?!"")/,
                "string"
            ],
            [
                /"""/,
                "string.delim",
                "@pop"
            ]
        ],
        dsstring: [
            [
                /^.*/,
                "invalid"
            ],
            [
                /[^\\"\$]/,
                "string"
            ],
            [
                /\$/,
                "",
                "@interpolated"
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
                "string.delim",
                "@pop"
            ]
        ],
        dtstring: [
            [
                /[^\\"\$]/,
                "string"
            ],
            [
                /\$/,
                "",
                "@interpolated"
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
                /"(?!"")/,
                "string"
            ],
            [
                /"""/,
                "string.delim",
                "@pop"
            ]
        ],
        interpolated: [
            [
                /\(/,
                {
                    token: "",
                    switchTo: "@interpolated_compound"
                }
            ],
            [
                /[a-zA-Z_]\w*/,
                "identifier"
            ],
            [
                "",
                "",
                "@pop"
            ]
        ],
        interpolated_compound: [
            [
                /\)/,
                "",
                "@pop"
            ],
            {
                include: "@root"
            }
        ],
        whitespace: [
            [
                /[ \t\r\n]+/,
                ""
            ],
            [
                /#=/,
                "comment",
                "@multi_comment"
            ],
            [
                /#.*$/,
                "comment"
            ]
        ],
        multi_comment: [
            [
                /#=/,
                "comment",
                "@push"
            ],
            [
                /=#/,
                "comment",
                "@pop"
            ],
            [
                /=(?!#)|#(?!=)/,
                "comment"
            ],
            [
                /[^#=]+/,
                "comment"
            ]
        ]
    }
};

},{"@parcel/transformer-js/src/esmodule-helpers.js":"gkKU3"}]},["6EyLb"], null, "parcelRequiref17b")

//# sourceMappingURL=julia.5006b305.js.map
