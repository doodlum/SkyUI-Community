class Components.UniformTimeMeter extends Components.Meter
{
   var AnimClip;
   var AnimStart;
   var CurrentPercent;
   var Empty;
   var FinishSound;
   var FrameCount;
   var FrameNumber;
   var Full;
   var TargetPercent;
   var bFinished;
   var meterMovieClip;
   function UniformTimeMeter(aMovieClip, aFinishSound, aClip, aAnimStart)
   {
      super(aMovieClip);
      this.FinishSound = aFinishSound;
      this.AnimClip = aClip;
      this.AnimStart = aAnimStart;
      this.FrameNumber = 48;
   }
   function SetTargetPercent(aPercent)
   {
      super.SetTargetPercent(aPercent);
      this.bFinished = aPercent >= 100 && this.CurrentPercent < 100;
      this.FrameCount = 0;
   }
   function Update()
   {
      var _loc2_;
      var _loc3_;
      if(this.FrameCount <= this.FrameNumber)
      {
         _loc2_ = Shared.GlobalFunc.Lerp(this.CurrentPercent,this.TargetPercent,0,this.FrameNumber,this.FrameCount);
         _loc3_ = Shared.GlobalFunc.Lerp(this.Empty,this.Full,0,100,_loc2_);
         this.meterMovieClip.gotoAndStop(_loc3_);
         this.FrameCount = this.FrameCount + 1;
         if(this.FrameCount == this.FrameNumber && this.bFinished)
         {
            gfx.io.GameDelegate.call("PlaySound",[this.FinishSound]);
            if(this.AnimClip != undefined)
            {
               this.AnimClip.gotoAndPlay(this.AnimStart);
            }
         }
      }
   }
}
