scriptName SKI_ConfigBase extends SKI_QuestBase

;-- Properties --------------------------------------
Int property OPTION_TYPE_INPUT
	Int function get()

		return 8
	endFunction
endproperty
String property CurrentPage
	String function get()

		return _currentPage
	endFunction
endproperty
Int property OPTION_TYPE_KEYMAP
	Int function get()

		return 7
	endFunction
endproperty
Int property LEFT_TO_RIGHT
	Int function get()

		return 1
	endFunction
endproperty
String property MENU_ROOT
	String function get()

		return "_root.ConfigPanelFader.configPanel"
	endFunction
endproperty
Int property OPTION_FLAG_WITH_UNMAP
	Int function get()

		return 4
	endFunction
endproperty
Int property TOP_TO_BOTTOM
	Int function get()

		return 2
	endFunction
endproperty
Int property OPTION_TYPE_HEADER
	Int function get()

		return 1
	endFunction
endproperty
Int property OPTION_TYPE_EMPTY
	Int function get()

		return 0
	endFunction
endproperty
Int property STATE_RESET
	Int function get()

		return 1
	endFunction
endproperty
Int property OPTION_TYPE_TOGGLE
	Int function get()

		return 3
	endFunction
endproperty
Int property OPTION_FLAG_DISABLED
	Int function get()

		return 1
	endFunction
endproperty
Int property STATE_COLOR
	Int function get()

		return 4
	endFunction
endproperty
String[] property Pages auto
Int property OPTION_TYPE_MENU
	Int function get()

		return 5
	endFunction
endproperty
Int property STATE_SLIDER
	Int function get()

		return 2
	endFunction
endproperty
Int property OPTION_TYPE_TEXT
	Int function get()

		return 2
	endFunction
endproperty
Int property OPTION_FLAG_HIDDEN
	Int function get()

		return 2
	endFunction
endproperty
Int property STATE_MENU
	Int function get()

		return 3
	endFunction
endproperty
String property JOURNAL_MENU
	String function get()

		return "Journal Menu"
	endFunction
endproperty
Int property OPTION_TYPE_SLIDER
	Int function get()

		return 4
	endFunction
endproperty
Int property OPTION_FLAG_NONE
	Int function get()

		return 0
	endFunction
endproperty
String property ModName auto
Int property OPTION_TYPE_COLOR
	Int function get()

		return 6
	endFunction
endproperty
Int property STATE_DEFAULT
	Int function get()

		return 0
	endFunction
endproperty
Int property STATE_INPUT
	Int function get()

		return 5
	endFunction
endproperty

;-- Variables ---------------------------------------
Bool _messageResult = false
Int _currentPageNum = 0
Int _activeOption = -1
String[] _textBuf
SKI_ConfigManager _configManager
Int _configID = -1
Int[] _optionFlagsBuf
String[] _strValueBuf
String _infoText
Int _state = 0
String _inputStartText
String _currentPage = ""
Int[] _colorParams
Bool _initialized = false
Float[] _sliderParams
Int _cursorFillMode = 1
Int[] _menuParams
String[] _stateOptionMap
Bool _waitForMessage = false
Int _cursorPosition = 0
Float[] _numValueBuf

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

function SetCursorPosition(Int a_position)

	if a_position < 128
		_cursorPosition = a_position
	endIf
endFunction

function SetSliderValue(Float a_value)

	String optionState = _stateOptionMap[_activeOption % 256]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnSliderAcceptST(a_value)
		self.GotoState(oldState)
	else
		self.OnOptionSliderAccept(_activeOption, a_value)
	endIf
	_activeOption = -1
endFunction

Int function AddSliderOption(String a_text, Float a_value, String a_formatString, Int a_flags)

	return self.AddOption(self.OPTION_TYPE_SLIDER, a_text, a_formatString, a_value, a_flags)
endFunction

function SetOptionFlagsST(Int a_flags, Bool a_noUpdate, String a_stateName)

	if _state == self.STATE_RESET
		self.Error("Cannot set option flags while in OnPageReset(). Pass flags to AddOption instead")
		return 
	endIf
	Int index = self.GetStateOptionIndex(a_stateName)
	if index < 0
		self.Error("Cannot use SetOptionFlagsST outside a valid option state")
		return 
	endIf
	self.SetOptionFlags(index, a_flags, a_noUpdate)
endFunction

function OnInputAcceptST(String a_input)
{Called when a new text input has been accepted for this state option}

	; Empty function
endFunction

