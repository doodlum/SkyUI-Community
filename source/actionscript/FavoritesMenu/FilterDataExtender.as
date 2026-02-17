class FilterDataExtender implements skyui.components.list.IListProcessor
{
   static var FILTERFLAG_ALL = 15;
   static var FILTERFLAG_DEFAULT = 1;
   static var FILTERFLAG_GEAR = 2;
   static var FILTERFLAG_AID = 4;
   static var FILTERFLAG_MAGIC = 8;
   static var FILTERFLAG_GROUP_ADD = 16;
   static var FILTERFLAG_GROUP_0 = 32;
   function FilterDataExtender()
   {
   }
   function processList(a_list)
   {
      var _loc4_ = a_list.entryList;
      var _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < _loc4_.length)
      {
         _loc2_ = _loc4_[_loc3_];
         if(!_loc2_.skyui_itemDataProcessed)
         {
            _loc2_.skyui_itemDataProcessed = true;
            this.processEntry(_loc2_);
         }
         _loc3_ = _loc3_ + 1;
      }
   }
   function processEntry(a_entryObject)
   {
      a_entryObject.itemId &= 4294967295;
      var _loc2_ = a_entryObject.formType;
      switch(_loc2_)
      {
         case skyui.defines.Form.TYPE_ARMOR:
         case skyui.defines.Form.TYPE_AMMO:
         case skyui.defines.Form.TYPE_WEAPON:
         case skyui.defines.Form.TYPE_LIGHT:
            a_entryObject.filterFlag = FilterDataExtender.FILTERFLAG_GEAR;
            return;
         case skyui.defines.Form.TYPE_INGREDIENT:
         case skyui.defines.Form.TYPE_POTION:
            a_entryObject.filterFlag = FilterDataExtender.FILTERFLAG_AID;
            return;
         case skyui.defines.Form.TYPE_SPELL:
         case skyui.defines.Form.TYPE_SHOUT:
         case skyui.defines.Form.TYPE_SCROLLITEM:
            a_entryObject.filterFlag = FilterDataExtender.FILTERFLAG_MAGIC;
            return;
         case skyui.defines.Form.TYPE_BOOK:
         case skyui.defines.Form.TYPE_EFFECTSETTING:
         default:
            a_entryObject.filterFlag = FilterDataExtender.FILTERFLAG_DEFAULT;
            return;
      }
   }
}
