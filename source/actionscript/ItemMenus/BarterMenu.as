class BarterMenu extends ItemMenu
{
  /* PRIVATE VARIABLES */

    private var _buyMult: Number = 1;
    private var _sellMult: Number = 1;
    private var _confirmAmount: Number = 0;
    private var _playerGold: Number = 0;
    private var _vendorGold: Number = 0;

    private var _categoryListIconArt: Array;
    private var _tabBarIconArt: Array;
    
    
  /* PROPERTIES */
    
    // @override ItemMenu
    public var bEnableTabs: Boolean = true;


  /* INITIALIZATION */

    public function BarterMenu()
    {
        super();

        this._categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
        this._tabBarIconArt = ["buy", "sell"];
    }
    
    
  /* PUBLIC FUNCTIONS */

    public function InitExtensions()
    {
        super.InitExtensions();
        gfx.io.GameDelegate.addCallBack("SetBarterMultipliers", this, "SetBarterMultipliers");
        
        this.itemCard.addEventListener("messageConfirm",this,"onTransactionConfirm");
        this.itemCard.addEventListener("sliderChange",this,"onQuantitySliderChange");
        
        this.inventoryLists.tabBarIconArt = this._tabBarIconArt;
        
        // Initialize menu-specific list components
        var categoryList: CategoryList = this.inventoryLists.categoryList;
        categoryList.iconArt = this._categoryListIconArt;
    }

    // @override ItemMenu
    public function setConfig(a_config: Object)
    {
        super.setConfig(a_config);

        var itemList: TabularList = this.inventoryLists.itemList;		
        itemList.addDataProcessor(new BarterDataSetter(this._buyMult, this._sellMult));
        itemList.addDataProcessor(new InventoryIconSetter(a_config["Appearance"]));
        itemList.addDataProcessor(new skyui.props.PropertyDataExtender(a_config["Appearance"], a_config["Properties"], "itemProperties", "itemIcons", "itemCompoundProperties"));
        
        var layout: ListLayout = skyui.components.list.ListLayoutManager.createLayout(a_config["ListLayout"], "ItemListLayout");
        itemList.layout = layout;

        // Not 100% happy with doing this here, but has to do for now.
        if (this.inventoryLists.categoryList.selectedEntry)
            layout.changeFilterFlag(this.inventoryLists.categoryList.selectedEntry.flag);
    }

    private function onExitButtonPress()
    {
        gfx.io.GameDelegate.call("CloseMenu",[]);
    }

    // @API
    public function SetBarterMultipliers(a_buyMult: Number, a_sellMult: Number)
    {
        this._buyMult = a_buyMult;
        this._sellMult = a_sellMult;
    }

    // @API
    public function ShowRawDealWarning(a_warning: String)
    {
        this.itemCard.ShowConfirmMessage(a_warning);
    }
    
    // @override ItemMenu
    public function UpdateItemCardInfo(a_updateObj: Object)
    {
        if (this.isViewingVendorItems()) {
            a_updateObj.value *= this._buyMult;
            a_updateObj.value = Math.max(a_updateObj.value, 1);
        } else {
            a_updateObj.value *= this._sellMult;
        }
        a_updateObj.value = Math.floor(a_updateObj.value + 0.5);
        this.itemCard.itemInfo = a_updateObj;
        this.bottomBar.updateBarterPerItemInfo(a_updateObj);
    }

    // @override ItemMenu
    public function UpdatePlayerInfo(a_playerGold: Number, a_vendorGold: Number, a_vendorName: String, a_playerUpdateObj: Object)
    {
        this._vendorGold = a_vendorGold;
        this._playerGold = a_playerGold;
        this.bottomBar.updateBarterInfo(a_playerUpdateObj, this.itemCard.itemInfo, a_playerGold, a_vendorGold, a_vendorName);
    }
    
    
  /* PRIVATE FUNCTIONS */

    // @override ItemMenu
    private function onShowItemsList(event: Object)
    {
        this.inventoryLists.showItemsList();

        //super.onShowItemsList(event);
    }

    // @override ItemMenu
    private function onItemHighlightChange(event: Object)
    {
        if (event.index != -1)
            this.updateBottomBar(true);

        super.onItemHighlightChange(event);
    }

    // @override ItemMenu
    private function onHideItemsList(event: Object)
    {
        super.onHideItemsList(event);

        this.bottomBar.updateBarterPerItemInfo({type: skyui.defines.Inventory.ICT_NONE});
        
        this.updateBottomBar(false);
    }
    
    private function onQuantitySliderChange(event: Object)
    {
        var price = this.itemCard.itemInfo.value * event.value;
        if (this.isViewingVendorItems()) {
            price *= -1;
        }
        this.bottomBar.updateBarterPriceInfo(this._playerGold, this._vendorGold, this.itemCard.itemInfo, price);
    }
    
    // @override ItemMenu
    private function onQuantityMenuSelect(event: Object)
    {
        var price = event.amount * this.itemCard.itemInfo.value;
        if (price > this._vendorGold && !this.isViewingVendorItems()) {
            this._confirmAmount = event.amount;

            gfx.io.GameDelegate.call("GetRawDealWarningString", [price], this, "ShowRawDealWarning");

            this.bottomBar.updateBarterPriceInfo(this._playerGold, this._vendorGold, this.itemCard.itemInfo, price);
            return;
        }
        this.doTransaction(event.amount);
    }

    // @override ItemMenu
    private function onItemCardSubMenuAction(event: Object)
    {
        super.onItemCardSubMenuAction(event);
        if (event.menu == "quantity") {
            if (event.opening) {
                this.onQuantitySliderChange({value: this.itemCard.itemInfo.count});
                return;
            }
            this.bottomBar.updateBarterPriceInfo(this._playerGold, this._vendorGold);
        }
    }
    
    private function onTransactionConfirm()
    {
        this.doTransaction(this._confirmAmount);
        this._confirmAmount = 0;
    }
    
    private function doTransaction(a_amount: Number)
    {
        gfx.io.GameDelegate.call("ItemSelect",[a_amount, this.itemCard.itemInfo.value, this.isViewingVendorItems()]);
        // Update barter multipliers
        // Update itemList => dataProcessor => BarterDataSetter updateBarterMultipliers
        // Update itemCardInfo gfx.io.GameDelegate.call("RequestItemCardInfo",[], this, "UpdateItemCardInfo");
    }
    
    private function isViewingVendorItems()
    {
        return this.inventoryLists.categoryList.activeSegment == 0;
    }
    
    // @override ItemMenu
    private function updateBottomBar(a_bSelected: Boolean)
    {
        this.navPanel.clearButtons();
        
        if (a_bSelected) {
            this.navPanel.addButton({text: (this.isViewingVendorItems() ? "$Buy" : "$Sell"), controls: skyui.defines.Input.Activate});
        } else {
            this.navPanel.addButton({text: "$Exit", controls: this._cancelControls});
            this.navPanel.addButton({text: "$Search", controls: this._searchControls});
            if (this._platform != 0) {
                this.navPanel.addButton({text: "$Column", controls: this._sortColumnControls});
                this.navPanel.addButton({text: "$Order", controls: this._sortOrderControls});
            }
            this.navPanel.addButton({text: "$Switch Tab", controls: this._switchControls});
        }
        
        this.navPanel.updateButtons(true);
    }

}
