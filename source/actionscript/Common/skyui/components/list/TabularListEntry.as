// @abstract
class skyui.components.list.TabularListEntry extends skyui.components.list.BasicListEntry
{
  /* PRIVATE VARIABLES */

    private var _layoutUpdateCount: Number = -1;


  /* STAGE ELEMENTS */

    public var selectIndicator: MovieClip;


  /* PUBLIC FUNCTIONS */

    // @override BasicListEntry
    public function setEntry(a_entryObject: Object, a_state: ListState)
    {
        var layout: ListLayout = skyui.components.list.TabularList(a_state.list).layout;
            
        // Show select area if this is the current entry
        this.selectIndicator._visible = (a_entryObject == a_state.list.selectedEntry);
        
        var curLayoutUpdateCount = layout.layoutUpdateCount;
        
        // Has the view update sequence number changed? Then Update the columns positions etc.
        if (this._layoutUpdateCount != curLayoutUpdateCount) {
            this._layoutUpdateCount = curLayoutUpdateCount;
            
            this.setEntryLayout(a_entryObject, a_state);
            this.setSpecificEntryLayout(a_entryObject, a_state);
        }
        
        // Format the actual entry contents. Do this with every upate.
        for (var i = 0; i < layout.columnCount; i++) {
            var columnLayoutData: ColumnLayoutData = layout.columnLayoutData[i];
            var e = this[columnLayoutData.stageName];

            // Substitute @variables by entryObject properties
            var entryValue: String = columnLayoutData.entryValue;
            if (entryValue != undefined) {
                if (entryValue.charAt(0) == "@") {
                    var subVal = a_entryObject[entryValue.slice(1)] != undefined
                        ? a_entryObject[entryValue.slice(1)]
                        : "-";
                    if (columnLayoutData.stageName == "textField1")
                        subVal = this.__rf_cleanDisplayText(subVal);
                    e.SetText(subVal);					
                } else {
                    if (columnLayoutData.stageName == "textField1")
                        entryValue = this.__rf_cleanDisplayText(entryValue);
                    e.SetText(entryValue);
                }
            }
            
            // Process based on column type 
            switch (columnLayoutData.type) {
                case skyui.components.list.ListLayout.COL_TYPE_EQUIP_ICON :
                    this.formatEquipIcon(e, a_entryObject, a_state);
                    break;

                case skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON :
                    this.formatItemIcon(e, a_entryObject, a_state);
                    break;

                case skyui.components.list.ListLayout.COL_TYPE_NAME :
                    this.formatName(e, a_entryObject, a_state);
                    break;

                case skyui.components.list.ListLayout.COL_TYPE_TEXT :
                default :
                    this.formatText(e, a_entryObject, a_state);
            }
            
            // Process color overrides after regular formatting
            if (columnLayoutData.colorAttribute != undefined) {
                var color = a_entryObject[columnLayoutData.colorAttribute];
                if (color != undefined)
                    e.textColor = color;
            }
        }
    }

    // Do any clip-specific tasks when the view was changed for this entry.
    // @abstract
    public function setSpecificEntryLayout(a_entryObject: Object, a_state: ListState) {}

    // @abstract
    public function formatName(a_entryField: Object, a_entryObject: Object, a_state: ListState) {}

    // @abstract
    public function formatEquipIcon(a_entryField: Object, a_entryObject: Object, a_state: ListState) {}

    // @abstract
    public function formatItemIcon(a_entryField: Object, a_entryObject: Object, a_state: ListState) {}

    // @abstract
    public function formatText(a_entryField: Object, a_entryObject: Object, a_state: ListState) {}


  /* PRIVATE FUNCTIONS */

    private function setEntryLayout(a_entryObject: Object, a_state: ListState)
    {
        var layout: ListLayout = skyui.components.list.TabularList(a_state.list).layout;
            
        this.background._width = this.selectIndicator._width = layout.entryWidth;
        this.background._height = this.selectIndicator._height = layout.entryHeight;

        // Set up all visible elements in this entry
        for (var i = 0; i < layout.columnCount; i++) {
            var columnLayoutData: ColumnLayoutData = layout.columnLayoutData[i];
            var e = this[columnLayoutData.stageName];
            
            e._visible = true;
        
            e._x = columnLayoutData.x;
            e._y = columnLayoutData.y;
        
            if (columnLayoutData.width > 0)
                e._width = columnLayoutData.width;
        
            if (columnLayoutData.height > 0)
                e._height = columnLayoutData.height;
            
            if (e instanceof TextField)
                e.setTextFormat(columnLayoutData.textFormat);
        }
        
        // Hide any unused elements
        var hiddenStageNames = layout.hiddenStageNames;
        
        for (var i = 0; i < hiddenStageNames.length; i++)
            this[hiddenStageNames[i]]._visible = false;
    }

    // HACK: specific workaround for tab-delimited translation text (e.g. BOOBIES Potions).
    // TODO: replace with a cleaner generic solution if SkyUI handles this case centrally later.
    private function __rf_cleanDisplayText(a_text)
    {
        if (a_text == undefined) return a_text;

        var tabIndex = a_text.indexOf("\t");

        if (tabIndex == -1) return a_text;
        
        var cleanIndex = tabIndex;
        while (cleanIndex > 0 && (a_text.charCodeAt(cleanIndex - 1) == 32 || a_text.charCodeAt(cleanIndex - 1) == 160))
        {
            cleanIndex -= 1;
        }
        
        return (cleanIndex == tabIndex) ? a_text : a_text.substring(0, cleanIndex);
    }
}
