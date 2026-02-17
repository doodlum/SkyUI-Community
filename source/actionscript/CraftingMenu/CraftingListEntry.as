class CraftingListEntry extends skyui.components.list.TabularListEntry
{
	/* CONSTANTS */

	private static var STATES = ["None", "Equipped", "LeftEquip", "RightEquip", "LeftAndRightEquip"];


	/* PRIVATE VARIABLES */

	private var _iconLabel;
	private var _iconColor;


	/* STAGE ELEMENTS */

	public var itemIcon;
	public var equipIcon;
	public var poisonIcon;
	public var stolenIcon;


	/* INITIALIZATION */

	public function CraftingListEntry()
	{
		super();
	}

	// @override TabularListEntry
	public function initialize(a_index, a_state)
	{
		super.initialize();
		var iconLoader = new MovieClipLoader();
		iconLoader.addListener(this);
		iconLoader.loadClip(a_state.iconSource, this.itemIcon);
		this.itemIcon._visible = false;
		this.equipIcon._visible = false;
		var i = 0;
		while (this["textField" + i] != undefined)
		{
			this["textField" + i]._visible = false;
			i = i + 1;
		}
	}


	/* PUBLIC FUNCTIONS */

	// @override TabularListEntry
	public function setSpecificEntryLayout(a_entryObject, a_state)
	{
		var iconY = skyui.components.list.TabularList(a_state.list).layout.entryHeight * 0.25;
		var iconSize = skyui.components.list.TabularList(a_state.list).layout.entryHeight * 0.5;
		this.poisonIcon._height = this.poisonIcon._width = iconSize;
		this.stolenIcon._height = this.stolenIcon._width = iconSize;
		this.poisonIcon._y = iconY;
		this.stolenIcon._y = iconY;
	}

	// @override TabularListEntry
	public function formatEquipIcon(a_entryField, a_entryObject, a_state)
	{
		if (a_entryObject != undefined && a_entryObject.equipState != undefined)
		{
			a_entryField.gotoAndStop(CraftingListEntry.STATES[a_entryObject.equipState]);
		}
		else
		{
			a_entryField.gotoAndStop("None");
		}
	}

	// @override TabularListEntry
	public function formatItemIcon(a_entryField, a_entryObject, a_state)
	{
		this._iconLabel = a_entryObject.iconLabel == undefined ? "default_misc" : a_entryObject.iconLabel;
		this._iconColor = a_entryObject.iconColor;
		a_entryField.gotoAndStop(this._iconLabel);
		this.changeIconColor(MovieClip(a_entryField), this._iconColor);
	}

	// @override TabularListEntry
	public function formatName(a_entryField, a_entryObject, a_state)
	{
		if (a_entryObject.text == undefined)
		{
			a_entryField.SetText(" ");
			return undefined;
		}

		// Text
		var text = a_entryObject.text;
		if (a_entryObject.soulLVL != undefined)
		{
			text = text + " (" + a_entryObject.soulLVL + ")";
		}
		if (a_entryObject.count > 1)
		{
			text = text + " (" + a_entryObject.count.toString() + ")";
		}
		if (text.length > a_state.maxTextLength)
		{
			text = text.substr(0, a_state.maxTextLength - 3) + "...";
		}
		a_entryField.autoSize = "left";
		a_entryField.SetText(text);
		this.formatColor(a_entryField, a_entryObject, a_state);

		var iconPos = a_entryField._x + a_entryField._width + 5;

		// All icons have the same size
		var iconSpace = this.stolenIcon._width * 1.25;

		// Poisoned Icon
		if (a_entryObject.isPoisoned == true)
		{
			this.poisonIcon._x = iconPos;
			iconPos += iconSpace;
			this.poisonIcon.gotoAndStop("show");
		}
		else
		{
			this.poisonIcon.gotoAndStop("hide");
		}

		// Stolen Icon
		if ((a_entryObject.isStolen == true || a_entryObject.isStealing == true) && a_state.showStolenIcon == true)
		{
			this.stolenIcon._x = iconPos;
			iconPos += iconSpace;
			this.stolenIcon.gotoAndStop("show");
		}
		else
		{
			this.stolenIcon.gotoAndStop("hide");
		}
	}

	// @override TabularEntry
	public function formatText(a_entryField, a_entryObject, a_state)
	{
		this.formatColor(a_entryField, a_entryObject, a_state);
	}


	/* PRIVATE FUNCTIONS */

	// @implements MovieClipLoader
	private function onLoadInit(a_icon)
	{
		a_icon.gotoAndStop(this._iconLabel);
		this.changeIconColor(a_icon, this._iconColor);
	}

	private function formatColor(a_entryField, a_entryObject, a_state)
	{
		// Stolen
		if (a_entryObject.infoIsStolen == true || a_entryObject.isStealing == true)
		{
			a_entryField.textColor = a_entryObject.enabled != false ? a_state.stolenEnabledColor : a_state.stolenDisabledColor;
		}
		// Default
		else
		{
			a_entryField.textColor = a_entryObject.enabled != false ? a_state.defaultEnabledColor : a_state.defaultDisabledColor;
		}
	}

	private function changeIconColor(a_icon, a_rgb)
	{
		var element;
		var ct;
		var tf;
		for (var e in a_icon)
		{
			element = a_icon[e];
			if (element instanceof MovieClip)
			{
				ct = new flash.geom.ColorTransform();
				tf = new flash.geom.Transform(MovieClip(element));
				ct.rgb = a_rgb != undefined ? a_rgb : 16777215;
				tf.colorTransform = ct;
			}
		}
	}
}
