scriptName SKI_ConfigManager extends SKI_QuestBase hidden

;-- Properties --------------------------------------
String property JOURNAL_MENU
	String function get()

		return "Journal Menu"
	endFunction
endproperty
String property MENU_ROOT
	String function get()

		return "_root.ConfigPanelFader.configPanel"
	endFunction
endproperty

;-- Variables ---------------------------------------
String[] _modNames
Bool _locked = false
Bool _lockInit = false
Int _updateCounter = 0
Bool _cleanupFlag = false
Int _configCount = 0
SKI_ConfigBase[] _modConfigs
SKI_ConfigBase _activeConfig
Int _curConfigID = 0
Int _addCounter = 0

;-- Functions ---------------------------------------

function Log(String a_msg)

	debug.Trace(self as String + ": " + a_msg, 0)
endFunction

function OnGameReload()

	self.RegisterForModEvent("SKICP_modSelected", "OnModSelect")
	self.RegisterForModEvent("SKICP_pageSelected", "OnPageSelect")
	self.RegisterForModEvent("SKICP_optionHighlighted", "OnOptionHighlight")
	self.RegisterForModEvent("SKICP_optionSelected", "OnOptionSelect")
	self.RegisterForModEvent("SKICP_optionDefaulted", "OnOptionDefault")
	self.RegisterForModEvent("SKICP_keymapChanged", "OnKeymapChange")
	self.RegisterForModEvent("SKICP_sliderSelected", "OnSliderSelect")
	self.RegisterForModEvent("SKICP_sliderAccepted", "OnSliderAccept")
	self.RegisterForModEvent("SKICP_menuSelected", "OnMenuSelect")
	self.RegisterForModEvent("SKICP_menuAccepted", "OnMenuAccept")
	self.RegisterForModEvent("SKICP_colorSelected", "OnColorSelect")
	self.RegisterForModEvent("SKICP_colorAccepted", "OnColorAccept")
	self.RegisterForModEvent("SKICP_inputSelected", "OnInputSelect")
	self.RegisterForModEvent("SKICP_inputAccepted", "OnInputAccept")
	self.RegisterForModEvent("SKICP_dialogCanceled", "OnDialogCancel")
	self.RegisterForMenu(self.JOURNAL_MENU)
	_lockInit = true
	_cleanupFlag = true
	self.CleanUp()
	self.SendModEvent("SKICP_configManagerReady", "", 0.000000)
	_updateCounter = 0
	self.RegisterForSingleUpdate(5 as Float)
endFunction

