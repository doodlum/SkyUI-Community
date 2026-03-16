class CCCreditCost extends MovieClip
{
   var Container_mc;
   var Owned_mc;
   var Price_mc;
   var Price_tf;
   var SalePrice_mc;
   var SalePrice_tf;
   var Strike_mc;
   var _OnSale;
   var _StrikeThroughExtraWidth = 4;
   var eLanguage = "en";
   function CCCreditCost()
   {
      super();
      this.Price_tf = this.Price_mc.Price_tf;
      this.SalePrice_tf = this.SalePrice_mc.Price_tf;
   }
   function UpdateCreditDisplay(avalue)
   {
      this._OnSale = avalue.onSale;
      if(this.SupportsPurchase())
      {
         this.Price_mc._visible = !avalue.owned;
         this.SalePrice_mc._visible = !avalue.owned && avalue.onSale;
         this.Strike_mc._visible = !avalue.owned && avalue.onSale;
      }
      else
      {
         this.Price_mc._visible = false;
         this.SalePrice_mc._visible = false;
         this.Strike_mc._visible = false;
      }
      this.Owned_mc._visible = avalue.owned;
      this.Price_tf.autoSize = "left";
      this.SalePrice_tf.autoSize = "left";
      this.Price_tf.text = avalue.normalPrice + "";
      this.SalePrice_tf.text = avalue.price + "";
      this.OnTextChanged();
   }
   function OnTextChanged()
   {
      var _loc2_ = this.Container_mc._x;
      var _loc4_ = this.Container_mc._x + this.Container_mc._width;
      var _loc3_ = _loc4_ - _loc2_;
      if(this._OnSale)
      {
         this.Price_mc._x = _loc2_ + (_loc3_ - this.Price_mc._width) / 2;
         this.SalePrice_mc._x = _loc2_ + (_loc3_ - this.SalePrice_mc._width) / 2;
         this.Strike_mc._x = this.Price_mc._x - this._StrikeThroughExtraWidth;
         this.Strike_mc._width = this.Price_mc._width + this._StrikeThroughExtraWidth * 2;
      }
      else
      {
         this.Price_mc._x = _loc2_ + (_loc3_ - this.Price_mc._width) / 2;
      }
   }
   function SupportsPurchase()
   {
      if(this.eLanguage == "DD")
      {
         return false;
      }
      if(this.eLanguage == "ja")
      {
         return false;
      }
      if(this.eLanguage == "zhhant")
      {
         return false;
      }
      return true;
   }
}
