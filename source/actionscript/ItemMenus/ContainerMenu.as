class ContainerMenu extends ItemMenu
{
	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = ContainerMenu.SKYUI_VERSION_MAJOR + "." + ContainerMenu.SKYUI_VERSION_MINOR + " SE";

  /* CONSTANTS */

	private static var NULL_HAND = -1;
	private static var RIGHT_HAND = 0;
	private static var LEFT_HAND = 1;


  /* PRIVATE VARIABLES */

	private var _bEquipMode = false;
	private var _equipHand;

	private var _equipModeKey;
	private var _equipModeControls;

	private var _categoryListIconArt;
	private var _tabBarIconArt;


  /* PROPERTIES */

	// @API
	public var bNPCMode = false;

	// @override ItemMenu
	public var bEnableTabs = true;


  /* INITIALIZATION */

	public function ContainerMenu()
	{
		super();

		_categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
		_tabBarIconArt = ["take", "give"];
	}


  /* PUBLIC FUNCTIONS */

	public function InitExtensions()
	{
		super.InitExtensions();

		inventoryLists.tabBarIconArt = _tabBarIconArt;

		// Initialize menu-specific list components
		var categoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;

		gfx.io.GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");
		gfx.io.GameDelegate.addCallBack("XButtonPress", this, "onXButtonPress");
		itemCardFadeHolder.StealTextInstance._visible = false;
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

		_equipModeKey = a_config.Input.controls.pc.equipMode;
		_equipModeControls = {keyCode: _equipModeKey};
	}

	// @API
	public function ShowItemsList()
	{
		// Not necessary anymore. Now handled in onShowItemsList for consistency reasons.
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		super.handleInput(details, pathToFocus);

		if (shouldProcessItemsListInput(false)) {
			if (_platform == 0 && details.skseKeycode == _equipModeKey && inventoryLists.itemList.selectedIndex != -1) {
				_bEquipMode = details.value != "keyUp";
				updateBottomBar(true);
			}
		}

		return true;
	}

	// @override ItemMenu
	public function UpdateItemCardInfo(a_updateObj)
	{
		super.UpdateItemCardInfo(a_updateObj);

		updateBottomBar(true);

		if (a_updateObj.pickpocketChance != undefined) {
			itemCardFadeHolder.StealTextInstance._visible = true;
			itemCardFadeHolder.StealTextInstance.PercentTextInstance.html = true;
			itemCardFadeHolder.StealTextInstance.PercentTextInstance.htmlText = "<font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + a_updateObj.pickpocketChance + "%</font>" + (isViewingContainer() ? skyui.util.Translator.translate("$ TO STEAL") : skyui.util.Translator.translate("$ TO PLACE"));
		} else {
			itemCardFadeHolder.StealTextInstance._visible = false;
		}
	}

	// @API
	public function AttemptEquip(a_slot, a_bCheckOverList)
	{
		var bCheckOverList = a_bCheckOverList != undefined ? a_bCheckOverList : true;

		if (!shouldProcessItemsListInput(bCheckOverList) || !confirmSelectedEntry()) {
			return undefined;
		}

		if (_platform == 0) {
			if (_bEquipMode) {
				startItemEquip(a_slot);
			} else {
				startItemTransfer();
			}
		} else {
			startItemEquip(a_slot);
		}
	}

	// @API
	public function onXButtonPress()
	{
		// If we are zoomed into an item, do nothing
		if (!bFadedIn) {
			return undefined;
		}

		if (isViewingContainer() && !bNPCMode) {
			gfx.io.GameDelegate.call("TakeAllItems", []);
		}
	}

	// @API
	public function SetPlatform(a_platform, a_bPS3Switch)
	{
		super.SetPlatform(a_platform, a_bPS3Switch);
		_bEquipMode = a_platform != 0;
	}


  /* PRIVATE FUNCTIONS */

	private function onItemSelect(event)
	{
		if (event.keyboardOrMouse != 0) {
			if (_platform == 0 && _bEquipMode) {
				startItemEquip(ContainerMenu.NULL_HAND);
			} else {
				startItemTransfer();
			}
		}
	}

	private function onItemCardSubMenuAction(event)
	{
		super.onItemCardSubMenuAction(event);
		if (event.menu == "quantity") {
			gfx.io.GameDelegate.call("QuantitySliderOpen", [event.opening]);
		}
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
	private function onShowItemsList(event)
	{
		inventoryLists.showItemsList();
	}

	// @override ItemMenu
	private function onHideItemsList(event)
	{
		super.onHideItemsList(event);

		bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_NONE});

		updateBottomBar(false);
	}

	private function onMouseRotationFastClick(a_mouseButton)
	{
		gfx.io.GameDelegate.call("CheckForMouseEquip", [a_mouseButton], this, "AttemptEquip");
	}

	private function onQuantityMenuSelect(event)
	{
		if (_equipHand != undefined) {
			gfx.io.GameDelegate.call("EquipItem", [_equipHand, event.amount]);

			if (!checkBook(inventoryLists.itemList.selectedEntry)) {
				checkPoison(inventoryLists.itemList.selectedEntry);
			}

			_equipHand = undefined;
			return undefined;
		}

		if (inventoryLists.itemList.selectedEntry.enabled) {
			gfx.io.GameDelegate.call("ItemTransfer", [event.amount, isViewingContainer()]);
			return undefined;
		}

		gfx.io.GameDelegate.call("DisabledItemSelect", []);
	}

	// @override ItemMenu
	private function updateBottomBar(a_bSelected)
	{
		navPanel.clearButtons();

		if (a_bSelected && inventoryLists.itemList.selectedIndex != -1 && inventoryLists.currentState == InventoryLists.SHOW_PANEL) {
			if (isViewingContainer()) {
				if (_platform != 0) {
					navPanel.addButton({text: "$Take", controls: skyui.defines.Input.Activate});
					navPanel.addButton(getEquipButtonData(itemCard.itemInfo.type, true));
				} else if (_bEquipMode) {
					navPanel.addButton(getEquipButtonData(itemCard.itemInfo.type));
				} else {
					navPanel.addButton({text: "$Take", controls: skyui.defines.Input.Activate});
				}
				if (!bNPCMode) {
					navPanel.addButton({text: "$Take All", controls: skyui.defines.Input.XButton});
				}
			} else {
				if (_platform != 0) {
					navPanel.addButton({text: (!bNPCMode ? "$Store" : "$Give"), controls: skyui.defines.Input.Activate});
					navPanel.addButton(getEquipButtonData(itemCard.itemInfo.type, true));
				} else if (_bEquipMode) {
					navPanel.addButton(getEquipButtonData(itemCard.itemInfo.type));
				} else {
					navPanel.addButton({text: (!bNPCMode ? "$Store" : "$Give"), controls: skyui.defines.Input.Activate});
				}
				navPanel.addButton({text: (!itemCard.itemInfo.favorite ? "$Favorite" : "$Unfavorite"), controls: skyui.defines.Input.YButton});
			}
			if (!_bEquipMode) {
				navPanel.addButton({text: "$Equip Mode", controls: _equipModeControls});
			}
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: _sortColumnControls});
				navPanel.addButton({text: "$Order", controls: _sortOrderControls});
			}
			navPanel.addButton({text: "$Switch Tab", controls: _switchControls});
			if (isViewingContainer() && !bNPCMode) {
				navPanel.addButton({text: "$Take All", controls: skyui.defines.Input.XButton});
			}
		}

		navPanel.updateButtons(true);
	}

	private function startItemTransfer()
	{
		if (inventoryLists.itemList.selectedEntry.enabled) {
			// Don't remove. This is so if an item weighs nothing, it takes the whole stack
			//  Gold, for example.
			if (itemCard.itemInfo.weight == 0 && isViewingContainer()) {
				onQuantityMenuSelect({amount:inventoryLists.itemList.selectedEntry.count});
				return undefined;
			}

			if (_quantityMinCount < 1 || inventoryLists.itemList.selectedEntry.count < _quantityMinCount) {
				onQuantityMenuSelect({amount:1});
			} else {
				itemCard.ShowQuantityMenu(inventoryLists.itemList.selectedEntry.count);
			}
		}
	}

	private function startItemEquip(a_equipHand)
	{
		if (isViewingContainer()) {
			_equipHand = a_equipHand;
			startItemTransfer();
			return undefined;
		}

		gfx.io.GameDelegate.call("EquipItem", [a_equipHand]);
		if (!checkBook(inventoryLists.itemList.selectedEntry)) {
			checkPoison(inventoryLists.itemList.selectedEntry);
		}
	}

	private function isViewingContainer()
	{
		return inventoryLists.categoryList.activeSegment == 0;
	}

	/*
		This method is only used in ContainerMenu.
		If you attempt to use a poison in Container menu
		  a dialog box is presented to ask whether you want to poison the equipped weapon
		  If you release the _equipModeKey while the diaolog is present, the keyUp event
		  for this key is not received by ContainerMenu, so _bEquipMode remains true
		  meaning that the bottom bar buttons are incorrect
	*/
	private function checkPoison(a_entryObject)
	{
		if (a_entryObject.type != skyui.defines.Inventory.ICT_POTION || _global.skse == null) {
			return false;
		}

		if (a_entryObject.subType != skyui.defines.Item.POTION_POISON) {
			return false;
		}

		// force equip mode to false.
		// Use this until we can detect if a specific keyCode is depressed
		// _bEquipMode = skse.IsKeyDown(_equipModeKey)
		_bEquipMode = false;

		return true;
	}
}
