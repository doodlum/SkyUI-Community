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

   var _enableMarquee: Boolean = false;
   var _baselineSelection: Object;
   var _marqueeMC: MovieClip;
   var _startX: Number = 0;
   var _startY: Number = 0;
   var _isSelecting: Boolean = false;

   var _multiDropQueue: Array = [];
   var _isProcessingQueue: Boolean = false;

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
      if (a_config.ItemList.selection.marquee.enabled != undefined) {
         this._enableMarquee = a_config.ItemList.selection.marquee.enabled;
      }
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
      if (this._enableMarquee && details.value == "keyDown") 
      {
         var nav = details.navEquivalent;
         var kc = details.code;

         var isActualNav = (nav >= 1 && nav <= 6);
         
         if (isActualNav && kc != 16 && kc != 17 && kc != 18) {
            if (this.isMultiSelectionActive()) {
               this.clearMarqueeSelection();
            }
         }
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
      if (this._enableMarquee && Key.isDown(Key.CONTROL))
         return;

      var _loc2_ = a_bCheckOverList == undefined ? true : a_bCheckOverList;
      if(this.shouldProcessItemsListInput(_loc2_) && this.confirmSelectedEntry())
      {
         gfx.io.GameDelegate.call("ItemSelect",[a_slot]);
         this.checkBook(this.inventoryLists.itemList.selectedEntry);
      }
   }
   function DropItem()
   {
      if (this._enableMarquee && this.DropItemRange())
         return;

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
      if (this._enableMarquee && Key.isDown(Key.CONTROL) && event.entry != undefined)
      {
         event.entry.isMarqueeSelected = !event.entry.isMarqueeSelected;
         
         if (!event.entry.isMarqueeSelected && this.inventoryLists.itemList.selectedIndex == event.index) {
            this.inventoryLists.itemList.selectedIndex = -1;
         }

         this.inventoryLists.itemList.requestUpdate();
         gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
         return;
      }

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


   
   function DropItemRange()
   {
      var list = this.inventoryLists.itemList;
      this._multiDropQueue = [];

      for (var i = 0; i < list.entryList.length; i++) {
         if (list.entryList[i].isMarqueeSelected == true) {
            this._multiDropQueue.push(i);
         }
      }

      if (this._multiDropQueue.length > 0) {
         this._multiDropQueue.sort(function(a, b) { return b - a; });
         
         this.inventoryLists.itemList.disableInput = true;
         this._isProcessingQueue = true;
         this.onEnterFrame = this.processDropQueue;
         return true;
      }

      return false;
   }
   
   function processDropQueue()
   {
      var list = this.inventoryLists.itemList;

      if (this._multiDropQueue.length > 0) {
         
         var targetIdx = this._multiDropQueue.shift();
         var entry = list.entryList[targetIdx];

         if (entry != undefined) {
            list.doSetSelectedIndex(targetIdx, 1);
            gfx.io.GameDelegate.call("ItemDrop", [entry.count]);
         }
      } else {
         delete this.onEnterFrame;
         this._isProcessingQueue = false;
         this.inventoryLists.itemList.disableInput = false;
         
         this.clearMarqueeSelection();
         gfx.io.GameDelegate.call("RequestItemCardInfo", [], this, "UpdateItemCardInfo");
      }
   }

   function isMultiSelectionActive()
   {
      var entries = this.inventoryLists.itemList.entryList;
      for (var i = 0; i < entries.length; i++) {
         if (entries[i].isMarqueeSelected) return true;
      }
      return false;
   }
   
   function onMouseDown()
   {
      var itemList = this.inventoryLists.itemList;
      var isCtrl = Key.isDown(Key.CONTROL); 

      if (this._enableMarquee && this.bFadedIn && isCtrl) 
      {
         this._isSelecting = true;
         this._startX = _root._xmouse;
         this._startY = _root._ymouse;
         
         this._baselineSelection = {};
         var entries = itemList.entryList;
         for (var i = 0; i < entries.length; i++) {
            if (entries[i].isMarqueeSelected) this._baselineSelection[i] = true;
         }

         if (this._marqueeMC == undefined) {
            this._marqueeMC = this.createEmptyMovieClip("marquee_mc", this.getNextHighestDepth());
         }
         this._marqueeMC._visible = true;
      }
      else if (!isCtrl)
      {
         if (this.isMultiSelectionActive()) {
            this.clearMarqueeSelection();
         }
      }
   }

   function onMouseUp()
   {
      if (this._enableMarquee && this._isSelecting) {
         this._isSelecting = false;
         this._marqueeMC.clear();
         this._marqueeMC._visible = false;
         this._baselineSelection = null; 
      }
   }

   function onMouseMove()
   {
      if (this._enableMarquee && this._isSelecting) {
         this.drawMarquee(_root._xmouse, _root._ymouse);
         this.checkMarqueeIntersection();
      }
   }

   function drawMarquee(a_currX: Number, a_currY: Number)
   {
      var mc = this._marqueeMC;
      mc.clear();
      mc.lineStyle(1, 0xFFFFFF, 80); 
      mc.beginFill(0xFFFFFF, 20); 
      
      var x = this._startX;
      var y = this._startY;
      var w = a_currX - x;
      var h = a_currY - y;
      
      mc.moveTo(x, y);
      mc.lineTo(x + w, y);
      mc.lineTo(x + w, y + h);
      mc.lineTo(x, y + h);
      mc.lineTo(x, y);
      mc.endFill();
   }

   function checkMarqueeIntersection()
   {
      var list = this.inventoryLists.itemList;
      var marqueeBounds = this._marqueeMC.getBounds(_root);
      
      for (var i = 0; i < list._maxListIndex; i++) {
         var clip = list.getClipByIndex(i);
         if (clip != undefined && clip._visible && clip.itemIndex != undefined) {
            var itemBounds = clip.getBounds(_root);
            
            var isHit = !(itemBounds.xMin > marqueeBounds.xMax || 
                          itemBounds.xMax < marqueeBounds.xMin || 
                          itemBounds.yMin > marqueeBounds.yMax || 
                          itemBounds.yMax < marqueeBounds.yMin);
            
            var wasSelected = (this._baselineSelection != null && this._baselineSelection[clip.itemIndex] == true);
            
            var finalState = (isHit != wasSelected);
            
            if (clip.setMultiSelected != undefined) {
                clip.setMultiSelected(finalState);
            }
         }
      }
   }
   function clearMarqueeSelection()
   {
      var list = this.inventoryLists.itemList;
      var entries = list.entryList;
      var changed = false;

      for (var i = 0; i < entries.length; i++) {
         if (entries[i].isMarqueeSelected) {
            entries[i].isMarqueeSelected = false;
            changed = true;
         }
      }

      if (changed) {
         list.requestUpdate();
      }
   }
}