Int function AddToggleOption(String a_text, Bool a_checked, Int a_flags)

	return self.AddOption(self.OPTION_TYPE_TOGGLE, a_text, none, (a_checked as Int) as Float, a_flags)
endFunction

function AddSliderOptionST(String a_stateName, String a_text, Float a_value, String a_formatString, Int a_flags)

	self.AddOptionST(a_stateName, self.OPTION_TYPE_SLIDER, a_text, a_formatString, a_value, a_flags)
endFunction

function OnConfigInit()
{Called when this config menu is initialized}

	; Empty function
endFunction

function SetTitleText(String a_text)

	ui.InvokeString(self.JOURNAL_MENU, self.MENU_ROOT + ".setTitleText", a_text)
endFunction

function SelectOption(Int a_index)

	String optionState = _stateOptionMap[a_index]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnSelectST()
		self.GotoState(oldState)
	else
		Int option = a_index + _currentPageNum * 256
		self.OnOptionSelect(option)
	endIf
endFunction

function OnOptionColorAccept(Int a_option, Int a_color)
{Called when a new color has been accepted}

	; Empty function
endFunction

function SetCursorFillMode(Int a_fillMode)

	if a_fillMode == self.LEFT_TO_RIGHT || a_fillMode == self.TOP_TO_BOTTOM
		_cursorFillMode = a_fillMode
	endIf
endFunction

function OnOptionDefault(Int a_option)
{Called when resetting an option to its default value}

	; Empty function
endFunction

function OnDefaultST()
{Called when resetting a state option to its default value}

	; Empty function
endFunction

function Error(String a_msg)

	debug.Trace(self as String + " ERROR: " + a_msg, 0)
endFunction

function OnOptionHighlight(Int a_option)
{Called when highlighting an option}

	; Empty function
endFunction

function AddInputOptionST(String a_stateName, String a_text, String a_value, Int a_flags)

	self.AddOptionST(a_stateName, self.OPTION_TYPE_INPUT, a_text, a_value, 0 as Float, a_flags)
endFunction

function RequestSliderDialogData(Int a_index)

	_activeOption = a_index + _currentPageNum * 256
	_sliderParams[0] = 0 as Float
	_sliderParams[1] = 0 as Float
	_sliderParams[2] = 0 as Float
	_sliderParams[3] = 1 as Float
	_sliderParams[4] = 1 as Float
	_state = self.STATE_SLIDER
	String optionState = _stateOptionMap[a_index]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnSliderOpenST()
		self.GotoState(oldState)
	else
		self.OnOptionSliderOpen(_activeOption)
	endIf
	_state = self.STATE_DEFAULT
	ui.InvokeFloatA(self.JOURNAL_MENU, self.MENU_ROOT + ".setSliderDialogParams", _sliderParams)
endFunction

function RemapKey(Int a_index, Int a_keyCode, String a_conflictControl, String a_conflictName)

	String optionState = _stateOptionMap[a_index]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnKeyMapChangeST(a_keyCode, a_conflictControl, a_conflictName)
		self.GotoState(oldState)
	else
		Int option = a_index + _currentPageNum * 256
		self.OnOptionKeyMapChange(option, a_keyCode, a_conflictControl, a_conflictName)
	endIf
endFunction

function HighlightOption(Int a_index)

	_infoText = ""
	if a_index != -1
		String optionState = _stateOptionMap[a_index]
		if optionState != ""
			String oldState = self.GetState()
			self.GotoState(optionState)
			self.OnHighlightST()
			self.GotoState(oldState)
		else
			Int option = a_index + _currentPageNum * 256
			self.OnOptionHighlight(option)
		endIf
	endIf
	ui.InvokeString(self.JOURNAL_MENU, self.MENU_ROOT + ".setInfoText", _infoText)
endFunction

function ResetOption(Int a_index)

	String optionState = _stateOptionMap[a_index]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnDefaultST()
		self.GotoState(oldState)
	else
		Int option = a_index + _currentPageNum * 256
		self.OnOptionDefault(option)
	endIf
endFunction

function OnOptionColorOpen(Int a_option)
{Called when a color option has been selected}

	; Empty function
endFunction

function AddColorOptionST(String a_stateName, String a_text, Int a_color, Int a_flags)

	self.AddOptionST(a_stateName, self.OPTION_TYPE_COLOR, a_text, none, a_color as Float, a_flags)
endFunction

function OnConfigRegister()
{Called when this config menu registered at the control panel}

	; Empty function
endFunction

