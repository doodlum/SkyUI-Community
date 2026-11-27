/*
 * Marquee (rubber band) multi-selection for the item list of an item menu (InventoryMenu, ContainerMenu).
 *
 *   Ctrl + drag   inside the item list draws a frame; entries it touches toggle their selection
 *                 (XOR against the selection that existed when the drag started).
 *   Ctrl + click  on an entry toggles that entry.
 *   Click         (no Ctrl) anywhere except the scrollbar clears the selection.
 *   Navigation    (up/down/left/right/page/home/end) clears the selection.
 *   Filter change (category, tab, search) clears the selection.
 *
 * The selection is stored on the entry objects (entry.isMarqueeSelected). Only entries that are part of the
 * current filtered view count as selected; listState.marqueeActive tells the entry renderer whether a
 * multi-selection exists, so it can dim the plain cursor highlight.
 *
 * Batch actions (drop, transfer) process one entry per frame. Each step re-resolves the target by entry
 * identity (falling back to a formId/name key if the engine rebuilt the entry objects), selects it in the
 * list and calls the action; the next step waits until the list shows the result (the entry is gone or its
 * count dropped) or a timeout expires (the engine refused, e.g. a quest item).
 */
class skyui.components.list.MarqueeSelectionController
{
  /* CONSTANTS */

    // Pixels the mouse must move with Ctrl held before a press becomes a marquee drag instead of a Ctrl+click.
    private static var DRAG_THRESHOLD = 4;

    // Frames to wait for the engine to apply one batch step before moving on.
    private static var MAX_WAIT_FRAMES = 20;


  /* PRIVATE VARIABLES */

    private var _menu;
    private var _inventoryLists;
    private var _marqueeMC;
    private var _driverMC;

    private var _startX = 0;
    private var _startY = 0;
    private var _bCtrlPress = false;
    private var _bDragging = false;

    private var _queue;
    private var _actionFunc;
    private var _filterFunc;
    private var _pending;
    private var _waitFrames = 0;
    private var _bProcessing = false;
    private var _savedDisableInput = false;
    private var _savedMouseDrivenNav = false;


  /* PUBLIC VARIABLES */

    public var enabled = false;


  /* INITIALIZATION */

    public function MarqueeSelectionController(a_menu, a_inventoryLists)
    {
        this._menu = a_menu;
        this._inventoryLists = a_inventoryLists;
        this._queue = [];
        Mouse.addListener(this);
    }

    // Call from the menu's InitExtensions(), once InventoryLists has set up its filters.
    public function init()
    {
        var lists = this._inventoryLists;
        if (lists._typeFilter != undefined)
            lists._typeFilter.addEventListener("filterChange", this, "onFilterChange");
        if (lists._nameFilter != undefined)
            lists._nameFilter.addEventListener("filterChange", this, "onFilterChange");
    }


  /* PROPERTIES */

    public function get isProcessing()
    {
        return this._bProcessing;
    }


  /* PUBLIC FUNCTIONS */

    // @GFx Mouse listener
    public function onMouseDown()
    {
        if (!this.enabled || this._bProcessing || !this._menu.bFadedIn)
            return;

        var list = this._inventoryLists.itemList;

        if (Key.isDown(Key.CONTROL)) {
            // Only start inside the item list (not over the scrollbar, the 3D item, the item card, ...)
            if (!this._menu.shouldProcessItemsListInput(false) || !list.hitTest(_root._xmouse, _root._ymouse, true) || this.isOverScrollbar())
                return;

            this._bCtrlPress = true;
            this._bDragging = false;
            this._startX = this._menu._xmouse;
            this._startY = this._menu._ymouse;
        } else if (this.hasSelection() && !this.isOverScrollbar()) {
            this.clearSelection();
        }
    }

    // @GFx Mouse listener
    public function onMouseMove()
    {
        if (!this._bCtrlPress)
            return;

        var x = this._menu._xmouse;
        var y = this._menu._ymouse;

        if (!this._bDragging) {
            var limit = skyui.components.list.MarqueeSelectionController.DRAG_THRESHOLD;
            if (Math.abs(x - this._startX) < limit && Math.abs(y - this._startY) < limit)
                return;
            this.beginDrag();
        }

        this.drawMarquee(x, y);
        this.updateMarqueeSelection();
    }

