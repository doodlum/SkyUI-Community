class skyui.components.SearchWidget extends MovieClip
{
    // API
    public var dispatchEvent: Function;
    public var isDisabled: Boolean = false;

    // UI Elements
    public var textField: TextField;

    // Constants
    private static var S_FILTER: String          = "$FILTER";
    private static var MAX_HISTORY: Number       = 20;
    private static var SEP_HISTORY: String       = "||";
    private static var SEP_FIELD: String         = "|";
    private static var DEFAULT_KEY: String       = "default";
    
    // State
    private var _isActive: Boolean = false;
    private var _enableAutoupdate: Boolean = false;
    private var _updateDelay: Number = 0;
    private var _updateTimerId: Number;
    private var _previousFocus: Object;
    
    // Data
    private var _menuKey: String;
    private var _history: Array;
    private var _historyIndex: Number = -1;
    private var _textBeforeHistory: String = "";
    private var _placeholderText: String;

    // ═══════════════════════════════════════════════════════
    // CONSTRUCTOR & INIT
    // ═══════════════════════════════════════════════════════
    public function SearchWidget()
    {
        super();
        gfx.events.EventDispatcher.initialize(this);

        this._menuKey = "default"; 
        this._history = [];
        
        // Setup TextField
        this.textField.noTranslate = true;
        this.textField.SetText(skyui.components.SearchWidget.S_FILTER);
        this._placeholderText = this.textField.text;
        
        this.textField.onKillFocus = function(newFocus: Object) {
            this._parent.deactivateInput(true); // Save history on focus loss
        };

        skyui.util.ConfigManager.registerLoadCallback(this, "onConfigLoad");
    }

    public function isActive() 
    { 
        return this._isActive; 
    }

    public function get menuKey() { return this._menuKey; }
    public function set menuKey(val: String) 
    { 
        this._menuKey = val; 
        this.loadHistoryInternal(); 
    }

    private function onConfigLoad(event: Object)
    {
        this._bEnableAutoupdate = event.config.SearchBox.autoupdate.enable;
        this._updateDelay       = event.config.SearchBox.autoupdate.delay;

        // Auto-detect menu if not explicitly set via property
        if (this._menuKey == skyui.components.SearchWidget.DEFAULT_KEY) {
            this.detectMenuKey();
        }
    }

    private function detectMenuKey()
    {
        var url: String = _root._url;
        if (url == undefined) return;
        
        var lowerUrl: String = url.toLowerCase();
        
        // Map URL substrings to Menu Keys
        if (lowerUrl.indexOf("inventorymenu") != -1)      this._menuKey = "InventoryMenu";
        else if (lowerUrl.indexOf("magicmenu") != -1)     this._menuKey = "MagicMenu";
        else if (lowerUrl.indexOf("containermenu") != -1) this._menuKey = "ContainerMenu";
        else if (lowerUrl.indexOf("bartermenu") != -1)    this._menuKey = "BarterMenu";
        else if (lowerUrl.indexOf("giftmenu") != -1)      this._menuKey = "GiftMenu";
        else if (lowerUrl.indexOf("craftingmenu") != -1)  this._menuKey = "Crafting Menu";
        else this._menuKey = "InventoryMenu"; // Fallback

        this.loadHistoryInternal();
    }

    // ═══════════════════════════════════════════════════════
    // PUBLIC INPUT API
    // ═══════════════════════════════════════════════════════
    // Called by mouse click on the widget
    public function onPress(mouseIndex: Number, keyboardOrMouse: Number)
    {
        this.activateInput();
    }

    // Called by Controller/Keyboard shortcut (e.g. Spacebar) via InventoryLists
    public function onSearchKeyPress()
    {
        if (this._isActive) {
            // FIX: If active but lost focus (e.g. user clicked list), regain focus first
            var currentFocus: Object = eval(Selection.getFocus());
            if (currentFocus != this.textField) {
                this.forceRefocus();
                return;
            }
            
            // If active and focused -> Clear and Reset
            this.textField.SetText("");
            this.deactivateInput(false); 
        } else {
            // If inactive -> Open
            this.activateInput();
        }
    }

    // Called when clearing via long-press (if implemented in container)
    public function onSearchKeyClear()
    {
        if (this._isActive) {
            this.textField.SetText("");
            this._onTextChanged();
        } else {
            this.resetVisuals();
        }
    }

    // ═══════════════════════════════════════════════════════
    // INPUT STATE MANAGEMENT
    // ═══════════════════════════════════════════════════════
    private function activateInput()
    {
        if (this._isActive || this.isDisabled) return;

        this._previousFocus = gfx.managers.FocusHandler.instance.getFocus(0);
        this._historyIndex = -1;
        this._textBeforeHistory = "";

        // Prepare text field
        var currentText: String = this.textField.text;
        var isPlaceholder: Boolean = (currentText == this._placeholderText);
        
        this.textField.type = "input";
        this.textField.selectable = true;
        this.textField.text = isPlaceholder ? "" : currentText;

        this.forceRefocus();

        this._isActive = true;
        skse.AllowTextInput(true);
        this.dispatchEvent({type: "inputStart"});

        // Capture 'this' for the closure
        var self: SearchWidget = this;
        this.textField.onChanged = function() { 
            self._onTextChanged(); 
        };
    }

    private function deactivateInput(saveToHistory: Boolean)
    {
        if (!this._isActive) return;

        // Cleanup
        this.cancelDebounce();
        delete this.textField.onChanged;
        delete _root.onEnterFrame; 

        // Reset UI state
        this.textField.type = "dynamic";
        this.textField.selectable = false;
        
        this.restorePreviousFocus();

        this._isActive = false;
        skse.AllowTextInput(false);

        var finalText: String = this.getTrimmedText();

        if (finalText.length > 0) {
            if (saveToHistory) {
                this.pushHistory(finalText);
            }
            this.dispatchEvent({type: "inputEnd", data: finalText});
        } else {
            this.resetVisuals();
        }
    }

    // Forces focus to the textfield and moves cursor to end
    private function forceRefocus()
    {
        Selection.setFocus(this.textField);
        
        // Scaleform hack: Wait one frame to ensure selection sticks
        var self: SearchWidget = this;
        var tField: TextField = this.textField;
        
        _root.onEnterFrame = function() {
            delete _root.onEnterFrame;
            var len: Number = tField.text.length;
            Selection.setSelection(len, len);
        };
    }

    private function restorePreviousFocus()
    {
        if (this._previousFocus != undefined) {
            var prev: Object = this._previousFocus;
            var wasEnabled: Boolean = prev.focusEnabled;
            prev.focusEnabled = true;
            Selection.setFocus(prev, 0);
            prev.focusEnabled = wasEnabled;
        }
    }

    private function resetVisuals()
    {
        this.textField.SetText(skyui.components.SearchWidget.S_FILTER);
        this._placeholderText = this.textField.text;
        this.dispatchEvent({type: "inputEnd", data: ""});
    }

    // ═══════════════════════════════════════════════════════
    // TEXT CHANGE HANDLERS
    // ═══════════════════════════════════════════════════════
    private function _onTextChanged()
    {
        // Reset history index if user types
        if (this._historyIndex != -1) {
            this._historyIndex = -1;
            this._textBeforeHistory = "";
        }

        if (this._bEnableAutoupdate) {
            this.cancelDebounce();
            this._updateTimerId = setInterval(this, "fireInputChange", this._updateDelay);
        }
    }

    private function fireInputChange()
    {
        this.cancelDebounce();
        this.dispatchEvent({type: "inputChange", data: this.getTrimmedText()});
    }

    private function cancelDebounce()
    {
        if (this._updateTimerId != undefined) {
            clearInterval(this._updateTimerId);
            this._updateTimerId = undefined;
        }
    }

    // ═══════════════════════════════════════════════════════
    // HISTORY & NAVIGATION (UP/DOWN ARROWS)
    // ═══════════════════════════════════════════════════════
    public function handleInput(details: Object, pathToFocus: Array)
    {
        if (!Shared.GlobalFunc.IsKeyPressed(details)) return false;

        var nav: Number = details.navEquivalent;

        if (nav == gfx.ui.NavigationCode.ENTER || nav == gfx.ui.NavigationCode.ESCAPE || nav == gfx.ui.NavigationCode.TAB) {
            this.deactivateInput(true);
            return true;
        }

        if (this._isActive) {
            if (nav == gfx.ui.NavigationCode.UP) {
                this.navigateHistory(-1);
                return true;
            }
            if (nav == gfx.ui.NavigationCode.DOWN) {
                this.navigateHistory(1);
                return true;
            }
        }

        var nextClip = pathToFocus.shift();
        if (nextClip) return nextClip.handleInput(details, pathToFocus);
        return false;
    }

    private function navigateHistory(dir: Number)
    {
        if (this._history.length == 0) return;

        // Start navigation: save current text
        if (this._historyIndex == -1 && dir == -1) {
            this._textBeforeHistory = this.getTrimmedText();
            this._historyIndex = 0;
        } 
        // Move forward
        else if (dir == -1 && this._historyIndex < this._history.length - 1) {
            this._historyIndex++;
        } 
        // Move backward
        else if (dir == 1 && this._historyIndex > 0) {
            this._historyIndex--;
        } 
        // Exit history mode
        else if (dir == 1 && this._historyIndex == 0) {
            this._historyIndex = -1;
            this.updateTextField(this._textBeforeHistory);
            this.fireInputChange();
            return;
        } else {
            return; // Bound reached
        }

        this.updateTextField(this._history[this._historyIndex]);
        this.fireInputChange();
    }

    private function updateTextField(text: String)
    {
        // Temporarily disable listener to prevent triggering logic loop
        delete this.textField.onChanged;
        
        this.textField.SetText((text != undefined) ? text : "");
        var len: Number = this.textField.text.length;
        Selection.setSelection(len, len);

        var self: SearchWidget = this;
        this.textField.onChanged = function() { self._onTextChanged(); };
    }

    private function pushHistory(text: String)
    {
        // Remove duplicates
        for (var i: Number = 0; i < this._history.length; i++) {
            if (this._history[i] == text) {
                this._history.splice(i, 1);
                break;
            }
        }
        
        this._history.unshift(text);
        if (this._history.length > skyui.components.SearchWidget.MAX_HISTORY) {
            this._history.length = skyui.components.SearchWidget.MAX_HISTORY;
        }
        
        this.saveHistoryInternal();
    }

    // ═══════════════════════════════════════════════════════
    // PERSISTENCE (Communicate with Papyrus)
    // ═══════════════════════════════════════════════════════
    private function loadHistoryInternal()
    {
        skse.SendModEvent("LoadSearchHistory", this._menuKey);
    }

    private function saveHistoryInternal()
    {
        var payload: String = this._menuKey + skyui.components.SearchWidget.SEP_FIELD + this._history.join(skyui.components.SearchWidget.SEP_HISTORY);
        skse.SendModEvent("SaveSearchHistory", payload);
    }

    // Callback invoked by Papyrus via UI.InvokeString
    public function receiveHistory(serialized: String)
    {
        if (serialized == undefined || serialized == "") {
            this._history = [];
            return;
        }

        var raw: Array = serialized.split(skyui.components.SearchWidget.SEP_HISTORY);
        var clean: Array = [];

        for (var i: Number = 0; i < raw.length; i++) {
            if (raw[i] != undefined && raw[i] != "") {
                clean.push(raw[i]);
            }
        }
        this._history = clean;
    }

    // ═══════════════════════════════════════════════════════
    // UTILS
    // ═══════════════════════════════════════════════════════
    private function getTrimmedText()
    {
        var s: String = this.textField.text;
        var i: Number = 0; 
        var j: Number = s.length - 1;
        
        if (j < 0) return "";

        // Fast whitespace trim
        while (s.charCodeAt(i) <= 32 && i <= j) i++;
        while (s.charCodeAt(j) <= 32 && j >= i) j--;

        return s.slice(i, j + 1);
    }
}