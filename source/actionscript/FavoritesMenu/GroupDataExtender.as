class GroupDataExtender implements skyui.components.list.IListProcessor
{
   var _groupButtons;
   var _invalidItems;
   var _itemIdMap;
   var groupData;
   var iconData;
   var mainHandData;
   var offHandData;
   static var GROUP_SIZE = 32;
   function GroupDataExtender(a_groupButtons)
   {
      this.groupData = [];
      this.mainHandData = [];
      this.offHandData = [];
      this.iconData = [];
      this._itemIdMap = {};
      this._invalidItems = [];
      this._groupButtons = a_groupButtons;
   }
   function processList(a_list)
   {
      var _loc7_ = int(this.groupData.length / GroupDataExtender.GROUP_SIZE);
      var _loc6_ = 0;
      var _loc3_ = 0;
      while(_loc3_ < _loc7_)
      {
         _loc6_ |= FilterDataExtender.FILTERFLAG_GROUP_0 << _loc3_;
         _loc3_ = _loc3_ + 1;
      }
      var _loc5_ = a_list.entryList;
      var _loc4_ = 0;
      var _loc2_;
      while(_loc4_ < _loc5_.length)
      {
         _loc2_ = _loc5_[_loc4_];
         _loc2_.filterFlag &= ~_loc6_;
         _loc2_.mainHandFlag = 0;
         _loc2_.offHandFlag = 0;
         if(_loc2_.itemId != undefined)
         {
            this._itemIdMap[_loc2_.itemId] = _loc2_;
         }
         _loc4_ = _loc4_ + 1;
      }
      this.processGroupData();
      this.processMainHandData();
      this.processOffHandData();
      this.processIconData();
   }
   function processGroupData()
   {
      var _loc5_ = 0;
      var _loc6_ = FilterDataExtender.FILTERFLAG_GROUP_0;
      var _loc3_ = 0;
      var _loc2_;
      var _loc4_;
      while(_loc3_ < this.groupData.length)
      {
         if(_loc5_ == GroupDataExtender.GROUP_SIZE)
         {
            _loc6_ <<= 1;
            _loc5_ = 0;
         }
         _loc2_ = this.groupData[_loc3_];
         if(_loc2_)
         {
            _loc4_ = this._itemIdMap[_loc2_];
            if(_loc4_ != null)
            {
               _loc4_.filterFlag |= _loc6_;
            }
            else
            {
               this.reportInvalidItem(_loc2_);
            }
         }
         _loc3_++;
         _loc5_++;
      }
   }
   function processMainHandData()
   {
      var _loc2_ = 0;
      var _loc3_;
      var _loc4_;
      while(_loc2_ < this.mainHandData.length)
      {
         _loc3_ = this.mainHandData[_loc2_];
         if(_loc3_)
         {
            _loc4_ = this._itemIdMap[_loc3_];
            if(_loc4_ != null)
            {
               _loc4_.mainHandFlag |= 1 << _loc2_;
            }
            else
            {
               this.reportInvalidItem(_loc3_);
            }
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function processOffHandData()
   {
      var _loc2_ = 0;
      var _loc3_;
      var _loc4_;
      while(_loc2_ < this.offHandData.length)
      {
         _loc3_ = this.offHandData[_loc2_];
         if(_loc3_)
         {
            _loc4_ = this._itemIdMap[_loc3_];
            if(_loc4_ != null)
            {
               _loc4_.offHandFlag |= 1 << _loc2_;
            }
            else
            {
               this.reportInvalidItem(_loc3_);
            }
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function processIconData()
   {
      var _loc2_ = 0;
      var _loc4_;
      var _loc5_;
      var _loc3_;
      while(_loc2_ < this.iconData.length)
      {
         _loc5_ = this.iconData[_loc2_];
         if(_loc5_)
         {
            _loc3_ = this._itemIdMap[_loc5_];
            if(_loc3_ != null)
            {
               _loc4_ = !_loc3_.iconLabel ? "misc_default" : _loc3_.iconLabel;
            }
            else
            {
               _loc4_ = "misc_default";
               this.reportInvalidItem(_loc5_);
            }
         }
         else
         {
            _loc4_ = "none";
         }
         this._groupButtons[_loc2_].itemIcon.gotoAndStop(_loc4_);
         _loc2_ = _loc2_ + 1;
      }
   }
   function reportInvalidItem(a_itemId)
   {
      var _loc2_ = 0;
      while(_loc2_ < this._invalidItems.length)
      {
         if(this._invalidItems[_loc2_] == a_itemId)
         {
            return undefined;
         }
         _loc2_ = _loc2_ + 1;
      }
      this._invalidItems.push(a_itemId);
      skse.SendModEvent("SKIFM_foundInvalidItem",String(a_itemId));
   }
}
