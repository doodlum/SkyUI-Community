class FilterDataExtender implements skyui.components.list.IListProcessor
{
	/* CONSTANTS */

	public static var FILTERFLAG_ALL = 15;
	public static var FILTERFLAG_DEFAULT = 1;
	public static var FILTERFLAG_GEAR = 2;
	public static var FILTERFLAG_AID = 4;
	public static var FILTERFLAG_MAGIC = 8;

	public static var FILTERFLAG_GROUP_ADD = 16;
	public static var FILTERFLAG_GROUP_0 = 32;
	// Group N+1 = (GROUP_N << 1) | GROUP_ADD


	/* PRIVATE VARIABLES */

	/* PROPERTIES */

	/* INITIALIZATION */

	public function FilterDataExtender()
	{
	}


	/* PUBLIC FUNCTIONS */

	// @override IListProcessor
	public function processList(a_list)
	{
		var entryList = a_list.entryList;
		var i = 0;
		var e;
		while (i < entryList.length)
		{
			e = entryList[i];
			if (!e.skyui_itemDataProcessed)
			{
				e.skyui_itemDataProcessed = true;
				this.processEntry(e);
			}
			i = i + 1;
		}
	}


	/* PRIVATE FUNCTIONS */

	private function processEntry(a_entryObject)
	{
		// ItemID
		a_entryObject.itemId &= 4294967295; // better safe than sorry

		var formType = a_entryObject.formType;
		switch (formType)
		{
			case skyui.defines.Form.TYPE_ARMOR:
			case skyui.defines.Form.TYPE_AMMO:
			case skyui.defines.Form.TYPE_WEAPON:
			case skyui.defines.Form.TYPE_LIGHT:
				a_entryObject.filterFlag = FilterDataExtender.FILTERFLAG_GEAR;
				return;
			case skyui.defines.Form.TYPE_INGREDIENT:
			case skyui.defines.Form.TYPE_POTION:
				a_entryObject.filterFlag = FilterDataExtender.FILTERFLAG_AID;
				return;
			case skyui.defines.Form.TYPE_SPELL:
			case skyui.defines.Form.TYPE_SHOUT:
			case skyui.defines.Form.TYPE_SCROLLITEM:
				a_entryObject.filterFlag = FilterDataExtender.FILTERFLAG_MAGIC;
				return;
			case skyui.defines.Form.TYPE_BOOK:
			case skyui.defines.Form.TYPE_EFFECTSETTING:
			default:
				// This is a default flag to make sure ALL includes everything
				a_entryObject.filterFlag = FilterDataExtender.FILTERFLAG_DEFAULT;
				return;
		}
	}
}
