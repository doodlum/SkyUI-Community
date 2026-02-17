class Quest_Journal extends MovieClip
{
	/* CONSTANTS */

	public static var SKYUI_RELEASE_IDX = 2018;
	public static var SKYUI_VERSION_MAJOR = 5;
	public static var SKYUI_VERSION_MINOR = 2;
	public static var SKYUI_VERSION_STRING = Quest_Journal.SKYUI_VERSION_MAJOR + "." + Quest_Journal.SKYUI_VERSION_MINOR + " SE";

	public static var PAGE_QUEST = 0;
	public static var PAGE_STATS = 1;
	public static var PAGE_SYSTEM = 2;

	public static var QUESTS_TAB = 0;
	public static var STATS_TAB = 1;
	public static var SETTINGS_TAB = 2;

	/* STAGE ELEMENTS */

	var BottomBar;
	var BottomBar_mc;

	var QuestsFader;
	var StatsFader;
	var SystemFader;

	var QuestsTab;
	var StatsTab;
	var SystemTab;

	public var previousTabButton;
	public var nextTabButton;

	/* PRIVATE VARIABLES */

	var bTabsDisabled;
	var iCurrentTab;
	var PageArray;
	var TopmostPage;
	var TabButtonGroup;
	var ConfigPanel;

	/* CONSTRUCTOR */

	public function Quest_Journal()
	{
		super();
		BottomBar_mc = BottomBar;
		PageArray = new Array(QuestsFader.Page_mc, StatsFader.Page_mc, SystemFader.Page_mc);
		TopmostPage = QuestsFader;
		bTabsDisabled = false;
	}

	/* PUBLIC FUNCTIONS */

	public function InitExtensions()
	{
		Shared.GlobalFunc.SetLockFunction();
		MovieClip(BottomBar_mc).Lock("B");

		ConfigPanel = _root.ConfigPanelFader.configPanel;

		QuestsTab.disableFocus = true;
		StatsTab.disableFocus = true;
		SystemTab.disableFocus = true;

		TabButtonGroup = gfx.controls.ButtonGroup(QuestsTab.group);
		TabButtonGroup.addEventListener("itemClick", this, "onTabClick");
		TabButtonGroup.addEventListener("change", this, "onTabChange");

		gfx.io.GameDelegate.addCallBack("RestoreSavedSettings", this, "RestoreSavedSettings");
		gfx.io.GameDelegate.addCallBack("onRightStickInput", this, "onRightStickInput");
		gfx.io.GameDelegate.addCallBack("HideMenu", this, "DoHideMenu");
		gfx.io.GameDelegate.addCallBack("ShowMenu", this, "DoShowMenu");
		gfx.io.GameDelegate.addCallBack("StartCloseMenu", this, "CloseMenu");
		gfx.io.GameDelegate.call("ShouldShowMod", [], this, "SetShowMod");

		BottomBar_mc.InitBar();

		ConfigPanel.initExtensions();
	}

	public function SetShowMod()
	{
		SystemPage(PageArray[Quest_Journal.PAGE_SYSTEM]).SetShowMod(arguments[0]);
	}

	public function RestoreSavedSettings(aiSavedTab, abTabsDisabled)
	{
		iCurrentTab = Math.min(Math.max(aiSavedTab, 0), TabButtonGroup.length - 1);
		bTabsDisabled = abTabsDisabled;
		if (bTabsDisabled) {
			iCurrentTab = TabButtonGroup.length - 1;
			QuestsTab.disabled = true;
			StatsTab.disabled = true;
		}
		SwitchPageToFront(iCurrentTab, true);
		TabButtonGroup.setSelectedButton(TabButtonGroup.getButtonAt(iCurrentTab));
	}

	public function SwitchPageToFront(aiTab, abForceFade)
	{
		if (TopmostPage != PageArray[iCurrentTab]._parent) {
			TopmostPage.gotoAndStop("hide");
			PageArray[iCurrentTab]._parent.swapDepths(TopmostPage);
			TopmostPage = PageArray[iCurrentTab]._parent;
		}
		TopmostPage.gotoAndPlay(abForceFade ? "ForceFade" : "fadeIn");
		BottomBar_mc.LevelMeterRect._visible = iCurrentTab != 0;
	}

	public function handleInput(details, pathToFocus)
	{
		var bHandledInput = false;
		if (pathToFocus != undefined && pathToFocus.length > 0) {
			bHandledInput = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}

		var prevTabNav;
		var nextTabNav;

		if (!bHandledInput && Shared.GlobalFunc.IsKeyPressed(details, false)) {
			prevTabNav = gfx.ui.NavigationCode.GAMEPAD_L2;
			nextTabNav = gfx.ui.NavigationCode.GAMEPAD_R2;
			if (SystemPage(PageArray[Quest_Journal.PAGE_SYSTEM]).GetIsRemoteDevice()) {
				prevTabNav = gfx.ui.NavigationCode.GAMEPAD_L1;
				nextTabNav = gfx.ui.NavigationCode.GAMEPAD_R1;
			}
			if (details.navEquivalent === gfx.ui.NavigationCode.TAB) {
				CloseMenu();
			} else if (details.navEquivalent === prevTabNav) {
				if (!bTabsDisabled) {
					PageArray[iCurrentTab].endPage();
					iCurrentTab += details.navEquivalent != prevTabNav ? 1 : -1;
					if (iCurrentTab == -1) {
						iCurrentTab = TabButtonGroup.length - 1;
					}
					if (iCurrentTab == TabButtonGroup.length) {
						iCurrentTab = 0;
					}
					SwitchPageToFront(iCurrentTab, false);
					TabButtonGroup.setSelectedButton(TabButtonGroup.getButtonAt(iCurrentTab));
				}
			} else if (details.navEquivalent === nextTabNav) {
				if (!bTabsDisabled) {
					PageArray[iCurrentTab].endPage();
					iCurrentTab += details.navEquivalent != prevTabNav ? 1 : -1;
					if (iCurrentTab == -1) {
						iCurrentTab = TabButtonGroup.length - 1;
					}
					if (iCurrentTab == TabButtonGroup.length) {
						iCurrentTab = 0;
					}
					SwitchPageToFront(iCurrentTab, false);
					TabButtonGroup.setSelectedButton(TabButtonGroup.getButtonAt(iCurrentTab));
				}
			}
		}
		return true;
	}

	public function CloseMenu(abForceClose)
	{
		if (abForceClose != true) {
			gfx.io.GameDelegate.call("PlaySound", ["UIJournalClose"]);
		}
		gfx.io.GameDelegate.call("CloseMenu", [iCurrentTab, QuestsFader.Page_mc.selectedQuestID, QuestsFader.Page_mc.selectedQuestInstance]);
	}

	public function onTabClick(event)
	{
		if (bTabsDisabled) {
			return undefined;
		}

		var iOldTab = iCurrentTab;

		if (event.item == QuestsTab) {
			iCurrentTab = 0;
		} else if (event.item == StatsTab) {
			iCurrentTab = 1;
		} else if (event.item == SystemTab) {
			iCurrentTab = 2;
		}
		if (iOldTab != iCurrentTab) {
			PageArray[iOldTab].endPage();
			SwitchPageToFront(iCurrentTab, false);
		}
	}

	public function onTabChange(event)
	{
		event.item.gotoAndPlay("selecting");
		PageArray[iCurrentTab].startPage();
		gfx.io.GameDelegate.call("PlaySound", ["UIJournalTabsSD"]);
	}

	public function onRightStickInput(afX, afY)
	{
		if (PageArray[iCurrentTab].onRightStickInput != undefined) {
			PageArray[iCurrentTab].onRightStickInput(afX, afY);
		}
	}

	public function SetPlatform(aiPlatform, abPS3Switch)
	{
		if (aiPlatform == 0) {
			previousTabButton._visible = nextTabButton._visible = false;
		} else {
			previousTabButton._visible = nextTabButton._visible = true;
			previousTabButton.gotoAndStop(280);
			nextTabButton.gotoAndStop(281);
		}

		for (var i in PageArray) {
			if (PageArray[i].SetPlatform != undefined) {
				PageArray[i].SetPlatform(aiPlatform, abPS3Switch);
			}
		}
		BottomBar_mc.setPlatform(aiPlatform, abPS3Switch);

		ConfigPanel.setPlatform(aiPlatform, abPS3Switch);
	}

	public function DoHideMenu()
	{
		_parent.gotoAndPlay("fadeOut");
	}

	public function DoShowMenu()
	{
		_parent.gotoAndPlay("fadeIn");
	}

	public function DisableTabs(abEnable)
	{
		QuestsTab.disabled = abEnable;
		StatsTab.disabled = abEnable;
		SystemTab.disabled = abEnable;
	}

	public function ConfigPanelOpen()
	{
		DisableTabs(true);
		SystemFader.Page_mc.endPage();
		DoHideMenu();
		_root.ConfigPanelFader.swapDepths(_root.QuestJournalFader);
		gfx.managers.FocusHandler.instance.setFocus(ConfigPanel, 0);
		ConfigPanel.startPage();
	}

	public function ConfigPanelClose()
	{
		ConfigPanel.endPage();
		_root.QuestJournalFader.swapDepths(_root.ConfigPanelFader);
		gfx.managers.FocusHandler.instance.setFocus(this, 0);
		DoShowMenu();
		SystemFader.Page_mc.startPage();
		DisableTabs(false);
	}
}
