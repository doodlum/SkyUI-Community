class skyui.components.list.BasicListEntry extends MovieClip
{
   var itemIndex;
   var isEnabled = true;
   function BasicListEntry()
   {
      super();
   }
   function onRollOver()
   {
      var _loc2_ = this._parent;
      if(this.itemIndex != undefined && (this.isEnabled || _loc2_.canSelectDisabled))
      {
         _loc2_.onItemRollOver(this.itemIndex);
      }
   }
   function onRollOut()
   {
      var _loc2_ = this._parent;
      if(this.itemIndex != undefined && (this.isEnabled || _loc2_.canSelectDisabled))
      {
         _loc2_.onItemRollOut(this.itemIndex);
      }
   }
   function onPress(a_mouseIndex, a_keyboardOrMouse)
   {
      var _loc2_ = this._parent;
      if(this.itemIndex != undefined && (this.isEnabled || _loc2_.canSelectDisabled))
      {
         _loc2_.onItemPress(this.itemIndex,a_keyboardOrMouse);
      }
   }
   function onPressAux(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
   {
      var _loc2_ = this._parent;
      if(this.itemIndex != undefined && (this.isEnabled || _loc2_.canSelectDisabled))
      {
         _loc2_.onItemPressAux(this.itemIndex,a_keyboardOrMouse,a_buttonIndex);
      }
   }
   function initialize(a_index, a_list)
   {
   }
   function setEntry(a_entryObject, a_state)
   {
   }
}
