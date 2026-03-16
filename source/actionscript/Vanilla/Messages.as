class Messages extends MovieClip
{
   var MessageArray;
   var ShownCount;
   var ShownMessageArray;
   var bAnimating;
   var onEnterFrame;
   var ySpacing;
   static var MAX_SHOWN = 4;
   static var Y_SPACING = 15;
   static var END_ANIM_FRAME = 80;
   static var InstanceCounter = 0;
   function Messages()
   {
      super();
      this.MessageArray = new Array();
      this.ShownMessageArray = new Array();
      this.ShownCount = 0;
      this.bAnimating = false;
   }
   function Update()
   {
      var bqueuedMessage = this.MessageArray.length > 0;
      if(bqueuedMessage && !this.bAnimating && this.ShownCount < Messages.MAX_SHOWN)
      {
         this.ShownMessageArray.push(this.attachMovie("MessageText","Text" + Messages.InstanceCounter++,this.getNextHighestDepth(),{_x:0,_y:0}));
         this.ShownMessageArray[this.ShownMessageArray.length - 1].TextFieldClip.tf1.html = true;
         this.ShownMessageArray[this.ShownMessageArray.length - 1].TextFieldClip.tf1.textAutoSize = "shrink";
         this.ShownMessageArray[this.ShownMessageArray.length - 1].TextFieldClip.tf1.htmlText = this.MessageArray.shift();
         this.bAnimating = true;
         this.ySpacing = 0;
         this.onEnterFrame = function()
         {
            var _loc2_;
            if(this.ySpacing < Messages.Y_SPACING)
            {
               _loc2_ = 0;
               while(_loc2_ < this.ShownMessageArray.length - 1)
               {
                  this.ShownMessageArray[_loc2_]._y += 2;
                  _loc2_ = _loc2_ + 1;
               }
               this.ySpacing = this.ySpacing + 1;
            }
            else
            {
               this.bAnimating = false;
               if(!bqueuedMessage || this.ShownCount == Messages.MAX_SHOWN)
               {
                  this.ShownMessageArray[0].gotoAndPlay("FadeOut");
               }
               delete this.onEnterFrame;
            }
         };
         this.ShownCount = this.ShownCount + 1;
      }
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < this.ShownMessageArray.length)
      {
         if(this.ShownMessageArray[_loc2_]._currentFrame >= Messages.END_ANIM_FRAME)
         {
            _loc3_ = this.ShownMessageArray.splice(_loc2_,1);
            _loc3_[0].removeMovieClip();
            this.ShownCount = this.ShownCount - 1;
            this.bAnimating = false;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(!bqueuedMessage && !this.bAnimating && this.ShownMessageArray.length > 0)
      {
         this.bAnimating = true;
         this.ShownMessageArray[0].gotoAndPlay("FadeOut");
      }
   }
}
