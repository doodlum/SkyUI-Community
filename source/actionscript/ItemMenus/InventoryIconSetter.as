class InventoryIconSetter implements skyui.components.list.IListProcessor
{
   // Lookup tables built once from skyui.defines (see buildTables).
   //
   // AS2 does not inline static constants: every `case skyui.defines.Armor.EQUIP_HEAD:` is resolved through
   // _global at runtime, and a switch evaluates its cases in order until one matches. processEntry used to
   // walk several such switches per entry, which dominated list rebuild time for large inventories (#207).
   // The tables give the same results with one or two property lookups per entry.
   static var _tables;

   var _noIconColors;

   function InventoryIconSetter(a_configAppearance)
   {
      this._noIconColors = a_configAppearance.icons.item.noColor;
      if(InventoryIconSetter._tables == undefined)
      {
         InventoryIconSetter._tables = InventoryIconSetter.buildTables();
      }
   }

   function processList(a_list)
   {
      var entryList = a_list.entryList;
      var t = InventoryIconSetter._tables;
      var noIconColors = this._noIconColors;
      var len = entryList.length;
      for(var i = 0; i < len; i++)
      {
         var e = entryList[i];
         InventoryIconSetter.processEntryWith(t, e);
         if(noIconColors && e.iconColor != undefined)
         {
            delete e.iconColor;
         }
      }
   }

   function processEntry(a_entryObject)
   {
      InventoryIconSetter.processEntryWith(InventoryIconSetter._tables, a_entryObject);
      if(this._noIconColors && a_entryObject.iconColor != undefined)
      {
         delete a_entryObject.iconColor;
      }
   }

   static function processEntryWith(t, e)
   {
      switch(t.formKind[e.formType])
      {
         case 1: // scroll
            e.iconLabel = "default_scroll";
            if(e.subType == t.scrollSpider)
            {
               e.iconLabel = "scroll_spider";
            }
            if(e.resistance != undefined && e.resistance != t.avNone)
            {
               var rc = t.resistColor[e.resistance];
               if(rc != undefined)
               {
                  e.iconColor = rc;
               }
            }
            break;
         case 2: // armor
            InventoryIconSetter.processArmorIcon(t, e);
            break;
         case 3: // book
            e.iconLabel = "default_book";
            var bl = t.book[e.subType];
            if(bl != undefined)
            {
               e.iconLabel = bl;
               if(e.subType == t.bookElderScroll)
               {
                  e.iconColor = 7693901;
               }
            }
            break;
         case 4:
            e.iconLabel = "default_ingredient";
            break;
         case 5:
            e.iconLabel = "misc_torch";
            break;
         case 6: // misc
            if(e.iconLabel == undefined)
            {
               e.iconLabel = "default_misc";
               var m = t.misc[e.subType];
               if(m != undefined)
               {
                  e.iconLabel = m.l;
                  if(m.c != undefined)
                  {
                     e.iconColor = m.c;
                  }
               }
            }
            if(e.formId >>> 24 == 0xFE && e.eslId == t.eslPetAmulet)
            {
               e.iconLabel = "armor_amulet";
            }
            break;
         case 7: // weapon
            e.iconLabel = "default_weapon";
            e.iconColor = 10790335;
            var wl = t.weapon[e.subType];
            if(wl != undefined)
            {
               e.iconLabel = wl;
            }
            break;
         case 8: // ammo
            e.iconLabel = "weapon_arrow";
            e.iconColor = 11050636;
            if(e.subType == t.ammoBolt)
            {
               e.iconLabel = "weapon_bolt";
            }
            break;
         case 9:
            e.iconLabel = "default_key";
            break;
         case 10: // potion
            e.iconLabel = "default_potion";
            var p = t.potion[e.subType];
            if(p != undefined)
            {
               e.iconLabel = p.l;
               if(p.c != undefined)
               {
                  e.iconColor = p.c;
               }
            }
            break;
         case 11:
            InventoryIconSetter.processSoulGemIcon(e);
      }
   }

   static function processArmorIcon(t, e)
   {
      e.iconLabel = "default_armor";
      e.iconColor = 15587975;
      var subType = e.subType;
      if(subType == t.equipCloak)
      {
         e.iconLabel = "clothing_cloak";
         return;
      }
      if(subType == t.equipBackpack)
      {
         e.iconLabel = "clothing_backpack";
         return;
      }
      var label;
      switch(t.weightKind[e.weightClass])
      {
         case 1: // light
            e.iconColor = 0x6B4D16;
            label = t.lightArmor[subType];
            if(label == undefined)
            {
               label = t.jewelry[subType];
            }
            break;
         case 2: // heavy
            e.iconColor = 7042437;
            label = t.heavyArmor[subType];
            if(label == undefined)
            {
               label = t.jewelry[subType];
            }
            break;
         case 3: // jewelry
            label = t.jewelry[subType];
            break;
         default: // clothing
            label = t.clothing[subType];
      }
      if(label != undefined)
      {
         e.iconLabel = label;
      }
   }

   // Soul gems are rare in a list; kept as switches.
   static function processSoulGemIcon(a_entryObject)
   {
      a_entryObject.iconLabel = "misc_soulgem";
      a_entryObject.iconColor = 14934271;
      switch(a_entryObject.subType)
      {
         case skyui.defines.Item.SOULGEM_PETTY:
            a_entryObject.iconColor = 14144767;
            InventoryIconSetter.processSoulGemStatusIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_LESSER:
            a_entryObject.iconColor = 12630783;
            InventoryIconSetter.processSoulGemStatusIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_COMMON:
            a_entryObject.iconColor = 11248639;
            InventoryIconSetter.processSoulGemStatusIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_GREATER:
            a_entryObject.iconColor = 9735164;
            InventoryIconSetter.processGrandSoulGemIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_GRAND:
            a_entryObject.iconColor = 7694847;
            InventoryIconSetter.processGrandSoulGemIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_SOULTOMATO:
            a_entryObject.iconColor = 13716024;
            InventoryIconSetter.processSoulTomatoIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_AZURA:
            a_entryObject.iconColor = 7694847;
            a_entryObject.iconLabel = "soulgem_azura";
         default:
            return;
      }
   }

   static function processSoulTomatoIcon(a_entryObject)
   {
      switch(a_entryObject.status)
      {
         case skyui.defines.Item.SOULGEMSTATUS_EMPTY:
            a_entryObject.iconLabel = "soulgem_tomatoempty";
            break;
         case skyui.defines.Item.SOULGEMSTATUS_PARTIAL:
            a_entryObject.iconLabel = "soulgem_tomatopartial";
            break;
         case skyui.defines.Item.SOULGEMSTATUS_FULL:
            a_entryObject.iconLabel = "soulgem_tomatofull";
         default:
            return;
      }
   }

   static function processGrandSoulGemIcon(a_entryObject)
   {
      switch(a_entryObject.status)
      {
         case skyui.defines.Item.SOULGEMSTATUS_EMPTY:
            a_entryObject.iconLabel = "soulgem_grandempty";
            break;
         case skyui.defines.Item.SOULGEMSTATUS_FULL:
            a_entryObject.iconLabel = "soulgem_grandfull";
            break;
         case skyui.defines.Item.SOULGEMSTATUS_PARTIAL:
            a_entryObject.iconLabel = "soulgem_grandpartial";
         default:
            return;
      }
   }

   static function processSoulGemStatusIcon(a_entryObject)
   {
      switch(a_entryObject.status)
      {
         case skyui.defines.Item.SOULGEMSTATUS_EMPTY:
            a_entryObject.iconLabel = "soulgem_empty";
            break;
         case skyui.defines.Item.SOULGEMSTATUS_FULL:
            a_entryObject.iconLabel = "soulgem_full";
            break;
         case skyui.defines.Item.SOULGEMSTATUS_PARTIAL:
            a_entryObject.iconLabel = "soulgem_partial";
         default:
            return;
      }
   }

   // First assignment wins, matching switch semantics if two defines ever share a value.
   static function put(a_map, a_key, a_value)
   {
      if(a_key != undefined && a_map[a_key] == undefined)
      {
         a_map[a_key] = a_value;
      }
   }

   static function buildTables()
   {
      var Form = skyui.defines.Form;
      var Armor = skyui.defines.Armor;
      var Weapon = skyui.defines.Weapon;
      var Item = skyui.defines.Item;
      var Actor = skyui.defines.Actor;
      var put = InventoryIconSetter.put;
      var t = {};

      t.formKind = {};
      put(t.formKind, Form.TYPE_SCROLLITEM, 1);
      put(t.formKind, Form.TYPE_ARMOR, 2);
      put(t.formKind, Form.TYPE_BOOK, 3);
      put(t.formKind, Form.TYPE_INGREDIENT, 4);
      put(t.formKind, Form.TYPE_LIGHT, 5);
      put(t.formKind, Form.TYPE_MISC, 6);
      put(t.formKind, Form.TYPE_WEAPON, 7);
      put(t.formKind, Form.TYPE_AMMO, 8);
      put(t.formKind, Form.TYPE_KEY, 9);
      put(t.formKind, Form.TYPE_POTION, 10);
      put(t.formKind, Form.TYPE_SOULGEM, 11);

      t.avNone = Actor.AV_NONE;
      t.resistColor = {};
      put(t.resistColor, Actor.AV_FIRERESIST, 13055542);
      put(t.resistColor, Actor.AV_ELECTRICRESIST, 16776960);
      put(t.resistColor, Actor.AV_FROSTRESIST, 2096127);

      t.scrollSpider = Item.SCROLL_SPIDER;
      t.eslPetAmulet = Form.ESLID_CCVSV002PETAMULET;
      t.ammoBolt = Weapon.AMMO_BOLT;
      t.bookElderScroll = Item.BOOK_ELDERSCROLL;
      t.equipCloak = Armor.EQUIP_CLOAK;
      t.equipBackpack = Armor.EQUIP_BACKPACK;

      t.weightKind = {};
      put(t.weightKind, Armor.WEIGHT_LIGHT, 1);
      put(t.weightKind, Armor.WEIGHT_HEAVY, 2);
      put(t.weightKind, Armor.WEIGHT_JEWELRY, 3);

      t.lightArmor = InventoryIconSetter.armorTable("lightarmor_");
      t.heavyArmor = InventoryIconSetter.armorTable("armor_");
      t.clothing = InventoryIconSetter.armorTable("clothing_");
      t.jewelry = {};
      put(t.jewelry, Armor.EQUIP_AMULET, "armor_amulet");
      put(t.jewelry, Armor.EQUIP_RING, "armor_ring");
      put(t.jewelry, Armor.EQUIP_CIRCLET, "armor_circlet");

      t.book = {};
      put(t.book, Item.BOOK_RECIPE, "book_note");
      put(t.book, Item.BOOK_NOTE, "book_note");
      put(t.book, Item.BOOK_SPELLTOME, "book_tome");
      put(t.book, Item.BOOK_MAP, "book_map");
      put(t.book, Item.BOOK_ELDERSCROLL, "misc_elderscroll");

      t.weapon = {};
      put(t.weapon, Weapon.TYPE_SWORD, "weapon_sword");
      put(t.weapon, Weapon.TYPE_DAGGER, "weapon_dagger");
      put(t.weapon, Weapon.TYPE_WARAXE, "weapon_waraxe");
      put(t.weapon, Weapon.TYPE_MACE, "weapon_mace");
      put(t.weapon, Weapon.TYPE_GREATSWORD, "weapon_greatsword");
      put(t.weapon, Weapon.TYPE_BATTLEAXE, "weapon_battleaxe");
      put(t.weapon, Weapon.TYPE_WARHAMMER, "weapon_hammer");
      put(t.weapon, Weapon.TYPE_BOW, "weapon_bow");
      put(t.weapon, Weapon.TYPE_STAFF, "weapon_staff");
      put(t.weapon, Weapon.TYPE_CROSSBOW, "weapon_crossbow");
      put(t.weapon, Weapon.TYPE_PICKAXE, "weapon_pickaxe");
      put(t.weapon, Weapon.TYPE_FISHINGROD, "weapon_fishingrod");
      put(t.weapon, Weapon.TYPE_WOODAXE, "weapon_woodaxe");

      t.potion = {};
      put(t.potion, Item.POTION_DRINK, {l:"food_wine"});
      put(t.potion, Item.POTION_FOOD, {l:"default_food"});
      put(t.potion, Item.POTION_POISON, {l:"potion_poison", c:11337907});
      put(t.potion, Item.POTION_HEALTH, {l:"potion_health", c:14364275});
      put(t.potion, Item.POTION_HEALRATE, {l:"potion_health", c:14364275});
      put(t.potion, Item.POTION_HEALRATEMULT, {l:"potion_health", c:14364275});
      put(t.potion, Item.POTION_MAGICKA, {l:"potion_magic", c:3055579});
      put(t.potion, Item.POTION_MAGICKARATE, {l:"potion_magic", c:3055579});
      put(t.potion, Item.POTION_MAGICKARATEMULT, {l:"potion_magic", c:3055579});
      put(t.potion, Item.POTION_STAMINA, {l:"potion_stam", c:5364526});
      put(t.potion, Item.POTION_STAMINARATE, {l:"potion_stam", c:5364526});
      put(t.potion, Item.POTION_STAMINARATEMULT, {l:"potion_stam", c:5364526});
      put(t.potion, Item.POTION_FIRERESIST, {l:"potion_fire", c:13055542});
      put(t.potion, Item.POTION_ELECTRICRESIST, {l:"potion_shock", c:15379200});
      put(t.potion, Item.POTION_AYLEIDCRYSTAL, {l:"soulgem_ayleidcrystalfull", c:6014153});
      put(t.potion, Item.POTION_FROSTRESIST, {l:"potion_frost", c:2096127});

      t.misc = {};
      put(t.misc, Item.MISC_ARTIFACT, {l:"misc_artifact"});
      put(t.misc, Item.MISC_GEM, {l:"misc_gem", c:16756945});
      put(t.misc, Item.MISC_HIDE, {l:"misc_hide", c:14398318});
      put(t.misc, Item.MISC_REMAINS, {l:"misc_remains"});
      put(t.misc, Item.MISC_INGOT, {l:"misc_ingot", c:8553090});
      put(t.misc, Item.MISC_CLUTTER, {l:"misc_clutter"});
      put(t.misc, Item.MISC_FIREWOOD, {l:"misc_wood", c:12553824});
      put(t.misc, Item.MISC_DRAGONCLAW, {l:"misc_dragonclaw"});
      put(t.misc, Item.MISC_LOCKPICK, {l:"misc_lockpick"});
      put(t.misc, Item.MISC_GOLD, {l:"misc_gold", c:13421619});
      put(t.misc, Item.MISC_LEATHER, {l:"misc_leather", c:12225827});
      put(t.misc, Item.MISC_NETCHLEATHER, {l:"misc_strips", c:7886222});
      put(t.misc, Item.MISC_LEATHERSTRIPS, {l:"misc_strips", c:12225827});
      put(t.misc, Item.MISC_TROLLSKULL, {l:"misc_trollskull"});
      put(t.misc, Item.MISC_CHILDRENSCLOTHES, {l:"clothing_body", c:15587975});
      put(t.misc, Item.MISC_ORE, {l:"misc_ore", c:8553090});
      put(t.misc, Item.MISC_HOUSEPART, {l:"misc_housepart", c:16777215});
      put(t.misc, Item.MISC_BROKENWEAPON, {l:"default_weapon", c:16777215});
      put(t.misc, Item.MISC_AYLEIDCRYSTAL, {l:"soulgem_ayleidcrystalfull", c:6014153});
      put(t.misc, Item.MISC_HORSETACK, {l:"misc_horsetack"});
      put(t.misc, Item.MISC_DWARVENSCRAP, {l:"misc_dwarvenscrap", c:7364402});
      put(t.misc, Item.MISC_SCROLLSPIDER, {l:"scroll_spider"});
      put(t.misc, Item.MISC_INSTRUMENT, {l:"misc_instrument", c:16777215});
      put(t.misc, Item.MISC_BUGJAR, {l:"misc_jar", c:16777215});
      put(t.misc, Item.MISC_MAP, {l:"book_map"});
      put(t.misc, Item.MISC_POTION, {l:"default_potion"});
      put(t.misc, Item.MISC_POISON, {l:"potion_poison"});
      put(t.misc, Item.MISC_SCROLL, {l:"default_scroll"});
      put(t.misc, Item.MISC_BOOK, {l:"default_book"});
      put(t.misc, Item.MISC_RING, {l:"armor_ring"});
      put(t.misc, Item.MISC_INGREDIENT, {l:"default_ingredient"});
      put(t.misc, Item.MISC_PETGEAR, {l:"clothing_backpack"});

      return t;
   }

   // Slot -> icon suffix shared by the light armor, heavy armor and clothing icon sets.
   static function armorTable(a_prefix)
   {
      var Armor = skyui.defines.Armor;
      var put = InventoryIconSetter.put;
      var m = {};
      put(m, Armor.EQUIP_HEAD, a_prefix + "head");
      put(m, Armor.EQUIP_HAIR, a_prefix + "head");
      put(m, Armor.EQUIP_LONGHAIR, a_prefix + "head");
      put(m, Armor.EQUIP_BODY, a_prefix + "body");
      put(m, Armor.EQUIP_TAIL, a_prefix + "body");
      put(m, Armor.EQUIP_HANDS, a_prefix + "hands");
      put(m, Armor.EQUIP_FOREARMS, a_prefix + "forearms");
      put(m, Armor.EQUIP_FEET, a_prefix + "feet");
      put(m, Armor.EQUIP_CALVES, a_prefix + "calves");
      put(m, Armor.EQUIP_SHIELD, a_prefix + "shield");
      return m;
   }
}
