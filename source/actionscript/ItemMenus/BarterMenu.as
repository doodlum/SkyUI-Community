class BarterMenu extends ItemMenu
{
	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = BarterMenu.SKYUI_VERSION_MAJOR + "." + BarterMenu.SKYUI_VERSION_MINOR + " SE";

  /* PRIVATE VARIABLES */

	private var _buyMult = 1;
	private var _sellMult = 1;
	private var _confirmAmount = 0;
	private var _playerGold = 0;
	private var _vendorGold = 0;

	private var _categoryListIconArt;
	private var _tabBarIconArt;


  /* PROPERTIES */

	// @override ItemMenu
	public var bEnableTabs = true;


  /* INITIALIZATION */

	public function BarterMenu()
	{
		super();

		_categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
		_tabBarIconArt = ["buy", "sell"];
	}


  /* PUBLIC FUNCTIONS */

	public function InitExtensions()
	{
		super.InitExtensions();
		gfx.io.GameDelegate.addCallBack("SetBarterMultipliers", this, "SetBarterMultipliers");

		itemCard.addEventListener("messageConfirm", this, "onTransactionConfirm");
		itemCard.addEventListener("sliderChange", this, "onQuantitySliderChange");

		inventoryLists.tabBarIconArt = _tabBarIconArt;

		// Initialize menu-specific list components
		var categoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
	}

	// @override ItemMenu
	public function setConfig(a_config)
	{
		super.setConfig(a_config);

		var itemList = inventoryLists.itemList;
		itemList.addDataProcessor(new BarterDataSetter(_buyMult, _sellMult));
		itemList.addDataProcessor(new InventoryIconSetter(a_config.Appearance));
		itemList.addDataProcessor(new skyui.props.PropertyDataExtender(a_config.Appearance, a_config.Properties, "itemProperties", "itemIcons", "itemCompoundProperties"));

		var layout = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout, "ItemListLayout");
		itemList.layout = layout;

		// Not 100% happy with doing this here, but has to do for now.
		if (inventoryLists.categoryList.selectedEntry) {
			layout.changeFilterFlag(inventoryLists.categoryList.selectedEntry.flag);
		}
	}

	private function onExitButtonPress()
	{
		gfx.io.GameDelegate.call("CloseMenu", []);
	}

	// @API
	public function SetBarterMultipliers(a_buyMult, a_sellMult)
	{
		_buyMult = a_buyMult;
		_sellMult = a_sellMult;
	}

	// @API
	public function ShowRawDealWarning(a_warning)
	{
		itemCard.ShowConfirmMessage(a_warning);
	}

	// @override ItemMenu
	public function UpdateItemCardInfo(a_updateObj)
	{
		if (isViewingVendorItems()) {
			a_updateObj.value *= _buyMult;
			a_updateObj.value = Math.max(a_updateObj.value, 1);
		} else {
			a_updateObj.value *= _sellMult;
		}
		a_updateObj.value = Math.floor(a_updateObj.value + 0.5);
		itemCard.itemInfo = a_updateObj;
		bottomBar.updateBarterPerItemInfo(a_updateObj);
	}

	// @override ItemMenu
	public function UpdatePlayerInfo(a_playerGold, a_vendorGold, a_vendorName, a_playerUpdateObj)
	{
		_vendorGold = a_vendorGold;
		_playerGold = a_playerGold;
		bottomBar.updateBarterInfo(a_playerUpdateObj, itemCard.itemInfo, a_playerGold, a_vendorGold, a_vendorName);
	}


  /* PRIVATE FUNCTIONS */

	// @override ItemMenu
	private function onShowItemsList(event)
	{
		inventoryLists.showItemsList();
	}

	// @override ItemMenu
	private function onItemHighlightChange(event)
	{
		if (event.index != -1) {
			updateBottomBar(true);
		}
		super.onItemHighlightChange(event);
	}

	// @override ItemMenu
	private function onHideItemsList(event)
	{
		super.onHideItemsList(event);

		bottomBar.updateBarterPerItemInfo({type:skyui.defines.Inventory.ICT_NONE});

		updateBottomBar(false);
	}

	private function onQuantitySliderChange(event)
	{
		var price = itemCard.itemInfo.value * event.value;
		if (isViewingVendorItems()) {
			price *= -1;
		}
		bottomBar.updateBarterPriceInfo(_playerGold, _vendorGold, itemCard.itemInfo, price);
	}

	// @override ItemMenu
	private function onQuantityMenuSelect(event)
	{
		var price = event.amount * itemCard.itemInfo.value;
		if (price > _vendorGold && !isViewingVendorItems()) {
			_confirmAmount = event.amount;
			gfx.io.GameDelegate.call("GetRawDealWarningString", [price], this, "ShowRawDealWarning");
			bottomBar.updateBarterPriceInfo(_playerGold, _vendorGold, itemCard.itemInfo, price);
			return undefined;
		}
		doTransaction(event.amount);
	}

	// @override ItemMenu
	private function onItemCardSubMenuAction(event)
	{
		super.onItemCardSubMenuAction(event);
		if (event.menu == "quantity") {
			if (event.opening) {
				onQuantitySliderChange({value:itemCard.itemInfo.count});
				return undefined;
			}
			bottomBar.updateBarterPriceInfo(_playerGold, _vendorGold);
		}
	}

	private function onTransactionConfirm()
	{
		doTransaction(_confirmAmount);
		_confirmAmount = 0;
	}

	private function doTransaction(a_amount)
	{
		gfx.io.GameDelegate.call("ItemSelect", [a_amount, itemCard.itemInfo.value, isViewingVendorItems()]);
		// Update barter multipliers
		// Update itemList => dataProcessor => BarterDataSetter updateBarterMultipliers
		// Update itemCardInfo GameDelegate.call("RequestItemCardInfo",[], this, "UpdateItemCardInfo");
	}

	private function isViewingVendorItems()
	{
		return inventoryLists.categoryList.activeSegment == 0;
	}

	// @override ItemMenu
	private function updateBottomBar(a_bSelected)
	{
		navPanel.clearButtons();

		if (a_bSelected) {
			navPanel.addButton({text: (!isViewingVendorItems() ? "$Sell" : "$Buy"), controls: skyui.defines.Input.Activate});
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: _sortColumnControls});
				navPanel.addButton({text: "$Order", controls: _sortOrderControls});
			}
			navPanel.addButton({text: "$Switch Tab", controls: _switchControls});
		}

		navPanel.updateButtons(true);
	}
}
