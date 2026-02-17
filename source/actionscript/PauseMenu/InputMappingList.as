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
      var _loc2_ = this.GetClipByIndex(0);
      return _loc2_._height;
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      var _loc4_ = aEntryClip.buttonArt;
      var _loc2_ = aEntryClip.textField;
      _loc4_._alpha = aEntryObject != this.selectedEntry ? 30 : 100;
      _loc2_._alpha = aEntryObject != this.selectedEntry ? 30 : 100;
      _loc2_.textAutoSize = "shrink";
      _loc4_.setButtonName(aEntryObject.buttonName);
      _loc2_.SetText("$" + aEntryObject.text);
   }
}
