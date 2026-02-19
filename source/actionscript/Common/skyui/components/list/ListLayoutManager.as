class skyui.components.list.ListLayoutManager
{
   static var _initialized = skyui.components.list.ListLayoutManager.initialize();
   function ListLayoutManager()
   {
   }
   static function initialize()
   {
      skyui.util.ConfigManager.setConstant("ITEM_ICON",skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON);
      skyui.util.ConfigManager.setConstant("EQUIP_ICON",skyui.components.list.ListLayout.COL_TYPE_EQUIP_ICON);
      skyui.util.ConfigManager.setConstant("NAME",skyui.components.list.ListLayout.COL_TYPE_NAME);
      skyui.util.ConfigManager.setConstant("TEXT",skyui.components.list.ListLayout.COL_TYPE_TEXT);
      skyui.util.ConfigManager.addConstantTable("skyui.defines.Actor",skyui.defines.Actor);
      skyui.util.ConfigManager.addConstantTable("skyui.defines.Armor",skyui.defines.Armor);
      skyui.util.ConfigManager.addConstantTable("skyui.defines.Form",skyui.defines.Form);
      skyui.util.ConfigManager.addConstantTable("skyui.defines.Input",skyui.defines.Input);
      skyui.util.ConfigManager.addConstantTable("skyui.defines.Inventory",skyui.defines.Inventory);
      skyui.util.ConfigManager.addConstantTable("skyui.defines.Item",skyui.defines.Item);
      skyui.util.ConfigManager.addConstantTable("skyui.defines.Magic",skyui.defines.Magic);
      skyui.util.ConfigManager.addConstantTable("skyui.defines.Material",skyui.defines.Material);
      skyui.util.ConfigManager.addConstantTable("skyui.defines.Weapon",skyui.defines.Weapon);
      return true;
   }
   static function createLayout(a_sectionData, a_name)
   {
      var _loc5_ = a_sectionData.views;
      var _loc4_ = a_sectionData.columns;
      var _loc3_ = a_sectionData.defaults;
      var _loc1_;
      for(var _loc6_ in a_sectionData.layouts)
      {
         _loc1_ = a_sectionData.layouts[_loc6_];
         if(_loc1_.name == a_name)
         {
            return new skyui.components.list.ListLayout(_loc1_,_loc5_,_loc4_,_loc3_);
         }
      }
      return null;
   }
}
