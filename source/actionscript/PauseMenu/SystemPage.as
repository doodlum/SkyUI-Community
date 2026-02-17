class SystemPage extends MovieClip
{
   var BottomBar_mc;
   var CategoryList;
   var CategoryList_mc;
   var ConfirmPanel;
   var ConfirmTextField;
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
   var PanelRect;
   var SaveLoadListHolder;
   var SaveLoadPanel;
   var SettingsList;
   var SettingsPanel;
   var SystemDivider;
   var TopmostPanel;
   var VersionText;
   var _acceptButton;
   var _acceptControls;
   var _cancelButton;
   var _cancelControls;
   var _characterSelectionControls;
   var _defaultControls;
   var _deleteButton;
   var _deleteControls;
   var _kinectControls;
   var _showModMenu;
   var _skyrimVersion;
   var _skyrimVersionBuild;
   var _skyrimVersionMinor;
   var bDefaultButtonVisible;
   var bIsRemoteDevice;
   var bMenuClosing;
   var bRemapMode;
   var bSavingSettings;
   var bSettingsChanged;
   var bShowKinectTunerButton;
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
   static var HELP_LIST_STATE = 11;
   static var HELP_TEXT_STATE = 12;
   static var TRANSITIONING = 13;
   static var CHARACTER_LOAD_STATE = 14;
   static var CHARACTER_SELECTION_STATE = 15;
   static var MOD_MANAGER_BUTTON_INDEX = 3;
   static var CONTROLLER_ORBIS = 3;
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
      this.ConfirmTextField = this.ConfirmPanel.ConfirmText.textField;
      this.TopmostPanel = this.PanelRect;
      this.bUpdated = false;
      this.bRemapMode = false;
      this.bSettingsChanged = false;
      this.bMenuClosing = false;
      this.bSavingSettings = false;
      this.bShowKinectTunerButton = false;
      this.iPlatform = 0;
      this.bDefaultButtonVisible = false;
      this._showModMenu = false;
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
      this.SaveLoadListHolder.addEventListener("saveGameSelected",this,"ConfirmSaveGame");
      this.SaveLoadListHolder.addEventListener("loadGameSelected",this,"ConfirmLoadGame");
      this.SaveLoadListHolder.addEventListener("saveListCharactersPopulated",this,"OnSaveListCharactersOpenSuccess");
      this.SaveLoadListHolder.addEventListener("saveListPopulated",this,"OnSaveListOpenSuccess");
      this.SaveLoadListHolder.addEventListener("saveListOnBatchAdded",this,"OnSaveListBatchAdded");
      this.SaveLoadListHolder.addEventListener("OnCharacterSelected",this,"OnCharacterSelected");
      gfx.io.GameDelegate.addCallBack("OnSaveDataEventSaveSUCCESS",this,"OnSaveDataEventSaveSUCCESS");
      gfx.io.GameDelegate.addCallBack("OnSaveDataEventSaveCANCEL",this,"OnSaveDataEventSaveCANCEL");
      gfx.io.GameDelegate.addCallBack("OnSaveDataEventLoadCANCEL",this,"OnSaveDataEventLoadCANCEL");
      this.SaveLoadListHolder.addEventListener("saveHighlighted",this,"onSaveHighlight");
      this.SaveLoadListHolder.List_mc.addEventListener("listPress",this,"onSaveLoadListPress");
      this.CategoryList.addEventListener("itemPress",this,"onCategoryButtonPress");
      this.CategoryList.addEventListener("listPress",this,"onCategoryListPress");
      this.CategoryList.addEventListener("listMovedUp",this,"onCategoryListMoveUp");
      this.CategoryList.addEventListener("listMovedDown",this,"onCategoryListMoveDown");
      this.CategoryList.addEventListener("selectionChange",this,"onCategoryListMouseSelectionChange");
      this.CategoryList.disableInput = true;
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
      this.BottomBar_mc = this._parent._parent.BottomBar_mc;
      gfx.io.GameDelegate.addCallBack("BackOutFromLoadGame",this,"BackOutFromLoadGame");
      gfx.io.GameDelegate.addCallBack("SetRemoteDevice",this,"SetRemoteDevice");
      gfx.io.GameDelegate.addCallBack("UpdatePermissions",this,"UpdatePermissions");
   }
   function SetShowMod(bshow)
   {
      this._showModMenu = bshow;
      if(this._showModMenu && this.CategoryList.entryList && this.CategoryList.entryList.length > 0)
      {
         this.CategoryList.entryList.splice(SystemPage.MOD_MANAGER_BUTTON_INDEX,0,{text:"$MOD MANAGER"});
         this.CategoryList.InvalidateData();
      }
   }
   function startPage()
   {
      this.CategoryList.disableInput = false;
      var _loc2_;
      if(!this.bUpdated)
      {
         this.currentState = SystemPage.MAIN_STATE;
         gfx.io.GameDelegate.call("SetVersionText",[this.VersionText]);
         _loc2_ = this.VersionText.text.split(".");
         this._skyrimVersion = _loc2_[0];
         this._skyrimVersionMinor = _loc2_[1];
         this._skyrimVersionBuild = _loc2_[2];
         gfx.io.GameDelegate.call("ShouldShowKinectTunerOption",[],this,"SetShouldShowKinectTunerOption");
         this.UpdatePermissions();
         this.bUpdated = true;
      }
      else
      {
         this.UpdateStateFocus(this.iCurrentState);
      }
   }
   function endPage()
   {
      this.BottomBar_mc.buttonPanel.clearButtons();
      this.CategoryList.disableInput = true;
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
      if(this.iPlatform == SystemPage.CONTROLLER_ORBIS)
      {
         this.bMenuClosing = true;
         this.EndState();
      }
   }
   function OnSaveDataEventSaveCANCEL()
   {
      if(this.iPlatform == SystemPage.CONTROLLER_ORBIS)
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
      var _loc4_ = false;
      if(this.bRemapMode || this.bMenuClosing || this.bSavingSettings || this.iCurrentState == SystemPage.TRANSITIONING)
      {
         _loc4_ = true;
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
            _loc4_ = true;
         }
         else if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 88) && this.iCurrentState == SystemPage.SAVE_LOAD_STATE)
         {
            if(this.iPlatform == SystemPage.CONTROLLER_ORBIS)
            {
               gfx.io.GameDelegate.call("ORBISDeleteSave",[]);
            }
            else
            {
               this.ConfirmDeleteSave();
            }
            _loc4_ = true;
         }
         else if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y || details.code == 84) && this.iCurrentState == SystemPage.SAVE_LOAD_STATE && !this.SaveLoadListHolder.isSaving)
         {
            this.StartState(SystemPage.CHARACTER_LOAD_STATE);
            _loc4_ = true;
         }
         else if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y || details.code == 84) && (this.iCurrentState == SystemPage.OPTIONS_LISTS_STATE || this.iCurrentState == SystemPage.INPUT_MAPPING_STATE))
         {
            this.ConfirmTextField.SetText("$Reset settings to default values?");
            this.StartState(SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE);
            _loc4_ = true;
         }
         else if(this.bShowKinectTunerButton && details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R1 && this.iCurrentState == SystemPage.OPTIONS_LISTS_STATE)
         {
            gfx.io.GameDelegate.call("OpenKinectTuner",[]);
            _loc4_ = true;
         }
         else if(!pathToFocus[0].handleInput(details,pathToFocus.slice(1)))
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
            {
               _loc4_ = this.onAcceptPress();
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
            {
               _loc4_ = this.onCancelPress();
            }
         }
      }
      return _loc4_;
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
               if(this.iPlatform == SystemPage.CONTROLLER_ORBIS)
               {
                  if(this.SaveLoadListHolder.isSaving)
                  {
                     this.iSaveDelayTimerID = setInterval(this,"DoSaveGame",1);
                     break;
                  }
                  gfx.io.GameDelegate.call("LoadGame",[this.SaveLoadListHolder.selectedIndex]);
                  break;
               }
               this.bMenuClosing = true;
               if(this.SaveLoadListHolder.isSaving)
               {
                  this.ConfirmPanel._visible = false;
                  if(this.iPlatform > 1)
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
   function onCategoryButtonPress(event)
   {
      if(event.entry.disabled)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
         return undefined;
      }
      var _loc4_;
      if(this.iCurrentState == SystemPage.MAIN_STATE)
      {
         _loc4_ = event.index;
         if(!this._showModMenu && _loc4_ >= SystemPage.MOD_MANAGER_BUTTON_INDEX)
         {
            _loc4_ += 1;
         }
         switch(_loc4_)
         {
            case 0:
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               gfx.io.GameDelegate.call("QuickSave",[]);
               return;
            case 1:
               gfx.io.GameDelegate.call("UseCurrentCharacterFilter",[]);
               this.SaveLoadListHolder.isSaving = true;
               if(this.iPlatform == 3)
               {
                  this.SaveLoadListHolder.PopulateEmptySaveList();
                  return;
               }
               gfx.io.GameDelegate.call("SAVE",[this.SaveLoadListHolder.List_mc.entryList,this.SaveLoadListHolder.batchSize]);
               return;
               break;
            case 2:
               this.SaveLoadListHolder.isSaving = false;
               gfx.io.GameDelegate.call("LOAD",[this.SaveLoadListHolder.List_mc.entryList,this.SaveLoadListHolder.batchSize]);
               return;
            case 3:
               gfx.io.GameDelegate.call("ModManager",[]);
               return;
            case 4:
               this.StartState(SystemPage.SETTINGS_CATEGORY_STATE);
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
            case 5:
               _root.QuestJournalFader.Menu_mc.ConfigPanelOpen();
               return;
            case 6:
               if(this.MappingList.entryList.length == 0)
               {
                  this.requestInputMappings();
               }
               this.StartState(SystemPage.INPUT_MAPPING_STATE);
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
            case 7:
               if(this.HelpList.entryList.length == 0)
               {
                  gfx.io.GameDelegate.call("PopulateHelpTopics",[this.HelpList.entryList]);
                  this.HelpList.entryList.sort(this.doABCSort);
                  this.HelpList.InvalidateData();
               }
               if(this.HelpList.entryList.length == 0)
               {
                  gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
                  return;
               }
               this.StartState(SystemPage.HELP_LIST_STATE);
               gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
               return;
               break;
            case 8:
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
      if(this.iPlatform != 3)
      {
         this.StartState(SystemPage.SAVE_LOAD_STATE);
      }
   }
   function OnSaveListCharactersOpenSuccess()
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
      if(this.iPlatform != SystemPage.CONTROLLER_ORBIS)
      {
         this._parent._parent.CloseMenu();
      }
   }
   function onSaveHighlight(event)
   {
      if(this.iCurrentState == SystemPage.SAVE_LOAD_STATE && !this.SaveLoadListHolder.isShowingCharacterList)
      {
         if(this._deleteButton != null)
         {
            this._deleteButton._alpha = event.index != -1 ? 100 : 50;
         }
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
      var _loc3_;
      var _loc4_;
      var _loc5_;
      switch(this.SettingsList.selectedIndex)
      {
         case 0:
            _loc3_ = parseInt(this._skyrimVersion);
            _loc4_ = parseInt(this._skyrimVersionMinor);
            _loc5_ = parseInt(this._skyrimVersionBuild);
            if(_loc3_ > 1 || _loc3_ == 1 && _loc4_ > 6 || _loc3_ == 1 && _loc4_ == 6 && _loc5_ > 659)
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
            _loc4_ = 0;
            _loc2_.entryList = [{text:"$Master",movieType:0}];
            gfx.io.GameDelegate.call("RequestAudioOptions",[_loc2_.entryList]);
            for(_loc4_ in _loc2_.entryList)
            {
               _loc2_.entryList[_loc4_].movieType = 0;
            }
      }
      _loc3_ = 0;
      while(_loc3_ < _loc2_.entryList.length)
      {
         if(_loc2_.entryList[_loc3_].ID == undefined)
         {
            _loc2_.entryList.splice(_loc3_,1);
         }
         else
         {
            _loc3_ += 1;
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
   }
   function inputMappingSort(a_obj1, a_obj2)
   {
      if(a_obj1.sortIndex < a_obj2.sortIndex)
      {
         return -1;
      }
      if(a_obj1.sortIndex > a_obj2.sortIndex)
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
         delete this.iDebounceRemapModeID;
      }
      this.bRemapMode = false;
   }
   function ResetControlsToDefaults()
   {
      gfx.io.GameDelegate.call("ResetControlsToDefaults",[this.MappingList.entryList]);
      this.requestInputMappings(true);
      this.bSettingsChanged = true;
   }
   function onHelpItemPress()
   {
      gfx.io.GameDelegate.call("RequestHelpText",[this.HelpList.selectedEntry.index,this.HelpTitleText,this.HelpText]);
      this.ApplyHelpTextButtonArt();
      this.HelpListPanel.bCloseToMainState = false;
      this.EndState();
      this.StartState(SystemPage.HELP_TEXT_STATE);
   }
   function ApplyHelpTextButtonArt()
   {
      var _loc2_ = this.HelpButtonHolder.CreateButtonArt(this.HelpText.textField);
      if(_loc2_ != undefined)
      {
         this.HelpText.htmlText = _loc2_;
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
         return undefined;
      }
      this.ConfirmTextField.textAutoSize = "shrink";
      this.ConfirmTextField.SetText("$Quit to main menu?  Any unsaved progress will be lost.");
      this.StartState(SystemPage.QUIT_CONFIRM_STATE);
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
      if(this._showModMenu)
      {
         gfx.io.GameDelegate.call("SetSaveDisabled",[this.CategoryList.entryList[0],this.CategoryList.entryList[1],this.CategoryList.entryList[2],this.CategoryList.entryList[4],this.CategoryList.entryList[6],this.CategoryList.entryList[8],true]);
      }
      else
      {
         gfx.io.GameDelegate.call("SetSaveDisabled",[this.CategoryList.entryList[0],this.CategoryList.entryList[1],this.CategoryList.entryList[2],this.CategoryList.entryList[3],this.CategoryList.entryList[5],this.CategoryList.entryList[7],true]);
      }
      this.CategoryList.UpdateList();
   }
   function StartState(aiState)
   {
      this.BottomBar_mc.buttonPanel.clearButtons();
      switch(aiState)
      {
         case SystemPage.CHARACTER_LOAD_STATE:
            this.SaveLoadListHolder.isShowingCharacterList = true;
            this.SystemDivider.gotoAndStop("Left");
            gfx.io.GameDelegate.call("PopulateCharacterList",[this.SaveLoadListHolder.List_mc.entryList,this.SaveLoadListHolder.batchSize]);
            break;
         case SystemPage.CHARACTER_SELECTION_STATE:
            this.BottomBar_mc.buttonPanel.addButton({text:"$Cancel",controls:this._cancelControls});
            break;
         case SystemPage.SAVE_LOAD_STATE:
            this.SaveLoadListHolder.isShowingCharacterList = false;
            this.SystemDivider.gotoAndStop("Left");
            this._deleteButton = this.BottomBar_mc.buttonPanel.addButton({text:"$Delete",controls:this._deleteControls});
            if(this.SaveLoadListHolder.isSaving == false)
            {
               this.BottomBar_mc.buttonPanel.addButton({text:"$CharacterSelection",controls:this._characterSelectionControls});
            }
            this.BottomBar_mc.buttonPanel.addButton({text:"$Cancel",controls:this._cancelControls});
            this.BottomBar_mc.buttonPanel.updateButtons(true);
            break;
         case SystemPage.INPUT_MAPPING_STATE:
            this.SystemDivider.gotoAndStop("Left");
            if(this.bIsRemoteDevice)
            {
               this.bDefaultButtonVisible = false;
            }
            else
            {
               this.BottomBar_mc.buttonPanel.addButton({text:"$Defaults",controls:this._defaultControls});
               this.bDefaultButtonVisible = true;
            }
            this.BottomBar_mc.buttonPanel.addButton({text:"$Cancel",controls:this._cancelControls});
            this.BottomBar_mc.buttonPanel.updateButtons(true);
            break;
         case SystemPage.OPTIONS_LISTS_STATE:
            this.BottomBar_mc.buttonPanel.addButton({text:"$Defaults",controls:this._defaultControls});
            if(aiState == SystemPage.OPTIONS_LISTS_STATE && this.bShowKinectTunerButton && this.iPlatform == 2 && this.SettingsList.selectedIndex == 0)
            {
               this.BottomBar_mc.buttonPanel.addButton({text:"$Kinect Tuner",controls:this._kinectControls});
            }
            this.BottomBar_mc.buttonPanel.addButton({text:"$Cancel",controls:this._cancelControls});
            this.BottomBar_mc.buttonPanel.updateButtons(true);
            break;
         case SystemPage.HELP_TEXT_STATE:
         case SystemPage.HELP_LIST_STATE:
         case SystemPage.SETTINGS_CATEGORY_STATE:
            this.BottomBar_mc.buttonPanel.addButton({text:"$Cancel",controls:this._cancelControls});
            this.BottomBar_mc.buttonPanel.updateButtons(true);
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
      this.iCurrentState = SystemPage.TRANSITIONING;
      this.GetPanelForState(aiState).gotoAndPlay("start");
   }
   function EndState()
   {
      this.BottomBar_mc.buttonPanel.clearButtons();
      switch(this.iCurrentState)
      {
         case SystemPage.CHARACTER_LOAD_STATE:
         case SystemPage.CHARACTER_SELECTION_STATE:
         case SystemPage.SAVE_LOAD_STATE:
         case SystemPage.INPUT_MAPPING_STATE:
         case SystemPage.HELP_TEXT_STATE:
            if(this.iPlatform != SystemPage.CONTROLLER_ORBIS)
            {
               this.SystemDivider.gotoAndStop("Right");
            }
            break;
         case SystemPage.HELP_LIST_STATE:
            this.HelpList.disableInput = true;
            if(this.HelpListPanel.bCloseToMainState != false)
            {
               this.SystemDivider.gotoAndStop("Right");
            }
            break;
         case SystemPage.SETTINGS_CATEGORY_STATE:
            this.SettingsList.disableInput = true;
            if(this.SettingsPanel.bCloseToMainState != false)
            {
               this.SystemDivider.gotoAndStop("Right");
            }
            break;
         case SystemPage.PC_QUIT_LIST_STATE:
            this.SystemDivider.gotoAndStop("Right");
            break;
         case SystemPage.OPTIONS_LISTS_STATE:
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
         case SystemPage.SAVE_LOAD_STATE:
         case SystemPage.CHARACTER_LOAD_STATE:
         case SystemPage.CHARACTER_SELECTION_STATE:
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
   function SetPlatform(a_platform, a_bPS3Switch)
   {
      this.BottomBar_mc.SetPlatform(a_platform,a_bPS3Switch);
      this.CategoryList.SetPlatform(a_platform,a_bPS3Switch);
      if(a_platform != 0)
      {
         this.SettingsList.selectedIndex = 0;
         this.PCQuitList.selectedIndex = 0;
         this.HelpList.selectedIndex = 0;
         this.MappingList.selectedIndex = 0;
         this._deleteControls = {keyCode:278};
         this._defaultControls = {keyCode:279};
         this._kinectControls = {keyCode:275};
         this._acceptControls = {keyCode:276};
         this._cancelControls = {keyCode:277};
         this._characterSelectionControls = {keyCode:279};
      }
      else
      {
         this._deleteControls = {keyCode:45};
         this._defaultControls = {keyCode:20};
         this._kinectControls = {keyCode:37};
         this._acceptControls = {keyCode:28};
         this._cancelControls = {keyCode:15};
         this._characterSelectionControls = {keyCode:20};
      }
      this.ConfirmPanel.buttonPanel.clearButtons();
      this._acceptButton = this.ConfirmPanel.buttonPanel.addButton({text:"$Yes",controls:this._acceptControls});
      this._acceptButton.addEventListener("click",this,"onAcceptMousePress");
      this._cancelButton = this.ConfirmPanel.buttonPanel.addButton({text:"$No",controls:this._cancelControls});
      this._cancelButton.addEventListener("click",this,"onCancelMousePress");
      this.ConfirmPanel.buttonPanel.updateButtons(true);
      this.iPlatform = a_platform;
      this.SaveLoadListHolder.platform = a_platform;
      this.requestInputMappings();
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
   function SetRemoteDevice(abISRemoteDevice)
   {
      this.bIsRemoteDevice = abISRemoteDevice;
      if(this.bIsRemoteDevice)
      {
         this.MappingList.entryList.clear();
      }
   }
   function UpdatePermissions()
   {
      if(this._showModMenu)
      {
         gfx.io.GameDelegate.call("SetSaveDisabled",[this.CategoryList.entryList[0],this.CategoryList.entryList[1],this.CategoryList.entryList[2],this.CategoryList.entryList[4],this.CategoryList.entryList[6],this.CategoryList.entryList[8],false]);
         this.CategoryList.entryList[7].disabled = false;
      }
      else
      {
         gfx.io.GameDelegate.call("SetSaveDisabled",[this.CategoryList.entryList[0],this.CategoryList.entryList[1],this.CategoryList.entryList[2],this.CategoryList.entryList[3],this.CategoryList.entryList[5],this.CategoryList.entryList[7],false]);
         this.CategoryList.entryList[6].disabled = false;
      }
      this.CategoryList.UpdateList();
   }
   function requestInputMappings(a_updateOnly)
   {
      this.MappingList.entryList.splice(0);
      gfx.io.GameDelegate.call("RequestInputMappings",[this.MappingList.entryList]);
      this.MappingList.entryList.sort(this.inputMappingSort);
      if(a_updateOnly)
      {
         this.MappingList.UpdateList();
      }
      else
      {
         this.MappingList.InvalidateData();
      }
   }
}
