class MagicMenu extends ItemMenu
{
   var ToggleMenuFade;
   var _cancelControls;
   var _categoryListIconArt;
   var _platform;
   var _searchControls;
   var _sortColumnControls;
   var _sortOrderControls;
   var _switchControls;
   var _switchTabKey;
   var bFadedIn;
   var bottomBar;
   var confirmSelectedEntry;
   var inventoryLists;
   var itemCard;
   var navPanel;
   var saveIndices;
   var shouldProcessItemsListInput;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = MagicMenu.SKYUI_VERSION_MAJOR + "." + MagicMenu.SKYUI_VERSION_MINOR + " SE";
   var _hideButtonFlag = 0;
   var _bMenuClosing = false;
   var _bSwitchMenus = false;
   function MagicMenu()
   {
      super();
      this._categoryListIconArt = ["cat_favorites","mag_all","mag_alteration","mag_illusion","mag_destruction","mag_conjuration","mag_restoration","mag_shouts","mag_powers","mag_activeeffects"];
   }
   function InitExtensions()
   {
      super.InitExtensions();
      gfx.io.GameDelegate.addCallBack("DragonSoulSpent",this,"DragonSoulSpent");
      gfx.io.GameDelegate.addCallBack("AttemptEquip",this,"AttemptEquip");
      this.bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_SPELL_DEFAULT});
      var _loc3_ = this.inventoryLists.categoryList;
      _loc3_.iconArt = this._categoryListIconArt;
   }
   function setConfig(a_config)
   {
      super.setConfig(a_config);
      var _loc3_ = this.inventoryLists.itemList;
      _loc3_.addDataProcessor(new MagicDataSetter(a_config.Appearance));
      _loc3_.addDataProcessor(new MagicIconSetter(a_config.Appearance));
      _loc3_.addDataProcessor(new skyui.props.PropertyDataExtender(a_config.Appearance,a_config.Properties,"magicProperties","magicIcons","magicCompoundProperties"));
      var _loc5_ = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout,"MagicListLayout");
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
            if(details.skseKeycode == this._switchTabKey || details.control == "Quick Inventory")
            {
               this.openInventoryMenu(true);
            }
         }
      }
      return true;
   }
   function DragonSoulSpent()
   {
      this.itemCard.itemInfo.soulSpent = true;
      this.updateBottomBar();
   }
   function AttemptEquip(a_slot)
   {
      if(this.shouldProcessItemsListInput(true) && this.confirmSelectedEntry())
      {
         gfx.io.GameDelegate.call("ItemSelect",[a_slot]);
      }
   }
   function onItemSelect(event)
   {
      if(event.keyboardOrMouse != 0)
      {
         if(event.entry.enabled)
         {
            gfx.io.GameDelegate.call("ItemSelect",[]);
         }
         else
         {
            gfx.io.GameDelegate.call("ShowShoutFail",[]);
         }
      }
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
         skse.OpenMenu("InventoryMenu");
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
      this.bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_SPELL_DEFAULT});
      this.updateBottomBar(false);
   }
   function openInventoryMenu(a_bFade)
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
         skse.OpenMenu("InventoryMenu");
      }
   }
   function updateBottomBar(a_bSelected)
   {
      this.navPanel.clearButtons();
      if(a_bSelected && (this.inventoryLists.itemList.selectedEntry.filterFlag & skyui.defines.Inventory.FILTERFLAG_MAGIC_ACTIVEEFFECTS) == 0)
      {
         this.navPanel.addButton({text:"$Equip",controls:skyui.defines.Input.Equip});
         if(this.inventoryLists.itemList.selectedEntry.filterFlag & this.inventoryLists.categoryList.entryList[0].flag != 0)
         {
            this.navPanel.addButton({text:"$Unfavorite",controls:skyui.defines.Input.YButton});
         }
         else
         {
            this.navPanel.addButton({text:"$Favorite",controls:skyui.defines.Input.YButton});
         }
         if(this.itemCard.itemInfo.showUnlocked)
         {
            this.navPanel.addButton({text:"$Unlock",controls:skyui.defines.Input.XButton});
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
         this.navPanel.addButton({text:"$Inventory",controls:this._switchControls});
      }
      this.navPanel.updateButtons(true);
   }
   function startMenuFade()
   {
      this.inventoryLists.hidePanel();
      this.ToggleMenuFade();
      this.saveIndices();
      this._bMenuClosing = true;
   }
}
