scriptName SKI_WidgetBase extends SKI_QuestBase

;-- Properties --------------------------------------
String property HAnchor
{Horizontal anchor point of the widget ["left", "center", "right"]. Default: "left"}
	String function get()

		return _hAnchor
	endFunction
	function set(String a_val)

		_hAnchor = a_val
		if self.Ready
			self.UpdateWidgetHAnchor()
		endIf
	endFunction
endproperty
String property WidgetName = "I-forgot-to-set-the-widget name" auto
{Name of the widget. Used to identify it in the user interface.}
Float property Y
{Vertical position of the widget in pixels at a resolution of 1280x720 [0.0, 720.0]. Default: 0.0}
	Float function get()

		return _y
	endFunction
	function set(Float a_val)

		_y = a_val
		if self.Ready
			self.UpdateWidgetPositionY()
		endIf
	endFunction
endproperty
Float property X
{Horizontal position of the widget in pixels at a resolution of 1280x720 [0.0, 1280.0]. Default: 0.0}
	Float function get()

		return _x
	endFunction
	function set(Float a_val)

		_x = a_val
		if self.Ready
			self.UpdateWidgetPositionX()
		endIf
	endFunction
endproperty
String property HUD_MENU
	String function get()

		return "HUD Menu"
	endFunction
endproperty
Bool property RequireExtend = true auto
{Require extending the widget type instead of using it directly.}
String property VAnchor
{Vertical anchor point of the widget ["top", "center", "bottom"]. Default: "top"}
	String function get()

		return _vAnchor
	endFunction
	function set(String a_val)

		_vAnchor = a_val
		if self.Ready
			self.UpdateWidgetVAnchor()
		endIf
	endFunction
endproperty
Float property Alpha
{Opacity of the widget [0.0, 100.0]. Default: 0.0}
	Float function get()

		return _alpha
	endFunction
	function set(Float a_val)

		_alpha = a_val
		if self.Ready
			self.UpdateWidgetAlpha()
		endIf
	endFunction
endproperty
Int property WidgetID
{Unique ID of the widget. ReadOnly}
	Int function get()

		return _widgetID
	endFunction
endproperty
Bool property Ready
{True once the widget has registered. ReadOnly}
	Bool function get()

		return _initialized
	endFunction
endproperty
String property WidgetRoot
{Path to the root of the widget from _root of HudMenu. ReadOnly}
	String function get()

		return _widgetRoot
	endFunction
endproperty
String[] property Modes
{HUDModes in which the widget is visible, see readme for available modes}
	String[] function get()

		return _modes
	endFunction
	function set(String[] a_val)

		_modes = a_val
		if self.Ready
			self.UpdateWidgetModes()
		endIf
	endFunction
endproperty

;-- Variables ---------------------------------------
Int _widgetID = -1
String _vAnchor = "top"
Float _alpha = 100.000
String _widgetRoot = ""
Float _x = 0.000000
String[] _modes
String _hAnchor = "left"
Float _y = 0.000000
Bool _initialized = false
SKI_WidgetManager _widgetManager
Bool _ready = false

;-- Functions ---------------------------------------

function TweenTo(Float a_x, Float a_y, Float a_duration)
{Moves the widget to a new x, y position over time}

	Float[] args = new Float[3]
	args[0] = a_x
	args[1] = a_y
	args[2] = a_duration
	ui.InvokeFloatA(self.HUD_MENU, _widgetRoot + ".tweenTo", args)
endFunction

function UpdateWidgetVAnchor()

	ui.InvokeString(self.HUD_MENU, _widgetRoot + ".setVAnchor", self.VAnchor)
endFunction

String function GetWidgetType()

	return ""
endFunction

