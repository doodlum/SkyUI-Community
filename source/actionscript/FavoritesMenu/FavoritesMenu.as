class FavoritesMenu extends MovieClip
{
   var _categoryButtonGroup;
   var _groupAddControls;
   var _groupButtonGroup;
   var _groupDataExtender;
   var _groupUseControls;
   var _platform;
   var _saveEquipStateControls;
   var _setIconControls;
   var _sortFilter;
   var _state;
   var _toggleFocusControls;
   var _typeFilter;
   var btnAid;
   var btnAll;
   var btnGear;
   var btnMagic;
   var groupButtonFader;
   var headerText;
   var itemList;
   var leftHandItemId;
   var listState;
   var navButton;
   var navPanel;
   var onInvalidate;
   var rightHandItemId;
   var scrollPosition;
   static var ITEM_SELECT = 0;
   static var GROUP_ASSIGN = 1;
   static var GROUP_ASSIGN_SYNC = 2;
   static var GROUP_REMOVE_SYNC = 3;
   static var CLOSING = 4;
   static var SAVE_EQUIP_STATE_SYNC = 5;
   static var SET_ICON_SYNC = 6;
   var _leftKeycode = -1;
   var _rightKeycode = -1;
   var _groupAddKey = -1;
   var _groupUseKey = -1;
   var _setIconKey = -1;
   var _saveEquipStateKey = -1;
   var _toggleFocusKey = -1;
   var _useMouseNavigation = false;
   var _categoryIndex = 0;
   var _groupIndex = 0;
   var _groupButtonFocused = false;
   var _groupAssignIndex = -1;
   var _savedIndex = -1;
   var _savedScrollPosition = 0;
   var _groupButtonsShown = false;
   var _waitingForGroupData = true;
   var _isInitialized = false;
   var _navPanelEnabled = false;
   var _fadedIn = false;
   var bPCControlsReady = true;
   function FavoritesMenu()
   {
      super();
      this._typeFilter = new skyui.filter.ItemTypeFilter();
      this._sortFilter = new skyui.filter.SortFilter();
      this._categoryButtonGroup = new gfx.controls.ButtonGroup("CategoryButtonGroup");
      this._groupButtonGroup = new gfx.controls.ButtonGroup("GroupButtonGroup");
      Mouse.addListener(this);
   }
   function initControls(a_navPanelEnabled, a_groupAddKey, a_groupUseKey, a_setIconKey, a_saveEquipStateKey, a_toggleFocusKey)
   {
      this._navPanelEnabled = a_navPanelEnabled;
      if(this._platform == 0)
      {
         this._groupAddKey = a_groupAddKey;
         this._groupUseKey = a_groupUseKey;
         this._setIconKey = a_setIconKey;
         this._saveEquipStateKey = a_saveEquipStateKey;
         this._toggleFocusKey = a_toggleFocusKey;
         this.createControls();
      }
      this.updateNavButtons();
   }
   function pushGroupItems()
   {
      var _loc3_ = 0;
      while(_loc3_ < arguments.length)
      {
         this._groupDataExtender.groupData.push(arguments[_loc3_] & 0xFFFFFFFF);
         _loc3_ = _loc3_ + 1;
      }
   }
   function finishGroupData(a_groupCount)
   {
      var _loc4_ = 1;
      var _loc3_;
      _loc3_ = 0;
      while(_loc3_ < a_groupCount)
      {
         this._groupDataExtender.mainHandData.push(arguments[_loc4_] & 0xFFFFFFFF);
         _loc3_++;
         _loc4_++;
      }
      _loc3_ = 0;
      while(_loc3_ < a_groupCount)
      {
         this._groupDataExtender.offHandData.push(arguments[_loc4_] & 0xFFFFFFFF);
         _loc3_++;
         _loc4_++;
      }
      _loc3_ = 0;
      while(_loc3_ < a_groupCount)
      {
         this._groupDataExtender.iconData.push(arguments[_loc4_] & 0xFFFFFFFF);
         _loc3_++;
         _loc4_++;
      }
      if(this._isInitialized)
      {
         this.itemList.InvalidateData();
      }
      this._waitingForGroupData = false;
      this.enableGroupButtons(true);
      this.updateNavButtons();
   }
   function updateGroupData(a_groupIndex, a_mainHandItemId, a_offHandItemId, a_iconItemId)
   {
      var _loc5_ = a_groupIndex * GroupDataExtender.GROUP_SIZE;
      this._groupDataExtender.mainHandData[a_groupIndex] = a_mainHandItemId & 0xFFFFFFFF;
      this._groupDataExtender.offHandData[a_groupIndex] = a_offHandItemId & 0xFFFFFFFF;
      this._groupDataExtender.iconData[a_groupIndex] = a_iconItemId & 0xFFFFFFFF;
      var _loc3_ = 4;
      var _loc4_ = _loc5_;
      while(_loc3_ < arguments.length)
      {
         this._groupDataExtender.groupData[_loc4_] = arguments[_loc3_] & 0xFFFFFFFF;
         _loc3_++;
         _loc4_++;
      }
      if(this._isInitialized)
      {
         this.itemList.InvalidateData();
      }
      this.unlock();
   }
   function unlock()
   {
      if(this._state == FavoritesMenu.GROUP_ASSIGN_SYNC)
      {
         this.endGroupAssignment();
      }
      else if(this._state == FavoritesMenu.GROUP_REMOVE_SYNC)
      {
         this.endGroupRemoval();
      }
      else if(this._state == FavoritesMenu.SET_ICON_SYNC)
      {
         this.endSetGroupIcon();
      }
      else if(this._state == FavoritesMenu.SAVE_EQUIP_STATE_SYNC)
      {
         this.endSaveEquipState();
      }
      this.updateNavButtons();
   }
   function InitExtensions()
   {
      Stage.scaleMode = "showAll";
      skse.ExtendData(true);
      this.btnAll.group = this._categoryButtonGroup;
      this.btnGear.group = this._categoryButtonGroup;
      this.btnAid.group = this._categoryButtonGroup;
      this.btnMagic.group = this._categoryButtonGroup;
      var _loc4_ = [];
      var _loc3_ = 1;
      var _loc2_;
      while(_loc3_ <= 8)
      {
         _loc2_ = this.groupButtonFader.groupButtonHolder["btnGroup" + _loc3_];
         _loc2_.text;
         _loc4_.push(_loc2_);
         _loc2_.group = this._groupButtonGroup;
         _loc3_ = _loc3_ + 1;
      }
      this._categoryButtonGroup.addEventListener("change",this,"onCategorySelect");
      this._groupButtonGroup.addEventListener("change",this,"onGroupSelect");
      this.itemList.addDataProcessor(new FilterDataExtender());
      this.itemList.addDataProcessor(new FavoritesIconSetter());
      this._groupDataExtender = new GroupDataExtender(_loc4_);
      this.itemList.addDataProcessor(this._groupDataExtender);
      var _loc5_ = new skyui.components.list.FilteredEnumeration(this.itemList.entryList);
      _loc5_.addFilter(this._typeFilter);
      _loc5_.addFilter(this._sortFilter);
      this._typeFilter.addEventListener("filterChange",this,"onFilterChange");
      this._sortFilter.addEventListener("filterChange",this,"onFilterChange");
      this.itemList.listEnumeration = _loc5_;
      Shared.GlobalFunc.SetLockFunction();
      this._parent.Lock("BL");
      gfx.io.GameDelegate.addCallBack("PopulateItems",this,"populateItemList");
      gfx.io.GameDelegate.addCallBack("SetSelectedItem",this,"setSelectedItem");
      gfx.io.GameDelegate.addCallBack("StartFadeOut",this,"startFadeOut");
      this.itemList.addEventListener("itemPress",this,"onItemPress");
      this.itemList.addEventListener("selectionChange",this,"onItemSelectionChange");
      gfx.managers.FocusHandler.instance.setFocus(this.itemList,0);
      this._parent.gotoAndPlay("startFadeIn");
      this._sortFilter.setSortBy(["text"],[],false);
      this._state = FavoritesMenu.ITEM_SELECT;
      this._waitingForGroupData = true;
      this.navPanel._visible = false;
      this.navButton.visible = false;
      this.restoreIndices();
      this.setGroupFocus(false);
      this._isInitialized = true;
      this.updateNavButtons();
   }
   function get ItemList()
   {
      return this.itemList;
   }
   function handleInput(details, pathToFocus)
   {
      if(this._state == FavoritesMenu.CLOSING)
      {
         return true;
      }
      var _loc4_ = pathToFocus.shift();
      if(_loc4_ && _loc4_.handleInput(details,pathToFocus))
      {
         return true;
      }
      var _loc3_;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
         {
            if(this._state == FavoritesMenu.GROUP_ASSIGN)
            {
               this.endGroupAssignment();
            }
            else
            {
               this.startFadeOut();
            }
            return true;
         }
         if(details.navEquivalent == gfx.ui.NavigationCode.LEFT || details.skseKeycode == this._leftKeycode)
         {
            if(this._state == FavoritesMenu.GROUP_ASSIGN)
            {
               _loc3_ = this._groupAssignIndex;
               if(_loc3_ == -1)
               {
                  _loc3_ = this._groupButtonGroup.length - 1;
               }
               else
               {
                  _loc3_ = _loc3_ - 1;
               }
               if(_loc3_ < 0)
               {
                  _loc3_ = this._groupButtonGroup.length - 1;
               }
               this._groupButtonGroup.setSelectedButton(this._groupButtonGroup.getButtonAt(_loc3_));
            }
            else if(this._state == FavoritesMenu.ITEM_SELECT)
            {
               if(this._groupButtonFocused)
               {
                  this._groupIndex = this._groupIndex - 1;
                  if(this._groupIndex < 0)
                  {
                     this._groupIndex = this._groupButtonGroup.length - 1;
                  }
                  this._groupButtonGroup.setSelectedButton(this._groupButtonGroup.getButtonAt(this._groupIndex));
               }
               else
               {
                  this._categoryIndex = this._categoryIndex - 1;
                  if(this._categoryIndex < 0)
                  {
                     this._categoryIndex = this._categoryButtonGroup.length - 1;
                  }
                  this._categoryButtonGroup.setSelectedButton(this._categoryButtonGroup.getButtonAt(this._categoryIndex));
               }
            }
            return true;
         }
         if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT || details.skseKeycode == this._rightKeycode)
         {
            if(this._state == FavoritesMenu.GROUP_ASSIGN)
            {
               _loc3_ = this._groupAssignIndex;
               if(_loc3_ == -1)
               {
                  _loc3_ = 0;
               }
               else
               {
                  _loc3_ = _loc3_ + 1;
               }
               if(_loc3_ >= this._groupButtonGroup.length)
               {
                  _loc3_ = 0;
               }
               this._groupButtonGroup.setSelectedButton(this._groupButtonGroup.getButtonAt(_loc3_));
            }
            else if(this._state == FavoritesMenu.ITEM_SELECT)
            {
               if(this._groupButtonFocused)
               {
                  this._groupIndex = this._groupIndex + 1;
                  if(this._groupIndex >= this._groupButtonGroup.length)
                  {
                     this._groupIndex = 0;
                  }
                  this._groupButtonGroup.setSelectedButton(this._groupButtonGroup.getButtonAt(this._groupIndex));
               }
               else
               {
                  this._categoryIndex = this._categoryIndex + 1;
                  if(this._categoryIndex >= this._categoryButtonGroup.length)
                  {
                     this._categoryIndex = 0;
                  }
                  this._categoryButtonGroup.setSelectedButton(this._categoryButtonGroup.getButtonAt(this._categoryIndex));
               }
            }
            return true;
         }
         if(details.skseKeycode == this._groupAddKey)
         {
            if(this._state == FavoritesMenu.ITEM_SELECT)
            {
               if(!this._groupButtonFocused)
               {
                  this.startGroupAssignment();
               }
               else
               {
                  this.startGroupRemoval();
               }
            }
            else if(this._state == FavoritesMenu.GROUP_ASSIGN)
            {
               this.endGroupAssignment();
            }
            return true;
         }
         if(this._state == FavoritesMenu.GROUP_ASSIGN && details.navEquivalent == gfx.ui.NavigationCode.ENTER)
         {
            if(this._groupAssignIndex != -1)
            {
               this.applyGroupAssignment();
            }
            return true;
         }
         if(details.skseKeycode == this._groupUseKey)
         {
            if(this._state == FavoritesMenu.ITEM_SELECT)
            {
               this.requestGroupUse();
            }
            return true;
         }
         if(details.skseKeycode == this._setIconKey)
         {
            if(this._state == FavoritesMenu.ITEM_SELECT)
            {
               this.startSetGroupIcon();
            }
         }
         else if(details.skseKeycode == this._saveEquipStateKey)
         {
            if(this._state == FavoritesMenu.ITEM_SELECT)
            {
               this.startSaveEquipState();
            }
         }
         else if(details.skseKeycode == this._toggleFocusKey)
         {
            if(this._state == FavoritesMenu.ITEM_SELECT)
            {
               this.setGroupFocus(!this._groupButtonFocused);
            }
            return true;
         }
      }
      return true;
   }
   function get selectedIndex()
   {
      return !this.confirmSelectedEntry() ? -1 : this.itemList.selectedEntry.index;
   }
   function setSelectedItem(a_index)
   {
      return undefined;
   }
   function SetPlatform(a_platform, a_bPS3Switch)
   {
      this._platform = a_platform;
      var _loc2_ = this._platform != 0;
      this._leftKeycode = skyui.util.GlobalFunctions.getMappedKey("Left",skyui.defines.Input.CONTEXT_MENUMODE,_loc2_);
      this._rightKeycode = skyui.util.GlobalFunctions.getMappedKey("Right",skyui.defines.Input.CONTEXT_MENUMODE,_loc2_);
      if(this._platform != 0)
      {
         this._groupAddKey = skyui.util.GlobalFunctions.getMappedKey("Toggle POV",skyui.defines.Input.CONTEXT_GAMEPLAY,true);
         this._groupUseKey = skyui.util.GlobalFunctions.getMappedKey("Ready Weapon",skyui.defines.Input.CONTEXT_GAMEPLAY,true);
         this._setIconKey = skyui.util.GlobalFunctions.getMappedKey("Sprint",skyui.defines.Input.CONTEXT_GAMEPLAY,true);
         this._saveEquipStateKey = skyui.util.GlobalFunctions.getMappedKey("Wait",skyui.defines.Input.CONTEXT_GAMEPLAY,true);
         this._toggleFocusKey = skyui.util.GlobalFunctions.getMappedKey("Jump",skyui.defines.Input.CONTEXT_GAMEPLAY,true);
         this.createControls();
      }
      this.navButton.setPlatform(a_platform);
      this.navPanel.row1.setPlatform(a_platform,a_bPS3Switch);
      this.navPanel.row2.setPlatform(a_platform,a_bPS3Switch);
      this.updateNavButtons();
   }
   function onFilterChange(a_event)
   {
      if(this._isInitialized)
      {
         this.itemList.InvalidateData();
      }
   }
   function onItemPress(a_event)
   {
      if(this._state != FavoritesMenu.ITEM_SELECT)
      {
         return undefined;
      }
      if(a_event.keyboardOrMouse != 0)
      {
         this._useMouseNavigation = false;
         gfx.io.GameDelegate.call("ItemSelect",[]);
      }
      else
      {
         this._useMouseNavigation = true;
      }
   }
   function onItemSelectionChange(a_event)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      this._useMouseNavigation = a_event.keyboardOrMouse == 0;
      this.updateNavButtons();
   }
   function onCategorySelect(a_event)
   {
      var _loc2_ = a_event.item;
      if(_loc2_ == null)
      {
         return undefined;
      }
      this._categoryIndex = this._categoryButtonGroup.indexOf(_loc2_);
      this._groupButtonFocused = false;
      this._groupButtonGroup.setSelectedButton(null);
      this.itemList.listState.activeGroupIndex = -1;
      this.headerText.SetText(_loc2_.text);
      this._typeFilter.changeFilterFlag(_loc2_.filterFlag);
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
      this.updateNavButtons();
   }
   function onGroupSelect(a_event)
   {
      var _loc2_ = a_event.item;
      if(_loc2_ == null)
      {
         return undefined;
      }
      var _loc3_ = this._groupButtonGroup.indexOf(_loc2_);
      this._groupButtonFocused = true;
      this._categoryButtonGroup.setSelectedButton(null);
      this.headerText.SetText(_loc2_.text);
      this.itemList.listState.activeGroupIndex = _loc3_;
      this._typeFilter.changeFilterFlag(_loc2_.filterFlag);
      if(this._state == FavoritesMenu.GROUP_ASSIGN)
      {
         if(this._groupAssignIndex == _loc3_)
         {
            this.applyGroupAssignment();
         }
         else
         {
            this.navButton.setButtonData({text:"$Confirm Group",controls:skyui.defines.Input.Accept});
            this._groupAssignIndex = _loc3_;
         }
      }
      else
      {
         this._groupIndex = _loc3_;
      }
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
      this.updateNavButtons();
   }
   function onFadeInCompletion()
   {
      this._fadedIn = true;
      this.updateNavButtons();
   }
   function startFadeOut()
   {
      this._state = FavoritesMenu.CLOSING;
      this.updateNavButtons();
      this._parent.gotoAndPlay("startFadeOut");
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
   }
   function onFadeOutCompletion()
   {
      this.saveIndices();
      gfx.io.GameDelegate.call("FadeDone",[this.itemList.selectedIndex]);
   }
   function onMouseDown()
   {
      this._useMouseNavigation = true;
   }
   function onMouseMove()
   {
      this._useMouseNavigation = true;
   }
   function startGroupAssignment()
   {
      if(this._waitingForGroupData)
      {
         return undefined;
      }
      var _loc3_ = this.itemList.selectedEntry;
      if(_loc3_ == null)
      {
         return undefined;
      }
      this._state = FavoritesMenu.GROUP_ASSIGN;
      this.headerText._visible = false;
      this._groupAssignIndex = -1;
      var _loc2_ = this.itemList.selectedEntry;
      this.itemList.listState.assignedEntry = _loc2_;
      _loc2_.filterFlag |= FilterDataExtender.FILTERFLAG_GROUP_ADD;
      this.itemList.listState.restoredSelectedIndex = this.itemList.selectedIndex;
      this.itemList.listState.restoredScrollPosition = this.itemList.scrollPosition;
      this.itemList.selectedIndex = -1;
      this.itemList.disableSelection = true;
      this.itemList.requestUpdate();
      this.navButton.visible = true;
      this.navButton.setButtonData({text:"$Select Group",controls:skyui.defines.Input.LeftRight});
      this.btnAll.disabled = true;
      this.btnGear.disabled = true;
      this.btnAid.disabled = true;
      this.btnMagic.disabled = true;
      this.btnAll.visible = false;
      this.btnGear.visible = false;
      this.btnAid.visible = false;
      this.btnMagic.visible = false;
      this.updateNavButtons();
   }
   function applyGroupAssignment()
   {
      var _loc2_ = this.itemList.listState.assignedEntry.formId;
      var _loc3_ = this.itemList.listState.assignedEntry.itemId;
      if(_loc2_ == null || _loc2_ == 0 || this._groupAssignIndex == -1)
      {
         this.endGroupAssignment();
         gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
      }
      else
      {
         this.itemList.suspended = true;
         this.enableGroupButtons(false);
         this._state = FavoritesMenu.GROUP_ASSIGN_SYNC;
         skse.SendModEvent("SKIFM_groupAdd",String(_loc3_),this._groupAssignIndex,_loc2_);
         gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
      }
   }
   function endGroupAssignment()
   {
      this.itemList.listState.assignedEntry.filterFlag &= ~FilterDataExtender.FILTERFLAG_GROUP_ADD;
      this.itemList.listState.assignedEntry = null;
      this.itemList.onInvalidate = function()
      {
         this.scrollPosition = this.listState.restoredScrollPosition;
         this.selectedIndex = this.listState.restoredSelectedIndex;
         delete this.onInvalidate;
      };
      this.itemList.disableSelection = false;
      this.itemList.requestInvalidate();
      this.itemList.suspended = false;
      this._state = FavoritesMenu.ITEM_SELECT;
      this._groupAssignIndex = -1;
      this.btnAll.disabled = false;
      this.btnGear.disabled = false;
      this.btnAid.disabled = false;
      this.btnMagic.disabled = false;
      this.btnAll.visible = true;
      this.btnGear.visible = true;
      this.btnAid.visible = true;
      this.btnMagic.visible = true;
      this.headerText._visible = true;
      this.navButton.visible = false;
      this.setGroupFocus(false);
      this.enableGroupButtons(true);
      this.updateNavButtons();
   }
   function startGroupRemoval()
   {
      var _loc2_ = this.itemList.selectedEntry.itemId;
      if(this._groupButtonFocused && this._groupIndex >= 0)
      {
         this._state = FavoritesMenu.GROUP_REMOVE_SYNC;
         skse.SendModEvent("SKIFM_groupRemove",String(_loc2_),this._groupIndex);
         gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
      }
   }
   function endGroupRemoval()
   {
      this._state = FavoritesMenu.ITEM_SELECT;
   }
   function requestGroupUse()
   {
      if(this._groupButtonFocused && this._groupIndex >= 0 && this.itemList.listEnumeration.size() > 0)
      {
         skse.SendModEvent("SKIFM_groupUse","",this._groupIndex);
         this.startFadeOut();
      }
   }
   function startSaveEquipState()
   {
      this.leftHandItemId = 0;
      this.rightHandItemId = 0;
      var _loc4_ = this.itemList.entryList.length;
      var _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < _loc4_)
      {
         _loc2_ = this.itemList.entryList[_loc3_];
         if(_loc2_.equipState == 2)
         {
            this.leftHandItemId = _loc2_.itemId;
         }
         else if(_loc2_.equipState == 3)
         {
            this.rightHandItemId = _loc2_.itemId;
         }
         else if(_loc2_.equipState == 4)
         {
            this.leftHandItemId = _loc2_.itemId;
            this.rightHandItemId = _loc2_.itemId;
         }
         _loc3_ = _loc3_ + 1;
      }
      var _loc5_ = this.itemList.selectedEntry;
      if(this._groupButtonFocused && this._groupIndex >= 0)
      {
         this._state = FavoritesMenu.SAVE_EQUIP_STATE_SYNC;
         skse.SendModEvent("SKIFM_saveEquipState","",this._groupIndex);
         gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
      }
   }
   function endSaveEquipState()
   {
      this._state = FavoritesMenu.ITEM_SELECT;
   }
   function startSetGroupIcon()
   {
      var _loc3_ = this.itemList.selectedEntry.itemId;
      var _loc2_ = this.itemList.selectedEntry.formId;
      if(this._groupButtonFocused && this._groupIndex >= 0 && _loc2_)
      {
         this._state = FavoritesMenu.SET_ICON_SYNC;
         skse.SendModEvent("SKIFM_setGroupIcon",String(_loc3_),this._groupIndex,_loc2_);
         gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
      }
   }
   function endSetGroupIcon()
   {
      this._state = FavoritesMenu.ITEM_SELECT;
   }
   function enableGroupButtons(a_enabled)
   {
      if(a_enabled && !this._groupButtonsShown)
      {
         this._groupButtonsShown = true;
         this.groupButtonFader.gotoAndPlay("show");
      }
      var _loc3_ = !a_enabled;
      var _loc2_ = 1;
      while(_loc2_ <= 8)
      {
         this.groupButtonFader.groupButtonHolder["btnGroup" + _loc2_].disabled = _loc3_;
         _loc2_ = _loc2_ + 1;
      }
   }
   function setGroupFocus(a_focus)
   {
      if(a_focus)
      {
         if(this._groupButtonsShown)
         {
            this._groupButtonGroup.setSelectedButton(this._groupButtonGroup.getButtonAt(this._groupIndex));
         }
      }
      else
      {
         this._categoryButtonGroup.setSelectedButton(this._categoryButtonGroup.getButtonAt(this._categoryIndex));
      }
   }
   function confirmSelectedEntry()
   {
      if(this._state != FavoritesMenu.ITEM_SELECT)
      {
         return false;
      }
      if(this._platform != 0 || !this._useMouseNavigation)
      {
         return true;
      }
      var _loc2_ = Mouse.getTopMostEntity();
      while(_loc2_ != undefined)
      {
         if(_loc2_.itemIndex == this.itemList.selectedIndex)
         {
            return true;
         }
         _loc2_ = _loc2_._parent;
      }
      return false;
   }
   function saveIndices()
   {
      var _loc2_ = [this._categoryIndex,this._groupIndex,this.itemList.selectedIndex,this.itemList.scrollPosition];
      skse.StoreIndices("SKI_FavoritesMenuState",_loc2_);
   }
   function restoreIndices()
   {
      var _loc2_ = [];
      skse.LoadIndices("SKI_FavoritesMenuState",_loc2_);
      if(_loc2_.length != 4)
      {
         return undefined;
      }
      this._categoryIndex = _loc2_[0];
      this._groupIndex = _loc2_[1];
      this.itemList.listState.restoredSelectedIndex = _loc2_[2];
      this.itemList.listState.restoredScrollPosition = _loc2_[3];
      this.itemList.onInvalidate = function()
      {
         this.scrollPosition = this.listState.restoredScrollPosition;
         this.selectedIndex = this.listState.restoredSelectedIndex;
         delete this.onInvalidate;
      };
   }
   function updateNavButtons()
   {
      if(this._state != FavoritesMenu.ITEM_SELECT || !this._navPanelEnabled || !this._fadedIn || this._waitingForGroupData)
      {
         this.navPanel._visible = false;
         return undefined;
      }
      var _loc6_ = this.itemList.listEnumeration.size() > 0;
      var _loc5_ = this.itemList.selectedEntry != null;
      this.navPanel._visible = true;
      var _loc3_ = this.navPanel.row1;
      var _loc2_ = this.navPanel.row2;
      var _loc4_ = false;
      _loc3_.clearButtons();
      _loc3_.addButton({text:"$Toggle Focus",controls:this._toggleFocusControls});
      if(_loc5_)
      {
         _loc3_.addButton({text:(!this._groupButtonFocused ? "$Group" : "$Ungroup"),controls:this._groupAddControls});
      }
      _loc3_.updateButtons(true);
      _loc2_.clearButtons();
      if(this._groupButtonFocused && _loc6_)
      {
         _loc4_ = true;
         _loc2_.addButton({text:"$Group Use",controls:this._groupUseControls});
         _loc2_.addButton({text:"$Save Equip State",controls:this._saveEquipStateControls});
         if(_loc5_)
         {
            _loc2_.addButton({text:"$Set Group Icon",controls:this._setIconControls});
         }
      }
      _loc2_.updateButtons(true);
      _loc3_._x = - _loc3_._width / 2;
      _loc3_._y = !_loc4_ ? 35 : 10;
      _loc2_._x = - _loc2_._width / 2;
      _loc2_._y = 65;
   }
   function createControls()
   {
      this._groupAddControls = {keyCode:this._groupAddKey};
      this._groupUseControls = {keyCode:this._groupUseKey};
      this._setIconControls = {keyCode:this._setIconKey};
      this._saveEquipStateControls = {keyCode:this._saveEquipStateKey};
      this._toggleFocusControls = {keyCode:this._toggleFocusKey};
   }
}
