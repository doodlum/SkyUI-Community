class skyui.components.list.MarqueeSelectionController
{
  /* PRIVATE VARIABLES */

    private var _menu: MovieClip;
    private var _inventoryLists: MovieClip;
    private var _marqueeMC: MovieClip;

    private var _startX: Number = 0;
    private var _startY: Number = 0;
    private var _isSelecting: Boolean = false;
    private var _baselineSelection: Object;

    private var _dropQueue: Array;
    private var _isProcessingQueue: Boolean = false;


  /* PUBLIC VARIABLES */

    public var enabled: Boolean = false;


  /* INITIALIZATION */

    public function MarqueeSelectionController(a_menu: MovieClip, a_inventoryLists: MovieClip)
    {
        Mouse.addListener(this);
        this._menu = a_menu;
        this._inventoryLists = a_inventoryLists;
        this._dropQueue = [];
    }


  /* PUBLIC FUNCTIONS */

    public function onMouseDown()
    {
        if (!this.enabled || !this._menu.bFadedIn) return;

        var itemList = this._inventoryLists.itemList;
        var isCtrl = Key.isDown(Key.CONTROL);

        if (isCtrl) {
            this._isSelecting = true;
            this._startX = _root._xmouse;
            this._startY = _root._ymouse;

            this._baselineSelection = {};
            var entries = itemList.entryList;
            for (var i = 0; i < entries.length; i++) {
                if (entries[i].isMarqueeSelected) this._baselineSelection[i] = true;
            }

            if (this._marqueeMC == undefined) {
                this._marqueeMC = this._menu.createEmptyMovieClip("marquee_mc", this._menu.getNextHighestDepth());
            }
            this._marqueeMC._visible = true;
        } else if (!isCtrl) {
            this.clearSelection();
        }
    }

    public function onMouseMove()
    {
        if (this._isSelecting) {
            this.drawMarquee(_root._xmouse, _root._ymouse);
            this.checkIntersection();
        }
    }

    public function onMouseUp()
    {
        if (this._isSelecting) {
            this._isSelecting = false;
            this._marqueeMC.clear();
            this._marqueeMC._visible = false;
            this._baselineSelection = null;
        }
    }

    public function handleInput(details: Object)
    {
        if (!this.enabled) return;

        if (details.value == "keyDown") {
            var nav = details.navEquivalent;
            var kc = details.code;
            if (nav >= 1 && nav <= 6 && kc != 16 && kc != 17 && kc != 18) {
                if (this.isMultiSelectionActive()) this.clearSelection();
            }
        }
    }

    public function processItemClick(a_index: Number, a_entry: Object)
    {
        if (this.enabled && Key.isDown(Key.CONTROL) && a_entry != undefined) {
            a_entry.isMarqueeSelected = !a_entry.isMarqueeSelected;

            var list = this._inventoryLists.itemList;
            if (!a_entry.isMarqueeSelected && list.selectedIndex == a_index) {
                list.selectedIndex = -1;
            }

            list.requestUpdate();
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
            return true;
        }
        return false;
    }

    public function startBatchDrop()
    {
        var list = this._inventoryLists.itemList;
        this._dropQueue = [];

        for (var i = 0; i < list.entryList.length; i++) {
            if (list.entryList[i].isMarqueeSelected) 
                this._dropQueue.push(i);
        }

        if (this._dropQueue.length > 1) {
            this._dropQueue.sort(function(a, b) { return b - a; });
            list.disableInput = true;
            this._isProcessingQueue = true;
            this._menu.onEnterFrame = mx.utils.Delegate.create(this, this.processDropQueue);
            return true;
        }
        if (this._dropQueue.length == 1) {
            list.selectedIndex = this._dropQueue[0];
        }
        return false;
    }

    public function clearSelection()
    {
        var list = this._inventoryLists.itemList;
        var entries = list.entryList;
        var changed = false;

        for (var i = 0; i < entries.length; i++) {
            if (entries[i].isMarqueeSelected) {
                entries[i].isMarqueeSelected = false;
                changed = true;
            }
        }
        if (changed) list.requestUpdate();
    }

    public function isMultiSelectionActive()
    {
        var entries = this._inventoryLists.itemList.entryList;
        for (var i = 0; i < entries.length; i++) {
            if (entries[i].isMarqueeSelected) return true;
        }
        return false;
    }


  /* PRIVATE FUNCTIONS */

    private function drawMarquee(a_currX: Number, a_currY: Number)
    {
        var mc = this._marqueeMC;
        mc.clear();
        mc.lineStyle(1, 0xFFFFFF, 80);
        mc.beginFill(0xFFFFFF, 20);
        mc.moveTo(this._startX, this._startY);
        mc.lineTo(a_currX, this._startY);
        mc.lineTo(a_currX, a_currY);
        mc.lineTo(this._startX, a_currY);
        mc.lineTo(this._startX, this._startY);
        mc.endFill();
    }

    private function checkIntersection()
    {
        var list = this._inventoryLists.itemList;
        var marqueeBounds = this._marqueeMC.getBounds(_root);

        for (var i = 0; i < list._maxListIndex; i++) {
            var clip = list.getClipByIndex(i);
            if (clip != undefined && clip._visible && clip.itemIndex != undefined) {
                var itemBounds = clip.getBounds(_root);
                var isHit = !(itemBounds.xMin > marqueeBounds.xMax || itemBounds.xMax < marqueeBounds.xMin || 
                                itemBounds.yMin > marqueeBounds.yMax || itemBounds.yMax < marqueeBounds.yMin);

                var wasSelected = (this._baselineSelection != null && this._baselineSelection[clip.itemIndex] == true);
                if (clip.setMultiSelected != undefined) clip.setMultiSelected(isHit != wasSelected);
            }
        }
    }

    private function processDropQueue()
    {
        var list = this._inventoryLists.itemList;
        if (this._dropQueue.length > 0) {
            var targetIdx = this._dropQueue.shift();
            var entry = list.entryList[targetIdx];
            if (entry != undefined) {
                list.doSetSelectedIndex(targetIdx, 1);
                gfx.io.GameDelegate.call("ItemDrop", [entry.count]);
            }
        } else {
            delete this._menu.onEnterFrame;
            this._isProcessingQueue = false;
            list.disableInput = false;
            this.clearSelection();
            gfx.io.GameDelegate.call("RequestItemCardInfo", [], this._menu, "UpdateItemCardInfo");
        }
    }
}