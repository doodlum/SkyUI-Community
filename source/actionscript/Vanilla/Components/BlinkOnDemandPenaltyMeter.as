class Components.BlinkOnDemandPenaltyMeter extends Components.BlinkOnDemandMeter
{
   var CurrentPenaltyPercent;
   var Empty;
   var EmptySpeed;
   var FillSpeed;
   var Full;
   var TargetPenaltyPercent;
   var penaltyEmpty;
   var penaltyFull;
   var penaltyMeterMovieClip;
   function BlinkOnDemandPenaltyMeter(aMeterMovieClip, aBlinkMovieClip, aPenaltyMeterMovieClip)
   {
      super(aMeterMovieClip,aBlinkMovieClip);
      this.CurrentPenaltyPercent = 0;
      this.TargetPenaltyPercent = 0;
      this.penaltyMeterMovieClip = aPenaltyMeterMovieClip;
      if(this.penaltyMeterMovieClip != undefined)
      {
         this.penaltyMeterMovieClip.gotoAndStop("Full");
         this.penaltyFull = this.penaltyMeterMovieClip._currentframe;
         this.penaltyMeterMovieClip.gotoAndStop("Empty");
         this.penaltyEmpty = this.penaltyMeterMovieClip._currentframe;
      }
   }
   function SetPenaltyPercent(aPercent)
   {
      if(this.penaltyMeterMovieClip === undefined)
      {
         return undefined;
      }
      this.CurrentPenaltyPercent = Math.min(100,Math.max(aPercent,0));
      this.TargetPenaltyPercent = this.CurrentPenaltyPercent;
      var _loc2_ = Math.floor(Shared.GlobalFunc.Lerp(this.Empty,this.Full,0,100,this.CurrentPenaltyPercent));
      this.penaltyMeterMovieClip.gotoAndStop(_loc2_);
   }
   function SetPenaltyTargetPercent(aPercent)
   {
      this.TargetPenaltyPercent = Math.min(100,Math.max(aPercent,0));
   }
   function UpdatePenalty()
   {
      if(this.penaltyMeterMovieClip === undefined)
      {
         return undefined;
      }
      var _loc3_;
      var _loc2_;
      if(this.TargetPenaltyPercent > 0 && this.TargetPenaltyPercent > this.CurrentPenaltyPercent)
      {
         if(this.TargetPenaltyPercent - this.CurrentPenaltyPercent > this.FillSpeed)
         {
            this.CurrentPenaltyPercent += this.FillSpeed;
            _loc3_ = Shared.GlobalFunc.Lerp(this.Empty,this.Full,0,100,this.CurrentPenaltyPercent);
            this.penaltyMeterMovieClip.gotoAndStop(_loc3_);
         }
         else
         {
            this.SetPenaltyPercent(this.TargetPenaltyPercent);
         }
      }
      else if(this.TargetPenaltyPercent <= this.CurrentPenaltyPercent)
      {
         _loc2_ = this.CurrentPenaltyPercent - this.TargetPenaltyPercent > this.EmptySpeed;
         if(this.TargetPenaltyPercent > 0 && _loc2_ || this.CurrentPenaltyPercent > this.EmptySpeed)
         {
            if(_loc2_)
            {
               this.CurrentPenaltyPercent -= this.EmptySpeed;
            }
            else
            {
               this.CurrentPenaltyPercent = this.TargetPenaltyPercent;
            }
            _loc3_ = Shared.GlobalFunc.Lerp(this.Empty,this.Full,0,100,this.CurrentPenaltyPercent);
            this.penaltyMeterMovieClip.gotoAndStop(_loc3_);
         }
         else if(this.CurrentPenaltyPercent >= 0)
         {
            this.SetPenaltyPercent(this.TargetPenaltyPercent);
         }
      }
   }
}
