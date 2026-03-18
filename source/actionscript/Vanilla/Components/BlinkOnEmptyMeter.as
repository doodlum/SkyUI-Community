class Components.BlinkOnEmptyMeter extends Components.Meter
{
   var CurrentPercent;
   var Empty;
   var meterMovieClip;
   function BlinkOnEmptyMeter(aMeterClip)
   {
      super(aMeterClip);
   }
   function Update()
   {
      super.Update();
      var _loc3_ = this.meterMovieClip._currentframe;
      var _loc4_;
      if(this.CurrentPercent <= 0)
      {
         if(_loc3_ == this.Empty)
         {
            this.meterMovieClip.gotoAndPlay(this.Empty + 1);
            _loc4_ = this.meterMovieClip._currentframe;
         }
      }
   }
}
