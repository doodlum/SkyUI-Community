/*
 *  Encapsulates the list layout configuration.
 */
class skyui.components.list.ListLayout
{
  /* CONSTANTS */

    private static var MAX_TEXTFIELD_INDEX = 10;

    private static var LEFT = 0;
    private static var RIGHT = 1;
    private static var TOP = 2;
    private static var BOTTOM = 3;

    public static var COL_TYPE_ITEM_ICON = 0;
    public static var COL_TYPE_EQUIP_ICON = 1;
    public static var COL_TYPE_TEXT = 2;
    public static var COL_TYPE_NAME = 3;


  /* PRIVATE VARIABLES */

    private var _activeViewIndex: Number = -1;
        
    private var _layoutData: Object;
    private var _viewData: Object;
    private var _columnData: Object;
    private var _defaultsData: Object;

    private var _lastViewIndex: Number = -1;

    // viewIndex, columnIndex, stateIndex
    private var _prefData: Object;

    private var _stateData: Object;

    private var _defaultEntryTextFormat: TextFormat;
    private var _defaultLabelTextFormat: TextFormat;

    // List of views in this layout (updated only when the config changes)
    private var _viewList: Array;

    // List of columns for the current view (updated when the view changes
    private var _columnList: Array;

    private var _lastFilterFlag: Number = -1;


  /* PROPERTIES */

    public function get currentView()
    {
        return this._viewList[this._activeViewIndex];
    }

    private var _activeColumnIndex: Number = -1;

    public function get activeColumnIndex()
    {
        return this._activeColumnIndex;
    }

    public function get columnCount()
    {
        return this._columnLayoutData.length;
    }

    private var _activeColumnState: Number = 1;

    public function get activeColumnState()
    {
        return this._activeColumnState;
    }

    private var _columnLayoutData: Array;

    public function get columnLayoutData()
    {
        return this._columnLayoutData;
    }

    private var _hiddenStageNames: Array;

    public function get hiddenStageNames()
    {
        return this._hiddenStageNames;
    }

    private var _entryWidth: Number;

    public function get entryWidth()
    {
        return this._entryWidth;
    }

    public function set entryWidth(a_width: Number)
    {
        this._entryWidth = a_width;
    }

    private var _entryHeight: Number;

    public function get entryHeight()
    {
        return this._entryHeight;
    }

    private var _layoutUpdateCount: Number = 1;

    public function get layoutUpdateCount()
    {
        return this._layoutUpdateCount;
    }

    private var _columnDescriptors: Array;

    public function get columnDescriptors()
    {
        return this._columnDescriptors;
    }

    private var _sortOptions: Array;

    public function get sortOptions()
    {
        return this._sortOptions;
    }

    private var _sortAttributes: Array;

    public function get sortAttributes()
    {
        return this._sortAttributes;
    }



  /* INITIALIZATION */

    public function ListLayout(a_layoutData: Object, a_viewData: Object, a_columnData: Object, a_defaultsData: Object)
    {
        skyui.util.GlobalFunctions.addArrayFunctions();
        
        gfx.events.EventDispatcher.initialize(this);
        
        this._prefData = {column: null, stateIndex: 1};
        this._viewList = [];
        this._columnList = [];
        this._columnLayoutData = [];
        this._hiddenStageNames = [];
        this._columnDescriptors = [];
        
        this._layoutData = a_layoutData;
        this._viewData = a_viewData;
        this._columnData = a_columnData;
        this._defaultsData = a_defaultsData;

        if (this._entryWidth == undefined)
            this._entryWidth = this._defaultsData.entryWidth;
        
        this.updateViewList();
        this.updateColumnList();
        
        // Initial textformats
        this._defaultEntryTextFormat = new TextFormat(); 
        this._defaultLabelTextFormat = new TextFormat();
        
        // Copy default textformat values from config
        for (var prop in this._defaultsData.entry.textFormat)
            if (this._defaultEntryTextFormat.hasOwnProperty(prop))
                this._defaultEntryTextFormat[prop] = this._defaultsData.entry.textFormat[prop];
        
        for (var prop in this._defaultsData.label.textFormat)
            if (this._defaultLabelTextFormat.hasOwnProperty(prop))
                this._defaultLabelTextFormat[prop] = this._defaultsData.label.textFormat[prop];
    }


  /* PUBLIC FUNCTIONS */

    // @mixin by gfx.events.EventDispatcher
    public var dispatchEvent: Function;
    public var dispatchQueue: Function;
    public var hasEventListener: Function;
    public var addEventListener: Function;
    public var removeEventListener: Function;
    public var removeAllEventListeners: Function;
    public var cleanUpEvents: Function;

