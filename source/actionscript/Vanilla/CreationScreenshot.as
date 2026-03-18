class CreationScreenshot extends CarouselButton
{
   var Name_tf;
   var Price_mc;
   var SaleBanner_mc;
   var TextMask_mc;
   var _visible;
   var onEnterFrame;
   var StopUpdating = false;
   var eLanguage = "en";
   function CreationScreenshot()
   {
      super();
      this.Name_tf.autoSize = "center";
      this.onEnterFrame = null;
   }
   function get Item()
   {
      return super.Item;
   }
   function set Item(avalue)
   {
      super.Item = avalue;
      var _loc3_;
      if(this.Item != null)
      {
         this.Name_tf.text = this.Item.text;
         this.AlignTextToVisibleArea();
         this.Price_mc.eLanguage = this.eLanguage;
         this.Price_mc.UpdateCreditDisplay(this.Item);
         this._visible = true;
         this.SaleBanner_mc._visible = this.Item.onSale;
         if(this.Item.onSale)
         {
            _loc3_ = Math.round((1 - this.Item.price / this.Item.normalPrice) * 100);
            this.SaleBanner_mc.Discount_tf.text = "$OFF";
            this.SaleBanner_mc.Discount_tf.text = _loc3_ + "% " + this.SaleBanner_mc.Discount_tf.text;
         }
      }
   }
   function StartUpdatingTextAlignment()
   {
      if(this.onEnterFrame == null)
      {
         this.onEnterFrame = Shared.Proxy.create(this,this.OnAnimUpdate);
      }
   }
   function OnAnimUpdate()
   {
      this.AlignTextToVisibleArea();
      if(this.StopUpdating)
      {
         this.onEnterFrame = null;
         this.StopUpdating = false;
      }
   }
   function AlignTextToVisibleArea()
   {
      if(this.Name_tf._width <= this.TextMask_mc._width)
      {
         this.Name_tf._x = this.TextMask_mc._x + (this.TextMask_mc._width - this.Name_tf._width) / 2;
      }
      else
      {
         this.Name_tf._x = this.TextMask_mc._x;
      }
   }
}
