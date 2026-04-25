class skyui.components.list.FilteredEnumeration extends skyui.components.list.BasicEnumeration
{
  /* PRIVATE VARIABLES */

    private var _filteredData: Array;
    private var _filterChain: Array;


  /* INITIALIZATION */

    public function FilteredEnumeration(a_data: Array)
    {
        super(a_data);
        
        this._filterChain = [];
        this._filteredData = [];
    }


  /* PUBLIC FUNCTIONS */

    public function addFilter(a_filter: IFilter)
    {
        this._filterChain.push(a_filter);
    }

    // @override skyui.BasicEnumeration
    public function size()
    {
        return this._filteredData.length;
    }

    // @override skyui.BasicEnumeration
    public function at(a_index: Number)
    {
        return this._filteredData[a_index];
    }

    // @override skyui.IEntryEnumeration
    public function lookupEntryIndex(a_enumIndex: Number)
    {
        return this._filteredData[a_enumIndex].itemIndex;
    }

    // @override skyui.IEntryEnumeration
    public function lookupEnumIndex(a_entryIndex: Number)
    {
        return this._entryData[a_entryIndex].filteredIndex;
    }

    // The underlying entryData has been modified externally, so regenerate the enumeration.
    public function invalidate()
    {
        this.applyFilters();
    }


  /* PRIVATE FUNCTIONS */

    private function applyFilters()
    {
        this._filteredData.splice(0);
        
        // Copy the original list, add some helper attributes for easy mapping
        for (var i = 0; i < this._entryData.length; i++) {
            this._entryData[i].filteredIndex = undefined;
            this._filteredData[i] = this._entryData[i];
        }

        // Apply filters
        for (var i = 0; i < this._filterChain.length; i++)
            this._filterChain[i].applyFilter(this._filteredData);

        for (var i = 0; i < this._filteredData.length; i++)
            this._filteredData[i].filteredIndex = i;
    }
}