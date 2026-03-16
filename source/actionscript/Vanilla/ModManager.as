class ModManager extends MovieClip
{
   var AccountSettingsPage_mc;
   var BottomButtons_mc;
   var CurrentState;
   var DetailsPage_mc;
   var LibraryPage_mc;
   var ListsHolder_mc;
   var LoginHolder_mc;
   var LoginMenu;
   var ModCategoryList1;
   var ModCategoryList2;
   var PreviousState;
   var SearchPage_mc;
   var _PreviousFocusedCategory;
   var _StoredSelectedEntry;
   var codeObj;
   var onEnterFrame;
   static var LOGIN_STATE = "LoginState";
   static var MOD_CATEGORY_LIST_STATE = "ModCategoryListState";
   static var MOD_DETAIL_STATE = "ModDetailState";
   static var MOD_LIBRARY_STATE = "ModLibraryState";
   static var MOD_LIBRARY_REORDER_STATE = "ModLibraryReorderState";
   static var MOD_SEARCH_STATE = "ModSearchState";
   static var ACCOUNT_SETTINGS_STATE = "AccountSettingsState";
   static var MOD_MANAGER_CLOSING = "ModManagerClosingState";
   static var MOD_MANAGER_CLOSED_STATE = "ModManagerClosedState";
   static var DELETE_ALL_MODS_OPTION = "DeleteAllModsOption";
   static var DISABLE_ALL_MODS_OPTION = "DisableAllModsOption";
   var _DataArray = [];
   var iPlatform = 0;
   var PS3Switch = false;
   var _CurrScrollPage = 0;
   var _codeObjInitialized = false;
   static var MinimalMode = false;
   var _LoggedIn = false;
   function ModManager()
   {
      super();
      trace("ModManager::ModManager");
      _global.gfxExtensions = true;
      Shared.GlobalFunc.MaintainTextFormat();
      _root.CodeObj = this.codeObj = new Object();
      _root.InitExtensions = Shared.Proxy.create(this,this.InitExtensions);
      _root.onCodeObjectInit = Shared.Proxy.create(this,this.onCodeObjectInit);
      _root.ReleaseCodeObject = Shared.Proxy.create(this,this.ReleaseCodeObject);
      _root.SetPlatform = Shared.Proxy.create(this,this.SetPlatform);
      _root.onRightStickInput = Shared.Proxy.create(this,this.OnRightStickInput);
      this.DisplayScreen(null);
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function get dataArray()
   {
      return this._DataArray;
   }
   function get minimalMode()
   {
      return ModManager.MinimalMode;
   }
   function OnLoginSuccess()
   {
      trace("ModManager::OnLoginSuccess");
      this._LoggedIn = true;
   }
   function onEULACanceled(event)
   {
      trace("ModManager::onEULACanceled");
      this.onModCancel();
   }
   function onInitDataComplete()
   {
      trace("ModManager::onInitDataComplete");
      var _loc2_;
      var _loc3_;
      if(this.minimalMode)
      {
         this.BeginState(ModManager.MOD_LIBRARY_STATE);
      }
      else
      {
         _loc2_ = 0;
         _loc3_ = 0;
         if(!this.IsValidCategoryObj(this._DataArray[0]))
         {
            _loc2_ = this.GetNextValidDataArray_Index(0);
         }
         _loc3_ = this.GetNextValidDataArray_Index(_loc2_);
         if(_loc2_ != 1.7976931348623157e+308)
         {
            this._CurrScrollPage = _loc2_;
            this.ModCategoryList1.dataObj = this._DataArray[_loc2_];
         }
         if(_loc3_ != 1.7976931348623157e+308)
         {
            this.ModCategoryList2.dataObj = this._DataArray[_loc3_];
         }
         this.AccountSettingsPage_mc.List_mc.focusEnabled = true;
         this.AccountSettingsPage_mc.List_mc.InvalidateData();
         this.ModCategoryList1.selectedIndex = 0;
         this.UpdateScrollMarkers();
         this.BeginState(ModManager.MOD_CATEGORY_LIST_STATE);
      }
   }
   function BackToLogin()
   {
      trace("ModManager::BackToLogin");
      this.BeginState(ModManager.LOGIN_STATE);
   }
   function onDataCategoryUpdate(auiCategory)
   {
      trace("ModManager::onDataCategoryUpdate " + auiCategory);
      var _loc2_;
      var _loc3_;
      if(this.IsValidCategoryObj(this._DataArray[this._CurrScrollPage]))
      {
         _loc2_ = this._CurrScrollPage;
      }
      else
      {
         _loc2_ = this.GetNextValidDataArray_Index(this._CurrScrollPage);
         this._CurrScrollPage = _loc2_;
      }
      _loc3_ = this.GetNextValidDataArray_Index(_loc2_);
      this.ModCategoryList1.dataObj = this._DataArray[_loc2_];
      this.ModCategoryList2.dataObj = this._DataArray[_loc3_];
      if(!this.ModCategoryList1.dataObj.loaded)
      {
         this.codeObj.StartCategoryRefresh(_loc2_);
      }
      if(!this.ModCategoryList2.dataObj.loaded)
      {
         this.codeObj.StartCategoryRefresh(_loc3_);
      }
   }
   function onDataObjectChange(aUpdatedObj)
   {
      this.ModCategoryList1.onDataObjectChange(aUpdatedObj);
      this.ModCategoryList2.onDataObjectChange(aUpdatedObj);
      if(aUpdatedObj == this.DetailsPage_mc.dataObj)
      {
         this.DetailsPage_mc.dataObj = aUpdatedObj;
      }
      this.LibraryPage_mc.onDataObjectChange(aUpdatedObj);
   }
   function onLibraryArrayChange()
   {
      this.LibraryPage_mc.dataArray.sort(this.sortModsFunc);
      this.LibraryPage_mc.InvalidateData();
      this.UpdateAccountSettingsList();
   }
   function ShowDetailsPageError(astrErrorText)
   {
      if(this.DetailsPage_mc._visible)
      {
         this.DetailsPage_mc.ShowError(astrErrorText);
      }
   }
   function onConfirmCloseManager()
   {
      trace("ModManager::onConfirmCloseManager");
      this.LibraryPage_mc.ClearArray();
      if(!this.codeObj.attemptCloseManager())
      {
         this.BeginState(ModManager.MOD_MANAGER_CLOSING);
      }
      else
      {
         this.BeginState(ModManager.MOD_MANAGER_CLOSED_STATE);
      }
   }
   function onModSearchReturned(resultCategory)
   {
      trace("ModManager::onModSearchReturned");
      this.SearchPage_mc.SearchReturned(resultCategory);
      var _loc3_;
      if(resultCategory != -1)
      {
         _loc3_ = this.GetNextValidDataArray_Index(resultCategory);
         this._CurrScrollPage = resultCategory;
         this.ModCategoryList1.dataObj = this._DataArray[resultCategory];
         if(_loc3_ != 1.7976931348623157e+308)
         {
            this.ModCategoryList2.dataObj = this._DataArray[_loc3_];
         }
         this.ModCategoryList1.currScrollPage = 0;
         this.ModCategoryList1.selectedIndex = 0;
         Selection.setFocus(this.ModCategoryList1);
         this.BeginState(ModManager.MOD_CATEGORY_LIST_STATE);
      }
   }
   function onVKBTextEntered(astrEnteredText)
   {
      if(this.CurrentState == ModManager.LOGIN_STATE)
      {
         this.LoginMenu.onVKBTextEntered(astrEnteredText);
      }
      else if(this.CurrentState == ModManager.MOD_SEARCH_STATE)
      {
         this.SearchPage_mc.onVKBTextEntered(astrEnteredText);
      }
   }
   function SetLibraryFreeSpace(aFreedSpace)
   {
      trace("ModManager::SetLibraryFreeSpace " + aFreedSpace);
      this.LibraryPage_mc.freeSpace = aFreedSpace;
      this.LibraryPage_mc.InvalidateData();
   }
   function Init()
   {
      trace("ModManager::Init");
      var _loc4_;
      var _loc3_;
      var _loc2_;
      if(this._codeObjInitialized)
      {
         this.onEnterFrame = null;
         this.ModCategoryList1 = this.ListsHolder_mc.List1_mc;
         this.ModCategoryList1.addEventListener(gfx.events.EventTypes.ITEM_CLICK,Shared.Proxy.create(this,this.onModItemPress));
         this.ModCategoryList1.addEventListener(gfx.events.EventTypes.ITEM_ROLL_OVER,Shared.Proxy.create(this,this.onListRollover,this.ModCategoryList1));
         this.ModCategoryList1.addEventListener(ModCategoryList.PLAY_SOUND,Shared.Proxy.create(this,this.onPlaySound));
         this.ModCategoryList1.addEventListener(ListEntryBase.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.onLoadThumbnail));
         this.ModCategoryList1.addEventListener(ListEntryBase.DISPLAY_IMAGE,Shared.Proxy.create(this,this.onDisplayImage));
         this.ModCategoryList1.addEventListener(ListEntryBase.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.onUnregisterImage));
         this.ModCategoryList2 = this.ListsHolder_mc.List2_mc;
         this.ModCategoryList2.addEventListener(gfx.events.EventTypes.ITEM_CLICK,Shared.Proxy.create(this,this.onModItemPress));
         this.ModCategoryList2.addEventListener(gfx.events.EventTypes.ITEM_ROLL_OVER,Shared.Proxy.create(this,this.onListRollover,this.ModCategoryList2));
         this.ModCategoryList2.addEventListener(ModCategoryList.PLAY_SOUND,Shared.Proxy.create(this,this.onPlaySound));
         this.ModCategoryList2.addEventListener(ListEntryBase.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.onLoadThumbnail));
         this.ModCategoryList2.addEventListener(ListEntryBase.DISPLAY_IMAGE,Shared.Proxy.create(this,this.onDisplayImage));
         this.ModCategoryList2.addEventListener(ListEntryBase.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.onUnregisterImage));
         MovieClip(this.ListsHolder_mc.ScrollUp).onRelease = Shared.Proxy.create(this,this.onScrollUpClick);
         MovieClip(this.ListsHolder_mc.ScrollDown).onRelease = Shared.Proxy.create(this,this.onScrollDownClick);
         this.DetailsPage_mc.addEventListener(ListEntryBase.DISPLAY_IMAGE,Shared.Proxy.create(this,this.onDisplayImage));
         this.DetailsPage_mc.addEventListener(ListEntryBase.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.onUnregisterImage));
         this.DetailsPage_mc.addEventListener("itemPress",Shared.Proxy.create(this,this.onDetailsOptionPress));
         this.DetailsPage_mc.addEventListener(ModCategoryList.PLAY_SOUND,Shared.Proxy.create(this,this.onPlaySound));
         this.BottomButtons_mc.SetPlatform(this.iPlatform,this.PS3Switch);
         this.BottomButtons_mc.addEventListener(BottomButtons.BUTTON_CLICKED,Shared.Proxy.create(this,this.OnBottomButtonClicked));
         this.SearchPage_mc.CodeObject = this.codeObj;
         this.SearchPage_mc.SetPlatform(this.iPlatform);
         this.LibraryPage_mc.addEventListener(ModLibraryPage.LIBRARY_ITEM_PRESSED,Shared.Proxy.create(this,this.OnLibraryItemPressed));
         this.LibraryPage_mc.addEventListener(ModLibraryPage.PLAY_SOUND,Shared.Proxy.create(this,this.onPlaySound));
         this.LibraryPage_mc.addEventListener(ListEntryBase.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.onLoadThumbnail));
         this.LibraryPage_mc.addEventListener(ListEntryBase.DISPLAY_IMAGE,Shared.Proxy.create(this,this.onDisplayImage));
         this.LibraryPage_mc.addEventListener(ListEntryBase.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.onUnregisterImage));
         this.AccountSettingsPage_mc.List_mc.entryList = [{text:"$DeleteAllMods",key:ModManager.DELETE_ALL_MODS_OPTION},{text:"$DisableAllMods",key:ModManager.DISABLE_ALL_MODS_OPTION}];
         _loc4_ = new Object();
         _loc4_.onLoadInit = Shared.Proxy.create(this,this.OnLoginLoadInit);
         _loc3_ = new MovieClipLoader();
         _loc3_.addListener(_loc4_);
         _loc3_.loadClip("BethesdaNetLogin.swf",this.LoginHolder_mc);
         _loc2_ = new Object();
         _loc2_.onMouseWheel = Shared.Proxy.create(this,this.onMouseWheel);
         Mouse.addListener(_loc2_);
      }
   }
   function handleInput(details, pathToFocus)
   {
      trace("ModManager::handleInput");
      var _loc3_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         _loc3_ = this.DoHandleInput(details.navEquivalent,details.code);
      }
      if(!_loc3_)
      {
         pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      return true;
   }
   function DoHandleInput(nav, keyCode, usingMouse)
   {
      trace("ModManager::handleInput " + nav);
      var _loc3_ = false;
      if(this.CurrentState == ModManager.MOD_CATEGORY_LIST_STATE)
      {
         if(nav == gfx.ui.NavigationCode.ESCAPE || nav == gfx.ui.NavigationCode.GAMEPAD_B || nav == gfx.ui.NavigationCode.TAB || keyCode == 9)
         {
            this.onModCancel();
            _loc3_ = true;
         }
         if(nav == gfx.ui.NavigationCode.UP)
         {
            this.scrollCategoryListUp();
            _loc3_ = true;
         }
         else if(nav == gfx.ui.NavigationCode.DOWN)
         {
            this.scrollCategoryListDown();
            _loc3_ = true;
         }
         if(nav == gfx.ui.NavigationCode.GAMEPAD_Y || keyCode == 84)
         {
            this.codeObj.PlaySound("UIMenuOK");
            this.BeginState(ModManager.MOD_LIBRARY_STATE);
            _loc3_ = true;
         }
         if(nav == gfx.ui.NavigationCode.GAMEPAD_X || keyCode == 88)
         {
            this.codeObj.PlaySound("UIMenuOK");
            this.BeginState(ModManager.MOD_SEARCH_STATE);
            _loc3_ = true;
         }
         if(nav == gfx.ui.NavigationCode.PAGE_UP || nav == gfx.ui.NavigationCode.GAMEPAD_L1)
         {
            if(Selection.getFocus() == targetPath(this.ModCategoryList1))
            {
               this.ModCategoryList1.JumpLeft();
            }
            else if(Selection.getFocus() == targetPath(this.ModCategoryList2))
            {
               this.ModCategoryList2.JumpLeft();
            }
         }
         if(nav == gfx.ui.NavigationCode.PAGE_DOWN || nav == gfx.ui.NavigationCode.GAMEPAD_R1)
         {
            if(Selection.getFocus() == targetPath(this.ModCategoryList1))
            {
               this.ModCategoryList1.JumpRight();
            }
            else if(Selection.getFocus() == targetPath(this.ModCategoryList2))
            {
               this.ModCategoryList2.JumpRight();
            }
         }
         if(nav == gfx.ui.NavigationCode.HOME || nav == gfx.ui.NavigationCode.GAMEPAD_L2 || keyCode == 36)
         {
            this.onTimeFilterLeftPress();
         }
         if(nav == gfx.ui.NavigationCode.END || nav == gfx.ui.NavigationCode.GAMEPAD_R2 || keyCode == 35)
         {
            this.onTimeFilterRightPress();
         }
         if(usingMouse && keyCode == 13)
         {
            if(this.ListsHolder_mc._visible && this._StoredSelectedEntry != null)
            {
               this.codeObj.PlaySound("UIMenuOK");
               this.BeginState(ModManager.MOD_DETAIL_STATE);
            }
         }
      }
      else if(this.CurrentState == ModManager.MOD_DETAIL_STATE)
      {
         if(nav == gfx.ui.NavigationCode.ESCAPE || nav == gfx.ui.NavigationCode.GAMEPAD_B || nav == gfx.ui.NavigationCode.TAB || keyCode == 9)
         {
            this.codeObj.PlaySound("UIMenuCancel");
            this.BeginState(ModManager.MOD_CATEGORY_LIST_STATE);
            _loc3_ = true;
         }
         if(nav == gfx.ui.NavigationCode.ENTER || nav == gfx.ui.NavigationCode.GAMEPAD_A || keyCode == 13)
         {
            this.onDetailsOptionPress();
         }
      }
      else if(this.CurrentState == ModManager.MOD_LIBRARY_STATE)
      {
         if(this.minimalMode)
         {
            if(nav == gfx.ui.NavigationCode.ESCAPE || nav == gfx.ui.NavigationCode.GAMEPAD_B || nav == gfx.ui.NavigationCode.TAB || keyCode == 9)
            {
               if(this._LoggedIn)
               {
                  this.onModCancel();
                  _loc3_ = true;
               }
               else
               {
                  this.codeObj.PlaySound("UIMenuCancel");
                  this.BeginState(ModManager.LOGIN_STATE);
                  this.LoginMenu.ReenterLogin();
                  _loc3_ = true;
               }
            }
         }
         else
         {
            if(nav == gfx.ui.NavigationCode.ESCAPE || nav == gfx.ui.NavigationCode.GAMEPAD_B || nav == gfx.ui.NavigationCode.TAB || keyCode == 9)
            {
               if(this._LoggedIn)
               {
                  this.BeginState(ModManager.MOD_CATEGORY_LIST_STATE);
               }
               else
               {
                  this.BeginState(ModManager.LOGIN_STATE);
                  this.LoginMenu.ReenterLogin();
               }
               this.codeObj.PlaySound("UIMenuCancel");
               _loc3_ = true;
            }
            if(nav == gfx.ui.NavigationCode.GAMEPAD_A || keyCode == 13)
            {
               if(this.LibraryPage_mc.List_mc.selectedEntry != null)
               {
                  this.codeObj.PlaySound("UIMenuOK");
                  this.ToggleModActive(this.LibraryPage_mc.List_mc.selectedEntry);
                  this.LibraryPage_mc.Refresh();
                  Selection.setFocus(this.LibraryPage_mc);
               }
               _loc3_ = true;
            }
            if(nav == gfx.ui.NavigationCode.GAMEPAD_Y || keyCode == 84)
            {
               if(this.LibraryPage_mc.List_mc.selectedEntry)
               {
                  this.codeObj.PlaySound("UIMenuOK");
                  this.DeleteLibraryMod(this.LibraryPage_mc.List_mc.selectedEntry);
                  _loc3_ = true;
               }
               Selection.setFocus(this.LibraryPage_mc);
            }
            if(nav == gfx.ui.NavigationCode.GAMEPAD_X || keyCode == 88)
            {
               this.codeObj.PlaySound("UIMenuOK");
               Selection.setFocus(this.LibraryPage_mc);
               this.onModReorderPressed();
               _loc3_ = true;
            }
            if(nav == gfx.ui.NavigationCode.GAMEPAD_BACK || keyCode == 86)
            {
               this.codeObj.PlaySound("UIMenuOK");
               this.BeginState(ModManager.ACCOUNT_SETTINGS_STATE);
               _loc3_ = true;
            }
         }
      }
      else if(this.CurrentState == ModManager.MOD_LIBRARY_REORDER_STATE)
      {
         if(nav == gfx.ui.NavigationCode.GAMEPAD_X || keyCode == 88)
         {
            this.codeObj.PlaySound("UIMenuOK");
            this.onModReorderPressed();
            _loc3_ = true;
         }
      }
      else if(this.CurrentState == ModManager.MOD_SEARCH_STATE)
      {
         if(nav == gfx.ui.NavigationCode.ESCAPE || nav == gfx.ui.NavigationCode.GAMEPAD_B || nav == gfx.ui.NavigationCode.TAB || keyCode == 9)
         {
            this.codeObj.PlaySound("UIMenuCancel");
            this.BeginState(ModManager.MOD_CATEGORY_LIST_STATE);
            _loc3_ = true;
         }
         if(nav == gfx.ui.NavigationCode.ENTER || nav == gfx.ui.NavigationCode.GAMEPAD_A || keyCode == 13)
         {
            this.codeObj.PlaySound("UIMenuOK");
            this.SearchPage_mc.SearchForMods();
            _loc3_ = true;
         }
      }
      else if(this.CurrentState == ModManager.ACCOUNT_SETTINGS_STATE)
      {
         if(nav == gfx.ui.NavigationCode.ESCAPE || nav == gfx.ui.NavigationCode.GAMEPAD_B || nav == gfx.ui.NavigationCode.TAB || keyCode == 9)
         {
            this.codeObj.PlaySound("UIMenuCancel");
            this.BeginState(ModManager.MOD_LIBRARY_STATE);
            _loc3_ = true;
         }
         if(nav == gfx.ui.NavigationCode.ENTER || nav == gfx.ui.NavigationCode.GAMEPAD_A)
         {
            if(this.AccountSettingsPage_mc.List_mc.selectedEntry.key == ModManager.DELETE_ALL_MODS_OPTION)
            {
               this.codeObj.PlaySound("UIMenuOK");
               this.DeleteAllMods();
            }
            else if(this.AccountSettingsPage_mc.List_mc.selectedEntry.key == ModManager.DISABLE_ALL_MODS_OPTION)
            {
               this.codeObj.PlaySound("UIMenuOK");
               this.DisableAllMods();
            }
            _loc3_ = true;
         }
      }
      else if(this.CurrentState == ModManager.LOGIN_STATE)
      {
         if(!this.LoginMenu.SpinnerVisible())
         {
            if(nav == gfx.ui.NavigationCode.GAMEPAD_Y || keyCode == 36)
            {
               if(this.LoginMenu.IsAtLogin())
               {
                  this.codeObj.PlaySound("UIMenuOK");
                  this.BeginState(ModManager.MOD_LIBRARY_STATE);
                  _loc3_ = true;
               }
            }
         }
      }
      return _loc3_;
   }
   function sortModsFunc(aModData1, aModData2)
   {
      var _loc1_ = 0;
      if(aModData1 != null && aModData2 == null)
      {
         _loc1_ = -1;
      }
      else if(aModData1 == null && aModData2 != null)
      {
         _loc1_ = 1;
      }
      if(aModData1 != null && aModData2 != null)
      {
         if(_loc1_ == 0)
         {
            if(aModData1.sortIndex != undefined && aModData2.sortIndex == undefined)
            {
               _loc1_ = -1;
            }
            else if(aModData1.sortIndex == undefined && aModData2.sortIndex != undefined)
            {
               _loc1_ = 1;
            }
            else if(aModData1.sortIndex != undefined && aModData2.sortIndex != undefined)
            {
               if(aModData1.sortIndex < aModData2.sortIndex)
               {
                  _loc1_ = -1;
               }
               if(aModData1.sortIndex > aModData2.sortIndex)
               {
                  _loc1_ = 1;
               }
            }
         }
         if(_loc1_ == 0)
         {
            if(aModData1.text < aModData2.text)
            {
               _loc1_ = -1;
            }
            if(aModData1.text > aModData2.text)
            {
               _loc1_ = 1;
            }
         }
      }
      return _loc1_;
   }
   function InitExtensions()
   {
      trace("ModManager::InitExtensions");
   }
   function onCodeObjectInit()
   {
      trace("ModManager::onCodeObjectInit");
      this._codeObjInitialized = true;
   }
   function ReleaseCodeObject()
   {
      trace("ModManager::ReleaseCodeObject");
      this.LoginMenu.Destroy();
      this.SearchPage_mc.Destroy();
      delete this.codeObj;
      delete _root.CodeObj;
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      trace("ModManager::SetPlatform " + aiPlatform);
      this.iPlatform = aiPlatform;
      this.PS3Switch = abPS3Switch;
      if(this._codeObjInitialized)
      {
         this.BottomButtons_mc.SetPlatform(aiPlatform,abPS3Switch);
      }
   }
   function OnRightStickInput(afXDelta, afYDelta)
   {
      if(this.CurrentState == ModManager.MOD_DETAIL_STATE)
      {
         this.DetailsPage_mc.OnRightStickInput(afXDelta,afYDelta);
      }
      else if(this.CurrentState == ModManager.MOD_LIBRARY_STATE)
      {
         this.LibraryPage_mc.OnRightStickInput(afXDelta,afYDelta);
      }
   }
   function OnLoginLoadInit(mc)
   {
      trace("ModManager::OnLoginLoadInit");
      mc._visible = false;
      mc.onEnterFrame = Shared.Proxy.create(this,this.OnLoginLoadInitFinished,mc);
   }
   function OnLoginLoadInitFinished(mc)
   {
      trace("ModManager::OnLoginLoadInitFinished");
      if(this.LoginHolder_mc.LoginMenu_mc.Constructed)
      {
         this.LoginHolder_mc.onEnterFrame = null;
         this.LoginHolder_mc._visible = false;
         this.LoginMenu = this.LoginHolder_mc.LoginMenu_mc;
         this.LoginMenu.InitView();
         this.LoginMenu.CodeObject = this.codeObj;
         this.LoginMenu.SetPlatform(this.iPlatform,this.PS3Switch);
         this.LoginMenu.SetBottomButtons(this.BottomButtons_mc);
         this.LoginMenu.addEventListener(BethesdaNetLogin.LOGIN_ACTIVATED,Shared.Proxy.create(this,this.onLoginActivated));
         this.LoginMenu.addEventListener(BethesdaNetLogin.LOGIN_CANCELED,Shared.Proxy.create(this,this.onLoginCanceled));
         this.LoginMenu.addEventListener(BethesdaNetLogin.LOGIN_ERROR,Shared.Proxy.create(this,this.onLoginError));
         this.LoginMenu.addEventListener(BethesdaNetLogin.EULA_CANCELED,Shared.Proxy.create(this,this.onEULACanceled));
         ModManager.MinimalMode = this.codeObj.UseMinimalModMenu();
         this.codeObj.InitModManager(this,this.LoginMenu,this.LibraryPage_mc.dataArray);
      }
   }
   function IsValidCategoryObj(aCategoryObj)
   {
      return aCategoryObj.entries instanceof Array && (aCategoryObj.entries.length > 0 || aCategoryObj.loaded == false) && (aCategoryObj.isSelectedFilter == undefined || aCategoryObj.isSelectedFilter);
   }
   function GetPrevValidDataArray_Index(aTargetIndex)
   {
      var _loc3_ = aTargetIndex;
      var _loc2_ = aTargetIndex - 1;
      while(_loc3_ == aTargetIndex && _loc2_ >= 0)
      {
         if(this.IsValidCategoryObj(this._DataArray[_loc2_]))
         {
            _loc3_ = _loc2_;
         }
         _loc2_ = _loc2_ - 1;
      }
      return _loc3_;
   }
   function GetNextValidDataArray_Index(aTargetIndex)
   {
      var _loc3_ = aTargetIndex;
      var _loc2_ = aTargetIndex + 1;
      while(_loc3_ == aTargetIndex && _loc2_ < this._DataArray.length)
      {
         if(this.IsValidCategoryObj(this._DataArray[_loc2_]))
         {
            _loc3_ = _loc2_;
         }
         _loc2_ = _loc2_ + 1;
      }
      return _loc3_;
   }
   function scrollCategoryListUp(abForceScroll)
   {
      if(abForceScroll == undefined)
      {
         abForceScroll = false;
      }
      var _loc2_;
      var _loc4_;
      if(!abForceScroll && Selection.getFocus() == targetPath(this.ModCategoryList2))
      {
         Selection.setFocus(this.ModCategoryList1);
         this.ModCategoryList1.selectedIndex = this.ModCategoryList2.selectedIndex;
         this.ModCategoryList2.selectedIndex = 1.7976931348623157e+308;
         this.codeObj.PlaySound("UIMenuFocus");
         this._PreviousFocusedCategory = this.ModCategoryList1;
      }
      else
      {
         _loc2_ = this.GetPrevValidDataArray_Index(this._CurrScrollPage);
         if(_loc2_ < this._CurrScrollPage)
         {
            _loc4_ = this._CurrScrollPage;
            this._CurrScrollPage = _loc2_;
            this.ModCategoryList1.dataObj = this._DataArray[this._CurrScrollPage];
            this.ModCategoryList2.dataObj = this._DataArray[_loc4_];
            this.codeObj.PlaySound("UIMenuFocus");
            this.ListsHolder_mc.gotoAndPlay("scrollUp");
         }
      }
      this.UpdateScrollMarkers();
   }
   function scrollCategoryListDown(abForceScroll)
   {
      if(abForceScroll == undefined)
      {
         abForceScroll = false;
      }
      var _loc3_;
      var _loc2_;
      if(!abForceScroll && Selection.getFocus() == targetPath(this.ModCategoryList1))
      {
         Selection.setFocus(this.ModCategoryList2);
         this.ModCategoryList2.selectedIndex = this.ModCategoryList1.selectedIndex;
         this.ModCategoryList1.selectedIndex = 1.7976931348623157e+308;
         this.codeObj.PlaySound("UIMenuFocus");
         this._PreviousFocusedCategory = this.ModCategoryList2;
      }
      else
      {
         _loc3_ = this.GetNextValidDataArray_Index(this._CurrScrollPage);
         _loc2_ = this.GetNextValidDataArray_Index(_loc3_);
         if(_loc2_ > _loc3_)
         {
            this._CurrScrollPage = _loc3_;
            this.ModCategoryList1.dataObj = this._DataArray[_loc3_];
            this.ModCategoryList2.dataObj = this._DataArray[_loc2_];
            this.codeObj.PlaySound("UIMenuFocus");
            if(this._DataArray[_loc2_].loaded == false)
            {
               this.codeObj.StartCategoryRefresh(_loc2_);
            }
            this.ListsHolder_mc.gotoAndPlay("scrollDown");
         }
      }
      this.UpdateScrollMarkers();
   }
   function onScrollUpClick()
   {
      this.scrollCategoryListUp();
   }
   function onScrollDownClick()
   {
      this.scrollCategoryListDown();
   }
   function UpdateScrollMarkers()
   {
      var _loc2_ = this.GetNextValidDataArray_Index(this._CurrScrollPage);
      if(this.ListsHolder_mc.ScrollUp != null)
      {
         this.ListsHolder_mc.ScrollUp._visible = this.GetPrevValidDataArray_Index(this._CurrScrollPage) < this._CurrScrollPage;
      }
      if(this.ListsHolder_mc.ScrollDown != null)
      {
         this.ListsHolder_mc.ScrollDown._visible = this.GetNextValidDataArray_Index(_loc2_) > _loc2_;
      }
      this.UpdateTimeFilterButton();
   }
   function onModItemPress(event)
   {
      if(event.target == this.ModCategoryList1)
      {
         this._StoredSelectedEntry = this.ModCategoryList1.selectedEntry;
      }
      else if(event.target == this.ModCategoryList2)
      {
         this._StoredSelectedEntry = this.ModCategoryList2.selectedEntry;
      }
      else
      {
         this._StoredSelectedEntry = undefined;
      }
      if(this.ListsHolder_mc._visible && this._StoredSelectedEntry != null)
      {
         this.codeObj.PlaySound("UIMenuOK");
         this.BeginState(ModManager.MOD_DETAIL_STATE);
      }
   }
   function onPlaySound(event, scope)
   {
      this.codeObj.PlaySound(event.sound);
   }
   function onListRollover(event, scope)
   {
      if(scope == this.ModCategoryList1)
      {
         Selection.setFocus(this.ModCategoryList1);
         this._StoredSelectedEntry = this.ModCategoryList1.selectedEntry;
         this._PreviousFocusedCategory = this.ModCategoryList1;
         this.ModCategoryList1.selectedIndex = this.ModCategoryList1.selectedIndex;
         this.ModCategoryList2.selectedIndex = 1.7976931348623157e+308;
      }
      else if(scope == this.ModCategoryList2)
      {
         Selection.setFocus(this.ModCategoryList2);
         this._StoredSelectedEntry = this.ModCategoryList2.selectedEntry;
         this._PreviousFocusedCategory = this.ModCategoryList2;
         this.ModCategoryList2.selectedIndex = this.ModCategoryList2.selectedIndex;
         this.ModCategoryList1.selectedIndex = 1.7976931348623157e+308;
      }
      this.UpdateTimeFilterButton();
   }
   function onLoginActivated(event)
   {
      trace("ModManager::onLoginActivated");
      this.BeginState(ModManager.LOGIN_STATE);
   }
   function onLoginCanceled(event)
   {
      trace("ModManager::onLoginCanceled");
      if(this.CurrentState == ModManager.LOGIN_STATE)
      {
         this.onModCancel();
      }
   }
   function onLoginError(event)
   {
      trace("ModManager::onLoginError");
      this._LoggedIn = false;
   }
   function onModCancel()
   {
      this.codeObj.PlaySound("UIMenuCancel");
      this.codeObj.confirmCloseManager();
   }
   function onModReorderPressed()
   {
      this.LibraryPage_mc.reorderMode = !this.LibraryPage_mc.reorderMode;
      if(this.LibraryPage_mc.reorderMode)
      {
         this.BeginState(ModManager.MOD_LIBRARY_REORDER_STATE);
      }
      else
      {
         this.BeginState(ModManager.MOD_LIBRARY_STATE);
      }
   }
   function UpdateAccountSettingsList()
   {
      var _loc3_;
      var _loc2_;
      if(this.AccountSettingsPage_mc.List_mc.entryList.length > 0)
      {
         this.AccountSettingsPage_mc.List_mc.entryList[0].disabled = this.LibraryPage_mc.dataArray.length == 0;
         _loc3_ = false;
         for(var _loc4_ in this.LibraryPage_mc.dataArray)
         {
            _loc2_ = this.LibraryPage_mc.dataArray[_loc4_];
            if(_loc2_.checked == true)
            {
               _loc3_ = true;
            }
         }
         this.AccountSettingsPage_mc.List_mc.entryList[1].disabled = !_loc3_;
         this.AccountSettingsPage_mc.List_mc.UpdateList();
      }
   }
   function onAccountSettingsPress(event)
   {
      trace("ModManager::onAccountSettingsPress");
      switch(event.index)
      {
         case 0:
            this.DeleteAllMods();
            break;
         case 1:
            this.DisableAllMods();
         default:
            return;
      }
   }
   function DeleteAllMods()
   {
      trace("ModManager::DeleteAllMods");
      if(!this.AccountSettingsPage_mc.List_mc.entryList[0].disabled)
      {
         this.codeObj.DeleteAllMods();
      }
   }
   function DisableAllMods()
   {
      trace("ModManager::DisableAllMods");
      if(!this.AccountSettingsPage_mc.List_mc.entryList[1].disabled)
      {
         this.codeObj.DisableAllMods();
      }
   }
   function BeginState(state)
   {
      trace("ModManager::BeginState " + state);
      if(this.CurrentState == state)
      {
         return undefined;
      }
      this.EndState(this.CurrentState);
      this.PreviousState = this.CurrentState;
      this.CurrentState = state;
      switch(this.CurrentState)
      {
         case ModManager.LOGIN_STATE:
            this.LoginMenu.SetBottomButtons(this.BottomButtons_mc);
            this.DisplayScreen(this.LoginHolder_mc);
            break;
         case ModManager.MOD_CATEGORY_LIST_STATE:
            this.DisplayScreen(this.ListsHolder_mc);
            if(this.ModCategoryList2.selectedIndex == 1.7976931348623157e+308)
            {
               Selection.setFocus(this.ModCategoryList1);
            }
            else
            {
               Selection.setFocus(this.ModCategoryList2);
            }
            this.BottomButtons_mc.SetButtons([BottomButtons.DETAILS,BottomButtons.LIBRARY,BottomButtons.SEARCH,BottomButtons.MOD_TIME_FILTER,BottomButtons.CANCEL]);
            this.UpdateTimeFilterButton();
            break;
         case ModManager.MOD_DETAIL_STATE:
            if(this._StoredSelectedEntry != null)
            {
               this.codeObj.populateDetails(this._StoredSelectedEntry);
               this.DetailsPage_mc.dataObj = this._StoredSelectedEntry;
               this.DetailsPage_mc.OptionsList_mc.selectedIndex = 0;
               this.DisplayScreen(this.DetailsPage_mc);
               Selection.setFocus(this.DetailsPage_mc);
               this.BottomButtons_mc.SetButtons([BottomButtons.CONFIRM,BottomButtons.CANCEL]);
            }
            break;
         case ModManager.MOD_LIBRARY_STATE:
            if(this.minimalMode)
            {
               this.BottomButtons_mc.SetButtons([BottomButtons.CANCEL]);
            }
            else if(this.LibraryPage_mc.List_mc.entryList.length == 0)
            {
               this.BottomButtons_mc.SetButtons([BottomButtons.OPTIONS,BottomButtons.CANCEL]);
            }
            else
            {
               this.BottomButtons_mc.SetButtons([BottomButtons.ENABLE_MOD,BottomButtons.REORDER_MOD,BottomButtons.DELETE_MOD,BottomButtons.OPTIONS,BottomButtons.CANCEL]);
            }
            if(this.PreviousState != ModManager.MOD_LIBRARY_REORDER_STATE)
            {
               this.LibraryPage_mc.SetBottomButtons(this.BottomButtons_mc);
               this.LibraryPage_mc.List_mc.selectedIndex = 0;
               this.DisplayScreen(this.LibraryPage_mc);
            }
            this.LibraryPage_mc.Refresh();
            Selection.setFocus(this.LibraryPage_mc);
            break;
         case ModManager.MOD_LIBRARY_REORDER_STATE:
            this.BottomButtons_mc.SetButtons([BottomButtons.DONE_REORDER_MOD]);
            this.DisplayScreen(this.LibraryPage_mc);
            Selection.setFocus(this.LibraryPage_mc);
            break;
         case ModManager.MOD_SEARCH_STATE:
            this.DisplayScreen(this.SearchPage_mc);
            this.SearchPage_mc.ClearSearchField();
            Selection.setFocus(this.SearchPage_mc.Input_tf);
            this.BottomButtons_mc.SetButtons([BottomButtons.SEARCH_CONFIRM,BottomButtons.CANCEL]);
            if(this.iPlatform == 0 || this.iPlatform == 1)
            {
               this.codeObj.startEditText();
            }
            break;
         case ModManager.ACCOUNT_SETTINGS_STATE:
            this.UpdateAccountSettingsList();
            this.AccountSettingsPage_mc.List_mc.selectedIndex = 0;
            this.AccountSettingsPage_mc.List_mc.addEventListener("itemPress",Shared.Proxy.create(this,this.onAccountSettingsPress));
            this.DisplayScreen(this.AccountSettingsPage_mc);
            this.AccountSettingsPage_mc.List_mc.focusEnabled = true;
            Selection.setFocus(this.AccountSettingsPage_mc.List_mc);
            this.BottomButtons_mc.SetButtons([BottomButtons.CANCEL]);
            break;
         case ModManager.MOD_MANAGER_CLOSING:
            this.LoginHolder_mc._visible = true;
            this.LoginMenu.ShowSpinner("");
            this.ListsHolder_mc._visible = false;
            this.BottomButtons_mc._visible = false;
            break;
         case ModManager.MOD_MANAGER_CLOSED_STATE:
            Selection.setFocus(null);
         default:
            return;
      }
   }
   function EndState()
   {
      trace("ModManager::EndState " + this.CurrentState);
      switch(this.CurrentState)
      {
         case ModManager.LOGIN_STATE:
            this.LoginMenu.ExitLoginFlow();
            break;
         case ModManager.MOD_DETAIL_STATE:
            if(this.DetailsPage_mc.hasRatingChanged)
            {
               this.codeObj.RateMod(this._StoredSelectedEntry,this.DetailsPage_mc.tempRating);
            }
            this._StoredSelectedEntry = null;
            this.DetailsPage_mc.dataObj = null;
            this.codeObj.ExitDetails();
            break;
         case ModManager.MOD_LIBRARY_REORDER_STATE:
            this.codeObj.onLibraryReorderComplete();
            break;
         case ModManager.MOD_SEARCH_STATE:
            this.codeObj.endEditText();
            break;
         case ModManager.ACCOUNT_SETTINGS_STATE:
            this.AccountSettingsPage_mc.List_mc.removeAllEventListeners("itemPress");
            this.codeObj.PlaySound("UIMenuCancel");
         case ModManager.MOD_CATEGORY_LIST_STATE:
         default:
            return;
      }
   }
   function DisplayScreen(mc)
   {
      trace("ModManager::DisplayScreen");
      this.ListsHolder_mc._visible = this.ListsHolder_mc == mc;
      this.LoginHolder_mc._visible = this.LoginHolder_mc == mc;
      this.DetailsPage_mc._visible = this.DetailsPage_mc == mc;
      this.LibraryPage_mc._visible = this.LibraryPage_mc == mc;
      this.AccountSettingsPage_mc._visible = this.AccountSettingsPage_mc == mc;
      this.SearchPage_mc._visible = this.SearchPage_mc == mc;
   }
   function OnBottomButtonClicked(event)
   {
      var _loc2_ = event.data;
      this.DoHandleInput(null,_loc2_.KeyCode,true);
   }
   function OnLibraryItemPressed(event)
   {
      var _loc2_ = event.data;
      if(!this.minimalMode)
      {
         this.codeObj.PlaySound("UIMenuOK");
      }
      this.ToggleModActive(_loc2_);
      this.LibraryPage_mc.Refresh();
   }
   function ToggleModActive(data)
   {
      trace("ModManager::ToggleModActive");
      if(this.minimalMode)
      {
         return undefined;
      }
      if(data.disabled == true)
      {
         this.codeObj.onDisabledLibraryPress();
      }
      else if(data != null && data.blacklisted == true)
      {
         this.codeObj.onBlacklistLibraryPress();
      }
      else if(data.dataObj instanceof Object)
      {
         if(data.checked)
         {
            this.codeObj.UninstallMod(data.dataObj);
         }
         else
         {
            this.codeObj.InstallMod(data.dataObj);
         }
      }
      else if(data.checked)
      {
         this.codeObj.UninstallMod_NonBnet(data);
      }
      else
      {
         this.codeObj.InstallMod_NonBnet(data);
      }
   }
   function DeleteLibraryMod(data)
   {
      this.codeObj.DeleteModFromLibrary(data);
   }
   function onLoadThumbnail(event)
   {
      trace("ModManager::onLoadThumbnail");
      this.codeObj.LoadThumbnail(event.data);
   }
   function onUnregisterImage(event)
   {
      this.codeObj.UnregisterImage(event.data);
   }
   function onDisplayImage(event)
   {
      this.codeObj.onDisplayImage(event.data);
   }
   function GetCurrentCategoryObject()
   {
      var _loc2_ = null;
      if(this.iPlatform == BethesdaNetLogin.CONTROLLER_PC)
      {
         _loc2_ = this._PreviousFocusedCategory.dataObj;
      }
      else if(Selection.getFocus() == targetPath(this.ModCategoryList1))
      {
         _loc2_ = this.ModCategoryList1.dataObj;
      }
      else if(Selection.getFocus() == targetPath(this.ModCategoryList2))
      {
         _loc2_ = this.ModCategoryList2.dataObj;
      }
      return _loc2_;
   }
   function UpdateTimeFilterData(prevFilter, nextFilter)
   {
      if(prevFilter == this._CurrScrollPage)
      {
         this._CurrScrollPage = nextFilter;
      }
      this.codeObj.PlaySound("UIMenuOK");
      this.onDataCategoryUpdate(prevFilter);
      this.UpdateTimeFilterButton();
   }
   function onTimeFilterLeftPress()
   {
      var _loc2_ = this.GetCurrentCategoryObject();
      if(_loc2_ == null)
      {
         trace("No category object found");
         return undefined;
      }
      var _loc4_ = _loc2_.subFilterIndex;
      var _loc3_;
      if(_loc2_.subFilterIndex != undefined)
      {
         if(_loc2_.prevSubFilter != undefined)
         {
            _loc3_ = _loc2_.prevSubFilter;
         }
         else
         {
            _loc3_ = _loc4_ - 1;
         }
         if(0 <= _loc3_ && _loc3_ < this.dataArray.length)
         {
            this.dataArray[_loc3_].isSelectedFilter = true;
            _loc2_.isSelectedFilter = false;
            this.UpdateTimeFilterData(_loc4_,_loc3_);
         }
         else
         {
            trace("nextFilter(" + _loc3_ + ") is out of bounds.  Length:" + this.dataArray.length);
         }
      }
   }
   function onTimeFilterRightPress()
   {
      var _loc2_ = this.GetCurrentCategoryObject();
      if(_loc2_ == null)
      {
         trace("No category object found");
         return undefined;
      }
      var _loc4_ = _loc2_.subFilterIndex;
      if(_loc2_ == null)
      {
         trace("No category object found");
         return undefined;
      }
      var _loc3_;
      if(_loc2_.subFilterIndex != undefined)
      {
         if(_loc2_.nextSubFilter != undefined)
         {
            _loc3_ = _loc2_.nextSubFilter;
         }
         else
         {
            _loc3_ = _loc4_ + 1;
         }
         if(0 <= _loc3_ && _loc3_ < this.dataArray.length)
         {
            this.dataArray[_loc3_].isSelectedFilter = true;
            _loc2_.isSelectedFilter = false;
            this.UpdateTimeFilterData(_loc4_,_loc3_);
         }
         else
         {
            trace("nextFilter(" + _loc3_ + ") is out of bounds.  Length:" + this.dataArray.length);
         }
      }
   }
   function UpdateTimeFilterButton()
   {
      var _loc2_ = this.GetCurrentCategoryObject();
      var _loc3_ = this.ListsHolder_mc._visible && _loc2_.subFilterIndex != undefined;
      this.BottomButtons_mc.ToggleButtonVisibleByIndex(3,_loc3_);
      if(_loc2_.subFilterIndex != undefined)
      {
         if(0 <= _loc2_.subFilterIndex && _loc2_.subFilterIndex < this.dataArray.length)
         {
            if(this.dataArray[_loc2_.subFilterIndex].filterString != undefined)
            {
               this.BottomButtons_mc.GetButtonByIndex(3).label = this.dataArray[_loc2_.subFilterIndex].filterString;
            }
            else
            {
               this.BottomButtons_mc.GetButtonByIndex(3).label = "";
            }
         }
         else
         {
            trace("currCatObj.subFilterIndex(" + _loc2_.subFilterIndex + ") is out of bounds.  Length:" + this.dataArray.length);
         }
      }
   }
   function onDetailsOptionPress()
   {
      trace("ModManager::onDetailsOptionPress");
      if(this.DetailsPage_mc.selectedEntry.disabled != true)
      {
         switch(this.DetailsPage_mc.selectedEntry.id)
         {
            case ModDetailsPage.FOLLOW_ID:
               this.codeObj.FollowMod(this._StoredSelectedEntry);
               break;
            case ModDetailsPage.UNFOLLOW_ID:
               this.codeObj.UnfollowMod(this._StoredSelectedEntry);
               break;
            case ModDetailsPage.DOWNLOAD_ID:
               if(this.LibraryPage_mc.GetModSpaceRemaining() > 0 && this._StoredSelectedEntry.fileSizeDisplay > this.LibraryPage_mc.GetModSpaceRemaining())
               {
                  this.ShowDetailsPageError("$DetailsPageError_ModTooLarge");
                  break;
               }
               this.codeObj.DownloadMod(this._StoredSelectedEntry);
               break;
            case ModDetailsPage.UPDATE_ID:
               this.codeObj.UpdateMod(this._StoredSelectedEntry);
               break;
            case ModDetailsPage.DELETE_ID:
               this.codeObj.DeleteMod(this._StoredSelectedEntry);
               break;
            case ModDetailsPage.INSTALL_ID:
               this.codeObj.InstallMod(this._StoredSelectedEntry);
               break;
            case ModDetailsPage.UNINSTALL_ID:
               this.codeObj.UninstallMod(this._StoredSelectedEntry);
         }
         this.codeObj.PlaySound("UIMenuOK");
         this.DetailsPage_mc.InvalidateData();
      }
   }
   function onMouseWheel(delta)
   {
      var _loc2_ = false;
      if(this.CurrentState == ModManager.MOD_CATEGORY_LIST_STATE)
      {
         _loc2_ = true;
         if(delta < 0)
         {
            this.scrollCategoryListDown(true);
         }
         else if(delta > 0)
         {
            this.scrollCategoryListUp(true);
         }
      }
      return _loc2_;
   }
}