    // @GFx Mouse listener
    public function onMouseUp()
    {
        if (!this._bCtrlPress)
            return;

        this._bCtrlPress = false;

        if (this._bDragging) {
            this.endDrag();
        } else {
            // Ctrl+click without drag: toggle the entry under the cursor
            this.toggleEntry(this.getEntryUnderMouse());
        }
    }

    // Called from the menu's handleInput before it forwards the input.
    public function handleInput(details)
    {
        if (!this.enabled || (details.value != "keyDown" && details.value != "keyHold"))
            return;

        var nav = details.navEquivalent;
        if (nav == gfx.ui.NavigationCode.UP || nav == gfx.ui.NavigationCode.DOWN ||
            nav == gfx.ui.NavigationCode.LEFT || nav == gfx.ui.NavigationCode.RIGHT ||
            nav == gfx.ui.NavigationCode.PAGE_UP || nav == gfx.ui.NavigationCode.PAGE_DOWN ||
            nav == gfx.ui.NavigationCode.HOME || nav == gfx.ui.NavigationCode.END) {
            if (this.hasSelection())
                this.clearSelection();
        }
    }

    // Called from the menu's onItemSelect (itemPress). Returns true if the press was consumed.
    public function processItemClick(a_event)
    {
        if (!this.enabled)
            return false;

        if (this._bProcessing)
            return true;

        if (!Key.isDown(Key.CONTROL))
            return false;

        // Mouse: the toggle happens in onMouseUp (a press may turn into a drag). Keyboard: toggle now.
        if (a_event.keyboardOrMouse != 0)
            this.toggleEntry(a_event.entry);

        return true;
    }

    // True when Ctrl is held over the item list: the press belongs to the marquee, not to equip/transfer.
    public function shouldSuppressAction()
    {
        if (!this.enabled)
            return false;
        if (this._bProcessing)
            return true;
        return Key.isDown(Key.CONTROL) && this._inventoryLists.itemList.hitTest(_root._xmouse, _root._ymouse, true);
    }

    // Entries that are marquee-selected and visible in the current filtered view, in view order.
    public function getSelectedEntries()
    {
        var result = [];
        if (!this.enabled || !this.hasSelection())
            return result;

        var enumeration = this._inventoryLists.itemList.listEnumeration;
        var n = enumeration.size();
        for (var i = 0; i < n; i++) {
            var e = enumeration.at(i);
            if (e.isMarqueeSelected == true)
                result.push(e);
        }
        return result;
    }

    public function isMultiSelectionActive()
    {
        return this.getSelectedEntries().length > 0;
    }

    /*
     * Starts a batch over the selected entries.
     *   a_actionFunc(entry)  performs the action on the (already list-selected) entry.
     *   a_filterFunc(entry)  returns true if the entry may be processed (checked again right before each step).
     * Returns the number of entries queued (0 = nothing done, the selection is cleared).
     */
    public function startBatch(a_actionFunc, a_filterFunc)
    {
        if (!this.enabled || this._bProcessing)
            return 0;

        var selected = this.getSelectedEntries();
        this._queue = [];

        for (var i = 0; i < selected.length; i++) {
            var e = selected[i];
            if (a_filterFunc == undefined || a_filterFunc(e))
                this._queue.push({entry: e, key: skyui.components.list.MarqueeSelectionController.entryKey(e)});
        }

        if (this._queue.length == 0) {
            this.clearSelection();
            return 0;
        }

        var list = this._inventoryLists.itemList;

        this._actionFunc = a_actionFunc;
        this._filterFunc = a_filterFunc;
        this._pending = undefined;
        this._waitFrames = 0;
        this._bProcessing = true;
        this._savedDisableInput = list.disableInput;
        list.disableInput = true;
        // Otherwise UpdateList (after a scroll or an engine refresh) re-selects the entry under the mouse.
        this._savedMouseDrivenNav = list.isMouseDrivenNav;
        list.isMouseDrivenNav = false;

        if (this._driverMC == undefined)
            this._driverMC = this._menu.createEmptyMovieClip("marqueeDriver_mc", this._menu.getNextHighestDepth());
        this._driverMC.onEnterFrame = mx.utils.Delegate.create(this, this.processQueue);

        return this._queue.length;
    }

