class skyui.util.Tween
{
   function Tween()
   {
   }
   static function LinearTween(a_obj, a_prop, a_start, a_end, a_duration, a_onFinish)
   {
      var _loc1_ = "__tween_" + a_prop + "__";
      var _loc3_;
      if(a_obj.hasOwnProperty(_loc1_))
      {
         _loc3_ = a_obj[_loc1_];
         if(_loc3_.isPlaying)
         {
            _loc3_.stop();
            false;
         }
      }
      var _loc5_ = a_obj[a_prop];
      var _loc4_ = Math.abs((a_end - _loc5_) / (a_end - a_start)) * a_duration;
      a_obj[_loc1_] = new mx.transitions.Tween(a_obj,a_prop,mx.transitions.easing.None.easeNone,_loc5_,a_end,_loc4_,true);
      if(a_onFinish)
      {
         a_obj[_loc1_].onMotionFinished = a_onFinish;
         if(_loc4_ <= 0)
         {
            a_onFinish();
         }
      }
      return a_obj[_loc1_];
   }
}
