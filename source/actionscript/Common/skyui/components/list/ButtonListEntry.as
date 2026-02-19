class skyui.components.list.ButtonListEntry extends skyui.components.list.BasicListEntry
{
   var activeIndicator;
   var gotoAndPlay;
   var icon;
   var isEnabled;
   var selectIndicator;
   var textField;
   static var defaultTextColor = 16777215;
   static var activeTextColor = 16777215;
   static var selectedTextColor = 16777215;
   static var disabledTextColor = 5263440;
   function ButtonListEntry()
   {
      super();
   }
   function setEntry(a_entryObject, a_state)
   {
      this.isEnabled = a_entryObject.enabled;
      var _loc4_ = a_entryObject == a_state.list.selectedEntry;
      var _loc3_ = a_state.activeEntry != undefined && a_entryObject == a_state.activeEntry;
      if(a_entryObject.state != undefined)
      {
         this.gotoAndPlay(a_entryObject.state);
      }
      if(this.textField != undefined)
      {
         this.textField.autoSize = !a_entryObject.align ? "left" : a_entryObject.align;
         if(!a_entryObject.enabled)
         {
            this.textField.textColor = skyui.components.list.ButtonListEntry.disabledTextColor;
         }
         else if(_loc3_)
         {
            this.textField.textColor = skyui.components.list.ButtonListEntry.activeTextColor;
         }
         else if(_loc4_)
         {
            this.textField.textColor = skyui.components.list.ButtonListEntry.selectedTextColor;
         }
         else
         {
            this.textField.textColor = skyui.components.list.ButtonListEntry.defaultTextColor;
         }
         this.textField.SetText(!a_entryObject.text ? " " : a_entryObject.text);
      }
      if(this.selectIndicator != undefined)
      {
         this.selectIndicator._visible = _loc4_;
      }
      if(this.activeIndicator != undefined)
      {
         this.activeIndicator._visible = _loc3_;
         this.activeIndicator._x = this.textField._x - this.activeIndicator._width - 5;
      }
      if(this.icon != undefined && a_entryObject.iconLabel != undefined)
      {
         this.icon.gotoAndStop(a_entryObject.iconLabel);
      }
   }
}
