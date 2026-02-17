class StatsList extends Shared.BSScrollingList
{
	/* STAGE ELEMENTS */

	var scrollbar;

	/* CONSTRUCTOR */

	public function StatsList()
	{
		super();
		scrollbar.focusTarget = this;
	}

	/* PUBLIC FUNCTIONS */

	public function SetEntryText(aEntryClip, aEntryObject)
	{
		super.SetEntryText(aEntryClip, aEntryObject);
		aEntryClip.valueText.textAutoSize = "shrink";
		if (aEntryObject.text != undefined) {
			aEntryClip.valueText.SetText(aEntryObject.value.toString());
			return undefined;
		}
		aEntryClip.valueText.SetText(" ");
	}
}
