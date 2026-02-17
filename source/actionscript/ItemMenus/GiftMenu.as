class GiftMenu extends ItemMenu
{
   var _cancelControls;
   var _categoryListIconArt;
   var _platform;
   var _searchControls;
   var _sortColumnControls;
   var _sortOrderControls;
   var bottomBar;
   var inventoryLists;
   var navPanel;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = GiftMenu.SKYUI_VERSION_MAJOR + "." + GiftMenu.SKYUI_VERSION_MINOR + " SE";
   var _bGivingGifts = true;
   function GiftMenu()
   {
      super();
      this._categoryListIconArt = ["inv_all","inv_weapons","inv_armor","inv_potions","inv_scrolls","inv_food","inv_ingredients","inv_books","inv_keys","inv_misc"];
   }
   function InitExtensions()
   {
      super.InitExtensions();
      gfx.io.GameDelegate.addCallBack("SetMenuInfo",this,"SetMenuInfo");
      var _loc3_ = this.inventoryLists.categoryList;
      _loc3_.iconArt = this._categoryListIconArt;
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
   function ShowItemsList()
   {
   }
   function SetMenuInfo(a_bGivingGifts, a_bUseFavorPoints)
   {
      this._bGivingGifts = a_bGivingGifts;
      if(!a_bUseFavorPoints)
      {
         this.bottomBar.hidePlayerInfo();
      }
   }
   function UpdatePlayerInfo(a_favorPoints)
   {
      this.bottomBar.setGiftInfo(a_favorPoints);
   }
   function onShowItemsList(event)
   {
      var _loc2_ = this.inventoryLists.categoryList;
      _loc2_.selectedIndex = 0;
      _loc2_.entryList[0].text = "$ALL";
      _loc2_.InvalidateData();
      this.inventoryLists.showItemsList();
   }
   function onHideItemsList(event)
   {
      super.onHideItemsList(event);
      this.bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_NONE});
      this.updateBottomBar(false);
   }
   function onItemHighlightChange(event)
   {
      super.onItemHighlightChange(event);
      if(event.index != -1)
      {
         this.updateBottomBar(true);
      }
   }
   function onItemCardSubMenuAction(event)
   {
      super.onItemCardSubMenuAction(event);
      if(event.menu == "quantity")
      {
         gfx.io.GameDelegate.call("QuantitySliderOpen",[event.opening]);
      }
   }
   function updateBottomBar(a_bSelected)
   {
      this.navPanel.clearButtons();
      if(a_bSelected)
      {
         this.navPanel.addButton({text:(!this._bGivingGifts ? "$Take" : "$Give"),controls:skyui.defines.Input.Activate});
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
      }
      this.navPanel.updateButtons(true);
   }
}
