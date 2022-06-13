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
parcelRequire.register("86ZEt", function(module, exports) {

$parcel$export(module.exports, "setupMode", () => $5e7eb5021cd15fec$export$6df00d141df42469);

var $leKFq = parcelRequire("leKFq");
// node_modules/vscode-languageserver-types/lib/esm/main.js
"use strict";
// node_modules/jsonc-parser/lib/esm/impl/scanner.js
"use strict";
// node_modules/jsonc-parser/lib/esm/impl/format.js
"use strict";
// node_modules/jsonc-parser/lib/esm/impl/parser.js
"use strict";
// node_modules/jsonc-parser/lib/esm/impl/edit.js
"use strict";
// node_modules/jsonc-parser/lib/esm/main.js
"use strict";
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ var $5e7eb5021cd15fec$var$__defProp = Object.defineProperty;
var $5e7eb5021cd15fec$var$__getOwnPropDesc = Object.getOwnPropertyDescriptor;
var $5e7eb5021cd15fec$var$__getOwnPropNames = Object.getOwnPropertyNames;
var $5e7eb5021cd15fec$var$__hasOwnProp = Object.prototype.hasOwnProperty;
var $5e7eb5021cd15fec$var$__markAsModule = (target)=>$5e7eb5021cd15fec$var$__defProp(target, "__esModule", {
        value: true
    })
;
var $5e7eb5021cd15fec$var$__reExport = (target, module, desc)=>{
    if (module && typeof module === "object" || typeof module === "function") {
        for (let key of $5e7eb5021cd15fec$var$__getOwnPropNames(module))if (!$5e7eb5021cd15fec$var$__hasOwnProp.call(target, key) && key !== "default") $5e7eb5021cd15fec$var$__defProp(target, key, {
            get: ()=>module[key]
            ,
            enumerable: !(desc = $5e7eb5021cd15fec$var$__getOwnPropDesc(module, key)) || desc.enumerable
        });
    }
    return target;
};
// src/fillers/monaco-editor-core.ts
var $5e7eb5021cd15fec$var$monaco_editor_core_exports = {};
$5e7eb5021cd15fec$var$__markAsModule($5e7eb5021cd15fec$var$monaco_editor_core_exports);
$5e7eb5021cd15fec$var$__reExport($5e7eb5021cd15fec$var$monaco_editor_core_exports, $leKFq);
// src/json/workerManager.ts
var $5e7eb5021cd15fec$var$STOP_WHEN_IDLE_FOR = 120000;
var $5e7eb5021cd15fec$var$WorkerManager = class {
    constructor(defaults){
        this._defaults = defaults;
        this._worker = null;
        this._client = null;
        this._idleCheckInterval = window.setInterval(()=>this._checkIfIdle()
        , 30000);
        this._lastUsedTime = 0;
        this._configChangeListener = this._defaults.onDidChange(()=>this._stopWorker()
        );
    }
    _stopWorker() {
        if (this._worker) {
            this._worker.dispose();
            this._worker = null;
        }
        this._client = null;
    }
    dispose() {
        clearInterval(this._idleCheckInterval);
        this._configChangeListener.dispose();
        this._stopWorker();
    }
    _checkIfIdle() {
        if (!this._worker) return;
        let timePassedSinceLastUsed = Date.now() - this._lastUsedTime;
        if (timePassedSinceLastUsed > $5e7eb5021cd15fec$var$STOP_WHEN_IDLE_FOR) this._stopWorker();
    }
    _getClient() {
        this._lastUsedTime = Date.now();
        if (!this._client) {
            this._worker = $5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.createWebWorker({
                moduleId: "vs/language/json/jsonWorker",
                label: this._defaults.languageId,
                createData: {
                    languageSettings: this._defaults.diagnosticsOptions,
                    languageId: this._defaults.languageId,
                    enableSchemaRequest: this._defaults.diagnosticsOptions.enableSchemaRequest
                }
            });
            this._client = this._worker.getProxy();
        }
        return this._client;
    }
    getLanguageServiceWorker(...resources) {
        let _client;
        return this._getClient().then((client)=>{
            _client = client;
        }).then((_)=>{
            if (this._worker) return this._worker.withSyncedResources(resources);
        }).then((_)=>_client
        );
    }
};
var $5e7eb5021cd15fec$var$integer;
(function(integer2) {
    integer2.MIN_VALUE = -2147483648;
    integer2.MAX_VALUE = 2147483647;
})($5e7eb5021cd15fec$var$integer || ($5e7eb5021cd15fec$var$integer = {}));
var $5e7eb5021cd15fec$var$uinteger;
(function(uinteger2) {
    uinteger2.MIN_VALUE = 0;
    uinteger2.MAX_VALUE = 2147483647;
})($5e7eb5021cd15fec$var$uinteger || ($5e7eb5021cd15fec$var$uinteger = {}));
var $5e7eb5021cd15fec$var$Position;
(function(Position3) {
    function create(line, character) {
        if (line === Number.MAX_VALUE) line = $5e7eb5021cd15fec$var$uinteger.MAX_VALUE;
        if (character === Number.MAX_VALUE) character = $5e7eb5021cd15fec$var$uinteger.MAX_VALUE;
        return {
            line: line,
            character: character
        };
    }
    Position3.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.objectLiteral(candidate) && $5e7eb5021cd15fec$var$Is.uinteger(candidate.line) && $5e7eb5021cd15fec$var$Is.uinteger(candidate.character);
    }
    Position3.is = is;
})($5e7eb5021cd15fec$var$Position || ($5e7eb5021cd15fec$var$Position = {}));
var $5e7eb5021cd15fec$var$Range;
(function(Range3) {
    function create(one, two, three, four) {
        if ($5e7eb5021cd15fec$var$Is.uinteger(one) && $5e7eb5021cd15fec$var$Is.uinteger(two) && $5e7eb5021cd15fec$var$Is.uinteger(three) && $5e7eb5021cd15fec$var$Is.uinteger(four)) return {
            start: $5e7eb5021cd15fec$var$Position.create(one, two),
            end: $5e7eb5021cd15fec$var$Position.create(three, four)
        };
        else if ($5e7eb5021cd15fec$var$Position.is(one) && $5e7eb5021cd15fec$var$Position.is(two)) return {
            start: one,
            end: two
        };
        else throw new Error("Range#create called with invalid arguments[" + one + ", " + two + ", " + three + ", " + four + "]");
    }
    Range3.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.objectLiteral(candidate) && $5e7eb5021cd15fec$var$Position.is(candidate.start) && $5e7eb5021cd15fec$var$Position.is(candidate.end);
    }
    Range3.is = is;
})($5e7eb5021cd15fec$var$Range || ($5e7eb5021cd15fec$var$Range = {}));
var $5e7eb5021cd15fec$var$Location;
(function(Location2) {
    function create(uri, range) {
        return {
            uri: uri,
            range: range
        };
    }
    Location2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Range.is(candidate.range) && ($5e7eb5021cd15fec$var$Is.string(candidate.uri) || $5e7eb5021cd15fec$var$Is.undefined(candidate.uri));
    }
    Location2.is = is;
})($5e7eb5021cd15fec$var$Location || ($5e7eb5021cd15fec$var$Location = {}));
var $5e7eb5021cd15fec$var$LocationLink;
(function(LocationLink2) {
    function create(targetUri, targetRange, targetSelectionRange, originSelectionRange) {
        return {
            targetUri: targetUri,
            targetRange: targetRange,
            targetSelectionRange: targetSelectionRange,
            originSelectionRange: originSelectionRange
        };
    }
    LocationLink2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Range.is(candidate.targetRange) && $5e7eb5021cd15fec$var$Is.string(candidate.targetUri) && ($5e7eb5021cd15fec$var$Range.is(candidate.targetSelectionRange) || $5e7eb5021cd15fec$var$Is.undefined(candidate.targetSelectionRange)) && ($5e7eb5021cd15fec$var$Range.is(candidate.originSelectionRange) || $5e7eb5021cd15fec$var$Is.undefined(candidate.originSelectionRange));
    }
    LocationLink2.is = is;
})($5e7eb5021cd15fec$var$LocationLink || ($5e7eb5021cd15fec$var$LocationLink = {}));
var $5e7eb5021cd15fec$var$Color;
(function(Color2) {
    function create(red, green, blue, alpha) {
        return {
            red: red,
            green: green,
            blue: blue,
            alpha: alpha
        };
    }
    Color2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.numberRange(candidate.red, 0, 1) && $5e7eb5021cd15fec$var$Is.numberRange(candidate.green, 0, 1) && $5e7eb5021cd15fec$var$Is.numberRange(candidate.blue, 0, 1) && $5e7eb5021cd15fec$var$Is.numberRange(candidate.alpha, 0, 1);
    }
    Color2.is = is;
})($5e7eb5021cd15fec$var$Color || ($5e7eb5021cd15fec$var$Color = {}));
var $5e7eb5021cd15fec$var$ColorInformation;
(function(ColorInformation2) {
    function create(range, color) {
        return {
            range: range,
            color: color
        };
    }
    ColorInformation2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Range.is(candidate.range) && $5e7eb5021cd15fec$var$Color.is(candidate.color);
    }
    ColorInformation2.is = is;
})($5e7eb5021cd15fec$var$ColorInformation || ($5e7eb5021cd15fec$var$ColorInformation = {}));
var $5e7eb5021cd15fec$var$ColorPresentation;
(function(ColorPresentation2) {
    function create(label, textEdit, additionalTextEdits) {
        return {
            label: label,
            textEdit: textEdit,
            additionalTextEdits: additionalTextEdits
        };
    }
    ColorPresentation2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.string(candidate.label) && ($5e7eb5021cd15fec$var$Is.undefined(candidate.textEdit) || $5e7eb5021cd15fec$var$TextEdit.is(candidate)) && ($5e7eb5021cd15fec$var$Is.undefined(candidate.additionalTextEdits) || $5e7eb5021cd15fec$var$Is.typedArray(candidate.additionalTextEdits, $5e7eb5021cd15fec$var$TextEdit.is));
    }
    ColorPresentation2.is = is;
})($5e7eb5021cd15fec$var$ColorPresentation || ($5e7eb5021cd15fec$var$ColorPresentation = {}));
var $5e7eb5021cd15fec$var$FoldingRangeKind;
(function(FoldingRangeKind2) {
    FoldingRangeKind2["Comment"] = "comment";
    FoldingRangeKind2["Imports"] = "imports";
    FoldingRangeKind2["Region"] = "region";
})($5e7eb5021cd15fec$var$FoldingRangeKind || ($5e7eb5021cd15fec$var$FoldingRangeKind = {}));
var $5e7eb5021cd15fec$var$FoldingRange;
(function(FoldingRange2) {
    function create(startLine, endLine, startCharacter, endCharacter, kind) {
        var result = {
            startLine: startLine,
            endLine: endLine
        };
        if ($5e7eb5021cd15fec$var$Is.defined(startCharacter)) result.startCharacter = startCharacter;
        if ($5e7eb5021cd15fec$var$Is.defined(endCharacter)) result.endCharacter = endCharacter;
        if ($5e7eb5021cd15fec$var$Is.defined(kind)) result.kind = kind;
        return result;
    }
    FoldingRange2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.uinteger(candidate.startLine) && $5e7eb5021cd15fec$var$Is.uinteger(candidate.startLine) && ($5e7eb5021cd15fec$var$Is.undefined(candidate.startCharacter) || $5e7eb5021cd15fec$var$Is.uinteger(candidate.startCharacter)) && ($5e7eb5021cd15fec$var$Is.undefined(candidate.endCharacter) || $5e7eb5021cd15fec$var$Is.uinteger(candidate.endCharacter)) && ($5e7eb5021cd15fec$var$Is.undefined(candidate.kind) || $5e7eb5021cd15fec$var$Is.string(candidate.kind));
    }
    FoldingRange2.is = is;
})($5e7eb5021cd15fec$var$FoldingRange || ($5e7eb5021cd15fec$var$FoldingRange = {}));
var $5e7eb5021cd15fec$var$DiagnosticRelatedInformation;
(function(DiagnosticRelatedInformation2) {
    function create(location, message) {
        return {
            location: location,
            message: message
        };
    }
    DiagnosticRelatedInformation2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Location.is(candidate.location) && $5e7eb5021cd15fec$var$Is.string(candidate.message);
    }
    DiagnosticRelatedInformation2.is = is;
})($5e7eb5021cd15fec$var$DiagnosticRelatedInformation || ($5e7eb5021cd15fec$var$DiagnosticRelatedInformation = {}));
var $5e7eb5021cd15fec$var$DiagnosticSeverity;
(function(DiagnosticSeverity2) {
    DiagnosticSeverity2.Error = 1;
    DiagnosticSeverity2.Warning = 2;
    DiagnosticSeverity2.Information = 3;
    DiagnosticSeverity2.Hint = 4;
})($5e7eb5021cd15fec$var$DiagnosticSeverity || ($5e7eb5021cd15fec$var$DiagnosticSeverity = {}));
var $5e7eb5021cd15fec$var$DiagnosticTag;
(function(DiagnosticTag2) {
    DiagnosticTag2.Unnecessary = 1;
    DiagnosticTag2.Deprecated = 2;
})($5e7eb5021cd15fec$var$DiagnosticTag || ($5e7eb5021cd15fec$var$DiagnosticTag = {}));
var $5e7eb5021cd15fec$var$CodeDescription;
(function(CodeDescription2) {
    function is(value) {
        var candidate = value;
        return candidate !== void 0 && candidate !== null && $5e7eb5021cd15fec$var$Is.string(candidate.href);
    }
    CodeDescription2.is = is;
})($5e7eb5021cd15fec$var$CodeDescription || ($5e7eb5021cd15fec$var$CodeDescription = {}));
var $5e7eb5021cd15fec$var$Diagnostic;
(function(Diagnostic2) {
    function create(range, message, severity, code, source, relatedInformation) {
        var result = {
            range: range,
            message: message
        };
        if ($5e7eb5021cd15fec$var$Is.defined(severity)) result.severity = severity;
        if ($5e7eb5021cd15fec$var$Is.defined(code)) result.code = code;
        if ($5e7eb5021cd15fec$var$Is.defined(source)) result.source = source;
        if ($5e7eb5021cd15fec$var$Is.defined(relatedInformation)) result.relatedInformation = relatedInformation;
        return result;
    }
    Diagnostic2.create = create;
    function is(value) {
        var _a;
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Range.is(candidate.range) && $5e7eb5021cd15fec$var$Is.string(candidate.message) && ($5e7eb5021cd15fec$var$Is.number(candidate.severity) || $5e7eb5021cd15fec$var$Is.undefined(candidate.severity)) && ($5e7eb5021cd15fec$var$Is.integer(candidate.code) || $5e7eb5021cd15fec$var$Is.string(candidate.code) || $5e7eb5021cd15fec$var$Is.undefined(candidate.code)) && ($5e7eb5021cd15fec$var$Is.undefined(candidate.codeDescription) || $5e7eb5021cd15fec$var$Is.string((_a = candidate.codeDescription) === null || _a === void 0 ? void 0 : _a.href)) && ($5e7eb5021cd15fec$var$Is.string(candidate.source) || $5e7eb5021cd15fec$var$Is.undefined(candidate.source)) && ($5e7eb5021cd15fec$var$Is.undefined(candidate.relatedInformation) || $5e7eb5021cd15fec$var$Is.typedArray(candidate.relatedInformation, $5e7eb5021cd15fec$var$DiagnosticRelatedInformation.is));
    }
    Diagnostic2.is = is;
})($5e7eb5021cd15fec$var$Diagnostic || ($5e7eb5021cd15fec$var$Diagnostic = {}));
var $5e7eb5021cd15fec$var$Command;
(function(Command2) {
    function create(title, command) {
        var args = [];
        for(var _i = 2; _i < arguments.length; _i++)args[_i - 2] = arguments[_i];
        var result = {
            title: title,
            command: command
        };
        if ($5e7eb5021cd15fec$var$Is.defined(args) && args.length > 0) result.arguments = args;
        return result;
    }
    Command2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Is.string(candidate.title) && $5e7eb5021cd15fec$var$Is.string(candidate.command);
    }
    Command2.is = is;
})($5e7eb5021cd15fec$var$Command || ($5e7eb5021cd15fec$var$Command = {}));
var $5e7eb5021cd15fec$var$TextEdit;
(function(TextEdit2) {
    function replace(range, newText) {
        return {
            range: range,
            newText: newText
        };
    }
    TextEdit2.replace = replace;
    function insert(position, newText) {
        return {
            range: {
                start: position,
                end: position
            },
            newText: newText
        };
    }
    TextEdit2.insert = insert;
    function del(range) {
        return {
            range: range,
            newText: ""
        };
    }
    TextEdit2.del = del;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.objectLiteral(candidate) && $5e7eb5021cd15fec$var$Is.string(candidate.newText) && $5e7eb5021cd15fec$var$Range.is(candidate.range);
    }
    TextEdit2.is = is;
})($5e7eb5021cd15fec$var$TextEdit || ($5e7eb5021cd15fec$var$TextEdit = {}));
var $5e7eb5021cd15fec$var$ChangeAnnotation;
(function(ChangeAnnotation2) {
    function create(label, needsConfirmation, description) {
        var result = {
            label: label
        };
        if (needsConfirmation !== void 0) result.needsConfirmation = needsConfirmation;
        if (description !== void 0) result.description = description;
        return result;
    }
    ChangeAnnotation2.create = create;
    function is(value) {
        var candidate = value;
        return candidate !== void 0 && $5e7eb5021cd15fec$var$Is.objectLiteral(candidate) && $5e7eb5021cd15fec$var$Is.string(candidate.label) && ($5e7eb5021cd15fec$var$Is.boolean(candidate.needsConfirmation) || candidate.needsConfirmation === void 0) && ($5e7eb5021cd15fec$var$Is.string(candidate.description) || candidate.description === void 0);
    }
    ChangeAnnotation2.is = is;
})($5e7eb5021cd15fec$var$ChangeAnnotation || ($5e7eb5021cd15fec$var$ChangeAnnotation = {}));
var $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier;
(function(ChangeAnnotationIdentifier2) {
    function is(value) {
        var candidate = value;
        return typeof candidate === "string";
    }
    ChangeAnnotationIdentifier2.is = is;
})($5e7eb5021cd15fec$var$ChangeAnnotationIdentifier || ($5e7eb5021cd15fec$var$ChangeAnnotationIdentifier = {}));
var $5e7eb5021cd15fec$var$AnnotatedTextEdit;
(function(AnnotatedTextEdit2) {
    function replace(range, newText, annotation) {
        return {
            range: range,
            newText: newText,
            annotationId: annotation
        };
    }
    AnnotatedTextEdit2.replace = replace;
    function insert(position, newText, annotation) {
        return {
            range: {
                start: position,
                end: position
            },
            newText: newText,
            annotationId: annotation
        };
    }
    AnnotatedTextEdit2.insert = insert;
    function del(range, annotation) {
        return {
            range: range,
            newText: "",
            annotationId: annotation
        };
    }
    AnnotatedTextEdit2.del = del;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$TextEdit.is(candidate) && ($5e7eb5021cd15fec$var$ChangeAnnotation.is(candidate.annotationId) || $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(candidate.annotationId));
    }
    AnnotatedTextEdit2.is = is;
})($5e7eb5021cd15fec$var$AnnotatedTextEdit || ($5e7eb5021cd15fec$var$AnnotatedTextEdit = {}));
var $5e7eb5021cd15fec$var$TextDocumentEdit;
(function(TextDocumentEdit2) {
    function create(textDocument, edits) {
        return {
            textDocument: textDocument,
            edits: edits
        };
    }
    TextDocumentEdit2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$OptionalVersionedTextDocumentIdentifier.is(candidate.textDocument) && Array.isArray(candidate.edits);
    }
    TextDocumentEdit2.is = is;
})($5e7eb5021cd15fec$var$TextDocumentEdit || ($5e7eb5021cd15fec$var$TextDocumentEdit = {}));
var $5e7eb5021cd15fec$var$CreateFile;
(function(CreateFile2) {
    function create(uri, options, annotation) {
        var result = {
            kind: "create",
            uri: uri
        };
        if (options !== void 0 && (options.overwrite !== void 0 || options.ignoreIfExists !== void 0)) result.options = options;
        if (annotation !== void 0) result.annotationId = annotation;
        return result;
    }
    CreateFile2.create = create;
    function is(value) {
        var candidate = value;
        return candidate && candidate.kind === "create" && $5e7eb5021cd15fec$var$Is.string(candidate.uri) && (candidate.options === void 0 || (candidate.options.overwrite === void 0 || $5e7eb5021cd15fec$var$Is.boolean(candidate.options.overwrite)) && (candidate.options.ignoreIfExists === void 0 || $5e7eb5021cd15fec$var$Is.boolean(candidate.options.ignoreIfExists))) && (candidate.annotationId === void 0 || $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(candidate.annotationId));
    }
    CreateFile2.is = is;
})($5e7eb5021cd15fec$var$CreateFile || ($5e7eb5021cd15fec$var$CreateFile = {}));
var $5e7eb5021cd15fec$var$RenameFile;
(function(RenameFile2) {
    function create(oldUri, newUri, options, annotation) {
        var result = {
            kind: "rename",
            oldUri: oldUri,
            newUri: newUri
        };
        if (options !== void 0 && (options.overwrite !== void 0 || options.ignoreIfExists !== void 0)) result.options = options;
        if (annotation !== void 0) result.annotationId = annotation;
        return result;
    }
    RenameFile2.create = create;
    function is(value) {
        var candidate = value;
        return candidate && candidate.kind === "rename" && $5e7eb5021cd15fec$var$Is.string(candidate.oldUri) && $5e7eb5021cd15fec$var$Is.string(candidate.newUri) && (candidate.options === void 0 || (candidate.options.overwrite === void 0 || $5e7eb5021cd15fec$var$Is.boolean(candidate.options.overwrite)) && (candidate.options.ignoreIfExists === void 0 || $5e7eb5021cd15fec$var$Is.boolean(candidate.options.ignoreIfExists))) && (candidate.annotationId === void 0 || $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(candidate.annotationId));
    }
    RenameFile2.is = is;
})($5e7eb5021cd15fec$var$RenameFile || ($5e7eb5021cd15fec$var$RenameFile = {}));
var $5e7eb5021cd15fec$var$DeleteFile;
(function(DeleteFile2) {
    function create(uri, options, annotation) {
        var result = {
            kind: "delete",
            uri: uri
        };
        if (options !== void 0 && (options.recursive !== void 0 || options.ignoreIfNotExists !== void 0)) result.options = options;
        if (annotation !== void 0) result.annotationId = annotation;
        return result;
    }
    DeleteFile2.create = create;
    function is(value) {
        var candidate = value;
        return candidate && candidate.kind === "delete" && $5e7eb5021cd15fec$var$Is.string(candidate.uri) && (candidate.options === void 0 || (candidate.options.recursive === void 0 || $5e7eb5021cd15fec$var$Is.boolean(candidate.options.recursive)) && (candidate.options.ignoreIfNotExists === void 0 || $5e7eb5021cd15fec$var$Is.boolean(candidate.options.ignoreIfNotExists))) && (candidate.annotationId === void 0 || $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(candidate.annotationId));
    }
    DeleteFile2.is = is;
})($5e7eb5021cd15fec$var$DeleteFile || ($5e7eb5021cd15fec$var$DeleteFile = {}));
var $5e7eb5021cd15fec$var$WorkspaceEdit;
(function(WorkspaceEdit2) {
    function is(value) {
        var candidate = value;
        return candidate && (candidate.changes !== void 0 || candidate.documentChanges !== void 0) && (candidate.documentChanges === void 0 || candidate.documentChanges.every(function(change) {
            if ($5e7eb5021cd15fec$var$Is.string(change.kind)) return $5e7eb5021cd15fec$var$CreateFile.is(change) || $5e7eb5021cd15fec$var$RenameFile.is(change) || $5e7eb5021cd15fec$var$DeleteFile.is(change);
            else return $5e7eb5021cd15fec$var$TextDocumentEdit.is(change);
        }));
    }
    WorkspaceEdit2.is = is;
})($5e7eb5021cd15fec$var$WorkspaceEdit || ($5e7eb5021cd15fec$var$WorkspaceEdit = {}));
var $5e7eb5021cd15fec$var$TextEditChangeImpl = function() {
    function TextEditChangeImpl2(edits, changeAnnotations) {
        this.edits = edits;
        this.changeAnnotations = changeAnnotations;
    }
    TextEditChangeImpl2.prototype.insert = function(position, newText, annotation) {
        var edit2;
        var id;
        if (annotation === void 0) edit2 = $5e7eb5021cd15fec$var$TextEdit.insert(position, newText);
        else if ($5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(annotation)) {
            id = annotation;
            edit2 = $5e7eb5021cd15fec$var$AnnotatedTextEdit.insert(position, newText, annotation);
        } else {
            this.assertChangeAnnotations(this.changeAnnotations);
            id = this.changeAnnotations.manage(annotation);
            edit2 = $5e7eb5021cd15fec$var$AnnotatedTextEdit.insert(position, newText, id);
        }
        this.edits.push(edit2);
        if (id !== void 0) return id;
    };
    TextEditChangeImpl2.prototype.replace = function(range, newText, annotation) {
        var edit2;
        var id;
        if (annotation === void 0) edit2 = $5e7eb5021cd15fec$var$TextEdit.replace(range, newText);
        else if ($5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(annotation)) {
            id = annotation;
            edit2 = $5e7eb5021cd15fec$var$AnnotatedTextEdit.replace(range, newText, annotation);
        } else {
            this.assertChangeAnnotations(this.changeAnnotations);
            id = this.changeAnnotations.manage(annotation);
            edit2 = $5e7eb5021cd15fec$var$AnnotatedTextEdit.replace(range, newText, id);
        }
        this.edits.push(edit2);
        if (id !== void 0) return id;
    };
    TextEditChangeImpl2.prototype.delete = function(range, annotation) {
        var edit2;
        var id;
        if (annotation === void 0) edit2 = $5e7eb5021cd15fec$var$TextEdit.del(range);
        else if ($5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(annotation)) {
            id = annotation;
            edit2 = $5e7eb5021cd15fec$var$AnnotatedTextEdit.del(range, annotation);
        } else {
            this.assertChangeAnnotations(this.changeAnnotations);
            id = this.changeAnnotations.manage(annotation);
            edit2 = $5e7eb5021cd15fec$var$AnnotatedTextEdit.del(range, id);
        }
        this.edits.push(edit2);
        if (id !== void 0) return id;
    };
    TextEditChangeImpl2.prototype.add = function(edit2) {
        this.edits.push(edit2);
    };
    TextEditChangeImpl2.prototype.all = function() {
        return this.edits;
    };
    TextEditChangeImpl2.prototype.clear = function() {
        this.edits.splice(0, this.edits.length);
    };
    TextEditChangeImpl2.prototype.assertChangeAnnotations = function(value) {
        if (value === void 0) throw new Error("Text edit change is not configured to manage change annotations.");
    };
    return TextEditChangeImpl2;
}();
var $5e7eb5021cd15fec$var$ChangeAnnotations = function() {
    function ChangeAnnotations2(annotations) {
        this._annotations = annotations === void 0 ? Object.create(null) : annotations;
        this._counter = 0;
        this._size = 0;
    }
    ChangeAnnotations2.prototype.all = function() {
        return this._annotations;
    };
    Object.defineProperty(ChangeAnnotations2.prototype, "size", {
        get: function() {
            return this._size;
        },
        enumerable: false,
        configurable: true
    });
    ChangeAnnotations2.prototype.manage = function(idOrAnnotation, annotation) {
        var id;
        if ($5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(idOrAnnotation)) id = idOrAnnotation;
        else {
            id = this.nextId();
            annotation = idOrAnnotation;
        }
        if (this._annotations[id] !== void 0) throw new Error("Id " + id + " is already in use.");
        if (annotation === void 0) throw new Error("No annotation provided for id " + id);
        this._annotations[id] = annotation;
        this._size++;
        return id;
    };
    ChangeAnnotations2.prototype.nextId = function() {
        this._counter++;
        return this._counter.toString();
    };
    return ChangeAnnotations2;
}();
var $5e7eb5021cd15fec$var$WorkspaceChange = function() {
    function WorkspaceChange2(workspaceEdit) {
        var _this = this;
        this._textEditChanges = Object.create(null);
        if (workspaceEdit !== void 0) {
            this._workspaceEdit = workspaceEdit;
            if (workspaceEdit.documentChanges) {
                this._changeAnnotations = new $5e7eb5021cd15fec$var$ChangeAnnotations(workspaceEdit.changeAnnotations);
                workspaceEdit.changeAnnotations = this._changeAnnotations.all();
                workspaceEdit.documentChanges.forEach(function(change) {
                    if ($5e7eb5021cd15fec$var$TextDocumentEdit.is(change)) {
                        var textEditChange = new $5e7eb5021cd15fec$var$TextEditChangeImpl(change.edits, _this._changeAnnotations);
                        _this._textEditChanges[change.textDocument.uri] = textEditChange;
                    }
                });
            } else if (workspaceEdit.changes) Object.keys(workspaceEdit.changes).forEach(function(key) {
                var textEditChange = new $5e7eb5021cd15fec$var$TextEditChangeImpl(workspaceEdit.changes[key]);
                _this._textEditChanges[key] = textEditChange;
            });
        } else this._workspaceEdit = {};
    }
    Object.defineProperty(WorkspaceChange2.prototype, "edit", {
        get: function() {
            this.initDocumentChanges();
            if (this._changeAnnotations !== void 0) {
                if (this._changeAnnotations.size === 0) this._workspaceEdit.changeAnnotations = void 0;
                else this._workspaceEdit.changeAnnotations = this._changeAnnotations.all();
            }
            return this._workspaceEdit;
        },
        enumerable: false,
        configurable: true
    });
    WorkspaceChange2.prototype.getTextEditChange = function(key) {
        if ($5e7eb5021cd15fec$var$OptionalVersionedTextDocumentIdentifier.is(key)) {
            this.initDocumentChanges();
            if (this._workspaceEdit.documentChanges === void 0) throw new Error("Workspace edit is not configured for document changes.");
            var textDocument = {
                uri: key.uri,
                version: key.version
            };
            var result = this._textEditChanges[textDocument.uri];
            if (!result) {
                var edits = [];
                var textDocumentEdit = {
                    textDocument: textDocument,
                    edits: edits
                };
                this._workspaceEdit.documentChanges.push(textDocumentEdit);
                result = new $5e7eb5021cd15fec$var$TextEditChangeImpl(edits, this._changeAnnotations);
                this._textEditChanges[textDocument.uri] = result;
            }
            return result;
        } else {
            this.initChanges();
            if (this._workspaceEdit.changes === void 0) throw new Error("Workspace edit is not configured for normal text edit changes.");
            var result = this._textEditChanges[key];
            if (!result) {
                var edits = [];
                this._workspaceEdit.changes[key] = edits;
                result = new $5e7eb5021cd15fec$var$TextEditChangeImpl(edits);
                this._textEditChanges[key] = result;
            }
            return result;
        }
    };
    WorkspaceChange2.prototype.initDocumentChanges = function() {
        if (this._workspaceEdit.documentChanges === void 0 && this._workspaceEdit.changes === void 0) {
            this._changeAnnotations = new $5e7eb5021cd15fec$var$ChangeAnnotations();
            this._workspaceEdit.documentChanges = [];
            this._workspaceEdit.changeAnnotations = this._changeAnnotations.all();
        }
    };
    WorkspaceChange2.prototype.initChanges = function() {
        if (this._workspaceEdit.documentChanges === void 0 && this._workspaceEdit.changes === void 0) this._workspaceEdit.changes = Object.create(null);
    };
    WorkspaceChange2.prototype.createFile = function(uri, optionsOrAnnotation, options) {
        this.initDocumentChanges();
        if (this._workspaceEdit.documentChanges === void 0) throw new Error("Workspace edit is not configured for document changes.");
        var annotation;
        if ($5e7eb5021cd15fec$var$ChangeAnnotation.is(optionsOrAnnotation) || $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(optionsOrAnnotation)) annotation = optionsOrAnnotation;
        else options = optionsOrAnnotation;
        var operation;
        var id;
        if (annotation === void 0) operation = $5e7eb5021cd15fec$var$CreateFile.create(uri, options);
        else {
            id = $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(annotation) ? annotation : this._changeAnnotations.manage(annotation);
            operation = $5e7eb5021cd15fec$var$CreateFile.create(uri, options, id);
        }
        this._workspaceEdit.documentChanges.push(operation);
        if (id !== void 0) return id;
    };
    WorkspaceChange2.prototype.renameFile = function(oldUri, newUri, optionsOrAnnotation, options) {
        this.initDocumentChanges();
        if (this._workspaceEdit.documentChanges === void 0) throw new Error("Workspace edit is not configured for document changes.");
        var annotation;
        if ($5e7eb5021cd15fec$var$ChangeAnnotation.is(optionsOrAnnotation) || $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(optionsOrAnnotation)) annotation = optionsOrAnnotation;
        else options = optionsOrAnnotation;
        var operation;
        var id;
        if (annotation === void 0) operation = $5e7eb5021cd15fec$var$RenameFile.create(oldUri, newUri, options);
        else {
            id = $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(annotation) ? annotation : this._changeAnnotations.manage(annotation);
            operation = $5e7eb5021cd15fec$var$RenameFile.create(oldUri, newUri, options, id);
        }
        this._workspaceEdit.documentChanges.push(operation);
        if (id !== void 0) return id;
    };
    WorkspaceChange2.prototype.deleteFile = function(uri, optionsOrAnnotation, options) {
        this.initDocumentChanges();
        if (this._workspaceEdit.documentChanges === void 0) throw new Error("Workspace edit is not configured for document changes.");
        var annotation;
        if ($5e7eb5021cd15fec$var$ChangeAnnotation.is(optionsOrAnnotation) || $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(optionsOrAnnotation)) annotation = optionsOrAnnotation;
        else options = optionsOrAnnotation;
        var operation;
        var id;
        if (annotation === void 0) operation = $5e7eb5021cd15fec$var$DeleteFile.create(uri, options);
        else {
            id = $5e7eb5021cd15fec$var$ChangeAnnotationIdentifier.is(annotation) ? annotation : this._changeAnnotations.manage(annotation);
            operation = $5e7eb5021cd15fec$var$DeleteFile.create(uri, options, id);
        }
        this._workspaceEdit.documentChanges.push(operation);
        if (id !== void 0) return id;
    };
    return WorkspaceChange2;
}();
var $5e7eb5021cd15fec$var$TextDocumentIdentifier;
(function(TextDocumentIdentifier2) {
    function create(uri) {
        return {
            uri: uri
        };
    }
    TextDocumentIdentifier2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Is.string(candidate.uri);
    }
    TextDocumentIdentifier2.is = is;
})($5e7eb5021cd15fec$var$TextDocumentIdentifier || ($5e7eb5021cd15fec$var$TextDocumentIdentifier = {}));
var $5e7eb5021cd15fec$var$VersionedTextDocumentIdentifier;
(function(VersionedTextDocumentIdentifier2) {
    function create(uri, version) {
        return {
            uri: uri,
            version: version
        };
    }
    VersionedTextDocumentIdentifier2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Is.string(candidate.uri) && $5e7eb5021cd15fec$var$Is.integer(candidate.version);
    }
    VersionedTextDocumentIdentifier2.is = is;
})($5e7eb5021cd15fec$var$VersionedTextDocumentIdentifier || ($5e7eb5021cd15fec$var$VersionedTextDocumentIdentifier = {}));
var $5e7eb5021cd15fec$var$OptionalVersionedTextDocumentIdentifier;
(function(OptionalVersionedTextDocumentIdentifier2) {
    function create(uri, version) {
        return {
            uri: uri,
            version: version
        };
    }
    OptionalVersionedTextDocumentIdentifier2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Is.string(candidate.uri) && (candidate.version === null || $5e7eb5021cd15fec$var$Is.integer(candidate.version));
    }
    OptionalVersionedTextDocumentIdentifier2.is = is;
})($5e7eb5021cd15fec$var$OptionalVersionedTextDocumentIdentifier || ($5e7eb5021cd15fec$var$OptionalVersionedTextDocumentIdentifier = {}));
var $5e7eb5021cd15fec$var$TextDocumentItem;
(function(TextDocumentItem2) {
    function create(uri, languageId, version, text) {
        return {
            uri: uri,
            languageId: languageId,
            version: version,
            text: text
        };
    }
    TextDocumentItem2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Is.string(candidate.uri) && $5e7eb5021cd15fec$var$Is.string(candidate.languageId) && $5e7eb5021cd15fec$var$Is.integer(candidate.version) && $5e7eb5021cd15fec$var$Is.string(candidate.text);
    }
    TextDocumentItem2.is = is;
})($5e7eb5021cd15fec$var$TextDocumentItem || ($5e7eb5021cd15fec$var$TextDocumentItem = {}));
var $5e7eb5021cd15fec$var$MarkupKind;
(function(MarkupKind2) {
    MarkupKind2.PlainText = "plaintext";
    MarkupKind2.Markdown = "markdown";
})($5e7eb5021cd15fec$var$MarkupKind || ($5e7eb5021cd15fec$var$MarkupKind = {}));
(function(MarkupKind2) {
    function is(value) {
        var candidate = value;
        return candidate === MarkupKind2.PlainText || candidate === MarkupKind2.Markdown;
    }
    MarkupKind2.is = is;
})($5e7eb5021cd15fec$var$MarkupKind || ($5e7eb5021cd15fec$var$MarkupKind = {}));
var $5e7eb5021cd15fec$var$MarkupContent;
(function(MarkupContent2) {
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.objectLiteral(value) && $5e7eb5021cd15fec$var$MarkupKind.is(candidate.kind) && $5e7eb5021cd15fec$var$Is.string(candidate.value);
    }
    MarkupContent2.is = is;
})($5e7eb5021cd15fec$var$MarkupContent || ($5e7eb5021cd15fec$var$MarkupContent = {}));
var $5e7eb5021cd15fec$var$CompletionItemKind;
(function(CompletionItemKind2) {
    CompletionItemKind2.Text = 1;
    CompletionItemKind2.Method = 2;
    CompletionItemKind2.Function = 3;
    CompletionItemKind2.Constructor = 4;
    CompletionItemKind2.Field = 5;
    CompletionItemKind2.Variable = 6;
    CompletionItemKind2.Class = 7;
    CompletionItemKind2.Interface = 8;
    CompletionItemKind2.Module = 9;
    CompletionItemKind2.Property = 10;
    CompletionItemKind2.Unit = 11;
    CompletionItemKind2.Value = 12;
    CompletionItemKind2.Enum = 13;
    CompletionItemKind2.Keyword = 14;
    CompletionItemKind2.Snippet = 15;
    CompletionItemKind2.Color = 16;
    CompletionItemKind2.File = 17;
    CompletionItemKind2.Reference = 18;
    CompletionItemKind2.Folder = 19;
    CompletionItemKind2.EnumMember = 20;
    CompletionItemKind2.Constant = 21;
    CompletionItemKind2.Struct = 22;
    CompletionItemKind2.Event = 23;
    CompletionItemKind2.Operator = 24;
    CompletionItemKind2.TypeParameter = 25;
})($5e7eb5021cd15fec$var$CompletionItemKind || ($5e7eb5021cd15fec$var$CompletionItemKind = {}));
var $5e7eb5021cd15fec$var$InsertTextFormat;
(function(InsertTextFormat2) {
    InsertTextFormat2.PlainText = 1;
    InsertTextFormat2.Snippet = 2;
})($5e7eb5021cd15fec$var$InsertTextFormat || ($5e7eb5021cd15fec$var$InsertTextFormat = {}));
var $5e7eb5021cd15fec$var$CompletionItemTag;
(function(CompletionItemTag2) {
    CompletionItemTag2.Deprecated = 1;
})($5e7eb5021cd15fec$var$CompletionItemTag || ($5e7eb5021cd15fec$var$CompletionItemTag = {}));
var $5e7eb5021cd15fec$var$InsertReplaceEdit;
(function(InsertReplaceEdit2) {
    function create(newText, insert, replace) {
        return {
            newText: newText,
            insert: insert,
            replace: replace
        };
    }
    InsertReplaceEdit2.create = create;
    function is(value) {
        var candidate = value;
        return candidate && $5e7eb5021cd15fec$var$Is.string(candidate.newText) && $5e7eb5021cd15fec$var$Range.is(candidate.insert) && $5e7eb5021cd15fec$var$Range.is(candidate.replace);
    }
    InsertReplaceEdit2.is = is;
})($5e7eb5021cd15fec$var$InsertReplaceEdit || ($5e7eb5021cd15fec$var$InsertReplaceEdit = {}));
var $5e7eb5021cd15fec$var$InsertTextMode;
(function(InsertTextMode2) {
    InsertTextMode2.asIs = 1;
    InsertTextMode2.adjustIndentation = 2;
})($5e7eb5021cd15fec$var$InsertTextMode || ($5e7eb5021cd15fec$var$InsertTextMode = {}));
var $5e7eb5021cd15fec$var$CompletionItem;
(function(CompletionItem2) {
    function create(label) {
        return {
            label: label
        };
    }
    CompletionItem2.create = create;
})($5e7eb5021cd15fec$var$CompletionItem || ($5e7eb5021cd15fec$var$CompletionItem = {}));
var $5e7eb5021cd15fec$var$CompletionList;
(function(CompletionList2) {
    function create(items, isIncomplete) {
        return {
            items: items ? items : [],
            isIncomplete: !!isIncomplete
        };
    }
    CompletionList2.create = create;
})($5e7eb5021cd15fec$var$CompletionList || ($5e7eb5021cd15fec$var$CompletionList = {}));
var $5e7eb5021cd15fec$var$MarkedString;
(function(MarkedString2) {
    function fromPlainText(plainText) {
        return plainText.replace(/[\\`*_{}[\]()#+\-.!]/g, "\\$&");
    }
    MarkedString2.fromPlainText = fromPlainText;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.string(candidate) || $5e7eb5021cd15fec$var$Is.objectLiteral(candidate) && $5e7eb5021cd15fec$var$Is.string(candidate.language) && $5e7eb5021cd15fec$var$Is.string(candidate.value);
    }
    MarkedString2.is = is;
})($5e7eb5021cd15fec$var$MarkedString || ($5e7eb5021cd15fec$var$MarkedString = {}));
var $5e7eb5021cd15fec$var$Hover;
(function(Hover2) {
    function is(value) {
        var candidate = value;
        return !!candidate && $5e7eb5021cd15fec$var$Is.objectLiteral(candidate) && ($5e7eb5021cd15fec$var$MarkupContent.is(candidate.contents) || $5e7eb5021cd15fec$var$MarkedString.is(candidate.contents) || $5e7eb5021cd15fec$var$Is.typedArray(candidate.contents, $5e7eb5021cd15fec$var$MarkedString.is)) && (value.range === void 0 || $5e7eb5021cd15fec$var$Range.is(value.range));
    }
    Hover2.is = is;
})($5e7eb5021cd15fec$var$Hover || ($5e7eb5021cd15fec$var$Hover = {}));
var $5e7eb5021cd15fec$var$ParameterInformation;
(function(ParameterInformation2) {
    function create(label, documentation) {
        return documentation ? {
            label: label,
            documentation: documentation
        } : {
            label: label
        };
    }
    ParameterInformation2.create = create;
})($5e7eb5021cd15fec$var$ParameterInformation || ($5e7eb5021cd15fec$var$ParameterInformation = {}));
var $5e7eb5021cd15fec$var$SignatureInformation;
(function(SignatureInformation2) {
    function create(label, documentation) {
        var parameters = [];
        for(var _i = 2; _i < arguments.length; _i++)parameters[_i - 2] = arguments[_i];
        var result = {
            label: label
        };
        if ($5e7eb5021cd15fec$var$Is.defined(documentation)) result.documentation = documentation;
        if ($5e7eb5021cd15fec$var$Is.defined(parameters)) result.parameters = parameters;
        else result.parameters = [];
        return result;
    }
    SignatureInformation2.create = create;
})($5e7eb5021cd15fec$var$SignatureInformation || ($5e7eb5021cd15fec$var$SignatureInformation = {}));
var $5e7eb5021cd15fec$var$DocumentHighlightKind;
(function(DocumentHighlightKind2) {
    DocumentHighlightKind2.Text = 1;
    DocumentHighlightKind2.Read = 2;
    DocumentHighlightKind2.Write = 3;
})($5e7eb5021cd15fec$var$DocumentHighlightKind || ($5e7eb5021cd15fec$var$DocumentHighlightKind = {}));
var $5e7eb5021cd15fec$var$DocumentHighlight;
(function(DocumentHighlight2) {
    function create(range, kind) {
        var result = {
            range: range
        };
        if ($5e7eb5021cd15fec$var$Is.number(kind)) result.kind = kind;
        return result;
    }
    DocumentHighlight2.create = create;
})($5e7eb5021cd15fec$var$DocumentHighlight || ($5e7eb5021cd15fec$var$DocumentHighlight = {}));
var $5e7eb5021cd15fec$var$SymbolKind;
(function(SymbolKind2) {
    SymbolKind2.File = 1;
    SymbolKind2.Module = 2;
    SymbolKind2.Namespace = 3;
    SymbolKind2.Package = 4;
    SymbolKind2.Class = 5;
    SymbolKind2.Method = 6;
    SymbolKind2.Property = 7;
    SymbolKind2.Field = 8;
    SymbolKind2.Constructor = 9;
    SymbolKind2.Enum = 10;
    SymbolKind2.Interface = 11;
    SymbolKind2.Function = 12;
    SymbolKind2.Variable = 13;
    SymbolKind2.Constant = 14;
    SymbolKind2.String = 15;
    SymbolKind2.Number = 16;
    SymbolKind2.Boolean = 17;
    SymbolKind2.Array = 18;
    SymbolKind2.Object = 19;
    SymbolKind2.Key = 20;
    SymbolKind2.Null = 21;
    SymbolKind2.EnumMember = 22;
    SymbolKind2.Struct = 23;
    SymbolKind2.Event = 24;
    SymbolKind2.Operator = 25;
    SymbolKind2.TypeParameter = 26;
})($5e7eb5021cd15fec$var$SymbolKind || ($5e7eb5021cd15fec$var$SymbolKind = {}));
var $5e7eb5021cd15fec$var$SymbolTag;
(function(SymbolTag2) {
    SymbolTag2.Deprecated = 1;
})($5e7eb5021cd15fec$var$SymbolTag || ($5e7eb5021cd15fec$var$SymbolTag = {}));
var $5e7eb5021cd15fec$var$SymbolInformation;
(function(SymbolInformation2) {
    function create(name, kind, range, uri, containerName) {
        var result = {
            name: name,
            kind: kind,
            location: {
                uri: uri,
                range: range
            }
        };
        if (containerName) result.containerName = containerName;
        return result;
    }
    SymbolInformation2.create = create;
})($5e7eb5021cd15fec$var$SymbolInformation || ($5e7eb5021cd15fec$var$SymbolInformation = {}));
var $5e7eb5021cd15fec$var$DocumentSymbol;
(function(DocumentSymbol2) {
    function create(name, detail, kind, range, selectionRange, children) {
        var result = {
            name: name,
            detail: detail,
            kind: kind,
            range: range,
            selectionRange: selectionRange
        };
        if (children !== void 0) result.children = children;
        return result;
    }
    DocumentSymbol2.create = create;
    function is(value) {
        var candidate = value;
        return candidate && $5e7eb5021cd15fec$var$Is.string(candidate.name) && $5e7eb5021cd15fec$var$Is.number(candidate.kind) && $5e7eb5021cd15fec$var$Range.is(candidate.range) && $5e7eb5021cd15fec$var$Range.is(candidate.selectionRange) && (candidate.detail === void 0 || $5e7eb5021cd15fec$var$Is.string(candidate.detail)) && (candidate.deprecated === void 0 || $5e7eb5021cd15fec$var$Is.boolean(candidate.deprecated)) && (candidate.children === void 0 || Array.isArray(candidate.children)) && (candidate.tags === void 0 || Array.isArray(candidate.tags));
    }
    DocumentSymbol2.is = is;
})($5e7eb5021cd15fec$var$DocumentSymbol || ($5e7eb5021cd15fec$var$DocumentSymbol = {}));
var $5e7eb5021cd15fec$var$CodeActionKind;
(function(CodeActionKind2) {
    CodeActionKind2.Empty = "";
    CodeActionKind2.QuickFix = "quickfix";
    CodeActionKind2.Refactor = "refactor";
    CodeActionKind2.RefactorExtract = "refactor.extract";
    CodeActionKind2.RefactorInline = "refactor.inline";
    CodeActionKind2.RefactorRewrite = "refactor.rewrite";
    CodeActionKind2.Source = "source";
    CodeActionKind2.SourceOrganizeImports = "source.organizeImports";
    CodeActionKind2.SourceFixAll = "source.fixAll";
})($5e7eb5021cd15fec$var$CodeActionKind || ($5e7eb5021cd15fec$var$CodeActionKind = {}));
var $5e7eb5021cd15fec$var$CodeActionContext;
(function(CodeActionContext2) {
    function create(diagnostics, only) {
        var result = {
            diagnostics: diagnostics
        };
        if (only !== void 0 && only !== null) result.only = only;
        return result;
    }
    CodeActionContext2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Is.typedArray(candidate.diagnostics, $5e7eb5021cd15fec$var$Diagnostic.is) && (candidate.only === void 0 || $5e7eb5021cd15fec$var$Is.typedArray(candidate.only, $5e7eb5021cd15fec$var$Is.string));
    }
    CodeActionContext2.is = is;
})($5e7eb5021cd15fec$var$CodeActionContext || ($5e7eb5021cd15fec$var$CodeActionContext = {}));
var $5e7eb5021cd15fec$var$CodeAction;
(function(CodeAction2) {
    function create(title, kindOrCommandOrEdit, kind) {
        var result = {
            title: title
        };
        var checkKind = true;
        if (typeof kindOrCommandOrEdit === "string") {
            checkKind = false;
            result.kind = kindOrCommandOrEdit;
        } else if ($5e7eb5021cd15fec$var$Command.is(kindOrCommandOrEdit)) result.command = kindOrCommandOrEdit;
        else result.edit = kindOrCommandOrEdit;
        if (checkKind && kind !== void 0) result.kind = kind;
        return result;
    }
    CodeAction2.create = create;
    function is(value) {
        var candidate = value;
        return candidate && $5e7eb5021cd15fec$var$Is.string(candidate.title) && (candidate.diagnostics === void 0 || $5e7eb5021cd15fec$var$Is.typedArray(candidate.diagnostics, $5e7eb5021cd15fec$var$Diagnostic.is)) && (candidate.kind === void 0 || $5e7eb5021cd15fec$var$Is.string(candidate.kind)) && (candidate.edit !== void 0 || candidate.command !== void 0) && (candidate.command === void 0 || $5e7eb5021cd15fec$var$Command.is(candidate.command)) && (candidate.isPreferred === void 0 || $5e7eb5021cd15fec$var$Is.boolean(candidate.isPreferred)) && (candidate.edit === void 0 || $5e7eb5021cd15fec$var$WorkspaceEdit.is(candidate.edit));
    }
    CodeAction2.is = is;
})($5e7eb5021cd15fec$var$CodeAction || ($5e7eb5021cd15fec$var$CodeAction = {}));
var $5e7eb5021cd15fec$var$CodeLens;
(function(CodeLens2) {
    function create(range, data) {
        var result = {
            range: range
        };
        if ($5e7eb5021cd15fec$var$Is.defined(data)) result.data = data;
        return result;
    }
    CodeLens2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Range.is(candidate.range) && ($5e7eb5021cd15fec$var$Is.undefined(candidate.command) || $5e7eb5021cd15fec$var$Command.is(candidate.command));
    }
    CodeLens2.is = is;
})($5e7eb5021cd15fec$var$CodeLens || ($5e7eb5021cd15fec$var$CodeLens = {}));
var $5e7eb5021cd15fec$var$FormattingOptions;
(function(FormattingOptions2) {
    function create(tabSize, insertSpaces) {
        return {
            tabSize: tabSize,
            insertSpaces: insertSpaces
        };
    }
    FormattingOptions2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Is.uinteger(candidate.tabSize) && $5e7eb5021cd15fec$var$Is.boolean(candidate.insertSpaces);
    }
    FormattingOptions2.is = is;
})($5e7eb5021cd15fec$var$FormattingOptions || ($5e7eb5021cd15fec$var$FormattingOptions = {}));
var $5e7eb5021cd15fec$var$DocumentLink;
(function(DocumentLink2) {
    function create(range, target, data) {
        return {
            range: range,
            target: target,
            data: data
        };
    }
    DocumentLink2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Range.is(candidate.range) && ($5e7eb5021cd15fec$var$Is.undefined(candidate.target) || $5e7eb5021cd15fec$var$Is.string(candidate.target));
    }
    DocumentLink2.is = is;
})($5e7eb5021cd15fec$var$DocumentLink || ($5e7eb5021cd15fec$var$DocumentLink = {}));
var $5e7eb5021cd15fec$var$SelectionRange;
(function(SelectionRange2) {
    function create(range, parent) {
        return {
            range: range,
            parent: parent
        };
    }
    SelectionRange2.create = create;
    function is(value) {
        var candidate = value;
        return candidate !== void 0 && $5e7eb5021cd15fec$var$Range.is(candidate.range) && (candidate.parent === void 0 || SelectionRange2.is(candidate.parent));
    }
    SelectionRange2.is = is;
})($5e7eb5021cd15fec$var$SelectionRange || ($5e7eb5021cd15fec$var$SelectionRange = {}));
var $5e7eb5021cd15fec$var$TextDocument;
(function(TextDocument2) {
    function create(uri, languageId, version, content) {
        return new $5e7eb5021cd15fec$var$FullTextDocument(uri, languageId, version, content);
    }
    TextDocument2.create = create;
    function is(value) {
        var candidate = value;
        return $5e7eb5021cd15fec$var$Is.defined(candidate) && $5e7eb5021cd15fec$var$Is.string(candidate.uri) && ($5e7eb5021cd15fec$var$Is.undefined(candidate.languageId) || $5e7eb5021cd15fec$var$Is.string(candidate.languageId)) && $5e7eb5021cd15fec$var$Is.uinteger(candidate.lineCount) && $5e7eb5021cd15fec$var$Is.func(candidate.getText) && $5e7eb5021cd15fec$var$Is.func(candidate.positionAt) && $5e7eb5021cd15fec$var$Is.func(candidate.offsetAt) ? true : false;
    }
    TextDocument2.is = is;
    function applyEdits(document, edits) {
        var text = document.getText();
        var sortedEdits = mergeSort(edits, function(a, b) {
            var diff = a.range.start.line - b.range.start.line;
            if (diff === 0) return a.range.start.character - b.range.start.character;
            return diff;
        });
        var lastModifiedOffset = text.length;
        for(var i = sortedEdits.length - 1; i >= 0; i--){
            var e = sortedEdits[i];
            var startOffset = document.offsetAt(e.range.start);
            var endOffset = document.offsetAt(e.range.end);
            if (endOffset <= lastModifiedOffset) text = text.substring(0, startOffset) + e.newText + text.substring(endOffset, text.length);
            else throw new Error("Overlapping edit");
            lastModifiedOffset = startOffset;
        }
        return text;
    }
    TextDocument2.applyEdits = applyEdits;
    function mergeSort(data, compare) {
        if (data.length <= 1) return data;
        var p = data.length / 2 | 0;
        var left = data.slice(0, p);
        var right = data.slice(p);
        mergeSort(left, compare);
        mergeSort(right, compare);
        var leftIdx = 0;
        var rightIdx = 0;
        var i = 0;
        while(leftIdx < left.length && rightIdx < right.length){
            var ret = compare(left[leftIdx], right[rightIdx]);
            if (ret <= 0) data[i++] = left[leftIdx++];
            else data[i++] = right[rightIdx++];
        }
        while(leftIdx < left.length)data[i++] = left[leftIdx++];
        while(rightIdx < right.length)data[i++] = right[rightIdx++];
        return data;
    }
})($5e7eb5021cd15fec$var$TextDocument || ($5e7eb5021cd15fec$var$TextDocument = {}));
var $5e7eb5021cd15fec$var$FullTextDocument = function() {
    function FullTextDocument2(uri, languageId, version, content) {
        this._uri = uri;
        this._languageId = languageId;
        this._version = version;
        this._content = content;
        this._lineOffsets = void 0;
    }
    Object.defineProperty(FullTextDocument2.prototype, "uri", {
        get: function() {
            return this._uri;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(FullTextDocument2.prototype, "languageId", {
        get: function() {
            return this._languageId;
        },
        enumerable: false,
        configurable: true
    });
    Object.defineProperty(FullTextDocument2.prototype, "version", {
        get: function() {
            return this._version;
        },
        enumerable: false,
        configurable: true
    });
    FullTextDocument2.prototype.getText = function(range) {
        if (range) {
            var start = this.offsetAt(range.start);
            var end = this.offsetAt(range.end);
            return this._content.substring(start, end);
        }
        return this._content;
    };
    FullTextDocument2.prototype.update = function(event, version) {
        this._content = event.text;
        this._version = version;
        this._lineOffsets = void 0;
    };
    FullTextDocument2.prototype.getLineOffsets = function() {
        if (this._lineOffsets === void 0) {
            var lineOffsets = [];
            var text = this._content;
            var isLineStart = true;
            for(var i = 0; i < text.length; i++){
                if (isLineStart) {
                    lineOffsets.push(i);
                    isLineStart = false;
                }
                var ch = text.charAt(i);
                isLineStart = ch === "\r" || ch === "\n";
                if (ch === "\r" && i + 1 < text.length && text.charAt(i + 1) === "\n") i++;
            }
            if (isLineStart && text.length > 0) lineOffsets.push(text.length);
            this._lineOffsets = lineOffsets;
        }
        return this._lineOffsets;
    };
    FullTextDocument2.prototype.positionAt = function(offset) {
        offset = Math.max(Math.min(offset, this._content.length), 0);
        var lineOffsets = this.getLineOffsets();
        var low = 0, high = lineOffsets.length;
        if (high === 0) return $5e7eb5021cd15fec$var$Position.create(0, offset);
        while(low < high){
            var mid = Math.floor((low + high) / 2);
            if (lineOffsets[mid] > offset) high = mid;
            else low = mid + 1;
        }
        var line = low - 1;
        return $5e7eb5021cd15fec$var$Position.create(line, offset - lineOffsets[line]);
    };
    FullTextDocument2.prototype.offsetAt = function(position) {
        var lineOffsets = this.getLineOffsets();
        if (position.line >= lineOffsets.length) return this._content.length;
        else if (position.line < 0) return 0;
        var lineOffset = lineOffsets[position.line];
        var nextLineOffset = position.line + 1 < lineOffsets.length ? lineOffsets[position.line + 1] : this._content.length;
        return Math.max(Math.min(lineOffset + position.character, nextLineOffset), lineOffset);
    };
    Object.defineProperty(FullTextDocument2.prototype, "lineCount", {
        get: function() {
            return this.getLineOffsets().length;
        },
        enumerable: false,
        configurable: true
    });
    return FullTextDocument2;
}();
var $5e7eb5021cd15fec$var$Is;
(function(Is2) {
    var toString = Object.prototype.toString;
    function defined(value) {
        return typeof value !== "undefined";
    }
    Is2.defined = defined;
    function undefined2(value) {
        return typeof value === "undefined";
    }
    Is2.undefined = undefined2;
    function boolean(value) {
        return value === true || value === false;
    }
    Is2.boolean = boolean;
    function string(value) {
        return toString.call(value) === "[object String]";
    }
    Is2.string = string;
    function number(value) {
        return toString.call(value) === "[object Number]";
    }
    Is2.number = number;
    function numberRange(value, min, max) {
        return toString.call(value) === "[object Number]" && min <= value && value <= max;
    }
    Is2.numberRange = numberRange;
    function integer2(value) {
        return toString.call(value) === "[object Number]" && -2147483648 <= value && value <= 2147483647;
    }
    Is2.integer = integer2;
    function uinteger2(value) {
        return toString.call(value) === "[object Number]" && 0 <= value && value <= 2147483647;
    }
    Is2.uinteger = uinteger2;
    function func(value) {
        return toString.call(value) === "[object Function]";
    }
    Is2.func = func;
    function objectLiteral(value) {
        return value !== null && typeof value === "object";
    }
    Is2.objectLiteral = objectLiteral;
    function typedArray(value, check) {
        return Array.isArray(value) && value.every(check);
    }
    Is2.typedArray = typedArray;
})($5e7eb5021cd15fec$var$Is || ($5e7eb5021cd15fec$var$Is = {}));
// src/common/lspLanguageFeatures.ts
var $5e7eb5021cd15fec$var$DiagnosticsAdapter = class {
    constructor(_languageId, _worker, configChangeEvent){
        this._languageId = _languageId;
        this._worker = _worker;
        this._disposables = [];
        this._listener = Object.create(null);
        const onModelAdd = (model)=>{
            let modeId = model.getLanguageId();
            if (modeId !== this._languageId) return;
            let handle;
            this._listener[model.uri.toString()] = model.onDidChangeContent(()=>{
                window.clearTimeout(handle);
                handle = window.setTimeout(()=>this._doValidate(model.uri, modeId)
                , 500);
            });
            this._doValidate(model.uri, modeId);
        };
        const onModelRemoved = (model)=>{
            $5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.setModelMarkers(model, this._languageId, []);
            let uriStr = model.uri.toString();
            let listener = this._listener[uriStr];
            if (listener) {
                listener.dispose();
                delete this._listener[uriStr];
            }
        };
        this._disposables.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.onDidCreateModel(onModelAdd));
        this._disposables.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.onWillDisposeModel(onModelRemoved));
        this._disposables.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.onDidChangeModelLanguage((event)=>{
            onModelRemoved(event.model);
            onModelAdd(event.model);
        }));
        this._disposables.push(configChangeEvent((_)=>{
            $5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.getModels().forEach((model)=>{
                if (model.getLanguageId() === this._languageId) {
                    onModelRemoved(model);
                    onModelAdd(model);
                }
            });
        }));
        this._disposables.push({
            dispose: ()=>{
                $5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.getModels().forEach(onModelRemoved);
                for(let key in this._listener)this._listener[key].dispose();
            }
        });
        $5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.getModels().forEach(onModelAdd);
    }
    dispose() {
        this._disposables.forEach((d)=>d && d.dispose()
        );
        this._disposables.length = 0;
    }
    _doValidate(resource, languageId) {
        this._worker(resource).then((worker)=>{
            return worker.doValidation(resource.toString());
        }).then((diagnostics)=>{
            const markers = diagnostics.map((d)=>$5e7eb5021cd15fec$var$toDiagnostics(resource, d)
            );
            let model = $5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.getModel(resource);
            if (model && model.getLanguageId() === languageId) $5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.setModelMarkers(model, languageId, markers);
        }).then(void 0, (err)=>{
            console.error(err);
        });
    }
};
function $5e7eb5021cd15fec$var$toSeverity(lsSeverity) {
    switch(lsSeverity){
        case $5e7eb5021cd15fec$var$DiagnosticSeverity.Error:
            return $5e7eb5021cd15fec$var$monaco_editor_core_exports.MarkerSeverity.Error;
        case $5e7eb5021cd15fec$var$DiagnosticSeverity.Warning:
            return $5e7eb5021cd15fec$var$monaco_editor_core_exports.MarkerSeverity.Warning;
        case $5e7eb5021cd15fec$var$DiagnosticSeverity.Information:
            return $5e7eb5021cd15fec$var$monaco_editor_core_exports.MarkerSeverity.Info;
        case $5e7eb5021cd15fec$var$DiagnosticSeverity.Hint:
            return $5e7eb5021cd15fec$var$monaco_editor_core_exports.MarkerSeverity.Hint;
        default:
            return $5e7eb5021cd15fec$var$monaco_editor_core_exports.MarkerSeverity.Info;
    }
}
function $5e7eb5021cd15fec$var$toDiagnostics(resource, diag) {
    let code = typeof diag.code === "number" ? String(diag.code) : diag.code;
    return {
        severity: $5e7eb5021cd15fec$var$toSeverity(diag.severity),
        startLineNumber: diag.range.start.line + 1,
        startColumn: diag.range.start.character + 1,
        endLineNumber: diag.range.end.line + 1,
        endColumn: diag.range.end.character + 1,
        message: diag.message,
        code: code,
        source: diag.source
    };
}
var $5e7eb5021cd15fec$var$CompletionAdapter = class {
    constructor(_worker, _triggerCharacters){
        this._worker = _worker;
        this._triggerCharacters = _triggerCharacters;
    }
    get triggerCharacters() {
        return this._triggerCharacters;
    }
    provideCompletionItems(model, position, context, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>{
            return worker.doComplete(resource.toString(), $5e7eb5021cd15fec$var$fromPosition(position));
        }).then((info)=>{
            if (!info) return;
            const wordInfo = model.getWordUntilPosition(position);
            const wordRange = new $5e7eb5021cd15fec$var$monaco_editor_core_exports.Range(position.lineNumber, wordInfo.startColumn, position.lineNumber, wordInfo.endColumn);
            const items = info.items.map((entry)=>{
                const item = {
                    label: entry.label,
                    insertText: entry.insertText || entry.label,
                    sortText: entry.sortText,
                    filterText: entry.filterText,
                    documentation: entry.documentation,
                    detail: entry.detail,
                    command: $5e7eb5021cd15fec$var$toCommand(entry.command),
                    range: wordRange,
                    kind: $5e7eb5021cd15fec$var$toCompletionItemKind(entry.kind)
                };
                if (entry.textEdit) {
                    if ($5e7eb5021cd15fec$var$isInsertReplaceEdit(entry.textEdit)) item.range = {
                        insert: $5e7eb5021cd15fec$var$toRange(entry.textEdit.insert),
                        replace: $5e7eb5021cd15fec$var$toRange(entry.textEdit.replace)
                    };
                    else item.range = $5e7eb5021cd15fec$var$toRange(entry.textEdit.range);
                    item.insertText = entry.textEdit.newText;
                }
                if (entry.additionalTextEdits) item.additionalTextEdits = entry.additionalTextEdits.map($5e7eb5021cd15fec$var$toTextEdit);
                if (entry.insertTextFormat === $5e7eb5021cd15fec$var$InsertTextFormat.Snippet) item.insertTextRules = $5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.CompletionItemInsertTextRule.InsertAsSnippet;
                return item;
            });
            return {
                isIncomplete: info.isIncomplete,
                suggestions: items
            };
        });
    }
};
function $5e7eb5021cd15fec$var$fromPosition(position) {
    if (!position) return void 0;
    return {
        character: position.column - 1,
        line: position.lineNumber - 1
    };
}
function $5e7eb5021cd15fec$var$fromRange(range) {
    if (!range) return void 0;
    return {
        start: {
            line: range.startLineNumber - 1,
            character: range.startColumn - 1
        },
        end: {
            line: range.endLineNumber - 1,
            character: range.endColumn - 1
        }
    };
}
function $5e7eb5021cd15fec$var$toRange(range) {
    if (!range) return void 0;
    return new $5e7eb5021cd15fec$var$monaco_editor_core_exports.Range(range.start.line + 1, range.start.character + 1, range.end.line + 1, range.end.character + 1);
}
function $5e7eb5021cd15fec$var$isInsertReplaceEdit(edit2) {
    return typeof edit2.insert !== "undefined" && typeof edit2.replace !== "undefined";
}
function $5e7eb5021cd15fec$var$toCompletionItemKind(kind) {
    const mItemKind = $5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.CompletionItemKind;
    switch(kind){
        case $5e7eb5021cd15fec$var$CompletionItemKind.Text:
            return mItemKind.Text;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Method:
            return mItemKind.Method;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Function:
            return mItemKind.Function;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Constructor:
            return mItemKind.Constructor;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Field:
            return mItemKind.Field;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Variable:
            return mItemKind.Variable;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Class:
            return mItemKind.Class;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Interface:
            return mItemKind.Interface;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Module:
            return mItemKind.Module;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Property:
            return mItemKind.Property;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Unit:
            return mItemKind.Unit;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Value:
            return mItemKind.Value;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Enum:
            return mItemKind.Enum;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Keyword:
            return mItemKind.Keyword;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Snippet:
            return mItemKind.Snippet;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Color:
            return mItemKind.Color;
        case $5e7eb5021cd15fec$var$CompletionItemKind.File:
            return mItemKind.File;
        case $5e7eb5021cd15fec$var$CompletionItemKind.Reference:
            return mItemKind.Reference;
    }
    return mItemKind.Property;
}
function $5e7eb5021cd15fec$var$toTextEdit(textEdit) {
    if (!textEdit) return void 0;
    return {
        range: $5e7eb5021cd15fec$var$toRange(textEdit.range),
        text: textEdit.newText
    };
}
function $5e7eb5021cd15fec$var$toCommand(c) {
    return c && c.command === "editor.action.triggerSuggest" ? {
        id: c.command,
        title: c.title,
        arguments: c.arguments
    } : void 0;
}
var $5e7eb5021cd15fec$var$HoverAdapter = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideHover(model, position, token) {
        let resource = model.uri;
        return this._worker(resource).then((worker)=>{
            return worker.doHover(resource.toString(), $5e7eb5021cd15fec$var$fromPosition(position));
        }).then((info)=>{
            if (!info) return;
            return {
                range: $5e7eb5021cd15fec$var$toRange(info.range),
                contents: $5e7eb5021cd15fec$var$toMarkedStringArray(info.contents)
            };
        });
    }
};
function $5e7eb5021cd15fec$var$isMarkupContent(thing) {
    return thing && typeof thing === "object" && typeof thing.kind === "string";
}
function $5e7eb5021cd15fec$var$toMarkdownString(entry) {
    if (typeof entry === "string") return {
        value: entry
    };
    if ($5e7eb5021cd15fec$var$isMarkupContent(entry)) {
        if (entry.kind === "plaintext") return {
            value: entry.value.replace(/[\\`*_{}[\]()#+\-.!]/g, "\\$&")
        };
        return {
            value: entry.value
        };
    }
    return {
        value: "```" + entry.language + "\n" + entry.value + "\n```\n"
    };
}
function $5e7eb5021cd15fec$var$toMarkedStringArray(contents) {
    if (!contents) return void 0;
    if (Array.isArray(contents)) return contents.map($5e7eb5021cd15fec$var$toMarkdownString);
    return [
        $5e7eb5021cd15fec$var$toMarkdownString(contents)
    ];
}
var $5e7eb5021cd15fec$var$DocumentSymbolAdapter = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideDocumentSymbols(model, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>worker.findDocumentSymbols(resource.toString())
        ).then((items)=>{
            if (!items) return;
            return items.map((item)=>({
                    name: item.name,
                    detail: "",
                    containerName: item.containerName,
                    kind: $5e7eb5021cd15fec$var$toSymbolKind(item.kind),
                    range: $5e7eb5021cd15fec$var$toRange(item.location.range),
                    selectionRange: $5e7eb5021cd15fec$var$toRange(item.location.range),
                    tags: []
                })
            );
        });
    }
};
function $5e7eb5021cd15fec$var$toSymbolKind(kind) {
    let mKind = $5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.SymbolKind;
    switch(kind){
        case $5e7eb5021cd15fec$var$SymbolKind.File:
            return mKind.Array;
        case $5e7eb5021cd15fec$var$SymbolKind.Module:
            return mKind.Module;
        case $5e7eb5021cd15fec$var$SymbolKind.Namespace:
            return mKind.Namespace;
        case $5e7eb5021cd15fec$var$SymbolKind.Package:
            return mKind.Package;
        case $5e7eb5021cd15fec$var$SymbolKind.Class:
            return mKind.Class;
        case $5e7eb5021cd15fec$var$SymbolKind.Method:
            return mKind.Method;
        case $5e7eb5021cd15fec$var$SymbolKind.Property:
            return mKind.Property;
        case $5e7eb5021cd15fec$var$SymbolKind.Field:
            return mKind.Field;
        case $5e7eb5021cd15fec$var$SymbolKind.Constructor:
            return mKind.Constructor;
        case $5e7eb5021cd15fec$var$SymbolKind.Enum:
            return mKind.Enum;
        case $5e7eb5021cd15fec$var$SymbolKind.Interface:
            return mKind.Interface;
        case $5e7eb5021cd15fec$var$SymbolKind.Function:
            return mKind.Function;
        case $5e7eb5021cd15fec$var$SymbolKind.Variable:
            return mKind.Variable;
        case $5e7eb5021cd15fec$var$SymbolKind.Constant:
            return mKind.Constant;
        case $5e7eb5021cd15fec$var$SymbolKind.String:
            return mKind.String;
        case $5e7eb5021cd15fec$var$SymbolKind.Number:
            return mKind.Number;
        case $5e7eb5021cd15fec$var$SymbolKind.Boolean:
            return mKind.Boolean;
        case $5e7eb5021cd15fec$var$SymbolKind.Array:
            return mKind.Array;
    }
    return mKind.Function;
}
var $5e7eb5021cd15fec$var$DocumentFormattingEditProvider = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideDocumentFormattingEdits(model, options, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>{
            return worker.format(resource.toString(), null, $5e7eb5021cd15fec$var$fromFormattingOptions(options)).then((edits)=>{
                if (!edits || edits.length === 0) return;
                return edits.map($5e7eb5021cd15fec$var$toTextEdit);
            });
        });
    }
};
var $5e7eb5021cd15fec$var$DocumentRangeFormattingEditProvider = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideDocumentRangeFormattingEdits(model, range, options, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>{
            return worker.format(resource.toString(), $5e7eb5021cd15fec$var$fromRange(range), $5e7eb5021cd15fec$var$fromFormattingOptions(options)).then((edits)=>{
                if (!edits || edits.length === 0) return;
                return edits.map($5e7eb5021cd15fec$var$toTextEdit);
            });
        });
    }
};
function $5e7eb5021cd15fec$var$fromFormattingOptions(options) {
    return {
        tabSize: options.tabSize,
        insertSpaces: options.insertSpaces
    };
}
var $5e7eb5021cd15fec$var$DocumentColorAdapter = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideDocumentColors(model, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>worker.findDocumentColors(resource.toString())
        ).then((infos)=>{
            if (!infos) return;
            return infos.map((item)=>({
                    color: item.color,
                    range: $5e7eb5021cd15fec$var$toRange(item.range)
                })
            );
        });
    }
    provideColorPresentations(model, info, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>worker.getColorPresentations(resource.toString(), info.color, $5e7eb5021cd15fec$var$fromRange(info.range))
        ).then((presentations)=>{
            if (!presentations) return;
            return presentations.map((presentation)=>{
                let item = {
                    label: presentation.label
                };
                if (presentation.textEdit) item.textEdit = $5e7eb5021cd15fec$var$toTextEdit(presentation.textEdit);
                if (presentation.additionalTextEdits) item.additionalTextEdits = presentation.additionalTextEdits.map($5e7eb5021cd15fec$var$toTextEdit);
                return item;
            });
        });
    }
};
var $5e7eb5021cd15fec$var$FoldingRangeAdapter = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideFoldingRanges(model, context, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>worker.getFoldingRanges(resource.toString(), context)
        ).then((ranges)=>{
            if (!ranges) return;
            return ranges.map((range)=>{
                const result = {
                    start: range.startLine + 1,
                    end: range.endLine + 1
                };
                if (typeof range.kind !== "undefined") result.kind = $5e7eb5021cd15fec$var$toFoldingRangeKind(range.kind);
                return result;
            });
        });
    }
};
function $5e7eb5021cd15fec$var$toFoldingRangeKind(kind) {
    switch(kind){
        case $5e7eb5021cd15fec$var$FoldingRangeKind.Comment:
            return $5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.FoldingRangeKind.Comment;
        case $5e7eb5021cd15fec$var$FoldingRangeKind.Imports:
            return $5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.FoldingRangeKind.Imports;
        case $5e7eb5021cd15fec$var$FoldingRangeKind.Region:
            return $5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.FoldingRangeKind.Region;
    }
    return void 0;
}
var $5e7eb5021cd15fec$var$SelectionRangeAdapter = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideSelectionRanges(model, positions, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>worker.getSelectionRanges(resource.toString(), positions.map($5e7eb5021cd15fec$var$fromPosition))
        ).then((selectionRanges)=>{
            if (!selectionRanges) return;
            return selectionRanges.map((selectionRange)=>{
                const result = [];
                while(selectionRange){
                    result.push({
                        range: $5e7eb5021cd15fec$var$toRange(selectionRange.range)
                    });
                    selectionRange = selectionRange.parent;
                }
                return result;
            });
        });
    }
};
function $5e7eb5021cd15fec$var$createScanner(text, ignoreTrivia) {
    if (ignoreTrivia === void 0) ignoreTrivia = false;
    var len = text.length;
    var pos = 0, value = "", tokenOffset = 0, token = 16, lineNumber = 0, lineStartOffset = 0, tokenLineStartOffset = 0, prevTokenLineStartOffset = 0, scanError = 0;
    function scanHexDigits(count, exact) {
        var digits = 0;
        var value2 = 0;
        while(digits < count || !exact){
            var ch = text.charCodeAt(pos);
            if (ch >= 48 && ch <= 57) value2 = value2 * 16 + ch - 48;
            else if (ch >= 65 && ch <= 70) value2 = value2 * 16 + ch - 65 + 10;
            else if (ch >= 97 && ch <= 102) value2 = value2 * 16 + ch - 97 + 10;
            else break;
            pos++;
            digits++;
        }
        if (digits < count) value2 = -1;
        return value2;
    }
    function setPosition(newPosition) {
        pos = newPosition;
        value = "";
        tokenOffset = 0;
        token = 16;
        scanError = 0;
    }
    function scanNumber() {
        var start = pos;
        if (text.charCodeAt(pos) === 48) pos++;
        else {
            pos++;
            while(pos < text.length && $5e7eb5021cd15fec$var$isDigit(text.charCodeAt(pos)))pos++;
        }
        if (pos < text.length && text.charCodeAt(pos) === 46) {
            pos++;
            if (pos < text.length && $5e7eb5021cd15fec$var$isDigit(text.charCodeAt(pos))) {
                pos++;
                while(pos < text.length && $5e7eb5021cd15fec$var$isDigit(text.charCodeAt(pos)))pos++;
            } else {
                scanError = 3;
                return text.substring(start, pos);
            }
        }
        var end = pos;
        if (pos < text.length && (text.charCodeAt(pos) === 69 || text.charCodeAt(pos) === 101)) {
            pos++;
            if (pos < text.length && text.charCodeAt(pos) === 43 || text.charCodeAt(pos) === 45) pos++;
            if (pos < text.length && $5e7eb5021cd15fec$var$isDigit(text.charCodeAt(pos))) {
                pos++;
                while(pos < text.length && $5e7eb5021cd15fec$var$isDigit(text.charCodeAt(pos)))pos++;
                end = pos;
            } else scanError = 3;
        }
        return text.substring(start, end);
    }
    function scanString() {
        var result = "", start = pos;
        while(true){
            if (pos >= len) {
                result += text.substring(start, pos);
                scanError = 2;
                break;
            }
            var ch = text.charCodeAt(pos);
            if (ch === 34) {
                result += text.substring(start, pos);
                pos++;
                break;
            }
            if (ch === 92) {
                result += text.substring(start, pos);
                pos++;
                if (pos >= len) {
                    scanError = 2;
                    break;
                }
                var ch2 = text.charCodeAt(pos++);
                switch(ch2){
                    case 34:
                        result += '"';
                        break;
                    case 92:
                        result += "\\";
                        break;
                    case 47:
                        result += "/";
                        break;
                    case 98:
                        result += "\b";
                        break;
                    case 102:
                        result += "\f";
                        break;
                    case 110:
                        result += "\n";
                        break;
                    case 114:
                        result += "\r";
                        break;
                    case 116:
                        result += "	";
                        break;
                    case 117:
                        var ch3 = scanHexDigits(4, true);
                        if (ch3 >= 0) result += String.fromCharCode(ch3);
                        else scanError = 4;
                        break;
                    default:
                        scanError = 5;
                }
                start = pos;
                continue;
            }
            if (ch >= 0 && ch <= 31) {
                if ($5e7eb5021cd15fec$var$isLineBreak(ch)) {
                    result += text.substring(start, pos);
                    scanError = 2;
                    break;
                } else scanError = 6;
            }
            pos++;
        }
        return result;
    }
    function scanNext() {
        value = "";
        scanError = 0;
        tokenOffset = pos;
        lineStartOffset = lineNumber;
        prevTokenLineStartOffset = tokenLineStartOffset;
        if (pos >= len) {
            tokenOffset = len;
            return token = 17;
        }
        var code = text.charCodeAt(pos);
        if ($5e7eb5021cd15fec$var$isWhiteSpace(code)) {
            do {
                pos++;
                value += String.fromCharCode(code);
                code = text.charCodeAt(pos);
            }while ($5e7eb5021cd15fec$var$isWhiteSpace(code))
            return token = 15;
        }
        if ($5e7eb5021cd15fec$var$isLineBreak(code)) {
            pos++;
            value += String.fromCharCode(code);
            if (code === 13 && text.charCodeAt(pos) === 10) {
                pos++;
                value += "\n";
            }
            lineNumber++;
            tokenLineStartOffset = pos;
            return token = 14;
        }
        switch(code){
            case 123:
                pos++;
                return token = 1;
            case 125:
                pos++;
                return token = 2;
            case 91:
                pos++;
                return token = 3;
            case 93:
                pos++;
                return token = 4;
            case 58:
                pos++;
                return token = 6;
            case 44:
                pos++;
                return token = 5;
            case 34:
                pos++;
                value = scanString();
                return token = 10;
            case 47:
                var start = pos - 1;
                if (text.charCodeAt(pos + 1) === 47) {
                    pos += 2;
                    while(pos < len){
                        if ($5e7eb5021cd15fec$var$isLineBreak(text.charCodeAt(pos))) break;
                        pos++;
                    }
                    value = text.substring(start, pos);
                    return token = 12;
                }
                if (text.charCodeAt(pos + 1) === 42) {
                    pos += 2;
                    var safeLength = len - 1;
                    var commentClosed = false;
                    while(pos < safeLength){
                        var ch = text.charCodeAt(pos);
                        if (ch === 42 && text.charCodeAt(pos + 1) === 47) {
                            pos += 2;
                            commentClosed = true;
                            break;
                        }
                        pos++;
                        if ($5e7eb5021cd15fec$var$isLineBreak(ch)) {
                            if (ch === 13 && text.charCodeAt(pos) === 10) pos++;
                            lineNumber++;
                            tokenLineStartOffset = pos;
                        }
                    }
                    if (!commentClosed) {
                        pos++;
                        scanError = 1;
                    }
                    value = text.substring(start, pos);
                    return token = 13;
                }
                value += String.fromCharCode(code);
                pos++;
                return token = 16;
            case 45:
                value += String.fromCharCode(code);
                pos++;
                if (pos === len || !$5e7eb5021cd15fec$var$isDigit(text.charCodeAt(pos))) return token = 16;
            case 48:
            case 49:
            case 50:
            case 51:
            case 52:
            case 53:
            case 54:
            case 55:
            case 56:
            case 57:
                value += scanNumber();
                return token = 11;
            default:
                while(pos < len && isUnknownContentCharacter(code)){
                    pos++;
                    code = text.charCodeAt(pos);
                }
                if (tokenOffset !== pos) {
                    value = text.substring(tokenOffset, pos);
                    switch(value){
                        case "true":
                            return token = 8;
                        case "false":
                            return token = 9;
                        case "null":
                            return token = 7;
                    }
                    return token = 16;
                }
                value += String.fromCharCode(code);
                pos++;
                return token = 16;
        }
    }
    function isUnknownContentCharacter(code) {
        if ($5e7eb5021cd15fec$var$isWhiteSpace(code) || $5e7eb5021cd15fec$var$isLineBreak(code)) return false;
        switch(code){
            case 125:
            case 93:
            case 123:
            case 91:
            case 34:
            case 58:
            case 44:
            case 47:
                return false;
        }
        return true;
    }
    function scanNextNonTrivia() {
        var result;
        do result = scanNext();
        while (result >= 12 && result <= 15)
        return result;
    }
    return {
        setPosition: setPosition,
        getPosition: function() {
            return pos;
        },
        scan: ignoreTrivia ? scanNextNonTrivia : scanNext,
        getToken: function() {
            return token;
        },
        getTokenValue: function() {
            return value;
        },
        getTokenOffset: function() {
            return tokenOffset;
        },
        getTokenLength: function() {
            return pos - tokenOffset;
        },
        getTokenStartLine: function() {
            return lineStartOffset;
        },
        getTokenStartCharacter: function() {
            return tokenOffset - prevTokenLineStartOffset;
        },
        getTokenError: function() {
            return scanError;
        }
    };
}
function $5e7eb5021cd15fec$var$isWhiteSpace(ch) {
    return ch === 32 || ch === 9 || ch === 11 || ch === 12 || ch === 160 || ch === 5760 || ch >= 8192 && ch <= 8203 || ch === 8239 || ch === 8287 || ch === 12288 || ch === 65279;
}
function $5e7eb5021cd15fec$var$isLineBreak(ch) {
    return ch === 10 || ch === 13 || ch === 8232 || ch === 8233;
}
function $5e7eb5021cd15fec$var$isDigit(ch) {
    return ch >= 48 && ch <= 57;
}
var $5e7eb5021cd15fec$var$ParseOptions;
(function(ParseOptions2) {
    ParseOptions2.DEFAULT = {
        allowTrailingComma: false
    };
})($5e7eb5021cd15fec$var$ParseOptions || ($5e7eb5021cd15fec$var$ParseOptions = {}));
var $5e7eb5021cd15fec$var$createScanner2 = $5e7eb5021cd15fec$var$createScanner;
// src/json/tokenization.ts
function $5e7eb5021cd15fec$var$createTokenizationSupport(supportComments) {
    return {
        getInitialState: ()=>new $5e7eb5021cd15fec$var$JSONState(null, null, false, null)
        ,
        tokenize: (line, state)=>$5e7eb5021cd15fec$var$tokenize(supportComments, line, state)
    };
}
var $5e7eb5021cd15fec$var$TOKEN_DELIM_OBJECT = "delimiter.bracket.json";
var $5e7eb5021cd15fec$var$TOKEN_DELIM_ARRAY = "delimiter.array.json";
var $5e7eb5021cd15fec$var$TOKEN_DELIM_COLON = "delimiter.colon.json";
var $5e7eb5021cd15fec$var$TOKEN_DELIM_COMMA = "delimiter.comma.json";
var $5e7eb5021cd15fec$var$TOKEN_VALUE_BOOLEAN = "keyword.json";
var $5e7eb5021cd15fec$var$TOKEN_VALUE_NULL = "keyword.json";
var $5e7eb5021cd15fec$var$TOKEN_VALUE_STRING = "string.value.json";
var $5e7eb5021cd15fec$var$TOKEN_VALUE_NUMBER = "number.json";
var $5e7eb5021cd15fec$var$TOKEN_PROPERTY_NAME = "string.key.json";
var $5e7eb5021cd15fec$var$TOKEN_COMMENT_BLOCK = "comment.block.json";
var $5e7eb5021cd15fec$var$TOKEN_COMMENT_LINE = "comment.line.json";
var $5e7eb5021cd15fec$var$JSONParent;
(function(JSONParent2) {
    JSONParent2[JSONParent2["Object"] = 0] = "Object";
    JSONParent2[JSONParent2["Array"] = 1] = "Array";
})($5e7eb5021cd15fec$var$JSONParent || ($5e7eb5021cd15fec$var$JSONParent = {}));
var $5e7eb5021cd15fec$var$ParentsStack = class {
    constructor(parent, type){
        this.parent = parent;
        this.type = type;
    }
    static pop(parents) {
        if (parents) return parents.parent;
        return null;
    }
    static push(parents, type) {
        return new $5e7eb5021cd15fec$var$ParentsStack(parents, type);
    }
    static equals(a, b) {
        if (!a && !b) return true;
        if (!a || !b) return false;
        while(a && b){
            if (a === b) return true;
            if (a.type !== b.type) return false;
            a = a.parent;
            b = b.parent;
        }
        return true;
    }
};
var $5e7eb5021cd15fec$var$JSONState = class {
    constructor(state, scanError, lastWasColon, parents){
        this._state = state;
        this.scanError = scanError;
        this.lastWasColon = lastWasColon;
        this.parents = parents;
    }
    clone() {
        return new $5e7eb5021cd15fec$var$JSONState(this._state, this.scanError, this.lastWasColon, this.parents);
    }
    equals(other) {
        if (other === this) return true;
        if (!other || !(other instanceof $5e7eb5021cd15fec$var$JSONState)) return false;
        return this.scanError === other.scanError && this.lastWasColon === other.lastWasColon && $5e7eb5021cd15fec$var$ParentsStack.equals(this.parents, other.parents);
    }
    getStateData() {
        return this._state;
    }
    setStateData(state) {
        this._state = state;
    }
};
var $5e7eb5021cd15fec$var$ScanError;
(function(ScanError2) {
    ScanError2[ScanError2["None"] = 0] = "None";
    ScanError2[ScanError2["UnexpectedEndOfComment"] = 1] = "UnexpectedEndOfComment";
    ScanError2[ScanError2["UnexpectedEndOfString"] = 2] = "UnexpectedEndOfString";
    ScanError2[ScanError2["UnexpectedEndOfNumber"] = 3] = "UnexpectedEndOfNumber";
    ScanError2[ScanError2["InvalidUnicode"] = 4] = "InvalidUnicode";
    ScanError2[ScanError2["InvalidEscapeCharacter"] = 5] = "InvalidEscapeCharacter";
    ScanError2[ScanError2["InvalidCharacter"] = 6] = "InvalidCharacter";
})($5e7eb5021cd15fec$var$ScanError || ($5e7eb5021cd15fec$var$ScanError = {}));
var $5e7eb5021cd15fec$var$SyntaxKind;
(function(SyntaxKind2) {
    SyntaxKind2[SyntaxKind2["OpenBraceToken"] = 1] = "OpenBraceToken";
    SyntaxKind2[SyntaxKind2["CloseBraceToken"] = 2] = "CloseBraceToken";
    SyntaxKind2[SyntaxKind2["OpenBracketToken"] = 3] = "OpenBracketToken";
    SyntaxKind2[SyntaxKind2["CloseBracketToken"] = 4] = "CloseBracketToken";
    SyntaxKind2[SyntaxKind2["CommaToken"] = 5] = "CommaToken";
    SyntaxKind2[SyntaxKind2["ColonToken"] = 6] = "ColonToken";
    SyntaxKind2[SyntaxKind2["NullKeyword"] = 7] = "NullKeyword";
    SyntaxKind2[SyntaxKind2["TrueKeyword"] = 8] = "TrueKeyword";
    SyntaxKind2[SyntaxKind2["FalseKeyword"] = 9] = "FalseKeyword";
    SyntaxKind2[SyntaxKind2["StringLiteral"] = 10] = "StringLiteral";
    SyntaxKind2[SyntaxKind2["NumericLiteral"] = 11] = "NumericLiteral";
    SyntaxKind2[SyntaxKind2["LineCommentTrivia"] = 12] = "LineCommentTrivia";
    SyntaxKind2[SyntaxKind2["BlockCommentTrivia"] = 13] = "BlockCommentTrivia";
    SyntaxKind2[SyntaxKind2["LineBreakTrivia"] = 14] = "LineBreakTrivia";
    SyntaxKind2[SyntaxKind2["Trivia"] = 15] = "Trivia";
    SyntaxKind2[SyntaxKind2["Unknown"] = 16] = "Unknown";
    SyntaxKind2[SyntaxKind2["EOF"] = 17] = "EOF";
})($5e7eb5021cd15fec$var$SyntaxKind || ($5e7eb5021cd15fec$var$SyntaxKind = {}));
function $5e7eb5021cd15fec$var$tokenize(comments, line, state, offsetDelta = 0) {
    let numberOfInsertedCharacters = 0;
    let adjustOffset = false;
    switch(state.scanError){
        case 2:
            line = '"' + line;
            numberOfInsertedCharacters = 1;
            break;
        case 1:
            line = "/*" + line;
            numberOfInsertedCharacters = 2;
            break;
    }
    const scanner2 = $5e7eb5021cd15fec$var$createScanner2(line);
    let lastWasColon = state.lastWasColon;
    let parents = state.parents;
    const ret = {
        tokens: [],
        endState: state.clone()
    };
    while(true){
        let offset = offsetDelta + scanner2.getPosition();
        let type = "";
        const kind = scanner2.scan();
        if (kind === 17) break;
        if (offset === offsetDelta + scanner2.getPosition()) throw new Error("Scanner did not advance, next 3 characters are: " + line.substr(scanner2.getPosition(), 3));
        if (adjustOffset) offset -= numberOfInsertedCharacters;
        adjustOffset = numberOfInsertedCharacters > 0;
        switch(kind){
            case 1:
                parents = $5e7eb5021cd15fec$var$ParentsStack.push(parents, 0);
                type = $5e7eb5021cd15fec$var$TOKEN_DELIM_OBJECT;
                lastWasColon = false;
                break;
            case 2:
                parents = $5e7eb5021cd15fec$var$ParentsStack.pop(parents);
                type = $5e7eb5021cd15fec$var$TOKEN_DELIM_OBJECT;
                lastWasColon = false;
                break;
            case 3:
                parents = $5e7eb5021cd15fec$var$ParentsStack.push(parents, 1);
                type = $5e7eb5021cd15fec$var$TOKEN_DELIM_ARRAY;
                lastWasColon = false;
                break;
            case 4:
                parents = $5e7eb5021cd15fec$var$ParentsStack.pop(parents);
                type = $5e7eb5021cd15fec$var$TOKEN_DELIM_ARRAY;
                lastWasColon = false;
                break;
            case 6:
                type = $5e7eb5021cd15fec$var$TOKEN_DELIM_COLON;
                lastWasColon = true;
                break;
            case 5:
                type = $5e7eb5021cd15fec$var$TOKEN_DELIM_COMMA;
                lastWasColon = false;
                break;
            case 8:
            case 9:
                type = $5e7eb5021cd15fec$var$TOKEN_VALUE_BOOLEAN;
                lastWasColon = false;
                break;
            case 7:
                type = $5e7eb5021cd15fec$var$TOKEN_VALUE_NULL;
                lastWasColon = false;
                break;
            case 10:
                const currentParent = parents ? parents.type : 0;
                const inArray = currentParent === 1;
                type = lastWasColon || inArray ? $5e7eb5021cd15fec$var$TOKEN_VALUE_STRING : $5e7eb5021cd15fec$var$TOKEN_PROPERTY_NAME;
                lastWasColon = false;
                break;
            case 11:
                type = $5e7eb5021cd15fec$var$TOKEN_VALUE_NUMBER;
                lastWasColon = false;
                break;
        }
        if (comments) switch(kind){
            case 12:
                type = $5e7eb5021cd15fec$var$TOKEN_COMMENT_LINE;
                break;
            case 13:
                type = $5e7eb5021cd15fec$var$TOKEN_COMMENT_BLOCK;
                break;
        }
        ret.endState = new $5e7eb5021cd15fec$var$JSONState(state.getStateData(), scanner2.getTokenError(), lastWasColon, parents);
        ret.tokens.push({
            startIndex: offset,
            scopes: type
        });
    }
    return ret;
}
// src/json/jsonMode.ts
var $5e7eb5021cd15fec$var$JSONDiagnosticsAdapter = class extends $5e7eb5021cd15fec$var$DiagnosticsAdapter {
    constructor(languageId, worker, defaults){
        super(languageId, worker, defaults.onDidChange);
        this._disposables.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.onWillDisposeModel((model)=>{
            this._resetSchema(model.uri);
        }));
        this._disposables.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.editor.onDidChangeModelLanguage((event)=>{
            this._resetSchema(event.model.uri);
        }));
    }
    _resetSchema(resource) {
        this._worker().then((worker)=>{
            worker.resetSchema(resource.toString());
        });
    }
};
function $5e7eb5021cd15fec$export$6df00d141df42469(defaults) {
    const disposables = [];
    const providers = [];
    const client = new $5e7eb5021cd15fec$var$WorkerManager(defaults);
    disposables.push(client);
    const worker = (...uris)=>{
        return client.getLanguageServiceWorker(...uris);
    };
    function registerProviders() {
        const { languageId: languageId , modeConfiguration: modeConfiguration2  } = defaults;
        $5e7eb5021cd15fec$var$disposeAll(providers);
        if (modeConfiguration2.documentFormattingEdits) providers.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.registerDocumentFormattingEditProvider(languageId, new $5e7eb5021cd15fec$var$DocumentFormattingEditProvider(worker)));
        if (modeConfiguration2.documentRangeFormattingEdits) providers.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.registerDocumentRangeFormattingEditProvider(languageId, new $5e7eb5021cd15fec$var$DocumentRangeFormattingEditProvider(worker)));
        if (modeConfiguration2.completionItems) providers.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.registerCompletionItemProvider(languageId, new $5e7eb5021cd15fec$var$CompletionAdapter(worker, [
            " ",
            ":",
            '"'
        ])));
        if (modeConfiguration2.hovers) providers.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.registerHoverProvider(languageId, new $5e7eb5021cd15fec$var$HoverAdapter(worker)));
        if (modeConfiguration2.documentSymbols) providers.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.registerDocumentSymbolProvider(languageId, new $5e7eb5021cd15fec$var$DocumentSymbolAdapter(worker)));
        if (modeConfiguration2.tokens) providers.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.setTokensProvider(languageId, $5e7eb5021cd15fec$var$createTokenizationSupport(true)));
        if (modeConfiguration2.colors) providers.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.registerColorProvider(languageId, new $5e7eb5021cd15fec$var$DocumentColorAdapter(worker)));
        if (modeConfiguration2.foldingRanges) providers.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.registerFoldingRangeProvider(languageId, new $5e7eb5021cd15fec$var$FoldingRangeAdapter(worker)));
        if (modeConfiguration2.diagnostics) providers.push(new $5e7eb5021cd15fec$var$JSONDiagnosticsAdapter(languageId, worker, defaults));
        if (modeConfiguration2.selectionRanges) providers.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.registerSelectionRangeProvider(languageId, new $5e7eb5021cd15fec$var$SelectionRangeAdapter(worker)));
    }
    registerProviders();
    disposables.push($5e7eb5021cd15fec$var$monaco_editor_core_exports.languages.setLanguageConfiguration(defaults.languageId, $5e7eb5021cd15fec$var$richEditConfiguration));
    let modeConfiguration = defaults.modeConfiguration;
    defaults.onDidChange((newDefaults)=>{
        if (newDefaults.modeConfiguration !== modeConfiguration) {
            modeConfiguration = newDefaults.modeConfiguration;
            registerProviders();
        }
    });
    disposables.push($5e7eb5021cd15fec$var$asDisposable(providers));
    return $5e7eb5021cd15fec$var$asDisposable(disposables);
}
function $5e7eb5021cd15fec$var$asDisposable(disposables) {
    return {
        dispose: ()=>$5e7eb5021cd15fec$var$disposeAll(disposables)
    };
}
function $5e7eb5021cd15fec$var$disposeAll(disposables) {
    while(disposables.length)disposables.pop().dispose();
}
var $5e7eb5021cd15fec$var$richEditConfiguration = {
    wordPattern: /(-?\d*\.\d\w*)|([^\[\{\]\}\:\"\,\s]+)/g,
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
        ]
    ],
    autoClosingPairs: [
        {
            open: "{",
            close: "}",
            notIn: [
                "string"
            ]
        },
        {
            open: "[",
            close: "]",
            notIn: [
                "string"
            ]
        },
        {
            open: '"',
            close: '"',
            notIn: [
                "string"
            ]
        }
    ]
};

});


//# sourceMappingURL=jsonMode.ec2b9a52.js.map
