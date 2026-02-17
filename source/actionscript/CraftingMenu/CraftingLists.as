class CraftingLists extends MovieClip
{
	/* CONSTANTS */

	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = CraftingLists.SKYUI_VERSION_MAJOR + "." + CraftingLists.SKYUI_VERSION_MINOR + " SE";

	static var HIDE_PANEL = 0;
	static var SHOW_PANEL = 1;
	static var TRANSITIONING_TO_HIDE_PANEL = 2;
	static var TRANSITIONING_TO_SHOW_PANEL = 3;

	static var SHORT_LIST_OFFSET = 210;


	/* STAGE ELEMENTS */

	public var panelContainer;


	/* PRIVATE VARIABLES */

	private var _typeFilter;
	private var _nameFilter;
	private var _sortFilter;

	private var _platform;

	private var _currCategoryIndex;
	private var _savedSelectionIndex = -1;

	private var _searchKey = -1;
	private var _sortOrderKey = -1;
	private var _sortOrderKeyHeld = false;

	private var _columnSelectDialog;
	private var _columnSelectInterval;

	private var _subtypeName;

	private var _bFocusItemList = true;


	/* PROPERTIES */

	public var itemList;

	// @API
	public var CategoriesList;

	public var searchWidget;

	public var categoryLabel;

	public var columnSelectButton;

	private var _currentState;

	public function get currentState()
	{
		return _currentState;
	}

	public function set currentState(a_newState)
	{
		if (a_newState == SHOW_PANEL)
			gfx.managers.FocusHandler.instance.setFocus(itemList, 0);

		_currentState = a_newState;
	}


	/* INITIALIZATION */

	public function CraftingLists()
	{
		super();

		skyui.util.GlobalFunctions.addArrayFunctions();

		gfx.events.EventDispatcher.initialize(this);

		gotoAndStop("NoPanels");

		gfx.io.GameDelegate.addCallBack("SetCategoriesList", this, "SetCategoriesList");
		gfx.io.GameDelegate.addCallBack("InvalidateListData", this, "InvalidateListData");

		_typeFilter = new skyui.filter.ItemTypeFilter();
		_nameFilter = new skyui.filter.NameFilter();
		_sortFilter = new skyui.filter.SortFilter();

		categoryLabel = panelContainer.categoryLabel;
		CategoriesList = panelContainer.categoriesList; // Note: Re-assigned later if alchemy
		itemList = panelContainer.itemList;
		searchWidget = panelContainer.searchWidget;
		columnSelectButton = panelContainer.columnSelectButton;

		skyui.util.ConfigManager.registerLoadCallback(this, "onConfigLoad");
		skyui.util.ConfigManager.registerUpdateCallback(this, "onConfigUpdate");

		// Hide by default, maybe show later
		panelContainer.effectsList._visible = false;
	}


	/* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent;
	public var dispatchQueue;
	public var hasEventListener;
	public var addEventListener;
	public var removeEventListener;
	public var removeAllEventListeners;
	public var cleanUpEvents;

	// @mixin by Shared.GlobalFunc
	public var Lock;

	public var onUnsuspend;

	public function InitExtensions(a_subtypeName)
	{
		_subtypeName = a_subtypeName;

		// Alchemy uses a different layout
		if (_subtypeName == "Alchemy") {
			panelContainer.gotoAndStop("no_categories");

			// Hide top icon category bar, use effects list instead
			CategoriesList._visible = false;
			CategoriesList = panelContainer.effectsList;
			CategoriesList._visible = true;

			itemList.gotoAndStop("short");
			itemList.leftBorder = SHORT_LIST_OFFSET;
			itemList.listHeight = 560;

		// Support for custom categorization
		} else if (_subtypeName == "ConstructibleObject") {
			itemList.addDataProcessor(new CustomConstructDataSetter());

		// Smithing doesn't need top icon categories
		} else if (_subtypeName == "Smithing") {
			panelContainer.gotoAndStop("no_categories");
			CategoriesList._visible = false;
			itemList.listHeight = 560;
		}

		var listEnumeration = new skyui.components.list.FilteredEnumeration(itemList.entryList);
		listEnumeration.addFilter(_typeFilter);
		listEnumeration.addFilter(_nameFilter);
		listEnumeration.addFilter(_sortFilter);
		itemList.listEnumeration = listEnumeration;

		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		_nameFilter.addEventListener("filterChange", this, "onFilterChange");
		_sortFilter.addEventListener("filterChange", this, "onFilterChange");

		CategoriesList.listEnumeration = new skyui.components.list.BasicEnumeration(CategoriesList.entryList);

		itemList.listState.maxTextLength = 80;

		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		_nameFilter.addEventListener("filterChange", this, "onFilterChange");
		_sortFilter.addEventListener("filterChange", this, "onFilterChange");

		CategoriesList.addEventListener("itemPress", this, "onCategoriesItemPress");
		CategoriesList.addEventListener("itemPressAux", this, "onCategoriesItemPress");
		CategoriesList.addEventListener("selectionChange", this, "onCategoriesListSelectionChange");

		itemList.disableInput = false;

		itemList.addEventListener("selectionChange", this, "onItemsListSelectionChange");
		itemList.addEventListener("sortChange", this, "onSortChange");
		itemList.addEventListener("itemPress", this, "onItemPress");

		searchWidget.addEventListener("inputStart", this, "onSearchInputStart");
		searchWidget.addEventListener("inputEnd", this, "onSearchInputEnd");
		searchWidget.addEventListener("inputChange", this, "onSearchInputChange");

		columnSelectButton.addEventListener("press", this, "onColumnSelectButtonPress");

		itemList.onInvalidate = mx.utils.Delegate.create(this, onItemListInvalidate);

		CategoriesList.onUnsuspend = function()
		{
			// this == CategoriesList
			this.onItemPress(0, 0); // Select first category
			delete this.onUnsuspend;
		};

		// Delay updates until config is ready
		CategoriesList.suspended = true;
		itemList.suspended = true;
	}

	public function showPanel(a_bPlayBladeSound)
	{
		// Release itemlist for updating
		CategoriesList.suspended = false;
		itemList.suspended = false;

		_currentState = TRANSITIONING_TO_SHOW_PANEL;
		gotoAndPlay("PanelShow");

		dispatchEvent({type:"categoryChange", index:CategoriesList.selectedIndex});

		if (a_bPlayBladeSound != false)
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
	}

	public function hidePanel()
	{
		_currentState = TRANSITIONING_TO_HIDE_PANEL;
		gotoAndPlay("PanelHide");

		gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeCloseSD"]);
	}

	public function setPlatform(a_platform, a_bPS3Switch)
	{
		_platform = a_platform;

		CategoriesList.setPlatform(a_platform, a_bPS3Switch);
		itemList.setPlatform(a_platform, a_bPS3Switch);
	}

	public function setPartitionedFilterMode(a_bPartitioned)
	{
		_typeFilter.setPartitionedFilterMode(a_bPartitioned);
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		if (_currentState != SHOW_PANEL)
			return false;

		if (_platform != 0) {
			if (details.skseKeycode == _sortOrderKey) {
				if (details.value == "keyDown") {
					_sortOrderKeyHeld = true;

					if (_columnSelectDialog)
						skyui.util.DialogManager.close();
					else
						_columnSelectInterval = setInterval(this, "onColumnSelectButtonPress", 1000, {type:"timeout"});

					return true;
				} else if (details.value == "keyUp") {
					_sortOrderKeyHeld = false;

					if (_columnSelectInterval == undefined)
						// keyPress handled: Key was released after the interval expired, don't process any further
						return true;

					// keyPress not handled: Clear intervals and change value to keyDown to be processed later
					clearInterval(_columnSelectInterval);
					delete _columnSelectInterval;
					// Continue processing the event as a normal keyDown event
					details.value = "keyDown";
				} else if (_sortOrderKeyHeld && details.value == "keyHold") {
					// Fix for opening journal menu while key is depressed
					// For some reason this is the only time we receive a keyHold event
					_sortOrderKeyHeld = false;

					if (_columnSelectDialog)
						skyui.util.DialogManager.close();

					return true;
				}
			}

			if (_sortOrderKeyHeld) // Disable extra input while interval is active
				return true;
		}

		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			// Search hotkey (default space)
			if (details.skseKeycode == _searchKey) {
				searchWidget.startInput();
				return true;
			}
		}

		if (_subtypeName == "Alchemy") {
			if (handleAlchemyNavigation(details, pathToFocus))
				return true;
		} else {
			if (CategoriesList.handleInput(details, pathToFocus))
				return true;
		}

		var nextClip = pathToFocus.shift();
		return nextClip.handleInput(details, pathToFocus);
	}

	public function getContentBounds()
	{
		var lb = panelContainer.ListBackground;
		return [lb._x, lb._y, lb._width, lb._height];
	}

	public function showItemsList()
	{
		_currCategoryIndex = CategoriesList.selectedIndex;

		categoryLabel.textField.SetText(CategoriesList.selectedEntry.text.toUpperCase());

		// Start with no selection
		itemList.selectedIndex = -1;
		itemList.scrollPosition = 0;

		var catFlag;
		if (CategoriesList.selectedEntry != undefined) {
			catFlag = CategoriesList.selectedEntry.flag;

			// Set filter type
			_typeFilter.changeFilterFlag(catFlag);

			// Not set yet before the config is loaded
			itemList.layout.changeFilterFlag(catFlag);
		}

		itemList.requestUpdate();

		dispatchEvent({type:"showItemsList", index:itemList.selectedIndex});

		itemList.disableInput = false;
	}

	// Called to initially set the category list.
	// @API
	public function SetCategoriesList()
	{
		var textOffset = 0;
		var flagOffset = 1;
		var bDontHideOffset = 2;
		var len = 3;

		CategoriesList.clearList();

		var i = 0;
		var index = 0;
		var entry;
		while (i < arguments.length) {
			entry = {text:arguments[i + textOffset], flag:arguments[i + flagOffset], bDontHide:arguments[i + bDontHideOffset], savedItemIndex:0, filterFlag:(arguments[i + bDontHideOffset] != true ? 0 : 1)};

			if (entry.flag == 0) {
				entry.divider = true;
			}

			entry.enabled = false;

			CategoriesList.entryList.push(entry);
			i += len;
			index++;
		}

		// We have enough information to init the art now.
		// But the list has not been invalidated, so no clips have been loaded yet.
		preprocessCategoriesList();

		CategoriesList.selectedIndex = 0;
		CategoriesList.InvalidateData();
	}

	// Called whenever the underlying entryList data is updated (using an item, equipping etc.)
	// @API
	public function InvalidateListData()
	{
		itemList.InvalidateData();
	}


	/* PRIVATE FUNCTIONS */

	private function handleAlchemyNavigation(details, pathToFocus)
	{
		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == gfx.ui.NavigationCode.LEFT) {
				if (!_bFocusItemList)
					return true;

				_savedSelectionIndex = itemList.selectedIndex;
				itemList.selectedIndex = -1;

				// Moving from Item list to Category List
				_bFocusItemList = false;
				return true;

			} else if (details.navEquivalent == gfx.ui.NavigationCode.RIGHT) {
				if (_bFocusItemList)
					return true;

				if (_savedSelectionIndex == -1) {
					itemList.selectDefaultIndex(true);
				} else {
					itemList.selectedIndex = _savedSelectionIndex;
				}

				// Moving from Category list to Item List
				_bFocusItemList = true;
				return true;
			}

			// Ok thats a bit weird but whatever...:
			// Itemlist always has focus, but if this flag is false, categories list gets to run first.
			// Since both use the same nav scheme, category list wins.
			if (!_bFocusItemList) {
				if (CategoriesList.handleInput(details, pathToFocus)) {
					// Clear saved index
					_savedSelectionIndex = -1;

					return true;
				}
			}
		}

		return false;
	}

	private function onHideCategoriesList(event)
	{
		itemList.listHeight = 579;
	}

	private function onConfigLoad(event)
	{
		var config = event.config;
		_searchKey = config.Input.controls.pc.search;

		if (_platform != 0) {
			_sortOrderKey = config.Input.controls.gamepad.sortOrder;
		}
	}

	private function onItemListInvalidate()
	{
		// Set enabled == false for empty categories
		var i;
		var j;
		if (_subtypeName != "Alchemy") {
			i = 0;
			while (i < CategoriesList.entryList.length) {
				j = 0;
				while (j < itemList.entryList.length) {
					if (_typeFilter.isMatch(itemList.entryList[j], CategoriesList.entryList[i].flag)) {
						CategoriesList.entryList[i].enabled = true;
						break;
					}
					j = j + 1;
				}
				i = i + 1;
			}
		}

		// Grey out any categories that are not enabled
		CategoriesList.UpdateList();

		// This is called when an ItemCard list closes(ex. ShowSoulGemList) to refresh ItemCard data
		if (itemList.selectedIndex == -1)
			dispatchEvent({type:"showItemsList", index:-1});
		else
			dispatchEvent({type:"itemHighlightChange", index:itemList.selectedIndex});
	}

	private function preprocessCategoriesList()
	{
		// EnchantConstruct - Set icon art, but leave default categories as they are.
		if (_subtypeName == "EnchantConstruct") {
			CategoriesList.iconArt = ["ench_disentchant", "separator", "ench_item", "ench_effect", "ench_soul"];

		// Smithing - Set icon art, but leave default categories as they are.
		} else if (_subtypeName == "Smithing") {
			CategoriesList.iconArt = ["smithing"];

		// ConstructibleObject - Use a custom categorization scheme.
		} else if (_subtypeName == "ConstructibleObject") {
			CategoriesList.iconArt = ["construct_all", "weapon", "ammo", "armor", "jewelry", "food", "misc"];

			replaceConstructObjectCategories();

		// Alchemy - Use a custom categorization scheme.
		} else if (_subtypeName == "Alchemy") {
			fixupAlchemyCategories();
		}
	}

	private function replaceConstructObjectCategories()
	{
		CategoriesList.clearList();

		CategoriesList.entryList.push({text:"$ALL", flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_ALL, bDontHide:1, savedItemIndex:0, filterFlag:1, enabled:false});
		CategoriesList.entryList.push({text:"$WEAPONS", flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_WEAPONS, bDontHide:1, savedItemIndex:0, filterFlag:1, enabled:false});
		CategoriesList.entryList.push({text:"$AMMO", flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_AMMO, bDontHide:1, savedItemIndex:0, filterFlag:1, enabled:false});
		CategoriesList.entryList.push({text:skyui.util.Translator.translate("$Armor"), flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_ARMOR, bDontHide:1, savedItemIndex:0, filterFlag:1, enabled:false});
		CategoriesList.entryList.push({text:skyui.util.Translator.translate("$Jewelry"), flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_JEWELRY, bDontHide:1, savedItemIndex:0, filterFlag:1, enabled:false});
		CategoriesList.entryList.push({text:skyui.util.Translator.translate("$Food"), flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_FOOD, bDontHide:1, savedItemIndex:0, filterFlag:1, enabled:false});
		CategoriesList.entryList.push({text:skyui.util.Translator.translate("$Misc"), flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_MISC, bDontHide:1, savedItemIndex:0, filterFlag:1, enabled:false});
	}

	private function fixupAlchemyCategories()
	{
		// Ingredients category is always enabled
		CategoriesList.entryList[0].enabled = true;
		CategoriesList.entryList[0].iconLabel = "ingredients";

		// Old flag is type. New flag is index (was flag before skse ext.)
		var i = 1;
		var cat;
		while (i < CategoriesList.entryList.length) {
			cat = CategoriesList.entryList[i];

			if (cat.flag & skyui.defines.Inventory.FILTERFLAG_CUST_ALCH_GOOD)
				cat.iconLabel = "beneficial";
			else if (cat.flag & skyui.defines.Inventory.FILTERFLAG_CUST_ALCH_BAD)
				cat.iconLabel = "harmful";
			else if (cat.flag & skyui.defines.Inventory.FILTERFLAG_CUST_ALCH_OTHER)
				cat.iconLabel = "other";

			// Thats the index that was previously used as flag and sent by the game (without SKSE).
			cat.flag = i;
			i = i + 1;
		}
	}

	private function onFilterChange()
	{
		itemList.requestInvalidate();
	}

	private function onColumnSelectButtonPress(event)
	{
		if (event.type == "timeout") {
			clearInterval(_columnSelectInterval);
			delete _columnSelectInterval;
		}

		if (_columnSelectDialog) {
			skyui.util.DialogManager.close();
			return;
		}

		_savedSelectionIndex = itemList.selectedIndex;
		itemList.selectedIndex = -1;

		CategoriesList.disableSelection = CategoriesList.disableInput = true;
		itemList.disableSelection = itemList.disableInput = true;
		searchWidget.isDisabled = true;

		_columnSelectDialog = skyui.util.DialogManager.open(panelContainer, "ColumnSelectDialog", {_x:554, _y:35, layout:itemList.layout});
		_columnSelectDialog.addEventListener("dialogClosed", this, "onColumnSelectDialogClosed");
	}

	private function onColumnSelectDialogClosed(event)
	{
		CategoriesList.disableSelection = CategoriesList.disableInput = false;
		itemList.disableSelection = itemList.disableInput = false;
		searchWidget.isDisabled = false;

		itemList.selectedIndex = _savedSelectionIndex;
	}

	private function onConfigUpdate(event)
	{
		itemList.layout.refresh();
	}

	private function onItemPress()
	{
		_bFocusItemList = true;
		// CraftingMenu has a handler that does the actual work.
		// This is just for focus.
	}

	private function onCategoriesItemPress()
	{
		_bFocusItemList = false;
		showItemsList();
	}

	private function onCategoriesListSelectionChange(event)
	{
		dispatchEvent({type:"categoryChange", index:event.index});

		if (event.index != -1)
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}

	private function onItemsListSelectionChange(event)
	{
		dispatchEvent({type:"itemHighlightChange", index:event.index});

		if (event.index != -1)
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}

	private function onSortChange(event)
	{
		_sortFilter.setSortBy(event.attributes, event.options);
	}

	private function onSearchInputStart(event)
	{
		CategoriesList.disableSelection = CategoriesList.disableInput = true;
		itemList.disableSelection = itemList.disableInput = true;
		_nameFilter.filterText = "";
	}

	private function onSearchInputChange(event)
	{
		_nameFilter.filterText = event.data;
	}

	private function onSearchInputEnd(event)
	{
		CategoriesList.disableSelection = CategoriesList.disableInput = false;
		itemList.disableSelection = itemList.disableInput = false;
		_nameFilter.filterText = event.data;
	}
}
