class InventoryLists extends MovieClip
{
   var _columnSelectDialog;
   var _columnSelectInterval;
   var _currCategoryIndex;
   var _currentState;
   var _leftTabText;
   var _nameFilter;
   var _platform;
   var _rightTabText;
   var _sortFilter;
   var _tabBarIconArt;
   var _typeFilter;
   var categoryLabel;
   var categoryList;
   var columnSelectButton;
   var dispatchEvent;
   var itemList;
   var panelContainer;
   var searchWidget;
   var tabBar;
   var _searchKeyHeld:Boolean = false;
   var _searchKeyClearUsed:Boolean = false;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = InventoryLists.SKYUI_VERSION_MAJOR + "." + InventoryLists.SKYUI_VERSION_MINOR + " SE";
   static var HIDE_PANEL = 0;
   static var SHOW_PANEL = 1;
   static var TRANSITIONING_TO_HIDE_PANEL = 2;
   static var TRANSITIONING_TO_SHOW_PANEL = 3;
   var _savedSelectionIndex = -1;
   var _searchKey = -1;
   var _switchTabKey = -1;
   var _sortOrderKey = -1;
   var _sortOrderKeyHeld = false;
   var _bTabbed = false;
   function InventoryLists()
   {
      super();
      skyui.util.GlobalFunctions.addArrayFunctions();
      gfx.events.EventDispatcher.initialize(this);
      this.gotoAndStop("NoPanels");
      gfx.io.GameDelegate.addCallBack("SetCategoriesList",this,"SetCategoriesList");
      gfx.io.GameDelegate.addCallBack("InvalidateListData",this,"InvalidateListData");
      this._typeFilter = new skyui.filter.ItemTypeFilter();
      this._nameFilter = new skyui.filter.NameFilter();
      this._sortFilter = new skyui.filter.SortFilter();
      this.categoryList = this.panelContainer.categoryList;
      this.categoryLabel = this.panelContainer.categoryLabel;
      this.itemList = this.panelContainer.itemList;
      this.searchWidget = this.panelContainer.searchWidget;
      this.columnSelectButton = this.panelContainer.columnSelectButton;
      skyui.util.ConfigManager.registerLoadCallback(this,"onConfigLoad");
      skyui.util.ConfigManager.registerUpdateCallback(this,"onConfigUpdate");
   }
   function get currentState()
   {
      return this._currentState;
   }
   function set currentState(a_newState)
   {
      if(a_newState == InventoryLists.SHOW_PANEL)
      {
         gfx.managers.FocusHandler.instance.setFocus(this.itemList,0);
      }
      this._currentState = a_newState;
   }
   function set tabBarIconArt(a_iconArt)
   {
      this._tabBarIconArt = a_iconArt;
      if(this.tabBar)
      {
         this.tabBar.setIcons(this._tabBarIconArt[0],this._tabBarIconArt[1]);
      }
   }
   function get tabBarIconArt()
   {
      return this._tabBarIconArt;
   }
   function onLoad()
   {
      this.categoryList.listEnumeration = new skyui.components.list.BasicEnumeration(this.categoryList.entryList);
      var _loc2_ = new skyui.components.list.FilteredEnumeration(this.itemList.entryList);
      _loc2_.addFilter(this._typeFilter);
      _loc2_.addFilter(this._nameFilter);
      _loc2_.addFilter(this._sortFilter);
      this.itemList.listEnumeration = _loc2_;
      this.itemList.listState.maxTextLength = 80;
      this._typeFilter.addEventListener("filterChange",this,"onFilterChange");
      this._nameFilter.addEventListener("filterChange",this,"onFilterChange");
      this._sortFilter.addEventListener("filterChange",this,"onFilterChange");
      this.categoryList.addEventListener("itemPress",this,"onCategoriesItemPress");
      this.categoryList.addEventListener("itemPressAux",this,"onCategoriesItemPress");
      this.categoryList.addEventListener("selectionChange",this,"onCategoriesListSelectionChange");
      this.itemList.disableInput = false;
      this.itemList.addEventListener("selectionChange",this,"onItemsListSelectionChange");
      this.itemList.addEventListener("sortChange",this,"onSortChange");
      this.searchWidget.addEventListener("inputStart",this,"onSearchInputStart");
      this.searchWidget.addEventListener("inputEnd",this,"onSearchInputEnd");
      this.searchWidget.addEventListener("inputChange",this,"onSearchInputChange");
      this.columnSelectButton.addEventListener("press",this,"onColumnSelectButtonPress");
   }
   function InitExtensions()
   {
      this.categoryList.suspended = true;
      this.itemList.suspended = true;
   }
   function showPanel(a_bPlayBladeSound)
   {
      this.categoryList.suspended = false;
      this.itemList.suspended = false;
      this._currentState = InventoryLists.TRANSITIONING_TO_SHOW_PANEL;
      this.gotoAndPlay("PanelShow");
      this.dispatchEvent({type:"categoryChange",index:this.categoryList.selectedIndex});
      if(a_bPlayBladeSound != false)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
      }
   }
   function hidePanel()
   {
      this._currentState = InventoryLists.TRANSITIONING_TO_HIDE_PANEL;
      this.gotoAndPlay("PanelHide");
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
   }
   function enableTabBar()
   {
      this._bTabbed = true;
      this.panelContainer.gotoAndPlay("tabbed");
      this.itemList.listHeight = 480;
   }
   function setPlatform(a_platform, a_bPS3Switch)
   {
      this._platform = a_platform;
      this.categoryList.setPlatform(a_platform,a_bPS3Switch);
      this.itemList.setPlatform(a_platform,a_bPS3Switch);
   }
   function handleInput(details, pathToFocus)
   {
      if(this._currentState != InventoryLists.SHOW_PANEL)
      {
         return false;
      }
      if(this._platform != 0)
      {
         if(details.skseKeycode == this._sortOrderKey)
         {
            if(details.value == "keyDown")
            {
               this._sortOrderKeyHeld = true;
               if(this._columnSelectDialog)
               {
                  skyui.util.DialogManager.close();
               }
               else
               {
                  this._columnSelectInterval = setInterval(this,"onColumnSelectButtonPress",1000,{type:"timeout"});
               }
               return true;
            }
            if(details.value == "keyUp")
            {
               this._sortOrderKeyHeld = false;
               if(this._columnSelectInterval == undefined)
               {
                  return true;
               }
               clearInterval(this._columnSelectInterval);
               delete this._columnSelectInterval;
               details.value = "keyDown";
            }
            else if(this._sortOrderKeyHeld && details.value == "keyHold")
            {
               this._sortOrderKeyHeld = false;
               if(this._columnSelectDialog)
               {
                  skyui.util.DialogManager.close();
               }
               return true;
            }
         }
         if(this._sortOrderKeyHeld)
         {
            return true;
         }
      }
      if(details.skseKeycode == this._searchKey)
      {
         if(details.value == "keyDown")
         {
            this._searchKeyHeld = true;
            this._searchKeyClearUsed = false;
            return true;
         }
         if(details.value == "keyUp")
         {
            if(!this._searchKeyClearUsed && !this.searchWidget.isActive()) {
                  this.searchWidget.onSearchKeyPress();
            }
            this._searchKeyHeld = false;
            this._searchKeyClearUsed = false;
            return true;
         }
         if(details.value == "keyHold")
         {
            return true;
         }
         return true;
      }

      if(this._searchKeyHeld && details.skseKeycode == 14)
      {
         if(details.value == "keyDown") {
            this._searchKeyClearUsed = true;
            this.searchWidget.onSearchKeyClear();
         }
         return true;
      }

      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(this.tabBar != undefined && details.skseKeycode == this._switchTabKey)
         {
               this.tabBar.tabToggle();
               return true;
         }
      }
      if(this.categoryList.handleInput(details,pathToFocus))
      {
         return true;
      }
      var _loc4_ = pathToFocus.shift();
      return _loc4_.handleInput(details,pathToFocus);
   }
   function getContentBounds()
   {
      var _loc2_ = this.panelContainer.ListBackground;
      return [_loc2_._x,_loc2_._y,_loc2_._width,_loc2_._height];
   }
   function showItemsList()
   {
      this._currCategoryIndex = this.categoryList.selectedIndex;
      this.categoryLabel.textField.SetText(this.categoryList.selectedEntry.text);
      this.itemList.selectedIndex = -1;
      this.itemList.scrollPosition = 0;
      if(this.categoryList.selectedEntry != undefined)
      {
         this._typeFilter.changeFilterFlag(this.categoryList.selectedEntry.flag);
         this.itemList.layout.changeFilterFlag(this.categoryList.selectedEntry.flag);
      }
      this.itemList.requestUpdate();
      this.dispatchEvent({type:"itemHighlightChange",index:this.itemList.selectedIndex});
      this.itemList.disableInput = false;
   }
   function SetCategoriesList()
   {
      var _loc14_ = 0;
      var _loc13_ = 1;
      var _loc6_ = 2;
      var _loc12_ = 3;
      this.categoryList.clearList();
      var _loc3_ = 0;
      var _loc5_ = 0;
      var _loc4_;
      while(_loc3_ < arguments.length)
      {
         _loc4_ = {text:arguments[_loc3_ + _loc14_],flag:arguments[_loc3_ + _loc13_],bDontHide:arguments[_loc3_ + _loc6_],savedItemIndex:0,filterFlag:(arguments[_loc3_ + _loc6_] != true ? 0 : 1)};
         this.categoryList.entryList.push(_loc4_);
         if(_loc4_.flag == 0)
         {
            this.categoryList.dividerIndex = _loc5_;
         }
         _loc3_ += _loc12_;
         _loc5_++;
      }
      if(this._bTabbed)
      {
         this.categoryList.selectedIndex = 0;
         this._leftTabText = this.categoryList.entryList[0].text;
         this._rightTabText = this.categoryList.entryList[this.categoryList.dividerIndex + 1].text;
         this.categoryList.entryList[0].text = this.categoryList.entryList[this.categoryList.dividerIndex + 1].text = "$ALL";
      }
      this.categoryList.InvalidateData();
   }
   function InvalidateListData()
   {
      var _loc4_ = this.categoryList.selectedEntry.flag;
      var _loc3_ = 0;
      while(_loc3_ < this.categoryList.entryList.length)
      {
         this.categoryList.entryList[_loc3_].filterFlag = !this.categoryList.entryList[_loc3_].bDontHide ? 0 : 1;
         _loc3_ = _loc3_ + 1;
      }
      this.itemList.InvalidateData();
      _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < this.itemList.entryList.length)
      {
         _loc2_ = 0;
         while(_loc2_ < this.categoryList.entryList.length)
         {
            if(this.categoryList.entryList[_loc2_].filterFlag == 0)
            {
               if(this.itemList.entryList[_loc3_].filterFlag & this.categoryList.entryList[_loc2_].flag)
               {
                  this.categoryList.entryList[_loc2_].filterFlag = 1;
               }
            }
            _loc2_ = _loc2_ + 1;
         }
         _loc3_ = _loc3_ + 1;
      }
      this.categoryList.UpdateList();
      if(_loc4_ != this.categoryList.selectedEntry.flag)
      {
         this._typeFilter.itemFilter = this.categoryList.selectedEntry.flag;
         this.dispatchEvent({type:"categoryChange",index:this.categoryList.selectedIndex});
      }
      if(this.itemList.selectedIndex == -1)
      {
         this.dispatchEvent({type:"showItemsList",index:-1});
      }
      else
      {
         this.dispatchEvent({type:"itemHighlightChange",index:this.itemList.selectedIndex});
      }
   }
   function onConfigLoad(event)
   {
      var _loc2_ = event.config;
      this._searchKey = _loc2_.Input.controls.pc.search;
      if(this._platform == 0)
      {
         this._switchTabKey = _loc2_.Input.controls.pc.switchTab;
      }
      else
      {
         this._switchTabKey = _loc2_.Input.controls.gamepad.switchTab;
         this._sortOrderKey = _loc2_.Input.controls.gamepad.sortOrder;
      }
   }
   function onFilterChange()
   {
      this.itemList.requestInvalidate();
   }
   function onTabBarLoad()
   {
      this.tabBar = this.panelContainer.tabBar;
      this.tabBar.setIcons(this._tabBarIconArt[0],this._tabBarIconArt[1]);
      this.tabBar.addEventListener("tabPress",this,"onTabPress");
      if(this.categoryList.dividerIndex != -1)
      {
         this.tabBar.setLabelText(this._leftTabText,this._rightTabText);
      }
   }
   function onColumnSelectButtonPress(event)
   {
      if(event.type == "timeout")
      {
         clearInterval(this._columnSelectInterval);
         delete this._columnSelectInterval;
      }
      if(this._columnSelectDialog)
      {
         skyui.util.DialogManager.close();
         return undefined;
      }
      this._savedSelectionIndex = this.itemList.selectedIndex;
      this.itemList.selectedIndex = -1;
      this.categoryList.disableSelection = this.categoryList.disableInput = true;
      this.itemList.disableSelection = this.itemList.disableInput = true;
      this.searchWidget.isDisabled = true;
      this._columnSelectDialog = skyui.util.DialogManager.open(this.panelContainer,"ColumnSelectDialog",{_x:554,_y:35,layout:this.itemList.layout});
      this._columnSelectDialog.addEventListener("dialogClosed",this,"onColumnSelectDialogClosed");
   }
   function onColumnSelectDialogClosed(event)
   {
      this.categoryList.disableSelection = this.categoryList.disableInput = false;
      this.itemList.disableSelection = this.itemList.disableInput = false;
      this.searchWidget.isDisabled = false;
      this.itemList.selectedIndex = this._savedSelectionIndex;
   }
   function onConfigUpdate(event)
   {
      this.itemList.layout.refresh();
   }
   function onCategoriesItemPress()
   {
      this.showItemsList();
   }
   function onTabPress(event)
   {
      if(this.categoryList.disableSelection || this.categoryList.disableInput || this.itemList.disableSelection || this.itemList.disableInput)
      {
         return undefined;
      }
      if(event.index == skyui.components.TabBar.LEFT_TAB)
      {
         this.tabBar.activeTab = skyui.components.TabBar.LEFT_TAB;
         this.categoryList.activeSegment = CategoryList.LEFT_SEGMENT;
      }
      else if(event.index == skyui.components.TabBar.RIGHT_TAB)
      {
         this.tabBar.activeTab = skyui.components.TabBar.RIGHT_TAB;
         this.categoryList.activeSegment = CategoryList.RIGHT_SEGMENT;
      }
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
      this.showItemsList();
   }
   function onCategoriesListSelectionChange(event)
   {
      this.dispatchEvent({type:"categoryChange",index:event.index});
      if(event.index != -1)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      }
   }
   function onItemsListSelectionChange(event)
   {
      this.dispatchEvent({type:"itemHighlightChange",index:event.index});
      if(event.index != -1)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      }
   }
   function onSortChange(event)
   {
      this._sortFilter.setSortBy(event.attributes,event.options);
   }
   function onSearchInputStart(event)
   {
      this._searchKeyHeld = false;
      this.categoryList.disableSelection = this.categoryList.disableInput = true;
      this.itemList.disableSelection = this.itemList.disableInput = true;
      this._nameFilter.filterText = "";
   }
   function onSearchInputChange(event)
   {
      this._nameFilter.filterText = event.data;
   }
   function onSearchInputEnd(event)
   {
      this.categoryList.disableSelection = this.categoryList.disableInput = false;
      this.itemList.disableSelection = this.itemList.disableInput = false;
      this._nameFilter.filterText = event.data;
   }
}
