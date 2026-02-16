scriptName SKI_Main extends SKI_QuestBase

;-- Properties --------------------------------------
String property INVENTORY_MENU
	String function get()

		return "InventoryMenu"
	endFunction
endproperty
Int property ERR_SKSE_VERSION_SCPT
	Int function get()

		return 3
	endFunction
endproperty
Bool property CraftingMenuCheckEnabled
	Bool function get()

		return _craftingMenuCheckEnabled
	endFunction
	function set(Bool a_val)

		_craftingMenuCheckEnabled = a_val
		if a_val
			self.RegisterForMenu(self.CRAFTING_MENU)
		else
			self.UnregisterForMenu(self.CRAFTING_MENU)
		endIf
	endFunction
endproperty
String property CONTAINER_MENU
	String function get()

		return "ContainerMenu"
	endFunction
endproperty
Bool property FavoritesMenuCheckEnabled
	Bool function get()

		return _favoritesMenuCheckEnabled
	endFunction
	function set(Bool a_val)

		_favoritesMenuCheckEnabled = a_val
		if a_val
			self.RegisterForMenu(self.FAVORITES_MENU)
		else
			self.UnregisterForMenu(self.FAVORITES_MENU)
		endIf
	endFunction
endproperty
Bool property MapMenuCheckEnabled
	Bool function get()

		return _mapMenuCheckEnabled
	endFunction
	function set(Bool a_val)

		_mapMenuCheckEnabled = a_val
		if a_val
			self.RegisterForMenu(self.MAP_MENU)
		else
			self.UnregisterForMenu(self.MAP_MENU)
		endIf
	endFunction
endproperty
String property BARTER_MENU
	String function get()

		return "BarterMenu"
	endFunction
endproperty
Bool property ErrorDetected = false auto
Bool property ContainerMenuCheckEnabled
	Bool function get()

		return _containerMenuCheckEnabled
	endFunction
	function set(Bool a_val)

		_containerMenuCheckEnabled = a_val
		if a_val
			self.RegisterForMenu(self.CONTAINER_MENU)
		else
			self.UnregisterForMenu(self.CONTAINER_MENU)
		endIf
	endFunction
endproperty
Bool property BarterMenuCheckEnabled
	Bool function get()

		return _barterMenuCheckEnabled
	endFunction
	function set(Bool a_val)

		_barterMenuCheckEnabled = a_val
		if a_val
			self.RegisterForMenu(self.BARTER_MENU)
		else
			self.UnregisterForMenu(self.BARTER_MENU)
		endIf
	endFunction
endproperty
String property MinSKSEVersion
	String function get()

		return "2.0.4"
	endFunction
endproperty
Int property ERR_SWF_VERSION
	Int function get()

		return 6
	endFunction
endproperty
String property ReqSWFVersion
	String function get()

		return "5.2 SE"
	endFunction
endproperty
Bool property InventoryMenuCheckEnabled
	Bool function get()

		return _inventoryMenuCheckEnabled
	endFunction
	function set(Bool a_val)

		_inventoryMenuCheckEnabled = a_val
		if a_val
			self.RegisterForMenu(self.INVENTORY_MENU)
		else
			self.UnregisterForMenu(self.INVENTORY_MENU)
		endIf
	endFunction
endproperty
String property HUD_MENU
	String function get()

		return "HUD Menu"
	endFunction
endproperty
Bool property GiftMenuCheckEnabled
	Bool function get()

		return _giftMenuCheckEnabled
	endFunction
	function set(Bool a_val)

		_giftMenuCheckEnabled = a_val
		if a_val
			self.RegisterForMenu(self.GIFT_MENU)
		else
			self.UnregisterForMenu(self.GIFT_MENU)
		endIf
	endFunction
endproperty
String property MAGIC_MENU
	String function get()

		return "MagicMenu"
	endFunction
endproperty
Int property ReqSWFRelease
	Int function get()

		return 2018
	endFunction
endproperty
Bool property MagicMenuCheckEnabled
	Bool function get()

		return _magicMenuCheckEnabled
	endFunction
	function set(Bool a_val)

		_magicMenuCheckEnabled = a_val
		if a_val
			self.RegisterForMenu(self.MAGIC_MENU)
		else
			self.UnregisterForMenu(self.MAGIC_MENU)
		endIf
	endFunction
