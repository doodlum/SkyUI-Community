class CraftingLists extends MovieClip
{
   var CategoriesList;
   var _columnSelectDialog;
   var _columnSelectInterval;
   var _currCategoryIndex;
   var _currentState;
   var _nameFilter;
   var _platform;
   var _sortFilter;
   var _subtypeName;
   var _typeFilter;
   var categoryLabel;
   var columnSelectButton;
   var dispatchEvent;
   var itemList;
   var onUnsuspend;
   var panelContainer;
   var searchWidget;
   static var HIDE_PANEL = 0;
   static var SHOW_PANEL = 1;
   static var TRANSITIONING_TO_HIDE_PANEL = 2;
   static var TRANSITIONING_TO_SHOW_PANEL = 3;
   static var SHORT_LIST_OFFSET = 210;
   var _savedSelectionIndex = -1;
   var _searchKey = -1;
   var _sortOrderKey = -1;
   var _sortOrderKeyHeld = false;
   var _bFocusItemList = true;
   function CraftingLists()
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
      this.categoryLabel = this.panelContainer.categoryLabel;
      this.CategoriesList = this.panelContainer.categoriesList;
      this.itemList = this.panelContainer.itemList;
      this.searchWidget = this.panelContainer.searchWidget;
      this.columnSelectButton = this.panelContainer.columnSelectButton;
      skyui.util.ConfigManager.registerLoadCallback(this,"onConfigLoad");
      skyui.util.ConfigManager.registerUpdateCallback(this,"onConfigUpdate");
      this.panelContainer.effectsList._visible = false;
   }
   function get currentState()
   {
      return this._currentState;
   }
   function set currentState(a_newState)
   {
      if(a_newState == CraftingLists.SHOW_PANEL)
      {
         gfx.managers.FocusHandler.instance.setFocus(this.itemList,0);
      }
      this._currentState = a_newState;
   }
   function InitExtensions(a_subtypeName)
   {
      this._subtypeName = a_subtypeName;
      if(this._subtypeName == "Alchemy")
      {
         this.panelContainer.gotoAndStop("no_categories");
         this.CategoriesList._visible = false;
         this.CategoriesList = this.panelContainer.effectsList;
         this.CategoriesList._visible = true;
         this.itemList.gotoAndStop("short");
         this.itemList.leftBorder = CraftingLists.SHORT_LIST_OFFSET;
         this.itemList.listHeight = 560;
      }
      else if(this._subtypeName == "ConstructibleObject")
      {
         this.itemList.addDataProcessor(new CustomConstructDataSetter());
      }
      else if(this._subtypeName == "Smithing")
      {
         this.panelContainer.gotoAndStop("no_categories");
         this.CategoriesList._visible = false;
         this.itemList.listHeight = 560;
      }
      var _loc2_ = new skyui.components.list.FilteredEnumeration(this.itemList.entryList);
      _loc2_.addFilter(this._typeFilter);
      _loc2_.addFilter(this._nameFilter);
      _loc2_.addFilter(this._sortFilter);
      this.itemList.listEnumeration = _loc2_;
      this._typeFilter.addEventListener("filterChange",this,"onFilterChange");
      this._nameFilter.addEventListener("filterChange",this,"onFilterChange");
      this._sortFilter.addEventListener("filterChange",this,"onFilterChange");
      this.CategoriesList.listEnumeration = new skyui.components.list.BasicEnumeration(this.CategoriesList.entryList);
      this.itemList.listState.maxTextLength = 80;
      this._typeFilter.addEventListener("filterChange",this,"onFilterChange");
      this._nameFilter.addEventListener("filterChange",this,"onFilterChange");
      this._sortFilter.addEventListener("filterChange",this,"onFilterChange");
      this.CategoriesList.addEventListener("itemPress",this,"onCategoriesItemPress");
      this.CategoriesList.addEventListener("itemPressAux",this,"onCategoriesItemPress");
      this.CategoriesList.addEventListener("selectionChange",this,"onCategoriesListSelectionChange");
      this.itemList.disableInput = false;
      this.itemList.addEventListener("selectionChange",this,"onItemsListSelectionChange");
      this.itemList.addEventListener("sortChange",this,"onSortChange");
      this.itemList.addEventListener("itemPress",this,"onItemPress");
      this.searchWidget.addEventListener("inputStart",this,"onSearchInputStart");
      this.searchWidget.addEventListener("inputEnd",this,"onSearchInputEnd");
      this.searchWidget.addEventListener("inputChange",this,"onSearchInputChange");
      this.columnSelectButton.addEventListener("press",this,"onColumnSelectButtonPress");
      this.itemList.onInvalidate = mx.utils.Delegate.create(this,this.onItemListInvalidate);
      this.CategoriesList.onUnsuspend = function()
      {
         this.onItemPress(0,0);
         delete this.onUnsuspend;
      };
      this.CategoriesList.suspended = true;
      this.itemList.suspended = true;
   }
   function showPanel(a_bPlayBladeSound)
   {
      this.CategoriesList.suspended = false;
      this.itemList.suspended = false;
      this._currentState = CraftingLists.TRANSITIONING_TO_SHOW_PANEL;
      this.gotoAndPlay("PanelShow");
      this.dispatchEvent({type:"categoryChange",index:this.CategoriesList.selectedIndex});
      if(a_bPlayBladeSound != false)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
      }
   }
   function hidePanel()
   {
      this._currentState = CraftingLists.TRANSITIONING_TO_HIDE_PANEL;
      this.gotoAndPlay("PanelHide");
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
   }
   function setPlatform(a_platform, a_bPS3Switch)
   {
      this._platform = a_platform;
      this.CategoriesList.setPlatform(a_platform,a_bPS3Switch);
      this.itemList.setPlatform(a_platform,a_bPS3Switch);
   }
   function setPartitionedFilterMode(a_bPartitioned)
   {
      this._typeFilter.setPartitionedFilterMode(a_bPartitioned);
   }
   function handleInput(details, pathToFocus)
   {
      if(this._currentState != CraftingLists.SHOW_PANEL)
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
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.skseKeycode == this._searchKey)
         {
            this.searchWidget.startInput();
            return true;
         }
      }
      if(this._subtypeName == "Alchemy")
      {
         if(this.handleAlchemyNavigation(details,pathToFocus))
         {
            return true;
         }
      }
      else if(this.CategoriesList.handleInput(details,pathToFocus))
      {
         return true;
      }
      var _loc4_ = pathToFocus.shift();
      return _loc4_.handleInput(details,pathToFocus);
   }
   function handleAlchemyNavigation(details, pathToFocus)
   {
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.LEFT)
         {
            if(!this._bFocusItemList)
            {
               return true;
            }
            this._savedSelectionIndex = this.itemList.selectedIndex;
            this.itemList.selectedIndex = -1;
            this._bFocusItemList = false;
            return true;
         }
         if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT)
         {
            if(this._bFocusItemList)
            {
               return true;
            }
            if(this._savedSelectionIndex == -1)
            {
               this.itemList.selectDefaultIndex(true);
            }
            else
            {
               this.itemList.selectedIndex = this._savedSelectionIndex;
            }
            this._bFocusItemList = true;
            return true;
         }
         if(!this._bFocusItemList)
         {
            if(this.CategoriesList.handleInput(details,pathToFocus))
            {
               this._savedSelectionIndex = -1;
               return true;
            }
         }
      }
      return false;
   }
   function getContentBounds()
   {
      var _loc2_ = this.panelContainer.ListBackground;
      return [_loc2_._x,_loc2_._y,_loc2_._width,_loc2_._height];
   }
   function showItemsList()
   {
      this._currCategoryIndex = this.CategoriesList.selectedIndex;
      this.categoryLabel.textField.SetText(this.CategoriesList.selectedEntry.text.toUpperCase());
      this.itemList.selectedIndex = -1;
      this.itemList.scrollPosition = 0;
      var _loc2_;
      if(this.CategoriesList.selectedEntry != undefined)
      {
         _loc2_ = this.CategoriesList.selectedEntry.flag;
         this._typeFilter.changeFilterFlag(_loc2_);
         this.itemList.layout.changeFilterFlag(_loc2_);
      }
      this.itemList.requestUpdate();
      this.dispatchEvent({type:"showItemsList",index:this.itemList.selectedIndex});
      this.itemList.disableInput = false;
   }
   function SetCategoriesList()
   {
      var _loc14_ = 0;
      var _loc13_ = 1;
      var _loc6_ = 2;
      var _loc12_ = 3;
      this.CategoriesList.clearList();
      var _loc3_ = 0;
      var _loc5_ = 0;
      var _loc4_;
      while(_loc3_ < arguments.length)
      {
         _loc4_ = {text:arguments[_loc3_ + _loc14_],flag:arguments[_loc3_ + _loc13_],bDontHide:arguments[_loc3_ + _loc6_],savedItemIndex:0,filterFlag:(arguments[_loc3_ + _loc6_] != true ? 0 : 1)};
         if(_loc4_.flag == 0)
         {
            _loc4_.divider = true;
         }
         _loc4_.enabled = false;
         this.CategoriesList.entryList.push(_loc4_);
         _loc3_ += _loc12_;
         _loc5_++;
      }
      this.preprocessCategoriesList();
      this.CategoriesList.selectedIndex = 0;
      this.CategoriesList.InvalidateData();
   }
   function InvalidateListData()
   {
      this.itemList.InvalidateData();
   }
   function onHideCategoriesList(event)
   {
      this.itemList.listHeight = 579;
   }
   function onConfigLoad(event)
   {
      var _loc2_ = event.config;
      this._searchKey = _loc2_.Input.controls.pc.search;
      if(this._platform != 0)
      {
         this._sortOrderKey = _loc2_.Input.controls.gamepad.sortOrder;
      }
   }
   function onItemListInvalidate()
   {
      var _loc3_;
      var _loc2_;
      if(this._subtypeName != "Alchemy")
      {
         _loc3_ = 0;
         while(_loc3_ < this.CategoriesList.entryList.length)
         {
            _loc2_ = 0;
            while(_loc2_ < this.itemList.entryList.length)
            {
               if(this._typeFilter.isMatch(this.itemList.entryList[_loc2_],this.CategoriesList.entryList[_loc3_].flag))
               {
                  this.CategoriesList.entryList[_loc3_].enabled = true;
                  break;
               }
               _loc2_ = _loc2_ + 1;
            }
            _loc3_ = _loc3_ + 1;
         }
      }
      this.CategoriesList.UpdateList();
      if(this.itemList.selectedIndex == -1)
      {
         this.dispatchEvent({type:"showItemsList",index:-1});
      }
      else
      {
         this.dispatchEvent({type:"itemHighlightChange",index:this.itemList.selectedIndex});
      }
   }
   function preprocessCategoriesList()
   {
      if(this._subtypeName == "EnchantConstruct")
      {
         this.CategoriesList.iconArt = ["ench_disentchant","separator","ench_item","ench_effect","ench_soul"];
      }
      else if(this._subtypeName == "Smithing")
      {
         this.CategoriesList.iconArt = ["smithing"];
      }
      else if(this._subtypeName == "ConstructibleObject")
      {
         this.CategoriesList.iconArt = ["construct_all","weapon","ammo","armor","jewelry","food","misc"];
         this.replaceConstructObjectCategories();
      }
      else if(this._subtypeName == "Alchemy")
      {
         this.fixupAlchemyCategories();
      }
   }
   function replaceConstructObjectCategories()
   {
      this.CategoriesList.clearList();
      this.CategoriesList.entryList.push({text:"$ALL",flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_ALL,bDontHide:1,savedItemIndex:0,filterFlag:1,enabled:false});
      this.CategoriesList.entryList.push({text:"$WEAPONS",flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_WEAPONS,bDontHide:1,savedItemIndex:0,filterFlag:1,enabled:false});
      this.CategoriesList.entryList.push({text:"$AMMO",flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_AMMO,bDontHide:1,savedItemIndex:0,filterFlag:1,enabled:false});
      this.CategoriesList.entryList.push({text:skyui.util.Translator.translate("$Armor"),flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_ARMOR,bDontHide:1,savedItemIndex:0,filterFlag:1,enabled:false});
      this.CategoriesList.entryList.push({text:skyui.util.Translator.translate("$Jewelry"),flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_JEWELRY,bDontHide:1,savedItemIndex:0,filterFlag:1,enabled:false});
      this.CategoriesList.entryList.push({text:skyui.util.Translator.translate("$Food"),flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_FOOD,bDontHide:1,savedItemIndex:0,filterFlag:1,enabled:false});
      this.CategoriesList.entryList.push({text:skyui.util.Translator.translate("$Misc"),flag:skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_MISC,bDontHide:1,savedItemIndex:0,filterFlag:1,enabled:false});
   }
   function fixupAlchemyCategories()
   {
      this.CategoriesList.entryList[0].enabled = true;
      this.CategoriesList.entryList[0].iconLabel = "ingredients";
      var _loc3_ = 1;
      var _loc2_;
      while(_loc3_ < this.CategoriesList.entryList.length)
      {
         _loc2_ = this.CategoriesList.entryList[_loc3_];
         if(_loc2_.flag & skyui.defines.Inventory.FILTERFLAG_CUST_ALCH_GOOD)
         {
            _loc2_.iconLabel = "beneficial";
         }
         else if(_loc2_.flag & skyui.defines.Inventory.FILTERFLAG_CUST_ALCH_BAD)
         {
            _loc2_.iconLabel = "harmful";
         }
         else if(_loc2_.flag & skyui.defines.Inventory.FILTERFLAG_CUST_ALCH_OTHER)
         {
            _loc2_.iconLabel = "other";
         }
         _loc2_.flag = _loc3_;
         _loc3_ = _loc3_ + 1;
      }
   }
   function onFilterChange()
   {
      this.itemList.requestInvalidate();
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
      this.CategoriesList.disableSelection = this.CategoriesList.disableInput = true;
      this.itemList.disableSelection = this.itemList.disableInput = true;
      this.searchWidget.isDisabled = true;
      this._columnSelectDialog = skyui.util.DialogManager.open(this.panelContainer,"ColumnSelectDialog",{_x:554,_y:35,layout:this.itemList.layout});
      this._columnSelectDialog.addEventListener("dialogClosed",this,"onColumnSelectDialogClosed");
   }
   function onColumnSelectDialogClosed(event)
   {
      this.CategoriesList.disableSelection = this.CategoriesList.disableInput = false;
      this.itemList.disableSelection = this.itemList.disableInput = false;
      this.searchWidget.isDisabled = false;
      this.itemList.selectedIndex = this._savedSelectionIndex;
   }
   function onConfigUpdate(event)
   {
      this.itemList.layout.refresh();
   }
   function onItemPress()
   {
      this._bFocusItemList = true;
   }
   function onCategoriesItemPress()
   {
      this._bFocusItemList = false;
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
      this.CategoriesList.disableSelection = this.CategoriesList.disableInput = true;
      this.itemList.disableSelection = this.itemList.disableInput = true;
      this._nameFilter.filterText = "";
   }
   function onSearchInputChange(event)
   {
      this._nameFilter.filterText = event.data;
   }
   function onSearchInputEnd(event)
   {
      this.CategoriesList.disableSelection = this.CategoriesList.disableInput = false;
      this.itemList.disableSelection = this.itemList.disableInput = false;
      this._nameFilter.filterText = event.data;
   }
}
