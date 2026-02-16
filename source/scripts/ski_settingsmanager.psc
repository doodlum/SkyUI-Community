scriptName SKI_SettingsManager extends SKI_QuestBase

;-- Properties --------------------------------------
String property CRAFTING_MENU
	String function get()

		return "Crafting Menu"
	endFunction
endproperty
String property GIFT_MENU
	String function get()

		return "GiftMenu"
	endFunction
endproperty
String property MAGIC_MENU
	String function get()

		return "MagicMenu"
	endFunction
endproperty
String property MENU_ROOT
	String function get()

		return "_global.skyui.util.ConfigManager"
	endFunction
endproperty
String property CONTAINER_MENU
	String function get()

		return "ContainerMenu"
	endFunction
endproperty
String property INVENTORY_MENU
	String function get()

		return "InventoryMenu"
	endFunction
endproperty
String property BARTER_MENU
	String function get()

		return "BarterMenu"
	endFunction
endproperty

;-- Variables ---------------------------------------
String[] _overrideValues
Int _overrideCount = 0
String[] _overrideKeys
String _currentMenu

;-- Functions ---------------------------------------

function OnGameReload()

	self.RegisterForMenu(self.INVENTORY_MENU)
	self.RegisterForMenu(self.MAGIC_MENU)
	self.RegisterForMenu(self.CONTAINER_MENU)
	self.RegisterForMenu(self.BARTER_MENU)
	self.RegisterForMenu(self.GIFT_MENU)
	self.RegisterForMenu(self.CRAFTING_MENU)
	self.RegisterForModEvent("SKICO_setConfigOverride", "OnSetConfigOverride")
endFunction

; Skipped compiler generated GetState

function OnMenuOpen(String a_menuName)

	self.GotoState("LOCKED")
	if ui.IsMenuOpen(a_menuName)
		_currentMenu = a_menuName
		ui.InvokeStringA(a_menuName, self.MENU_ROOT + ".setExternalOverrideKeys", _overrideKeys)
		ui.InvokeStringA(a_menuName, self.MENU_ROOT + ".setExternalOverrideValues", _overrideValues)
	endIf
	self.GotoState("")
endFunction

function OnSetConfigOverride(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	String overrideKey = a_strArg
	String overrideValue = ui.GetString(_currentMenu, self.MENU_ROOT + ".out_overrides." + overrideKey)
	self.SetOverride(overrideKey, overrideValue)
endFunction

; Skipped compiler generated GotoState

Int function NextFreeIndex()

	Int i = 0
	while i < _overrideKeys.length
		if _overrideKeys[i] == ""
			return i
		endIf
		i += 1
	endWhile
	return -1
endFunction

function OnInit()

	_overrideKeys = new String[128]
	_overrideValues = new String[128]
	Int i = 0
	while i < 128
		_overrideKeys[i] = ""
		_overrideValues[i] = ""
		i += 1
	endWhile
	self.OnGameReload()
endFunction

Bool function SetOverride(String a_key, String a_value)

	if a_key == ""
		return false
	endIf
	Int index = _overrideKeys.find(a_key, 0)
	if index != -1
		_overrideValues[index] = a_value
		return true
	else
		if _overrideCount >= 128
			return false
		endIf
		index = self.NextFreeIndex()
		if index == -1
			return false
		endIf
		_overrideKeys[index] = a_key
		_overrideValues[index] = a_value
		_overrideCount += 1
		return true
	endIf
endFunction

Bool function ClearOverride(String a_key)

	if a_key == ""
		return false
	endIf
	Int index = _overrideKeys.find(a_key, 0)
	if index == -1
		return false
	endIf
	_overrideKeys[index] = ""
	_overrideValues[index] = ""
	_overrideCount -= 1
	return true
endFunction

;-- State -------------------------------------------
state LOCKED

	function OnMenuOpen(String a_menuName)

		; Empty function
	endFunction
endState
