class IconTabListEntry extends skyui.components.list.BasicListEntry
{
	/* PRIVATE VARIABLES */

	private var _iconLabel;
	private var _iconSize;


	/* STAGE ELEMENTS */

	public var icon;


	/* PUBLIC FUNCTIONS */

	public function initialize(a_index, a_state)
	{
		super.initialize();
		this._iconLabel = IconTabList(a_state.list).iconArt[a_index];
		this._iconSize = IconTabList(a_state.list).iconSize;
		this.icon.gotoAndStop(this._iconLabel);
	}

	public function setEntry(a_entryObject, a_state)
	{
		this.enabled = a_entryObject.enabled;
		if (a_entryObject.divider == true)
		{
			this._alpha = 100;
		}
		else if (!this.enabled)
		{
			this._alpha = 15;
		}
		else if (a_entryObject == a_state.list.selectedEntry)
		{
			this._alpha = 100;
		}
		else
		{
			this._alpha = 50;
		}
	}


	/* PRIVATE FUNCTIONS */
}
