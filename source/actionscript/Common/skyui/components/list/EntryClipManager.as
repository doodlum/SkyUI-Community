class skyui.components.list.EntryClipManager
{
   var _clipPool;
   var _list;
   var _nextIndex = 0;
   var _clipCount = -1;
   function EntryClipManager(a_list)
   {
      this._list = a_list;
      this._clipPool = [];
   }
   function get clipCount()
   {
      return this._clipCount;
   }
   function set clipCount(a_clipCount)
   {
      this._clipCount = a_clipCount;
      var _loc3_ = a_clipCount - this._clipPool.length;
      if(_loc3_ > 0)
      {
         this.growPool(_loc3_);
      }
      var _loc2_ = 0;
      while(_loc2_ < this._clipPool.length)
      {
         this._clipPool[_loc2_]._visible = false;
         this._clipPool[_loc2_].itemIndex = undefined;
         _loc2_ = _loc2_ + 1;
      }
   }
   function getClip(a_index)
   {
      if(a_index >= this._clipCount)
      {
         return undefined;
      }
      return this._clipPool[a_index];
   }
   function growPool(a_size)
   {
      var _loc4_ = this._list.entryRenderer;
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < a_size)
      {
         _loc3_ = this._list.attachMovie(_loc4_,_loc4_ + this._nextIndex,this._list.getNextHighestDepth());
         _loc3_.initialize(this._nextIndex,this._list.listState);
         this._clipPool[this._nextIndex] = _loc3_;
         this._nextIndex = this._nextIndex + 1;
         _loc2_ = _loc2_ + 1;
      }
   }
}
