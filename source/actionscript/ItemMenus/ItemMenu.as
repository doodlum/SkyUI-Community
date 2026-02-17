class ItemMenu extends MovieClip
{
   var _acceptControls;
   var _bPlayBladeSound;
   var _cancelControls;
   var _config;
   var _platform;
   var _searchControls;
   var _searchKey;
   var _sortColumnControls;
   var _sortOrderControls;
   var _switchControls;
   var _switchTabKey;
   var bottomBar;
   var exitMenuRect;
   var inventoryLists;
   var itemCard;
   var itemCardFadeHolder;
   var layout;
   var listState;
   var mouseRotationRect;
   var navPanel;
   var onInvalidate;
   var onItemPress;
   var onUnsuspend;
   var scrollPosition;
   var selectedIndex;
   var _bItemCardFadedIn = false;
   var _bItemCardPositioned = false;
   var _quantityMinCount = 5;
   var bEnableTabs = false;
   var bPCControlsReady = true;
   var bFadedIn = true;
   function ItemMenu()
   {
      super();
      this.itemCard = this.itemCardFadeHolder.ItemCard_mc;
      this.navPanel = this.bottomBar.buttonPanel;
      Mouse.addListener(this);
      skyui.util.ConfigManager.registerLoadCallback(this,"onConfigLoad");
      this.bFadedIn = true;
      this._bItemCardFadedIn = false;
   }
   function InitExtensions(a_bPlayBladeSound)
   {
      skse.ExtendData(true);
      skse.ForceContainerCategorization(true);
      this._bPlayBladeSound = a_bPlayBladeSound;
      this.inventoryLists.InitExtensions();
      if(this.bEnableTabs)
      {
         this.inventoryLists.enableTabBar();
      }
      gfx.io.GameDelegate.addCallBack("UpdatePlayerInfo",this,"UpdatePlayerInfo");
      gfx.io.GameDelegate.addCallBack("UpdateItemCardInfo",this,"UpdateItemCardInfo");
      gfx.io.GameDelegate.addCallBack("ToggleMenuFade",this,"ToggleMenuFade");
      gfx.io.GameDelegate.addCallBack("RestoreIndices",this,"RestoreIndices");
      this.inventoryLists.addEventListener("categoryChange",this,"onCategoryChange");
      this.inventoryLists.addEventListener("itemHighlightChange",this,"onItemHighlightChange");
      this.inventoryLists.addEventListener("showItemsList",this,"onShowItemsList");
      this.inventoryLists.addEventListener("hideItemsList",this,"onHideItemsList");
      this.inventoryLists.itemList.addEventListener("itemPress",this,"onItemSelect");
      this.itemCard.addEventListener("quantitySelect",this,"onQuantityMenuSelect");
      this.itemCard.addEventListener("subMenuAction",this,"onItemCardSubMenuAction");
      this.positionFixedElements();
      this.itemCard._visible = false;
      this.navPanel.hideButtons();
      this.exitMenuRect.onMouseDown = function()
      {
         if(this._parent.bFadedIn == true && Mouse.getTopMostEntity() == this)
         {
            this._parent.onExitMenuRectClick();
         }
      };
   }
   function setConfig(a_config)
   {
      this._config = a_config;
      this.positionFloatingElements();
      var _loc3_ = this.inventoryLists.itemList.listState;
      var _loc8_ = this.inventoryLists.categoryList.listState;
      var _loc2_ = a_config.Appearance;
      _loc8_.iconSource = _loc2_.icons.category.source;
      _loc3_.iconSource = _loc2_.icons.item.source;
      _loc3_.showStolenIcon = _loc2_.icons.item.showStolen;
      _loc3_.defaultEnabledColor = _loc2_.colors.text.enabled;
      _loc3_.negativeEnabledColor = _loc2_.colors.negative.enabled;
      _loc3_.stolenEnabledColor = _loc2_.colors.stolen.enabled;
      _loc3_.defaultDisabledColor = _loc2_.colors.text.disabled;
      _loc3_.negativeDisabledColor = _loc2_.colors.negative.disabled;
      _loc3_.stolenDisabledColor = _loc2_.colors.stolen.disabled;
      this._quantityMinCount = a_config.ItemList.quantityMenu.minCount;
      var _loc6_;
      var _loc5_;
      var _loc7_;
      if(this._platform == 0)
      {
         this._switchTabKey = a_config.Input.controls.pc.switchTab;
      }
      else
      {
         this._switchTabKey = a_config.Input.controls.gamepad.switchTab;
         _loc6_ = a_config.Input.controls.gamepad.prevColumn;
         _loc5_ = a_config.Input.controls.gamepad.nextColumn;
         _loc7_ = a_config.Input.controls.gamepad.sortOrder;
         this._sortColumnControls = [{keyCode:_loc6_},{keyCode:_loc5_}];
         this._sortOrderControls = {keyCode:_loc7_};
      }
      this._switchControls = {keyCode:this._switchTabKey};
      this._searchKey = a_config.Input.controls.pc.search;
      this._searchControls = {keyCode:this._searchKey};
      this.updateBottomBar(false);
   }
   function SetPlatform(a_platform, a_bPS3Switch)
   {
      this._platform = a_platform;
      if(a_platform == 0)
      {
         this._acceptControls = skyui.defines.Input.Enter;
         this._cancelControls = skyui.defines.Input.Tab;
         this._switchControls = skyui.defines.Input.Alt;
      }
      else
      {
         this._acceptControls = skyui.defines.Input.Accept;
         this._cancelControls = skyui.defines.Input.Cancel;
         this._switchControls = skyui.defines.Input.GamepadBack;
         this._sortColumnControls = skyui.defines.Input.SortColumn;
         this._sortOrderControls = skyui.defines.Input.SortOrder;
      }
      this._searchControls = skyui.defines.Input.Space;
      this.inventoryLists.setPlatform(a_platform,a_bPS3Switch);
      this.itemCard.SetPlatform(a_platform,a_bPS3Switch);
      this.bottomBar.setPlatform(a_platform,a_bPS3Switch);
   }
   function GetInventoryItemList()
   {
      return this.inventoryLists.itemList;
   }
   function handleInput(details, pathToFocus)
   {
      if(!this.bFadedIn)
      {
         return true;
      }
      var _loc3_ = pathToFocus.shift();
      if(_loc3_.handleInput(details,pathToFocus))
      {
         return true;
      }
      if(Shared.GlobalFunc.IsKeyPressed(details) && (details.navEquivalent == gfx.ui.NavigationCode.TAB || details.navEquivalent == gfx.ui.NavigationCode.SHIFT_TAB))
      {
         gfx.io.GameDelegate.call("CloseMenu",[]);
      }
      return true;
   }
   function UpdatePlayerInfo(aUpdateObj)
   {
      this.bottomBar.UpdatePlayerInfo(aUpdateObj,this.itemCard.itemInfo);
   }
   function UpdateItemCardInfo(aUpdateObj)
   {
      this.itemCard.itemInfo = aUpdateObj;
      this.bottomBar.updatePerItemInfo(aUpdateObj);
   }
   function ToggleMenuFade()
   {
      if(this.bFadedIn)
      {
         this._parent.gotoAndPlay("fadeOut");
         this.bFadedIn = false;
         this.inventoryLists.itemList.disableSelection = true;
         this.inventoryLists.itemList.disableInput = true;
         this.inventoryLists.categoryList.disableSelection = true;
         this.inventoryLists.categoryList.disableInput = true;
      }
      else
      {
         this._parent.gotoAndPlay("fadeIn");
      }
   }
   function SetFadedIn()
   {
      this.bFadedIn = true;
      this.inventoryLists.itemList.disableSelection = false;
      this.inventoryLists.itemList.disableInput = false;
      this.inventoryLists.categoryList.disableSelection = false;
      this.inventoryLists.categoryList.disableInput = false;
   }
   function RestoreIndices()
   {
      var _loc4_ = this.inventoryLists.categoryList;
      var _loc3_ = this.inventoryLists.itemList;
      if(arguments[0] != undefined && arguments[0] != -1 && arguments.length == 5)
      {
         _loc4_.listState.restoredItem = arguments[0];
         _loc4_.onUnsuspend = function()
         {
            this.onItemPress(this.listState.restoredItem,0);
            delete this.onUnsuspend;
         };
         _loc3_.listState.restoredScrollPosition = arguments[2];
         _loc3_.listState.restoredSelectedIndex = arguments[1];
         _loc3_.listState.restoredActiveColumnIndex = arguments[3];
         _loc3_.listState.restoredActiveColumnState = arguments[4];
         _loc3_.onUnsuspend = function()
         {
            this.onInvalidate = function()
            {
               this.scrollPosition = this.listState.restoredScrollPosition;
               this.selectedIndex = this.listState.restoredSelectedIndex;
               delete this.onInvalidate;
            };
            this.layout.restoreColumnState(this.listState.restoredActiveColumnIndex,this.listState.restoredActiveColumnState);
            delete this.onUnsuspend;
         };
      }
      else
      {
         _loc4_.onUnsuspend = function()
         {
            this.onItemPress(1,0);
            delete this.onUnsuspend;
         };
      }
   }
   function onItemCardSubMenuAction(event)
   {
      if(event.opening == true)
      {
         this.inventoryLists.itemList.disableSelection = true;
         this.inventoryLists.itemList.disableInput = true;
         this.inventoryLists.categoryList.disableSelection = true;
         this.inventoryLists.categoryList.disableInput = true;
      }
      else if(event.opening == false)
      {
         this.inventoryLists.itemList.disableSelection = false;
         this.inventoryLists.itemList.disableInput = false;
         this.inventoryLists.categoryList.disableSelection = false;
         this.inventoryLists.categoryList.disableInput = false;
      }
   }
   function onConfigLoad(event)
   {
      this.setConfig(event.config);
      this.inventoryLists.showPanel(this._bPlayBladeSound);
   }
   function onMouseWheel(delta)
   {
      var _loc2_ = Mouse.getTopMostEntity();
      while(_loc2_ != undefined)
      {
         if(_loc2_ == this.mouseRotationRect && this.shouldProcessItemsListInput(false) || !this.bFadedIn && delta == -1)
         {
            gfx.io.GameDelegate.call("ZoomItemModel",[delta]);
            break;
         }
         _loc2_ = _loc2_._parent;
      }
   }
   function onExitMenuRectClick()
   {
      gfx.io.GameDelegate.call("CloseMenu",[]);
   }
   function onCategoryChange(event)
   {
   }
   function onItemHighlightChange(event)
   {
      if(event.index != -1)
      {
         if(!this._bItemCardFadedIn)
         {
            this._bItemCardFadedIn = true;
            if(this._bItemCardPositioned)
            {
               this.itemCard.FadeInCard();
            }
         }
         if(this._bItemCardPositioned)
         {
            gfx.io.GameDelegate.call("UpdateItem3D",[true]);
         }
         gfx.io.GameDelegate.call("RequestItemCardInfo",[],this,"UpdateItemCardInfo");
      }
      else
      {
         if(!this.bFadedIn)
         {
            this.resetMenu();
         }
         if(this._bItemCardFadedIn)
         {
            this._bItemCardFadedIn = false;
            this.onHideItemsList();
         }
      }
   }
   function onShowItemsList(event)
   {
      this.onItemHighlightChange(event);
   }
   function onHideItemsList(event)
   {
      gfx.io.GameDelegate.call("UpdateItem3D",[false]);
      this.itemCard.FadeOutCard();
   }
   function onItemSelect(event)
   {
      if(event.entry.enabled)
      {
         if(this._quantityMinCount < 1 || event.entry.count < this._quantityMinCount)
         {
            this.onQuantityMenuSelect({amount:1});
         }
         else
         {
            this.itemCard.ShowQuantityMenu(event.entry.count);
         }
      }
      else
      {
         gfx.io.GameDelegate.call("DisabledItemSelect",[]);
      }
   }
   function onQuantityMenuSelect(event)
   {
      gfx.io.GameDelegate.call("ItemSelect",[event.amount]);
   }
   function onMouseRotationStart()
   {
      gfx.io.GameDelegate.call("StartMouseRotation",[]);
      this.inventoryLists.categoryList.disableSelection = true;
      this.inventoryLists.itemList.disableSelection = true;
   }
   function onMouseRotationStop()
   {
      gfx.io.GameDelegate.call("StopMouseRotation",[]);
      this.inventoryLists.categoryList.disableSelection = false;
      this.inventoryLists.itemList.disableSelection = false;
   }
   function onMouseRotationFastClick()
   {
      if(this.shouldProcessItemsListInput(false))
      {
         this.onItemSelect({entry:this.inventoryLists.itemList.selectedEntry,keyboardOrMouse:0});
      }
   }
   function saveIndices()
   {
      var _loc2_ = new Array();
      _loc2_.push(this.inventoryLists.categoryList.selectedIndex);
      _loc2_.push(this.inventoryLists.itemList.selectedIndex);
      _loc2_.push(this.inventoryLists.itemList.scrollPosition);
      _loc2_.push(this.inventoryLists.itemList.layout.activeColumnIndex);
      _loc2_.push(this.inventoryLists.itemList.layout.activeColumnState);
      gfx.io.GameDelegate.call("SaveIndices",[_loc2_]);
   }
   function positionFixedElements()
   {
      Shared.GlobalFunc.SetLockFunction();
      this.inventoryLists.Lock("L");
      this.inventoryLists._x -= 20;
      var _loc3_ = Stage.visibleRect.x + Stage.safeRect.x;
      var _loc2_ = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
      this.bottomBar.positionElements(_loc3_,_loc2_);
      MovieClip(this.exitMenuRect).Lock("TL");
      this.exitMenuRect._x -= Stage.safeRect.x;
      this.exitMenuRect._y -= Stage.safeRect.y;
   }
   function positionFloatingElements()
   {
      var _loc8_ = Stage.visibleRect.x + Stage.safeRect.x;
      var _loc6_ = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
      var _loc7_ = this.inventoryLists.getContentBounds();
      var _loc5_ = this.inventoryLists._x + _loc7_[0] + _loc7_[2] + 25;
      var _loc2_ = this.itemCard._parent;
      var _loc3_ = this._config.ItemInfo.itemcard;
      var _loc9_ = this._config.ItemInfo.itemicon;
      var _loc4_ = (_loc6_ - _loc5_) / _loc2_._width;
      if(_loc4_ < 1)
      {
         _loc2_._width *= _loc4_;
         _loc2_._height *= _loc4_;
         _loc9_.scale *= _loc4_;
      }
      if(_loc3_.align == "left")
      {
         _loc2_._x = _loc5_ + _loc8_ + _loc3_.xOffset;
      }
      else if(_loc3_.align == "right")
      {
         _loc2_._x = _loc6_ - _loc2_._width + _loc3_.xOffset;
      }
      else
      {
         _loc2_._x = _loc5_ + _loc3_.xOffset + (Stage.visibleRect.x + Stage.visibleRect.width - _loc5_ - _loc2_._width) / 2;
      }
      _loc2_._y += _loc3_.yOffset;
      if(this.mouseRotationRect != undefined)
      {
         MovieClip(this.mouseRotationRect).Lock("T");
         this.mouseRotationRect._x = this.itemCard._parent._x;
         this.mouseRotationRect._width = _loc2_._width;
         this.mouseRotationRect._height = 0.55 * Stage.visibleRect.height;
      }
      this._bItemCardPositioned = true;
      if(this._bItemCardFadedIn)
      {
         gfx.io.GameDelegate.call("UpdateItem3D",[true]);
         this.itemCard.FadeInCard();
      }
   }
   function shouldProcessItemsListInput(abCheckIfOverRect)
   {
      var _loc4_ = this.bFadedIn == true && this.inventoryLists.currentState == InventoryLists.SHOW_PANEL && this.inventoryLists.itemList.itemCount > 0 && !this.inventoryLists.itemList.disableSelection && !this.inventoryLists.itemList.disableInput;
      var _loc2_;
      var _loc3_;
      if(_loc4_ && this._platform == 0 && abCheckIfOverRect)
      {
         _loc2_ = Mouse.getTopMostEntity();
         _loc3_ = false;
         while(!_loc3_ && _loc2_ != undefined)
         {
            if(_loc2_ == this.inventoryLists.itemList)
            {
               _loc3_ = true;
            }
            _loc2_ = _loc2_._parent;
         }
         _loc4_ = _loc4_ && _loc3_;
      }
      return _loc4_;
   }
   function confirmSelectedEntry()
   {
      if(this._platform != 0)
      {
         return true;
      }
      var _loc2_ = Mouse.getTopMostEntity();
      while(_loc2_ != undefined)
      {
         if(_loc2_.itemIndex == this.inventoryLists.itemList.selectedIndex)
         {
            return true;
         }
         _loc2_ = _loc2_._parent;
      }
      return false;
   }
   function resetMenu()
   {
      this.saveIndices();
      gfx.io.GameDelegate.call("CloseMenu",[]);
      skse.OpenMenu("Inventory Menu");
   }
   function checkBook(a_entryObject)
   {
      if(a_entryObject.type != skyui.defines.Inventory.ICT_BOOK || _global.skse == null)
      {
         return false;
      }
      a_entryObject.flags |= skyui.defines.Item.BOOKFLAG_READ;
      a_entryObject.skyui_itemDataProcessed = false;
      this.inventoryLists.itemList.requestInvalidate();
      return true;
   }
   function getEquipButtonData(a_itemType, a_bAlwaysEquip)
   {
      var _loc1_ = {};
      var _loc3_ = skyui.defines.Input.Activate;
      var _loc2_ = skyui.defines.Input.Equip;
      switch(a_itemType)
      {
         case skyui.defines.Inventory.ICT_ARMOR:
            _loc1_.text = "$Equip";
            _loc1_.controls = !a_bAlwaysEquip ? _loc3_ : _loc2_;
            break;
         case skyui.defines.Inventory.ICT_BOOK:
            _loc1_.text = "$Read";
            _loc1_.controls = !a_bAlwaysEquip ? _loc3_ : _loc2_;
            break;
         case skyui.defines.Inventory.ICT_FOOD:
         case skyui.defines.Inventory.ICT_INGREDIENT:
            _loc1_.text = "$Eat";
            _loc1_.controls = !a_bAlwaysEquip ? _loc3_ : _loc2_;
            break;
         case skyui.defines.Inventory.ICT_WEAPON:
            _loc1_.text = "$Equip";
            _loc1_.controls = _loc2_;
            break;
         default:
            _loc1_.text = "$Use";
            _loc1_.controls = !a_bAlwaysEquip ? _loc3_ : _loc2_;
      }
      return _loc1_;
   }
   function updateBottomBar(a_bSelected)
   {
   }
}
