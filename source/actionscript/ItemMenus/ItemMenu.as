class ItemMenu extends MovieClip
{
  /* PRIVATE VARIABLES */

    private var _platform: Number;
    private var _bItemCardFadedIn: Boolean = false;
    private var _bItemCardPositioned: Boolean = false;
    
    private var _quantityMinCount: Number = 5;
    
    private var _config: Object;
    
    private var _bPlayBladeSound: Boolean;
    
    private var _searchKey: Number;
    private var _switchTabKey: Number;
    
    private var _acceptControls: Object;
    private var _cancelControls: Object;
    private var _searchControls: Object;
    private var _switchControls: Object;
    private var _sortColumnControls: Array;
    private var _sortOrderControls: Object;
    
    
  /* STAGE ELEMENTS */
    
    public var inventoryLists: InventoryLists;
    
    public var itemCardFadeHolder: MovieClip;

    public var bottomBar: BottomBar;
    
    public var mouseRotationRect: MovieClip;
    public var exitMenuRect: MovieClip;
    
    
  /* PROPERTIES */
    
    public var itemCard: MovieClip;
    
    public var navPanel: ButtonPanel;
    
    public var bEnableTabs: Boolean = false;
    
    // @GFx
    public var bPCControlsReady: Boolean = true;
    
    public var bFadedIn: Boolean = true;
    
    
  /* INITIALIZATION */

    public function ItemMenu()
    {
        super();
        
        this.itemCard = this.itemCardFadeHolder.ItemCard_mc;
        this.navPanel = this.bottomBar.buttonPanel;
        
        Mouse.addListener(this);
        skyui.util.ConfigManager.registerLoadCallback(this, "onConfigLoad");
        
        this.bFadedIn = true;
        this._bItemCardFadedIn = false;
    }

  /* PUBLIC FUNCTIONS */

    // @API
    public function InitExtensions(a_bPlayBladeSound)
    {
        Stage.scaleMode = "showAll";
        Shared.GlobalFunc.SetLockFunction();
        skse.ExtendData(true);
        skse.ForceContainerCategorization(true);
        
        this._bPlayBladeSound = a_bPlayBladeSound;
        
        this.inventoryLists.InitExtensions();
        
        if (this.bEnableTabs)
            this.inventoryLists.enableTabBar();
        
        gfx.io.GameDelegate.addCallBack("UpdatePlayerInfo", this, "UpdatePlayerInfo");
        gfx.io.GameDelegate.addCallBack("UpdateItemCardInfo", this, "UpdateItemCardInfo");
        gfx.io.GameDelegate.addCallBack("ToggleMenuFade", this, "ToggleMenuFade");
        gfx.io.GameDelegate.addCallBack("RestoreIndices", this, "RestoreIndices");
        
        this.inventoryLists.addEventListener("categoryChange", this, "onCategoryChange");
        this.inventoryLists.addEventListener("itemHighlightChange", this, "onItemHighlightChange");
        this.inventoryLists.addEventListener("showItemsList", this, "onShowItemsList");
        this.inventoryLists.addEventListener("hideItemsList", this, "onHideItemsList");
        
        this.inventoryLists.itemList.addEventListener("itemPress", this ,"onItemSelect");
        
        this.itemCard.addEventListener("quantitySelect", this, "onQuantityMenuSelect");
        this.itemCard.addEventListener("subMenuAction", this, "onItemCardSubMenuAction");
        
        this.positionFixedElements();
        this.updateDynamicListHeight();
        
        this.itemCard._visible = false;
        this.navPanel.hideButtons();
        
        this.exitMenuRect.onMouseDown = function()
        {
            if (this._parent.bFadedIn == true && Mouse.getTopMostEntity() == this)
                this._parent.onExitMenuRectClick();
        };
    }
    
    public function setConfig(a_config: Object)
    {
        this._config = a_config;

        this.positionFloatingElements();
        
        var itemListState = this.inventoryLists.itemList.listState;
        var categoryListState = this.inventoryLists.categoryList.listState;
        var appearance = a_config["Appearance"];
        
        categoryListState.iconSource = appearance.icons.category.source;
        
        itemListState.iconSource = appearance.icons.item.source;
        itemListState.showStolenIcon = appearance.icons.item.showStolen;
        
        itemListState.defaultEnabledColor = appearance.colors.text.enabled;
        itemListState.negativeEnabledColor = appearance.colors.negative.enabled;
        itemListState.stolenEnabledColor = appearance.colors.stolen.enabled;
        itemListState.defaultDisabledColor = appearance.colors.text.disabled;
        itemListState.negativeDisabledColor = appearance.colors.negative.disabled;
        itemListState.stolenDisabledColor = appearance.colors.stolen.disabled;

        var itemList = a_config["ItemList"];
        this._quantityMinCount = itemList.quantityMenu.minCount;
        
        var input = a_config["Input"];
        if (this._platform == 0) {
            this._switchTabKey = input.controls.pc.switchTab;
        } else {
            var gamepad = input.controls.gamepad;
            this._switchTabKey = gamepad.switchTab;
            this._sortColumnControls = [{keyCode: gamepad.prevColumn}, {keyCode: gamepad.nextColumn}];
            this._sortOrderControls = {keyCode: gamepad.sortOrder};
        }
        
        this._switchControls = {keyCode: this._switchTabKey};
        
        this._searchKey = input.controls.pc.search;
        this._searchControls = {keyCode: this._searchKey};
        
        var listLayout = a_config["ListLayout"];
        this.inventoryLists.applyDynamicWidth(listLayout.defaults.entryWidth);

        this.updateBottomBar(false);
    }

    // @API
    public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean)
    {
        this._platform = a_platform;
        
        if (a_platform == 0) {
            this._acceptControls = skyui.defines.Input.Enter;
            this._cancelControls = skyui.defines.Input.Tab;
            
            // Defaults
            this._switchControls = skyui.defines.Input.Alt;
        } else {
            this._acceptControls = skyui.defines.Input.Accept;
            this._cancelControls = skyui.defines.Input.Cancel;
            
            // Defaults
            this._switchControls = skyui.defines.Input.GamepadBack;
            this._sortColumnControls = skyui.defines.Input.SortColumn;
            this._sortOrderControls = skyui.defines.Input.SortOrder;
        }
        
        // Defaults
        this._searchControls = skyui.defines.Input.Space;
        
        this.inventoryLists.setPlatform(a_platform,a_bPS3Switch);
        this.itemCard.SetPlatform(a_platform,a_bPS3Switch);
        this.bottomBar.setPlatform(a_platform,a_bPS3Switch);
    }

    // @API
    public function GetInventoryItemList()
    {
        return this.inventoryLists.itemList;
    }

    // @GFx
    public function handleInput(details: gfx.ui.InputDetails, pathToFocus: Array)
    {
        if (!this.bFadedIn)
            return true;
            
        var nextClip = pathToFocus.shift();
            
        if (nextClip.handleInput(details, pathToFocus))
            return true;
        
        if (Shared.GlobalFunc.IsKeyPressed(details) && (details.navEquivalent == gfx.ui.NavigationCode.TAB || details.navEquivalent == gfx.ui.NavigationCode.SHIFT_TAB))
            gfx.io.GameDelegate.call("CloseMenu", []);

        return true;
    }

    // @API
    public function UpdatePlayerInfo(aUpdateObj: Object)
    {
        this.bottomBar.UpdatePlayerInfo(aUpdateObj, this.itemCard.itemInfo);
    }

    // @API
    public function UpdateItemCardInfo(aUpdateObj: Object)
    {
        this.itemCard.itemInfo = aUpdateObj;
        this.bottomBar.updatePerItemInfo(aUpdateObj);
    }

    // @API
    public function ToggleMenuFade()
    {
        if (this.bFadedIn) {
            this._parent.gotoAndPlay("fadeOut");
            this.bFadedIn = false;
            this.inventoryLists.itemList.disableSelection = true;
            this.inventoryLists.itemList.disableInput = true;
            this.inventoryLists.categoryList.disableSelection = true;
            this.inventoryLists.categoryList.disableInput = true;
        } else {
            this._parent.gotoAndPlay("fadeIn");
        }
    }

    // @API
    public function SetFadedIn()
    {
        this.bFadedIn = true;
        this.inventoryLists.itemList.disableSelection = false;
        this.inventoryLists.itemList.disableInput = false;
        this.inventoryLists.categoryList.disableSelection = false;
        this.inventoryLists.categoryList.disableInput = false;
    }
    
    // @API
    public function RestoreIndices()
    {
        var categoryList = this.inventoryLists.categoryList;
        var itemList = this.inventoryLists.itemList;
        
        if (arguments[0] != undefined && arguments[0] != -1 && arguments.length == 5) {
            categoryList.listState.restoredItem = arguments[0];
            categoryList.onUnsuspend = function()
            {
                this.onItemPress(this.listState.restoredItem, 0);
                delete this.onUnsuspend;
            };
            
            itemList.listState.restoredScrollPosition = arguments[2];
            itemList.listState.restoredSelectedIndex = arguments[1];
            itemList.listState.restoredActiveColumnIndex = arguments[3];
            itemList.listState.restoredActiveColumnState = arguments[4];

            itemList.onUnsuspend = function()
            {
                this.onInvalidate = function()
                {
                    this.scrollPosition = this.listState.restoredScrollPosition;
                    this.selectedIndex = this.listState.restoredSelectedIndex;
                    delete this.onInvalidate;
                };
                
                this.layout.restoreColumnState(this.listState.restoredActiveColumnIndex, this.listState.restoredActiveColumnState);
                delete this.onUnsuspend;
            };
        } else {
            
            categoryList.onUnsuspend = function()
            {
                this.onItemPress(1, 0); // ALL
                delete this.onUnsuspend;
            };
        }
    }
    
    
  /* PRIVATE FUNCTIONS */

    public function onItemCardSubMenuAction(event: Object)
    {
        if (event.opening == true) {
            this.inventoryLists.itemList.disableSelection = true;
            this.inventoryLists.itemList.disableInput = true;
            this.inventoryLists.categoryList.disableSelection = true;
            this.inventoryLists.categoryList.disableInput = true;
        } else if (event.opening == false) {
            this.inventoryLists.itemList.disableSelection = false;
            this.inventoryLists.itemList.disableInput = false;
            this.inventoryLists.categoryList.disableSelection = false;
            this.inventoryLists.categoryList.disableInput = false;
        }
    }
    
    private function onConfigLoad(event: Object)
    {
        this.setConfig(event.config);

        this.inventoryLists.showPanel(this._bPlayBladeSound);
    }

    private function onMouseWheel(delta)
    {
        if(this.mouseRotationRect != undefined && this.mouseRotationRect.hitTest(_root._xmouse, _root._ymouse, true))
        {
            if(this.shouldProcessItemsListInput(false) || (!this.bFadedIn && delta == -1))
            {
                gfx.io.GameDelegate.call("ZoomItemModel", [delta]);
            }
        }
    }

    private function onExitMenuRectClick()
    {
        gfx.io.GameDelegate.call("CloseMenu", []);
    }

    private function onCategoryChange(event: Object)
    {
    }
    
    private function onItemHighlightChange(event: Object)
    {		
        if (event.index != -1) {
            if (!this._bItemCardFadedIn) {
                this._bItemCardFadedIn = true;
                
                if (this._bItemCardPositioned)
                    this.itemCard.FadeInCard();
            }
            
            if (this._bItemCardPositioned)
                gfx.io.GameDelegate.call("UpdateItem3D", [true]);
                
            gfx.io.GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
            
        } else {
            if (!this.bFadedIn)
                this.resetMenu();
            
            if (this._bItemCardFadedIn) {
                this._bItemCardFadedIn = false;
                this.onHideItemsList();
            }
        }
    }

    private function onShowItemsList(event: Object)
    {
        this.onItemHighlightChange(event);
    }

    private function onHideItemsList(event: Object)
    {
        gfx.io.GameDelegate.call("UpdateItem3D", [false]);
        this.itemCard.FadeOutCard();
    }

    private function onItemSelect(event: Object)
    {
        if (event.entry.enabled) {
            if (this._quantityMinCount < 1 || (event.entry.count < this._quantityMinCount))
                this.onQuantityMenuSelect({amount:1});
            else
                this.itemCard.ShowQuantityMenu(event.entry.count);
        } else {
            gfx.io.GameDelegate.call("DisabledItemSelect", []);
        }


    }

    private function onQuantityMenuSelect(event: Object)
    {
        gfx.io.GameDelegate.call("ItemSelect", [event.amount]);
    }

    private function onMouseRotationStart()
    {
        gfx.io.GameDelegate.call("StartMouseRotation", []);
        this.inventoryLists.categoryList.disableSelection = true;
        this.inventoryLists.itemList.disableSelection = true;
    }

    private function onMouseRotationStop()
    {
        gfx.io.GameDelegate.call("StopMouseRotation", []);
        this.inventoryLists.categoryList.disableSelection = false;
        this.inventoryLists.itemList.disableSelection = false;
    }

    private function onMouseRotationFastClick()
    {
        if (this.shouldProcessItemsListInput(false))
            this.onItemSelect({entry: this.inventoryLists.itemList.selectedEntry, keyboardOrMouse: 0});
    }

    private function saveIndices()
    {
        var a = new Array();
        
        // Save selected category, selected item and relative scroll position
        a.push(this.inventoryLists.categoryList.selectedIndex);
        a.push(this.inventoryLists.itemList.selectedIndex);
        a.push(this.inventoryLists.itemList.scrollPosition);
        a.push(this.inventoryLists.itemList.layout.activeColumnIndex);
        a.push(this.inventoryLists.itemList.layout.activeColumnState);
        
        gfx.io.GameDelegate.call("SaveIndices", [a]);
    }

    function updateDynamicListHeight()
    {
        var listPoint = {
            x: this.inventoryLists.itemList._x, 
            y: this.inventoryLists.itemList._y
        };
        this._parent.globalToLocal(listPoint);
        this.inventoryLists.panelContainer.localToGlobal(listPoint);

        var tab = this.inventoryLists.panelContainer.tabBar;
        var paddingItemList = 0;
        var minHeightItemList = 100;
        var heightItemList = this.bottomBar._y - listPoint.y - paddingItemList;

        if (heightItemList < minHeightItemList)
        {
            heightItemList = minHeightItemList;
        }
        if (tab)
        {
            heightItemList -= tab._height;
        }
        this.inventoryLists.itemList.listHeight = heightItemList;
        this.inventoryLists.itemList.requestUpdate();
    }
    
    private function positionFixedElements()
    {
        this.inventoryLists.Lock("TL");
        this.inventoryLists._x -= 20;
        this.inventoryLists._y -= Stage.safeRect.y;
        
        var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
        var rightEdge = Stage.visibleRect.x - Stage.safeRect.x + Stage.visibleRect.width;
        var marginBottomBar = 17;
        
        this.bottomBar.Lock("B");
        this.bottomBar._y += Stage.safeRect.y - this.bottomBar._height + marginBottomBar;
        this.bottomBar.positionElements(leftEdge, rightEdge);
        
        MovieClip(this.exitMenuRect).Lock("TL");
        this.exitMenuRect._x -= Stage.safeRect.x;
        this.exitMenuRect._y -= Stage.safeRect.y;
    }
    
    private function positionFloatingElements()
    {
        var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
        var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
        
        var a = this.inventoryLists.getContentBounds();
        // 25 is hardcoded cause thats the final offset after the animation of the panel container is done
        var panelEdge = this.inventoryLists._x + a[0] + a[2] + 25;

        var itemCardContainer = this.itemCard._parent;
        var itemcardPosition = this._config.ItemInfo.itemcard;
        var itemiconPosition = this._config.ItemInfo.itemicon;
        
        var scaleMult = (rightEdge - panelEdge) / itemCardContainer._width;
        
        // Scale down if necessary
        if (scaleMult < 1.0) {
            itemCardContainer._width *= scaleMult;
            itemCardContainer._height *= scaleMult;
            itemiconPosition.scale *= scaleMult;
        }
        
        if (itemcardPosition.align == "left")
            itemCardContainer._x = panelEdge + leftEdge + itemcardPosition.xOffset;
        else if (itemcardPosition.align == "right")
            itemCardContainer._x = rightEdge - itemCardContainer._width + itemcardPosition.xOffset;
        else
            itemCardContainer._x = panelEdge + itemcardPosition.xOffset + (Stage.visibleRect.x + Stage.visibleRect.width - panelEdge - itemCardContainer._width) / 2;

        itemCardContainer._y = itemCardContainer._y + itemcardPosition.yOffset;

        if (this.mouseRotationRect != undefined) {
            MovieClip(this.mouseRotationRect).Lock("T");
            this.mouseRotationRect._x = this.itemCard._parent._x;
            this.mouseRotationRect._width = itemCardContainer._width;
            this.mouseRotationRect._height = 0.55 * Stage.visibleRect.height;
        }
            
        this._bItemCardPositioned = true;
        
        // Delayed fade in if positioned wasn't set
        if (this._bItemCardFadedIn) {
            gfx.io.GameDelegate.call("UpdateItem3D", [true]);
            this.itemCard.FadeInCard();
        }
    }
    
    private function shouldProcessItemsListInput(abCheckIfOverRect)
   {
      var bCanProcess = this.bFadedIn == true && 
                        this.inventoryLists.currentState == InventoryLists.SHOW_PANEL && 
                        this.inventoryLists.itemList.itemCount > 0 && 
                        !this.inventoryLists.itemList.disableSelection && 
                        !this.inventoryLists.itemList.disableInput;

      if (bCanProcess && this._platform == 0 && abCheckIfOverRect)
         bCanProcess = this.inventoryLists.itemList.hitTest(_root._xmouse, _root._ymouse, true);
      
      return bCanProcess;
   }

    // Added to prevent clicks on the scrollbar from equipping/using stuff
    function confirmSelectedEntry()
    {
        // only confirm when using mouse
        if(this._platform != 0) return true;
        
        var list = this.inventoryLists.itemList;
        if(list.selectedIndex != -1 && list.selectedEntry != undefined && list.selectedEntry.clipIndex != undefined) 
        {
            var clip = list.getClipByIndex(list.selectedEntry.clipIndex);
            if (clip != undefined && clip._visible && clip.hitTest(_root._xmouse, _root._ymouse, true))
                return true;
        }
        return false;
    }

    /*
        This method is only used for the InventoryMenu Favorites Category.
        It prevents a lockup when unfavoriting the last item from favorites list by
        resetting the menu.
    */
    private function resetMenu()
    {
        this.saveIndices();
        gfx.io.GameDelegate.call("CloseMenu", []);
        skse.OpenMenu("Inventory Menu");
    }

    /*
        This method is only used in InventoryMenu and ContainerMenu.
        It it allows determination of read books.
        Item list isn't re-sent when you activate a book, unlike other items,
        so the flags don't get updated.
        If the item is a book, we apply the book read flag and invalidate locally
    */
    private function checkBook(a_entryObject: Object)
    {

        if (a_entryObject.type != skyui.defines.Inventory.ICT_BOOK || _global.skse == null)
            return false;

        a_entryObject.flags |= skyui.defines.Item.BOOKFLAG_READ;
        a_entryObject.skyui_itemDataProcessed = false;
        
        this.inventoryLists.itemList.requestInvalidate();

        return true;
    }
    
    private function getEquipButtonData(a_itemType: Number, a_bAlwaysEquip: Boolean)
    {
        var btnData = {};
        
        var useControls = skyui.defines.Input.Activate;
        var equipControls = skyui.defines.Input.Equip;
        
        switch (a_itemType) {
            case skyui.defines.Inventory.ICT_ARMOR :
                btnData.text = "$Equip";
                btnData.controls = a_bAlwaysEquip ? equipControls : useControls;
                break;
            case skyui.defines.Inventory.ICT_BOOK :
                btnData.text = "$Read";
                btnData.controls = a_bAlwaysEquip ? equipControls : useControls;
                break;
            case skyui.defines.Inventory.ICT_FOOD :
            case skyui.defines.Inventory.ICT_INGREDIENT :
                btnData.text = "$Eat";
                btnData.controls = a_bAlwaysEquip ? equipControls : useControls;
                break;
            case skyui.defines.Inventory.ICT_WEAPON :
                btnData.text = "$Equip";
                btnData.controls = equipControls;
                break;

            default :
                btnData.text = "$Use";
                btnData.controls = a_bAlwaysEquip ? equipControls : useControls;
        }
        
        return btnData;
    }
    
    // @abstract
    private function updateBottomBar(a_bSelected: Boolean) {}
}
