scriptName SKI_FavoritesManager extends SKI_QuestBase

;-- Properties --------------------------------------
Int property GROUP_FLAG_UNEQUIP_HANDS
	Int function get()

		return 2
	endFunction
endproperty
actor property PlayerREF auto
Int property GROUP_FLAG_UNEQUIP_ARMOR
	Int function get()

		return 1
	endFunction
endproperty
Int property SetIconKey
	Int function get()

		return _setIconKey
	endFunction
	function set(Int a_val)

		self.SwapControlKey(a_val, _setIconKey)
		_setIconKey = a_val
	endFunction
endproperty
Int property SaveEquipStateKey
	Int function get()

		return _saveEquipStateKey
	endFunction
	function set(Int a_val)

		self.SwapControlKey(a_val, _saveEquipStateKey)
		_saveEquipStateKey = a_val
	endFunction
endproperty
String property MENU_ROOT
	String function get()

		return "_root.MenuHolder.Menu_mc"
	endFunction
endproperty
Int property ToggleFocusKey
	Int function get()

		return _toggleFocusKey
	endFunction
	function set(Int a_val)

		self.SwapControlKey(a_val, _toggleFocusKey)
		_toggleFocusKey = a_val
	endFunction
endproperty
Bool property ButtonHelpEnabled = true auto
Int property GroupAddKey
	Int function get()

		return _groupAddKey
	endFunction
	function set(Int a_val)

		self.SwapControlKey(a_val, _groupAddKey)
		_groupAddKey = a_val
	endFunction
endproperty
String property FAVORITES_MENU
	String function get()

		return "FavoritesMenu"
	endFunction
endproperty
Int property GroupUseKey
	Int function get()

		return _groupUseKey
	endFunction
	function set(Int a_val)

		self.SwapControlKey(a_val, _groupUseKey)
		_groupUseKey = a_val
	endFunction
endproperty

;-- Variables ---------------------------------------
Int[] _groupOffHandItemIds
Form[] _items2
Bool _usedVoice = false
EquipSlot _voiceSlot
Bool _silenceEquipSounds = false
Int _setIconKey = 56
Race _vampireLordRace
EquipSlot _rightHandSlot
Int[] _itemIds2
Bool[] _itemInvalidFlags2
EquipSlot _bothHandsSlot
SoundCategory _audioCategoryUI
Int _groupUseKey = 19
Bool _usedLeftHand = false
Int[] _itemIds1
EquipSlot _leftHandSlot
Int _groupAddKey = 33
Form[] _groupMainHandItems
Form[] _groupIconItems
Form[] _items1
Bool[] _itemInvalidFlags1
Form[] _groupOffHandItems
Int _toggleFocusKey = 57
Int[] _groupMainHandItemIds
Int[] _groupHotkeys
Int[] _groupIconItemIds
Bool _usedRightHand = false
Int _usedOutfitMask = 0
Int[] _groupFlags
Int _saveEquipStateKey = 20
EquipSlot _eitherHandSlot

;-- Functions ---------------------------------------

function OnFoundInvalidItem(String a_eventName, String a_strArg, Float a_numArg, form a_sender)

	self.InvalidateItem(a_strArg as Int, true)
endFunction

function OnSetGroupIcon(String a_eventName, String a_strArg, Float a_numArg, form a_sender)

	Int groupIndex = a_numArg as Int
	Int itemId = a_strArg as Int
	form item = a_sender
	_groupIconItems[groupIndex] = item
	_groupIconItemIds[groupIndex] = itemId
	self.UpdateMenuGroupData(groupIndex)
endFunction

function OnKeyDown(Int a_keyCode)

	self.GotoState("PROCESSING")
	Int groupIndex = _groupHotkeys.find(a_keyCode, 0)
	if groupIndex != -1 && !utility.IsInMenuMode()
		self.GroupUse(groupIndex)
	endIf
	self.GotoState("")
endFunction

function OnVersionUpdate(Int a_version)

	if a_version >= 2 && CurrentVersion < 2
		debug.Trace(self as String + ": Updating to script version 2", 0)
		_vampireLordRace = game.GetFormFromFile(10298, "Dawnguard.esm") as Race
	endIf
	if a_version >= 3 && CurrentVersion < 3
		debug.Trace(self as String + ": Updating to script version 3", 0)
		_itemInvalidFlags1 = new Bool[128]
		_itemInvalidFlags2 = new Bool[128]
	endIf
