class ConfigPanel extends MovieClip
{
  /* CONSTANTS */

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

    private var _platform: Number;

    // Quest_Journal_mc
    private var _parentMenu: MovieClip;
    private var _buttonPanelL: ButtonPanel;
    private var _buttonPanelR: ButtonPanel;
    
    private var _bottomBarStartY: Number;
    
    private var _modListPanel: ModListPanel;
    private var _modList: ScrollingList;
    private var _subList: ScrollingList;
    private var _optionsList: MultiColumnScrollingList;

    private var _customContent: MovieClip;
    private var _customContentX: Number = 0;
    private var _customContentY: Number = 0;
    
    private var _state: Number;
    private var _focus: Number;
    
    private var _optionFlagsBuffer: Array;
    private var _optionTextBuffer: Array;
    private var _optionStrValueBuffer: Array;
    private var _optionNumValueBuffer: Array;
    
    private var _titleText: String = "";
    private var _infoText: String = "";
    private var	_dialogTitleText: String = "";
    
    private var _highlightIndex: Number = -1;
    private var _highlightIntervalID: Number;
    
    private var _menuDialogOptions: Array;
    
    private var	_sliderDialogFormatString: String = "";
    
    private var _currentRemapOption: Number = -1;
    private var _bRemapMode: Boolean = false;
    private var _remapDelayID: Number;
    
    private var _acceptControls: Object;
    private var _cancelControls: Object;
    private var _defaultControls: Object;
    private var _unmapControls: Object;
    
    private var _bDefaultEnabled: Boolean = false;
    
    private var _bRequestPageReset: Boolean = false;
    
    
  /* STAGE ELEMENTS */

    public var contentHolder: MovieClip;
    
    public var titlebar: MovieClip;
    
    public var bottomBar: MovieClip;
    
    
  /* INITIALIATZION */
    
    public function ConfigPanel()
    {
        super();
        // A bit hackish but w/e
        this._parentMenu = _root.QuestJournalFader.Menu_mc;

        this._modListPanel = this.contentHolder.modListPanel;
        this._modList = this._modListPanel.modListFader.list;
        this._subList = this._modListPanel.subListFader.list;
        this._optionsList = this.contentHolder.optionsPanel.optionsList;
        
        this._buttonPanelL = this.bottomBar.buttonPanelL;
        this._buttonPanelR = this.bottomBar.buttonPanelR;
        
        this._state = ConfigPanel.READY;
        
        this._optionFlagsBuffer = [];
        this._optionTextBuffer = [];
        this._optionStrValueBuffer = [];
        this._optionNumValueBuffer = [];
        
        this._menuDialogOptions = [];

        this.contentHolder.infoPanel.textField.verticalAutoSize = "top";
    }
    
    // @override MovieClip
    private function onLoad()
    {
        super.onLoad();

        this._modList.listEnumeration = new skyui.components.list.BasicEnumeration(this._modList.entryList);
        this._subList.listEnumeration = new skyui.components.list.BasicEnumeration(this._subList.entryList);
        this._optionsList.listEnumeration = new skyui.components.list.BasicEnumeration(this._optionsList.entryList);
        
        this._modList.addEventListener("itemPress", this, "onModListPress");
        this._modList.addEventListener("selectionChange", this, "onModListChange");
        
        this._subList.addEventListener("itemPress", this, "onSubListPress");
        this._subList.addEventListener("selectionChange", this, "onSubListChange");
        
        this._optionsList.addEventListener("itemPress", this, "onOptionPress");
        this._optionsList.addEventListener("selectionChange", this, "onOptionChange");
        
        this._modListPanel.addEventListener("modListEnter", this, "onModListEnter");
        this._modListPanel.addEventListener("modListExit", this, "onModListExit");
        this._modListPanel.addEventListener("subListEnter", this, "onSubListEnter");
        this._modListPanel.addEventListener("subListExit", this, "onSubListExit");

        this._optionsList._visible = false;
    }
    
    
  /* PAPYRUS INTERFACE */

    // Holds last selected key
    public var selectedKeyCode = -1;

    public function unlock()
    {
        this._state = ConfigPanel.READY;
        
        // Execute depending forced reset when ready
        if (this._bRequestPageReset) {
            this._bRequestPageReset = false;
            var entry = this._subList.listState.activeEntry;
            this.selectPage(entry);
            return;
        }
    }
    
