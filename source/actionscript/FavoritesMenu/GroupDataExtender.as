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
      var _loc3_;
      while(_loc2_ < this.iconData.length)
      {
         _loc3_ = new MovieClipLoader();
         _loc3_.addListener(this);
         _loc3_.loadClip("skyui/icons_item_psychosteve.swf",this._groupButtons[_loc2_].itemIcon);
         this._groupButtons[_loc2_].itemIcon._visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
   function onLoadInit(a_icon)
   {
      var _loc2_ = 0;
      while(_loc2_ < this._groupButtons.length)
      {
         if(this._groupButtons[_loc2_].itemIcon == a_icon)
         {
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(_loc2_ >= this._groupButtons.length)
      {
         return undefined;
      }
      var _loc3_ = this.iconData[_loc2_];
      var _loc4_;
      var _loc5_;
      if(_loc3_)
      {
         var _loc6_ = this._itemIdMap[_loc3_];
         if(_loc6_ != null)
         {
            _loc4_ = _loc6_.iconLabel;
            _loc5_ = _loc6_.iconColor;
         }
         else
         {
            this.reportInvalidItem(_loc3_);
         }
      }
      a_icon._visible = true;
      a_icon.gotoAndStop(_loc4_ == undefined ? "default_misc" : _loc4_);
      this.changeIconColor(a_icon,_loc5_);
      for(var _loc7_ in a_icon)
      {
         var _loc8_ = a_icon[_loc7_];
         if(_loc8_ instanceof MovieClip)
         {
            var _loc9_ = _loc8_.transform;
            var _loc10_ = _loc9_.matrix;
            _loc10_.translate(-64,-64);
            _loc9_.matrix = _loc10_;
         }
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
