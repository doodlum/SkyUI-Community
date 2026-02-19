class QuantitySlider extends gfx.controls.Slider
{
   var __get__maximum;
   var __get__value;
   var __set__value;
   var dispatchEvent;
   function QuantitySlider()
   {
      super();
   }
   function handleInput(details, pathToFocus)
   {
      var _loc4_ = super.handleInput(details,pathToFocus);
      if(!_loc4_)
      {
         if(Shared.GlobalFunc.IsKeyPressed(details))
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.PAGE_DOWN || details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_L1)
            {
               this.value = Math.floor(this.value - this.maximum / 4);
               this.dispatchEvent({type:"change"});
               _loc4_ = true;
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.PAGE_UP || details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R1)
            {
               this.value = Math.ceil(this.value + this.maximum / 4);
               this.dispatchEvent({type:"change"});
               _loc4_ = true;
            }
         }
      }
      return _loc4_;
   }
}
