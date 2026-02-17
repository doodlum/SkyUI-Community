class BarterDataSetter extends InventoryDataSetter
{
   var _barterBuyMult;
   var _barterSellMult;
   function BarterDataSetter(a_barterBuyMult, a_barterSellMult)
   {
      super();
      this._barterBuyMult = a_barterBuyMult != undefined ? a_barterBuyMult : 1;
      this._barterSellMult = a_barterSellMult != undefined ? a_barterSellMult : 1;
   }
   function processEntry(a_entryObject, a_itemInfo)
   {
      if(a_entryObject.filterFlag < 1024)
      {
         a_itemInfo.value *= this._barterSellMult;
      }
      else
      {
         a_itemInfo.value = Math.max(a_itemInfo.value * this._barterBuyMult,1);
      }
      a_itemInfo.value = Math.floor(a_itemInfo.value + 0.5);
      super.processEntry(a_entryObject,a_itemInfo);
   }
   function updateBarterMultipliers(a_barterBuyMult, a_barterSellMult)
   {
      this._barterBuyMult = a_barterBuyMult != undefined ? a_barterBuyMult : 1;
      this._barterSellMult = a_barterSellMult != undefined ? a_barterSellMult : 1;
   }
}