function OnGameReload()

	_ready = false
	self.RegisterForModEvent("SKIWF_widgetManagerReady", "OnWidgetManagerReady")
	if !self.IsExtending() && RequireExtend as Bool
		debug.MessageBox("WARNING!\n" + self as String + " must extend a base script type.")
	endIf
	if !_initialized
		_initialized = true
		if !_modes
			_modes = new String[6]
			_modes[0] = "All"
			_modes[1] = "StealthMode"
			_modes[2] = "Favor"
			_modes[3] = "Swimming"
			_modes[4] = "HorseMode"
			_modes[5] = "WarHorseMode"
		endIf
		self.OnWidgetInit()
		debug.Trace(self as String + " INITIALIZED", 0)
	endIf
	self.CheckVersion()
endFunction

; Skipped compiler generated GotoState

Float[] function GetDimensions()
{Return the dimensions of the widget (width,height).}

	Float[] dim = new Float[2]
	dim[0] = 0 as Float
	dim[1] = 0 as Float
	return dim
endFunction

function UpdateWidgetHAnchor()

	ui.InvokeString(self.HUD_MENU, _widgetRoot + ".setHAnchor", self.HAnchor)
endFunction

function FadeTo(Float a_alpha, Float a_duration)
{Fades the widget to a new alpha over time}

	Float[] args = new Float[2]
	args[0] = a_alpha
	args[1] = a_duration
	ui.InvokeFloatA(self.HUD_MENU, _widgetRoot + ".fadeTo", args)
endFunction

Bool function IsExtending()

	String S = self as String
	String sn = self.GetWidgetType() + " "
	S = stringutil.Substring(S, 1, stringutil.GetLength(sn))
	if S == sn
		return false
	endIf
	return true
endFunction

function TweenToX(Float a_x, Float a_duration)
{Moves the widget to a new x position over time}

	self.TweenTo(a_x, _y, a_duration)
endFunction

function UpdateWidgetClientInfo()

	ui.InvokeString(self.HUD_MENU, _widgetRoot + ".setClientInfo", self as String)
endFunction

function OnWidgetLoad()

	_ready = true
	self.OnWidgetReset()
	self.UpdateWidgetModes()
endFunction

function UpdateWidgetPositionY()

	ui.InvokeFloat(self.HUD_MENU, _widgetRoot + ".setPositionY", self.Y)
endFunction

function OnInit()

	self.OnGameReload()
endFunction

function UpdateWidgetModes()

	ui.InvokeStringA(self.HUD_MENU, _widgetRoot + ".setModes", self.Modes)
endFunction

function UpdateWidgetPositionX()

	ui.InvokeFloat(self.HUD_MENU, _widgetRoot + ".setPositionX", self.X)
endFunction

function OnWidgetInit()
{Handles any custom widget initialization}

	; Empty function
endFunction

function UpdateWidgetAlpha()

	ui.InvokeFloat(self.HUD_MENU, _widgetRoot + ".setAlpha", self.Alpha)
endFunction

; Skipped compiler generated GetState

function OnWidgetManagerReady(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)

	SKI_WidgetManager newManager = a_sender as SKI_WidgetManager
	if _widgetManager == newManager
		return 
	endIf
	_widgetManager = newManager
	_widgetID = _widgetManager.RequestWidgetID(self)
	if _widgetID != -1
		_widgetRoot = "_root.WidgetContainer." + _widgetID as String + ".widget"
		_widgetManager.CreateWidget(_widgetID, self.GetWidgetSource())
	else
		debug.Trace("WidgetWarning: " + self as String + ": could not be loaded, too many widgets. Max is 128", 0)
	endIf
endFunction

String function GetWidgetSource()

	return ""
endFunction

function OnWidgetReset()

	self.UpdateWidgetClientInfo()
	self.UpdateWidgetHAnchor()
	self.UpdateWidgetVAnchor()
	self.UpdateWidgetPositionX()
	self.UpdateWidgetPositionY()
	self.UpdateWidgetAlpha()
endFunction

function TweenToY(Float a_y, Float a_duration)
{Moves the widget to a new y position over time}

	self.TweenTo(_x, a_y, a_duration)
endFunction