endFunction

Bool function IsFormInGroup(Int a_groupIndex, form a_item)

	Form[] items
	Int offset = 32 * a_groupIndex
	if offset >= 128
		offset -= 128
		items = _items2
	else
		items = _items1
	endIf
	Int i = items.find(a_item, offset)
	if i >= offset && i < offset + 32
		return true
	endIf
	return false
endFunction

function ReplaceGroupIcon(Int a_groupIndex)

	Bool[] itemInvalidFlags
	Int[] itemIds
	Form[] items
	if _groupMainHandItemIds[a_groupIndex]
		_groupIconItems[a_groupIndex] = _groupMainHandItems[a_groupIndex]
		_groupIconItemIds[a_groupIndex] = _groupMainHandItemIds[a_groupIndex]
		return 
	elseIf _groupOffHandItemIds[a_groupIndex]
		_groupIconItems[a_groupIndex] = _groupOffHandItems[a_groupIndex]
		_groupIconItemIds[a_groupIndex] = _groupOffHandItemIds[a_groupIndex]
		return 
	endIf
	Int offset = a_groupIndex * 32
	if offset >= 128
		offset -= 128
		items = _items2
		itemIds = _itemIds2
		itemInvalidFlags = _itemInvalidFlags2
	else
		items = _items1
		itemIds = _itemIds1
		itemInvalidFlags = _itemInvalidFlags1
	endIf
	Int i = offset
	Int n = offset + 32
	while i < n
		if items[i] != none && !itemInvalidFlags[i]
			_groupIconItems[a_groupIndex] = items[i]
			_groupIconItemIds[a_groupIndex] = itemIds[i]
			return 
		else
			i += 1
		endIf
	endWhile
	_groupIconItems[a_groupIndex] = none
	_groupIconItemIds[a_groupIndex] = 0
endFunction

Bool function SetGroupHotkey(Int a_groupIndex, Int a_keyCode)

	if a_keyCode == -1
		_groupHotkeys[a_groupIndex] = -1
		self.UnregisterForKey(oldKeycode)
		return true
	endIf
	Int oldIndex = _groupHotkeys.find(a_keyCode, 0)
	Int oldKeycode = _groupHotkeys[a_groupIndex]
	if oldIndex == a_groupIndex
		return false
	endIf
	if oldIndex != -1 && oldKeycode != -1
		_groupHotkeys[oldIndex] = oldKeycode
	else
		if oldIndex != -1
			_groupHotkeys[oldIndex] = -1
		endIf
		if oldKeycode != -1
			self.UnregisterForKey(oldKeycode)
		endIf
		self.RegisterForKey(a_keyCode)
	endIf
	_groupHotkeys[a_groupIndex] = a_keyCode
	return true
endFunction

Int function GetNumFormsInGroup(Int a_groupIndex, form a_item)

	Int count
	Form[] items
	Int offset = 32 * a_groupIndex
	if offset >= 128
		offset -= 128
		items = _items2
	else
		items = _items1
	endIf
	Int i = offset
	Int n = offset + 32
	while i < n
		if items[i] == a_item
			count += 1
		endIf
		i += 1
	endWhile
	return count
endFunction

form function GetFormFromItemId(Int a_groupIndex, Int itemId)

	Int[] itemIds
	Form[] items
	Int offset = 32 * a_groupIndex
	if offset >= 128
		offset -= 128
		items = _items2
		itemIds = _itemIds2
	else
		items = _items1
		itemIds = _itemIds1
	endIf
	Int i = itemIds.find(itemId, offset)
	if i >= offset && i < offset + 32
		return items[i]
	else
		return none
	endIf
endFunction

function OnGroupUse(String a_eventName, String a_strArg, Float a_numArg, form a_sender)

	self.GotoState("PROCESSING")
	self.GroupUse(a_numArg as Int)
	self.GotoState("")
endFunction

