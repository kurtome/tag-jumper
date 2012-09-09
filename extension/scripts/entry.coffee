

class EntryManager

	injectCss: (tabId, filePath) ->
		chrome.tabs.insertCSS(
			tabId, 
			{
				file: filePath
			}
		)


	injectScript: (tabId, filePath) ->
		chrome.tabs.executeScript(
			tabId, 
			{
				file: filePath
			}
		)

entryManager = new EntryManager()

cssFiles = [ "tag-jumper.css" ]

jsFiles = 
	[
		"lib/Box2dWeb-2.1.a.3.min.js",
		"lib/caat-min.js",
		"lib/caat-box2d-min.js",
		"lib/jquery-1.7.2.min.js",
		"scripts/tag-jumper-main.js"
	]


chrome.browserAction.onClicked.addListener (tab) ->
	entryManager.injectCss tab.id, file for file in cssFiles

	entryManager.injectScript tab.id, file for file in jsFiles

