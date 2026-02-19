class skyui.util.ColorFunctions
{
   static var RAD_TO_DEG = 57.295779513082;
   static var DEG_TO_RAD = 0.017453292519943;
   static var TWO_PI = 6.2831853071796;
   static var SQRT_3_OVER_2 = 0.86602540378444;
   function ColorFunctions()
   {
   }
   static function hexToRgb(a_RRGGBB)
   {
      var _loc1_ = skyui.util.ColorFunctions.validHex(a_RRGGBB);
      return [_loc1_ >> 16 & 0xFF,_loc1_ >> 8 & 0xFF,_loc1_ & 0xFF];
   }
   static function hexToHsv(a_RRGGBB)
   {
      return skyui.util.ColorFunctions.rgbToHsv(skyui.util.ColorFunctions.hexToRgb(a_RRGGBB));
   }
   static function hexToHsl(a_RRGGBB)
   {
      return skyui.util.ColorFunctions.rgbToHsl(skyui.util.ColorFunctions.hexToRgb(a_RRGGBB));
   }
   static function hexToStr(a_RRGGBB, a_prefix)
   {
      var _loc2_ = a_RRGGBB.toString(16).toUpperCase();
      var _loc3_ = "";
      var _loc1_ = _loc2_.length;
      while(_loc1_ < 6)
      {
         _loc3_ += "0";
         _loc1_ = _loc1_ + 1;
      }
      _loc2_ = (!a_prefix ? "" : "0x") + _loc3_ + _loc2_;
      return _loc2_;
   }
   static function validHex(a_RRGGBB)
   {
      return skyui.util.ColorFunctions.clampValue(a_RRGGBB,0,16777215);
   }
   static function rgbToHex(a_RGB)
   {
      var _loc1_ = a_RGB;
      return _loc1_[0] << 16 ^ _loc1_[1] << 8 ^ _loc1_[2];
   }
   static function rgbToHsv(a_RGB)
   {
      var _loc6_ = skyui.util.ColorFunctions.clampValue(a_RGB[0],0,255) / 255;
      var _loc5_ = skyui.util.ColorFunctions.clampValue(a_RGB[1],0,255) / 255;
      var _loc3_ = skyui.util.ColorFunctions.clampValue(a_RGB[2],0,255) / 255;
      var _loc1_;
      var _loc4_;
      var _loc2_;
      var _loc8_ = Math.max(_loc6_,Math.max(_loc5_,_loc3_));
      var _loc10_ = Math.min(_loc6_,Math.min(_loc5_,_loc3_));
      var _loc7_ = _loc8_ - _loc10_;
      var _loc12_ = (2 * _loc6_ - _loc5_ - _loc3_) / 2;
      var _loc11_ = (_loc5_ - _loc3_) * skyui.util.ColorFunctions.SQRT_3_OVER_2;
      _loc1_ = Math.atan2(_loc11_,_loc12_);
      _loc2_ = _loc8_;
      _loc4_ = _loc7_ != 0 ? _loc7_ / _loc2_ : 0;
      if(_loc1_ < 0)
      {
         _loc1_ += skyui.util.ColorFunctions.TWO_PI;
      }
      _loc1_ *= skyui.util.ColorFunctions.RAD_TO_DEG;
      _loc4_ *= 100;
      _loc2_ *= 100;
      _loc1_ = Math.round(_loc1_);
      _loc4_ = Math.round(_loc4_);
      _loc2_ = Math.round(_loc2_);
      return [_loc1_,_loc4_,_loc2_];
   }
   static function rgbToHsb(a_RGB)
   {
      return skyui.util.ColorFunctions.rgbToHsv(a_RGB);
   }
   static function rgbToHsl(a_RGB)
   {
      var _loc6_ = skyui.util.ColorFunctions.clampValue(a_RGB[0],0,255) / 255;
      var _loc5_ = skyui.util.ColorFunctions.clampValue(a_RGB[1],0,255) / 255;
      var _loc3_ = skyui.util.ColorFunctions.clampValue(a_RGB[2],0,255) / 255;
      var _loc1_;
      var _loc4_;
      var _loc2_;
      var _loc8_ = Math.max(_loc6_,Math.max(_loc5_,_loc3_));
      var _loc9_ = Math.min(_loc6_,Math.min(_loc5_,_loc3_));
      var _loc7_ = _loc8_ - _loc9_;
      var _loc12_ = (2 * _loc6_ - _loc5_ - _loc3_) / 2;
      var _loc11_ = (_loc5_ - _loc3_) * skyui.util.ColorFunctions.SQRT_3_OVER_2;
      _loc1_ = Math.atan2(_loc11_,_loc12_);
      _loc2_ = (_loc8_ + _loc9_) / 2;
      _loc4_ = _loc7_ != 0 ? _loc7_ / (1 - Math.abs(2 * _loc2_ - 1)) : 0;
      if(_loc1_ < 0)
      {
         _loc1_ += skyui.util.ColorFunctions.TWO_PI;
      }
      _loc1_ *= skyui.util.ColorFunctions.RAD_TO_DEG;
      _loc4_ *= 100;
      _loc2_ *= 100;
      _loc1_ = Math.round(_loc1_);
      _loc4_ = Math.round(_loc4_);
      _loc2_ = Math.round(_loc2_);
      return [_loc1_,_loc4_,_loc2_];
   }
   static function hsvToRgb(a_HSV)
   {
      var _loc11_ = skyui.util.ColorFunctions.loopValue(a_HSV[0],360);
      var _loc9_ = skyui.util.ColorFunctions.clampValue(a_HSV[1],0,100) / 100;
      var _loc7_ = skyui.util.ColorFunctions.clampValue(a_HSV[2],0,100) / 100;
      var _loc2_;
      var _loc3_;
      var _loc1_;
      var _loc4_ = _loc7_ * _loc9_;
      var _loc8_ = _loc11_ / 60;
      var _loc10_ = Math.floor(_loc8_);
      var _loc5_ = _loc4_ * (1 - Math.abs(_loc8_ % 2 - 1));
      switch(_loc10_)
      {
         case 0:
            _loc2_ = _loc4_;
            _loc3_ = _loc5_;
            _loc1_ = 0;
            break;
         case 1:
            _loc2_ = _loc5_;
            _loc3_ = _loc4_;
            _loc1_ = 0;
            break;
         case 2:
            _loc2_ = 0;
            _loc3_ = _loc4_;
            _loc1_ = _loc5_;
            break;
         case 3:
            _loc2_ = 0;
            _loc3_ = _loc5_;
            _loc1_ = _loc4_;
            break;
         case 4:
            _loc2_ = _loc5_;
            _loc3_ = 0;
            _loc1_ = _loc4_;
            break;
         case 5:
            _loc2_ = _loc4_;
            _loc3_ = 0;
            _loc1_ = _loc5_;
            break;
         default:
            _loc2_ = 0;
            _loc3_ = 0;
            _loc1_ = 0;
      }
      var _loc6_ = _loc7_ - _loc4_;
      _loc2_ += _loc6_;
      _loc3_ += _loc6_;
      _loc1_ += _loc6_;
      _loc2_ *= 255;
      _loc3_ *= 255;
      _loc1_ *= 255;
      _loc2_ = Math.round(_loc2_);
      _loc3_ = Math.round(_loc3_);
      _loc1_ = Math.round(_loc1_);
      return [_loc2_,_loc3_,_loc1_];
   }
   static function hsvToHex(a_HSV)
   {
      return skyui.util.ColorFunctions.rgbToHex(skyui.util.ColorFunctions.hsvToRgb(a_HSV));
   }
   static function hsbToRgb(a_HSB)
   {
      return skyui.util.ColorFunctions.hsvToRgb(a_HSB);
   }
   static function hsbToHex(a_HSB)
   {
      return skyui.util.ColorFunctions.hsvToHex(a_HSB);
   }
   static function hslToRgb(a_HSL)
   {
      var _loc12_ = skyui.util.ColorFunctions.loopValue(a_HSL[0],360);
      var _loc9_ = skyui.util.ColorFunctions.clampValue(a_HSL[1],0,100) / 100;
      var _loc7_ = skyui.util.ColorFunctions.clampValue(a_HSL[2],0,100) / 100;
      var _loc2_;
      var _loc3_;
      var _loc1_;
      var _loc4_ = (1 - Math.abs(2 * _loc7_ - 1)) * _loc9_;
      var _loc8_ = _loc12_ / 60;
      var _loc10_ = Math.floor(_loc8_);
      var _loc5_ = _loc4_ * (1 - Math.abs(_loc8_ % 2 - 1));
      switch(_loc10_)
      {
         case 0:
            _loc2_ = _loc4_;
            _loc3_ = _loc5_;
            _loc1_ = 0;
            break;
         case 1:
            _loc2_ = _loc5_;
            _loc3_ = _loc4_;
            _loc1_ = 0;
            break;
         case 2:
            _loc2_ = 0;
            _loc3_ = _loc4_;
            _loc1_ = _loc5_;
            break;
         case 3:
            _loc2_ = 0;
            _loc3_ = _loc5_;
            _loc1_ = _loc4_;
            break;
         case 4:
            _loc2_ = _loc5_;
            _loc3_ = 0;
            _loc1_ = _loc4_;
            break;
         case 5:
            _loc2_ = _loc4_;
            _loc3_ = 0;
            _loc1_ = _loc5_;
            break;
         default:
            _loc2_ = 0;
            _loc3_ = 0;
            _loc1_ = 0;
      }
      var _loc6_ = _loc7_ - _loc4_ / 2;
      _loc2_ += _loc6_;
      _loc3_ += _loc6_;
      _loc1_ += _loc6_;
      _loc2_ *= 255;
      _loc3_ *= 255;
      _loc1_ *= 255;
      _loc2_ = Math.round(_loc2_);
      _loc3_ = Math.round(_loc3_);
      _loc1_ = Math.round(_loc1_);
      return [_loc2_,_loc3_,_loc1_];
   }
   static function hslToHex(a_HSL)
   {
      return skyui.util.ColorFunctions.rgbToHex(skyui.util.ColorFunctions.hslToRgb(a_HSL));
   }
   static function clampValue(a_val, a_min, a_max)
   {
      return Math.min(a_max,Math.max(a_min,a_val));
   }
   static function loopValue(a_val, a_max)
   {
      return a_val % a_max;
   }
}
