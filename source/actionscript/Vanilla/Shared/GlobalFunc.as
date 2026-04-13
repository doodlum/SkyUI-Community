class Shared.GlobalFunc
{
   var _currentframe;
   var _name;
   var _parent;
   var _x;
   var _y;
   var getTextFormat;
   var gotoAndPlay;
   var gotoAndStop;
   var htmlText;
   var onEnterFrame;
   var setTextFormat;
   var text;
   static var RegisteredTextFields = new Object();
   static var RegisteredMovieClips = new Object();
   function GlobalFunc()
   {
   }
   static function Lerp(aTargetMin, aTargetMax, aSourceMin, aSourceMax, aSource, abClamp)
   {
      var _loc1_ = aTargetMin + (aSource - aSourceMin) / (aSourceMax - aSourceMin) * (aTargetMax - aTargetMin);
      if(abClamp)
      {
         _loc1_ = Math.min(Math.max(_loc1_,aTargetMin),aTargetMax);
      }
      return _loc1_;
   }
   static function IsKeyPressed(aInputInfo, abProcessKeyHeldDown)
   {
      if(abProcessKeyHeldDown == undefined)
      {
         abProcessKeyHeldDown = true;
      }
      return aInputInfo.value == "keyDown" || abProcessKeyHeldDown && aInputInfo.value == "keyHold";
   }
   static function RoundDecimal(aNumber, aPrecision)
   {
      var _loc1_ = Math.pow(10,aPrecision);
      return Math.round(_loc1_ * aNumber) / _loc1_;
   }
   static function MaintainTextFormat()
   {
      TextField.prototype.SetText = function(aText, abHTMLText)
      {
         if (aText == undefined || aText == "")
         {
            aText = " ";
         }
         var fmt;
         var letterSpacing;
         var kerning;
         if (abHTMLText)
         {
            fmt = this.getTextFormat();
            letterSpacing = fmt.letterSpacing;
            kerning = fmt.kerning;
            this.htmlText = aText;
            fmt = this.getTextFormat();
            fmt.letterSpacing = letterSpacing;
            fmt.kerning = kerning;
            this.setTextFormat(fmt);
         }
         else
         {
            fmt = this.getTextFormat();
            this.text = aText;
            this.setTextFormat(fmt);
         }

         /* ─── SkyUI Extension: Text overflow handling ─── */
         if (this.enableShrinkToFit || this.overflowMode == "ellipsis") {
            Shared.GlobalFunc.ApplyTextOverflow(this);
         }
      };
      /* ─── SkyUI Extension: Initialize custom properties ─── */
      if (TextField.prototype.enableShrinkToFit == undefined) {
         TextField.prototype.enableShrinkToFit = false;
         TextField.prototype.overflowMode = "none";
         TextField.prototype.maxHeightExpand = 0;
         TextField.prototype.minFontSize = 10;
      }
   }
   static function SetLockFunction()
   {
      MovieClip.prototype.Lock = function(aPosition)
      {
         var _loc4_ = {x:Stage.visibleRect.x + Stage.safeRect.x,y:Stage.visibleRect.y + Stage.safeRect.y};
         var _loc3_ = {x:Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x,y:Stage.visibleRect.y + Stage.visibleRect.height - Stage.safeRect.y};
         this._parent.globalToLocal(_loc4_);
         this._parent.globalToLocal(_loc3_);
         if(aPosition == "T" || aPosition == "TL" || aPosition == "TR")
         {
            this._y = _loc4_.y;
         }
         if(aPosition == "B" || aPosition == "BL" || aPosition == "BR")
         {
            this._y = _loc3_.y;
         }
         if(aPosition == "L" || aPosition == "TL" || aPosition == "BL")
         {
            this._x = _loc4_.x;
         }
         if(aPosition == "R" || aPosition == "TR" || aPosition == "BR")
         {
            this._x = _loc3_.x;
         }
      };
   }
   static function AddMovieExploreFunctions()
   {
      MovieClip.prototype.getMovieClips = function()
      {
         var _loc2_ = new Array();
         for(var _loc3_ in this)
         {
            if(this[_loc3_] instanceof MovieClip && this[_loc3_] != this)
            {
               _loc2_.push(this[_loc3_]);
            }
         }
         return _loc2_;
      };
      MovieClip.prototype.showMovieClips = function()
      {
         for(var _loc2_ in this)
         {
            if(this[_loc2_] instanceof MovieClip && this[_loc2_] != this)
            {
               trace(this[_loc2_]);
               this[_loc2_].showMovieClips();
            }
         }
      };
   }
   static function AddReverseFunctions()
   {
      MovieClip.prototype.PlayReverse = function()
      {
         if(this._currentframe > 1)
         {
            this.gotoAndStop(this._currentframe - 1);
            this.onEnterFrame = function()
            {
               if(this._currentframe > 1)
               {
                  this.gotoAndStop(this._currentframe - 1);
               }
               else
               {
                  delete this.onEnterFrame;
               }
            };
         }
         else
         {
            this.gotoAndStop(1);
         }
      };
      MovieClip.prototype.PlayForward = function(aFrameLabel)
      {
         delete this.onEnterFrame;
         this.gotoAndPlay(aFrameLabel);
      };
      MovieClip.prototype.PlayForward = function(aFrame)
      {
         delete this.onEnterFrame;
         this.gotoAndPlay(aFrame);
      };
   }
   static function GetTextField(aParentClip, aName)
   {
      if(Shared.GlobalFunc.RegisteredTextFields[aName + aParentClip._name] != undefined)
      {
         return Shared.GlobalFunc.RegisteredTextFields[aName + aParentClip._name];
      }
      trace(aName + " is not registered a TextField name.");
   }
   static function GetMovieClip(aParentClip, aName)
   {
      if(Shared.GlobalFunc.RegisteredMovieClips[aName + aParentClip._name] != undefined)
      {
         return Shared.GlobalFunc.RegisteredMovieClips[aName + aParentClip._name];
      }
      trace(aName + " is not registered a MovieClip name.");
   }
   static function AddRegisterTextFields()
   {
      TextField.prototype.RegisterTextField = function(aStartingClip)
      {
         if(Shared.GlobalFunc.RegisteredTextFields[this._name + aStartingClip._name] == undefined)
         {
            Shared.GlobalFunc.RegisteredTextFields[this._name + aStartingClip._name] = this;
         }
      };
   }
   static function RegisterTextFields(aStartingClip)
   {
      for(var _loc2_ in aStartingClip)
      {
         if(aStartingClip[_loc2_] instanceof TextField)
         {
            aStartingClip[_loc2_].RegisterTextField(aStartingClip);
         }
      }
   }
   static function RegisterAllTextFieldsInTimeline(aStartingClip)
   {
      var _loc2_ = 1;
      while(aStartingClip._totalFrames && _loc2_ <= aStartingClip._totalFrames)
      {
         aStartingClip.gotoAndStop(_loc2_);
         Shared.GlobalFunc.RegisterTextFields(aStartingClip);
         _loc2_ = _loc2_ + 1;
      }
   }
   static function AddRegisterMovieClips()
   {
      MovieClip.prototype.RegisterMovieClip = function(aStartingClip)
      {
         if(Shared.GlobalFunc.RegisteredMovieClips[this._name + aStartingClip._name] == undefined)
         {
            Shared.GlobalFunc.RegisteredMovieClips[this._name + aStartingClip._name] = this;
         }
      };
   }
   static function RegisterMovieClips(aStartingClip)
   {
      for(var _loc2_ in aStartingClip)
      {
         if(aStartingClip[_loc2_] instanceof MovieClip)
         {
            aStartingClip[_loc2_].RegisterMovieClip(aStartingClip);
         }
      }
   }
   static function RecursiveRegisterMovieClips(aStartingClip, aRootClip)
   {
      for(var _loc3_ in aStartingClip)
      {
         if(aStartingClip[_loc3_] instanceof MovieClip)
         {
            if(aStartingClip[_loc3_] != aStartingClip)
            {
               Shared.GlobalFunc.RecursiveRegisterMovieClips(aStartingClip[_loc3_],aRootClip);
            }
            aStartingClip[_loc3_].RegisterMovieClip(aRootClip);
         }
      }
   }
   static function RegisterAllMovieClipsInTimeline(aStartingClip)
   {
      var _loc2_ = 1;
      while(aStartingClip._totalFrames && _loc2_ <= aStartingClip._totalFrames)
      {
         aStartingClip.gotoAndStop(_loc2_);
         Shared.GlobalFunc.RegisterMovieClips(aStartingClip);
         _loc2_ = _loc2_ + 1;
      }
   }
   static function StringTrim(astrText)
   {
      var _loc2_ = 0;
      var _loc1_ = 0;
      var _loc5_ = astrText.length;
      var _loc3_;
      while(astrText.charAt(_loc2_) == " " || astrText.charAt(_loc2_) == "\n" || astrText.charAt(_loc2_) == "\r" || astrText.charAt(_loc2_) == "\t")
      {
         _loc2_ = _loc2_ + 1;
      }
      _loc3_ = astrText.substring(_loc2_);
      _loc1_ = _loc3_.length - 1;
      while(_loc3_.charAt(_loc1_) == " " || _loc3_.charAt(_loc1_) == "\n" || _loc3_.charAt(_loc1_) == "\r" || _loc3_.charAt(_loc1_) == "\t")
      {
         _loc1_ = _loc1_ - 1;
      }
      _loc3_ = _loc3_.substring(0,_loc1_ + 1);
      return _loc3_;
   }



   /* ─── SkyUI Extensions ─── */
   static function ApplyTextOverflow(tf:TextField) {
      if (tf.text == "" || tf.text == undefined) return;

      if (tf.origHeight == undefined) tf.origHeight = tf._height;
      tf._height = tf.origHeight;
      tf.textAutoSize = "none";
      tf.multiline = true;
      tf.wordWrap = true;

      if (tf.enableShrinkToFit) {
         var availableHeight:Number = tf.origHeight + tf.maxHeightExpand;
         tf._height = availableHeight;

         var fmt:TextFormat = tf.getTextFormat();
         var metrics:Object = fmt.getTextExtent(tf.text, tf._width);

         if (metrics.textFieldHeight > tf._height) {
            Shared.GlobalFunc._shrinkFontToFit(tf);
         }

         metrics = tf.getTextFormat().getTextExtent(tf.text, tf._width);
         var expansion:Number = Math.min(Math.max(metrics.textFieldHeight - tf.origHeight, 0), tf.maxHeightExpand);
         tf._height = tf.origHeight + expansion;
      }

      if (tf.overflowMode == "ellipsis" && tf.maxscroll > 1) {
         Shared.GlobalFunc._applyEllipsis(tf);
      }
   }
   
   private static function _shrinkFontToFit(tf:TextField) {
      if (tf.numLines == 0) return;
      var fmt:TextFormat = tf.getTextFormat();
      var minSize:Number = tf.minFontSize;
      var maxSize:Number = fmt.size;
      var bestSize:Number = minSize;

      while (minSize <= maxSize) {
         var mid:Number = Math.floor((minSize + maxSize) / 2);
         fmt.size = mid;
         tf.setTextFormat(fmt);

         // +4 (2 pixel gutter) = textFieldHeight
         if ((tf.textHeight + 4) < tf._height) {
            bestSize = mid;
            minSize = mid + 1;
         } else {
            maxSize = mid - 1;
         }
      }
      fmt.size = bestSize;
      tf.setTextFormat(fmt);
   }

   private static function _applyEllipsis(tf:TextField) {
      var original:String = tf.htmlText;
      var ellipsis:String = "...";
      var fmt:TextFormat = tf.getTextFormat();

      var left:Number = 0;
      var right:Number = original.length;
      var best:String = original;

      while (left <= right) {
         var mid:Number = Math.floor((left + right) / 2);
         var test:String = original.substr(0, mid) + ellipsis;

         tf.htmlText = test;
         tf.setTextFormat(fmt);

         if (tf.maxscroll == 1) {
            best = test;
            left = mid + 1;
         } else {
            right = mid - 1;
         }
      }

      tf.htmlText = best;
      tf.setTextFormat(fmt);
   }
}