    // Selects a single selected entry in the list (so the regular single-item code path acts on it).
    public function selectEntry(a_entry)
    {
        var list = this._inventoryLists.itemList;
        if (a_entry == undefined || a_entry.filteredIndex == undefined)
            return false;
        list.selectedIndex = a_entry.itemIndex;
        return list.selectedEntry == a_entry;
    }

    public function clearSelection()
    {
        var list = this._inventoryLists.itemList;
        var entries = list.entryList;
        var changed = list.listState.marqueeActive == true;

        for (var i = 0; i < entries.length; i++) {
            if (entries[i].isMarqueeSelected) {
                delete entries[i].isMarqueeSelected;
                changed = true;
            }
        }

        list.listState.marqueeActive = false;
        if (changed)
            list.requestUpdate();
    }

    // Aborts a running drag or batch and clears the selection (menu closing).
    public function cancel()
    {
        if (this._bDragging)
            this.endDrag();
        this._bCtrlPress = false;
        if (this._bProcessing)
            this.finishBatch();
        else
            this.clearSelection();
    }


  /* PRIVATE FUNCTIONS */

    private function onFilterChange(event)
    {
        if (!this._bProcessing && this.hasSelection())
            this.clearSelection();
    }

    // Cheap check (no list scan): set whenever an entry gets selected, reset by clearSelection.
    private function hasSelection()
    {
        return this._inventoryLists.itemList.listState.marqueeActive == true;
    }

    private function isOverScrollbar()
    {
        var sb = this._inventoryLists.itemList.scrollbar;
        return sb != undefined && sb._visible && sb.hitTest(_root._xmouse, _root._ymouse, true);
    }

    private function getEntryUnderMouse()
    {
        var list = this._inventoryLists.itemList;
        for (var i = 0; i < list._maxListIndex; i++) {
            var clip = list.getClipByIndex(i);
            if (clip != undefined && clip._visible && clip.itemIndex != undefined && clip.hitTest(_root._xmouse, _root._ymouse, true))
                return list.entryList[clip.itemIndex];
        }
        return undefined;
    }

    private function toggleEntry(a_entry)
    {
        if (a_entry == undefined || a_entry.filteredIndex == undefined)
            return;

        if (a_entry.isMarqueeSelected == true)
            delete a_entry.isMarqueeSelected;
        else
            a_entry.isMarqueeSelected = true;

        this.refreshActiveFlag();
        this._inventoryLists.itemList.requestUpdate();
        gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
    }

    private function refreshActiveFlag()
    {
        var list = this._inventoryLists.itemList;
        var enumeration = list.listEnumeration;
        var n = enumeration.size();
        var active = false;
        for (var i = 0; i < n; i++) {
            if (enumeration.at(i).isMarqueeSelected == true) {
                active = true;
                break;
            }
        }
        list.listState.marqueeActive = active;
    }

    private function beginDrag()
    {
        this._bDragging = true;

        // Remember the selection at drag start; the marquee XORs against it.
        var entries = this._inventoryLists.itemList.entryList;
        for (var i = 0; i < entries.length; i++)
            entries[i].marqueeBaseline = (entries[i].isMarqueeSelected == true);

        if (this._marqueeMC == undefined)
            this._marqueeMC = this._menu.createEmptyMovieClip("marquee_mc", this._menu.getNextHighestDepth());
        this._marqueeMC._visible = true;
    }

    private function endDrag()
    {
        this._bDragging = false;
        this._marqueeMC.clear();
        this._marqueeMC._visible = false;

        var entries = this._inventoryLists.itemList.entryList;
        for (var i = 0; i < entries.length; i++)
            delete entries[i].marqueeBaseline;
    }

    private function drawMarquee(a_x, a_y)
    {
        var mc = this._marqueeMC;
        mc.clear();
        mc.lineStyle(1, 0xFFFFFF, 80);
        mc.beginFill(0xFFFFFF, 20);
        mc.moveTo(this._startX, this._startY);
        mc.lineTo(a_x, this._startY);
        mc.lineTo(a_x, a_y);
        mc.lineTo(this._startX, a_y);
        mc.lineTo(this._startX, this._startY);
        mc.endFill();
    }