endproperty
String property CRAFTING_MENU
	String function get()

		return "Crafting Menu"
	endFunction
endproperty
Int property ERR_SWF_INVALID
	Int function get()

		return 5
	endFunction
endproperty
Int property MinSKSERelease
	Int function get()

		return 53
	endFunction
endproperty
String property MAP_MENU
	String function get()

		return "MapMenu"
	endFunction
endproperty
Int property ERR_SKSE_MISSING
	Int function get()

		return 1
	endFunction
endproperty
Int property ERR_SKSE_BROKEN
	Int function get()

		return 7
	endFunction
endproperty
String property FAVORITES_MENU
	String function get()

		return "FavoritesMenu"
	endFunction
endproperty
String property GIFT_MENU
	String function get()

		return "GiftMenu"
	endFunction
endproperty
Int property ERR_SKSE_VERSION_RT
	Int function get()

		return 2
	endFunction
endproperty
String property JOURNAL_MENU
	String function get()

		return "Journal Menu"
	endFunction
endproperty
Int property ERR_INI_PAPYRUS
	Int function get()

		return 4
	endFunction
endproperty

;-- Variables ---------------------------------------
Bool _giftMenuCheckEnabled = true
Bool _inventoryMenuCheckEnabled = true
Bool _mapMenuCheckEnabled = true
Bool _favoritesMenuCheckEnabled = true
Bool _magicMenuCheckEnabled = true
Bool _containerMenuCheckEnabled = true
Bool _craftingMenuCheckEnabled = true
Bool _barterMenuCheckEnabled = true

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

function Error(Int a_errId, String a_msg)

	debug.MessageBox("SKYUI ERROR CODE " + a_errId as String + "\n\n" + a_msg + "\n\nFor more help, visit the SkyUI SE Nexus or Workshop pages.")
	ErrorDetected = true
endFunction

function OnMenuOpen(String a_menuName)

	if a_menuName == self.INVENTORY_MENU
		if self.CheckMenuVersion("inventorymenu.swf", a_menuName, "_global.InventoryMenu") && self.CheckItemMenuComponents(a_menuName)
			self.UnregisterForMenu(a_menuName)
		endIf
	elseIf a_menuName == self.MAGIC_MENU
		if self.CheckMenuVersion("magicmenu.swf", a_menuName, "_global.MagicMenu") && self.CheckItemMenuComponents(a_menuName)
			self.UnregisterForMenu(a_menuName)
		endIf
	elseIf a_menuName == self.CONTAINER_MENU
		if self.CheckMenuVersion("containermenu.swf", a_menuName, "_global.ContainerMenu") && self.CheckItemMenuComponents(a_menuName)
			self.UnregisterForMenu(a_menuName)
		endIf
	elseIf a_menuName == self.BARTER_MENU
		if self.CheckMenuVersion("bartermenu.swf", a_menuName, "_global.BarterMenu") && self.CheckItemMenuComponents(a_menuName)
			self.UnregisterForMenu(a_menuName)
		endIf
	elseIf a_menuName == self.GIFT_MENU
		if self.CheckMenuVersion("giftmenu.swf", a_menuName, "_global.GiftMenu") && self.CheckItemMenuComponents(a_menuName)
			self.UnregisterForMenu(a_menuName)
		endIf
	elseIf a_menuName == self.JOURNAL_MENU
		if self.CheckMenuVersion("quest_journal.swf", a_menuName, "_global.Quest_Journal") && self.CheckMenuVersion("skyui/configpanel.swf", a_menuName, "_global.ConfigPanel")
			self.UnregisterForMenu(a_menuName)
		endIf
	elseIf a_menuName == self.MAP_MENU
		if self.CheckMenuVersion("map.swf", a_menuName, "_global.Map.MapMenu")
			self.UnregisterForMenu(a_menuName)
		endIf
	elseIf a_menuName == self.FAVORITES_MENU
		if self.CheckMenuVersion("favoritesmenu.swf", a_menuName, "_global.FavoritesMenu")
			self.UnregisterForMenu(a_menuName)
		endIf
	elseIf a_menuName == self.CRAFTING_MENU
		if self.CheckMenuVersion("craftingmenu.swf", a_menuName, "_global.CraftingMenu")
			self.UnregisterForMenu(a_menuName)
		endIf
	endIf
endFunction

