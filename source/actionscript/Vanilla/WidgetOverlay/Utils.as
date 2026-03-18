class WidgetOverlay.Utils
{
   static var TextureLoader = new MovieClipLoader();
   static var OverlayMap = new Object();
   function Utils()
   {
   }
   static function EmptyFunc()
   {
   }
   static function ShowOverlay(aOverlay, aX, aY, aWidth, aHeight)
   {
      var _loc2_ = WidgetOverlay.Utils.OverlayMap[aOverlay];
      var _loc3_;
      if(undefined == _loc2_)
      {
         _loc3_ = _root.attachMovie("Overlay",aOverlay,_root.getNextHighestDepth());
         _loc2_ = new WidgetOverlay.Overlay(_loc3_);
         WidgetOverlay.Utils.OverlayMap[aOverlay] = _loc2_;
      }
      _loc2_.SetPosition(aX,aY);
      _loc2_.SetDimensions(aWidth,aHeight);
   }
   static function HideOverlay(aOverlay)
   {
      _root[aOverlay].removeMovieClip();
      WidgetOverlay.Utils.OverlayMap[aOverlay] = undefined;
   }
   static function AddWidget(aOverlay, aWidget, aSymbol)
   {
      return WidgetOverlay.Utils.OverlayMap[aOverlay].AddWidget(aWidget,aSymbol);
   }
   static function RemoveWidget(aOverlay, aWidget)
   {
      WidgetOverlay.Utils.OverlayMap[aOverlay].RemoveWidget(aWidget);
   }
   static function SetTextFormatProp(aOverlay, aTextWidget, aProp, aValue)
   {
      var _loc3_ = _root[aOverlay][aTextWidget].TextFieldClip;
      var _loc2_ = _loc3_.getTextFormat();
      _loc2_[aProp] = aValue;
      _loc3_.setTextFormat(_loc2_);
      _loc3_.setNewTextFormat(_loc2_);
   }
   static function SetPosition(aOverlay, aWidget, aX, aY)
   {
      var _loc2_ = _root[aOverlay][aWidget];
      _loc2_._x = aX;
      _loc2_._y = aY;
   }
   static function SetOverlayFocus(aOverlay, abHasFocus)
   {
      var _loc1_ = WidgetOverlay.Utils.OverlayMap[aOverlay];
      if(undefined != _loc1_)
      {
         _loc1_.SetFocus(abHasFocus);
      }
   }
}