    public function setModNames(/* names */)
    {
        this._modList.clearList();
        this._modList.listState.savedIndex = null;
        
        for (var i = 0; i < arguments.length; i++) {
            var s = arguments[i];
            if (s != "")
                this._modList.entryList.push({modIndex: i, modName: s, text: skyui.util.Translator.translate(s), align: "right", enabled: true});
        }

        this._modList.entryList.sortOn("text", Array.CASEINSENSITIVE);
        this._modList.InvalidateData();
    }
    
    public function setPageNames(/* names */)
    {
        this._subList.clearList();
        this._subList.listState.savedIndex = null;
        
        for (var i = 0; i < arguments.length; i++) {
            var s = arguments[i];
            if (s.toLowerCase() != "none")
                this._subList.entryList.push({pageIndex: i, pageName: s, text: skyui.util.Translator.translate(s), align: "right", enabled: true});
        }
        this._subList.InvalidateData();
    }
    
    public function setCustomContentParams(a_x: Number, a_y: Number)
    {
        this._customContentX = a_x;
        this._customContentY = a_y;
    }
    
    public function loadCustomContent(a_source: String)
    {
        this.unloadCustomContent();
        
        var optionsPanel: MovieClip = this.contentHolder.optionsPanel;
        
        this._customContent = optionsPanel.createEmptyMovieClip("customContent", optionsPanel.getNextHighestDepth());
        this._customContent._x = this._customContentX;
        this._customContent._y = this._customContentY;
        this._customContent.loadMovie(a_source);
        
        this._optionsList._visible = false;
    }
    
    public function unloadCustomContent()
    {
        if (!this._customContent)
            return;
            
        this._customContent.removeMovieClip();
        this._customContent = undefined;
        
        this._optionsList._visible = true;
    }
    
    public function setTitleText(a_text: String)
    {
        this._titleText = skyui.util.Translator.translate(a_text).toUpperCase();
        
        // Don't apply yet if waiting for option data
        if (this._state != ConfigPanel.WAIT_FOR_OPTION_DATA)
            this.applyTitleText();
    }
    
    public function setInfoText(a_text: String)
    {
        this._infoText = skyui.util.Translator.translateNested(a_text);
        
        // Don't apply yet if waiting for option data
        if (this._state != ConfigPanel.WAIT_FOR_OPTION_DATA)
            this.applyInfoText();
    }
    
    public function setOptionFlagsBuffer(/* values */)
    {
        for (var i = 0; i < arguments.length; i++)
            this._optionFlagsBuffer[i] = arguments[i];
    }
    
    public function setOptionTextBuffer(/* values */)
    {
        for (var i = 0; i < arguments.length; i++)
            this._optionTextBuffer[i] = skyui.util.Translator.translateNested(arguments[i]);
    }
    
    public function setOptionStrValueBuffer(/* values */)
    {
        for (var i = 0; i < arguments.length; i++)
            this._optionStrValueBuffer[i] = (arguments[i].toLowerCase() == "none") ? null : arguments[i];
    }
    
    public function setOptionNumValueBuffer(/* values */)
    {
        for (var i = 0; i < arguments.length; i++)
            this._optionNumValueBuffer[i] = arguments[i];
    }

    public function setSliderDialogParams(a_value: Number, a_default: Number, a_min: Number, a_max: Number, a_interval: Number)
    {
        this._state = ConfigPanel.DIALOG;
        
        var initObj = {
            _x: 719, _y: 265,
            platform: this._platform,
            titleText: this._dialogTitleText,
            sliderValue: a_value,
            sliderDefault: a_default,
            sliderMax: a_max,
            sliderMin: a_min,
            sliderInterval: a_interval,
            sliderFormatString: this._sliderDialogFormatString
        };
        
        var dialog = skyui.util.DialogManager.open(this, "OptionSliderDialog", initObj);
        dialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
        dialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
        this.dimOut();
    }
    
    public function setMenuDialogOptions(/* values */)
    {
        this._menuDialogOptions.splice(0);
        
        for (var i = 0; i < arguments.length; i++) {
            var s = arguments[i];
            
            // Cut off rest of the buffer once the first emtpy string was found
            if (s.toLowerCase() == "none" || s == "")
                break;
                
            this._menuDialogOptions[i] = skyui.util.Translator.translateNested(arguments[i]);
        }
    }
    
