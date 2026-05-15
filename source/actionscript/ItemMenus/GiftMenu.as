class GiftMenu extends ItemMenu
{
  /* PRIVATE VARIABLES */

    private var _bGivingGifts: Boolean = true;

    private var _categoryListIconArt: Array;


  /* INITIALIZATION */

    public function GiftMenu()
    {
        super();

        this._categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
    }
    
    
  /* PUBLIC FUNCTIONS */

    public function InitExtensions()
    {
        super.InitExtensions();
        gfx.io.GameDelegate.addCallBack("SetMenuInfo", this, "SetMenuInfo");
        
        // Initialize menu-specific list components
        var categoryList: CategoryList = this.inventoryLists.categoryList;
        categoryList.iconArt = this._categoryListIconArt;
    }

    // @override ItemMenu
    public function setConfig(a_config: Object)
    {
        super.setConfig(a_config);

        var itemList: TabularList = this.inventoryLists.itemList;		
        itemList.addDataProcessor(new InventoryDataSetter());
        itemList.addDataProcessor(new InventoryIconSetter(a_config["Appearance"]));
        itemList.addDataProcessor(new skyui.props.PropertyDataExtender(a_config["Appearance"], a_config["Properties"], "itemProperties", "itemIcons", "itemCompoundProperties"));
        
        var layout: ListLayout = skyui.components.list.ListLayoutManager.createLayout(a_config["ListLayout"], "ItemListLayout");
        itemList.layout = layout;

        // Not 100% happy with doing this here, but has to do for now.
        if (this.inventoryLists.categoryList.selectedEntry)
            layout.changeFilterFlag(this.inventoryLists.categoryList.selectedEntry.flag);
    }

    // @API
    public function ShowItemsList()
    {
        // Not necessary anymore. Now handled in onShowItemsList for consistency reasons.
        //inventoryLists.showItemsList();
    }

    // @API
    public function SetMenuInfo(a_bGivingGifts: Boolean, a_bUseFavorPoints: Boolean)
    {
        this._bGivingGifts = a_bGivingGifts;
        
        if (!a_bUseFavorPoints)
            this.bottomBar.hidePlayerInfo();
    }

    // @override ItemMenu
    public function UpdatePlayerInfo(a_favorPoints: Number)
    {
        this.bottomBar.setGiftInfo(a_favorPoints);
    }

    
  /* PRIVATE FUNCTIONS */

    // @override ItemMenu
    private function onShowItemsList(event: Object)
    {
        // Force select of first category because RestoreIndices isn't called for GiftMenu
        // TODO: Do this in the correct place, i.e. InventoryLists.SetCategoriesList();
        var categoryList: CategoryList = this.inventoryLists.categoryList;
        categoryList.selectedIndex = 0;
        categoryList.entryList[0].text = "$ALL";
        categoryList.InvalidateData();

        this.inventoryLists.showItemsList();
    }

    // @override ItemMenu
    private function onHideItemsList(event: Object)
    {
        super.onHideItemsList(event);

        this.bottomBar.updatePerItemInfo({type: skyui.defines.Inventory.ICT_NONE});
        
        this.updateBottomBar(false);
    }

    private function onItemHighlightChange(event: Object)
    {
        super.onItemHighlightChange(event);
        
        if (event.index != -1)
            this.updateBottomBar(true);	
    }

    // @override ItemMenu
    private function onItemCardSubMenuAction(event: Object)
    {
        super.onItemCardSubMenuAction(event);
        if (event.menu == "quantity")
            gfx.io.GameDelegate.call("QuantitySliderOpen", [event.opening]);
    }
    
    // @override ItemMenu
    private function updateBottomBar(a_bSelected: Boolean)
    {
        this.navPanel.clearButtons();
        
        if (a_bSelected) {
            this.navPanel.addButton({text: (this._bGivingGifts ? "$Give" : "$Take"), controls: skyui.defines.Input.Activate});
        } else {
            this.navPanel.addButton({text: "$Exit", controls: this._cancelControls});
            this.navPanel.addButton({text: "$Search", controls: this._searchControls});
            if (this._platform != 0) {
                this.navPanel.addButton({text: "$Column", controls: this._sortColumnControls});
                this.navPanel.addButton({text: "$Order", controls: this._sortOrderControls});
            }
        }
        
        this.navPanel.updateButtons(true);
    }

}
