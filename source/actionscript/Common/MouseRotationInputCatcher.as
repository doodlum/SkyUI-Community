class MouseRotationInputCatcher extends MovieClip
{
   var iProcessRotationDelayTimerID;
   static var PROCESS_ROTATION_DELAY = 150;
   function MouseRotationInputCatcher()
   {
      super();
   }
   function onMouseDown()
   {
      var _loc2_ = Mouse.getTopMostEntity() == this;
      if(_loc2_ || this._parent.bFadedIn == false)
      {
         this._parent.onMouseRotationStart();
      }
      if(_loc2_ && this.iProcessRotationDelayTimerID == undefined)
      {
         this.iProcessRotationDelayTimerID = setInterval(this,"onProcessDelayElapsed",MouseRotationInputCatcher.PROCESS_ROTATION_DELAY);
      }
   }
   function onProcessDelayElapsed()
   {
      clearInterval(this.iProcessRotationDelayTimerID);
      this.iProcessRotationDelayTimerID = undefined;
   }
   function onMouseUp()
   {
      this._parent.onMouseRotationStop();
      clearInterval(this.iProcessRotationDelayTimerID);
      if(this.iProcessRotationDelayTimerID != undefined && this._parent.bFadedIn != false)
      {
         this._parent.onMouseRotationFastClick(0);
      }
      this.iProcessRotationDelayTimerID = undefined;
   }
   function onPressAux()
   {
      this._parent.onMouseRotationFastClick(1);
   }
}
