class InventoryMenu extends ItemMenu
{
   var ToggleMenuFade;
   var _acceptControls;
   var _cancelControls;
   var _categoryListIconArt;
   var _platform;
   var _quantityMinCount;
   var _searchControls;
   var _sortColumnControls;
   var _sortOrderControls;
   var _switchControls;
   var _switchTabKey;
   var bFadedIn;
   var bottomBar;
   var checkBook;
   var confirmSelectedEntry;
   var getEquipButtonData;
   var inventoryLists;
   var itemCard;
   var navPanel;
   var saveIndices;
   var shouldProcessItemsListInput;
   var _bMenuClosing = false;
   var _bSwitchMenus = false;
   var bPCControlsReady = true;
   function InventoryMenu()
   {
      super();
      this._categoryListIconArt = ["cat_favorites","inv_all","inv_weapons","inv_armor","inv_potions","inv_scrolls","inv_food","inv_ingredients","inv_books","inv_keys","inv_misc"];
      gfx.io.GameDelegate.addCallBack("AttemptEquip",this,"AttemptEquip");
      gfx.io.GameDelegate.addCallBack("DropItem",this,"DropItem");
      gfx.io.GameDelegate.addCallBack("AttemptChargeItem",this,"AttemptChargeItem");
      gfx.io.GameDelegate.addCallBack("ItemRotating",this,"ItemRotating");
   }
   function InitExtensions()
   {
      super.InitExtensions();
      Shared.GlobalFunc.AddReverseFunctions();
      this.inventoryLists.zoomButtonHolder.gotoAndStop(1);
      var _loc3_ = this.inventoryLists.categoryList;
      _loc3_.iconArt = this._categoryListIconArt;
      this.itemCard.addEventListener("itemPress",this,"onItemCardListPress");
   }
   function setConfig(a_config)
   {
      super.setConfig(a_config);
      var _loc3_ = this.inventoryLists.itemList;
      _loc3_.addDataProcessor(new InventoryDataSetter());
      _loc3_.addDataProcessor(new InventoryIconSetter(a_config.Appearance));
      _loc3_.addDataProcessor(new skyui.props.PropertyDataExtender(a_config.Appearance,a_config.Properties,"itemProperties","itemIcons","itemCompoundProperties"));
      var _loc5_ = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout,"ItemListLayout");
      _loc3_.layout = _loc5_;
      if(this.inventoryLists.categoryList.selectedEntry)
      {
         _loc5_.changeFilterFlag(this.inventoryLists.categoryList.selectedEntry.flag);
      }
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
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.TAB || details.navEquivalent == gfx.ui.NavigationCode.SHIFT_TAB)
         {
            this.startMenuFade();
            gfx.io.GameDelegate.call("CloseTweenMenu",[]);
         }
         else if(!this.inventoryLists.itemList.disableInput)
         {
            if(details.skseKeycode == this._switchTabKey || details.control == "Quick Magic")
            {
               this.openMagicMenu(true);
            }
         }
      }
      return true;
   }
   function AttemptEquip(a_slot, a_bCheckOverList)
   {
      var _loc2_ = a_bCheckOverList == undefined ? true : a_bCheckOverList;
      if(this.shouldProcessItemsListInput(_loc2_) && this.confirmSelectedEntry())
      {
         gfx.io.GameDelegate.call("ItemSelect",[a_slot]);
         this.checkBook(this.inventoryLists.itemList.selectedEntry);
      }
   }
   function DropItem()
   {
      if(this.shouldProcessItemsListInput(false) && this.inventoryLists.itemList.selectedEntry != undefined)
      {
         if(this._quantityMinCount < 1 || this.inventoryLists.itemList.selectedEntry.count < this._quantityMinCount)
         {
            this.onQuantityMenuSelect({amount:1});
         }
         else
         {
            this.itemCard.ShowQuantityMenu(this.inventoryLists.itemList.selectedEntry.count);
         }
      }
   }
   function AttemptChargeItem()
   {
      if(this.inventoryLists.itemList.selectedIndex == -1)
      {
         return undefined;
      }
      if(this.shouldProcessItemsListInput(false) && this.itemCard.itemInfo.charge != undefined && this.itemCard.itemInfo.charge < 100)
      {
         gfx.io.GameDelegate.call("ShowSoulGemList",[]);
      }
   }
   function SetPlatform(a_platform, a_bPS3Switch)
   {
      this.inventoryLists.zoomButtonHolder.gotoAndStop(1);
      this.inventoryLists.zoomButtonHolder.ZoomButton._visible = a_platform != 0;
      this.inventoryLists.zoomButtonHolder.ZoomButton.SetPlatform(a_platform,a_bPS3Switch);
      super.SetPlatform(a_platform,a_bPS3Switch);
   }
   function ItemRotating()
   {
      this.inventoryLists.zoomButtonHolder.PlayForward(this.inventoryLists.zoomButtonHolder._currentframe);
   }
   function onExitMenuRectClick()
   {
      this.startMenuFade();
      gfx.io.GameDelegate.call("ShowTweenMenu",[]);
   }
   function onFadeCompletion()
   {
      if(!this._bMenuClosing)
      {
         return undefined;
      }
      gfx.io.GameDelegate.call("CloseMenu",[]);
      if(this._bSwitchMenus)
      {
         gfx.io.GameDelegate.call("CloseTweenMenu",[]);
         skse.OpenMenu("MagicMenu");
      }
   }
   function onShowItemsList(event)
   {
      super.onShowItemsList(event);
      if(event.index != -1)
      {
         this.updateBottomBar(true);
      }
   }
   function onItemHighlightChange(event)
   {
      super.onItemHighlightChange(event);
      if(event.index != -1)
      {
         this.updateBottomBar(true);
      }
   }
   function onHideItemsList(event)
   {
      super.onHideItemsList(event);
      this.bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_NONE});
      this.updateBottomBar(false);
   }
   function onItemSelect(event)
   {
      if(event.entry.enabled && event.keyboardOrMouse != 0)
      {
         gfx.io.GameDelegate.call("ItemSelect",[]);
         this.checkBook(event.entry);
      }
   }
   function onQuantityMenuSelect(event)
   {
      gfx.io.GameDelegate.call("ItemDrop",[event.amount]);
      gfx.io.GameDelegate.call("RequestItemCardInfo",[],this,"UpdateItemCardInfo");
   }
   function onMouseRotationFastClick(aiMouseButton)
   {
      gfx.io.GameDelegate.call("CheckForMouseEquip",[aiMouseButton],this,"AttemptEquip");
   }
   function onItemCardListPress(event)
   {
      gfx.io.GameDelegate.call("ItemCardListCallback",[event.index]);
   }
   function onItemCardSubMenuAction(event)
   {
      super.onItemCardSubMenuAction(event);
      gfx.io.GameDelegate.call("QuantitySliderOpen",[event.opening]);
      if(event.menu == "list")
      {
         if(event.opening == true)
         {
            this.navPanel.clearButtons();
            this.navPanel.addButton({text:"$Select",controls:this._acceptControls});
            this.navPanel.addButton({text:"$Cancel",controls:this._cancelControls});
            this.navPanel.updateButtons(true);
         }
         else
         {
            gfx.io.GameDelegate.call("RequestItemCardInfo",[],this,"UpdateItemCardInfo");
            this.updateBottomBar(true);
         }
      }
   }
   function openMagicMenu(a_bFade)
   {
      if(a_bFade)
      {
         this._bSwitchMenus = true;
         this.startMenuFade();
      }
      else
      {
         this.saveIndices();
         gfx.io.GameDelegate.call("CloseMenu",[]);
         gfx.io.GameDelegate.call("CloseTweenMenu",[]);
         skse.OpenMenu("MagicMenu");
      }
   }
   function startMenuFade()
   {
      this.inventoryLists.hidePanel();
      this.ToggleMenuFade();
      this.saveIndices();
      this._bMenuClosing = true;
   }
   function updateBottomBar(a_bSelected)
   {
      this.navPanel.clearButtons();
      if(a_bSelected)
      {
         this.navPanel.addButton(this.getEquipButtonData(this.itemCard.itemInfo.type));
         this.navPanel.addButton({text:"$Drop",controls:skyui.defines.Input.XButton});
         if(this.inventoryLists.itemList.selectedEntry.filterFlag & this.inventoryLists.categoryList.entryList[0].flag != 0)
         {
            this.navPanel.addButton({text:"$Unfavorite",controls:skyui.defines.Input.YButton});
         }
         else
         {
            this.navPanel.addButton({text:"$Favorite",controls:skyui.defines.Input.YButton});
         }
         if(this.itemCard.itemInfo.charge != undefined && this.itemCard.itemInfo.charge < 100)
         {
            this.navPanel.addButton({text:"$Charge",controls:skyui.defines.Input.ChargeItem});
         }
      }
      else
      {
         this.navPanel.addButton({text:"$Exit",controls:this._cancelControls});
         this.navPanel.addButton({text:"$Search",controls:this._searchControls});
         if(this._platform != 0)
         {
            this.navPanel.addButton({text:"$Column",controls:this._sortColumnControls});
            this.navPanel.addButton({text:"$Order",controls:this._sortOrderControls});
         }
         this.navPanel.addButton({text:"$Magic",controls:this._switchControls});
      }
      this.navPanel.updateButtons(true);
   }
}