function OnSliderSelect(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int optionIndex = a_numArg as Int
	_activeConfig.RequestSliderDialogData(optionIndex)
endFunction

function CleanUp()

	self.GotoState("BUSY")
	_cleanupFlag = false
	_configCount = 0
	Int i = 0
	while i < _modConfigs.length
		if _modConfigs[i] == none || _modConfigs[i].GetFormID() == 0
			_modConfigs[i] = none
			_modNames[i] = ""
		else
			_configCount += 1
		endIf
		i += 1
	endWhile
	self.GotoState("")
endFunction

function OnMenuClose(String a_menuName)

	self.GotoState("")
	if _activeConfig
		_activeConfig.CloseConfig()
	endIf
	_activeConfig = none
endFunction

function ForceReset()

	self.Log("Forcing config manager reset...")
	self.SendModEvent("SKICP_configManagerReset", "", 0.000000)
	self.GotoState("BUSY")
	Int i = 0
	while i < _modConfigs.length
		_modConfigs[i] = none
		_modNames[i] = ""
		i += 1
	endWhile
	_curConfigID = 0
	_configCount = 0
	self.GotoState("")
	self.SendModEvent("SKICP_configManagerReady", "", 0.000000)
endFunction

function OnKeymapChange(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int optionIndex = a_numArg as Int
	Int keyCode = ui.GetInt(self.JOURNAL_MENU, self.MENU_ROOT + ".selectedKeyCode")
	String conflictControl = input.GetMappedControl(keyCode)
	String conflictName = ""
	Int i = 0
	while conflictControl == "" && i < _modConfigs.length
		if _modConfigs[i] != none
			conflictControl = _modConfigs[i].GetCustomControl(keyCode)
			if conflictControl != ""
				conflictName = _modNames[i]
			endIf
		endIf
		i += 1
	endWhile
	_activeConfig.RemapKey(optionIndex, keyCode, conflictControl, conflictName)
	ui.InvokeBool(self.JOURNAL_MENU, self.MENU_ROOT + ".unlock", true)
endFunction

function OnMenuSelect(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int optionIndex = a_numArg as Int
	_activeConfig.RequestMenuDialogData(optionIndex)
endFunction

function OnUpdate()

	if _cleanupFlag
		self.CleanUp()
	endIf
	if _addCounter > 0
		debug.Notification("MCM: Registered " + _addCounter as String + " new menu(s).")
		_addCounter = 0
	endIf
	self.SendModEvent("SKICP_configManagerReady", "", 0.000000)
	if _updateCounter < 6
		_updateCounter += 1
		self.RegisterForSingleUpdate(5 as Float)
	else
		self.RegisterForSingleUpdate(30 as Float)
	endIf
endFunction

Int function GetVersion()

	return 4
endFunction

function OnOptionDefault(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int optionIndex = a_numArg as Int
	_activeConfig.ResetOption(optionIndex)
	ui.InvokeBool(self.JOURNAL_MENU, self.MENU_ROOT + ".unlock", true)
endFunction

function OnOptionSelect(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int optionIndex = a_numArg as Int
	_activeConfig.SelectOption(optionIndex)
	ui.InvokeBool(self.JOURNAL_MENU, self.MENU_ROOT + ".unlock", true)
endFunction

Int function NextID()

	Int startIdx = _curConfigID
	while _modConfigs[_curConfigID] != none
		_curConfigID += 1
		if _curConfigID >= 128
			_curConfigID = 0
		endIf
		if _curConfigID == startIdx
			return -1
		endIf
	endWhile
	return _curConfigID
endFunction

function OnDialogCancel(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	ui.InvokeBool(self.JOURNAL_MENU, self.MENU_ROOT + ".unlock", true)
endFunction

function OnSliderAccept(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Float value = a_numArg
	_activeConfig.SetSliderValue(value)
	ui.InvokeBool(self.JOURNAL_MENU, self.MENU_ROOT + ".unlock", true)
endFunction

Int function RegisterMod(SKI_ConfigBase a_menu, String a_modName)

	self.GotoState("BUSY")
	if _configCount >= 128
		self.GotoState("")
		return -1
	endIf
	Int i = 0
	while i < _modConfigs.length
		if _modConfigs[i] == a_menu
			self.GotoState("")
			return i
		endIf
		i += 1
	endWhile
	Int configID = self.NextID()
	if configID == -1
		self.GotoState("")
		return -1
	endIf
	_modConfigs[configID] = a_menu
	_modNames[configID] = a_modName
	_configCount += 1
	_addCounter += 1
	self.GotoState("")
	return configID
endFunction

Int function UnregisterMod(SKI_ConfigBase a_menu)

	self.GotoState("BUSY")
	Int i = 0
	while i < _modConfigs.length
		if _modConfigs[i] == a_menu
			_modConfigs[i] = none
			_modNames[i] = ""
			_configCount -= 1
			self.GotoState("")
			return i
		endIf
		i += 1
	endWhile
	self.GotoState("")
	return -1
endFunction

function OnInit()

	_modConfigs = new SKI_ConfigBase[128]
	_modNames = new String[128]
	self.OnGameReload()
endFunction

function OnMenuAccept(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int value = a_numArg as Int
	_activeConfig.SetMenuIndex(value)
	ui.InvokeBool(self.JOURNAL_MENU, self.MENU_ROOT + ".unlock", true)
endFunction

function OnInputSelect(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int optionIndex = a_numArg as Int
	_activeConfig.RequestInputDialogData(optionIndex)
endFunction

function OnMenuOpen(String a_menuName)

	self.GotoState("BUSY")
	_activeConfig = none
	ui.InvokeStringA(self.JOURNAL_MENU, self.MENU_ROOT + ".setModNames", _modNames)
endFunction

function OnModSelect(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int configIndex = a_numArg as Int
	if configIndex > -1
		if _activeConfig
			_activeConfig.CloseConfig()
		endIf
		_activeConfig = _modConfigs[configIndex]
		_activeConfig.OpenConfig()
	endIf
	ui.InvokeBool(self.JOURNAL_MENU, self.MENU_ROOT + ".unlock", true)
endFunction

function OnColorAccept(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int color = a_numArg as Int
	_activeConfig.SetColorValue(color)
	ui.InvokeBool(self.JOURNAL_MENU, self.MENU_ROOT + ".unlock", true)
endFunction

function OnInputAccept(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	_activeConfig.SetInputText(a_strArg)
	ui.InvokeBool(self.JOURNAL_MENU, self.MENU_ROOT + ".unlock", true)
endFunction

function OnOptionHighlight(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int optionIndex = a_numArg as Int
	_activeConfig.HighlightOption(optionIndex)
endFunction

; Skipped compiler generated GotoState

; Skipped compiler generated GetState

function OnColorSelect(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	Int optionIndex = a_numArg as Int
	_activeConfig.RequestColorDialogData(optionIndex)
endFunction

function OnPageSelect(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	String page = a_strArg
	Int index = a_numArg as Int
	_activeConfig.SetPage(page, index)
	ui.InvokeBool(self.JOURNAL_MENU, self.MENU_ROOT + ".unlock", true)
endFunction

;-- State -------------------------------------------
state BUSY

	Int function RegisterMod(SKI_ConfigBase a_menu, String a_modName)

		return -2
	endFunction

	function CleanUp()

		; Empty function
	endFunction

	function ForceReset()

		; Empty function
	endFunction

	Int function UnregisterMod(SKI_ConfigBase a_menu)

		return -2
	endFunction
endState
