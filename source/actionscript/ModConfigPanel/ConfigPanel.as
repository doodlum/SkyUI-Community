class ConfigPanel extends MovieClip
{
	/* CONSTANTS */

	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = ConfigPanel.SKYUI_VERSION_MAJOR + "." + ConfigPanel.SKYUI_VERSION_MINOR + " SE";

	private static var READY = 0;
	private static var WAIT_FOR_OPTION_DATA = 1;
	private static var WAIT_FOR_SLIDER_DATA = 2;
	private static var WAIT_FOR_MENU_DATA = 3;
	private static var WAIT_FOR_COLOR_DATA = 4;
	private static var WAIT_FOR_INPUT_DATA = 5;
	private static var WAIT_FOR_SELECT = 6;
	private static var WAIT_FOR_DEFAULT = 7;
	private static var DIALOG = 8;

	private static var FOCUS_MODLIST = 0;
	private static var FOCUS_OPTIONS = 1;


	/* PRIVATE VARIABLES */

	private var _platform;

	// Quest_Journal_mc
	private var _parentMenu;
	private var _buttonPanelL;
	private var _buttonPanelR;

	private var _bottomBarStartY;

	private var _modListPanel;
	private var _modList;
	private var _subList;
	private var _optionsList;

	private var _customContent;
	private var _customContentX = 0;
	private var _customContentY = 0;

	private var _state;
	private var _focus;

	private var _optionFlagsBuffer;
	private var _optionTextBuffer;
	private var _optionStrValueBuffer;
	private var _optionNumValueBuffer;

	private var _titleText = "";
	private var _infoText = "";
	private var _dialogTitleText = "";

	private var _highlightIndex = -1;
	private var _highlightIntervalID;

	private var _menuDialogOptions;

	private var _sliderDialogFormatString = "";

	private var _currentRemapOption = -1;
	private var _bRemapMode = false;
	private var _remapDelayID;

	private var _acceptControls;
	private var _cancelControls;
	private var _defaultControls;
	private var _unmapControls;

	private var _bDefaultEnabled = false;

	private var _bRequestPageReset = false;


	/* STAGE ELEMENTS */

	public var contentHolder;
	public var titlebar;
	public var bottomBar;


	/* INITIALIZATION */

	public function ConfigPanel()
	{
		super();
		// A bit hackish but w/e
		_parentMenu = _root.QuestJournalFader.Menu_mc;

		_modListPanel = contentHolder.modListPanel;
		_modList = _modListPanel.modListFader.list;
		_subList = _modListPanel.subListFader.list;
		_optionsList = contentHolder.optionsPanel.optionsList;

		_buttonPanelL = bottomBar.buttonPanelL;
		_buttonPanelR = bottomBar.buttonPanelR;

		_state = READY;

		_optionFlagsBuffer = [];
		_optionTextBuffer = [];
		_optionStrValueBuffer = [];
		_optionNumValueBuffer = [];

		_menuDialogOptions = [];

		contentHolder.infoPanel.textField.verticalAutoSize = "top";
	}

	// @override MovieClip
	private function onLoad()
	{
		super.onLoad();

		_modList.listEnumeration = new skyui.components.list.BasicEnumeration(_modList.entryList);
		_subList.listEnumeration = new skyui.components.list.BasicEnumeration(_subList.entryList);
		_optionsList.listEnumeration = new skyui.components.list.BasicEnumeration(_optionsList.entryList);

		_modList.addEventListener("itemPress", this, "onModListPress");
		_modList.addEventListener("selectionChange", this, "onModListChange");

		_subList.addEventListener("itemPress", this, "onSubListPress");
		_subList.addEventListener("selectionChange", this, "onSubListChange");

		_optionsList.addEventListener("itemPress", this, "onOptionPress");
		_optionsList.addEventListener("selectionChange", this, "onOptionChange");

		_modListPanel.addEventListener("modListEnter", this, "onModListEnter");
		_modListPanel.addEventListener("modListExit", this, "onModListExit");
		_modListPanel.addEventListener("subListEnter", this, "onSubListEnter");
		_modListPanel.addEventListener("subListExit", this, "onSubListExit");

		_optionsList._visible = false;
	}


	/* PAPYRUS INTERFACE */

	// Holds last selected key
	public var selectedKeyCode = -1;

	public function unlock()
	{
		_state = READY;

		// Execute depending forced reset when ready
		if (_bRequestPageReset) {
			_bRequestPageReset = false;
			var entry = _subList.listState.activeEntry;
			selectPage(entry);
			return;
		}
	}

	public function setModNames(/* names */)
	{
		_modList.clearList();
		_modList.listState.savedIndex = null;

		var i = 0;
		var s;
		while (i < arguments.length) {
			s = arguments[i];
			if (s != "") {
				_modList.entryList.push({modIndex: i, modName: s, text: Translator.translate(s), align: "right", enabled: true});
			}
			i = i + 1;
		}

		_modList.entryList.sortOn("text", Array.CASEINSENSITIVE);
		_modList.InvalidateData();
	}

	public function setPageNames(/* names */)
	{
		_subList.clearList();
		_subList.listState.savedIndex = null;

		var i = 0;
		var s;
		while (i < arguments.length) {
			s = arguments[i];
			if (s.toLowerCase() != "none") {
				_subList.entryList.push({pageIndex: i, pageName: s, text: Translator.translate(s), align: "right", enabled: true});
			}
			i = i + 1;
		}
		_subList.InvalidateData();
	}

	public function setCustomContentParams(a_x, a_y)
	{
		_customContentX = a_x;
		_customContentY = a_y;
	}

	public function loadCustomContent(a_source)
	{
		unloadCustomContent();

		var optionsPanel = contentHolder.optionsPanel;

		_customContent = optionsPanel.createEmptyMovieClip("customContent", optionsPanel.getNextHighestDepth());
		_customContent._x = _customContentX;
		_customContent._y = _customContentY;
		_customContent.loadMovie(a_source);

		_optionsList._visible = false;
	}

	public function unloadCustomContent()
	{
		if (!_customContent)
			return;

		_customContent.removeMovieClip();
		_customContent = undefined;

		_optionsList._visible = true;
	}

	public function setTitleText(a_text)
	{
		_titleText = skyui.util.Translator.translate(a_text).toUpperCase();

		// Don't apply yet if waiting for option data
		if (_state != WAIT_FOR_OPTION_DATA)
			applyTitleText();
	}

	public function setInfoText(a_text)
	{
		_infoText = skyui.util.Translator.translateNested(a_text);

		// Don't apply yet if waiting for option data
		if (_state != WAIT_FOR_OPTION_DATA)
			applyInfoText();
	}

	public function setOptionFlagsBuffer(/* values */)
	{
		var i = 0;
		while (i < arguments.length) {
			_optionFlagsBuffer[i] = arguments[i];
			i = i + 1;
		}
	}

	public function setOptionTextBuffer(/* values */)
	{
		var i = 0;
		while (i < arguments.length) {
			_optionTextBuffer[i] = skyui.util.Translator.translateNested(arguments[i]);
			i = i + 1;
		}
	}

	public function setOptionStrValueBuffer(/* values */)
	{
		var i = 0;
		while (i < arguments.length) {
			_optionStrValueBuffer[i] = arguments[i].toLowerCase() != "none" ? arguments[i] : null;
			i = i + 1;
		}
	}

	public function setOptionNumValueBuffer(/* values */)
	{
		var i = 0;
		while (i < arguments.length) {
			_optionNumValueBuffer[i] = arguments[i];
			i = i + 1;
		}
	}

	public function setSliderDialogParams(a_value, a_default, a_min, a_max, a_interval)
	{
		_state = DIALOG;

		var initObj = {
			_x: 719, _y: 265,
			platform: _platform,
			titleText: _dialogTitleText,
			sliderValue: a_value,
			sliderDefault: a_default,
			sliderMax: a_max,
			sliderMin: a_min,
			sliderInterval: a_interval,
			sliderFormatString: _sliderDialogFormatString
		};

		var dialog = skyui.util.DialogManager.open(this, "OptionSliderDialog", initObj);
		dialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
		dialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
		dimOut();
	}

	public function setMenuDialogOptions(/* values */)
	{
		_menuDialogOptions.splice(0);

		var i = 0;
		var s;
		while (i < arguments.length) {
			s = arguments[i];

			// Cut off rest of the buffer once the first empty string was found
			if (s.toLowerCase() == "none" || s == "") {
				break;
			}

			_menuDialogOptions[i] = skyui.util.Translator.translateNested(arguments[i]);
			i = i + 1;
		}
	}

	public function setMenuDialogParams(a_startIndex, a_defaultIndex)
	{
		_state = DIALOG;

		var initObj = {
			_x: 719, _y: 265,
			platform: _platform,
			titleText: _dialogTitleText,
			menuOptions: _menuDialogOptions,
			menuStartIndex: a_startIndex,
			menuDefaultIndex: a_defaultIndex
		};

		var dialog = skyui.util.DialogManager.open(this, "OptionMenuDialog", initObj);
		dialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
		dialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
		dimOut();
	}

	public function setColorDialogParams(a_currentColor, a_defaultColor)
	{
		_state = DIALOG;

		var initObj = {
			_x: 719, _y: 265,
			platform: _platform,
			titleText: _dialogTitleText,
			currentColor: a_currentColor,
			defaultColor: a_defaultColor
		};

		var dialog = skyui.util.DialogManager.open(this, "OptionColorDialog", initObj);
		dialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
		dialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
		dimOut();
	}

	public function setInputDialogParams(a_initialText)
	{
		_state = DIALOG;

		var initObj = {
			_x: 719, _y: 265,
			platform: _platform,
			titleText: _dialogTitleText,
			initialText: a_initialText
		};

		var dialog = skyui.util.DialogManager.open(this, "OptionTextInputDialog", initObj);
		dialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
		dialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
		dimOut();
	}

	public function flushOptionBuffers(a_optionCount)
	{
		_optionsList.clearList();
		_optionsList.listState.savedIndex = null;

		var i = 0;
		var optionType;
		var flags;
		while (i < a_optionCount) {
			// Both option type and flags are passed in the flags buffer
			optionType = _optionFlagsBuffer[i] & 0xFF;
			flags = (_optionFlagsBuffer[i] >>> 8) & 0xFF;

			_optionsList.entryList.push({optionType: optionType,
										 text: _optionTextBuffer[i],
										 strValue: _optionStrValueBuffer[i],
										 numValue: _optionNumValueBuffer[i],
										 flags: flags});
			i = i + 1;
		}

		// Pad uneven option count with empty option so keyboard selection area is symmetrical
		if (_optionsList.entryList.length % 2 != 0) {
			_optionsList.entryList.push({optionType: OptionsListEntry.OPTION_EMPTY});
		}

		_optionsList.InvalidateData();
		_optionsList.selectedIndex = -1;

		_optionFlagsBuffer.splice(0);
		_optionTextBuffer.splice(0);
		_optionStrValueBuffer.splice(0);
		_optionNumValueBuffer.splice(0);

		applyTitleText();

		_highlightIndex = -1;
		clearInterval(_highlightIntervalID);

		_infoText = "";
		applyInfoText();
	}

	// Direct access to option data
	public var optionCursorIndex = -1;

	public function get optionCursor()
	{
		return _optionsList.entryList[optionCursorIndex];
	}

	public function invalidateOptionData()
	{
		_optionsList.InvalidateData();
	}

	public function setOptionFlags(/* values */)
	{
		var index = arguments[0];
		var flags = arguments[1];
		_optionsList.entryList[index].flags = flags;
	}

	public function forcePageReset()
	{
		_bRequestPageReset = true;
	}

	public function showMessageDialog(a_text, a_acceptLabel, a_cancelLabel)
	{
		// Don't open it while READY cause we should always be waiting for something.
		if (_state == READY) {
			skse.SendModEvent("SKICP_messageDialogClosed", null, 0);
			return;
		}

		// This is a special dialog. It doesn't result in Papyrus event when closed but instead the
		// thread opening is supposed to sleep and wait until it's closed again (behaving like Message.Show()).
		// It keeps _state set to whatever it was.
		var initObj = {
			_x: 719, _y: 265,
			platform: _platform,
			messageText: a_text,
			acceptLabel: a_acceptLabel,
			cancelLabel: a_cancelLabel
		};

		var dialog = skyui.util.DialogManager.open(this, "MessageDialog", initObj);
		dialog.addEventListener("dialogClosing", this, "onMessageDialogClosing");
		dimOut();
	}


	/* PUBLIC FUNCTIONS */

	public function initExtensions()
	{
		bottomBar.Lock("B");
		_bottomBarStartY = bottomBar._y;

		showWelcomeScreen();
	}

	public function setPlatform(a_platform, a_bPS3Switch)
	{
		_platform = a_platform;

		if (a_platform == 0) {
			_acceptControls = skyui.defines.Input.Enter;
			_cancelControls = skyui.defines.Input.Tab;
			_defaultControls = skyui.defines.Input.ReadyWeapon;
			_unmapControls = skyui.defines.Input.JournalYButton;
		} else {
			_acceptControls = skyui.defines.Input.Accept;
			_cancelControls = skyui.defines.Input.Cancel;
			_defaultControls = skyui.defines.Input.JournalXButton;
			_unmapControls = skyui.defines.Input.JournalYButton;
		}

		_buttonPanelL.setPlatform(a_platform, a_bPS3Switch);
		_buttonPanelR.setPlatform(a_platform, a_bPS3Switch);

		updateModListButtons(false);
	}

	public function startPage()
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
		_parent.gotoAndPlay("fadeIn");

		changeFocus(FOCUS_MODLIST);
		showWelcomeScreen();
	}

	public function endPage()
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		_parent.gotoAndPlay("fadeOut");
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		if (_bRemapMode)
			return true;

		var valid;
		var restored;

		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			if (_focus == FOCUS_OPTIONS) {
				valid = !_optionsList.disableInput && _optionsList.selectedIndex % 2 == 0 && _subList.entryList.length > 0 && _subList._visible;
				if (valid && details.navEquivalent == gfx.ui.NavigationCode.LEFT) {
					changeFocus(FOCUS_MODLIST);
					_optionsList.listState.savedIndex = _optionsList.selectedIndex;
					_optionsList.selectedIndex = -1;

					restored = _subList.listState.savedIndex;
					_subList.selectedIndex = (restored > -1) ? restored : ((_subList.listState.activeEntry.itemIndex > -1) ? _subList.listState.activeEntry.itemIndex : 0);
					return true;
				}
			} else if (_focus == FOCUS_MODLIST) {
				valid = !_subList.disableInput && _optionsList.entryList.length > 0 && _optionsList._visible;
				if (valid && details.navEquivalent == gfx.ui.NavigationCode.RIGHT) {
					changeFocus(FOCUS_OPTIONS);
					_subList.listState.savedIndex = _subList.selectedIndex;
					_subList.selectedIndex = -1;

					restored = _optionsList.listState.savedIndex;
					_optionsList.selectedIndex = (restored > -1) ? restored : 0;
					return true;
				}
			}
		}

		var nextClip = pathToFocus.shift();
		if (nextClip && nextClip.handleInput(details, pathToFocus))
			return true;

		if (Shared.GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
				if (_modListPanel.isSublistActive()) {
					changeFocus(FOCUS_MODLIST);
					_modListPanel.showList();
				} else if (_modListPanel.isListActive()) {
					_parentMenu.ConfigPanelClose();
				}
				return true;
			} else if (details.control == _defaultControls.name) {
				requestDefaults();
				return true;
			} else if (details.control == _unmapControls.name) {
				requestUnmap();
				return true;
			}
		}

		// Don't forward to higher level
		return true;
	}


	/* PRIVATE FUNCTIONS */

	private function requestDefaults()
	{
		if (_state != READY)
			return;

		var index = _optionsList.selectedIndex;
		if (index == -1)
			return;

		if (_optionsList.selectedEntry.flags & OptionsListEntry.FLAG_DISABLED)
			return;

		_state = WAIT_FOR_DEFAULT;
		skse.SendModEvent("SKICP_optionDefaulted", null, index);
	}

	private function requestUnmap()
	{
		if (_state != READY)
			return;

		var index = _optionsList.selectedIndex;
		if (index == -1)
			return;

		if (_optionsList.selectedEntry.flags & (OptionsListEntry.FLAG_DISABLED | OptionsListEntry.FLAG_HIDDEN))
			return;

		if (!(_optionsList.selectedEntry.flags & OptionsListEntry.FLAG_WITH_UNMAP))
			return;

		selectedKeyCode = -1;
		_state = WAIT_FOR_SELECT;
		skse.SendModEvent("SKICP_keymapChanged", null, index);
	}

	private function onModListEnter(event)
	{
		showWelcomeScreen();
	}

	private function onModListExit(event)
	{
	}

	private function onSubListEnter(event)
	{
	}

	private function onSubListExit(event)
	{
		_optionsList.clearList();
		_optionsList.InvalidateData();
		unloadCustomContent();
	}

	private function onModListPress(a_event)
	{
		selectMod(a_event.entry);
	}

	private function onModListChange(a_event)
	{
		if (a_event.index != -1)
			changeFocus(FOCUS_MODLIST);

		updateModListButtons(false);
	}

	private function onSubListPress(a_event)
	{
		selectPage(a_event.entry);
	}

	private function onSubListChange(a_event)
	{
		if (a_event.index != -1)
			changeFocus(FOCUS_MODLIST);

		updateModListButtons(true);
	}

	private function onOptionPress(a_event)
	{
		selectOption(a_event.index);
	}

	private function onOptionChange(a_event)
	{
		if (a_event.index != -1)
			changeFocus(FOCUS_OPTIONS);

		initHighlightOption(a_event.index);
		updateOptionButtons();
	}

	private function onOptionChangeDialogClosing(event)
	{
		dimIn();
	}

	private function onMessageDialogClosing(event)
	{
		dimIn();
	}

	private function onOptionChangeDialogClosed(event)
	{
	}

	private function selectMod(a_entry)
	{
		if (_state != READY)
			return;

		_subList.listState.activeEntry = null;
		_subList.clearList();
		_subList.InvalidateData();

		_optionsList.clearList();
		_optionsList.InvalidateData();
		unloadCustomContent();

		_state = WAIT_FOR_OPTION_DATA;
		skse.SendModEvent("SKICP_modSelected", null, a_entry.modIndex);

		_modListPanel.showSublist();
	}

	private function selectPage(a_entry)
	{
		if (_state != READY)
			return;

		if (a_entry != null) {
			_subList.listState.activeEntry = a_entry;
			_subList.UpdateList();

			// Send name as well so mod doesn't have to look it up by index later
			_state = WAIT_FOR_OPTION_DATA;
			skse.SendModEvent("SKICP_pageSelected", a_entry.pageName, a_entry.pageIndex);

		// Special case for ForcePageReset without any pages
		} else {
			_state = WAIT_FOR_OPTION_DATA;
			skse.SendModEvent("SKICP_pageSelected", "", -1);
		}
	}

	private function selectOption(a_index)
	{
		if (_state != READY)
			return;

		var e = _optionsList.selectedEntry;
		if (e == undefined)
			return;

		if (e.flags & OptionsListEntry.FLAG_DISABLED)
			return;

		switch (e.optionType) {
			case OptionsListEntry.OPTION_TEXT:
			case OptionsListEntry.OPTION_TOGGLE:
				_state = WAIT_FOR_SELECT;
				skse.SendModEvent("SKICP_optionSelected", null, a_index);
				break;

			case OptionsListEntry.OPTION_SLIDER:
				_dialogTitleText = e.text;
				_sliderDialogFormatString = e.strValue;
				_state = WAIT_FOR_SLIDER_DATA;
				skse.SendModEvent("SKICP_sliderSelected", null, a_index);
				break;

			case OptionsListEntry.OPTION_MENU:
				_dialogTitleText = e.text;
				_state = WAIT_FOR_MENU_DATA;
				skse.SendModEvent("SKICP_menuSelected", null, a_index);
				break;

			case OptionsListEntry.OPTION_COLOR:
				_dialogTitleText = e.text;
				_state = WAIT_FOR_COLOR_DATA;
				skse.SendModEvent("SKICP_colorSelected", null, a_index);
				break;

			case OptionsListEntry.OPTION_KEYMAP:
				if (!_bRemapMode) {
					_currentRemapOption = a_index;
					initRemapMode();
				}
				break;

			case OptionsListEntry.OPTION_INPUT:
				_dialogTitleText = e.text;
				_state = WAIT_FOR_INPUT_DATA;
				skse.SendModEvent("SKICP_inputSelected", null, a_index);

			case OptionsListEntry.OPTION_EMPTY:
			case OptionsListEntry.OPTION_HEADER:
			default:
				return;
		}
	}

	private function initRemapMode()
	{
		dimOut();
		var dialog = skyui.util.DialogManager.open(this, "KeymapDialog", {_x: 719, _y: 240});
		dialog.background._width = dialog.textField.textWidth + 100;

		_bRemapMode = true;
		skse.StartRemapMode(this);
	}

	// @SKSE
	private function EndRemapMode(a_keyCode)
	{
		selectedKeyCode = a_keyCode;
		_state = WAIT_FOR_SELECT;
		skse.SendModEvent("SKICP_keymapChanged", null, _currentRemapOption);
		_remapDelayID = setInterval(this, "clearRemap", 200);

		skyui.util.DialogManager.close();
		dimIn();
	}

	private function clearRemap()
	{
		clearInterval(_remapDelayID);
		delete _remapDelayID;

		_bRemapMode = false;
		_currentRemapOption = -1;
	}

	private function initHighlightOption(a_index)
	{
		if (_state != READY)
			return;

		// Same option?
		if (a_index == _highlightIndex)
			return;

		_highlightIndex = a_index;

		clearInterval(_highlightIntervalID);
		_highlightIntervalID = setInterval(this, "doHighlightOption", 200, a_index);
	}

	private function doHighlightOption(a_index)
	{
		clearInterval(_highlightIntervalID);
		delete _highlightIntervalID;

		skse.SendModEvent("SKICP_optionHighlighted", null, a_index);
	}

	private function applyTitleText()
	{
		titlebar.textField.text = _titleText;

		var w = titlebar.textField.textWidth + 100;
		if (w < 300)
			w = 300;

		titlebar.background._width = w;
	}

	private function applyInfoText()
	{
		var t = contentHolder.infoPanel;

		t.textField.text = skyui.util.GlobalFunctions.unescape(_infoText);

		var h;
		if (_infoText != "") {
			h = t.textField.textHeight + 22;
			t.background._height = h;
		} else {
			t.background._height = 32;
		}
	}

	private function changeFocus(a_focus)
	{
		_focus = a_focus;
		gfx.managers.FocusHandler.instance.setFocus(a_focus != FOCUS_OPTIONS ? _modListPanel : _optionsList, 0);
	}

	private function dimOut()
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
		_optionsList.disableSelection = _optionsList.disableInput = true;
		_modListPanel.isDisabled = true;

		skyui.util.Tween.LinearTween(bottomBar, "_alpha", 100, 0, 0.5, null);
		skyui.util.Tween.LinearTween(bottomBar, "_y", _bottomBarStartY, _bottomBarStartY + 50, 0.5, null);

		skyui.util.Tween.LinearTween(contentHolder, "_alpha", 100, 75, 0.5, null);
	}

	private function dimIn()
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuBladeCloseSD"]);
		_optionsList.disableSelection = _optionsList.disableInput = false;
		_modListPanel.isDisabled = false;

		skyui.util.Tween.LinearTween(bottomBar, "_alpha", 0, 100, 0.5, null);
		skyui.util.Tween.LinearTween(bottomBar, "_y", _bottomBarStartY + 50, _bottomBarStartY, 0.5, null);

		skyui.util.Tween.LinearTween(contentHolder, "_alpha", 75, 100, 0.5, null);
	}

	private function showWelcomeScreen()
	{
		setCustomContentParams(150, 50);
		loadCustomContent("skyui/mcm_splash.swf");

		setTitleText("$MOD CONFIGURATION");
		setInfoText("");
	}

	private function updateModListButtons(a_bSubList)
	{
		var entry = _modListPanel.selectedEntry;

		_buttonPanelL.clearButtons();
		if (entry != null)
			_buttonPanelL.addButton({text: "$Select", controls: _acceptControls});
		_buttonPanelL.updateButtons(true);

		_buttonPanelR.clearButtons();
		_buttonPanelR.addButton({text: (!a_bSubList ? "$Exit" : "$Back"), controls: _cancelControls});
		_buttonPanelR.updateButtons(true);
	}

	private function updateOptionButtons()
	{
		var entry = _optionsList.selectedEntry;

		_buttonPanelL.clearButtons();

		var type;
		if (entry != null && !(entry.flags & (OptionsListEntry.FLAG_DISABLED | OptionsListEntry.FLAG_HIDDEN))) {
			type = entry.optionType;
			switch (type) {
				case OptionsListEntry.OPTION_TOGGLE:
					_buttonPanelL.addButton({text: "$Toggle", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_TEXT:
					_buttonPanelL.addButton({text: "$Select", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_SLIDER:
					_buttonPanelL.addButton({text: "$Open Slider", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_MENU:
					_buttonPanelL.addButton({text: "$Open Menu", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_COLOR:
					_buttonPanelL.addButton({text: "$Pick Color", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_INPUT:
					_buttonPanelL.addButton({text: "$Input Text", controls: _acceptControls});
					break;
				case OptionsListEntry.OPTION_KEYMAP:
					_buttonPanelL.addButton({text: "$Remap", controls: _acceptControls});
					if (entry.flags & OptionsListEntry.FLAG_WITH_UNMAP)
						_buttonPanelL.addButton({text: "$Unmap", controls: _unmapControls});
					break;
				case OptionsListEntry.OPTION_EMPTY:
				case OptionsListEntry.OPTION_HEADER:
			}

			if (type != OptionsListEntry.OPTION_EMPTY && type != OptionsListEntry.OPTION_HEADER) {
				_buttonPanelL.addButton({text: "$Default", controls: _defaultControls});
				_bDefaultEnabled = true;
			} else {
				_bDefaultEnabled = false;
			}
		} else {
			_bDefaultEnabled = false;
		}

		_buttonPanelL.updateButtons(true);

		_buttonPanelR.clearButtons();
		_buttonPanelR.addButton({text: "$Back", controls: _cancelControls});
		_buttonPanelR.updateButtons(true);
	}
}
