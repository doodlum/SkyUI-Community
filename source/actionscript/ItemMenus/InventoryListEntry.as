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
   var selectIndicator;
   var stolenIcon;
   static var STATES = ["None","Equipped","LeftEquip","RightEquip","LeftAndRightEquip"];
   function InventoryListEntry()
   {
      super();
   }
   function initialize(a_index, a_state)
   {
      super.initialize();
      var _loc5_ = new MovieClipLoader();
      _loc5_.addListener(this);
      _loc5_.loadClip(a_state.iconSource,this.itemIcon);
      this.itemIcon._visible = false;
      this.equipIcon._visible = false;
      var _loc6_ = 0;
      while(this["textField" + _loc6_] != undefined)
      {
         this["textField" + _loc6_]._visible = false;
         _loc6_ += 1;
      }
   }
   function __rf_cleanDisplayText(a_text)
   {
      var _loc2_;
      var _loc3_;
      if(a_text == undefined)
      {
         return a_text;
      }
      _loc2_ = a_text.indexOf("\t");
      if(_loc2_ == -1)
      {
         return a_text;
      }
      _loc3_ = _loc2_;
      while(_loc3_ > 0 && (a_text.charCodeAt(_loc3_ - 1) == 32 || a_text.charCodeAt(_loc3_ - 1) == 160))
      {
         _loc3_ -= 1;
      }
      return a_text.substring(0,_loc3_);
   }
   function setEntry(a_entryObject, a_state)
   {
      var _loc4_ = skyui.components.list.TabularList(a_state.list).layout;
      this.selectIndicator._visible = a_entryObject == a_state.list.selectedEntry;
      var _loc5_ = _loc4_.layoutUpdateCount;
      if(this._layoutUpdateCount != _loc5_)
      {
         this._layoutUpdateCount = _loc5_;
         this.setEntryLayout(a_entryObject,a_state);
         this.setSpecificEntryLayout(a_entryObject,a_state);
      }
      var _loc6_ = 0;
      var _loc7_;
      var _loc8_;
      var _loc9_;
      var _loc10_;
      var _loc11_;
      var _loc12_;
      while(_loc6_ < _loc4_.columnCount)
      {
         _loc7_ = _loc4_.columnLayoutData[_loc6_];
         _loc8_ = this[_loc7_.stageName];
         _loc9_ = _loc7_.entryValue;
         if(_loc9_ != undefined)
         {
            if(_loc9_.charAt(0) == "@")
            {
               _loc10_ = a_entryObject[_loc9_.slice(1)];
               _loc12_ = _loc10_ == undefined ? "-" : _loc10_;
               if(_loc7_.stageName == "textField1")
               {
                  _loc12_ = this.__rf_cleanDisplayText(_loc12_);
               }
               _loc8_.SetText(_loc12_);
            }
            else
            {
               _loc12_ = _loc9_;
               if(_loc7_.stageName == "textField1")
               {
                  _loc12_ = this.__rf_cleanDisplayText(_loc12_);
               }
               _loc8_.SetText(_loc12_);
            }
         }
         switch(_loc7_.type)
         {
            case skyui.components.list.ListLayout.COL_TYPE_EQUIP_ICON:
               this.formatEquipIcon(_loc8_,a_entryObject,a_state);
               break;
            case skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON:
               this.formatItemIcon(_loc8_,a_entryObject,a_state);
               break;
            case skyui.components.list.ListLayout.COL_TYPE_NAME:
               this.formatName(_loc8_,a_entryObject,a_state);
               break;
            case skyui.components.list.ListLayout.COL_TYPE_TEXT:
            default:
               this.formatText(_loc8_,a_entryObject,a_state);
         }
         if(_loc7_.colorAttribute != undefined)
         {
            _loc11_ = a_entryObject[_loc7_.colorAttribute];
            if(_loc11_ != undefined)
            {
               _loc8_.textColor = _loc11_;
            }
         }
         _loc6_ += 1;
      }
   }
   function setSpecificEntryLayout(a_entryObject, a_state)
   {
      var _loc4_ = skyui.components.list.TabularList(a_state.list).layout.entryHeight * 0.25;
      var _loc5_ = skyui.components.list.TabularList(a_state.list).layout.entryHeight * 0.5;
      this.bestIcon._height = this.bestIcon._width = _loc5_;
      this.favoriteIcon._height = this.favoriteIcon._width = _loc5_;
      this.poisonIcon._height = this.poisonIcon._width = _loc5_;
      this.stolenIcon._height = this.stolenIcon._width = _loc5_;
      this.enchIcon._height = this.enchIcon._width = _loc5_;
      this.readIcon._height = this.readIcon._width = _loc5_;
      this.bestIcon._y = _loc4_;
      this.favoriteIcon._y = _loc4_;
      this.poisonIcon._y = _loc4_;
      this.stolenIcon._y = _loc4_;
      this.enchIcon._y = _loc4_;
      this.readIcon._y = _loc4_;
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
      var _loc5_ = a_entryObject.text;
      if(a_entryObject.soulLVL != undefined)
      {
         _loc5_ = _loc5_ + " (" + a_entryObject.soulLVL + ")";
      }
      if(a_entryObject.count > 1)
      {
         _loc5_ = _loc5_ + " (" + a_entryObject.count.toString() + ")";
      }
      if(_loc5_.length > a_state.maxTextLength)
      {
         _loc5_ = _loc5_.substr(0,a_state.maxTextLength - 3) + "...";
      }
      a_entryField.autoSize = "left";
      a_entryField.SetText(_loc5_);
      this.formatColor(a_entryField,a_entryObject,a_state);
      var _loc6_ = a_entryField._x + a_entryField._width + 5;
      var _loc7_ = this.bestIcon._width * 1.25;
      if(a_entryObject.bestInClass == true)
      {
         this.bestIcon._x = _loc6_;
         _loc6_ += _loc7_;
         this.bestIcon.gotoAndStop("show");
      }
      else
      {
         this.bestIcon.gotoAndStop("hide");
      }
      if(a_entryObject.favorite == true)
      {
         this.favoriteIcon._x = _loc6_;
         _loc6_ += _loc7_;
         this.favoriteIcon.gotoAndStop("show");
      }
      else
      {
         this.favoriteIcon.gotoAndStop("hide");
      }
      if(a_entryObject.isPoisoned == true)
      {
         this.poisonIcon._x = _loc6_;
         _loc6_ += _loc7_;
         this.poisonIcon.gotoAndStop("show");
      }
      else
      {
         this.poisonIcon.gotoAndStop("hide");
      }
      if((a_entryObject.isStolen == true || a_entryObject.isStealing == true) && a_state.showStolenIcon == true)
      {
         this.stolenIcon._x = _loc6_;
         _loc6_ += _loc7_;
         this.stolenIcon.gotoAndStop("show");
      }
      else
      {
         this.stolenIcon.gotoAndStop("hide");
      }
      if(a_entryObject.isEnchanted == true)
      {
         this.enchIcon._x = _loc6_;
         _loc6_ += _loc7_;
         this.enchIcon.gotoAndStop("show");
      }
      else
      {
         this.enchIcon.gotoAndStop("hide");
      }
      if(a_entryObject.isRead == true)
      {
         this.readIcon._x = _loc6_;
         _loc6_ += _loc7_;
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
      a_entryField.autoSize = a_entryField.getTextFormat().align;
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
      var _loc3_;
      var _loc4_;
      var _loc5_;
      for(var _loc6_ in a_icon)
      {
         _loc3_ = a_icon[_loc6_];
         if(_loc3_ instanceof MovieClip)
         {
            _loc4_ = new flash.geom.ColorTransform();
            _loc5_ = new flash.geom.Transform(MovieClip(_loc3_));
            _loc4_.rgb = a_rgb != undefined ? a_rgb : 16777215;
            _loc5_.colorTransform = _loc4_;
         }
      }
   }
}
