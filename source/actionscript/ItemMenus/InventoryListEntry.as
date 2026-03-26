class InventoryListEntry extends skyui.components.list.TabularListEntry
{
   var _iconColor;
   var _iconLabel;
   var bestIcon;
   var enchIcon;
   var equipIcon;
   var favoriteIcon;
   var itemIcon;
   var poisonIcon;
   var readIcon;
   var stolenIcon;
   static var STATES = ["None","Equipped","LeftEquip","RightEquip","LeftAndRightEquip"];
   function InventoryListEntry()
   {
      super();
   }
   function initialize(a_index, a_state)
   {
      super.initialize();
      var _loc4_ = new MovieClipLoader();
      _loc4_.addListener(this);
      _loc4_.loadClip(a_state.iconSource,this.itemIcon);
      this.itemIcon._visible = false;
      this.equipIcon._visible = false;
      var _loc3_ = 0;
      while(this["textField" + _loc3_] != undefined)
      {
         this["textField" + _loc3_]._visible = false;
         _loc3_ = _loc3_ + 1;
      }
   }
   function setSpecificEntryLayout(a_entryObject, a_state)
   {
      var _loc2_ = skyui.components.list.TabularList(a_state.list).layout.entryHeight * 0.25;
      var _loc3_ = skyui.components.list.TabularList(a_state.list).layout.entryHeight * 0.5;
      this.bestIcon._height = this.bestIcon._width = _loc3_;
      this.favoriteIcon._height = this.favoriteIcon._width = _loc3_;
      this.poisonIcon._height = this.poisonIcon._width = _loc3_;
      this.stolenIcon._height = this.stolenIcon._width = _loc3_;
      this.enchIcon._height = this.enchIcon._width = _loc3_;
      this.readIcon._height = this.readIcon._width = _loc3_;
      this.bestIcon._y = _loc2_;
      this.favoriteIcon._y = _loc2_;
      this.poisonIcon._y = _loc2_;
      this.stolenIcon._y = _loc2_;
      this.enchIcon._y = _loc2_;
      this.readIcon._y = _loc2_;
   }
   function formatEquipIcon(a_entryField, a_entryObject, a_state)
   {
      if(a_entryObject != undefined && a_entryObject.equipState != undefined)
      {
         a_entryField.gotoAndStop(InventoryListEntry.STATES[a_entryObject.equipState]);
      }
      else
      {
         a_entryField.gotoAndStop("None");
      }
   }
   function formatItemIcon(a_entryField, a_entryObject, a_state)
   {
      this._iconLabel = a_entryObject.iconLabel == undefined ? "default_misc" : a_entryObject.iconLabel;
      this._iconColor = a_entryObject.iconColor;
      a_entryField.gotoAndStop(this._iconLabel);
      this.changeIconColor(MovieClip(a_entryField),this._iconColor);
   }
   function formatName(a_entryField, a_entryObject, a_state)
   {
      if(a_entryObject.text == undefined)
      {
         a_entryField.SetText(" ");
         return undefined;
      }
      var _loc4_ = a_entryObject.text;
      if(a_entryObject.soulLVL != undefined)
      {
         _loc4_ = _loc4_ + " (" + a_entryObject.soulLVL + ")";
      }
      if(a_entryObject.count > 1)
      {
         _loc4_ = _loc4_ + " (" + a_entryObject.count.toString() + ")";
      }
      if(_loc4_.length > a_state.maxTextLength)
      {
         _loc4_ = _loc4_.substr(0,a_state.maxTextLength - 3) + "...";
      }
      a_entryField.autoSize = "left";
      a_entryField.SetText(_loc4_);
      this.formatColor(a_entryField,a_entryObject,a_state);
      var _loc2_ = a_entryField._x + a_entryField._width + 5;
      var _loc5_ = this.bestIcon._width * 1.25;
      if(a_entryObject.bestInClass == true)
      {
         this.bestIcon._x = _loc2_;
         _loc2_ += _loc5_;
         this.bestIcon.gotoAndStop("show");
      }
      else
      {
         this.bestIcon.gotoAndStop("hide");
      }
      if(a_entryObject.favorite == true)
      {
         this.favoriteIcon._x = _loc2_;
         _loc2_ += _loc5_;
         this.favoriteIcon.gotoAndStop("show");
      }
      else
      {
         this.favoriteIcon.gotoAndStop("hide");
      }
      if(a_entryObject.isPoisoned == true)
      {
         this.poisonIcon._x = _loc2_;
         _loc2_ += _loc5_;
         this.poisonIcon.gotoAndStop("show");
      }
      else
      {
         this.poisonIcon.gotoAndStop("hide");
      }
      if((a_entryObject.isStolen == true || a_entryObject.isStealing == true) && a_state.showStolenIcon == true)
      {
         this.stolenIcon._x = _loc2_;
         _loc2_ += _loc5_;
         this.stolenIcon.gotoAndStop("show");
      }
      else
      {
         this.stolenIcon.gotoAndStop("hide");
      }
      if(a_entryObject.isEnchanted == true)
      {
         this.enchIcon._x = _loc2_;
         _loc2_ += _loc5_;
         this.enchIcon.gotoAndStop("show");
      }
      else
      {
         this.enchIcon.gotoAndStop("hide");
      }
      if(a_entryObject.isRead == true)
      {
         this.readIcon._x = _loc2_;
         _loc2_ += _loc5_;
         this.readIcon.gotoAndStop("show");
      }
      else
      {
         this.readIcon.gotoAndStop("hide");
      }
   }
   function formatText(a_entryField, a_entryObject, a_state)
   {
      this.formatColor(a_entryField,a_entryObject,a_state);
      if (a_entryField != this.textField0) {
         a_entryField.autoSize = "right";
      }
   }
   function onLoadInit(a_icon)
   {
      a_icon.gotoAndStop(this._iconLabel);
      this.changeIconColor(a_icon,this._iconColor);
   }
   function formatColor(a_entryField, a_entryObject, a_state)
   {
      if(a_entryObject.negativeEffect == true)
      {
         a_entryField.textColor = a_entryObject.enabled != false ? a_state.negativeEnabledColor : a_state.negativeDisabledColor;
      }
      else if(a_entryObject.infoIsStolen == true || a_entryObject.isStealing == true)
      {
         a_entryField.textColor = a_entryObject.enabled != false ? a_state.stolenEnabledColor : a_state.stolenDisabledColor;
      }
      else
      {
         a_entryField.textColor = a_entryObject.enabled != false ? a_state.defaultEnabledColor : a_state.defaultDisabledColor;
      }
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
