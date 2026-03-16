class ShoutMeter extends MovieClip
{
   var FlashClip;
   var MeterEmtpy;
   var MeterFull;
   var ProgressClip;
   function ShoutMeter(aProgressClip, aFlashClip)
   {
      super();
      this.ProgressClip = aProgressClip;
      this.FlashClip = aFlashClip;
      this.ProgressClip.gotoAndStop("Empty");
      this.MeterEmtpy = this.ProgressClip._currentframe;
      this.ProgressClip.gotoAndStop("Full");
      this.MeterFull = this.ProgressClip._currentframe;
      this.ProgressClip.gotoAndStop("Normal");
      this.FlashClip.gotoAndStop("Warning Start");
   }
   function SetPercent(aPercent)
   {
      var _loc2_;
      var _loc3_;
      if(aPercent >= 100)
      {
         this.ProgressClip.gotoAndStop("Normal");
      }
      else
      {
         _loc2_ = Math.min(100,Math.max(aPercent,0));
         _loc3_ = Math.floor(Shared.GlobalFunc.Lerp(this.MeterEmtpy,this.MeterFull,0,100,_loc2_));
         this.ProgressClip.gotoAndStop(_loc3_);
      }
   }
   function FlashMeter()
   {
      this.FlashClip.gotoAndPlay("Warning Start");
   }
}