Bool function CheckMenuVersion(String a_swfName, String a_menu, String a_class)

	Int releaseIdx = ui.GetInt(a_menu, a_class + ".SKYUI_RELEASE_IDX")
	String version = ui.GetString(a_menu, a_class + ".SKYUI_VERSION_STRING")
	if !ui.IsMenuOpen(a_menu)
		return false
	endIf
	if releaseIdx == 0
		self.Error(self.ERR_SWF_INVALID, "Incompatible menu file (" + a_swfName + ").\nPlease make sure you installed everything correctly and no other mod has overwritten this file.\n" + "If you were using an older SkyUI version, un-install it and re-install the latest version.")
	elseIf releaseIdx != self.ReqSWFRelease
		self.Error(self.ERR_SWF_VERSION, "Menu file version mismatch for " + a_swfName + ".\n" + "Required version: " + self.ReqSWFVersion + "\n" + "Detected version: " + version)
	endIf
	return true
endFunction

function OnGameReload()

	ErrorDetected = false
	if skse.GetVersionRelease() == 0
		self.Error(self.ERR_SKSE_MISSING, "The Skyrim Script Extender (SKSE64) is not running.\nSkyUI will not work correctly!\n\n" + "This message may also appear if a new Skyrim Patch has been released. In this case, wait until SKSE64 has been updated, then install the new version.")
		return 
	elseIf self.GetType() == 0
		self.Error(self.ERR_SKSE_BROKEN, "The SKSE64 scripts have been overwritten or are not properly loaded.\nReinstalling SKSE64 might fix this.")
		return 
	elseIf skse.GetVersionRelease() < self.MinSKSERelease
		self.Error(self.ERR_SKSE_VERSION_RT, "SKSE64 is outdated.\nSkyUI will not work correctly!\n" + "Required version: " + self.MinSKSEVersion + " or newer\n" + "Detected version: " + skse.GetVersion() as String + "." + skse.GetVersionMinor() as String + "." + skse.GetVersionBeta() as String)
		return 
	elseIf skse.GetScriptVersionRelease() < self.MinSKSERelease
		self.Error(self.ERR_SKSE_VERSION_SCPT, "SKSE64 scripts are outdated.\nYou probably forgot to install/update them with the rest of SKSE64.\nSkyUI will not work correctly!")
		return 
	endIf
	if utility.GetINIInt("iMinMemoryPageSize:Papyrus") <= 0 || utility.GetINIInt("iMaxMemoryPageSize:Papyrus") <= 0 || utility.GetINIInt("iMaxAllocatedMemoryBytes:Papyrus") <= 0
		self.Error(self.ERR_INI_PAPYRUS, "Your Papyrus INI settings are invalid. Please fix this, otherwise SkyUI will stop working at some point.")
		return 
	endIf
	if self.InventoryMenuCheckEnabled
		self.RegisterForMenu(self.INVENTORY_MENU)
	endIf
	if self.MagicMenuCheckEnabled
		self.RegisterForMenu(self.MAGIC_MENU)
	endIf
	if self.ContainerMenuCheckEnabled
		self.RegisterForMenu(self.CONTAINER_MENU)
	endIf
	if self.BarterMenuCheckEnabled
		self.RegisterForMenu(self.BARTER_MENU)
	endIf
	if self.GiftMenuCheckEnabled
		self.RegisterForMenu(self.GIFT_MENU)
	endIf
	if self.MapMenuCheckEnabled
		self.RegisterForMenu(self.MAP_MENU)
	endIf
	if self.FavoritesMenuCheckEnabled
		self.RegisterForMenu(self.FAVORITES_MENU)
	endIf
	if self.CraftingMenuCheckEnabled
		self.RegisterForMenu(self.CRAFTING_MENU)
	endIf
	self.RegisterForMenu(self.JOURNAL_MENU)
endFunction

function OnInit()

	self.OnGameReload()
endFunction

Bool function CheckItemMenuComponents(String a_menu)

	return self.CheckMenuVersion("skyui/itemcard.swf", a_menu, "_global.ItemCard") && self.CheckMenuVersion("skyui/bottombar.swf", a_menu, "_global.BottomBar") && self.CheckMenuVersion("skyui/inventorylists.swf", a_menu, "_global.InventoryLists")
endFunction

; Skipped compiler generated GotoState
