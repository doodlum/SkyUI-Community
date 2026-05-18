class skyui.filter.SortFilter implements skyui.filter.IFilter
{
  /* PRIVATE VARIABLES */

    private var _sortAttributes: Array;
    private var _sortOptions: Array;


  /* INITIALIZATION */

    public function SortFilter()
    {
        gfx.events.EventDispatcher.initialize(this);
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

    // Change the filter attributes and options and trigger an update if necessary.
    public function setSortBy(a_sortAttributes: Array, a_sortOptions: Array)
    {
        if (this._sortAttributes == a_sortAttributes && this._sortOptions == a_sortOptions)
            return;
            
        this._sortAttributes = a_sortAttributes;
        this._sortOptions = a_sortOptions;
        
        this.dispatchEvent({type: "filterChange"});
    }

    // @override skyui.filter.IFilter
    public function applyFilter(a_filteredList: Array)
    {
        var primaryAttribute = this._sortAttributes[0];
        
        for (var i = 0; i < a_filteredList.length; i++) {
            var t = a_filteredList[i][primaryAttribute];
            if (t == null)
                a_filteredList[i]._sortFlag = 1;
            else
                a_filteredList[i]._sortFlag = 0;
        }

        this._sortAttributes.unshift("enabled");
        this._sortOptions.unshift(Array.NUMERIC | Array.DESCENDING);

        this._sortAttributes.unshift("_sortFlag");
        this._sortOptions.unshift(Array.NUMERIC);
        
        a_filteredList.sortOn(this._sortAttributes, this._sortOptions);
        
        this._sortAttributes.shift();
        this._sortOptions.shift();
        
        this._sortAttributes.shift();
        this._sortOptions.shift();
    }
}
