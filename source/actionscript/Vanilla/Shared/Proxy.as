class Shared.Proxy
{
   function Proxy()
   {
   }
   static function create(oTarget, fFunction)
   {
      var aParameters = new Array();
      var _loc2_ = 2;
      while(_loc2_ < arguments.length)
      {
         aParameters[_loc2_ - 2] = arguments[_loc2_];
         _loc2_ = _loc2_ + 1;
      }
      var _loc4_ = function()
      {
         var _loc2_ = arguments.concat(aParameters);
         fFunction.apply(oTarget,_loc2_);
      };
      return _loc4_;
   }
}