function OnOptionSelect(Int a_option)
{Called when a non-interactive option has been selected}

	; Empty function
endFunction

Int function GetStateOptionIndex(String a_stateName)

	if a_stateName == ""
		a_stateName = self.GetState()
	endIf
	if a_stateName == ""
		return -1
	endIf
	return _stateOptionMap.find(a_stateName, 0)
endFunction

function CloseConfig()

	self.OnConfigClose()
	self.ClearOptionBuffers()
	_waitForMessage = false
	_optionFlagsBuf = new Int[1]
	_textBuf = new String[1]
	_strValueBuf = new String[1]
	_numValueBuf = new Float[1]
	_stateOptionMap = new String[1]
endFunction

Int function AddEmptyOption()

	return self.AddOption(self.OPTION_TYPE_EMPTY, none, none, 0 as Float, 0)
endFunction

function OnSliderAcceptST(Float a_value)
{Called when a new slider state value has been accepted}

	; Empty function
endFunction

function AddToggleOptionST(String a_stateName, String a_text, Bool a_checked, Int a_flags)

	self.AddOptionST(a_stateName, self.OPTION_TYPE_TOGGLE, a_text, none, (a_checked as Int) as Float, a_flags)
endFunction

function SetInputDialogStartText(String a_text)

	if _state != self.STATE_INPUT
		self.Error("Cannot set input dialog params while outside OnOptionInputOpen()")
		return 
	endIf
	_inputStartText = a_text
endFunction

function OnPageReset(String a_page)
{Called when a new page is selected, including the initial empty page}

	; Empty function
endFunction

function OnOptionMenuOpen(Int a_option)
{Called when a menu option has been selected}

	; Empty function
endFunction

function SetSliderDialogInterval(Float a_value)

	if _state != self.STATE_SLIDER
		self.Error("Cannot set slider dialog params while outside OnOptionSliderOpen()")
		return 
	endIf
	_sliderParams[4] = a_value
endFunction

