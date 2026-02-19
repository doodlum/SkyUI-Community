class skyui.filter.SortFilter implements skyui.filter.IFilter
{
   var _sortAttributes;
   var _sortOptions;
   var dispatchEvent;
   function SortFilter()
   {
      gfx.events.EventDispatcher.initialize(this);
   }
   function setSortBy(a_sortAttributes, a_sortOptions)
   {
      if(this._sortAttributes == a_sortAttributes && this._sortOptions == a_sortOptions)
      {
         return undefined;
      }
      this._sortAttributes = a_sortAttributes;
      this._sortOptions = a_sortOptions;
      this.dispatchEvent({type:"filterChange"});
   }
   function applyFilter(a_filteredList)
   {
      var _loc5_ = this._sortAttributes[0];
      var _loc2_ = 0;
      var _loc4_;
      while(_loc2_ < a_filteredList.length)
      {
         _loc4_ = a_filteredList[_loc2_][_loc5_];
         if(_loc4_ == null)
         {
            a_filteredList[_loc2_]._sortFlag = 1;
         }
         else
         {
            a_filteredList[_loc2_]._sortFlag = 0;
         }
         _loc2_ = _loc2_ + 1;
      }
      this._sortAttributes.unshift("enabled");
      this._sortOptions.unshift(Array.NUMERIC | Array.DESCENDING);
      this._sortAttributes.unshift("_sortFlag");
      this._sortOptions.unshift(Array.NUMERIC);
      a_filteredList.sortOn(this._sortAttributes,this._sortOptions);
      this._sortAttributes.shift();
      this._sortOptions.shift();
      this._sortAttributes.shift();
      this._sortOptions.shift();
   }
}
