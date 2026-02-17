class Map.LocationListEntry extends skyui.components.list.BasicListEntry
{
   var background;
   var icon;
   var selectIndicator;
   var textField;
   function LocationListEntry()
   {
      super();
   }
   function get width()
   {
      return this.background._width;
   }
   function set width(a_val)
   {
      this.background._width = a_val;
      this.selectIndicator._width = a_val;
   }
   function setEntry(a_entryObject, a_state)
   {
      var _loc4_ = this.background._width;
      var _loc3_ = a_entryObject == a_state.list.selectedEntry;
      this.selectIndicator._visible = _loc3_;
      this.icon.gotoAndStop(a_entryObject.iconFrame);
      if(this.icon._width > this.icon._height)
      {
         this.icon._height *= 30 / this.icon._width;
         this.icon._width = 30;
      }
      else
      {
         this.icon._width *= 30 / this.icon._height;
         this.icon._height = 30;
      }
      this.textField.SetText(a_entryObject.label);
   }
}
