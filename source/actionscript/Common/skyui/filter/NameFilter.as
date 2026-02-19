class skyui.filter.NameFilter implements skyui.filter.IFilter
{
   var dispatchEvent;
   var nameAttribute = "text";
   var _filterText = "";
   function NameFilter()
   {
      gfx.events.EventDispatcher.initialize(this);
   }
   function get filterText()
   {
      return this._filterText;
   }
   function set filterText(a_filterText)
   {
      a_filterText = a_filterText.toLowerCase();
      if(a_filterText == this._filterText)
      {
         return;
      }
      this._filterText = a_filterText;
      this.dispatchEvent({type:"filterChange"});
   }
   function applyFilter(a_filteredList)
   {
      if(this._filterText == undefined || this._filterText == "")
      {
         return undefined;
      }
      var _loc2_ = 0;
      while(_loc2_ < a_filteredList.length)
      {
         if(!this.isMatch(a_filteredList[_loc2_]))
         {
            a_filteredList.splice(_loc2_,1);
            _loc2_ = _loc2_ - 1;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function isMatch(a_entry)
   {
      var _loc6_ = a_entry[this.nameAttribute].toLowerCase();
      var _loc4_ = 0;
      var _loc3_ = false;
      var _loc2_ = 0;
      var _loc5_;
      while(_loc2_ < _loc6_.length)
      {
         _loc5_ = skyui.util.GlobalFunctions.mapUnicodeChar(this._filterText.charCodeAt(_loc4_));
         if(_loc6_.charCodeAt(_loc2_) == _loc5_)
         {
            if(!_loc3_)
            {
               _loc3_ = true;
            }
            _loc4_ = _loc4_ + 1;
            if(_loc4_ >= this._filterText.length)
            {
               return true;
            }
         }
         else if(_loc3_)
         {
            _loc3_ = false;
            _loc4_ = 0;
         }
         _loc2_ = _loc2_ + 1;
      }
      return false;
   }
}
