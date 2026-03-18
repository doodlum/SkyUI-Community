class AnimatedLetter extends MovieClip
{
   var AnimationBase_mc;
   var QuestName;
   var onEnterFrame;
   var LetterSpacing = 0;
   var OldWidth = 0;
   var QuestNameIndex = 0;
   var Start = 0;
   var EndPosition = 104;
   static var SpaceWidth = 15;
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
         this.Start += _loc3_ <= 0 ? AnimatedLetter.SpaceWidth : _loc3_;
         _loc2_ = _loc2_ + 1;
      }
      this.Start *= -0.5;
      this.Start -= this.EndPosition;
      this.QuestNameIndex = 0;
      this.LetterSpacing = 0;
      this.OldWidth = 0;
      this.AnimationBase_mc.onEnterFrame = this.AnimationBase_mc.ShowLetter;
   }
   function ShowLetter()
   {
      var _loc6_ = this.QuestName.length;
      var _loc4_ = this.QuestNameIndex++;
      var _loc5_;
      var _loc3_;
      var _loc2_;
      if(_loc4_ < _loc6_)
      {
         _loc5_ = this.QuestName.substr(_loc4_,1);
         _loc3_ = this.AnimationBase_mc.duplicateMovieClip("letter" + _loc4_,this._parent.getNextHighestDepth());
         QuestNotification.AnimationCount = QuestNotification.AnimationCount + 1;
         _loc3_.Letter_mc.LetterTextInstance.text = _loc5_;
         _loc2_ = _loc3_.Letter_mc.LetterTextInstance.getLineMetrics(0).width;
         if(_loc2_ == 0)
         {
            _loc2_ = AnimatedLetter.SpaceWidth;
         }
         else
         {
            _loc2_ -= 5;
         }
         _loc3_._x = this.Start + this.LetterSpacing + this.OldWidth / 2 + (_loc4_ < 0 ? 0 : _loc2_ / 2);
         this.LetterSpacing = _loc3_._x - this.Start;
         this.OldWidth = _loc2_;
         _loc3_.gotoAndPlay("StartAnim");
      }
      else
      {
         delete this.onEnterFrame;
      }
   }
}
