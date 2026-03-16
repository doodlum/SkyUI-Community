class WideCreditCost extends CCCreditCost
{
   var Container_mc;
   var Price_mc;
   var SalePrice_mc;
   var Strike_mc;
   var _OnSale;
   var _StrikeThroughExtraWidth;
   function WideCreditCost()
   {
      super();
   }
   function OnTextChanged()
   {
      var _loc3_ = this.Container_mc._x;
      var _loc4_ = this.Container_mc._x + this.Container_mc._width;
      var _loc2_ = _loc4_ - _loc3_ - this.Price_mc._width;
      if(this._OnSale)
      {
         _loc2_ -= this.SalePrice_mc._width;
         this.Price_mc._x = _loc3_ + _loc2_ / 3;
         this.SalePrice_mc._x = this.Price_mc._x + this.Price_mc._width + _loc2_ / 3;
         this.Strike_mc._x = this.Price_mc._x - this._StrikeThroughExtraWidth;
         this.Strike_mc._width = this.Price_mc._width + this._StrikeThroughExtraWidth * 2;
      }
      else
      {
         this.Price_mc._x = _loc3_ + _loc2_ / 2;
      }
   }
}
