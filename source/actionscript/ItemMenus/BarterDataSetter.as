class BarterDataSetter extends InventoryDataSetter
{
  /* PRIVATE VARIABLES */

	private var _barterBuyMult;
	private var _barterSellMult;


  /* INITIALIZATION */

	public function BarterDataSetter(a_barterBuyMult, a_barterSellMult)
	{
		super();
		_barterBuyMult = a_barterBuyMult != undefined ? a_barterBuyMult : 1;
		_barterSellMult = a_barterSellMult != undefined ? a_barterSellMult : 1;
	}


  /* PUBLIC FUNCTIONS */

	// @override InventoryDataSetter
	public function processEntry(a_entryObject, a_itemInfo)
	{
		// Apply multipliers to itemInfo value, then process the entry
		if (a_entryObject.filterFlag < 1024) {
			a_itemInfo.value *= _barterSellMult;
		} else {
			a_itemInfo.value = Math.max(a_itemInfo.value * _barterBuyMult, 1);
		}
		a_itemInfo.value = Math.floor(a_itemInfo.value + 0.5);

		super.processEntry(a_entryObject, a_itemInfo);
	}

	public function updateBarterMultipliers(a_barterBuyMult, a_barterSellMult)
	{
		// Not used (yet/ever)
		// see BarterMenu.doTransaction
		_barterBuyMult = a_barterBuyMult != undefined ? a_barterBuyMult : 1;
		_barterSellMult = a_barterSellMult != undefined ? a_barterSellMult : 1;
	}
}
