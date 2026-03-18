class ModDetailsOptionsList extends Shared.BSScrollingList
{
   var EntriesA;
   var GetClipByIndex;
   var SetEntry;
   var __get__selectedEntry;
   var iSelectedIndex;
   var STAR_SPACING = 2.5;
   function ModDetailsOptionsList()
   {
      super();
   }
   function UpdateSelectedEntry()
   {
      if(this.iSelectedIndex != -1)
      {
         this.SetEntry(this.GetClipByIndex(this.EntriesA[this.iSelectedIndex].clipIndex),this.EntriesA[this.iSelectedIndex]);
      }
   }
   function SetEntryText(aEntryClip, aEntryObject)
   {
      super.SetEntryText(aEntryClip,aEntryObject);
      var _loc12_ = aEntryClip.textField;
      var _loc13_ = aEntryClip.border;
      var _loc9_ = aEntryObject == this.selectedEntry;
      if(_loc12_)
      {
         _loc12_.textColor = !_loc9_ ? 16777215 : 0;
      }
      if(_loc13_ != null)
      {
         _loc13_._alpha = !_loc9_ ? 0 : 100;
      }
      var _loc3_ = aEntryClip.StarHolder_mc;
      for(var _loc10_ in _loc3_)
      {
         if(typeof _loc3_[_loc10_] == "movieclip")
         {
            _loc3_[_loc10_].removeMovieClip();
         }
      }
      var _loc4_;
      var _loc5_;
      var _loc6_;
      if(aEntryObject.showStars)
      {
         _loc4_ = 0;
         while(_loc4_ < ModListEntry.MAX_RATING)
         {
            _loc6_ = aEntryObject.rating - _loc4_;
            if(_loc6_ <= 0.25)
            {
               _loc5_ = _loc3_.attachMovie("Star_Empty","Star" + _loc4_,_loc3_.getNextHighestDepth());
            }
            else if(_loc6_ > 0.25 && _loc6_ <= 0.75)
            {
               _loc5_ = _loc3_.attachMovie("Star_HalfFull","Star" + _loc4_,_loc3_.getNextHighestDepth());
            }
            else
            {
               _loc5_ = _loc3_.attachMovie("Star_Full","Star" + _loc4_,_loc3_.getNextHighestDepth());
            }
            _loc5_._x = (_loc5_._width + this.STAR_SPACING) * _loc4_;
            _loc4_ = _loc4_ + 1;
         }
      }
      var _loc8_ = aEntryClip.transform.colorTransform;
      _loc8_.redOffset = !aEntryObject.disabled ? 0 : -128;
      _loc8_.greenOffset = !aEntryObject.disabled ? 0 : -128;
      _loc8_.blueOffset = !aEntryObject.disabled ? 0 : -128;
      aEntryClip.transform.colorTransform = _loc8_;
      _loc8_ = _loc3_.transform.colorTransform;
      _loc8_.redOffset = !_loc9_ ? 0 : -255;
      _loc8_.greenOffset = !_loc9_ ? 0 : -255;
      _loc8_.blueOffset = !_loc9_ ? 0 : -255;
      _loc3_.transform.colorTransform = _loc8_;
   }
}
