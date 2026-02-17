class InputMappingList extends Shared.BSScrollingList
{
	var GetClipByIndex;
	var __get__selectedEntry;

	function InputMappingList()
	{
		super();
	}

	function GetEntryHeight(aiEntryIndex)
	{
		var entry = this.GetClipByIndex(0);
		return entry._height;
	}

	function SetEntry(aEntryClip, aEntryObject)
	{
		var buttonArt = aEntryClip.buttonArt;
		var label = aEntryClip.textField;

		buttonArt._alpha = aEntryObject != this.selectedEntry ? 30 : 100;
		label._alpha = aEntryObject != this.selectedEntry ? 30 : 100;
		label.textAutoSize = "shrink";

		buttonArt.setButtonName(aEntryObject.buttonName);
		label.SetText("$" + aEntryObject.text);
	}
}
