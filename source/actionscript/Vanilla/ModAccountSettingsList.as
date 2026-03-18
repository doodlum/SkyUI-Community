class ModAccountSettingsList extends Shared.BSScrollingList
{
   var __get__selectedEntry;
   function ModAccountSettingsList()
   {
      super();
   }
   function SetEntryText(entryClip, entryObject)
   {
      super.SetEntryText(entryClip,entryObject);
      var _loc5_ = entryClip.textField;
      var _loc3_ = entryClip.border;
      var _loc4_ = entryObject == this.selectedEntry;
      if(!entryObject.disabled)
      {
         if(_loc5_)
         {
            _loc5_.textColor = !_loc4_ ? 16777215 : 0;
         }
         if(_loc3_ != null)
         {
            _loc3_._alpha = !_loc4_ ? 0 : 100;
         }
      }
      else
      {
         _loc3_._alpha = !_loc4_ ? 0 : 15;
      }
   }
}
