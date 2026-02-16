scriptName SKI_ActiveEffectsWidget extends SKI_WidgetBase

;-- Properties --------------------------------------
String property Orientation
{The axis in which new effects will be added to after the total number of effects > GroupEffectCount}
	String function get()

		return _orientation
	endFunction
	function set(String a_val)

		_orientation = a_val
		if self.Ready
			ui.InvokeString(self.HUD_MENU, self.WidgetRoot + ".setOrientation", _orientation)
		endIf
	endFunction
endproperty
Int property GroupEffectCount
{Maximum number of widgets displayed until a new group (column, or row) is created}
	Int function get()

		return _groupEffectCount
	endFunction
	function set(Int a_val)

		_groupEffectCount = a_val
		if self.Ready
			ui.InvokeInt(self.HUD_MENU, self.WidgetRoot + ".setGroupEffectCount", _groupEffectCount)
		endIf
	endFunction
endproperty
Int property MinimumTimeLeft
{The minimum time left for an effect to be displayed}
	Int function get()

		return _minimumTimeLeft
	endFunction
	function set(Int a_val)

		_minimumTimeLeft = a_val
		if self.Ready
			ui.InvokeInt(self.HUD_MENU, self.WidgetRoot + ".setMinTimeLeft", _minimumTimeLeft)
		endIf
	endFunction
endproperty
Float property EffectSize
{Size of each effect icon in pixels at a resolution of 1280x720}
	Float function get()

		return _effectSize
	endFunction
	function set(Float a_val)

		_effectSize = a_val
		if self.Ready
			ui.InvokeFloat(self.HUD_MENU, self.WidgetRoot + ".setEffectSize", _effectSize)
		endIf
	endFunction
endproperty
Bool property Enabled
{Whether the active effects are displayed or not}
	Bool function get()

		return _enabled
	endFunction
	function set(Bool a_val)

		_enabled = a_val
		if self.Ready
			ui.InvokeBool(self.HUD_MENU, self.WidgetRoot + ".setEnabled", _enabled)
		endIf
	endFunction
endproperty

;-- Variables ---------------------------------------
Int _minimumTimeLeft = 180
Bool _enabled = false
Float _effectSize = 48.0000
String _orientation = "vertical"
Int _groupEffectCount = 8

;-- Functions ---------------------------------------

String function GetWidgetType()

	return "SKI_ActiveEffectsWidget"
endFunction

; Skipped compiler generated GetState

Int function GetVersion()

	return 3
endFunction

function OnWidgetReset()

	parent.OnWidgetReset()
	Float[] numberArgs = new Float[4]
	numberArgs[0] = _enabled as Float
	numberArgs[1] = _effectSize
	numberArgs[2] = _groupEffectCount as Float
	numberArgs[3] = _minimumTimeLeft as Float
	ui.InvokeFloatA(self.HUD_MENU, self.WidgetRoot + ".initNumbers", numberArgs)
	String[] stringArgs = new String[1]
	stringArgs[0] = _orientation
	ui.InvokeStringA(self.HUD_MENU, self.WidgetRoot + ".initStrings", stringArgs)
	ui.Invoke(self.HUD_MENU, self.WidgetRoot + ".initCommit")
endFunction

; Skipped compiler generated GotoState

function OnVersionUpdate(Int a_version)

	if a_version >= 2 && CurrentVersion < 2
		debug.Trace(self as String + ": Updating to script version 2", 0)
		String[] hudModes = new String[6]
		hudModes[0] = "All"
		hudModes[1] = "StealthMode"
		hudModes[2] = "Favor"
		hudModes[3] = "Swimming"
		hudModes[4] = "HorseMode"
		hudModes[5] = "WarHorseMode"
		self.Modes = hudModes
	endIf
endFunction

String function GetWidgetSource()

	return "skyui/activeeffects.swf"
endFunction
