class CustomConstructDataSetter implements skyui.components.list.IListProcessor
{
	/* INITIALIZATION */

	public function CustomConstructDataSetter()
	{
		super();
	}

	// @override IListProcessor
	public function processList(a_list)
	{
		var entryList = a_list.entryList;
		var i = 0;
		var e;
		while (i < entryList.length)
		{
			e = entryList[i];
			if (!(e.oldFilterFlag != undefined || e.filterFlag == 0))
			{
				e.oldFilterFlag = e.filterFlag;
				this.processEntry(e);
			}
			i = i + 1;
		}
	}


	/* PUBLIC FUNCTIONS */

	public function processEntry(a_entryObject)
	{
		// We can map these categories 1:1
		var bDone = false;
		switch (a_entryObject.oldFilterFlag)
		{
			case skyui.defines.Inventory.FILTERFLAG_CRAFT_JEWELRY:
				a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_JEWELRY;
				bDone = true;
				break;
			case skyui.defines.Inventory.FILTERFLAG_CRAFT_FOOD:
				a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_FOOD;
				bDone = true;
		}
		if (bDone)
		{
			return undefined;
		}
		switch (a_entryObject.formType)
		{
			case skyui.defines.Form.TYPE_ARMOR:
				a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_ARMOR;
				return;
			case skyui.defines.Form.TYPE_INGREDIENT:
				a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_FOOD;
				return;
			case skyui.defines.Form.TYPE_WEAPON:
				a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_WEAPONS;
				return;
			case skyui.defines.Form.TYPE_AMMO:
				a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_AMMO;
				return;
			case skyui.defines.Form.TYPE_POTION:
				a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_FOOD;
				return;
			default:
				a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_MISC;
				return;
		}
	}
}
