scriptname SKI_WidgetManager extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		HUD_MENU	= "HUD Menu" autoReadonly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

; -- Version 1 --

int					_widgetCount	= 0
int					_curWidgetID	= 0
string[]			_widgetSources
SKI_WidgetBase[]	_widgets

; Item card layout reported by the inventory menu (SKIIM_itemCardMetrics): passed to the HUD widget loader, which uses it
; to centre the 3D item before an item menu opens. Kept here rather than in SKI_ConfigMenu, which MCM Helper replaces.
string				_itemCardMetrics = ""


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_widgets = new SKI_WidgetBase[128]
	_widgetSources = new string[128]
	Utility.Wait(0.5)
	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	RegisterForModEvent("SKIWF_widgetLoaded", "OnWidgetLoad")
	RegisterForModEvent("SKIWF_widgetError", "OnWidgetError")
	RegisterForModEvent("SKIIM_itemCardMetrics", "OnItemCardMetrics")
	RegisterForModEvent("SKIIM_hudItemCardReady", "OnHudItemCardReady")
	Apply3DItemPosition()
	CleanUp()
	if (UI.IsMenuOpen(HUD_MENU))
		InitWidgetLoader()
	else
		RegisterForMenu(HUD_MENU)
	endIf
endEvent


; EVENTS ------------------------------------------------------------------------------------------

event OnMenuOpen(string a_menuName)
	if (a_menuName == HUD_MENU)
		UnregisterForMenu(HUD_MENU)
		InitWidgetLoader()
	endIf
endEvent

event OnWidgetLoad(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int widgetID = a_strArg as int
	SKI_WidgetBase client = _widgets[widgetID]
	if (client != none)
		client.OnWidgetLoad()
	endIf
endEvent

event OnWidgetError(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int widgetID = a_numArg as int
	string errorType = a_strArg
	Debug.Trace("WidgetError: " + _widgets[widgetID] + ": " + errorType)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

int function RequestWidgetID(SKI_WidgetBase a_client)
	if (_widgetCount >= 128)
		return -1
	endIf

	int widgetID = NextWidgetID()
	_widgets[widgetID] = a_client
	_widgetCount += 1
	return widgetID
endFunction

SKI_WidgetBase[] function GetWidgets()
	SKI_WidgetBase[] widgetsCopy = new SKI_WidgetBase[128]
	int i = 0
	while (i < _widgets.length)
		widgetsCopy[i] = _widgets[i]
		i += 1
	endWhile
	return widgetsCopy
endFunction

function CreateWidget(int a_widgetID, string a_widgetSource)
	_widgetSources[a_widgetID] = a_widgetSource
	string[] args = new string[2]
	args[0] = a_widgetID as string
	args[1] = a_widgetSource
	UI.InvokeStringA(HUD_MENU, "_root.widgetLoaderContainer.widgetLoader.loadWidget", args)
endFunction


; PRIVATE FUNCTIONS -------------------------------------------------------------------------------

function InitWidgetLoader()
	Debug.Trace("InitWidgetLoader()")

	int releaseIdx = UI.GetInt(HUD_MENU, "_global.WidgetLoader.SKYUI_RELEASE_IDX")

	; Not loaded yet, load it
	if (releaseIdx == 0)
		string rootPath = ""
		string[] args = new string[2]
		args[0] = "widgetLoaderContainer"
		args[1] = "-1000"
		UI.InvokeStringA(HUD_MENU, "_root.createEmptyMovieClip", args)
		UI.InvokeString(HUD_MENU, "_root.widgetLoaderContainer.loadMovie", "skyui/widgetloader.swf")
		Utility.Wait(0.5)
		releaseIdx = UI.GetInt(HUD_MENU, "_global.WidgetLoader.SKYUI_RELEASE_IDX")

		if (releaseIdx == 0)
			rootPath = "exported/"
			UI.InvokeString(HUD_MENU, "_root.widgetLoaderContainer.loadMovie", "exported/skyui/widgetloader.swf")
			Utility.Wait(0.5)
			releaseIdx = UI.GetInt(HUD_MENU, "_global.WidgetLoader.SKYUI_RELEASE_IDX")
		endIf

		if (releaseIdx == 0)
			Debug.Trace("InitWidgetLoader(): load failed")
			return
		endIf

		UI.InvokeString(HUD_MENU, "_root.widgetLoaderContainer.widgetLoader.setRootPath", rootPath)
	endIf

	UI.InvokeStringA(HUD_MENU, "_root.widgetLoaderContainer.widgetLoader.loadWidgets", _widgetSources)
	SendModEvent("SKIWF_widgetManagerReady")
endFunction

int function NextWidgetID()
	int startIdx = _curWidgetID
	while (_widgets[_curWidgetID] != none)
		_curWidgetID += 1
		if (_curWidgetID >= 128)
			_curWidgetID = 0
		endIf
		if (_curWidgetID == startIdx)
			return -1
		endIf
	endWhile
	return _curWidgetID
endFunction

function CleanUp()
	_widgetCount = 0
	int i = 0
	while (i < _widgets.length)
		if (_widgets[i] == none || _widgets[i].GetFormID() == 0)
			_widgets[i] = none
			_widgetSources[i] = ""
		else
			_widgetCount += 1
		endIf
		i += 1
	endWhile
endFunction


; 3D ITEM POSITION --------------------------------------------------------------------------------

; Sent by ItemMenu.positionFloatingElements each time an item menu places its card: the measured layout
; ("panel,w,xMin,xMax,yMin,y,safe,ox,oy", see skyui.util.ItemCardLayout). Kept in the save for the HUD.
event OnItemCardMetrics(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	if (a_strArg == _itemCardMetrics)
		return
	endIf
	_itemCardMetrics = a_strArg
	PushItemCardMetricsToHUD()
endEvent

event OnHudItemCardReady(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	PushItemCardMetricsToHUD()
endEvent

function PushItemCardMetricsToHUD()
	if (_itemCardMetrics == "")
		return
	endIf
	string[] parts = StringUtil.Split(_itemCardMetrics, ",")
	if (parts.length < 9)
		return
	endIf
	float[] args = new float[9]
	int i = 0
	while (i < 9)
		args[i] = parts[i] as float
		i += 1
	endWhile
	UI.InvokeFloatA("HUD Menu", "_root.widgetLoaderContainer.widgetLoader.setItemCardMetrics", args)
endFunction

; Fallback for a missing HUD widget loader: the 3D item position the item menus last applied (fields 10 and 11 of the
; metrics, offsets included), set at game load so a session starts centred. The HUD's own computation replaces it.
function Apply3DItemPosition()
	string[] parts = StringUtil.Split(_itemCardMetrics, ",")
	if (parts.length < 11)
		return
	endIf
	float x = parts[9] as float
	float z = parts[10] as float
	Utility.SetINIFloat("fInventory3DItemPosX:Interface", x)
	Utility.SetINIFloat("fInventory3DItemPosXWide:Interface", x)
	Utility.SetINIFloat("fMagic3DItemPosX:Interface", x)
	Utility.SetINIFloat("fMagic3DItemPosXWide:Interface", x)
	Utility.SetINIFloat("fInventory3DItemPosZ:Interface", z)
	Utility.SetINIFloat("fInventory3DItemPosZWide:Interface", z)
	Utility.SetINIFloat("fMagic3DItemPosZ:Interface", z)
	Utility.SetINIFloat("fMagic3DItemPosZWide:Interface", z)
endFunction
