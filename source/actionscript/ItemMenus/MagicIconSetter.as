class MagicIconSetter implements skyui.components.list.IListProcessor
{
   var _noIconColors;
   var _list;

   function MagicIconSetter(a_configAppearance)
   {
      this._noIconColors = a_configAppearance.icons.item.noColor;
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
         
         if (entry != undefined && !entry.skyui_iconProcessed && entry.skyui_itemDataProcessed) {
               var chunkEnd = Math.min(i + batchSize, totalEntries);
               
               for (var j = i; j < chunkEnd; j++) {
                  var batchEntry = listEnum.at(j);
                  if (batchEntry != undefined && !batchEntry.skyui_iconProcessed && batchEntry.skyui_itemDataProcessed) {
                     this.processEntry(batchEntry);
                     batchEntry.skyui_iconProcessed = true;
                  }
               }
               break;
         }
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
      this.processSpellBaseId(a_entryObject);
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
   function processSpellBaseId(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case 0x38B5:
         case 0x3F52:
         case 0x38B6:
            a_entryObject.iconLabel = "magic_sun";
            a_entryObject.iconColor = 16746240;
            break;
         case 0x1D74B:
            a_entryObject.iconLabel = "misc_remains";
            a_entryObject.iconColor = 6465078;
            break;
         case 0x1772D:
            a_entryObject.iconLabel = "magic_wind";
            a_entryObject.iconColor = 13487044;
            break;
         case 0x72320:
         case 0x72311:
         case 0x7233B:
            a_entryObject.iconLabel = "magic_fire";
            a_entryObject.iconColor = 2096127;
            break;
      }
   }
}