function OnSaveEquipState(String a_eventName, String a_strArg, Float a_numArg, form a_sender)

	Int groupIndex = a_numArg as Int
	Int mainHandItemId = ui.GetInt(self.FAVORITES_MENU, self.MENU_ROOT + ".rightHandItemId")
	Int offHandItemId = ui.GetInt(self.FAVORITES_MENU, self.MENU_ROOT + ".leftHandItemId")
	form mainHandForm = self.GetFormFromItemId(groupIndex, mainHandItemId)
	if mainHandForm
		_groupMainHandItemIds[groupIndex] = mainHandItemId
		_groupMainHandItems[groupIndex] = mainHandForm
	else
		_groupMainHandItemIds[groupIndex] = 0
		_groupMainHandItems[groupIndex] = none
	endIf
	form offHandForm = self.GetFormFromItemId(groupIndex, offHandItemId)
	if offHandForm
		_groupOffHandItemIds[groupIndex] = offHandItemId
		_groupOffHandItems[groupIndex] = offHandForm
	else
		_groupOffHandItemIds[groupIndex] = 0
		_groupOffHandItems[groupIndex] = none
	endIf
	self.UpdateMenuGroupData(groupIndex)
endFunction

function OnMenuOpen(String a_menuName)

	Int i = 0
	while i < 128
		_itemInvalidFlags1[i] = false
		i += 1
	endWhile
	i = 0
	while i < 128
		_itemInvalidFlags2[i] = false
		i += 1
	endWhile
	self.InitControls()
	self.InitMenuGroupData()
endFunction

function CleanUp()

	Int i = 0
	while i < _items1.length
		if _items1[i] == none || _items1[i].GetFormID() == 0
			_items1[i] = none
			_itemIds1[i] = 0
		endIf
		i += 1
	endWhile
	i = 0
	while i < _items2.length
		if _items2[i] == none || _items2[i].GetFormID() == 0
			_items2[i] = none
			_itemIds2[i] = 0
		endIf
		i += 1
	endWhile
endFunction

; Skipped compiler generated GetState

function OnGameReload()

	self.CheckVersion()
	self.RegisterForModEvent("SKIFM_groupAdd", "OnGroupAdd")
	self.RegisterForModEvent("SKIFM_groupRemove", "OnGroupRemove")
	self.RegisterForModEvent("SKIFM_groupUse", "OnGroupUse")
	self.RegisterForModEvent("SKIFM_saveEquipState", "OnSaveEquipState")
	self.RegisterForModEvent("SKIFM_setGroupIcon", "OnSetGroupIcon")
	self.RegisterForModEvent("SKIFM_foundInvalidItem", "OnFoundInvalidItem")
	self.RegisterForMenu(self.FAVORITES_MENU)
	self.RegisterHotkeys()
	self.CleanUp()
endFunction

Int function FindFreeIndex(Int[] a_itemIds, Bool[] a_itemInvalidFlags, Int offset)

	Int i = a_itemIds.find(0, offset)
	if i >= offset && i < offset + 32
		return i
	endIf
	i = offset
	Int n = offset + 32
	while i < n
		if a_itemInvalidFlags[i]
			return i
		endIf
		i += 1
	endWhile
	return -1
endFunction

Bool function GroupAdd(Int a_groupIndex, Int a_itemId, form a_item)

	Bool[] itemInvalidFlags
	Int[] itemIds
	Form[] items
	Int offset = 32 * a_groupIndex
	if offset >= 128
		offset -= 128
		items = _items2
		itemIds = _itemIds2
		itemInvalidFlags = _itemInvalidFlags2
	else
		items = _items1
		itemIds = _itemIds1
		itemInvalidFlags = _itemInvalidFlags1
	endIf
	if self.IsItemIdInGroup(a_groupIndex, a_itemId)
		return true
	endIf
	Int index = self.FindFreeIndex(itemIds, itemInvalidFlags, offset)
	if index == -1
		return false
	endIf
	items[index] = a_item
	itemIds[index] = a_itemId
	itemInvalidFlags[index] = false
	if _groupIconItems[a_groupIndex] == none
		_groupIconItems[a_groupIndex] = a_item
		_groupIconItemIds[a_groupIndex] = a_itemId
	endIf
	return true