    public function setMenuDialogParams(a_startIndex: Number, a_defaultIndex: Number)
    {
        this._state = ConfigPanel.DIALOG;
        
        var initObj = {
            _x: 719, _y: 265,
            platform: this._platform,
            titleText: this._dialogTitleText,
            menuOptions:this. _menuDialogOptions,
            menuStartIndex: a_startIndex,
            menuDefaultIndex: a_defaultIndex
        };
        
        var dialog = skyui.util.DialogManager.open(this, "OptionMenuDialog", initObj);
        dialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
        dialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
        this.dimOut();
    }

    public function setColorDialogParams(a_currentColor: Number, a_defaultColor: Number)
    {
        this._state = ConfigPanel.DIALOG;
        
        var initObj = {
            _x: 719, _y: 265,
            platform: this._platform,
            titleText: this._dialogTitleText,
            currentColor: a_currentColor,
            defaultColor: a_defaultColor
        };
        
        var dialog = skyui.util.DialogManager.open(this, "OptionColorDialog", initObj);
        dialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
        dialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
        this.dimOut();
    }

    function setInputDialogParams(a_initialText)
    {
        this._state = ConfigPanel.DIALOG;

        var initObj = {
            _x:719, _y:265,
            platform: this._platform,
            titleText: this._dialogTitleText,
            initialText: a_initialText
        };

        var dialog = skyui.util.DialogManager.open(this, "OptionTextInputDialog", initObj);
        dialog.addEventListener("dialogClosed", this, "onOptionChangeDialogClosed");
        dialog.addEventListener("dialogClosing", this, "onOptionChangeDialogClosing");
        this.dimOut();
    }
    
    public function flushOptionBuffers(a_optionCount: Number)
    {
        this._optionsList.clearList();
        this._optionsList.listState.savedIndex = null;
        
        for (var i = 0; i < a_optionCount; i++) {
            // Both option type and flags are passed in the flags buffer
            var optionType = this._optionFlagsBuffer[i] & 0xFF;
            var flags = (this._optionFlagsBuffer[i] >>> 8) & 0xFF;
            
            this._optionsList.entryList.push({optionType: optionType, 
                                        text: this._optionTextBuffer[i],
                                        strValue: this._optionStrValueBuffer[i],
                                        numValue: this._optionNumValueBuffer[i],
                                        flags: flags});
        }
        
        // Pad uneven option count with empty option keyboard selection area is symmetrical
        if ((this._optionsList.entryList.length % 2) != 0)
            this._optionsList.entryList.push({optionType: OptionsListEntry.OPTION_EMPTY});
            
        this._optionsList.InvalidateData();
        this._optionsList.selectedIndex = -1;
        
        this._optionFlagsBuffer.splice(0);
        this._optionTextBuffer.splice(0);
        this._optionStrValueBuffer.splice(0);
        this._optionNumValueBuffer.splice(0);
        
        this.applyTitleText();
        
        this._highlightIndex = -1;
        clearInterval(this._highlightIntervalID);
        
        this._infoText = "";
        this.applyInfoText();
    }
    
    // Direct access to option data
    public var optionCursorIndex = -1;
    
    public function get optionCursor()
    {
        return this._optionsList.entryList[this.optionCursorIndex];
    }
    
    public function invalidateOptionData()
    {
        this._optionsList.InvalidateData();
    }
    
    public function setOptionFlags(/* values */)
    {
        var index = arguments[0];
        var flags = arguments[1];
        this._optionsList.entryList[index].flags = flags;
    }
    
    public function forcePageReset()
    {
        this._bRequestPageReset = true;
    }
    
    public function showMessageDialog(a_text: String, a_acceptLabel: String, a_cancelLabel: String)
    {
        // Don't open it while ConfigPanel.READY cause we should always be waiting for something.
        if (this._state == ConfigPanel.READY) {
            skse.SendModEvent("SKICP_messageDialogClosed", null, 0);
            return;
        }
        
        // This is a special dialog. It doesn't result in Papyrus event when closed but instead the
        // thread opening is supposed to sleep and wait until it's closed again (behaving like Message.Show()).
        // It keeps _state set to whatever it was.
        var initObj = {
            _x: 719, _y: 265,
            platform: this._platform,
            messageText: a_text,
            acceptLabel: a_acceptLabel,
            cancelLabel: a_cancelLabel
        };
        
        var dialog = skyui.util.DialogManager.open(this, "MessageDialog", initObj);
        dialog.addEventListener("dialogClosing", this, "onMessageDialogClosing");
        this.dimOut();
    }
    
    
  /* PUBLIC FUNCTIONS */

