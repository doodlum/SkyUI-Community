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

    // @override MovieClip
    public function onRollOver()
    {
        var list = this._parent;
        
        if (this.itemIndex != undefined && (this.isEnabled || list.canSelectDisabled))
            list.onItemRollOver(this.itemIndex);
    }
        
    // @override MovieClip
    public function onRollOut()
    {
        var list = this._parent;
        
        if (this.itemIndex != undefined && (this.isEnabled || list.canSelectDisabled))
            list.onItemRollOut(this.itemIndex);
    }
        
    // @override MovieClip
    public function onPress(a_mouseIndex: Number, a_keyboardOrMouse: Number)
    {
        var list = this._parent;
            
        if (this.itemIndex != undefined && (this.isEnabled || list.canSelectDisabled))
            list.onItemPress(this.itemIndex, a_keyboardOrMouse);
    }
        
    // @override MovieClip
    public function onPressAux(a_mouseIndex: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number)
    {
        var list = this._parent;
            
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
