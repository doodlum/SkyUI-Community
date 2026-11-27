class skyui.filter.ItemTypeFilter implements skyui.filter.IFilter
{
   var _matcherFunc;
   var dispatchEvent;
   var _itemFilter = 4294967295;
   function ItemTypeFilter()
   {
      gfx.events.EventDispatcher.initialize(this);
      this._matcherFunc = skyui.filter.ItemTypeFilter.entryMatchesFilter;
   }
   function get itemFilter()
   {
      return this._itemFilter;
   }
   function changeFilterFlag(a_newFilter, a_bDoNotUpdate)
   {
      if(a_bDoNotUpdate == undefined)
      {
         a_bDoNotUpdate = false;
      }
      this._itemFilter = a_newFilter;
      if(!a_bDoNotUpdate)
      {
         this.dispatchEvent({type:"filterChange"});
      }
   }
   function setPartitionedFilterMode(a_bPartition)
   {
      this._matcherFunc = !a_bPartition ? skyui.filter.ItemTypeFilter.entryMatchesFilter : skyui.filter.ItemTypeFilter.entryMatchesPartitionedFilter;
   }
   function applyFilter(a_filteredList)
   {
      // Compact in place (keeps order). Removing non-matching entries one splice() at a time shifted the rest of
      // the array on every removal - O(n^2) for categories that hide most of a large list.
      var matcher = this._matcherFunc;
      var flag = this._itemFilter;
      var len = a_filteredList.length;
      var writeIndex = 0;
      for(var i = 0; i < len; i++)
      {
         var e = a_filteredList[i];
         if(matcher(e,flag))
         {
            a_filteredList[writeIndex++] = e;
         }
      }
      a_filteredList.length = writeIndex;
   }
   function isMatch(a_entry, a_flag)
   {
      return this._matcherFunc(a_entry,a_flag);
   }
   static function entryMatchesFilter(a_entry, a_flag)
   {
      return a_entry != undefined && (a_entry.filterFlag == undefined || (a_entry.filterFlag & a_flag) != 0);
   }
   static function entryMatchesPartitionedFilter(a_entry, a_flag)
   {
      if(a_entry == undefined)
      {
         return false;
      }
      if(a_flag == 4294967295)
      {
         return true;
      }
      var _loc1_ = a_entry.filterFlag;
      var _loc4_ = _loc1_ & 0xFF;
      var _loc3_ = (_loc1_ & 0xFF00) >>> 8;
      var _loc6_ = (_loc1_ & 0xFF0000) >>> 16;
      var _loc5_ = (_loc1_ & 0xFF000000) >>> 24;
      return _loc4_ == a_flag || _loc3_ == a_flag || _loc6_ == a_flag || _loc5_ == a_flag;
   }
}
