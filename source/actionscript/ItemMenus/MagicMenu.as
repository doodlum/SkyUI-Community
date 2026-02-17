class MagicMenu extends ItemMenu
{
	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = MagicMenu.SKYUI_VERSION_MAJOR + "." + MagicMenu.SKYUI_VERSION_MINOR + " SE";

  /* PRIVATE VARIABLES */

	private var _hideButtonFlag = 0;
	private var _bMenuClosing = false;
	private var _bSwitchMenus = false;

	private var _categoryListIconArt;


  /* INITIALIZATION */

	public function MagicMenu()
	{
		super();

		_categoryListIconArt = ["cat_favorites", "mag_all", "mag_alteration", "mag_illusion",
								"mag_destruction", "mag_conjuration", "mag_restoration", "mag_shouts",
								"mag_powers", "mag_activeeffects"];
	}


  /* PUBLIC FUNCTIONS */

	public function InitExtensions()
	{
		super.InitExtensions();

		gfx.io.GameDelegate.addCallBack("DragonSoulSpent", this, "DragonSoulSpent");
		gfx.io.GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");

		bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_SPELL_DEFAULT});

		// Initialize menu-specific list components
		var categoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
	}

	// @override ItemMenu
	public function setConfig(a_config)
	{
		super.setConfig(a_config);

		var itemList = inventoryLists.itemList;
		itemList.addDataProcessor(new MagicDataSetter(a_config.Appearance));
		itemList.addDataProcessor(new MagicIconSetter(a_config.Appearance));
		itemList.addDataProcessor(new skyui.props.PropertyDataExtender(a_config.Appearance, a_config.Properties, "magicProperties", "magicIcons", "magicCompoundProperties"));

		var layout = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout, "MagicListLayout");
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
				// Gamepad back || ALT (default) || 'I'
				if (details.skseKeycode == _switchTabKey || details.control == "Quick Inventory") {
					openInventoryMenu(true);
				}
			}
		}

		return true;
	}

	// @API
	public function DragonSoulSpent()
	{
		itemCard.itemInfo.soulSpent = true;
		updateBottomBar();
	}

	// @API
	public function AttemptEquip(a_slot)
	{
		if (shouldProcessItemsListInput(true) && confirmSelectedEntry()) {
			gfx.io.GameDelegate.call("ItemSelect", [a_slot]);
		}
	}


  /* PRIVATE FUNCTIONS */

	// @override ItemMenu
	private function onItemSelect(event)
	{
		//Vanilla bugfix
		if (event.keyboardOrMouse != 0) {
			if (event.entry.enabled) {
				gfx.io.GameDelegate.call("ItemSelect", []);
			} else {
				gfx.io.GameDelegate.call("ShowShoutFail", []);
			}
		}
	}

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
			skse.OpenMenu("InventoryMenu");
		}
	}

	// @override ItemMenu
	private function onShowItemsList(event)
	{
		super.onShowItemsList(event);

		if (event.index != -1)
			updateBottomBar(true);
	}

	// @override ItemMenu
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

		bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_SPELL_DEFAULT});

		updateBottomBar(false);
	}

	private function openInventoryMenu(a_bFade)
	{
		if (a_bFade) {
			_bSwitchMenus = true;
			startMenuFade();
		} else {
			saveIndices();
			gfx.io.GameDelegate.call("CloseMenu", []);
			gfx.io.GameDelegate.call("CloseTweenMenu", []);
			skse.OpenMenu("InventoryMenu");
		}
	}

	// @override ItemMenu
	private function updateBottomBar(a_bSelected)
	{
		navPanel.clearButtons();

		if (a_bSelected && (inventoryLists.itemList.selectedEntry.filterFlag & skyui.defines.Inventory.FILTERFLAG_MAGIC_ACTIVEEFFECTS) == 0) {
			navPanel.addButton({text: "$Equip", controls: Input.Equip});

			if (inventoryLists.itemList.selectedEntry.filterFlag & inventoryLists.categoryList.entryList[0].flag != 0)
				navPanel.addButton({text: "$Unfavorite", controls: Input.YButton});
			else
				navPanel.addButton({text: "$Favorite", controls: Input.YButton});

			if (itemCard.itemInfo.showUnlocked) {
				navPanel.addButton({text: "$Unlock", controls: Input.XButton});
			}
		} else {
			navPanel.addButton({text: "$Exit", controls: _cancelControls});
			navPanel.addButton({text: "$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text: "$Column", controls: _sortColumnControls});
				navPanel.addButton({text: "$Order", controls: _sortOrderControls});
			}
			navPanel.addButton({text: "$Inventory", controls: _switchControls});
		}

		navPanel.updateButtons(true);
	}

	private function startMenuFade()
	{
		inventoryLists.hidePanel();
		ToggleMenuFade();
		saveIndices();
		_bMenuClosing = true;
	}
}
