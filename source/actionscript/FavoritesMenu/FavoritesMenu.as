class FavoritesMenu extends MovieClip
{
	/* CONSTANTS */

	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = FavoritesMenu.SKYUI_VERSION_MAJOR + "." + FavoritesMenu.SKYUI_VERSION_MINOR + " SE";

	private static var ITEM_SELECT = 0;
	private static var GROUP_ASSIGN = 1;
	private static var GROUP_ASSIGN_SYNC = 2;
	private static var GROUP_REMOVE_SYNC = 3;
	private static var CLOSING = 4;
	private static var SAVE_EQUIP_STATE_SYNC = 5;
	private static var SET_ICON_SYNC = 6;


	/* PRIVATE VARIABLES */

	private var _platform;

	private var _typeFilter;
	private var _sortFilter;

	private var _groupDataExtender;

	private var _categoryButtonGroup;
	private var _groupButtonGroup;

	private var _leftKeycode = -1;
	private var _rightKeycode = -1;

	private var _groupAddKey = -1;
	private var _groupUseKey = -1;
	private var _setIconKey = -1;
	private var _saveEquipStateKey = -1;
	private var _toggleFocusKey = -1;

	private var _groupAddControls;
	private var _groupUseControls;
	private var _setIconControls;
	private var _saveEquipStateControls;
	private var _toggleFocusControls;

	private var _state;

	// A workaround to prevent mouse navigation issues
	private var _useMouseNavigation = false;

	private var _categoryIndex = 0;
	private var _groupIndex = 0;

	private var _groupButtonFocused = false;

	private var _groupAssignIndex = -1;

	private var _savedIndex = -1;
	private var _savedScrollPosition = 0;

	private var _groupButtonsShown = false;
	private var _waitingForGroupData = true;

	private var _isInitialized = false;

	private var _navPanelEnabled = false;
	private var _fadedIn = false;


	/* STAGE ELEMENTS */

	public var itemList;

	public var btnAll;
	public var btnGear;
	public var btnAid;
	public var btnMagic;

	public var groupButtonFader;

	public var navButton;

	public var headerText;

	public var navPanel;


	/* PROPERTIES */

	// @API
	public var bPCControlsReady = true;


	/* PAPYRUS INTERFACE */

	public var leftHandItemId;
	public var rightHandItemId;
	public var scrollPosition;
	public var onInvalidate;
	public var listState;


	/* INITIALIZATION */

	public function FavoritesMenu()
	{
		super();
		this._typeFilter = new skyui.filter.ItemTypeFilter();
		this._sortFilter = new skyui.filter.SortFilter();
		this._categoryButtonGroup = new gfx.controls.ButtonGroup("CategoryButtonGroup");
		this._groupButtonGroup = new gfx.controls.ButtonGroup("GroupButtonGroup");
		Mouse.addListener(this);
	}

	public function initControls(a_navPanelEnabled, a_groupAddKey, a_groupUseKey,
								 a_setIconKey, a_saveEquipStateKey, a_toggleFocusKey)
	{
		this._navPanelEnabled = a_navPanelEnabled;

		// On PC, we need overrides from Papyrus to make sure no mouse buttons are used (handleInput doesnt catch those).
		// On gamepad, we can get the keys via SKSE so no need to let the user rebind it.
		if (this._platform == 0)
		{
			this._groupAddKey = a_groupAddKey;
			this._groupUseKey = a_groupUseKey;
			this._setIconKey = a_setIconKey;
			this._saveEquipStateKey = a_saveEquipStateKey;
			this._toggleFocusKey = a_toggleFocusKey;
			this.createControls();
		}
		this.updateNavButtons();
	}

	public function pushGroupItems()
	{
		var i = 0;
		while (i < arguments.length)
		{
			this._groupDataExtender.groupData.push(arguments[i] & 0xFFFFFFFF);
			i = i + 1;
		}
	}

	public function finishGroupData(a_groupCount)
	{
		var offset = 1;
		var i;

		i = 0;
		while (i < a_groupCount)
		{
			this._groupDataExtender.mainHandData.push(arguments[offset] & 0xFFFFFFFF);
			i++;
			offset++;
		}
		i = 0;
		while (i < a_groupCount)
		{
			this._groupDataExtender.offHandData.push(arguments[offset] & 0xFFFFFFFF);
			i++;
			offset++;
		}
		i = 0;
		while (i < a_groupCount)
		{
			this._groupDataExtender.iconData.push(arguments[offset] & 0xFFFFFFFF);
			i++;
			offset++;
		}

		if (this._isInitialized)
		{
			this.itemList.InvalidateData();
		}
		this._waitingForGroupData = false;
		this.enableGroupButtons(true);
		this.updateNavButtons();
	}

	public function updateGroupData(a_groupIndex, a_mainHandItemId, a_offHandItemId, a_iconItemId)
	{
		var startIndex = a_groupIndex * GroupDataExtender.GROUP_SIZE;

		this._groupDataExtender.mainHandData[a_groupIndex] = a_mainHandItemId & 0xFFFFFFFF;
		this._groupDataExtender.offHandData[a_groupIndex] = a_offHandItemId & 0xFFFFFFFF;
		this._groupDataExtender.iconData[a_groupIndex] = a_iconItemId & 0xFFFFFFFF;

		var i = 4;
		var j = startIndex;
		while (i < arguments.length)
		{
			this._groupDataExtender.groupData[j] = arguments[i] & 0xFFFFFFFF;
			i++;
			j++;
		}

		if (this._isInitialized)
		{
			this.itemList.InvalidateData();
		}

		// Automatically unlock after receiving an update
		this.unlock();
	}

	public function unlock()
	{
		// Received group data as result of group assignment?
		if (this._state == FavoritesMenu.GROUP_ASSIGN_SYNC)
		{
			this.endGroupAssignment();
		}
		else if (this._state == FavoritesMenu.GROUP_REMOVE_SYNC)
		{
			this.endGroupRemoval();
		}
		else if (this._state == FavoritesMenu.SET_ICON_SYNC)
		{
			this.endSetGroupIcon();
		}
		else if (this._state == FavoritesMenu.SAVE_EQUIP_STATE_SYNC)
		{
			this.endSaveEquipState();
		}
		this.updateNavButtons();
	}


	/* PUBLIC FUNCTIONS */

	// @API
	public function InitExtensions()
	{
		skse.ExtendData(true);

		this.btnAll.group = this._categoryButtonGroup;
		this.btnGear.group = this._categoryButtonGroup;
		this.btnAid.group = this._categoryButtonGroup;
		this.btnMagic.group = this._categoryButtonGroup;

		var groupButtons = [];
		var i = 1;
		var btn;
		while (i <= 8)
		{
			btn = this.groupButtonFader.groupButtonHolder["btnGroup" + i];
			btn.text;
			groupButtons.push(btn);
			btn.group = this._groupButtonGroup;
			i = i + 1;
		}

		this._categoryButtonGroup.addEventListener("change", this, "onCategorySelect");
		this._groupButtonGroup.addEventListener("change", this, "onGroupSelect");

		this.itemList.addDataProcessor(new FilterDataExtender());
		this.itemList.addDataProcessor(new FavoritesIconSetter());

		this._groupDataExtender = new GroupDataExtender(groupButtons);
		this.itemList.addDataProcessor(this._groupDataExtender);

		var listEnumeration = new skyui.components.list.FilteredEnumeration(this.itemList.entryList);
		listEnumeration.addFilter(this._typeFilter);
		listEnumeration.addFilter(this._sortFilter);

		this._typeFilter.addEventListener("filterChange", this, "onFilterChange");
		this._sortFilter.addEventListener("filterChange", this, "onFilterChange");

		this.itemList.listEnumeration = listEnumeration;

		Shared.GlobalFunc.SetLockFunction();
		this._parent.Lock("BL");

		gfx.io.GameDelegate.addCallBack("PopulateItems", this, "populateItemList");
		gfx.io.GameDelegate.addCallBack("SetSelectedItem", this, "setSelectedItem");
		gfx.io.GameDelegate.addCallBack("StartFadeOut", this, "startFadeOut");

		this.itemList.addEventListener("itemPress", this, "onItemPress");
		this.itemList.addEventListener("selectionChange", this, "onItemSelectionChange");
		gfx.managers.FocusHandler.instance.setFocus(this.itemList, 0);

		this._parent.gotoAndPlay("startFadeIn");

		this._sortFilter.setSortBy(["text"], [], false);

		this._state = FavoritesMenu.ITEM_SELECT;

		// Wait for initial group data
		this._waitingForGroupData = true;

		this.navPanel._visible = false;
		this.navButton.visible = false;

		this.restoreIndices();

		this.setGroupFocus(false);

		// We avoid any invalidates before this point.
		// After it, the next invalidate should be triggered from game code after filling list data.
		// That is when we can restore selectedIndex and scroll position
		this._isInitialized = true;

		this.updateNavButtons();
	}

	// @API
	public function get ItemList()
	{
		return this.itemList;
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		if (this._state == FavoritesMenu.CLOSING)
		{
			return true;
		}

		var nextClip = pathToFocus.shift();
		if (nextClip && nextClip.handleInput(details, pathToFocus))
		{
			return true;
		}

		var idx;

		if (Shared.GlobalFunc.IsKeyPressed(details))
		{
			if (details.navEquivalent == gfx.ui.NavigationCode.TAB)
			{
				if (this._state == FavoritesMenu.GROUP_ASSIGN)
				{
					this.endGroupAssignment();
				}
				else
				{
					this.startFadeOut();
				}
				return true;
			}
			if (details.navEquivalent == gfx.ui.NavigationCode.LEFT || details.skseKeycode == this._leftKeycode)
			{
				if (this._state == FavoritesMenu.GROUP_ASSIGN)
				{
					// Don't change the index here, leave it to onGroupSelect so it can detect assignment confirmation
					idx = this._groupAssignIndex;
					if (idx == -1)
					{
						idx = this._groupButtonGroup.length - 1;
					}
					else
					{
						idx = idx - 1;
					}
					if (idx < 0)
					{
						idx = this._groupButtonGroup.length - 1;
					}
					this._groupButtonGroup.setSelectedButton(this._groupButtonGroup.getButtonAt(idx));
				}
				else if (this._state == FavoritesMenu.ITEM_SELECT)
				{
					if (this._groupButtonFocused)
					{
						this._groupIndex = this._groupIndex - 1;
						if (this._groupIndex < 0)
						{
							this._groupIndex = this._groupButtonGroup.length - 1;
						}
						this._groupButtonGroup.setSelectedButton(this._groupButtonGroup.getButtonAt(this._groupIndex));
					}
					else
					{
						this._categoryIndex = this._categoryIndex - 1;
						if (this._categoryIndex < 0)
						{
							this._categoryIndex = this._categoryButtonGroup.length - 1;
						}
						this._categoryButtonGroup.setSelectedButton(this._categoryButtonGroup.getButtonAt(this._categoryIndex));
					}
				}
				return true;
			}
			if (details.navEquivalent == gfx.ui.NavigationCode.RIGHT || details.skseKeycode == this._rightKeycode)
			{
				if (this._state == FavoritesMenu.GROUP_ASSIGN)
				{
					// Don't change the index here, leave it to onGroupSelect so it can detect assignment confirmation
					idx = this._groupAssignIndex;
					if (idx == -1)
					{
						idx = 0;
					}
					else
					{
						idx = idx + 1;
					}
					if (idx >= this._groupButtonGroup.length)
					{
						idx = 0;
					}
					this._groupButtonGroup.setSelectedButton(this._groupButtonGroup.getButtonAt(idx));
				}
				else if (this._state == FavoritesMenu.ITEM_SELECT)
				{
					if (this._groupButtonFocused)
					{
						this._groupIndex = this._groupIndex + 1;
						if (this._groupIndex >= this._groupButtonGroup.length)
						{
							this._groupIndex = 0;
						}
						this._groupButtonGroup.setSelectedButton(this._groupButtonGroup.getButtonAt(this._groupIndex));
					}
					else
					{
						this._categoryIndex = this._categoryIndex + 1;
						if (this._categoryIndex >= this._categoryButtonGroup.length)
						{
							this._categoryIndex = 0;
						}
						this._categoryButtonGroup.setSelectedButton(this._categoryButtonGroup.getButtonAt(this._categoryIndex));
					}
				}
				return true;
			}
			if (details.skseKeycode == this._groupAddKey)
			{
				if (this._state == FavoritesMenu.ITEM_SELECT)
				{
					if (!this._groupButtonFocused)
					{
						this.startGroupAssignment();
					}
					else
					{
						this.startGroupRemoval();
					}
				}
				else if (this._state == FavoritesMenu.GROUP_ASSIGN)
				{
					this.endGroupAssignment();
				}
				return true;
			}
			if (this._state == FavoritesMenu.GROUP_ASSIGN && details.navEquivalent == gfx.ui.NavigationCode.ENTER)
			{
				if (this._groupAssignIndex != -1)
				{
					this.applyGroupAssignment();
				}
				return true;
			}
			if (details.skseKeycode == this._groupUseKey)
			{
				if (this._state == FavoritesMenu.ITEM_SELECT)
				{
					this.requestGroupUse();
				}
				return true;
			}
			if (details.skseKeycode == this._setIconKey)
			{
				if (this._state == FavoritesMenu.ITEM_SELECT)
				{
					this.startSetGroupIcon();
				}
			}
			else if (details.skseKeycode == this._saveEquipStateKey)
			{
				if (this._state == FavoritesMenu.ITEM_SELECT)
				{
					this.startSaveEquipState();
				}
			}
			else if (details.skseKeycode == this._toggleFocusKey)
			{
				if (this._state == FavoritesMenu.ITEM_SELECT)
				{
					this.setGroupFocus(!this._groupButtonFocused);
				}
				return true;
			}
		}
		return true;
	}

	// @API
	public function get selectedIndex()
	{
		return !this.confirmSelectedEntry() ? -1 : this.itemList.selectedEntry.index;
	}

	// @API
	public function setSelectedItem(a_index)
	{
		// We use skse.Store/LoadIndices to restore the selected item on our terms
		return undefined;
	}

	// @API
	public function SetPlatform(a_platform, a_bPS3Switch)
	{
		this._platform = a_platform;

		var isGamepad = this._platform != 0;
		this._leftKeycode = skyui.util.GlobalFunctions.getMappedKey("Left", skyui.defines.Input.CONTEXT_MENUMODE, isGamepad);
		this._rightKeycode = skyui.util.GlobalFunctions.getMappedKey("Right", skyui.defines.Input.CONTEXT_MENUMODE, isGamepad);

		// Set keys via SKSE for gamepad, wait for initControls for PC
		if (this._platform != 0)
		{
			this._groupAddKey = skyui.util.GlobalFunctions.getMappedKey("Toggle POV", skyui.defines.Input.CONTEXT_GAMEPLAY, true);
			this._groupUseKey = skyui.util.GlobalFunctions.getMappedKey("Ready Weapon", skyui.defines.Input.CONTEXT_GAMEPLAY, true);
			this._setIconKey = skyui.util.GlobalFunctions.getMappedKey("Sprint", skyui.defines.Input.CONTEXT_GAMEPLAY, true);
			this._saveEquipStateKey = skyui.util.GlobalFunctions.getMappedKey("Wait", skyui.defines.Input.CONTEXT_GAMEPLAY, true);
			this._toggleFocusKey = skyui.util.GlobalFunctions.getMappedKey("Jump", skyui.defines.Input.CONTEXT_GAMEPLAY, true);
			this.createControls();
		}
		this.navButton.setPlatform(a_platform);
		this.navPanel.row1.setPlatform(a_platform, a_bPS3Switch);
		this.navPanel.row2.setPlatform(a_platform, a_bPS3Switch);
		this.updateNavButtons();
	}


	/* PRIVATE FUNCTIONS */

	private function onFilterChange(a_event)
	{
		if (this._isInitialized)
		{
			this.itemList.InvalidateData();
		}
	}

	private function onItemPress(a_event)
	{
		if (this._state != FavoritesMenu.ITEM_SELECT)
		{
			return undefined;
		}
		// Only handles keyboard input, mouse is done internally
		if (a_event.keyboardOrMouse != 0)
		{
			this._useMouseNavigation = false;
			gfx.io.GameDelegate.call("ItemSelect", []);
		}
		else
		{
			this._useMouseNavigation = true;
		}
	}

	private function onItemSelectionChange(a_event)
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		this._useMouseNavigation = a_event.keyboardOrMouse == 0;
		this.updateNavButtons();
	}

	private function onCategorySelect(a_event)
	{
		var btn = a_event.item;
		if (btn == null)
		{
			return undefined;
		}
		this._categoryIndex = this._categoryButtonGroup.indexOf(btn);
		this._groupButtonFocused = false;
		this._groupButtonGroup.setSelectedButton(null);
		this.itemList.listState.activeGroupIndex = -1;
		this.headerText.SetText(btn.text);
		this._typeFilter.changeFilterFlag(btn.filterFlag);
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
		this.updateNavButtons();
	}

	private function onGroupSelect(a_event)
	{
		var btn = a_event.item;
		if (btn == null)
		{
			return undefined;
		}
		var index = this._groupButtonGroup.indexOf(btn);
		this._groupButtonFocused = true;
		this._categoryButtonGroup.setSelectedButton(null);
		this.headerText.SetText(btn.text);
		this.itemList.listState.activeGroupIndex = index;
		this._typeFilter.changeFilterFlag(btn.filterFlag);

		if (this._state == FavoritesMenu.GROUP_ASSIGN)
		{
			if (this._groupAssignIndex == index)
			{
				this.applyGroupAssignment();
			}
			else
			{
				this.navButton.setButtonData({text: "$Confirm Group", controls: skyui.defines.Input.Accept});
				this._groupAssignIndex = index;
			}
		}
		else
		{
			this._groupIndex = index;
		}
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
		this.updateNavButtons();
	}

	private function onFadeInCompletion()
	{
		this._fadedIn = true;
		this.updateNavButtons();
	}

	private function startFadeOut()
	{
		this._state = FavoritesMenu.CLOSING;
		this.updateNavButtons();
		this._parent.gotoAndPlay("startFadeOut");
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeCloseSD"]);
	}

	private function onFadeOutCompletion()
	{
		this.saveIndices();
		gfx.io.GameDelegate.call("FadeDone", [this.itemList.selectedIndex]);
	}

	private function onMouseDown()
	{
		this._useMouseNavigation = true;
	}

	private function onMouseMove()
	{
		this._useMouseNavigation = true;
	}

	private function startGroupAssignment()
	{
		if (this._waitingForGroupData)
		{
			return undefined;
		}
		var selectedEntry = this.itemList.selectedEntry;
		if (selectedEntry == null)
		{
			return undefined;
		}
		this._state = FavoritesMenu.GROUP_ASSIGN;
		this.headerText._visible = false;
		this._groupAssignIndex = -1;

		var assignedEntry = this.itemList.selectedEntry;
		this.itemList.listState.assignedEntry = assignedEntry;
		assignedEntry.filterFlag |= FilterDataExtender.FILTERFLAG_GROUP_ADD;

		this.itemList.listState.restoredSelectedIndex = this.itemList.selectedIndex;
		this.itemList.listState.restoredScrollPosition = this.itemList.scrollPosition;
		this.itemList.selectedIndex = -1;
		this.itemList.disableSelection = true;
		this.itemList.requestUpdate();

		this.navButton.visible = true;
		this.navButton.setButtonData({text: "$Select Group", controls: skyui.defines.Input.LeftRight});

		this.btnAll.disabled = true;
		this.btnGear.disabled = true;
		this.btnAid.disabled = true;
		this.btnMagic.disabled = true;
		this.btnAll.visible = false;
		this.btnGear.visible = false;
		this.btnAid.visible = false;
		this.btnMagic.visible = false;
		this.updateNavButtons();
	}

	private function applyGroupAssignment()
	{
		var formId = this.itemList.listState.assignedEntry.formId;
		var itemId = this.itemList.listState.assignedEntry.itemId;

		if (formId == null || formId == 0 || this._groupAssignIndex == -1)
		{
			this.endGroupAssignment();
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		}
		else
		{
			// Suspend list to avoid redundant invalidate before new synced group data arrives
			this.itemList.suspended = true;
			this.enableGroupButtons(false);
			this._state = FavoritesMenu.GROUP_ASSIGN_SYNC;
			skse.SendModEvent("SKIFM_groupAdd", String(itemId), this._groupAssignIndex, formId);
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
		}
	}

	private function endGroupAssignment()
	{
		this.itemList.listState.assignedEntry.filterFlag &= ~FilterDataExtender.FILTERFLAG_GROUP_ADD;
		this.itemList.listState.assignedEntry = null;

		this.itemList.onInvalidate = function()
		{
			this.scrollPosition = this.listState.restoredScrollPosition;
			this.selectedIndex = this.listState.restoredSelectedIndex;
			delete this.onInvalidate;
		};

		this.itemList.disableSelection = false;
		this.itemList.requestInvalidate();
		this.itemList.suspended = false;
		this._state = FavoritesMenu.ITEM_SELECT;
		this._groupAssignIndex = -1;

		this.btnAll.disabled = false;
		this.btnGear.disabled = false;
		this.btnAid.disabled = false;
		this.btnMagic.disabled = false;
		this.btnAll.visible = true;
		this.btnGear.visible = true;
		this.btnAid.visible = true;
		this.btnMagic.visible = true;

		this.headerText._visible = true;
		this.navButton.visible = false;
		this.setGroupFocus(false);
		this.enableGroupButtons(true);
		this.updateNavButtons();
	}

	private function startGroupRemoval()
	{
		var itemId = this.itemList.selectedEntry.itemId;
		if (this._groupButtonFocused && this._groupIndex >= 0)
		{
			this._state = FavoritesMenu.GROUP_REMOVE_SYNC;
			skse.SendModEvent("SKIFM_groupRemove", String(itemId), this._groupIndex);
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
		}
	}

	private function endGroupRemoval()
	{
		this._state = FavoritesMenu.ITEM_SELECT;
	}

	private function requestGroupUse()
	{
		if (this._groupButtonFocused && this._groupIndex >= 0 && this.itemList.listEnumeration.size() > 0)
		{
			skse.SendModEvent("SKIFM_groupUse", "", this._groupIndex);
			this.startFadeOut();
		}
	}

	private function startSaveEquipState()
	{
		this.leftHandItemId = 0;
		this.rightHandItemId = 0;

		var n = this.itemList.entryList.length;
		var i = 0;
		var e;
		while (i < n)
		{
			e = this.itemList.entryList[i];
			if (e.equipState == 2)
			{
				this.leftHandItemId = e.itemId;
			}
			else if (e.equipState == 3)
			{
				this.rightHandItemId = e.itemId;
			}
			else if (e.equipState == 4)
			{
				this.leftHandItemId = e.itemId;
				this.rightHandItemId = e.itemId;
			}
			i = i + 1;
		}

		var selectedEntry = this.itemList.selectedEntry;
		if (this._groupButtonFocused && this._groupIndex >= 0)
		{
			this._state = FavoritesMenu.SAVE_EQUIP_STATE_SYNC;
			skse.SendModEvent("SKIFM_saveEquipState", "", this._groupIndex);
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
		}
	}

	private function endSaveEquipState()
	{
		this._state = FavoritesMenu.ITEM_SELECT;
	}

	private function startSetGroupIcon()
	{
		var itemId = this.itemList.selectedEntry.itemId;
		var formId = this.itemList.selectedEntry.formId;
		if (this._groupButtonFocused && this._groupIndex >= 0 && formId)
		{
			this._state = FavoritesMenu.SET_ICON_SYNC;
			skse.SendModEvent("SKIFM_setGroupIcon", String(itemId), this._groupIndex, formId);
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
		}
	}

	private function endSetGroupIcon()
	{
		this._state = FavoritesMenu.ITEM_SELECT;
	}

	private function enableGroupButtons(a_enabled)
	{
		if (a_enabled && !this._groupButtonsShown)
		{
			this._groupButtonsShown = true;
			this.groupButtonFader.gotoAndPlay("show");
		}
		var t = !a_enabled;
		var i = 1;
		while (i <= 8)
		{
			this.groupButtonFader.groupButtonHolder["btnGroup" + i].disabled = t;
			i = i + 1;
		}
	}

	private function setGroupFocus(a_focus)
	{
		if (a_focus)
		{
			if (this._groupButtonsShown)
			{
				this._groupButtonGroup.setSelectedButton(this._groupButtonGroup.getButtonAt(this._groupIndex));
			}
		}
		else
		{
			this._categoryButtonGroup.setSelectedButton(this._categoryButtonGroup.getButtonAt(this._categoryIndex));
		}
	}

	// Added to prevent clicks on the scrollbar from equipping/using stuff
	private function confirmSelectedEntry()
	{
		// only allow item selection while in item select state
		if (this._state != FavoritesMenu.ITEM_SELECT)
		{
			return false;
		}
		// only confirm when using mouse
		if (this._platform != 0 || !this._useMouseNavigation)
		{
			return true;
		}
		var e = Mouse.getTopMostEntity();
		while (e != undefined)
		{
			if (e.itemIndex == this.itemList.selectedIndex)
			{
				return true;
			}
			e = e._parent;
		}
		return false;
	}

	private function saveIndices()
	{
		var indicesIn = [this._categoryIndex, this._groupIndex, this.itemList.selectedIndex, this.itemList.scrollPosition];
		skse.StoreIndices("SKI_FavoritesMenuState", indicesIn);
	}

	private function restoreIndices()
	{
		var indicesOut = [];
		skse.LoadIndices("SKI_FavoritesMenuState", indicesOut);
		if (indicesOut.length != 4)
		{
			return undefined;
		}
		this._categoryIndex = indicesOut[0];
		this._groupIndex = indicesOut[1];
		this.itemList.listState.restoredSelectedIndex = indicesOut[2];
		this.itemList.listState.restoredScrollPosition = indicesOut[3];
		this.itemList.onInvalidate = function()
		{
			this.scrollPosition = this.listState.restoredScrollPosition;
			this.selectedIndex = this.listState.restoredSelectedIndex;
			delete this.onInvalidate;
		};
	}

	private function updateNavButtons()
	{
		if (this._state != FavoritesMenu.ITEM_SELECT || !this._navPanelEnabled || !this._fadedIn || this._waitingForGroupData)
		{
			this.navPanel._visible = false;
			return undefined;
		}

		var isListFilled = this.itemList.listEnumeration.size() > 0;
		var isEntrySelected = this.itemList.selectedEntry != null;

		this.navPanel._visible = true;

		var row1 = this.navPanel.row1;
		var row2 = this.navPanel.row2;
		var twoRows = false;

		row1.clearButtons();
		row1.addButton({text: "$Toggle Focus", controls: this._toggleFocusControls});
		if (isEntrySelected)
		{
			row1.addButton({text: (!this._groupButtonFocused ? "$Group" : "$Ungroup"), controls: this._groupAddControls});
		}
		row1.updateButtons(true);

		row2.clearButtons();
		if (this._groupButtonFocused && isListFilled)
		{
			twoRows = true;
			row2.addButton({text: "$Group Use", controls: this._groupUseControls});
			row2.addButton({text: "$Save Equip State", controls: this._saveEquipStateControls});
			if (isEntrySelected)
			{
				row2.addButton({text: "$Set Group Icon", controls: this._setIconControls});
			}
		}
		row2.updateButtons(true);

		row1._x = - row1._width / 2;
		row1._y = !twoRows ? 35 : 10;
		row2._x = - row2._width / 2;
		row2._y = 65;
	}

	private function createControls()
	{
		this._groupAddControls = {keyCode: this._groupAddKey};
		this._groupUseControls = {keyCode: this._groupUseKey};
		this._setIconControls = {keyCode: this._setIconKey};
		this._saveEquipStateControls = {keyCode: this._saveEquipStateKey};
		this._toggleFocusControls = {keyCode: this._toggleFocusKey};
	}
}
