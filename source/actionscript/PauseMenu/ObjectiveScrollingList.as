class ObjectiveScrollingList extends Shared.BSScrollingList
{
	var SetEntryText;
	var __get__selectedEntry;

	function ObjectiveScrollingList()
	{
		super();
	}

	function SetEntry(aEntryClip, aEntryObject)
	{
		if (aEntryObject.text == undefined) {
			aEntryClip.gotoAndStop("None");
		} else {
			var slabelName = "";
			if (aEntryObject.active) {
				slabelName += "Active";
			} else if (aEntryObject.completed) {
				slabelName += "Completed";
			} else if (aEntryObject.failed) {
				slabelName += "Failed";
			} else {
				slabelName += "Normal";
			}
			if (aEntryObject == this.selectedEntry) {
				slabelName += "Selected";
			}
			aEntryClip.gotoAndStop(slabelName);
		}
		this.SetEntryText(aEntryClip, aEntryObject);
	}
}
