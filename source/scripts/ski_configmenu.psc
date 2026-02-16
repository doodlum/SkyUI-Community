scriptName ski_configmenu extends SKI_ConfigBase

;-- Properties --------------------------------------
ski_favoritesmanager property SKI_FavoritesManagerInstance auto
ski_activeeffectswidget property SKI_ActiveEffectsWidgetInstance auto
ski_main property SKI_MainInstance auto
ski_settingsmanager property SKI_SettingsManagerInstance auto

;-- Variables ---------------------------------------
Int _itemlistFontSizeIdx = 1
Float _fMagic3DItemPosScaleWide
Float _effectWidgetYOffset = 0.000000
Int _3DItemFlags
Float _fInventory3DItemPosX
String[] _categoryIconThemeValues
Int _nextColumnButton = 275
Bool _3DItemDisablePositioning = false
Int _favCurGroupIdx = 0
Float[] _vertAlignmentBaseOffsets
Float[] _alignmentBaseOffsets
Int _effectWidgetVAnchorIdx = 0
Float _itemcardXOffset = 0.000000
Int _switchTabKey = 56
Float _fMagic3DItemPosZWide
Int _effectWidgetOrientationIdx = 1
String[] _vertAlignmentValues
String[] _categoryIconThemeShortNames
String[] _alignments
Int _effectWidgetFlags
Float _fInventory3DItemPosZ
String[] _orientations
Bool _itemlistNoIconColors = false
Float _itemXBaseW
Float _3DItemScale = 1.50000
Float _fMagic3DItemPosX
Float _fInventory3DItemPosScaleWide
String[] _vertAlignments
Int _effectWidgetIconSizeIdx = 1
Float _fMagic3DItemPosZ
String[] _categoryIconThemeLongNames
Int _searchKey = 57
Float _fInventory3DItemPosZWide
Int _itemcardAlignIdx = 2
String[] _orientationValues
String[] _alignmentValues
Float _fMagic3DItemPosScale
Float _3DItemYOffset = 0.000000
Float _fInventory3DItemPosXWide
Float _fMagic3DItemPosXWide
Float _itemXBase
Int _effectWidgetHAnchorIdx = 1
Float[] _effectWidgetIconSizeValues
Int _prevColumnButton = 274
Int _equipModeKey = 42
Float _effectWidgetXOffset = 0.000000
Int _sortOrderButton = 272
Int _switchTabButton = 271
Int _effectWidgetGroupCount = 8
String[] _favGroupNames
Float _3DItemXOffset = 0.000000
Float _fInventory3DItemPosScale
Float _itemcardYOffset = 0.000000
Int _categoryIconThemeIdx = 0
Int _itemlistQuantityMinCount = 6
String[] _sizes

;-- Functions ---------------------------------------

function Apply3DItemScale()

	if _3DItemDisablePositioning
		utility.SetINIFloat("fInventory3DItemPosScaleWide:Interface", _fInventory3DItemPosScaleWide)
		utility.SetINIFloat("fMagic3DItemPosScaleWide:Interface", _fMagic3DItemPosScaleWide)
		utility.SetINIFloat("fInventory3DItemPosScale:Interface", _fInventory3DItemPosScale)
		utility.SetINIFloat("fMagic3DItemPosScale:Interface", _fMagic3DItemPosScale)
	else
		utility.SetINIFloat("fInventory3DItemPosScaleWide:Interface", _3DItemScale)
		utility.SetINIFloat("fMagic3DItemPosScaleWide:Interface", _3DItemScale)
		utility.SetINIFloat("fInventory3DItemPosScale:Interface", _3DItemScale)
		utility.SetINIFloat("fMagic3DItemPosScale:Interface", _3DItemScale)
	endIf
endFunction

function RefreshFavoriteHotkeys()

	self.SetKeyMapOptionValueST(SKI_FavoritesManagerInstance.GroupAddKey, true, "FAV_GROUP_ADD_KEY")
	self.SetKeyMapOptionValueST(SKI_FavoritesManagerInstance.GroupUseKey, true, "FAV_GROUP_USE_KEY")
	self.SetKeyMapOptionValueST(SKI_FavoritesManagerInstance.SetIconKey, true, "FAV_SET_ICON_KEY")
	self.SetKeyMapOptionValueST(SKI_FavoritesManagerInstance.ToggleFocusKey, true, "FAV_TOGGLE_FOCUS")
	self.SetKeyMapOptionValueST(SKI_FavoritesManagerInstance.SaveEquipStateKey, false, "FAV_EQUIP_STATE_KEY")
endFunction

function ApplySettings()

	_fInventory3DItemPosXWide = utility.GetINIFloat("fInventory3DItemPosXWide:Interface")
	_fInventory3DItemPosX = utility.GetINIFloat("fInventory3DItemPosX:Interface")
	_fMagic3DItemPosXWide = utility.GetINIFloat("fMagic3DItemPosXWide:Interface")
	_fMagic3DItemPosX = utility.GetINIFloat("fMagic3DItemPosX:Interface")
	_fInventory3DItemPosZWide = utility.GetINIFloat("fInventory3DItemPosZWide:Interface")
	_fInventory3DItemPosZ = utility.GetINIFloat("fInventory3DItemPosZ:Interface")
	_fMagic3DItemPosZWide = utility.GetINIFloat("fMagic3DItemPosZWide:Interface")
	_fMagic3DItemPosZ = utility.GetINIFloat("fMagic3DItemPosZ:Interface")
	_fInventory3DItemPosScaleWide = utility.GetINIFloat("fInventory3DItemPosScaleWide:Interface")
	_fMagic3DItemPosScaleWide = utility.GetINIFloat("fMagic3DItemPosScaleWide:Interface")
	_fInventory3DItemPosScale = utility.GetINIFloat("fInventory3DItemPosScale:Interface")
	_fMagic3DItemPosScale = utility.GetINIFloat("fMagic3DItemPosScale:Interface")
	Float h = utility.GetINIInt("iSize H:Display") as Float
	Float w = utility.GetINIInt("iSize W:Display") as Float
	Float ar = w / h
	if ar == 1.60000
		_itemXBaseW = -39.0583
	else
		_itemXBaseW = -35.7225
	endIf
	if ar == 1.25000
		_itemXBase = -48.2225
	else
		_itemXBase = -45.7225
	endIf
	self.Apply3DItemXOffset()
	self.Apply3DItemYOffset()
	self.Apply3DItemScale()
endFunction

; Skipped compiler generated GetState

function SetCurrentFavoriteGroup(Int a_index)

	Int ARMOR_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_ARMOR
	Int HANDS_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_HANDS
	self.SetToggleOptionValueST(SKI_FavoritesManagerInstance.GetGroupFlag(_favCurGroupIdx, ARMOR_FLAG), true, "FAV_GROUP_UNEQUIP_ARMOR")
	self.SetToggleOptionValueST(SKI_FavoritesManagerInstance.GetGroupFlag(_favCurGroupIdx, HANDS_FLAG), true, "FAV_GROUP_UNEQUIP_HANDS")
endFunction

