class CCPurchaseDialog extends MovieClip
{
   var Credits_mc;
   var InputBuy_mc;
   var InputCancel_mc;
   var Name_tf;
   var _Item;
   var currentFrameLabel;
   var dispatchEvent;
   static var BUY_CLICKED = "BUY_CLICKED";
   static var CANCEL_CLICKED = "CANCEL_CLICKED";
   static var BUTTON_HOVER = "BUTTON_HOVER";
   var WillBuyOnAccept = true;
   function CCPurchaseDialog()
   {
      super();
      this.focusEnabled = true;
      gfx.events.EventDispatcher.initialize(this);
      this.InputBuy_mc.onRelease = Shared.Proxy.create(this,this.OnBuyClick);
      this.InputBuy_mc.onRollOver = Shared.Proxy.create(this,this.OnBuyHover);
      this.InputCancel_mc.onRelease = Shared.Proxy.create(this,this.OnCancelClick);
      this.InputCancel_mc.onRollOver = Shared.Proxy.create(this,this.OnCancelHover);
   }
   function get Item()
   {
      return this._Item;
   }
   function set Item(avalue)
   {
      this.Name_tf.SetText(avalue.text);
      this.Credits_mc.UpdateCreditDisplay(avalue);
      this._Item = avalue;
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      if(pathToFocus.length > 0)
      {
         _loc2_ = pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      if(!_loc2_ && Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.LEFT || details.code == 37)
         {
            if(this.currentFrameLabel != "BUY")
            {
               this.WillBuyOnAccept = true;
               this.gotoAndStop("BUY");
               this.currentFrameLabel = "BUY";
               this.dispatchEvent({type:CCPurchaseDialog.BUTTON_HOVER,target:this});
            }
            _loc2_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT || details.code == 39)
         {
            if(this.currentFrameLabel != "CANCEL")
            {
               this.WillBuyOnAccept = false;
               this.gotoAndStop("CANCEL");
               this.currentFrameLabel = "CANCEL";
               this.dispatchEvent({type:CCPurchaseDialog.BUTTON_HOVER,target:this});
            }
            _loc2_ = true;
         }
      }
      return _loc2_;
   }
   function OnBuyClick()
   {
      this.dispatchEvent({type:CCPurchaseDialog.BUY_CLICKED,target:this});
   }
   function OnBuyHover()
   {
      this.WillBuyOnAccept = true;
      this.gotoAndStop("BUY");
      this.currentFrameLabel = "BUY";
      this.dispatchEvent({type:CCPurchaseDialog.BUTTON_HOVER,target:this});
   }
   function OnCancelClick()
   {
      this.dispatchEvent({type:CCPurchaseDialog.CANCEL_CLICKED,target:this});
   }
   function OnCancelHover()
   {
      this.WillBuyOnAccept = false;
      this.gotoAndStop("CANCEL");
      this.currentFrameLabel = "CANCEL";
      this.dispatchEvent({type:CCPurchaseDialog.BUTTON_HOVER,target:this});
   }
}