endFunction

function SetGroupFlag(Int a_groupIndex, Int a_flag, Bool a_value)

	if a_value
		_groupFlags[a_groupIndex] = math.LogicalOr(_groupFlags[a_groupIndex], a_flag)
	else
		_groupFlags[a_groupIndex] = math.LogicalAnd(_groupFlags[a_groupIndex], math.LogicalNot(a_flag))
	endIf
endFunction

function RegisterHotkeys()

	Int i = 0
	while i < _groupHotkeys.length
		if _groupHotkeys[i] != -1
			self.RegisterForKey(_groupHotkeys[i])
		endIf
		i += 1
	endWhile
endFunction

function GroupUse(Int a_groupIndex)

	Bool[] itemInvalidFlags
	Int[] itemIds
	Form[] items
	Int offset = 32 * a_groupIndex
	if offset >= 128
		offset -= 128
		items = _items2
		itemIds = _itemIds2
		itemInvalidFlags = _itemInvalidFlags2
	else
		items = _items1
		itemIds = _itemIds1
		itemInvalidFlags = _itemInvalidFlags1
	endIf
	_usedRightHand = false
	_usedLeftHand = false
	_usedVoice = false
	_usedOutfitMask = 0
	Form[] deferredItems = new Form[32]
	Int deferredIdx = 0
	Int[] invalidItemIds = new Int[32]
	Int invalidIdx = 0
	_audioCategoryUI.Mute()
	if self.GetGroupFlag(a_groupIndex, self.GROUP_FLAG_UNEQUIP_HANDS)
		self.UnequipHand(0)
		self.UnequipHand(1)
	endIf
	form offHandItem = _groupOffHandItems[a_groupIndex]
	Int offHandItemId = _groupOffHandItemIds[a_groupIndex]
	if offHandItem
		Int itemType = offHandItem.GetType()
		if self.IsItemValid(offHandItem, itemType)
			self.ProcessItem(offHandItem, itemType, false, true, offHandItemId)
		endIf
	endIf
	form mainHandItem = _groupMainHandItems[a_groupIndex]
	Int mainHandItemId = _groupMainHandItemIds[a_groupIndex]
	if mainHandItem
		Int itemtype = mainHandItem.GetType()
		if self.IsItemValid(mainHandItem, itemtype)
			self.ProcessItem(mainHandItem, itemtype, false, false, mainHandItemId)
		endIf
	endIf
	Int i = offset
	Int n = offset + 32
	while i < n
		form item = items[i]
		Int itemId = itemIds[i]
		if item as Bool && item != mainHandItem && item != offHandItem && !itemInvalidFlags[i]
			Int itemtype = item.GetType()
			if !self.IsItemValid(item, itemtype)
				invalidItemIds[invalidIdx] = itemId
				invalidIdx += 1
			elseIf !self.ProcessItem(item, itemtype, true, false, itemId)
				deferredItems[deferredIdx] = item
				deferredIdx += 1
			endIf
		endIf
		i += 1
	endWhile
	i = 0
	while i < deferredIdx
		form item = deferredItems[i]
		Int itemtype = item.GetType()
		self.ProcessItem(item, itemtype, false, false, 0)
		i += 1
	endWhile
	if self.GetGroupFlag(a_groupIndex, self.GROUP_FLAG_UNEQUIP_ARMOR)
		Int h = 1
		while h < -2147483648
			form wornForm = PlayerREF.GetWornForm(h)
			if wornForm
				if !math.LogicalAnd(h, _usedOutfitMask)
					PlayerREF.UnEquipItemEX(wornForm, 0, false)
				endIf
			endIf
			h = math.LeftShift(h, 1)
		endWhile
	endIf
	_audioCategoryUI.UnMute()
	i = 0
	while i < invalidIdx
		self.InvalidateItem(invalidItemIds[i], false)
		i += 1
	endWhile
endFunction

