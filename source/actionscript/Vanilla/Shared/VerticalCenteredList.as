class Shared.VerticalCenteredList extends Shared.CenteredList
{
   var EntriesA;
   var SelectedEntry;
   var bRepositionEntries;
   var dispatchEvent;
   var iSelectedIndex;
   var moveListDown;
   var moveListUp;
   function VerticalCenteredList()
   {
      super();
      this.bRepositionEntries = false;
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.PAGE_DOWN)
         {
            this.moveListDown();
            _loc2_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.PAGE_UP)
         {
            this.moveListUp();
            _loc2_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.ENTER && this.iSelectedIndex != -1)
         {
            this.dispatchEvent({type:"itemPress",index:this.iSelectedIndex,entry:this.EntriesA[this.iSelectedIndex]});
            _loc2_ = true;
         }
      }
      return _loc2_;
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      if(aEntryObject.text != undefined)
      {
         if(aEntryObject.count > 1)
         {
            aEntryClip.textField.SetText(aEntryObject.text + " (" + aEntryObject.count + ")");
         }
         else
         {
            aEntryClip.textField.SetText(aEntryObject.text);
         }
      }
      else
      {
         aEntryClip.textField.SetText(" ");
      }
      if(aEntryObject == this.SelectedEntry)
      {
         aEntryClip.EquipLeftIcon_mc._visible = true;
         aEntryClip.EquipRightIcon_mc._visible = true;
      }
      else
      {
         aEntryClip.EquipLeftIcon_mc._visible = false;
         aEntryClip.EquipRightIcon_mc._visible = false;
      }
   }
}
