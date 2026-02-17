class GroupDataExtender implements skyui.components.list.IListProcessor
{
	/* CONSTANTS */

	public static var GROUP_SIZE = 32;


	/* PRIVATE VARIABLES */

	private var _itemIdMap;

	private var _groupButtons;

	private var _invalidItems;


	/* PROPERTIES */

	public var groupData;
	public var mainHandData;
	public var offHandData;
	public var iconData;


	/* INITIALIZATION */

	public function GroupDataExtender(a_groupButtons)
	{
		this.groupData = [];
		this.mainHandData = [];
		this.offHandData = [];
		this.iconData = [];
		this._itemIdMap = {};
		this._invalidItems = [];
		this._groupButtons = a_groupButtons;
	}


	/* PUBLIC FUNCTIONS */

	// @override IListProcessor
	public function processList(a_list)
	{
		var groupCount = int(this.groupData.length / GroupDataExtender.GROUP_SIZE);

		var clearFlag = 0;
		var c = 0;
		while (c < groupCount)
		{
			clearFlag |= FilterDataExtender.FILTERFLAG_GROUP_0 << c;
			c = c + 1;
		}

		var entryList = a_list.entryList;

		// Create map for itemid->entry, clear group filter flags
		var i = 0;
		var e;
		while (i < entryList.length)
		{
			e = entryList[i];
			e.filterFlag &= ~clearFlag;
			e.mainHandFlag = 0;
			e.offHandFlag = 0;
			if (e.itemId != undefined)
			{
				this._itemIdMap[e.itemId] = e;
			}
			i = i + 1;
		}

		this.processGroupData();
		this.processMainHandData();
		this.processOffHandData();
		this.processIconData();
	}


	/* PRIVATE FUNCTIONS */

	private function processGroupData()
	{
		// Set filterFlags for group membership
		var c = 0;
		var curFilterFlag = FilterDataExtender.FILTERFLAG_GROUP_0;

		var i = 0;
		var itemId;
		var t;
		while (i < this.groupData.length)
		{
			if (c == GroupDataExtender.GROUP_SIZE)
			{
				curFilterFlag <<= 1;
				c = 0;
			}
			itemId = this.groupData[i];
			if (itemId)
			{
				t = this._itemIdMap[itemId];
				if (t != null)
				{
					t.filterFlag |= curFilterFlag;
				}
				// Lookup failed? We help Papyrus with the cleanup by notifying it about the invalid item
				else
				{
					this.reportInvalidItem(itemId);
				}
			}
			i++;
			c++;
		}
	}

	private function processMainHandData()
	{
		// Set filterFlags for group membership
		var i = 0;
		var itemId;
		var t;
		while (i < this.mainHandData.length)
		{
			itemId = this.mainHandData[i];
			if (itemId)
			{
				t = this._itemIdMap[itemId];
				if (t != null)
				{
					t.mainHandFlag |= 1 << i;
				}
				else
				{
					this.reportInvalidItem(itemId);
				}
			}
			i = i + 1;
		}
	}

	private function processOffHandData()
	{
		// Set filterFlags for group membership
		var i = 0;
		var itemId;
		var t;
		while (i < this.offHandData.length)
		{
			itemId = this.offHandData[i];
			if (itemId)
			{
				t = this._itemIdMap[itemId];
				if (t != null)
				{
					t.offHandFlag |= 1 << i;
				}
				else
				{
					this.reportInvalidItem(itemId);
				}
			}
			i = i + 1;
		}
	}

	private function processIconData()
	{
		// Set icons (assumes iconDataExtender already set iconLabel)
		var i = 0;
		var iconLabel;
		var itemId;
		var t;
		while (i < this.iconData.length)
		{
			itemId = this.iconData[i];
			if (itemId)
			{
				t = this._itemIdMap[itemId];
				if (t != null)
				{
					iconLabel = !t.iconLabel ? "misc_default" : t.iconLabel;
				}
				else
				{
					iconLabel = "misc_default";
					this.reportInvalidItem(itemId);
				}
			}
			else
			{
				iconLabel = "none";
			}
			this._groupButtons[i].itemIcon.gotoAndStop(iconLabel);
			i = i + 1;
		}
	}

	private function reportInvalidItem(a_itemId)
	{
		var i = 0;
		while (i < this._invalidItems.length)
		{
			if (this._invalidItems[i] == a_itemId)
			{
				return undefined;
			}
			i = i + 1;
		}
		this._invalidItems.push(a_itemId);
		skse.SendModEvent("SKIFM_foundInvalidItem", String(a_itemId));
	}
}
