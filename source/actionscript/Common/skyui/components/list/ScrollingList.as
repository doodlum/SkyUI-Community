class skyui.components.list.ScrollingList extends skyui.components.list.BasicList
{
  /* PRIVATE VARIABLES */ 

    // This serves as the actual size of the list as its incremented during updating
    private var _listIndex: Number = 0;

    private var _curClipIndex: Number = -1;

    // The maximum allowed size. Actual size might be smaller if the list is not filled completely.
    private var _maxListIndex: Number;


  /* STAGE ELEMENTS */

    public var scrollbar: MovieClip;

    public var scrollUpButton: MovieClip;
    public var scrollDownButton: MovieClip;


  /* PROPERTIES */

    public var entryHeight: Number = 28;

    public var scrollDelta: Number = 1;

    public var isPressOnMove: Boolean = false;

    private var _scrollPosition: Number = 0;

    public function get scrollPosition()
    {
        return this._scrollPosition;
    }

    public function set scrollPosition(a_newPosition: Number)
    {
        if (a_newPosition == this._scrollPosition || a_newPosition < 0 || a_newPosition > this._maxScrollPosition)
            return;
            
        if (this.scrollbar != undefined)
            this.scrollbar.position = a_newPosition;
        else
            this.updateScrollPosition(a_newPosition);
    }

    private var _maxScrollPosition: Number = 0;

    public function get maxScrollPosition()
    {
        return this._maxScrollPosition;
    }

    private var _listHeight: Number;

    public function get listHeight()
    {
        return this._listHeight;
    }

    public function set listHeight(a_height: Number)
    {
        this._listHeight = this.background._height = a_height;
        
        if (this.scrollbar != undefined)
            this.scrollbar.height = this._listHeight;
    }


  /* INITIALIZATION */

    public function ScrollingList()
    {
        super();
        
        this._listHeight = this.background._height - this.topBorder - this.bottomBorder;
        
        this._maxListIndex = Math.floor(this._listHeight / this.entryHeight);
    }


  /* PUBLIC FUNCTIONS */

    // @override MovieClip
    public function onLoad()
    {
        if (this.scrollbar != undefined) {
            this.scrollbar.position = 0;
            this.scrollbar.addEventListener("scroll", this, "onScroll");
            this.scrollbar._y = this.background._y + this.topBorder;
            this.scrollbar.height = this._listHeight;
        }
    }

    // @override BasicList
    public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean)
    {
        super.setPlatform(a_platform,a_bPS3Switch);
    }

    // @GFx
    public function handleInput(details: InputDetails, pathToFocus: Array)
    {
        if (this.disableInput)
            return false;

        // That makes no sense, does it?
        var entry = this.getClipByIndex(this.selectedIndex);
        var bHandled = entry != undefined && entry.handleInput != undefined && entry.handleInput(details, pathToFocus.slice(1));
        if (bHandled)
            return true;

        if (Shared.GlobalFunc.IsKeyPressed(details)) {
            if (details.navEquivalent == gfx.ui.NavigationCode.UP || details.navEquivalent == gfx.ui.NavigationCode.PAGE_UP) {
                this.moveSelectionUp(details.navEquivalent == gfx.ui.NavigationCode.PAGE_UP);
                return true;
            } else if (details.navEquivalent == gfx.ui.NavigationCode.DOWN || details.navEquivalent == gfx.ui.NavigationCode.PAGE_DOWN) {
                this.moveSelectionDown(details.navEquivalent == gfx.ui.NavigationCode.PAGE_DOWN);
                return true;
            } else if (!this.disableSelection && details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
                // TODO: See gfx.managers.InputDelegate.inputToNav(); stop it from converting numberpad -> navEquivalent
                // Fix for numberpad 0 being handled as ENTER
                if (details.code == 96 && this._platform == skyui.components.list.BasicList.PLATFORM_PC)
                    return false;

                this.onItemPress();
                return true;

            }
        }
        return false;
    }

    // @override BasicList
    public function UpdateList()
    {
        if (this._bSuspended) {
            this._bRequestUpdate = true;
            return;
        }
        
        // Prepare clips
        this.setClipCount(this._maxListIndex);
        
        var xStart = this.background._x + this.leftBorder;
        var yStart = this.background._y + this.topBorder;
        var h = 0;

        // Clear clipIndex for everything before the selected list portion
        for (var i = 0; i < this.getListEnumSize() && i < this._scrollPosition ; i++)
            this.getListEnumEntry(i).clipIndex = undefined;

        this._listIndex = 0;
        
        // Display the selected list portion of the list
        for (var i = this._scrollPosition; i < this.getListEnumSize() && this._listIndex < this._maxListIndex; i++) {
            var entryClip = this.getClipByIndex(this._listIndex);
            var entryItem = this.getListEnumEntry(i);

            entryClip.itemIndex = entryItem.itemIndex;
            entryItem.clipIndex = this._listIndex;
            
            entryClip.setEntry(entryItem, this.listState);

            entryClip._x = xStart;
            entryClip._y = yStart + h;
            entryClip._visible = true;

            h = h + this.entryHeight;

            ++this._listIndex;
        }
        
        // Clear clipIndex for everything after the selected list portion
        for (var i = this._scrollPosition + this._listIndex; i < this.getListEnumSize(); i++)
            this.getListEnumEntry(i).clipIndex = undefined;
            
        // Select entry under the cursor for mouse-driven navigation
        if (this.isMouseDrivenNav) {
            for (var j = 0; j < this._listIndex; j++) {
                var clip = this.getClipByIndex(j);
                if (clip != undefined && clip._visible && clip.itemIndex != undefined && clip.hitTest(_root._xmouse, _root._ymouse, true)) {
                    this.doSetSelectedIndex(clip.itemIndex, skyui.components.list.BasicList.SELECT_MOUSE);
                    break;
                }
            }
        }
                    
        if (this.scrollUpButton != undefined)
            this.scrollUpButton._visible = this._scrollPosition > 0;
        if (this.scrollDownButton != undefined) 
            this.scrollDownButton._visible = this._scrollPosition < this._maxScrollPosition;
    }

    // @override BasicList
    public function InvalidateData()
    {
        if (this._bSuspended) {
            this._bRequestInvalidate = true;
            return;
        }
        
        for (var i = 0; i < this._entryList.length; i++) {
            this._entryList[i].itemIndex = i;
            this._entryList[i].clipIndex = undefined;
        }
            
        for (var i = 0; i < this._dataProcessors.length; i++)
            this._dataProcessors[i].processList(this);
        
        this.listEnumeration.invalidate();

        if (this._selectedIndex >= this.listEnumeration.size())
            this._selectedIndex = this.listEnumeration.size() - 1;
            
        if (this.listEnumeration.lookupEnumIndex(this._selectedIndex) == null)
            this._selectedIndex = -1;
        
        this.calculateMaxScrollPosition();		
        this.UpdateList();
        
        // Restore selection
        if (this._curClipIndex != undefined && this._curClipIndex != -1 && this._listIndex > 0) {
            if (this._curClipIndex >= this._listIndex)
                this._curClipIndex = this._listIndex - 1;
            
            var entryClip = this.getClipByIndex(this._curClipIndex);
            this.doSetSelectedIndex(entryClip.itemIndex, skyui.components.list.BasicList.SELECT_MOUSE);
        }
        
        if (this.onInvalidate)
            this.onInvalidate();
    }

    public function moveSelectionUp(a_bScrollPage: Boolean)
    {
        if (!this.disableSelection && !a_bScrollPage) {
            if (this._selectedIndex == -1) {
                this.selectDefaultIndex(false);
            } else if (this.getSelectedListEnumIndex() >= this.scrollDelta) {
                this.doSetSelectedIndex(this.getListEnumRelativeIndex(-this.scrollDelta), skyui.components.list.BasicList.SELECT_KEYBOARD);
                this.isMouseDrivenNav = false;
                
                if (this.isPressOnMove)
                    this.onItemPress();
            } else if (this.getListEnumSize() > 0) {
                this.doSetSelectedIndex(this.getListEnumEntry(this.getListEnumSize() - 1).itemIndex, skyui.components.list.BasicList.SELECT_KEYBOARD);
                this.isMouseDrivenNav = false;
                
                if (this.isPressOnMove)
                    this.onItemPress();
            }
        } else if (a_bScrollPage) {
            var t = this.scrollPosition - this._listIndex;
            this.scrollPosition = t > 0 ? t : 0;
            this.doSetSelectedIndex(-1, skyui.components.list.BasicList.SELECT_MOUSE);
        } else {
            this.scrollPosition = this.scrollPosition - this.scrollDelta;
        }
    }

    public function moveSelectionDown(a_bScrollPage: Boolean)
    {
        if (!this.disableSelection && !a_bScrollPage) {
            if (this._selectedIndex == -1) {
                this.selectDefaultIndex(true);
            } else if (this.getSelectedListEnumIndex() < this.getListEnumSize() - this.scrollDelta) {
                this.doSetSelectedIndex(this.getListEnumRelativeIndex(this.scrollDelta), skyui.components.list.BasicList.SELECT_KEYBOARD);
                this.isMouseDrivenNav = false;
                
                if (this.isPressOnMove)
                    this.onItemPress();
            } else if (this.getListEnumSize() > 0) {
                this.doSetSelectedIndex(this.getListEnumEntry(0).itemIndex, skyui.components.list.BasicList.SELECT_KEYBOARD);
                this.isMouseDrivenNav = false;
                
                if (this.isPressOnMove)
                    this.onItemPress();
            }
        } else if (a_bScrollPage) {
            var t = this.scrollPosition + this._listIndex;
            this.scrollPosition = t < this._maxScrollPosition ? t : this._maxScrollPosition;
            this.doSetSelectedIndex(-1, skyui.components.list.BasicList.SELECT_MOUSE);
        } else {
            this.scrollPosition = this.scrollPosition + this.scrollDelta;
        }
    }

    public function selectDefaultIndex(a_bTop: Boolean)
    {
        if (this._listIndex <= 0)
            return;
            
        if (a_bTop) {
            var firstClip = this.getClipByIndex(0);
            if (firstClip.itemIndex != undefined)
                this.doSetSelectedIndex(firstClip.itemIndex, skyui.components.list.BasicList.SELECT_KEYBOARD);
        } else {
            var lastClip = this.getClipByIndex(this._listIndex - 1);
            if (lastClip.itemIndex != undefined)
                this.doSetSelectedIndex(lastClip.itemIndex, skyui.components.list.BasicList.SELECT_KEYBOARD);
        }
    }


  /* PRIVATE FUNCTIONS */

    // @GFx
    private function onMouseWheel(a_delta: Number)
    {
        if (this.disableInput)
            return;
        
        if (this.hitTest(_root._xmouse, _root._ymouse, true)) 
        {
            this.isMouseDrivenNav = true;
            if (a_delta < 0)      this.scrollPosition += this.scrollDelta;
            else if (a_delta > 0) this.scrollPosition -= this.scrollDelta;
        }
    }

    private function onScroll(event: Object)
    {
        this.updateScrollPosition(Math.floor(event.position + 0.5));
    }

    // @override BasicList
    private function doSetSelectedIndex(a_newIndex: Number, a_keyboardOrMouse: Number)
    {
        if (this.disableSelection || a_newIndex == this._selectedIndex)
            return;
            
        // Selection is not contained in current entry enumeration, ignore
        if (a_newIndex != -1 && this.getListEnumIndex(a_newIndex) == undefined)
            return;
            
        var oldEntry = this.selectedEntry;
        
        this._selectedIndex = a_newIndex;

        // Old entry was mapped to a clip? Then clear with setEntry now that selectedIndex has been updated
        if (oldEntry.clipIndex != undefined) {
            var clip = this.getClipByIndex(oldEntry.clipIndex);
            clip.setEntry(oldEntry, this.listState);
        }
            
            
        // Select valid entry
        if (this._selectedIndex != -1) {
            
            var enumIndex = this.getSelectedListEnumIndex();
            
            // New entry before visible portion, move scroll window up
            if (enumIndex < this._scrollPosition) {
                this.scrollPosition = enumIndex;
                
            // New entry below visible portion, move scroll window down
            } else if (enumIndex >= this._scrollPosition + this._listIndex) {
                this.scrollPosition = Math.min(enumIndex - this._listIndex + this.scrollDelta, this._maxScrollPosition);
                
            // No need to change the scroll window, just select new entry
            } else {
                var clip = this.getClipByIndex(this.selectedEntry.clipIndex);
                clip.setEntry(this.selectedEntry, this.listState);
            }
                
            this._curClipIndex = this.selectedEntry.clipIndex;
            
        // Unselect
        } else {
            this._curClipIndex = -1;
        }

        this.dispatchEvent({type:"selectionChange", index:this._selectedIndex, keyboardOrMouse:a_keyboardOrMouse});
    }

    private function calculateMaxScrollPosition()
    {
        var t = this.getListEnumSize() - this._maxListIndex;
        this._maxScrollPosition = (t > 0) ? t : 0;

        this.updateScrollbar();

        if (this._scrollPosition > this._maxScrollPosition)
            this.scrollPosition = this._maxScrollPosition;
    }

    private function updateScrollPosition(a_position: Number)
    {
        this._scrollPosition = a_position;
        this.UpdateList();
    }

    private function updateScrollbar()
    {
        if (this.scrollbar != undefined) {
            this.scrollbar._visible = this._maxScrollPosition > 0;
            this.scrollbar.setScrollProperties(this._maxListIndex,0,this._maxScrollPosition);
        }
    }

    // @override BasicList
    private function getClipByIndex(a_index: Number)
    {
        if (a_index < 0 || a_index >= this._maxListIndex)
            return undefined;

        return this._entryClipManager.getClip(a_index);
    }
}
