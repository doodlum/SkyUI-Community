class StartMenu extends MovieClip
{
   var BottomButtons_mc;
   var ButtonRect;
   var ChangeUserButton;
   var CharacterSelectionHint;
   var ConfirmPanel_mc;
   var DLCList_mc;
   var DLCPanel;
   var DeleteButton;
   var DeleteMouseButton;
   var DeleteSaveButton;
   var Error_AgeRestrictOrbis;
   var Error_NeedUpdateOrbis;
   var Error_NotSignedInOrbis;
   var GamerIconLoader;
   var GamerIconRect;
   var GamerIconSize;
   var GamerIcon_mc;
   var GamerTagWidget_mc;
   var GamerTag_mc;
   var LoadingContentMessage;
   var LoginHolder_mc;
   var Logo_mc;
   var MainList;
   var MainListHolder;
   var MarketplaceButton;
   var MessageOfTheDay_mc;
   var SaveLoadConfirmText;
   var SaveLoadListHolder;
   var SaveLoadPanel_mc;
   var VersionText;
   var _BottomButtons_mc;
   var _Header_tf;
   var _LoginHolder_mc;
   var _LoginMenu;
   var _MessageOfTheDay_mc;
   var _Motd_tf;
   var _NeedsLoginScreen;
   var _Sky10UpSell;
   var _Sky10UpSellBG;
   var _Sky10UpSellText;
   var codeObj;
   var fadeOutParams;
   var hasContinueButton;
   var iLoadDLCContentMessageTimerID;
   var iLoadDLCListTimerID;
   var iPlatform;
   var onEnterFrame;
   var shouldProcessInputs;
   var strCurrentState;
   var strFadeOutCallback;
   static var PRESS_START_STATE = "PressStart";
   static var MAIN_STATE = "Main";
   static var MAIN_CONFIRM_STATE = "MainConfirm";
   static var CHARACTER_LOAD_STATE = "CharacterLoad";
   static var CHARACTER_SELECTION_STATE = "CharacterSelection";
   static var SAVE_LOAD_STATE = "SaveLoad";
   static var SAVE_LOAD_CONFIRM_STATE = "SaveLoadConfirm";
   static var DELETE_SAVE_CONFIRM_STATE = "DeleteSaveConfirm";
   static var DLC_STATE = "DLC";
   static var MARKETPLACE_CONFIRM_STATE = "MarketplaceConfirm";
   static var LOGIN_STATE = "Login";
   static var START_ANIM_STR = "StartAnim";
   static var END_ANIM_STR = "EndAnim";
   static var CONTINUE_INDEX = 0;
   static var NEW_INDEX = 1;
   static var LOAD_INDEX = 2;
   static var DLC_INDEX = 3;
   static var SKY10_UPSELL_INDEX = 4;
   static var CREATION_CLUB_INDEX = 5;
   static var DOWNLOAD_ALL_INDEX = 6;
   static var MOD_INDEX = 7;
   static var CREDITS_INDEX = 8;
   static var QUIT_INDEX = 9;
   static var HELP_INDEX = 10;
   static var PS5_DATA_TRANSFER_INDEX = 11;
   static var LOADING_ICON_OFFSET = 50;
   static var DISABLED_GREY_OUT_ALPHA = 50;
   var PS3Switch = false;
   var _codeObjInitialized = false;
   static var PLATFORM_PC_KBMOUSE = 0;
   static var PLATFORM_PC_GAMEPAD = 1;
   static var PLATFORM_DURANGO = 2;
   static var PLATFORM_ORBIS = 3;
   static var PLATFORM_SCARLETT = 4;
   static var PLATFORM_PROSPERO = 5;
   static var ALPHA_AVAILABLE = 100;
   static var ALPHA_DISABLED = 50;
   static var OUT_OF_THE_STAGE = -10000;
   var _Margin = 60;
   var _UserCanAccessCreationClub = true;
   var _CClubAllowedByBnet = true;
   var _ModsAllowedByBnet = true;
   function StartMenu()
   {
      super();
      this.hasContinueButton = false;
      this.MainList = this.MainListHolder.List_mc;
      this.SaveLoadListHolder = this.SaveLoadPanel_mc;
      this.DLCList_mc = this.DLCPanel.DLCList;
      this._LoginHolder_mc = this.LoginHolder_mc;
      this._Sky10UpSell = this.MainListHolder.Sky10SelectionHint_mc;
      this._Sky10UpSellText = this.MainListHolder.Sky10Text.EntrySky10;
      this._Sky10UpSellBG = this.MainListHolder.bg_Sky10;
      this.ShowSky10UpsellBanner(false);
      this.DeleteSaveButton = this.DeleteButton;
      this.ChangeUserButton = this.ChangeUserButton;
      this.MarketplaceButton = this.DLCPanel.MarketplaceButton;
      this.MarketplaceButton._visible = false;
      this._BottomButtons_mc = this.BottomButtons_mc;
      this._MessageOfTheDay_mc = this.MessageOfTheDay_mc;
      this._Header_tf = this._MessageOfTheDay_mc.Header_tf;
      this._Motd_tf = this._MessageOfTheDay_mc.Motd_tf;
      _root.CodeObj = this.codeObj = new Object();
      _root.ReleaseCodeObject = Shared.Proxy.create(this,this.ReleaseCodeObject);
      _root.onCodeObjectInit = Shared.Proxy.create(this,this.onCodeObjectInit);
      this.CharacterSelectionHint = this.SaveLoadListHolder.CharacterSelectionHint_mc;
      this.ShowCharacterSelectionHint(false);
      _root.Error_NotSignedInOrbis = this.Error_NotSignedInOrbis.text;
      _root.Error_AgeRestrictOrbis = this.Error_AgeRestrictOrbis.text;
      _root.Error_NeedUpdateOrbis = this.Error_NeedUpdateOrbis.text;
      this.Error_NotSignedInOrbis._x = StartMenu.OUT_OF_THE_STAGE;
      this.Error_AgeRestrictOrbis._x = StartMenu.OUT_OF_THE_STAGE;
      this.Error_NeedUpdateOrbis._x = StartMenu.OUT_OF_THE_STAGE;
      var _loc5_ = new Object();
      _loc5_.onLoadInit = Shared.Proxy.create(this,this.OnLoginLoadInit);
      var _loc4_ = new MovieClipLoader();
      _loc4_.addListener(_loc5_);
      _loc4_.loadClip("BethesdaNetLogin.swf",this._LoginHolder_mc);
      this._Header_tf.textAutoSize = "shrink";
      this.SetMotd("");
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function Init()
   {
      this._BottomButtons_mc.SetPlatform(this.iPlatform,this.PS3Switch);
      this._BottomButtons_mc.Margin = this._Margin;
      this.onEnterFrame = null;
   }
   function OnLoginLoadInit(mc)
   {
      mc._visible = false;
      mc.onEnterFrame = Shared.Proxy.create(this,this.OnLoginLoadInitFinished,mc);
   }
   function OnLoginLoadInitFinished(mc)
   {
      if(this._LoginHolder_mc.LoginMenu_mc.Constructed)
      {
         this._LoginHolder_mc.onEnterFrame = null;
         this._LoginHolder_mc._visible = this.strCurrentState == StartMenu.LOGIN_STATE;
         this._LoginMenu = this._LoginHolder_mc.LoginMenu_mc;
         this._LoginMenu.ShowLoadOrderButton = false;
         this._LoginMenu.InitView();
         this._LoginMenu.CodeObject = this.codeObj;
         this._LoginMenu.SetPlatform(this.iPlatform,this.PS3Switch);
         this._LoginMenu.SetBottomButtons(this._BottomButtons_mc);
         this._LoginMenu.addEventListener(BethesdaNetLogin.LOGIN_CANCELED,Shared.Proxy.create(this,this.onLoginCanceled));
         this._LoginMenu.addEventListener(BethesdaNetLogin.LOGIN_ERROR,Shared.Proxy.create(this,this.onLoginError));
         this.codeObj.initLogin(this,this._LoginMenu);
         if(this.strCurrentState == StartMenu.LOGIN_STATE)
         {
            this.codeObj.BeginLogin();
         }
         else
         {
            this.codeObj.GetBnetUpdate();
         }
      }
   }
   function onCodeObjectInit()
   {
      this._codeObjInitialized = true;
   }
   function ReleaseCodeObject()
   {
      this._LoginMenu.Destroy();
      delete this.codeObj;
      delete _root.CodeObj;
   }
   function InitExtensions()
   {
      Shared.GlobalFunc.SetLockFunction();
      this._parent.Lock("BR");
      this.Logo_mc.Lock("BL");
      this.Logo_mc._y -= 80;
      this.GamerTagWidget_mc.Lock("TL");
      this.GamerTag_mc = this.GamerTagWidget_mc.GamerTag_mc;
      this.GamerIcon_mc = this.GamerTagWidget_mc.GamerIcon_mc;
      this.GamerIconSize = this.GamerIcon_mc._width;
      this.GamerIconLoader = new MovieClipLoader();
      this.GamerIconLoader.addListener(this);
      gfx.io.GameDelegate.addCallBack("sendMenuProperties",this,"setupMainMenu");
      gfx.io.GameDelegate.addCallBack("ConfirmNewGame",this,"ShowConfirmScreen");
      gfx.io.GameDelegate.addCallBack("ConfirmContinue",this,"ShowConfirmScreen");
      gfx.io.GameDelegate.addCallBack("FadeOutMenu",this,"DoFadeOutMenu");
      gfx.io.GameDelegate.addCallBack("FadeInMenu",this,"DoFadeInMenu");
      gfx.io.GameDelegate.addCallBack("onProfileChange",this,"onProfileChange");
      gfx.io.GameDelegate.addCallBack("StartLoadingDLC",this,"StartLoadingDLC");
      gfx.io.GameDelegate.addCallBack("DoneLoadingDLC",this,"DoneLoadingDLC");
      gfx.io.GameDelegate.addCallBack("ShowGamerTagAndIcon",this,"ShowGamerTagAndIcon");
      gfx.io.GameDelegate.addCallBack("OnDeleteSaveUISanityCheck",this,"OnDeleteSaveUISanityCheck");
      gfx.io.GameDelegate.addCallBack("OnSaveDataEventLoadSUCCESS",this,"OnSaveDataEventLoadSUCCESS");
      gfx.io.GameDelegate.addCallBack("OnSaveDataEventLoadCANCEL",this,"OnSaveDataEventLoadCANCEL");
      gfx.io.GameDelegate.addCallBack("onStartButtonProcessFinished",this,"onStartButtonProcessFinished");
      this.MainList.addEventListener("itemPress",this,"onMainButtonPress");
      this.MainList.addEventListener("listPress",this,"onMainListPress");
      this.MainList.addEventListener("listMovedUp",this,"onMainListMoveUp");
      this.MainList.addEventListener("listMovedDown",this,"onMainListMoveDown");
      this.MainList.addEventListener("selectionChange",this,"onMainListMouseSelectionChange");
      this.ButtonRect.handleInput = function()
      {
         return false;
      };
      this.ButtonRect.AcceptMouseButton.addEventListener("click",this,"onAcceptMousePress");
      this.ButtonRect.CancelMouseButton.addEventListener("click",this,"onCancelMousePress");
      this.ButtonRect.AcceptMouseButton.SetPlatform(0,false);
      this.ButtonRect.CancelMouseButton.SetPlatform(0,false);
      this.SaveLoadListHolder.addEventListener("loadGameSelected",this,"ConfirmLoadGame");
      this.SaveLoadListHolder.addEventListener("saveListPopulated",this,"OnSaveListOpenSuccess");
      this.SaveLoadListHolder.addEventListener("saveListCharactersPopulated",this,"OnsaveListCharactersOpenSuccess");
      this.SaveLoadListHolder.addEventListener("saveListOnBatchAdded",this,"OnSaveListBatchAdded");
      this.SaveLoadListHolder.addEventListener("OnCharacterSelected",this,"OnCharacterSelected");
      this.SaveLoadListHolder.addEventListener("saveHighlighted",this,"onSaveHighlight");
      this.SaveLoadListHolder.addEventListener("OnSaveLoadPanelBackClicked",Shared.Proxy.create(this,this.OnSaveLoadPanelBackClicked));
      this.SaveLoadListHolder.List_mc.addEventListener("listPress",this,"onSaveLoadListPress");
      this.DeleteSaveButton._alpha = StartMenu.ALPHA_AVAILABLE;
      this.DeleteMouseButton._alpha = StartMenu.ALPHA_AVAILABLE;
      this.MarketplaceButton._alpha = StartMenu.ALPHA_DISABLED;
      this.DeleteSaveButton._x = - this.DeleteSaveButton.textField.textWidth - StartMenu.LOADING_ICON_OFFSET;
      this.DeleteMouseButton._x = this.DeleteSaveButton._x;
      this.ChangeUserButton._x = - this.ChangeUserButton.textField.textWidth - StartMenu.LOADING_ICON_OFFSET;
      this.DLCList_mc._visible = false;
      this.CharacterSelectionHint.addEventListener("OnMousePressCharacterChange",Shared.Proxy.create(this,this.OnMousePressCharacterChange));
   }
   function setupMainMenu()
   {
      var _loc10_ = 0;
      var _loc5_ = 1;
      var _loc6_ = 2;
      var _loc13_ = 3;
      var _loc7_ = 4;
      var _loc15_ = 5;
      var _loc12_ = 6;
      var _loc8_ = 7;
      var _loc9_ = 8;
      var _loc11_ = 9;
      var _loc14_ = 10;
      var _loc16_ = 11;
      var _loc4_ = StartMenu.NEW_INDEX;
      if(this.MainList.entryList.length > 0)
      {
         _loc4_ = this.MainList.centeredEntry.index;
      }
      this.MainList.ClearList();
      if(arguments[_loc5_])
      {
         this.hasContinueButton = true;
         this.MainList.entryList.push({text:"$CONTINUE",index:StartMenu.CONTINUE_INDEX,disabled:false});
         if(_loc4_ == StartMenu.NEW_INDEX)
         {
            _loc4_ = StartMenu.CONTINUE_INDEX;
         }
      }
      this.MainList.entryList.push({text:"$NEW",index:StartMenu.NEW_INDEX,disabled:false});
      this.MainList.entryList.push({text:"$LOAD",disabled:!arguments[_loc5_],index:StartMenu.LOAD_INDEX});
      if(arguments[_loc16_] && this.iPlatform == StartMenu.PLATFORM_PROSPERO)
      {
         this.MainList.entryList.push({text:"$TRANSFER DATA",index:StartMenu.PS5_DATA_TRANSFER_INDEX,disabled:false});
      }
      if(arguments[_loc15_] == true)
      {
         this.MainList.entryList.push({text:"$DOWNLOADABLE CONTENT",index:StartMenu.DLC_INDEX,disabled:false});
      }
      if(arguments[_loc9_])
      {
         this.MainList.entryList.push({text:"$CREATION CLUB",disabled:false,index:StartMenu.CREATION_CLUB_INDEX});
      }
      this.ShowSky10UpsellBanner(false);
      if(arguments[_loc7_] == true)
      {
         this.ShowSky10UpsellBanner(true);
      }
      if(!arguments[_loc14_])
      {
      }
      if(arguments[_loc8_])
      {
         this.MainList.entryList.push({text:"$MOD MANAGER",disabled:false,index:StartMenu.MOD_INDEX});
      }
      this.MainList.entryList.push({text:"$CREDITS",index:StartMenu.CREDITS_INDEX,disabled:false});
      if(arguments[_loc10_])
      {
         this.MainList.entryList.push({text:"$QUIT",index:StartMenu.QUIT_INDEX,disabled:false});
      }
      if(arguments[_loc12_])
      {
         this.MainList.entryList.push({text:"$HELP",index:StartMenu.HELP_INDEX,disabled:false});
      }
      var _loc3_ = 0;
      while(_loc3_ < this.MainList.entryList.length)
      {
         if(this.MainList.entryList[_loc3_].index == _loc4_)
         {
            this.MainList.RestoreScrollPosition(_loc3_,false);
         }
         _loc3_ = _loc3_ + 1;
      }
      this.MainList.InvalidateData();
      this._NeedsLoginScreen = !arguments[_loc11_];
      if(this.currentState == undefined)
      {
         if(arguments[_loc13_])
         {
            this.StartState(StartMenu.PRESS_START_STATE);
         }
         else if(this._NeedsLoginScreen)
         {
            this.StartState(StartMenu.LOGIN_STATE);
         }
         else
         {
            this.StartState(StartMenu.MAIN_STATE);
         }
      }
      else if(this.currentState == StartMenu.SAVE_LOAD_STATE || this.currentState == StartMenu.SAVE_LOAD_CONFIRM_STATE || this.currentState == StartMenu.DELETE_SAVE_CONFIRM_STATE)
      {
         this.StartState(StartMenu.MAIN_STATE);
      }
      if(arguments[_loc6_] != undefined)
      {
         this.VersionText.SetText("v " + arguments[_loc6_]);
      }
      else
      {
         this.VersionText.SetText(" ");
      }
   }
   function ShowGamerTagAndIcon(strGamerTag)
   {
      if(strGamerTag.length > 0)
      {
         Shared.GlobalFunc.MaintainTextFormat();
         this.GamerTag_mc.GamerTagText_tf.text = strGamerTag;
         this.GamerTag_mc.visible = true;
         this.GamerIconRect = this.GamerIcon_mc.createEmptyMovieClip("GamerIconRect",this.getNextHighestDepth());
         this.GamerIconLoader.loadClip("img://BGSUserIcon",this.GamerIconRect);
      }
      else
      {
         this.GamerTag_mc.visible = false;
         this.GamerIcon_mc.visible = false;
      }
   }
   function onLoadInit(aTargetClip)
   {
      aTargetClip._width = this.GamerIconSize;
      aTargetClip._height = this.GamerIconSize;
   }
   function OnDeleteSaveUISanityCheck(aHasRecentSave, aCanLoadGame)
   {
      var _loc7_ = false;
      if(this.hasContinueButton)
      {
         if(!aHasRecentSave)
         {
            if(this.MainList.entryList[0].index == StartMenu.CONTINUE_INDEX)
            {
               this.MainList.entryList.shift();
            }
            this.MainList.RestoreScrollPosition(1,true);
            _loc7_ = true;
         }
      }
      var _loc2_;
      if(!aCanLoadGame)
      {
         _loc2_ = 0;
         while(_loc2_ < this.MainList.maxEntries)
         {
            if(this.MainList.entryList[_loc2_].index == StartMenu.LOAD_INDEX)
            {
               this.MainList.entryList.splice(_loc2_,1,{text:"$LOAD",disabled:true,index:StartMenu.LOAD_INDEX,textColor:6316128});
               _loc7_ = true;
               this.MainList.RestoreScrollPosition(0,false);
               break;
            }
            _loc2_ = _loc2_ + 1;
         }
      }
      if(_loc7_)
      {
         this.MainList.InvalidateData();
      }
   }
   function ShowCharacterSelectionHint(abFlag)
   {
      this.CharacterSelectionHint._visible = false;
   }
   function ShowSky10UpsellBanner(abFlag)
   {
      this._Sky10UpSellText.SetText("$Skyrim 10th Anniversary Available Now!");
      this._Sky10UpSell._visible = abFlag;
      this._Sky10UpSellText._visible = abFlag;
      this._Sky10UpSellBG._visible = abFlag;
   }
   function OnSaveDataEventLoadSUCCESS()
   {
      this.ShowCharacterSelectionHint(false);
      if(this.IsPlatformSony())
      {
         this.onCancelPress();
      }
   }
   function OnSaveDataEventLoadCANCEL()
   {
      if(this.IsPlatformSony())
      {
         this.RequestCharacterListLoad();
      }
   }
   function get currentState()
   {
      return this.strCurrentState;
   }
   function set currentState(strNewState)
   {
      gfx.io.GameDelegate.call("currentState",[strNewState]);
      if(strNewState == StartMenu.MAIN_STATE)
      {
         this.MainList.disableSelection = false;
      }
      if(strNewState != this.strCurrentState)
      {
         this.ShouldProcessInputs = true;
      }
      if(this.IsPlatformSony())
      {
         this.ShowDeleteButtonHelp(strNewState == StartMenu.CHARACTER_SELECTION_STATE);
      }
      else
      {
         this.ShowDeleteButtonHelp(strNewState == StartMenu.SAVE_LOAD_STATE);
      }
      this.ShowChangeUserButtonHelp(strNewState == StartMenu.MAIN_STATE);
      this.ShowCharacterSelectionHint(strNewState == StartMenu.SAVE_LOAD_STATE);
      this.SaveLoadListHolder.ShowSelectionButtons(strNewState == StartMenu.SAVE_LOAD_STATE || strNewState == StartMenu.CHARACTER_SELECTION_STATE);
      this.strCurrentState = strNewState;
      this.ChangeStateFocus(strNewState);
   }
   function get ShouldProcessInputs()
   {
      return this.shouldProcessInputs;
   }
   function set ShouldProcessInputs(abFlag)
   {
      this.shouldProcessInputs = abFlag;
   }
   function handleInput(details, pathToFocus)
   {
      var _loc5_;
      var _loc4_;
      var _loc3_;
      if(this.IsPlatformSony() && this.currentState == StartMenu.PRESS_START_STATE)
      {
         if(Shared.GlobalFunc.IsKeyPressed(details))
         {
            gfx.io.GameDelegate.call("EndPressStartState",[]);
         }
      }
      else if(pathToFocus.length > 0 && !pathToFocus[0].handleInput(details,pathToFocus.slice(1)))
      {
         if(Shared.GlobalFunc.IsKeyPressed(details) && this.ShouldProcessInputs)
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
            {
               this.onAcceptPress();
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
            {
               this.onCancelPress();
            }
            else if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 88) && this.DeleteSaveButton._visible && this.DeleteSaveButton._alpha == StartMenu.ALPHA_AVAILABLE)
            {
               if(this.IsPlatformSony())
               {
                  _loc5_ = this.SaveLoadListHolder.selectedEntry;
                  if(_loc5_ != undefined)
                  {
                     _loc4_ = _loc5_.flags;
                     if(_loc4_ == undefined)
                     {
                        _loc4_ = 0;
                     }
                     _loc3_ = _loc5_.id;
                     if(_loc3_ == undefined)
                     {
                        _loc3_ = 4294967295;
                     }
                  }
                  gfx.io.GameDelegate.call("ORBISDeleteSave",[_loc3_,_loc4_]);
               }
               else
               {
                  this.ConfirmDeleteSave();
               }
            }
            else if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y || details.code == 84) && this.strCurrentState == StartMenu.SAVE_LOAD_STATE && !this.SaveLoadListHolder.isSaving)
            {
               gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
               this.EndState();
            }
            else if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 88) && this.currentState == StartMenu.MAIN_STATE)
            {
               gfx.io.GameDelegate.call("Sky10DLCPressed",[]);
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y && this.currentState == StartMenu.DLC_STATE && this.MarketplaceButton._visible && this.MarketplaceButton._alpha == StartMenu.ALPHA_AVAILABLE)
            {
               this.SaveLoadConfirmText.textField.SetText("$Open Xbox LIVE Marketplace?");
               this.SetPlatform(this.iPlatform);
               this.StartState(StartMenu.MARKETPLACE_CONFIRM_STATE);
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y && this.currentState == StartMenu.MAIN_STATE && this.ChangeUserButton._visible)
            {
               gfx.io.GameDelegate.call("ChangeUser",[]);
            }
         }
      }
      return true;
   }
   function onMouseButtonDeleteSaveClick()
   {
      if(this.DeleteSaveButton._alpha == StartMenu.ALPHA_AVAILABLE)
      {
         this.ConfirmDeleteSave();
      }
   }
   function onMouseButtonDeleteRollOver()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
   }
   function onStartButtonProcessFinished()
   {
      this.EndState(StartMenu.PRESS_START_STATE);
   }
   function onAcceptPress()
   {
      switch(this.strCurrentState)
      {
         case StartMenu.MAIN_CONFIRM_STATE:
            if(this.MainList.selectedEntry.index == StartMenu.NEW_INDEX)
            {
               gfx.io.GameDelegate.call("PlaySound",["UIStartNewGame"]);
               this.FadeOutAndCall("StartNewGame");
            }
            else if(this.MainList.selectedEntry.index == StartMenu.CONTINUE_INDEX)
            {
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               this.FadeOutAndCall("ContinueLastSavedGame");
            }
            else if(this.MainList.selectedEntry.index == StartMenu.QUIT_INDEX)
            {
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               gfx.io.GameDelegate.call("QuitToDesktop",[]);
            }
            break;
         case StartMenu.CHARACTER_SELECTION_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
            break;
         case StartMenu.SAVE_LOAD_CONFIRM_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
            this.FadeOutAndCall("LoadGame",[this.SaveLoadListHolder.selectedIndex]);
            break;
         case StartMenu.DELETE_SAVE_CONFIRM_STATE:
            this.SaveLoadListHolder.DeleteSelectedSave();
            if(this.SaveLoadListHolder.numSaves == 0)
            {
               gfx.io.GameDelegate.call("DoDeleteSaveUISanityCheck",[]);
               this.StartState(StartMenu.MAIN_STATE);
            }
            else
            {
               this.EndState();
            }
            break;
         case StartMenu.MARKETPLACE_CONFIRM_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
            gfx.io.GameDelegate.call("OpenMarketplace",[]);
            this.StartState(StartMenu.MAIN_STATE);
         default:
            return;
      }
   }
   function isConfirming()
   {
      return this.strCurrentState == StartMenu.SAVE_LOAD_CONFIRM_STATE || this.strCurrentState == StartMenu.DELETE_SAVE_CONFIRM_STATE || this.strCurrentState == StartMenu.MARKETPLACE_CONFIRM_STATE || this.strCurrentState == StartMenu.MAIN_CONFIRM_STATE;
   }
   function onAcceptMousePress()
   {
      if(this.isConfirming())
      {
         this.onAcceptPress();
      }
   }
   function OnMousePressCharacterChange(evt)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
      this.EndState();
   }
   function onCancelMousePress()
   {
      if(this.isConfirming())
      {
         this.onCancelPress();
      }
   }
   function onCancelPress()
   {
      switch(this.strCurrentState)
      {
         case StartMenu.SAVE_LOAD_STATE:
            this.currentState = StartMenu.CHARACTER_SELECTION_STATE;
            this.EndState();
            this.SaveLoadListHolder.ForceStopLoading();
            this.SaveLoadListHolder.RemoveScreenshot();
            break;
         case StartMenu.CHARACTER_SELECTION_STATE:
         case StartMenu.MAIN_CONFIRM_STATE:
         case StartMenu.SAVE_LOAD_CONFIRM_STATE:
         case StartMenu.DELETE_SAVE_CONFIRM_STATE:
         case StartMenu.DLC_STATE:
         case StartMenu.MARKETPLACE_CONFIRM_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
            this.EndState();
         default:
            return;
      }
   }
   function onMainButtonPress(event)
   {
      if(this.strCurrentState == StartMenu.MAIN_STATE || this.iPlatform == 0)
      {
         switch(event.entry.index)
         {
            case StartMenu.CONTINUE_INDEX:
               gfx.io.GameDelegate.call("CONTINUE",[]);
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
            case StartMenu.NEW_INDEX:
               gfx.io.GameDelegate.call("NEW",[]);
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
            case StartMenu.QUIT_INDEX:
               this.ShowConfirmScreen("$Quit to desktop?  Any unsaved progress will be lost.");
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
            case StartMenu.LOAD_INDEX:
               if(!event.entry.disabled)
               {
                  this.SaveLoadListHolder.isSaving = false;
                  this.RequestCharacterListLoad();
                  return;
               }
               gfx.io.GameDelegate.call("OnDisabledLoadPress",[]);
               return;
               break;
            case StartMenu.PS5_DATA_TRANSFER_INDEX:
               gfx.io.GameDelegate.call("OnPS5DataTransfer",[]);
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
            case StartMenu.DLC_INDEX:
               this.StartState(StartMenu.DLC_STATE);
               return;
            case StartMenu.CREDITS_INDEX:
               this._MessageOfTheDay_mc.visible = false;
               this.FadeOutAndCall("OpenCreditsMenu");
               return;
            case StartMenu.HELP_INDEX:
               gfx.io.GameDelegate.call("HELP",[]);
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
            case StartMenu.MOD_INDEX:
               if(this._ModsAllowedByBnet)
               {
                  this._MessageOfTheDay_mc.visible = false;
                  gfx.io.GameDelegate.call("MOD",[]);
                  gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
                  return;
               }
               this.codeObj.ModsBlockedByBnet();
               gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
               return;
               break;
            case StartMenu.SKY10_UPSELL_INDEX:
               gfx.io.GameDelegate.call("Sky10DLCPressed",[]);
               return;
            case StartMenu.CREATION_CLUB_INDEX:
               if(this._CClubAllowedByBnet)
               {
                  if(this._UserCanAccessCreationClub)
                  {
                     this._MessageOfTheDay_mc.visible = false;
                     gfx.io.GameDelegate.call("CreationClub",[]);
                     gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
                     return;
                  }
                  this.codeObj.CClubBlockedByPermissions();
                  gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
                  return;
               }
               this.codeObj.CClubBlockedByBnet();
               gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
               return;
               break;
            case StartMenu.DOWNLOAD_ALL_INDEX:
               if(!event.entry.disabled)
               {
                  gfx.io.GameDelegate.call("DownloadAll",[]);
               }
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
            default:
               gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
               return;
         }
      }
   }
   function RequestCharacterListLoad()
   {
      gfx.io.GameDelegate.call("PopulateCharacterList",[this.SaveLoadListHolder.List_mc.entryList,this.SaveLoadListHolder.batchSize]);
      this.StartState(StartMenu.CHARACTER_LOAD_STATE);
   }
   function onMainListPress(event)
   {
      this.onCancelPress();
   }
   function onPCQuitButtonPress(event)
   {
      if(event.index == 0)
      {
         gfx.io.GameDelegate.call("QuitToMainMenu",[]);
      }
      else if(event.index == 1)
      {
         gfx.io.GameDelegate.call("QuitToDesktop",[]);
      }
   }
   function onSaveLoadListPress()
   {
      this.onAcceptPress();
   }
   function onMainListMoveUp(event)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      if(event.scrollChanged == true)
      {
         this.MainList._parent.gotoAndPlay("moveUp");
      }
   }
   function onMainListMoveDown(event)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      if(event.scrollChanged == true)
      {
         this.MainList._parent.gotoAndPlay("moveDown");
      }
   }
   function onMainListMouseSelectionChange(event)
   {
      if(event.keyboardOrMouse == 0 && event.index != -1)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      }
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.ButtonRect.AcceptGamepadButton._visible = aiPlatform != 0;
      this.ButtonRect.CancelGamepadButton._visible = aiPlatform != 0;
      this.ButtonRect.AcceptMouseButton._visible = aiPlatform == 0;
      this.ButtonRect.CancelMouseButton._visible = aiPlatform == 0;
      this._Sky10UpSell.SetPlatform(aiPlatform,abPS3Switch);
      var _loc4_ = this.DeleteSaveButton._visible;
      if(aiPlatform == StartMenu.PLATFORM_PC_KBMOUSE)
      {
         this.DeleteSaveButton._visible = false;
         this.DeleteMouseButton.label = this.DeleteSaveButton.label;
         this.DeleteMouseButton._x = this.DeleteButton._x;
         this.DeleteMouseButton.trackAsMenu = true;
         this.DeleteSaveButton = this.DeleteMouseButton;
         this.DeleteSaveButton.onPress = Shared.Proxy.create(this,this.onMouseButtonDeleteSaveClick);
         this.DeleteSaveButton.addEventListener("rollOver",Shared.Proxy.create(this,this.onMouseButtonDeleteRollOver));
      }
      else if(aiPlatform == StartMenu.PLATFORM_PC_GAMEPAD && this.DeleteSaveButton == this.DeleteMouseButton)
      {
         this.DeleteSaveButton._visible = false;
         this.DeleteSaveButton = this.DeleteButton;
         this.DeleteSaveButton.onPress = undefined;
         this.DeleteMouseButton.removeEventListeners("rollOver",Shared.Proxy.create(this,this.onMouseButtonDeleteRollOver));
      }
      else
      {
         this.DeleteMouseButton._visible = false;
      }
      this.ShowDeleteButtonHelp(_loc4_);
      this.DeleteSaveButton.SetPlatform(aiPlatform,abPS3Switch);
      this.ChangeUserButton.SetPlatform(aiPlatform,abPS3Switch);
      this.MarketplaceButton.SetPlatform(aiPlatform,abPS3Switch);
      this.MainListHolder.SelectionArrow._visible = aiPlatform != 0;
      if(aiPlatform != 0)
      {
         this.ButtonRect.AcceptGamepadButton.SetPlatform(aiPlatform,abPS3Switch);
         this.ButtonRect.CancelGamepadButton.SetPlatform(aiPlatform,abPS3Switch);
      }
      this.CharacterSelectionHint.SetPlatform(aiPlatform);
      this.MarketplaceButton._visible = false;
      if(this.iPlatform == undefined)
      {
         this.DLCPanel.warningText.SetText("$Loading downloadable content..." + (!this.IsPlatformSony() ? "" : "_PS3"));
         this.LoadingContentMessage.Message_mc.textField.SetText("$Loading extra content." + (!this.IsPlatformSony() ? "" : "_PS3"));
      }
      this.iPlatform = aiPlatform;
      this.SaveLoadListHolder.platform = this.iPlatform;
      this.PS3Switch = abPS3Switch;
      this.MainList.SetPlatform(aiPlatform,abPS3Switch);
   }
   function DoFadeOutMenu()
   {
      this.FadeOutAndCall();
   }
   function DoFadeInMenu()
   {
      this._parent.gotoAndPlay("fadeIn");
      this.EndState();
   }
   function FadeOutAndCall(strCallback, paramList)
   {
      this.strFadeOutCallback = strCallback;
      this.fadeOutParams = paramList;
      this._parent.gotoAndPlay("fadeOut");
      gfx.io.GameDelegate.call("fadeOutStarted",[]);
   }
   function onFadeOutCompletion()
   {
      if(this.strFadeOutCallback != undefined && this.strFadeOutCallback.length > 0)
      {
         if(this.fadeOutParams != undefined)
         {
            gfx.io.GameDelegate.call(this.strFadeOutCallback,this.fadeOutParams);
         }
         else
         {
            gfx.io.GameDelegate.call(this.strFadeOutCallback,[]);
         }
      }
   }
   function StartState(strStateName)
   {
      gfx.io.GameDelegate.call("StartState",[strStateName]);
      this.ShouldProcessInputs = false;
      if(strStateName == StartMenu.LOGIN_STATE)
      {
         this.strCurrentState = strStateName;
         if(this._LoginMenu != null)
         {
            this._LoginHolder_mc._visible = true;
            this.codeObj.BeginLogin();
         }
         return undefined;
      }
      if(strStateName == StartMenu.CHARACTER_SELECTION_STATE)
      {
         this.SaveLoadListHolder.isShowingCharacterList = true;
      }
      else if(strStateName == StartMenu.SAVE_LOAD_STATE)
      {
         this.SaveLoadListHolder.isShowingCharacterList = false;
      }
      else if(strStateName == StartMenu.DLC_STATE)
      {
         this.ShowMarketplaceButtonHelp(false);
      }
      if(this.strCurrentState == StartMenu.MAIN_STATE)
      {
         this.MainList.disableSelection = true;
         this._MessageOfTheDay_mc.visible = this._Motd_tf.text.length > 1;
      }
      this.ShowDeleteButtonHelp(false);
      this.ShowChangeUserButtonHelp(false);
      this.SaveLoadListHolder.ShowSelectionButtons(false);
      this.strCurrentState = strStateName + StartMenu.START_ANIM_STR;
      this.gotoAndPlay(this.strCurrentState);
      gfx.managers.FocusHandler.instance.setFocus(this,0);
   }
   function EndState()
   {
      if(this.strCurrentState == StartMenu.DLC_STATE)
      {
         this.ShowMarketplaceButtonHelp(false);
      }
      if(this.strCurrentState == StartMenu.LOGIN_STATE)
      {
         this._LoginHolder_mc._visible = false;
         this._BottomButtons_mc._visible = false;
         return undefined;
      }
      if(this.strCurrentState == StartMenu.PRESS_START_STATE && this._NeedsLoginScreen)
      {
         this.StartState(StartMenu.LOGIN_STATE);
      }
      else if(this.strCurrentState != StartMenu.MAIN_STATE)
      {
         this.strCurrentState += StartMenu.END_ANIM_STR;
         this.gotoAndPlay(this.strCurrentState);
      }
      if(this.strCurrentState == StartMenu.SAVE_LOAD_CONFIRM_STATE || this.strCurrentState == StartMenu.DELETE_SAVE_CONFIRM_STATE)
      {
         this.SaveLoadListHolder.ShowSelectionButtons(true);
      }
   }
   function ChangeStateFocus(strNewState)
   {
      switch(strNewState)
      {
         case StartMenu.MAIN_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.MainList,0);
            break;
         case StartMenu.CHARACTER_SELECTION_STATE:
         case StartMenu.SAVE_LOAD_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.SaveLoadListHolder.List_mc,0);
            this.SaveLoadListHolder.List_mc.disableSelection = false;
            break;
         case StartMenu.DLC_STATE:
            this.iLoadDLCListTimerID = setInterval(this,"DoLoadDLCList",500);
            gfx.managers.FocusHandler.instance.setFocus(this.DLCList_mc,0);
            break;
         case StartMenu.MAIN_CONFIRM_STATE:
         case StartMenu.SAVE_LOAD_CONFIRM_STATE:
         case StartMenu.DELETE_SAVE_CONFIRM_STATE:
         case StartMenu.PRESS_START_STATE:
         case StartMenu.MARKETPLACE_CONFIRM_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.ButtonRect,0);
         default:
            return;
      }
   }
   function ShowConfirmScreen(astrConfirmText)
   {
      this.ConfirmPanel_mc.textField.SetText(astrConfirmText);
      this.SetPlatform(this.iPlatform);
      this.StartState(StartMenu.MAIN_CONFIRM_STATE);
   }
   function OnSaveListOpenSuccess()
   {
      if(this.SaveLoadListHolder.numSaves > 0 && this.strCurrentState.indexOf(StartMenu.SAVE_LOAD_STATE) == -1)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
         this.StartState(StartMenu.SAVE_LOAD_STATE);
      }
      else
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
      }
   }
   function OnsaveListCharactersOpenSuccess()
   {
      if(this.strCurrentState == StartMenu.CHARACTER_LOAD_STATE || this.strCurrentState == "CharacterLoadStartAnim")
      {
         this.SaveLoadListHolder.isShowingCharacterList = true;
         this.ShowCharacterSelectionHint(false);
         gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
         this.StartState(StartMenu.CHARACTER_SELECTION_STATE);
      }
      else
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
      }
   }
   function OnSaveListBatchAdded()
   {
      if(this.SaveLoadListHolder.numSaves > 0 && this.strCurrentState == StartMenu.SAVE_LOAD_STATE)
      {
         this.ShowCharacterSelectionHint(true);
      }
   }
   function OnCharacterSelected()
   {
      if(!this.IsPlatformSony())
      {
         this.StartState(StartMenu.SAVE_LOAD_STATE);
      }
   }
   function onSaveHighlight(event)
   {
      this.DeleteSaveButton._alpha = event.index != -1 ? StartMenu.ALPHA_AVAILABLE : StartMenu.ALPHA_DISABLED;
      if(this.iPlatform == 0)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      }
   }
   function ConfirmLoadGame(event)
   {
      this.SaveLoadListHolder.List_mc.disableSelection = true;
      this.SaveLoadConfirmText.textField.SetText("$Load this game?");
      this.SetPlatform(this.iPlatform);
      this.StartState(StartMenu.SAVE_LOAD_CONFIRM_STATE);
   }
   function ConfirmDeleteSave()
   {
      this.SaveLoadListHolder.List_mc.disableSelection = true;
      this.SaveLoadConfirmText.textField.SetText("$Delete this save?");
      this.SetPlatform(this.iPlatform);
      this.StartState(StartMenu.DELETE_SAVE_CONFIRM_STATE);
   }
   function ShowDeleteButtonHelp(abFlag)
   {
      this.DeleteSaveButton.disabled = !abFlag;
      this.DeleteSaveButton._visible = abFlag;
      this.VersionText._visible = !abFlag;
   }
   function ShowChangeUserButtonHelp(abFlag)
   {
      if(this.IsPlatformXBox())
      {
         this.ChangeUserButton.disabled = !abFlag;
         this.ChangeUserButton._visible = abFlag;
         this.VersionText._visible = !abFlag;
      }
      else
      {
         this.ChangeUserButton.disabled = true;
         this.ChangeUserButton._visible = false;
      }
   }
   function ShowMarketplaceButtonHelp(abFlag)
   {
      if(this.IsPlatformXBox())
      {
         this.MarketplaceButton._visible = abFlag;
         this.VersionText._visible = !abFlag;
      }
      else
      {
         this.MarketplaceButton._visible = false;
      }
   }
   function ShowPressStartState()
   {
      if(this.strCurrentState != StartMenu.PRESS_START_STATE)
      {
         this.StartState(StartMenu.PRESS_START_STATE);
      }
   }
   function StartLoadingDLC()
   {
      this.LoadingContentMessage.gotoAndPlay("startFadeIn");
      clearInterval(this.iLoadDLCContentMessageTimerID);
      this.iLoadDLCContentMessageTimerID = setInterval(this,"onLoadingDLCMessageFadeCompletion",1000);
   }
   function onLoadingDLCMessageFadeCompletion()
   {
      clearInterval(this.iLoadDLCContentMessageTimerID);
      gfx.io.GameDelegate.call("DoLoadDLCPlugins",[]);
   }
   function DoneLoadingDLC()
   {
      this.LoadingContentMessage.gotoAndPlay("startFadeOut");
   }
   function DoLoadDLCList()
   {
      clearInterval(this.iLoadDLCListTimerID);
      this.DLCList_mc.entryList.splice(0,this.DLCList_mc.entryList.length);
      gfx.io.GameDelegate.call("LoadDLC",[this.DLCList_mc.entryList],this,"UpdateDLCPanel");
   }
   function UpdateDLCPanel(abMarketplaceAvail, abNewDLCAvail)
   {
      if(this.DLCList_mc.entryList.length > 0)
      {
         this.DLCList_mc._visible = true;
         this.DLCPanel.warningText.SetText(" ");
         if(this.iPlatform != 0)
         {
            this.DLCList_mc.selectedIndex = 0;
         }
         this.DLCList_mc.InvalidateData();
      }
      else
      {
         this.DLCList_mc._visible = false;
         this.DLCPanel.warningText.SetText("$No content downloaded" + (!this.IsPlatformSony() ? "" : "_PS3"));
      }
      this.MarketplaceButton._visible = false;
      if(abNewDLCAvail == true)
      {
         this.DLCPanel.NewContentAvail.SetText("$New content available");
      }
   }
   function OnSaveLoadPanelSelectClicked()
   {
      this.onAcceptPress();
   }
   function OnSaveLoadPanelBackClicked()
   {
      this.onCancelPress();
   }
   function onLoginCanceled(event)
   {
      if(this.strCurrentState == StartMenu.LOGIN_STATE)
      {
         this.EndState();
         this.StartState(StartMenu.MAIN_STATE);
      }
   }
   function onLoginError(event)
   {
   }
   function OnLoginSuccess()
   {
      this.EndState();
      this.StartState(StartMenu.MAIN_STATE);
   }
   function SetMotd(motdText)
   {
      this._Motd_tf.text = motdText;
      this._MessageOfTheDay_mc._visible = this._Motd_tf.text.length > 1;
   }
   function SetCreationClubAccess(canAccess)
   {
      this._UserCanAccessCreationClub = canAccess;
      this.MainList.GetClipByIndex(StartMenu.CREATION_CLUB_INDEX).alpha = !(this._UserCanAccessCreationClub && this._CClubAllowedByBnet) ? StartMenu.DISABLED_GREY_OUT_ALPHA : 100;
   }
   function UpdateBnetStatus(cclubUp, modsUp)
   {
      this._CClubAllowedByBnet = cclubUp;
      this._ModsAllowedByBnet = modsUp;
      this.MainList.GetClipByIndex(StartMenu.CREATION_CLUB_INDEX).alpha = !(this._UserCanAccessCreationClub && this._CClubAllowedByBnet) ? StartMenu.DISABLED_GREY_OUT_ALPHA : 100;
      this.MainList.GetClipByIndex(StartMenu.MOD_INDEX).alpha = !this._ModsAllowedByBnet ? StartMenu.DISABLED_GREY_OUT_ALPHA : 100;
   }
   function IsPlatformSony()
   {
      return this.iPlatform == StartMenu.PLATFORM_ORBIS || this.iPlatform == StartMenu.PLATFORM_PROSPERO;
   }
   function IsPlatformXBox()
   {
      return this.iPlatform == StartMenu.PLATFORM_DURANGO || this.iPlatform == StartMenu.PLATFORM_SCARLETT;
   }
}
