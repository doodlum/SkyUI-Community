class ObjectiveScrollingList extends Shared.BSScrollingList
{
   var SetEntryText;
   var selectedEntry;
   function ObjectiveScrollingList()
   {
      super();
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      var _loc2_;
      if(aEntryObject.text != undefined)
      {
         _loc2_ = "";
         if(aEntryObject.active)
         {
            _loc2_ += "Active";
         }
         else if(aEntryObject.completed)
         {
            _loc2_ += "Completed";
         }
         else if(aEntryObject.failed)
         {
            _loc2_ += "Failed";
         }
         else
         {
            _loc2_ += "Normal";
         }
         if(aEntryObject == this.selectedEntry)
         {
            _loc2_ += "Selected";
         }
         aEntryClip.gotoAndStop(_loc2_);
      }
      else
      {
         aEntryClip.gotoAndStop("None");
      }
      this.SetEntryText(aEntryClip,aEntryObject);
   }
}
