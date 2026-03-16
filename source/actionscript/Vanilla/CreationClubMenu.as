class CreationClubMenu extends MovieClip
{
   var BGLoader;
   var Bars_mc;
   var BottomButtons_mc;
   var CCButtons_mc;
   var CategoryList_mc;
   var CurrentState;
   var Details_mc;
   var HaveCreationDetails;
   var Header_mc;
   var LoginHolder_mc;
   var PreviousState;
   var PurchaseDialog_mc;
   var Search_mc;
   var Tabs_mc;
   var Wallet_mc;
   var _BottomButtons_mc;
   var _FeaturedList_mc;
   var _Header_mc;
   var _LoginHolder_mc;
   var _LoginMenu;
   var _StoredSelectedEntry;
   var _Wallet_mc;
   var addEventListener;
   var codeObj;
   var onEnterFrame;
   static var LOGIN_STATE = "LoginState";
   static var CC_CATEGORY_LIST_STATE = "CategoryListState";
   static var CC_DETAILS_STATE = "DetailsState";
   static var CC_PURCHASE_CREATION_STATE = "PurchaseCreationState";
   static var CC_CLOSING_STATE = "ClosedState";
   static var BUTTON_DOWNLOAD_ALL = {PCArt:"CCY",XBoxArt:"CC360_Y",PS3Art:"CCPS3_Y",Label:"$Download All",KeyCode:89};
   static var PURCHASE_CREDITS = {PCArt:"CCX",XBoxArt:"CC360_X",PS3Art:"CCPS3_X",Label:"$Purchase Credits",KeyCode:88};
   static var PURCHASE_MOD = {PCArt:"CCEnter",XBoxArt:"CC360_A",PS3Art:"CCPS3_A",Label:"$Purchase Creation",KeyCode:13};
   static var BUTTON_UPDATE_CREATION = {PCArt:"CCEnter",XBoxArt:"CC360_A",PS3Art:"CCPS3_A",Label:"$Update",KeyCode:13};
   static var BUTTON_DOWNLOAD_CREATION = {PCArt:"CCEnter",XBoxArt:"CC360_A",PS3Art:"CCPS3_A",Label:"$Download",KeyCode:13};
   static var DETAILS = {PCArt:"CCEnter",XBoxArt:"CC360_A",PS3Art:"CCPS3_A",Label:"$Mod_Details",KeyCode:13};
   static var CANCEL = {PCArt:"CCEsc",XBoxArt:"CC360_B",PS3Art:"CCPS3_B",Label:"$Back",KeyCode:9};
   var iPlatform = 0;
   var PS3Switch = false;
   var _codeObjInitialized = false;
   var _CurrScrollPage = 0;
   var _AcceptInput = true;
   var _LoggedIn = false;
   var _Margin = 60;
   var _DataArray = [];
   var Library = [];
   var eLanguage = "en";
   function CreationClubMenu()
   {
      super();
      trace("CreationClubMenu::CreationClubMenu");
      _global.gfxExtensions = true;
      this.focusEnabled = true;
      gfx.events.EventDispatcher.initialize(this);
      Shared.GlobalFunc.MaintainTextFormat();
      _root.CodeObj = this.codeObj = new Object();
      _root.InitExtensions = Shared.Proxy.create(this,this.InitExtensions);
      _root.onCodeObjectInit = Shared.Proxy.create(this,this.onCodeObjectInit);
      _root.ReleaseCodeObject = Shared.Proxy.create(this,this.ReleaseCodeObject);
      _root.SetPlatform = Shared.Proxy.create(this,this.SetPlatform);
      _root.onRightStickInput = Shared.Proxy.create(this,this.OnRightStickInput);
      this.CategoryList_mc._visible = false;
      this.Details_mc._visible = false;
      this.Header_mc._visible = false;
      this.Wallet_mc._visible = false;
      this.Tabs_mc._visible = false;
      this.Search_mc._visible = false;
      this.Bars_mc._visible = false;
      this.BGLoader = new MovieClipLoader();
      this.BGLoader.addListener(this);
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function get dataArray()
   {
      return this._DataArray;
   }
   function get Credits()
   {
      if(this._Wallet_mc != undefined)
      {
         return this._Wallet_mc.Credits;
      }
      return 0;
   }
   function set Credits(acredits)
   {
      if(this._Wallet_mc != undefined)
      {
         this._Wallet_mc.Credits = acredits;
      }
   }
   function OnLoginSuccess()
   {
      trace("CreationClubMenu::OnLoginSuccess");
      this._LoggedIn = true;
   }
   function onInitDataComplete()
   {
      trace("CreationClubMenu::onInitDataComplete");
      this._CurrScrollPage = -1;
      this.ScrollDownFilter();
      this.UpdateScrollMarkers();
      this.BeginState(CreationClubMenu.CC_CATEGORY_LIST_STATE);
   }
   function OnExitCreditScreen(credits)
   {
      trace("CreationClubMenu::OnExitCreditScreen");
      this.Credits = credits;
      if(this.CurrentState == CreationClubMenu.CC_DETAILS_STATE)
      {
         this.InitDetailsDisplay();
      }
   }
   function OnModPurchase()
   {
      trace("CreationClubMenu::OnModPurchase");
      this.BeginState(this.PreviousState);
      this.InitDetailsDisplay();
      if(this.CanDownloadSelectedItem())
      {
         this.codeObj.DownloadCreation(this._StoredSelectedEntry);
      }
   }
   function SortDataArray()
   {
      var _loc3_ = 1;
      var _loc2_;
      var _loc4_;
      while(_loc3_ < this._DataArray.length)
      {
         _loc2_ = _loc3_ - 1;
         while(_loc2_ >= 0)
         {
            if(this._DataArray[_loc3_].order < this._DataArray[_loc2_].order)
            {
               _loc4_ = this._DataArray[_loc3_];
               this._DataArray[_loc3_] = this._DataArray[_loc2_];
               this._DataArray[_loc2_] = _loc4_;
            }
            _loc2_ = _loc2_ - 1;
         }
         _loc3_ = _loc3_ + 1;
      }
   }
   function onDataObjectChange(aUpdatedObj)
   {
      if(this.CurrentState == CreationClubMenu.CC_CATEGORY_LIST_STATE)
      {
         this._FeaturedList_mc.onDataObjectChange(aUpdatedObj);
      }
      else if(this.CurrentState == CreationClubMenu.CC_DETAILS_STATE)
      {
         this.InitDetailsDisplay();
      }
   }
   function Init()
   {
      trace("CreationClubMenu::Init");
      var _loc4_;
      var _loc3_;
      var _loc2_;
      if(this._codeObjInitialized)
      {
         this.onEnterFrame = null;
         this._Header_mc = this.Header_mc;
         this._Wallet_mc = this.Wallet_mc;
         this._FeaturedList_mc = this.CategoryList_mc.Featured_mc;
         this._FeaturedList_mc.eLanguage = this.eLanguage;
         this._BottomButtons_mc = this.BottomButtons_mc;
         this._LoginHolder_mc = this.LoginHolder_mc;
         this._FeaturedList_mc.addEventListener(gfx.events.EventTypes.ITEM_CLICK,Shared.Proxy.create(this,this.onModItemPress));
         this._FeaturedList_mc.addEventListener(gfx.events.EventTypes.ITEM_ROLL_OVER,Shared.Proxy.create(this,this.onListRollover,this._FeaturedList_mc));
         this._FeaturedList_mc.addEventListener(CarouselButton.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.onLoadThumbnail));
         this._FeaturedList_mc.addEventListener(CarouselButton.DISPLAY_IMAGE,Shared.Proxy.create(this,this.onDisplayImage));
         this._FeaturedList_mc.addEventListener(CarouselButton.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.onUnregisterImage));
         this._FeaturedList_mc.addEventListener(CCCarousel.UPDATE_SCROLL,Shared.Proxy.create(this,this.UpdateScrollMarkers));
         this.Tabs_mc.addEventListener(gfx.events.EventTypes.ITEM_CLICK,Shared.Proxy.create(this,this.onTabPress));
         this.Tabs_mc.SetPlatform(this.iPlatform,this.PS3Switch);
         this.Tabs_mc.addEventListener(FilterTabs.BUTTON_CLICKED,Shared.Proxy.create(this,this.OnBottomButtonClicked));
         this.Tabs_mc.addEventListener(FilterTabs.PLAY_SCROLL_LEFT_SOUND,Shared.Proxy.create(this,this.OnTabLeft));
         this.Tabs_mc.addEventListener(FilterTabs.PLAY_SCROLL_RIGHT_SOUND,Shared.Proxy.create(this,this.OnTabRight));
         MovieClip(this.CategoryList_mc.ScrollUp).onRelease = Shared.Proxy.create(this,this.OnScrollUpClick);
         MovieClip(this.CategoryList_mc.ScrollDown).onRelease = Shared.Proxy.create(this,this.OnScrollDownClick);
         this.Details_mc.addEventListener(CCModDetails.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.onLoadThumbnail));
         this.Details_mc.addEventListener(CCModDetails.DISPLAY_IMAGE,Shared.Proxy.create(this,this.onDisplayImage));
         this.Details_mc.addEventListener(CCModDetails.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.onUnregisterImage));
         this.Details_mc.addEventListener(CCModDetails.SCROLL_DETAILS,Shared.Proxy.create(this,this.OnFocusSoundEvent));
         this.Details_mc.Gallery_mc.addEventListener(gfx.events.EventTypes.ITEM_ROLL_OVER,Shared.Proxy.create(this,this.onListRollover,this.Details_mc.Gallery_mc));
         this.Details_mc.Gallery_mc.addEventListener(gfx.events.EventTypes.ITEM_CLICK,Shared.Proxy.create(this,this.OnEnterButtonClick));
         this.Details_mc.Details_mc.BuyNow_mc.onRelease = Shared.Proxy.create(this,this.OnEnterButtonClick);
         this.Details_mc.eLanguage = this.eLanguage;
         this.PurchaseDialog_mc = this.Details_mc.PurchaseDialog_mc;
         this.PurchaseDialog_mc.addEventListener(CCPurchaseDialog.BUY_CLICKED,Shared.Proxy.create(this,this.OnPurchaseDialogBuyClicked));
         this.PurchaseDialog_mc.addEventListener(CCPurchaseDialog.CANCEL_CLICKED,Shared.Proxy.create(this,this.OnPurchaseDialogCancelClicked));
         this.PurchaseDialog_mc._visible = false;
         this.PurchaseDialog_mc.addEventListener(CCPurchaseDialog.BUTTON_HOVER,Shared.Proxy.create(this,this.OnFocusSoundEvent));
         this._BottomButtons_mc.SetPlatform(this.iPlatform,this.PS3Switch);
         this._BottomButtons_mc.addEventListener(BottomButtons.BUTTON_CLICKED,Shared.Proxy.create(this,this.OnBottomButtonClicked));
         this._BottomButtons_mc.Align = BottomButtons.CENTER_ALIGN;
         this._BottomButtons_mc.Margin = this._Margin;
         this.CCButtons_mc.SetPlatform(this.iPlatform,this.PS3Switch);
         this.CCButtons_mc.addEventListener(BottomButtons.BUTTON_CLICKED,Shared.Proxy.create(this,this.OnBottomButtonClicked));
         this.CCButtons_mc.Align = BottomButtons.RIGHT_ALIGN;
         this.CCButtons_mc.Margin = this._Margin;
         this.CCButtons_mc.GamepadButton = "CCGamepadButton";
         this.CCButtons_mc.MouseButton = "CCMouseButton";
         this._CurrScrollPage = -1;
         this.CategoryList_mc.focusEnabled = true;
         this.addEventListener("onEULAAccepted",Shared.Proxy.create(this.onEulaAccepted));
         _loc4_ = new Object();
         _loc4_.onLoadInit = Shared.Proxy.create(this,this.OnLoginLoadInit);
         _loc3_ = new MovieClipLoader();
         _loc3_.addListener(_loc4_);
         _loc3_.loadClip("BethesdaNetLogin.swf",this._LoginHolder_mc);
         _loc2_ = new Object();
         _loc2_.onMouseWheel = Shared.Proxy.create(this,this.onMouseWheel);
         Mouse.addListener(_loc2_);
      }
   }
   function InitExtensions()
   {
   }
   function onCodeObjectInit(lang)
   {
      trace("CreationClubMenu::onCodeObjectInit Language[" + lang + "]");
      this._codeObjInitialized = true;
      this.eLanguage = lang;
   }
   function ReleaseCodeObject()
   {
      trace("CreationClubMenu::ReleaseCodeObject");
      this._LoginMenu.Destroy();
      delete this.codeObj;
      delete _root.CodeObj;
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      trace("CreationClubMenu::SetPlatform " + aiPlatform);
      this.iPlatform = aiPlatform;
      this.PS3Switch = abPS3Switch;
      if(this._codeObjInitialized)
      {
         this.CCButtons_mc.SetPlatform(aiPlatform,abPS3Switch);
         this._BottomButtons_mc.SetPlatform(aiPlatform,abPS3Switch);
         this.Tabs_mc.SetPlatform(this.iPlatform,this.PS3Switch);
      }
   }
   function OnRightStickInput(afXDelta, afYDelta)
   {
   }
   function handleInput(details, pathToFocus)
   {
      trace("CreationClubMenu::handleInput");
      if(!this._AcceptInput)
      {
         return true;
      }
      var _loc2_ = false;
      if(pathToFocus.length > 0)
      {
         _loc2_ = pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      if(!_loc2_ && Shared.GlobalFunc.IsKeyPressed(details))
      {
         _loc2_ = this.DoHandleInput(details.navEquivalent,details.code,false);
      }
      return true;
   }
   function DoHandleInput(nav, keyCode, usingMouse)
   {
      trace("CreationClubMenu::DoHandleInput " + nav);
      if(!this._AcceptInput)
      {
         return true;
      }
      var _loc2_ = false;
      switch(this.CurrentState)
      {
         case CreationClubMenu.CC_CATEGORY_LIST_STATE:
            _loc2_ = this.HandleInputCategoryList(nav,keyCode);
            break;
         case CreationClubMenu.CC_DETAILS_STATE:
            _loc2_ = this.HandleInputDetails(nav,keyCode);
            break;
         case CreationClubMenu.CC_PURCHASE_CREATION_STATE:
            _loc2_ = this.HandleInputPurchaseDialog(nav,keyCode);
      }
      return _loc2_;
   }
   function HandleInputCategoryList(nav, keyCode)
   {
      trace("CreationClubMenu::HandleInputCategoryList " + nav);
      var _loc3_ = false;
      if(nav == gfx.ui.NavigationCode.ESCAPE || nav == gfx.ui.NavigationCode.GAMEPAD_B || nav == gfx.ui.NavigationCode.TAB || keyCode == 9)
      {
         this.codeObj.PlaySound("UIMenuCancel");
         this.onExit();
         _loc3_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.GAMEPAD_X || keyCode == 88)
      {
         if(this.SupportsPurchase())
         {
            this.codeObj.PlaySound("UIMenuOK");
            this.codeObj.EnterCreditsScreen();
            _loc3_ = true;
         }
      }
      else if(nav == gfx.ui.NavigationCode.GAMEPAD_Y || keyCode == 89)
      {
         this.codeObj.DownloadAll();
         _loc3_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.HOME || nav == gfx.ui.NavigationCode.GAMEPAD_L1 || keyCode == 36)
      {
         this.ScrollUpFilter();
         _loc3_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.END || nav == gfx.ui.NavigationCode.GAMEPAD_R1 || keyCode == 35)
      {
         this.ScrollDownFilter();
         _loc3_ = true;
      }
      else if(keyCode == 13)
      {
         this._StoredSelectedEntry = this._FeaturedList_mc.CurrentButton.Item;
         if(this._StoredSelectedEntry != null)
         {
            this.codeObj.PlaySound("UIMenuOK");
            this.BeginState(CreationClubMenu.CC_DETAILS_STATE);
         }
         _loc3_ = true;
      }
      return _loc3_;
   }
   function HandleInputDetails(nav, keyCode)
   {
      trace("CreationClubMenu::HandleInputDetails " + nav);
      var _loc3_ = false;
      if(nav == gfx.ui.NavigationCode.ENTER || nav == gfx.ui.NavigationCode.GAMEPAD_A || keyCode == 13)
      {
         this.OnEnterButtonClick();
         _loc3_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.ESCAPE || nav == gfx.ui.NavigationCode.GAMEPAD_B || nav == gfx.ui.NavigationCode.TAB || keyCode == 9)
      {
         this.codeObj.PlaySound("UIMenuCancel");
         this.BeginState(CreationClubMenu.CC_CATEGORY_LIST_STATE);
         _loc3_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.GAMEPAD_X || keyCode == 88)
      {
         this.codeObj.PlaySound("UIMenuOK");
         this.codeObj.EnterCreditsScreen();
         _loc3_ = true;
      }
      return _loc3_;
   }
   function HandleInputPurchaseDialog(nav, keyCode)
   {
      trace("CreationClubMenu::HandleInputPurchaseDialog " + nav);
      var _loc3_ = false;
      var _loc4_;
      if(nav == gfx.ui.NavigationCode.ENTER || nav == gfx.ui.NavigationCode.GAMEPAD_A || keyCode == 13)
      {
         if(this.PurchaseDialog_mc.WillBuyOnAccept)
         {
            _loc4_ = this.Credits - this._StoredSelectedEntry.price;
            this.codeObj.PurchaseMod(_loc4_,this._StoredSelectedEntry);
            this.codeObj.PlaySound("UISkillNewShoutLearned");
            this._AcceptInput = false;
         }
         else
         {
            this.codeObj.PlaySound("UIMenuCancel");
            this.BeginState(CreationClubMenu.CC_DETAILS_STATE);
            _loc3_ = true;
         }
         _loc3_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.ESCAPE || nav == gfx.ui.NavigationCode.GAMEPAD_B || nav == gfx.ui.NavigationCode.TAB || keyCode == 9)
      {
         this.codeObj.PlaySound("UIMenuCancel");
         this.BeginState(CreationClubMenu.CC_DETAILS_STATE);
         _loc3_ = true;
      }
      return _loc3_;
   }
   function onExit()
   {
      trace("CreationClubMenu::onExit");
      this._AcceptInput = false;
      this.codeObj.confirmCloseManager();
   }
   function OnLoginLoadInit(mc)
   {
      trace("CreationClubMenu::OnLoginLoadInit");
      mc._visible = false;
      mc.onEnterFrame = Shared.Proxy.create(this,this.OnLoginLoadInitFinished,mc);
   }
   function OnLoginLoadInitFinished(mc)
   {
      trace("CreationClubMenu::OnLoginLoadInitFinished");
      if(this._LoginHolder_mc.LoginMenu_mc.Constructed)
      {
         this._LoginHolder_mc.onEnterFrame = null;
         this._LoginHolder_mc._visible = false;
         this._LoginMenu = this._LoginHolder_mc.LoginMenu_mc;
         this._LoginMenu.ShowLoadOrderButton = false;
         this._LoginMenu.InitView();
         this._LoginMenu.CodeObject = this.codeObj;
         this._LoginMenu.SetPlatform(this.iPlatform,this.PS3Switch);
         this._LoginMenu.SetBottomButtons(this._BottomButtons_mc);
         this._LoginMenu.addEventListener(BethesdaNetLogin.LOGIN_ACTIVATED,Shared.Proxy.create(this,this.onLoginActivated));
         this._LoginMenu.addEventListener(BethesdaNetLogin.LOGIN_CANCELED,Shared.Proxy.create(this,this.onLoginCanceled));
         this._LoginMenu.addEventListener(BethesdaNetLogin.LOGIN_ERROR,Shared.Proxy.create(this,this.onLoginError));
         this._LoginMenu.addEventListener(BethesdaNetLogin.EULA_CANCELED,Shared.Proxy.create(this,this.onEULACanceled));
         this.codeObj.InitCreationClubMenu(this,this._LoginMenu,this.Library);
      }
   }
   function onBackgroundTexturesLoaded()
   {
      trace("CreationClubMenu::onBackgroundTexturesLoaded");
      this.BGLoader.loadClip("img://CC_Background",this.CategoryList_mc.BGTextureHolder);
      this.BGLoader.loadClip("img://CC_Details",this.Details_mc.BGTextureHolder);
   }
   function onLoadInit(aTargetClip)
   {
      trace("CreationClubMenu::onLoadInit");
      aTargetClip._width = 1493.3;
      aTargetClip._height = 840;
   }
   function onDontCloseManager()
   {
      trace("CreationClubMenu::onDontCloseManager");
      this._AcceptInput = true;
   }
   function onConfirmCloseManager()
   {
      trace("CreationClubMenu::onConfirmCloseManager");
      this.codeObj.attemptCloseManager();
      this.BeginState(CreationClubMenu.CC_CLOSING_STATE);
   }
   function UpdateScrollMarkers()
   {
      if(this.CategoryList_mc.ScrollUp != null)
      {
         this.CategoryList_mc.ScrollUp._visible = this._FeaturedList_mc.CanScrollLeft();
      }
      if(this.CategoryList_mc.ScrollDown != null)
      {
         this.CategoryList_mc.ScrollDown._visible = this._FeaturedList_mc.CanScrollRight();
      }
   }
   function onLoginActivated(event)
   {
      trace("CreationClubMenu::onLoginActivated");
      this.BeginState(CreationClubMenu.LOGIN_STATE);
   }
   function onLoginCanceled(event)
   {
      trace("CreationClubMenu::onLoginCanceled");
      if(this.CurrentState == CreationClubMenu.LOGIN_STATE)
      {
         this.onExit();
      }
   }
   function onLoginError(event)
   {
      trace("CreationClubMenu::onLoginError");
      this._LoggedIn = false;
   }
   function onEULACanceled(event)
   {
      trace("CreationClubMenu::onEULACanceled");
      this.onExit();
   }
   function BeginState(state)
   {
      trace("CreationClubMenu::BeginState " + state);
      if(this.CurrentState == state)
      {
         return undefined;
      }
      this.EndState(this.CurrentState);
      this.PreviousState = this.CurrentState;
      this.CurrentState = state;
      switch(this.CurrentState)
      {
         case CreationClubMenu.LOGIN_STATE:
            this._BottomButtons_mc.Hide(false);
            this.CCButtons_mc.Hide(true);
            this.DisplayScreen(this._LoginHolder_mc);
            this.Tabs_mc._visible = false;
            return;
         case CreationClubMenu.CC_CATEGORY_LIST_STATE:
            if(this._DataArray[this._CurrScrollPage].entries.length == 0)
            {
               this.ScrollDownFilter();
               if(this._DataArray[this._CurrScrollPage].entries.length == 0)
               {
                  this.ScrollUpFilter();
               }
            }
            this.DisplayScreen(this.CategoryList_mc);
            this.UpdateScrollMarkers();
            this._FeaturedList_mc.Focus();
            this._FeaturedList_mc.SetFeaturedItems(this._DataArray[this._CurrScrollPage].entries,this.PreviousState != CreationClubMenu.CC_DETAILS_STATE);
            this.Tabs_mc.SetLabels(this._DataArray);
            this.Tabs_mc.SetTab(this._CurrScrollPage);
            this.UpdateButtons();
            this.Tabs_mc.LockInput(false);
            return;
         case CreationClubMenu.CC_DETAILS_STATE:
            this.DisplayScreen(this.Details_mc);
            this.InitDetailsDisplay();
            this.Tabs_mc.LockInput(true);
            if(this.PreviousState != CreationClubMenu.CC_PURCHASE_CREATION_STATE)
            {
               this.HaveCreationDetails = false;
               this.codeObj.EnterDetailsScreen(this._StoredSelectedEntry.contentId);
               this.Details_mc.ResetScreen();
            }
            this.Details_mc.SetFocus(true);
            return;
         case CreationClubMenu.CC_PURCHASE_CREATION_STATE:
            this.ShowPurchaseMod();
            this.PurchaseDialog_mc._visible = true;
            Selection.setFocus(this.PurchaseDialog_mc);
            return;
         case CreationClubMenu.CC_CLOSING_STATE:
            this.DisplayScreen(null);
            Selection.setFocus(null);
            this._AcceptInput = false;
            return;
         default:
            trace("CreationClubMenu::BeginState unsupported state:" + state);
            return;
      }
   }
   function EndState()
   {
      trace("CreationClubMenu::EndState " + this.CurrentState);
      switch(this.CurrentState)
      {
         case CreationClubMenu.LOGIN_STATE:
            this._BottomButtons_mc.Hide(true);
            this.CCButtons_mc.Hide(false);
            this.Tabs_mc._visible = true;
            break;
         case CreationClubMenu.CC_DETAILS_STATE:
            this.Details_mc.SetFocus(false);
            break;
         case CreationClubMenu.CC_PURCHASE_CREATION_STATE:
            this.PurchaseDialog_mc._visible = false;
            this._AcceptInput = true;
            break;
         case CreationClubMenu.CC_CLOSING_STATE:
            this._AcceptInput = true;
         default:
            return;
      }
   }
   function DisplayScreen(mc)
   {
      trace("CreationClubMenu::DisplayScreen");
      this._Header_mc._visible = this._LoginHolder_mc != mc && mc != null;
      if(this.SupportsPurchase())
      {
         this._Wallet_mc._visible = this._LoginHolder_mc != mc && mc != null;
      }
      else
      {
         this._Wallet_mc._visible = false;
      }
      this.Search_mc._visible = this._LoginHolder_mc != mc && mc != null;
      this.Bars_mc._visible = this._LoginHolder_mc != mc && mc != null;
      this.Tabs_mc._visible = this._LoginHolder_mc != mc && mc != null;
      this._LoginHolder_mc._visible = this._LoginHolder_mc == mc;
      this.CategoryList_mc._visible = this.CategoryList_mc == mc;
      this.Details_mc._visible = this.Details_mc == mc;
   }
   function CanPurchaseSelectedItem()
   {
      return this._StoredSelectedEntry != null && (!this._StoredSelectedEntry.owned && this.Credits - this._StoredSelectedEntry.price >= 0) && this.HaveCreationDetails;
   }
   function CanDownloadSelectedItem()
   {
      return this._StoredSelectedEntry != null && this._StoredSelectedEntry.owned && (!this._StoredSelectedEntry.installed && this._StoredSelectedEntry.downloadProgress == undefined && !this._StoredSelectedEntry.installQueued || this._StoredSelectedEntry.needsUpdate) && this.HaveCreationDetails;
   }
   function InitDetailsDisplay()
   {
      trace("CreationClubMenu::InitDetailsDisplay");
      this.Details_mc.Item = this._StoredSelectedEntry;
      this.Details_mc.HideErrorText();
      this.Details_mc.UpdateLeftRightScroll();
      this.UpdateButtons();
   }
   function ScrollUpFilter()
   {
      var _loc2_ = this._CurrScrollPage - 1;
      while(_loc2_ >= 0 && this._DataArray[_loc2_].entries.length == 0)
      {
         _loc2_ = _loc2_ - 1;
      }
      if(_loc2_ >= 0 && _loc2_ != this._CurrScrollPage)
      {
         this._CurrScrollPage = _loc2_;
         this._FeaturedList_mc.SetFeaturedItems(this._DataArray[_loc2_].entries,true);
         this.Tabs_mc.SetTab(_loc2_);
         this.UpdateScrollMarkers();
      }
   }
   function ScrollDownFilter()
   {
      var _loc2_ = this._CurrScrollPage + 1;
      while(_loc2_ < this._DataArray.length && this._DataArray[_loc2_].entries.length == 0)
      {
         _loc2_ = _loc2_ + 1;
      }
      if(_loc2_ < this._DataArray.length && _loc2_ != this._CurrScrollPage)
      {
         this._CurrScrollPage = _loc2_;
         this._FeaturedList_mc.SetFeaturedItems(this._DataArray[_loc2_].entries,true);
         this.Tabs_mc.SetTab(_loc2_);
         this.UpdateScrollMarkers();
      }
   }
   function ScrollUpFeatured()
   {
      this._FeaturedList_mc.DoHandleInput(gfx.ui.NavigationCode.LEFT,37);
      this.UpdateScrollMarkers();
   }
   function ScrollDownFeatured()
   {
      this._FeaturedList_mc.DoHandleInput(gfx.ui.NavigationCode.RIGHT,39);
      this.UpdateScrollMarkers();
   }
   function onMouseWheel(delta)
   {
      var _loc2_ = false;
      if(this.CurrentState == CreationClubMenu.CC_CATEGORY_LIST_STATE)
      {
         _loc2_ = true;
         if(delta < 0)
         {
            this.ScrollDownFeatured();
         }
         else if(delta > 0)
         {
            this.ScrollUpFeatured();
         }
      }
      return _loc2_;
   }
   function OnScrollUpClick()
   {
      this.ScrollUpFeatured();
   }
   function OnScrollDownClick()
   {
      this.ScrollDownFeatured();
   }
   function onVKBTextEntered(astrEnteredText)
   {
      trace("CreationClubMenu::onVKBTextEntered " + astrEnteredText);
      if(this.CurrentState == CreationClubMenu.LOGIN_STATE)
      {
         this._LoginMenu.onVKBTextEntered(astrEnteredText);
      }
   }
   function onModItemPress(event)
   {
      trace("CreationClubMenu::onModItemPress");
      this._StoredSelectedEntry = undefined;
      if(event.target == this._FeaturedList_mc)
      {
         this._StoredSelectedEntry = this._FeaturedList_mc.CurrentButton.Item;
      }
      if(this._StoredSelectedEntry != null)
      {
         this.codeObj.PlaySound("UIMenuOK");
         this.BeginState(CreationClubMenu.CC_DETAILS_STATE);
      }
   }
   function onTabPress(event)
   {
      trace("CreationClubMenu::onTabPress");
      if(event.target == this.Tabs_mc && this.CurrentState == CreationClubMenu.CC_CATEGORY_LIST_STATE)
      {
         this._CurrScrollPage = this.Tabs_mc.Index;
         this._FeaturedList_mc.SetFeaturedItems(this._DataArray[this._CurrScrollPage].entries,true);
         this.UpdateScrollMarkers();
      }
   }
   function onPlaySound(event, scope)
   {
      this.codeObj.PlaySound(event.sound);
   }
   function OnFocusSoundEvent()
   {
      this.codeObj.PlaySound("UIMenuFocus");
   }
   function onListRollover(event, scope)
   {
      if(scope == this._FeaturedList_mc)
      {
         this._StoredSelectedEntry = this._FeaturedList_mc.CurrentButton.Item;
         this.UpdateScrollMarkers();
      }
      this.OnFocusSoundEvent();
   }
   function OnBottomButtonClicked(event)
   {
      var _loc2_ = event.data;
      this.DoHandleInput(null,_loc2_.KeyCode,true);
   }
   function onLoadThumbnail(event)
   {
      this.codeObj.LoadThumbnail(event.data);
   }
   function onUnregisterImage(event)
   {
      this.codeObj.UnregisterImage(event.data);
   }
   function onDisplayImage(event)
   {
      trace("CreationClubMenu::onDisplayImage");
      this.codeObj.onDisplayImage(event.data);
   }
   function ShowPurchaseMod()
   {
      this.InitDetailsDisplay();
      this.PurchaseDialog_mc.Item = this._StoredSelectedEntry;
   }
   function OnPurchaseCredits(event)
   {
      this.codeObj.PlaySound("UIMenuOK");
      this.codeObj.EnterCreditsScreen();
   }
   function onEulaAccepted()
   {
      trace("CreationClubMenu::onEulaAccepted");
      this._LoginMenu.ShowSpinner("$Waiting for data...");
   }
   function ShowDetailsPageError(astrErrorText)
   {
      trace("CreationClubMenu::ShowDetailsPageError " + astrErrorText);
      if(this.Details_mc._visible)
      {
         this.Details_mc.ShowError(astrErrorText);
      }
   }
   function BackToLogin()
   {
      this.BeginState(CreationClubMenu.LOGIN_STATE);
   }
   function OnEnterButtonClick()
   {
      trace("CreationClubMenu::OnEnterButtonClick");
      if(this.CanPurchaseSelectedItem())
      {
         if(this.SupportsPurchase())
         {
            this.BeginState(CreationClubMenu.CC_PURCHASE_CREATION_STATE);
            this.codeObj.PlaySound("UISkillsStop");
         }
      }
      else if(this.CanDownloadSelectedItem())
      {
         this.codeObj.DownloadCreation(this._StoredSelectedEntry);
         this.codeObj.PlaySound("UIMenuOK");
      }
      else
      {
         this.codeObj.PlaySound("UIMenuOK");
      }
   }
   function OnTabLeft()
   {
      this.codeObj.PlaySound("UIMenuBladeCloseSD");
   }
   function OnTabRight()
   {
      this.codeObj.PlaySound("UIMenuBladeOpenSD");
   }
   function OnPurchaseDialogBuyClicked()
   {
      this.DoHandleInput(null,13,true);
   }
   function OnPurchaseDialogCancelClicked()
   {
      this.DoHandleInput(null,9,true);
   }
   function UpdateButtons()
   {
      trace("CreationClubMenu::UpdateButtons");
      var _loc2_ = new Array();
      if(this.CurrentState == CreationClubMenu.CC_CATEGORY_LIST_STATE)
      {
         _loc2_.push(CreationClubMenu.DETAILS);
      }
      var _loc4_ = false;
      var _loc5_;
      if(this.CurrentState == CreationClubMenu.CC_DETAILS_STATE)
      {
         _loc4_ = true;
         _loc5_ = _loc2_.length;
         if(this._StoredSelectedEntry.owned)
         {
            if(this._StoredSelectedEntry.needsUpdate)
            {
               _loc2_.push(CreationClubMenu.BUTTON_UPDATE_CREATION);
            }
            else
            {
               _loc2_.push(CreationClubMenu.BUTTON_DOWNLOAD_CREATION);
            }
         }
         else if(this.SupportsPurchase())
         {
            _loc2_.push(CreationClubMenu.PURCHASE_MOD);
         }
      }
      if(this.CurrentState != CreationClubMenu.LOGIN_STATE && this.CurrentState != CreationClubMenu.CC_PURCHASE_CREATION_STATE && this.CurrentState != CreationClubMenu.CC_CLOSING_STATE)
      {
         _loc2_.push(CreationClubMenu.BUTTON_DOWNLOAD_ALL);
         if(this.SupportsPurchase())
         {
            _loc2_.push(CreationClubMenu.PURCHASE_CREDITS);
         }
         _loc2_.push(CreationClubMenu.CANCEL);
      }
      this.CCButtons_mc.SetButtons(_loc2_);
      var _loc3_;
      if(_loc4_)
      {
         _loc3_ = this.CCButtons_mc.GetButtonByIndex(_loc5_);
         if(_loc3_ != null)
         {
            _loc3_.disabled = !this.CanPurchaseSelectedItem() && !this.CanDownloadSelectedItem();
            _loc3_.textField.autoSize = true;
         }
      }
   }
   function SupportsPurchase()
   {
      if(this.eLanguage == "DD")
      {
         return false;
      }
      if(this.eLanguage == "ja")
      {
         return false;
      }
      if(this.eLanguage == "zhhant")
      {
         return false;
      }
      return true;
   }
}
