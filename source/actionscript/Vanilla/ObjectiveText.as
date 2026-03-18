class ObjectiveText extends MovieClip
{
   var MovieClipsA;
   static var ObjectiveLine_mc;
   static var ClipCount = 0;
   static var ArraySize = 0;
   function ObjectiveText()
   {
      super();
      this.MovieClipsA = new Array();
   }
   function UpdateObjectives(aObjectiveArrayA)
   {
      if(ObjectiveText.ArraySize > 0)
      {
         delete this.MovieClipsA.shift();
         this.DuplicateObjective(aObjectiveArrayA);
         this.MovieClipsA[2].gotoAndPlay("OutToPositionThreeNoPause");
         return true;
      }
      return false;
   }
   function DuplicateObjective(aObjectiveArrayA)
   {
      var _loc2_ = String(aObjectiveArrayA.shift());
      var _loc4_ = String(aObjectiveArrayA.shift());
      var _loc5_;
      var _loc6_;
      var _loc3_;
      if(_loc2_ != "undefined")
      {
         if(_loc4_.length > 0)
         {
            _loc6_ = new TextField();
            _loc6_.SetText(_loc4_);
            _loc5_ = _loc6_.text + ": " + _loc2_;
         }
         else
         {
            _loc5_ = _loc2_;
         }
         ObjectiveText.ObjectiveLine_mc = this._parent.ObjectiveLineInstance;
         _loc3_ = ObjectiveText.ObjectiveLine_mc.duplicateMovieClip("objective" + ObjectiveText.ClipCount++,this._parent.GetDepth());
         QuestNotification.AnimationCount = QuestNotification.AnimationCount + 1;
         _loc3_.ObjectiveTextFieldInstance.TextFieldInstance.SetText(_loc5_);
         this.MovieClipsA.push(_loc3_);
      }
      ObjectiveText.ArraySize--;
      if(ObjectiveText.ArraySize == 0)
      {
         QuestNotification.RestartAnimations();
      }
   }
   function ShowObjectives(aCount, aObjectiveArrayA)
   {
      if(aObjectiveArrayA.length > 0)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIObjectiveNew"]);
      }
      while(this.MovieClipsA.length)
      {
         delete this.MovieClipsA.shift();
      }
      var _loc3_ = Math.min(aObjectiveArrayA.length,Math.min(aCount,3));
      ObjectiveText.ArraySize = aCount;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_)
      {
         this.DuplicateObjective(aObjectiveArrayA);
         _loc2_ = _loc2_ + 1;
      }
      this.MovieClipsA[0].gotoAndPlay("OutToPositionOne");
      this.MovieClipsA[1].gotoAndPlay("OutToPositionTwo");
      this.MovieClipsA[2].gotoAndPlay("OutToPositionThree");
   }
}
