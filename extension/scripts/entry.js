// Generated by CoffeeScript 1.3.3
var EntryManager, cssFiles, entryManager, jsFiles;

EntryManager = (function() {

  function EntryManager() {}

  EntryManager.prototype.injectCss = function(tabId, filePath) {
    return chrome.tabs.insertCSS(tabId, {
      file: filePath
    });
  };

  EntryManager.prototype.injectScript = function(tabId, filePath) {
    return chrome.tabs.executeScript(tabId, {
      file: filePath
    });
  };

  return EntryManager;

})();

entryManager = new EntryManager();

cssFiles = ["tag-jumper.css"];

jsFiles = ["lib/Box2dWeb-2.1.a.3.min.js", "lib/caat-min.js", "lib/caat-box2d-min.js", "lib/jquery-1.7.2.min.js", "scripts/tag-jumper-main.js"];

chrome.browserAction.onClicked.addListener(function(tab) {
  var file, _i, _j, _len, _len1, _results;
  for (_i = 0, _len = cssFiles.length; _i < _len; _i++) {
    file = cssFiles[_i];
    entryManager.injectCss(tab.id, file);
  }
  _results = [];
  for (_j = 0, _len1 = jsFiles.length; _j < _len1; _j++) {
    file = jsFiles[_j];
    _results.push(entryManager.injectScript(tab.id, file));
  }
  return _results;
});
