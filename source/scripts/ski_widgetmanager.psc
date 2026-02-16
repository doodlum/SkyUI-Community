scriptName SKI_WidgetManager extends SKI_QuestBase

;-- Properties --------------------------------------
String property HUD_MENU
	String function get()

		return "HUD Menu"
	endFunction
endproperty

;-- Variables ---------------------------------------
Int _widgetCount = 0
Int _curWidgetID = 0
String[] _widgetSources
SKI_WidgetBase[] _widgets

;-- Functions ---------------------------------------

function OnInit()

	_widgets = new SKI_WidgetBase[128]
	_widgetSources = new String[128]
	utility.Wait(0.500000)
	self.OnGameReload()
endFunction

function CreateWidget(Int a_widgetID, String a_widgetSource)

	_widgetSources[a_widgetID] = a_widgetSource
	String[] args = new String[2]
	args[0] = a_widgetID as String
	args[1] = a_widgetSource
	ui.InvokeStringA(self.HUD_MENU, "_root.widgetLoaderContainer.widgetLoader.loadWidget", args)
endFunction

; Skipped compiler generated GotoState

; Skipped compiler generated GetState

Int function NextWidgetID()

	Int startIdx = _curWidgetID
	while _widgets[_curWidgetID] != none
		_curWidgetID += 1
		if _curWidgetID >= 128
			_curWidgetID = 0
		endIf
		if _curWidgetID == startIdx
			return -1
		endIf
	endWhile
	return _curWidgetID
endFunction

function InitWidgetLoader()

	debug.Trace("InitWidgetLoader()", 0)
	Int releaseIdx = ui.GetInt(self.HUD_MENU, "_global.WidgetLoader.SKYUI_RELEASE_IDX")
	if releaseIdx == 0
		String rootPath = ""
		String[] args = new String[2]
		args[0] = "widgetLoaderContainer"
		args[1] = "-1000"
		ui.InvokeStringA(self.HUD_MENU, "_root.createEmptyMovieClip", args)
		ui.InvokeString(self.HUD_MENU, "_root.widgetLoaderContainer.loadMovie", "skyui/widgetloader.swf")
		utility.Wait(0.500000)
		releaseIdx = ui.GetInt(self.HUD_MENU, "_global.WidgetLoader.SKYUI_RELEASE_IDX")
		if releaseIdx == 0
			rootPath = "exported/"
			ui.InvokeString(self.HUD_MENU, "_root.widgetLoaderContainer.loadMovie", "exported/skyui/widgetloader.swf")
			utility.Wait(0.500000)
			releaseIdx = ui.GetInt(self.HUD_MENU, "_global.WidgetLoader.SKYUI_RELEASE_IDX")
		endIf
		if releaseIdx == 0
			debug.Trace("InitWidgetLoader(): load failed", 0)
			return 
		endIf
		ui.InvokeString(self.HUD_MENU, "_root.widgetLoaderContainer.widgetLoader.setRootPath", rootPath)
	endIf
	ui.InvokeStringA(self.HUD_MENU, "_root.widgetLoaderContainer.widgetLoader.loadWidgets", _widgetSources)
	self.SendModEvent("SKIWF_widgetManagerReady", "", 0.000000)
endFunction

SKI_WidgetBase[] function GetWidgets()

	SKI_WidgetBase[] widgetsCopy = new SKI_WidgetBase[128]
	Int i = 0
	while i < _widgets.length
		widgetsCopy[i] = _widgets[i]
		i += 1
	endWhile
	return widgetsCopy
endFunction

function OnGameReload()

	self.RegisterForModEvent("SKIWF_widgetLoaded", "OnWidgetLoad")
	self.RegisterForModEvent("SKIWF_widgetError", "OnWidgetError")
	self.CleanUp()
	if ui.IsMenuOpen(self.HUD_MENU)
		self.InitWidgetLoader()
	else
		self.RegisterForMenu(self.HUD_MENU)
	endIf
endFunction

function OnWidgetLoad(String a_eventName, String a_strArg, Float a_numArg, form a_sender)

	Int widgetID = a_strArg as Int
	ski_widgetbase client = _widgets[widgetID]
	if client != none
		client.OnWidgetLoad()
	endIf
endFunction

Int function RequestWidgetID(ski_widgetbase a_client)

	if _widgetCount >= 128
		return -1
	endIf
	Int widgetID = self.NextWidgetID()
	_widgets[widgetID] = a_client
	_widgetCount += 1
	return widgetID
endFunction

function OnMenuOpen(String a_menuName)

	if a_menuName == self.HUD_MENU
		self.UnregisterForMenu(self.HUD_MENU)
		self.InitWidgetLoader()
	endIf
endFunction

function OnWidgetError(String a_eventName, String a_strArg, Float a_numArg, form a_sender)

	Int widgetID = a_numArg as Int
	String errorType = a_strArg
	debug.Trace("WidgetError: " + _widgets[widgetID] as String + ": " + errorType, 0)
endFunction

function CleanUp()

	_widgetCount = 0
	Int i = 0
	while i < _widgets.length
		if _widgets[i] == none || _widgets[i].GetFormID() == 0
			_widgets[i] = none
			_widgetSources[i] = ""
		else
			_widgetCount += 1
		endIf
		i += 1
	endWhile
endFunction
