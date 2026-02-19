class skyui.components.list.FilteredEnumeration extends skyui.components.list.BasicEnumeration
{
   var _entryData;
   var _filterChain;
   var _filteredData;
   function FilteredEnumeration(a_data)
   {
      super(a_data);
      this._filterChain = [];
      this._filteredData = [];
   }
   function addFilter(a_filter)
   {
      this._filterChain.push(a_filter);
   }
   function size()
   {
      return this._filteredData.length;
   }
   function at(a_index)
   {
      return this._filteredData[a_index];
   }
   function lookupEntryIndex(a_enumIndex)
   {
      return this._filteredData[a_enumIndex].itemIndex;
   }
   function lookupEnumIndex(a_entryIndex)
   {
      return this._entryData[a_entryIndex].filteredIndex;
   }
   function invalidate()
   {
      this.applyFilters();
   }
   function applyFilters()
   {
      this._filteredData.splice(0);
      var _loc2_ = 0;
      while(_loc2_ < this._entryData.length)
      {
         this._entryData[_loc2_].filteredIndex = undefined;
         this._filteredData[_loc2_] = this._entryData[_loc2_];
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < this._filterChain.length)
      {
         this._filterChain[_loc2_].applyFilter(this._filteredData);
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < this._filteredData.length)
      {
         this._filteredData[_loc2_].filteredIndex = _loc2_;
         _loc2_ = _loc2_ + 1;
      }
   }
}
