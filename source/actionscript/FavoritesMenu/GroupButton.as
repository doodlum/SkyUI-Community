class GroupButton extends gfx.controls.Button
{
	/* STAGE ELEMENTS */

	public var groupNum;


	/* PROPERTIES */

	public var text;

	private var _groupIndex = 0;

	public function get groupIndex()
	{
		return this._groupIndex;
	}

	public function set groupIndex(a_index)
	{
		this._groupIndex = a_index;
		this._filterFlag = FilterDataExtender.FILTERFLAG_GROUP_0 << this.groupIndex | FilterDataExtender.FILTERFLAG_GROUP_ADD;
		this.groupNum.gotoAndStop(this.groupIndex + 1);
	}

	private var _filterFlag = 0;

	public function get filterFlag()
	{
		return this._filterFlag;
	}


	/* INITIALIZATION */

	public function GroupButton()
	{
		super();
		this.text = skyui.util.Translator.translate("$GROUP") + " " + (this.groupIndex + 1);
	}
}