function OnPageReset(String a_page)

	if a_page == ""
		self.LoadCustomContent("skyui/skyui_splash.swf", 0.000000, 0.000000)
		return 
	else
		self.UnloadCustomContent()
	endIf
	if a_page == "$General"
		self.SetCursorFillMode(self.TOP_TO_BOTTOM)
		self.AddHeaderOption("$Item List", 0)
		self.AddTextOptionST("ITEMLIST_FONT_SIZE", "$Font Size", _sizes[_itemlistFontSizeIdx], 0)
		self.AddSliderOptionST("ITEMLIST_QUANTITY_MIN_COUNT", "$Quantity Menu Min. Count", _itemlistQuantityMinCount as Float, "{0}", 0)
		self.AddMenuOptionST("ITEMLIST_CATEGORY_ICON_THEME", "$Category Icon Theme", _categoryIconThemeShortNames[_categoryIconThemeIdx], 0)
		self.AddToggleOptionST("ITEMLIST_NO_ICON_COLORS", "$Disable Icon Colors", _itemlistNoIconColors, 0)
		self.AddEmptyOption()
		self.AddHeaderOption("$Active Effects HUD", 0)
		self.AddToggleOptionST("EFFECT_WIDGET_ENABLED", "$Enabled", SKI_ActiveEffectsWidgetInstance.Enabled, 0)
		self.AddTextOptionST("EFFECT_WIDGET_ICON_SIZE", "$Icon Size", _sizes[_effectWidgetIconSizeIdx], _effectWidgetFlags)
		self.AddSliderOptionST("EFFECT_WIDGET_MIN_TIME_LEFT", "$Minimum Time Left", SKI_ActiveEffectsWidgetInstance.MinimumTimeLeft as Float, "{0} s", _effectWidgetFlags)
		self.SetCursorPosition(1)
		self.AddHeaderOption("$Favorites Menu", 0)
		self.AddToggleOptionST("FAV_MENU_HELP_ENABLED", "$Show Button Help", SKI_FavoritesManagerInstance.ButtonHelpEnabled, 0)
		self.AddEmptyOption()
		Int ARMOR_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_ARMOR
		Int HANDS_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_HANDS
		self.AddHeaderOption("$Favorite Groups", 0)
		self.AddMenuOptionST("FAV_GROUP_SELECT", "", "$Group {" + (_favCurGroupIdx + 1) as String + "}", 0)
		self.AddToggleOptionST("FAV_GROUP_UNEQUIP_ARMOR", "$Unequip Armor", SKI_FavoritesManagerInstance.GetGroupFlag(_favCurGroupIdx, ARMOR_FLAG), 0)
		self.AddToggleOptionST("FAV_GROUP_UNEQUIP_HANDS", "$Unequip Hands", SKI_FavoritesManagerInstance.GetGroupFlag(_favCurGroupIdx, HANDS_FLAG), 0)
	elseIf a_page == "$Controls"
		Bool isGamepad = game.UsingGamepad()
		self.SetCursorFillMode(self.TOP_TO_BOTTOM)
		self.AddHeaderOption("$Item List", 0)
		if !isGamepad
			self.AddKeyMapOptionST("SEARCH_KEY", "$Search", _searchKey, 0)
			self.AddKeyMapOptionST("SWITCH_TAB_KEY", "$Switch Tab", _switchTabKey, 0)
			self.AddKeyMapOptionST("EQUIP_MODE_KEY", "$Equip Mode", _equipModeKey, 0)
		else
			self.AddKeyMapOptionST("SEARCH_KEY", "$Search", _searchKey, self.OPTION_FLAG_DISABLED)
			self.AddKeyMapOptionST("SWITCH_TAB_BUTTON", "$Switch Tab", _switchTabButton, 0)
			self.AddKeyMapOptionST("PREV_COLUMN_BUTTON", "$Previous Column", _prevColumnButton, 0)
			self.AddKeyMapOptionST("NEXT_COLUMN_BUTTON", "$Next Column", _nextColumnButton, 0)
			self.AddKeyMapOptionST("SORT_ORDER_BUTTON", "$Order", _sortOrderButton, 0)
		endIf
		if !isGamepad
			self.AddEmptyOption()
			self.AddHeaderOption("$Favorites Menu", 0)
			self.AddKeyMapOptionST("FAV_GROUP_ADD_KEY", "{$Group}/{$Ungroup}", SKI_FavoritesManagerInstance.GroupAddKey, 0)
			self.AddKeyMapOptionST("FAV_GROUP_USE_KEY", "$Group Use", SKI_FavoritesManagerInstance.GroupUseKey, 0)
			self.AddKeyMapOptionST("FAV_SET_ICON_KEY", "$Set Group Icon", SKI_FavoritesManagerInstance.SetIconKey, 0)
			self.AddKeyMapOptionST("FAV_EQUIP_STATE_KEY", "$Save Equip State", SKI_FavoritesManagerInstance.SaveEquipStateKey, 0)
			self.AddKeyMapOptionST("FAV_TOGGLE_FOCUS", "$Toggle Focus", SKI_FavoritesManagerInstance.ToggleFocusKey, 0)
		endIf
		self.SetCursorPosition(1)
		Int[] groupHotkeys = SKI_FavoritesManagerInstance.GetGroupHotkeys()
		self.AddHeaderOption("$Favorite Groups", 0)
		self.AddKeyMapOptionST("FAV_GROUP_USE_HOTKEY1", "$Group {1}", groupHotkeys[0], self.OPTION_FLAG_WITH_UNMAP)
		self.AddKeyMapOptionST("FAV_GROUP_USE_HOTKEY2", "$Group {2}", groupHotkeys[1], self.OPTION_FLAG_WITH_UNMAP)
		self.AddKeyMapOptionST("FAV_GROUP_USE_HOTKEY3", "$Group {3}", groupHotkeys[2], self.OPTION_FLAG_WITH_UNMAP)
		self.AddKeyMapOptionST("FAV_GROUP_USE_HOTKEY4", "$Group {4}", groupHotkeys[3], self.OPTION_FLAG_WITH_UNMAP)
		self.AddKeyMapOptionST("FAV_GROUP_USE_HOTKEY5", "$Group {5}", groupHotkeys[4], self.OPTION_FLAG_WITH_UNMAP)
		self.AddKeyMapOptionST("FAV_GROUP_USE_HOTKEY6", "$Group {6}", groupHotkeys[5], self.OPTION_FLAG_WITH_UNMAP)
		self.AddKeyMapOptionST("FAV_GROUP_USE_HOTKEY7", "$Group {7}", groupHotkeys[6], self.OPTION_FLAG_WITH_UNMAP)
		self.AddKeyMapOptionST("FAV_GROUP_USE_HOTKEY8", "$Group {8}", groupHotkeys[7], self.OPTION_FLAG_WITH_UNMAP)
	elseIf a_page == "$Advanced"
		self.SetCursorFillMode(self.TOP_TO_BOTTOM)
		self.AddHeaderOption("$3D Item", 0)
		self.AddSliderOptionST("XD_ITEM_XOFFSET", "$Horizontal Offset", _3DItemXOffset, "{0}", _3DItemFlags)
		self.AddSliderOptionST("XD_ITEM_YOFFSET", "$Vertical Offset", _3DItemYOffset, "{0}", _3DItemFlags)
		self.AddSliderOptionST("XD_ITEM_SCALE", "$Scale", _3DItemScale, "{1}", _3DItemFlags)
		self.AddToggleOptionST("XD_ITEM_POSITIONING", "$Disable Positioning", _3DItemDisablePositioning, 0)
		self.AddEmptyOption()
		self.AddHeaderOption("$Active Effects HUD", 0)
		self.AddTextOptionST("EFFECT_WIDGET_ORIENTATION", "$Orientation", _orientations[_effectWidgetOrientationIdx], _effectWidgetFlags)
		self.AddTextOptionST("EFFECT_WIDGET_HORIZONTAL_ANCHOR", "$Horizontal Anchor", _alignments[_effectWidgetHAnchorIdx], _effectWidgetFlags)
		self.AddTextOptionST("EFFECT_WIDGET_VERTICAL_ANCHOR", "$Vertical Anchor", _vertAlignments[_effectWidgetVAnchorIdx], _effectWidgetFlags)
		self.AddSliderOptionST("EFFECT_WIDGET_GROUP_COUNT", "$Icon Group Count", SKI_ActiveEffectsWidgetInstance.GroupEffectCount as Float, "{0}", _effectWidgetFlags)
		self.AddSliderOptionST("EFFECT_WIDGET_XOFFSET", "$Horizontal Offset", _effectWidgetXOffset, "{0}", _effectWidgetFlags)
		self.AddSliderOptionST("EFFECT_WIDGET_YOFFSET", "$Vertical Offset", _effectWidgetYOffset, "{0}", _effectWidgetFlags)
		self.SetCursorPosition(1)
		self.AddHeaderOption("$Item Card", 0)
		self.AddTextOptionST("ITEMCARD_ALIGN", "$Align", _alignments[_itemcardAlignIdx], 0)
		self.AddSliderOptionST("ITEMCARD_XOFFSET", "$Horizontal Offset", _itemcardXOffset, "{0}", 0)
		self.AddSliderOptionST("ITEMCARD_YOFFSET", "$Vertical Offset", _itemcardYOffset, "{0}", 0)
		self.AddEmptyOption()
		self.AddHeaderOption("$SWF Version Checking", 0)
		self.AddToggleOptionST("CHECK_MAP_MENU", "Map Menu", SKI_MainInstance.MapMenuCheckEnabled, 0)
		self.AddToggleOptionST("CHECK_FAVORITES_MENU", "Favorites Menu", SKI_MainInstance.FavoritesMenuCheckEnabled, 0)
		self.AddToggleOptionST("CHECK_INVENTORY_MENU", "Inventory Menu", SKI_MainInstance.InventoryMenuCheckEnabled, 0)
		self.AddToggleOptionST("CHECK_MAGIC_MENU", "Magic Menu", SKI_MainInstance.MagicMenuCheckEnabled, 0)
		self.AddToggleOptionST("CHECK_BARTER_MENU", "Barter Menu", SKI_MainInstance.BarterMenuCheckEnabled, 0)
		self.AddToggleOptionST("CHECK_CONTAINER_MENU", "Container Menu", SKI_MainInstance.ContainerMenuCheckEnabled, 0)
		self.AddToggleOptionST("CHECK_CRAFTING_MENU", "Crafting Menu", SKI_MainInstance.CraftingMenuCheckEnabled, 0)
		self.AddToggleOptionST("CHECK_GIFT_MENU", "Gift Menu", SKI_MainInstance.GiftMenuCheckEnabled, 0)
	endIf
