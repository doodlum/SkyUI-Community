class GiftMenu extends ItemMenu
{
	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = GiftMenu.SKYUI_VERSION_MAJOR + "." + GiftMenu.SKYUI_VERSION_MINOR + " SE";

  /* PRIVATE VARIABLES */

	private var _bGivingGifts = true;

	private var _categoryListIconArt;


  /* INITIALIZATION */

	public function GiftMenu()
	{
		super();

		_categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
	}


  /* PUBLIC FUNCTIONS */

	public function InitExtensions()
	{
		super.InitExtensions();
		gfx.io.GameDelegate.addCallBack("SetMenuInfo", this, "SetMenuInfo");

		// Initialize menu-specific list components
		var categoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
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

	// @API
	public function ShowItemsList()
	{
		// Not necessary anymore. Now handled in onShowItemsList for consistency reasons.
	}

	// @API
	public function SetMenuInfo(a_bGivingGifts, a_bUseFavorPoints)
	{
		_bGivingGifts = a_bGivingGifts;
		if (!a_bUseFavorPoints) {
			bottomBar.hidePlayerInfo();
		}
	}

	// @override ItemMenu
	public function UpdatePlayerInfo(a_favorPoints)
	{
		bottomBar.setGiftInfo(a_favorPoints);
	}


  /* PRIVATE FUNCTIONS */

	// @override ItemMenu
	private function onShowItemsList(event)
	{
		// Force select of first category because RestoreIndices isn't called for GiftMenu
		// TODO: Do this in the correct place, i.e. InventoryLists.SetCategoriesList();
		var categoryList = inventoryLists.categoryList;
		categoryList.selectedIndex = 0;
		categoryList.entryList[0].text = "$ALL";
		categoryList.InvalidateData();

		inventoryLists.showItemsList();
	}

	// @override ItemMenu
	private function onHideItemsList(event)
	{
		super.onHideItemsList(event);

		bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_NONE});

		updateBottomBar(false);
	}

	private function onItemHighlightChange(event)
	{
		super.onItemHighlightChange(event);

		if (event.index != -1) {
			updateBottomBar(true);
		}
	}

	// @override ItemMenu
	private function onItemCardSubMenuAction(event)
	{
		super.onItemCardSubMenuAction(event);
		if (event.menu == "quantity") {
			gfx.io.GameDelegate.call("QuantitySliderOpen", [event.opening]);
		}
	}

	// @override ItemMenu
	private function updateBottomBar(a_bSelected)
	{
		navPanel.clearButtons();

		if (a_bSelected) {
			navPanel.addButton({text: (!_bGivingGifts ? "$Take" : "$Give"), controls: skyui.defines.Input.Activate});
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: _sortColumnControls});
				navPanel.addButton({text: "$Order", controls: _sortOrderControls});
			}
		}

		navPanel.updateButtons(true);
	}
}
