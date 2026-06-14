class InventoryMenu extends ItemMenu
{
  /* PRIVATE VARIABLES */

    private var _bMenuClosing: Boolean = false;
    private var _bSwitchMenus: Boolean = false;

    private var _categoryListIconArt: Array;
    
    
  /* PROPERTIES */

    // @GFx
    public var bPCControlsReady: Boolean = true;


  /* INITIALIZATION */

    public function InventoryMenu()
    {
        super();
        
        this._categoryListIconArt = ["cat_favorites", "inv_all", "inv_weapons", "inv_armor",
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
        
        this.inventoryLists.zoomButtonHolder.gotoAndStop(1);
    
        // Initialize menu-specific list components
        var categoryList: CategoryList = this.inventoryLists.categoryList;
        categoryList.iconArt = this._categoryListIconArt;

        this.itemCard.addEventListener("itemPress", this, "onItemCardListPress");
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

    // @GFx
    public function handleInput(details: InputDetails, pathToFocus: Array)
    {
        if (!this.bFadedIn)
            return true;
        
        var nextClip = pathToFocus.shift();
        if (nextClip.handleInput(details, pathToFocus))
            return true;
            
        if (Shared.GlobalFunc.IsKeyPressed(details)) {
            if (details.navEquivalent == gfx.ui.NavigationCode.TAB || details.navEquivalent == gfx.ui.NavigationCode.SHIFT_TAB ) {
                this.startMenuFade();
                gfx.io.GameDelegate.call("CloseTweenMenu", []);
            } else if (!this.inventoryLists.itemList.disableInput) {
                // Gamepad back || ALT (default) || 'P'
                if (details.skseKeycode == this._switchTabKey || details.control == "Quick Magic")
                    this.openMagicMenu(true);
            }
        }
        
        return true;
    }

    // @API
    public function AttemptEquip(a_slot: Number, a_bCheckOverList: Boolean)
    {
        var bCheckOverList = a_bCheckOverList != undefined ? a_bCheckOverList : true;
        if (this.shouldProcessItemsListInput(bCheckOverList) && this.confirmSelectedEntry()) {
            gfx.io.GameDelegate.call("ItemSelect", [a_slot]);
            this.checkBook(this.inventoryLists.itemList.selectedEntry);
        }
    }

    // @API
    public function DropItem()
    {
        if (this.shouldProcessItemsListInput(false) && this.inventoryLists.itemList.selectedEntry != undefined) {
            if (this._quantityMinCount < 1 || (this.inventoryLists.itemList.selectedEntry.count < this._quantityMinCount))
                this.onQuantityMenuSelect({amount:1});
            else
                this.itemCard.ShowQuantityMenu(this.inventoryLists.itemList.selectedEntry.count);
        }
    }

    // @API
    public function AttemptChargeItem()
    {
        if (this.inventoryLists.itemList.selectedIndex == -1)
            return;
        
        if (this.shouldProcessItemsListInput(false) && this.itemCard.itemInfo.charge != undefined && this.itemCard.itemInfo.charge < 100)
            gfx.io.GameDelegate.call("ShowSoulGemList", []);
    }

    // @override ItemMenu
    public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean)
    {		
        this.inventoryLists.zoomButtonHolder.gotoAndStop(1);
        this.inventoryLists.zoomButtonHolder.ZoomButton._visible = a_platform != 0;
        this.inventoryLists.zoomButtonHolder.ZoomButton.SetPlatform(a_platform, a_bPS3Switch);
        
        super.SetPlatform(a_platform, a_bPS3Switch);
    }

    // @API
    public function ItemRotating()
    {
        this.inventoryLists.zoomButtonHolder.PlayForward(this.inventoryLists.zoomButtonHolder._currentframe);
    }
    
    
/* PRIVATE FUNCTIONS */

    // @override ItemMenu
    private function onExitMenuRectClick()
    {
        this.startMenuFade();
        gfx.io.GameDelegate.call("ShowTweenMenu", []);
    }

    private function onFadeCompletion()
    {
        if (!this._bMenuClosing)
            return;

        gfx.io.GameDelegate.call("CloseMenu", []);
        if (this._bSwitchMenus) {
            gfx.io.GameDelegate.call("CloseTweenMenu",[]);
            skse.OpenMenu("MagicMenu");
        }
    }

    // @override ItemMenu
    private function onShowItemsList(event: Object)
    {
        super.onShowItemsList(event);
        
        if (event.index != -1)
            this.updateBottomBar(true);
    }

    private function onItemHighlightChange(event: Object)
    {
        super.onItemHighlightChange(event);
        
        if (event.index != -1)
            this.updateBottomBar(true);
            
    }

    // @override ItemMenu
    private function onHideItemsList(event: Object)
    {
        super.onHideItemsList(event);

        this.bottomBar.updatePerItemInfo({type: skyui.defines.Inventory.ICT_NONE});
        
        this.updateBottomBar(false);
    }

    // @override ItemMenu
    private function onItemSelect(event: Object)
    {
        if (event.entry.enabled && event.keyboardOrMouse != 0) {
            gfx.io.GameDelegate.call("ItemSelect", []);
            this.checkBook(event.entry);
        }
    }

    // @override ItemMenu
    private function onQuantityMenuSelect(event: Object)
    {
        gfx.io.GameDelegate.call("ItemDrop", [event.amount]);
        
        // Bug Fix: ItemCard does not update when attempting to drop quest items through the quantity menu
        //   so let's request an update even though it may be redundant.
        gfx.io.GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
    }


    private function onMouseRotationFastClick(aiMouseButton: Number)
    {
        gfx.io.GameDelegate.call("CheckForMouseEquip", [aiMouseButton], this, "AttemptEquip");
    }

    private function onItemCardListPress(event: Object)
    {
        gfx.io.GameDelegate.call("ItemCardListCallback", [event.index]);
    }

    // @override ItemMenu
    private function onItemCardSubMenuAction(event: Object)
    {
        super.onItemCardSubMenuAction(event);
        gfx.io.GameDelegate.call("QuantitySliderOpen", [event.opening]);
        
        if (event.menu == "list") {
            if (event.opening == true) {
                this.navPanel.clearButtons();
                this.navPanel.addButton({text: "$Select", controls: this._acceptControls});
                this.navPanel.addButton({text: "$Cancel", controls: this._cancelControls});
                this.navPanel.updateButtons(true);
            } else {
                gfx.io.GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
                this.updateBottomBar(true);
            }
        }
    }
    
    private function openMagicMenu(a_bFade: Boolean)
    {
        if (a_bFade) {
            this._bSwitchMenus = true;
            this.startMenuFade();
        } else {
            this.saveIndices();
            gfx.io.GameDelegate.call("CloseMenu",[]);
            gfx.io.GameDelegate.call("CloseTweenMenu",[]);
            skse.OpenMenu("MagicMenu");
        }
    }
    
    private function startMenuFade()
    {
        this.inventoryLists.hidePanel();
        this.ToggleMenuFade();
        this.saveIndices();
        this._bMenuClosing = true;
    }
    
    // @override ItemMenu
    private function updateBottomBar(a_bSelected: Boolean)
    {
        this.navPanel.clearButtons();
        
        if (a_bSelected) {
            this.navPanel.addButton(this.getEquipButtonData(this.itemCard.itemInfo.type));
            this.navPanel.addButton({text: "$Drop", controls: skyui.defines.Input.XButton});
            
            if (this.inventoryLists.itemList.selectedEntry.filterFlag & this.inventoryLists.categoryList.entryList[0].flag != 0)
                this.navPanel.addButton({text: "$Unfavorite", controls: skyui.defines.Input.YButton});
            else
                this.navPanel.addButton({text: "$Favorite", controls: skyui.defines.Input.YButton});
    
            if (this.itemCard.itemInfo.charge != undefined && this.itemCard.itemInfo.charge < 100)
                this.navPanel.addButton({text: "$Charge", controls: skyui.defines.Input.ChargeItem});
                
        } else {
            this.navPanel.addButton({text: "$Exit", controls: this._cancelControls});
            this.navPanel.addButton({text: "$Search", controls: this._searchControls});
            if (this._platform != 0) {
                this.navPanel.addButton({text: "$Column", controls: this._sortColumnControls});
                this.navPanel.addButton({text: "$Order", controls: this._sortOrderControls});
            }
            this.navPanel.addButton({text: "$Magic", controls: this._switchControls});
        }
        
        this.navPanel.updateButtons(true);
    }
}