Bool function ProcessItem(form a_item, Int a_itemType, Bool a_allowDeferring, Bool a_offHandOnly, Int a_itemId)

	if a_itemType == 41
		if _usedRightHand as Bool && _usedLeftHand as Bool
			return true
		endIf
		weapon itemWeapon = a_item as weapon
		Int weaponType = itemWeapon.GetweaponType()
		if weaponType <= 4 || weaponType == 8
			if !_usedRightHand && !a_offHandOnly
				if a_item == PlayerREF.GetEquippedObject(1) && a_itemId != PlayerREF.GetEquippedItemId(1)
					self.UnequipHand(1)
				endIf
				PlayerREF.EquipItemById(itemWeapon as form, a_itemId, 1, false, _silenceEquipSounds)
				_usedRightHand = true
			elseIf !_usedLeftHand
				if a_item == PlayerREF.GetEquippedObject(0) && a_itemId != PlayerREF.GetEquippedItemId(0)
					self.UnequipHand(0)
				endIf
				PlayerREF.EquipItemById(itemWeapon as form, a_itemId, 2, false, _silenceEquipSounds)
				_usedLeftHand = true
			endIf
		elseIf weaponType > 4 && !_usedRightHand && !_usedLeftHand
			if a_item == PlayerREF.GetEquippedObject(0) && a_itemId != PlayerREF.GetEquippedItemId(0)
				self.UnequipHand(0)
			endIf
			PlayerREF.EquipItemById(itemWeapon as form, a_itemId, 0, false, _silenceEquipSounds)
			_usedRightHand = true
			_usedLeftHand = true
		endIf
		return true
	elseIf a_itemType == 26
		Int slotMask = (a_item as armor).GetslotMask()
		if slotMask == 512
			if !_usedLeftHand
				PlayerREF.EquipItemById(a_item, a_itemId, 0, false, _silenceEquipSounds)
				_usedLeftHand = true
				_usedOutfitMask += slotMask
			endIf
		elseIf !math.LogicalAnd(_usedOutfitMask, slotMask)
			if a_item == PlayerREF.GetWornForm(slotMask) && a_itemId != PlayerREF.GetWornItemId(slotMask)
				PlayerREF.UnEquipItemEX(a_item, 0, false)
			endIf
			PlayerREF.EquipItemById(a_item, a_itemId, 0, false, _silenceEquipSounds)
			_usedOutfitMask += slotMask
		endIf
		return true
	elseIf a_itemType == 42
		PlayerREF.EquipItemEX(a_item, 0, false, _silenceEquipSounds)
		return true
	elseIf a_itemType == 22
		spell itemSpell = a_item as spell
		EquipSlot spellEquipSlot = itemSpell.GetEquipType()
		if spellEquipSlot != _voiceSlot
			if _usedRightHand as Bool && _usedLeftHand as Bool
				return true
			endIf
			if spellEquipSlot == _eitherHandSlot
				if !_usedRightHand && !a_offHandOnly
					PlayerREF.EquipSpell(itemSpell, 1)
					_usedRightHand = true
				elseIf !_usedLeftHand
					PlayerREF.EquipSpell(itemSpell, 0)
					_usedLeftHand = true
				endIf
			elseIf spellEquipSlot == _bothHandsSlot
				if !_usedRightHand && !_usedLeftHand
					PlayerREF.EquipSpell(itemSpell, 1)
					_usedRightHand = true
					_usedLeftHand = true
				endIf
			elseIf spellEquipSlot == _leftHandSlot
				if !_usedLeftHand
					PlayerREF.EquipSpell(itemSpell, 0)
					_usedLeftHand = true
				endIf
			endIf
		elseIf !_usedVoice
			PlayerREF.EquipSpell(itemSpell, 2)
			_usedVoice = true
		endIf
		return true
	elseIf a_itemType == 23
		scroll itemScroll = a_item as scroll
		if _usedRightHand as Bool && _usedLeftHand as Bool
			return true
		endIf
		if !_usedRightHand && !a_offHandOnly
			PlayerREF.EquipItemEX(itemScroll as form, 1, false, _silenceEquipSounds)
			_usedRightHand = true
		elseIf !_usedLeftHand
			PlayerREF.EquipItemEX(itemScroll as form, 2, false, _silenceEquipSounds)
			_usedLeftHand = true
		endIf
		return true
	elseIf a_itemType == 119
		if !_usedVoice
			PlayerREF.EquipShout(a_item as shout)
			_usedVoice = true
		endIf
		return true
	elseIf a_itemType == 46
		if (a_item as potion).IsHostile()
			if a_allowDeferring
				return false
			endIf
			PlayerREF.EquipItem(a_item, false, true)
			return true
		endIf
		PlayerREF.EquipItem((a_item as potion) as form, false, true)
		return true
	elseIf a_itemType == 30
		PlayerREF.EquipItem((a_item as ingredient) as form, false, true)
		return true
	elseIf a_itemType == 31
		if !_usedLeftHand
			PlayerREF.EquipItemEX(a_item, 0, false, _silenceEquipSounds)
			_usedLeftHand = true
		endIf
		return true
	elseIf a_itemType == 32
		PlayerREF.EquipItem(a_item, false, true)
		return true
	endIf
	return true
