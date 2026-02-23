class InventoryIconSetter implements skyui.components.list.IListProcessor
{
   var _noIconColors;
   function InventoryIconSetter(a_configAppearance)
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
      switch(a_entryObject.formType)
      {
         case skyui.defines.Form.TYPE_SCROLLITEM:
            a_entryObject.iconLabel = "default_scroll";
            this.processResist(a_entryObject);
            this.processScrollBaseIdIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_ARMOR:
            this.processArmorIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_BOOK:
            this.processBookIcon(a_entryObject);
            this.processBookBaseIdIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_INGREDIENT:
            a_entryObject.iconLabel = "default_ingredient";
            break;
         case skyui.defines.Form.TYPE_LIGHT:
            a_entryObject.iconLabel = "misc_torch";
            break;
         case skyui.defines.Form.TYPE_MISC:
            this.processMiscIcon(a_entryObject);
            this.processMiscBaseIdIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_WEAPON:
            this.processWeaponIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_AMMO:
            this.processAmmoIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_KEY:
            a_entryObject.iconLabel = "default_key";
            break;
         case skyui.defines.Form.TYPE_POTION:
            this.processPotionIcon(a_entryObject);
            this.processPotionBaseIdIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_SOULGEM:
            this.processSoulGemIcon(a_entryObject);
            this.processSoulGemBaseIdIcon(a_entryObject);
      }
      if(this._noIconColors && a_entryObject.iconColor != undefined)
      {
         delete a_entryObject.iconColor;
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
            a_entryObject.iconColor = 13055542;
            break;
         case skyui.defines.Actor.AV_ELECTRICRESIST:
            a_entryObject.iconColor = 16776960;
            break;
         case skyui.defines.Actor.AV_FROSTRESIST:
            a_entryObject.iconColor = 2096127;
         default:
            return;
      }
   }
   function processArmorIcon(a_entryObject)
   {
      a_entryObject.iconLabel = "default_armor";
      a_entryObject.iconColor = 15587975;
      if(a_entryObject.subType == skyui.defines.Armor.EQUIP_CLOAK)
      {
         a_entryObject.iconLabel = "clothing_cloak";
         return;
      }
      if(a_entryObject.subType == skyui.defines.Armor.EQUIP_BACKPACK)
      {
         a_entryObject.iconLabel = "clothing_backpack";
         return;
      }
      switch(a_entryObject.weightClass)
      {
         case skyui.defines.Armor.WEIGHT_LIGHT:
            this.processLightArmorIcon(a_entryObject);
            return;
         case skyui.defines.Armor.WEIGHT_HEAVY:
            this.processHeavyArmorIcon(a_entryObject);
            return;
         case skyui.defines.Armor.WEIGHT_JEWELRY:
            this.processJewelryArmorIcon(a_entryObject);
            return;
         case skyui.defines.Armor.WEIGHT_CLOTHING:
         default:
            this.processClothingArmorIcon(a_entryObject);
            return;
      }
   }
   function processLightArmorIcon(a_entryObject)
   {
      a_entryObject.iconColor = 7692288;
      switch(a_entryObject.subType)
      {
         case skyui.defines.Armor.EQUIP_HEAD:
         case skyui.defines.Armor.EQUIP_HAIR:
         case skyui.defines.Armor.EQUIP_LONGHAIR:
            a_entryObject.iconLabel = "lightarmor_head";
            break;
         case skyui.defines.Armor.EQUIP_BODY:
         case skyui.defines.Armor.EQUIP_TAIL:
            a_entryObject.iconLabel = "lightarmor_body";
            break;
         case skyui.defines.Armor.EQUIP_HANDS:
            a_entryObject.iconLabel = "lightarmor_hands";
            break;
         case skyui.defines.Armor.EQUIP_FOREARMS:
            a_entryObject.iconLabel = "lightarmor_forearms";
            break;
         case skyui.defines.Armor.EQUIP_FEET:
            a_entryObject.iconLabel = "lightarmor_feet";
            break;
         case skyui.defines.Armor.EQUIP_CALVES:
            a_entryObject.iconLabel = "lightarmor_calves";
            break;
         case skyui.defines.Armor.EQUIP_SHIELD:
            a_entryObject.iconLabel = "lightarmor_shield";
            break;
         case skyui.defines.Armor.EQUIP_AMULET:
         case skyui.defines.Armor.EQUIP_RING:
         case skyui.defines.Armor.EQUIP_CIRCLET:
         case skyui.defines.Armor.EQUIP_EARS:
            this.processJewelryArmorIcon(a_entryObject);
         default:
            return;
      }
   }
   function processHeavyArmorIcon(a_entryObject)
   {
      a_entryObject.iconColor = 7042437;
      switch(a_entryObject.subType)
      {
         case skyui.defines.Armor.EQUIP_HEAD:
         case skyui.defines.Armor.EQUIP_HAIR:
         case skyui.defines.Armor.EQUIP_LONGHAIR:
            a_entryObject.iconLabel = "armor_head";
            break;
         case skyui.defines.Armor.EQUIP_BODY:
         case skyui.defines.Armor.EQUIP_TAIL:
            a_entryObject.iconLabel = "armor_body";
            break;
         case skyui.defines.Armor.EQUIP_HANDS:
            a_entryObject.iconLabel = "armor_hands";
            break;
         case skyui.defines.Armor.EQUIP_FOREARMS:
            a_entryObject.iconLabel = "armor_forearms";
            break;
         case skyui.defines.Armor.EQUIP_FEET:
            a_entryObject.iconLabel = "armor_feet";
            break;
         case skyui.defines.Armor.EQUIP_CALVES:
            a_entryObject.iconLabel = "armor_calves";
            break;
         case skyui.defines.Armor.EQUIP_SHIELD:
            a_entryObject.iconLabel = "armor_shield";
            break;
         case skyui.defines.Armor.EQUIP_AMULET:
         case skyui.defines.Armor.EQUIP_RING:
         case skyui.defines.Armor.EQUIP_CIRCLET:
         case skyui.defines.Armor.EQUIP_EARS:
            this.processJewelryArmorIcon(a_entryObject);
         default:
            return;
      }
   }
   function processJewelryArmorIcon(a_entryObject)
   {
      switch(a_entryObject.subType)
      {
         case skyui.defines.Armor.EQUIP_AMULET:
            a_entryObject.iconLabel = "armor_amulet";
            break;
         case skyui.defines.Armor.EQUIP_RING:
            a_entryObject.iconLabel = "armor_ring";
            break;
         case skyui.defines.Armor.EQUIP_CIRCLET:
            a_entryObject.iconLabel = "armor_circlet";
         case skyui.defines.Armor.EQUIP_EARS:
         default:
            return;
      }
   }
   function processClothingArmorIcon(a_entryObject)
   {
      switch(a_entryObject.subType)
      {
         case skyui.defines.Armor.EQUIP_HEAD:
         case skyui.defines.Armor.EQUIP_HAIR:
         case skyui.defines.Armor.EQUIP_LONGHAIR:
            a_entryObject.iconLabel = "clothing_head";
            break;
         case skyui.defines.Armor.EQUIP_BODY:
         case skyui.defines.Armor.EQUIP_TAIL:
            a_entryObject.iconLabel = "clothing_body";
            break;
         case skyui.defines.Armor.EQUIP_HANDS:
            a_entryObject.iconLabel = "clothing_hands";
            break;
         case skyui.defines.Armor.EQUIP_FOREARMS:
            a_entryObject.iconLabel = "clothing_forearms";
            break;
         case skyui.defines.Armor.EQUIP_FEET:
            a_entryObject.iconLabel = "clothing_feet";
            break;
         case skyui.defines.Armor.EQUIP_CALVES:
            a_entryObject.iconLabel = "clothing_calves";
            break;
         case skyui.defines.Armor.EQUIP_SHIELD:
            a_entryObject.iconLabel = "clothing_shield";
         case skyui.defines.Armor.EQUIP_EARS:
         default:
            return;
      }
   }
   function processBookIcon(a_entryObject)
   {
      a_entryObject.iconLabel = "default_book";
      switch(a_entryObject.subType)
      {
         case skyui.defines.Item.BOOK_RECIPE:
         case skyui.defines.Item.BOOK_NOTE:
            a_entryObject.iconLabel = "book_note";
            break;
         case skyui.defines.Item.BOOK_SPELLTOME:
            a_entryObject.iconLabel = "book_tome";
         default:
            return;
      }
   }
   function processWeaponIcon(a_entryObject)
   {
      a_entryObject.iconLabel = "default_weapon";
      a_entryObject.iconColor = 10790335;
      switch(a_entryObject.subType)
      {
         case skyui.defines.Weapon.TYPE_SWORD:
            a_entryObject.iconLabel = "weapon_sword";
            break;
         case skyui.defines.Weapon.TYPE_DAGGER:
            a_entryObject.iconLabel = "weapon_dagger";
            break;
         case skyui.defines.Weapon.TYPE_WARAXE:
            a_entryObject.iconLabel = "weapon_waraxe";
            break;
         case skyui.defines.Weapon.TYPE_MACE:
            a_entryObject.iconLabel = "weapon_mace";
            break;
         case skyui.defines.Weapon.TYPE_GREATSWORD:
            a_entryObject.iconLabel = "weapon_greatsword";
            break;
         case skyui.defines.Weapon.TYPE_BATTLEAXE:
            a_entryObject.iconLabel = "weapon_battleaxe";
            break;
         case skyui.defines.Weapon.TYPE_WARHAMMER:
            a_entryObject.iconLabel = "weapon_hammer";
            break;
         case skyui.defines.Weapon.TYPE_BOW:
            a_entryObject.iconLabel = "weapon_bow";
            break;
         case skyui.defines.Weapon.TYPE_STAFF:
            a_entryObject.iconLabel = "weapon_staff";
            break;
         case skyui.defines.Weapon.TYPE_CROSSBOW:
            a_entryObject.iconLabel = "weapon_crossbow";
            break;
         case skyui.defines.Weapon.TYPE_PICKAXE:
            a_entryObject.iconLabel = "weapon_pickaxe";
            break;
         case skyui.defines.Weapon.TYPE_FISHINGROD:
            a_entryObject.iconLabel = "weapon_fishingrod";
            break;
         case skyui.defines.Weapon.TYPE_WOODAXE:
            a_entryObject.iconLabel = "weapon_woodaxe";
         case skyui.defines.Weapon.TYPE_MELEE:
         default:
            return;
      }
   }
   function processAmmoIcon(a_entryObject)
   {
      a_entryObject.iconLabel = "weapon_arrow";
      a_entryObject.iconColor = 11050636;
      switch(a_entryObject.subType)
      {
         case skyui.defines.Weapon.AMMO_ARROW:
            a_entryObject.iconLabel = "weapon_arrow";
            break;
         case skyui.defines.Weapon.AMMO_BOLT:
            a_entryObject.iconLabel = "weapon_bolt";
         default:
            return;
      }
   }
   function processPotionIcon(a_entryObject)
   {
      a_entryObject.iconLabel = "default_potion";
      switch(a_entryObject.subType)
      {
         case skyui.defines.Item.POTION_DRINK:
            a_entryObject.iconLabel = "food_wine";
            break;
         case skyui.defines.Item.POTION_FOOD:
            a_entryObject.iconLabel = "default_food";
            break;
         case skyui.defines.Item.POTION_POISON:
            a_entryObject.iconLabel = "potion_poison";
            a_entryObject.iconColor = 11337907;
            break;
         case skyui.defines.Item.POTION_HEALTH:
         case skyui.defines.Item.POTION_HEALRATE:
         case skyui.defines.Item.POTION_HEALRATEMULT:
            a_entryObject.iconLabel = "potion_health";
            a_entryObject.iconColor = 14364275;
            break;
         case skyui.defines.Item.POTION_MAGICKA:
         case skyui.defines.Item.POTION_MAGICKARATE:
         case skyui.defines.Item.POTION_MAGICKARATEMULT:
            a_entryObject.iconLabel = "potion_magic";
            a_entryObject.iconColor = 3055579;
            break;
         case skyui.defines.Item.POTION_STAMINA:
         case skyui.defines.Item.POTION_STAMINARATE:
         case skyui.defines.Item.POTION_STAMINARATEMULT:
            a_entryObject.iconLabel = "potion_stam";
            a_entryObject.iconColor = 5364526;
            break;
         case skyui.defines.Item.POTION_FIRERESIST:
            a_entryObject.iconLabel = "potion_fire";
            a_entryObject.iconColor = 13055542;
            break;
         case skyui.defines.Item.POTION_ELECTRICRESIST:
            a_entryObject.iconLabel = "potion_shock";
            a_entryObject.iconColor = 15379200;
            break;
         case skyui.defines.Item.POTION_FROSTRESIST:
            a_entryObject.iconLabel = "potion_frost";
            a_entryObject.iconColor = 2096127;
         default:
            return;
      }
   }
   function processSoulGemIcon(a_entryObject)
   {
      a_entryObject.iconLabel = "misc_soulgem";
      a_entryObject.iconColor = 14934271;
      switch(a_entryObject.subType)
      {
         case skyui.defines.Item.SOULGEM_PETTY:
            a_entryObject.iconColor = 14144767;
            this.processSoulGemStatusIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_LESSER:
            a_entryObject.iconColor = 12630783;
            this.processSoulGemStatusIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_COMMON:
            a_entryObject.iconColor = 11248639;
            this.processSoulGemStatusIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_GREATER:
            a_entryObject.iconColor = 9735164;
            this.processGrandSoulGemIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_GRAND:
            a_entryObject.iconColor = 7694847;
            this.processGrandSoulGemIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_AZURA:
            a_entryObject.iconColor = 7694847;
            a_entryObject.iconLabel = "soulgem_azura";
         default:
            return;
      }
   }
   function processGrandSoulGemIcon(a_entryObject)
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
   function processSoulGemStatusIcon(a_entryObject)
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
   function processMiscIcon(a_entryObject)
   {
      if(a_entryObject.iconLabel != undefined)
      {
         return;
      }
      a_entryObject.iconLabel = "default_misc";
      switch(a_entryObject.subType)
      {
         case skyui.defines.Item.MISC_ARTIFACT:
            a_entryObject.iconLabel = "misc_artifact";
            break;
         case skyui.defines.Item.MISC_GEM:
            a_entryObject.iconLabel = "misc_gem";
            a_entryObject.iconColor = 16756945;
            break;
         case skyui.defines.Item.MISC_HIDE:
            a_entryObject.iconLabel = "misc_hide";
            a_entryObject.iconColor = 14398318;
            break;
         case skyui.defines.Item.MISC_REMAINS:
            a_entryObject.iconLabel = "misc_remains";
            break;
         case skyui.defines.Item.MISC_INGOT:
            a_entryObject.iconLabel = "misc_ingot";
            a_entryObject.iconColor = 8553090;
            break;
         case skyui.defines.Item.MISC_CLUTTER:
            a_entryObject.iconLabel = "misc_clutter";
            break;
         case skyui.defines.Item.MISC_FIREWOOD:
            a_entryObject.iconLabel = "misc_wood";
            a_entryObject.iconColor = 11051660;
            break;
         case skyui.defines.Item.MISC_DRAGONCLAW:
            a_entryObject.iconLabel = "misc_dragonclaw";
            break;
         case skyui.defines.Item.MISC_LOCKPICK:
            a_entryObject.iconLabel = "misc_lockpick";
            break;
         case skyui.defines.Item.MISC_GOLD:
            a_entryObject.iconLabel = "misc_gold";
            a_entryObject.iconColor = 13421619;
            break;
         case skyui.defines.Item.MISC_LEATHER:
            a_entryObject.iconLabel = "misc_leather";
            a_entryObject.iconColor = 12225827;
            break;
         case skyui.defines.Item.MISC_NETCHLEATHER:
            a_entryObject.iconLabel = "misc_strips";
            a_entryObject.iconColor = 7886222;
            break;
         case skyui.defines.Item.MISC_LEATHERSTRIPS:
            a_entryObject.iconLabel = "misc_strips";
            a_entryObject.iconColor = 12225827;
            break;
         case skyui.defines.Item.MISC_TROLLSKULL:
            a_entryObject.iconLabel = "misc_trollskull";
            break;
         case skyui.defines.Item.MISC_CHILDRENSCLOTHES:
            a_entryObject.iconColor = 15587975;
            a_entryObject.iconLabel = "clothing_body";
            break;
         case skyui.defines.Item.MISC_ORE:
            a_entryObject.iconLabel = "misc_ore";
            a_entryObject.iconColor = 8553090;
            break;
         case skyui.defines.Item.MISC_HOUSEPART:
            a_entryObject.iconLabel = "misc_housepart";
            a_entryObject.iconColor = 16777215;
            break;
         case skyui.defines.Item.MISC_BROKENWEAPON:
            a_entryObject.iconLabel = "default_weapon";
            a_entryObject.iconColor = 16777215;
            break;
         case skyui.defines.Item.MISC_AYLEIDCRYSTAL:
            a_entryObject.iconLabel = "soulgem_ayleidcrystalfull";
            a_entryObject.iconColor = 6014153;
            break;
         case skyui.defines.Item.MISC_HORSETACK:
            a_entryObject.iconLabel = "misc_horsetack";
            break;
         case skyui.defines.Item.MISC_DWARVENSCRAP:
            a_entryObject.iconLabel = "misc_dwarvenscrap";
            a_entryObject.iconColor = 7364402;
            break;
         case skyui.defines.Item.MISC_SCROLLSPIDER:
            a_entryObject.iconLabel = "scroll_spider";
            break;
         case skyui.defines.Item.MISC_INSTRUMENT:
            a_entryObject.iconLabel = "misc_instrument";
            a_entryObject.iconColor = 16777215;
            break;
         case skyui.defines.Item.MISC_BUGJAR:
            a_entryObject.iconLabel = "misc_jar";
            a_entryObject.iconColor = 16777215;
            break;
         case skyui.defines.Item.MISC_MAP:
            a_entryObject.iconLabel = "book_map";
            break;
         case skyui.defines.Item.MISC_POTION:
            a_entryObject.iconLabel = "default_potion";
            break;
         case skyui.defines.Item.MISC_POISON:
            a_entryObject.iconLabel = "potion_poison";
            break;
         case skyui.defines.Item.MISC_SCROLL:
            a_entryObject.iconLabel = "default_scroll";
            break;
         case skyui.defines.Item.MISC_BOOK:
            a_entryObject.iconLabel = "default_book";
            break;
         case skyui.defines.Item.MISC_RING:
            a_entryObject.iconLabel = "armor_ring";
            break;
         case skyui.defines.Item.MISC_INGREDIENT:
            a_entryObject.iconLabel = "default_ingredient";
            break;
         case skyui.defines.Item.MISC_PETGEAR:
            a_entryObject.iconLabel = "clothing_backpack";
         default:
            return;
      }
   }
   function processMiscBaseIdIcon(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case skyui.defines.Form.BASEID_CCVSV002PETAMULET:
            a_entryObject.iconLabel = "armor_amulet";
            break;
      }
   }
   function processBookBaseIdIcon(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case 0xDDEFB:
         case 0xEF07A:
         case 0xF33CD:
         case 0xF33CE:
         case 0xF33CF:
         case 0xF33D0:
         case 0xF33D1:
         case 0xF33D2:
         case 0xF33D3:
         case 0xF33D4:
         case 0xF33D5:
         case 0xF33E0:
         case 0x1CAF2:
         case 0x70CCA:
         case 0x70CCB:
         case 0x70CCC:
         case 0x70CCD:
         case 0x70CCE:
         case 0x70CCF:
         case 0x70CD0:
         case 0x70CD1:
         case 0x70CD2:
         case 0x70CD3:
         case 0x70CD4:
         case 0x70CD5:
            a_entryObject.iconLabel = "book_map";
            break;
         case 0x2D513:
         case 0x48782:
         case 0x126DC:
         case 0x11A13:
         case 0x118F9:
            a_entryObject.iconLabel = "misc_elderscroll";
            a_entryObject.iconColor = 7693901;
            break;
      }
   }
   function processScrollBaseIdIcon(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case 0x1445E:
         case 0x14480:
         case 0x16E1C:
         case 0x1707B:
         case 0x1952C:
         case 0x19534:
         case 0x1CAB0:
         case 0x1DA03:
         case 0x206D3:
         case 0x206D9:
         case 0x206DB:
         case 0x2095F:
         case 0x20960:
         case 0x20961:
         case 0x27490:
         case 0x2749D:
         case 0x274A5:
         case 0x3319E:
         case 0x3319F:
         case 0x331A0:
         case 0x331A1:
            a_entryObject.iconLabel = "scroll_spider";
            break;
      }
   }
   function processPotionBaseIdIcon(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case 0x20E802:
         case 0xAF476:
         case 0xAF477:
            a_entryObject.iconLabel = "soulgem_ayleidcrystalfull";
            a_entryObject.iconColor = 6014153;
            break;
      }
   }
   function processSoulGemBaseIdIcon(a_entryObject)
   {
      if(a_entryObject.baseId == 0x804 || a_entryObject.baseId == 0x137F40)
      {
         a_entryObject.iconColor = 13716024;
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
               break;
         }
      }
   }
}
