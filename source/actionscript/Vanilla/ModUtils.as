class ModUtils
{
   function ModUtils()
   {
   }
   static function GetFileSizeString(size)
   {
      var _loc3_ = 0;
      var _loc2_;
      while(size >= 1024)
      {
         size /= 1024;
         _loc3_ += 3;
      }
      _loc2_ = ModUtils.toFixed(size,2);
      var _loc4_ = _loc2_.indexOf(".00");
      if(_loc4_ != -1 && _loc4_ >= _loc2_.length - 3)
      {
         _loc2_ = _loc2_.slice(0,_loc4_);
      }
      switch(_loc3_)
      {
         case 0:
            _loc2_ += " B";
            break;
         case 3:
            _loc2_ += " KB";
            break;
         case 6:
            _loc2_ += " MB";
            break;
         case 9:
            _loc2_ += " GB";
            break;
         default:
            _loc2_ += " ?B";
      }
      return _loc2_;
   }
   static function toFixed(value, digits)
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
