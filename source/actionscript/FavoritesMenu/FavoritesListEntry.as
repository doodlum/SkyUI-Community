class FavoritesListEntry extends skyui.components.list.BasicListEntry
{
	/* CONSTANTS */

	private static var STATES = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];


	/* PRIVATE VARIABLES */


	/* STAGE ELEMENTS */

	public var itemIcon;
	public var equipIcon;
	public var textField;
	public var selectIndicator;
	public var hotkeyIcon;
	public var mainHandIcon;
	public var offHandIcon;


	/* INITIALIZATION */

	public function FavoritesListEntry()
	{
		super();
	}

	// @override BasicListEntry
	public function initialize(a_index, a_state)
	{
		super.initialize();
	}


	/* PUBLIC FUNCTIONS */

	// @override BasicListEntry
	public function setEntry(a_entryObject, a_state)
	{
		var isAssigned = a_entryObject == a_state.assignedEntry;
		var isSelected = a_entryObject == a_state.list.selectedEntry || isAssigned;

		var groupIndex = a_state.activeGroupIndex;
		var isMainHand = groupIndex != -1 && (a_entryObject.mainHandFlag & 1 << groupIndex) != 0;
		var isOffHand = groupIndex != -1 && (a_entryObject.offHandFlag & 1 << groupIndex) != 0;

		this.isEnabled = a_state.assignedEntry == null || isAssigned;
		this._alpha = !this.isEnabled ? 25 : 100;

		if (this.selectIndicator != undefined)
		{
			this.selectIndicator._visible = isSelected;
		}

		var hotkey;
		var maxTextLength;

		if (a_entryObject.text == undefined)
		{
			this.textField.SetText(" ");
		}
		else
		{
			hotkey = a_entryObject.hotkey;
			if (hotkey != undefined && hotkey != -1)
			{
				if (hotkey >= 0 && hotkey <= 7)
				{
					this.textField.SetText(a_entryObject.text);
					this.hotkeyIcon._visible = true;
					this.hotkeyIcon.gotoAndStop(hotkey + 1);
				}
				else
				{
					this.textField.SetText("$HK" + hotkey);
					this.textField.SetText(this.textField.text + ". " + a_entryObject.text);
					this.hotkeyIcon._visible = false;
				}
			}
			else
			{
				this.textField.SetText(a_entryObject.text);
				this.hotkeyIcon._visible = false;
			}
			maxTextLength = 32;
			if (this.textField.text.length > maxTextLength)
			{
				this.textField.SetText(this.textField.text.substr(0, maxTextLength - 3) + "...");
			}
		}

		var iconLabel = a_entryObject.iconLabel == undefined ? "default_misc" : a_entryObject.iconLabel;
		this.itemIcon.gotoAndStop(iconLabel);
		this.itemIcon._alpha = !isSelected ? 50 : 90;

		if (a_entryObject == null)
		{
			this.equipIcon.gotoAndStop("None");
		}
		else
		{
			this.equipIcon.gotoAndStop(FavoritesListEntry.STATES[a_entryObject.equipState]);
		}

		var iconOffset = this.textField._x + this.textField.textWidth + 8;

		if (isMainHand)
		{
			this.mainHandIcon._x = iconOffset;
			iconOffset += 12;
		}
		this.mainHandIcon._visible = isMainHand;

		if (isOffHand)
		{
			this.offHandIcon._x = iconOffset;
		}
		this.offHandIcon._visible = isOffHand;
	}


	/* PRIVATE FUNCTIONS */
}
