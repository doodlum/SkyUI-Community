class ItemcardDataExtender implements skyui.components.list.IListProcessor
{
   var _itemInfo;
   var _requestItemInfo;
   var _selectedIndex;
   var _list;

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
      if (this._list != a_list)
      {
         if (this._list)
            this._list.removeEventListener("listUpdate", this, "onListUpdate");
         
         this._list = a_list;
         this._list.addEventListener("listUpdate", this, "onListUpdate");
      }
   }

   function onListUpdate(event: Object)
   {
      var listEnum = this._list.listEnumeration;
      if (listEnum == undefined) return;

      var maxVisible = this._list.maxListIndex;
      var batchSize = maxVisible * 2;
      
      var startIdx = this._list.scrollPosition;
      var endIdx = Math.min(startIdx + maxVisible, listEnum.size());
      
      var totalEntries = listEnum.size();
      
      for (var i = startIdx; i < endIdx; i++) {
         var entry = listEnum.at(i);
         
         if (entry != undefined && !entry.skyui_itemDataProcessed && entry.filterFlag != 0) {
               var chunkEnd = Math.min(i + batchSize, totalEntries);
               
            for (var j = i; j < chunkEnd; j++) {
               var batchEntry = listEnum.at(j);
               if (batchEntry != undefined && !batchEntry.skyui_itemDataProcessed) {
                  batchEntry.skyui_itemDataProcessed = true;
                  
                  this.fixSKSEExtendedObject(batchEntry);
                  this._requestItemInfo.apply(this._list, [this, batchEntry.itemIndex]);
                  this.processEntry(batchEntry, this._itemInfo);
               }
            }
            break;
         }
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
