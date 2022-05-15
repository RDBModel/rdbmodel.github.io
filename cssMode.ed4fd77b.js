var e=("undefined"!=typeof globalThis?globalThis:"undefined"!=typeof self?self:"undefined"!=typeof window?window:"undefined"!=typeof global?global:{}).parcelRequiref17b;e.register("2LfUJ",(function(t,n){var r,i,o,a;r=t.exports,i="setupMode",o=()=>yt,Object.defineProperty(r,i,{get:o,set:a,enumerable:!0,configurable:!0});var s=e("cDseA"),u=Object.defineProperty,c=Object.getOwnPropertyDescriptor,d=Object.getOwnPropertyNames,g=Object.prototype.hasOwnProperty,l={};u(l,"__esModule",{value:!0}),((e,t,n)=>{if(t&&"object"==typeof t||"function"==typeof t)for(let r of d(t))g.call(e,r)||"default"===r||u(e,r,{get:()=>t[r],enumerable:!(n=c(t,r))||n.enumerable})})(l,s);var h,f,p,v,m,_,w,b,y,k,C,E,x,I,A,S,T,R,M,P,D,L,j,O,F,N,U,W,V,H,K,z,X,B,q,$,J,Q,G,Y,Z,ee,te,ne,re,ie,oe,ae,se;(f=h||(h={})).MIN_VALUE=-2147483648,f.MAX_VALUE=2147483647,(v=p||(p={})).MIN_VALUE=0,v.MAX_VALUE=2147483647,(_=m||(m={})).create=function(e,t){return e===Number.MAX_VALUE&&(e=p.MAX_VALUE),t===Number.MAX_VALUE&&(t=p.MAX_VALUE),{line:e,character:t}},_.is=function(e){var t=e;return st.objectLiteral(t)&&st.uinteger(t.line)&&st.uinteger(t.character)},(b=w||(w={})).create=function(e,t,n,r){if(st.uinteger(e)&&st.uinteger(t)&&st.uinteger(n)&&st.uinteger(r))return{start:m.create(e,t),end:m.create(n,r)};if(m.is(e)&&m.is(t))return{start:e,end:t};throw new Error("Range#create called with invalid arguments["+e+", "+t+", "+n+", "+r+"]")},b.is=function(e){var t=e;return st.objectLiteral(t)&&m.is(t.start)&&m.is(t.end)},(k=y||(y={})).create=function(e,t){return{uri:e,range:t}},k.is=function(e){var t=e;return st.defined(t)&&w.is(t.range)&&(st.string(t.uri)||st.undefined(t.uri))},(E=C||(C={})).create=function(e,t,n,r){return{targetUri:e,targetRange:t,targetSelectionRange:n,originSelectionRange:r}},E.is=function(e){var t=e;return st.defined(t)&&w.is(t.targetRange)&&st.string(t.targetUri)&&(w.is(t.targetSelectionRange)||st.undefined(t.targetSelectionRange))&&(w.is(t.originSelectionRange)||st.undefined(t.originSelectionRange))},(I=x||(x={})).create=function(e,t,n,r){return{red:e,green:t,blue:n,alpha:r}},I.is=function(e){var t=e;return st.numberRange(t.red,0,1)&&st.numberRange(t.green,0,1)&&st.numberRange(t.blue,0,1)&&st.numberRange(t.alpha,0,1)},(S=A||(A={})).create=function(e,t){return{range:e,color:t}},S.is=function(e){var t=e;return w.is(t.range)&&x.is(t.color)},(R=T||(T={})).create=function(e,t,n){return{label:e,textEdit:t,additionalTextEdits:n}},R.is=function(e){var t=e;return st.string(t.label)&&(st.undefined(t.textEdit)||B.is(t))&&(st.undefined(t.additionalTextEdits)||st.typedArray(t.additionalTextEdits,B.is))},(P=M||(M={})).Comment="comment",P.Imports="imports",P.Region="region",(L=D||(D={})).create=function(e,t,n,r,i){var o={startLine:e,endLine:t};return st.defined(n)&&(o.startCharacter=n),st.defined(r)&&(o.endCharacter=r),st.defined(i)&&(o.kind=i),o},L.is=function(e){var t=e;return st.uinteger(t.startLine)&&st.uinteger(t.startLine)&&(st.undefined(t.startCharacter)||st.uinteger(t.startCharacter))&&(st.undefined(t.endCharacter)||st.uinteger(t.endCharacter))&&(st.undefined(t.kind)||st.string(t.kind))},(O=j||(j={})).create=function(e,t){return{location:e,message:t}},O.is=function(e){var t=e;return st.defined(t)&&y.is(t.location)&&st.string(t.message)},(N=F||(F={})).Error=1,N.Warning=2,N.Information=3,N.Hint=4,(W=U||(U={})).Unnecessary=1,W.Deprecated=2,(V||(V={})).is=function(e){var t=e;return null!=t&&st.string(t.href)},(K=H||(H={})).create=function(e,t,n,r,i,o){var a={range:e,message:t};return st.defined(n)&&(a.severity=n),st.defined(r)&&(a.code=r),st.defined(i)&&(a.source=i),st.defined(o)&&(a.relatedInformation=o),a},K.is=function(e){var t,n=e;return st.defined(n)&&w.is(n.range)&&st.string(n.message)&&(st.number(n.severity)||st.undefined(n.severity))&&(st.integer(n.code)||st.string(n.code)||st.undefined(n.code))&&(st.undefined(n.codeDescription)||st.string(null===(t=n.codeDescription)||void 0===t?void 0:t.href))&&(st.string(n.source)||st.undefined(n.source))&&(st.undefined(n.relatedInformation)||st.typedArray(n.relatedInformation,j.is))},(X=z||(z={})).create=function(e,t){for(var n=[],r=2;r<arguments.length;r++)n[r-2]=arguments[r];var i={title:e,command:t};return st.defined(n)&&n.length>0&&(i.arguments=n),i},X.is=function(e){var t=e;return st.defined(t)&&st.string(t.title)&&st.string(t.command)},(q=B||(B={})).replace=function(e,t){return{range:e,newText:t}},q.insert=function(e,t){return{range:{start:e,end:e},newText:t}},q.del=function(e){return{range:e,newText:""}},q.is=function(e){var t=e;return st.objectLiteral(t)&&st.string(t.newText)&&w.is(t.range)},(J=$||($={})).create=function(e,t,n){var r={label:e};return void 0!==t&&(r.needsConfirmation=t),void 0!==n&&(r.description=n),r},J.is=function(e){var t=e;return void 0!==t&&st.objectLiteral(t)&&st.string(t.label)&&(st.boolean(t.needsConfirmation)||void 0===t.needsConfirmation)&&(st.string(t.description)||void 0===t.description)},(Q||(Q={})).is=function(e){return"string"==typeof e},(Y=G||(G={})).replace=function(e,t,n){return{range:e,newText:t,annotationId:n}},Y.insert=function(e,t,n){return{range:{start:e,end:e},newText:t,annotationId:n}},Y.del=function(e,t){return{range:e,newText:"",annotationId:t}},Y.is=function(e){var t=e;return B.is(t)&&($.is(t.annotationId)||Q.is(t.annotationId))},(ee=Z||(Z={})).create=function(e,t){return{textDocument:e,edits:t}},ee.is=function(e){var t=e;return st.defined(t)&&le.is(t.textDocument)&&Array.isArray(t.edits)},(ne=te||(te={})).create=function(e,t,n){var r={kind:"create",uri:e};return void 0===t||void 0===t.overwrite&&void 0===t.ignoreIfExists||(r.options=t),void 0!==n&&(r.annotationId=n),r},ne.is=function(e){var t=e;return t&&"create"===t.kind&&st.string(t.uri)&&(void 0===t.options||(void 0===t.options.overwrite||st.boolean(t.options.overwrite))&&(void 0===t.options.ignoreIfExists||st.boolean(t.options.ignoreIfExists)))&&(void 0===t.annotationId||Q.is(t.annotationId))},(ie=re||(re={})).create=function(e,t,n,r){var i={kind:"rename",oldUri:e,newUri:t};return void 0===n||void 0===n.overwrite&&void 0===n.ignoreIfExists||(i.options=n),void 0!==r&&(i.annotationId=r),i},ie.is=function(e){var t=e;return t&&"rename"===t.kind&&st.string(t.oldUri)&&st.string(t.newUri)&&(void 0===t.options||(void 0===t.options.overwrite||st.boolean(t.options.overwrite))&&(void 0===t.options.ignoreIfExists||st.boolean(t.options.ignoreIfExists)))&&(void 0===t.annotationId||Q.is(t.annotationId))},(ae=oe||(oe={})).create=function(e,t,n){var r={kind:"delete",uri:e};return void 0===t||void 0===t.recursive&&void 0===t.ignoreIfNotExists||(r.options=t),void 0!==n&&(r.annotationId=n),r},ae.is=function(e){var t=e;return t&&"delete"===t.kind&&st.string(t.uri)&&(void 0===t.options||(void 0===t.options.recursive||st.boolean(t.options.recursive))&&(void 0===t.options.ignoreIfNotExists||st.boolean(t.options.ignoreIfNotExists)))&&(void 0===t.annotationId||Q.is(t.annotationId))},(se||(se={})).is=function(e){var t=e;return t&&(void 0!==t.changes||void 0!==t.documentChanges)&&(void 0===t.documentChanges||t.documentChanges.every((function(e){return st.string(e.kind)?te.is(e)||re.is(e)||oe.is(e):Z.is(e)})))};var ue,ce,de,ge,le,he,fe,pe,ve,me,_e,we,be,ye,ke,Ce,Ee,xe,Ie,Ae,Se,Te,Re,Me,Pe,De,Le,je,Oe,Fe,Ne,Ue,We,Ve,He,Ke,ze,Xe,Be,qe,$e,Je,Qe,Ge,Ye,Ze,et,tt,nt,rt,it,ot=function(){function e(e,t){this.edits=e,this.changeAnnotations=t}return e.prototype.insert=function(e,t,n){var r,i;if(void 0===n?r=B.insert(e,t):Q.is(n)?(i=n,r=G.insert(e,t,n)):(this.assertChangeAnnotations(this.changeAnnotations),i=this.changeAnnotations.manage(n),r=G.insert(e,t,i)),this.edits.push(r),void 0!==i)return i},e.prototype.replace=function(e,t,n){var r,i;if(void 0===n?r=B.replace(e,t):Q.is(n)?(i=n,r=G.replace(e,t,n)):(this.assertChangeAnnotations(this.changeAnnotations),i=this.changeAnnotations.manage(n),r=G.replace(e,t,i)),this.edits.push(r),void 0!==i)return i},e.prototype.delete=function(e,t){var n,r;if(void 0===t?n=B.del(e):Q.is(t)?(r=t,n=G.del(e,t)):(this.assertChangeAnnotations(this.changeAnnotations),r=this.changeAnnotations.manage(t),n=G.del(e,r)),this.edits.push(n),void 0!==r)return r},e.prototype.add=function(e){this.edits.push(e)},e.prototype.all=function(){return this.edits},e.prototype.clear=function(){this.edits.splice(0,this.edits.length)},e.prototype.assertChangeAnnotations=function(e){if(void 0===e)throw new Error("Text edit change is not configured to manage change annotations.")},e}(),at=function(){function e(e){this._annotations=void 0===e?Object.create(null):e,this._counter=0,this._size=0}return e.prototype.all=function(){return this._annotations},Object.defineProperty(e.prototype,"size",{get:function(){return this._size},enumerable:!1,configurable:!0}),e.prototype.manage=function(e,t){var n;if(Q.is(e)?n=e:(n=this.nextId(),t=e),void 0!==this._annotations[n])throw new Error("Id "+n+" is already in use.");if(void 0===t)throw new Error("No annotation provided for id "+n);return this._annotations[n]=t,this._size++,n},e.prototype.nextId=function(){return this._counter++,this._counter.toString()},e}();!function(){function e(e){var t=this;this._textEditChanges=Object.create(null),void 0!==e?(this._workspaceEdit=e,e.documentChanges?(this._changeAnnotations=new at(e.changeAnnotations),e.changeAnnotations=this._changeAnnotations.all(),e.documentChanges.forEach((function(e){if(Z.is(e)){var n=new ot(e.edits,t._changeAnnotations);t._textEditChanges[e.textDocument.uri]=n}}))):e.changes&&Object.keys(e.changes).forEach((function(n){var r=new ot(e.changes[n]);t._textEditChanges[n]=r}))):this._workspaceEdit={}}Object.defineProperty(e.prototype,"edit",{get:function(){return this.initDocumentChanges(),void 0!==this._changeAnnotations&&(0===this._changeAnnotations.size?this._workspaceEdit.changeAnnotations=void 0:this._workspaceEdit.changeAnnotations=this._changeAnnotations.all()),this._workspaceEdit},enumerable:!1,configurable:!0}),e.prototype.getTextEditChange=function(e){if(le.is(e)){if(this.initDocumentChanges(),void 0===this._workspaceEdit.documentChanges)throw new Error("Workspace edit is not configured for document changes.");var t={uri:e.uri,version:e.version};if(!(r=this._textEditChanges[t.uri])){var n={textDocument:t,edits:i=[]};this._workspaceEdit.documentChanges.push(n),r=new ot(i,this._changeAnnotations),this._textEditChanges[t.uri]=r}return r}if(this.initChanges(),void 0===this._workspaceEdit.changes)throw new Error("Workspace edit is not configured for normal text edit changes.");var r;if(!(r=this._textEditChanges[e])){var i=[];this._workspaceEdit.changes[e]=i,r=new ot(i),this._textEditChanges[e]=r}return r},e.prototype.initDocumentChanges=function(){void 0===this._workspaceEdit.documentChanges&&void 0===this._workspaceEdit.changes&&(this._changeAnnotations=new at,this._workspaceEdit.documentChanges=[],this._workspaceEdit.changeAnnotations=this._changeAnnotations.all())},e.prototype.initChanges=function(){void 0===this._workspaceEdit.documentChanges&&void 0===this._workspaceEdit.changes&&(this._workspaceEdit.changes=Object.create(null))},e.prototype.createFile=function(e,t,n){if(this.initDocumentChanges(),void 0===this._workspaceEdit.documentChanges)throw new Error("Workspace edit is not configured for document changes.");var r,i,o;if($.is(t)||Q.is(t)?r=t:n=t,void 0===r?i=te.create(e,n):(o=Q.is(r)?r:this._changeAnnotations.manage(r),i=te.create(e,n,o)),this._workspaceEdit.documentChanges.push(i),void 0!==o)return o},e.prototype.renameFile=function(e,t,n,r){if(this.initDocumentChanges(),void 0===this._workspaceEdit.documentChanges)throw new Error("Workspace edit is not configured for document changes.");var i,o,a;if($.is(n)||Q.is(n)?i=n:r=n,void 0===i?o=re.create(e,t,r):(a=Q.is(i)?i:this._changeAnnotations.manage(i),o=re.create(e,t,r,a)),this._workspaceEdit.documentChanges.push(o),void 0!==a)return a},e.prototype.deleteFile=function(e,t,n){if(this.initDocumentChanges(),void 0===this._workspaceEdit.documentChanges)throw new Error("Workspace edit is not configured for document changes.");var r,i,o;if($.is(t)||Q.is(t)?r=t:n=t,void 0===r?i=oe.create(e,n):(o=Q.is(r)?r:this._changeAnnotations.manage(r),i=oe.create(e,n,o)),this._workspaceEdit.documentChanges.push(i),void 0!==o)return o}}();(ce=ue||(ue={})).create=function(e){return{uri:e}},ce.is=function(e){var t=e;return st.defined(t)&&st.string(t.uri)},(ge=de||(de={})).create=function(e,t){return{uri:e,version:t}},ge.is=function(e){var t=e;return st.defined(t)&&st.string(t.uri)&&st.integer(t.version)},(he=le||(le={})).create=function(e,t){return{uri:e,version:t}},he.is=function(e){var t=e;return st.defined(t)&&st.string(t.uri)&&(null===t.version||st.integer(t.version))},(pe=fe||(fe={})).create=function(e,t,n,r){return{uri:e,languageId:t,version:n,text:r}},pe.is=function(e){var t=e;return st.defined(t)&&st.string(t.uri)&&st.string(t.languageId)&&st.integer(t.version)&&st.string(t.text)},(me=ve||(ve={})).PlainText="plaintext",me.Markdown="markdown",function(e){e.is=function(t){var n=t;return n===e.PlainText||n===e.Markdown}}(ve||(ve={})),(_e||(_e={})).is=function(e){var t=e;return st.objectLiteral(e)&&ve.is(t.kind)&&st.string(t.value)},(be=we||(we={})).Text=1,be.Method=2,be.Function=3,be.Constructor=4,be.Field=5,be.Variable=6,be.Class=7,be.Interface=8,be.Module=9,be.Property=10,be.Unit=11,be.Value=12,be.Enum=13,be.Keyword=14,be.Snippet=15,be.Color=16,be.File=17,be.Reference=18,be.Folder=19,be.EnumMember=20,be.Constant=21,be.Struct=22,be.Event=23,be.Operator=24,be.TypeParameter=25,(ke=ye||(ye={})).PlainText=1,ke.Snippet=2,(Ce||(Ce={})).Deprecated=1,(xe=Ee||(Ee={})).create=function(e,t,n){return{newText:e,insert:t,replace:n}},xe.is=function(e){var t=e;return t&&st.string(t.newText)&&w.is(t.insert)&&w.is(t.replace)},(Ae=Ie||(Ie={})).asIs=1,Ae.adjustIndentation=2,(Se||(Se={})).create=function(e){return{label:e}},(Te||(Te={})).create=function(e,t){return{items:e||[],isIncomplete:!!t}},(Me=Re||(Re={})).fromPlainText=function(e){return e.replace(/[\\`*_{}[\]()#+\-.!]/g,"\\$&")},Me.is=function(e){var t=e;return st.string(t)||st.objectLiteral(t)&&st.string(t.language)&&st.string(t.value)},(Pe||(Pe={})).is=function(e){var t=e;return!!t&&st.objectLiteral(t)&&(_e.is(t.contents)||Re.is(t.contents)||st.typedArray(t.contents,Re.is))&&(void 0===e.range||w.is(e.range))},(De||(De={})).create=function(e,t){return t?{label:e,documentation:t}:{label:e}},(Le||(Le={})).create=function(e,t){for(var n=[],r=2;r<arguments.length;r++)n[r-2]=arguments[r];var i={label:e};return st.defined(t)&&(i.documentation=t),st.defined(n)?i.parameters=n:i.parameters=[],i},(Oe=je||(je={})).Text=1,Oe.Read=2,Oe.Write=3,(Fe||(Fe={})).create=function(e,t){var n={range:e};return st.number(t)&&(n.kind=t),n},(Ue=Ne||(Ne={})).File=1,Ue.Module=2,Ue.Namespace=3,Ue.Package=4,Ue.Class=5,Ue.Method=6,Ue.Property=7,Ue.Field=8,Ue.Constructor=9,Ue.Enum=10,Ue.Interface=11,Ue.Function=12,Ue.Variable=13,Ue.Constant=14,Ue.String=15,Ue.Number=16,Ue.Boolean=17,Ue.Array=18,Ue.Object=19,Ue.Key=20,Ue.Null=21,Ue.EnumMember=22,Ue.Struct=23,Ue.Event=24,Ue.Operator=25,Ue.TypeParameter=26,(We||(We={})).Deprecated=1,(Ve||(Ve={})).create=function(e,t,n,r,i){var o={name:e,kind:t,location:{uri:r,range:n}};return i&&(o.containerName=i),o},(Ke=He||(He={})).create=function(e,t,n,r,i,o){var a={name:e,detail:t,kind:n,range:r,selectionRange:i};return void 0!==o&&(a.children=o),a},Ke.is=function(e){var t=e;return t&&st.string(t.name)&&st.number(t.kind)&&w.is(t.range)&&w.is(t.selectionRange)&&(void 0===t.detail||st.string(t.detail))&&(void 0===t.deprecated||st.boolean(t.deprecated))&&(void 0===t.children||Array.isArray(t.children))&&(void 0===t.tags||Array.isArray(t.tags))},(Xe=ze||(ze={})).Empty="",Xe.QuickFix="quickfix",Xe.Refactor="refactor",Xe.RefactorExtract="refactor.extract",Xe.RefactorInline="refactor.inline",Xe.RefactorRewrite="refactor.rewrite",Xe.Source="source",Xe.SourceOrganizeImports="source.organizeImports",Xe.SourceFixAll="source.fixAll",(qe=Be||(Be={})).create=function(e,t){var n={diagnostics:e};return null!=t&&(n.only=t),n},qe.is=function(e){var t=e;return st.defined(t)&&st.typedArray(t.diagnostics,H.is)&&(void 0===t.only||st.typedArray(t.only,st.string))},(Je=$e||($e={})).create=function(e,t,n){var r={title:e},i=!0;return"string"==typeof t?(i=!1,r.kind=t):z.is(t)?r.command=t:r.edit=t,i&&void 0!==n&&(r.kind=n),r},Je.is=function(e){var t=e;return t&&st.string(t.title)&&(void 0===t.diagnostics||st.typedArray(t.diagnostics,H.is))&&(void 0===t.kind||st.string(t.kind))&&(void 0!==t.edit||void 0!==t.command)&&(void 0===t.command||z.is(t.command))&&(void 0===t.isPreferred||st.boolean(t.isPreferred))&&(void 0===t.edit||se.is(t.edit))},(Ge=Qe||(Qe={})).create=function(e,t){var n={range:e};return st.defined(t)&&(n.data=t),n},Ge.is=function(e){var t=e;return st.defined(t)&&w.is(t.range)&&(st.undefined(t.command)||z.is(t.command))},(Ze=Ye||(Ye={})).create=function(e,t){return{tabSize:e,insertSpaces:t}},Ze.is=function(e){var t=e;return st.defined(t)&&st.uinteger(t.tabSize)&&st.boolean(t.insertSpaces)},(tt=et||(et={})).create=function(e,t,n){return{range:e,target:t,data:n}},tt.is=function(e){var t=e;return st.defined(t)&&w.is(t.range)&&(st.undefined(t.target)||st.string(t.target))},(rt=nt||(nt={})).create=function(e,t){return{range:e,parent:t}},rt.is=function(e){var t=e;return void 0!==t&&w.is(t.range)&&(void 0===t.parent||rt.is(t.parent))},function(e){function t(e,n){if(e.length<=1)return e;var r=e.length/2|0,i=e.slice(0,r),o=e.slice(r);t(i,n),t(o,n);for(var a=0,s=0,u=0;a<i.length&&s<o.length;){var c=n(i[a],o[s]);e[u++]=c<=0?i[a++]:o[s++]}for(;a<i.length;)e[u++]=i[a++];for(;s<o.length;)e[u++]=o[s++];return e}e.create=function(e,t,n,r){return new dt(e,t,n,r)},e.is=function(e){var t=e;return!!(st.defined(t)&&st.string(t.uri)&&(st.undefined(t.languageId)||st.string(t.languageId))&&st.uinteger(t.lineCount)&&st.func(t.getText)&&st.func(t.positionAt)&&st.func(t.offsetAt))},e.applyEdits=function(e,n){for(var r=e.getText(),i=t(n,(function(e,t){var n=e.range.start.line-t.range.start.line;return 0===n?e.range.start.character-t.range.start.character:n})),o=r.length,a=i.length-1;a>=0;a--){var s=i[a],u=e.offsetAt(s.range.start),c=e.offsetAt(s.range.end);if(!(c<=o))throw new Error("Overlapping edit");r=r.substring(0,u)+s.newText+r.substring(c,r.length),o=u}return r}}(it||(it={}));var st,ut,ct,dt=function(){function e(e,t,n,r){this._uri=e,this._languageId=t,this._version=n,this._content=r,this._lineOffsets=void 0}return Object.defineProperty(e.prototype,"uri",{get:function(){return this._uri},enumerable:!1,configurable:!0}),Object.defineProperty(e.prototype,"languageId",{get:function(){return this._languageId},enumerable:!1,configurable:!0}),Object.defineProperty(e.prototype,"version",{get:function(){return this._version},enumerable:!1,configurable:!0}),e.prototype.getText=function(e){if(e){var t=this.offsetAt(e.start),n=this.offsetAt(e.end);return this._content.substring(t,n)}return this._content},e.prototype.update=function(e,t){this._content=e.text,this._version=t,this._lineOffsets=void 0},e.prototype.getLineOffsets=function(){if(void 0===this._lineOffsets){for(var e=[],t=this._content,n=!0,r=0;r<t.length;r++){n&&(e.push(r),n=!1);var i=t.charAt(r);n="\r"===i||"\n"===i,"\r"===i&&r+1<t.length&&"\n"===t.charAt(r+1)&&r++}n&&t.length>0&&e.push(t.length),this._lineOffsets=e}return this._lineOffsets},e.prototype.positionAt=function(e){e=Math.max(Math.min(e,this._content.length),0);var t=this.getLineOffsets(),n=0,r=t.length;if(0===r)return m.create(0,e);for(;n<r;){var i=Math.floor((n+r)/2);t[i]>e?r=i:n=i+1}var o=n-1;return m.create(o,e-t[o])},e.prototype.offsetAt=function(e){var t=this.getLineOffsets();if(e.line>=t.length)return this._content.length;if(e.line<0)return 0;var n=t[e.line],r=e.line+1<t.length?t[e.line+1]:this._content.length;return Math.max(Math.min(n+e.character,r),n)},Object.defineProperty(e.prototype,"lineCount",{get:function(){return this.getLineOffsets().length},enumerable:!1,configurable:!0}),e}();ut=st||(st={}),ct=Object.prototype.toString,ut.defined=function(e){return void 0!==e},ut.undefined=function(e){return void 0===e},ut.boolean=function(e){return!0===e||!1===e},ut.string=function(e){return"[object String]"===ct.call(e)},ut.number=function(e){return"[object Number]"===ct.call(e)},ut.numberRange=function(e,t,n){return"[object Number]"===ct.call(e)&&t<=e&&e<=n},ut.integer=function(e){return"[object Number]"===ct.call(e)&&-2147483648<=e&&e<=2147483647},ut.uinteger=function(e){return"[object Number]"===ct.call(e)&&0<=e&&e<=2147483647},ut.func=function(e){return"[object Function]"===ct.call(e)},ut.objectLiteral=function(e){return null!==e&&"object"==typeof e},ut.typedArray=function(e,t){return Array.isArray(e)&&e.every(t)};function gt(e){switch(e){case F.Error:return l.MarkerSeverity.Error;case F.Warning:return l.MarkerSeverity.Warning;case F.Information:return l.MarkerSeverity.Info;case F.Hint:return l.MarkerSeverity.Hint;default:return l.MarkerSeverity.Info}}function lt(e){if(e)return{character:e.column-1,line:e.lineNumber-1}}function ht(e){if(e)return new l.Range(e.start.line+1,e.start.character+1,e.end.line+1,e.end.character+1)}function ft(e){const t=l.languages.CompletionItemKind;switch(e){case we.Text:return t.Text;case we.Method:return t.Method;case we.Function:return t.Function;case we.Constructor:return t.Constructor;case we.Field:return t.Field;case we.Variable:return t.Variable;case we.Class:return t.Class;case we.Interface:return t.Interface;case we.Module:return t.Module;case we.Property:return t.Property;case we.Unit:return t.Unit;case we.Value:return t.Value;case we.Enum:return t.Enum;case we.Keyword:return t.Keyword;case we.Snippet:return t.Snippet;case we.Color:return t.Color;case we.File:return t.File;case we.Reference:return t.Reference}return t.Property}function pt(e){if(e)return{range:ht(e.range),text:e.newText}}function vt(e){return"string"==typeof e?{value:e}:(t=e)&&"object"==typeof t&&"string"==typeof t.kind?"plaintext"===e.kind?{value:e.value.replace(/[\\`*_{}[\]()#+\-.!]/g,"\\$&")}:{value:e.value}:{value:"```"+e.language+"\n"+e.value+"\n```\n"};var t}function mt(e){if(e)return Array.isArray(e)?e.map(vt):[vt(e)]}function _t(e){switch(e){case je.Read:return l.languages.DocumentHighlightKind.Read;case je.Write:return l.languages.DocumentHighlightKind.Write;case je.Text:return l.languages.DocumentHighlightKind.Text}return l.languages.DocumentHighlightKind.Text}function wt(e){return{uri:l.Uri.parse(e.uri),range:ht(e.range)}}function bt(e){let t=l.languages.SymbolKind;switch(e){case Ne.File:return t.Array;case Ne.Module:return t.Module;case Ne.Namespace:return t.Namespace;case Ne.Package:return t.Package;case Ne.Class:return t.Class;case Ne.Method:return t.Method;case Ne.Property:return t.Property;case Ne.Field:return t.Field;case Ne.Constructor:return t.Constructor;case Ne.Enum:return t.Enum;case Ne.Interface:return t.Interface;case Ne.Function:return t.Function;case Ne.Variable:return t.Variable;case Ne.Constant:return t.Constant;case Ne.String:return t.String;case Ne.Number:return t.Number;case Ne.Boolean:return t.Boolean;case Ne.Array:return t.Array}return t.Function}function yt(e){const t=[],n=[],r=new class{constructor(e){this._defaults=e,this._worker=null,this._client=null,this._idleCheckInterval=window.setInterval((()=>this._checkIfIdle()),3e4),this._lastUsedTime=0,this._configChangeListener=this._defaults.onDidChange((()=>this._stopWorker()))}_stopWorker(){this._worker&&(this._worker.dispose(),this._worker=null),this._client=null}dispose(){clearInterval(this._idleCheckInterval),this._configChangeListener.dispose(),this._stopWorker()}_checkIfIdle(){this._worker&&Date.now()-this._lastUsedTime>12e4&&this._stopWorker()}_getClient(){return this._lastUsedTime=Date.now(),this._client||(this._worker=l.editor.createWebWorker({moduleId:"vs/language/css/cssWorker",label:this._defaults.languageId,createData:{options:this._defaults.options,languageId:this._defaults.languageId}}),this._client=this._worker.getProxy()),this._client}getLanguageServiceWorker(...e){let t;return this._getClient().then((e=>{t=e})).then((t=>{if(this._worker)return this._worker.withSyncedResources(e)})).then((e=>t))}}(e);t.push(r);const i=(...e)=>r.getLanguageServiceWorker(...e);return function(){const{languageId:t,modeConfiguration:r}=e;Ct(n),r.completionItems&&n.push(l.languages.registerCompletionItemProvider(t,new class{constructor(e,t){this._worker=e,this._triggerCharacters=t}get triggerCharacters(){return this._triggerCharacters}provideCompletionItems(e,t,n,r){const i=e.uri;return this._worker(i).then((e=>e.doComplete(i.toString(),lt(t)))).then((n=>{if(!n)return;const r=e.getWordUntilPosition(t),i=new l.Range(t.lineNumber,r.startColumn,t.lineNumber,r.endColumn),o=n.items.map((e=>{const t={label:e.label,insertText:e.insertText||e.label,sortText:e.sortText,filterText:e.filterText,documentation:e.documentation,detail:e.detail,command:(n=e.command,n&&"editor.action.triggerSuggest"===n.command?{id:n.command,title:n.title,arguments:n.arguments}:void 0),range:i,kind:ft(e.kind)};var n,r;return e.textEdit&&(void 0!==(r=e.textEdit).insert&&void 0!==r.replace?t.range={insert:ht(e.textEdit.insert),replace:ht(e.textEdit.replace)}:t.range=ht(e.textEdit.range),t.insertText=e.textEdit.newText),e.additionalTextEdits&&(t.additionalTextEdits=e.additionalTextEdits.map(pt)),e.insertTextFormat===ye.Snippet&&(t.insertTextRules=l.languages.CompletionItemInsertTextRule.InsertAsSnippet),t}));return{isIncomplete:n.isIncomplete,suggestions:o}}))}}(i,["/","-",":"]))),r.hovers&&n.push(l.languages.registerHoverProvider(t,new class{constructor(e){this._worker=e}provideHover(e,t,n){let r=e.uri;return this._worker(r).then((e=>e.doHover(r.toString(),lt(t)))).then((e=>{if(e)return{range:ht(e.range),contents:mt(e.contents)}}))}}(i))),r.documentHighlights&&n.push(l.languages.registerDocumentHighlightProvider(t,new class{constructor(e){this._worker=e}provideDocumentHighlights(e,t,n){const r=e.uri;return this._worker(r).then((e=>e.findDocumentHighlights(r.toString(),lt(t)))).then((e=>{if(e)return e.map((e=>({range:ht(e.range),kind:_t(e.kind)})))}))}}(i))),r.definitions&&n.push(l.languages.registerDefinitionProvider(t,new class{constructor(e){this._worker=e}provideDefinition(e,t,n){const r=e.uri;return this._worker(r).then((e=>e.findDefinition(r.toString(),lt(t)))).then((e=>{if(e)return[wt(e)]}))}}(i))),r.references&&n.push(l.languages.registerReferenceProvider(t,new class{constructor(e){this._worker=e}provideReferences(e,t,n,r){const i=e.uri;return this._worker(i).then((e=>e.findReferences(i.toString(),lt(t)))).then((e=>{if(e)return e.map(wt)}))}}(i))),r.documentSymbols&&n.push(l.languages.registerDocumentSymbolProvider(t,new class{constructor(e){this._worker=e}provideDocumentSymbols(e,t){const n=e.uri;return this._worker(n).then((e=>e.findDocumentSymbols(n.toString()))).then((e=>{if(e)return e.map((e=>({name:e.name,detail:"",containerName:e.containerName,kind:bt(e.kind),range:ht(e.location.range),selectionRange:ht(e.location.range),tags:[]})))}))}}(i))),r.rename&&n.push(l.languages.registerRenameProvider(t,new class{constructor(e){this._worker=e}provideRenameEdits(e,t,n,r){const i=e.uri;return this._worker(i).then((e=>e.doRename(i.toString(),lt(t),n))).then((e=>function(e){if(!e||!e.changes)return;let t=[];for(let n in e.changes){const r=l.Uri.parse(n);for(let i of e.changes[n])t.push({resource:r,edit:{range:ht(i.range),text:i.newText}})}return{edits:t}}(e)))}}(i))),r.colors&&n.push(l.languages.registerColorProvider(t,new class{constructor(e){this._worker=e}provideDocumentColors(e,t){const n=e.uri;return this._worker(n).then((e=>e.findDocumentColors(n.toString()))).then((e=>{if(e)return e.map((e=>({color:e.color,range:ht(e.range)})))}))}provideColorPresentations(e,t,n){const r=e.uri;return this._worker(r).then((e=>e.getColorPresentations(r.toString(),t.color,function(e){if(e)return{start:{line:e.startLineNumber-1,character:e.startColumn-1},end:{line:e.endLineNumber-1,character:e.endColumn-1}}}(t.range)))).then((e=>{if(e)return e.map((e=>{let t={label:e.label};return e.textEdit&&(t.textEdit=pt(e.textEdit)),e.additionalTextEdits&&(t.additionalTextEdits=e.additionalTextEdits.map(pt)),t}))}))}}(i))),r.foldingRanges&&n.push(l.languages.registerFoldingRangeProvider(t,new class{constructor(e){this._worker=e}provideFoldingRanges(e,t,n){const r=e.uri;return this._worker(r).then((e=>e.getFoldingRanges(r.toString(),t))).then((e=>{if(e)return e.map((e=>{const t={start:e.startLine+1,end:e.endLine+1};return void 0!==e.kind&&(t.kind=function(e){switch(e){case M.Comment:return l.languages.FoldingRangeKind.Comment;case M.Imports:return l.languages.FoldingRangeKind.Imports;case M.Region:return l.languages.FoldingRangeKind.Region}}(e.kind)),t}))}))}}(i))),r.diagnostics&&n.push(new class{constructor(e,t,n){this._languageId=e,this._worker=t,this._disposables=[],this._listener=Object.create(null);const r=e=>{let t,n=e.getLanguageId();n===this._languageId&&(this._listener[e.uri.toString()]=e.onDidChangeContent((()=>{window.clearTimeout(t),t=window.setTimeout((()=>this._doValidate(e.uri,n)),500)})),this._doValidate(e.uri,n))},i=e=>{l.editor.setModelMarkers(e,this._languageId,[]);let t=e.uri.toString(),n=this._listener[t];n&&(n.dispose(),delete this._listener[t])};this._disposables.push(l.editor.onDidCreateModel(r)),this._disposables.push(l.editor.onWillDisposeModel(i)),this._disposables.push(l.editor.onDidChangeModelLanguage((e=>{i(e.model),r(e.model)}))),this._disposables.push(n((e=>{l.editor.getModels().forEach((e=>{e.getLanguageId()===this._languageId&&(i(e),r(e))}))}))),this._disposables.push({dispose:()=>{l.editor.getModels().forEach(i);for(let e in this._listener)this._listener[e].dispose()}}),l.editor.getModels().forEach(r)}dispose(){this._disposables.forEach((e=>e&&e.dispose())),this._disposables.length=0}_doValidate(e,t){this._worker(e).then((t=>t.doValidation(e.toString()))).then((n=>{const r=n.map((e=>function(e,t){let n="number"==typeof t.code?String(t.code):t.code;return{severity:gt(t.severity),startLineNumber:t.range.start.line+1,startColumn:t.range.start.character+1,endLineNumber:t.range.end.line+1,endColumn:t.range.end.character+1,message:t.message,code:n,source:t.source}}(0,e)));let i=l.editor.getModel(e);i&&i.getLanguageId()===t&&l.editor.setModelMarkers(i,t,r)})).then(void 0,(e=>{console.error(e)}))}}(t,i,e.onDidChange)),r.selectionRanges&&n.push(l.languages.registerSelectionRangeProvider(t,new class{constructor(e){this._worker=e}provideSelectionRanges(e,t,n){const r=e.uri;return this._worker(r).then((e=>e.getSelectionRanges(r.toString(),t.map(lt)))).then((e=>{if(e)return e.map((e=>{const t=[];for(;e;)t.push({range:ht(e.range)}),e=e.parent;return t}))}))}}(i)))}(),t.push(kt(n)),kt(t)}function kt(e){return{dispose:()=>Ct(e)}}function Ct(e){for(;e.length;)e.pop().dispose()}}));
//# sourceMappingURL=cssMode.ed4fd77b.js.map