    public function initExtensions()
    {
        Stage.scaleMode = "showAll";
        Shared.GlobalFunc.SetLockFunction();
        this.bottomBar.Lock("B");
        var marginBottomBar = 8;

        this.bottomBar._y += Stage.safeRect.y - marginBottomBar;
        this._bottomBarStartY = this.bottomBar._y;
        
        this.showWelcomeScreen();
    }
    
    public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean)
    {
        this._platform = a_platform;
        
        if (a_platform == 0) {
            this._acceptControls = skyui.defines.Input.Enter;
            this._cancelControls = skyui.defines.Input.Tab;
            this._defaultControls = skyui.defines.Input.ReadyWeapon;
            this._unmapControls = skyui.defines.Input.JournalYButton;
        } else {
            this._acceptControls = skyui.defines.Input.Accept;
            this._cancelControls = skyui.defines.Input.Cancel;
            this._defaultControls = skyui.defines.Input.JournalXButton;
            this._unmapControls = skyui.defines.Input.JournalYButton;
        }
        
        this._buttonPanelL.setPlatform(a_platform, a_bPS3Switch);
        this._buttonPanelR.setPlatform(a_platform, a_bPS3Switch);
        
        this.updateModListButtons(false);
    }

    public function startPage()
    {
        gfx.io.GameDelegate.call("PlaySound", ["UIMenuOK"]);
        this._parent.gotoAndPlay("fadeIn");
        
        this.changeFocus(ConfigPanel.FOCUS_MODLIST);
        this.showWelcomeScreen();
    }
    
    public function endPage()
    {
        gfx.io.GameDelegate.call("PlaySound", ["UIMenuCancel"]);
        this._parent.gotoAndPlay("fadeOut");
    }
    
    // @GFx
    public function handleInput(details: InputDetails, pathToFocus: Array)
    {
        if (this._bRemapMode)
            return true;
        
        if (Shared.GlobalFunc.IsKeyPressed(details)) {
            if (this._focus == ConfigPanel.FOCUS_OPTIONS) {
                var valid = !this._optionsList.disableInput && this._optionsList.selectedIndex % 2 == 0 && this._subList.entryList.length > 0 && this._subList._visible;
                if (valid && details.navEquivalent == gfx.ui.NavigationCode.LEFT) {
                    this.changeFocus(ConfigPanel.FOCUS_MODLIST);
                    this._optionsList.listState.savedIndex = this._optionsList.selectedIndex;
                    this._optionsList.selectedIndex = -1;
                    
                    var restored = this._subList.listState.savedIndex;
                    this._subList.selectedIndex = (restored > -1) ? restored : ((this._subList.listState.activeEntry.itemIndex > -1) ? this._subList.listState.activeEntry.itemIndex : 0);
                    return true;
                }
            } else if (this._focus == ConfigPanel.FOCUS_MODLIST) {
                var valid = !this._subList.disableInput && this._optionsList.entryList.length > 0 && this._optionsList._visible;
                if (valid && details.navEquivalent == gfx.ui.NavigationCode.RIGHT) {
                    this.changeFocus(ConfigPanel.FOCUS_OPTIONS);
                    this._subList.listState.savedIndex = this._subList.selectedIndex;
                    this._subList.selectedIndex = -1;
                    
                    var restored = this._optionsList.listState.savedIndex;
                    this._optionsList.selectedIndex = (restored > -1) ? restored : 0;
                    return true;
                }
            }
        }
        
        var nextClip = pathToFocus.shift();
        if (nextClip && nextClip.handleInput(details, pathToFocus))
            return true;
    
        if (Shared.GlobalFunc.IsKeyPressed(details, false)) {
            if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
                
                if (this._modListPanel.isSublistActive()) {
                    this.changeFocus(ConfigPanel.FOCUS_MODLIST);
                    this._modListPanel.showList();
                } else if (this._modListPanel.isListActive()) {
                    this._parentMenu.ConfigPanelClose();
                }
                return true;
            } else if (details.control == this._defaultControls.name) {
                this.requestDefaults();
                return true;
            } else if (details.control == this._unmapControls.name) {
                this.requestUnmap();
                return true;
            }
        }
        
        // Don't forward to higher level
        return true;
    }
    
    
  /* PRIVATE FUNCTIONS */

    private function requestDefaults()
    {
        if (this._state != ConfigPanel.READY)
            return;

        var index = this._optionsList.selectedIndex;
        if (index == -1)
            return;

        if (this._optionsList.selectedEntry.flags & OptionsListEntry.FLAG_DISABLED)
            return;

        this._state = ConfigPanel.WAIT_FOR_DEFAULT;
        skse.SendModEvent("SKICP_optionDefaulted", null, index);
    }
    
    private function requestUnmap()
    {
        if (this._state != ConfigPanel.READY)
            return;
            
        var index = this._optionsList.selectedIndex;
        if (index == -1)
            return;

        if (this._optionsList.selectedEntry.flags & (OptionsListEntry.FLAG_DISABLED | OptionsListEntry.FLAG_HIDDEN))
            return;

        if (!(this._optionsList.selectedEntry.flags & OptionsListEntry.FLAG_WITH_UNMAP))
            return;

        this.selectedKeyCode = -1;
        this._state = ConfigPanel.WAIT_FOR_SELECT;
        skse.SendModEvent("SKICP_keymapChanged", null, index);
    }

    private function onModListEnter(event: Object)
    {
        this.showWelcomeScreen();
    }
    
    private function onModListExit(event: Object)
    {
    }
    
    private function onSubListEnter(event: Object)
    {
    }
    
    private function onSubListExit(event: Object)
    {
        this._optionsList.clearList();
        this._optionsList.InvalidateData();
        this.unloadCustomContent();
    }
    
    private function onModListPress(a_event: Object)
    {
        this.selectMod(a_event.entry);
    }
    
    private function onModListChange(a_event: Object)
    {
        if (a_event.index != -1)
            this.changeFocus(ConfigPanel.FOCUS_MODLIST);
            
        this.updateModListButtons(false);
    }
    
    private function onSubListPress(a_event: Object)
    {
        this.selectPage(a_event.entry);
    }
    
    private function onSubListChange(a_event: Object)
    {
        if (a_event.index != -1)
            this.changeFocus(ConfigPanel.FOCUS_MODLIST);
            
        this.updateModListButtons(true);
    }
    
    private function onOptionPress(a_event: Object)
    {
        this.selectOption(a_event.index);
    }
    
    private function onOptionChange(a_event: Object)
    {
        if (a_event.index != -1)
            this.changeFocus(ConfigPanel.FOCUS_OPTIONS);
        
        this.initHighlightOption(a_event.index);
        this.updateOptionButtons();
    }
    
    private function onOptionChangeDialogClosing(event: Object)
    {
        this.dimIn();
    }
    
    private function onMessageDialogClosing(event: Object)
    {
        this.dimIn();
    }
    
    
    private function onOptionChangeDialogClosed(event: Object)
    {
    }
    
    private function selectMod(a_entry: Object)
    {		
        if (this._state != ConfigPanel.READY)
            return;
        
        this._subList.listState.activeEntry = null;
        this._subList.clearList();
        this._subList.InvalidateData();
        
        this._optionsList.clearList();
        this._optionsList.InvalidateData();
        this.unloadCustomContent();
        
        this._state = ConfigPanel.WAIT_FOR_OPTION_DATA;
        skse.SendModEvent("SKICP_modSelected", null, a_entry.modIndex);
        
        this._modListPanel.showSublist();
    }
    
    private function selectPage(a_entry: Object)
    {		
        if (this._state != ConfigPanel.READY)
            return;
            
        if (a_entry != null) {
            this._subList.listState.activeEntry = a_entry;
            this._subList.UpdateList();
            
            // Send name as well so mod doesn't have to look it up by index later
            this._state = ConfigPanel.WAIT_FOR_OPTION_DATA;
            skse.SendModEvent("SKICP_pageSelected", a_entry.pageName, a_entry.pageIndex);
            
        // Special case for ForcePageReset without any pages
        } else {
            this._state = ConfigPanel.WAIT_FOR_OPTION_DATA;
            skse.SendModEvent("SKICP_pageSelected", "", -1);
        }
    }
    
    private function selectOption(a_index: Number)
    {
        if (this._state != ConfigPanel.READY)
            return;
        
        var e = this._optionsList.selectedEntry;
        if (e == undefined)
            return;
            
        if (e.flags & OptionsListEntry.FLAG_DISABLED)
            return
        
        switch (e.optionType) {
            case OptionsListEntry.OPTION_EMPTY:
            case OptionsListEntry.OPTION_HEADER:
                break;
                
            case OptionsListEntry.OPTION_TEXT:
            case OptionsListEntry.OPTION_TOGGLE:
                this._state = ConfigPanel.WAIT_FOR_SELECT;
                skse.SendModEvent("SKICP_optionSelected", null, a_index);
                break;
                
            case OptionsListEntry.OPTION_SLIDER:
                this._dialogTitleText = e.text;
                this._sliderDialogFormatString = e.strValue;
                this._state = ConfigPanel.WAIT_FOR_SLIDER_DATA;
                skse.SendModEvent("SKICP_sliderSelected", null, a_index);
                break;
                
            case OptionsListEntry.OPTION_MENU:
                this._dialogTitleText = e.text;
                this._state = ConfigPanel.WAIT_FOR_MENU_DATA;
                skse.SendModEvent("SKICP_menuSelected", null, a_index);
                break;

            case OptionsListEntry.OPTION_COLOR:
                this._dialogTitleText = e.text;
                this._state = ConfigPanel.WAIT_FOR_COLOR_DATA;
                skse.SendModEvent("SKICP_colorSelected", null, a_index);
                break;
                
            case OptionsListEntry.OPTION_KEYMAP:
                if (!this._bRemapMode) {
                    this._currentRemapOption = a_index;
                    this.initRemapMode();
                }
                break;
            case OptionsListEntry.OPTION_INPUT:
                this._dialogTitleText = e.text;
                this._state = ConfigPanel.WAIT_FOR_INPUT_DATA;
                skse.SendModEvent("SKICP_inputSelected", null, a_index);
                break;
        }
    }
    
    private function initRemapMode()
    {
        this.dimOut();
        var dialog = skyui.util.DialogManager.open(this, "KeymapDialog", {_x: 719, _y: 240});
        dialog.background._width = dialog.textField.textWidth + 100;
        
        this._bRemapMode = true;
        skse.StartRemapMode(this);
    }
    
    // @SKSE
    private function EndRemapMode(a_keyCode: Number)
    {
        this.selectedKeyCode = a_keyCode;
        this._state = ConfigPanel.WAIT_FOR_SELECT;
        skse.SendModEvent("SKICP_keymapChanged", null, this._currentRemapOption);
        this._remapDelayID = setInterval(this, "clearRemap", 200);
        
        skyui.util.DialogManager.close();
        this.dimIn();
    }
    
    private function clearRemap()
    {
        clearInterval(this._remapDelayID);
        delete this._remapDelayID;
        
        this._bRemapMode = false;
        this._currentRemapOption = -1;
    }
    
    private function initHighlightOption(a_index: Number)
    {
        if (this._state != ConfigPanel.READY)
            return;
        
        // Same option?
        if (a_index == this._highlightIndex)
            return;

        this._highlightIndex = a_index;
        
        clearInterval(this._highlightIntervalID);
        this._highlightIntervalID = setInterval(this, "doHighlightOption", 200, a_index);
    }
    
    private function doHighlightOption(a_index: Number)
    {
        clearInterval(this._highlightIntervalID);
        delete this._highlightIntervalID;
        
        skse.SendModEvent("SKICP_optionHighlighted", null, a_index);
    }
    
    private function applyTitleText()
    {
        this.titlebar.textField.text = this._titleText;
        
        var w = this.titlebar.textField.textWidth + 100;
        if (w < 300)
            w = 300;
            
        this.titlebar.background._width = w;
    }
    
    private function applyInfoText()
    {
        var t = this.contentHolder.infoPanel;
        
        t.textField.text = skyui.util.GlobalFunctions.unescape(this._infoText);
        
        if (this._infoText != "") {
            var h = t.textField.textHeight + 22;
            t.background._height = h;
        } else {
            t.background._height = 32;
        }
    }
    
    private function changeFocus(a_focus: Number)
    {
        this._focus = a_focus;
        gfx.managers.FocusHandler.instance.setFocus(a_focus == ConfigPanel.FOCUS_OPTIONS ? this._optionsList : this._modListPanel, 0);
    }
    
    private function dimOut()
    {
        gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
        this._optionsList.disableSelection = this._optionsList.disableInput = true;
        this._modListPanel.isDisabled = true;

        skyui.util.Tween.LinearTween(this.bottomBar, "_alpha", 100, 0, 0.5, null);
        skyui.util.Tween.LinearTween(this.bottomBar, "_y", this._bottomBarStartY, this._bottomBarStartY + 50, 0.5, null);

        skyui.util.Tween.LinearTween(this.contentHolder, "_alpha", 100, 75, 0.5, null);
    }
    
    private function dimIn()
    {
        gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
        this._optionsList.disableSelection = this._optionsList.disableInput = false;
        this._modListPanel.isDisabled = false;


        skyui.util.Tween.LinearTween(this.bottomBar, "_alpha", 0, 100, 0.5, null);
        skyui.util.Tween.LinearTween(this.bottomBar, "_y", this._bottomBarStartY + 50, this._bottomBarStartY, 0.5, null);

        skyui.util.Tween.LinearTween(this.contentHolder, "_alpha", 75, 100, 0.5, null);
    }
    
    private function showWelcomeScreen()
    {
        this.setCustomContentParams(150, 50);
        this.loadCustomContent("skyui/mcm_splash.swf");

        this.setTitleText("$MOD CONFIGURATION");
        this.setInfoText("");
    }
    
    private function updateModListButtons(a_bSubList: Boolean)
    {
        var entry = this._modListPanel.selectedEntry;
        
        this._buttonPanelL.clearButtons();
        if (entry != null)
            this._buttonPanelL.addButton({text: "$Select", controls: this._acceptControls});
        this._buttonPanelL.updateButtons(true);

        this._buttonPanelR.clearButtons();
        this._buttonPanelR.addButton({text: a_bSubList? "$Back" : "$Exit", controls: this._cancelControls});
        this._buttonPanelR.updateButtons(true);
    }
    
    private function updateOptionButtons()
    {
        var entry = this._optionsList.selectedEntry;
        
        this._buttonPanelL.clearButtons();
        
        if (entry != null && !(entry.flags & (OptionsListEntry.FLAG_DISABLED | OptionsListEntry.FLAG_HIDDEN))) {
            var type = entry.optionType;
            switch (type) {
                case OptionsListEntry.OPTION_EMPTY:
                case OptionsListEntry.OPTION_HEADER:
                    break;
                case OptionsListEntry.OPTION_TOGGLE:
                    this._buttonPanelL.addButton({text: "$Toggle", controls: this._acceptControls});
                    break;
                case OptionsListEntry.OPTION_TEXT:
                    this._buttonPanelL.addButton({text: "$Select", controls: this._acceptControls});
                    break;
                case OptionsListEntry.OPTION_SLIDER:
                    this._buttonPanelL.addButton({text: "$Open Slider", controls: this._acceptControls});
                    break;
                case OptionsListEntry.OPTION_MENU:
                    this._buttonPanelL.addButton({text: "$Open Menu", controls: this._acceptControls});
                    break;
                case OptionsListEntry.OPTION_COLOR:
                    this._buttonPanelL.addButton({text: "$Pick Color", controls: this._acceptControls});
                    break;
                case OptionsListEntry.OPTION_INPUT:
                    this._buttonPanelL.addButton({text: "$Input Text", controls: this._acceptControls});
                    break;
                case OptionsListEntry.OPTION_KEYMAP:
                    this._buttonPanelL.addButton({text: "$Remap", controls: this._acceptControls});
                    if (entry.flags & OptionsListEntry.FLAG_WITH_UNMAP)
                        this._buttonPanelL.addButton({text: "$Unmap", controls: this._unmapControls});
                    break;
            }

            if (type != OptionsListEntry.OPTION_EMPTY && type != OptionsListEntry.OPTION_HEADER) {
                this._buttonPanelL.addButton({text: "$Default", controls: this._defaultControls});
                this._bDefaultEnabled = true;
            } else {
                this._bDefaultEnabled = false;
            }
        } else {
            this._bDefaultEnabled = false;
        }
        
        this._buttonPanelL.updateButtons(true);

        this._buttonPanelR.clearButtons();
        this._buttonPanelR.addButton({text: "$Back", controls: this._cancelControls});
        this._buttonPanelR.updateButtons(true);
    }
}
