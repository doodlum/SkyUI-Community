// Entry objects are the actual markers
class Map.LocationListEntry extends skyui.components.list.BasicListEntry
{
	/* STAGE ELEMENTS */

	public var selectIndicator;
	public var background;
	public var icon;
	public var textField;


	/* PROPERTIES */

	public function get width()
	{
		return this.background._width;
	}

	public function set width(a_val)
	{
		this.background._width = a_val;
		this.selectIndicator._width = a_val;
	}


	/* PUBLIC FUNCTIONS */

	public function setEntry(a_entryObject, a_state)
	{
		var entryWidth = this.background._width;
		var isSelected = a_entryObject == a_state.list.selectedEntry;

		this.selectIndicator._visible = isSelected;

		this.icon.gotoAndStop(a_entryObject.iconFrame);

		if(this.icon._width > this.icon._height)
		{
			this.icon._height *= 30 / this.icon._width;
			this.icon._width = 30;
		}
		else
		{
			this.icon._width *= 30 / this.icon._height;
			this.icon._height = 30;
		}

		this.textField.SetText(a_entryObject.label);
	}
}
