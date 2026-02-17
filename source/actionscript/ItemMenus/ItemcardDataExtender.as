class ItemcardDataExtender implements skyui.components.list.IListProcessor
{
   var _itemInfo;
   var _requestItemInfo;
   var _selectedIndex;
   function ItemcardDataExtender()
   {
      this._requestItemInfo = function(a_target, a_index)
      {
         var _loc2_ = this._selectedIndex;
         this._selectedIndex = a_index;
         gfx.io.GameDelegate.call("RequestItemCardInfo",[],a_target,"updateItemInfo");
         this._selectedIndex = _loc2_;
      };
   }
   function updateItemInfo(a_updateObj)
   {
      this._itemInfo = a_updateObj;
   }
   function processList(a_list)
   {
      var _loc4_ = a_list.entryList;
      var _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < _loc4_.length)
      {
         _loc2_ = _loc4_[_loc3_];
         if(!(_loc2_.skyui_itemDataProcessed || _loc2_.filterFlag == 0))
         {
            _loc2_.skyui_itemDataProcessed = true;
            this.fixSKSEExtendedObject(_loc2_);
            this._requestItemInfo.apply(a_list,[this,_loc3_]);
            this.processEntry(_loc2_,this._itemInfo);
         }
         _loc3_ = _loc3_ + 1;
      }
   }
   function processEntry(a_entryObject, a_itemInfo)
   {
   }
   function fixSKSEExtendedObject(a_extendedObject)
   {
      if(a_extendedObject.formType == undefined)
      {
         return undefined;
      }
      var _loc2_;
      switch(a_extendedObject.formType)
      {
         case skyui.defines.Form.TYPE_SPELL:
         case skyui.defines.Form.TYPE_SCROLLITEM:
         case skyui.defines.Form.TYPE_INGREDIENT:
         case skyui.defines.Form.TYPE_POTION:
         case skyui.defines.Form.TYPE_EFFECTSETTING:
            if(a_extendedObject.school == undefined && a_extendedObject.subType != undefined)
            {
               a_extendedObject.school = a_extendedObject.subType;
               delete a_extendedObject.subType;
            }
            if(a_extendedObject.resistance == undefined && a_extendedObject.magicType != undefined)
            {
               a_extendedObject.resistance = a_extendedObject.magicType;
               delete a_extendedObject.magicType;
            }
            break;
         case skyui.defines.Form.TYPE_WEAPON:
            if(a_extendedObject.weaponType == undefined && a_extendedObject.subType != undefined)
            {
               a_extendedObject.weaponType = a_extendedObject.subType;
               delete a_extendedObject.subType;
            }
            break;
         case skyui.defines.Form.TYPE_BOOK:
            if(a_extendedObject.flags == undefined && a_extendedObject.bookType != undefined)
            {
               _loc2_ = a_extendedObject.bookType;
               a_extendedObject.bookType = (_loc2_ & 0xFF00) >>> 8;
               a_extendedObject.flags = _loc2_ & 0xFF;
            }
         default:
            return;
      }
   }
}
