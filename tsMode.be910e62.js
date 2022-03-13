function e(e,t,i,s){Object.defineProperty(e,t,{get:i,set:s,enumerable:!0,configurable:!0})}var t=("undefined"!=typeof globalThis?globalThis:"undefined"!=typeof self?self:"undefined"!=typeof window?window:"undefined"!=typeof global?global:{}).parcelRequiref17b;t.register("gnedA",(function(i,s){e(i.exports,"setupTypeScript",(()=>Q)),e(i.exports,"setupJavaScript",(()=>Y)),e(i.exports,"getJavaScriptWorker",(()=>Z)),e(i.exports,"getTypeScriptWorker",(()=>ee));var n=t("lkMpi"),r=Object.defineProperty,o=Object.getOwnPropertyDescriptor,a=Object.getOwnPropertyNames,l=Object.prototype.hasOwnProperty,c={};
/*!-----------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Version: 0.31.0(252e010eb73ddc2fa1a37c1dade7bf35d87106cd)
 * Released under the MIT license
 * https://github.com/microsoft/monaco-editor/blob/main/LICENSE.txt
 *-----------------------------------------------------------------------------*/r(c,"__esModule",{value:!0}),((e,t,i)=>{if(t&&"object"==typeof t||"function"==typeof t)for(let s of a(t))l.call(e,s)||"default"===s||r(e,s,{get:()=>t[s],enumerable:!(i=o(t,s))||i.enumerable})})(c,n);var d,g,u,p,m,h,b,f,_,S;(g=d||(d={}))[g.None=0]="None",g[g.CommonJS=1]="CommonJS",g[g.AMD=2]="AMD",g[g.UMD=3]="UMD",g[g.System=4]="System",g[g.ES2015=5]="ES2015",g[g.ESNext=99]="ESNext",(p=u||(u={}))[p.None=0]="None",p[p.Preserve=1]="Preserve",p[p.React=2]="React",p[p.ReactNative=3]="ReactNative",p[p.ReactJSX=4]="ReactJSX",p[p.ReactJSXDev=5]="ReactJSXDev",(h=m||(m={}))[h.CarriageReturnLineFeed=0]="CarriageReturnLineFeed",h[h.LineFeed=1]="LineFeed",(f=b||(b={}))[f.ES3=0]="ES3",f[f.ES5=1]="ES5",f[f.ES2015=2]="ES2015",f[f.ES2016=3]="ES2016",f[f.ES2017=4]="ES2017",f[f.ES2018=5]="ES2018",f[f.ES2019=6]="ES2019",f[f.ES2020=7]="ES2020",f[f.ESNext=99]="ESNext",f[f.JSON=100]="JSON",f[f.Latest=99]="Latest",(S=_||(_={}))[S.Classic=1]="Classic",S[S.NodeJs=2]="NodeJs";var y=class{constructor(e,t,i,s){this._onDidChange=new c.Emitter,this._onDidExtraLibsChange=new c.Emitter,this._extraLibs=Object.create(null),this._removedExtraLibs=Object.create(null),this._eagerModelSync=!1,this.setCompilerOptions(e),this.setDiagnosticsOptions(t),this.setWorkerOptions(i),this.setInlayHintsOptions(s),this._onDidExtraLibsChangeTimeout=-1}get onDidChange(){return this._onDidChange.event}get onDidExtraLibsChange(){return this._onDidExtraLibsChange.event}get workerOptions(){return this._workerOptions}get inlayHintsOptions(){return this._inlayHintsOptions}getExtraLibs(){return this._extraLibs}addExtraLib(e,t){let i;if(i=void 0===t?`ts:extralib-${Math.random().toString(36).substring(2,15)}`:t,this._extraLibs[i]&&this._extraLibs[i].content===e)return{dispose:()=>{}};let s=1;return this._removedExtraLibs[i]&&(s=this._removedExtraLibs[i]+1),this._extraLibs[i]&&(s=this._extraLibs[i].version+1),this._extraLibs[i]={content:e,version:s},this._fireOnDidExtraLibsChangeSoon(),{dispose:()=>{let e=this._extraLibs[i];e&&e.version===s&&(delete this._extraLibs[i],this._removedExtraLibs[i]=s,this._fireOnDidExtraLibsChangeSoon())}}}setExtraLibs(e){for(const e in this._extraLibs)this._removedExtraLibs[e]=this._extraLibs[e].version;if(this._extraLibs=Object.create(null),e&&e.length>0)for(const t of e){const e=t.filePath||`ts:extralib-${Math.random().toString(36).substring(2,15)}`,i=t.content;let s=1;this._removedExtraLibs[e]&&(s=this._removedExtraLibs[e]+1),this._extraLibs[e]={content:i,version:s}}this._fireOnDidExtraLibsChangeSoon()}_fireOnDidExtraLibsChangeSoon(){-1===this._onDidExtraLibsChangeTimeout&&(this._onDidExtraLibsChangeTimeout=window.setTimeout((()=>{this._onDidExtraLibsChangeTimeout=-1,this._onDidExtraLibsChange.fire(void 0)}),0))}getCompilerOptions(){return this._compilerOptions}setCompilerOptions(e){this._compilerOptions=e||Object.create(null),this._onDidChange.fire(void 0)}getDiagnosticsOptions(){return this._diagnosticsOptions}setDiagnosticsOptions(e){this._diagnosticsOptions=e||Object.create(null),this._onDidChange.fire(void 0)}setWorkerOptions(e){this._workerOptions=e||Object.create(null),this._onDidChange.fire(void 0)}setInlayHintsOptions(e){this._inlayHintsOptions=e||Object.create(null),this._onDidChange.fire(void 0)}setMaximumWorkerIdleTime(e){}setEagerModelSync(e){this._eagerModelSync=e}getEagerModelSync(){return this._eagerModelSync}},x=new y({allowNonTsExtensions:!0,target:99},{noSemanticValidation:!1,noSyntaxValidation:!1,onlyVisible:!1},{},{}),w=new y({allowNonTsExtensions:!0,allowJs:!0,target:99},{noSemanticValidation:!0,noSyntaxValidation:!1,onlyVisible:!1},{},{});function v(){return Promise.resolve($beb9d2b9c68a1eae$exports)}c.languages.typescript={ModuleKind:d,JsxEmit:u,NewLineKind:m,ScriptTarget:b,ModuleResolutionKind:_,typescriptVersion:"4.4.4",typescriptDefaults:x,javascriptDefaults:w,getTypeScriptWorker:()=>v().then((e=>e.getTypeScriptWorker())),getJavaScriptWorker:()=>v().then((e=>e.getJavaScriptWorker()))},c.languages.onLanguage("typescript",(()=>v().then((e=>e.setupTypeScript(x))))),c.languages.onLanguage("javascript",(()=>v().then((e=>e.setupJavaScript(w)))));var C,k,D={};function L(e,t,i=0){if("string"==typeof e)return e;if(void 0===e)return"";let s="";if(i){s+=t;for(let e=0;e<i;e++)s+="  "}if(s+=e.messageText,i++,e.next)for(const n of e.next)s+=L(n,t,i);return s}function O(e){return e?e.map((e=>e.text)).join(""):""}D["lib.d.ts"]=!0,D["lib.dom.d.ts"]=!0,D["lib.dom.iterable.d.ts"]=!0,D["lib.es2015.collection.d.ts"]=!0,D["lib.es2015.core.d.ts"]=!0,D["lib.es2015.d.ts"]=!0,D["lib.es2015.generator.d.ts"]=!0,D["lib.es2015.iterable.d.ts"]=!0,D["lib.es2015.promise.d.ts"]=!0,D["lib.es2015.proxy.d.ts"]=!0,D["lib.es2015.reflect.d.ts"]=!0,D["lib.es2015.symbol.d.ts"]=!0,D["lib.es2015.symbol.wellknown.d.ts"]=!0,D["lib.es2016.array.include.d.ts"]=!0,D["lib.es2016.d.ts"]=!0,D["lib.es2016.full.d.ts"]=!0,D["lib.es2017.d.ts"]=!0,D["lib.es2017.full.d.ts"]=!0,D["lib.es2017.intl.d.ts"]=!0,D["lib.es2017.object.d.ts"]=!0,D["lib.es2017.sharedmemory.d.ts"]=!0,D["lib.es2017.string.d.ts"]=!0,D["lib.es2017.typedarrays.d.ts"]=!0,D["lib.es2018.asyncgenerator.d.ts"]=!0,D["lib.es2018.asynciterable.d.ts"]=!0,D["lib.es2018.d.ts"]=!0,D["lib.es2018.full.d.ts"]=!0,D["lib.es2018.intl.d.ts"]=!0,D["lib.es2018.promise.d.ts"]=!0,D["lib.es2018.regexp.d.ts"]=!0,D["lib.es2019.array.d.ts"]=!0,D["lib.es2019.d.ts"]=!0,D["lib.es2019.full.d.ts"]=!0,D["lib.es2019.object.d.ts"]=!0,D["lib.es2019.string.d.ts"]=!0,D["lib.es2019.symbol.d.ts"]=!0,D["lib.es2020.bigint.d.ts"]=!0,D["lib.es2020.d.ts"]=!0,D["lib.es2020.full.d.ts"]=!0,D["lib.es2020.intl.d.ts"]=!0,D["lib.es2020.promise.d.ts"]=!0,D["lib.es2020.sharedmemory.d.ts"]=!0,D["lib.es2020.string.d.ts"]=!0,D["lib.es2020.symbol.wellknown.d.ts"]=!0,D["lib.es2021.d.ts"]=!0,D["lib.es2021.full.d.ts"]=!0,D["lib.es2021.promise.d.ts"]=!0,D["lib.es2021.string.d.ts"]=!0,D["lib.es2021.weakref.d.ts"]=!0,D["lib.es5.d.ts"]=!0,D["lib.es6.d.ts"]=!0,D["lib.esnext.d.ts"]=!0,D["lib.esnext.full.d.ts"]=!0,D["lib.esnext.intl.d.ts"]=!0,D["lib.esnext.promise.d.ts"]=!0,D["lib.esnext.string.d.ts"]=!0,D["lib.esnext.weakref.d.ts"]=!0,D["lib.scripthost.d.ts"]=!0,D["lib.webworker.d.ts"]=!0,D["lib.webworker.importscripts.d.ts"]=!0,D["lib.webworker.iterable.d.ts"]=!0,(k=C||(C={}))[k.None=0]="None",k[k.Block=1]="Block",k[k.Smart=2]="Smart";var E,T,F=class{constructor(e){this._worker=e}_textSpanToRange(e,t){let i=e.getPositionAt(t.start),s=e.getPositionAt(t.start+t.length),{lineNumber:n,column:r}=i,{lineNumber:o,column:a}=s;return{startLineNumber:n,startColumn:r,endLineNumber:o,endColumn:a}}};(T=E||(E={}))[T.Warning=0]="Warning",T[T.Error=1]="Error",T[T.Suggestion=2]="Suggestion",T[T.Message=3]="Message";var I=class extends F{constructor(e,t,i,s){super(s),this._libFiles=e,this._defaults=t,this._selector=i,this._disposables=[],this._listener=Object.create(null);const n=e=>{if(e.getLanguageId()!==i)return;const t=()=>{const{onlyVisible:t}=this._defaults.getDiagnosticsOptions();t?e.isAttachedToEditor()&&this._doValidate(e):this._doValidate(e)};let s;const n=e.onDidChangeContent((()=>{clearTimeout(s),s=window.setTimeout(t,500)})),r=e.onDidChangeAttached((()=>{const{onlyVisible:i}=this._defaults.getDiagnosticsOptions();i&&(e.isAttachedToEditor()?t():c.editor.setModelMarkers(e,this._selector,[]))}));this._listener[e.uri.toString()]={dispose(){n.dispose(),r.dispose(),clearTimeout(s)}},t()},r=e=>{c.editor.setModelMarkers(e,this._selector,[]);const t=e.uri.toString();this._listener[t]&&(this._listener[t].dispose(),delete this._listener[t])};this._disposables.push(c.editor.onDidCreateModel((e=>n(e)))),this._disposables.push(c.editor.onWillDisposeModel(r)),this._disposables.push(c.editor.onDidChangeModelLanguage((e=>{r(e.model),n(e.model)}))),this._disposables.push({dispose(){for(const e of c.editor.getModels())r(e)}});const o=()=>{for(const e of c.editor.getModels())r(e),n(e)};this._disposables.push(this._defaults.onDidChange(o)),this._disposables.push(this._defaults.onDidExtraLibsChange(o)),c.editor.getModels().forEach((e=>n(e)))}dispose(){this._disposables.forEach((e=>e&&e.dispose())),this._disposables=[]}async _doValidate(e){const t=await this._worker(e.uri);if(e.isDisposed())return;const i=[],{noSyntaxValidation:s,noSemanticValidation:n,noSuggestionDiagnostics:r}=this._defaults.getDiagnosticsOptions();s||i.push(t.getSyntacticDiagnostics(e.uri.toString())),n||i.push(t.getSemanticDiagnostics(e.uri.toString())),r||i.push(t.getSuggestionDiagnostics(e.uri.toString()));const o=await Promise.all(i);if(!o||e.isDisposed())return;const a=o.reduce(((e,t)=>t.concat(e)),[]).filter((e=>-1===(this._defaults.getDiagnosticsOptions().diagnosticCodesToIgnore||[]).indexOf(e.code))),l=a.map((e=>e.relatedInformation||[])).reduce(((e,t)=>t.concat(e)),[]).map((e=>e.file?c.Uri.parse(e.file.fileName):null));await this._libFiles.fetchLibFilesIfNecessary(l),e.isDisposed()||c.editor.setModelMarkers(e,this._selector,a.map((t=>this._convertDiagnostics(e,t))))}_convertDiagnostics(e,t){const i=t.start||0,s=t.length||1,{lineNumber:n,column:r}=e.getPositionAt(i),{lineNumber:o,column:a}=e.getPositionAt(i+s),l=[];return t.reportsUnnecessary&&l.push(c.MarkerTag.Unnecessary),t.reportsDeprecated&&l.push(c.MarkerTag.Deprecated),{severity:this._tsDiagnosticCategoryToMarkerSeverity(t.category),startLineNumber:n,startColumn:r,endLineNumber:o,endColumn:a,message:L(t.messageText,"\n"),code:t.code.toString(),tags:l,relatedInformation:this._convertRelatedInformation(e,t.relatedInformation)}}_convertRelatedInformation(e,t){if(!t)return[];const i=[];return t.forEach((t=>{let s=e;if(t.file&&(s=this._libFiles.getOrCreateModel(t.file.fileName)),!s)return;const n=t.start||0,r=t.length||1,{lineNumber:o,column:a}=s.getPositionAt(n),{lineNumber:l,column:c}=s.getPositionAt(n+r);i.push({resource:s.uri,startLineNumber:o,startColumn:a,endLineNumber:l,endColumn:c,message:L(t.messageText,"\n")})})),i}_tsDiagnosticCategoryToMarkerSeverity(e){switch(e){case 1:return c.MarkerSeverity.Error;case 3:return c.MarkerSeverity.Info;case 0:return c.MarkerSeverity.Warning;case 2:return c.MarkerSeverity.Hint}return c.MarkerSeverity.Info}},N=class extends F{get triggerCharacters(){return["."]}async provideCompletionItems(e,t,i,s){const n=e.getWordUntilPosition(t),r=new c.Range(t.lineNumber,n.startColumn,t.lineNumber,n.endColumn),o=e.uri,a=e.getOffsetAt(t),l=await this._worker(o);if(e.isDisposed())return;const d=await l.getCompletionsAtPosition(o.toString(),a);if(!d||e.isDisposed())return;return{suggestions:d.entries.map((i=>{let s=r;if(i.replacementSpan){const t=e.getPositionAt(i.replacementSpan.start),n=e.getPositionAt(i.replacementSpan.start+i.replacementSpan.length);s=new c.Range(t.lineNumber,t.column,n.lineNumber,n.column)}const n=[];return-1!==i.kindModifiers?.indexOf("deprecated")&&n.push(c.languages.CompletionItemTag.Deprecated),{uri:o,position:t,offset:a,range:s,label:i.name,insertText:i.name,sortText:i.sortText,kind:N.convertKind(i.kind),tags:n}}))}}async resolveCompletionItem(e,t){const i=e,s=i.uri,n=i.position,r=i.offset,o=await this._worker(s),a=await o.getCompletionEntryDetails(s.toString(),r,i.label);return a?{uri:s,position:n,label:a.name,kind:N.convertKind(a.kind),detail:O(a.displayParts),documentation:{value:N.createDocumentationString(a)}}:i}static convertKind(e){switch(e){case W.primitiveType:case W.keyword:return c.languages.CompletionItemKind.Keyword;case W.variable:case W.localVariable:return c.languages.CompletionItemKind.Variable;case W.memberVariable:case W.memberGetAccessor:case W.memberSetAccessor:return c.languages.CompletionItemKind.Field;case W.function:case W.memberFunction:case W.constructSignature:case W.callSignature:case W.indexSignature:return c.languages.CompletionItemKind.Function;case W.enum:return c.languages.CompletionItemKind.Enum;case W.module:return c.languages.CompletionItemKind.Module;case W.class:return c.languages.CompletionItemKind.Class;case W.interface:return c.languages.CompletionItemKind.Interface;case W.warning:return c.languages.CompletionItemKind.File}return c.languages.CompletionItemKind.Property}static createDocumentationString(e){let t=O(e.documentation);if(e.tags)for(const i of e.tags)t+=`\n\n${P(i)}`;return t}};function P(e){let t=`*@${e.name}*`;if("param"===e.name&&e.text){const[i,...s]=e.text;t+=`\`${i.text}\``,s.length>0&&(t+=` — ${s.map((e=>e.text)).join(" ")}`)}else Array.isArray(e.text)?t+=` — ${e.text.map((e=>e.text)).join(" ")}`:e.text&&(t+=` — ${e.text}`);return t}var A=class extends F{constructor(){super(...arguments),this.signatureHelpTriggerCharacters=["(",","]}static _toSignatureHelpTriggerReason(e){switch(e.triggerKind){case c.languages.SignatureHelpTriggerKind.TriggerCharacter:return e.triggerCharacter?e.isRetrigger?{kind:"retrigger",triggerCharacter:e.triggerCharacter}:{kind:"characterTyped",triggerCharacter:e.triggerCharacter}:{kind:"invoked"};case c.languages.SignatureHelpTriggerKind.ContentChange:return e.isRetrigger?{kind:"retrigger"}:{kind:"invoked"};case c.languages.SignatureHelpTriggerKind.Invoke:default:return{kind:"invoked"}}}async provideSignatureHelp(e,t,i,s){const n=e.uri,r=e.getOffsetAt(t),o=await this._worker(n);if(e.isDisposed())return;const a=await o.getSignatureHelpItems(n.toString(),r,{triggerReason:A._toSignatureHelpTriggerReason(s)});if(!a||e.isDisposed())return;const l={activeSignature:a.selectedItemIndex,activeParameter:a.argumentIndex,signatures:[]};return a.items.forEach((e=>{const t={label:"",parameters:[]};t.documentation={value:O(e.documentation)},t.label+=O(e.prefixDisplayParts),e.parameters.forEach(((i,s,n)=>{const r=O(i.displayParts),o={label:r,documentation:{value:O(i.documentation)}};t.label+=r,t.parameters.push(o),s<n.length-1&&(t.label+=O(e.separatorDisplayParts))})),t.label+=O(e.suffixDisplayParts),l.signatures.push(t)})),{value:l,dispose(){}}}},M=class extends F{async provideHover(e,t,i){const s=e.uri,n=e.getOffsetAt(t),r=await this._worker(s);if(e.isDisposed())return;const o=await r.getQuickInfoAtPosition(s.toString(),n);if(!o||e.isDisposed())return;const a=O(o.documentation),l=o.tags?o.tags.map((e=>P(e))).join("  \n\n"):"",c=O(o.displayParts);return{range:this._textSpanToRange(e,o.textSpan),contents:[{value:"```typescript\n"+c+"\n```\n"},{value:a+(l?"\n\n"+l:"")}]}}},R=class extends F{async provideDocumentHighlights(e,t,i){const s=e.uri,n=e.getOffsetAt(t),r=await this._worker(s);if(e.isDisposed())return;const o=await r.getOccurrencesAtPosition(s.toString(),n);return o&&!e.isDisposed()?o.map((t=>({range:this._textSpanToRange(e,t.textSpan),kind:t.isWriteAccess?c.languages.DocumentHighlightKind.Write:c.languages.DocumentHighlightKind.Text}))):void 0}},K=class extends F{constructor(e,t){super(t),this._libFiles=e}async provideDefinition(e,t,i){const s=e.uri,n=e.getOffsetAt(t),r=await this._worker(s);if(e.isDisposed())return;const o=await r.getDefinitionAtPosition(s.toString(),n);if(!o||e.isDisposed())return;if(await this._libFiles.fetchLibFilesIfNecessary(o.map((e=>c.Uri.parse(e.fileName)))),e.isDisposed())return;const a=[];for(let e of o){const t=this._libFiles.getOrCreateModel(e.fileName);t&&a.push({uri:t.uri,range:this._textSpanToRange(t,e.textSpan)})}return a}},H=class extends F{constructor(e,t){super(t),this._libFiles=e}async provideReferences(e,t,i,s){const n=e.uri,r=e.getOffsetAt(t),o=await this._worker(n);if(e.isDisposed())return;const a=await o.getReferencesAtPosition(n.toString(),r);if(!a||e.isDisposed())return;if(await this._libFiles.fetchLibFilesIfNecessary(a.map((e=>c.Uri.parse(e.fileName)))),e.isDisposed())return;const l=[];for(let e of a){const t=this._libFiles.getOrCreateModel(e.fileName);t&&l.push({uri:t.uri,range:this._textSpanToRange(t,e.textSpan)})}return l}},V=class extends F{async provideDocumentSymbols(e,t){const i=e.uri,s=await this._worker(i);if(e.isDisposed())return;const n=await s.getNavigationBarItems(i.toString());if(!n||e.isDisposed())return;const r=(t,i,s)=>{let n={name:i.text,detail:"",kind:j[i.kind]||c.languages.SymbolKind.Variable,range:this._textSpanToRange(e,i.spans[0]),selectionRange:this._textSpanToRange(e,i.spans[0]),tags:[]};if(s&&(n.containerName=s),i.childItems&&i.childItems.length>0)for(let e of i.childItems)r(t,e,n.name);t.push(n)};let o=[];return n.forEach((e=>r(o,e))),o}},W=class{};W.unknown="",W.keyword="keyword",W.script="script",W.module="module",W.class="class",W.interface="interface",W.type="type",W.enum="enum",W.variable="var",W.localVariable="local var",W.function="function",W.localFunction="local function",W.memberFunction="method",W.memberGetAccessor="getter",W.memberSetAccessor="setter",W.memberVariable="property",W.constructorImplementation="constructor",W.callSignature="call",W.indexSignature="index",W.constructSignature="construct",W.parameter="parameter",W.typeParameter="type parameter",W.primitiveType="primitive type",W.label="label",W.alias="alias",W.const="const",W.let="let",W.warning="warning";var j=Object.create(null);j[W.module]=c.languages.SymbolKind.Module,j[W.class]=c.languages.SymbolKind.Class,j[W.enum]=c.languages.SymbolKind.Enum,j[W.interface]=c.languages.SymbolKind.Interface,j[W.memberFunction]=c.languages.SymbolKind.Method,j[W.memberVariable]=c.languages.SymbolKind.Property,j[W.memberGetAccessor]=c.languages.SymbolKind.Property,j[W.memberSetAccessor]=c.languages.SymbolKind.Property,j[W.variable]=c.languages.SymbolKind.Variable,j[W.const]=c.languages.SymbolKind.Variable,j[W.localVariable]=c.languages.SymbolKind.Variable,j[W.variable]=c.languages.SymbolKind.Variable,j[W.function]=c.languages.SymbolKind.Function,j[W.localFunction]=c.languages.SymbolKind.Function;var J,B,$=class extends F{static _convertOptions(e){return{ConvertTabsToSpaces:e.insertSpaces,TabSize:e.tabSize,IndentSize:e.tabSize,IndentStyle:2,NewLineCharacter:"\n",InsertSpaceAfterCommaDelimiter:!0,InsertSpaceAfterSemicolonInForStatements:!0,InsertSpaceBeforeAndAfterBinaryOperators:!0,InsertSpaceAfterKeywordsInControlFlowStatements:!0,InsertSpaceAfterFunctionKeywordForAnonymousFunctions:!0,InsertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis:!1,InsertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets:!1,InsertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces:!1,PlaceOpenBraceOnNewLineForControlBlocks:!1,PlaceOpenBraceOnNewLineForFunctions:!1}}_convertTextChanges(e,t){return{text:t.newText,range:this._textSpanToRange(e,t.span)}}},U=class extends ${async provideDocumentRangeFormattingEdits(e,t,i,s){const n=e.uri,r=e.getOffsetAt({lineNumber:t.startLineNumber,column:t.startColumn}),o=e.getOffsetAt({lineNumber:t.endLineNumber,column:t.endColumn}),a=await this._worker(n);if(e.isDisposed())return;const l=await a.getFormattingEditsForRange(n.toString(),r,o,$._convertOptions(i));return l&&!e.isDisposed()?l.map((t=>this._convertTextChanges(e,t))):void 0}},z=class extends ${get autoFormatTriggerCharacters(){return[";","}","\n"]}async provideOnTypeFormattingEdits(e,t,i,s,n){const r=e.uri,o=e.getOffsetAt(t),a=await this._worker(r);if(e.isDisposed())return;const l=await a.getFormattingEditsAfterKeystroke(r.toString(),o,i,$._convertOptions(s));return l&&!e.isDisposed()?l.map((t=>this._convertTextChanges(e,t))):void 0}},X=class extends ${async provideCodeActions(e,t,i,s){const n=e.uri,r=e.getOffsetAt({lineNumber:t.startLineNumber,column:t.startColumn}),o=e.getOffsetAt({lineNumber:t.endLineNumber,column:t.endColumn}),a=$._convertOptions(e.getOptions()),l=i.markers.filter((e=>e.code)).map((e=>e.code)).map(Number),c=await this._worker(n);if(e.isDisposed())return;const d=await c.getCodeFixesAtPosition(n.toString(),r,o,l,a);if(!d||e.isDisposed())return{actions:[],dispose:()=>{}};return{actions:d.filter((e=>0===e.changes.filter((e=>e.isNewFile)).length)).map((t=>this._tsCodeFixActionToMonacoCodeAction(e,i,t))),dispose:()=>{}}}_tsCodeFixActionToMonacoCodeAction(e,t,i){const s=[];for(const t of i.changes)for(const i of t.textChanges)s.push({resource:e.uri,edit:{range:this._textSpanToRange(e,i.span),text:i.newText}});return{title:i.description,edit:{edits:s},diagnostics:t.markers,kind:"quickfix"}}},G=class extends F{constructor(e,t){super(t),this._libFiles=e}async provideRenameEdits(e,t,i,s){const n=e.uri,r=n.toString(),o=e.getOffsetAt(t),a=await this._worker(n);if(e.isDisposed())return;const l=await a.getRenameInfo(r,o,{allowRenameOfImportPath:!1});if(!1===l.canRename)return{edits:[],rejectReason:l.localizedErrorMessage};if(void 0!==l.fileToRename)throw new Error("Renaming files is not supported.");const c=await a.findRenameLocations(r,o,!1,!1,!1);if(!c||e.isDisposed())return;const d=[];for(const e of c){const t=this._libFiles.getOrCreateModel(e.fileName);if(!t)throw new Error(`Unknown file ${e.fileName}.`);d.push({resource:t.uri,edit:{range:this._textSpanToRange(t,e.textSpan),text:i}})}return{edits:d}}},q=class extends F{async provideInlayHints(e,t,i){const s=e.uri,n=s.toString(),r=e.getOffsetAt({lineNumber:t.startLineNumber,column:t.startColumn}),o=e.getOffsetAt({lineNumber:t.endLineNumber,column:t.endColumn}),a=await this._worker(s);if(e.isDisposed())return[];return(await a.provideInlayHints(n,r,o)).map((t=>({...t,position:e.getPositionAt(t.position),kind:this._convertHintKind(t.kind)})))}_convertHintKind(e){switch(e){case"Parameter":return c.languages.InlayHintKind.Parameter;case"Type":return c.languages.InlayHintKind.Type;default:return c.languages.InlayHintKind.Other}}};function Q(e){B=te(e,"typescript")}function Y(e){J=te(e,"javascript")}function Z(){return new Promise(((e,t)=>{if(!J)return t("JavaScript not registered!");e(J)}))}function ee(){return new Promise(((e,t)=>{if(!B)return t("TypeScript not registered!");e(B)}))}function te(e,t){const i=new class{constructor(e,t){this._modeId=e,this._defaults=t,this._worker=null,this._client=null,this._configChangeListener=this._defaults.onDidChange((()=>this._stopWorker())),this._updateExtraLibsToken=0,this._extraLibsChangeListener=this._defaults.onDidExtraLibsChange((()=>this._updateExtraLibs()))}_stopWorker(){this._worker&&(this._worker.dispose(),this._worker=null),this._client=null}dispose(){this._configChangeListener.dispose(),this._extraLibsChangeListener.dispose(),this._stopWorker()}async _updateExtraLibs(){if(!this._worker)return;const e=++this._updateExtraLibsToken,t=await this._worker.getProxy();this._updateExtraLibsToken===e&&t.updateExtraLibs(this._defaults.getExtraLibs())}_getClient(){if(!this._client){this._worker=c.editor.createWebWorker({moduleId:"vs/language/typescript/tsWorker",label:this._modeId,keepIdleModels:!0,createData:{compilerOptions:this._defaults.getCompilerOptions(),extraLibs:this._defaults.getExtraLibs(),customWorkerPath:this._defaults.workerOptions.customWorkerPath,inlayHintsOptions:this._defaults.inlayHintsOptions}});let e=this._worker.getProxy();this._defaults.getEagerModelSync()&&(e=e.then((e=>this._worker?this._worker.withSyncedResources(c.editor.getModels().filter((e=>e.getLanguageId()===this._modeId)).map((e=>e.uri))):e))),this._client=e}return this._client}getLanguageServiceWorker(...e){let t;return this._getClient().then((e=>{t=e})).then((t=>{if(this._worker)return this._worker.withSyncedResources(e)})).then((e=>t))}}(t,e),s=(...e)=>i.getLanguageServiceWorker(...e),n=new class{constructor(e){this._worker=e,this._libFiles={},this._hasFetchedLibFiles=!1,this._fetchLibFilesPromise=null}isLibFile(e){return!!e&&0===e.path.indexOf("/lib.")&&!!D[e.path.slice(1)]}getOrCreateModel(e){const t=c.Uri.parse(e),i=c.editor.getModel(t);if(i)return i;if(this.isLibFile(t)&&this._hasFetchedLibFiles)return c.editor.createModel(this._libFiles[t.path.slice(1)],"typescript",t);const s=x.getExtraLibs()[e];return s?c.editor.createModel(s.content,"typescript",t):null}_containsLibFile(e){for(let t of e)if(this.isLibFile(t))return!0;return!1}async fetchLibFilesIfNecessary(e){this._containsLibFile(e)&&await this._fetchLibFiles()}_fetchLibFiles(){return this._fetchLibFilesPromise||(this._fetchLibFilesPromise=this._worker().then((e=>e.getLibFiles())).then((e=>{this._hasFetchedLibFiles=!0,this._libFiles=e}))),this._fetchLibFilesPromise}}(s);return c.languages.registerCompletionItemProvider(t,new N(s)),c.languages.registerSignatureHelpProvider(t,new A(s)),c.languages.registerHoverProvider(t,new M(s)),c.languages.registerDocumentHighlightProvider(t,new R(s)),c.languages.registerDefinitionProvider(t,new K(n,s)),c.languages.registerReferenceProvider(t,new H(n,s)),c.languages.registerDocumentSymbolProvider(t,new V(s)),c.languages.registerDocumentRangeFormattingEditProvider(t,new U(s)),c.languages.registerOnTypeFormattingEditProvider(t,new z(s)),c.languages.registerCodeActionProvider(t,new X(s)),c.languages.registerRenameProvider(t,new G(n,s)),c.languages.registerInlayHintsProvider(t,new q(s)),new I(n,e,t,s),s}}));