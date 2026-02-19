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
   var length;
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
         if(aText == undefined || aText == "")
         {
            aText = " ";
         }
         var _loc2_ = this.getTextFormat();
         var _loc4_;
         var _loc5_;
         if(abHTMLText)
         {
            _loc4_ = _loc2_.letterSpacing;
            _loc5_ = _loc2_.kerning;
            this.htmlText = aText;
            _loc2_ = this.getTextFormat();
            _loc2_.letterSpacing = _loc4_;
            _loc2_.kerning = _loc5_;
            this.setTextFormat(_loc2_);
            return undefined;
         }
         this.text = aText;
         this.setTextFormat(_loc2_);
         return undefined;
      };
      _global.ASSetPropFlags(TextField.prototype,"SetText",1,0);
   }
   static function SetLockFunction()
   {
      MovieClip.prototype.Lock = function(aPosition)
      {
         var _loc3_ = {x:Stage.visibleRect.x + Stage.safeRect.x,y:Stage.visibleRect.y + Stage.safeRect.y};
         var _loc4_ = {x:Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x,y:Stage.visibleRect.y + Stage.visibleRect.height - Stage.safeRect.y};
         this._parent.globalToLocal(_loc3_);
         this._parent.globalToLocal(_loc4_);
         if(aPosition == "T" || aPosition == "TL" || aPosition == "TR")
         {
            this._y = _loc3_.y;
         }
         if(aPosition == "B" || aPosition == "BL" || aPosition == "BR")
         {
            this._y = _loc4_.y;
         }
         if(aPosition == "L" || aPosition == "TL" || aPosition == "BL")
         {
            this._x = _loc3_.x;
         }
         if(aPosition == "R" || aPosition == "TR" || aPosition == "BR")
         {
            this._x = _loc4_.x;
         }
      };
      _global.ASSetPropFlags(MovieClip.prototype,"Lock",1,0);
   }
   static function AddMovieExploreFunctions()
   {
      MovieClip.prototype.getMovieClips = function()
      {
         var _loc3_ = new Array();
         var _loc2_ = 0;
         while(_loc2_ < this.length)
         {
            if(this[_loc2_] instanceof MovieClip && this[_loc2_] != this)
            {
               _loc3_.push(this[_loc2_]);
            }
            _loc2_ = _loc2_ + 1;
         }
         return _loc3_;
      };
      MovieClip.prototype.showMovieClips = function()
      {
         var _loc2_ = 0;
         while(_loc2_ < this.length)
         {
            if(this[_loc2_] instanceof MovieClip && this[_loc2_] != this)
            {
               trace(this[_loc2_]);
               this[_loc2_].showMovieClips();
            }
            _loc2_ = _loc2_ + 1;
         }
      };
      _global.ASSetPropFlags(MovieClip.prototype,["getMovieClips","showMovieClips"],1,0);
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
                  return undefined;
               }
               delete this.onEnterFrame;
            };
            return undefined;
         }
         this.gotoAndStop(1);
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
      _global.ASSetPropFlags(MovieClip.prototype,["PlayReverse","PlayForward"],1,0);
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
      _global.ASSetPropFlags(TextField.prototype,"RegisterTextField",1,0);
   }
   static function RegisterTextFields(aStartingClip)
   {
      var _loc1_ = 0;
      while(_loc1_ < aStartingClip.length)
      {
         if(aStartingClip[_loc1_] instanceof TextField)
         {
            aStartingClip[_loc1_].RegisterTextField(aStartingClip);
         }
         _loc1_ = _loc1_ + 1;
      }
   }
   static function RegisterAllTextFieldsInTimeline(aStartingClip)
   {
      var _loc1_ = 1;
      while(aStartingClip._totalFrames && _loc1_ <= aStartingClip._totalFrames)
      {
         aStartingClip.gotoAndStop(_loc1_);
         Shared.GlobalFunc.RegisterTextFields(aStartingClip);
         _loc1_ = _loc1_ + 1;
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
      _global.ASSetPropFlags(MovieClip.prototype,"RegisterMovieClip",1,0);
   }
   static function RegisterMovieClips(aStartingClip)
   {
      var _loc1_ = 0;
      while(_loc1_ < aStartingClip.length)
      {
         if(aStartingClip[_loc1_] instanceof MovieClip)
         {
            aStartingClip[_loc1_].RegisterMovieClip(aStartingClip);
         }
         _loc1_ = _loc1_ + 1;
      }
   }
   static function RecursiveRegisterMovieClips(aStartingClip, aRootClip)
   {
      var _loc1_ = 0;
      while(_loc1_ < aStartingClip.length)
      {
         if(aStartingClip[_loc1_] instanceof MovieClip)
         {
            if(aStartingClip[_loc1_] != aStartingClip)
            {
               Shared.GlobalFunc.RecursiveRegisterMovieClips(aStartingClip[_loc1_],aRootClip);
            }
            aStartingClip[_loc1_].RegisterMovieClip(aRootClip);
         }
         _loc1_ = _loc1_ + 1;
      }
   }
   static function RegisterAllMovieClipsInTimeline(aStartingClip)
   {
      var _loc1_ = 0;
      while(aStartingClip._totalFrames && _loc1_ <= aStartingClip._totalFrames)
      {
         aStartingClip.gotoAndStop(_loc1_);
         Shared.GlobalFunc.RegisterMovieClips(aStartingClip);
         _loc1_ = _loc1_ + 1;
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
}