endFunction

Int function GetVersion()

	return 9
endFunction

function Apply3DItemYOffset()

	if _3DItemDisablePositioning
		utility.SetINIFloat("fInventory3DItemPosZWide:Interface", _fInventory3DItemPosZWide)
		utility.SetINIFloat("fInventory3DItemPosZ:Interface", _fInventory3DItemPosZ)
		utility.SetINIFloat("fMagic3DItemPosZWide:Interface", _fMagic3DItemPosZWide)
		utility.SetINIFloat("fMagic3DItemPosZ:Interface", _fMagic3DItemPosZ)
	else
		utility.SetINIFloat("fInventory3DItemPosZWide:Interface", 12 as Float + _3DItemYOffset)
		utility.SetINIFloat("fInventory3DItemPosZ:Interface", 16 as Float + _3DItemYOffset)
		utility.SetINIFloat("fMagic3DItemPosZWide:Interface", 12 as Float + _3DItemYOffset)
		utility.SetINIFloat("fMagic3DItemPosZ:Interface", 16 as Float + _3DItemYOffset)
	endIf
endFunction

function OnConfigInit()

	_alignments = new String[3]
	_alignments[0] = "$Left"
	_alignments[1] = "$Right"
	_alignments[2] = "$Center"
	_sizes = new String[3]
	_sizes[0] = "$Small"
	_sizes[1] = "$Medium"
	_sizes[2] = "$Large"
	_alignmentValues = new String[3]
	_alignmentValues[0] = "left"
	_alignmentValues[1] = "right"
	_alignmentValues[2] = "center"
	self.ApplySettings()
endFunction

function Apply3DItemXOffset()

	if _3DItemDisablePositioning
		utility.SetINIFloat("fInventory3DItemPosXWide:Interface", _fInventory3DItemPosXWide)
		utility.SetINIFloat("fInventory3DItemPosX:Interface", _fInventory3DItemPosX)
		utility.SetINIFloat("fMagic3DItemPosXWide:Interface", _fMagic3DItemPosXWide)
		utility.SetINIFloat("fMagic3DItemPosX:Interface", _fMagic3DItemPosX)
	else
		utility.SetINIFloat("fInventory3DItemPosXWide:Interface", _itemXBaseW + _3DItemXOffset)
		utility.SetINIFloat("fInventory3DItemPosX:Interface", _itemXBase + _3DItemXOffset)
		utility.SetINIFloat("fMagic3DItemPosXWide:Interface", _itemXBaseW + _3DItemXOffset)
		utility.SetINIFloat("fMagic3DItemPosX:Interface", _itemXBase + _3DItemXOffset)
	endIf
endFunction

; Skipped compiler generated GotoState

function ApplyItemListFontSize()

	if _itemlistFontSizeIdx == 0
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$label$textFormat$size", "12")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$entry$textFormat$size", "13")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$n_iconSize$value", "16")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$a_textBorder$value", "<0, 0, 0.3, 0>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$indent", "-25")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$border", "<0, 10, 2, 2>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$iconColumn$border", "<0, 3, 2, 2>")
	elseIf _itemlistFontSizeIdx == 1
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$label$textFormat$size", "12")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$entry$textFormat$size", "14")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$n_iconSize$value", "18")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$a_textBorder$value", "<0, 0, 1.1, 0>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$indent", "-28")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$border", "<0, 10, 3, 3>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$iconColumn$border", "<0, 3, 3, 3>")
	else
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$label$textFormat$size", "14")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$defaults$entry$textFormat$size", "18")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$n_iconSize$value", "20")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$vars$a_textBorder$value", "<0, 0, 0.4, 0>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$indent", "-30")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$equipColumn$border", "<0, 10, 3.2, 3.2>")
		SKI_SettingsManagerInstance.SetOverride("ListLayout$columns$iconColumn$border", "<0, 4, 3.2, 3.2>")
	endIf
endFunction

function SetFavoritesGroupHotkey(Int a_groupIndex, Int a_keyCode, String a_conflictControl, String a_conflictName)

	Bool continue = true
	if a_conflictControl != "" && a_conflictName != ModName
		String msg
		if a_conflictName != ""
			msg = "$SKI_MSG2{" + a_conflictControl + " (" + a_conflictName + ")}"
		else
			msg = "$SKI_MSG2{" + a_conflictControl + "}"
		endIf
		continue = self.ShowMessage(msg, true, "$Yes", "$No")
	endIf
	if !continue
		return 
	endIf
	if !SKI_FavoritesManagerInstance.SetGroupHotkey(a_groupIndex, a_keyCode)
		return 
	endIf
	Int[] groupHotkeys = SKI_FavoritesManagerInstance.GetGroupHotkeys()
	self.SetKeyMapOptionValueST(groupHotkeys[0], true, "FAV_GROUP_USE_HOTKEY1")
	self.SetKeyMapOptionValueST(groupHotkeys[1], true, "FAV_GROUP_USE_HOTKEY2")
	self.SetKeyMapOptionValueST(groupHotkeys[2], true, "FAV_GROUP_USE_HOTKEY3")
	self.SetKeyMapOptionValueST(groupHotkeys[3], true, "FAV_GROUP_USE_HOTKEY4")
	self.SetKeyMapOptionValueST(groupHotkeys[4], true, "FAV_GROUP_USE_HOTKEY5")
	self.SetKeyMapOptionValueST(groupHotkeys[5], true, "FAV_GROUP_USE_HOTKEY6")
	self.SetKeyMapOptionValueST(groupHotkeys[6], true, "FAV_GROUP_USE_HOTKEY7")
	self.SetKeyMapOptionValueST(groupHotkeys[7], false, "FAV_GROUP_USE_HOTKEY8")
endFunction

function OnGameReload()

	parent.OnGameReload()
	self.ApplySettings()
endFunction

String function GetCustomControl(Int a_keyCode)

	Int[] groupHotkeys = SKI_FavoritesManagerInstance.GetGroupHotkeys()
	Int index = groupHotkeys.find(a_keyCode, 0)
	if index != -1
		return "Group " + (index + 1) as String
	endIf
	return ""
endFunction

