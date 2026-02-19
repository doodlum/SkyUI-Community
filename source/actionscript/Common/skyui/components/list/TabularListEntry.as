class skyui.components.list.TabularListEntry extends skyui.components.list.BasicListEntry
{
   var background;
   var selectIndicator;
   var _layoutUpdateCount = -1;
   function TabularListEntry()
   {
      super();
   }
   function setEntry(a_entryObject, a_state)
   {
      var _loc10_ = skyui.components.list.TabularList(a_state.list).layout;
      this.selectIndicator._visible = a_entryObject == a_state.list.selectedEntry;
      var _loc11_ = _loc10_.layoutUpdateCount;
      if(this._layoutUpdateCount != _loc11_)
      {
         this._layoutUpdateCount = _loc11_;
         this.setEntryLayout(a_entryObject,a_state);
         this.setSpecificEntryLayout(a_entryObject,a_state);
      }
      var _loc6_ = 0;
      var _loc3_;
      var _loc2_;
      var _loc5_;
      var _loc9_;
      var _loc8_;
      while(_loc6_ < _loc10_.columnCount)
      {
         _loc3_ = _loc10_.columnLayoutData[_loc6_];
         _loc2_ = this[_loc3_.stageName];
         _loc5_ = _loc3_.entryValue;
         if(_loc5_ != undefined)
         {
            if(_loc5_.charAt(0) == "@")
            {
               _loc9_ = a_entryObject[_loc5_.slice(1)];
               _loc2_.SetText(_loc9_ == undefined ? "-" : _loc9_);
            }
            else
            {
               _loc2_.SetText(_loc5_);
            }
         }
         switch(_loc3_.type)
         {
            case skyui.components.list.ListLayout.COL_TYPE_EQUIP_ICON:
               this.formatEquipIcon(_loc2_,a_entryObject,a_state);
               break;
            case skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON:
               this.formatItemIcon(_loc2_,a_entryObject,a_state);
               break;
            case skyui.components.list.ListLayout.COL_TYPE_NAME:
               this.formatName(_loc2_,a_entryObject,a_state);
               break;
            case skyui.components.list.ListLayout.COL_TYPE_TEXT:
            default:
               this.formatText(_loc2_,a_entryObject,a_state);
         }
         if(_loc3_.colorAttribute != undefined)
         {
            _loc8_ = a_entryObject[_loc3_.colorAttribute];
            if(_loc8_ != undefined)
            {
               _loc2_.textColor = _loc8_;
            }
         }
         _loc6_ = _loc6_ + 1;
      }
   }
   function setSpecificEntryLayout(a_entryObject, a_state)
   {
   }
   function formatName(a_entryField, a_entryObject, a_state)
   {
   }
   function formatEquipIcon(a_entryField, a_entryObject, a_state)
   {
   }
   function formatItemIcon(a_entryField, a_entryObject, a_state)
   {
   }
   function formatText(a_entryField, a_entryObject, a_state)
   {
   }
   function setEntryLayout(a_entryObject, a_state)
   {
      var _loc5_ = skyui.components.list.TabularList(a_state.list).layout;
      this.background._width = this.selectIndicator._width = _loc5_.entryWidth;
      this.background._height = this.selectIndicator._height = _loc5_.entryHeight;
      var _loc4_ = 0;
      var _loc2_;
      var _loc3_;
      while(_loc4_ < _loc5_.columnCount)
      {
         _loc2_ = _loc5_.columnLayoutData[_loc4_];
         _loc3_ = this[_loc2_.stageName];
         _loc3_._visible = true;
         _loc3_._x = _loc2_.x;
         _loc3_._y = _loc2_.y;
         if(_loc2_.width > 0)
         {
            _loc3_._width = _loc2_.width;
         }
         if(_loc2_.height > 0)
         {
            _loc3_._height = _loc2_.height;
         }
         if(_loc3_ instanceof TextField)
         {
            _loc3_.setTextFormat(_loc2_.textFormat);
         }
         _loc4_ = _loc4_ + 1;
      }
      var _loc6_ = _loc5_.hiddenStageNames;
      _loc4_ = 0;
      while(_loc4_ < _loc6_.length)
      {
         this[_loc6_[_loc4_]]._visible = false;
         _loc4_ = _loc4_ + 1;
      }
   }
}
