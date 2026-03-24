class SystemPage extends MovieClip
{
   var BottomBar_mc;
   var CategoryList;
   var CategoryList_mc;
   var ConfirmPanel;
   var ConfirmTextField;
   var CreationListPanel;
   var CreationTextPanel;
   var CreationsButtonHolder;
   var CreationsList;
   var CreationsText;
   var CreationsTitleText;
   var ErrorText;
   var HelpButtonHolder;
   var HelpList;
   var HelpListPanel;
   var HelpText;
   var HelpTextPanel;
   var HelpTitleText;
   var InputMappingPanel;
   var MappingList;
   var OptionsListsPanel;
   var PCQuitList;
   var PCQuitPanel;
   var PS3Switch;
   var PanelRect;
   var SaveLoadListHolder;
   var SaveLoadPanel;
   var SettingsList;
   var SettingsPanel;
   var SystemDivider;
   var TabPageSwitchBottomMem;
   var TopmostPanel;
   var VersionText;
   var _ShowModMenu;
   var _skyrimVersion;
   var _skyrimVersionBuild;
   var _skyrimVersionMinor;
   var bDefaultsButtonVisible;
   var bIsRemoteDevice;
   var bMenuClosing;
   var bRemapMode;
   var bSavingSettings;
   var bSettingsChanged;
   var bShowKinectTunerButton;
   var bVersionInitialized;
   var bUpdated;
   var iCurrentState;
   var iDebounceRemapModeID;
   var iHideErrorTextID;
   var iPlatform;
   var iSaveDelayTimerID;
   var iSavingSettingsTimerID;
   static var MAIN_STATE = 0;
   static var SAVE_LOAD_STATE = 1;
   static var SAVE_LOAD_CONFIRM_STATE = 2;
   static var SETTINGS_CATEGORY_STATE = 3;
   static var OPTIONS_LISTS_STATE = 4;
   static var DEFAULT_SETTINGS_CONFIRM_STATE = 5;
   static var INPUT_MAPPING_STATE = 6;
   static var QUIT_CONFIRM_STATE = 7;
   static var PC_QUIT_LIST_STATE = 8;
   static var PC_QUIT_CONFIRM_STATE = 9;
   static var DELETE_SAVE_CONFIRM_STATE = 10;
   static var CREATIONS_LIST_STATE = 11;
   static var CREATIONS_TEXT_STATE = 12;
   static var HELP_LIST_STATE = 13;
   static var HELP_TEXT_STATE = 14;
   static var TRANSITIONING = 15;
   static var CHARACTER_LOAD_STATE = 16;
   static var CHARACTER_SELECTION_STATE = 17;
   // static var MOD_MANAGER_BUTTON_INDEX = 4;
   static var CONTROLLER_ORBIS = 3;
   static var CONTROLLER_SCARLETT = 4;
   static var CONTROLLER_PROSPERO = 5;

   static var IDX_QUICKSAVE;
   static var IDX_SAVE;
   static var IDX_LOAD;

   static var IDX_INSTALLED_CONTENT;
   static var IDX_CREATIONS;
   
   static var IDX_SETTINGS;
   static var IDX_MOD_CONFIG;
   static var IDX_CONTROLS;
   static var IDX_HELP;
   static var IDX_QUIT;

   var CancelButtonMappedTo = "Esc";
   function SystemPage()
   {
      super();
      this.CategoryList = this.CategoryList_mc.List_mc;
      this.SaveLoadListHolder = this.SaveLoadPanel;
      this.SettingsList = this.SettingsPanel.List_mc;
      this.MappingList = this.InputMappingPanel.List_mc;
      this.PCQuitList = this.PCQuitPanel.List_mc;
      this.HelpList = this.HelpListPanel.List_mc;
      this.HelpText = this.HelpTextPanel.HelpTextHolder.HelpText;
      this.HelpButtonHolder = this.HelpTextPanel.HelpTextHolder.ButtonArtHolder;
      this.HelpTitleText = this.HelpTextPanel.HelpTextHolder.TitleText;
      this.CreationsList = this.CreationListPanel.cList_mc;
      this.CreationsText = this.CreationTextPanel.CreationTextHolder.CreationText;
      this.CreationsButtonHolder = this.CreationTextPanel.CreationTextHolder.ButtonArtHolder;
      this.CreationsTitleText = this.CreationTextPanel.CreationTextHolder.TitleText;
      this.ConfirmTextField = this.ConfirmPanel.ConfirmText.textField;
      this.TopmostPanel = this.PanelRect;
      this.bUpdated = false;
      this.bRemapMode = false;
      this.bSettingsChanged = false;
      this.bMenuClosing = false;
      this.bSavingSettings = false;
      this.bShowKinectTunerButton = false;
      this.bVersionInitialized = false;
      this.iPlatform = 0;
      this.bDefaultsButtonVisible = false;
      this.TabPageSwitchBottomMem = new Array();
      this._ShowModMenu = false;
      var _loc3_ = JournalBottomBar.IDX_BUTTON1;
      while(_loc3_ <= JournalBottomBar.IDX_LASTBUTTON)
      {
         this.TabPageSwitchBottomMem[_loc3_] = {Visible:false,Label:"",Art:undefined};
         _loc3_ = _loc3_ + 1;
      }
      Shared.ButtonMapping.Initialize("SystemPage");
   }
   function GetIsRemoteDevice()
   {
      return this.bIsRemoteDevice;
   }
   function onLoad()
   {
      this.CategoryList.entryList.push({text:"$QUICKSAVE"});
      this.CategoryList.entryList.push({text:"$SAVE"});
      this.CategoryList.entryList.push({text:"$LOAD"});
      this.CategoryList.entryList.push({text:"$SETTINGS"});
      this.CategoryList.entryList.push({text:"$MOD CONFIGURATION"});
      this.CategoryList.entryList.push({text:"$CONTROLS"});
      this.CategoryList.entryList.push({text:"$HELP"});
      this.CategoryList.entryList.push({text:"$QUIT"});
      this.CategoryList.InvalidateData();
      this.ConfirmPanel.handleInput = function()
      {
         return false;
      };
      this.ConfirmPanel.ButtonRect.AcceptMouseButton.addEventListener("click",this,"onAcceptMousePress");
      this.ConfirmPanel.ButtonRect.CancelMouseButton.addEventListener("click",this,"onCancelMousePress");
      this.ConfirmPanel.ButtonRect.AcceptMouseButton.SetPlatform(0,false);
      this.ConfirmPanel.ButtonRect.CancelMouseButton.SetPlatform(0,false);
      this.SaveLoadListHolder.addEventListener("saveGameSelected",this,"ConfirmSaveGame");
      this.SaveLoadListHolder.addEventListener("loadGameSelected",this,"ConfirmLoadGame");
      this.SaveLoadListHolder.addEventListener("saveListCharactersPopulated",this,"OnsaveListCharactersOpenSuccess");
      this.SaveLoadListHolder.addEventListener("saveListPopulated",this,"OnSaveListOpenSuccess");
      this.SaveLoadListHolder.addEventListener("saveListOnBatchAdded",this,"OnSaveListBatchAdded");
      this.SaveLoadListHolder.addEventListener("OnCharacterSelected",this,"OnCharacterSelected");
      gfx.io.GameDelegate.addCallBack("OnSaveDataEventSaveSUCCESS",this,"OnSaveDataEventSaveSUCCESS");
      gfx.io.GameDelegate.addCallBack("OnSaveDataEventSaveCANCEL",this,"OnSaveDataEventSaveCANCEL");
      gfx.io.GameDelegate.addCallBack("OnSaveDataEventLoadCANCEL",this,"OnSaveDataEventLoadCANCEL");
      this.SaveLoadListHolder.addEventListener("saveHighlighted",this,"onSaveHighlight");
      this.SaveLoadListHolder.List_mc.addEventListener("listPress",this,"onSaveLoadListPress");
      this.SettingsList.entryList = [{text:"$Gameplay"},{text:"$Display"},{text:"$Audio"}];
      this.SettingsList.InvalidateData();
      this.SettingsList.addEventListener("itemPress",this,"onSettingsCategoryPress");
      this.SettingsList.disableInput = true;
      this.InputMappingPanel.List_mc.addEventListener("itemPress",this,"onInputMappingPress");
      gfx.io.GameDelegate.addCallBack("FinishRemapMode",this,"onFinishRemapMode");
      gfx.io.GameDelegate.addCallBack("SettingsSaved",this,"onSettingsSaved");
      gfx.io.GameDelegate.addCallBack("RefreshSystemButtons",this,"RefreshSystemButtons");
      this.PCQuitList.entryList = [{text:"$Main Menu"},{text:"$Desktop"}];
      this.PCQuitList.UpdateList();
      this.PCQuitList.addEventListener("itemPress",this,"onPCQuitButtonPress");
      this.HelpList.addEventListener("itemPress",this,"onHelpItemPress");
      this.HelpList.disableInput = true;
      this.HelpTitleText.textAutoSize = "shrink";
      this.CreationsList.addEventListener("itemPress",this,"onCreationsItemPress");
      this.CreationsList.disableInput = true;
      this.CreationsTitleText.textAutoSize = "shrink";
      this.BottomBar_mc = this._parent._parent.BottomBar_mc;
      gfx.io.GameDelegate.addCallBack("BackOutFromLoadGame",this,"BackOutFromLoadGame");
      gfx.io.GameDelegate.addCallBack("SetRemoteDevice",this,"SetRemoteDevice");
      gfx.io.GameDelegate.addCallBack("UpdatePermissions",this,"UpdatePermissions");
   }
   function SetShowMod(show)
   {
      this._ShowModMenu = show;
   }
   function startPage()
   {
      var _loc2_;
      if(!this.bUpdated)
      {
         gfx.io.GameDelegate.call("SetVersionText",[this.VersionText]);
         this.ParseVersion();
         this.bVersionInitialized = true;

         this.InitializeCategoryIndices();
         this.InitializeCategoryBethesdaUI();
         
         this.currentState = SystemPage.MAIN_STATE;
         gfx.io.GameDelegate.call("ShouldShowKinectTunerOption",[],this,"SetShouldShowKinectTunerOption");
         this.UpdatePermissions();
         this.BottomBar_mc.SetButtonVisibility(1,false,50);
         this.bUpdated = true;
      }
      else
      {
         this.UpdateStateFocus(this.iCurrentState);
         _loc2_ = JournalBottomBar.IDX_BUTTON1;
         while(_loc2_ <= JournalBottomBar.IDX_LASTBUTTON)
         {
            this.BottomBar_mc.SetButtonVisibility(_loc2_ + 1,this.TabPageSwitchBottomMem[_loc2_].Visible,100);
            if(this.TabPageSwitchBottomMem[_loc2_].Visible)
            {
               this.BottomBar_mc.Buttons[_loc2_].label = this.TabPageSwitchBottomMem[_loc2_].Label;
               this.BottomBar_mc.Buttons[_loc2_].SetArt(this.TabPageSwitchBottomMem[_loc2_].Art);
            }
            _loc2_ = _loc2_ + 1;
         }
      }
      this.CategoryList.addEventListener("itemPress",this,"onCategoryButtonPress");
      this.CategoryList.addEventListener("listPress",this,"onCategoryListPress");
      this.CategoryList.addEventListener("listMovedUp",this,"onCategoryListMoveUp");
      this.CategoryList.addEventListener("listMovedDown",this,"onCategoryListMoveDown");
      this.CategoryList.addEventListener("selectionChange",this,"onCategoryListMouseSelectionChange");
      this.BottomBar_mc.addEventListener("OnBottomBarButtonMousePress",Shared.Proxy.create(this,this.OnBottomBarButtonMousePress));
   }
   function endPage()
   {
      this.CategoryList.removeEventListener("itemPress",this,"onCategoryButtonPress");
      this.CategoryList.removeEventListener("listPress",this,"onCategoryListPress");
      this.CategoryList.removeEventListener("listMovedUp",this,"onCategoryListMoveUp");
      this.CategoryList.removeEventListener("listMovedDown",this,"onCategoryListMoveDown");
      this.CategoryList.removeEventListener("selectionChange",this,"onCategoryListMouseSelectionChange");
      this.BottomBar_mc.removeAllEventListeners();
      var _loc2_ = JournalBottomBar.IDX_BUTTON1;
      while(_loc2_ <= JournalBottomBar.IDX_LASTBUTTON)
      {
         this.TabPageSwitchBottomMem[_loc2_] = {Visible:this.BottomBar_mc.IsButtonVisible(_loc2_ + 1),Label:this.BottomBar_mc.Buttons[_loc2_].label,Art:this.BottomBar_mc.Buttons[_loc2_].GetArt()};
         _loc2_ = _loc2_ + 1;
      }
      this.BottomBar_mc.SetButtonVisibility(1,false,100);
      this.BottomBar_mc.SetButtonVisibility(2,false,100);
   }
   function get currentState()
   {
      return this.iCurrentState;
   }
   function set currentState(aiNewState)
   {
      if(aiNewState == undefined)
      {
         return;
      }
      if(aiNewState == SystemPage.MAIN_STATE)
      {
         this.SaveLoadListHolder.isShowingCharacterList = false;
      }
      else if(aiNewState == SystemPage.SAVE_LOAD_STATE && this.SaveLoadListHolder.isShowingCharacterList)
      {
         aiNewState = SystemPage.CHARACTER_SELECTION_STATE;
      }
      var _loc3_ = this.GetPanelForState(aiNewState);
      this.iCurrentState = aiNewState;
      if(_loc3_ != this.TopmostPanel)
      {
         _loc3_.swapDepths(this.TopmostPanel);
         this.TopmostPanel = _loc3_;
      }
      this.UpdateStateFocus(aiNewState);
   }
   function OnSaveDataEventSaveSUCCESS()
   {
      if(this.IsPlatformSony())
      {
         this.bMenuClosing = true;
         this.EndState();
      }
   }
   function OnSaveDataEventSaveCANCEL()
   {
      if(this.IsPlatformSony())
      {
         this.HideErrorText();
         this.EndState();
         this.StartState(SystemPage.SAVE_LOAD_STATE);
      }
   }
   function OnSaveDataEventLoadCANCEL()
   {
      this.StartState(SystemPage.CHARACTER_SELECTION_STATE);
   }
   function handleInput(details, pathToFocus)
   {
      var _loc3_ = false;
      if(this.bRemapMode || this.bMenuClosing || this.bSavingSettings || this.iCurrentState == SystemPage.TRANSITIONING)
      {
         _loc3_ = true;
      }
      else if(Shared.GlobalFunc.IsKeyPressed(details,this.iCurrentState != SystemPage.INPUT_MAPPING_STATE))
      {
         if(this.iCurrentState != SystemPage.OPTIONS_LISTS_STATE)
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT && this.iCurrentState == SystemPage.MAIN_STATE)
            {
               details.navEquivalent = gfx.ui.NavigationCode.ENTER;
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.LEFT && this.iCurrentState != SystemPage.MAIN_STATE)
            {
               details.navEquivalent = gfx.ui.NavigationCode.TAB;
            }
         }
         if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_L2 || details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R2) && this.isConfirming())
         {
            _loc3_ = true;
         }
         else if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 88) && this.iCurrentState == SystemPage.SAVE_LOAD_STATE && this.BottomBar_mc.IsButtonVisible(1))
         {
            if(this.IsPlatformSony())
            {
               gfx.io.GameDelegate.call("ORBISDeleteSave",[]);
               _loc3_ = true;
            }
            else
            {
               this.ConfirmDeleteSave();
               _loc3_ = true;
            }
         }
         else if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y || details.code == 84) && this.iCurrentState == SystemPage.SAVE_LOAD_STATE && !this.SaveLoadListHolder.isSaving && this.BottomBar_mc.IsButtonVisible(2))
         {
            this.StartState(SystemPage.CHARACTER_LOAD_STATE);
            _loc3_ = true;
         }
         else if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y || details.code == 84) && (this.iCurrentState == SystemPage.OPTIONS_LISTS_STATE || this.iCurrentState == SystemPage.INPUT_MAPPING_STATE) && this.bDefaultsButtonVisible === true)
         {
            this.ConfirmTextField.SetText("$Reset settings to default values?");
            this.StartState(SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE);
            _loc3_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R1 && this.iCurrentState == SystemPage.OPTIONS_LISTS_STATE && this.BottomBar_mc.IsButtonVisible(2))
         {
            gfx.io.GameDelegate.call("OpenKinectTuner",[]);
            _loc3_ = true;
         }
         else if(!pathToFocus[0].handleInput(details,pathToFocus.slice(1)))
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
            {
               _loc3_ = this.onAcceptPress();
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
            {
               _loc3_ = this.onCancelPress();
            }
         }
      }
      return _loc3_;
   }
   function onAcceptPress()
   {
      var _loc2_ = true;
      switch(this.iCurrentState)
      {
         case SystemPage.CHARACTER_SELECTION_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
            gfx.io.GameDelegate.call("CharacterSelected",[this.SaveLoadListHolder.selectedIndex]);
            break;
         case SystemPage.SAVE_LOAD_CONFIRM_STATE:
         case SystemPage.TRANSITIONING:
            if(this.SaveLoadListHolder.List_mc.disableSelection)
            {
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               if(!this.IsPlatformSony())
               {
                  this.bMenuClosing = true;
                  if(this.SaveLoadListHolder.isSaving)
                  {
                     this.ConfirmPanel._visible = false;
                     if(this.iPlatform == Shared.ButtonChange.PLATFORM_360)
                     {
                        this.ErrorText.SetText("$Saving content. Please don\'t turn off your console.");
                     }
                     else
                     {
                        this.ErrorText.SetText("$Saving...");
                     }
                     this.iSaveDelayTimerID = setInterval(this,"DoSaveGame",1);
                     break;
                  }
                  gfx.io.GameDelegate.call("LoadGame",[this.SaveLoadListHolder.selectedIndex]);
                  break;
               }
               if(this.SaveLoadListHolder.isSaving)
               {
                  this.iSaveDelayTimerID = setInterval(this,"DoSaveGame",1);
                  break;
               }
               gfx.io.GameDelegate.call("LoadGame",[this.SaveLoadListHolder.selectedIndex]);
            }
            break;
         case SystemPage.QUIT_CONFIRM_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
            gfx.io.GameDelegate.call("QuitToMainMenu",[]);
            this.bMenuClosing = true;
            break;
         case SystemPage.PC_QUIT_CONFIRM_STATE:
            if(this.PCQuitList.selectedIndex == 0)
            {
               gfx.io.GameDelegate.call("QuitToMainMenu",[]);
               this.bMenuClosing = true;
               break;
            }
            if(this.PCQuitList.selectedIndex == 1)
            {
               gfx.io.GameDelegate.call("QuitToDesktop",[]);
            }
            break;
         case SystemPage.DELETE_SAVE_CONFIRM_STATE:
            this.SaveLoadListHolder.DeleteSelectedSave();
            if(this.SaveLoadListHolder.numSaves == 0)
            {
               this.GetPanelForState(SystemPage.SAVE_LOAD_STATE).gotoAndStop(1);
               this.GetPanelForState(SystemPage.DELETE_SAVE_CONFIRM_STATE).gotoAndStop(1);
               this.BottomBar_mc.SetButtonVisibility(1,false);
               this.BottomBar_mc.SetButtonVisibility(2,false);
               this.currentState = SystemPage.MAIN_STATE;
               this.SystemDivider.gotoAndStop("Right");
               break;
            }
            this.EndState();
            break;
         case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
            if(this.ConfirmPanel.returnState == SystemPage.OPTIONS_LISTS_STATE)
            {
               this.ResetSettingsToDefaults();
            }
            else if(this.ConfirmPanel.returnState == SystemPage.INPUT_MAPPING_STATE)
            {
               this.ResetControlsToDefaults();
            }
            this.EndState();
            break;
         default:
            _loc2_ = false;
      }
      return _loc2_;
   }
   function onCancelPress()
   {
      var _loc2_ = true;
      switch(this.iCurrentState)
      {
         case SystemPage.CHARACTER_LOAD_STATE:
         case SystemPage.CHARACTER_SELECTION_STATE:
         case SystemPage.SAVE_LOAD_STATE:
            this.SaveLoadListHolder.ForceStopLoading();
         case SystemPage.PC_QUIT_LIST_STATE:
         case SystemPage.HELP_LIST_STATE:
         case SystemPage.CREATIONS_LIST_STATE:
         case SystemPage.SAVE_LOAD_CONFIRM_STATE:
         case SystemPage.QUIT_CONFIRM_STATE:
         case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
         case SystemPage.PC_QUIT_CONFIRM_STATE:
         case SystemPage.DELETE_SAVE_CONFIRM_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
            this.EndState();
            break;
         case SystemPage.HELP_TEXT_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
            this.EndState();
            this.StartState(SystemPage.HELP_LIST_STATE);
            this.HelpListPanel.bCloseToMainState = true;
            break;
         case SystemPage.CREATIONS_TEXT_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
            this.EndState();
            this.StartState(SystemPage.CREATIONS_LIST_STATE);
            this.CreationListPanel.bCloseToMainState = true;
            break;
         case SystemPage.OPTIONS_LISTS_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
            this.EndState();
            this.StartState(SystemPage.SETTINGS_CATEGORY_STATE);
            this.SettingsPanel.bCloseToMainState = true;
            break;
         case SystemPage.INPUT_MAPPING_STATE:
         case SystemPage.SETTINGS_CATEGORY_STATE:
            gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
            if(this.bSettingsChanged)
            {
               this.ErrorText.SetText("$Saving...");
               this.bSavingSettings = true;
               if(this.iCurrentState == SystemPage.INPUT_MAPPING_STATE)
               {
                  this.iSavingSettingsTimerID = setInterval(this,"SaveControls",1000);
                  break;
               }
               if(this.iCurrentState == SystemPage.SETTINGS_CATEGORY_STATE)
               {
                  this.iSavingSettingsTimerID = setInterval(this,"SaveSettings",1000);
               }
               break;
            }
            this.onSettingsSaved();
            break;
         default:
            _loc2_ = false;
      }
      return _loc2_;
   }
   function isConfirming()
   {
      return this.iCurrentState == SystemPage.SAVE_LOAD_CONFIRM_STATE || this.iCurrentState == SystemPage.QUIT_CONFIRM_STATE || this.iCurrentState == SystemPage.PC_QUIT_CONFIRM_STATE || this.iCurrentState == SystemPage.DELETE_SAVE_CONFIRM_STATE || this.iCurrentState == SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE;
   }
   function onAcceptMousePress()
   {
      if(this.isConfirming())
      {
         this.onAcceptPress();
      }
   }
   function onCancelMousePress()
   {
      if(this.isConfirming())
      {
         this.onCancelPress();
      }
   }
   function OnBottomBarButtonMousePress(evt)
   {
      var _loc3_ = evt.target;
      if(evt.target.label == "$Delete")
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
         this.ConfirmDeleteSave();
      }
      else if(evt.target.label == "$CharacterSelection")
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
         this.StartState(SystemPage.CHARACTER_LOAD_STATE);
      }
      else if(evt.target.label == "$Defaults")
      {
         if(this.iCurrentState == SystemPage.OPTIONS_LISTS_STATE || this.iCurrentState == SystemPage.INPUT_MAPPING_STATE)
         {
            this.ConfirmTextField.SetText("$Reset settings to default values?");
            this.StartState(SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE);
         }
      }
      else if(evt.target.label == "$Cancel")
      {
         this.onCancelPress();
      }
   }
   function onCategoryButtonPress(event)
   {
      if (!this.bVersionInitialized) return;

      if(event.entry.disabled)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
      }
      else if(this.iCurrentState == SystemPage.MAIN_STATE)
      {
         switch(event.index)
         {
            case this.IDX_QUICKSAVE:
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               gfx.io.GameDelegate.call("QuickSave",[]);
               return;
            case this.IDX_SAVE:
               gfx.io.GameDelegate.call("UseCurrentCharacterFilter",[]);
               this.SaveLoadListHolder.isSaving = true;
               if(this.IsPlatformSony())
               {
                  this.SaveLoadListHolder.PopulateEmptySaveList();
                  return;
               }
               gfx.io.GameDelegate.call("SAVE",[this.SaveLoadListHolder.List_mc.entryList,this.SaveLoadListHolder.batchSize]);
               return;
               break;
            case this.IDX_LOAD:
               this.SaveLoadListHolder.isSaving = false;
               gfx.io.GameDelegate.call("LOAD",[this.SaveLoadListHolder.List_mc.entryList,this.SaveLoadListHolder.batchSize]);
               return;
            case this.IDX_INSTALLED_CONTENT:
               if(this.CreationsList.entryList.length == 0)
               {
                  gfx.io.GameDelegate.call("PopulateCreationClubTopics",[this.CreationsList.entryList]);
                  this.CreationsList.entryList.sort(this.doABCSort);
                  this.CreationsList.InvalidateData();
               }
               if(this.CreationsList.entryList.length != 0)
               {
                  this.StartState(SystemPage.CREATIONS_LIST_STATE);
                  gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
                  return;
               }
               gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
               return;
               break;
            case this.IDX_CREATIONS:
               gfx.io.GameDelegate.call("ModManager",[]);
               return;
            case this.IDX_SETTINGS:
               this.StartState(SystemPage.SETTINGS_CATEGORY_STATE);
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
            case this.IDX_MOD_CONFIG:
               _root.QuestJournalFader.Menu_mc.ConfigPanelOpen();
               return;
            case this.IDX_CONTROLS:
               if(this.MappingList.entryList.length == 0)
               {
                  gfx.io.GameDelegate.call("RequestInputMappings",[this.MappingList.entryList]);
                  this.MappingList.entryList.sort(this.inputMappingSort);
                  this.MappingList.InvalidateData();
               }
               this.StartState(SystemPage.INPUT_MAPPING_STATE);
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
            case this.IDX_HELP:
               if(this.HelpList.entryList.length == 0)
               {
                  gfx.io.GameDelegate.call("PopulateHelpTopics",[this.HelpList.entryList]);
                  this.HelpList.entryList.sort(this.doABCSort);
                  this.HelpList.InvalidateData();
               }
               if(this.HelpList.entryList.length != 0)
               {
                  this.StartState(SystemPage.HELP_LIST_STATE);
                  gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               }
               else
               {
                  gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
               }
               return;
            case this.IDX_QUIT:
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               gfx.io.GameDelegate.call("RequestIsOnPC",[],this,"populateQuitList");
               return;
            default:
               gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
               return;
         }
      }
   }
   function onCategoryListPress(event)
   {
      if(!this.bRemapMode && !this.bMenuClosing && !this.bSavingSettings && this.iCurrentState != SystemPage.TRANSITIONING)
      {
         this.onCancelPress();
         this.CategoryList.disableSelection = false;
         this.CategoryList.UpdateList();
         this.CategoryList.disableSelection = true;
      }
   }
   function doABCSort(aObj1, aObj2)
   {
      if(aObj1.text < aObj2.text)
      {
         return -1;
      }
      if(aObj1.text > aObj2.text)
      {
         return 1;
      }
      return 0;
   }
   function onCategoryListMoveUp(event)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      if(event.scrollChanged == true)
      {
         this.CategoryList._parent.gotoAndPlay("moveUp");
      }
   }
   function onCategoryListMoveDown(event)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      if(event.scrollChanged == true)
      {
         this.CategoryList._parent.gotoAndPlay("moveDown");
      }
   }
   function onCategoryListMouseSelectionChange(event)
   {
      if(event.keyboardOrMouse == 0 && event.index != -1)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      }
   }
   function OnCharacterSelected()
   {
      if(!this.IsPlatformSony())
      {
         this.StartState(SystemPage.SAVE_LOAD_STATE);
      }
   }
   function OnsaveListCharactersOpenSuccess()
   {
      if(this.SaveLoadListHolder.numSaves > 0)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
         this.StartState(SystemPage.CHARACTER_SELECTION_STATE);
      }
      else
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
      }
   }
   function OnSaveListOpenSuccess()
   {
      if(this.SaveLoadListHolder.numSaves > 0)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
         this.StartState(SystemPage.SAVE_LOAD_STATE);
      }
      else
      {
         this.StartState(SystemPage.CHARACTER_LOAD_STATE);
      }
   }
   function OnSaveListBatchAdded()
   {
   }
   function ConfirmSaveGame(event)
   {
      this.SaveLoadListHolder.List_mc.disableSelection = true;
      if(this.iCurrentState == SystemPage.SAVE_LOAD_STATE)
      {
         if(event.index == 0)
         {
            this.iCurrentState = SystemPage.SAVE_LOAD_CONFIRM_STATE;
            this.onAcceptPress();
         }
         else
         {
            this.ConfirmTextField.SetText("$Save over this game?");
            this.StartState(SystemPage.SAVE_LOAD_CONFIRM_STATE);
            gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
         }
      }
   }
   function DoSaveGame()
   {
      clearInterval(this.iSaveDelayTimerID);
      gfx.io.GameDelegate.call("SaveGame",[this.SaveLoadListHolder.selectedIndex]);
      if(!this.IsPlatformSony())
      {
         this._parent._parent.CloseMenu();
      }
   }
   function onSaveHighlight(event)
   {
      if(this.iCurrentState == SystemPage.SAVE_LOAD_STATE && !this.SaveLoadListHolder.isShowingCharacterList)
      {
         this.BottomBar_mc.SetButtonVisibility(1,true,event.index != -1 ? 100 : 50);
         if(this.iPlatform == 0)
         {
            gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
         }
      }
   }
   function onSaveLoadListPress()
   {
      this.onAcceptPress();
   }
   function ConfirmLoadGame(event)
   {
      this.SaveLoadListHolder.List_mc.disableSelection = true;
      if(this.iCurrentState == SystemPage.SAVE_LOAD_STATE)
      {
         this.ConfirmTextField.SetText("$Load this game? All unsaved progress will be lost.");
         this.StartState(SystemPage.SAVE_LOAD_CONFIRM_STATE);
         gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
      }
   }
   function ConfirmDeleteSave()
   {
      if(!this.SaveLoadListHolder.isSaving || this.SaveLoadListHolder.selectedIndex != 0)
      {
         this.SaveLoadListHolder.List_mc.disableSelection = true;
         if(this.iCurrentState == SystemPage.SAVE_LOAD_STATE)
         {
            this.ConfirmTextField.SetText("$Delete this save?");
            this.StartState(SystemPage.DELETE_SAVE_CONFIRM_STATE);
         }
      }
   }
   function onSettingsCategoryPress()
   {
      var _loc2_ = this.OptionsListsPanel.OptionsLists.List_mc;
      switch(this.SettingsList.selectedIndex)
      {
         case 0:
            if(this.IsVersionAtLeast(1, 6, 659))
            {
               _loc2_.entryList = [{text:"$Invert Y",movieType:2},{text:"$Look Sensitivity",movieType:0},{text:"$Vibration",movieType:2},{text:"$360 Controller",movieType:2},{text:"$SaveGameMissingCreationsCheck",movieType:2},{text:"$Survival Mode",movieType:2},{text:"$Difficulty",movieType:1,options:["$Very Easy","$Easy","$Normal","$Hard","$Very Hard","$Legendary"]},{text:"$Show Floating Markers",movieType:2},{text:"$Save on Rest",movieType:2},{text:"$Save on Wait",movieType:2},{text:"$Save on Travel",movieType:2},{text:"$Save on Pause",movieType:1,options:["$5 Mins","$10 Mins","$15 Mins","$30 Mins","$45 Mins","$60 Mins","$Disabled"]},{text:"$Use Kinect Commands",movieType:2}];
            }
            else
            {
               _loc2_.entryList = [{text:"$Invert Y",movieType:2},{text:"$Look Sensitivity",movieType:0},{text:"$Vibration",movieType:2},{text:"$360 Controller",movieType:2},{text:"$Survival Mode",movieType:2},{text:"$Difficulty",movieType:1,options:["$Very Easy","$Easy","$Normal","$Hard","$Very Hard","$Legendary"]},{text:"$Show Floating Markers",movieType:2},{text:"$Save on Rest",movieType:2},{text:"$Save on Wait",movieType:2},{text:"$Save on Travel",movieType:2},{text:"$Save on Pause",movieType:1,options:["$5 Mins","$10 Mins","$15 Mins","$30 Mins","$45 Mins","$60 Mins","$Disabled"]},{text:"$Use Kinect Commands",movieType:2}];
            }
            gfx.io.GameDelegate.call("RequestGameplayOptions",[_loc2_.entryList]);
            break;
         case 1:
            _loc2_.entryList = [{text:"$Brightness",movieType:0},{text:"$HUD Opacity",movieType:0},{text:"$Actor Fade",movieType:0},{text:"$Item Fade",movieType:0},{text:"$Object Fade",movieType:0},{text:"$Grass Fade",movieType:0},{text:"$Shadow Fade",movieType:0},{text:"$Light Fade",movieType:0},{text:"$Specularity Fade",movieType:0},{text:"$Tree LOD Fade",movieType:0},{text:"$Crosshair",movieType:2},{text:"$Dialogue Subtitles",movieType:2},{text:"$General Subtitles",movieType:2},{text:"$DDOF Intensity",movieType:0}];
            gfx.io.GameDelegate.call("RequestDisplayOptions",[_loc2_.entryList]);
            break;
         case 2:
            _loc2_.entryList = [{text:"$Master",movieType:0}];
            gfx.io.GameDelegate.call("RequestAudioOptions",[_loc2_.entryList]);
            for(var _loc4_ in _loc2_.entryList)
            {
               _loc2_.entryList[_loc4_].movieType = 0;
            }
      }
      var _loc3_ = 0;
      while(_loc3_ < _loc2_.entryList.length)
      {
         if(_loc2_.entryList[_loc3_].ID == undefined)
         {
            _loc2_.entryList.splice(_loc3_,1);
         }
         else
         {
            _loc3_ = _loc3_ + 1;
         }
      }
      if(this.iPlatform != 0)
      {
         _loc2_.selectedIndex = 0;
      }
      _loc2_.InvalidateData();
      this.SettingsPanel.bCloseToMainState = false;
      this.EndState();
      this.StartState(SystemPage.OPTIONS_LISTS_STATE);
      gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
      this.bSettingsChanged = true;
   }
   function ResetSettingsToDefaults()
   {
      var _loc2_ = this.OptionsListsPanel.OptionsLists.List_mc;
      for(var _loc3_ in _loc2_.entryList)
      {
         if(_loc2_.entryList[_loc3_].defaultVal != undefined)
         {
            _loc2_.entryList[_loc3_].value = _loc2_.entryList[_loc3_].defaultVal;
            gfx.io.GameDelegate.call("OptionChange",[_loc2_.entryList[_loc3_].ID,_loc2_.entryList[_loc3_].value]);
         }
      }
      _loc2_.bAllowValueOverwrite = true;
      _loc2_.UpdateList();
      _loc2_.bAllowValueOverwrite = false;
   }
   function onInputMappingPress(event)
   {
      if(this.bRemapMode == false && this.iCurrentState == SystemPage.INPUT_MAPPING_STATE)
      {
         this.MappingList.disableSelection = true;
         this.bRemapMode = true;
         this.ErrorText.SetText("$Press a button to map to this action.");
         gfx.io.GameDelegate.call("PlaySound",["UIMenuPrevNext"]);
         gfx.io.GameDelegate.call("StartRemapMode",[event.entry.text,this.MappingList.entryList]);
      }
   }
   function onFinishRemapMode(abSuccess)
   {
      if(abSuccess)
      {
         this.HideErrorText();
         this.MappingList.entryList.sort(this.inputMappingSort);
         this.MappingList.UpdateList();
         this.bSettingsChanged = true;
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      }
      else
      {
         this.ErrorText.SetText("$That button is reserved.");
         gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
         this.iHideErrorTextID = setInterval(this,"HideErrorText",1000);
      }
      this.MappingList.disableSelection = false;
      this.iDebounceRemapModeID = setInterval(this,"ClearRemapMode",200);
      this.refreshBottomBarButtonText(this.iCurrentState);
   }
   function inputMappingSort(aObj1, aObj2)
   {
      if(aObj1.sortIndex < aObj2.sortIndex)
      {
         return -1;
      }
      if(aObj1.sortIndex > aObj2.sortIndex)
      {
         return 1;
      }
      return 0;
   }
   function HideErrorText()
   {
      if(this.iHideErrorTextID != undefined)
      {
         clearInterval(this.iHideErrorTextID);
      }
      this.ErrorText.SetText(" ");
   }
   function ClearRemapMode()
   {
      if(this.iDebounceRemapModeID != undefined)
      {
         clearInterval(this.iDebounceRemapModeID);
      }
      this.bRemapMode = false;
   }
   function ResetControlsToDefaults()
   {
      gfx.io.GameDelegate.call("ResetControlsToDefaults",[this.MappingList.entryList]);
      this.MappingList.entryList.splice(0,this.MappingList.entryList.length);
      gfx.io.GameDelegate.call("RequestInputMappings",[this.MappingList.entryList]);
      this.MappingList.entryList.sort(this.inputMappingSort);
      this.MappingList.UpdateList();
      this.bSettingsChanged = true;
   }
   function onHelpItemPress()
   {
      trace("OnHelpItemPress");
      gfx.io.GameDelegate.call("RequestHelpText",[this.HelpList.selectedEntry.index,this.HelpTitleText,this.HelpText]);
      this.ApplyHelpTextButtonArt();
      this.HelpListPanel.bCloseToMainState = false;
      this.EndState();
      this.StartState(SystemPage.HELP_TEXT_STATE);
   }
   function onCreationsItemPress()
   {
      trace("OnCreationsItemPress");
      gfx.io.GameDelegate.call("RequestCreationClubText",[this.CreationsList.selectedEntry.index,this.CreationsTitleText,this.CreationsText]);
      this.ApplyCreationsTextButtonArt();
      this.CreationListPanel.bCloseToMainState = false;
      this.EndState();
      this.StartState(SystemPage.CREATIONS_TEXT_STATE);
   }
   function ApplyHelpTextButtonArt()
   {
      var _loc2_ = this.HelpButtonHolder.CreateButtonArt(this.HelpText.textField);
      if(_loc2_ != undefined)
      {
         this.HelpText.htmlText = _loc2_;
      }
   }
   function ApplyCreationsTextButtonArt()
   {
      var _loc2_ = this.CreationsButtonHolder.CreateButtonArt(this.CreationsText.textField);
      if(_loc2_ != undefined)
      {
         this.CreationsText.htmlText = _loc2_;
      }
   }
   function populateQuitList(abOnPC)
   {
      if(abOnPC)
      {
         if(this.iPlatform != 0)
         {
            this.PCQuitList.selectedIndex = 0;
         }
         this.StartState(SystemPage.PC_QUIT_LIST_STATE);
      }
      else
      {
         this.ConfirmTextField.textAutoSize = "shrink";
         this.ConfirmTextField.SetText("$Quit to main menu?  Any unsaved progress will be lost.");
         this.StartState(SystemPage.QUIT_CONFIRM_STATE);
      }
   }
   function onPCQuitButtonPress(event)
   {
      if(this.iCurrentState == SystemPage.PC_QUIT_LIST_STATE)
      {
         this.PCQuitList.disableSelection = true;
         if(event.index == 0)
         {
            this.ConfirmTextField.textAutoSize = "shrink";
            this.ConfirmTextField.SetText("$Quit to main menu?  Any unsaved progress will be lost.");
         }
         else if(event.index == 1)
         {
            this.ConfirmTextField.textAutoSize = "shrink";
            this.ConfirmTextField.SetText("$Quit to desktop?  Any unsaved progress will be lost.");
         }
         this.StartState(SystemPage.PC_QUIT_CONFIRM_STATE);
      }
   }
   function SaveControls()
   {
      clearInterval(this.iSavingSettingsTimerID);
      gfx.io.GameDelegate.call("SaveControls",[]);
   }
   function SaveSettings()
   {
      clearInterval(this.iSavingSettingsTimerID);
      gfx.io.GameDelegate.call("SaveSettings",[]);
   }
   function onSettingsSaved()
   {
      this.bSavingSettings = false;
      this.bSettingsChanged = false;
      this.ErrorText.SetText(" ");
      this.EndState();
   }
   function RefreshSystemButtons()
   {
      this.UpdateSystemButtons(true);
   }
   function refreshBottomBarButtonText(aiState)
   {
      var _loc2_;
      switch(aiState)
      {
         case SystemPage.CHARACTER_SELECTION_STATE:
            this.BottomBar_mc.SetButtonInfo(1,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
            break;
         case SystemPage.SAVE_LOAD_STATE:
            this.BottomBar_mc.SetButtonInfo(1,"$Delete",{PCArt:"X",XBoxArt:"360_X",PS3Art:"PS3_X"});
            if(!this.SaveLoadListHolder.isSaving)
            {
               this.BottomBar_mc.SetButtonInfo(2,"$CharacterSelection",{PCArt:"T",XBoxArt:"360_Y",PS3Art:"PS3_Y"});
               this.BottomBar_mc.SetButtonInfo(3,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
            }
            else
            {
               this.BottomBar_mc.SetButtonInfo(2,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
            }
            break;
         case SystemPage.INPUT_MAPPING_STATE:
            _loc2_ = 1;
            if(!this.bIsRemoteDevice)
            {
               this.BottomBar_mc.SetButtonInfo(1,"$Defaults",{PCArt:"T",XBoxArt:"360_Y",PS3Art:"PS3_Y"});
               _loc2_ = 2;
            }
            this.BottomBar_mc.SetButtonInfo(_loc2_,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
            break;
         case SystemPage.OPTIONS_LISTS_STATE:
            this.BottomBar_mc.SetButtonInfo(1,"$Defaults",{PCArt:"T",XBoxArt:"360_Y",PS3Art:"PS3_Y"});
            _loc2_ = 2;
            if(this.bShowKinectTunerButton && this.iPlatform == 2 && this.SettingsList.selectedIndex == 0)
            {
               this.BottomBar_mc.SetButtonInfo(2,"$Kinect Tuner",{PCArt:"K",XBoxArt:"360_RB",PS3Art:"PS3_RB"});
               _loc2_ = 3;
            }
            this.BottomBar_mc.SetButtonInfo(_loc2_,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
            break;
         case SystemPage.CREATIONS_TEXT_STATE:
         case SystemPage.CREATIONS_LIST_STATE:
         case SystemPage.HELP_TEXT_STATE:
         case SystemPage.HELP_LIST_STATE:
         case SystemPage.SETTINGS_CATEGORY_STATE:
            this.BottomBar_mc.SetButtonInfo(1,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
         case SystemPage.CHARACTER_LOAD_STATE:
         case SystemPage.PC_QUIT_LIST_STATE:
         case SystemPage.SAVE_LOAD_CONFIRM_STATE:
         case SystemPage.QUIT_CONFIRM_STATE:
         case SystemPage.PC_QUIT_CONFIRM_STATE:
         case SystemPage.DELETE_SAVE_CONFIRM_STATE:
         case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
         default:
            return;
      }
   }
   function StartState(aiState)
   {
      var _loc2_;
      switch(aiState)
      {
         case SystemPage.CHARACTER_LOAD_STATE:
            this.SaveLoadListHolder.isShowingCharacterList = true;
            this.SystemDivider.gotoAndStop("Left");
            gfx.io.GameDelegate.call("PopulateCharacterList",[this.SaveLoadListHolder.List_mc.entryList,this.SaveLoadListHolder.batchSize]);
            this.BottomBar_mc.SetButtonVisibility(1,false);
            this.BottomBar_mc.SetButtonVisibility(2,false);
            this.BottomBar_mc.SetButtonVisibility(3,false);
            break;
         case SystemPage.CHARACTER_SELECTION_STATE:
            this.BottomBar_mc.SetButtonInfo(1,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
            this.BottomBar_mc.SetButtonVisibility(1,true,100);
            this.BottomBar_mc.SetButtonVisibility(2,false);
            this.BottomBar_mc.SetButtonVisibility(3,false);
            break;
         case SystemPage.SAVE_LOAD_STATE:
            this.SaveLoadListHolder.isShowingCharacterList = false;
            this.SystemDivider.gotoAndStop("Left");
            this.BottomBar_mc.SetButtonInfo(1,"$Delete",{PCArt:"X",XBoxArt:"360_X",PS3Art:"PS3_X"});
            this.BottomBar_mc.SetButtonVisibility(1,true,100);
            if(!this.SaveLoadListHolder.isSaving)
            {
               this.BottomBar_mc.SetButtonInfo(2,"$CharacterSelection",{PCArt:"T",XBoxArt:"360_Y",PS3Art:"PS3_Y"});
               this.BottomBar_mc.SetButtonVisibility(2,true,100);
               this.BottomBar_mc.SetButtonInfo(3,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
               this.BottomBar_mc.SetButtonVisibility(3,true,100);
               break;
            }
            this.BottomBar_mc.SetButtonInfo(2,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
            this.BottomBar_mc.SetButtonVisibility(2,true,100);
            break;
         case SystemPage.INPUT_MAPPING_STATE:
            this.SystemDivider.gotoAndStop("Left");
            _loc2_ = 1;
            if(!this.bIsRemoteDevice)
            {
               this.BottomBar_mc.SetButtonInfo(1,"$Defaults",{PCArt:"T",XBoxArt:"360_Y",PS3Art:"PS3_Y"});
               this.BottomBar_mc.SetButtonVisibility(1,true,100);
               this.bDefaultsButtonVisible = true;
               _loc2_ = 2;
            }
            else
            {
               this.BottomBar_mc.SetButtonVisibility(2,false);
               this.bDefaultsButtonVisible = false;
            }
            this.BottomBar_mc.SetButtonInfo(_loc2_,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
            this.BottomBar_mc.SetButtonVisibility(_loc2_,true,100);
            break;
         case SystemPage.OPTIONS_LISTS_STATE:
            this.BottomBar_mc.SetButtonInfo(1,"$Defaults",{PCArt:"T",XBoxArt:"360_Y",PS3Art:"PS3_Y"});
            this.BottomBar_mc.SetButtonVisibility(1,true,100);
            this.bDefaultsButtonVisible = true;
            _loc2_ = 2;
            if(this.bShowKinectTunerButton && this.iPlatform == 2 && this.SettingsList.selectedIndex == 0)
            {
               this.BottomBar_mc.SetButtonInfo(2,"$Kinect Tuner",{PCArt:"K",XBoxArt:"360_RB",PS3Art:"PS3_RB"});
               this.BottomBar_mc.SetButtonVisibility(2,true,100);
               _loc2_ = 3;
            }
            else
            {
               this.BottomBar_mc.SetButtonVisibility(3,false);
            }
            this.BottomBar_mc.SetButtonInfo(_loc2_,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
            this.BottomBar_mc.SetButtonVisibility(_loc2_,true,100);
            break;
         case SystemPage.CREATIONS_TEXT_STATE:
         case SystemPage.CREATIONS_LIST_STATE:
         case SystemPage.HELP_TEXT_STATE:
         case SystemPage.HELP_LIST_STATE:
         case SystemPage.SETTINGS_CATEGORY_STATE:
            this.BottomBar_mc.SetButtonInfo(1,"$Cancel",{PCArt:this.CancelButtonMappedTo,XBoxArt:"360_B",PS3Art:"PS3_B"});
            this.BottomBar_mc.SetButtonVisibility(1,true,100);
         case SystemPage.PC_QUIT_LIST_STATE:
            this.SystemDivider.gotoAndStop("Left");
            break;
         case SystemPage.SAVE_LOAD_CONFIRM_STATE:
         case SystemPage.QUIT_CONFIRM_STATE:
         case SystemPage.PC_QUIT_CONFIRM_STATE:
         case SystemPage.DELETE_SAVE_CONFIRM_STATE:
         case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
            this.ConfirmPanel.confirmType = aiState;
            this.ConfirmPanel.returnState = this.iCurrentState;
      }
      this.refreshBottomBarButtonText(aiState);
      this.iCurrentState = SystemPage.TRANSITIONING;
      this.GetPanelForState(aiState).gotoAndPlay("start");
   }
   function EndState()
   {
      switch(this.iCurrentState)
      {
         case SystemPage.CHARACTER_LOAD_STATE:
         case SystemPage.CHARACTER_SELECTION_STATE:
         case SystemPage.SAVE_LOAD_STATE:
         case SystemPage.INPUT_MAPPING_STATE:
         case SystemPage.CREATIONS_TEXT_STATE:
            if(!this.IsPlatformSony())
            {
               this.SystemDivider.gotoAndStop("Right");
            }
            this.BottomBar_mc.SetButtonVisibility(1,false);
            this.BottomBar_mc.SetButtonVisibility(2,false);
            this.BottomBar_mc.SetButtonVisibility(3,false);
            break;
         case SystemPage.HELP_TEXT_STATE:
            if(!this.IsPlatformSony())
            {
               this.SystemDivider.gotoAndStop("Right");
            }
            this.BottomBar_mc.SetButtonVisibility(1,false);
            this.BottomBar_mc.SetButtonVisibility(2,false);
            this.BottomBar_mc.SetButtonVisibility(3,false);
            break;
         case SystemPage.OPTIONS_LISTS_STATE:
            this.BottomBar_mc.SetButtonVisibility(1,false);
            this.BottomBar_mc.SetButtonVisibility(2,false);
            this.BottomBar_mc.SetButtonVisibility(3,false);
            break;
         case SystemPage.CREATIONS_LIST_STATE:
            this.BottomBar_mc.SetButtonVisibility(1,false);
            this.BottomBar_mc.SetButtonVisibility(2,false);
            this.BottomBar_mc.SetButtonVisibility(3,false);
            this.CreationsList.disableInput = true;
            if(this.CreationListPanel.bCloseToMainState != false)
            {
               this.SystemDivider.gotoAndStop("Right");
            }
            break;
         case SystemPage.HELP_LIST_STATE:
            this.BottomBar_mc.SetButtonVisibility(1,false);
            this.BottomBar_mc.SetButtonVisibility(2,false);
            this.BottomBar_mc.SetButtonVisibility(3,false);
            this.HelpList.disableInput = true;
            if(this.HelpListPanel.bCloseToMainState != false)
            {
               this.SystemDivider.gotoAndStop("Right");
            }
            break;
         case SystemPage.SETTINGS_CATEGORY_STATE:
            this.BottomBar_mc.SetButtonVisibility(1,false);
            this.BottomBar_mc.SetButtonVisibility(2,false);
            this.BottomBar_mc.SetButtonVisibility(3,false);
            this.SettingsList.disableInput = true;
            if(this.SettingsPanel.bCloseToMainState != false)
            {
               this.SystemDivider.gotoAndStop("Right");
            }
            break;
         case SystemPage.PC_QUIT_LIST_STATE:
            this.SystemDivider.gotoAndStop("Right");
      }
      if(this.iCurrentState != SystemPage.MAIN_STATE)
      {
         this.GetPanelForState(this.iCurrentState).gotoAndPlay("end");
         this.iCurrentState = SystemPage.TRANSITIONING;
      }
   }
   function GetPanelForState(aiState)
   {
      switch(aiState)
      {
         case SystemPage.MAIN_STATE:
            return this.PanelRect;
         case SystemPage.SETTINGS_CATEGORY_STATE:
            return this.SettingsPanel;
         case SystemPage.OPTIONS_LISTS_STATE:
            return this.OptionsListsPanel;
         case SystemPage.INPUT_MAPPING_STATE:
            return this.InputMappingPanel;
         case SystemPage.CHARACTER_LOAD_STATE:
         case SystemPage.CHARACTER_SELECTION_STATE:
         case SystemPage.SAVE_LOAD_STATE:
            return this.SaveLoadPanel;
         case SystemPage.SAVE_LOAD_CONFIRM_STATE:
         case SystemPage.PC_QUIT_CONFIRM_STATE:
         case SystemPage.QUIT_CONFIRM_STATE:
         case SystemPage.DELETE_SAVE_CONFIRM_STATE:
         case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
            return this.ConfirmPanel;
         case SystemPage.PC_QUIT_LIST_STATE:
            return this.PCQuitPanel;
         case SystemPage.CREATIONS_LIST_STATE:
            return this.CreationListPanel;
         case SystemPage.CREATIONS_TEXT_STATE:
            return this.CreationTextPanel;
         case SystemPage.HELP_LIST_STATE:
            return this.HelpListPanel;
         case SystemPage.HELP_TEXT_STATE:
            return this.HelpTextPanel;
         default:
            return;
      }
   }
   function UpdateStateFocus(aiNewState)
   {
      this.CategoryList.disableSelection = aiNewState != SystemPage.MAIN_STATE;
      switch(aiNewState)
      {
         case SystemPage.MAIN_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.CategoryList,0);
            break;
         case SystemPage.SETTINGS_CATEGORY_STATE:
            this.SettingsList.disableInput = false;
            gfx.managers.FocusHandler.instance.setFocus(this.SettingsList,0);
            break;
         case SystemPage.OPTIONS_LISTS_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.OptionsListsPanel.OptionsLists.List_mc,0);
            break;
         case SystemPage.INPUT_MAPPING_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.MappingList,0);
            break;
         case SystemPage.CHARACTER_LOAD_STATE:
         case SystemPage.CHARACTER_SELECTION_STATE:
         case SystemPage.SAVE_LOAD_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.SaveLoadListHolder.List_mc,0);
            this.SaveLoadListHolder.List_mc.disableSelection = false;
            break;
         case SystemPage.SAVE_LOAD_CONFIRM_STATE:
         case SystemPage.QUIT_CONFIRM_STATE:
         case SystemPage.PC_QUIT_CONFIRM_STATE:
         case SystemPage.DELETE_SAVE_CONFIRM_STATE:
         case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.ConfirmPanel,0);
            break;
         case SystemPage.PC_QUIT_LIST_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.PCQuitList,0);
            this.PCQuitList.disableSelection = false;
            break;
         case SystemPage.CREATIONS_LIST_STATE:
            this.CreationsList.disableInput = false;
            gfx.managers.FocusHandler.instance.setFocus(this.CreationsList,0);
            break;
         case SystemPage.CREATIONS_TEXT_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.CreationsText,0);
            break;
         case SystemPage.HELP_LIST_STATE:
            this.HelpList.disableInput = false;
            gfx.managers.FocusHandler.instance.setFocus(this.HelpList,0);
            break;
         case SystemPage.HELP_TEXT_STATE:
            gfx.managers.FocusHandler.instance.setFocus(this.HelpText,0);
         default:
            return;
      }
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      trace("SystemPage::SetPlatform: aiPlatform " + aiPlatform.toString() + ", aSwapPS3 " + abPS3Switch.toString());
      this.iPlatform = aiPlatform;
      this.PS3Switch = abPS3Switch;
      this.ConfirmPanel.ButtonRect.AcceptGamepadButton._visible = aiPlatform != 0;
      this.ConfirmPanel.ButtonRect.CancelGamepadButton._visible = aiPlatform != 0;
      this.ConfirmPanel.ButtonRect.AcceptMouseButton._visible = aiPlatform == 0;
      this.ConfirmPanel.ButtonRect.CancelMouseButton._visible = aiPlatform == 0;
      this.BottomBar_mc.SetPlatform(aiPlatform,abPS3Switch);
      this.CategoryList.SetPlatform(aiPlatform,abPS3Switch);
      this.MappingList.SetPlatform(aiPlatform,abPS3Switch);
      this.HelpButtonHolder.SetPlatform(aiPlatform,abPS3Switch);
      this.CreationsButtonHolder.SetPlatform(aiPlatform,abPS3Switch);
      var _loc4_;
      if(aiPlatform != 0)
      {
         this.ConfirmPanel.ButtonRect.AcceptGamepadButton.SetPlatform(aiPlatform,abPS3Switch);
         this.ConfirmPanel.ButtonRect.CancelGamepadButton.SetPlatform(aiPlatform,abPS3Switch);
         this.SettingsList.selectedIndex = 0;
         this.PCQuitList.selectedIndex = 0;
         this.HelpList.selectedIndex = 0;
         this.CreationsList.selectedIndex = 0;
         this.MappingList.selectedIndex = 0;
      }
      else
      {
         _loc4_ = this.ConfirmPanel.ButtonRect.AcceptMouseButton;
         Shared.ButtonMapping.CorrectLabel(_loc4_);
         _loc4_ = this.ConfirmPanel.ButtonRect.CancelMouseButton;
         Shared.ButtonMapping.CorrectLabel(_loc4_);
      }
      this.iPlatform = aiPlatform;
      this.SaveLoadListHolder.SetPlatform(aiPlatform,abPS3Switch);
   }
   function BackOutFromLoadGame()
   {
      this.bMenuClosing = false;
      this.onCancelPress();
   }
   function SetShouldShowKinectTunerOption(abFlag)
   {
      this.bShowKinectTunerButton = abFlag == true;
   }
   function SetRemoteDevice(abIsRemoteDevice)
   {
      this.bIsRemoteDevice = abIsRemoteDevice;
      if(this.bIsRemoteDevice)
      {
         this.MappingList.entryList.clear();
      }
   }
   function UpdatePermissions()
   {
      this.UpdateSystemButtons(false);
   }
   function IsPlatformSony()
   {
      return this.iPlatform == SystemPage.CONTROLLER_ORBIS || this.iPlatform == SystemPage.CONTROLLER_PROSPERO;
   }
   function ParseVersion()
   {
      var clean = this.VersionText.text.split(" ")[0];
      var parts = clean.split(".");

      this._skyrimVersion = parseInt(parts[0]);
      this._skyrimVersionMinor = parseInt(parts[1]);
      this._skyrimVersionBuild = parseInt(parts[2]);
   }
   function IsVersionAtLeast(major, minor, build)
   {
      if(this._skyrimVersion > major) return true;
      if(this._skyrimVersion < major) return false;

      if(this._skyrimVersionMinor > minor) return true;
      if(this._skyrimVersionMinor < minor) return false;

      return this._skyrimVersionBuild >= build;
   }
   function InitializeCategoryIndices()
   {
      if (!this.bVersionInitialized) return;

      var i = 0;
      
      this.IDX_QUICKSAVE = i++;
      this.IDX_SAVE = i++;
      this.IDX_LOAD = i++;

      this.IDX_INSTALLED_CONTENT = this.IsVersionAtLeast(1, 6, 1130) ? i++ : undefined;
      this.IDX_CREATIONS = this._ShowModMenu ? i++ : undefined;

      this.IDX_SETTINGS = i++;
      this.IDX_MOD_CONFIG = i++;
      this.IDX_CONTROLS = i++;
      this.IDX_HELP = i++;
      this.IDX_QUIT = i++;
   }
   function InitializeCategoryBethesdaUI()
   {
      if (!this.bVersionInitialized) return;
      
      var isAE = this.IsVersionAtLeast(1, 6, 1130);
      if (isAE) {
         this.CategoryList.entryList.splice(this.IDX_INSTALLED_CONTENT, 0, {text:"$INSTALLED CONTENT"});
      }
      
      if(this._ShowModMenu && this.CategoryList.entryList.length > 0) {
         var label = isAE ? "$CREATIONS" : "$MOD MANAGER";
         this.CategoryList.entryList.splice(this.IDX_CREATIONS, 0, {text: label});
      }
      
      this.CategoryList.InvalidateData();
   }
   function UpdateSystemButtons(abRefreshMode)
   {
      if (!this.bVersionInitialized) return;
      
      var list = this.CategoryList.entryList;
      
      var arr = [
         list[this.IDX_QUICKSAVE],
         list[this.IDX_SAVE],
         list[this.IDX_LOAD]
      ];
      
      if (this.IDX_INSTALLED_CONTENT !== undefined) {
         arr.push(list[this.IDX_INSTALLED_CONTENT]);
      }
      
      if (this.IDX_CREATIONS !== undefined) {
         arr.push(list[this.IDX_CREATIONS]);
      }
      
      arr.push(
         list[this.IDX_SETTINGS],
         list[this.IDX_MOD_CONFIG],
         list[this.IDX_CONTROLS],
         list[this.IDX_HELP],
         list[this.IDX_QUIT],
         abRefreshMode
      );

      gfx.io.GameDelegate.call("SetSaveDisabled", arr);

      if (!abRefreshMode) {
         list[this.IDX_HELP].disabled = false;
         list[this.IDX_QUIT].disabled = false;
      }

      this.CategoryList.UpdateList();
   }
}