function SwapItemListKey(Int a_newKey, Int a_curKey)

	if a_newKey == _searchKey
		_searchKey = a_curKey
		self.SetKeyMapOptionValueST(_searchKey, true, "SEARCH_KEY")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey as String)
	elseIf a_newKey == _switchTabKey
		_switchTabKey = a_curKey
		self.SetKeyMapOptionValueST(_switchTabKey, true, "SWITCH_TAB_KEY")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey as String)
	elseIf a_newKey == _equipModeKey
		_equipModeKey = a_curKey
		self.SetKeyMapOptionValueST(_equipModeKey, true, "EQUIP_MODE_KEY")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey as String)
	elseIf a_newKey == _switchTabButton
		_switchTabButton = a_curKey
		self.SetKeyMapOptionValueST(_switchTabButton, true, "SWITCH_TAB_BUTTON")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", _switchTabButton as String)
	elseIf a_newKey == _prevColumnButton
		_prevColumnButton = a_curKey
		self.SetKeyMapOptionValueST(_prevColumnButton, true, "PREV_COLUMN_BUTTON")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", _prevColumnButton as String)
	elseIf a_newKey == _nextColumnButton
		_nextColumnButton = a_curKey
		self.SetKeyMapOptionValueST(_nextColumnButton, true, "NEXT_COLUMN_BUTTON")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", _nextColumnButton as String)
	elseIf a_newKey == _sortOrderButton
		_sortOrderButton = a_curKey
		self.SetKeyMapOptionValueST(_sortOrderButton, true, "SORT_ORDER_BUTTON")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", _sortOrderButton as String)
	endIf
endFunction

Bool function ValidateKey(Int a_keyCode, Bool a_gamepad)

	if a_keyCode == 1
		return false
	endIf
	Bool isGamepad = game.UsingGamepad()
	if isGamepad != a_gamepad
		return false
	endIf
	if !isGamepad
		if a_keyCode > 255
			self.ShowMessage("$SKI_MSG1", false, "$OK", "$Cancel")
			return false
		endIf
	elseIf a_keyCode < 266
		return false
	endIf
	return true
endFunction

function OnVersionUpdate(Int a_version)

	if a_version >= 2 && CurrentVersion < 2
		debug.Trace(self as String + ": Updating to script version 2", 0)
		_categoryIconThemeShortNames = new String[4]
		_categoryIconThemeShortNames[0] = "SKYUI V3"
		_categoryIconThemeShortNames[1] = "CELTIC"
		_categoryIconThemeShortNames[2] = "CURVED"
		_categoryIconThemeShortNames[3] = "STRAIGHT"
		_categoryIconThemeLongNames = new String[4]
		_categoryIconThemeLongNames[0] = "SkyUI V3, by PsychoSteve"
		_categoryIconThemeLongNames[1] = "Celtic, by GreatClone"
		_categoryIconThemeLongNames[2] = "Curved, by T3T"
		_categoryIconThemeLongNames[3] = "Straight, by T3T"
		_categoryIconThemeValues = new String[4]
		_categoryIconThemeValues[0] = "skyui\\icons_category_psychosteve.swf"
		_categoryIconThemeValues[1] = "skyui\\icons_category_celtic.swf"
		_categoryIconThemeValues[2] = "skyui\\icons_category_curved.swf"
		_categoryIconThemeValues[3] = "skyui\\icons_category_straight.swf"
		SKI_SettingsManagerInstance.ClearOverride("Input$controls$search")
		SKI_SettingsManagerInstance.ClearOverride("Input$controls$switchTab")
		SKI_SettingsManagerInstance.ClearOverride("Input$controls$equipMode")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey as String)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey as String)
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey as String)
	endIf
	if a_version >= 3 && CurrentVersion < 3
		debug.Trace(self as String + ": Updating to script version 3", 0)
		_3DItemFlags = self.OPTION_FLAG_NONE
	endIf
	if a_version >= 4 && CurrentVersion < 4
		debug.Trace(self as String + ": Updating to script version 4", 0)
		_orientations = new String[2]
		_orientations[0] = "$Horizontal"
		_orientations[1] = "$Vertical"
		_orientationValues = new String[2]
		_orientationValues[0] = "horizontal"
		_orientationValues[1] = "vertical"
		_vertAlignments = new String[3]
		_vertAlignments[0] = "$Top"
		_vertAlignments[1] = "$Bottom"
		_vertAlignments[2] = "$Center"
		_vertAlignmentValues = new String[3]
		_vertAlignmentValues[0] = "top"
		_vertAlignmentValues[1] = "bottom"
		_vertAlignmentValues[2] = "center"
		_effectWidgetIconSizeValues = new Float[3]
		_effectWidgetIconSizeValues[0] = 32.0000
		_effectWidgetIconSizeValues[1] = 48.0000
		_effectWidgetIconSizeValues[2] = 64.0000
		_alignmentBaseOffsets = new Float[3]
		_alignmentBaseOffsets[0] = 0.000000
		_alignmentBaseOffsets[1] = 1280.00
		_alignmentBaseOffsets[2] = 640.000
		_vertAlignmentBaseOffsets = new Float[3]
		_vertAlignmentBaseOffsets[0] = 0.000000
		_vertAlignmentBaseOffsets[1] = 720.000
		_vertAlignmentBaseOffsets[2] = 360.000
		_effectWidgetFlags = self.OPTION_FLAG_NONE
		SKI_ActiveEffectsWidgetInstance.Enabled = true
		SKI_ActiveEffectsWidgetInstance.EffectSize = _effectWidgetIconSizeValues[_effectWidgetIconSizeIdx]
		SKI_ActiveEffectsWidgetInstance.HAnchor = _alignmentValues[_effectWidgetHAnchorIdx]
		SKI_ActiveEffectsWidgetInstance.VAnchor = _vertAlignmentValues[_effectWidgetVAnchorIdx]
		SKI_ActiveEffectsWidgetInstance.GroupEffectCount = _effectWidgetGroupCount
		SKI_ActiveEffectsWidgetInstance.Orientation = _orientationValues[_effectWidgetOrientationIdx]
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[_effectWidgetHAnchorIdx] + _effectWidgetXOffset
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[_effectWidgetVAnchorIdx] + _effectWidgetYOffset
	endIf
	if a_version >= 5 && CurrentVersion < 5
		debug.Trace(self as String + ": Updating to script version 5", 0)
	endIf
	if a_version >= 6 && CurrentVersion < 6
		debug.Trace(self as String + ": Updating to script version 6", 0)
		Pages = new String[3]
		Pages[0] = "$General"
		Pages[1] = "$Favorite Groups"
		Pages[2] = "$Advanced"
		_favGroupNames = new String[8]
		_favGroupNames[0] = "$Group {1}"
		_favGroupNames[1] = "$Group {2}"
		_favGroupNames[2] = "$Group {3}"
		_favGroupNames[3] = "$Group {4}"
		_favGroupNames[4] = "$Group {5}"
		_favGroupNames[5] = "$Group {6}"
		_favGroupNames[6] = "$Group {7}"
		_favGroupNames[7] = "$Group {8}"
	endIf
	if a_version >= 7 && CurrentVersion < 7
		debug.Trace(self as String + ": Updating to script version 7", 0)
		Pages = new String[3]
		Pages[0] = "$General"
		Pages[1] = "$Controls"
		Pages[2] = "$Advanced"
	endIf
	if a_version >= 8 && CurrentVersion < 8
		debug.Trace(self as String + ": Updating to script version 8", 0)
		_categoryIconThemeShortNames = new String[1]
		_categoryIconThemeShortNames[0] = "SKYUI V5"
		_categoryIconThemeLongNames = new String[1]
		_categoryIconThemeLongNames[0] = "SkyUI V5, by PsychoSteve"
		_categoryIconThemeValues = new String[1]
		_categoryIconThemeValues[0] = "skyui\\icons_category_psychosteve.swf"
		_categoryIconThemeIdx = 0
		SKI_SettingsManagerInstance.ClearOverride("Appearance$icons$category$source")
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$category$source", _categoryIconThemeValues[_categoryIconThemeIdx])
	endIf
	if a_version >= 9 && CurrentVersion < 9
		debug.Trace(self as String + ": Updating to script version 9", 0)
		_categoryIconThemeShortNames = new String[4]
		_categoryIconThemeShortNames[0] = "SKYUI V5"
		_categoryIconThemeShortNames[1] = "CELTIC"
		_categoryIconThemeShortNames[2] = "CURVED"
		_categoryIconThemeShortNames[3] = "STRAIGHT"
		_categoryIconThemeLongNames = new String[4]
		_categoryIconThemeLongNames[0] = "SkyUI V5, by PsychoSteve"
		_categoryIconThemeLongNames[1] = "Celtic, by GreatClone"
		_categoryIconThemeLongNames[2] = "Curved, by T3T"
		_categoryIconThemeLongNames[3] = "Straight, by T3T"
		_categoryIconThemeValues = new String[4]
		_categoryIconThemeValues[0] = "skyui\\icons_category_psychosteve.swf"
		_categoryIconThemeValues[1] = "skyui\\icons_category_celtic.swf"
		_categoryIconThemeValues[2] = "skyui\\icons_category_curved.swf"
		_categoryIconThemeValues[3] = "skyui\\icons_category_straight.swf"
	endIf
