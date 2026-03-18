class WidgetOverlay.OverlayButtonBar extends gfx.controls.ButtonBar
{
   var CallbackFunction;
   var __set__dataProvider;
   var __set__itemRenderer;
   var addEventListener;
   var validateNow;
   static var BUTTON_DEFINITION_STRIDE = 2;
   function OverlayButtonBar()
   {
      super();
      this.itemRenderer = "OverlayButton";
      this.addEventListener("itemClick",this,"ButtonCallback");
   }
   function SetupButtons()
   {
      var _loc7_ = arguments.length / WidgetOverlay.OverlayButtonBar.BUTTON_DEFINITION_STRIDE;
      var _loc8_ = new Array(_loc7_);
      var _loc3_ = 0;
      var _loc4_;
      while(_loc3_ < _loc7_)
      {
         _loc4_ = {label:arguments[_loc3_ * WidgetOverlay.OverlayButtonBar.BUTTON_DEFINITION_STRIDE],data:arguments[_loc3_ * WidgetOverlay.OverlayButtonBar.BUTTON_DEFINITION_STRIDE + 1]};
         _loc8_[_loc3_] = _loc4_;
         _loc3_ = _loc3_ + 1;
      }
      this.dataProvider = _loc8_;
      this.validateNow();
   }
   function SetCallbackFunction(aOverlay, aWidget)
   {
      this.CallbackFunction = aOverlay.concat(".",aWidget);
   }
   function ButtonCallback(aEvent)
   {
      gfx.io.GameDelegate.call(this.CallbackFunction,[aEvent.index,aEvent.data]);
   }
}
