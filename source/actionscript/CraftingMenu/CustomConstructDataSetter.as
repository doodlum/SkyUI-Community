class CustomConstructDataSetter implements skyui.components.list.IListProcessor
{
   function CustomConstructDataSetter()
   {
      super();
   }
   function processList(a_list)
   {
      var _loc4_ = a_list.entryList;
      var _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < _loc4_.length)
      {
         _loc2_ = _loc4_[_loc3_];
         if(!(_loc2_.oldFilterFlag != undefined || _loc2_.filterFlag == 0))
         {
            _loc2_.oldFilterFlag = _loc2_.filterFlag;
            this.processEntry(_loc2_);
         }
         _loc3_ = _loc3_ + 1;
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
