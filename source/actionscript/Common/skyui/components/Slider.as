class skyui.components.Slider extends gfx.controls.Slider
{
   var __get__maximum;
   var __get__minimum;
   var _disabled;
   var _rotation;
   var _snapInterval;
   var constraints;
   var dispatchEventAndSound;
   var leftArrow;
   var offsetLeft;
   var offsetRight;
   var rightArrow;
   var thumb;
   var track;
   var value;
   function Slider()
   {
      super();
   }
   function get disabled()
   {
      return super.disabled;
   }
   function set disabled(a_val)
   {
      this.leftArrow.disabled = this._disabled;
      this.rightArrow.disabled = this._disabled;
      super.disabled = a_val;
   }
   function handleInput(details, pathToFocus)
   {
      if(super.handleInput(details,pathToFocus))
      {
         return true;
      }
      if(details.value == "keyDown" || details.value == "keyHold")
      {
         switch(details.navEquivalent)
         {
            case gfx.ui.NavigationCode.PAGE_DOWN:
            case gfx.ui.NavigationCode.GAMEPAD_L1:
               this.value -= Math.abs(this.maximum - this.minimum) / 10;
               this.dispatchEventAndSound({type:"change"});
               return true;
            case gfx.ui.NavigationCode.PAGE_UP:
            case gfx.ui.NavigationCode.GAMEPAD_R1:
               this.value += Math.abs(this.maximum - this.minimum) / 10;
               this.dispatchEventAndSound({type:"change"});
               return true;
         }
      }
      return false;
   }
   function configUI()
   {
      super.configUI();
      this.leftArrow.addEventListener("click",this,"scrollLeft");
      this.rightArrow.addEventListener("click",this,"scrollRight");
      this.leftArrow.autoRepeat = this.rightArrow.autoRepeat = true;
      this.leftArrow.focusTarget = this.rightArrow.focusTarget = this;
      var _loc3_ = this._rotation;
      this._rotation = 0;
      this.constraints.addElement(this.rightArrow,gfx.utils.Constraints.RIGHT);
      this.constraints.addElement(this.track,gfx.utils.Constraints.LEFT | gfx.utils.Constraints.RIGHT);
      this._rotation = _loc3_;
      this.offsetLeft = this.leftArrow._width + this.thumb._width / 2;
      this.offsetRight = this.rightArrow._width + this.thumb._width / 2;
   }
   function scrollLeft(event)
   {
      this.value -= this._snapInterval;
      this.dispatchEventAndSound({type:"change"});
   }
   function scrollRight(event)
   {
      this.value += this._snapInterval;
      this.dispatchEventAndSound({type:"change"});
   }
}
