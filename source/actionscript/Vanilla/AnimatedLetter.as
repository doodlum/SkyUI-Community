class AnimatedLetter extends MovieClip
{
   var AnimationBase_mc;
   var QuestName;
   var onEnterFrame;
   var QuestNameIndex:Number = 0;
   var CustomFormat:TextFormat;

   var EndPosition:Number = 0;
   static var LetterSpacing:Number = 2;
   static var SpaceWidth:Number = 40;
   var _cursorX:Number = 0;

   function AnimatedLetter()
   {
      super();
      Shared.GlobalFunc.MaintainTextFormat();
   }
   function ShowQuestUpdate(aQuestName, aQuestStatus)
   {
      this.QuestName = (aQuestName.length > 0 && aQuestStatus.length > 0)
         ? (aQuestStatus + ": " + aQuestName)
         : aQuestName;

      this.CustomFormat = this.AnimationBase_mc.Letter_mc.LetterTextInstance.getTextFormat();
      this.CustomFormat.letterSpacing = 0;
      this.CustomFormat.kerning = false;

      var totalWidth:Number = 0;
      for (var i = 0; i < this.QuestName.length; i++)
      {
         var ch:String = this.QuestName.charAt(i);
         var isSpace:Boolean = ch.charCodeAt(0) == 32;
         var metrics:Object = this.CustomFormat.getTextExtent(ch);
         var w:Number = isSpace ? AnimatedLetter.SpaceWidth : metrics.width; 
         
         totalWidth += w;
         if (i < this.QuestName.length - 1) totalWidth += AnimatedLetter.LetterSpacing;
      }

      this._cursorX = -(totalWidth * 0.5) - this.EndPosition;

      this.QuestNameIndex = 0;
      this.AnimationBase_mc.onEnterFrame = this.AnimationBase_mc.ShowLetter;
   }
   function ShowLetter()
   {
      var i = this.QuestNameIndex++;
      if (i < this.QuestName.length)
      {
         var charStr:String = this.QuestName.charAt(i);
         var clip = this.AnimationBase_mc.duplicateMovieClip("letter" + i, this._parent.getNextHighestDepth());

         QuestNotification.AnimationCount++;

         var tf = clip.Letter_mc.LetterTextInstance;
         tf.autoSize = "left";
         tf.text = charStr;
         tf.setTextFormat(this.CustomFormat);

         tf._x = 0;

         var bounds:Object = tf.getCharBoundaries(0);
         var inkW:Number = bounds ? bounds.width : tf._width;
         var inkH:Number = bounds ? bounds.height : tf._height;

         clip._x = this._cursorX;

         var clipW:Number = clip._width;
         this._cursorX += clipW + AnimatedLetter.LetterSpacing;

         clip.gotoAndPlay("StartAnim");
      }
      else
      {
         delete this.onEnterFrame;
      }
   }
}
