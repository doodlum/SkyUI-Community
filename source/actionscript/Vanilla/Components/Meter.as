class Components.Meter
{
   var CurrentPercent;
   var Empty;
   var EmptySpeed;
   var FillSpeed;
   var Full;
   var TargetPercent;
   var meterMovieClip;
   function Meter(aMovieClip)
   {
      this.Empty = 0;
      this.Full = 0;
      this.CurrentPercent = 100;
      this.TargetPercent = 100;
      this.FillSpeed = 2;
      this.EmptySpeed = 3;
      this.meterMovieClip = aMovieClip;
      this.meterMovieClip.gotoAndStop("Empty");
      this.Empty = this.meterMovieClip._currentframe;
      this.meterMovieClip.gotoAndStop("Full");
      this.Full = this.meterMovieClip._currentframe;
   }
   function SetPercent(aPercent)
   {
      this.CurrentPercent = Math.min(100,Math.max(aPercent,0));
      this.TargetPercent = this.CurrentPercent;
      var _loc2_ = Math.floor(Shared.GlobalFunc.Lerp(this.Empty,this.Full,0,100,this.CurrentPercent));
      this.meterMovieClip.gotoAndStop(_loc2_);
   }
   function SetTargetPercent(aPercent)
   {
      this.TargetPercent = Math.min(100,Math.max(aPercent,0));
   }
   function SetFillSpeed(aSpeed)
   {
      this.FillSpeed = aSpeed;
   }
   function SetEmptySpeed(aSpeed)
   {
      this.EmptySpeed = aSpeed;
   }
   function Update()
   {
      var _loc3_;
      var _loc2_;
      if(this.TargetPercent > 0 && this.TargetPercent > this.CurrentPercent)
      {
         if(this.TargetPercent - this.CurrentPercent > this.FillSpeed)
         {
            this.CurrentPercent += this.FillSpeed;
            _loc3_ = Shared.GlobalFunc.Lerp(this.Empty,this.Full,0,100,this.CurrentPercent);
            this.meterMovieClip.gotoAndStop(_loc3_);
         }
         else
         {
            this.SetPercent(this.TargetPercent);
         }
      }
      else if(this.TargetPercent <= this.CurrentPercent)
      {
         _loc2_ = this.CurrentPercent - this.TargetPercent > this.EmptySpeed;
         if(this.TargetPercent > 0 && _loc2_ || this.CurrentPercent > this.EmptySpeed)
         {
            if(_loc2_)
            {
               this.CurrentPercent -= this.EmptySpeed;
            }
            else
            {
               this.CurrentPercent = this.TargetPercent;
            }
            _loc3_ = Shared.GlobalFunc.Lerp(this.Empty,this.Full,0,100,this.CurrentPercent);
            this.meterMovieClip.gotoAndStop(_loc3_);
         }
         else if(this.CurrentPercent >= 0)
         {
            this.SetPercent(this.TargetPercent);
         }
      }
   }
}
