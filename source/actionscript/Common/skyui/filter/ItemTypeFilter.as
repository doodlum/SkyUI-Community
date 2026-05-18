class skyui.filter.ItemTypeFilter implements skyui.filter.IFilter
{
  /* PRIVATE VARIABLES */

    private var _matcherFunc: Function;
    
    
  /* PROPERTIES */

    private var _itemFilter: Number = 0xFFFFFFFF;

    function get itemFilter()
    {
        return this._itemFilter;
    }


  /* INITIALIZATION */

    public function ItemTypeFilter()
    {
        gfx.events.EventDispatcher.initialize(this);
        
        this._matcherFunc = skyui.filter.ItemTypeFilter.entryMatchesFilter;
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
    
    public function changeFilterFlag(a_newFilter: Number, a_bDoNotUpdate: Boolean)
    {
        if (a_bDoNotUpdate == undefined)
            a_bDoNotUpdate = false;
        
        this._itemFilter = a_newFilter;
        
        if (!a_bDoNotUpdate)
            this.dispatchEvent({type:"filterChange"});
    }

    public function setPartitionedFilterMode(a_bPartition: Boolean)
    {
        this._matcherFunc = a_bPartition
            ? skyui.filter.ItemTypeFilter.entryMatchesPartitionedFilter
            : skyui.filter.ItemTypeFilter.entryMatchesFilter;
    }
    
    // @override skyui.IFilter
    public function applyFilter(a_filteredList: Array)
    {
        for (var i = 0; i < a_filteredList.length; i++) {
            if (!this._matcherFunc(a_filteredList[i], this._itemFilter)) {
                a_filteredList.splice(i,1);
                i--;
            }
        }
    }
    
    public function isMatch(a_entry: Object, a_flag)
    {
        return this._matcherFunc(a_entry, a_flag);
    }
    
    
  /* PRIVATE FUNCTIONS */
    
    public static function entryMatchesFilter(a_entry: Object, a_flag: Boolean)
    {
        return a_entry != undefined &&
            (a_entry.filterFlag == undefined || (a_entry.filterFlag & a_flag) != 0);
    }

    private static function entryMatchesPartitionedFilter(a_entry: Object, a_flag: Boolean)
    {
        if (a_entry == undefined)
            return false;
            
        if (a_flag == 0xFFFFFFFF)
            return true;
            
        var flag: Number = a_entry.filterFlag;
        var byte0: Number = (flag & 0x000000FF);
        var byte1: Number = (flag & 0x0000FF00) >>> 8;
        var byte2: Number = (flag & 0x00FF0000) >>> 16;
        var byte3: Number = (flag & 0xFF000000) >>> 24;
        
        return byte0 == a_flag || byte1 == a_flag || byte2 == a_flag || byte3 == a_flag;
    }
}