function OnConfigManagerReady(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	SKI_ConfigManager newManager = a_sender as SKI_ConfigManager
	if _configManager == newManager || newManager == none
		return 
	endIf
	_configID = newManager.RegisterMod(self, ModName)
	if _configID >= 0
		_configManager = newManager
		self.OnConfigRegister()
		debug.Trace(self as String + ": Registered " + ModName + " at MCM.", 0)
	endIf
endFunction

function SetSliderOptionValue(Int a_option, Float a_value, String a_formatString, Bool a_noUpdate)

	Int index = a_option % 256
	Int type = _optionFlagsBuf[index] % 256
	if type != self.OPTION_TYPE_SLIDER
		Int pageIdx = a_option / 256 - 1
		if pageIdx != -1
			self.Error("Option type mismatch. Expected slider option, page \"" + Pages[pageIdx] + "\", index " + index as String)
		else
			self.Error("Option type mismatch. Expected slider option, page \"\", index " + index as String)
		endIf
		return 
	endIf
	self.SetOptionValues(index, a_formatString, a_value, a_noUpdate)
endFunction

function SetOptionStrValue(Int a_index, String a_strValue, Bool a_noUpdate)

	if _state == self.STATE_RESET
		self.Error("Cannot modify option data while in OnPageReset()")
		return 
	endIf
	String menu = self.JOURNAL_MENU
	String root = self.MENU_ROOT
	ui.SetInt(menu, root + ".optionCursorIndex", a_index)
	ui.SetString(menu, root + ".optionCursor.strValue", a_strValue)
	if !a_noUpdate
		ui.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction

Int function AddKeyMapOption(String a_text, Int a_keyCode, Int a_flags)

	return self.AddOption(self.OPTION_TYPE_KEYMAP, a_text, none, a_keyCode as Float, a_flags)
endFunction

function OnVersionUpdate(Int a_version)
{Called when a version update of this script has been detected}

	; Empty function
endFunction

function SetOptionValues(Int a_index, String a_strValue, Float a_numValue, Bool a_noUpdate)

	if _state == self.STATE_RESET
		self.Error("Cannot modify option data while in OnPageReset()")
		return 
	endIf
	String menu = self.JOURNAL_MENU
	String root = self.MENU_ROOT
	ui.SetInt(menu, root + ".optionCursorIndex", a_index)
	ui.SetString(menu, root + ".optionCursor.strValue", a_strValue)
	ui.SetFloat(menu, root + ".optionCursor.numValue", a_numValue)
	if !a_noUpdate
		ui.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction

function SetTextOptionValueST(String a_value, Bool a_noUpdate, String a_stateName)

	Int index = self.GetStateOptionIndex(a_stateName)
	if index < 0
		self.Error("Cannot use SetTextOptionValueST outside a valid option state")
		return 
	endIf
	self.SetTextOptionValue(index, a_value, a_noUpdate)
endFunction

function SetToggleOptionValueST(Bool a_checked, Bool a_noUpdate, String a_stateName)

	Int index = self.GetStateOptionIndex(a_stateName)
	if index < 0
		self.Error("Cannot use SetToggleOptionValueST outside a valid option state")
		return 
	endIf
	self.SetToggleOptionValue(index, a_checked, a_noUpdate)
endFunction

function AddTextOptionST(String a_stateName, String a_text, String a_value, Int a_flags)

	self.AddOptionST(a_stateName, self.OPTION_TYPE_TEXT, a_text, a_value, 0 as Float, a_flags)
endFunction

function RequestColorDialogData(Int a_index)

	_activeOption = a_index + _currentPageNum * 256
	_colorParams[0] = -1
	_colorParams[1] = -1
	_state = self.STATE_COLOR
	String optionState = _stateOptionMap[a_index]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnColorOpenST()
		self.GotoState(oldState)
	else
		self.OnOptionColorOpen(_activeOption)
	endIf
	_state = self.STATE_DEFAULT
	ui.InvokeIntA(self.JOURNAL_MENU, self.MENU_ROOT + ".setColorDialogParams", _colorParams)
endFunction

function RequestMenuDialogData(Int a_index)

	_activeOption = a_index + _currentPageNum * 256
	_menuParams[0] = -1
	_menuParams[1] = -1
	_state = self.STATE_MENU
	String optionState = _stateOptionMap[a_index]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnMenuOpenST()
		self.GotoState(oldState)
	else
		self.OnOptionMenuOpen(_activeOption)
	endIf
	_state = self.STATE_DEFAULT
	ui.InvokeIntA(self.JOURNAL_MENU, self.MENU_ROOT + ".setMenuDialogParams", _menuParams)
endFunction

function SetOptionFlags(Int a_option, Int a_flags, Bool a_noUpdate)

	if _state == self.STATE_RESET
		self.Error("Cannot set option flags while in OnPageReset(). Pass flags to AddOption instead")
		return 
	endIf
	Int index = a_option % 256
	Int oldFlags = _optionFlagsBuf[index]
	oldFlags %= 256
	oldFlags += a_flags * 256
	Int[] params = new Int[2]
	params[0] = index
	params[1] = a_flags
	ui.InvokeIntA(self.JOURNAL_MENU, self.MENU_ROOT + ".setOptionFlags", params)
	if !a_noUpdate
		ui.Invoke(self.JOURNAL_MENU, self.MENU_ROOT + ".invalidateOptionData")
	endIf
endFunction

function SetInputText(String a_text)

	String optionState = _stateOptionMap[_activeOption % 256]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnInputAcceptST(a_text)
		self.GotoState(oldState)
	else
		self.OnOptionInputAccept(_activeOption, a_text)
	endIf
	_activeOption = -1
endFunction

function SetMenuDialogDefaultIndex(Int a_value)

	if _state != self.STATE_MENU
		self.Error("Cannot set menu dialog params while outside OnOptionMenuOpen()")
		return 
	endIf
	_menuParams[1] = a_value
endFunction

function OnInputOpenST()
{Called when a text input state option has been selected}

	; Empty function
endFunction

function SetPage(String a_page, Int a_index)

	_currentPage = a_page
	_currentPageNum = 1 + a_index
	if a_page != ""
		self.SetTitleText(a_page)
	else
		self.SetTitleText(ModName)
	endIf
	self.ClearOptionBuffers()
	_state = self.STATE_RESET
	self.OnPageReset(a_page)
	_state = self.STATE_DEFAULT
	self.WriteOptionBuffers()
endFunction

function AddKeyMapOptionST(String a_stateName, String a_text, Int a_keyCode, Int a_flags)

	self.AddOptionST(a_stateName, self.OPTION_TYPE_KEYMAP, a_text, none, a_keyCode as Float, a_flags)
endFunction

function OpenConfig()

	_optionFlagsBuf = new Int[128]
	_textBuf = new String[128]
	_strValueBuf = new String[128]
	_numValueBuf = new Float[128]
	_stateOptionMap = new String[128]
	self.SetPage("", -1)
	self.OnConfigOpen()
	ui.InvokeStringA(self.JOURNAL_MENU, self.MENU_ROOT + ".setPageNames", Pages)
endFunction

function SetInfoText(String a_text)

	_infoText = a_text
endFunction

Bool function ShowMessage(String a_message, Bool a_withCancel, String a_acceptLabel, String a_cancelLabel)

	if _waitForMessage
		self.Error("Called ShowMessage() while another message was already open")
		return false
	endIf
	_waitForMessage = true
	_messageResult = false
	String[] params = new String[3]
	params[0] = a_message
	params[1] = a_acceptLabel
	if a_withCancel
		params[2] = a_cancelLabel
	else
		params[2] = ""
	endIf
	self.RegisterForModEvent("SKICP_messageDialogClosed", "OnMessageDialogClose")
	ui.InvokeStringA(self.JOURNAL_MENU, self.MENU_ROOT + ".showMessageDialog", params)
	while _waitForMessage
		utility.WaitMenuMode(0.100000)
	endWhile
	self.UnregisterForModEvent("SKICP_messageDialogClosed")
	return _messageResult
endFunction

function OnConfigManagerReset(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	_configManager = none
endFunction

function SetColorDialogDefaultColor(Int a_color)

	if _state != self.STATE_COLOR
		self.Error("Cannot set color dialog params while outside OnOptionColorOpen()")
		return 
	endIf
	_colorParams[1] = a_color
endFunction

function OnColorOpenST()
{Called when a color state option has been selected}

	; Empty function
endFunction

function SetColorDialogStartColor(Int a_color)

	if _state != self.STATE_COLOR
		self.Error("Cannot set color dialog params while outside OnOptionColorOpen()")
		return 
	endIf
	_colorParams[0] = a_color
endFunction

; Skipped compiler generated GotoState

function SetMenuDialogOptions(String[] a_options)

	if _state != self.STATE_MENU
		self.Error("Cannot set menu dialog params while outside OnOptionMenuOpen()")
		return 
	endIf
	ui.InvokeStringA(self.JOURNAL_MENU, self.MENU_ROOT + ".setMenuDialogOptions", a_options)
endFunction

function SetSliderOptionValueST(Float a_value, String a_formatString, Bool a_noUpdate, String a_stateName)

	Int index = self.GetStateOptionIndex(a_stateName)
	if index < 0
		self.Error("Cannot use SetSliderOptionValueST outside a valid option state")
		return 
	endIf
	self.SetSliderOptionValue(index, a_value, a_formatString, a_noUpdate)
endFunction

function AddOptionST(String a_stateName, Int a_optionType, String a_text, String a_strValue, Float a_numValue, Int a_flags)

	if _stateOptionMap.find(a_stateName, 0) != -1
		self.Error("State option name " + a_stateName + " is already in use")
		return 
	endIf
	Int index = self.AddOption(a_optionType, a_text, a_strValue, a_numValue, a_flags) % 256
	if index < 0
		return 
	endIf
	if _stateOptionMap[index] != ""
		self.Error("State option index " + index as String + " already in use")
		return 
	endIf
	_stateOptionMap[index] = a_stateName
endFunction

function OnSelectST()
{Called when a non-interactive state option has been selected}

	; Empty function
endFunction

function SetSliderDialogStartValue(Float a_value)

	if _state != self.STATE_SLIDER
		self.Error("Cannot set slider dialog params while outside OnOptionSliderOpen()")
		return 
	endIf
	_sliderParams[0] = a_value
endFunction

Int function AddHeaderOption(String a_text, Int a_flags)

	return self.AddOption(self.OPTION_TYPE_HEADER, a_text, none, 0 as Float, a_flags)
endFunction

function OnGameReload()

	if !_initialized
		_initialized = true
		_sliderParams = new Float[5]
		_menuParams = new Int[2]
		_colorParams = new Int[2]
		self.OnConfigInit()
		debug.Trace(self as String + " INITIALIZED", 0)
	endIf
	self.RegisterForModEvent("SKICP_configManagerReady", "OnConfigManagerReady")
	self.RegisterForModEvent("SKICP_configManagerReset", "OnConfigManagerReset")
	self.CheckVersion()
endFunction

function SetTextOptionValue(Int a_option, String a_value, Bool a_noUpdate)

	Int index = a_option % 256
	Int type = _optionFlagsBuf[index] % 256
	if type != self.OPTION_TYPE_TEXT
		Int pageIdx = a_option / 256 - 1
		if pageIdx != -1
			self.Error("Option type mismatch. Expected text option, page \"" + Pages[pageIdx] + "\", index " + index as String)
		else
			self.Error("Option type mismatch. Expected text option, page \"\", index " + index as String)
		endIf
		return 
	endIf
	self.SetOptionStrValue(index, a_value, a_noUpdate)
endFunction

function SetSliderDialogDefaultValue(Float a_value)

	if _state != self.STATE_SLIDER
		self.Error("Cannot set slider dialog params while outside OnOptionSliderOpen()")
		return 
	endIf
	_sliderParams[1] = a_value
endFunction

function OnOptionSliderAccept(Int a_option, Float a_value)
{Called when a new slider value has been accepted}

	; Empty function
endFunction

function SetMenuDialogStartIndex(Int a_value)

	if _state != self.STATE_MENU
		self.Error("Cannot set menu dialog params while outside OnOptionMenuOpen()")
		return 
	endIf
	_menuParams[0] = a_value
endFunction

function SetInputOptionValueST(String a_value, Bool a_noUpdate, String a_stateName)

	Int index = self.GetStateOptionIndex(a_stateName)
	if index < 0
		self.Error("Cannot use SetInputOptionValueST outside a valid option state")
		return 
	endIf
	self.SetInputOptionValue(index, a_value, a_noUpdate)
endFunction

function OnSliderOpenST()
{Called when a slider state option has been selected}

	; Empty function
endFunction

function SetKeyMapOptionValueST(Int a_keyCode, Bool a_noUpdate, String a_stateName)

	Int index = self.GetStateOptionIndex(a_stateName)
	if index < 0
		self.Error("Cannot use SetKeyMapOptionValueST outside a valid option state")
		return 
	endIf
	self.SetKeyMapOptionValue(index, a_keyCode, a_noUpdate)
endFunction

function SetColorOptionValueST(Int a_color, Bool a_noUpdate, String a_stateName)

	Int index = self.GetStateOptionIndex(a_stateName)
	if index < 0
		self.Error("Cannot use SetColorOptionValueST outside a valid option state")
		return 
	endIf
	self.SetColorOptionValue(index, a_color, a_noUpdate)
endFunction

function SetMenuOptionValue(Int a_option, String a_value, Bool a_noUpdate)

	Int index = a_option % 256
	Int type = _optionFlagsBuf[index] % 256
	if type != self.OPTION_TYPE_MENU
		Int pageIdx = a_option / 256 - 1
		if pageIdx != -1
			self.Error("Option type mismatch. Expected menu option, page \"" + Pages[pageIdx] + "\", index " + index as String)
		else
			self.Error("Option type mismatch. Expected menu option, page \"\", index " + index as String)
		endIf
		return 
	endIf
	self.SetOptionStrValue(index, a_value, a_noUpdate)
endFunction

function SetMenuOptionValueST(String a_value, Bool a_noUpdate, String a_stateName)

	Int index = self.GetStateOptionIndex(a_stateName)
	if index < 0
		self.Error("Cannot use SetMenuOptionValueST outside a valid option state")
		return 
	endIf
	self.SetMenuOptionValue(index, a_value, a_noUpdate)
endFunction

Int function AddMenuOption(String a_text, String a_value, Int a_flags)

	return self.AddOption(self.OPTION_TYPE_MENU, a_text, a_value, 0 as Float, a_flags)
endFunction

function ForcePageReset()
{Forces a full reset of the current page}

	ui.Invoke(self.JOURNAL_MENU, self.MENU_ROOT + ".forcePageReset")
endFunction

function SetOptionNumValue(Int a_index, Float a_numValue, Bool a_noUpdate)

	if _state == self.STATE_RESET
		self.Error("Cannot modify option data while in OnPageReset()")
		return 
	endIf
	String menu = self.JOURNAL_MENU
	String root = self.MENU_ROOT
	ui.SetInt(menu, root + ".optionCursorIndex", a_index)
	ui.SetFloat(menu, root + ".optionCursor.numValue", a_numValue)
	if !a_noUpdate
		ui.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction

function OnMenuOpenST()
{Called when a menu state option has been selected}

	; Empty function
endFunction

function SetInputOptionValue(Int a_option, String a_value, Bool a_noUpdate)

	Int index = a_option % 256
	Int type = _optionFlagsBuf[index] % 256
	if type != self.OPTION_TYPE_INPUT
		Int pageIdx = a_option / 256 - 1
		if pageIdx != -1
			self.Error("Option type mismatch. Expected input option, page \"" + Pages[pageIdx] + "\", index " + index as String)
		else
			self.Error("Option type mismatch. Expected input option, page \"\", index " + index as String)
		endIf
		return 
	endIf
	self.SetOptionStrValue(index, a_value, a_noUpdate)
endFunction

function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)
{Called when a key has been remapped for this state option}

	; Empty function
endFunction

function SetKeyMapOptionValue(Int a_option, Int a_keyCode, Bool a_noUpdate)

	Int index = a_option % 256
	Int type = _optionFlagsBuf[index] % 256
	if type != self.OPTION_TYPE_KEYMAP
		Int pageIdx = a_option / 256 - 1
		if pageIdx != -1
			self.Error("Option type mismatch. Expected keymap option, page \"" + Pages[pageIdx] + "\", index " + index as String)
		else
			self.Error("Option type mismatch. Expected keymap option, page \"\", index " + index as String)
		endIf
		return 
	endIf
	self.SetOptionNumValue(index, a_keyCode as Float, a_noUpdate)
endFunction

function SetColorOptionValue(Int a_option, Int a_color, Bool a_noUpdate)

	Int index = a_option % 256
	Int type = _optionFlagsBuf[index] % 256
	if type != self.OPTION_TYPE_COLOR
		Int pageIdx = a_option / 256 - 1
		if pageIdx != -1
			self.Error("Option type mismatch. Expected color option, page \"" + Pages[pageIdx] + "\", index " + index as String)
		else
			self.Error("Option type mismatch. Expected color option, page \"\", index " + index as String)
		endIf
		return 
	endIf
	self.SetOptionNumValue(index, a_color as Float, a_noUpdate)
endFunction

function LoadCustomContent(String a_source, Float a_x, Float a_y)

	Float[] params = new Float[2]
	params[0] = a_x
	params[1] = a_y
	ui.InvokeFloatA(self.JOURNAL_MENU, self.MENU_ROOT + ".setCustomContentParams", params)
	ui.InvokeString(self.JOURNAL_MENU, self.MENU_ROOT + ".loadCustomContent", a_source)
endFunction

function SetToggleOptionValue(Int a_option, Bool a_checked, Bool a_noUpdate)

	Int index = a_option % 256
	Int type = _optionFlagsBuf[index] % 256
	if type != self.OPTION_TYPE_TOGGLE
		Int pageIdx = a_option / 256 - 1
		if pageIdx != -1
			self.Error("Option type mismatch. Expected toggle option, page \"" + Pages[pageIdx] + "\", index " + index as String)
		else
			self.Error("Option type mismatch. Expected toggle option, page \"\", index " + index as String)
		endIf
		return 
	endIf
	self.SetOptionNumValue(index, (a_checked as Int) as Float, a_noUpdate)
endFunction

Int function AddInputOption(String a_text, String a_value, Int a_flags)

	return self.AddOption(self.OPTION_TYPE_INPUT, a_text, a_value, 0 as Float, a_flags)
endFunction

function OnOptionKeyMapChange(Int a_option, Int a_keyCode, String a_conflictControl, String a_conflictName)
{Called when a key has been remapped}

	; Empty function
endFunction

function WriteOptionBuffers()

	String menu = self.JOURNAL_MENU
	String root = self.MENU_ROOT
	Int t = self.OPTION_TYPE_EMPTY
	Int i = 0
	Int optionCount = 0
	i = 0
	while i < 128
		if _optionFlagsBuf[i] != t
			optionCount = i + 1
		endIf
		i += 1
	endWhile
	ui.InvokeIntA(menu, root + ".setOptionFlagsBuffer", _optionFlagsBuf)
	ui.InvokeStringA(menu, root + ".setOptionTextBuffer", _textBuf)
	ui.InvokeStringA(menu, root + ".setOptionStrValueBuffer", _strValueBuf)
	ui.InvokeFloatA(menu, root + ".setOptionNumValueBuffer", _numValueBuf)
	ui.InvokeInt(menu, root + ".flushOptionBuffers", optionCount)
endFunction

function ClearOptionBuffers()

	Int t = self.OPTION_TYPE_EMPTY
	Int i = 0
	while i < 128
		_optionFlagsBuf[i] = t
		_textBuf[i] = ""
		_strValueBuf[i] = ""
		_numValueBuf[i] = 0 as Float
		_stateOptionMap[i] = ""
		i += 1
	endWhile
	_cursorPosition = 0
	_cursorFillMode = self.LEFT_TO_RIGHT
endFunction

Int function AddTextOption(String a_text, String a_value, Int a_flags)

	return self.AddOption(self.OPTION_TYPE_TEXT, a_text, a_value, 0 as Float, a_flags)
endFunction

function SetColorValue(Int a_color)

	String optionState = _stateOptionMap[_activeOption % 256]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnColorAcceptST(a_color)
		self.GotoState(oldState)
	else
		self.OnOptionColorAccept(_activeOption, a_color)
	endIf
	_activeOption = -1
endFunction

function OnOptionInputAccept(Int a_option, String a_input)
{Called when a new text input has been accepted}

	; Empty function
endFunction

function RequestInputDialogData(Int a_index)

	_activeOption = a_index + _currentPageNum * 256
	_inputStartText = ""
	_state = self.STATE_INPUT
	String optionState = _stateOptionMap[a_index]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnInputOpenST()
		self.GotoState(oldState)
	else
		self.OnOptionInputOpen(_activeOption)
	endIf
	_state = self.STATE_DEFAULT
	ui.InvokeString(self.JOURNAL_MENU, self.MENU_ROOT + ".setInputDialogParams", _inputStartText)
endFunction

function OnInit()

	self.OnGameReload()
endFunction

function OnConfigOpen()
{Called when this config menu is opened}

	; Empty function
endFunction

function OnOptionSliderOpen(Int a_option)
{Called when a slider option has been selected}

	; Empty function
endFunction

function OnOptionMenuAccept(Int a_option, Int a_index)
{Called when a menu entry has been accepted}

	; Empty function
endFunction

function OnHighlightST()
{Called when highlighting a state option}

	; Empty function
endFunction

function OnColorAcceptST(Int a_color)
{Called when a new color has been accepted for this state option}

	; Empty function
endFunction

Int function AddOption(Int a_optionType, String a_text, String a_strValue, Float a_numValue, Int a_flags)

	if _state != self.STATE_RESET
		self.Error("Cannot add option " + a_text + " outside of OnPageReset()")
		return -1
	endIf
	Int pos = _cursorPosition
	if pos == -1
		return -1
	endIf
	_optionFlagsBuf[pos] = a_optionType + a_flags * 256
	_textBuf[pos] = a_text
	_strValueBuf[pos] = a_strValue
	_numValueBuf[pos] = a_numValue
	_cursorPosition += _cursorFillMode
	if _cursorPosition >= 128
		_cursorPosition = -1
	endIf
	return pos + _currentPageNum * 256
endFunction

String function GetCustomControl(Int a_keyCode)
{Returns the name of a custom control mapped to given keyCode, or "" if the key is not in use by this config}

	return ""
endFunction

Int function GetVersion()
{Returns version of this script}

	return 1
endFunction

function OnMessageDialogClose(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	_messageResult = a_numArg as Bool
	_waitForMessage = false
endFunction

Int function AddColorOption(String a_text, Int a_color, Int a_flags)

	return self.AddOption(self.OPTION_TYPE_COLOR, a_text, none, a_color as Float, a_flags)
endFunction

function SetMenuIndex(Int a_index)

	String optionState = _stateOptionMap[_activeOption % 256]
	if optionState != ""
		String oldState = self.GetState()
		self.GotoState(optionState)
		self.OnMenuAcceptST(a_index)
		self.GotoState(oldState)
	else
		self.OnOptionMenuAccept(_activeOption, a_index)
	endIf
	_activeOption = -1
endFunction

function OnConfigClose()
{Called when this config menu is closed}

	; Empty function
endFunction

function OnMenuAcceptST(Int a_index)
{Called when a menu entry has been accepted for this state option}

	; Empty function
endFunction

function SetSliderDialogRange(Float a_minValue, Float a_maxValue)

	if _state != self.STATE_SLIDER
		self.Error("Cannot set slider dialog params while outside OnOptionSliderOpen()")
		return 
	endIf
	_sliderParams[2] = a_minValue
	_sliderParams[3] = a_maxValue
endFunction

function OnOptionInputOpen(Int a_option)
{Called when a text input option has been selected}

	; Empty function
endFunction

function AddMenuOptionST(String a_stateName, String a_text, String a_value, Int a_flags)

	self.AddOptionST(a_stateName, self.OPTION_TYPE_MENU, a_text, a_value, 0 as Float, a_flags)
endFunction

function UnloadCustomContent()

	ui.Invoke(self.JOURNAL_MENU, self.MENU_ROOT + ".unloadCustomContent")
endFunction
