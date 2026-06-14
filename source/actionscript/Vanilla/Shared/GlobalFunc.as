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

    /**
     * Injects the Anchor method into the MovieClip prototype.
     * This allows any MovieClip to be aligned relative to another clip.
     */
    static function AddAnchorFunction() {
        if (MovieClip.prototype.Anchor != undefined) return;
        if (Shared.GlobalFunc._deferCounter == undefined) Shared.GlobalFunc._deferCounter = 0;

        /**
         * Aligns the current MovieClip relative to a source MovieClip.
         * 
         * @param source            The reference MovieClip to align against.
         * @param targetAnchorType  Point on THIS clip (TL, TC, TR, CL, C, CR, BL, BC, BR).
         * @param sourceAnchorType  Point on SOURCE clip. If undefined, targetAnchorType is used for source, and target is mirrored.
         * @param offsetX           Additional horizontal offset.
         * @param offsetY           Additional vertical offset.
         * @param waitNextFrame     If true, delays calculation by one frame (useful for newly created UI).
         * @return                  Returns 'this' for method chaining.
         */
        MovieClip.prototype.Anchor = function(source:MovieClip, targetAnchorType:String, sourceAnchorType:String, offsetX:Number, offsetY:Number, waitNextFrame:Boolean) {
            if (!source) return this;
            
            if (sourceAnchorType == undefined) {
                sourceAnchorType = targetAnchorType;
                targetAnchorType = undefined;
            }
            
            var sAnchor:Number = Shared.GlobalFunc._parseAnchorString(sourceAnchorType);
            var tAnchor:Number = (targetAnchorType != undefined) 
                ? Shared.GlobalFunc._parseAnchorString(targetAnchorType) 
                : Shared.GlobalFunc._parseOppositeAnchor(sAnchor);
            
            // Defer execution by one frame to allow Scaleform components (like DialogManager) 
            // to finalize their internal layout and calculate accurate dimensions.
            if (waitNextFrame === true) {
                var target = this;
                var helperName = "__anchorHelper_" + (++Shared.GlobalFunc._deferCounter);
                var helper = target.createEmptyMovieClip(helperName, target.getNextHighestDepth());
                
                helper.onEnterFrame = function() {
                    delete this.onEnterFrame;
                    this.removeMovieClip();
                    Shared.GlobalFunc.Anchor(target, source, tAnchor, sAnchor, offsetX, offsetY);
                };
            } else {
                Shared.GlobalFunc.Anchor(this, source, tAnchor, sAnchor, offsetX, offsetY);
            }
            
            return this;
        };
    }

    /**
     * Core static logic for calculating and applying coordinates.
     * 
     * @param target        The MovieClip to be moved.
     * @param source        The reference MovieClip.
     * @param targetAnchor  Numeric ID (1-9) of the anchor point on the target.
     * @param sourceAnchor  Numeric ID (1-9) of the anchor point on the source.
     * @param offsetX       Horizontal translation.
     * @param offsetY       Vertical translation.
     */
    public static function Anchor(target:MovieClip, source:MovieClip, targetAnchor:Number, sourceAnchor:Number, offsetX:Number, offsetY:Number) {
        if (!target || !source) return;
        
        var destPt = Shared.GlobalFunc._getAnchorPointGlobal(source, sourceAnchor);
        if (!destPt || isNaN(destPt.x) || isNaN(destPt.y)) return;
        
        destPt.x += (offsetX != undefined ? offsetX : 0);
        destPt.y += (offsetY != undefined ? offsetY : 0);
        
        var targetPt = Shared.GlobalFunc._getAnchorPointLocal(target, targetAnchor);
        target.localToGlobal(targetPt);
        if (!targetPt || isNaN(targetPt.x) || isNaN(targetPt.y)) return;
        
        var parent = target._parent;
        if (parent) {
            parent.globalToLocal(destPt);
            parent.globalToLocal(targetPt);
        }
        
        target._x += (destPt.x - targetPt.x);
        target._y += (destPt.y - targetPt.y);
    }

    /**
     * Converts a string anchor code to a numeric Numpad-style ID (1-9).
     * 
     * @param anchorType    String code (e.g., "TL", "TC", "BR").
     * @return              Numeric ID (1=TL, 2=TC, 3=TR, 4=CL, 5=C, 6=CR, 7=BL, 8=BC, 9=BR).
     */
    private static function _parseAnchorString(anchorType:String) {
        var map = {TL:1, T:2, TC:2, TR:3, L:4, CL:4, C:5, CR:6, R:6, BL:7, B:8, BC:8, BR:9};
        var key = (anchorType && typeof anchorType == "string") ? anchorType.toUpperCase() : "C";
        return map[key] || 5;
    }

    /**
     * Calculates the vertically mirrored anchor point.
     * 
     * @param anchor    Original anchor numeric ID.
     * @return          Opposite anchor ID (e.g., Top becomes Bottom).
     */
    private static function _parseOppositeAnchor(anchor:Number) {
        var flip = [5, 7, 8, 9, 4, 5, 6, 1, 2, 3];
        return flip[anchor] || 5;
    }

    /**
     * Retrieves global stage coordinates for a specific anchor point on a clip.
     * 
     * @param clip      The MovieClip to inspect.
     * @param anchor    Anchor point numeric ID.
     * @return          Object with global {x, y}.
     */
    private static function _getAnchorPointGlobal(clip:MovieClip, anchor:Number) {
        var pt = Shared.GlobalFunc._getAnchorPointLocal(clip, anchor);
        clip.localToGlobal(pt); 
        return pt;
    }

    /**
     * Calculates local coordinates of an anchor point relative to the clip's visual bounds.
     * 
     * @param clip      The MovieClip to inspect.
     * @param anchor    Anchor point numeric ID (1-9).
     * @return          Object with local {x, y}.
     */
    private static function _getAnchorPointLocal(clip:MovieClip, anchor:Number) {
        var b = clip.getBounds(clip);
        var xMin:Number = b.xMin != undefined ? b.xMin : 0;
        var xMax:Number = b.xMax != undefined ? b.xMax : 0;
        var yMin:Number = b.yMin != undefined ? b.yMin : 0;
        var yMax:Number = b.yMax != undefined ? b.yMax : 0;
        
        // Protection against crooked anchors (return to center)
        anchor = (anchor > 0 && anchor < 10) ? anchor : 5; 
        
        var col = (anchor - 1) % 3;             // 0: Left, 1: Center, 2: Right
        var row = Math.floor((anchor - 1) / 3); // 0: Up,   1: Middle, 2: Down
        
        var x = (col == 0) ? xMin : (col == 2 ? xMax : (xMin + xMax) / 2);
        var y = (row == 0) ? yMin : (row == 2 ? yMax : (yMin + yMax) / 2);
        
        return {x: x, y: y};
    }
}
