class MagicMenu extends ItemMenu
{
  /* PRIVATE VARIABLES */

    private var _hideButtonFlag: Number = 0;
    private var _bMenuClosing: Boolean = false;
    private var _bSwitchMenus: Boolean = false;

    private var _categoryListIconArt: Array;
    
    
  /* PROPERTIES */

    public var hideButtonFlag: Number;
    

  /* INITIALIZATION */

    public function MagicMenu()
    {
        super();
        
        this._categoryListIconArt = ["cat_favorites", "mag_all", "mag_alteration", "mag_illusion",
                            "mag_destruction", "mag_conjuration", "mag_restoration", "mag_shouts",
                            "mag_powers", "mag_activeeffects"];
    }
    
    
  /* PUBLIC FUNCTIONS */

    public function InitExtensions()
    {
        super.InitExtensions();
        
        gfx.io.GameDelegate.addCallBack("DragonSoulSpent", this, "DragonSoulSpent");
        gfx.io.GameDelegate.addCallBack("AttemptEquip", this , "AttemptEquip");
        
        this.bottomBar.updatePerItemInfo({type: skyui.defines.Inventory.ICT_SPELL_DEFAULT});
        
        // Initialize menu-specific list components
        var categoryList: CategoryList = this.inventoryLists.categoryList;
        categoryList.iconArt = this._categoryListIconArt;
    }

    // @override ItemMenu
    public function setConfig(a_config: Object)
    {
        super.setConfig(a_config);
        
        var itemList: TabularList = this.inventoryLists.itemList;
        itemList.addDataProcessor(new MagicDataSetter(a_config["Appearance"]));
        itemList.addDataProcessor(new MagicIconSetter(a_config["Appearance"]));
        itemList.addDataProcessor(new skyui.props.PropertyDataExtender(a_config["Appearance"], a_config["Properties"], "magicProperties", "magicIcons", "magicCompoundProperties"));
        
        var layout: ListLayout = skyui.components.list.ListLayoutManager.createLayout(a_config["ListLayout"], "MagicListLayout");
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
                gfx.io.GameDelegate.call("CloseTweenMenu",[]);
            } else if (!this.inventoryLists.itemList.disableInput) {
                // Gamepad back || ALT (default) || 'I'
                if (details.skseKeycode == this._switchTabKey || details.control == "Quick Inventory")
                    this.openInventoryMenu(true);
            }
        }
        return true;
    }

    // @API
    public function DragonSoulSpent()
    {
        this.itemCard.itemInfo.soulSpent = true;
        this.updateBottomBar(true);
    }
    
    // @API
    public function AttemptEquip(a_slot: Number)
    {
        if (this.shouldProcessItemsListInput(true) && this.confirmSelectedEntry())
            gfx.io.GameDelegate.call("ItemSelect",[a_slot]);
    }
    
    
  /* PRIVATE FUNCTIONS */

    // @override ItemMenu
    private function onItemSelect(event: Object)
    {
        //Vanilla bugfix
        if (event.keyboardOrMouse != 0) {
            if (event.entry.enabled)
                gfx.io.GameDelegate.call("ItemSelect",[]);
            else
                gfx.io.GameDelegate.call("ShowShoutFail",[]);
        }
    }

    // @override ItemMenu
    private function onExitMenuRectClick()
    {
        this.startMenuFade();
        gfx.io.GameDelegate.call("ShowTweenMenu",[]);
    }

    private function onFadeCompletion()
    {
        if (!this._bMenuClosing)
            return;

        gfx.io.GameDelegate.call("CloseMenu", []);
        if (this._bSwitchMenus) {
            gfx.io.GameDelegate.call("CloseTweenMenu",[]);
            skse.OpenMenu("InventoryMenu");
        }
    }

    // @override ItemMenu
    private function onShowItemsList(event: Object)
    {
        super.onShowItemsList(event);
        
        if (event.index != -1)
            this.updateBottomBar(true);
    }

    // @override ItemMenu
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
        
        this.bottomBar.updatePerItemInfo({type: skyui.defines.Inventory.ICT_SPELL_DEFAULT});
        
        this.updateBottomBar(false);
    }
    
    private function openInventoryMenu(a_bFade: Boolean)
    {
        if (a_bFade) {
            this._bSwitchMenus = true;
            this.startMenuFade();
        } else {
            this.saveIndices();
            gfx.io.GameDelegate.call("CloseMenu",[]);
            gfx.io.GameDelegate.call("CloseTweenMenu",[]);
            skse.OpenMenu("InventoryMenu");
        }
    }
    
    // @override ItemMenu
    private function updateBottomBar(a_bSelected: Boolean)
    {
        this.navPanel.clearButtons();
        
        if (a_bSelected && (this.inventoryLists.itemList.selectedEntry.filterFlag & skyui.defines.Inventory.FILTERFLAG_MAGIC_ACTIVEEFFECTS) == 0) {
            this.navPanel.addButton({text: "$Equip", controls: skyui.defines.Input.Equip});
            
            if (this.inventoryLists.itemList.selectedEntry.filterFlag & this.inventoryLists.categoryList.entryList[0].flag != 0)
                this.navPanel.addButton({text: "$Unfavorite", controls: skyui.defines.Input.YButton});
            else
                this.navPanel.addButton({text: "$Favorite", controls: skyui.defines.Input.YButton});
    
            if (this.itemCard.itemInfo.showUnlocked)
                this.navPanel.addButton({text: "$Unlock", controls: skyui.defines.Input.XButton});
                
        } else {
            this.navPanel.addButton({text: "$Exit", controls: this._cancelControls});
            this.navPanel.addButton({text: "$Search", controls: this._searchControls});
            if (this._platform != 0) {
                this.navPanel.addButton({text: "$Column", controls: this._sortColumnControls});
                this.navPanel.addButton({text: "$Order", controls: this._sortOrderControls});
            }
            this.navPanel.addButton({text: "$Inventory", controls: this._switchControls});
        }
        
        this.navPanel.updateButtons(true);
    }
    
    private function startMenuFade()
    {
        this.inventoryLists.hidePanel();
        this.ToggleMenuFade();
        this.saveIndices();
        this._bMenuClosing = true;
    }
}
