class CCListEntry extends ListEntryBase
{
   var Price_mc;
   var _DataObj;
   var onEnterFrame;
   var _Price_mc = null;
   function CCListEntry()
   {
      super();
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function Init()
   {
      this.onEnterFrame = null;
      this._Price_mc = this.Price_mc;
   }
   function redrawUIComponent()
   {
      super.redrawUIComponent();
      if(this._DataObj != null && this._Price_mc != null)
      {
         this._Price_mc.UpdateCreditDisplay(this._DataObj.owned,this._DataObj.onSale,this._DataObj.price);
      }
   }
}
