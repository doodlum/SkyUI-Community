class skyui.components.list.BasicListEntry extends MovieClip
{
  /* STAGE ELEMENTS */

    public var background: MovieClip;


  /* PROPERTIES */

    public var itemIndex: Number;
    public var isEnabled: Boolean = true;


  /* INITIALIZATION */

    function BasicListEntry()
    {
        super();
    }


  /* PUBLIC FUNCTIONS */

    // ScrollingList wraps its entries in a masked sub-clip (entriesContainer), so this._parent
    // is the container, not the list itself. Walk up the display tree until we find a clip
    // that actually exposes onItemPress -- that's the owning list. For lists that don't nest
    // (e.g. ButtonList) the loop exits immediately on the first iteration and behavior is
    // unchanged.
    private function findOwningList()
    {
        var p = this._parent;
        while (p != undefined && p.onItemPress == undefined)
            p = p._parent;
        return p;
    }

    // @override MovieClip
    public function onRollOver()
    {
        var list = this.findOwningList();

        if (this.itemIndex != undefined && (this.isEnabled || list.canSelectDisabled))
            list.onItemRollOver(this.itemIndex);
    }

    // @override MovieClip
    public function onRollOut()
    {
        var list = this.findOwningList();

        if (this.itemIndex != undefined && (this.isEnabled || list.canSelectDisabled))
            list.onItemRollOut(this.itemIndex);
    }

    // @override MovieClip
    public function onPress(a_mouseIndex: Number, a_keyboardOrMouse: Number)
    {
        var list = this.findOwningList();

        if (this.itemIndex != undefined && (this.isEnabled || list.canSelectDisabled))
            list.onItemPress(this.itemIndex, a_keyboardOrMouse);
    }

    // @override MovieClip
    public function onPressAux(a_mouseIndex: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number)
    {
        var list = this.findOwningList();

        if (this.itemIndex != undefined && (this.isEnabled || list.canSelectDisabled))
            list.onItemPressAux(this.itemIndex, a_keyboardOrMouse, a_buttonIndex);
    }


    // # NOTE: Empty functions are intentionally commented out—they cause ColumnSelectDialog to break.
    // JPEXS currently has issues with using empty functions.
    // # See https://www.free-decompiler.com/flash/issues/2705

    // // This is called after the object is added to the stage since the constructor does not accept any parameters.
    // public function initialize(a_index: Number, a_list: BasicList)
    // {
    //     // Do nothing.
    // }

    // // @abstract
    // public function setEntry(a_entryObject: Object, a_state: ListState) {}
}
