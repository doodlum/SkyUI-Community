class FavoritesIconSetter implements skyui.components.list.IListProcessor
{
   function FavoritesIconSetter()
   {
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
            this.processScrollIcon(a_entryObject);
            this.processScrollResist(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_ARMOR:
            this.processArmorClass(a_entryObject);
            this.processArmorPartMask(a_entryObject);
            this.processArmorOther(a_entryObject);
            this.processArmorBaseId(a_entryObject);
            this.processArmorIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_BOOK:
            this.processBookIcon(a_entryObject);
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
            this.processWeaponType(a_entryObject);
            this.processWeaponBaseId(a_entryObject);
            this.processWeaponIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_AMMO:
            this.processAmmoType(a_entryObject);
            this.processAmmoIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_KEY:
            a_entryObject.iconLabel = "default_key";
            break;
         case skyui.defines.Form.TYPE_POTION:
            this.processPotionType(a_entryObject);
            this.processPotionIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_SOULGEM:
            this.processSoulGemIcon(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_SPELL:
            this.processSpellIcon(a_entryObject);
            this.processSpellBaseId(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_SHOUT:
            a_entryObject.iconLabel = "default_shout";
            break;
         default:
            a_entryObject.iconLabel = "default_misc";
            break;
      }
   }
   function processArmorClass(a_entryObject)
   {
      if(a_entryObject.weightClass == skyui.defines.Armor.WEIGHT_NONE)
      {
         a_entryObject.weightClass = null;
      }
      switch(a_entryObject.weightClass)
      {
         default:
            if(a_entryObject.keywords != undefined)
            {
               if(a_entryObject.keywords.VendorItemClothing != undefined)
               {
                  a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_CLOTHING;
               }
               else if(a_entryObject.keywords.VendorItemJewelry != undefined)
               {
                  a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_JEWELRY;
               }
            }
         case skyui.defines.Armor.WEIGHT_LIGHT:
         case skyui.defines.Armor.WEIGHT_HEAVY:
            return;
      }
   }
   function processArmorPartMask(a_entryObject)
   {
      if(a_entryObject.partMask == undefined)
      {
         return undefined;
      }
      var _loc1_ = 0;
      while(_loc1_ < skyui.defines.Armor.PARTMASK_PRECEDENCE.length)
      {
         if(a_entryObject.partMask & skyui.defines.Armor.PARTMASK_PRECEDENCE[_loc1_])
         {
            a_entryObject.mainPartMask = skyui.defines.Armor.PARTMASK_PRECEDENCE[_loc1_];
            break;
         }
         _loc1_ = _loc1_ + 1;
      }
      if(a_entryObject.mainPartMask == undefined)
      {
         return undefined;
      }
      switch(a_entryObject.mainPartMask)
      {
         case skyui.defines.Armor.PARTMASK_HEAD:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_HEAD;
            return;
         case skyui.defines.Armor.PARTMASK_HAIR:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_HAIR;
            return;
         case skyui.defines.Armor.PARTMASK_LONGHAIR:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_LONGHAIR;
            return;
         case skyui.defines.Armor.PARTMASK_BODY:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_BODY;
            return;
         case skyui.defines.Armor.PARTMASK_HANDS:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_HANDS;
            return;
         case skyui.defines.Armor.PARTMASK_FOREARMS:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_FOREARMS;
            return;
         case skyui.defines.Armor.PARTMASK_AMULET:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_AMULET;
            return;
         case skyui.defines.Armor.PARTMASK_RING:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_RING;
            return;
         case skyui.defines.Armor.PARTMASK_FEET:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_FEET;
            return;
         case skyui.defines.Armor.PARTMASK_CALVES:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_CALVES;
            return;
         case skyui.defines.Armor.PARTMASK_SHIELD:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_SHIELD;
            return;
         case skyui.defines.Armor.PARTMASK_CIRCLET:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_CIRCLET;
            return;
         case skyui.defines.Armor.PARTMASK_EARS:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_EARS;
            return;
         case skyui.defines.Armor.PARTMASK_TAIL:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_TAIL;
            return;
         case skyui.defines.Armor.PARTMASK_CLOAK:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_CLOAK;
            return;
         case skyui.defines.Armor.PARTMASK_BACKPACK:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_BACKPACK;
            return;
         default:
            a_entryObject.subType = a_entryObject.mainPartMask;
            return;
      }
   }
   function processArmorOther(a_entryObject)
   {
      if(a_entryObject.weightClass != null)
      {
         return undefined;
      }
      switch(a_entryObject.mainPartMask)
      {
         case skyui.defines.Armor.PARTMASK_HEAD:
         case skyui.defines.Armor.PARTMASK_HAIR:
         case skyui.defines.Armor.PARTMASK_LONGHAIR:
         case skyui.defines.Armor.PARTMASK_BODY:
         case skyui.defines.Armor.PARTMASK_HANDS:
         case skyui.defines.Armor.PARTMASK_FOREARMS:
         case skyui.defines.Armor.PARTMASK_FEET:
         case skyui.defines.Armor.PARTMASK_CALVES:
         case skyui.defines.Armor.PARTMASK_SHIELD:
         case skyui.defines.Armor.PARTMASK_TAIL:
            a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_CLOTHING;
            break;
         case skyui.defines.Armor.PARTMASK_AMULET:
         case skyui.defines.Armor.PARTMASK_RING:
         case skyui.defines.Armor.PARTMASK_CIRCLET:
         case skyui.defines.Armor.PARTMASK_EARS:
            a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_JEWELRY;
         default:
            return;
      }
   }
   function processArmorBaseId(a_entryObject)
   {
      switch(a_entryObject.formId >>> 24)
      {
         case 0x00:
            if(a_entryObject.baseId == skyui.defines.Form.FORMID_CLOTHESWEDDINGWREATH)
            {
               a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_JEWELRY;
            }
            return;
         case 0x02:
            if(a_entryObject.formId == skyui.defines.Form.FORMID_DLC1CLOTHESVAMPIRELORDARMOR)
            {
               a_entryObject.subType = skyui.defines.Armor.EQUIP_BODY;
            }
            return;
         default:
            if(a_entryObject.baseId == skyui.defines.Form.BASEID_CC025ADVDSGSRING)
            {
               a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_JEWELRY;
               a_entryObject.subType = skyui.defines.Armor.EQUIP_RING;
            }
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
      a_entryObject.iconColor = 0x6B4D16;
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
   function processScrollIcon(a_entryObject)
   {
      a_entryObject.iconLabel = "default_scroll";
      switch(a_entryObject.subType)
      {
         case skyui.defines.Item.SCROLL_SPIDER:
            a_entryObject.iconLabel = "scroll_spider";
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
            break;
         case skyui.defines.Item.BOOK_MAP:
            a_entryObject.iconLabel = "book_map";
            break;
         case skyui.defines.Item.BOOK_ELDERSCROLL:
            a_entryObject.iconLabel = "misc_elderscroll";
            a_entryObject.iconColor = 7693901;
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
            a_entryObject.iconColor = 12553824;
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
            a_entryObject.iconLabel = "clothing_body";
            a_entryObject.iconColor = 15587975;
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
      switch(a_entryObject.formId >>> 24)
      {
         case 0xFE:
            switch(a_entryObject.eslId)
            {
               case skyui.defines.Form.ESLID_CCVSV002PETAMULET:
                  a_entryObject.iconLabel = "armor_amulet";
                  break;
            }
      }
   }
   function processWeaponType(a_entryObject)
   {
      a_entryObject.subType = null;
      switch(a_entryObject.weaponType)
      {
         case skyui.defines.Weapon.ANIM_HANDTOHANDMELEE:
         case skyui.defines.Weapon.ANIM_H2H:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_MELEE;
            break;
         case skyui.defines.Weapon.ANIM_ONEHANDSWORD:
         case skyui.defines.Weapon.ANIM_1HS:
            if(a_entryObject.keywords != undefined && a_entryObject.keywords.ccBGSSSE001_FishingPoleKW != undefined)
            {
               a_entryObject.subType = skyui.defines.Weapon.TYPE_FISHINGROD;
               return;
            }
            a_entryObject.subType = skyui.defines.Weapon.TYPE_SWORD;
            break;
         case skyui.defines.Weapon.ANIM_ONEHANDDAGGER:
         case skyui.defines.Weapon.ANIM_1HD:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_DAGGER;
            break;
         case skyui.defines.Weapon.ANIM_ONEHANDAXE:
         case skyui.defines.Weapon.ANIM_1HA:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_WARAXE;
            break;
         case skyui.defines.Weapon.ANIM_ONEHANDMACE:
         case skyui.defines.Weapon.ANIM_1HM:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_MACE;
            break;
         case skyui.defines.Weapon.ANIM_TWOHANDSWORD:
         case skyui.defines.Weapon.ANIM_2HS:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_GREATSWORD;
            break;
         case skyui.defines.Weapon.ANIM_TWOHANDAXE:
         case skyui.defines.Weapon.ANIM_2HA:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_BATTLEAXE;
            if(a_entryObject.keywords != undefined && a_entryObject.keywords.WeapTypeWarhammer != undefined)
            {
               a_entryObject.subType = skyui.defines.Weapon.TYPE_WARHAMMER;
            }
            break;
         case skyui.defines.Weapon.ANIM_BOW:
         case skyui.defines.Weapon.ANIM_BOW2:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_BOW;
            break;
         case skyui.defines.Weapon.ANIM_STAFF:
         case skyui.defines.Weapon.ANIM_STAFF2:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_STAFF;
            break;
         case skyui.defines.Weapon.ANIM_CROSSBOW:
         case skyui.defines.Weapon.ANIM_CBOW:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_CROSSBOW;
         default:
            return;
      }
   }
   function processWeaponBaseId(a_entryObject)
   {
      switch(a_entryObject.formId >>> 24)
      {
         case 0x00:
            switch(a_entryObject.baseId)
            {
               case skyui.defines.Form.FORMID_WEAPPICKAXE:
               case skyui.defines.Form.FORMID_SSDROCKSPLINTERPICKAXE:
               case skyui.defines.Form.FORMID_DUNVOLUNRUUDPICKAXE:
                  a_entryObject.subType = skyui.defines.Weapon.TYPE_PICKAXE;
                  break;
               case skyui.defines.Form.FORMID_AXE01:
               case skyui.defines.Form.FORMID_DUNHALTEDSTREAMPOACHERSAXE:
                  a_entryObject.subType = skyui.defines.Weapon.TYPE_WOODAXE;
            }
            return;
         case 0x04:
            switch(a_entryObject.formId)
            {
               case skyui.defines.Form.FORMID_DLC2PICKAXE1:
               case skyui.defines.Form.FORMID_DLC2PICKAXE2:
               case skyui.defines.Form.FORMID_DLC2PICKAXE3:
                  a_entryObject.subType = skyui.defines.Weapon.TYPE_PICKAXE;
            }
            return;
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
   function processAmmoType(a_entryObject)
   {
      if((a_entryObject.flags & skyui.defines.Weapon.AMMOFLAG_NONBOLT) != 0)
      {
         a_entryObject.subType = skyui.defines.Weapon.AMMO_ARROW;
      }
      else
      {
         a_entryObject.subType = skyui.defines.Weapon.AMMO_BOLT;
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
   function processPotionType(a_entryObject)
   {
      a_entryObject.subType = skyui.defines.Item.POTION_POTION;
      if((a_entryObject.flags & skyui.defines.Item.ALCHFLAG_FOOD) != 0)
      {
         a_entryObject.subType = skyui.defines.Item.POTION_FOOD;
         if(a_entryObject.useSound.formId != undefined && a_entryObject.useSound.formId == skyui.defines.Form.FORMID_ITMPotionUse)
         {
            a_entryObject.subType = skyui.defines.Item.POTION_DRINK;
         }
      }
      else if((a_entryObject.flags & skyui.defines.Item.ALCHFLAG_POISON) != 0)
      {
         a_entryObject.subType = skyui.defines.Item.POTION_POISON;
      }
      else
      {
         switch(a_entryObject.actorValue)
         {
            case skyui.defines.Actor.AV_HEALTH:
               a_entryObject.subType = skyui.defines.Item.POTION_HEALTH;
               break;
            case skyui.defines.Actor.AV_MAGICKA:
               a_entryObject.subType = skyui.defines.Item.POTION_MAGICKA;
               break;
            case skyui.defines.Actor.AV_STAMINA:
               a_entryObject.subType = skyui.defines.Item.POTION_STAMINA;
               break;
            case skyui.defines.Actor.AV_HEALRATE:
               a_entryObject.subType = skyui.defines.Item.POTION_HEALRATE;
               break;
            case skyui.defines.Actor.AV_MAGICKARATE:
               a_entryObject.subType = skyui.defines.Item.POTION_MAGICKARATE;
               break;
            case skyui.defines.Actor.AV_STAMINARATE:
               a_entryObject.subType = skyui.defines.Item.POTION_STAMINARATE;
               break;
            case skyui.defines.Actor.AV_HEALRATEMULT:
               a_entryObject.subType = skyui.defines.Item.POTION_HEALRATEMULT;
               break;
            case skyui.defines.Actor.AV_MAGICKARATEMULT:
               a_entryObject.subType = skyui.defines.Item.POTION_MAGICKARATEMULT;
               break;
            case skyui.defines.Actor.AV_STAMINARATEMULT:
               a_entryObject.subType = skyui.defines.Item.POTION_STAMINARATEMULT;
               break;
            case skyui.defines.Actor.AV_FIRERESIST:
               a_entryObject.subType = skyui.defines.Item.POTION_FIRERESIST;
               break;
            case skyui.defines.Actor.AV_ELECTRICRESIST:
               a_entryObject.subType = skyui.defines.Item.POTION_ELECTRICRESIST;
               break;
            case skyui.defines.Actor.AV_FROSTRESIST:
               a_entryObject.subType = skyui.defines.Item.POTION_FROSTRESIST;
            default:
               return;
         }
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
         case skyui.defines.Item.POTION_AYLEIDCRYSTAL:
            a_entryObject.iconLabel = "soulgem_ayleidcrystalfull";
            a_entryObject.iconColor = 6014153;
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
         case skyui.defines.Item.SOULGEM_SOULTOMATO:
            a_entryObject.iconColor = 13716024;
            this.processSoulTomatoIcon(a_entryObject);
            break;
         case skyui.defines.Item.SOULGEM_AZURA:
            a_entryObject.iconColor = 7694847;
            a_entryObject.iconLabel = "soulgem_azura";
         default:
            return;
      }
   }
   function processSoulTomatoIcon(a_entryObject)
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
   function processScrollResist(a_entryObject)
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
