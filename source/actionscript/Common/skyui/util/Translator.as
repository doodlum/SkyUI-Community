class skyui.util.Translator
{
   static var _translator;
   function Translator()
   {
   }
   static function translate(a_str)
   {
      if(skyui.util.Translator._translator == undefined)
      {
         skyui.util.Translator._translator = _root.createTextField("_translator",_root.getNextHighestDepth(),0,0,1,1);
         skyui.util.Translator._translator._visible = false;
      }
      if(a_str == "")
      {
         return "";
      }
      if(a_str.charAt(0) != "$")
      {
         return a_str;
      }
      skyui.util.Translator._translator.text = a_str;
      return skyui.util.Translator._translator.text;
   }
   static function translateNested(a_str)
   {
      if(a_str == "")
      {
         return "";
      }
      if(a_str.indexOf("{") == -1)
      {
         return skyui.util.Translator.translate(a_str);
      }
      var _loc5_ = [];
      var _loc6_ = 0;
      var _loc1_;
      var _loc3_;
      var _loc7_;
      do
      {
         _loc1_ = a_str.indexOf("{",_loc6_);
         _loc3_ = a_str.indexOf("}",_loc6_);
         if(!(_loc1_ != -1 && _loc3_ != -1 && _loc1_ < _loc3_))
         {
            break;
         }
         _loc7_ = a_str.slice(_loc1_ + 1,_loc3_);
         _loc5_.push(skyui.util.Translator.translate(_loc7_));
         a_str = a_str.slice(0,_loc1_ + 1) + a_str.slice(_loc3_);
         _loc6_ = _loc1_ + 2;
      }
      while(true);
      
      a_str = skyui.util.Translator.translate(a_str);
      var _loc8_ = a_str.split("{}");
      var _loc9_ = "";
      var _loc4_;
      _loc4_ = 0;
      while(_loc4_ < _loc5_.length)
      {
         _loc9_ += _loc8_[_loc4_] + _loc5_[_loc4_];
         _loc4_ = _loc4_ + 1;
      }
      if(_loc4_ < _loc8_.length)
      {
         _loc9_ += _loc8_[_loc4_];
      }
      return _loc9_;
   }
}