endFunction

function SwapControlKey(Int a_newKey, Int a_curKey)

	if a_newKey == _groupAddKey
		_groupAddKey = a_curKey
	elseIf a_newKey == _groupUseKey
		_groupUseKey = a_curKey
	elseIf a_newKey == _setIconKey
		_setIconKey = a_curKey
	elseIf a_newKey == _saveEquipStateKey
		_saveEquipStateKey = a_curKey
	elseIf a_newKey == _toggleFocusKey
		_toggleFocusKey = a_curKey
	endIf
endFunction

function UnequipHand(Int a_hand)

	Int a_handEx = 1
	if a_hand == 0
		a_handEx = 2
	endIf
	form handItem = PlayerREF.GetEquippedObject(a_hand)
	if handItem
		Int itemType = handItem.GetType()
		if itemType == 22
			PlayerREF.UnequipSpell(handItem as spell, a_hand)
		else
			PlayerREF.UnEquipItemEX(handItem, a_handEx, false)
		endIf
	endIf
endFunction

function InitMenuGroupData()

	if _vampireLordRace == PlayerREF.GetRace()
		return 
	endIf
	Int[] args = new Int[25]
	args[0] = 8
	Int c = 1
	Int i = 0
	while i < 8
		args[c] = _groupMainHandItemIds[i]
		i += 1
		c += 1
	endWhile
	i = 0
	while i < 8
		args[c] = _groupOffHandItemIds[i]
		i += 1
		c += 1
	endWhile
	i = 0
	while i < 8
		args[c] = _groupIconItemIds[i]
		i += 1
		c += 1
	endWhile
	ui.InvokeIntA(self.FAVORITES_MENU, self.MENU_ROOT + ".pushGroupItems", _itemIds1)
	ui.InvokeIntA(self.FAVORITES_MENU, self.MENU_ROOT + ".pushGroupItems", _itemIds2)
	ui.InvokeIntA(self.FAVORITES_MENU, self.MENU_ROOT + ".finishGroupData", args)
endFunction

function PrintGroupItems(Int a_groupIndex)

	Int[] itemIds
	Form[] items
	debug.Trace("PrintGroupItems called on group " + a_groupIndex as String, 0)
	Int offset = 32 * a_groupIndex
	if offset >= 128
		offset -= 128
		items = _items2
		itemIds = _itemIds2
	else
		items = _items1
		itemIds = _itemIds1
	endIf
	Int i = offset
	Int n = offset + 32
	while i < n
		if items[i]
			debug.Trace(i as String + " is " + itemIds[i] as String + ", form is " + items[i] as String + ": " + items[i].GetName(), 0)
		endIf
		i += 1
	endWhile
	if _groupIconItemIds[a_groupIndex]
		debug.Trace("Group icon is " + _groupIconItemIds[a_groupIndex] as String + ", form is " + _groupIconItems[a_groupIndex] as String + ": " + _groupIconItems[a_groupIndex].GetName(), 0)
	endIf
	if _groupMainHandItemIds[a_groupIndex]
		debug.Trace("Group MH is " + _groupMainHandItemIds[a_groupIndex] as String + ", form is " + _groupMainHandItems[a_groupIndex] as String + ": " + _groupMainHandItems[a_groupIndex].GetName(), 0)
	endIf
	if _groupOffHandItemIds[a_groupIndex]
		debug.Trace("Group OH is " + _groupOffHandItemIds[a_groupIndex] as String + ", form is " + _groupOffHandItems[a_groupIndex] as String + ": " + _groupOffHandItems[a_groupIndex].GetName(), 0)
	endIf
