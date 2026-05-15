class ContainerMenu extends ItemMenu
{
  /* CONSTANTS */

    private static var NULL_HAND: Number = -1;
    private static var RIGHT_HAND: Number = 0;
    private static var LEFT_HAND: Number = 1;


  /* PRIVATE VARIABLES */

    private var _bEquipMode: Boolean = false;
    private var _equipHand: Number;

    private var _equipModeKey: Number;
    private var _equipModeControls: Object;
    
    private var _categoryListIconArt: Array;
    private var _tabBarIconArt: Array;
    
    
  /* PROPERTIES */
    
    // @API
    public var bNPCMode: Boolean = false;
    
    // @override ItemMenu
    public var bEnableTabs: Boolean = true;


  /* INITIALIZATION */

    public function ContainerMenu()
    {
        super();
        
        this._categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
        
        this._tabBarIconArt = ["take", "give"];
    }


  /* PUBLIC FUNCTIONS */

    public function InitExtensions()
    {
        super.InitExtensions();
        
        this.inventoryLists.tabBarIconArt = this._tabBarIconArt;

        // Initialize menu-specific list components
        var categoryList: CategoryList = this.inventoryLists.categoryList;
        categoryList.iconArt = this._categoryListIconArt;

        gfx.io.GameDelegate.addCallBack("AttemptEquip", this, "AttemptEquip");
        gfx.io.GameDelegate.addCallBack("XButtonPress", this, "onXButtonPress");
        this.itemCardFadeHolder.StealTextInstance._visible = false;
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
            
        this._equipModeKey = a_config["Input"].controls.pc.equipMode;
        this._equipModeControls = {keyCode: this._equipModeKey};
    }

    // @API
    public function ShowItemsList()
    {
        // Not necessary anymore. Now handled in onShowItemsList for consistency reasons.
        //inventoryLists.showItemsList();
    }

    // @GFx
    public function handleInput(details: InputDetails, pathToFocus: Array)
    {
        super.handleInput(details,pathToFocus);
      
        if (this._platform == 0 && details.skseKeycode == this._equipModeKey) {
            this._bEquipMode = details.value != "keyUp";
            
            if (this.shouldProcessItemsListInput(false))
                this.updateBottomBar(true);
        }
        return true;
    }

    // @override ItemMenu
    public function UpdateItemCardInfo(a_updateObj: Object)
    {
        super.UpdateItemCardInfo(a_updateObj);

        this.updateBottomBar(true);

        if (a_updateObj.pickpocketChance != undefined) {
            this.itemCardFadeHolder.StealTextInstance._visible = true;
            this.itemCardFadeHolder.StealTextInstance.PercentTextInstance.html = true;
            this.itemCardFadeHolder.StealTextInstance.PercentTextInstance.htmlText = "<font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + a_updateObj.pickpocketChance + "%</font>" + (this.isViewingContainer() ? skyui.util.Translator.translate("$ TO STEAL") : skyui.util.Translator.translate("$ TO PLACE"));
        } else {
            this.itemCardFadeHolder.StealTextInstance._visible = false;
        }
    }

    // @API
    public function AttemptEquip(a_slot: Number, a_bCheckOverList: Boolean)
    {
        var bCheckOverList = a_bCheckOverList == undefined ? true : a_bCheckOverList;
        
        if (!this.shouldProcessItemsListInput(bCheckOverList) || !this.confirmSelectedEntry())
            return;
            
        if (this._platform == 0) {
            if (this._bEquipMode)
                this.startItemEquip(a_slot);
            else
                this.startItemTransfer();
        } else {
            this.startItemEquip(a_slot);
        }
    }

    // @API
    public function onXButtonPress()
    {
        // If we are zoomed into an item, do nothing
        if (!this.bFadedIn)
            return;
        
        if (this.isViewingContainer() && !this.bNPCMode)
            gfx.io.GameDelegate.call("TakeAllItems", []);
    }

    // @API
    public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean)
    {
        super.SetPlatform(a_platform, a_bPS3Switch);

        this._bEquipMode = (a_platform != 0);
    }
    
    
  /* PRIVATE FUNCTIONS */

    private function onItemSelect(event: Object)
    {
        if (event.keyboardOrMouse != 0) {
            if (this._platform == 0 && this._bEquipMode)
                this.startItemEquip(ContainerMenu.NULL_HAND);
            else
                this.startItemTransfer();
        }
    }

    private function onItemCardSubMenuAction(event: Object)
    {
        super.onItemCardSubMenuAction(event);

        if (event.menu == "quantity")
            gfx.io.GameDelegate.call("QuantitySliderOpen", [event.opening]);
    }

    // @override ItemMenu
    private function onItemHighlightChange(event: Object)
    {
        if (event.index != -1)
            this.updateBottomBar(true);

        super.onItemHighlightChange(event);
    }

    // @override ItemMenu
    private function onShowItemsList(event: Object)
    {
        this.inventoryLists.showItemsList();
    }

    // @override ItemMenu
    private function onHideItemsList(event: Object)
    {
        super.onHideItemsList(event);

        this.bottomBar.updatePerItemInfo({type: skyui.defines.Inventory.ICT_NONE});

        this.updateBottomBar(false);
    }

    private function onMouseRotationFastClick(a_mouseButton: Number)
    {
        gfx.io.GameDelegate.call("CheckForMouseEquip", [a_mouseButton], this, "AttemptEquip");
    }

    private function onQuantityMenuSelect(event: Object)
    {
        if (_equipHand != undefined) {
            gfx.io.GameDelegate.call("EquipItem",[_equipHand, event.amount]);

            if (!this.checkBook(this.inventoryLists.itemList.selectedEntry))
                this.checkPoison(this.inventoryLists.itemList.selectedEntry);

            this._equipHand = undefined;
            return;
        }

        if (this.inventoryLists.itemList.selectedEntry.enabled) {
            gfx.io.GameDelegate.call("ItemTransfer", [event.amount, this.isViewingContainer()]);
            return;
        }

        gfx.io.GameDelegate.call("DisabledItemSelect",[]);
    }
    
    // @override ItemMenu
    private function updateBottomBar(a_bSelected: Boolean)
    {
        this.navPanel.clearButtons();
        
        if (a_bSelected && this.inventoryLists.itemList.selectedIndex != -1 && this.inventoryLists.currentState == InventoryLists.SHOW_PANEL) {
            if (this.isViewingContainer()) {
                if (this._platform != 0) {
                    this.navPanel.addButton({text: "$Take", controls: skyui.defines.Input.Activate});
                    this.navPanel.addButton(this.getEquipButtonData(this.itemCard.itemInfo.type, true));
                } else {
                    if (this._bEquipMode)
                        this.navPanel.addButton(this.getEquipButtonData(this.itemCard.itemInfo.type));
                    else
                        this.navPanel.addButton({text: "$Take", controls: skyui.defines.Input.Activate});
                }
                if (!this.bNPCMode)
                    this.navPanel.addButton({text: "$Take All", controls: skyui.defines.Input.XButton});
            } else {
                if (this._platform != 0) {
                    this.navPanel.addButton({text: bNPCMode ? "$Give" : "$Store", controls: skyui.defines.Input.Activate});
                    this.navPanel.addButton(this.getEquipButtonData(this.itemCard.itemInfo.type, true));
                } else {
                    if (this._bEquipMode)
                        this.navPanel.addButton(this.getEquipButtonData(this.itemCard.itemInfo.type));
                    else
                        this.navPanel.addButton({text: this.bNPCMode ? "$Give" : "$Store", controls: skyui.defines.Input.Activate});
                }

                this.navPanel.addButton({text: this.itemCard.itemInfo.favorite ? "$Unfavorite" : "$Favorite", controls: skyui.defines.Input.YButton});
            }
            if (!this._bEquipMode)
                this.navPanel.addButton({text: "$Equip Mode", controls: this._equipModeControls});
        } else {
            this.navPanel.addButton({text: "$Exit", controls: this._cancelControls});
            this.navPanel.addButton({text: "$Search", controls: this._searchControls});
            if (this._platform != 0) {
                this.navPanel.addButton({text: "$Column", controls: this._sortColumnControls});
                this.navPanel.addButton({text: "$Order", controls: this._sortOrderControls});
            }
            this.navPanel.addButton({text: "$Switch Tab", controls: this._switchControls});
            
            if (this.isViewingContainer() && !this.bNPCMode)
                this.navPanel.addButton({text: "$Take All", controls: skyui.defines.Input.XButton});			

        }
        
        this.navPanel.updateButtons(true);
    }

    private function startItemTransfer()
    {
        if (this.inventoryLists.itemList.selectedEntry.enabled) {
            // Don't remove. This is so if an item weighs nothing, it takes the whole stack
            //  Gold, for example.
            if (this.itemCard.itemInfo.weight == 0 && this.isViewingContainer()) {
                this.onQuantityMenuSelect({amount: this.inventoryLists.itemList.selectedEntry.count});
                return;
            }

            if (this._quantityMinCount < 1 || (this.inventoryLists.itemList.selectedEntry.count < this._quantityMinCount)) {
                this.onQuantityMenuSelect({amount:1});
            } else {
                this.itemCard.ShowQuantityMenu(this.inventoryLists.itemList.selectedEntry.count);
            }
        }
    }

    private function startItemEquip(a_equipHand: Number)
    {
        if (this.isViewingContainer()) {
            this._equipHand = a_equipHand;
            this.startItemTransfer();
            return;
        }

        gfx.io.GameDelegate.call("EquipItem", [a_equipHand]);
        if (!this.checkBook(this.inventoryLists.itemList.selectedEntry))
            this.checkPoison(this.inventoryLists.itemList.selectedEntry);
    }
    
    private function isViewingContainer()
    {
        return (this.inventoryLists.categoryList.activeSegment == 0);
    }

    /*
        This method is only used in ContainerMenu.
        If you attempt to use a poison in Container menu
        a dialog box is presented to ask whether you want to poison the equipped weapon
        If you release the _equipModeKey while the diaolog is present, the keyUp event
        for this key is not received by ContainerMenu, so _bEquipMode remains true
        meaning that the bottom bar buttons are incorrect
    */
    private function checkPoison(a_entryObject: Object)
    {
        if (a_entryObject.type != skyui.defines.Inventory.ICT_POTION || _global.skse == null)
            return false;

        if (a_entryObject.subType != skyui.defines.Item.POTION_POISON)
            return false;

        // force equip mode to false.
        // Use this until we can detect if a specific keyCode is depressed
        // _bEquipMode = skse.IsKeyDown(_equipModeKey)
        this._bEquipMode = false;

        return true;
    }
}
