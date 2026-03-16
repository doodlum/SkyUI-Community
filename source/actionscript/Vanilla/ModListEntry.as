class ModListEntry extends ListEntryBase
{
   var RatingCount_tf;
   var RatingHolder_mc;
   var _DataObj;
   var textField;
   static var MAX_RATING = 5;
   var TEXT_STAR_INTERSTIT = 5;
   var STAR_SPACING = 2.5;
   function ModListEntry()
   {
      super();
   }
   function redrawUIComponent()
   {
      super.redrawUIComponent();
      var _loc4_;
      var _loc3_;
      var _loc5_;
      if(this._DataObj != null)
      {
         this.RatingHolder_mc._y = this.textField._y + this.textField._height;
         for(var _loc6_ in this.RatingHolder_mc)
         {
            if(this.RatingHolder_mc[_loc6_] instanceof MovieClip)
            {
               this.RatingHolder_mc[_loc6_].removeMovieClip();
            }
         }
         _loc4_ = 0;
         while(_loc4_ < ModListEntry.MAX_RATING)
         {
            _loc5_ = this._DataObj.rating - _loc4_;
            if(_loc5_ <= 0.25)
            {
               _loc3_ = this.RatingHolder_mc.attachMovie("Star_Empty","StarRating",this.RatingHolder_mc.getNextHighestDepth());
            }
            else if(_loc5_ > 0.25 && _loc5_ <= 0.75)
            {
               _loc3_ = this.RatingHolder_mc.attachMovie("Star_HalfFull","StarRating",this.RatingHolder_mc.getNextHighestDepth());
            }
            else
            {
               _loc3_ = this.RatingHolder_mc.attachMovie("Star_Full","StarRating",this.RatingHolder_mc.getNextHighestDepth());
            }
            _loc3_._x = (_loc3_._width + this.STAR_SPACING) * _loc4_;
            _loc4_ = _loc4_ + 1;
         }
         if(this.RatingCount_tf != null)
         {
            this.RatingCount_tf.SetText("(" + this._DataObj.ratingCount + ")",false);
            this.RatingCount_tf._y = this.RatingHolder_mc._y + this.RatingHolder_mc._height;
         }
      }
   }
}
