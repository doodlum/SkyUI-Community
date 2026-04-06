class AnimatedLetter extends MovieClip
{
   var onEnterFrame;
   var AnimationBase_mc:MovieClip;
   var QuestName:String;
   var QuestNameIndex:Number = 0;
   var CustomFormat:TextFormat;

   static var ScreenCenterOffset:Number = -94;
   static var SpaceWidth:Number = 15;
   static var LetterSpacing:Number = 3;

   var Letters:Array;
   var _cursorX:Number = 0;

   function AnimatedLetter()
   {
      super();
      Shared.GlobalFunc.MaintainTextFormat();
   }

   function ShowQuestUpdate(aQuestName:String, aQuestStatus:String)
   {
      this.QuestName = (aQuestName.length > 0 && aQuestStatus.length > 0)
         ? (aQuestStatus + ": " + aQuestName)
         : aQuestName;

      this.CustomFormat = this.AnimationBase_mc.Letter_mc.LetterTextInstance.getTextFormat();
      this.CustomFormat.letterSpacing = 0;
      this.CustomFormat.kerning = false;

      this.Letters = [];
      this.QuestNameIndex = 0;

      this.CreateLetters();
      this.CenterLetters();

      this.AnimationBase_mc.onEnterFrame = this.AnimationBase_mc.ShowLetter;
   }

   function CreateLetters()
   {
      var totalWidth:Number = 0;

      for (var i = 0; i < this.QuestName.length; i++)
      {
         var charStr:String = this.QuestName.charAt(i);

         if (charStr.charCodeAt(0) == 32)
         {
            totalWidth += AnimatedLetter.SpaceWidth;

            if (i < this.QuestName.length - 1)
               totalWidth += AnimatedLetter.LetterSpacing;

            this.Letters.push(null);
            continue;
         }

         var clip:MovieClip = this.AnimationBase_mc.duplicateMovieClip(
            "letter" + i,
            this._parent.getNextHighestDepth()
         );

         var tf:TextField = clip.Letter_mc.LetterTextInstance;

         tf.autoSize = "left";
         tf.text = charStr;
         tf.setTextFormat(this.CustomFormat);

         var w:Number = clip._width;

         totalWidth += w;

         if (i < this.QuestName.length - 1)
            totalWidth += AnimatedLetter.LetterSpacing;

         this.Letters.push(clip);
      }

      this._cursorX = -(totalWidth * 0.5) + AnimatedLetter.ScreenCenterOffset;
   }

   function CenterLetters()
   {
      var cursor:Number = this._cursorX;

      for (var i = 0; i < this.Letters.length; i++)
      {
         var clip:MovieClip = this.Letters[i];

         if (clip == null)
         {
            cursor += AnimatedLetter.SpaceWidth + AnimatedLetter.LetterSpacing;
            continue;
         }

         clip._x = cursor;

         cursor += clip._width + AnimatedLetter.LetterSpacing;
      }
   }

   function ShowLetter()
   {
      var i:Number = this.QuestNameIndex++;

      if (i < this.Letters.length)
      {
         var clip:MovieClip = this.Letters[i];

         if (clip == null)
            return;

         QuestNotification.AnimationCount++;
         clip.gotoAndPlay("StartAnim");
      }
      else
      {
         delete this.onEnterFrame;
      }
   }
}
