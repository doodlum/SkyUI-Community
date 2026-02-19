class skyui.util.Debug
{
   static var _buffer = [];
   function Debug()
   {
   }
   static function log()
   {
      var _loc7_ = new Date();
      var _loc10_ = String(_loc7_.getHours());
      var _loc8_ = String(_loc7_.getMinutes());
      var _loc9_ = String(_loc7_.getSeconds());
      var _loc6_ = String(_loc7_.getMilliseconds());
      var _loc5_ = "[" + (_loc10_.length >= 2 ? _loc10_ : "0" + _loc10_);
      _loc5_ += ":" + (_loc8_.length >= 2 ? _loc8_ : "0" + _loc8_);
      _loc5_ += ":" + (_loc9_.length >= 2 ? _loc9_ : "0" + _loc9_);
      _loc5_ += "." + (_loc6_.length >= 2 ? (_loc6_.length >= 3 ? _loc6_ : "0" + _loc6_) : "00" + _loc6_);
      _loc5_ += "]";
      var _loc4_;
      if(_global.skse && skyui.util.Debug._buffer.length > 0)
      {
         _loc4_ = 0;
         while(_loc4_ < skyui.util.Debug._buffer.length)
         {
            skse.Log(skyui.util.Debug._buffer[_loc4_]);
            _loc4_ = _loc4_ + 1;
         }
         skyui.util.Debug._buffer.splice(0);
      }
      _loc4_ = 0;
      var _loc3_;
      while(_loc4_ < arguments.length)
      {
         _loc3_ = _loc5_ + " " + arguments[_loc4_];
         if(_global.skse)
         {
            skse.Log(_loc3_);
         }
         else if(_global.gfxPlayer)
         {
            trace(_loc3_);
         }
         else
         {
            skyui.util.Debug._buffer.push(_loc3_);
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   static function logNT()
   {
      var _loc4_;
      if(_global.skse && skyui.util.Debug._buffer.length > 0)
      {
         _loc4_ = 0;
         while(_loc4_ < skyui.util.Debug._buffer.length)
         {
            skse.Log(skyui.util.Debug._buffer[_loc4_]);
            _loc4_ = _loc4_ + 1;
         }
         skyui.util.Debug._buffer.splice(0);
      }
      _loc4_ = 0;
      var _loc3_;
      while(_loc4_ < arguments.length)
      {
         _loc3_ = arguments[_loc4_];
         if(_global.skse)
         {
            skse.Log(_loc3_);
         }
         else if(_global.gfxPlayer)
         {
            trace(_loc3_);
         }
         else
         {
            skyui.util.Debug._buffer.push(_loc3_);
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   static function dump(a_name, a_obj, a_noTimestamp, a_padLevel)
   {
      var _loc6_ = "";
      var _loc4_ = a_padLevel != undefined ? a_padLevel : 0;
      var _loc8_ = !a_noTimestamp ? skyui.util.Debug.log : skyui.util.Debug.logNT;
      var _loc3_ = 0;
      while(_loc3_ < _loc4_)
      {
         _loc6_ += "    ";
         _loc3_ = _loc3_ + 1;
      }
      var _loc1_;
      if(typeof a_obj == "object" || typeof a_obj == "function")
      {
         _loc8_(_loc6_ + a_name);
         for(var _loc7_ in a_obj)
         {
            skyui.util.Debug.dump(_loc7_,a_obj[_loc7_],a_noTimestamp,_loc4_ + 1);
         }
      }
      else if(typeof a_obj == "array")
      {
         _loc8_(_loc6_ + a_name);
         _loc1_ = 0;
         while(_loc1_ < a_obj.length)
         {
            skyui.util.Debug.dump(_loc1_,a_obj[_loc1_],a_noTimestamp,_loc4_ + 1);
            _loc1_ = _loc1_ + 1;
         }
      }
      else
      {
         _loc8_(_loc6_ + a_name + ": " + a_obj);
      }
   }
   static function prettyFormId(a_formId, a_prefix)
   {
      var _loc2_ = a_formId.toString(16).toUpperCase();
      var _loc3_ = "";
      var _loc1_ = _loc2_.length;
      while(_loc1_ < 8)
      {
         _loc3_ += "0";
         _loc1_ = _loc1_ + 1;
      }
      _loc2_ = (!a_prefix ? "" : "0x") + _loc3_ + _loc2_;
      return _loc2_;
   }
   static function getFunctionName(a_func)
   {
      var _loc2_ = skyui.util.Debug.getFunctionNameRecursive(a_func,_global);
      return _loc2_;
   }
   static function getFunctionNameRecursive(a_func, a_root)
   {
      var _loc4_ = a_func;
      var _loc2_ = a_root;
      if(!_loc2_)
      {
         return null;
      }
      var _loc3_;
      var _loc5_;
      for(var _loc8_ in _loc2_)
      {
         if(_loc2_[_loc8_] instanceof Function && _loc2_[_loc8_].prototype != null)
         {
            for(var _loc7_ in _loc2_[_loc8_])
            {
               if(_loc2_[_loc8_][_loc7_] == _loc4_)
               {
                  return _loc8_ + "." + _loc7_;
               }
            }
            _loc3_ = _loc2_[_loc8_].prototype;
            _loc5_ = new Array();
            for(_loc7_ in _loc3_)
            {
               _loc5_.push(_loc7_);
            }
            _global.ASSetPropFlags(_loc3_,null,0,1);
            for(_loc7_ in _loc3_)
            {
               if(_loc3_[_loc7_] == _loc4_)
               {
                  return _loc8_ + "." + _loc7_;
               }
            }
            _global.ASSetPropFlags(_loc3_,null,1,0);
            _global.ASSetPropFlags(_loc3_,_loc5_,0,1);
         }
      }
      var _loc6_;
      for(_loc8_ in _loc2_)
      {
         if(typeof _loc2_[_loc8_] == "object")
         {
            _loc6_ = skyui.util.Debug.getFunctionNameRecursive(_loc4_,_loc2_[_loc8_]);
            if(_loc6_)
            {
               return _loc8_ + "." + _loc6_;
            }
         }
      }
      return null;
   }
}
