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
var $parcel$modules = {};
var $parcel$inits = {};

var parcelRequire = $parcel$global["parcelRequiref17b"];
if (parcelRequire == null) {
  parcelRequire = function(id) {
    if (id in $parcel$modules) {
      return $parcel$modules[id].exports;
    }
    if (id in $parcel$inits) {
      var init = $parcel$inits[id];
      delete $parcel$inits[id];
      var module = {id: id, exports: {}};
      $parcel$modules[id] = module;
      init.call(module.exports, module, module.exports);
      return module.exports;
    }
    var err = new Error("Cannot find module '" + id + "'");
    err.code = 'MODULE_NOT_FOUND';
    throw err;
  };

  parcelRequire.register = function register(id, init) {
    $parcel$inits[id] = init;
  };

  $parcel$global["parcelRequiref17b"] = parcelRequire;
}

var $1h2v8 = parcelRequire("1h2v8");

var $2ti7g = parcelRequire("2ti7g");
let $73969ec252b6d0af$var$initialized = false;
function $73969ec252b6d0af$export$2a47f398eeff8b01(foreignModule) {
    if ($73969ec252b6d0af$var$initialized) return;
    $73969ec252b6d0af$var$initialized = true;
    const simpleWorker = new $1h2v8.SimpleWorkerServer((msg)=>{
        self.postMessage(msg);
    }, (host)=>new $2ti7g.EditorSimpleWorker(host, foreignModule)
    );
    self.onmessage = (e)=>{
        simpleWorker.onmessage(e.data);
    };
}
self.onmessage = (e)=>{
    // Ignore first message in this case and initialize if not yet initialized
    if (!$73969ec252b6d0af$var$initialized) $73969ec252b6d0af$export$2a47f398eeff8b01(null);
};


//# sourceMappingURL=editor.worker.dfaa3d5c.js.map
