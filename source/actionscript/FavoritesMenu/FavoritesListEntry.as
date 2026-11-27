class FavoritesListEntry extends skyui.components.list.BasicListEntry
{
   var _alpha;
   var _iconColor;
   var _iconLabel;
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
      this.fixIconPos();
      var _loc3_ = new MovieClipLoader();
      _loc3_.addListener(this);
      _loc3_.loadClip("skyui/icons_item_psychosteve.swf",this.itemIcon);
      this.itemIcon._visible = false;
   }
   function fixIconPos()
   {
      if (skse.plugins.InventoryInjector == undefined){
         var _loc1_ = this.itemIcon.transform;
         var _loc2_ = _loc1_.matrix;
         _loc2_.translate(-64 * _loc2_.a,-64 * _loc2_.d);
         _loc1_.matrix = _loc2_;
      }
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
      this._iconLabel = a_entryObject.iconLabel == undefined ? "default_misc" : a_entryObject.iconLabel;
      this._iconColor = a_entryObject.iconColor;
      this.itemIcon.gotoAndStop(this._iconLabel);
      this.changeIconColor(this.itemIcon,this._iconColor);
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
   function onLoadInit(a_icon)
   {
      a_icon._visible = true;
      a_icon.gotoAndStop(this._iconLabel == undefined ? "default_misc" : this._iconLabel);
      this.changeIconColor(a_icon,this._iconColor);
   }
   function changeIconColor(a_icon, a_rgb)
   {
      var _loc2_;
      var _loc1_;
      var _loc3_;
      for(var _loc6_ in a_icon)
      {
         _loc2_ = a_icon[_loc6_];
         if(_loc2_ instanceof MovieClip)
         {
            _loc1_ = new flash.geom.ColorTransform();
            _loc3_ = new flash.geom.Transform(MovieClip(_loc2_));
            _loc1_.rgb = a_rgb != undefined ? a_rgb : 16777215;
            _loc3_.colorTransform = _loc1_;
         }
      }
   }
}
