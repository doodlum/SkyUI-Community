class skyui.components.list.TabularList extends skyui.components.list.ScrollingList
{
  /* PRIVATE VARIABLES */

    private var _previousColumnKey: Number = -1;
    private var _nextColumnKey: Number = -1;
    private var _sortOrderKey: Number = -1;

  /* STAGE ELEMENTS */

    public var header: SortedListHeader;


  /* PROPERTIES */ 

    private var _layout: ListLayout;

    public function get layout()
    {
        return this._layout;
    }

    public function set layout(a_layout: ListLayout)
    {
        if (this._layout)
            this._layout.removeEventListener("layoutChange", this, "onLayoutChange");
        this._layout = a_layout;
        this._layout.addEventListener("layoutChange", this, "onLayoutChange");
        
        if (this.header)
            this.header.layout = a_layout;
    }


  /* INITIALIZATION */

    public function TabularList()
    {
        super();
        
        skyui.util.ConfigManager.registerLoadCallback(this, "onConfigLoad");
    }


  /* PUBLIC FUNCTIONS */

    // @GFx
    public function handleInput(details: InputDetails, pathToFocus: Array)
    {		
        if (super.handleInput(details, pathToFocus))
            return true;

        if (!this.disableInput && this._platform != 0) {
            if (Shared.GlobalFunc.IsKeyPressed(details)) {
                if (details.skseKeycode == this._previousColumnKey) {
                    this._layout.selectColumn(this._layout.activeColumnIndex - 1);
                    return true;
                } else if (details.skseKeycode == this._nextColumnKey) {
                    this._layout.selectColumn(this._layout.activeColumnIndex + 1);
                    return true;
                } else if (details.skseKeycode == this._sortOrderKey) {
                    this._layout.selectColumn(this._layout.activeColumnIndex);
                    return true;
                }
            }
        }
        return false;
    }


  /* PRIVATE FUNCTIONS */

    private function onConfigLoad(event: Object)
    {
        var config = event.config;
        
        if (config.ScrollingList.selection.animation != undefined)
            this.enableAnimation = config.ScrollingList.selection.animation;
        
        if (this._platform != 0) {
            this._previousColumnKey = config["Input"].controls.gamepad.prevColumn;
            this._nextColumnKey = config["Input"].controls.gamepad.nextColumn;
            this._sortOrderKey = config["Input"].controls.gamepad.sortOrder;
        }
    }

    private function onLayoutChange(event: Object)
    {
        this.entryHeight = this._layout.entryHeight;

        this.header._x = this.leftBorder;
        
        this._maxListIndex = Math.floor((this._listHeight / this.entryHeight) + 0.05);
        
        if (this._layout.sortAttributes && this._layout.sortOptions)
            this.dispatchEvent({type:"sortChange", attributes: this._layout.sortAttributes, options:  this._layout.sortOptions});
        
        this.requestUpdate();
    }
}