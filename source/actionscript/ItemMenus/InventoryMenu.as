class InventoryMenu extends ItemMenu
{
	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = InventoryMenu.SKYUI_VERSION_MAJOR + "." + InventoryMenu.SKYUI_VERSION_MINOR + " SE";

  /* PRIVATE VARIABLES */

	private var _bMenuClosing = false;
	private var _bSwitchMenus = false;

	private var _categoryListIconArt;


  /* PROPERTIES */

	// @GFx
	public var bPCControlsReady = true;


  /* INITIALIZATION */

	public function InventoryMenu()
	{
		super();

		_categoryListIconArt = ["cat_favorites", "inv_all", "inv_weapons", "inv_armor",
								"inv_potions", "inv_scrolls", "inv_food", "inv_ingredients",
								"inv_books", "inv_keys", "inv_misc"];

		gfx.io.GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");
		gfx.io.GameDelegate.addCallBack("DropItem", this, "DropItem");
		gfx.io.GameDelegate.addCallBack("AttemptChargeItem", this, "AttemptChargeItem");
		gfx.io.GameDelegate.addCallBack("ItemRotating", this, "ItemRotating");
	}


  /* PUBLIC FUNCTIONS */

	// @override ItemMenu
	public function InitExtensions()
	{
		super.InitExtensions();

		Shared.GlobalFunc.AddReverseFunctions();

		inventoryLists.zoomButtonHolder.gotoAndStop(1);

		// Initialize menu-specific list components
		var categoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;

		itemCard.addEventListener("itemPress", this, "onItemCardListPress");
	}

	// @override ItemMenu
	public function setConfig(a_config)
	{
		super.setConfig(a_config);

		var itemList = inventoryLists.itemList;
		itemList.addDataProcessor(new InventoryDataSetter());
		itemList.addDataProcessor(new InventoryIconSetter(a_config.Appearance));
		itemList.addDataProcessor(new skyui.props.PropertyDataExtender(a_config.Appearance, a_config.Properties, "itemProperties", "itemIcons", "itemCompoundProperties"));

		var layout = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout, "ItemListLayout");
		itemList.layout = layout;

		// Not 100% happy with doing this here, but has to do for now.
		if (inventoryLists.categoryList.selectedEntry) {
			layout.changeFilterFlag(inventoryLists.categoryList.selectedEntry.flag);
		}
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		if (!bFadedIn)
			return true;

		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;

		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == gfx.ui.NavigationCode.TAB || details.navEquivalent == gfx.ui.NavigationCode.SHIFT_TAB) {
				startMenuFade();
				gfx.io.GameDelegate.call("CloseTweenMenu", []);
			} else if (!inventoryLists.itemList.disableInput) {
				// Gamepad back || ALT (default) || 'P'
				if (details.skseKeycode == _switchTabKey || details.control == "Quick Magic") {
					openMagicMenu(true);
				}
			}
		}

		return true;
	}

	// @API
	public function AttemptEquip(a_slot, a_bCheckOverList)
	{
		var bCheckOverList = a_bCheckOverList == undefined ? true : a_bCheckOverList;
		if (shouldProcessItemsListInput(bCheckOverList) && confirmSelectedEntry()) {
			gfx.io.GameDelegate.call("ItemSelect", [a_slot]);
			checkBook(inventoryLists.itemList.selectedEntry);
		}
	}

	// @API
	public function DropItem()
	{
		if (shouldProcessItemsListInput(false) && inventoryLists.itemList.selectedEntry != undefined) {
			if (_quantityMinCount < 1 || inventoryLists.itemList.selectedEntry.count < _quantityMinCount) {
				onQuantityMenuSelect({amount:1});
			} else {
				itemCard.ShowQuantityMenu(inventoryLists.itemList.selectedEntry.count);
			}
		}
	}

	// @API
	public function AttemptChargeItem()
	{
		if (inventoryLists.itemList.selectedIndex == -1)
			return;

		if (shouldProcessItemsListInput(false) && itemCard.itemInfo.charge != undefined && itemCard.itemInfo.charge < 100) {
			gfx.io.GameDelegate.call("ShowSoulGemList", []);
		}
	}

	// @override ItemMenu
	public function SetPlatform(a_platform, a_bPS3Switch)
	{
		inventoryLists.zoomButtonHolder.gotoAndStop(1);
		inventoryLists.zoomButtonHolder.ZoomButton._visible = a_platform != 0;
		inventoryLists.zoomButtonHolder.ZoomButton.SetPlatform(a_platform, a_bPS3Switch);

		super.SetPlatform(a_platform, a_bPS3Switch);
	}

	// @API
	public function ItemRotating()
	{
		inventoryLists.zoomButtonHolder.PlayForward(inventoryLists.zoomButtonHolder._currentframe);
	}


  /* PRIVATE FUNCTIONS */

	// @override ItemMenu
	private function onExitMenuRectClick()
	{
		startMenuFade();
		gfx.io.GameDelegate.call("ShowTweenMenu", []);
	}

	private function onFadeCompletion()
	{
		if (!_bMenuClosing)
			return;

		gfx.io.GameDelegate.call("CloseMenu", []);
		if (_bSwitchMenus) {
			gfx.io.GameDelegate.call("CloseTweenMenu", []);
			skse.OpenMenu("MagicMenu");
		}
	}

	// @override ItemMenu
	private function onShowItemsList(event)
	{
		super.onShowItemsList(event);

		if (event.index != -1)
			updateBottomBar(true);
	}

	private function onItemHighlightChange(event)
	{
		super.onItemHighlightChange(event);

		if (event.index != -1)
			updateBottomBar(true);
	}

	// @override ItemMenu
	private function onHideItemsList(event)
	{
		super.onHideItemsList(event);

		bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_NONE});

		updateBottomBar(false);
	}

	// @override ItemMenu
	private function onItemSelect(event)
	{
		if (event.entry.enabled && event.keyboardOrMouse != 0) {
			gfx.io.GameDelegate.call("ItemSelect", []);
			checkBook(event.entry);
		}
	}

	// @override ItemMenu
	private function onQuantityMenuSelect(event)
	{
		gfx.io.GameDelegate.call("ItemDrop", [event.amount]);

		// Bug Fix: ItemCard does not update when attempting to drop quest items through the quantity menu
		//   so let's request an update even though it may be redundant.
		gfx.io.GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
	}

	private function onMouseRotationFastClick(aiMouseButton)
	{
		gfx.io.GameDelegate.call("CheckForMouseEquip", [aiMouseButton], this, "AttemptEquip");
	}

	private function onItemCardListPress(event)
	{
		gfx.io.GameDelegate.call("ItemCardListCallback", [event.index]);
	}

	// @override ItemMenu
	private function onItemCardSubMenuAction(event)
	{
		super.onItemCardSubMenuAction(event);
		gfx.io.GameDelegate.call("QuantitySliderOpen", [event.opening]);

		if (event.menu == "list") {
			if (event.opening == true) {
				navPanel.clearButtons();
				navPanel.addButton({text: "$Select", controls: _acceptControls});
				navPanel.addButton({text: "$Cancel", controls: _cancelControls});
				navPanel.updateButtons(true);
			} else {
				gfx.io.GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
				updateBottomBar(true);
			}
		}
	}

	private function openMagicMenu(a_bFade)
	{
		if (a_bFade) {
			_bSwitchMenus = true;
			startMenuFade();
		} else {
			saveIndices();
			gfx.io.GameDelegate.call("CloseMenu", []);
			gfx.io.GameDelegate.call("CloseTweenMenu", []);
			skse.OpenMenu("MagicMenu");
		}
	}

	private function startMenuFade()
	{
		inventoryLists.hidePanel();
		ToggleMenuFade();
		saveIndices();
		_bMenuClosing = true;
	}

	// @override ItemMenu
	private function updateBottomBar(a_bSelected)
	{
		navPanel.clearButtons();

		if (a_bSelected) {
			navPanel.addButton(getEquipButtonData(itemCard.itemInfo.type));
			navPanel.addButton({text: "$Drop", controls: Input.XButton});

			if (inventoryLists.itemList.selectedEntry.filterFlag & inventoryLists.categoryList.entryList[0].flag != 0)
				navPanel.addButton({text: "$Unfavorite", controls: Input.YButton});
			else
				navPanel.addButton({text: "$Favorite", controls: Input.YButton});

			if (itemCard.itemInfo.charge != undefined && itemCard.itemInfo.charge < 100)
				navPanel.addButton({text: "$Charge", controls: Input.ChargeItem});

		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: _sortColumnControls});
				navPanel.addButton({text: "$Order", controls: _sortOrderControls});
			}
			navPanel.addButton({text: "$Magic", controls: _switchControls});
		}

		navPanel.updateButtons(true);
	}
}
