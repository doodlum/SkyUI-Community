class skyui.components.list.ScrollingList extends skyui.components.list.BasicList
{

/*  CONSTANTS & CONFIGURATION */
    
    public var smoothScrollLerp: Number      = 0.25;
    public var smoothScrollThreshold: Number = 0.05;

    public var wheelAccelThreshold: Number   = 200;
    public var wheelAccelMax: Number         = 12.0;

    public var keyRepeatDelay: Number        = 300;
    public var keyRepeatInterval: Number     = 25;

    static var SCROLL_BRIGHTNESS_DIM: Number       = 0.9;
    static var SCROLL_BRIGHTNESS_HIGHLIGHT: Number = 1.25;

    public function applyScrollConfig(a_config: Object)
    {
        if (a_config == undefined) return;

        var value;

        if (a_config.smoothScrollLerp != undefined) {
            value = Number(a_config.smoothScrollLerp);
            if (!isNaN(value)) this.smoothScrollLerp = Math.max(0.01, Math.min(value, 1));
        }
        if (a_config.smoothScrollThreshold != undefined) {
            value = Number(a_config.smoothScrollThreshold);
            if (!isNaN(value)) this.smoothScrollThreshold = Math.max(0.01, value);
        }
        if (a_config.wheelAccelThreshold != undefined) {
            value = Number(a_config.wheelAccelThreshold);
            if (!isNaN(value)) this.wheelAccelThreshold = Math.max(1, value);
        }
        if (a_config.wheelAccelMax != undefined) {
            value = Number(a_config.wheelAccelMax);
            if (!isNaN(value)) this.wheelAccelMax = Math.max(1, value);
        }
        if (a_config.keyRepeatDelay != undefined) {
            value = Number(a_config.keyRepeatDelay);
            if (!isNaN(value)) this.keyRepeatDelay = Math.max(0, value);
        }
        if (a_config.keyRepeatInterval != undefined) {
            value = Number(a_config.keyRepeatInterval);
            if (!isNaN(value)) this.keyRepeatInterval = Math.max(1, value);
        }
    }


/* VARIABLES */

    var _listHeight;
    var _maxListIndex;
    var scrollDownButton;
    var scrollUpButton;
    var scrollbar;
    var selectedEntry;

    var _listIndex              = 0;
    var _curClipIndex           = -1;
    var entryHeight             = 28;
    var scrollDelta             = 1;
    var isPressOnMove           = false;
    var _scrollPosition         = 0;
    var _maxScrollPosition      = 0;

    var _targetScrollPosition   = 0;
    var _floatScrollPosition    = 0;
    var _isSmoothScrolling      = false;
    var _bSmoothing             = false;
    var _lastWheelTime          = 0;

    var _keyRepeatTimeout;
    var _keyRepeatInterval;
    var _heldNavDirection       = -1;
    
    var _scrollbarMouseListener;


/* CONSTRUCTOR */

    function ScrollingList()
    {
        super();
        this._listHeight   = this.background._height - this.topBorder - this.bottomBorder;
        this._maxListIndex = Math.floor(this._listHeight / this.entryHeight);
    }



/* PROPERTIES */

    function get maxScrollPosition() { return this._maxScrollPosition; }

    function get scrollPosition() { return this._scrollPosition; }
    function set scrollPosition(a_newPosition)
    {
        a_newPosition = Math.max(0, Math.min(a_newPosition, this._maxScrollPosition));
        if (a_newPosition == this._scrollPosition) return;

        this._scrollPosition = a_newPosition;

        if (this.scrollbar != undefined) {
            this.scrollbar.position = a_newPosition;
        } else {
            this.updateScrollPosition(a_newPosition);
        }
    }

    function get listHeight() { return this._listHeight; }
    function set listHeight(a_height)
    {
        this._listHeight = this.background._height = a_height;
        if (this.scrollbar != undefined) {
            this.scrollbar.height = this._listHeight;
        }
    }



/* LIFECYCLE */

    function onLoad()
    {
        if (this.scrollbar != undefined) {
            this.scrollbar.position = 0;
            this.scrollbar.addEventListener("scroll", this, "onScroll");
            this.scrollbar._y = this.background._y + this.topBorder;
            this.scrollbar.height = this._listHeight;

            this.initScrollbarHighlights();
        }
    }

    function onUnload()
    {
        if (this._scrollbarMouseListener != undefined) {
            Mouse.removeListener(this._scrollbarMouseListener);
            this._scrollbarMouseListener = undefined;
        }
        this.stopKeyRepeat();
        this.stopSmoothScroll();
    }


/* INPUT HANDLING */

    function handleInput(details, pathToFocus)
    {
        if (this.disableInput) return false;

        var focusedClip    = this.getClipByIndex(this.selectedIndex);
        var handledByChild = focusedClip != undefined
            && focusedClip.handleInput != undefined
            && focusedClip.handleInput(details, pathToFocus.slice(1));
        if (handledByChild) return true;

        var nav = details.navEquivalent;
        var isNavKey = nav == gfx.ui.NavigationCode.UP
            || nav == gfx.ui.NavigationCode.DOWN
            || nav == gfx.ui.NavigationCode.PAGE_UP
            || nav == gfx.ui.NavigationCode.PAGE_DOWN;

        if (isNavKey) {
            if (details.value == "keyDown") {
                this.stopSmoothScroll();
                this.executeNavDirection(nav);
                this.startKeyRepeat(nav);
                return true;
            }
            if (details.value == "keyUp") {
                if (this._heldNavDirection == nav) this.stopKeyRepeat();
                return true;
            }
            if (details.value == "keyHold") {
                return true; 
            }
        }

        if (Shared.GlobalFunc.IsKeyPressed(details)) {
            if (!this.disableSelection && details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
                if (details.code == 96 && this._platform == skyui.components.list.BasicList.PLATFORM_PC) {
                    return false;
                }
                this.onItemPress();
                return true;
            }
        }

        return false;
    }



/* LIST RENDERING */

    // @override
    function UpdateList()
    {
        if (this._bSuspended) {
            this._bRequestUpdate = true;
            return undefined;
        }

        this.setClipCount(this._maxListIndex);

        for (var i = 0; i < this._entryList.length; i++) {
            this._entryList[i].clipIndex = undefined;
        }

        var enumSize  = this.getListEnumSize();
        var scrollPos = this._scrollPosition;
        var drawX     = this.background._x + this.leftBorder;
        var drawY     = this.background._y + this.topBorder;
        var yOffset   = 0;

        for (var i = 0; i < this._maxListIndex; i++) {
            var clip = this.getClipByIndex(i);
            if (clip != undefined && clip.itemIndex != undefined) {
                var entry = this._entryList[clip.itemIndex];
                if (entry != undefined) entry.clipIndex = undefined;
            }
        }

        this._listIndex = 0;
        var enumIdx     = scrollPos;

        while (enumIdx < enumSize && this._listIndex < this._maxListIndex) {
            var clip  = this.getClipByIndex(this._listIndex);
            var entry = this.getListEnumEntry(enumIdx);

            clip.itemIndex  = entry.itemIndex;
            entry.clipIndex = this._listIndex;
            clip.setEntry(entry, this.listState);

            clip._x       = drawX;
            clip._y       = drawY + yOffset;
            clip._visible = true;

            yOffset += this.entryHeight;
            this._listIndex++;
            enumIdx++;
        }

        for (var i = this._listIndex; i < this._maxListIndex; i++) {
            var unusedClip = this.getClipByIndex(i);
            if (unusedClip != undefined) {
                unusedClip._visible  = false;
                unusedClip.itemIndex = undefined;
            }
        }

        if (this.isMouseDrivenNav && this.hitTest(_root._xmouse, _root._ymouse, true)) {
            var mx = _root._xmouse;
            var my = _root._ymouse;
            for (var i = 0; i < this._listIndex; i++) {
                var clip = this.getClipByIndex(i);
                if (clip.hitTest(mx, my, true)) {
                    this.doSetSelectedIndex(clip.itemIndex, skyui.components.list.BasicList.SELECT_MOUSE);
                    break;
                }
            }
        }

        if (this.scrollUpButton   != undefined) this.scrollUpButton._visible   = scrollPos > 0;
        if (this.scrollDownButton != undefined) this.scrollDownButton._visible = scrollPos < this._maxScrollPosition;
    }

    // @override
    function InvalidateData()
    {
        if (this._bSuspended) {
            this._bRequestInvalidate = true;
            return;
        }

        var i = 0;
        while (i < this._entryList.length) {
            this._entryList[i].itemIndex = i;
            this._entryList[i].clipIndex = undefined;
            i++;
        }

        i = 0;
        while (i < this._dataProcessors.length) {
            this._dataProcessors[i].processList(this);
            i++;
        }

        this.listEnumeration.invalidate();

        if (this._selectedIndex >= this.listEnumeration.size()) {
            this._selectedIndex = this.listEnumeration.size() - 1;
        }
        if (this.listEnumeration.lookupEnumIndex(this._selectedIndex) == null) {
            this._selectedIndex = -1;
        }

        if (this._curClipIndex != -1 && this.getListEnumSize() > 0) {
            var targetRow = Math.min(this._curClipIndex, this._maxListIndex - 1);
            var entryAtRow = this.getListEnumEntry(this._scrollPosition + targetRow);
            if (entryAtRow != undefined) {
                this._selectedIndex = entryAtRow.itemIndex;
            }
        }

        this.calculateMaxScrollPosition();

        InventoryListEntry.bDisableAnim = true;
        
        this.UpdateList();
        
        if (this._selectedIndex != -1 && this.selectedEntry != undefined) {
            this._curClipIndex = this.selectedEntry.clipIndex;
        }

        InventoryListEntry.bDisableAnim = false;

        if (this.onInvalidate) {
            this.onInvalidate();
        }
    }



/* SELECTION */

    function moveSelectionUp(a_bScrollPage)
    {
        if (!this.disableSelection && !a_bScrollPage) {
            if (this._selectedIndex == -1) {
                this.selectDefaultIndex(false);
            } else if (this.getSelectedListEnumIndex() >= this.scrollDelta) {
                this.doSetSelectedIndex(
                    this.getListEnumRelativeIndex(-this.scrollDelta),
                    skyui.components.list.BasicList.SELECT_KEYBOARD);
                this.isMouseDrivenNav = false;
                if (this.isPressOnMove) this.onItemPress();
            } else {
                var lastIndex = this.getListEntryIndex(this.getListEnumSize() - 1);
                this.doSetSelectedIndex(lastIndex, skyui.components.list.BasicList.SELECT_KEYBOARD);
                this.isMouseDrivenNav = false;
            }
        } else if (a_bScrollPage) {
            this.scrollPosition -= this._listIndex;
            this.doSetSelectedIndex(-1, skyui.components.list.BasicList.SELECT_MOUSE);
        } else {
            this.scrollPosition -= this.scrollDelta;
        }
    }

    function moveSelectionDown(a_bScrollPage)
    {
        if (!this.disableSelection && !a_bScrollPage) {
            if (this._selectedIndex == -1) {
                this.selectDefaultIndex(true);
            } else if (this.getSelectedListEnumIndex() < this.getListEnumSize() - this.scrollDelta) {
                this.doSetSelectedIndex(
                    this.getListEnumRelativeIndex(this.scrollDelta),
                    skyui.components.list.BasicList.SELECT_KEYBOARD);
                this.isMouseDrivenNav = false;
                if (this.isPressOnMove) this.onItemPress();
            } else {
                var firstIndex = this.getListEntryIndex(0);
                this.doSetSelectedIndex(firstIndex, skyui.components.list.BasicList.SELECT_KEYBOARD);
                this.isMouseDrivenNav = false;
            }
        } else if (a_bScrollPage) {
            this.scrollPosition += this._listIndex;
            this.doSetSelectedIndex(-1, skyui.components.list.BasicList.SELECT_MOUSE);
        } else {
            this.scrollPosition += this.scrollDelta;
        }
    }

    function selectDefaultIndex(a_bTop)
    {
        if (this._listIndex <= 0) return undefined;

        var targetClipIndex = a_bTop ? 0 : (this._listIndex - 1);
        var clip = this.getClipByIndex(targetClipIndex);
        if (clip != undefined && clip.itemIndex != undefined) {
            this.doSetSelectedIndex(clip.itemIndex, skyui.components.list.BasicList.SELECT_KEYBOARD);
        }
    }

    function doSetSelectedIndex(a_newIndex, a_keyboardOrMouse)
    {
        if (this._selectedIndex == -1 && a_newIndex != -1) {
            InventoryListEntry._lastClipY = -1;
        }

        if (this.disableSelection || a_newIndex == this._selectedIndex) {
            return undefined;
        }
        if (a_newIndex != -1 && this.getListEnumIndex(a_newIndex) == undefined) {
            return undefined;
        }

        var prevEntry = this.selectedEntry; 
        this._selectedIndex = a_newIndex;

        if (prevEntry != undefined && prevEntry.clipIndex != undefined) {
            var prevClip = this.getClipByIndex(prevEntry.clipIndex);
            if (prevClip != undefined) {
                prevClip.setEntry(prevEntry, this.listState);
            }
        }

        if (this._selectedIndex != -1) {
            var enumIndex = this.getSelectedListEnumIndex();

            if (enumIndex < this._scrollPosition) {
                this.scrollPosition = enumIndex;
            } else if (enumIndex >= this._scrollPosition + this._listIndex) {
                this.scrollPosition = Math.min(
                    enumIndex - this._listIndex + this.scrollDelta,
                    this._maxScrollPosition
                );
            } else {
                var selClip = this.getClipByIndex(this.selectedEntry.clipIndex);
                if (selClip != undefined) {
                    selClip.setEntry(this.selectedEntry, this.listState);
                }
            }
            
            this._curClipIndex = this.selectedEntry.clipIndex;
        } else {
            this._curClipIndex = -1;
        }

        this.dispatchEvent({
            type:            "selectionChange",
            index:           this._selectedIndex,
            keyboardOrMouse: a_keyboardOrMouse
        });
    }



/* MOUSE WHEEL */

    function onMouseWheel(a_delta)
    {
        if (this.disableInput || !this.hitTest(_root._xmouse, _root._ymouse, true)) return;

        this.isMouseDrivenNav = true;
        var now = getTimer();
        var deltaTime = now - (this._lastWheelTime || 0);
        this._lastWheelTime = now;

        if (!this._isSmoothScrolling) {
            this._targetScrollPosition = this._scrollPosition;
            this._floatScrollPosition  = this._scrollPosition;
        }

        var accel = 1;
        if (deltaTime > 0 && deltaTime < this.wheelAccelThreshold) {
            accel = Math.min(this.wheelAccelThreshold / deltaTime, this.wheelAccelMax);
        }

        var dir = (a_delta > 0) ? -1 : 1;
        var moveAmount = dir * this.scrollDelta * accel;

        this._targetScrollPosition = Math.max(0, Math.min(this._targetScrollPosition + moveAmount, this._maxScrollPosition));

        if (this._targetScrollPosition != this._scrollPosition && !this._isSmoothScrolling) {
            this._isSmoothScrolling = true;
            this.onEnterFrame = this.smoothScrollUpdate;
        }
    }



/* SCROLLBAR EVENTS */

    function onScroll(event)
    {
        if (this._bSmoothing) return;
        this.stopSmoothScroll();
        
        InventoryListEntry.bDisableAnim = true;
        this.updateScrollPosition(Math.round(event.position));
        InventoryListEntry.bDisableAnim = false;
    }


/* SMOOTH SCROLL */

    function stopSmoothScroll()
    {
        if (!this._isSmoothScrolling) return;

        this._isSmoothScrolling    = false;
        this._floatScrollPosition  = this._scrollPosition;
        this._targetScrollPosition = this._scrollPosition;
        delete this.onEnterFrame;
    }

    function smoothScrollUpdate()
    {
        if (!this._isSmoothScrolling) {
            delete this.onEnterFrame;
            return;
        }

        this._floatScrollPosition += (this._targetScrollPosition - this._floatScrollPosition) * this.smoothScrollLerp;

        var reached = Math.abs(this._targetScrollPosition - this._floatScrollPosition) < this.smoothScrollThreshold;
        var nextPos = reached
            ? Math.round(this._targetScrollPosition)
            : Math.max(0, Math.min(Math.round(this._floatScrollPosition), this._maxScrollPosition));

        if (nextPos != this._scrollPosition) {
            this._scrollPosition = nextPos;

            if (this.scrollbar != undefined) {
                this._bSmoothing        = true;
                this.scrollbar.position = nextPos;
                this._bSmoothing        = false;
            }

            InventoryListEntry.bDisableAnim = true;
            this.UpdateList();
            InventoryListEntry.bDisableAnim = false;
        }

        if (reached) {
            this._isSmoothScrolling = false;
            delete this.onEnterFrame;
        }
    }



/* KEYBOARD REPEAT */

    function executeNavDirection(navCode)
    {
        if (navCode == gfx.ui.NavigationCode.UP || navCode == gfx.ui.NavigationCode.PAGE_UP) {
            this.moveSelectionUp(navCode == gfx.ui.NavigationCode.PAGE_UP);
        } else if (navCode == gfx.ui.NavigationCode.DOWN || navCode == gfx.ui.NavigationCode.PAGE_DOWN) {
            this.moveSelectionDown(navCode == gfx.ui.NavigationCode.PAGE_DOWN);
        }
    }

    function startKeyRepeat(navCode)
    {
        this.stopKeyRepeat();  
        this._heldNavDirection = navCode;
        this._keyRepeatTimeout = setInterval(this, "onKeyRepeatStart", this.keyRepeatDelay);
    }

    function onKeyRepeatStart()
    {
        clearInterval(this._keyRepeatTimeout);
        this._keyRepeatInterval = setInterval(this, "onKeyRepeatTick", this.keyRepeatInterval);
    }

    function onKeyRepeatTick()
    {
        if (this._heldNavDirection == -1) {
            this.stopKeyRepeat();
            return;
        }
        this.executeNavDirection(this._heldNavDirection);
    }

    function stopKeyRepeat()
    {
        clearInterval(this._keyRepeatTimeout);
        clearInterval(this._keyRepeatInterval);
        this._heldNavDirection = -1;
    }


/* SCROLL POSITION HELPERS */

    function calculateMaxScrollPosition()
    {
        var overflow = this.getListEnumSize() - this._maxListIndex;
        this._maxScrollPosition = Math.max(0, overflow);
        this.updateScrollbar();
        if (this._scrollPosition > this._maxScrollPosition) {
            this._scrollPosition = this._maxScrollPosition;
        }
    }

    function updateScrollPosition(a_position)
    {
        this._scrollPosition = a_position;
        this.UpdateList();
    }

    function updateScrollbar()
    {
        if (this.scrollbar != undefined) {
            this.scrollbar._visible = this._maxScrollPosition > 0;

            var pageSize = this._maxListIndex; 
            
            this.scrollbar.setScrollProperties(pageSize, 0, this._maxScrollPosition);

            this.scrollbar.lineScrollSize = this.scrollDelta;
            this.scrollbar.pageScrollSize = pageSize;
            
            if (this.scrollbar.trackScrollPageSize != undefined) {
                this.scrollbar.trackScrollPageSize = pageSize;
            }
        }
    }

    function getClipByIndex(a_index)
    {
        if (a_index < 0 || a_index >= this._maxListIndex) return undefined;
        return super.getClipByIndex(a_index);
    }

    function initScrollbarHighlights()
    {
        var sb = this.scrollbar;
        if (sb == undefined) return;

        sb.trackClickEnabled = true;
        sb.trackMode = "scrollPage";
        sb.buttonRepeatDelay = 150; 
        sb.buttonRepeatDuration = 10;

        var dimVal = skyui.components.list.ScrollingList.SCROLL_BRIGHTNESS_DIM;
        var highVal = skyui.components.list.ScrollingList.SCROLL_BRIGHTNESS_HIGHLIGHT;

        var dimTransform = new flash.geom.ColorTransform();
        dimTransform.redMultiplier = dimTransform.greenMultiplier = dimTransform.blueMultiplier = dimVal;

        var brightTransform = new flash.geom.ColorTransform();
        brightTransform.redMultiplier = brightTransform.greenMultiplier = brightTransform.blueMultiplier = highVal;

        sb._alpha = 100;
        var parts = [sb.upArrow, sb.downArrow, sb.thumb, sb.track];
        for (var i = 0; i < parts.length; i++) {
            if (parts[i] != undefined) {
                parts[i]._alpha = 100;
                parts[i].transform.colorTransform = dimTransform;
            }
        }

        var scope = this;
        this._scrollbarMouseListener = new Object();
        var mouseListener = this._scrollbarMouseListener;
        
        mouseListener.onMouseMove = function() {
            var scroll = scope.scrollbar;
            if (scroll != undefined && scroll._visible) {
                var mx = _root._xmouse;
                var my = _root._ymouse;

                var updatePartBrightness = function(a_part, a_isThumb) {
                    if (a_part == undefined) return;

                    var isHighlighted = a_part.hitTest(mx, my, true) || (a_isThumb && a_part.state == "down");

                    if (isHighlighted) {
                        if (a_part.transform.colorTransform.redMultiplier < highVal) {
                            a_part.transform.colorTransform = brightTransform;
                        }
                    } else {
                        if (a_part.transform.colorTransform.redMultiplier > dimVal) {
                            a_part.transform.colorTransform = dimTransform;
                        }
                    }
                };

                updatePartBrightness(scroll.upArrow, false);
                updatePartBrightness(scroll.downArrow, false);
                updatePartBrightness(scroll.thumb, true);
            }
        };
        
        Mouse.addListener(mouseListener);
    }
}
