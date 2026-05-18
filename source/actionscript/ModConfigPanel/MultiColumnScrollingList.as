class MultiColumnScrollingList extends skyui.components.list.ScrollingList
{
  /* PRIVATE VARIABLES */ 
    
    private var _separators: Array;
    
    
  /* PROPERTIES */
    
    public var columnSpacing: Number = 0;
    
    public var separatorRenderer: String;
    
    private var _columnCount: Number = 1;
    
    public function get columnCount()
    {
        return this._columnCount;
    }
    
    public function set columnCount(a_value: Number)
    {
        this._columnCount = a_value;
        
        this.refreshSeparators();
    }
    

  /* INITIALIZATION */

    public function MultiColumnScrollingList()
    {
        super();
        
        this.scrollDelta = this.columnCount;
        this._maxListIndex *= this.columnCount;
        
        if (this._separators == null)
            this._separators = [];
    }

    public function onLoad()
    {
        super.onLoad();

        if(this.scrollbar != undefined) {
            this.scrollbar.scrollDelta = this.scrollDelta;
        }
    }
    
    
  /* PUBLIC FUNCTIONS */
    
    // @override ScrollingList
    public function UpdateList()
    {
        // Prepare clips
        this.setClipCount(this._maxListIndex);

        var xStart = this.background._x + this.leftBorder;
        var yStart = this.background._y + this.topBorder;
        var h = 0;
        var w = 0;
        var lastColumnIndex = this.columnCount - 1;
        var columnWidth = (this.background._width - this.leftBorder - this.rightBorder - (this.columnCount-1) * this.columnSpacing) / this.columnCount;

        // Clear clipIndex for everything before the selected list part
        for (var i = 0; i < this.getListEnumSize() && i < this._scrollPosition ; i++)
            this.getListEnumEntry(i).clipIndex = undefined;

        this._listIndex = 0;
        
        // Display the selected part of the list
        for (var i = this._scrollPosition; i < this.getListEnumSize() && this._listIndex < this._maxListIndex; i++) {
            var entryClip = this.getClipByIndex(this._listIndex);
            var entryItem = this.getListEnumEntry(i);

            entryClip.itemIndex = entryItem.itemIndex;
            entryItem.clipIndex = this._listIndex;
            
            entryClip.width = columnWidth;
            entryClip.setEntry(entryItem, this.listState);

            entryClip._x = xStart + w;
            entryClip._y = yStart + h;
            entryClip._visible = true;

            if (i % this.columnCount == lastColumnIndex) {
                w = 0;
                h = h + this.entryHeight;
            } else {
                w = w + columnWidth + this.columnSpacing;
            }

            ++this._listIndex;
        }
        
        // Clear clipIndex for everything after the selected list part
        for (var i = this._scrollPosition + this._listIndex; i < this.getListEnumSize(); i++)
            this.getListEnumEntry(i).clipIndex = undefined;
        
        // Select entry under the cursor for mouse-driven navigation
        if (this.isMouseDrivenNav && this.hitTest(_root._xmouse, _root._ymouse, true)) {
            for (var i = 0; i < this._listIndex; i++) {
                var clip = this.getClipByIndex(i);
                if (clip._visible && clip.itemIndex != undefined && clip.hitTest(_root._xmouse, _root._ymouse, true)) {
                    this.doSetSelectedIndex(clip.itemIndex, skyui.components.list.BasicList.SELECT_MOUSE);
                    break;
                }
            }
        }
                    
        var bShowSeparators = this._listIndex > 0;
        for (var i = 0; i < this._separators.length; i++)
            this._separators[i]._visible = bShowSeparators;
    }
    
    // @GFx
    public function handleInput(details: InputDetails, pathToFocus: Array)
    {
        if (this.disableInput)
            return false;
            
        if (super.handleInput(details, pathToFocus))
            return true;

        if (Shared.GlobalFunc.IsKeyPressed(details)) {
            if (details.navEquivalent == gfx.ui.NavigationCode.LEFT) {
                this.moveSelectionLeft();
                return true;
            } else if (details.navEquivalent == gfx.ui.NavigationCode.RIGHT) {
                this.moveSelectionRight();
                return true;
            }
        }
        return false;
    }
    
    public function moveSelectionLeft()
    {
        if (this.disableSelection)
            return;

        if (this._selectedIndex == -1) {
            this.selectDefaultIndex(false);
        } else if ((this.getSelectedListEnumIndex() % this.columnCount) > 0) {
            this.doSetSelectedIndex(this.getListEnumRelativeIndex(-1), skyui.components.list.BasicList.SELECT_KEYBOARD);
            this.isMouseDrivenNav = false;
        }
    }

    public function moveSelectionRight()
    {
        if (this.disableSelection)
            return;

        if (this._selectedIndex == -1) {
            this.selectDefaultIndex(false);
        } else if ((this.getSelectedListEnumIndex() % this.columnCount) < (this.columnCount - 1)) {
            this.doSetSelectedIndex(this.getListEnumRelativeIndex(1), skyui.components.list.BasicList.SELECT_KEYBOARD);
            this.isMouseDrivenNav = false;
        }
    }
    
    
  /* PRIVATE FUNCTIONS */
    
    private function refreshSeparators()
    {
        if (this._separators == null)
            this._separators = [];
        
        while (this._separators.length > 0) {
            var e = this._separators.pop();
            e.removeMovieClip();
        }
        
        // Create separators
        if (!this.separatorRenderer)
            return;
            
        var columnWidth = (this.background._width - this.leftBorder - this.rightBorder - (this.columnCount - 1) * this.columnSpacing) / this.columnCount;
        var t = this.background._x + this.leftBorder;
        var d = this.columnSpacing / 2;
        
        for (var i = 0; i < this.columnCount - 1; i++) {
            var e = this.attachMovie(this.separatorRenderer, this.separatorRenderer + i, this.getNextHighestDepth());
            t += columnWidth + d;
            e._x = t;
            e._y = this.background._y;
            e._height = this.background._height;
            e._alpha = 50;
            this._separators.push(e);
            t += d;
        }
    }
}
