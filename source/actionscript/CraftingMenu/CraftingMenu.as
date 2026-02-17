class CraftingMenu extends MovieClip
{
	/* CONSTANTS */

	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = CraftingMenu.SKYUI_VERSION_MAJOR + "." + CraftingMenu.SKYUI_VERSION_MINOR + " SE";

	static var LIST_OFFSET = 20;
	static var SELECT_BUTTON = 0;
	static var EXIT_BUTTON = 1;
	static var AUX_BUTTON = 2;
	static var CRAFT_BUTTON = 3;

	static var SUBTYPE_NAMES = ["ConstructibleObject", "Smithing", "EnchantConstruct", "EnchantDestruct", "Alchemy"];


	/* STAGE ELEMENTS */

	// @API
	public var BottomBarInfo;

	public var ItemInfoHolder;
	public var MenuDescriptionHolder;
	public var MenuNameHolder;

	// Not API, but keeping the original name for compatibility with vanilla.
	public var InventoryLists;

	public var MouseRotationRect;
	public var ExitMenuRect;


	/* PRIVATE VARIABLES */

	private var _bCanCraft = false;
	private var _bCanFadeItemInfo = true;
	private var _bItemCardAdditionalDescription = false;
	private var _platform = 0;

	private var _searchKey;

	private var _acceptControls;
	private var _cancelControls;
	private var _searchControls;
	private var _sortColumnControls;
	private var _sortOrderControls;

	private var _config;
	private var _subtypeName;


	/* PROPERTIES */

	public var AdditionalDescriptionHolder;

	// @API
	public var AdditionalDescription;

	// @API
	public var ButtonText;

	// @API
	public var CategoryList;

	// @API
	public var ItemInfo;

	// @API
	public var ItemList;

	// @API
	public var MenuDescription;

	// @API
	public var MenuName;

	// @API
	public function get bCanCraft()
	{
		return _bCanCraft;
	}

	// @API
	public function set bCanCraft(abCanCraft)
	{
		_bCanCraft = abCanCraft;
		UpdateButtonText();
	}

	public function get bCanFadeItemInfo()
	{
		gfx.io.GameDelegate.call("CanFadeItemInfo", [], this, "SetCanFadeItemInfo");
		return _bCanFadeItemInfo;
	}

	// @API (?)
	public function SetCanFadeItemInfo(abCanFade)
	{
		_bCanFadeItemInfo = abCanFade;
	}

	public function get bItemCardAdditionalDescription()
	{
		return _bItemCardAdditionalDescription;
	}

	public function set bItemCardAdditionalDescription(abItemCardDesc)
	{
		_bItemCardAdditionalDescription = abItemCardDesc;
		if (abItemCardDesc) {
			AdditionalDescription.text = "";
		}
	}

	// @API
	public var bCanExpandPanel;

	// @API
	public var bHideAdditionalDescription;

	public var currentMenuType = "";

	public var navPanel;

	var dbgIntvl = 0;


	/* INITIALIZATION */

	public function CraftingMenu()
	{
		super();

		bCanExpandPanel = true;
		bHideAdditionalDescription = false;
		ButtonText = new Array("", "", "", "");

		CategoryList = InventoryLists;
		ItemInfo = ItemInfoHolder.ItemInfo;
		Mouse.addListener(this);

		skyui.util.ConfigManager.registerLoadCallback(this, "onConfigLoad");

		navPanel = BottomBarInfo.buttonPanel;
	}

	// @API
	public function Initialize()
	{
		skse.ExtendData(true);
		skse.ExtendAlchemyCategories(true);

		_subtypeName = SUBTYPE_NAMES[_currentframe - 1];

		ItemInfoHolder = ItemInfoHolder;
		ItemInfoHolder.gotoAndStop("default");
		ItemInfo.addEventListener("endEditItemName", this, "onEndEditItemName");
		ItemInfo.addEventListener("subMenuAction", this, "onSubMenuAction");
		BottomBarInfo = BottomBarInfo;
		AdditionalDescriptionHolder = ItemInfoHolder.AdditionalDescriptionHolder;
		AdditionalDescription = AdditionalDescriptionHolder.AdditionalDescription;
		AdditionalDescription.textAutoSize = "shrink";

		// Naming FTW - gotta respect the API though.
		MenuName = MenuNameHolder.MenuName;
		MenuName.autoSize = "left";
		MenuNameHolder._visible = false;

		MenuDescription = MenuDescriptionHolder.MenuDescription;
		MenuDescription.autoSize = "center";

		CategoryList.InitExtensions(_subtypeName);

		gfx.managers.FocusHandler.instance.setFocus(CategoryList, 0);

		CategoryList.addEventListener("itemHighlightChange", this, "onItemHighlightChange");
		CategoryList.addEventListener("showItemsList", this, "onShowItemsList");
		CategoryList.addEventListener("hideItemsList", this, "onHideItemsList");
		CategoryList.addEventListener("categoryChange", this, "onCategoryListChange");

		ItemList = CategoryList.itemList;
		ItemList.addEventListener("itemPress", this, "onItemSelect");

		ExitMenuRect.onPress = function()
		{
			gfx.io.GameDelegate.call("CloseMenu", []);
		};

		bCanCraft = false;
		positionFixedElements();
	}


	/* PUBLIC FUNCTIONS */

	// @API - Alchemy
	public function SetPartitionedFilterMode(a_bPartitioned)
	{
		CategoryList.setPartitionedFilterMode(a_bPartitioned);
	}

	// @API - Alchemy
	public function GetNumCategories()
	{
		return CategoryList.CategoriesList.entryList.length;
	}

	// @API
	public function UpdateButtonText()
	{
		navPanel.clearButtons();

		if (getItemShown()) {
			navPanel.addButton({text:ButtonText[CraftingMenu.SELECT_BUTTON], controls: skyui.defines.Input.Activate});
		} else {
			navPanel.addButton({text:"$Exit", controls: _cancelControls});
			navPanel.addButton({text:"$Search", controls: _searchControls});
			if (_platform != 0) {
				navPanel.addButton({text:"$Column", controls: _sortColumnControls});
				navPanel.addButton({text:"$Order", controls: _sortOrderControls});
			}
		}

		if (bCanCraft && ButtonText[CraftingMenu.CRAFT_BUTTON] != "") {
			navPanel.addButton({text:ButtonText[CraftingMenu.CRAFT_BUTTON], controls: skyui.defines.Input.XButton});
		}

		if (bCanCraft && ButtonText[CraftingMenu.AUX_BUTTON] != "") {
			navPanel.addButton({text:ButtonText[CraftingMenu.AUX_BUTTON], controls: skyui.defines.Input.YButton});
		}

		navPanel.updateButtons(true);
	}

	// @API
	public function UpdateItemList(abFullRebuild)
	{
		if (_subtypeName == "ConstructibleObject") {
			// After constructing an item, the native control flow is:
			//    (1) Call InvalidateListData directly and set some basic data
			//    (2) Call UpdateItemList(false) to set more stuff
			//
			// The problem is that enabled is only set in (2), so we always do a full rebuild not to screw up our sorting.
			// For this menu, this is not a problem. For others it would be (recursive calls to UpdateItemList).
			abFullRebuild = true;
		}

		if (abFullRebuild == true) {
			CategoryList.InvalidateListData();
		} else {
			ItemList.UpdateList();
		}
	}

	// @API
	public function UpdateItemDisplay()
	{
		var itemShown = getItemShown();
		FadeInfoCard(!itemShown);
		SetSelectedItem(ItemList.selectedIndex);
		gfx.io.GameDelegate.call("ShowItem3D", [itemShown]);
	}

	// @API
	public function FadeInfoCard(abFadeOut)
	{
		if (abFadeOut && bCanFadeItemInfo) {
			ItemInfo.FadeOutCard();
			if (bHideAdditionalDescription) {
				AdditionalDescriptionHolder._visible = false;
			}
			return;
		}
		if (abFadeOut) {
			return;
		}
		ItemInfo.FadeInCard();
		if (bHideAdditionalDescription) {
			AdditionalDescriptionHolder._visible = true;
		}
	}

	// @API
	public function SetSelectedItem(aSelection)
	{
		gfx.io.GameDelegate.call("SetSelectedItem", [aSelection]);
	}

	// @API - Alchemy
	public function PreRebuildList()
	{
	}

	// @API - Alchemy
	public function PostRebuildList(abRestoreSelection)
	{
	}

	// @API
	public function SetPlatform(a_platform, a_bPS3Switch)
	{
		_platform = a_platform;

		if (a_platform == 0) {
			_acceptControls = skyui.defines.Input.Enter;
			_cancelControls = skyui.defines.Input.Tab;
		} else {
			_acceptControls = skyui.defines.Input.Accept;
			_cancelControls = skyui.defines.Input.Cancel;

			// Defaults
			_sortColumnControls = skyui.defines.Input.SortColumn;
			_sortOrderControls = skyui.defines.Input.SortOrder;
		}

		// Defaults
		_searchControls = skyui.defines.Input.Space;

		ItemInfo.SetPlatform(a_platform, a_bPS3Switch);

		BottomBarInfo.setPlatform(a_platform, a_bPS3Switch);
		CategoryList.setPlatform(a_platform, a_bPS3Switch);
	}

	// @API
	public function UpdateIngredients(aLineTitle, aIngredients, abShowPlayerCount)
	{
		var itemTextField = !bItemCardAdditionalDescription ? AdditionalDescription : ItemInfo.GetItemName();
		itemTextField.text = !(aLineTitle != undefined && aLineTitle.length > 0) ? "" : aLineTitle + ": ";
		var oldTextFormat = itemTextField.getNewTextFormat();
		var newTextFormat = itemTextField.getNewTextFormat();
		var i = 0;
		var ingredient;
		var requiredCount;
		var itemCount;
		var ingredientString;
		while (i < aIngredients.length) {
			ingredient = aIngredients[i];
			newTextFormat.color = ingredient.PlayerCount >= ingredient.RequiredCount ? 16777215 : 7829367;
			itemTextField.setNewTextFormat(newTextFormat);
			requiredCount = "";
			if (ingredient.RequiredCount > 1) {
				requiredCount = ingredient.RequiredCount + " ";
			}
			itemCount = "";
			if (abShowPlayerCount && ingredient.PlayerCount >= 1) {
				itemCount = " (" + ingredient.PlayerCount + ")";
			}
			ingredientString = requiredCount + ingredient.Name + itemCount + (i < aIngredients.length - 1 ? ", " : "");
			itemTextField.replaceText(itemTextField.length, itemTextField.length + 1, ingredientString);
			i = i + 1;
		}
		itemTextField.setNewTextFormat(oldTextFormat);
	}

	// @API
	public function EditItemName(aInitialText, aMaxChars)
	{
		ItemInfo.StartEditName(aInitialText, aMaxChars);
	}

	// @API
	public function ShowSlider(aiMaxValue, aiMinValue, aiCurrentValue, aiSnapInterval)
	{
		ItemInfo.ShowEnchantingSlider(aiMaxValue, aiMinValue, aiCurrentValue);
		ItemInfo.quantitySlider.snapping = true;
		ItemInfo.quantitySlider.snapInterval = aiSnapInterval;
		ItemInfo.quantitySlider.addEventListener("change", this, "onSliderChanged");
		onSliderChanged();
	}

	// @API
	public function SetSliderValue(aValue)
	{
		ItemInfo.quantitySlider.value = aValue;
	}

	// @GFx
	public function handleInput(aInputEvent, aPathToFocus)
	{
		aPathToFocus[0].handleInput(aInputEvent, aPathToFocus.slice(1));

		return true;
	}


	/* PRIVATE FUNCTIONS */

	private function positionFixedElements()
	{
		Shared.GlobalFunc.SetLockFunction();

		MovieClip(CategoryList).Lock("L");
		CategoryList._x -= CraftingMenu.LIST_OFFSET;

		MenuNameHolder.Lock("L");
		MenuNameHolder._x -= CraftingMenu.LIST_OFFSET;
		MenuDescriptionHolder.Lock("TR");
		var leftOffset = Stage.visibleRect.x + Stage.safeRect.x;
		var rightOffset = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;

		var a = CategoryList.getContentBounds();
		// 25 is hardcoded cause thats the final offset after the animation of the panel container is done
		var panelEdge = CategoryList._x + a[0] + a[2] + 25;

		MenuDescriptionHolder._x = 10 + panelEdge + ((rightOffset - panelEdge) / 2) + (MenuDescriptionHolder._width / 2);

		BottomBarInfo.positionElements(leftOffset, rightOffset);

		MovieClip(ExitMenuRect).Lock("TL");
		ExitMenuRect._x -= Stage.safeRect.x + 10;
		ExitMenuRect._y -= Stage.safeRect.y;
	}

	private function positionFloatingElements()
	{
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;

		var a = CategoryList.getContentBounds();
		// 25 is hardcoded cause thats the final offset after the animation of the panel container is done
		var panelEdge = CategoryList._x + a[0] + a[2] + 25;

		var itemCardContainer = ItemInfo._parent;
		var itemcardPosition = _config.ItemInfo.itemcard;

		var itemCardWidth;

		// For some reason the container is larger than the card
		if (ItemInfo.background != undefined)
			itemCardWidth = ItemInfo.background._width;
		else
			itemCardWidth = ItemInfo._width;

		// Card x is at 0 so we can use the inner width without adjustment
		var scaleMult = (rightEdge - panelEdge) / itemCardContainer._width;

		// Scale down if necessary
		if (scaleMult < 1) {
			itemCardContainer._width *= scaleMult;
			itemCardContainer._height *= scaleMult;
			itemCardWidth *= scaleMult;
		}

		if (itemcardPosition.align == "left") {
			itemCardContainer._x = panelEdge + itemcardPosition.xOffset;
		} else if (itemcardPosition.align == "right") {
			itemCardContainer._x = rightEdge - itemCardWidth + itemcardPosition.xOffset;
		} else {
			itemCardContainer._x = panelEdge + itemcardPosition.xOffset + (Stage.visibleRect.x + Stage.visibleRect.width - panelEdge - itemCardWidth) / 2;
		}

		itemCardContainer._y += itemcardPosition.yOffset;

		MovieClip(MouseRotationRect).Lock("T");
		MouseRotationRect._x = ItemInfo._parent._x;
		MouseRotationRect._width = ItemInfo._parent._width;
		MouseRotationRect._height = 0.55 * Stage.visibleRect.height;
	}

	private function onConfigLoad(event)
	{
		setConfig(event.config);

		CategoryList.showPanel();
	}

	private function setConfig(a_config)
	{
		_config = a_config;
		ItemList.addDataProcessor(new CraftingDataSetter());
		ItemList.addDataProcessor(new CraftingIconSetter(a_config.Appearance));

		positionFloatingElements();

		var itemListState = CategoryList.itemList.listState;
		var appearance = a_config.Appearance;

		itemListState.iconSource = appearance.icons.item.source;
		itemListState.showStolenIcon = appearance.icons.item.showStolen;

		itemListState.defaultEnabledColor = appearance.colors.text.enabled;
		itemListState.negativeEnabledColor = appearance.colors.negative.enabled;
		itemListState.stolenEnabledColor = appearance.colors.stolen.enabled;
		itemListState.defaultDisabledColor = appearance.colors.text.disabled;
		itemListState.negativeDisabledColor = appearance.colors.negative.disabled;
		itemListState.stolenDisabledColor = appearance.colors.stolen.disabled;

		var layout;

		if (_subtypeName == "EnchantConstruct") {
			layout = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout, "EnchantListLayout");

		} else if (_subtypeName == "Smithing") {
			layout = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout, "SmithingListLayout");

		} else if (_subtypeName == "ConstructibleObject") {
			layout = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout, "ConstructListLayout");

		} else {
			layout = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout, "AlchemyListLayout");
			layout.entryWidth -= CraftingLists.SHORT_LIST_OFFSET;
		}

		ItemList.layout = layout;

		var previousColumnKey = a_config.Input.controls.gamepad.prevColumn;
		var nextColumnKey = a_config.Input.controls.gamepad.nextColumn;
		var sortOrderKey = a_config.Input.controls.gamepad.sortOrder;
		_sortColumnControls = [{keyCode:previousColumnKey}, {keyCode:nextColumnKey}];
		_sortOrderControls = {keyCode:sortOrderKey};

		_searchKey = a_config.Input.controls.pc.search;
		_searchControls = {keyCode:_searchKey};
	}

	private function onItemListPressed(event)
	{
		gfx.io.GameDelegate.call("CraftSelectedItem", [ItemList.selectedIndex]);
		gfx.io.GameDelegate.call("SetSelectedItem", [ItemList.selectedIndex]);
	}

	private function onItemSelect(event)
	{
		gfx.io.GameDelegate.call("ChooseItem", [event.index]);
		gfx.io.GameDelegate.call("ShowItem3D", [event.index != -1]);
		UpdateButtonText();
	}

	private function onItemHighlightChange(event)
	{
		SetSelectedItem(event.index);
		FadeInfoCard(event.index == -1);
		UpdateButtonText();
		gfx.io.GameDelegate.call("ShowItem3D", [event.index != -1]);
	}

	private function onShowItemsList(event)
	{
		if (_platform == 0) {
			gfx.io.GameDelegate.call("SetSelectedCategory", [CategoryList.CategoriesList.selectedIndex]);
		}

		onItemHighlightChange(event);
	}

	private function onHideItemsList(event)
	{
		SetSelectedItem(event.index);
		FadeInfoCard(true);
		UpdateButtonText();
		gfx.io.GameDelegate.call("ShowItem3D", [false]);
	}

	private function onCategoryListChange(event)
	{
		if (_platform != 0) {
			gfx.io.GameDelegate.call("SetSelectedCategory", [event.index]);
		}
	}

	private function onSliderChanged(event)
	{
		gfx.io.GameDelegate.call("CalculateCharge", [ItemInfo.quantitySlider.value], this, "SetChargeValues");
	}

	private function onSubMenuAction(event)
	{
		if (event.opening == true) {
			ItemList.disableSelection = true;
			ItemList.disableInput = true;
			CategoryList.CategoriesList.disableSelection = true;
			CategoryList.CategoriesList.disableInput = true;
		} else if (event.opening == false) {
			ItemList.disableSelection = false;
			ItemList.disableInput = false;
			CategoryList.CategoriesList.disableSelection = false;
			CategoryList.CategoriesList.disableInput = false;
		}
		if (event.menu == "quantity") {
			if (event.opening) {
				return;
			}
			gfx.io.GameDelegate.call("SliderClose", [!event.canceled, event.value]);
		}
	}

	private function onCraftButtonPress()
	{
		if (bCanCraft) {
			gfx.io.GameDelegate.call("CraftButtonPress", []);
		}
	}

	private function onExitButtonPress()
	{
		gfx.io.GameDelegate.call("CloseMenu", []);
	}

	private function onAuxButtonPress()
	{
		gfx.io.GameDelegate.call("AuxButtonPress", []);
	}

	private function onEndEditItemName(event)
	{
		ItemInfo.EndEditName();
		gfx.io.GameDelegate.call("EndItemRename", [event.useNewName, event.newName]);
	}

	private function getItemShown()
	{
		return ItemList.selectedIndex >= 0;
	}

	private function onMouseUp()
	{
		if (ItemInfo.bEditNameMode && !ItemInfo.hitTest(_root._xmouse, _root._ymouse)) {
			onEndEditItemName({useNewName:false, newName:""});
		}
	}

	private function onMouseRotationStart()
	{
		gfx.io.GameDelegate.call("StartMouseRotation", []);
		CategoryList.CategoriesList.disableSelection = true;
		ItemList.disableSelection = true;
	}

	private function onMouseRotationStop()
	{
		gfx.io.GameDelegate.call("StopMouseRotation", []);
		CategoryList.CategoriesList.disableSelection = false;
		ItemList.disableSelection = false;
	}

	private function onItemsListInputCatcherClick()
	{
	}

	private function onMouseRotationFastClick(aiMouseButton)
	{
		if (aiMouseButton == 0) {
			onItemsListInputCatcherClick();
		}
	}
}
