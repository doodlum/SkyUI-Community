class StreamingInstall extends MovieClip
{
   var EditByteProgress_mc;
   var EditPercentProgress_mc;
   var EditTitle_mc;
   var ProgressBarObject_mc;
   var ProgressBarWidthMax;
   var ProgressBar_mc;
   var TextContainer_mc;
   var TotalByteSize;
   var bFadedIn;
   function StreamingInstall()
   {
      super();
      this.bFadedIn = false;
      this.ProgressBarObject_mc = this._parent.ProgressBarObject_mc;
      this.ProgressBar_mc = this.ProgressBarObject_mc.ProgressBar_mc;
      this.ProgressBarWidthMax = this.ProgressBar_mc._width;
      this.TextContainer_mc = this._parent.TextContainer_mc;
      this.EditTitle_mc = this.TextContainer_mc.EditTitle_mc;
      this.EditByteProgress_mc = this.TextContainer_mc.EditByteProgress_mc;
      this.EditPercentProgress_mc = this.TextContainer_mc.EditPercentProgress_mc;
      this.EditTitle_mc.SetText("$StreamingInstallTitle");
      this.EditByteProgress_mc.text = "";
      this.EditPercentProgress_mc.text = "";
   }
   function InitExtensions()
   {
      Stage.scaleMode = "showAll";
      gfx.io.GameDelegate.addCallBack("SetPercent",this,"SetPercent");
   }
   function FadeInMenu()
   {
      if(!this.bFadedIn)
      {
         this._parent.gotoAndPlay("fadeIn");
         this.bFadedIn = true;
      }
   }
   function FadeOutMenu()
   {
      if(this.bFadedIn)
      {
         this._parent.gotoAndPlay("fadeOut");
         this.bFadedIn = false;
      }
   }
   function InitializeByteSizeProgress(aMaxBytes)
   {
      this.TotalByteSize = aMaxBytes;
   }
   function SetPercent(aPercent)
   {
      if(this.EditPercentProgress_mc != undefined)
      {
         aPercent = Math.max(0,Math.min(100,aPercent));
         this.EditPercentProgress_mc.text = aPercent + " %";
         this.SetProgressBar(aPercent);
         this.SetByteProgress(aPercent);
      }
      else
      {
         trace("PercentText component not found");
      }
   }
   function SetProgressBar(aPercent)
   {
      if(this.ProgressBar_mc != undefined)
      {
         this.ProgressBar_mc._width = this.ProgressBarWidthMax / 100 * aPercent;
      }
      else
      {
         trace("ProgressBar_mc component not found");
      }
   }
   function SetByteProgress(aPercent)
   {
      var _loc2_;
      var _loc3_;
      var _loc4_;
      if(this.EditByteProgress_mc != undefined)
      {
         _loc2_ = this.TotalByteSize / 100 * aPercent;
         _loc3_ = this.GetFileSizeString(_loc2_);
         _loc4_ = this.GetFileSizeString(this.TotalByteSize);
         this.EditByteProgress_mc.text = "( " + _loc3_ + " / " + _loc4_ + " )";
      }
      else
      {
         trace("EditByteProgress_mc component not found");
      }
   }
   function GetFileSizeString(size)
   {
      var _loc4_ = 0;
      var _loc3_;
      while(size >= 1024)
      {
         size /= 1024;
         _loc4_ += 3;
      }
      _loc3_ = this.toFixed(size,2);
      var _loc5_ = _loc3_.indexOf(".00");
      if(_loc5_ != -1 && _loc5_ >= _loc3_.length - 3)
      {
         _loc3_ = _loc3_.slice(0,_loc5_);
      }
      switch(_loc4_)
      {
         case 0:
            _loc3_ += " B";
            break;
         case 3:
            _loc3_ += " KB";
            break;
         case 6:
            _loc3_ += " MB";
            break;
         case 9:
            _loc3_ += " GB";
            break;
         default:
            _loc3_ += " ?B";
      }
      return _loc3_;
   }
   function toFixed(value, digits)
   {
      if(digits <= 0)
      {
         return String(Math.round(value));
      }
      var _loc4_ = Math.pow(10,digits);
      var _loc2_ = String(Math.round(value * _loc4_) / _loc4_);
      if(_loc2_.indexOf(".") == -1)
      {
         _loc2_ += ".0";
      }
      var _loc6_ = _loc2_.split(".");
      var _loc3_ = digits - _loc6_[1].length;
      var _loc1_ = 1;
      while(_loc1_ <= _loc3_)
      {
         _loc2_ += "0";
         _loc1_ = _loc1_ + 1;
      }
      return _loc2_;
   }
}
