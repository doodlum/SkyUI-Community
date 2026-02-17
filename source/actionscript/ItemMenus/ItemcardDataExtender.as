// @abstract
class ItemcardDataExtender implements skyui.components.list.IListProcessor
{
  /* PRIVATE VARIABLES */

	private var _itemInfo;
	private var _requestItemInfo;


  /* INITIALIZATION */

	public function ItemcardDataExtender()
	{
		_requestItemInfo = function(a_target, a_index)
		{
			var oldIndex = this._selectedIndex;
			this._selectedIndex = a_index;
			gfx.io.GameDelegate.call("RequestItemCardInfo", [], a_target, "updateItemInfo");
			this._selectedIndex = oldIndex;
		};
	}


  /* PUBLIC FUNCTIONS */

	public function updateItemInfo(a_updateObj)
	{
		_itemInfo = a_updateObj;
	}

	// @override IListProcessor
	public function processList(a_list)
	{
		var entryList = a_list.entryList;

		var i = 0;
		var e;
		while (i < entryList.length) {
			e = entryList[i];
			if (!(e.skyui_itemDataProcessed || e.filterFlag == 0)) {
				e.skyui_itemDataProcessed = true;

				// Fix wrong property names
				fixSKSEExtendedObject(e);

				// Hack to retrieve itemcard info
				_requestItemInfo.apply(a_list, [this, i]);
				processEntry(e, _itemInfo);
			}
			i = i + 1;
		}
	}


  /* PRIVATE FUNCTIONS */

	// @abstract
	private function processEntry(a_entryObject, a_itemInfo)
	{
	}

	private function fixSKSEExtendedObject(a_extendedObject)
	{
		if (a_extendedObject.formType == undefined)
			return;

		var oldBookType;
		switch (a_extendedObject.formType)
		{
			case skyui.defines.Form.TYPE_SPELL:
			case skyui.defines.Form.TYPE_SCROLLITEM:
			case skyui.defines.Form.TYPE_INGREDIENT:
			case skyui.defines.Form.TYPE_POTION:
			case skyui.defines.Form.TYPE_EFFECTSETTING:

				// school is sent as subType
				if (a_extendedObject.school == undefined && a_extendedObject.subType != undefined) {
					a_extendedObject.school = a_extendedObject.subType;
					delete a_extendedObject.subType;
				}

				// resistance is sent as magicType
				if (a_extendedObject.resistance == undefined && a_extendedObject.magicType != undefined) {
					a_extendedObject.resistance = a_extendedObject.magicType;
					delete a_extendedObject.magicType;
				}
				break;

			case skyui.defines.Form.TYPE_WEAPON:
				// weaponType is sent as subType
				if (a_extendedObject.weaponType == undefined && a_extendedObject.subType != undefined) {
					a_extendedObject.weaponType = a_extendedObject.subType;
					delete a_extendedObject.subType;
				}
				break;

			case skyui.defines.Form.TYPE_BOOK:
				// (SKSE < 1.6.6) flags and bookType (and some padding) are sent as one UInt32 bookType
				if (a_extendedObject.flags == undefined && a_extendedObject.bookType != undefined) {
					oldBookType = a_extendedObject.bookType;
					a_extendedObject.bookType = (oldBookType & 0xFF00) >>> 8;
					a_extendedObject.flags = oldBookType & 0xFF;
				}

			default:
				return;
		}
	}
}
