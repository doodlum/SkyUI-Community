class InventoryDataSetter extends ItemcardDataExtender
{
   function InventoryDataSetter()
   {
      super();
   }
   function processEntry(a_entryObject, a_itemInfo)
   {
      a_entryObject.baseId = a_entryObject.formId & 0xFFFFFF;
      a_entryObject.type = a_itemInfo.type;
      a_entryObject.isEquipped = a_entryObject.equipState > 0;
      a_entryObject.isStolen = a_itemInfo.stolen == true;
      a_entryObject.infoValue = a_itemInfo.value <= 0 ? null : Math.round(a_itemInfo.value * 100) / 100;
      a_entryObject.infoWeight = a_itemInfo.weight <= 0 ? null : Math.round(a_itemInfo.weight * 100) / 100;
      a_entryObject.infoValueWeight = !(a_itemInfo.weight > 0 && a_itemInfo.value > 0) ? null : Math.round(a_itemInfo.value / a_itemInfo.weight);
      switch(a_entryObject.formType)
      {
         case skyui.defines.Form.TYPE_SCROLLITEM:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Scroll");
            a_entryObject.duration = a_entryObject.duration <= 0 ? null : Math.round(a_entryObject.duration * 100) / 100;
            a_entryObject.magnitude = a_entryObject.magnitude <= 0 ? null : Math.round(a_entryObject.magnitude * 100) / 100;
            this.processScrollBaseId(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_ARMOR:
            a_entryObject.isEnchanted = a_itemInfo.effects != "";
            a_entryObject.infoArmor = a_itemInfo.armor <= 0 ? null : Math.round(a_itemInfo.armor * 100) / 100;
            this.processArmorClass(a_entryObject);
            this.processArmorPartMask(a_entryObject);
            this.processMaterialKeywords(a_entryObject);
            this.processArmorOther(a_entryObject);
            this.processArmorBaseId(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_BOOK:
            this.processBookType(a_entryObject);
            this.processBookBaseId(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_INGREDIENT:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Ingredient");
            break;
         case skyui.defines.Form.TYPE_LIGHT:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Torch");
            break;
         case skyui.defines.Form.TYPE_MISC:
            this.processMiscType(a_entryObject);
            this.processMiscBaseId(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_WEAPON:
            a_entryObject.isEnchanted = a_itemInfo.effects != "";
            a_entryObject.isPoisoned = a_itemInfo.poisoned == true;
            a_entryObject.infoDamage = a_itemInfo.damage <= 0 ? null : Math.round(a_itemInfo.damage * 100) / 100;
            this.processWeaponType(a_entryObject);
            this.processMaterialKeywords(a_entryObject);
            this.processWeaponBaseId(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_AMMO:
            a_entryObject.isEnchanted = a_itemInfo.effects != "";
            a_entryObject.infoDamage = a_itemInfo.damage <= 0 ? null : Math.round(a_itemInfo.damage * 100) / 100;
            this.processAmmoType(a_entryObject);
            this.processMaterialKeywords(a_entryObject);
            this.processAmmoBaseId(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_KEY:
            this.processKeyType(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_POTION:
            a_entryObject.duration = a_entryObject.duration <= 0 ? null : Math.round(a_entryObject.duration * 100) / 100;
            a_entryObject.magnitude = a_entryObject.magnitude <= 0 ? null : Math.round(a_entryObject.magnitude * 100) / 100;
            this.processPotionType(a_entryObject);
            this.processPotionBaseId(a_entryObject);
            break;
         case skyui.defines.Form.TYPE_SOULGEM:
            this.processSoulGemType(a_entryObject);
            this.processSoulGemStatus(a_entryObject);
            this.processSoulGemBaseId(a_entryObject);
         default:
            return;
      }
   }
   function processArmorClass(a_entryObject)
   {
      if(a_entryObject.weightClass == skyui.defines.Armor.WEIGHT_NONE)
      {
         a_entryObject.weightClass = null;
      }
      a_entryObject.weightClassDisplay = skyui.util.Translator.translate("$Other");
      switch(a_entryObject.weightClass)
      {
         case skyui.defines.Armor.WEIGHT_LIGHT:
            a_entryObject.weightClassDisplay = skyui.util.Translator.translate("$Light");
            return;
         case skyui.defines.Armor.WEIGHT_HEAVY:
            a_entryObject.weightClassDisplay = skyui.util.Translator.translate("$Heavy");
            return;
         default:
            if(a_entryObject.keywords == undefined)
            {
               return;
            }
            if(a_entryObject.keywords.VendorItemClothing != undefined)
            {
               a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_CLOTHING;
               a_entryObject.weightClassDisplay = skyui.util.Translator.translate("$Clothing");
               return;
            }
            if(a_entryObject.keywords.VendorItemJewelry != undefined)
            {
               a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_JEWELRY;
               a_entryObject.weightClassDisplay = skyui.util.Translator.translate("$Jewelry");
               return;
            }
            return;
      }
   }
   function processMaterialKeywords(a_entryObject)
   {
      a_entryObject.material = null;
      a_entryObject.materialDisplay = skyui.util.Translator.translate("$Other");
      if(a_entryObject.keywords == undefined)
      {
         return undefined;
      }
      if(a_entryObject.keywords.ccBGSSSE001_FishingPoleKW != undefined)
      {
         a_entryObject.material = null;
         a_entryObject.materialDisplay = null;
      }
      else if(a_entryObject.keywords.ArmorMaterialDaedric != undefined || a_entryObject.keywords.WeapMaterialDaedric != undefined || a_entryObject.keywords.ccBGSSSE025_ArmorMaterialDark != undefined || a_entryObject.keywords.ccBGSSSE025_WeapMaterialDark != undefined || a_entryObject.keywords.ccBGSSSE025_ArmorMaterialGolden != undefined || a_entryObject.keywords.ccBGSSSE025_WeapMaterialGolden != undefined)
      {
         a_entryObject.material = skyui.defines.Material.DAEDRIC;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Daedric");
      }
      else if(a_entryObject.keywords.ArmorMaterialDragonplate != undefined || a_entryObject.keywords.ArmorMaterialDragonscale != undefined || a_entryObject.keywords.DLC1WeapMaterialDragonbone != undefined)
      {
         a_entryObject.material = skyui.defines.Material.DRAGON;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Dragon");
      }
      else if(a_entryObject.keywords.ArmorMaterialDwarven != undefined || a_entryObject.keywords.WeapMaterialDwarven != undefined)
      {
         a_entryObject.material = skyui.defines.Material.DWARVEN;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Dwarven");
      }
      else if(a_entryObject.keywords.ArmorMaterialEbony != undefined || a_entryObject.keywords.WeapMaterialEbony != undefined)
      {
         a_entryObject.material = skyui.defines.Material.EBONY;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Ebony");
      }
      else if(a_entryObject.keywords.ArmorMaterialElven != undefined || a_entryObject.keywords.WeapMaterialElven != undefined || a_entryObject.keywords.ArmorMaterialElvenGilded != undefined)
      {
         a_entryObject.material = skyui.defines.Material.ELVEN;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Elven");
      }
      else if(a_entryObject.keywords.ArmorMaterialGlass != undefined || a_entryObject.keywords.WeapMaterialGlass != undefined)
      {
         a_entryObject.material = skyui.defines.Material.GLASS;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Glass");
      }
      else if(a_entryObject.keywords.ArmorMaterialHide != undefined || a_entryObject.keywords.ArmorMaterialScaled != undefined)
      {
         a_entryObject.material = skyui.defines.Material.HIDE;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Hide");
      }
      else if(a_entryObject.keywords.ArmorMaterialStormcloak != undefined || a_entryObject.keywords.ArmorMaterialBearStormcloak != undefined)
      {
         a_entryObject.material = skyui.defines.Material.STORMCLOAK;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Stormcloak");
      }
      else if(a_entryObject.keywords.ArmorMaterialForsworn != undefined)
      {
         a_entryObject.material = skyui.defines.Material.FORSWORN;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Forsworn");
      }
      else if(a_entryObject.keywords.ArmorMaterialImperialHeavy != undefined || a_entryObject.keywords.ArmorMaterialImperialLight != undefined || a_entryObject.keywords.WeapMaterialImperial != undefined || a_entryObject.keywords.ArmorMaterialImperialStudded != undefined || a_entryObject.keywords.ArmorMaterialStudded != undefined)
      {
         a_entryObject.material = skyui.defines.Material.IMPERIAL;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Imperial");
      }
      else if(a_entryObject.keywords.ArmorMaterialIron != undefined || a_entryObject.keywords.WeapMaterialIron != undefined || a_entryObject.keywords.ArmorMaterialIronBanded != undefined)
      {
         a_entryObject.material = skyui.defines.Material.IRON;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Iron");
      }
      else if(a_entryObject.keywords.ArmorMaterialLeather != undefined)
      {
         a_entryObject.material = skyui.defines.Material.LEATHER;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Leather");
      }
      else if(a_entryObject.keywords.ArmorMaterialOrcish != undefined || a_entryObject.keywords.WeapMaterialOrcish != undefined || a_entryObject.keywords.ccBGSSSE055_ArmorMaterialOrcishLight != undefined)
      {
         a_entryObject.material = skyui.defines.Material.ORCISH;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Orcish");
      }
      else if(a_entryObject.keywords.ArmorMaterialSteel != undefined || a_entryObject.keywords.WeapMaterialSteel != undefined || a_entryObject.keywords.ArmorMaterialSteelPlate != undefined || a_entryObject.keywords.WeapMaterialDraugr != undefined || a_entryObject.keywords.WeapMaterialDraugrHoned != undefined)
      {
         a_entryObject.material = skyui.defines.Material.STEEL;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Steel");
      }
      else if(a_entryObject.keywords.WeapMaterialSilver != undefined)
      {
         a_entryObject.material = skyui.defines.Material.SILVER;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Silver");
      }
      else if(a_entryObject.keywords.ArmorMaterialFalmer != undefined || a_entryObject.keywords.DLC1ArmorMaterialFalmerHardened != undefined || a_entryObject.keywords.DLC1ArmorMaterielFalmerHeavy != undefined || a_entryObject.keywords.DLC1ArmorMaterielFalmerHeavyOriginal != undefined)
      {
         a_entryObject.material = skyui.defines.Material.FALMER;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Falmer");
      }
      else if(a_entryObject.keywords.DLC1LD_CraftingMaterialAetherium != undefined)
      {
         a_entryObject.material = skyui.defines.Material.AETHERIUM;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Aetherium");
      }
      else if(a_entryObject.keywords.DLC2ArmorMaterialBonemoldHeavy != undefined || a_entryObject.keywords.DLC2ArmorMaterialBonemoldLight != undefined)
      {
         a_entryObject.material = skyui.defines.Material.BONEMOLD;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Bonemold");
      }
      else if(a_entryObject.keywords.DLC2ArmorMaterialChitinHeavy != undefined || a_entryObject.keywords.DLC2ArmorMaterialChitinLight != undefined)
      {
         a_entryObject.material = skyui.defines.Material.CHITIN;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Chitin");
      }
      else if(a_entryObject.keywords.DLC2ArmorMaterialNordicHeavy != undefined || a_entryObject.keywords.DLC2ArmorMaterialNordicLight != undefined || a_entryObject.keywords.DLC2WeaponMaterialNordic != undefined)
      {
         a_entryObject.material = skyui.defines.Material.NORDIC;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Nordic");
      }
      else if(a_entryObject.keywords.DLC2ArmorMaterialStalhrimHeavy != undefined || a_entryObject.keywords.DLC2ArmorMaterialStalhrimLight != undefined || a_entryObject.keywords.DLC2WeaponMaterialStalhrim != undefined)
      {
         a_entryObject.material = skyui.defines.Material.STALHRIM;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Stalhrim");
      }
      else if(a_entryObject.keywords.WeapMaterialFalmer != undefined || a_entryObject.keywords.WeapMaterialFalmerHoned != undefined)
      {
         a_entryObject.material = skyui.defines.Material.FALMER;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Falmer");
      }
      else if(a_entryObject.keywords.ccASVSSE001_ArmorOrdinator != undefined || a_entryObject.keywords.ccASVSSE001_ArmorOrdinatorIndoril != undefined)
      {
         a_entryObject.material = skyui.defines.Material.ORDINATOR;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Ordinator");
      }
      else if(a_entryObject.keywords.ccBGSSSE025_ArmorMaterialAmber != undefined || a_entryObject.keywords.ccBGSSSE025_WeapMaterialAmber != undefined)
      {
         a_entryObject.material = skyui.defines.Material.AMBER;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Amber");
      }
      else if(a_entryObject.keywords.ccBGSSSE025_ArmorMaterialMadness != undefined || a_entryObject.keywords.ccBGSSSE025_WeapMaterialMadness != undefined)
      {
         a_entryObject.material = skyui.defines.Material.MADNESS;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Madness");
      }
      else if(a_entryObject.keywords.WeapMaterialWood != undefined)
      {
         a_entryObject.material = skyui.defines.Material.WOOD;
         a_entryObject.materialDisplay = skyui.util.Translator.translate("$Wood");
      }
      else if(a_entryObject.keywords.ArmorJewelry != undefined)
      {
         a_entryObject.material = null;
         a_entryObject.materialDisplay = null;
      }
      else if(a_entryObject.keywords.ArmorClothing != undefined)
      {
         a_entryObject.material = null;
         a_entryObject.materialDisplay = null;
      }
   }
   function processWeaponType(a_entryObject)
   {
      a_entryObject.subType = null;
      a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Weapon");
      if(a_entryObject.keywords != undefined && a_entryObject.keywords.ccBGSSSE001_FishingPoleKW != undefined)
      {
         a_entryObject.subType = skyui.defines.Weapon.TYPE_FISHINGROD;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$FishingRod");
         return;
      }
      switch(a_entryObject.weaponType)
      {
         case skyui.defines.Weapon.ANIM_HANDTOHANDMELEE:
         case skyui.defines.Weapon.ANIM_H2H:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_MELEE;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Melee");
            break;
         case skyui.defines.Weapon.ANIM_ONEHANDSWORD:
         case skyui.defines.Weapon.ANIM_1HS:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_SWORD;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Sword");
            break;
         case skyui.defines.Weapon.ANIM_ONEHANDDAGGER:
         case skyui.defines.Weapon.ANIM_1HD:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_DAGGER;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Dagger");
            break;
         case skyui.defines.Weapon.ANIM_ONEHANDAXE:
         case skyui.defines.Weapon.ANIM_1HA:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_WARAXE;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$War Axe");
            break;
         case skyui.defines.Weapon.ANIM_ONEHANDMACE:
         case skyui.defines.Weapon.ANIM_1HM:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_MACE;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Mace");
            break;
         case skyui.defines.Weapon.ANIM_TWOHANDSWORD:
         case skyui.defines.Weapon.ANIM_2HS:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_GREATSWORD;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Greatsword");
            break;
         case skyui.defines.Weapon.ANIM_TWOHANDAXE:
         case skyui.defines.Weapon.ANIM_2HA:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_BATTLEAXE;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Battleaxe");
            if(a_entryObject.keywords != undefined && a_entryObject.keywords.WeapTypeWarhammer != undefined)
            {
               a_entryObject.subType = skyui.defines.Weapon.TYPE_WARHAMMER;
               a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Warhammer");
            }
            break;
         case skyui.defines.Weapon.ANIM_BOW:
         case skyui.defines.Weapon.ANIM_BOW2:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_BOW;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Bow");
            break;
         case skyui.defines.Weapon.ANIM_STAFF:
         case skyui.defines.Weapon.ANIM_STAFF2:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_STAFF;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Staff");
            break;
         case skyui.defines.Weapon.ANIM_CROSSBOW:
         case skyui.defines.Weapon.ANIM_CBOW:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_CROSSBOW;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Crossbow");
         default:
            return;
      }
   }
   function processWeaponBaseId(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case skyui.defines.Form.BASEID_WEAPPICKAXE:
         case skyui.defines.Form.BASEID_SSDROCKSPLINTERPICKAXE:
         case skyui.defines.Form.BASEID_DUNVOLUNRUUDPICKAXE:
         case skyui.defines.Form.BASEID_DLC2PICKAXE1:
         case skyui.defines.Form.BASEID_DLC2PICKAXE2:
         case skyui.defines.Form.BASEID_DLC2PICKAXE3:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_PICKAXE;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Pickaxe");
            break;
         case skyui.defines.Form.BASEID_AXE01:
         case skyui.defines.Form.BASEID_DUNHALTEDSTREAMPOACHERSAXE:
            a_entryObject.subType = skyui.defines.Weapon.TYPE_WOODAXE;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Wood Axe");
         default:
            return;
      }
   }
   function processArmorPartMask(a_entryObject)
   {
      if(a_entryObject.partMask == undefined)
      {
         return undefined;
      }
      var _loc2_ = 0;
      while(_loc2_ < skyui.defines.Armor.PARTMASK_PRECEDENCE.length)
      {
         if(a_entryObject.partMask & skyui.defines.Armor.PARTMASK_PRECEDENCE[_loc2_])
         {
            a_entryObject.mainPartMask = skyui.defines.Armor.PARTMASK_PRECEDENCE[_loc2_];
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(a_entryObject.mainPartMask == undefined)
      {
         return undefined;
      }
      switch(a_entryObject.mainPartMask)
      {
         case skyui.defines.Armor.PARTMASK_HEAD:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_HEAD;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Head");
            return;
         case skyui.defines.Armor.PARTMASK_HAIR:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_HAIR;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Head");
            return;
         case skyui.defines.Armor.PARTMASK_LONGHAIR:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_LONGHAIR;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Head");
            return;
         case skyui.defines.Armor.PARTMASK_BODY:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_BODY;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Body");
            return;
         case skyui.defines.Armor.PARTMASK_HANDS:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_HANDS;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Hands");
            return;
         case skyui.defines.Armor.PARTMASK_FOREARMS:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_FOREARMS;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Forearms");
            return;
         case skyui.defines.Armor.PARTMASK_AMULET:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_AMULET;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Amulet");
            return;
         case skyui.defines.Armor.PARTMASK_RING:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_RING;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Ring");
            return;
         case skyui.defines.Armor.PARTMASK_FEET:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_FEET;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Feet");
            return;
         case skyui.defines.Armor.PARTMASK_CALVES:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_CALVES;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Calves");
            return;
         case skyui.defines.Armor.PARTMASK_SHIELD:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_SHIELD;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Shield");
            return;
         case skyui.defines.Armor.PARTMASK_CIRCLET:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_CIRCLET;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Circlet");
            return;
         case skyui.defines.Armor.PARTMASK_EARS:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_EARS;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Ears");
            return;
         case skyui.defines.Armor.PARTMASK_TAIL:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_TAIL;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Tail");
            return;
         case skyui.defines.Armor.PARTMASK_CLOAK:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_CLOAK;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$ClothingCloak");
            return;
         case skyui.defines.Armor.PARTMASK_BACKPACK:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_BACKPACK;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Backpack");
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
         case skyui.defines.Armor.PARTMASK_CLOAK:
         case skyui.defines.Armor.PARTMASK_BACKPACK:
            a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_CLOTHING;
            a_entryObject.weightClassDisplay = skyui.util.Translator.translate("$Clothing");
            break;
         case skyui.defines.Armor.PARTMASK_AMULET:
         case skyui.defines.Armor.PARTMASK_RING:
         case skyui.defines.Armor.PARTMASK_CIRCLET:
         case skyui.defines.Armor.PARTMASK_EARS:
            a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_JEWELRY;
            a_entryObject.weightClassDisplay = skyui.util.Translator.translate("$Jewelry");
         default:
            return;
      }
   }
   function processArmorBaseId(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case skyui.defines.Form.BASEID_CLOTHESWEDDINGWREATH:
            a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_JEWELRY;
            a_entryObject.weightClassDisplay = skyui.util.Translator.translate("$Jewelry");
            break;
         case skyui.defines.Form.BASEID_DLC1CLOTHESVAMPIRELORDARMOR:
            a_entryObject.subType = skyui.defines.Armor.EQUIP_BODY;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Body");
            break;
         case skyui.defines.Form.BASEID_CC025ADVDSGSRING:
            a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_JEWELRY;
            a_entryObject.weightClassDisplay = skyui.util.Translator.translate("$Jewelry");
            a_entryObject.subType = skyui.defines.Armor.EQUIP_RING;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Ring");
         default:
            return;
      }
   }
   function processBookType(a_entryObject)
   {
      a_entryObject.subType = skyui.defines.Item.OTHER;
      a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Book");
      a_entryObject.isRead = (a_entryObject.flags & skyui.defines.Item.BOOKFLAG_READ) != 0;
      if(a_entryObject.bookType == skyui.defines.Item.BOOKTYPE_NOTE)
      {
         a_entryObject.subType = skyui.defines.Item.BOOK_NOTE;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Note");
      }
      if(a_entryObject.keywords == undefined)
      {
         return undefined;
      }
      if(a_entryObject.keywords.VendorItemRecipe != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.BOOK_RECIPE;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Recipe");
      }
      else if(a_entryObject.keywords.VendorItemSpellTome != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.BOOK_SPELLTOME;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Spell Tome");
      }
   }
   function processAmmoType(a_entryObject)
   {
      if((a_entryObject.flags & skyui.defines.Weapon.AMMOFLAG_NONBOLT) != 0)
      {
         a_entryObject.subType = skyui.defines.Weapon.AMMO_ARROW;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Arrow");
      }
      else
      {
         a_entryObject.subType = skyui.defines.Weapon.AMMO_BOLT;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Bolt");
      }
   }
   function processAmmoBaseId(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case skyui.defines.Form.BASEID_DAEDRICARROW:
            a_entryObject.material = skyui.defines.Material.DAEDRIC;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Daedric");
            break;
         case skyui.defines.Form.BASEID_EBONYARROW:
            a_entryObject.material = skyui.defines.Material.EBONY;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Ebony");
            break;
         case skyui.defines.Form.BASEID_GLASSARROW:
            a_entryObject.material = skyui.defines.Material.GLASS;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Glass");
            break;
         case skyui.defines.Form.BASEID_ELVENARROW:
         case skyui.defines.Form.BASEID_DLC1ELVENARROWBLESSED:
         case skyui.defines.Form.BASEID_DLC1ELVENARROWBLOOD:
            a_entryObject.material = skyui.defines.Material.ELVEN;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Elven");
            break;
         case skyui.defines.Form.BASEID_DWARVENARROW:
         case skyui.defines.Form.BASEID_DWARVENSPHEREARROW:
         case skyui.defines.Form.BASEID_DWARVENSPHEREBOLT01:
         case skyui.defines.Form.BASEID_DWARVENSPHEREBOLT02:
         case skyui.defines.Form.BASEID_DLC2DWARVENBALLISTABOLT:
            a_entryObject.material = skyui.defines.Material.DWARVEN;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Dwarven");
            break;
         case skyui.defines.Form.BASEID_ORCISHARROW:
            a_entryObject.material = skyui.defines.Material.ORCISH;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Orcish");
            break;
         case skyui.defines.Form.BASEID_NORDHEROARROW:
            a_entryObject.material = skyui.defines.Material.NORDIC;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Nordic");
            break;
         case skyui.defines.Form.BASEID_FALMERARROW:
            a_entryObject.material = skyui.defines.Material.FALMER;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Falmer");
            break;
         case skyui.defines.Form.BASEID_STEELARROW:
         case skyui.defines.Form.BASEID_MQ101STEELARROW:
         case skyui.defines.Form.BASEID_DRAUGRARROW:
         case skyui.defines.Form.BASEID_DUNGEIRMUNDSIGDISARROWSILLUSION:
            a_entryObject.material = skyui.defines.Material.STEEL;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Steel");
            break;
         case skyui.defines.Form.BASEID_IRONARROW:
         case skyui.defines.Form.BASEID_CWARROW:
         case skyui.defines.Form.BASEID_CWARROWSHORT:
         case skyui.defines.Form.BASEID_TRAPDART:
         case skyui.defines.Form.BASEID_DUNARCHERPRATICEARROW:
         case skyui.defines.Form.BASEID_FOLLOWERIRONARROW:
         case skyui.defines.Form.BASEID_TESTDLC1BOLT:
            a_entryObject.material = skyui.defines.Material.IRON;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Iron");
            break;
         case skyui.defines.Form.BASEID_DLC2RIEKLINGSPEARTHROWN:
            a_entryObject.material = skyui.defines.Material.WOOD;
            a_entryObject.materialDisplay = skyui.util.Translator.translate("$Wood");
         default:
            return;
      }
   }
   function processKeyType(a_entryObject)
   {
      a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Key");
      if(a_entryObject.infoValue <= 0)
      {
         a_entryObject.infoValue = null;
      }
      if(a_entryObject.infoValue <= 0)
      {
         a_entryObject.infoValue = null;
      }
   }
   function processPotionType(a_entryObject)
   {
      a_entryObject.subType = skyui.defines.Item.POTION_POTION;
      a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Potion");
      if((a_entryObject.flags & skyui.defines.Item.ALCHFLAG_FOOD) != 0)
      {
         a_entryObject.subType = skyui.defines.Item.POTION_FOOD;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Food");
         if(a_entryObject.useSound.formId != undefined && a_entryObject.useSound.formId == skyui.defines.Form.FORMID_ITMPotionUse)
         {
            a_entryObject.subType = skyui.defines.Item.POTION_DRINK;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Drink");
         }
      }
      else if((a_entryObject.flags & skyui.defines.Item.ALCHFLAG_POISON) != 0)
      {
         a_entryObject.subType = skyui.defines.Item.POTION_POISON;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Poison");
      }
      else
      {
         switch(a_entryObject.actorValue)
         {
            case skyui.defines.Actor.AV_HEALTH:
               a_entryObject.subType = skyui.defines.Item.POTION_HEALTH;
               a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Health");
               break;
            case skyui.defines.Actor.AV_MAGICKA:
               a_entryObject.subType = skyui.defines.Item.POTION_MAGICKA;
               a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Magicka");
               break;
            case skyui.defines.Actor.AV_STAMINA:
               a_entryObject.subType = skyui.defines.Item.POTION_STAMINA;
               a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Stamina");
               break;
            case skyui.defines.Actor.AV_HEALRATE:
               a_entryObject.subType = skyui.defines.Item.POTION_HEALRATE;
               a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Health");
               break;
            case skyui.defines.Actor.AV_MAGICKARATE:
               a_entryObject.subType = skyui.defines.Item.POTION_MAGICKARATE;
               a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Magicka");
               break;
            case skyui.defines.Actor.AV_STAMINARATE:
               a_entryObject.subType = skyui.defines.Item.POTION_STAMINARATE;
               a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Stamina");
               break;
            case skyui.defines.Actor.AV_HEALRATEMULT:
               a_entryObject.subType = skyui.defines.Item.POTION_HEALRATEMULT;
               a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Health");
               break;
            case skyui.defines.Actor.AV_MAGICKARATEMULT:
               a_entryObject.subType = skyui.defines.Item.POTION_MAGICKARATEMULT;
               a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Magicka");
               break;
            case skyui.defines.Actor.AV_STAMINARATEMULT:
               a_entryObject.subType = skyui.defines.Item.POTION_STAMINARATEMULT;
               a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Stamina");
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
   function processSoulGemType(a_entryObject)
   {
      a_entryObject.subType = skyui.defines.Item.OTHER;
      a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Soul Gem");
      if(a_entryObject.gemSize != undefined && a_entryObject.gemSize != skyui.defines.Item.SOULGEM_NONE)
      {
         a_entryObject.subType = a_entryObject.gemSize;
      }
   }
   function processSoulGemStatus(a_entryObject)
   {
      if(a_entryObject.gemSize == undefined || a_entryObject.soulSize == undefined || a_entryObject.soulSize == skyui.defines.Item.SOULGEM_NONE)
      {
         a_entryObject.status = skyui.defines.Item.SOULGEMSTATUS_EMPTY;
      }
      else if(a_entryObject.soulSize >= a_entryObject.gemSize)
      {
         a_entryObject.status = skyui.defines.Item.SOULGEMSTATUS_FULL;
      }
      else
      {
         a_entryObject.status = skyui.defines.Item.SOULGEMSTATUS_PARTIAL;
      }
   }
   function processSoulGemBaseId(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case skyui.defines.Form.BASEID_DA01SOULGEMBLACKSTAR:
         case skyui.defines.Form.BASEID_DA01SOULGEMAZURASSTAR:
            a_entryObject.subType = skyui.defines.Item.SOULGEM_AZURA;
            return;
         case skyui.defines.Form.BASEID_CC025SOULTOMATO1:
         case skyui.defines.Form.BASEID_CC025SOULTOMATO2:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$SoulTomato");
            return;
         default:
            return;
      }
   }
   function processMiscType(a_entryObject)
   {
      a_entryObject.subType = skyui.defines.Item.OTHER;
      a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Misc");
      if(a_entryObject.keywords == undefined)
      {
         return undefined;
      }
      if(a_entryObject.keywords.BYOHAdoptionClothesKeyword != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_CHILDRENSCLOTHES;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Clothing");
      }
      else if(a_entryObject.keywords.BYOHAdoptionToyKeyword != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_TOY;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Toy");
      }
      else if(a_entryObject.keywords.BYOHHouseCraftingCategoryWeaponRacks != undefined || a_entryObject.keywords.BYOHHouseCraftingCategoryShelf != undefined || a_entryObject.keywords.BYOHHouseCraftingCategoryFurniture != undefined || a_entryObject.keywords.BYOHHouseCraftingCategoryExterior != undefined || a_entryObject.keywords.BYOHHouseCraftingCategoryContainers != undefined || a_entryObject.keywords.BYOHHouseCraftingCategoryBuilding != undefined || a_entryObject.keywords.BYOHHouseCraftingCategorySmithing != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_HOUSEPART;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$House Part");
      }
      else if(a_entryObject.keywords.VendorItemDaedricArtifact != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_ARTIFACT;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Artifact");
      }
      else if(a_entryObject.keywords.VendorItemGem != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_GEM;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Gem");
      }
      else if(a_entryObject.keywords.VendorItemAnimalHide != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_HIDE;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Hide");
      }
      else if(a_entryObject.keywords.VendorItemTool != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_TOOL;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Tool");
      }
      else if(a_entryObject.keywords.VendorItemAnimalPart != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_REMAINS;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Remains");
      }
      else if(a_entryObject.keywords.VendorItemOreIngot != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_INGOT;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Ingot");
      }
      else if(a_entryObject.keywords.VendorItemFireword != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_FIREWOOD;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Firewood");
      }
      else if(a_entryObject.keywords.VendorItemClutter != undefined)
      {
         a_entryObject.subType = skyui.defines.Item.MISC_CLUTTER;
         a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Clutter");
      }
   }
   function processMiscBaseId(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case skyui.defines.Form.BASEID_GEMAMETHYSTFLAWLESS:
            a_entryObject.subType = skyui.defines.Item.MISC_GEM;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Gem");
            break;
         case skyui.defines.Form.BASEID_DLC2DRAGONCLAW1:
         case skyui.defines.Form.BASEID_DLC2DRAGONCLAW2:
         case skyui.defines.Form.BASEID_RUBYDRAGONCLAW:
         case skyui.defines.Form.BASEID_IVORYDRAGONCLAW:
         case skyui.defines.Form.BASEID_GLASSCLAW:
         case skyui.defines.Form.BASEID_EBONYCLAW:
         case skyui.defines.Form.BASEID_EMERALDDRAGONCLAW:
         case skyui.defines.Form.BASEID_DIAMONDCLAW:
         case skyui.defines.Form.BASEID_IRONCLAW:
         case skyui.defines.Form.BASEID_CORALDRAGONCLAW:
         case skyui.defines.Form.BASEID_E3GOLDENCLAW:
         case skyui.defines.Form.BASEID_SAPPHIREDRAGONCLAW:
         case skyui.defines.Form.BASEID_MS13GOLDENCLAW:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Claw");
            a_entryObject.subType = skyui.defines.Item.MISC_DRAGONCLAW;
            break;
         case skyui.defines.Form.BASEID_GEM1:
         case skyui.defines.Form.BASEID_GEM2:
         case skyui.defines.Form.BASEID_GEM3:
         case skyui.defines.Form.BASEID_GEM4:
         case skyui.defines.Form.BASEID_DLC1GEM1:
         case skyui.defines.Form.BASEID_DLC1GEM2:
         case skyui.defines.Form.BASEID_DLC1GEM3:
         case skyui.defines.Form.BASEID_DLC1GEM4:
         case skyui.defines.Form.BASEID_DLC1GEM5:
         case skyui.defines.Form.BASEID_DLC2GEM1:
         case skyui.defines.Form.BASEID_DLC2GEM2:
         case skyui.defines.Form.BASEID_DLC2GEM3:
         case skyui.defines.Form.BASEID_DLC2GEM4:
         case skyui.defines.Form.BASEID_DLC2GEM5:
         case skyui.defines.Form.BASEID_CCALMSIVIGEM1:
         case skyui.defines.Form.BASEID_CCALMSIVIGEM2:
         case skyui.defines.Form.BASEID_CCALMSIVIGEM3:
         case skyui.defines.Form.BASEID_CCALMSIVIGEM4:
            a_entryObject.subType = skyui.defines.Item.MISC_GEM;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Gem");
            break;
         case skyui.defines.Form.BASEID_REMAINS1:
         case skyui.defines.Form.BASEID_REMAINS2:
         case skyui.defines.Form.BASEID_REMAINS3:
         case skyui.defines.Form.BASEID_REMAINS4:
         case skyui.defines.Form.BASEID_REMAINS5:
         case skyui.defines.Form.BASEID_DLC1REMAINS1:
         case skyui.defines.Form.BASEID_DLC1REMAINS2:
         case skyui.defines.Form.BASEID_DLC1REMAINS3:
         case skyui.defines.Form.BASEID_DLC1REMAINS4:
         case skyui.defines.Form.BASEID_DLC1REMAINS5:
         case skyui.defines.Form.BASEID_DLC1REMAINS6:
         case skyui.defines.Form.BASEID_DLC1REMAINS7:
            a_entryObject.subType = skyui.defines.Item.MISC_REMAINS;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Remains");
            break;
         case skyui.defines.Form.BASEID_DLC2TROLLSKULL:
            a_entryObject.subType = skyui.defines.Item.MISC_TROLLSKULL;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Remains");
            break;
         case skyui.defines.Form.BASEID_LOCKPICK:
            a_entryObject.subType = skyui.defines.Item.MISC_LOCKPICK;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Lockpick");
            break;
         case skyui.defines.Form.BASEID_GOLD001:
            a_entryObject.subType = skyui.defines.Item.MISC_GOLD;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Gold");
            break;
         case skyui.defines.Form.BASEID_LEATHER01:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Leather");
            a_entryObject.subType = skyui.defines.Item.MISC_LEATHER;
            break;
         case skyui.defines.Form.BASEID_LEATHERSTRIPS:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Strips");
            a_entryObject.subType = skyui.defines.Item.MISC_LEATHERSTRIPS;
            break;
         case skyui.defines.Form.BASEID_CHITIN1:
         case skyui.defines.Form.BASEID_DLC1CHITIN1:
         case skyui.defines.Form.BASEID_DLC2CHITIN1:
            a_entryObject.subType = skyui.defines.Item.MISC_NETCHLEATHER;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$NetchLeather");
            break;
         case skyui.defines.Form.BASEID_HFHOUSEPART1:
         case skyui.defines.Form.BASEID_HFHOUSEPART2:
         case skyui.defines.Form.BASEID_HFHOUSEPART3:
         case skyui.defines.Form.BASEID_HFHOUSEPART4:
         case skyui.defines.Form.BASEID_HFHOUSEPART5:
         case skyui.defines.Form.BASEID_HFHOUSEPART6:
         case skyui.defines.Form.BASEID_HFHOUSEPART7:
         case skyui.defines.Form.BASEID_HFHOUSEPART8:
         case skyui.defines.Form.BASEID_HFHOUSEPART9:
         case skyui.defines.Form.BASEID_HFHOUSEPART10:
            a_entryObject.subType = skyui.defines.Item.MISC_HOUSEPART;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$BuildingMaterial");
            break;
         case skyui.defines.Form.BASEID_BROKENWEAPON1:
         case skyui.defines.Form.BASEID_BROKENWEAPON2:
         case skyui.defines.Form.BASEID_BROKENWEAPON3:
         case skyui.defines.Form.BASEID_BROKENWEAPON4:
         case skyui.defines.Form.BASEID_BROKENWEAPON5:
         case skyui.defines.Form.BASEID_BROKENWEAPON6:
         case skyui.defines.Form.BASEID_BROKENWEAPON7:
         case skyui.defines.Form.BASEID_BROKENWEAPON8:
         case skyui.defines.Form.BASEID_BROKENWEAPON9:
         case skyui.defines.Form.BASEID_BROKENWEAPON10:
         case skyui.defines.Form.BASEID_BROKENWEAPON11:
         case skyui.defines.Form.BASEID_BROKENWEAPON12:
         case skyui.defines.Form.BASEID_BROKENWEAPON13:
         case skyui.defines.Form.BASEID_BROKENWEAPON14:
         case skyui.defines.Form.BASEID_BROKENWEAPON15:
         case skyui.defines.Form.BASEID_BROKENWEAPON16:
         case skyui.defines.Form.BASEID_BROKENWEAPON17:
         case skyui.defines.Form.BASEID_BROKENWEAPON18:
         case skyui.defines.Form.BASEID_BROKENWEAPON19:
         case skyui.defines.Form.BASEID_BROKENWEAPON20:
         case skyui.defines.Form.BASEID_BROKENWEAPON21:
         case skyui.defines.Form.BASEID_BROKENWEAPON22:
         case skyui.defines.Form.BASEID_BROKENWEAPON23:
         case skyui.defines.Form.BASEID_BROKENWEAPON24:
         case skyui.defines.Form.BASEID_BROKENWEAPON25:
         case skyui.defines.Form.BASEID_BROKENWEAPON26:
         case skyui.defines.Form.BASEID_BROKENWEAPON27:
         case skyui.defines.Form.BASEID_BROKENWEAPON28:
         case skyui.defines.Form.BASEID_BROKENWEAPON29:
         case skyui.defines.Form.BASEID_BROKENWEAPON30:
         case skyui.defines.Form.BASEID_BROKENWEAPON31:
            a_entryObject.subType = skyui.defines.Item.MISC_BROKENWEAPON;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$BrokenWeapon");
            break;
         case skyui.defines.Form.BASEID_CC067AYLEIDCRYSTAL1:
         case skyui.defines.Form.BASEID_CC067AYLEIDCRYSTAL2:
         case skyui.defines.Form.BASEID_CC067AYLEIDCRYSTAL3:
         case skyui.defines.Form.BASEID_CC067AYLEIDCRYSTAL4:
         case skyui.defines.Form.BASEID_CC067AYLEIDCRYSTAL5:
         case skyui.defines.Form.BASEID_CC067AYLEIDCRYSTAL6:
            a_entryObject.subType = skyui.defines.Item.MISC_AYLEIDCRYSTAL;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$AyleidCrystal");
            break;
         case skyui.defines.Form.BASEID_UPDATEHORSETACK1:
         case skyui.defines.Form.BASEID_UPDATEHORSETACK2:
         case skyui.defines.Form.BASEID_HEARTLANDHORSETACK:
            a_entryObject.subType = skyui.defines.Item.MISC_HORSETACK;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$HorseTack");
            break;
         case skyui.defines.Form.BASEID_DWARVENSCRAP1:
         case skyui.defines.Form.BASEID_DWARVENSCRAP2:
         case skyui.defines.Form.BASEID_DWARVENSCRAP3:
         case skyui.defines.Form.BASEID_DWARVENSCRAP4:
         case skyui.defines.Form.BASEID_DWARVENSCRAP5:
         case skyui.defines.Form.BASEID_DWARVENSCRAP6:
         case skyui.defines.Form.BASEID_DWARVENSCRAP7:
         case skyui.defines.Form.BASEID_DWARVENSCRAP8:
         case skyui.defines.Form.BASEID_DWARVENSCRAP9:
         case skyui.defines.Form.BASEID_DWARVENSCRAP10:
         case skyui.defines.Form.BASEID_DWARVENSCRAP11:
         case skyui.defines.Form.BASEID_DWARVENSCRAP12:
         case skyui.defines.Form.BASEID_CC001DWESCRAP:
            a_entryObject.subType = skyui.defines.Item.MISC_DWARVENSCRAP;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$DwarvenScrap");
            break;
         case skyui.defines.Form.BASEID_INSTRUMENT1:
         case skyui.defines.Form.BASEID_INSTRUMENT2:
         case skyui.defines.Form.BASEID_INSTRUMENT3:
         case skyui.defines.Form.BASEID_INSTRUMENT4:
         case skyui.defines.Form.BASEID_INSTRUMENT5:
         case skyui.defines.Form.BASEID_INSTRUMENT6:
         case skyui.defines.Form.BASEID_INSTRUMENT7:
         case skyui.defines.Form.BASEID_INSTRUMENT8:
         case skyui.defines.Form.BASEID_INSTRUMENT9:
         case skyui.defines.Form.BASEID_HEARTLANDINSTRUMENT1:
         case skyui.defines.Form.BASEID_HEARTLANDINSTRUMENT2:
         case skyui.defines.Form.BASEID_HEARTLANDINSTRUMENT3:
            a_entryObject.subType = skyui.defines.Item.MISC_INSTRUMENT;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Instrument");
            break;
         case skyui.defines.Form.BASEID_BUGJAR1:
         case skyui.defines.Form.BASEID_BUGJAR2:
         case skyui.defines.Form.BASEID_BUGJAR3:
         case skyui.defines.Form.BASEID_BUGJAR4:
         case skyui.defines.Form.BASEID_BUGJAR5:
         case skyui.defines.Form.BASEID_CC025BUGJAR1:
         case skyui.defines.Form.BASEID_CC025BUGJAR2:
         case skyui.defines.Form.BASEID_CC025BUGJAR3:
            a_entryObject.subType = skyui.defines.Item.MISC_BUGJAR;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$BugJar");
            break;
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDERMISC1:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDERMISC2:
            a_entryObject.subType = skyui.defines.Item.MISC_SCROLLSPIDER;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$ScrollSpider");
            break;
         case skyui.defines.Form.BASEID_DLC2NETCHLEATHER:
            a_entryObject.subType = skyui.defines.Item.MISC_NETCHLEATHER;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$NetchLeather");
            break;
         case skyui.defines.Form.BASEID_MISCMAP1:
         case skyui.defines.Form.BASEID_MISCMAP2:
         case skyui.defines.Form.BASEID_DLC2MISCMAP:
         case skyui.defines.Form.BASEID_CC031MISCMAP:
            a_entryObject.subType = skyui.defines.Item.MISC_MAP;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Map");
            break;
         case skyui.defines.Form.BASEID_MISCAZURASSTAR:
         case skyui.defines.Form.BASEID_MISCARTIFACT1:
         case skyui.defines.Form.BASEID_MISCARTIFACT2:
            a_entryObject.subType = skyui.defines.Item.MISC_ARTIFACT;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Artifact");
            break;
         case skyui.defines.Form.BASEID_MISCPOTION:
         case skyui.defines.Form.BASEID_CCALMSIVIPOTION:
            a_entryObject.subType = skyui.defines.Item.MISC_POTION;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Potion");
            break;
         case skyui.defines.Form.BASEID_MISCPOISON:
            a_entryObject.subType = skyui.defines.Item.MISC_POISON;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Poison");
            break;
         case skyui.defines.Form.BASEID_MISCSCROLL1:
         case skyui.defines.Form.BASEID_MISCSCROLL2:
         case skyui.defines.Form.BASEID_MISCSCROLL3:
            a_entryObject.subType = skyui.defines.Item.MISC_SCROLL;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Scroll");
            break;
         case skyui.defines.Form.BASEID_MISCBOOK1:
         case skyui.defines.Form.BASEID_MISCBOOK2:
         case skyui.defines.Form.BASEID_MISCBOOK3:
         case skyui.defines.Form.BASEID_MISCBOOK4:
            a_entryObject.subType = skyui.defines.Item.MISC_BOOK;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Book");
            break;
         case skyui.defines.Form.BASEID_MISCRING1:
         case skyui.defines.Form.BASEID_MISCRING2:
         case skyui.defines.Form.BASEID_MISCRING3:
         case skyui.defines.Form.BASEID_MISCRING4:
         case skyui.defines.Form.BASEID_MISCRING5:
            a_entryObject.subType = skyui.defines.Item.MISC_RING;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Ring");
            break;
         case skyui.defines.Form.BASEID_DLC2INGREDIENT:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT1:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT2:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT3:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT4:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT5:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT6:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT7:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT8:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT9:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT10:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT11:
         case skyui.defines.Form.BASEID_CC001PUZZLEINGREDIENT12:
            a_entryObject.subType = skyui.defines.Item.MISC_INGREDIENT;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Ingredient");
            break;
         case skyui.defines.Form.BASEID_ORE1:
         case skyui.defines.Form.BASEID_ORE2:
         case skyui.defines.Form.BASEID_ORE3:
         case skyui.defines.Form.BASEID_ORE4:
         case skyui.defines.Form.BASEID_ORE5:
         case skyui.defines.Form.BASEID_ORE6:
         case skyui.defines.Form.BASEID_ORE7:
         case skyui.defines.Form.BASEID_ORE8:
         case skyui.defines.Form.BASEID_ORE9:
         case skyui.defines.Form.BASEID_ORE10:
         case skyui.defines.Form.BASEID_DLC2ORE1:
         case skyui.defines.Form.BASEID_DLC2ORE2:
         case skyui.defines.Form.BASEID_DLC2ORE3:
         case skyui.defines.Form.BASEID_CC025ORE1:
         case skyui.defines.Form.BASEID_CC025ORE2:
            a_entryObject.subType = skyui.defines.Item.MISC_ORE;
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Ore");
            break;
         default:
            return;
      }
   }
   function processBookBaseId(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case skyui.defines.Form.BASEID_BOOKMAP1:
         case skyui.defines.Form.BASEID_BOOKMAP2:
         case skyui.defines.Form.BASEID_BOOKMAP3:
         case skyui.defines.Form.BASEID_BOOKMAP4:
         case skyui.defines.Form.BASEID_BOOKMAP5:
         case skyui.defines.Form.BASEID_BOOKMAP6:
         case skyui.defines.Form.BASEID_BOOKMAP7:
         case skyui.defines.Form.BASEID_BOOKMAP8:
         case skyui.defines.Form.BASEID_BOOKMAP9:
         case skyui.defines.Form.BASEID_BOOKMAP10:
         case skyui.defines.Form.BASEID_BOOKMAP11:
         case skyui.defines.Form.BASEID_BOOKMAP12:
         case skyui.defines.Form.BASEID_DLC2BOOKMAP:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP1:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP2:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP3:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP4:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP5:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP6:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP7:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP8:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP9:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP10:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP11:
         case skyui.defines.Form.BASEID_CC001FISHBOOKMAP12:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$Map");
            return;
         case skyui.defines.Form.BASEID_ELDERSCROLL1:
         case skyui.defines.Form.BASEID_ELDERSCROLL2:
         case skyui.defines.Form.BASEID_DLC1ELDERSCROLL1:
         case skyui.defines.Form.BASEID_DLC1ELDERSCROLL2:
         case skyui.defines.Form.BASEID_DLC1ELDERSCROLL3:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$ElderScroll");
         default:
            return;
      }
   }
   function processScrollBaseId(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER1:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER2:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER3:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER4:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER5:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER6:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER7:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER8:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER9:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER10:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER11:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER12:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER13:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER14:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER15:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER16:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER17:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER18:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER19:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER20:
         case skyui.defines.Form.BASEID_DLC2SCROLLSPIDER21:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$ScrollSpider");
         default:
            return;
      }
   }
   function processPotionBaseId(a_entryObject)
   {
      switch(a_entryObject.baseId)
      {
         case skyui.defines.Form.BASEID_CC067AYLEIDCRYSTALPOTION:
         case skyui.defines.Form.BASEID_HEARTLANDAYLEIDCRYSTALPOTION1:
         case skyui.defines.Form.BASEID_HEARTLANDAYLEIDCRYSTALPOTION2:
            a_entryObject.subTypeDisplay = skyui.util.Translator.translate("$AyleidCrystal");
         default:
            return;
      }
   }
}
