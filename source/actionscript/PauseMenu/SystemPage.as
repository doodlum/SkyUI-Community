class SystemPage extends MovieClip
{
	/* CONSTANTS */

	public static var MAIN_STATE = 0;
	public static var SAVE_LOAD_STATE = 1;
	public static var SAVE_LOAD_CONFIRM_STATE = 2;
	public static var SETTINGS_CATEGORY_STATE = 3;
	public static var OPTIONS_LISTS_STATE = 4;
	public static var DEFAULT_SETTINGS_CONFIRM_STATE = 5;
	public static var INPUT_MAPPING_STATE = 6;
	public static var QUIT_CONFIRM_STATE = 7;
	public static var PC_QUIT_LIST_STATE = 8;
	public static var PC_QUIT_CONFIRM_STATE = 9;
	public static var DELETE_SAVE_CONFIRM_STATE = 10;
	public static var HELP_LIST_STATE = 11;
	public static var HELP_TEXT_STATE = 12;
	public static var TRANSITIONING = 13;
	public static var CHARACTER_LOAD_STATE = 14;
	public static var CHARACTER_SELECTION_STATE = 15;
	public static var MOD_MANAGER_BUTTON_INDEX = 3;
	public static var CONTROLLER_ORBIS = 3;

	/* STAGE ELEMENTS */

	var BottomBar_mc;
	var CategoryList;
	var CategoryList_mc;
	var ConfirmPanel;
	var HelpButtonHolder;
	var HelpList;
	var HelpListPanel;
	var HelpTextPanel;
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

	var ConfirmTextField;
	var ErrorText;
	var HelpText;
	var HelpTitleText;
	var VersionText;

	/* PRIVATE VARIABLES */

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

	private var _acceptButton;
	private var _cancelButton;
	private var _deleteButton;

	private var _acceptControls;
	private var _cancelControls;
	private var _characterSelectionControls;
	private var _defaultControls;
	private var _deleteControls;
	private var _kinectControls;

	private var _showModMenu;
	private var _skyrimVersion;
	private var _skyrimVersionMinor;
	private var _skyrimVersionBuild;

	/* CONSTRUCTOR */

	public function SystemPage()
	{
		super();
		CategoryList = CategoryList_mc.List_mc;
		SaveLoadListHolder = SaveLoadPanel;
		SettingsList = SettingsPanel.List_mc;
		MappingList = InputMappingPanel.List_mc;
		PCQuitList = PCQuitPanel.List_mc;
		HelpList = HelpListPanel.List_mc;
		HelpText = HelpTextPanel.HelpTextHolder.HelpText;
		HelpButtonHolder = HelpTextPanel.HelpTextHolder.ButtonArtHolder;
		HelpTitleText = HelpTextPanel.HelpTextHolder.TitleText;
		ConfirmTextField = ConfirmPanel.ConfirmText.textField;
		TopmostPanel = PanelRect;
		bUpdated = false;
		bRemapMode = false;
		bSettingsChanged = false;
		bMenuClosing = false;
		bSavingSettings = false;
		bShowKinectTunerButton = false;
		iPlatform = 0;
		bDefaultButtonVisible = false;
		_showModMenu = false;
	}

	/* PUBLIC FUNCTIONS */

	public function GetIsRemoteDevice()
	{
		return bIsRemoteDevice;
	}

	public function onLoad()
	{
		CategoryList.entryList.push({text: "$QUICKSAVE"});
		CategoryList.entryList.push({text: "$SAVE"});
		CategoryList.entryList.push({text: "$LOAD"});
		CategoryList.entryList.push({text: "$SETTINGS"});
		CategoryList.entryList.push({text: "$MOD CONFIGURATION"});
		CategoryList.entryList.push({text: "$CONTROLS"});
		CategoryList.entryList.push({text: "$HELP"});
		CategoryList.entryList.push({text: "$QUIT"});
		CategoryList.InvalidateData();

		ConfirmPanel.handleInput = function() {
			return false;
		};

		SaveLoadListHolder.addEventListener("saveGameSelected", this, "ConfirmSaveGame");
		SaveLoadListHolder.addEventListener("loadGameSelected", this, "ConfirmLoadGame");
		SaveLoadListHolder.addEventListener("saveListCharactersPopulated", this, "OnSaveListCharactersOpenSuccess");
		SaveLoadListHolder.addEventListener("saveListPopulated", this, "OnSaveListOpenSuccess");
		SaveLoadListHolder.addEventListener("saveListOnBatchAdded", this, "OnSaveListBatchAdded");
		SaveLoadListHolder.addEventListener("OnCharacterSelected", this, "OnCharacterSelected");

		gfx.io.GameDelegate.addCallBack("OnSaveDataEventSaveSUCCESS", this, "OnSaveDataEventSaveSUCCESS");
		gfx.io.GameDelegate.addCallBack("OnSaveDataEventSaveCANCEL", this, "OnSaveDataEventSaveCANCEL");
		gfx.io.GameDelegate.addCallBack("OnSaveDataEventLoadCANCEL", this, "OnSaveDataEventLoadCANCEL");

		SaveLoadListHolder.addEventListener("saveHighlighted", this, "onSaveHighlight");
		SaveLoadListHolder.List_mc.addEventListener("listPress", this, "onSaveLoadListPress");

		CategoryList.addEventListener("itemPress", this, "onCategoryButtonPress");
		CategoryList.addEventListener("listPress", this, "onCategoryListPress");
		CategoryList.addEventListener("listMovedUp", this, "onCategoryListMoveUp");
		CategoryList.addEventListener("listMovedDown", this, "onCategoryListMoveDown");
		CategoryList.addEventListener("selectionChange", this, "onCategoryListMouseSelectionChange");
		CategoryList.disableInput = true;

		SettingsList.entryList = [{text: "$Gameplay"}, {text: "$Display"}, {text: "$Audio"}];
		SettingsList.InvalidateData();
		SettingsList.addEventListener("itemPress", this, "onSettingsCategoryPress");
		SettingsList.disableInput = true;

		InputMappingPanel.List_mc.addEventListener("itemPress", this, "onInputMappingPress");

		gfx.io.GameDelegate.addCallBack("FinishRemapMode", this, "onFinishRemapMode");
		gfx.io.GameDelegate.addCallBack("SettingsSaved", this, "onSettingsSaved");
		gfx.io.GameDelegate.addCallBack("RefreshSystemButtons", this, "RefreshSystemButtons");

		PCQuitList.entryList = [{text: "$Main Menu"}, {text: "$Desktop"}];
		PCQuitList.UpdateList();
		PCQuitList.addEventListener("itemPress", this, "onPCQuitButtonPress");

		HelpList.addEventListener("itemPress", this, "onHelpItemPress");
		HelpList.disableInput = true;
		HelpTitleText.textAutoSize = "shrink";

		BottomBar_mc = _parent._parent.BottomBar_mc;

		gfx.io.GameDelegate.addCallBack("BackOutFromLoadGame", this, "BackOutFromLoadGame");
		gfx.io.GameDelegate.addCallBack("SetRemoteDevice", this, "SetRemoteDevice");
		gfx.io.GameDelegate.addCallBack("UpdatePermissions", this, "UpdatePermissions");
	}

	public function SetShowMod(bshow)
	{
		_showModMenu = bshow;
		if (_showModMenu && CategoryList.entryList && CategoryList.entryList.length > 0) {
			CategoryList.entryList.splice(SystemPage.MOD_MANAGER_BUTTON_INDEX, 0, {text: "$MOD MANAGER"});
			CategoryList.InvalidateData();
		}
	}

	public function startPage()
	{
		CategoryList.disableInput = false;
		var versionArr;
		if (!bUpdated) {
			currentState = SystemPage.MAIN_STATE;
			gfx.io.GameDelegate.call("SetVersionText", [VersionText]);
			versionArr = VersionText.text.split(".");
			_skyrimVersion = versionArr[0];
			_skyrimVersionMinor = versionArr[1];
			_skyrimVersionBuild = versionArr[2];
			gfx.io.GameDelegate.call("ShouldShowKinectTunerOption", [], this, "SetShouldShowKinectTunerOption");
			UpdatePermissions();
			bUpdated = true;
		} else {
			UpdateStateFocus(iCurrentState);
		}
	}

	public function endPage()
	{
		BottomBar_mc.buttonPanel.clearButtons();
		CategoryList.disableInput = true;
	}

	public function get currentState()
	{
		return iCurrentState;
	}

	public function set currentState(aiNewState)
	{
		if (aiNewState == undefined) {
			return;
		}
		if (aiNewState == SystemPage.MAIN_STATE) {
			SaveLoadListHolder.isShowingCharacterList = false;
		} else if (aiNewState == SystemPage.SAVE_LOAD_STATE && SaveLoadListHolder.isShowingCharacterList) {
			aiNewState = SystemPage.CHARACTER_SELECTION_STATE;
		}
		var panel = GetPanelForState(aiNewState);
		iCurrentState = aiNewState;
		if (panel != TopmostPanel) {
			panel.swapDepths(TopmostPanel);
			TopmostPanel = panel;
		}
		UpdateStateFocus(aiNewState);
	}

	public function OnSaveDataEventSaveSUCCESS()
	{
		if (iPlatform == SystemPage.CONTROLLER_ORBIS) {
			bMenuClosing = true;
			EndState();
		}
	}

	public function OnSaveDataEventSaveCANCEL()
	{
		if (iPlatform == SystemPage.CONTROLLER_ORBIS) {
			HideErrorText();
			EndState();
			StartState(SystemPage.SAVE_LOAD_STATE);
		}
	}

	public function OnSaveDataEventLoadCANCEL()
	{
		StartState(SystemPage.CHARACTER_SELECTION_STATE);
	}

	public function handleInput(details, pathToFocus)
	{
		var bHandledInput = false;
		if (bRemapMode || bMenuClosing || bSavingSettings || iCurrentState == SystemPage.TRANSITIONING) {
			bHandledInput = true;
		} else if (Shared.GlobalFunc.IsKeyPressed(details, iCurrentState != SystemPage.INPUT_MAPPING_STATE)) {
			if (iCurrentState != SystemPage.OPTIONS_LISTS_STATE) {
				if (details.navEquivalent == gfx.ui.NavigationCode.RIGHT && iCurrentState == SystemPage.MAIN_STATE) {
					details.navEquivalent = gfx.ui.NavigationCode.ENTER;
				} else if (details.navEquivalent == gfx.ui.NavigationCode.LEFT && iCurrentState != SystemPage.MAIN_STATE) {
					details.navEquivalent = gfx.ui.NavigationCode.TAB;
				}
			}
			if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_L2 || details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R2) && isConfirming()) {
				bHandledInput = true;
			} else if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 88) && iCurrentState == SystemPage.SAVE_LOAD_STATE) {
				if (iPlatform == SystemPage.CONTROLLER_ORBIS) {
					gfx.io.GameDelegate.call("ORBISDeleteSave", []);
				} else {
					ConfirmDeleteSave();
				}
				bHandledInput = true;
			} else if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y || details.code == 84) && iCurrentState == SystemPage.SAVE_LOAD_STATE && !SaveLoadListHolder.isSaving) {
				StartState(SystemPage.CHARACTER_LOAD_STATE);
				bHandledInput = true;
			} else if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_Y || details.code == 84) && (iCurrentState == SystemPage.OPTIONS_LISTS_STATE || iCurrentState == SystemPage.INPUT_MAPPING_STATE)) {
				ConfirmTextField.SetText("$Reset settings to default values?");
				StartState(SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE);
				bHandledInput = true;
			} else if (bShowKinectTunerButton && details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R1 && iCurrentState == SystemPage.OPTIONS_LISTS_STATE) {
				gfx.io.GameDelegate.call("OpenKinectTuner", []);
				bHandledInput = true;
			} else if (!pathToFocus[0].handleInput(details, pathToFocus.slice(1))) {
				if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
					bHandledInput = onAcceptPress();
				} else if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
					bHandledInput = onCancelPress();
				}
			}
		}
		return bHandledInput;
	}

	public function onAcceptPress()
	{
		var bAcceptPressed = true;
		switch (iCurrentState) {
			case SystemPage.CHARACTER_SELECTION_STATE:
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
				gfx.io.GameDelegate.call("CharacterSelected", [SaveLoadListHolder.selectedIndex]);
				break;
			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.TRANSITIONING:
				if (SaveLoadListHolder.List_mc.disableSelection) {
					gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
					if (iPlatform == SystemPage.CONTROLLER_ORBIS) {
						if (SaveLoadListHolder.isSaving) {
							iSaveDelayTimerID = setInterval(this, "DoSaveGame", 1);
							break;
						}
						gfx.io.GameDelegate.call("LoadGame", [SaveLoadListHolder.selectedIndex]);
						break;
					}
					bMenuClosing = true;
					if (SaveLoadListHolder.isSaving) {
						ConfirmPanel._visible = false;
						if (iPlatform > 1) {
							ErrorText.SetText("$Saving content. Please don\'t turn off your console.");
						} else {
							ErrorText.SetText("$Saving...");
						}
						iSaveDelayTimerID = setInterval(this, "DoSaveGame", 1);
						break;
					}
					gfx.io.GameDelegate.call("LoadGame", [SaveLoadListHolder.selectedIndex]);
				}
				break;
			case SystemPage.QUIT_CONFIRM_STATE:
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
				gfx.io.GameDelegate.call("QuitToMainMenu", []);
				bMenuClosing = true;
				break;
			case SystemPage.PC_QUIT_CONFIRM_STATE:
				if (PCQuitList.selectedIndex == 0) {
					gfx.io.GameDelegate.call("QuitToMainMenu", []);
					bMenuClosing = true;
					break;
				}
				if (PCQuitList.selectedIndex == 1) {
					gfx.io.GameDelegate.call("QuitToDesktop", []);
				}
				break;
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
				SaveLoadListHolder.DeleteSelectedSave();
				if (SaveLoadListHolder.numSaves == 0) {
					GetPanelForState(SystemPage.SAVE_LOAD_STATE).gotoAndStop(1);
					GetPanelForState(SystemPage.DELETE_SAVE_CONFIRM_STATE).gotoAndStop(1);
					currentState = SystemPage.MAIN_STATE;
					SystemDivider.gotoAndStop("Right");
					break;
				}
				EndState();
				break;
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
				if (ConfirmPanel.returnState == SystemPage.OPTIONS_LISTS_STATE) {
					ResetSettingsToDefaults();
				} else if (ConfirmPanel.returnState == SystemPage.INPUT_MAPPING_STATE) {
					ResetControlsToDefaults();
				}
				EndState();
				break;
			default:
				bAcceptPressed = false;
		}
		return bAcceptPressed;
	}

	public function onCancelPress()
	{
		var bCancelPressed = true;
		switch (iCurrentState) {
			case SystemPage.CHARACTER_LOAD_STATE:
			case SystemPage.CHARACTER_SELECTION_STATE:
			case SystemPage.SAVE_LOAD_STATE:
				SaveLoadListHolder.ForceStopLoading();
			case SystemPage.PC_QUIT_LIST_STATE:
			case SystemPage.HELP_LIST_STATE:
			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.QUIT_CONFIRM_STATE:
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
			case SystemPage.PC_QUIT_CONFIRM_STATE:
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				EndState();
				break;
			case SystemPage.HELP_TEXT_STATE:
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				EndState();
				StartState(SystemPage.HELP_LIST_STATE);
				HelpListPanel.bCloseToMainState = true;
				break;
			case SystemPage.OPTIONS_LISTS_STATE:
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				EndState();
				StartState(SystemPage.SETTINGS_CATEGORY_STATE);
				SettingsPanel.bCloseToMainState = true;
				break;
			case SystemPage.INPUT_MAPPING_STATE:
			case SystemPage.SETTINGS_CATEGORY_STATE:
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				if (bSettingsChanged) {
					ErrorText.SetText("$Saving...");
					bSavingSettings = true;
					if (iCurrentState == SystemPage.INPUT_MAPPING_STATE) {
						iSavingSettingsTimerID = setInterval(this, "SaveControls", 1000);
						break;
					}
					if (iCurrentState == SystemPage.SETTINGS_CATEGORY_STATE) {
						iSavingSettingsTimerID = setInterval(this, "SaveSettings", 1000);
					}
					break;
				}
				onSettingsSaved();
				break;
			default:
				bCancelPressed = false;
		}
		return bCancelPressed;
	}

	public function isConfirming()
	{
		return iCurrentState == SystemPage.SAVE_LOAD_CONFIRM_STATE || iCurrentState == SystemPage.QUIT_CONFIRM_STATE || iCurrentState == SystemPage.PC_QUIT_CONFIRM_STATE || iCurrentState == SystemPage.DELETE_SAVE_CONFIRM_STATE || iCurrentState == SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE;
	}

	public function onAcceptMousePress()
	{
		if (isConfirming()) {
			onAcceptPress();
		}
	}

	public function onCancelMousePress()
	{
		if (isConfirming()) {
			onCancelPress();
		}
	}

	public function onCategoryButtonPress(event)
	{
		if (event.entry.disabled) {
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			return undefined;
		}

		var iIndex;
		if (iCurrentState == SystemPage.MAIN_STATE) {
			iIndex = event.index;
			if (!_showModMenu && iIndex >= SystemPage.MOD_MANAGER_BUTTON_INDEX) {
				iIndex += 1;
			}
			switch (iIndex) {
				case 0:
					gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
					gfx.io.GameDelegate.call("QuickSave", []);
					return;
				case 1:
					gfx.io.GameDelegate.call("UseCurrentCharacterFilter", []);
					SaveLoadListHolder.isSaving = true;
					if (iPlatform == 3) {
						SaveLoadListHolder.PopulateEmptySaveList();
						return;
					}
					gfx.io.GameDelegate.call("SAVE", [SaveLoadListHolder.List_mc.entryList, SaveLoadListHolder.batchSize]);
					return;
					break;
				case 2:
					SaveLoadListHolder.isSaving = false;
					gfx.io.GameDelegate.call("LOAD", [SaveLoadListHolder.List_mc.entryList, SaveLoadListHolder.batchSize]);
					return;
				case 3:
					gfx.io.GameDelegate.call("ModManager", []);
					return;
				case 4:
					StartState(SystemPage.SETTINGS_CATEGORY_STATE);
					gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
					return;
				case 5:
					_root.QuestJournalFader.Menu_mc.ConfigPanelOpen();
					return;
				case 6:
					if (MappingList.entryList.length == 0) {
						requestInputMappings();
					}
					StartState(SystemPage.INPUT_MAPPING_STATE);
					gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
					return;
				case 7:
					if (HelpList.entryList.length == 0) {
						gfx.io.GameDelegate.call("PopulateHelpTopics", [HelpList.entryList]);
						HelpList.entryList.sort(doABCSort);
						HelpList.InvalidateData();
					}
					if (HelpList.entryList.length == 0) {
						gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
						return;
					}
					StartState(SystemPage.HELP_LIST_STATE);
					gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
					return;
					break;
				case 8:
					gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
					gfx.io.GameDelegate.call("RequestIsOnPC", [], this, "populateQuitList");
					return;
				default:
					gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
					return;
			}
		}
	}

	public function onCategoryListPress(event)
	{
		if (!bRemapMode && !bMenuClosing && !bSavingSettings && iCurrentState != SystemPage.TRANSITIONING) {
			onCancelPress();
			CategoryList.disableSelection = false;
			CategoryList.UpdateList();
			CategoryList.disableSelection = true;
		}
	}

	public function OnCharacterSelected()
	{
		if (iPlatform != 3) {
			StartState(SystemPage.SAVE_LOAD_STATE);
		}
	}

	public function OnSaveListCharactersOpenSuccess()
	{
		if (SaveLoadListHolder.numSaves > 0) {
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
			StartState(SystemPage.CHARACTER_SELECTION_STATE);
		} else {
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		}
	}

	public function OnSaveListOpenSuccess()
	{
		if (SaveLoadListHolder.numSaves > 0) {
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
			StartState(SystemPage.SAVE_LOAD_STATE);
		} else {
			StartState(SystemPage.CHARACTER_LOAD_STATE);
		}
	}

	public function OnSaveListBatchAdded()
	{
	}

	public function ConfirmSaveGame(event)
	{
		SaveLoadListHolder.List_mc.disableSelection = true;
		if (iCurrentState == SystemPage.SAVE_LOAD_STATE) {
			if (event.index == 0) {
				iCurrentState = SystemPage.SAVE_LOAD_CONFIRM_STATE;
				onAcceptPress();
			} else {
				ConfirmTextField.SetText("$Save over this game?");
				StartState(SystemPage.SAVE_LOAD_CONFIRM_STATE);
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
			}
		}
	}

	public function DoSaveGame()
	{
		clearInterval(iSaveDelayTimerID);
		gfx.io.GameDelegate.call("SaveGame", [SaveLoadListHolder.selectedIndex]);
		if (iPlatform != SystemPage.CONTROLLER_ORBIS) {
			_parent._parent.CloseMenu();
		}
	}

	public function onSaveHighlight(event)
	{
		if (iCurrentState == SystemPage.SAVE_LOAD_STATE && !SaveLoadListHolder.isShowingCharacterList) {
			if (_deleteButton != null) {
				_deleteButton._alpha = event.index != -1 ? 100 : 50;
			}
			if (iPlatform == 0) {
				gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
			}
		}
	}

	public function onSaveLoadListPress()
	{
		onAcceptPress();
	}

	public function ConfirmLoadGame(event)
	{
		SaveLoadListHolder.List_mc.disableSelection = true;
		if (iCurrentState == SystemPage.SAVE_LOAD_STATE) {
			ConfirmTextField.SetText("$Load this game? All unsaved progress will be lost.");
			StartState(SystemPage.SAVE_LOAD_CONFIRM_STATE);
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
		}
	}

	public function ConfirmDeleteSave()
	{
		if (!SaveLoadListHolder.isSaving || SaveLoadListHolder.selectedIndex != 0) {
			SaveLoadListHolder.List_mc.disableSelection = true;
			if (iCurrentState == SystemPage.SAVE_LOAD_STATE) {
				ConfirmTextField.SetText("$Delete this save?");
				StartState(SystemPage.DELETE_SAVE_CONFIRM_STATE);
			}
		}
	}

	public function onSettingsCategoryPress()
	{
		var optionsList = OptionsListsPanel.OptionsLists.List_mc;
		var iVersion;
		var iVersionMinor;
		var iVersionBuild;
		switch (SettingsList.selectedIndex) {
			case 0:
				iVersion = parseInt(_skyrimVersion);
				iVersionMinor = parseInt(_skyrimVersionMinor);
				iVersionBuild = parseInt(_skyrimVersionBuild);
				if (iVersion > 1 || iVersion == 1 && iVersionMinor > 6 || iVersion == 1 && iVersionMinor == 6 && iVersionBuild > 659) {
					optionsList.entryList = [{text: "$Invert Y", movieType: 2}, {text: "$Look Sensitivity", movieType: 0}, {text: "$Vibration", movieType: 2}, {text: "$360 Controller", movieType: 2}, {text: "$SaveGameMissingCreationsCheck", movieType: 2}, {text: "$Survival Mode", movieType: 2}, {text: "$Difficulty", movieType: 1, options: ["$Very Easy", "$Easy", "$Normal", "$Hard", "$Very Hard", "$Legendary"]}, {text: "$Show Floating Markers", movieType: 2}, {text: "$Save on Rest", movieType: 2}, {text: "$Save on Wait", movieType: 2}, {text: "$Save on Travel", movieType: 2}, {text: "$Save on Pause", movieType: 1, options: ["$5 Mins", "$10 Mins", "$15 Mins", "$30 Mins", "$45 Mins", "$60 Mins", "$Disabled"]}, {text: "$Use Kinect Commands", movieType: 2}];
				} else {
					optionsList.entryList = [{text: "$Invert Y", movieType: 2}, {text: "$Look Sensitivity", movieType: 0}, {text: "$Vibration", movieType: 2}, {text: "$360 Controller", movieType: 2}, {text: "$Survival Mode", movieType: 2}, {text: "$Difficulty", movieType: 1, options: ["$Very Easy", "$Easy", "$Normal", "$Hard", "$Very Hard", "$Legendary"]}, {text: "$Show Floating Markers", movieType: 2}, {text: "$Save on Rest", movieType: 2}, {text: "$Save on Wait", movieType: 2}, {text: "$Save on Travel", movieType: 2}, {text: "$Save on Pause", movieType: 1, options: ["$5 Mins", "$10 Mins", "$15 Mins", "$30 Mins", "$45 Mins", "$60 Mins", "$Disabled"]}, {text: "$Use Kinect Commands", movieType: 2}];
				}
				gfx.io.GameDelegate.call("RequestGameplayOptions", [optionsList.entryList]);
				break;
			case 1:
				optionsList.entryList = [{text: "$Brightness", movieType: 0}, {text: "$HUD Opacity", movieType: 0}, {text: "$Actor Fade", movieType: 0}, {text: "$Item Fade", movieType: 0}, {text: "$Object Fade", movieType: 0}, {text: "$Grass Fade", movieType: 0}, {text: "$Shadow Fade", movieType: 0}, {text: "$Light Fade", movieType: 0}, {text: "$Specularity Fade", movieType: 0}, {text: "$Tree LOD Fade", movieType: 0}, {text: "$Crosshair", movieType: 2}, {text: "$Dialogue Subtitles", movieType: 2}, {text: "$General Subtitles", movieType: 2}, {text: "$DDOF Intensity", movieType: 0}];
				gfx.io.GameDelegate.call("RequestDisplayOptions", [optionsList.entryList]);
				break;
			case 2:
				iVersionMinor = 0;
				optionsList.entryList = [{text: "$Master", movieType: 0}];
				gfx.io.GameDelegate.call("RequestAudioOptions", [optionsList.entryList]);
				for (iVersionMinor in optionsList.entryList) {
					optionsList.entryList[iVersionMinor].movieType = 0;
				}
		}

		iVersion = 0;
		while (iVersion < optionsList.entryList.length) {
			if (optionsList.entryList[iVersion].ID == undefined) {
				optionsList.entryList.splice(iVersion, 1);
			} else {
				iVersion += 1;
			}
		}

		if (iPlatform != 0) {
			optionsList.selectedIndex = 0;
		}
		optionsList.InvalidateData();
		SettingsPanel.bCloseToMainState = false;
		EndState();
		StartState(SystemPage.OPTIONS_LISTS_STATE);
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
		bSettingsChanged = true;
	}

	public function ResetSettingsToDefaults()
	{
		var optionsList = OptionsListsPanel.OptionsLists.List_mc;
		for (var i in optionsList.entryList) {
			if (optionsList.entryList[i].defaultVal != undefined) {
				optionsList.entryList[i].value = optionsList.entryList[i].defaultVal;
				gfx.io.GameDelegate.call("OptionChange", [optionsList.entryList[i].ID, optionsList.entryList[i].value]);
			}
		}
		optionsList.bAllowValueOverwrite = true;
		optionsList.UpdateList();
		optionsList.bAllowValueOverwrite = false;
	}

	public function onInputMappingPress(event)
	{
		if (bRemapMode == false && iCurrentState == SystemPage.INPUT_MAPPING_STATE) {
			MappingList.disableSelection = true;
			bRemapMode = true;
			ErrorText.SetText("$Press a button to map to this action.");
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
			gfx.io.GameDelegate.call("StartRemapMode", [event.entry.text, MappingList.entryList]);
		}
	}

	public function onFinishRemapMode(abSuccess)
	{
		if (abSuccess) {
			HideErrorText();
			MappingList.entryList.sort(inputMappingSort);
			MappingList.UpdateList();
			bSettingsChanged = true;
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		} else {
			ErrorText.SetText("$That button is reserved.");
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
			iHideErrorTextID = setInterval(this, "HideErrorText", 1000);
		}
		MappingList.disableSelection = false;
		iDebounceRemapModeID = setInterval(this, "ClearRemapMode", 200);
	}

	public function HideErrorText()
	{
		if (iHideErrorTextID != undefined) {
			clearInterval(iHideErrorTextID);
		}
		ErrorText.SetText(" ");
	}

	public function ClearRemapMode()
	{
		if (iDebounceRemapModeID != undefined) {
			clearInterval(iDebounceRemapModeID);
			delete iDebounceRemapModeID;
		}
		bRemapMode = false;
	}

	public function ResetControlsToDefaults()
	{
		gfx.io.GameDelegate.call("ResetControlsToDefaults", [MappingList.entryList]);
		requestInputMappings(true);
		bSettingsChanged = true;
	}

	public function onHelpItemPress()
	{
		gfx.io.GameDelegate.call("RequestHelpText", [HelpList.selectedEntry.index, HelpTitleText, HelpText]);
		ApplyHelpTextButtonArt();
		HelpListPanel.bCloseToMainState = false;
		EndState();
		StartState(SystemPage.HELP_TEXT_STATE);
	}

	public function ApplyHelpTextButtonArt()
	{
		var strTextWithButtons = HelpButtonHolder.CreateButtonArt(HelpText.textField);
		if (strTextWithButtons != undefined) {
			HelpText.htmlText = strTextWithButtons;
		}
	}

	public function populateQuitList(abOnPC)
	{
		if (abOnPC) {
			if (iPlatform != 0) {
				PCQuitList.selectedIndex = 0;
			}
			StartState(SystemPage.PC_QUIT_LIST_STATE);
			return undefined;
		}
		ConfirmTextField.textAutoSize = "shrink";
		ConfirmTextField.SetText("$Quit to main menu?  Any unsaved progress will be lost.");
		StartState(SystemPage.QUIT_CONFIRM_STATE);
	}

	public function onPCQuitButtonPress(event)
	{
		if (iCurrentState == SystemPage.PC_QUIT_LIST_STATE) {
			PCQuitList.disableSelection = true;
			if (event.index == 0) {
				ConfirmTextField.textAutoSize = "shrink";
				ConfirmTextField.SetText("$Quit to main menu?  Any unsaved progress will be lost.");
			} else if (event.index == 1) {
				ConfirmTextField.textAutoSize = "shrink";
				ConfirmTextField.SetText("$Quit to desktop?  Any unsaved progress will be lost.");
			}
			StartState(SystemPage.PC_QUIT_CONFIRM_STATE);
		}
	}

	public function SaveControls()
	{
		clearInterval(iSavingSettingsTimerID);
		gfx.io.GameDelegate.call("SaveControls", []);
	}

	public function SaveSettings()
	{
		clearInterval(iSavingSettingsTimerID);
		gfx.io.GameDelegate.call("SaveSettings", []);
	}

	public function onSettingsSaved()
	{
		bSavingSettings = false;
		bSettingsChanged = false;
		ErrorText.SetText(" ");
		EndState();
	}

	public function RefreshSystemButtons()
	{
		if (_showModMenu) {
			gfx.io.GameDelegate.call("SetSaveDisabled", [CategoryList.entryList[0], CategoryList.entryList[1], CategoryList.entryList[2], CategoryList.entryList[4], CategoryList.entryList[6], CategoryList.entryList[8], true]);
		} else {
			gfx.io.GameDelegate.call("SetSaveDisabled", [CategoryList.entryList[0], CategoryList.entryList[1], CategoryList.entryList[2], CategoryList.entryList[3], CategoryList.entryList[5], CategoryList.entryList[7], true]);
		}
		CategoryList.UpdateList();
	}

	public function StartState(aiState)
	{
		BottomBar_mc.buttonPanel.clearButtons();
		switch (aiState) {
			case SystemPage.CHARACTER_LOAD_STATE:
				SaveLoadListHolder.isShowingCharacterList = true;
				SystemDivider.gotoAndStop("Left");
				gfx.io.GameDelegate.call("PopulateCharacterList", [SaveLoadListHolder.List_mc.entryList, SaveLoadListHolder.batchSize]);
				break;
			case SystemPage.CHARACTER_SELECTION_STATE:
				BottomBar_mc.buttonPanel.addButton({text: "$Cancel", controls: _cancelControls});
				break;
			case SystemPage.SAVE_LOAD_STATE:
				SaveLoadListHolder.isShowingCharacterList = false;
				SystemDivider.gotoAndStop("Left");
				_deleteButton = BottomBar_mc.buttonPanel.addButton({text: "$Delete", controls: _deleteControls});
				if (SaveLoadListHolder.isSaving == false) {
					BottomBar_mc.buttonPanel.addButton({text: "$CharacterSelection", controls: _characterSelectionControls});
				}
				BottomBar_mc.buttonPanel.addButton({text: "$Cancel", controls: _cancelControls});
				BottomBar_mc.buttonPanel.updateButtons(true);
				break;
			case SystemPage.INPUT_MAPPING_STATE:
				SystemDivider.gotoAndStop("Left");
				if (bIsRemoteDevice) {
					bDefaultButtonVisible = false;
				} else {
					BottomBar_mc.buttonPanel.addButton({text: "$Defaults", controls: _defaultControls});
					bDefaultButtonVisible = true;
				}
				BottomBar_mc.buttonPanel.addButton({text: "$Cancel", controls: _cancelControls});
				BottomBar_mc.buttonPanel.updateButtons(true);
				break;
			case SystemPage.OPTIONS_LISTS_STATE:
				BottomBar_mc.buttonPanel.addButton({text: "$Defaults", controls: _defaultControls});
				if (aiState == SystemPage.OPTIONS_LISTS_STATE && bShowKinectTunerButton && iPlatform == 2 && SettingsList.selectedIndex == 0) {
					BottomBar_mc.buttonPanel.addButton({text: "$Kinect Tuner", controls: _kinectControls});
				}
				BottomBar_mc.buttonPanel.addButton({text: "$Cancel", controls: _cancelControls});
				BottomBar_mc.buttonPanel.updateButtons(true);
				break;
			case SystemPage.HELP_TEXT_STATE:
			case SystemPage.HELP_LIST_STATE:
			case SystemPage.SETTINGS_CATEGORY_STATE:
				BottomBar_mc.buttonPanel.addButton({text: "$Cancel", controls: _cancelControls});
				BottomBar_mc.buttonPanel.updateButtons(true);
				SystemDivider.gotoAndStop("Left");
				break;
			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.QUIT_CONFIRM_STATE:
			case SystemPage.PC_QUIT_CONFIRM_STATE:
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
				ConfirmPanel.confirmType = aiState;
				ConfirmPanel.returnState = iCurrentState;
		}
		iCurrentState = SystemPage.TRANSITIONING;
		GetPanelForState(aiState).gotoAndPlay("start");
	}

	public function EndState()
	{
		BottomBar_mc.buttonPanel.clearButtons();
		switch (iCurrentState) {
			case SystemPage.CHARACTER_LOAD_STATE:
			case SystemPage.CHARACTER_SELECTION_STATE:
			case SystemPage.SAVE_LOAD_STATE:
			case SystemPage.INPUT_MAPPING_STATE:
			case SystemPage.HELP_TEXT_STATE:
				if (iPlatform != SystemPage.CONTROLLER_ORBIS) {
					SystemDivider.gotoAndStop("Right");
				}
				break;
			case SystemPage.HELP_LIST_STATE:
				HelpList.disableInput = true;
				if (HelpListPanel.bCloseToMainState != false) {
					SystemDivider.gotoAndStop("Right");
				}
				break;
			case SystemPage.SETTINGS_CATEGORY_STATE:
				SettingsList.disableInput = true;
				if (SettingsPanel.bCloseToMainState != false) {
					SystemDivider.gotoAndStop("Right");
				}
				break;
			case SystemPage.PC_QUIT_LIST_STATE:
				SystemDivider.gotoAndStop("Right");
				break;
			case SystemPage.OPTIONS_LISTS_STATE:
		}
		if (iCurrentState != SystemPage.MAIN_STATE) {
			GetPanelForState(iCurrentState).gotoAndPlay("end");
			iCurrentState = SystemPage.TRANSITIONING;
		}
	}

	public function GetPanelForState(aiState)
	{
		switch (aiState) {
			case SystemPage.MAIN_STATE:
				return PanelRect;
			case SystemPage.SETTINGS_CATEGORY_STATE:
				return SettingsPanel;
			case SystemPage.OPTIONS_LISTS_STATE:
				return OptionsListsPanel;
			case SystemPage.INPUT_MAPPING_STATE:
				return InputMappingPanel;
			case SystemPage.CHARACTER_LOAD_STATE:
			case SystemPage.CHARACTER_SELECTION_STATE:
			case SystemPage.SAVE_LOAD_STATE:
				return SaveLoadPanel;
			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.PC_QUIT_CONFIRM_STATE:
			case SystemPage.QUIT_CONFIRM_STATE:
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
				return ConfirmPanel;
			case SystemPage.PC_QUIT_LIST_STATE:
				return PCQuitPanel;
			case SystemPage.HELP_LIST_STATE:
				return HelpListPanel;
			case SystemPage.HELP_TEXT_STATE:
				return HelpTextPanel;
			default:
				return;
		}
	}

	public function UpdateStateFocus(aiNewState)
	{
		CategoryList.disableSelection = aiNewState != SystemPage.MAIN_STATE;
		switch (aiNewState) {
			case SystemPage.MAIN_STATE:
				gfx.managers.FocusHandler.instance.setFocus(CategoryList, 0);
				break;
			case SystemPage.SETTINGS_CATEGORY_STATE:
				SettingsList.disableInput = false;
				gfx.managers.FocusHandler.instance.setFocus(SettingsList, 0);
				break;
			case SystemPage.OPTIONS_LISTS_STATE:
				gfx.managers.FocusHandler.instance.setFocus(OptionsListsPanel.OptionsLists.List_mc, 0);
				break;
			case SystemPage.INPUT_MAPPING_STATE:
				gfx.managers.FocusHandler.instance.setFocus(MappingList, 0);
				break;
			case SystemPage.SAVE_LOAD_STATE:
			case SystemPage.CHARACTER_LOAD_STATE:
			case SystemPage.CHARACTER_SELECTION_STATE:
				gfx.managers.FocusHandler.instance.setFocus(SaveLoadListHolder.List_mc, 0);
				SaveLoadListHolder.List_mc.disableSelection = false;
				break;
			case SystemPage.SAVE_LOAD_CONFIRM_STATE:
			case SystemPage.QUIT_CONFIRM_STATE:
			case SystemPage.PC_QUIT_CONFIRM_STATE:
			case SystemPage.DELETE_SAVE_CONFIRM_STATE:
			case SystemPage.DEFAULT_SETTINGS_CONFIRM_STATE:
				gfx.managers.FocusHandler.instance.setFocus(ConfirmPanel, 0);
				break;
			case SystemPage.PC_QUIT_LIST_STATE:
				gfx.managers.FocusHandler.instance.setFocus(PCQuitList, 0);
				PCQuitList.disableSelection = false;
				break;
			case SystemPage.HELP_LIST_STATE:
				HelpList.disableInput = false;
				gfx.managers.FocusHandler.instance.setFocus(HelpList, 0);
				break;
			case SystemPage.HELP_TEXT_STATE:
				gfx.managers.FocusHandler.instance.setFocus(HelpText, 0);
			default:
				return;
		}
	}

	public function SetPlatform(a_platform, a_bPS3Switch)
	{
		BottomBar_mc.SetPlatform(a_platform, a_bPS3Switch);
		CategoryList.SetPlatform(a_platform, a_bPS3Switch);
		if (a_platform != 0) {
			SettingsList.selectedIndex = 0;
			PCQuitList.selectedIndex = 0;
			HelpList.selectedIndex = 0;
			MappingList.selectedIndex = 0;
			_deleteControls = {keyCode: 278};
			_defaultControls = {keyCode: 279};
			_kinectControls = {keyCode: 275};
			_acceptControls = {keyCode: 276};
			_cancelControls = {keyCode: 277};
			_characterSelectionControls = {keyCode: 279};
		} else {
			_deleteControls = {keyCode: 45};
			_defaultControls = {keyCode: 20};
			_kinectControls = {keyCode: 37};
			_acceptControls = {keyCode: 28};
			_cancelControls = {keyCode: 15};
			_characterSelectionControls = {keyCode: 20};
		}
		ConfirmPanel.buttonPanel.clearButtons();
		_acceptButton = ConfirmPanel.buttonPanel.addButton({text: "$Yes", controls: _acceptControls});
		_acceptButton.addEventListener("click", this, "onAcceptMousePress");
		_cancelButton = ConfirmPanel.buttonPanel.addButton({text: "$No", controls: _cancelControls});
		_cancelButton.addEventListener("click", this, "onCancelMousePress");
		ConfirmPanel.buttonPanel.updateButtons(true);
		iPlatform = a_platform;
		SaveLoadListHolder.platform = a_platform;
		requestInputMappings();
	}

	public function BackOutFromLoadGame()
	{
		bMenuClosing = false;
		onCancelPress();
	}

	public function SetShouldShowKinectTunerOption(abFlag)
	{
		bShowKinectTunerButton = abFlag == true;
	}

	public function SetRemoteDevice(abISRemoteDevice)
	{
		bIsRemoteDevice = abISRemoteDevice;
		if (bIsRemoteDevice) {
			MappingList.entryList.clear();
		}
	}

	public function UpdatePermissions()
	{
		if (_showModMenu) {
			gfx.io.GameDelegate.call("SetSaveDisabled", [CategoryList.entryList[0], CategoryList.entryList[1], CategoryList.entryList[2], CategoryList.entryList[4], CategoryList.entryList[6], CategoryList.entryList[8], false]);
			CategoryList.entryList[7].disabled = false;
		} else {
			gfx.io.GameDelegate.call("SetSaveDisabled", [CategoryList.entryList[0], CategoryList.entryList[1], CategoryList.entryList[2], CategoryList.entryList[3], CategoryList.entryList[5], CategoryList.entryList[7], false]);
			CategoryList.entryList[6].disabled = false;
		}
		CategoryList.UpdateList();
	}

	/* PRIVATE FUNCTIONS */

	private function doABCSort(aObj1, aObj2)
	{
		if (aObj1.text < aObj2.text) {
			return -1;
		}
		if (aObj1.text > aObj2.text) {
			return 1;
		}
		return 0;
	}

	private function onCategoryListMoveUp(event)
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			CategoryList._parent.gotoAndPlay("moveUp");
		}
	}

	private function onCategoryListMoveDown(event)
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			CategoryList._parent.gotoAndPlay("moveDown");
		}
	}

	private function onCategoryListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0 && event.index != -1) {
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}

	private function inputMappingSort(a_obj1, a_obj2)
	{
		if (a_obj1.sortIndex < a_obj2.sortIndex) {
			return -1;
		}
		if (a_obj1.sortIndex > a_obj2.sortIndex) {
			return 1;
		}
		return 0;
	}

	private function requestInputMappings(a_updateOnly)
	{
		MappingList.entryList.splice(0);
		gfx.io.GameDelegate.call("RequestInputMappings", [MappingList.entryList]);
		MappingList.entryList.sort(inputMappingSort);
		if (a_updateOnly) {
			MappingList.UpdateList();
		} else {
			MappingList.InvalidateData();
		}
	}
}
