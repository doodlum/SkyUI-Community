class skyui.components.list.SortedListHeader extends MovieClip
{
  /* PRIVATE VARIABLES */

    private var _columns: Array;


  /* STAGE ELEMENTS */

    public var sortIcon: MovieClip;
    public var iconColumnIndicator: MovieClip;


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
    }


  /* INITIALIZATION */

    public function SortedListHeader()
    {
        super();
        
        this._columns = new Array();
    }


  /* PUBLIC FUNCTIONS */

    public function columnPress(a_columnIndex: Number)
    {
        this._layout.selectColumn(a_columnIndex);
    }


  /* PRIVATE FUNCTIONS */

    // Hides all columns (but doesn't delete them since they can be re-used later).
    private function clearColumns()
    {
        for (var i = 0; i < this._columns.length; i++)
            this._columns[i]._visible = false;
    }

    private function addColumn(a_index: Number)
    {
        if (a_index < 0)
            return undefined;
        
        var columnButton = this["Column" + a_index];

        if (columnButton != undefined) {
            this._columns[a_index] = columnButton;
            this._columns[a_index]._visible = true;
            return columnButton;
        }
        
        // Create on-demand
        columnButton = this.attachMovie("HeaderColumn", "Column" + a_index, this.getNextHighestDepth());



        columnButton.columnIndex = a_index;

        columnButton.onPress = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
        {
            if (!this.columnIndex != undefined)
                this._parent.columnPress(this.columnIndex);
        };

        columnButton.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
        {
            if (!this.columnIndex != undefined)
                this._parent.columnPress(this.columnIndex);
        };

        this._columns[a_index] = columnButton;
        return columnButton;
    }

    private function onLayoutChange(event)
    {
        this.clearColumns();
        
        var activeIndex = this._layout.activeColumnIndex;
            
        for (var i = 0; i < this._layout.columnCount; i++) {
            var columnLayoutData = this._layout.columnLayoutData[i];
            var btn = this.addColumn(i);

            btn.label._x = 0;

            btn._x = columnLayoutData.labelX;
            
            btn.label._width = columnLayoutData.labelWidth;
            btn.label.setTextFormat(columnLayoutData.labelTextFormat);
            
            btn.label.SetText(columnLayoutData.labelValue);
            
            if (activeIndex == i)
                this.sortIcon.gotoAndStop(columnLayoutData.labelArrowDown ? "desc" : "asc");
        }
        
        this.positionButtons();
    }

    // Places the buttonAreas around textfields and the sort indicator.
    private function positionButtons()
    {
        var activeIndex = this._layout.activeColumnIndex;
        for (var i = 0; i < this._columns.length; i++) {
            var e = this._columns[i];
            e.label._y = -e.label._height;
            
            e.buttonArea._x = e.label.getLineMetrics(0).x - 4;
            e.buttonArea._width = e.label.getLineMetrics(0).width + 8;
            e.buttonArea._y = e.label._y - 2;
            e.buttonArea._height = e.label._height + 2;
            
            if (this._layout.columnLayoutData[i].type == skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON) {
                this.iconColumnIndicator._x = e._x + e.buttonArea._x + e.buttonArea._width;
                this.iconColumnIndicator._y = -e._height + ((e._height - this.iconColumnIndicator._height) / 2);
            }
            
            if (activeIndex == i) {
                this.sortIcon._x = e._x + e.buttonArea._x + e.buttonArea._width;
                this.sortIcon._y = -e._height + ((e._height - this.sortIcon._height) / 2) - 1;
                
                this.iconColumnIndicator._visible = this._layout.columnLayoutData[i].type != skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON;
            }
        }
    }
}