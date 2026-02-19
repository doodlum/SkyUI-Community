class Components.DeltaMeter extends Components.Meter
{
   var DeltaEmpty;
   var DeltaFull;
   var DeltaMeterMovieClip;
   function DeltaMeter(aMovieClip)
   {
      super(aMovieClip);
      this.DeltaMeterMovieClip = aMovieClip.DeltaIndicatorInstance;
      this.DeltaMeterMovieClip.gotoAndStop("Empty");
      this.DeltaEmpty = this.DeltaMeterMovieClip._currentframe;
      this.DeltaMeterMovieClip.gotoAndStop("Full");
      this.DeltaFull = this.DeltaMeterMovieClip._currentframe;
   }
   function SetDeltaPercent(aiPercent)
   {
      var _loc3_ = Math.min(100,Math.max(aiPercent,0));
      var _loc2_ = Math.floor(Shared.GlobalFunc.Lerp(this.DeltaEmpty,this.DeltaFull,0,100,_loc3_));
      this.DeltaMeterMovieClip.gotoAndStop(_loc2_);
   }
}
