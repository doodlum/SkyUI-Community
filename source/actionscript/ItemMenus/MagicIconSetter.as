class MagicIconSetter implements skyui.components.list.IListProcessor
{
   var _noIconColors;
   function MagicIconSetter(a_configAppearance)
   {
      this._noIconColors = a_configAppearance.icons.item.noColor;
   }
   function processList(a_list)
   {
      var _loc3_ = a_list.entryList;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_.length)
      {
         this.processEntry(_loc3_[_loc2_]);
         _loc2_ = _loc2_ + 1;
      }
   }
   function processEntry(a_entryObject)
   {
      switch(a_entryObject.type)
      {
         case skyui.defines.Inventory.ICT_SPELL:
            this.processSpellIcon(a_entryObject);
            break;
         case skyui.defines.Inventory.ICT_SHOUT:
            a_entryObject.iconLabel = "default_shout";
            break;
         case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
            a_entryObject.iconLabel = "default_effect";
            break;
         case skyui.defines.Inventory.ICT_SPELL_DEFAULT:
            a_entryObject.iconLabel = "default_power";
      }
      if(this._noIconColors && a_entryObject.iconColor != undefined)
      {
         delete a_entryObject.iconColor;
      }
   }
   function processSpellIcon(a_entryObject)
   {
      a_entryObject.iconLabel = "default_power";
      switch(a_entryObject.school)
      {
         case skyui.defines.Actor.AV_ALTERATION:
            a_entryObject.iconLabel = "default_alteration";
            break;
         case skyui.defines.Actor.AV_CONJURATION:
            a_entryObject.iconLabel = "default_conjuration";
            break;
         case skyui.defines.Actor.AV_DESTRUCTION:
            a_entryObject.iconLabel = "default_destruction";
            this.processResist(a_entryObject);
            break;
         case skyui.defines.Actor.AV_ILLUSION:
            a_entryObject.iconLabel = "default_illusion";
            break;
         case skyui.defines.Actor.AV_RESTORATION:
            a_entryObject.iconLabel = "default_restoration";
         default:
            return;
      }
   }
   function processResist(a_entryObject)
   {
      if(a_entryObject.resistance == undefined || a_entryObject.resistance == skyui.defines.Actor.AV_NONE)
      {
         return undefined;
      }
      switch(a_entryObject.resistance)
      {
         case skyui.defines.Actor.AV_FIRERESIST:
            a_entryObject.iconLabel = "magic_fire";
            a_entryObject.iconColor = 13055542;
            break;
         case skyui.defines.Actor.AV_ELECTRICRESIST:
            a_entryObject.iconLabel = "magic_shock";
            a_entryObject.iconColor = 15379200;
            break;
         case skyui.defines.Actor.AV_FROSTRESIST:
            a_entryObject.iconLabel = "magic_frost";
            a_entryObject.iconColor = 2096127;
         default:
            return;
      }
   }
}
