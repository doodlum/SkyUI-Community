class InventoryIconSetter implements skyui.components.list.IListProcessor
{
  /* PRIVATE VARIABLES */

    private var _noIconColors: Boolean;


  /* INITIALIZATION */

    public function InventoryIconSetter(a_configAppearance: Object)
    {
        this._noIconColors = a_configAppearance.icons.item.noColor;
    }


  /* PUBLIC FUNCTIONS */
    
    // @override IListProcessor
    public function processList(a_list: BasicList)
    {
        var entryList: Array = a_list.entryList;
        
        for (var i: Number = 0; i < entryList.length; i++)
            this.processEntry(entryList[i]);
    }


  /* PRIVATE FUNCTIONS */

    private function processEntry(a_entryObject: Object)
    {
        switch (a_entryObject.formType) {
            case skyui.defines.Form.TYPE_SCROLLITEM:
                this.processScrollIcon(a_entryObject);
                this.processResist(a_entryObject);
                break;

            case skyui.defines.Form.TYPE_ARMOR:
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
                break;

            case skyui.defines.Form.TYPE_SOULGEM:
                this.processSoulGemIcon(a_entryObject);
                break;
        }

        if (this._noIconColors && a_entryObject.iconColor != undefined)
            delete(a_entryObject.iconColor);
    }

    private function processResist(a_entryObject: Object)
    {
        if (a_entryObject.resistance == undefined || a_entryObject.resistance == skyui.defines.Actor.AV_NONE)
            return;

        switch(a_entryObject.resistance) {
            case skyui.defines.Actor.AV_FIRERESIST:
                a_entryObject.iconColor = 0xC73636;
                break;

            case skyui.defines.Actor.AV_ELECTRICRESIST:
                a_entryObject.iconColor = 0xFFFF00;
                break;

            case skyui.defines.Actor.AV_FROSTRESIST:
                a_entryObject.iconColor = 0x1FFBFF;
                break;
        }
    }

    private function processArmorIcon(a_entryObject: Object)
    {
        a_entryObject.iconLabel = "default_armor";
        a_entryObject.iconColor = 0xEDDA87;

        switch(a_entryObject.subType)
        {
            case skyui.defines.Armor.EQUIP_CLOAK:
                a_entryObject.iconLabel = "clothing_cloak";
                break;
            case skyui.defines.Armor.EQUIP_BACKPACK:
                a_entryObject.iconLabel = "clothing_backpack";
                break;
        }

        switch(a_entryObject.weightClass) {
            case skyui.defines.Armor.WEIGHT_LIGHT:
                this.processLightArmorIcon(a_entryObject);
                break;

            case skyui.defines.Armor.WEIGHT_HEAVY:
                this.processHeavyArmorIcon(a_entryObject);
                break;

            case skyui.defines.Armor.WEIGHT_JEWELRY:
                this.processJewelryArmorIcon(a_entryObject);
                break;

            case skyui.defines.Armor.WEIGHT_CLOTHING:
            default:
                this.processClothingArmorIcon(a_entryObject);
                break;
        }
    }

    private function processLightArmorIcon(a_entryObject: Object)
    {
        a_entryObject.iconColor = 0x756000;

        switch(a_entryObject.subType) {
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
                break;


        }
    }

    private function processHeavyArmorIcon(a_entryObject: Object)
    {
        a_entryObject.iconColor = 0x6B7585;

        switch(a_entryObject.subType) {
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
                break;

        }
    }

    private function processJewelryArmorIcon(a_entryObject: Object)
    {
        switch(a_entryObject.subType) {
            case skyui.defines.Armor.EQUIP_AMULET:
                a_entryObject.iconLabel = "armor_amulet";
                break;

            case skyui.defines.Armor.EQUIP_RING:
                a_entryObject.iconLabel = "armor_ring";
                break;

            case skyui.defines.Armor.EQUIP_CIRCLET:
                a_entryObject.iconLabel = "armor_circlet";
                break;

            case skyui.defines.Armor.EQUIP_EARS:
                break;
        }
    }

    private function processClothingArmorIcon(a_entryObject: Object)
    {
        switch(a_entryObject.subType) {
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
                break;

            case skyui.defines.Armor.EQUIP_EARS:
                break;

        }
    }

    // Scrolls
    private function processScrollIcon(a_entryObject: Object)
    {
        a_entryObject.iconLabel = "default_scroll";
        switch(a_entryObject.subType)
        {
            case skyui.defines.Item.SCROLL_SPIDER:
                a_entryObject.iconLabel = "scroll_spider";
                break;
        }
    }

    // Books
    private function processBookIcon(a_entryObject: Object)
    {
        a_entryObject.iconLabel = "default_book";

        switch(a_entryObject.subType) {
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
                a_entryObject.iconColor = 0x75664D;
                break;
        }
    }

    // Weapons
    private function processWeaponIcon(a_entryObject: Object)
    {
        a_entryObject.iconLabel = "default_weapon";
        a_entryObject.iconColor = 0xA4A5BF;

        switch(a_entryObject.subType) {
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
                break;

            case skyui.defines.Weapon.TYPE_MELEE:
                break;
        }
    }

    // Ammo
    private function processAmmoIcon(a_entryObject: Object)
    {
        a_entryObject.iconLabel = "weapon_arrow";
        a_entryObject.iconColor = 0xA89E8C;

        switch(a_entryObject.subType) {
            case skyui.defines.Weapon.AMMO_ARROW:
                a_entryObject.iconLabel = "weapon_arrow";
                break;
            case skyui.defines.Weapon.AMMO_BOLT:
                a_entryObject.iconLabel = "weapon_bolt";
                break;
        }
    }

    private function processPotionIcon(a_entryObject: Object)
    {
        a_entryObject.iconLabel = "default_potion";

        switch(a_entryObject.subType) {
            case skyui.defines.Item.POTION_DRINK:
                a_entryObject.iconLabel = "food_wine";
                break;

            case skyui.defines.Item.POTION_FOOD:
                a_entryObject.iconLabel = "default_food";
                break;
                
            case skyui.defines.Item.POTION_POISON:
                a_entryObject.iconLabel = "potion_poison";
                a_entryObject.iconColor = 0xAD00B3;
                break;
                
            case skyui.defines.Item.POTION_HEALTH:
            case skyui.defines.Item.POTION_HEALRATE:
            case skyui.defines.Item.POTION_HEALRATEMULT:
                a_entryObject.iconLabel = "potion_health";
                a_entryObject.iconColor = 0xDB2E73;
                break;
                
            case skyui.defines.Item.POTION_MAGICKA:
            case skyui.defines.Item.POTION_MAGICKARATE:
            case skyui.defines.Item.POTION_MAGICKARATEMULT:
                a_entryObject.iconLabel = "potion_magic";
                a_entryObject.iconColor = 0x2E9FDB;
                break;
                
            case skyui.defines.Item.POTION_STAMINA:	
            case skyui.defines.Item.POTION_STAMINARATE:
            case skyui.defines.Item.POTION_STAMINARATEMULT:
                a_entryObject.iconLabel = "potion_stam";
                a_entryObject.iconColor = 0x51DB2E;
                break;

            case skyui.defines.Item.POTION_FIRERESIST:
                a_entryObject.iconLabel = "potion_fire";
                a_entryObject.iconColor = 0xC73636;
                break;

            case skyui.defines.Item.POTION_ELECTRICRESIST:
                a_entryObject.iconLabel = "potion_shock";
                a_entryObject.iconColor = 0xEAAB00;
                break;

            case skyui.defines.Item.POTION_AYLEIDCRYSTAL:
                a_entryObject.iconLabel = "soulgem_ayleidcrystalfull";
                a_entryObject.iconColor = 0x5BC4C9;
                break;

            case skyui.defines.Item.POTION_FROSTRESIST:
                a_entryObject.iconLabel = "potion_frost";
                a_entryObject.iconColor = 0x1FFBFF;
                break;
        }

    }

    private function processSoulGemIcon(a_entryObject: Object)
    {
        a_entryObject.iconLabel = "misc_soulgem";
        a_entryObject.iconColor = 0xE3E0FF;

        switch(a_entryObject.subType) {
            case skyui.defines.Item.SOULGEM_PETTY:
                a_entryObject.iconColor = 0xD7D4FF;
                this.processSoulGemStatusIcon(a_entryObject);
                break;

            case skyui.defines.Item.SOULGEM_LESSER:
                a_entryObject.iconColor = 0xC0BAFF;
                this.processSoulGemStatusIcon(a_entryObject);
                break;

            case skyui.defines.Item.SOULGEM_COMMON:
                a_entryObject.iconColor = 0xABA3FF;
                this.processSoulGemStatusIcon(a_entryObject);
                break;

            case skyui.defines.Item.SOULGEM_GREATER:
                a_entryObject.iconColor = 0x948BFC;
                this.processGrandSoulGemIcon(a_entryObject);
                break;

            case skyui.defines.Item.SOULGEM_GRAND:
                a_entryObject.iconColor = 0x7569FF;
                this.processGrandSoulGemIcon(a_entryObject);
                break;

            case skyui.defines.Item.SOULGEM_SOULTOMATO:
                a_entryObject.iconColor = 0xD14A38;
                this.processSoulTomatoIcon(a_entryObject);
                break;

            case skyui.defines.Item.SOULGEM_AZURA:
                a_entryObject.iconColor = 0x7569FF;
                a_entryObject.iconLabel = "soulgem_azura";
                break;
        }
    }

    private function processSoulTomatoIcon(a_entryObject: Object)
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

    private function processGrandSoulGemIcon(a_entryObject: Object) {
        switch(a_entryObject.status) {
            case skyui.defines.Item.SOULGEMSTATUS_EMPTY:
                a_entryObject.iconLabel = "soulgem_grandempty";
                break;

            case skyui.defines.Item.SOULGEMSTATUS_FULL:
                a_entryObject.iconLabel = "soulgem_grandfull";
                break;

            case skyui.defines.Item.SOULGEMSTATUS_PARTIAL:
                a_entryObject.iconLabel = "soulgem_grandpartial";
                break;
        }
    }

    private function processSoulGemStatusIcon(a_entryObject: Object) {
        switch(a_entryObject.status) {
            case skyui.defines.Item.SOULGEMSTATUS_EMPTY:
                a_entryObject.iconLabel = "soulgem_empty";
                break;

            case skyui.defines.Item.SOULGEMSTATUS_FULL:
                a_entryObject.iconLabel = "soulgem_full";
                break;

            case skyui.defines.Item.SOULGEMSTATUS_PARTIAL:
                a_entryObject.iconLabel = "soulgem_partial";
                break;
        }
    }

    private function processMiscIcon(a_entryObject: Object)
    {
        if(a_entryObject.iconLabel != undefined)
            return;

        a_entryObject.iconLabel = "default_misc";

        switch(a_entryObject.subType) {
            case skyui.defines.Item.MISC_ARTIFACT:
                a_entryObject.iconLabel = "misc_artifact";
                break;

            case skyui.defines.Item.MISC_GEM:
                a_entryObject.iconLabel = "misc_gem";
                a_entryObject.iconColor = 0xFFB0D1;
                break;

            case skyui.defines.Item.MISC_HIDE:
                a_entryObject.iconLabel = "misc_hide";
                a_entryObject.iconColor = 0xDBB36E;
                break;

            case skyui.defines.Item.MISC_REMAINS:
                a_entryObject.iconLabel = "misc_remains";
                break;

            case skyui.defines.Item.MISC_INGOT:
                a_entryObject.iconLabel = "misc_ingot";
                a_entryObject.iconColor = 0x828282;
                break;

            case skyui.defines.Item.MISC_CLUTTER:
                a_entryObject.iconLabel = "misc_clutter";
                break;

            case skyui.defines.Item.MISC_FIREWOOD:
                a_entryObject.iconLabel = "misc_wood";
                a_entryObject.iconColor = 0xA89E8C;
                break;

            case skyui.defines.Item.MISC_DRAGONCLAW:
                a_entryObject.iconLabel = "misc_dragonclaw";
                break;

            case skyui.defines.Item.MISC_LOCKPICK:
                a_entryObject.iconLabel = "misc_lockpick";
                break;

            case skyui.defines.Item.MISC_GOLD:
                a_entryObject.iconLabel = "misc_gold";
                a_entryObject.iconColor = 0xCCCC33;
                break;

            case skyui.defines.Item.MISC_LEATHER:
                a_entryObject.iconLabel = "misc_leather";
                a_entryObject.iconColor = 0xBA8D23;
                break;

            case skyui.defines.Item.MISC_NETCHLEATHER:
                a_entryObject.iconLabel = "misc_strips";
                a_entryObject.iconColor = 0x78558E;
                break;

            case skyui.defines.Item.MISC_LEATHERSTRIPS:
                a_entryObject.iconLabel = "misc_strips";
                a_entryObject.iconColor = 0xBA8D23;
                break;

            case skyui.defines.Item.MISC_TROLLSKULL:
                a_entryObject.iconLabel = "misc_trollskull";
                break;

            case skyui.defines.Item.MISC_CHILDRENSCLOTHES:
                a_entryObject.iconColor = 0xEDDA87;
                a_entryObject.iconLabel = "clothing_body";
                break;
            
            case skyui.defines.Item.MISC_ORE:
                a_entryObject.iconLabel = "misc_ore";
                a_entryObject.iconColor = 0x828282;
                break;

            case skyui.defines.Item.MISC_HOUSEPART:
                a_entryObject.iconLabel = "misc_housepart";
                a_entryObject.iconColor = 0xFFFFFF;
                break;

            case skyui.defines.Item.MISC_BROKENWEAPON:
                a_entryObject.iconLabel = "default_weapon";
                a_entryObject.iconColor = 0xFFFFFF;
                break;

            case skyui.defines.Item.MISC_AYLEIDCRYSTAL:
                a_entryObject.iconLabel = "soulgem_ayleidcrystalfull";
                a_entryObject.iconColor = 0x5BC4C9;
                break;

            case skyui.defines.Item.MISC_HORSETACK:
                a_entryObject.iconLabel = "misc_horsetack";
                break;

            case skyui.defines.Item.MISC_DWARVENSCRAP:
                a_entryObject.iconLabel = "misc_dwarvenscrap";
                a_entryObject.iconColor = 0x705F32;
                break;

            case skyui.defines.Item.MISC_SCROLLSPIDER:
                a_entryObject.iconLabel = "scroll_spider";
                break;
                
            case skyui.defines.Item.MISC_INSTRUMENT:
                a_entryObject.iconLabel = "misc_instrument";
                a_entryObject.iconColor = 0xFFFFFF;
                break;
                
            case skyui.defines.Item.MISC_BUGJAR:
                a_entryObject.iconLabel = "misc_jar";
                a_entryObject.iconColor = 0xFFFFFF;
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
                break;
        }
    }

    private function processMiscBaseIdIcon(a_entryObject: Object)
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
}

