class FavoritesListEntry extends skyui.components.list.BasicListEntry
{
   var _alpha;
   var equipIcon;
   var hotkeyIcon;
   var isEnabled;
   var itemIcon;
   var mainHandIcon;
   var offHandIcon;
   var selectIndicator;
   var textField;
   static var STATES = ["None","Equipped","LeftEquip","RightEquip","LeftAndRightEquip"];
   function FavoritesListEntry()
   {
      super();
   }
   function initialize(a_index, a_state)
   {
      super.initialize();
   }
   function setEntry(a_entryObject, a_state)
   {
      var _loc7_ = a_entryObject == a_state.assignedEntry;
      var _loc10_ = a_entryObject == a_state.list.selectedEntry || _loc7_;
      var _loc4_ = a_state.activeGroupIndex;
      var _loc6_ = _loc4_ != -1 && (a_entryObject.mainHandFlag & 1 << _loc4_) != 0;
      var _loc8_ = _loc4_ != -1 && (a_entryObject.offHandFlag & 1 << _loc4_) != 0;
      this.isEnabled = a_state.assignedEntry == null || _loc7_;
      this._alpha = !this.isEnabled ? 25 : 100;
      if(this.selectIndicator != undefined)
      {
         this.selectIndicator._visible = _loc10_;
      }
      var _loc3_;
      var _loc9_;
      if(a_entryObject.text == undefined)
      {
         this.textField.SetText(" ");
      }
      else
      {
         _loc3_ = a_entryObject.hotkey;
         if(_loc3_ != undefined && _loc3_ != -1)
         {
            if(_loc3_ >= 0 && _loc3_ <= 7)
            {
               this.textField.SetText(a_entryObject.text);
               this.hotkeyIcon._visible = true;
               this.hotkeyIcon.gotoAndStop(_loc3_ + 1);
            }
            else
            {
               this.textField.SetText("$HK" + _loc3_);
               this.textField.SetText(this.textField.text + ". " + a_entryObject.text);
               this.hotkeyIcon._visible = false;
            }
         }
         else
         {
            this.textField.SetText(a_entryObject.text);
            this.hotkeyIcon._visible = false;
         }
         _loc9_ = 32;
         if(this.textField.text.length > _loc9_)
         {
            this.textField.SetText(this.textField.text.substr(0,_loc9_ - 3) + "...");
         }
      }
      var _loc12_ = a_entryObject.iconLabel == undefined ? "default_misc" : a_entryObject.iconLabel;
      this.itemIcon.gotoAndStop(_loc12_);
      this.itemIcon._alpha = !_loc10_ ? 50 : 90;
      if(a_entryObject == null)
      {
         this.equipIcon.gotoAndStop("None");
      }
      else
      {
         this.equipIcon.gotoAndStop(FavoritesListEntry.STATES[a_entryObject.equipState]);
      }
      var _loc5_ = this.textField._x + this.textField.textWidth + 8;
      if(_loc6_)
      {
         this.mainHandIcon._x = _loc5_;
         _loc5_ += 12;
      }
      this.mainHandIcon._visible = _loc6_;
      if(_loc8_)
      {
         this.offHandIcon._x = _loc5_;
      }
      this.offHandIcon._visible = _loc8_;
   }
}
