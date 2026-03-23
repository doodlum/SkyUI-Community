class OptionsList extends Shared.BSScrollingList
{
   var EntriesA;
   var GetClipByIndex;
   var bAllowValueOverwrite;
   var selectedEntry;
   function OptionsList()
   {
      super();
      this.bAllowValueOverwrite = false;
   }
   function GetEntryHeight(aiEntryIndex)
   {
      var _loc2_ = this.GetClipByIndex(0);
      return _loc2_._height;
   }
   function onValueChange(aiItemIndex, aiNewValue)
   {
      if(aiItemIndex != undefined)
      {
         this.EntriesA[aiItemIndex].value = aiNewValue;
      }
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      if(aEntryClip != undefined)
      {
         aEntryClip.selected = aEntryObject == this.selectedEntry;
         if(this.bAllowValueOverwrite || aEntryClip.ID != aEntryObject.ID)
         {
            aEntryClip.movieType = aEntryObject.movieType;
            if(aEntryObject.options != undefined)
            {
               aEntryClip.SetOptionStepperOptions(aEntryObject.options);
            }
            aEntryClip.ID = aEntryObject.ID;
            aEntryClip.value = aEntryObject.value;
            aEntryClip.text = aEntryObject.text;
         }
      }
   }
}
