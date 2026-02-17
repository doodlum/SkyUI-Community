class QuestsPage extends MovieClip
{
	/* STAGE ELEMENTS */

	var DescriptionText;
	var Divider;
	var NoQuestsText;
	var ObjectiveList;
	var ObjectivesHeader;
	var QuestTitleText;
	var TitleList;
	var TitleList_mc;
	var objectiveList;
	var objectivesHeader;
	var questDescriptionText;
	var questTitleEndpieces;
	var questTitleText;

	/* PRIVATE VARIABLES */

	private var _showOnMapButton;
	private var _toggleActiveButton;
	private var _bottomBar;

	private var _toggleActiveControls;
	private var _showOnMapControls;
	private var _deleteControls;

	var bAllowShowOnMap;
	var bHasMiscQuests;
	var bUpdated;
	var iPlatform;

	/* CONSTRUCTOR */

	public function QuestsPage()
	{
		super();
		TitleList = TitleList_mc.List_mc;
		DescriptionText = questDescriptionText;
		QuestTitleText = questTitleText;
		ObjectiveList = objectiveList;
		ObjectivesHeader = objectivesHeader;
		bHasMiscQuests = false;
		bUpdated = false;
		_bottomBar = _parent._parent.BottomBar_mc;
	}

	/* PUBLIC FUNCTIONS */

	public function onLoad()
	{
		QuestTitleText.SetText(" ");
		DescriptionText.SetText(" ");
		DescriptionText.verticalAutoSize = "top";
		QuestTitleText.textAutoSize = "shrink";
		TitleList.addEventListener("itemPress", this, "onTitleListSelect");
		TitleList.addEventListener("listMovedUp", this, "onTitleListMoveUp");
		TitleList.addEventListener("listMovedDown", this, "onTitleListMoveDown");
		TitleList.addEventListener("selectionChange", this, "onTitleListMouseSelectionChange");
		TitleList.disableInput = true;
		ObjectiveList.addEventListener("itemPress", this, "onObjectiveListSelect");
		ObjectiveList.addEventListener("selectionChange", this, "onObjectiveListHighlight");
	}

	public function startPage()
	{
		TitleList.disableInput = false;

		if (!bUpdated) {
			gfx.io.GameDelegate.call("RequestQuestsData", [TitleList], this, "onQuestsDataComplete");
			bUpdated = true;
		}

		_bottomBar.buttonPanel.clearButtons();
		_toggleActiveButton = _bottomBar.buttonPanel.addButton({text: "$Toggle Active", controls: _toggleActiveControls});
		if (bAllowShowOnMap) {
			_showOnMapButton = _bottomBar.buttonPanel.addButton({text: "$Show on Map", controls: _showOnMapControls});
		}
		_bottomBar.buttonPanel.updateButtons(true);
		switchFocusToTitles();
	}

	public function endPage()
	{
		_showOnMapButton._alpha = 100;
		_toggleActiveButton._alpha = 100;
		_bottomBar.buttonPanel.clearButtons();
		TitleList.disableInput = true;
	}

	public function get selectedQuestID()
	{
		return TitleList.entryList.length > 0 ? TitleList.centeredEntry.formID : undefined;
	}

	public function get selectedQuestInstance()
	{
		return TitleList.entryList.length > 0 ? TitleList.centeredEntry.instance : undefined;
	}

	public function handleInput(details, pathToFocus)
	{
		var bHandledInput = false;
		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			if ((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 77) && bAllowShowOnMap) {
				onShowMap();
				bHandledInput = true;
			} else if (TitleList.entryList.length > 0) {
				if (details.navEquivalent == gfx.ui.NavigationCode.LEFT && gfx.managers.FocusHandler.instance.getFocus(0) != TitleList) {
					switchFocusToTitles();
					bHandledInput = true;
				} else if (details.navEquivalent == gfx.ui.NavigationCode.RIGHT && gfx.managers.FocusHandler.instance.getFocus(0) != ObjectiveList) {
					switchFocusToObjectives();
					bHandledInput = true;
				}
			}
		}
		if (!bHandledInput && pathToFocus != undefined && pathToFocus.length > 0) {
			bHandledInput = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		return bHandledInput;
	}

	public function onShowMap()
	{
		var quest;
		if (ObjectiveList.selectedEntry != undefined && ObjectiveList.selectedEntry.questTargetID != undefined) {
			quest = ObjectiveList.selectedEntry;
		} else {
			quest = ObjectiveList.entryList[0];
		}
		if (quest != undefined && quest.questTargetID != undefined) {
			_parent._parent.CloseMenu();
			gfx.io.GameDelegate.call("ShowTargetOnMap", [quest.questTargetID]);
		} else {
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		}
	}

	public function onRightStickInput(afX, afY)
	{
		if (afY < 0) {
			ObjectiveList.moveSelectionDown();
			return undefined;
		}
		ObjectiveList.moveSelectionUp();
	}

	public function SetPlatform(a_platform, a_bPS3Switch)
	{
		if (a_platform == 0) {
			_toggleActiveControls = {keyCode: 28};
			_showOnMapControls = {keyCode: 50};
			_deleteControls = {keyCode: 45};
		} else {
			_toggleActiveControls = {keyCode: 276};
			_showOnMapControls = {keyCode: 278};
			_deleteControls = {keyCode: 278};
		}
		iPlatform = a_platform;
		TitleList.SetPlatform(a_platform, a_bPS3Switch);
		ObjectiveList.SetPlatform(a_platform, a_bPS3Switch);
	}

	/* PRIVATE FUNCTIONS */

	private function isViewingMiscObjectives()
	{
		return bHasMiscQuests && TitleList.selectedEntry.formID == 0;
	}

	private function onTitleListSelect()
	{
		if (TitleList.selectedEntry != undefined && !TitleList.selectedEntry.completed) {
			if (!isViewingMiscObjectives()) {
				gfx.io.GameDelegate.call("ToggleQuestActiveStatus", [TitleList.selectedEntry.formID, TitleList.selectedEntry.instance], this, "onToggleQuestActive");
				return undefined;
			}
			TitleList.selectedEntry.active = !TitleList.selectedEntry.active;
			gfx.io.GameDelegate.call("ToggleShowMiscObjectives", [TitleList.selectedEntry.active]);
			TitleList.UpdateList();
		}
	}

	private function onObjectiveListSelect()
	{
		if (isViewingMiscObjectives()) {
			gfx.io.GameDelegate.call("ToggleQuestActiveStatus", [ObjectiveList.selectedEntry.formID, ObjectiveList.selectedEntry.instance], this, "onToggleQuestActive");
		}
	}

	private function switchFocusToTitles()
	{
		gfx.managers.FocusHandler.instance.setFocus(TitleList, 0);
		Divider.gotoAndStop("Right");
		_toggleActiveButton._alpha = 100;
		ObjectiveList.selectedIndex = -1;
		if (iPlatform != 0) {
			ObjectiveList.disableSelection = true;
		}
		updateShowOnMapButtonAlpha(0);
	}

	private function switchFocusToObjectives()
	{
		gfx.managers.FocusHandler.instance.setFocus(ObjectiveList, 0);
		Divider.gotoAndStop("Left");
		_toggleActiveButton._alpha = !isViewingMiscObjectives() ? 50 : 100;
		if (iPlatform != 0) {
			ObjectiveList.disableSelection = false;
		}
		ObjectiveList.selectedIndex = 0;
		updateShowOnMapButtonAlpha(0);
	}

	private function onObjectiveListHighlight(event)
	{
		updateShowOnMapButtonAlpha(event.index);
	}

	private function updateShowOnMapButtonAlpha(a_entryIdx)
	{
		var alpha = 50;
		if (bAllowShowOnMap && (a_entryIdx >= 0 && ObjectiveList.entryList[a_entryIdx].questTargetID != undefined) || ObjectiveList.entryList.length > 0 && ObjectiveList.entryList[0].questTargetID != undefined) {
			alpha = 100;
		}
		_toggleActiveButton._alpha = TitleList.selectedEntry.completed ? 50 : 100;
		_showOnMapButton._alpha = alpha;
	}

	private function onToggleQuestActive(a_bnewActiveStatus)
	{
		var iFormID;
		var iInstance;
		if (isViewingMiscObjectives()) {
			iFormID = ObjectiveList.selectedEntry.formID;
			iInstance = ObjectiveList.selectedEntry.instance;
			for (var i in ObjectiveList.entryList) {
				if (ObjectiveList.entryList[i].formID == iFormID && ObjectiveList.entryList[i].instance == iInstance) {
					ObjectiveList.entryList[i].active = a_bnewActiveStatus;
				}
			}
			ObjectiveList.UpdateList();
		} else {
			TitleList.selectedEntry.active = a_bnewActiveStatus;
			TitleList.UpdateList();
		}
		if (a_bnewActiveStatus) {
			gfx.io.GameDelegate.call("PlaySound", ["UIQuestActive"]);
			return undefined;
		}
		gfx.io.GameDelegate.call("PlaySound", ["UIQuestInactive"]);
	}

	private function onQuestsDataComplete(auiSavedFormID, auiSavedInstance, abAddMiscQuest, abMiscQuestActive, abAllowShowOnMap)
	{
		bAllowShowOnMap = abAllowShowOnMap;

		if (abAddMiscQuest) {
			return TitleList.entryList.length <= 0 ? undefined : TitleList.centeredEntry.formID;
			bHasMiscQuests = true;
		}

		var iTimeCompleted;
		var bCompleted = false;
		var bUncompleted = false;
		var i = 0;
		while (i < TitleList.entryList.length) {
			if (TitleList.entryList[i].formID == 0) {
				TitleList.entryList[i].timeIndex = 1.7976931348623157e+308;
			} else {
				TitleList.entryList[i].timeIndex = i;
			}
			if (TitleList.entryList[i].completed) {
				if (iTimeCompleted == undefined) {
					iTimeCompleted = TitleList.entryList[i].timeIndex - 0.5;
				}
				bCompleted = true;
			} else {
				bUncompleted = true;
			}
			i = i + 1;
		}

		if (iTimeCompleted != undefined && bCompleted && bUncompleted) {
			TitleList.entryList.push({divider: true, completed: true, timeIndex: itimeCompleted});
		}
		TitleList.entryList.sort(completedQuestSort);

		var iSavedIndex = 0;
		i = 0;
		while (i < TitleList.entryList.length) {
			if (TitleList.entryList[i].text != undefined) {
				TitleList.entryList[i].text = TitleList.entryList[i].text.toUpperCase();
			}
			if (TitleList.entryList[i].formID == auiSavedFormID && TitleList.entryList[i].instance == auiSavedInstance) {
				iSavedIndex = i;
			}
			i = i + 1;
		}

		TitleList.InvalidateData();
		TitleList.RestoreScrollPosition(iSavedIndex, true);
		TitleList.UpdateList();
		onQuestHighlight();
	}

	private function completedQuestSort(aObj1, aObj2)
	{
		if (!aObj1.completed && aObj2.completed) {
			return -1;
		}
		if (aObj1.completed && !aObj2.completed) {
			return 1;
		}
		if (aObj1.timeIndex < aObj2.timeIndex) {
			return -1;
		}
		if (aObj1.timeIndex > aObj2.timeIndex) {
			return 1;
		}
		return 0;
	}

	private function onQuestHighlight()
	{
		var aCategories;
		if (TitleList.entryList.length > 0) {
			aCategories = ["Misc", "Main", "MagesGuild", "ThievesGuild", "DarkBrotherhood", "Companion", "Favor", "Daedric", "Misc", "CivilWar", "DLC01", "DLC02"];
			QuestTitleText.SetText(TitleList.selectedEntry.text);
			if (TitleList.selectedEntry.objectives == undefined) {
				gfx.io.GameDelegate.call("RequestObjectivesData", []);
			}
			ObjectiveList.entryList = TitleList.selectedEntry.objectives;
			SetDescriptionText();
			questTitleEndpieces.gotoAndStop(aCategories[TitleList.selectedEntry.type]);
			questTitleEndpieces._visible = true;
			ObjectivesHeader._visible = !isViewingMiscObjectives();
			ObjectiveList.selectedIndex = -1;
			ObjectiveList.scrollPosition = 0;
			if (iPlatform != 0) {
				ObjectiveList.disableSelection = true;
			}
			updateShowOnMapButtonAlpha(0);
		} else {
			NoQuestsText.SetText("No Active Quests");
			DescriptionText.SetText(" ");
			QuestTitleText.SetText(" ");
			ObjectiveList.ClearList();
			questTitleEndpieces._visible = false;
			ObjectivesHeader._visible = false;
		}
		UpdateButtonVisiblity();
		ObjectiveList.InvalidateData();
	}

	private function UpdateButtonVisiblity()
	{
		var bHasEntries = TitleList.entryList.length > 0 && TitleList.entryList.selectedEntry != null;
		_toggleActiveButton._visible = bHasEntries && !TitleList.selectedEntry.completed;
		_showOnMapButton._visible = bHasEntries && !TitleList.selectedEntry.completed && bAllowShowOnMap;
	}

	private function SetDescriptionText()
	{
		var iHeaderYOffset = 25;
		var iObjectiveYOffset = 10;
		var iObjectiveBorderMaxY = 470;
		var iObjectiveBorderMinY = 40;
		DescriptionText.SetText(TitleList.selectedEntry.description);
		var oCharBoundaries = DescriptionText.getCharBoundaries(DescriptionText.getLineOffset(DescriptionText.numLines - 1));
		ObjectivesHeader._y = DescriptionText._y + oCharBoundaries.bottom + iHeaderYOffset;
		if (isViewingMiscObjectives()) {
			ObjectiveList._y = DescriptionText._y;
		} else {
			ObjectiveList._y = ObjectivesHeader._y + ObjectivesHeader._height + iObjectiveYOffset;
		}
		ObjectiveList.border._height = Math.max(iObjectiveBorderMaxY - ObjectiveList._y, iObjectiveBorderMinY);
		ObjectiveList.scrollbar.height = ObjectiveList.border._height - 20;
	}

	private function onTitleListMoveUp(event)
	{
		onQuestHighlight();
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			TitleList._parent.gotoAndPlay("moveUp");
		}
	}

	private function onTitleListMoveDown(event)
	{
		onQuestHighlight();
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) {
			TitleList._parent.gotoAndPlay("moveDown");
		}
	}

	private function onTitleListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0 && event.index != -1) {
			onQuestHighlight();
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}
}