    public function refresh()
    {
        this.updateViewList();
        this._lastViewIndex = -1;
        this.changeFilterFlag(this._lastFilterFlag);
    }

    public function changeFilterFlag(a_flag: Number)
    {
        this._lastFilterFlag = a_flag;
        
        // Find a matching view, or use last index
        for (var i = 0; i < this._viewList.length; i++) {
            
            // Wrap in array for single category
            var categories = ((this._viewList[i].category) instanceof Array) ? this._viewList[i].category : [this._viewList[i].category];
            
            if (categories.indexOf(a_flag) != undefined || i == this._viewList.length - 1) {
                this._activeViewIndex = i;
                break;
            }
        }
        
        if (this._activeViewIndex == -1 || this._lastViewIndex == this._activeViewIndex)
            return;
        
        this._lastViewIndex = this._activeViewIndex;
        
        // Do this before restoring the pref state!
        this.updateColumnList();
        
        // Restoring a previous state was not necessary or failed? Then use default
        if (!this.restorePrefState()) {
            this._activeColumnIndex = this.currentView.columns.indexOf(this.currentView.primaryColumn);
            if (this._activeColumnIndex == undefined)
                this._activeColumnIndex = 0;
                
            this._activeColumnState = 1;
        }

        this.updateLayout();
    }

    public function selectColumn(a_index: Number)
    {
        var listIndex = this.toColumnListIndex(a_index);
        var col = this._columnList[listIndex];
        
        // Invalid column
        if (col == null || col.passive)
            return;
            
        if (this._activeColumnIndex != a_index) {
            this._activeColumnIndex = a_index;
            this._activeColumnState = 1;
        } else {
            if (this._activeColumnState < col.states)
                this._activeColumnState++;
            else
                this._activeColumnState = 1;
        }
        
        // Save as preferred state
        this._prefData.column = col;
        this._prefData.stateIndex = this._activeColumnState;
            
        this.updateLayout();
    }

    public function restoreColumnState(a_activeIndex: Number, a_activeState: Number)
    {
        var listIndex = this.toColumnListIndex(a_activeIndex);
        var col = this._columnList[listIndex];
        
        // Invalid column
        if (col == null || col.passive)
            return;

        if (a_activeState < 1 || a_activeState > col.states)
            return;
        
        this._activeColumnIndex = a_activeIndex;
        this._activeColumnState = a_activeState;
        
        // Save as preferred state
        this._prefData.column = col;
        this._prefData.stateIndex = this._activeColumnState;

        this.updateLayout();
    }


    /* PRIVATE FUNCTIONS */

