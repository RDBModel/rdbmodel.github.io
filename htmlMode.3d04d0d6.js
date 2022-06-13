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
parcelRequire.register("gbMUR", function(module, exports) {

$parcel$export(module.exports, "setupMode1", () => $bc939e250b70dd70$export$972c61cff7b1bac7);
$parcel$export(module.exports, "setupMode", () => $bc939e250b70dd70$export$6df00d141df42469);

var $leKFq = parcelRequire("leKFq");
// node_modules/vscode-languageserver-types/lib/esm/main.js
"use strict";
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/ var $bc939e250b70dd70$var$__defProp = Object.defineProperty;
var $bc939e250b70dd70$var$__getOwnPropDesc = Object.getOwnPropertyDescriptor;
var $bc939e250b70dd70$var$__getOwnPropNames = Object.getOwnPropertyNames;
var $bc939e250b70dd70$var$__hasOwnProp = Object.prototype.hasOwnProperty;
var $bc939e250b70dd70$var$__markAsModule = (target)=>$bc939e250b70dd70$var$__defProp(target, "__esModule", {
        value: true
    })
;
var $bc939e250b70dd70$var$__reExport = (target, module, desc)=>{
    if (module && typeof module === "object" || typeof module === "function") {
        for (let key of $bc939e250b70dd70$var$__getOwnPropNames(module))if (!$bc939e250b70dd70$var$__hasOwnProp.call(target, key) && key !== "default") $bc939e250b70dd70$var$__defProp(target, key, {
            get: ()=>module[key]
            ,
            enumerable: !(desc = $bc939e250b70dd70$var$__getOwnPropDesc(module, key)) || desc.enumerable
        });
    }
    return target;
};
// src/fillers/monaco-editor-core.ts
var $bc939e250b70dd70$var$monaco_editor_core_exports = {};
$bc939e250b70dd70$var$__markAsModule($bc939e250b70dd70$var$monaco_editor_core_exports);
$bc939e250b70dd70$var$__reExport($bc939e250b70dd70$var$monaco_editor_core_exports, $leKFq);
// src/html/workerManager.ts
var $bc939e250b70dd70$var$STOP_WHEN_IDLE_FOR = 120000;
var $bc939e250b70dd70$var$WorkerManager = class {
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
        if (timePassedSinceLastUsed > $bc939e250b70dd70$var$STOP_WHEN_IDLE_FOR) this._stopWorker();
    }
    _getClient() {
        this._lastUsedTime = Date.now();
        if (!this._client) {
            this._worker = $bc939e250b70dd70$var$monaco_editor_core_exports.editor.createWebWorker({
                moduleId: "vs/language/html/htmlWorker",
                createData: {
                    languageSettings: this._defaults.options,
                    languageId: this._defaults.languageId
                },
                label: this._defaults.languageId
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
var $bc939e250b70dd70$var$integer;
(function(integer2) {
    integer2.MIN_VALUE = -2147483648;
    integer2.MAX_VALUE = 2147483647;
})($bc939e250b70dd70$var$integer || ($bc939e250b70dd70$var$integer = {}));
var $bc939e250b70dd70$var$uinteger;
(function(uinteger2) {
    uinteger2.MIN_VALUE = 0;
    uinteger2.MAX_VALUE = 2147483647;
})($bc939e250b70dd70$var$uinteger || ($bc939e250b70dd70$var$uinteger = {}));
var $bc939e250b70dd70$var$Position;
(function(Position3) {
    function create(line, character) {
        if (line === Number.MAX_VALUE) line = $bc939e250b70dd70$var$uinteger.MAX_VALUE;
        if (character === Number.MAX_VALUE) character = $bc939e250b70dd70$var$uinteger.MAX_VALUE;
        return {
            line: line,
            character: character
        };
    }
    Position3.create = create;
    function is(value) {
        var candidate = value;
        return $bc939e250b70dd70$var$Is.objectLiteral(candidate) && $bc939e250b70dd70$var$Is.uinteger(candidate.line) && $bc939e250b70dd70$var$Is.uinteger(candidate.character);
    }
    Position3.is = is;
})($bc939e250b70dd70$var$Position || ($bc939e250b70dd70$var$Position = {}));
var $bc939e250b70dd70$var$Range;
(function(Range3) {
    function create(one, two, three, four) {
        if ($bc939e250b70dd70$var$Is.uinteger(one) && $bc939e250b70dd70$var$Is.uinteger(two) && $bc939e250b70dd70$var$Is.uinteger(three) && $bc939e250b70dd70$var$Is.uinteger(four)) return {
            start: $bc939e250b70dd70$var$Position.create(one, two),
            end: $bc939e250b70dd70$var$Position.create(three, four)
        };
        else if ($bc939e250b70dd70$var$Position.is(one) && $bc939e250b70dd70$var$Position.is(two)) return {
            start: one,
            end: two
        };
        else throw new Error("Range#create called with invalid arguments[" + one + ", " + two + ", " + three + ", " + four + "]");
    }
    Range3.create = create;
    function is(value) {
        var candidate = value;
        return $bc939e250b70dd70$var$Is.objectLiteral(candidate) && $bc939e250b70dd70$var$Position.is(candidate.start) && $bc939e250b70dd70$var$Position.is(candidate.end);
    }
    Range3.is = is;
})($bc939e250b70dd70$var$Range || ($bc939e250b70dd70$var$Range = {}));
var $bc939e250b70dd70$var$Location;
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
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Range.is(candidate.range) && ($bc939e250b70dd70$var$Is.string(candidate.uri) || $bc939e250b70dd70$var$Is.undefined(candidate.uri));
    }
    Location2.is = is;
})($bc939e250b70dd70$var$Location || ($bc939e250b70dd70$var$Location = {}));
var $bc939e250b70dd70$var$LocationLink;
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
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Range.is(candidate.targetRange) && $bc939e250b70dd70$var$Is.string(candidate.targetUri) && ($bc939e250b70dd70$var$Range.is(candidate.targetSelectionRange) || $bc939e250b70dd70$var$Is.undefined(candidate.targetSelectionRange)) && ($bc939e250b70dd70$var$Range.is(candidate.originSelectionRange) || $bc939e250b70dd70$var$Is.undefined(candidate.originSelectionRange));
    }
    LocationLink2.is = is;
})($bc939e250b70dd70$var$LocationLink || ($bc939e250b70dd70$var$LocationLink = {}));
var $bc939e250b70dd70$var$Color;
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
        return $bc939e250b70dd70$var$Is.numberRange(candidate.red, 0, 1) && $bc939e250b70dd70$var$Is.numberRange(candidate.green, 0, 1) && $bc939e250b70dd70$var$Is.numberRange(candidate.blue, 0, 1) && $bc939e250b70dd70$var$Is.numberRange(candidate.alpha, 0, 1);
    }
    Color2.is = is;
})($bc939e250b70dd70$var$Color || ($bc939e250b70dd70$var$Color = {}));
var $bc939e250b70dd70$var$ColorInformation;
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
        return $bc939e250b70dd70$var$Range.is(candidate.range) && $bc939e250b70dd70$var$Color.is(candidate.color);
    }
    ColorInformation2.is = is;
})($bc939e250b70dd70$var$ColorInformation || ($bc939e250b70dd70$var$ColorInformation = {}));
var $bc939e250b70dd70$var$ColorPresentation;
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
        return $bc939e250b70dd70$var$Is.string(candidate.label) && ($bc939e250b70dd70$var$Is.undefined(candidate.textEdit) || $bc939e250b70dd70$var$TextEdit.is(candidate)) && ($bc939e250b70dd70$var$Is.undefined(candidate.additionalTextEdits) || $bc939e250b70dd70$var$Is.typedArray(candidate.additionalTextEdits, $bc939e250b70dd70$var$TextEdit.is));
    }
    ColorPresentation2.is = is;
})($bc939e250b70dd70$var$ColorPresentation || ($bc939e250b70dd70$var$ColorPresentation = {}));
var $bc939e250b70dd70$var$FoldingRangeKind;
(function(FoldingRangeKind2) {
    FoldingRangeKind2["Comment"] = "comment";
    FoldingRangeKind2["Imports"] = "imports";
    FoldingRangeKind2["Region"] = "region";
})($bc939e250b70dd70$var$FoldingRangeKind || ($bc939e250b70dd70$var$FoldingRangeKind = {}));
var $bc939e250b70dd70$var$FoldingRange;
(function(FoldingRange2) {
    function create(startLine, endLine, startCharacter, endCharacter, kind) {
        var result = {
            startLine: startLine,
            endLine: endLine
        };
        if ($bc939e250b70dd70$var$Is.defined(startCharacter)) result.startCharacter = startCharacter;
        if ($bc939e250b70dd70$var$Is.defined(endCharacter)) result.endCharacter = endCharacter;
        if ($bc939e250b70dd70$var$Is.defined(kind)) result.kind = kind;
        return result;
    }
    FoldingRange2.create = create;
    function is(value) {
        var candidate = value;
        return $bc939e250b70dd70$var$Is.uinteger(candidate.startLine) && $bc939e250b70dd70$var$Is.uinteger(candidate.startLine) && ($bc939e250b70dd70$var$Is.undefined(candidate.startCharacter) || $bc939e250b70dd70$var$Is.uinteger(candidate.startCharacter)) && ($bc939e250b70dd70$var$Is.undefined(candidate.endCharacter) || $bc939e250b70dd70$var$Is.uinteger(candidate.endCharacter)) && ($bc939e250b70dd70$var$Is.undefined(candidate.kind) || $bc939e250b70dd70$var$Is.string(candidate.kind));
    }
    FoldingRange2.is = is;
})($bc939e250b70dd70$var$FoldingRange || ($bc939e250b70dd70$var$FoldingRange = {}));
var $bc939e250b70dd70$var$DiagnosticRelatedInformation;
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
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Location.is(candidate.location) && $bc939e250b70dd70$var$Is.string(candidate.message);
    }
    DiagnosticRelatedInformation2.is = is;
})($bc939e250b70dd70$var$DiagnosticRelatedInformation || ($bc939e250b70dd70$var$DiagnosticRelatedInformation = {}));
var $bc939e250b70dd70$var$DiagnosticSeverity;
(function(DiagnosticSeverity2) {
    DiagnosticSeverity2.Error = 1;
    DiagnosticSeverity2.Warning = 2;
    DiagnosticSeverity2.Information = 3;
    DiagnosticSeverity2.Hint = 4;
})($bc939e250b70dd70$var$DiagnosticSeverity || ($bc939e250b70dd70$var$DiagnosticSeverity = {}));
var $bc939e250b70dd70$var$DiagnosticTag;
(function(DiagnosticTag2) {
    DiagnosticTag2.Unnecessary = 1;
    DiagnosticTag2.Deprecated = 2;
})($bc939e250b70dd70$var$DiagnosticTag || ($bc939e250b70dd70$var$DiagnosticTag = {}));
var $bc939e250b70dd70$var$CodeDescription;
(function(CodeDescription2) {
    function is(value) {
        var candidate = value;
        return candidate !== void 0 && candidate !== null && $bc939e250b70dd70$var$Is.string(candidate.href);
    }
    CodeDescription2.is = is;
})($bc939e250b70dd70$var$CodeDescription || ($bc939e250b70dd70$var$CodeDescription = {}));
var $bc939e250b70dd70$var$Diagnostic;
(function(Diagnostic2) {
    function create(range, message, severity, code, source, relatedInformation) {
        var result = {
            range: range,
            message: message
        };
        if ($bc939e250b70dd70$var$Is.defined(severity)) result.severity = severity;
        if ($bc939e250b70dd70$var$Is.defined(code)) result.code = code;
        if ($bc939e250b70dd70$var$Is.defined(source)) result.source = source;
        if ($bc939e250b70dd70$var$Is.defined(relatedInformation)) result.relatedInformation = relatedInformation;
        return result;
    }
    Diagnostic2.create = create;
    function is(value) {
        var _a;
        var candidate = value;
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Range.is(candidate.range) && $bc939e250b70dd70$var$Is.string(candidate.message) && ($bc939e250b70dd70$var$Is.number(candidate.severity) || $bc939e250b70dd70$var$Is.undefined(candidate.severity)) && ($bc939e250b70dd70$var$Is.integer(candidate.code) || $bc939e250b70dd70$var$Is.string(candidate.code) || $bc939e250b70dd70$var$Is.undefined(candidate.code)) && ($bc939e250b70dd70$var$Is.undefined(candidate.codeDescription) || $bc939e250b70dd70$var$Is.string((_a = candidate.codeDescription) === null || _a === void 0 ? void 0 : _a.href)) && ($bc939e250b70dd70$var$Is.string(candidate.source) || $bc939e250b70dd70$var$Is.undefined(candidate.source)) && ($bc939e250b70dd70$var$Is.undefined(candidate.relatedInformation) || $bc939e250b70dd70$var$Is.typedArray(candidate.relatedInformation, $bc939e250b70dd70$var$DiagnosticRelatedInformation.is));
    }
    Diagnostic2.is = is;
})($bc939e250b70dd70$var$Diagnostic || ($bc939e250b70dd70$var$Diagnostic = {}));
var $bc939e250b70dd70$var$Command;
(function(Command2) {
    function create(title, command) {
        var args = [];
        for(var _i = 2; _i < arguments.length; _i++)args[_i - 2] = arguments[_i];
        var result = {
            title: title,
            command: command
        };
        if ($bc939e250b70dd70$var$Is.defined(args) && args.length > 0) result.arguments = args;
        return result;
    }
    Command2.create = create;
    function is(value) {
        var candidate = value;
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Is.string(candidate.title) && $bc939e250b70dd70$var$Is.string(candidate.command);
    }
    Command2.is = is;
})($bc939e250b70dd70$var$Command || ($bc939e250b70dd70$var$Command = {}));
var $bc939e250b70dd70$var$TextEdit;
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
        return $bc939e250b70dd70$var$Is.objectLiteral(candidate) && $bc939e250b70dd70$var$Is.string(candidate.newText) && $bc939e250b70dd70$var$Range.is(candidate.range);
    }
    TextEdit2.is = is;
})($bc939e250b70dd70$var$TextEdit || ($bc939e250b70dd70$var$TextEdit = {}));
var $bc939e250b70dd70$var$ChangeAnnotation;
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
        return candidate !== void 0 && $bc939e250b70dd70$var$Is.objectLiteral(candidate) && $bc939e250b70dd70$var$Is.string(candidate.label) && ($bc939e250b70dd70$var$Is.boolean(candidate.needsConfirmation) || candidate.needsConfirmation === void 0) && ($bc939e250b70dd70$var$Is.string(candidate.description) || candidate.description === void 0);
    }
    ChangeAnnotation2.is = is;
})($bc939e250b70dd70$var$ChangeAnnotation || ($bc939e250b70dd70$var$ChangeAnnotation = {}));
var $bc939e250b70dd70$var$ChangeAnnotationIdentifier;
(function(ChangeAnnotationIdentifier2) {
    function is(value) {
        var candidate = value;
        return typeof candidate === "string";
    }
    ChangeAnnotationIdentifier2.is = is;
})($bc939e250b70dd70$var$ChangeAnnotationIdentifier || ($bc939e250b70dd70$var$ChangeAnnotationIdentifier = {}));
var $bc939e250b70dd70$var$AnnotatedTextEdit;
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
        return $bc939e250b70dd70$var$TextEdit.is(candidate) && ($bc939e250b70dd70$var$ChangeAnnotation.is(candidate.annotationId) || $bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(candidate.annotationId));
    }
    AnnotatedTextEdit2.is = is;
})($bc939e250b70dd70$var$AnnotatedTextEdit || ($bc939e250b70dd70$var$AnnotatedTextEdit = {}));
var $bc939e250b70dd70$var$TextDocumentEdit;
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
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$OptionalVersionedTextDocumentIdentifier.is(candidate.textDocument) && Array.isArray(candidate.edits);
    }
    TextDocumentEdit2.is = is;
})($bc939e250b70dd70$var$TextDocumentEdit || ($bc939e250b70dd70$var$TextDocumentEdit = {}));
var $bc939e250b70dd70$var$CreateFile;
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
        return candidate && candidate.kind === "create" && $bc939e250b70dd70$var$Is.string(candidate.uri) && (candidate.options === void 0 || (candidate.options.overwrite === void 0 || $bc939e250b70dd70$var$Is.boolean(candidate.options.overwrite)) && (candidate.options.ignoreIfExists === void 0 || $bc939e250b70dd70$var$Is.boolean(candidate.options.ignoreIfExists))) && (candidate.annotationId === void 0 || $bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(candidate.annotationId));
    }
    CreateFile2.is = is;
})($bc939e250b70dd70$var$CreateFile || ($bc939e250b70dd70$var$CreateFile = {}));
var $bc939e250b70dd70$var$RenameFile;
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
        return candidate && candidate.kind === "rename" && $bc939e250b70dd70$var$Is.string(candidate.oldUri) && $bc939e250b70dd70$var$Is.string(candidate.newUri) && (candidate.options === void 0 || (candidate.options.overwrite === void 0 || $bc939e250b70dd70$var$Is.boolean(candidate.options.overwrite)) && (candidate.options.ignoreIfExists === void 0 || $bc939e250b70dd70$var$Is.boolean(candidate.options.ignoreIfExists))) && (candidate.annotationId === void 0 || $bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(candidate.annotationId));
    }
    RenameFile2.is = is;
})($bc939e250b70dd70$var$RenameFile || ($bc939e250b70dd70$var$RenameFile = {}));
var $bc939e250b70dd70$var$DeleteFile;
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
        return candidate && candidate.kind === "delete" && $bc939e250b70dd70$var$Is.string(candidate.uri) && (candidate.options === void 0 || (candidate.options.recursive === void 0 || $bc939e250b70dd70$var$Is.boolean(candidate.options.recursive)) && (candidate.options.ignoreIfNotExists === void 0 || $bc939e250b70dd70$var$Is.boolean(candidate.options.ignoreIfNotExists))) && (candidate.annotationId === void 0 || $bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(candidate.annotationId));
    }
    DeleteFile2.is = is;
})($bc939e250b70dd70$var$DeleteFile || ($bc939e250b70dd70$var$DeleteFile = {}));
var $bc939e250b70dd70$var$WorkspaceEdit;
(function(WorkspaceEdit2) {
    function is(value) {
        var candidate = value;
        return candidate && (candidate.changes !== void 0 || candidate.documentChanges !== void 0) && (candidate.documentChanges === void 0 || candidate.documentChanges.every(function(change) {
            if ($bc939e250b70dd70$var$Is.string(change.kind)) return $bc939e250b70dd70$var$CreateFile.is(change) || $bc939e250b70dd70$var$RenameFile.is(change) || $bc939e250b70dd70$var$DeleteFile.is(change);
            else return $bc939e250b70dd70$var$TextDocumentEdit.is(change);
        }));
    }
    WorkspaceEdit2.is = is;
})($bc939e250b70dd70$var$WorkspaceEdit || ($bc939e250b70dd70$var$WorkspaceEdit = {}));
var $bc939e250b70dd70$var$TextEditChangeImpl = function() {
    function TextEditChangeImpl2(edits, changeAnnotations) {
        this.edits = edits;
        this.changeAnnotations = changeAnnotations;
    }
    TextEditChangeImpl2.prototype.insert = function(position, newText, annotation) {
        var edit;
        var id;
        if (annotation === void 0) edit = $bc939e250b70dd70$var$TextEdit.insert(position, newText);
        else if ($bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(annotation)) {
            id = annotation;
            edit = $bc939e250b70dd70$var$AnnotatedTextEdit.insert(position, newText, annotation);
        } else {
            this.assertChangeAnnotations(this.changeAnnotations);
            id = this.changeAnnotations.manage(annotation);
            edit = $bc939e250b70dd70$var$AnnotatedTextEdit.insert(position, newText, id);
        }
        this.edits.push(edit);
        if (id !== void 0) return id;
    };
    TextEditChangeImpl2.prototype.replace = function(range, newText, annotation) {
        var edit;
        var id;
        if (annotation === void 0) edit = $bc939e250b70dd70$var$TextEdit.replace(range, newText);
        else if ($bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(annotation)) {
            id = annotation;
            edit = $bc939e250b70dd70$var$AnnotatedTextEdit.replace(range, newText, annotation);
        } else {
            this.assertChangeAnnotations(this.changeAnnotations);
            id = this.changeAnnotations.manage(annotation);
            edit = $bc939e250b70dd70$var$AnnotatedTextEdit.replace(range, newText, id);
        }
        this.edits.push(edit);
        if (id !== void 0) return id;
    };
    TextEditChangeImpl2.prototype.delete = function(range, annotation) {
        var edit;
        var id;
        if (annotation === void 0) edit = $bc939e250b70dd70$var$TextEdit.del(range);
        else if ($bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(annotation)) {
            id = annotation;
            edit = $bc939e250b70dd70$var$AnnotatedTextEdit.del(range, annotation);
        } else {
            this.assertChangeAnnotations(this.changeAnnotations);
            id = this.changeAnnotations.manage(annotation);
            edit = $bc939e250b70dd70$var$AnnotatedTextEdit.del(range, id);
        }
        this.edits.push(edit);
        if (id !== void 0) return id;
    };
    TextEditChangeImpl2.prototype.add = function(edit) {
        this.edits.push(edit);
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
var $bc939e250b70dd70$var$ChangeAnnotations = function() {
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
        if ($bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(idOrAnnotation)) id = idOrAnnotation;
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
var $bc939e250b70dd70$var$WorkspaceChange = function() {
    function WorkspaceChange2(workspaceEdit) {
        var _this = this;
        this._textEditChanges = Object.create(null);
        if (workspaceEdit !== void 0) {
            this._workspaceEdit = workspaceEdit;
            if (workspaceEdit.documentChanges) {
                this._changeAnnotations = new $bc939e250b70dd70$var$ChangeAnnotations(workspaceEdit.changeAnnotations);
                workspaceEdit.changeAnnotations = this._changeAnnotations.all();
                workspaceEdit.documentChanges.forEach(function(change) {
                    if ($bc939e250b70dd70$var$TextDocumentEdit.is(change)) {
                        var textEditChange = new $bc939e250b70dd70$var$TextEditChangeImpl(change.edits, _this._changeAnnotations);
                        _this._textEditChanges[change.textDocument.uri] = textEditChange;
                    }
                });
            } else if (workspaceEdit.changes) Object.keys(workspaceEdit.changes).forEach(function(key) {
                var textEditChange = new $bc939e250b70dd70$var$TextEditChangeImpl(workspaceEdit.changes[key]);
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
        if ($bc939e250b70dd70$var$OptionalVersionedTextDocumentIdentifier.is(key)) {
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
                result = new $bc939e250b70dd70$var$TextEditChangeImpl(edits, this._changeAnnotations);
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
                result = new $bc939e250b70dd70$var$TextEditChangeImpl(edits);
                this._textEditChanges[key] = result;
            }
            return result;
        }
    };
    WorkspaceChange2.prototype.initDocumentChanges = function() {
        if (this._workspaceEdit.documentChanges === void 0 && this._workspaceEdit.changes === void 0) {
            this._changeAnnotations = new $bc939e250b70dd70$var$ChangeAnnotations();
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
        if ($bc939e250b70dd70$var$ChangeAnnotation.is(optionsOrAnnotation) || $bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(optionsOrAnnotation)) annotation = optionsOrAnnotation;
        else options = optionsOrAnnotation;
        var operation;
        var id;
        if (annotation === void 0) operation = $bc939e250b70dd70$var$CreateFile.create(uri, options);
        else {
            id = $bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(annotation) ? annotation : this._changeAnnotations.manage(annotation);
            operation = $bc939e250b70dd70$var$CreateFile.create(uri, options, id);
        }
        this._workspaceEdit.documentChanges.push(operation);
        if (id !== void 0) return id;
    };
    WorkspaceChange2.prototype.renameFile = function(oldUri, newUri, optionsOrAnnotation, options) {
        this.initDocumentChanges();
        if (this._workspaceEdit.documentChanges === void 0) throw new Error("Workspace edit is not configured for document changes.");
        var annotation;
        if ($bc939e250b70dd70$var$ChangeAnnotation.is(optionsOrAnnotation) || $bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(optionsOrAnnotation)) annotation = optionsOrAnnotation;
        else options = optionsOrAnnotation;
        var operation;
        var id;
        if (annotation === void 0) operation = $bc939e250b70dd70$var$RenameFile.create(oldUri, newUri, options);
        else {
            id = $bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(annotation) ? annotation : this._changeAnnotations.manage(annotation);
            operation = $bc939e250b70dd70$var$RenameFile.create(oldUri, newUri, options, id);
        }
        this._workspaceEdit.documentChanges.push(operation);
        if (id !== void 0) return id;
    };
    WorkspaceChange2.prototype.deleteFile = function(uri, optionsOrAnnotation, options) {
        this.initDocumentChanges();
        if (this._workspaceEdit.documentChanges === void 0) throw new Error("Workspace edit is not configured for document changes.");
        var annotation;
        if ($bc939e250b70dd70$var$ChangeAnnotation.is(optionsOrAnnotation) || $bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(optionsOrAnnotation)) annotation = optionsOrAnnotation;
        else options = optionsOrAnnotation;
        var operation;
        var id;
        if (annotation === void 0) operation = $bc939e250b70dd70$var$DeleteFile.create(uri, options);
        else {
            id = $bc939e250b70dd70$var$ChangeAnnotationIdentifier.is(annotation) ? annotation : this._changeAnnotations.manage(annotation);
            operation = $bc939e250b70dd70$var$DeleteFile.create(uri, options, id);
        }
        this._workspaceEdit.documentChanges.push(operation);
        if (id !== void 0) return id;
    };
    return WorkspaceChange2;
}();
var $bc939e250b70dd70$var$TextDocumentIdentifier;
(function(TextDocumentIdentifier2) {
    function create(uri) {
        return {
            uri: uri
        };
    }
    TextDocumentIdentifier2.create = create;
    function is(value) {
        var candidate = value;
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Is.string(candidate.uri);
    }
    TextDocumentIdentifier2.is = is;
})($bc939e250b70dd70$var$TextDocumentIdentifier || ($bc939e250b70dd70$var$TextDocumentIdentifier = {}));
var $bc939e250b70dd70$var$VersionedTextDocumentIdentifier;
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
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Is.string(candidate.uri) && $bc939e250b70dd70$var$Is.integer(candidate.version);
    }
    VersionedTextDocumentIdentifier2.is = is;
})($bc939e250b70dd70$var$VersionedTextDocumentIdentifier || ($bc939e250b70dd70$var$VersionedTextDocumentIdentifier = {}));
var $bc939e250b70dd70$var$OptionalVersionedTextDocumentIdentifier;
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
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Is.string(candidate.uri) && (candidate.version === null || $bc939e250b70dd70$var$Is.integer(candidate.version));
    }
    OptionalVersionedTextDocumentIdentifier2.is = is;
})($bc939e250b70dd70$var$OptionalVersionedTextDocumentIdentifier || ($bc939e250b70dd70$var$OptionalVersionedTextDocumentIdentifier = {}));
var $bc939e250b70dd70$var$TextDocumentItem;
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
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Is.string(candidate.uri) && $bc939e250b70dd70$var$Is.string(candidate.languageId) && $bc939e250b70dd70$var$Is.integer(candidate.version) && $bc939e250b70dd70$var$Is.string(candidate.text);
    }
    TextDocumentItem2.is = is;
})($bc939e250b70dd70$var$TextDocumentItem || ($bc939e250b70dd70$var$TextDocumentItem = {}));
var $bc939e250b70dd70$var$MarkupKind;
(function(MarkupKind2) {
    MarkupKind2.PlainText = "plaintext";
    MarkupKind2.Markdown = "markdown";
})($bc939e250b70dd70$var$MarkupKind || ($bc939e250b70dd70$var$MarkupKind = {}));
(function(MarkupKind2) {
    function is(value) {
        var candidate = value;
        return candidate === MarkupKind2.PlainText || candidate === MarkupKind2.Markdown;
    }
    MarkupKind2.is = is;
})($bc939e250b70dd70$var$MarkupKind || ($bc939e250b70dd70$var$MarkupKind = {}));
var $bc939e250b70dd70$var$MarkupContent;
(function(MarkupContent2) {
    function is(value) {
        var candidate = value;
        return $bc939e250b70dd70$var$Is.objectLiteral(value) && $bc939e250b70dd70$var$MarkupKind.is(candidate.kind) && $bc939e250b70dd70$var$Is.string(candidate.value);
    }
    MarkupContent2.is = is;
})($bc939e250b70dd70$var$MarkupContent || ($bc939e250b70dd70$var$MarkupContent = {}));
var $bc939e250b70dd70$var$CompletionItemKind;
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
})($bc939e250b70dd70$var$CompletionItemKind || ($bc939e250b70dd70$var$CompletionItemKind = {}));
var $bc939e250b70dd70$var$InsertTextFormat;
(function(InsertTextFormat2) {
    InsertTextFormat2.PlainText = 1;
    InsertTextFormat2.Snippet = 2;
})($bc939e250b70dd70$var$InsertTextFormat || ($bc939e250b70dd70$var$InsertTextFormat = {}));
var $bc939e250b70dd70$var$CompletionItemTag;
(function(CompletionItemTag2) {
    CompletionItemTag2.Deprecated = 1;
})($bc939e250b70dd70$var$CompletionItemTag || ($bc939e250b70dd70$var$CompletionItemTag = {}));
var $bc939e250b70dd70$var$InsertReplaceEdit;
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
        return candidate && $bc939e250b70dd70$var$Is.string(candidate.newText) && $bc939e250b70dd70$var$Range.is(candidate.insert) && $bc939e250b70dd70$var$Range.is(candidate.replace);
    }
    InsertReplaceEdit2.is = is;
})($bc939e250b70dd70$var$InsertReplaceEdit || ($bc939e250b70dd70$var$InsertReplaceEdit = {}));
var $bc939e250b70dd70$var$InsertTextMode;
(function(InsertTextMode2) {
    InsertTextMode2.asIs = 1;
    InsertTextMode2.adjustIndentation = 2;
})($bc939e250b70dd70$var$InsertTextMode || ($bc939e250b70dd70$var$InsertTextMode = {}));
var $bc939e250b70dd70$var$CompletionItem;
(function(CompletionItem2) {
    function create(label) {
        return {
            label: label
        };
    }
    CompletionItem2.create = create;
})($bc939e250b70dd70$var$CompletionItem || ($bc939e250b70dd70$var$CompletionItem = {}));
var $bc939e250b70dd70$var$CompletionList;
(function(CompletionList2) {
    function create(items, isIncomplete) {
        return {
            items: items ? items : [],
            isIncomplete: !!isIncomplete
        };
    }
    CompletionList2.create = create;
})($bc939e250b70dd70$var$CompletionList || ($bc939e250b70dd70$var$CompletionList = {}));
var $bc939e250b70dd70$var$MarkedString;
(function(MarkedString2) {
    function fromPlainText(plainText) {
        return plainText.replace(/[\\`*_{}[\]()#+\-.!]/g, "\\$&");
    }
    MarkedString2.fromPlainText = fromPlainText;
    function is(value) {
        var candidate = value;
        return $bc939e250b70dd70$var$Is.string(candidate) || $bc939e250b70dd70$var$Is.objectLiteral(candidate) && $bc939e250b70dd70$var$Is.string(candidate.language) && $bc939e250b70dd70$var$Is.string(candidate.value);
    }
    MarkedString2.is = is;
})($bc939e250b70dd70$var$MarkedString || ($bc939e250b70dd70$var$MarkedString = {}));
var $bc939e250b70dd70$var$Hover;
(function(Hover2) {
    function is(value) {
        var candidate = value;
        return !!candidate && $bc939e250b70dd70$var$Is.objectLiteral(candidate) && ($bc939e250b70dd70$var$MarkupContent.is(candidate.contents) || $bc939e250b70dd70$var$MarkedString.is(candidate.contents) || $bc939e250b70dd70$var$Is.typedArray(candidate.contents, $bc939e250b70dd70$var$MarkedString.is)) && (value.range === void 0 || $bc939e250b70dd70$var$Range.is(value.range));
    }
    Hover2.is = is;
})($bc939e250b70dd70$var$Hover || ($bc939e250b70dd70$var$Hover = {}));
var $bc939e250b70dd70$var$ParameterInformation;
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
})($bc939e250b70dd70$var$ParameterInformation || ($bc939e250b70dd70$var$ParameterInformation = {}));
var $bc939e250b70dd70$var$SignatureInformation;
(function(SignatureInformation2) {
    function create(label, documentation) {
        var parameters = [];
        for(var _i = 2; _i < arguments.length; _i++)parameters[_i - 2] = arguments[_i];
        var result = {
            label: label
        };
        if ($bc939e250b70dd70$var$Is.defined(documentation)) result.documentation = documentation;
        if ($bc939e250b70dd70$var$Is.defined(parameters)) result.parameters = parameters;
        else result.parameters = [];
        return result;
    }
    SignatureInformation2.create = create;
})($bc939e250b70dd70$var$SignatureInformation || ($bc939e250b70dd70$var$SignatureInformation = {}));
var $bc939e250b70dd70$var$DocumentHighlightKind;
(function(DocumentHighlightKind2) {
    DocumentHighlightKind2.Text = 1;
    DocumentHighlightKind2.Read = 2;
    DocumentHighlightKind2.Write = 3;
})($bc939e250b70dd70$var$DocumentHighlightKind || ($bc939e250b70dd70$var$DocumentHighlightKind = {}));
var $bc939e250b70dd70$var$DocumentHighlight;
(function(DocumentHighlight2) {
    function create(range, kind) {
        var result = {
            range: range
        };
        if ($bc939e250b70dd70$var$Is.number(kind)) result.kind = kind;
        return result;
    }
    DocumentHighlight2.create = create;
})($bc939e250b70dd70$var$DocumentHighlight || ($bc939e250b70dd70$var$DocumentHighlight = {}));
var $bc939e250b70dd70$var$SymbolKind;
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
})($bc939e250b70dd70$var$SymbolKind || ($bc939e250b70dd70$var$SymbolKind = {}));
var $bc939e250b70dd70$var$SymbolTag;
(function(SymbolTag2) {
    SymbolTag2.Deprecated = 1;
})($bc939e250b70dd70$var$SymbolTag || ($bc939e250b70dd70$var$SymbolTag = {}));
var $bc939e250b70dd70$var$SymbolInformation;
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
})($bc939e250b70dd70$var$SymbolInformation || ($bc939e250b70dd70$var$SymbolInformation = {}));
var $bc939e250b70dd70$var$DocumentSymbol;
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
        return candidate && $bc939e250b70dd70$var$Is.string(candidate.name) && $bc939e250b70dd70$var$Is.number(candidate.kind) && $bc939e250b70dd70$var$Range.is(candidate.range) && $bc939e250b70dd70$var$Range.is(candidate.selectionRange) && (candidate.detail === void 0 || $bc939e250b70dd70$var$Is.string(candidate.detail)) && (candidate.deprecated === void 0 || $bc939e250b70dd70$var$Is.boolean(candidate.deprecated)) && (candidate.children === void 0 || Array.isArray(candidate.children)) && (candidate.tags === void 0 || Array.isArray(candidate.tags));
    }
    DocumentSymbol2.is = is;
})($bc939e250b70dd70$var$DocumentSymbol || ($bc939e250b70dd70$var$DocumentSymbol = {}));
var $bc939e250b70dd70$var$CodeActionKind;
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
})($bc939e250b70dd70$var$CodeActionKind || ($bc939e250b70dd70$var$CodeActionKind = {}));
var $bc939e250b70dd70$var$CodeActionContext;
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
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Is.typedArray(candidate.diagnostics, $bc939e250b70dd70$var$Diagnostic.is) && (candidate.only === void 0 || $bc939e250b70dd70$var$Is.typedArray(candidate.only, $bc939e250b70dd70$var$Is.string));
    }
    CodeActionContext2.is = is;
})($bc939e250b70dd70$var$CodeActionContext || ($bc939e250b70dd70$var$CodeActionContext = {}));
var $bc939e250b70dd70$var$CodeAction;
(function(CodeAction2) {
    function create(title, kindOrCommandOrEdit, kind) {
        var result = {
            title: title
        };
        var checkKind = true;
        if (typeof kindOrCommandOrEdit === "string") {
            checkKind = false;
            result.kind = kindOrCommandOrEdit;
        } else if ($bc939e250b70dd70$var$Command.is(kindOrCommandOrEdit)) result.command = kindOrCommandOrEdit;
        else result.edit = kindOrCommandOrEdit;
        if (checkKind && kind !== void 0) result.kind = kind;
        return result;
    }
    CodeAction2.create = create;
    function is(value) {
        var candidate = value;
        return candidate && $bc939e250b70dd70$var$Is.string(candidate.title) && (candidate.diagnostics === void 0 || $bc939e250b70dd70$var$Is.typedArray(candidate.diagnostics, $bc939e250b70dd70$var$Diagnostic.is)) && (candidate.kind === void 0 || $bc939e250b70dd70$var$Is.string(candidate.kind)) && (candidate.edit !== void 0 || candidate.command !== void 0) && (candidate.command === void 0 || $bc939e250b70dd70$var$Command.is(candidate.command)) && (candidate.isPreferred === void 0 || $bc939e250b70dd70$var$Is.boolean(candidate.isPreferred)) && (candidate.edit === void 0 || $bc939e250b70dd70$var$WorkspaceEdit.is(candidate.edit));
    }
    CodeAction2.is = is;
})($bc939e250b70dd70$var$CodeAction || ($bc939e250b70dd70$var$CodeAction = {}));
var $bc939e250b70dd70$var$CodeLens;
(function(CodeLens2) {
    function create(range, data) {
        var result = {
            range: range
        };
        if ($bc939e250b70dd70$var$Is.defined(data)) result.data = data;
        return result;
    }
    CodeLens2.create = create;
    function is(value) {
        var candidate = value;
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Range.is(candidate.range) && ($bc939e250b70dd70$var$Is.undefined(candidate.command) || $bc939e250b70dd70$var$Command.is(candidate.command));
    }
    CodeLens2.is = is;
})($bc939e250b70dd70$var$CodeLens || ($bc939e250b70dd70$var$CodeLens = {}));
var $bc939e250b70dd70$var$FormattingOptions;
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
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Is.uinteger(candidate.tabSize) && $bc939e250b70dd70$var$Is.boolean(candidate.insertSpaces);
    }
    FormattingOptions2.is = is;
})($bc939e250b70dd70$var$FormattingOptions || ($bc939e250b70dd70$var$FormattingOptions = {}));
var $bc939e250b70dd70$var$DocumentLink;
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
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Range.is(candidate.range) && ($bc939e250b70dd70$var$Is.undefined(candidate.target) || $bc939e250b70dd70$var$Is.string(candidate.target));
    }
    DocumentLink2.is = is;
})($bc939e250b70dd70$var$DocumentLink || ($bc939e250b70dd70$var$DocumentLink = {}));
var $bc939e250b70dd70$var$SelectionRange;
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
        return candidate !== void 0 && $bc939e250b70dd70$var$Range.is(candidate.range) && (candidate.parent === void 0 || SelectionRange2.is(candidate.parent));
    }
    SelectionRange2.is = is;
})($bc939e250b70dd70$var$SelectionRange || ($bc939e250b70dd70$var$SelectionRange = {}));
var $bc939e250b70dd70$var$TextDocument;
(function(TextDocument2) {
    function create(uri, languageId, version, content) {
        return new $bc939e250b70dd70$var$FullTextDocument(uri, languageId, version, content);
    }
    TextDocument2.create = create;
    function is(value) {
        var candidate = value;
        return $bc939e250b70dd70$var$Is.defined(candidate) && $bc939e250b70dd70$var$Is.string(candidate.uri) && ($bc939e250b70dd70$var$Is.undefined(candidate.languageId) || $bc939e250b70dd70$var$Is.string(candidate.languageId)) && $bc939e250b70dd70$var$Is.uinteger(candidate.lineCount) && $bc939e250b70dd70$var$Is.func(candidate.getText) && $bc939e250b70dd70$var$Is.func(candidate.positionAt) && $bc939e250b70dd70$var$Is.func(candidate.offsetAt) ? true : false;
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
})($bc939e250b70dd70$var$TextDocument || ($bc939e250b70dd70$var$TextDocument = {}));
var $bc939e250b70dd70$var$FullTextDocument = function() {
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
        if (high === 0) return $bc939e250b70dd70$var$Position.create(0, offset);
        while(low < high){
            var mid = Math.floor((low + high) / 2);
            if (lineOffsets[mid] > offset) high = mid;
            else low = mid + 1;
        }
        var line = low - 1;
        return $bc939e250b70dd70$var$Position.create(line, offset - lineOffsets[line]);
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
var $bc939e250b70dd70$var$Is;
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
})($bc939e250b70dd70$var$Is || ($bc939e250b70dd70$var$Is = {}));
// src/common/lspLanguageFeatures.ts
var $bc939e250b70dd70$var$CompletionAdapter = class {
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
            return worker.doComplete(resource.toString(), $bc939e250b70dd70$var$fromPosition(position));
        }).then((info)=>{
            if (!info) return;
            const wordInfo = model.getWordUntilPosition(position);
            const wordRange = new $bc939e250b70dd70$var$monaco_editor_core_exports.Range(position.lineNumber, wordInfo.startColumn, position.lineNumber, wordInfo.endColumn);
            const items = info.items.map((entry)=>{
                const item = {
                    label: entry.label,
                    insertText: entry.insertText || entry.label,
                    sortText: entry.sortText,
                    filterText: entry.filterText,
                    documentation: entry.documentation,
                    detail: entry.detail,
                    command: $bc939e250b70dd70$var$toCommand(entry.command),
                    range: wordRange,
                    kind: $bc939e250b70dd70$var$toCompletionItemKind(entry.kind)
                };
                if (entry.textEdit) {
                    if ($bc939e250b70dd70$var$isInsertReplaceEdit(entry.textEdit)) item.range = {
                        insert: $bc939e250b70dd70$var$toRange(entry.textEdit.insert),
                        replace: $bc939e250b70dd70$var$toRange(entry.textEdit.replace)
                    };
                    else item.range = $bc939e250b70dd70$var$toRange(entry.textEdit.range);
                    item.insertText = entry.textEdit.newText;
                }
                if (entry.additionalTextEdits) item.additionalTextEdits = entry.additionalTextEdits.map($bc939e250b70dd70$var$toTextEdit);
                if (entry.insertTextFormat === $bc939e250b70dd70$var$InsertTextFormat.Snippet) item.insertTextRules = $bc939e250b70dd70$var$monaco_editor_core_exports.languages.CompletionItemInsertTextRule.InsertAsSnippet;
                return item;
            });
            return {
                isIncomplete: info.isIncomplete,
                suggestions: items
            };
        });
    }
};
function $bc939e250b70dd70$var$fromPosition(position) {
    if (!position) return void 0;
    return {
        character: position.column - 1,
        line: position.lineNumber - 1
    };
}
function $bc939e250b70dd70$var$fromRange(range) {
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
function $bc939e250b70dd70$var$toRange(range) {
    if (!range) return void 0;
    return new $bc939e250b70dd70$var$monaco_editor_core_exports.Range(range.start.line + 1, range.start.character + 1, range.end.line + 1, range.end.character + 1);
}
function $bc939e250b70dd70$var$isInsertReplaceEdit(edit) {
    return typeof edit.insert !== "undefined" && typeof edit.replace !== "undefined";
}
function $bc939e250b70dd70$var$toCompletionItemKind(kind) {
    const mItemKind = $bc939e250b70dd70$var$monaco_editor_core_exports.languages.CompletionItemKind;
    switch(kind){
        case $bc939e250b70dd70$var$CompletionItemKind.Text:
            return mItemKind.Text;
        case $bc939e250b70dd70$var$CompletionItemKind.Method:
            return mItemKind.Method;
        case $bc939e250b70dd70$var$CompletionItemKind.Function:
            return mItemKind.Function;
        case $bc939e250b70dd70$var$CompletionItemKind.Constructor:
            return mItemKind.Constructor;
        case $bc939e250b70dd70$var$CompletionItemKind.Field:
            return mItemKind.Field;
        case $bc939e250b70dd70$var$CompletionItemKind.Variable:
            return mItemKind.Variable;
        case $bc939e250b70dd70$var$CompletionItemKind.Class:
            return mItemKind.Class;
        case $bc939e250b70dd70$var$CompletionItemKind.Interface:
            return mItemKind.Interface;
        case $bc939e250b70dd70$var$CompletionItemKind.Module:
            return mItemKind.Module;
        case $bc939e250b70dd70$var$CompletionItemKind.Property:
            return mItemKind.Property;
        case $bc939e250b70dd70$var$CompletionItemKind.Unit:
            return mItemKind.Unit;
        case $bc939e250b70dd70$var$CompletionItemKind.Value:
            return mItemKind.Value;
        case $bc939e250b70dd70$var$CompletionItemKind.Enum:
            return mItemKind.Enum;
        case $bc939e250b70dd70$var$CompletionItemKind.Keyword:
            return mItemKind.Keyword;
        case $bc939e250b70dd70$var$CompletionItemKind.Snippet:
            return mItemKind.Snippet;
        case $bc939e250b70dd70$var$CompletionItemKind.Color:
            return mItemKind.Color;
        case $bc939e250b70dd70$var$CompletionItemKind.File:
            return mItemKind.File;
        case $bc939e250b70dd70$var$CompletionItemKind.Reference:
            return mItemKind.Reference;
    }
    return mItemKind.Property;
}
function $bc939e250b70dd70$var$toTextEdit(textEdit) {
    if (!textEdit) return void 0;
    return {
        range: $bc939e250b70dd70$var$toRange(textEdit.range),
        text: textEdit.newText
    };
}
function $bc939e250b70dd70$var$toCommand(c) {
    return c && c.command === "editor.action.triggerSuggest" ? {
        id: c.command,
        title: c.title,
        arguments: c.arguments
    } : void 0;
}
var $bc939e250b70dd70$var$HoverAdapter = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideHover(model, position, token) {
        let resource = model.uri;
        return this._worker(resource).then((worker)=>{
            return worker.doHover(resource.toString(), $bc939e250b70dd70$var$fromPosition(position));
        }).then((info)=>{
            if (!info) return;
            return {
                range: $bc939e250b70dd70$var$toRange(info.range),
                contents: $bc939e250b70dd70$var$toMarkedStringArray(info.contents)
            };
        });
    }
};
function $bc939e250b70dd70$var$isMarkupContent(thing) {
    return thing && typeof thing === "object" && typeof thing.kind === "string";
}
function $bc939e250b70dd70$var$toMarkdownString(entry) {
    if (typeof entry === "string") return {
        value: entry
    };
    if ($bc939e250b70dd70$var$isMarkupContent(entry)) {
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
function $bc939e250b70dd70$var$toMarkedStringArray(contents) {
    if (!contents) return void 0;
    if (Array.isArray(contents)) return contents.map($bc939e250b70dd70$var$toMarkdownString);
    return [
        $bc939e250b70dd70$var$toMarkdownString(contents)
    ];
}
var $bc939e250b70dd70$var$DocumentHighlightAdapter = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideDocumentHighlights(model, position, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>worker.findDocumentHighlights(resource.toString(), $bc939e250b70dd70$var$fromPosition(position))
        ).then((entries)=>{
            if (!entries) return;
            return entries.map((entry)=>{
                return {
                    range: $bc939e250b70dd70$var$toRange(entry.range),
                    kind: $bc939e250b70dd70$var$toDocumentHighlightKind(entry.kind)
                };
            });
        });
    }
};
function $bc939e250b70dd70$var$toDocumentHighlightKind(kind) {
    switch(kind){
        case $bc939e250b70dd70$var$DocumentHighlightKind.Read:
            return $bc939e250b70dd70$var$monaco_editor_core_exports.languages.DocumentHighlightKind.Read;
        case $bc939e250b70dd70$var$DocumentHighlightKind.Write:
            return $bc939e250b70dd70$var$monaco_editor_core_exports.languages.DocumentHighlightKind.Write;
        case $bc939e250b70dd70$var$DocumentHighlightKind.Text:
            return $bc939e250b70dd70$var$monaco_editor_core_exports.languages.DocumentHighlightKind.Text;
    }
    return $bc939e250b70dd70$var$monaco_editor_core_exports.languages.DocumentHighlightKind.Text;
}
var $bc939e250b70dd70$var$RenameAdapter = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideRenameEdits(model, position, newName, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>{
            return worker.doRename(resource.toString(), $bc939e250b70dd70$var$fromPosition(position), newName);
        }).then((edit)=>{
            return $bc939e250b70dd70$var$toWorkspaceEdit(edit);
        });
    }
};
function $bc939e250b70dd70$var$toWorkspaceEdit(edit) {
    if (!edit || !edit.changes) return void 0;
    let resourceEdits = [];
    for(let uri in edit.changes){
        const _uri = $bc939e250b70dd70$var$monaco_editor_core_exports.Uri.parse(uri);
        for (let e of edit.changes[uri])resourceEdits.push({
            resource: _uri,
            edit: {
                range: $bc939e250b70dd70$var$toRange(e.range),
                text: e.newText
            }
        });
    }
    return {
        edits: resourceEdits
    };
}
var $bc939e250b70dd70$var$DocumentSymbolAdapter = class {
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
                    kind: $bc939e250b70dd70$var$toSymbolKind(item.kind),
                    range: $bc939e250b70dd70$var$toRange(item.location.range),
                    selectionRange: $bc939e250b70dd70$var$toRange(item.location.range),
                    tags: []
                })
            );
        });
    }
};
function $bc939e250b70dd70$var$toSymbolKind(kind) {
    let mKind = $bc939e250b70dd70$var$monaco_editor_core_exports.languages.SymbolKind;
    switch(kind){
        case $bc939e250b70dd70$var$SymbolKind.File:
            return mKind.Array;
        case $bc939e250b70dd70$var$SymbolKind.Module:
            return mKind.Module;
        case $bc939e250b70dd70$var$SymbolKind.Namespace:
            return mKind.Namespace;
        case $bc939e250b70dd70$var$SymbolKind.Package:
            return mKind.Package;
        case $bc939e250b70dd70$var$SymbolKind.Class:
            return mKind.Class;
        case $bc939e250b70dd70$var$SymbolKind.Method:
            return mKind.Method;
        case $bc939e250b70dd70$var$SymbolKind.Property:
            return mKind.Property;
        case $bc939e250b70dd70$var$SymbolKind.Field:
            return mKind.Field;
        case $bc939e250b70dd70$var$SymbolKind.Constructor:
            return mKind.Constructor;
        case $bc939e250b70dd70$var$SymbolKind.Enum:
            return mKind.Enum;
        case $bc939e250b70dd70$var$SymbolKind.Interface:
            return mKind.Interface;
        case $bc939e250b70dd70$var$SymbolKind.Function:
            return mKind.Function;
        case $bc939e250b70dd70$var$SymbolKind.Variable:
            return mKind.Variable;
        case $bc939e250b70dd70$var$SymbolKind.Constant:
            return mKind.Constant;
        case $bc939e250b70dd70$var$SymbolKind.String:
            return mKind.String;
        case $bc939e250b70dd70$var$SymbolKind.Number:
            return mKind.Number;
        case $bc939e250b70dd70$var$SymbolKind.Boolean:
            return mKind.Boolean;
        case $bc939e250b70dd70$var$SymbolKind.Array:
            return mKind.Array;
    }
    return mKind.Function;
}
var $bc939e250b70dd70$var$DocumentLinkAdapter = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideLinks(model, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>worker.findDocumentLinks(resource.toString())
        ).then((items)=>{
            if (!items) return;
            return {
                links: items.map((item)=>({
                        range: $bc939e250b70dd70$var$toRange(item.range),
                        url: item.target
                    })
                )
            };
        });
    }
};
var $bc939e250b70dd70$var$DocumentFormattingEditProvider = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideDocumentFormattingEdits(model, options, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>{
            return worker.format(resource.toString(), null, $bc939e250b70dd70$var$fromFormattingOptions(options)).then((edits)=>{
                if (!edits || edits.length === 0) return;
                return edits.map($bc939e250b70dd70$var$toTextEdit);
            });
        });
    }
};
var $bc939e250b70dd70$var$DocumentRangeFormattingEditProvider = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideDocumentRangeFormattingEdits(model, range, options, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>{
            return worker.format(resource.toString(), $bc939e250b70dd70$var$fromRange(range), $bc939e250b70dd70$var$fromFormattingOptions(options)).then((edits)=>{
                if (!edits || edits.length === 0) return;
                return edits.map($bc939e250b70dd70$var$toTextEdit);
            });
        });
    }
};
function $bc939e250b70dd70$var$fromFormattingOptions(options) {
    return {
        tabSize: options.tabSize,
        insertSpaces: options.insertSpaces
    };
}
var $bc939e250b70dd70$var$FoldingRangeAdapter = class {
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
                if (typeof range.kind !== "undefined") result.kind = $bc939e250b70dd70$var$toFoldingRangeKind(range.kind);
                return result;
            });
        });
    }
};
function $bc939e250b70dd70$var$toFoldingRangeKind(kind) {
    switch(kind){
        case $bc939e250b70dd70$var$FoldingRangeKind.Comment:
            return $bc939e250b70dd70$var$monaco_editor_core_exports.languages.FoldingRangeKind.Comment;
        case $bc939e250b70dd70$var$FoldingRangeKind.Imports:
            return $bc939e250b70dd70$var$monaco_editor_core_exports.languages.FoldingRangeKind.Imports;
        case $bc939e250b70dd70$var$FoldingRangeKind.Region:
            return $bc939e250b70dd70$var$monaco_editor_core_exports.languages.FoldingRangeKind.Region;
    }
    return void 0;
}
var $bc939e250b70dd70$var$SelectionRangeAdapter = class {
    constructor(_worker){
        this._worker = _worker;
    }
    provideSelectionRanges(model, positions, token) {
        const resource = model.uri;
        return this._worker(resource).then((worker)=>worker.getSelectionRanges(resource.toString(), positions.map($bc939e250b70dd70$var$fromPosition))
        ).then((selectionRanges)=>{
            if (!selectionRanges) return;
            return selectionRanges.map((selectionRange)=>{
                const result = [];
                while(selectionRange){
                    result.push({
                        range: $bc939e250b70dd70$var$toRange(selectionRange.range)
                    });
                    selectionRange = selectionRange.parent;
                }
                return result;
            });
        });
    }
};
// src/html/htmlMode.ts
var $bc939e250b70dd70$var$HTMLCompletionAdapter = class extends $bc939e250b70dd70$var$CompletionAdapter {
    constructor(worker){
        super(worker, [
            ".",
            ":",
            "<",
            '"',
            "=",
            "/"
        ]);
    }
};
function $bc939e250b70dd70$export$972c61cff7b1bac7(defaults) {
    const client = new $bc939e250b70dd70$var$WorkerManager(defaults);
    const worker = (...uris)=>{
        return client.getLanguageServiceWorker(...uris);
    };
    let languageId = defaults.languageId;
    $bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerCompletionItemProvider(languageId, new $bc939e250b70dd70$var$HTMLCompletionAdapter(worker));
    $bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerHoverProvider(languageId, new $bc939e250b70dd70$var$HoverAdapter(worker));
    $bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerDocumentHighlightProvider(languageId, new $bc939e250b70dd70$var$DocumentHighlightAdapter(worker));
    $bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerLinkProvider(languageId, new $bc939e250b70dd70$var$DocumentLinkAdapter(worker));
    $bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerFoldingRangeProvider(languageId, new $bc939e250b70dd70$var$FoldingRangeAdapter(worker));
    $bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerDocumentSymbolProvider(languageId, new $bc939e250b70dd70$var$DocumentSymbolAdapter(worker));
    $bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerSelectionRangeProvider(languageId, new $bc939e250b70dd70$var$SelectionRangeAdapter(worker));
    $bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerRenameProvider(languageId, new $bc939e250b70dd70$var$RenameAdapter(worker));
    if (languageId === "html") {
        $bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerDocumentFormattingEditProvider(languageId, new $bc939e250b70dd70$var$DocumentFormattingEditProvider(worker));
        $bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerDocumentRangeFormattingEditProvider(languageId, new $bc939e250b70dd70$var$DocumentRangeFormattingEditProvider(worker));
    }
}
function $bc939e250b70dd70$export$6df00d141df42469(defaults) {
    const disposables = [];
    const providers = [];
    const client = new $bc939e250b70dd70$var$WorkerManager(defaults);
    disposables.push(client);
    const worker = (...uris)=>{
        return client.getLanguageServiceWorker(...uris);
    };
    function registerProviders() {
        const { languageId: languageId , modeConfiguration: modeConfiguration  } = defaults;
        $bc939e250b70dd70$var$disposeAll(providers);
        if (modeConfiguration.completionItems) providers.push($bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerCompletionItemProvider(languageId, new $bc939e250b70dd70$var$HTMLCompletionAdapter(worker)));
        if (modeConfiguration.hovers) providers.push($bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerHoverProvider(languageId, new $bc939e250b70dd70$var$HoverAdapter(worker)));
        if (modeConfiguration.documentHighlights) providers.push($bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerDocumentHighlightProvider(languageId, new $bc939e250b70dd70$var$DocumentHighlightAdapter(worker)));
        if (modeConfiguration.links) providers.push($bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerLinkProvider(languageId, new $bc939e250b70dd70$var$DocumentLinkAdapter(worker)));
        if (modeConfiguration.documentSymbols) providers.push($bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerDocumentSymbolProvider(languageId, new $bc939e250b70dd70$var$DocumentSymbolAdapter(worker)));
        if (modeConfiguration.rename) providers.push($bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerRenameProvider(languageId, new $bc939e250b70dd70$var$RenameAdapter(worker)));
        if (modeConfiguration.foldingRanges) providers.push($bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerFoldingRangeProvider(languageId, new $bc939e250b70dd70$var$FoldingRangeAdapter(worker)));
        if (modeConfiguration.selectionRanges) providers.push($bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerSelectionRangeProvider(languageId, new $bc939e250b70dd70$var$SelectionRangeAdapter(worker)));
        if (modeConfiguration.documentFormattingEdits) providers.push($bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerDocumentFormattingEditProvider(languageId, new $bc939e250b70dd70$var$DocumentFormattingEditProvider(worker)));
        if (modeConfiguration.documentRangeFormattingEdits) providers.push($bc939e250b70dd70$var$monaco_editor_core_exports.languages.registerDocumentRangeFormattingEditProvider(languageId, new $bc939e250b70dd70$var$DocumentRangeFormattingEditProvider(worker)));
    }
    registerProviders();
    disposables.push($bc939e250b70dd70$var$asDisposable(providers));
    return $bc939e250b70dd70$var$asDisposable(disposables);
}
function $bc939e250b70dd70$var$asDisposable(disposables) {
    return {
        dispose: ()=>$bc939e250b70dd70$var$disposeAll(disposables)
    };
}
function $bc939e250b70dd70$var$disposeAll(disposables) {
    while(disposables.length)disposables.pop().dispose();
}

});


//# sourceMappingURL=htmlMode.3d04d0d6.js.map
