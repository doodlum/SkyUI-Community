class ModDetailsRating extends MovieClip
{
   var RatingCount_tf;
   var StarHolder_mc;
   var _RatingCount;
   var _RatingVal;
   static var MAX_RATING = 5;
   var STAR_SPACING = 2.5;
   function ModDetailsRating()
   {
      super();
      this._RatingVal = -1;
      this._RatingCount = 0;
   }
   function get rating()
   {
      return this._RatingVal;
   }
   function set rating(aVal)
   {
      this._RatingVal = aVal;
      this.redrawUIComponent();
   }
   function get ratingCount()
   {
      return this._RatingCount;
   }
   function set ratingCount(aVal)
   {
      this._RatingCount = aVal;
      this.redrawUIComponent();
   }
   function redrawUIComponent()
   {
      if(this.RatingCount_tf != null)
      {
         this.RatingCount_tf.SetText("(" + this._RatingCount + ")",false);
      }
      for(var _loc5_ in this.StarHolder_mc)
      {
         if(this.StarHolder_mc[_loc5_] instanceof MovieClip)
         {
            this.StarHolder_mc[_loc5_].removeMovieClip();
         }
      }
      var _loc3_ = 0;
      var _loc2_;
      var _loc4_;
      while(_loc3_ < ModDetailsRating.MAX_RATING)
      {
         _loc4_ = this._RatingVal - _loc3_;
         if(_loc4_ <= 0.25)
         {
            _loc2_ = this.StarHolder_mc.attachMovie("Star_Empty","StarRating",this.StarHolder_mc.getNextHighestDepth());
         }
         else if(_loc4_ > 0.25 && _loc4_ <= 0.75)
         {
            _loc2_ = this.StarHolder_mc.attachMovie("Star_HalfFull","StarRating",this.StarHolder_mc.getNextHighestDepth());
         }
         else
         {
            _loc2_ = this.StarHolder_mc.attachMovie("Star_Full","StarRating",this.StarHolder_mc.getNextHighestDepth());
         }
         _loc2_._x = (_loc2_._width + this.STAR_SPACING) * _loc3_;
         _loc3_ = _loc3_ + 1;
      }
   }
}