endFunction

Bool function IsItemIdInGroup(Int a_groupIndex, Int a_itemId)

	Int[] itemIds
	Int offset = 32 * a_groupIndex
	if offset >= 128
		offset -= 128
		itemIds = _itemIds2
	else
		itemIds = _itemIds1
	endIf
	Int i = itemIds.find(a_itemId, offset)
	if i >= offset && i < offset + 32
		return true
	endIf
	return false
endFunction

Bool function GroupRemove(Int a_groupIndex, Int a_itemId)

	Bool[] itemInvalidFlags
	Int[] itemIds
	Form[] items
	Int offset = 32 * a_groupIndex
	if offset >= 128
		offset -= 128
		items = _items2
		itemIds = _itemIds2
		itemInvalidFlags = _itemInvalidFlags2
	else
		items = _items1
		itemIds = _itemIds1
		itemInvalidFlags = _itemInvalidFlags1
	endIf
	Int i = offset
	Int n = offset + 32
	while i < n
		if itemIds[i] == a_itemId
			items[i] = none
			itemIds[i] = 0
			itemInvalidFlags[i] = false
			i = n
		else
			i += 1
		endIf
	endWhile
	if a_itemId == _groupMainHandItemIds[a_groupIndex]
		_groupMainHandItems[a_groupIndex] = none
		_groupMainHandItemIds[a_groupIndex] = 0
	endIf
	if a_itemId == _groupOffHandItemIds[a_groupIndex]
		_groupOffHandItems[a_groupIndex] = none
		_groupOffHandItemIds[a_groupIndex] = 0
	endIf
	if a_itemId == _groupIconItemIds[a_groupIndex]
		self.ReplaceGroupIcon(a_groupIndex)
	endIf
	return true
endFunction

Int[] function GetGroupHotkeys()

	Int[] result = new Int[8]
	Int i = 0
	while i < 8
		result[i] = _groupHotkeys[i]
		i += 1
	endWhile
	return result
endFunction

function InitControls()

	Int[] args = new Int[6]
	args[0] = ButtonHelpEnabled as Int
	args[1] = _groupAddKey
	args[2] = _groupUseKey
	args[3] = _setIconKey
	args[4] = _saveEquipStateKey
	args[5] = _toggleFocusKey
	ui.InvokeIntA(self.FAVORITES_MENU, self.MENU_ROOT + ".initControls", args)
endFunction

; Skipped compiler generated GotoState

function OnInit()

	_items1 = new Form[128]
	_items2 = new Form[128]
	_itemIds1 = new Int[128]
	_itemIds2 = new Int[128]
	_groupFlags = new Int[8]
	_groupMainHandItems = new Form[8]
	_groupMainHandItemIds = new Int[8]
	_groupOffHandItems = new Form[8]
	_groupOffHandItemIds = new Int[8]
	_groupIconItems = new Form[8]
	_groupIconItemIds = new Int[8]
	_groupHotkeys = new Int[8]
	_groupHotkeys[0] = 59
	_groupHotkeys[1] = 60
	_groupHotkeys[2] = 61
	_groupHotkeys[3] = 62
	_groupHotkeys[4] = -1
	_groupHotkeys[5] = -1
	_groupHotkeys[6] = -1
	_groupHotkeys[7] = -1
	_audioCategoryUI = game.GetFormFromFile(410705, "Skyrim.esm") as SoundCategory
	_rightHandSlot = game.GetFormFromFile(81730, "Skyrim.esm") as EquipSlot
	_leftHandSlot = game.GetFormFromFile(81731, "Skyrim.esm") as EquipSlot
	_eitherHandSlot = game.GetFormFromFile(81732, "Skyrim.esm") as EquipSlot
	_bothHandsSlot = game.GetFormFromFile(81733, "Skyrim.esm") as EquipSlot
	_voiceSlot = game.GetFormFromFile(154606, "Skyrim.esm") as EquipSlot
	self.OnGameReload()
endFunction