    private function updateMarqueeSelection()
    {
        var list = this._inventoryLists.itemList;
        var bounds = this._marqueeMC.getBounds(_root);
        var changed = false;

        for (var i = 0; i < list._maxListIndex; i++) {
            var clip = list.getClipByIndex(i);
            if (clip == undefined || !clip._visible || clip.itemIndex == undefined)
                continue;

            var entry = list.entryList[clip.itemIndex];
            if (entry == undefined)
                continue;

            var b = clip.getBounds(_root);
            var isHit = !(b.xMin > bounds.xMax || b.xMax < bounds.xMin || b.yMin > bounds.yMax || b.yMax < bounds.yMin);
            var newState = (isHit != (entry.marqueeBaseline == true));

            if (newState != (entry.isMarqueeSelected == true)) {
                if (newState)
                    entry.isMarqueeSelected = true;
                else
                    delete entry.isMarqueeSelected;
                changed = true;
            }
        }

        if (changed) {
            this.refreshActiveFlag();
            list.requestUpdate();
        }
    }

    private function processQueue()
    {
        var list = this._inventoryLists.itemList;

        // Menu closing/fading: stop.
        if (!this._menu.bFadedIn) {
            this.finishBatch();
            return;
        }

        // Wait until the engine applied the previous step (or gave up on it).
        if (this._pending != undefined) {
            var cur = this.resolveEntry(this._pending);
            var applied = (cur == undefined || cur.count < this._pending.count);
            if (!applied && ++this._waitFrames < skyui.components.list.MarqueeSelectionController.MAX_WAIT_FRAMES)
                return;
            this._pending = undefined;
            this._waitFrames = 0;
        }

        while (this._queue.length > 0) {
            var item = this._queue.shift();
            var entry = this.resolveEntry(item);

            // Gone, hidden by the current filter, or no longer eligible: skip.
            if (entry == undefined || entry.filteredIndex == undefined)
                continue;
            if (this._filterFunc != undefined && !this._filterFunc(entry))
                continue;

            // The engine acts on the list's selected index; select the target and make sure it took.
            list.selectedIndex = entry.itemIndex;
            if (list.selectedEntry != entry)
                continue;

            item.entry = entry;
            item.count = entry.count;
            this._pending = item;
            this._waitFrames = 0;
            this._actionFunc(entry);
            return;
        }

        this.finishBatch();
    }

    // Finds the queued entry in the current list: same object if still present, else by key.
    // Note: the count is not part of the key, so a partially applied step still resolves.
    private function resolveEntry(a_item)
    {
        var entries = this._inventoryLists.itemList.entryList;
        var e = a_item.entry;
        // Identity alone is not enough: if the engine reused the object for another item, the key differs.
        if (e != undefined && entries[e.itemIndex] == e && skyui.components.list.MarqueeSelectionController.entryKey(e) == a_item.key)
            return e;

        for (var i = 0; i < entries.length; i++) {
            if (skyui.components.list.MarqueeSelectionController.entryKey(entries[i]) == a_item.key)
                return entries[i];
        }
        return undefined;
    }

    private function finishBatch()
    {
        var list = this._inventoryLists.itemList;

        if (this._driverMC != undefined)
            delete this._driverMC.onEnterFrame;

        this._bProcessing = false;
        this._queue = [];
        this._pending = undefined;
        this._actionFunc = undefined;
        this._filterFunc = undefined;

        // Don't re-enable input if the menu faded out meanwhile (ToggleMenuFade disabled it).
        if (this._menu.bFadedIn)
            list.disableInput = this._savedDisableInput;
        list.isMouseDrivenNav = this._savedMouseDrivenNav;

        this.clearSelection();

        if (list.selectedIndex != -1)
            gfx.io.GameDelegate.call("RequestItemCardInfo", [], this._menu, "UpdateItemCardInfo");
    }

    // Equipped or favorited items are never moved by a batch (only by acting on them alone).
    public static function isEquippedOrFavorite(a_entry)
    {
        return a_entry.equipState > 0 || a_entry.favorite == true;
    }

    public static function isGold(a_entry)
    {
        return a_entry.formId == skyui.defines.Form.FORMID_GOLD001 ||
            (a_entry.formType == skyui.defines.Form.TYPE_MISC && a_entry.subType == skyui.defines.Item.MISC_GOLD);
    }

    private static function entryKey(a_entry)
    {
        return a_entry.formId + "|" + a_entry.text + "|" + (a_entry.isStolen == true) + "|" + a_entry.equipState + "|" + (a_entry.favorite == true);
    }
}
