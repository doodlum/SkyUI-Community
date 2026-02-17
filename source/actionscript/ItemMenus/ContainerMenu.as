class ContainerMenu extends ItemMenu
{
   var _cancelControls;
   var _categoryListIconArt;
   var _equipHand;
   var _equipModeControls;
   var _equipModeKey;
   var _platform;
   var _quantityMinCount;
   var _searchControls;
   var _sortColumnControls;
   var _sortOrderControls;
   var _switchControls;
   var _tabBarIconArt;
   var bFadedIn;
   var bottomBar;
   var checkBook;
   var confirmSelectedEntry;
   var getEquipButtonData;
   var inventoryLists;
   var itemCard;
   var itemCardFadeHolder;
   var navPanel;
   var shouldProcessItemsListInput;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = ContainerMenu.SKYUI_VERSION_MAJOR + "." + ContainerMenu.SKYUI_VERSION_MINOR + " SE";
   static var NULL_HAND = -1;
   static var RIGHT_HAND = 0;
   static var LEFT_HAND = 1;
   var _bEquipMode = false;
   var bNPCMode = false;
   var bEnableTabs = true;
   function ContainerMenu()
   {
      super();
      this._categoryListIconArt = ["inv_all","inv_weapons","inv_armor","inv_potions","inv_scrolls","inv_food","inv_ingredients","inv_books","inv_keys","inv_misc"];
      this._tabBarIconArt = ["take","give"];
   }
   function InitExtensions()
   {
      super.InitExtensions();
      this.inventoryLists.tabBarIconArt = this._tabBarIconArt;
      var _loc3_ = this.inventoryLists.categoryList;
      _loc3_.iconArt = this._categoryListIconArt;
      gfx.io.GameDelegate.addCallBack("AttemptEquip",this,"AttemptEquip");
      gfx.io.GameDelegate.addCallBack("XButtonPress",this,"onXButtonPress");
      this.itemCardFadeHolder.StealTextInstance._visible = false;
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
      this._equipModeKey = a_config.Input.controls.pc.equipMode;
      this._equipModeControls = {keyCode:this._equipModeKey};
   }
   function ShowItemsList()
   {
   }
   function handleInput(details, pathToFocus)
   {
      super.handleInput(details,pathToFocus);
      if(this.shouldProcessItemsListInput(false))
      {
         if(this._platform == 0 && details.skseKeycode == this._equipModeKey && this.inventoryLists.itemList.selectedIndex != -1)
         {
            this._bEquipMode = details.value != "keyUp";
            this.updateBottomBar(true);
         }
      }
      return true;
   }
   function UpdateItemCardInfo(a_updateObj)
   {
      super.UpdateItemCardInfo(a_updateObj);
      this.updateBottomBar(true);
      if(a_updateObj.pickpocketChance != undefined)
      {
         this.itemCardFadeHolder.StealTextInstance._visible = true;
         this.itemCardFadeHolder.StealTextInstance.PercentTextInstance.html = true;
         this.itemCardFadeHolder.StealTextInstance.PercentTextInstance.htmlText = "<font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + a_updateObj.pickpocketChance + "%</font>" + (!this.isViewingContainer() ? skyui.util.Translator.translate("$ TO PLACE") : skyui.util.Translator.translate("$ TO STEAL"));
      }
      else
      {
         this.itemCardFadeHolder.StealTextInstance._visible = false;
      }
   }
   function AttemptEquip(a_slot, a_bCheckOverList)
   {
      var _loc2_ = a_bCheckOverList != undefined ? a_bCheckOverList : true;
      if(!this.shouldProcessItemsListInput(_loc2_) || !this.confirmSelectedEntry())
      {
         return undefined;
      }
      if(this._platform == 0)
      {
         if(this._bEquipMode)
         {
            this.startItemEquip(a_slot);
         }
         else
         {
            this.startItemTransfer();
         }
      }
      else
      {
         this.startItemEquip(a_slot);
      }
   }
   function onXButtonPress()
   {
      if(!this.bFadedIn)
      {
         return undefined;
      }
      if(this.isViewingContainer() && !this.bNPCMode)
      {
         gfx.io.GameDelegate.call("TakeAllItems",[]);
      }
   }
   function SetPlatform(a_platform, a_bPS3Switch)
   {
      super.SetPlatform(a_platform,a_bPS3Switch);
      this._bEquipMode = a_platform != 0;
   }
   function onItemSelect(event)
   {
      if(event.keyboardOrMouse != 0)
      {
         if(this._platform == 0 && this._bEquipMode)
         {
            this.startItemEquip(ContainerMenu.NULL_HAND);
         }
         else
         {
            this.startItemTransfer();
         }
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
   function onItemHighlightChange(event)
   {
      if(event.index != -1)
      {
         this.updateBottomBar(true);
      }
      super.onItemHighlightChange(event);
   }
   function onShowItemsList(event)
   {
      this.inventoryLists.showItemsList();
   }
   function onHideItemsList(event)
   {
      super.onHideItemsList(event);
      this.bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_NONE});
      this.updateBottomBar(false);
   }
   function onMouseRotationFastClick(a_mouseButton)
   {
      gfx.io.GameDelegate.call("CheckForMouseEquip",[a_mouseButton],this,"AttemptEquip");
   }
   function onQuantityMenuSelect(event)
   {
      if(this._equipHand != undefined)
      {
         gfx.io.GameDelegate.call("EquipItem",[this._equipHand,event.amount]);
         if(!this.checkBook(this.inventoryLists.itemList.selectedEntry))
         {
            this.checkPoison(this.inventoryLists.itemList.selectedEntry);
         }
         this._equipHand = undefined;
         return undefined;
      }
      if(this.inventoryLists.itemList.selectedEntry.enabled)
      {
         gfx.io.GameDelegate.call("ItemTransfer",[event.amount,this.isViewingContainer()]);
         return undefined;
      }
      gfx.io.GameDelegate.call("DisabledItemSelect",[]);
   }
   function updateBottomBar(a_bSelected)
   {
      this.navPanel.clearButtons();
      if(a_bSelected && this.inventoryLists.itemList.selectedIndex != -1 && this.inventoryLists.currentState == InventoryLists.SHOW_PANEL)
      {
         if(this.isViewingContainer())
         {
            if(this._platform != 0)
            {
               this.navPanel.addButton({text:"$Take",controls:skyui.defines.Input.Activate});
               this.navPanel.addButton(this.getEquipButtonData(this.itemCard.itemInfo.type,true));
            }
            else if(this._bEquipMode)
            {
               this.navPanel.addButton(this.getEquipButtonData(this.itemCard.itemInfo.type));
            }
            else
            {
               this.navPanel.addButton({text:"$Take",controls:skyui.defines.Input.Activate});
            }
            if(!this.bNPCMode)
            {
               this.navPanel.addButton({text:"$Take All",controls:skyui.defines.Input.XButton});
            }
         }
         else
         {
            if(this._platform != 0)
            {
               this.navPanel.addButton({text:(!this.bNPCMode ? "$Store" : "$Give"),controls:skyui.defines.Input.Activate});
               this.navPanel.addButton(this.getEquipButtonData(this.itemCard.itemInfo.type,true));
            }
            else if(this._bEquipMode)
            {
               this.navPanel.addButton(this.getEquipButtonData(this.itemCard.itemInfo.type));
            }
            else
            {
               this.navPanel.addButton({text:(!this.bNPCMode ? "$Store" : "$Give"),controls:skyui.defines.Input.Activate});
            }
            this.navPanel.addButton({text:(!this.itemCard.itemInfo.favorite ? "$Favorite" : "$Unfavorite"),controls:skyui.defines.Input.YButton});
         }
         if(!this._bEquipMode)
         {
            this.navPanel.addButton({text:"$Equip Mode",controls:this._equipModeControls});
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
         this.navPanel.addButton({text:"$Switch Tab",controls:this._switchControls});
         if(this.isViewingContainer() && !this.bNPCMode)
         {
            this.navPanel.addButton({text:"$Take All",controls:skyui.defines.Input.XButton});
         }
      }
      this.navPanel.updateButtons(true);
   }
   function startItemTransfer()
   {
      if(this.inventoryLists.itemList.selectedEntry.enabled)
      {
         if(this.itemCard.itemInfo.weight == 0 && this.isViewingContainer())
         {
            this.onQuantityMenuSelect({amount:this.inventoryLists.itemList.selectedEntry.count});
            return undefined;
         }
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
   function startItemEquip(a_equipHand)
   {
      if(this.isViewingContainer())
      {
         this._equipHand = a_equipHand;
         this.startItemTransfer();
         return undefined;
      }
      gfx.io.GameDelegate.call("EquipItem",[a_equipHand]);
      if(!this.checkBook(this.inventoryLists.itemList.selectedEntry))
      {
         this.checkPoison(this.inventoryLists.itemList.selectedEntry);
      }
   }
   function isViewingContainer()
   {
      return this.inventoryLists.categoryList.activeSegment == 0;
   }
   function checkPoison(a_entryObject)
   {
      if(a_entryObject.type != skyui.defines.Inventory.ICT_POTION || _global.skse == null)
      {
         return false;
      }
      if(a_entryObject.subType != skyui.defines.Item.POTION_POISON)
      {
         return false;
      }
      this._bEquipMode = false;
      return true;
   }
}