    private function updateLayout()
    {
        this._layoutUpdateCount++;

        var maxHeight = 0;
        var textFieldIndex = 0;

        this._hiddenStageNames.splice(0);
        this._columnLayoutData.splice(0);
        
        // Set bit at position i if column is weighted
        var weightedFlags = 0;
        
        var c = 0;
        // Move some data from current state to root of the column so we can access single- and multi-state columns in the same manner.
        // So this is a merge of defaults, column root and current state.
        for (var i = 0; i < this._columnList.length; i++) {			
            var col = this._columnList[i];
            // Skip
            if (col.hidden == true)
                continue;
                
            var columnLayoutData = new skyui.components.list.ColumnLayoutData();
            this._columnLayoutData[c] = columnLayoutData;
                
            // Non-active columns always use state 1
            var stateData: Object;
            if (c == this._activeColumnIndex) {
                stateData = col["state" + this._activeColumnState];
                this.updateSortParams(stateData);
            } else {
                stateData = col["state1"];
            }
                
            columnLayoutData.type = col.type;
            columnLayoutData.labelArrowDown = stateData.label.arrowDown ? true : false;
            columnLayoutData.labelValue = stateData.label.text;
            columnLayoutData.entryValue = stateData.entry.text;
            columnLayoutData.colorAttribute = stateData.colorAttribute;
            
            c++;
        }
        
        // Subtract arrow tip width
        var weightedWidth = this._entryWidth - 12;
        
        var weightSum = 0;

        var bEnableItemIcon = false;
        var bEnableEquipIcon = false;

        c = 0;
        for (var i = 0; i < this._columnList.length; i++) {
            var col = this._columnList[i];
            // Skip
            if (col.hidden == true)
                continue;
                
            var columnLayoutData = this._columnLayoutData[c++];

            // Calc total weighted width and set weighted flags
            if (col.weight != undefined) {
                weightSum += col.weight;
                weightedFlags = (weightedFlags | 1) << 1;
            } else {
                weightedFlags = (weightedFlags | 0) << 1;
            }
            
            if (col.indent != undefined)
                weightedWidth -= col.indent;
            
            // Height including borders for maxHeight
            var curHeight = 0;
            
            switch (col.type) {
                // ITEM ICON + EQUIP ICON
                case skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON:
                case skyui.components.list.ListLayout.COL_TYPE_EQUIP_ICON:
                                
                    if (col.type == skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON) {
                        columnLayoutData.stageName = "itemIcon";
                        bEnableItemIcon = true;
                    } else {
                        columnLayoutData.stageName = "equipIcon";
                        bEnableEquipIcon = true;
                    }
                    
                    columnLayoutData.width = this._columnLayoutData[i].height = col.icon.size;
                    weightedWidth -= col.icon.size;
                        
                    curHeight += col.icon.size;
                    
                    break;

                // REST
                default:
                    columnLayoutData.stageName = "textField" + textFieldIndex++;
                    
                    if (col.width != undefined) {
                        // Width >= 1 for absolute width, < 1 for percentage width
                        columnLayoutData.width = col.width < 1 ? (col.width * this._entryWidth) : col.width;
                        weightedWidth -= columnLayoutData.width;
                    } else {
                        columnLayoutData.width = 0;
                    }
                    
                    if (col.height != undefined)
                        // Height >= 1 for absolute height, < 1 for percentage height
                        columnLayoutData.height = col.height < 1 ? (col.height * this._entryWidth) : col.height;
                    else
                        columnLayoutData.height = 0;
                    
                    if (col.entry.textFormat != undefined) {
                        var customTextFormat = new TextFormat();

                        // First clone default format
                        for (var prop in this._defaultEntryTextFormat)
                            customTextFormat[prop] = this._defaultEntryTextFormat[prop];
                        
                        // Then override if necessary
                        for (var prop in col.entry.textFormat)
                            if (customTextFormat.hasOwnProperty(prop))
                                customTextFormat[prop] = col.entry.textFormat[prop];
                        
                        columnLayoutData.textFormat = customTextFormat;
                    } else {
                        columnLayoutData.textFormat = this._defaultEntryTextFormat;
                    }
                    
                    if (col.label.textFormat != undefined) {
                        var customTextFormat = new TextFormat();

                        // First clone default format
                        for (var prop in this._defaultLabelTextFormat)
                            customTextFormat[prop] = this._defaultLabelTextFormat[prop];
                    
                        // Then override if necessary
                        for (var prop in col.label.textFormat)
                            if (customTextFormat.hasOwnProperty(prop))
                                customTextFormat[prop] = col.label.textFormat[prop];
                                
                        columnLayoutData.labelTextFormat = customTextFormat;
                    } else {
                        columnLayoutData.labelTextFormat = this._defaultLabelTextFormat;
                    }
            }
            
            if (col.border != undefined) {
                weightedWidth -= col.border[skyui.components.list.ListLayout.LEFT] + col.border[skyui.components.list.ListLayout.RIGHT];
                curHeight += col.border[skyui.components.list.ListLayout.TOP] + col.border[skyui.components.list.ListLayout.BOTTOM];
                columnLayoutData.y = col.border[skyui.components.list.ListLayout.TOP];
            } else {
                columnLayoutData.y = 0;
            }
            
            if (curHeight > maxHeight)
                maxHeight = curHeight;
        }
        
        // Calculate the widths
        if (weightSum > 0 && weightedWidth > 0 && weightedFlags != 0) {
            c = this._columnLayoutData.length - 1;
            for (var i = this._columnList.length - 1; i >= 0; i--) {
                var col = this._columnList[i];
                // Skip
                if (col.hidden == true)
                    continue;
                    
                var columnLayoutData = this._columnLayoutData[c--];
                
                if ((weightedFlags >>>= 1) & 1) {
                    if (col.border != undefined)
                        columnLayoutData.width += ((col.weight / weightSum) * weightedWidth) - col.border[skyui.components.list.ListLayout.LEFT] - col.border[skyui.components.list.ListLayout.RIGHT];
                    else
                        columnLayoutData.width += (col.weight / weightSum) * weightedWidth;
                }
            }
        }
        
        // Set x positions based on calculated widths, and set label data
        var xPos = 0;
        c = 0;
        for (var i = 0; i < this._columnList.length; i++) {
            var col = this._columnList[i];
            // Skip
            if (col.hidden == true)
                continue;
                
            var columnLayoutData = this._columnLayoutData[c++];
            
            if (col.indent != undefined)
                xPos += col.indent;

            columnLayoutData.labelX = xPos;

            if (col.border != undefined) {
                columnLayoutData.labelWidth = columnLayoutData.width + col.border[skyui.components.list.ListLayout.LEFT] + col.border[skyui.components.list.ListLayout.RIGHT];
                columnLayoutData.x = xPos;
                xPos += col.border[skyui.components.list.ListLayout.LEFT];
                columnLayoutData.x = xPos;
                xPos += col.border[skyui.components.list.ListLayout.RIGHT] + columnLayoutData.width;
            } else {
                columnLayoutData.labelWidth = columnLayoutData.width;
                columnLayoutData.x = xPos;
                xPos += columnLayoutData.width;
            }
        }
        
        while (textFieldIndex < skyui.components.list.ListLayout.MAX_TEXTFIELD_INDEX)
            this._hiddenStageNames.push("textField" + textFieldIndex++);
        
        if (!bEnableItemIcon)
            this._hiddenStageNames.push("itemIcon");
        
        if (!bEnableEquipIcon)
            this._hiddenStageNames.push("equipIcon");
        
        this._entryHeight = maxHeight;
        
        // sortChange might not always trigger an update, so we have to make sure the list is updated,
        // even if that means we update it twice.
        this.dispatchEvent({type: "layoutChange"});
    }

