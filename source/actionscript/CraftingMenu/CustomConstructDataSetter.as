class CustomConstructDataSetter implements skyui.components.list.IListProcessor
{
   function CustomConstructDataSetter()
   {
      super();
   }
   function processList(a_list)
   {
      if (this._list == a_list) return;
      if (this._list) this._list.removeEventListener("listUpdate", this, "onListUpdate");
      this._list = a_list;
      if (this._list) this._list.addEventListener("listUpdate", this, "onListUpdate");
   }
   
   function onListUpdate(event: Object)
   {
      var listEnum = this._list.listEnumeration;
      if (listEnum == undefined) return;

      var visibleCount = Math.max(1, this._list.maxListIndex + 1);
      var batchSize = visibleCount * 2;
      
      var startIdx = this._list.scrollPosition;
      var endIdx = Math.min(startIdx + visibleCount, listEnum.size());
      
      var totalEntries = listEnum.size();

      for (var i = startIdx; i < endIdx; i++) {
         var entry = listEnum.at(i);
         
         if (entry != undefined && entry.oldFilterFlag == undefined && entry.filterFlag != 0) {
            var chunkEnd = Math.min(i + batchSize, totalEntries);
            
            for (var j = i; j < chunkEnd; j++) {
               var batchEntry = listEnum.at(j);
               
               if (batchEntry != undefined && batchEntry.oldFilterFlag == undefined && batchEntry.filterFlag != 0) {
                  batchEntry.oldFilterFlag = batchEntry.filterFlag;
                  this.processEntry(batchEntry);
               }
            }
            break;
         }
      }
   }
   function processEntry(a_entryObject)
   {
      var _loc2_ = false;
      switch(a_entryObject.oldFilterFlag)
      {
         case skyui.defines.Inventory.FILTERFLAG_CRAFT_JEWELRY:
            a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_JEWELRY;
            _loc2_ = true;
            break;
         case skyui.defines.Inventory.FILTERFLAG_CRAFT_FOOD:
            a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_FOOD;
            _loc2_ = true;
      }
      if(_loc2_)
      {
         return undefined;
      }
      switch(a_entryObject.formType)
      {
         case skyui.defines.Form.TYPE_ARMOR:
            a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_ARMOR;
            return;
         case skyui.defines.Form.TYPE_INGREDIENT:
            a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_FOOD;
            return;
         case skyui.defines.Form.TYPE_WEAPON:
            a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_WEAPONS;
            return;
         case skyui.defines.Form.TYPE_AMMO:
            a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_AMMO;
            return;
         case skyui.defines.Form.TYPE_POTION:
            a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_FOOD;
            return;
         default:
            a_entryObject.filterFlag = skyui.defines.Inventory.FILTERFLAG_CUST_CRAFT_MISC;
            return;
      }
   }
}
