class skyui.util.GlobalFunctions
{
   var length;
   static var _arrayExtended = false;
   function GlobalFunctions()
   {
   }
   static function extract(a_str, a_startChar, a_endChar)
   {
      return a_str.slice(a_str.indexOf(a_startChar) + 1,a_str.lastIndexOf(a_endChar));
   }
   static function clean(a_str)
   {
      if(a_str.indexOf(";") > 0)
      {
         a_str = a_str.slice(0,a_str.indexOf(";"));
      }
      var _loc3_ = 0;
      while(a_str.charAt(_loc3_) == " " || a_str.charAt(_loc3_) == "\t")
      {
         _loc3_ = _loc3_ + 1;
      }
      var _loc2_ = a_str.length - 1;
      while(a_str.charAt(_loc2_) == " " || a_str.charAt(_loc2_) == "\t")
      {
         _loc2_ = _loc2_ - 1;
      }
      return a_str.slice(_loc3_,_loc2_ + 1);
   }
   static function unescape(a_str)
   {
      a_str = a_str.split("\\n").join("\n");
      a_str = a_str.split("\\t").join("\t");
      return a_str;
   }
   static function addArrayFunctions()
   {
      if(skyui.util.GlobalFunctions._arrayExtended)
      {
         return undefined;
      }
      skyui.util.GlobalFunctions._arrayExtended = true;
      Array.prototype.indexOf = function(a_element)
      {
         var _loc2_ = 0;
         while(_loc2_ < this.length)
         {
            if(this[_loc2_] == a_element)
            {
               return _loc2_;
            }
            _loc2_ = _loc2_ + 1;
         }
         return undefined;
      };
      Array.prototype.equals = function(a)
      {
         if(a == undefined)
         {
            return false;
         }
         if(this.length != a.length)
         {
            return false;
         }
         var _loc2_ = 0;
         while(_loc2_ < a.length)
         {
            if(a[_loc2_] !== this[_loc2_])
            {
               return false;
            }
            _loc2_ = _loc2_ + 1;
         }
         return true;
      };
      Array.prototype.contains = function(a_element)
      {
         var _loc2_ = 0;
         while(_loc2_ < this.length)
         {
            if(this[_loc2_] == a_element)
            {
               return true;
            }
            _loc2_ = _loc2_ + 1;
         }
         return false;
      };
      _global.ASSetPropFlags(Array.prototype,["indexOf","equals","contains"],1,0);
   }
   static function mapUnicodeChar(a_charCode)
   {
      if(a_charCode == 8470)
      {
         return 185;
      }
      if(1025 <= a_charCode && a_charCode <= 1169)
      {
         switch(a_charCode)
         {
            case 1025:
               return 168;
            case 1028:
               return 170;
            case 1029:
               return 189;
            case 1030:
               return 178;
            case 1031:
               return 175;
            case 1032:
               return 163;
            case 1038:
               return 161;
            case 1105:
               return 184;
            case 1108:
               return 186;
            case 1109:
               return 190;
            case 1110:
               return 179;
            case 1111:
               return 191;
            case 1112:
               return 188;
            case 1118:
               return 162;
            case 1168:
               return 165;
            case 1169:
               return 164;
            default:
               if(1039 <= a_charCode && a_charCode <= 1103)
               {
                  return a_charCode - 848;
               }
         }
      }
      return a_charCode;
   }
   static function formatString(a_str)
   {
      if(arguments.length < 2)
      {
         return a_str;
      }
      var _loc12_ = "";
      var _loc8_ = 0;
      var _loc6_ = 1;
      var _loc7_;
      var _loc5_;
      var _loc4_;
      var _loc10_;
      var _loc2_;
      var _loc11_;
      var _loc9_;
      while(_loc6_ < arguments.length)
      {
         _loc7_ = a_str.indexOf("{",_loc8_);
         if(_loc7_ == -1)
         {
            return a_str;
         }
         _loc5_ = a_str.indexOf("}",_loc8_);
         if(_loc5_ == -1)
         {
            return a_str;
         }
         _loc12_ += a_str.slice(_loc8_,_loc7_);
         _loc4_ = Number(a_str.slice(_loc7_ + 1,_loc5_));
         _loc10_ = Math.pow(10,_loc4_);
         _loc2_ = (Math.round(arguments[_loc6_] * _loc10_) / _loc10_).toString();
         if(_loc4_ > 0)
         {
            if(_loc2_.indexOf(".") == -1)
            {
               _loc2_ += ".";
            }
            _loc11_ = _loc2_.split(".");
            _loc9_ = _loc11_[1].length;
            while(_loc9_++ < _loc4_)
            {
               _loc2_ += "0";
            }
         }
         _loc12_ += _loc2_;
         _loc8_ = _loc5_ + 1;
         _loc6_ = _loc6_ + 1;
      }
      _loc12_ += a_str.slice(_loc8_);
      return _loc12_;
   }
   static function formatNumber(a_number, a_decimal)
   {
      var _loc2_ = a_number.toString().toLowerCase();
      var _loc6_ = _loc2_.split("e",2);
      var _loc7_ = Math.pow(10,a_decimal);
      _loc2_ = String(Math.round(parseFloat(_loc6_[0]) * _loc7_) / _loc7_);
      var _loc5_;
      var _loc4_;
      var _loc1_;
      if(a_decimal > 0)
      {
         _loc5_ = _loc2_.indexOf(".");
         if(_loc5_ == -1)
         {
            _loc5_ = _loc2_.length;
            _loc2_ += ".";
         }
         _loc4_ = _loc2_.length - (_loc5_ + 1);
         _loc1_ = 0;
         while(_loc4_ + _loc1_ < a_decimal)
         {
            _loc2_ += "0";
            _loc1_ = _loc1_ + 1;
         }
      }
      if(_loc6_[1] != undefined)
      {
         _loc2_ += "E" + _loc6_[1];
      }
      return _loc2_;
   }
   static function getMappedKey(a_control, a_context, a_bGamepad)
   {
      if(_global.skse == undefined)
      {
         return -1;
      }
      if(a_bGamepad == true)
      {
         return skse.GetMappedKey(a_control,skyui.defines.Input.DEVICE_GAMEPAD,a_context);
      }
      var _loc2_ = skse.GetMappedKey(a_control,skyui.defines.Input.DEVICE_KEYBOARD,a_context);
      if(_loc2_ == -1)
      {
         _loc2_ = skse.GetMappedKey(a_control,skyui.defines.Input.DEVICE_MOUSE,a_context);
      }
      return _loc2_;
   }
   static function hookFunction(a_scope, a_memberFn, a_hookScope, a_hookFn)
   {
      var memberFn = a_scope[a_memberFn];
      if(memberFn == null || a_scope[a_memberFn] == null)
      {
         return false;
      }
      a_scope[a_memberFn] = function()
      {
         memberFn.apply(a_scope,arguments);
         a_hookScope[a_hookFn].apply(a_hookScope,arguments);
      };
      return true;
   }
   static function getDistance(a, b)
   {
      var _loc2_ = b._x - a._x;
      var _loc1_ = b._y - a._y;
      return Math.sqrt(_loc2_ * _loc2_ + _loc1_ * _loc1_);
   }
   static function getAngle(a, b)
   {
      var _loc2_ = b._x - a._x;
      var _loc1_ = b._y - a._y;
      return Math.atan2(_loc1_,_loc2_) * 57.29577951308232;
   }
}
