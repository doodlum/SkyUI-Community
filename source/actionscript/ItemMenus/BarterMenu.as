class BarterMenu extends ItemMenu
{
   var _cancelControls;
   var _categoryListIconArt;
   var _platform;
   var _searchControls;
   var _sortColumnControls;
   var _sortOrderControls;
   var _switchControls;
   var _tabBarIconArt;
   var bottomBar;
   var inventoryLists;
   var itemCard;
   var navPanel;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = BarterMenu.SKYUI_VERSION_MAJOR + "." + BarterMenu.SKYUI_VERSION_MINOR + " SE";
   var _buyMult = 1;
   var _sellMult = 1;
   var _confirmAmount = 0;
   var _playerGold = 0;
   var _vendorGold = 0;
   var bEnableTabs = true;
   function BarterMenu()
   {
      super();
      this._categoryListIconArt = ["inv_all","inv_weapons","inv_armor","inv_potions","inv_scrolls","inv_food","inv_ingredients","inv_books","inv_keys","inv_misc"];
      this._tabBarIconArt = ["buy","sell"];
   }
   function InitExtensions()
   {
      super.InitExtensions();
      gfx.io.GameDelegate.addCallBack("SetBarterMultipliers",this,"SetBarterMultipliers");
      this.itemCard.addEventListener("messageConfirm",this,"onTransactionConfirm");
      this.itemCard.addEventListener("sliderChange",this,"onQuantitySliderChange");
      this.inventoryLists.tabBarIconArt = this._tabBarIconArt;
      var _loc3_ = this.inventoryLists.categoryList;
      _loc3_.iconArt = this._categoryListIconArt;
   }
   function setConfig(a_config)
   {
      super.setConfig(a_config);
      var _loc3_ = this.inventoryLists.itemList;
      _loc3_.addDataProcessor(new BarterDataSetter(this._buyMult,this._sellMult));
      _loc3_.addDataProcessor(new InventoryIconSetter(a_config.Appearance));
      _loc3_.addDataProcessor(new skyui.props.PropertyDataExtender(a_config.Appearance,a_config.Properties,"itemProperties","itemIcons","itemCompoundProperties"));
      var _loc5_ = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout,"ItemListLayout");
      _loc3_.layout = _loc5_;
      if(this.inventoryLists.categoryList.selectedEntry)
      {
         _loc5_.changeFilterFlag(this.inventoryLists.categoryList.selectedEntry.flag);
      }
   }
   function onExitButtonPress()
   {
      gfx.io.GameDelegate.call("CloseMenu",[]);
   }
   function SetBarterMultipliers(a_buyMult, a_sellMult)
   {
      this._buyMult = a_buyMult;
      this._sellMult = a_sellMult;
   }
   function ShowRawDealWarning(a_warning)
   {
      this.itemCard.ShowConfirmMessage(a_warning);
   }
   function UpdateItemCardInfo(a_updateObj)
   {
      if(this.isViewingVendorItems())
      {
         a_updateObj.value *= this._buyMult;
         a_updateObj.value = Math.max(a_updateObj.value,1);
      }
      else
      {
         a_updateObj.value *= this._sellMult;
      }
      a_updateObj.value = Math.floor(a_updateObj.value + 0.5);
      this.itemCard.itemInfo = a_updateObj;
      this.bottomBar.updateBarterPerItemInfo(a_updateObj);
   }
   function UpdatePlayerInfo(a_playerGold, a_vendorGold, a_vendorName, a_playerUpdateObj)
   {
      this._vendorGold = a_vendorGold;
      this._playerGold = a_playerGold;
      this.bottomBar.updateBarterInfo(a_playerUpdateObj,this.itemCard.itemInfo,a_playerGold,a_vendorGold,a_vendorName);
   }
   function onShowItemsList(event)
   {
      this.inventoryLists.showItemsList();
   }
   function onItemHighlightChange(event)
   {
      if(event.index != -1)
      {
         this.updateBottomBar(true);
      }
      super.onItemHighlightChange(event);
   }
   function onHideItemsList(event)
   {
      super.onHideItemsList(event);
      this.bottomBar.updateBarterPerItemInfo({type:skyui.defines.Inventory.ICT_NONE});
      this.updateBottomBar(false);
   }
   function onQuantitySliderChange(event)
   {
      var _loc2_ = this.itemCard.itemInfo.value * event.value;
      if(this.isViewingVendorItems())
      {
         _loc2_ *= -1;
      }
      this.bottomBar.updateBarterPriceInfo(this._playerGold,this._vendorGold,this.itemCard.itemInfo,_loc2_);
   }
   function onQuantityMenuSelect(event)
   {
      var _loc2_ = event.amount * this.itemCard.itemInfo.value;
      if(_loc2_ > this._vendorGold && !this.isViewingVendorItems())
      {
         this._confirmAmount = event.amount;
         gfx.io.GameDelegate.call("GetRawDealWarningString",[_loc2_],this,"ShowRawDealWarning");
         this.bottomBar.updateBarterPriceInfo(this._playerGold,this._vendorGold,this.itemCard.itemInfo,_loc2_);
         return undefined;
      }
      this.doTransaction(event.amount);
   }
   function onItemCardSubMenuAction(event)
   {
      super.onItemCardSubMenuAction(event);
      if(event.menu == "quantity")
      {
         if(event.opening)
         {
            this.onQuantitySliderChange({value:this.itemCard.itemInfo.count});
            return undefined;
         }
         this.bottomBar.updateBarterPriceInfo(this._playerGold,this._vendorGold);
      }
   }
   function onTransactionConfirm()
   {
      this.doTransaction(this._confirmAmount);
      this._confirmAmount = 0;
   }
   function doTransaction(a_amount)
   {
      gfx.io.GameDelegate.call("ItemSelect",[a_amount,this.itemCard.itemInfo.value,this.isViewingVendorItems()]);
   }
   function isViewingVendorItems()
   {
      return this.inventoryLists.categoryList.activeSegment == 0;
   }
   function updateBottomBar(a_bSelected)
   {
      this.navPanel.clearButtons();
      if(a_bSelected)
      {
         this.navPanel.addButton({text:(!this.isViewingVendorItems() ? "$Sell" : "$Buy"),controls:skyui.defines.Input.Activate});
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
         this.navPanel.addButton({text:"$Switch Tab",controls:this._switchControls});
      }
      this.navPanel.updateButtons(true);
   }
}