    private function updateSortParams(stateData: Object)
    {
        var sortAttributes = stateData.sortAttributes;
        var sortOptions = stateData.sortOptions;
        
        if (!sortOptions) {
            this._sortOptions = null;
            this._sortAttributes = null;
            return;
        }
        
        // No attribute(s) set? Try to use entry value
        if (!sortAttributes)
            if (stateData.entry.text.charAt(0) == "@")
                sortAttributes = [ stateData.entry.text.slice(1) ];
        
        if (!sortAttributes) {
            this._sortOptions = null;
            this._sortAttributes = null;
            return;
        }
        
        // Wrap single attribute in array
        if (!(sortAttributes instanceof Array))
            sortAttributes = [sortAttributes];
            
        if (!(sortOptions instanceof Array))
            sortOptions = [sortOptions];
            
        this._sortOptions = sortOptions;
        this._sortAttributes = sortAttributes;
    }

    private function restorePrefState()
    {
        // No preference to restore yet
        if (!this._prefData.column)
            return false;

        var listIndex = this._columnList.indexOf(this._prefData.column);
        var layoutDataIndex = this.toColumnLayoutDataIndex(listIndex);

        if (listIndex > -1 && layoutDataIndex > -1) {
            this._activeColumnIndex = layoutDataIndex;
            this._activeColumnState = this._prefData.stateIndex;
            return true;
        }
        
        // Found no match, reset prefData and return false
        this._prefData.column = null;
        this._prefData.stateIndex = 1;
        return false;
    }

    // columnLayoutData index (no hidden columns) -> columnList index (all columns for this view)
    private function toColumnListIndex(a_index)
    {
        var c = 0;
        for (var i = 0; i < this._columnList.length; i++) {
            if (this._columnList[i].hidden == true)
                continue;
            if (c == a_index)
                return i;
            c++;
        }
        
        return -1;
    }

    // columnList index (all columns for this view) -> columnLayoutData index (no hidden columns)
    private function toColumnLayoutDataIndex(a_index)
    {
        var c = 0;
        for (var i = 0; i < this._columnList.length; i++) {
            if (this._columnList[i].hidden == true)
                continue;
            if (i == a_index)
                return c;
            c++;
        }
        
        return -1;
    }

    private function updateViewList()
    {
        this._viewList.splice(0);
        var viewNames = this._layoutData.views;
        for (var i = 0; i < viewNames.length; i++)
            this._viewList.push(this._viewData[viewNames[i]]);
    }

    private function updateColumnList()
    {
        this._columnList.splice(0);
        this._columnDescriptors.splice(0);
        
        var columnNames = this.currentView.columns;
        
        for (var i = 0; i < columnNames.length; i++) {
            var col = this._columnData[columnNames[i]];
            var cd : ColumnDescriptor = new skyui.components.list.ColumnDescriptor();
            cd.hidden = col.hidden;
            cd.identifier = columnNames[i];
            cd.longName = col.name;
            cd.type = col.type;
            
            this._columnList.push(col);
            this._columnDescriptors.push(cd);
        }
    }
}