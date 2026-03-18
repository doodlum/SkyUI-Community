scriptname SKI_SearchHistory extends SKI_QuestBase

import StringUtil
import UI

; SEARCH HISTORY CONSTANTS ---
string property SEP_FIELD = "|" autoReadOnly

; MENU CONSTANTS (copied from SKI_Main)
string property		INVENTORY_MENU	= "InventoryMenu" autoReadonly
string property		MAGIC_MENU		= "MagicMenu" autoReadonly
string property		CONTAINER_MENU	= "ContainerMenu" autoReadonly
string property		BARTER_MENU		= "BarterMenu" autoReadonly
string property		GIFT_MENU		= "GiftMenu" autoReadonly
string property		MAP_MENU		= "MapMenu" autoReadonly
string property		CRAFTING_MENU	= "Crafting Menu" autoReadonly

; HISTORY STORAGE VARIABLES (No StorageUtil required) ---
string property HistInventory auto
string property HistMagic auto
string property HistContainer auto
string property HistBarter auto
string property HistGift auto
string property HistCrafting auto
string property HistMap auto
; -----------------------------------------------------------


; INITIALIZATION -----------------------------------------------------------------------------------

event OnInit()
    OnGameReload()
endEvent

event OnGameReload()
    RegisterForModEvent("SaveSearchHistory", "OnSaveSearchHistory")
    RegisterForModEvent("LoadSearchHistory", "OnLoadSearchHistory")
    
    Debug.Trace("[SKI_SearchHistory] Registered for ModEvents.")
endEvent


; SEARCH HISTORY EVENTS (INTERNAL STORAGE) ----------------------------------------------------

event OnSaveSearchHistory(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	int sep = StringUtil.Find(a_strArg, SEP_FIELD)
	if (sep < 0)
		return
	endIf

	string menuKey = StringUtil.Substring(a_strArg, 0, sep)
	string history = StringUtil.Substring(a_strArg, sep + 1)

	; Save to internal variable instead of StorageUtil
	SetHistory(menuKey, history)
	
	Debug.Trace("[SKI_Main] Saved History for " + menuKey + ": " + history)
endEvent

event OnLoadSearchHistory(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	string menuKey = a_strArg
	
	; Load from internal variable
	string history = GetHistory(menuKey)

	Debug.Trace("[SKI_Main] Load Request for " + menuKey + ". Data: " + history)

	int tries = 0
	while (!UI.IsMenuOpen(menuKey) && tries < 15)
		Utility.Wait(0.1)
		tries += 1
	endWhile

	if (UI.IsMenuOpen(menuKey))
		UI.InvokeString(menuKey, "_root.Menu_mc.inventoryLists.searchWidget.receiveHistory", history)
		UI.InvokeString(menuKey, "_root.inventoryLists.searchWidget.receiveHistory", history)
		Debug.Trace("[SKI_Main] Sent history to " + menuKey)
	else
		Debug.Trace("[SKI_Main] ERROR: Menu " + menuKey + " not open!")
	endIf
endEvent

; --- HELPER FUNCTIONS FOR INTERNAL STORAGE ---
function SetHistory(string a_key, string a_data)
	if     (a_key == INVENTORY_MENU)
		HistInventory = a_data
	elseif (a_key == MAGIC_MENU)
		HistMagic = a_data
	elseif (a_key == CONTAINER_MENU)
		HistContainer = a_data
	elseif (a_key == BARTER_MENU)
		HistBarter = a_data
	elseif (a_key == GIFT_MENU)
		HistGift = a_data
	elseif (a_key == CRAFTING_MENU)
		HistCrafting = a_data
	elseif (a_key == MAP_MENU)
		HistMap = a_data
	endif
endFunction

string function GetHistory(string a_key)
	if     (a_key == INVENTORY_MENU)
		return HistInventory
	elseif (a_key == MAGIC_MENU)
		return HistMagic
	elseif (a_key == CONTAINER_MENU)
		return HistContainer
	elseif (a_key == BARTER_MENU)
		return HistBarter
	elseif (a_key == GIFT_MENU)
		return HistGift
	elseif (a_key == CRAFTING_MENU)
		return HistCrafting
	elseif (a_key == MAP_MENU)
		return HistMap
	endif
	return ""
endFunction