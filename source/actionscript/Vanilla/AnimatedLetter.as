class AnimatedLetter extends MovieClip
{
   var AnimationBase_mc;
   var QuestName;
   var onEnterFrame;
   static var SpaceWidth = 15;
   var QuestNameIndex = 0;
   var Start = 0;
   var LetterSpacing = 0;
   var OldWidth = 0;
   var EndPosition = 104;
   function AnimatedLetter()
   {
      super();
      Shared.GlobalFunc.MaintainTextFormat();
   }
   function ShowQuestUpdate(aQuestName, aQuestStatus)
   {
      var _loc4_;
      if(aQuestName.length > 0 && aQuestStatus.length > 0)
      {
         _loc4_ = new TextField();
         _loc4_.text = aQuestStatus + ": ";
         this.QuestName = _loc4_.text + aQuestName;
      }
      else
      {
         this.QuestName = aQuestName;
      }
      this.Start = 0;
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < this.QuestName.length)
      {
         this.AnimationBase_mc.Letter_mc.LetterTextInstance.SetText(this.QuestName.substr(_loc2_,1));
         _loc3_ = this.AnimationBase_mc.Letter_mc.LetterTextInstance.getLineMetrics(0).width - 5;
         this.Start += _loc3_ > 0 ? _loc3_ : AnimatedLetter.SpaceWidth;
         _loc2_ = _loc2_ + 1;
      }
      this.Start *= -0.5;
      this.Start -= Math.round(this.EndPosition * HUDMenu.scl_fAnimatedLetters);
      this.QuestNameIndex = 0;
      this.LetterSpacing = 0;
      this.OldWidth = 0;
      this.AnimationBase_mc.onEnterFrame = this.AnimationBase_mc.ShowLetter;
   }
   function ShowLetter()
   {
      var _loc6_ = this.QuestName.length;
      var _loc5_ = this.QuestNameIndex++;
      var _loc3_;
      var _loc4_;
      var _loc2_;
      if(_loc5_ < _loc6_)
      {
         _loc3_ = this.QuestName.substr(_loc5_,1);
         _loc4_ = this.AnimationBase_mc.duplicateMovieClip("letter" + _loc5_,this._parent.getNextHighestDepth());
         QuestNotification.AnimationCount = QuestNotification.AnimationCount + 1;
         _loc4_.Letter_mc.LetterTextInstance.text = _loc3_;
         _loc2_ = _loc4_.Letter_mc.LetterTextInstance.getLineMetrics(0).width;
         if(_loc2_ == 0)
         {
            _loc2_ = AnimatedLetter.SpaceWidth;
         }
         else if(_loc3_ == "M" || _loc3_ == "W")
         {
            _loc2_ -= 10;
         }
         else if(_loc3_ == "G" || _loc3_ == "O" || _loc3_ == "Q")
         {
            _loc2_ -= 8;
         }
         else if(_loc3_ == "A" || _loc3_ == "U")
         {
            _loc2_ -= 6;
         }
         else if(_loc3_ == "L")
         {
            _loc2_ -= 3;
         }
         else if(_loc3_ == "T")
         {
            _loc2_ -= 1;
         }
         else if(_loc3_ == "I" || _loc3_ == "J")
         {
            _loc2_ += 1;
         }
         else
         {
            _loc2_ -= 5;
         }
         _loc4_._x = this.Start + this.LetterSpacing + this.OldWidth / 2 + (_loc5_ >= 0 ? _loc2_ / 2 : 0);
         this.LetterSpacing = _loc4_._x - this.Start;
         this.OldWidth = _loc2_;
         _loc4_.gotoAndPlay("StartAnim");
         return undefined;
      }
      delete this.onEnterFrame;
   }
}