Bool function IsItemValid(form a_item, Int a_itemType)

	if !game.IsObjectFavorited(a_item)
		return false
	endIf
	if a_itemType == 22 || a_itemType == 119
		return PlayerREF.HasSpell(a_item)
	else
		return PlayerREF.GetItemCount(a_item) > 0
	endIf
endFunction

Int function GetVersion()

	return 3
endFunction

function OnGroupRemove(String a_eventName, String a_strArg, Float a_numArg, form a_sender)

	Int groupIndex = a_numArg as Int
	Int itemId = a_strArg as Int
	if self.GroupRemove(groupIndex, itemId)
		self.UpdateMenuGroupData(groupIndex)
	else
		ui.InvokeBool(self.FAVORITES_MENU, self.MENU_ROOT + ".unlock", true)
	endIf
endFunction

function InvalidateItem(Int a_itemId, Bool redrawIcon)

	Int index = _itemIds1.find(a_itemId, 0)
	if index != -1
		_itemInvalidFlags1[index] = true
	endIf
	index = _itemIds2.find(a_itemId, 0)
	if index != -1
		_itemInvalidFlags2[index] = true
	endIf
	index = _groupMainHandItemIds.find(a_itemId, 0)
	if index != -1
		_groupMainHandItems[index] = none
		_groupMainHandItemIds[index] = 0
	endIf
	index = _groupOffHandItemIds.find(a_itemId, 0)
	if index != -1
		_groupOffHandItems[index] = none
		_groupOffHandItemIds[index] = 0
	endIf
	index = _groupIconItemIds.find(a_itemId, 0)
	if index != -1
		self.ReplaceGroupIcon(index)
		if redrawIcon
			self.UpdateMenuGroupData(index)
		endIf
	endIf
endFunction

Int function GetNthItemIdInGroup(Int a_groupIndex, form a_item, Int a_num)

	Int[] itemIds
	Form[] items
	Int offset = 32 * a_groupIndex
	if offset >= 128
		offset -= 128
		items = _items2
		itemIds = _itemIds2
	else
		items = _items1
		itemIds = _itemIds1
	endIf
	Int i = offset
	Int n = offset + 32
	Int count = 0
	Int result = offset
	while result >= offset && result < n && count < a_num
		result = items.find(a_item, i)
		i = result + 1
		count += 1
	endWhile
	if result >= offset && result < n
		return itemIds[result]
	endIf
	return 0
endFunction

Bool function GetGroupFlag(Int a_groupIndex, Int a_flag)

	return math.LogicalAnd(_groupFlags[a_groupIndex], a_flag) as Bool
endFunction

function UpdateMenuGroupData(Int a_groupIndex)

	Int[] itemIds
	Int offset = 32 * a_groupIndex
	if offset >= 128
		offset -= 128
		itemIds = _itemIds2
	else
		itemIds = _itemIds1
	endIf
	Int[] args = new Int[36]
	args[0] = a_groupIndex
	args[1] = _groupMainHandItemIds[a_groupIndex]
	args[2] = _groupOffHandItemIds[a_groupIndex]
	args[3] = _groupIconItemIds[a_groupIndex]
	Int i = 4
	Int j = offset
	while i < 36
		args[i] = itemIds[j]
		i += 1
		j += 1
	endWhile
	ui.InvokeIntA(self.FAVORITES_MENU, self.MENU_ROOT + ".updateGroupData", args)
endFunction

function OnGroupAdd(String a_eventName, String a_strArg, Float a_numArg, form a_sender)

	Int groupIndex = a_numArg as Int
	Int itemId = a_strArg as Int
	form item = a_sender
	if self.GroupAdd(groupIndex, itemId, item)
		self.UpdateMenuGroupData(groupIndex)
	else
		ui.InvokeBool(self.FAVORITES_MENU, self.MENU_ROOT + ".unlock", true)
		debug.Notification("Group full!")
	endIf
endFunction

;-- State -------------------------------------------
state PROCESSING

	function OnGroupUse(String a_eventName, String a_strArg, Float a_numArg, form a_sender)

		; Empty function
	endFunction

	function OnKeyDown(Int a_keyCode)

		; Empty function
	endFunction
endState
