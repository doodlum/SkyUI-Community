class ItemMenu extends MovieClip
{
  /* PRIVATE VARIABLES */

	private var _platform;
	private var _bItemCardFadedIn = false;
	private var _bItemCardPositioned = false;

	private var _quantityMinCount = 5;

	private var _config;

	private var _bPlayBladeSound;

	private var _searchKey;
	private var _switchTabKey;

	private var _acceptControls;
	private var _cancelControls;
	private var _searchControls;
	private var _switchControls;
	private var _sortColumnControls;
	private var _sortOrderControls;


  /* STAGE ELEMENTS */

	public var inventoryLists;

	public var itemCardFadeHolder;

	public var bottomBar;

	public var mouseRotationRect;
	public var exitMenuRect;


  /* PROPERTIES */

	public var itemCard;

	public var navPanel;

	public var bEnableTabs = false;

	// @GFx
	public var bPCControlsReady = true;

	public var bFadedIn = true;


  /* INITIALIZATION */

	public function ItemMenu()
	{
		super();

		itemCard = itemCardFadeHolder.ItemCard_mc;
		navPanel = bottomBar.buttonPanel;

		Mouse.addListener(this);
		skyui.util.ConfigManager.registerLoadCallback(this, "onConfigLoad");

		bFadedIn = true;
		_bItemCardFadedIn = false;
	}


  /* PUBLIC FUNCTIONS */

	// @API
	public function InitExtensions(a_bPlayBladeSound)
	{
		skse.ExtendData(true);
		skse.ForceContainerCategorization(true);

		_bPlayBladeSound = a_bPlayBladeSound;

		inventoryLists.InitExtensions();

		if (bEnableTabs) {
			inventoryLists.enableTabBar();
		}

		gfx.io.GameDelegate.addCallBack("UpdatePlayerInfo", this, "UpdatePlayerInfo");
		gfx.io.GameDelegate.addCallBack("UpdateItemCardInfo", this, "UpdateItemCardInfo");
		gfx.io.GameDelegate.addCallBack("ToggleMenuFade", this, "ToggleMenuFade");
		gfx.io.GameDelegate.addCallBack("RestoreIndices", this, "RestoreIndices");

		inventoryLists.addEventListener("categoryChange", this, "onCategoryChange");
		inventoryLists.addEventListener("itemHighlightChange", this, "onItemHighlightChange");
		inventoryLists.addEventListener("showItemsList", this, "onShowItemsList");
		inventoryLists.addEventListener("hideItemsList", this, "onHideItemsList");

		inventoryLists.itemList.addEventListener("itemPress", this, "onItemSelect");

		itemCard.addEventListener("quantitySelect", this, "onQuantityMenuSelect");
		itemCard.addEventListener("subMenuAction", this, "onItemCardSubMenuAction");

		positionFixedElements();

		itemCard._visible = false;
		navPanel.hideButtons();

		exitMenuRect.onMouseDown = function()
		{
			if (this._parent.bFadedIn == true && Mouse.getTopMostEntity() == this) {
				this._parent.onExitMenuRectClick();
			}
		};
	}

	public function setConfig(a_config)
	{
		_config = a_config;

		positionFloatingElements();

		var itemListState = inventoryLists.itemList.listState;
		var categoryListState = inventoryLists.categoryList.listState;
		var appearance = a_config.Appearance;

		categoryListState.iconSource = appearance.icons.category.source;

		itemListState.iconSource = appearance.icons.item.source;
		itemListState.showStolenIcon = appearance.icons.item.showStolen;

		itemListState.defaultEnabledColor = appearance.colors.text.enabled;
		itemListState.negativeEnabledColor = appearance.colors.negative.enabled;
		itemListState.stolenEnabledColor = appearance.colors.stolen.enabled;
		itemListState.defaultDisabledColor = appearance.colors.text.disabled;
		itemListState.negativeDisabledColor = appearance.colors.negative.disabled;
		itemListState.stolenDisabledColor = appearance.colors.stolen.disabled;

		_quantityMinCount = a_config.ItemList.quantityMenu.minCount;

		var previousColumnKey;
		var nextColumnKey;
		var sortOrderKey;
		if (_platform == 0) {
			_switchTabKey = a_config.Input.controls.pc.switchTab;
		} else {
			_switchTabKey = a_config.Input.controls.gamepad.switchTab;
			previousColumnKey = a_config.Input.controls.gamepad.prevColumn;
			nextColumnKey = a_config.Input.controls.gamepad.nextColumn;
			sortOrderKey = a_config.Input.controls.gamepad.sortOrder;
			_sortColumnControls = [{keyCode: previousColumnKey}, {keyCode: nextColumnKey}];
			_sortOrderControls = {keyCode: sortOrderKey};
		}

		_switchControls = {keyCode: _switchTabKey};

		_searchKey = a_config.Input.controls.pc.search;
		_searchControls = {keyCode: _searchKey};

		updateBottomBar(false);
	}

	// @API
	public function SetPlatform(a_platform, a_bPS3Switch)
	{
		_platform = a_platform;

		if (a_platform == 0) {
			_acceptControls = skyui.defines.Input.Enter;
			_cancelControls = skyui.defines.Input.Tab;

			// Defaults
			_switchControls = skyui.defines.Input.Alt;
		} else {
			_acceptControls = skyui.defines.Input.Accept;
			_cancelControls = skyui.defines.Input.Cancel;

			// Defaults
			_switchControls = skyui.defines.Input.GamepadBack;
			_sortColumnControls = skyui.defines.Input.SortColumn;
			_sortOrderControls = skyui.defines.Input.SortOrder;
		}

		// Defaults
		_searchControls = skyui.defines.Input.Space;

		inventoryLists.setPlatform(a_platform, a_bPS3Switch);
		itemCard.SetPlatform(a_platform, a_bPS3Switch);
		bottomBar.setPlatform(a_platform, a_bPS3Switch);
	}

	// @API
	public function GetInventoryItemList()
	{
		return inventoryLists.itemList;
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		if (!bFadedIn)
			return true;

		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;

		if (Shared.GlobalFunc.IsKeyPressed(details) && (details.navEquivalent == gfx.ui.NavigationCode.TAB || details.navEquivalent == gfx.ui.NavigationCode.SHIFT_TAB)) {
			gfx.io.GameDelegate.call("CloseMenu", []);
		}

		return true;
	}

	// @API
	public function UpdatePlayerInfo(aUpdateObj)
	{
		bottomBar.UpdatePlayerInfo(aUpdateObj, itemCard.itemInfo);
	}

	// @API
	public function UpdateItemCardInfo(aUpdateObj)
	{
		itemCard.itemInfo = aUpdateObj;
		bottomBar.updatePerItemInfo(aUpdateObj);
	}

	// @API
	public function ToggleMenuFade()
	{
		if (bFadedIn) {
			_parent.gotoAndPlay("fadeOut");
			bFadedIn = false;
			inventoryLists.itemList.disableSelection = true;
			inventoryLists.itemList.disableInput = true;
			inventoryLists.categoryList.disableSelection = true;
			inventoryLists.categoryList.disableInput = true;
		} else {
			_parent.gotoAndPlay("fadeIn");
		}
	}

	// @API
	public function SetFadedIn()
	{
		bFadedIn = true;
		inventoryLists.itemList.disableSelection = false;
		inventoryLists.itemList.disableInput = false;
		inventoryLists.categoryList.disableSelection = false;
		inventoryLists.categoryList.disableInput = false;
	}

	// @API
	public function RestoreIndices()
	{
		var categoryList = inventoryLists.categoryList;
		var itemList = inventoryLists.itemList;

		if (arguments[0] != undefined && arguments[0] != -1 && arguments.length == 5) {
			categoryList.listState.restoredItem = arguments[0];
			categoryList.onUnsuspend = function()
			{
				this.onItemPress(this.listState.restoredItem, 0);
				delete this.onUnsuspend;
			};

			itemList.listState.restoredScrollPosition = arguments[2];
			itemList.listState.restoredSelectedIndex = arguments[1];
			itemList.listState.restoredActiveColumnIndex = arguments[3];
			itemList.listState.restoredActiveColumnState = arguments[4];

			itemList.onUnsuspend = function()
			{
				this.onInvalidate = function()
				{
					this.scrollPosition = this.listState.restoredScrollPosition;
					this.selectedIndex = this.listState.restoredSelectedIndex;
					delete this.onInvalidate;
				};
				this.layout.restoreColumnState(this.listState.restoredActiveColumnIndex, this.listState.restoredActiveColumnState);
				delete this.onUnsuspend;
			};
		} else {
			categoryList.onUnsuspend = function()
			{
				this.onItemPress(1, 0); // ALL
				delete this.onUnsuspend;
			};
		}
	}


  /* PRIVATE FUNCTIONS */

	public function onItemCardSubMenuAction(event)
	{
		if (event.opening == true) {
			inventoryLists.itemList.disableSelection = true;
			inventoryLists.itemList.disableInput = true;
			inventoryLists.categoryList.disableSelection = true;
			inventoryLists.categoryList.disableInput = true;
		} else if (event.opening == false) {
			inventoryLists.itemList.disableSelection = false;
			inventoryLists.itemList.disableInput = false;
			inventoryLists.categoryList.disableSelection = false;
			inventoryLists.categoryList.disableInput = false;
		}
	}

	private function onConfigLoad(event)
	{
		setConfig(event.config);

		inventoryLists.showPanel(_bPlayBladeSound);
	}

	private function onMouseWheel(delta)
	{
		var target = Mouse.getTopMostEntity();
		while (target != undefined) {
			if (target == mouseRotationRect && shouldProcessItemsListInput(false) || !bFadedIn && delta == -1) {
				gfx.io.GameDelegate.call("ZoomItemModel", [delta]);
				break;
			}
			target = target._parent;
		}
	}

	private function onExitMenuRectClick()
	{
		gfx.io.GameDelegate.call("CloseMenu", []);
	}

	private function onCategoryChange(event)
	{
	}

	private function onItemHighlightChange(event)
	{
		if (event.index != -1) {
			if (!_bItemCardFadedIn) {
				_bItemCardFadedIn = true;
				if (_bItemCardPositioned) {
					itemCard.FadeInCard();
				}
			}
			if (_bItemCardPositioned) {
				gfx.io.GameDelegate.call("UpdateItem3D", [true]);
			}
			gfx.io.GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
		} else {
			if (!bFadedIn) {
				resetMenu();
			}
			if (_bItemCardFadedIn) {
				_bItemCardFadedIn = false;
				onHideItemsList();
			}
		}
	}

	private function onShowItemsList(event)
	{
		onItemHighlightChange(event);
	}

	private function onHideItemsList(event)
	{
		gfx.io.GameDelegate.call("UpdateItem3D", [false]);
		itemCard.FadeOutCard();
	}

	private function onItemSelect(event)
	{
		if (event.entry.enabled) {
			if (_quantityMinCount < 1 || event.entry.count < _quantityMinCount) {
				onQuantityMenuSelect({amount:1});
			} else {
				itemCard.ShowQuantityMenu(event.entry.count);
			}
		} else {
			gfx.io.GameDelegate.call("DisabledItemSelect", []);
		}
	}

	private function onQuantityMenuSelect(event)
	{
		gfx.io.GameDelegate.call("ItemSelect", [event.amount]);
	}

	private function onMouseRotationStart()
	{
		gfx.io.GameDelegate.call("StartMouseRotation", []);
		inventoryLists.categoryList.disableSelection = true;
		inventoryLists.itemList.disableSelection = true;
	}

	private function onMouseRotationStop()
	{
		gfx.io.GameDelegate.call("StopMouseRotation", []);
		inventoryLists.categoryList.disableSelection = false;
		inventoryLists.itemList.disableSelection = false;
	}

	private function onMouseRotationFastClick()
	{
		if (shouldProcessItemsListInput(false)) {
			onItemSelect({entry: inventoryLists.itemList.selectedEntry, keyboardOrMouse: 0});
		}
	}

	private function saveIndices()
	{
		var a = new Array();

		// Save selected category, selected item and relative scroll position
		a.push(inventoryLists.categoryList.selectedIndex);
		a.push(inventoryLists.itemList.selectedIndex);
		a.push(inventoryLists.itemList.scrollPosition);
		a.push(inventoryLists.itemList.layout.activeColumnIndex);
		a.push(inventoryLists.itemList.layout.activeColumnState);

		gfx.io.GameDelegate.call("SaveIndices", [a]);
	}

	private function positionFixedElements()
	{
		Shared.GlobalFunc.SetLockFunction();

		inventoryLists.Lock("L");
		inventoryLists._x -= 20;

		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;

		bottomBar.positionElements(leftEdge, rightEdge);

		MovieClip(exitMenuRect).Lock("TL");
		exitMenuRect._x -= Stage.safeRect.x;
		exitMenuRect._y -= Stage.safeRect.y;
	}

	private function positionFloatingElements()
	{
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;

		var contentBounds = inventoryLists.getContentBounds();
		// 25 is hardcoded cause thats the final offset after the animation of the panel container is done
		var panelEdge = inventoryLists._x + contentBounds[0] + contentBounds[2] + 25;

		var itemCardContainer = itemCard._parent;
		var itemcardPosition = _config.ItemInfo.itemcard;
		var itemiconPosition = _config.ItemInfo.itemicon;

		var scaleMult = (rightEdge - panelEdge) / itemCardContainer._width;

		// Scale down if necessary
		if (scaleMult < 1) {
			itemCardContainer._width *= scaleMult;
			itemCardContainer._height *= scaleMult;
			itemiconPosition.scale *= scaleMult;
		}

		if (itemcardPosition.align == "left") {
			itemCardContainer._x = panelEdge + leftEdge + itemcardPosition.xOffset;
		} else if (itemcardPosition.align == "right") {
			itemCardContainer._x = rightEdge - itemCardContainer._width + itemcardPosition.xOffset;
		} else {
			itemCardContainer._x = panelEdge + itemcardPosition.xOffset + (Stage.visibleRect.x + Stage.visibleRect.width - panelEdge - itemCardContainer._width) / 2;
		}

		itemCardContainer._y += itemcardPosition.yOffset;

		if (mouseRotationRect != undefined) {
			MovieClip(mouseRotationRect).Lock("T");
			mouseRotationRect._x = itemCard._parent._x;
			mouseRotationRect._width = itemCardContainer._width;
			mouseRotationRect._height = 0.55 * Stage.visibleRect.height;
		}

		_bItemCardPositioned = true;

		// Delayed fade in if positioned wasn't set
		if (_bItemCardFadedIn) {
			gfx.io.GameDelegate.call("UpdateItem3D", [true]);
			itemCard.FadeInCard();
		}
	}

	private function shouldProcessItemsListInput(abCheckIfOverRect)
	{
		var process = bFadedIn == true && inventoryLists.currentState == InventoryLists.SHOW_PANEL && inventoryLists.itemList.itemCount > 0 && !inventoryLists.itemList.disableSelection && !inventoryLists.itemList.disableInput;

		var target;
		var found;
		if (process && _platform == 0 && abCheckIfOverRect) {
			target = Mouse.getTopMostEntity();
			found = false;
			while (!found && target != undefined) {
				if (target == inventoryLists.itemList) {
					found = true;
				}
				target = target._parent;
			}
			process = process && found;
		}
		return process;
	}

	// Added to prevent clicks on the scrollbar from equipping/using stuff
	private function confirmSelectedEntry()
	{
		// only confirm when using mouse
		if (_platform != 0)
			return true;

		var target = Mouse.getTopMostEntity();
		while (target != undefined) {
			if (target.itemIndex == inventoryLists.itemList.selectedIndex) {
				return true;
			}
			target = target._parent;
		}
		return false;
	}

	/*
		This method is only used for the InventoryMenu Favorites Category.
		It prevents a lockup when unfavoriting the last item from favorites list by
		resetting the menu.
	 */
	private function resetMenu()
	{
		saveIndices();
		gfx.io.GameDelegate.call("CloseMenu", []);
		skse.OpenMenu("Inventory Menu");
	}

	/*
		This method is only used in InventoryMenu and ContainerMenu.
		It it allows determination of read books.
		Item list isn't re-sent when you activate a book, unlike other items,
		 so the flags don't get updated.
		If the item is a book, we apply the book read flag and invalidate locally
	*/
	private function checkBook(a_entryObject)
	{
		if (a_entryObject.type != skyui.defines.Inventory.ICT_BOOK || _global.skse == null)
			return false;

		a_entryObject.flags |= skyui.defines.Item.BOOKFLAG_READ;
		a_entryObject.skyui_itemDataProcessed = false;

		inventoryLists.itemList.requestInvalidate();

		return true;
	}

	private function getEquipButtonData(a_itemType, a_bAlwaysEquip)
	{
		var btnData = {};

		var useControls = skyui.defines.Input.Activate;
		var equipControls = skyui.defines.Input.Equip;

		switch (a_itemType)
		{
			case skyui.defines.Inventory.ICT_ARMOR:
				btnData.text = "$Equip";
				btnData.controls = !a_bAlwaysEquip ? useControls : equipControls;
				break;
			case skyui.defines.Inventory.ICT_BOOK:
				btnData.text = "$Read";
				btnData.controls = !a_bAlwaysEquip ? useControls : equipControls;
				break;
			case skyui.defines.Inventory.ICT_FOOD:
			case skyui.defines.Inventory.ICT_INGREDIENT:
				btnData.text = "$Eat";
				btnData.controls = !a_bAlwaysEquip ? useControls : equipControls;
				break;
			case skyui.defines.Inventory.ICT_WEAPON:
				btnData.text = "$Equip";
				btnData.controls = equipControls;
				break;
			default:
				btnData.text = "$Use";
				btnData.controls = !a_bAlwaysEquip ? useControls : equipControls;
		}

		return btnData;
	}

	private function updateBottomBar(a_bSelected)
	{
	}
}