endFunction

;-- State -------------------------------------------
state FAV_GROUP_USE_HOTKEY5

	function OnDefaultST()

		self.SetFavoritesGroupHotkey(4, -1, "", "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{$Off}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		self.SetFavoritesGroupHotkey(4, a_keyCode, a_conflictControl, a_conflictName)
	endFunction
endState

;-- State -------------------------------------------
state CHECK_MAP_MENU

	function OnDefaultST()

		SKI_MainInstance.MapMenuCheckEnabled = true
		self.SetToggleOptionValueST(true, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO3{$On}")
	endFunction

	function OnSelectST()

		Bool newVal = !SKI_MainInstance.MapMenuCheckEnabled
		SKI_MainInstance.MapMenuCheckEnabled = newVal
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state EFFECT_WIDGET_ORIENTATION

	function OnDefaultST()

		_effectWidgetOrientationIdx = 1
		SKI_ActiveEffectsWidgetInstance.Orientation = _orientationValues[_effectWidgetOrientationIdx]
		self.SetTextOptionValueST(_orientations[_effectWidgetOrientationIdx], false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{" + _orientations[1] + "}")
	endFunction

	function OnSelectST()

		if _effectWidgetOrientationIdx < _orientations.length - 1
			_effectWidgetOrientationIdx += 1
		else
			_effectWidgetOrientationIdx = 0
		endIf
		SKI_ActiveEffectsWidgetInstance.Orientation = _orientationValues[_effectWidgetOrientationIdx]
		self.SetTextOptionValueST(_orientations[_effectWidgetOrientationIdx], false, "")
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_USE_HOTKEY6

	function OnDefaultST()

		self.SetFavoritesGroupHotkey(5, -1, "", "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{$Off}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		self.SetFavoritesGroupHotkey(5, a_keyCode, a_conflictControl, a_conflictName)
	endFunction
endState

;-- State -------------------------------------------
state ITEMCARD_XOFFSET

	function OnDefaultST()

		_itemcardXOffset = 0.000000
		self.SetSliderOptionValueST(_itemcardXOffset, "{0}", false, "")
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$xOffset", _itemcardXOffset as String)
	endFunction

	function OnSliderOpenST()

		self.SetSliderDialogStartValue(_itemcardXOffset)
		self.SetSliderDialogDefaultValue(0 as Float)
		self.SetSliderDialogRange(-1000 as Float, 1000 as Float)
		self.SetSliderDialogInterval(1 as Float)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{0}")
	endFunction

	function OnSliderAcceptST(Float a_value)

		_itemcardXOffset = a_value
		self.SetSliderOptionValueST(_itemcardXOffset, "{0}", false, "")
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$xOffset", _itemcardXOffset as String)
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_USE_HOTKEY8

	function OnDefaultST()

		self.SetFavoritesGroupHotkey(7, -1, "", "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{$Off}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		self.SetFavoritesGroupHotkey(7, a_keyCode, a_conflictControl, a_conflictName)
	endFunction
endState

;-- State -------------------------------------------
state CHECK_MAGIC_MENU

	function OnDefaultST()

		SKI_MainInstance.MagicMenuCheckEnabled = true
		self.SetToggleOptionValueST(true, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO3{$On}")
	endFunction

	function OnSelectST()

		Bool newVal = !SKI_MainInstance.MagicMenuCheckEnabled
		SKI_MainInstance.MagicMenuCheckEnabled = newVal
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_USE_KEY

	function OnDefaultST()

		SKI_FavoritesManagerInstance.GroupUseKey = 19
		self.RefreshFavoriteHotkeys()
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{R}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, false)
			return 
		endIf
		SKI_FavoritesManagerInstance.GroupUseKey = a_keyCode
		self.RefreshFavoriteHotkeys()
	endFunction
endState

;-- State -------------------------------------------
state EFFECT_WIDGET_MIN_TIME_LEFT

	function OnDefaultST()

		SKI_ActiveEffectsWidgetInstance.MinimumTimeLeft = 180
		self.SetSliderOptionValueST(180 as Float, "{0}", false, "")
	endFunction

	function OnSliderOpenST()

		self.SetSliderDialogStartValue(SKI_ActiveEffectsWidgetInstance.MinimumTimeLeft as Float)
		self.SetSliderDialogDefaultValue(180 as Float)
		self.SetSliderDialogRange(0 as Float, 600 as Float)
		self.SetSliderDialogInterval(10 as Float)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO5{180}")
	endFunction

	function OnSliderAcceptST(Float a_value)

		SKI_ActiveEffectsWidgetInstance.MinimumTimeLeft = a_value as Int
		self.SetSliderOptionValueST((a_value as Int) as Float, "{0} s", false, "")
	endFunction
endState

;-- State -------------------------------------------
state ITEMCARD_ALIGN

	function OnDefaultST()

		_itemcardAlignIdx = 2
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignmentValues[_itemcardAlignIdx])
		self.SetTextOptionValueST(_alignments[_itemcardAlignIdx], false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{" + _alignments[2] + "}")
	endFunction

	function OnSelectST()

		if _itemcardAlignIdx < _alignments.length - 1
			_itemcardAlignIdx += 1
		else
			_itemcardAlignIdx = 0
		endIf
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$align", _alignmentValues[_itemcardAlignIdx])
		self.SetTextOptionValueST(_alignments[_itemcardAlignIdx], false, "")
	endFunction
endState

;-- State -------------------------------------------
state ITEMLIST_NO_ICON_COLORS

	function OnDefaultST()

		_itemlistNoIconColors = false
		self.SetToggleOptionValueST(_itemlistNoIconColors, false, "")
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$item$noColor", _itemlistNoIconColors as String)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{$Off}")
	endFunction

	function OnSelectST()

		_itemlistNoIconColors = !_itemlistNoIconColors
		self.SetToggleOptionValueST(_itemlistNoIconColors, false, "")
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$item$noColor", _itemlistNoIconColors as String)
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_UNEQUIP_ARMOR

	function OnDefaultST()

		Int ARMOR_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_ARMOR
		SKI_FavoritesManagerInstance.SetGroupFlag(_favCurGroupIdx, ARMOR_FLAG, false)
		self.SetToggleOptionValueST(false, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO7{$Off}")
	endFunction

	function OnSelectST()

		Int ARMOR_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_ARMOR
		Bool newVal = !SKI_FavoritesManagerInstance.GetGroupFlag(_favCurGroupIdx, ARMOR_FLAG)
		SKI_FavoritesManagerInstance.SetGroupFlag(_favCurGroupIdx, ARMOR_FLAG, newVal)
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state SORT_ORDER_BUTTON

	function OnDefaultST()

		_sortOrderButton = 272
		self.SetKeyMapOptionValueST(_sortOrderButton, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", _sortOrderButton as String)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{LS}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, true)
			return 
		endIf
		self.SwapItemListKey(a_keyCode, _sortOrderButton)
		_sortOrderButton = a_keyCode
		self.SetKeyMapOptionValueST(_sortOrderButton, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$sortOrder", _sortOrderButton as String)
	endFunction
endState

;-- State -------------------------------------------
state CHECK_GIFT_MENU

	function OnDefaultST()

		SKI_MainInstance.GiftMenuCheckEnabled = true
		self.SetToggleOptionValueST(true, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO3{$On}")
	endFunction

	function OnSelectST()

		Bool newVal = !SKI_MainInstance.GiftMenuCheckEnabled
		SKI_MainInstance.GiftMenuCheckEnabled = newVal
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state FAV_SET_ICON_KEY

	function OnDefaultST()

		SKI_FavoritesManagerInstance.SetIconKey = 56
		self.RefreshFavoriteHotkeys()
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{LAlt}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, false)
			return 
		endIf
		SKI_FavoritesManagerInstance.SetIconKey = a_keyCode
		self.RefreshFavoriteHotkeys()
	endFunction
endState

;-- State -------------------------------------------
state EFFECT_WIDGET_ENABLED

	function OnDefaultST()

		SKI_ActiveEffectsWidgetInstance.Enabled = true
		_effectWidgetFlags = self.OPTION_FLAG_NONE
		self.SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_ICON_SIZE")
		self.SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_MIN_TIME_LEFT")
		self.SetToggleOptionValueST(true, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{$On}")
	endFunction

	function OnSelectST()

		Bool newVal = !SKI_ActiveEffectsWidgetInstance.Enabled
		SKI_ActiveEffectsWidgetInstance.Enabled = newVal
		if newVal
			_effectWidgetFlags = self.OPTION_FLAG_NONE
		else
			_effectWidgetFlags = self.OPTION_FLAG_DISABLED
		endIf
		self.SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_ICON_SIZE")
		self.SetOptionFlagsST(_effectWidgetFlags, true, "EFFECT_WIDGET_MIN_TIME_LEFT")
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_USE_HOTKEY3

	function OnDefaultST()

		self.SetFavoritesGroupHotkey(2, 61, "", "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{F3}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		self.SetFavoritesGroupHotkey(2, a_keyCode, a_conflictControl, a_conflictName)
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_SELECT

	function OnDefaultST()

		_favCurGroupIdx = 0
		self.SetCurrentFavoriteGroup(_favCurGroupIdx)
		self.SetTextOptionValueST((_favCurGroupIdx + 1) as String, false, "")
	endFunction

	function OnMenuAcceptST(Int a_index)

		_favCurGroupIdx = a_index
		self.SetCurrentFavoriteGroup(_favCurGroupIdx)
		self.SetMenuOptionValueST(_favGroupNames[_favCurGroupIdx], false, "")
	endFunction

	function OnMenuOpenST()

		self.SetMenuDialogStartIndex(_favCurGroupIdx)
		self.SetMenuDialogDefaultIndex(0)
		self.SetMenuDialogOptions(_favGroupNames)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO6")
	endFunction
endState

;-- State -------------------------------------------
state CHECK_CONTAINER_MENU

	function OnDefaultST()

		SKI_MainInstance.ContainerMenuCheckEnabled = true
		self.SetToggleOptionValueST(true, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO3{$On}")
	endFunction

	function OnSelectST()

		Bool newVal = !SKI_MainInstance.ContainerMenuCheckEnabled
		SKI_MainInstance.ContainerMenuCheckEnabled = newVal
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state EFFECT_WIDGET_XOFFSET

	function OnDefaultST()

		_effectWidgetXOffset = 0.000000
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[_effectWidgetHAnchorIdx] + _effectWidgetXOffset
		self.SetSliderOptionValueST(_effectWidgetXOffset, "{0}", false, "")
	endFunction

	function OnSliderOpenST()

		self.SetSliderDialogStartValue(_effectWidgetXOffset)
		self.SetSliderDialogDefaultValue(0 as Float)
		self.SetSliderDialogRange(-1280 as Float, 1280 as Float)
		self.SetSliderDialogInterval(1 as Float)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{0}")
	endFunction

	function OnSliderAcceptST(Float a_value)

		_effectWidgetXOffset = a_value
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[_effectWidgetHAnchorIdx] + _effectWidgetXOffset
		self.SetSliderOptionValueST(_effectWidgetXOffset, "{0}", false, "")
	endFunction
endState

;-- State -------------------------------------------
state SWITCH_TAB_KEY

	function OnDefaultST()

		_switchTabKey = 56
		self.SetKeyMapOptionValueST(_switchTabKey, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey as String)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{LAlt}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, false)
			return 
		endIf
		self.SwapItemListKey(a_keyCode, _switchTabKey)
		_switchTabKey = a_keyCode
		self.SetKeyMapOptionValueST(_switchTabKey, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$switchTab", _switchTabKey as String)
	endFunction
endState

;-- State -------------------------------------------
state CHECK_FAVORITES_MENU

	function OnDefaultST()

		SKI_MainInstance.FavoritesMenuCheckEnabled = true
		self.SetToggleOptionValueST(true, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO3{$On}")
	endFunction

	function OnSelectST()

		Bool newVal = !SKI_MainInstance.FavoritesMenuCheckEnabled
		SKI_MainInstance.FavoritesMenuCheckEnabled = newVal
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state EQUIP_MODE_KEY

	function OnDefaultST()

		_equipModeKey = 42
		self.SetKeyMapOptionValueST(_equipModeKey, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey as String)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{Shift}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, false)
			return 
		endIf
		self.SwapItemListKey(a_keyCode, _equipModeKey)
		_equipModeKey = a_keyCode
		self.SetKeyMapOptionValueST(_equipModeKey, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$equipMode", _equipModeKey as String)
	endFunction
endState

;-- State -------------------------------------------
state EFFECT_WIDGET_HORIZONTAL_ANCHOR

	function OnDefaultST()

		_effectWidgetVAnchorIdx = 1
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[_effectWidgetHAnchorIdx] + _effectWidgetXOffset
		self.SetTextOptionValueST(_alignments[_effectWidgetHAnchorIdx], false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{" + _alignments[1] + "}")
	endFunction

	function OnSelectST()

		if _effectWidgetHAnchorIdx < _alignments.length - 1
			_effectWidgetHAnchorIdx += 1
		else
			_effectWidgetHAnchorIdx = 0
		endIf
		SKI_ActiveEffectsWidgetInstance.HAnchor = _alignmentValues[_effectWidgetHAnchorIdx]
		SKI_ActiveEffectsWidgetInstance.X = _alignmentBaseOffsets[_effectWidgetHAnchorIdx] + _effectWidgetXOffset
		self.SetTextOptionValueST(_alignments[_effectWidgetHAnchorIdx], false, "")
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_ADD_KEY

	function OnDefaultST()

		SKI_FavoritesManagerInstance.GroupAddKey = 33
		self.RefreshFavoriteHotkeys()
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{F}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, false)
			return 
		endIf
		SKI_FavoritesManagerInstance.GroupAddKey = a_keyCode
		self.RefreshFavoriteHotkeys()
	endFunction
endState

;-- State -------------------------------------------
state FAV_TOGGLE_FOCUS

	function OnDefaultST()

		SKI_FavoritesManagerInstance.ToggleFocusKey = 57
		self.RefreshFavoriteHotkeys()
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{Space}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, false)
			return 
		endIf
		SKI_FavoritesManagerInstance.ToggleFocusKey = a_keyCode
		self.RefreshFavoriteHotkeys()
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_USE_HOTKEY1

	function OnDefaultST()

		self.SetFavoritesGroupHotkey(0, 59, "", "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{F1}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		self.SetFavoritesGroupHotkey(0, a_keyCode, a_conflictControl, a_conflictName)
	endFunction
endState

;-- State -------------------------------------------
state ITEMLIST_FONT_SIZE

	function OnDefaultST()

		_itemlistFontSizeIdx = 1
		self.SetTextOptionValueST(_sizes[_itemlistFontSizeIdx], false, "")
		self.ApplyItemListFontSize()
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{" + _sizes[1] + "}")
	endFunction

	function OnSelectST()

		if _itemlistFontSizeIdx < _sizes.length - 1
			_itemlistFontSizeIdx += 1
		else
			_itemlistFontSizeIdx = 0
		endIf
		self.SetTextOptionValueST(_sizes[_itemlistFontSizeIdx], false, "")
		self.ApplyItemListFontSize()
	endFunction
endState

;-- State -------------------------------------------
state PREV_COLUMN_BUTTON

	function OnDefaultST()

		_prevColumnButton = 274
		self.SetKeyMapOptionValueST(_prevColumnButton, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", _prevColumnButton as String)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{LB}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, true)
			return 
		endIf
		self.SwapItemListKey(a_keyCode, _prevColumnButton)
		_prevColumnButton = a_keyCode
		self.SetKeyMapOptionValueST(_prevColumnButton, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$prevColumn", _prevColumnButton as String)
	endFunction
endState

;-- State -------------------------------------------
state XD_ITEM_POSITIONING

	function OnDefaultST()

		_3DItemDisablePositioning = false
		_3DItemFlags = self.OPTION_FLAG_NONE
		self.SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_XOFFSET")
		self.SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_YOFFSET")
		self.SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_SCALE")
		self.SetToggleOptionValueST(false, false, "")
		self.Apply3DItemXOffset()
		self.Apply3DItemYOffset()
		self.Apply3DItemScale()
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO4{$Off}")
	endFunction

	function OnSelectST()

		Bool newVal = !_3DItemDisablePositioning
		_3DItemDisablePositioning = newVal
		if newVal
			_3DItemFlags = self.OPTION_FLAG_DISABLED
		else
			_3DItemFlags = self.OPTION_FLAG_NONE
		endIf
		self.SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_XOFFSET")
		self.SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_YOFFSET")
		self.SetOptionFlagsST(_3DItemFlags, true, "XD_ITEM_SCALE")
		self.SetToggleOptionValueST(newVal, false, "")
		self.Apply3DItemXOffset()
		self.Apply3DItemYOffset()
		self.Apply3DItemScale()
	endFunction
endState

;-- State -------------------------------------------
state ITEMLIST_CATEGORY_ICON_THEME

	function OnDefaultST()

		_categoryIconThemeIdx = 0
		self.SetTextOptionValueST(_categoryIconThemeShortNames[_categoryIconThemeIdx], false, "")
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$category$source", _categoryIconThemeValues[_categoryIconThemeIdx])
	endFunction

	function OnMenuAcceptST(Int a_index)

		_categoryIconThemeIdx = a_index
		self.SetMenuOptionValueST(_categoryIconThemeShortNames[_categoryIconThemeIdx], false, "")
		SKI_SettingsManagerInstance.SetOverride("Appearance$icons$category$source", _categoryIconThemeValues[_categoryIconThemeIdx])
	endFunction

	function OnMenuOpenST()

		self.SetMenuDialogStartIndex(_categoryIconThemeIdx)
		self.SetMenuDialogDefaultIndex(0)
		self.SetMenuDialogOptions(_categoryIconThemeLongNames)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{" + _categoryIconThemeShortNames[0] + "}")
	endFunction
endState

;-- State -------------------------------------------
state CHECK_BARTER_MENU

	function OnDefaultST()

		SKI_MainInstance.BarterMenuCheckEnabled = true
		self.SetToggleOptionValueST(true, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO3{$On}")
	endFunction

	function OnSelectST()

		Bool newVal = !SKI_MainInstance.BarterMenuCheckEnabled
		SKI_MainInstance.BarterMenuCheckEnabled = newVal
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state FAV_EQUIP_STATE_KEY

	function OnDefaultST()

		SKI_FavoritesManagerInstance.SaveEquipStateKey = 20
		self.RefreshFavoriteHotkeys()
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{T}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, false)
			return 
		endIf
		SKI_FavoritesManagerInstance.SaveEquipStateKey = a_keyCode
		self.RefreshFavoriteHotkeys()
	endFunction
endState

;-- State -------------------------------------------
state XD_ITEM_XOFFSET

	function OnDefaultST()

		_3DItemXOffset = 0.000000
		self.SetSliderOptionValueST(_3DItemXOffset, "{0}", false, "")
		self.Apply3DItemXOffset()
	endFunction

	function OnSliderOpenST()

		self.SetSliderDialogStartValue(_3DItemXOffset)
		self.SetSliderDialogDefaultValue(0 as Float)
		self.SetSliderDialogRange(-128 as Float, 128 as Float)
		self.SetSliderDialogInterval(1 as Float)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{0}")
	endFunction

	function OnSliderAcceptST(Float a_value)

		_3DItemXOffset = a_value
		self.SetSliderOptionValueST(_3DItemXOffset, "{0}", false, "")
		self.Apply3DItemXOffset()
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_UNEQUIP_HANDS

	function OnDefaultST()

		Int HANDS_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_ARMOR
		SKI_FavoritesManagerInstance.SetGroupFlag(_favCurGroupIdx, HANDS_FLAG, false)
		self.SetToggleOptionValueST(false, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO8{$Off}")
	endFunction

	function OnSelectST()

		Int HANDS_FLAG = SKI_FavoritesManagerInstance.GROUP_FLAG_UNEQUIP_HANDS
		Bool newVal = !SKI_FavoritesManagerInstance.GetGroupFlag(_favCurGroupIdx, HANDS_FLAG)
		SKI_FavoritesManagerInstance.SetGroupFlag(_favCurGroupIdx, HANDS_FLAG, newVal)
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state EFFECT_WIDGET_GROUP_COUNT

	function OnDefaultST()

		SKI_ActiveEffectsWidgetInstance.GroupEffectCount = 8
		self.SetSliderOptionValueST(8 as Float, "{0}", false, "")
	endFunction

	function OnSliderOpenST()

		self.SetSliderDialogStartValue(SKI_ActiveEffectsWidgetInstance.GroupEffectCount as Float)
		self.SetSliderDialogDefaultValue(8 as Float)
		self.SetSliderDialogRange(1 as Float, 16 as Float)
		self.SetSliderDialogInterval(1 as Float)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{8}")
	endFunction

	function OnSliderAcceptST(Float a_value)

		SKI_ActiveEffectsWidgetInstance.GroupEffectCount = a_value as Int
		self.SetSliderOptionValueST((a_value as Int) as Float, "{0}", false, "")
	endFunction
endState

;-- State -------------------------------------------
state CHECK_INVENTORY_MENU

	function OnDefaultST()

		SKI_MainInstance.InventoryMenuCheckEnabled = true
		self.SetToggleOptionValueST(true, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO3{$On}")
	endFunction

	function OnSelectST()

		Bool newVal = !SKI_MainInstance.InventoryMenuCheckEnabled
		SKI_MainInstance.InventoryMenuCheckEnabled = newVal
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state EFFECT_WIDGET_ICON_SIZE

	function OnDefaultST()

		_effectWidgetIconSizeIdx = 1
		SKI_ActiveEffectsWidgetInstance.EffectSize = _effectWidgetIconSizeValues[_effectWidgetIconSizeIdx]
		self.SetTextOptionValueST(_sizes[_effectWidgetIconSizeIdx], false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{" + _sizes[1] + "}")
	endFunction

	function OnSelectST()

		if _effectWidgetIconSizeIdx < _sizes.length - 1
			_effectWidgetIconSizeIdx += 1
		else
			_effectWidgetIconSizeIdx = 0
		endIf
		SKI_ActiveEffectsWidgetInstance.EffectSize = _effectWidgetIconSizeValues[_effectWidgetIconSizeIdx]
		self.SetTextOptionValueST(_sizes[_effectWidgetIconSizeIdx], false, "")
	endFunction
endState

;-- State -------------------------------------------
state XD_ITEM_SCALE

	function OnDefaultST()

		_3DItemScale = 1.50000
		self.SetSliderOptionValueST(_3DItemScale, "{1}", false, "")
		self.Apply3DItemScale()
	endFunction

	function OnSliderOpenST()

		self.SetSliderDialogStartValue(_3DItemScale)
		self.SetSliderDialogDefaultValue(1.50000)
		self.SetSliderDialogRange(0.500000, 5 as Float)
		self.SetSliderDialogInterval(0.100000)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{1.5}")
	endFunction

	function OnSliderAcceptST(Float a_value)

		_3DItemScale = a_value
		self.SetSliderOptionValueST(_3DItemScale, "{1}", false, "")
		self.Apply3DItemScale()
	endFunction
endState

;-- State -------------------------------------------
state NEXT_COLUMN_BUTTON

	function OnDefaultST()

		_nextColumnButton = 275
		self.SetKeyMapOptionValueST(_nextColumnButton, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", _nextColumnButton as String)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{RB}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, true)
			return 
		endIf
		self.SwapItemListKey(a_keyCode, _nextColumnButton)
		_nextColumnButton = a_keyCode
		self.SetKeyMapOptionValueST(_nextColumnButton, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$nextColumn", _nextColumnButton as String)
	endFunction
endState

;-- State -------------------------------------------
state ITEMCARD_YOFFSET

	function OnDefaultST()

		_itemcardYOffset = 0.000000
		self.SetSliderOptionValueST(_itemcardYOffset, "{0}", false, "")
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$yOffset", _itemcardYOffset as String)
	endFunction

	function OnSliderOpenST()

		self.SetSliderDialogStartValue(_itemcardYOffset)
		self.SetSliderDialogDefaultValue(0 as Float)
		self.SetSliderDialogRange(-1000 as Float, 1000 as Float)
		self.SetSliderDialogInterval(1 as Float)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{0}")
	endFunction

	function OnSliderAcceptST(Float a_value)

		_itemcardYOffset = a_value
		self.SetSliderOptionValueST(_itemcardYOffset, "{0}", false, "")
		SKI_SettingsManagerInstance.SetOverride("ItemInfo$itemcard$yOffset", _itemcardYOffset as String)
	endFunction
endState

;-- State -------------------------------------------
state SEARCH_KEY

	function OnDefaultST()

		_searchKey = 57
		self.SetKeyMapOptionValueST(_searchKey, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey as String)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{Space}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, false)
			return 
		endIf
		self.SwapItemListKey(a_keyCode, _searchKey)
		_searchKey = a_keyCode
		self.SetKeyMapOptionValueST(_searchKey, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$pc$search", _searchKey as String)
	endFunction
endState

;-- State -------------------------------------------
state FAV_MENU_HELP_ENABLED

	function OnDefaultST()

		SKI_FavoritesManagerInstance.ButtonHelpEnabled = true
		self.SetToggleOptionValueST(true, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{$On}")
	endFunction

	function OnSelectST()

		Bool newVal = !SKI_FavoritesManagerInstance.ButtonHelpEnabled
		SKI_FavoritesManagerInstance.ButtonHelpEnabled = newVal
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_USE_HOTKEY7

	function OnDefaultST()

		self.SetFavoritesGroupHotkey(6, -1, "", "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{$Off}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		self.SetFavoritesGroupHotkey(6, a_keyCode, a_conflictControl, a_conflictName)
	endFunction
endState

;-- State -------------------------------------------
state XD_ITEM_YOFFSET

	function OnDefaultST()

		_3DItemYOffset = 0.000000
		self.SetSliderOptionValueST(_3DItemYOffset, "{0}", false, "")
		self.Apply3DItemYOffset()
	endFunction

	function OnSliderOpenST()

		self.SetSliderDialogStartValue(_3DItemYOffset)
		self.SetSliderDialogDefaultValue(0 as Float)
		self.SetSliderDialogRange(-128 as Float, 128 as Float)
		self.SetSliderDialogInterval(1 as Float)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{0}")
	endFunction

	function OnSliderAcceptST(Float a_value)

		_3DItemYOffset = a_value
		self.SetSliderOptionValueST(_3DItemYOffset, "{0}", false, "")
		self.Apply3DItemYOffset()
	endFunction
endState

;-- State -------------------------------------------
state EFFECT_WIDGET_YOFFSET

	function OnDefaultST()

		_effectWidgetYOffset = 0.000000
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[_effectWidgetVAnchorIdx] + _effectWidgetYOffset
		self.SetSliderOptionValueST(_effectWidgetYOffset, "{0}", false, "")
	endFunction

	function OnSliderOpenST()

		self.SetSliderDialogStartValue(_effectWidgetYOffset)
		self.SetSliderDialogDefaultValue(0 as Float)
		self.SetSliderDialogRange(-720 as Float, 720 as Float)
		self.SetSliderDialogInterval(1 as Float)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{0}")
	endFunction

	function OnSliderAcceptST(Float a_value)

		_effectWidgetYOffset = a_value
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[_effectWidgetVAnchorIdx] + _effectWidgetYOffset
		self.SetSliderOptionValueST(_effectWidgetYOffset, "{0}", false, "")
	endFunction
endState

;-- State -------------------------------------------
state ITEMLIST_QUANTITY_MIN_COUNT

	function OnDefaultST()

		_itemlistQuantityMinCount = 6
		self.SetSliderOptionValueST(_itemlistQuantityMinCount as Float, "{0}", false, "")
		SKI_SettingsManagerInstance.SetOverride("ItemList$quantityMenu$minCount", _itemlistQuantityMinCount as String)
	endFunction

	function OnSliderOpenST()

		self.SetSliderDialogStartValue(_itemlistQuantityMinCount as Float)
		self.SetSliderDialogDefaultValue(6 as Float)
		self.SetSliderDialogRange(0 as Float, 100 as Float)
		self.SetSliderDialogInterval(1 as Float)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO2{6}")
	endFunction

	function OnSliderAcceptST(Float a_value)

		_itemlistQuantityMinCount = a_value as Int
		self.SetSliderOptionValueST(_itemlistQuantityMinCount as Float, "{0}", false, "")
		SKI_SettingsManagerInstance.SetOverride("ItemList$quantityMenu$minCount", _itemlistQuantityMinCount as String)
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_USE_HOTKEY2

	function OnDefaultST()

		self.SetFavoritesGroupHotkey(1, 60, "", "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{F2}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		self.SetFavoritesGroupHotkey(1, a_keyCode, a_conflictControl, a_conflictName)
	endFunction
endState

;-- State -------------------------------------------
state EFFECT_WIDGET_VERTICAL_ANCHOR

	function OnDefaultST()

		_effectWidgetVAnchorIdx = 0
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[_effectWidgetVAnchorIdx] + _effectWidgetYOffset
		self.SetTextOptionValueST(_vertAlignments[_effectWidgetVAnchorIdx], false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{" + _vertAlignments[0] + "}")
	endFunction

	function OnSelectST()

		if _effectWidgetVAnchorIdx < _vertAlignments.length - 1
			_effectWidgetVAnchorIdx += 1
		else
			_effectWidgetVAnchorIdx = 0
		endIf
		SKI_ActiveEffectsWidgetInstance.VAnchor = _vertAlignmentValues[_effectWidgetVAnchorIdx]
		SKI_ActiveEffectsWidgetInstance.Y = _vertAlignmentBaseOffsets[_effectWidgetVAnchorIdx] + _effectWidgetYOffset
		self.SetTextOptionValueST(_vertAlignments[_effectWidgetVAnchorIdx], false, "")
	endFunction
endState

;-- State -------------------------------------------
state SWITCH_TAB_BUTTON

	function OnDefaultST()

		_switchTabButton = 271
		self.SetKeyMapOptionValueST(_switchTabButton, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", _switchTabButton as String)
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{Back}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		if !self.ValidateKey(a_keyCode, true)
			return 
		endIf
		self.SwapItemListKey(a_keyCode, _switchTabButton)
		_switchTabButton = a_keyCode
		self.SetKeyMapOptionValueST(_switchTabButton, false, "")
		SKI_SettingsManagerInstance.SetOverride("Input$controls$gamepad$switchTab", _switchTabButton as String)
	endFunction
endState

;-- State -------------------------------------------
state FAV_GROUP_USE_HOTKEY4

	function OnDefaultST()

		self.SetFavoritesGroupHotkey(3, 62, "", "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO1{F4}")
	endFunction

	function OnKeyMapChangeST(Int a_keyCode, String a_conflictControl, String a_conflictName)

		self.SetFavoritesGroupHotkey(3, a_keyCode, a_conflictControl, a_conflictName)
	endFunction
endState

;-- State -------------------------------------------
state CHECK_CRAFTING_MENU

	function OnDefaultST()

		SKI_MainInstance.CraftingMenuCheckEnabled = true
		self.SetToggleOptionValueST(true, false, "")
	endFunction

	function OnHighlightST()

		self.SetInfoText("$SKI_INFO3{$On}")
	endFunction

	function OnSelectST()

		Bool newVal = !SKI_MainInstance.CraftingMenuCheckEnabled
		SKI_MainInstance.CraftingMenuCheckEnabled = newVal
		self.SetToggleOptionValueST(newVal, false, "")
	endFunction
endState
