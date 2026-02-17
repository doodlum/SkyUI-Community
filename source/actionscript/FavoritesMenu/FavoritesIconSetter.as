class FavoritesIconSetter implements skyui.components.list.IListProcessor
{
	/* INITIALIZATION */

	public function FavoritesIconSetter(a_configAppearance)
	{
	}


	/* PUBLIC FUNCTIONS */

	// @override IListProcessor
	public function processList(a_list)
	{
		var entryList = a_list.entryList;

		var i = 0;
		while (i < entryList.length)
		{
			this.processEntry(entryList[i]);
			i = i + 1;
		}
	}


	/* PRIVATE FUNCTIONS */

	private function processEntry(a_entryObject)
	{
		switch (a_entryObject.formType)
		{
			case skyui.defines.Form.TYPE_SCROLLITEM:
				a_entryObject.iconLabel = "default_scroll";
				return;
			case skyui.defines.Form.TYPE_ARMOR:
				this.processArmorClass(a_entryObject);
				this.processArmorPartMask(a_entryObject);
				this.processArmorOther(a_entryObject);
				this.processArmorBaseId(a_entryObject);
				this.processArmorIcon(a_entryObject);
				return;
			case skyui.defines.Form.TYPE_INGREDIENT:
				a_entryObject.iconLabel = "default_ingredient";
				return;
			case skyui.defines.Form.TYPE_LIGHT:
				a_entryObject.iconLabel = "misc_torch";
				return;
			case skyui.defines.Form.TYPE_WEAPON:
				this.processWeaponType(a_entryObject);
				this.processWeaponBaseId(a_entryObject);
				this.processWeaponIcon(a_entryObject);
				return;
			case skyui.defines.Form.TYPE_AMMO:
				this.processAmmoType(a_entryObject);
				this.processAmmoIcon(a_entryObject);
				return;
			case skyui.defines.Form.TYPE_POTION:
				this.processPotionType(a_entryObject);
				this.processPotionIcon(a_entryObject);
				return;
			case skyui.defines.Form.TYPE_SPELL:
				this.processSpellIcon(a_entryObject);
				return;
			case skyui.defines.Form.TYPE_SHOUT:
				a_entryObject.iconLabel = "default_shout";
				return;
			default:
				a_entryObject.iconLabel = "default_misc";
				return;
		}
	}

	private function processArmorClass(a_entryObject)
	{
		if (a_entryObject.weightClass == skyui.defines.Armor.WEIGHT_NONE)
		{
			a_entryObject.weightClass = null;
		}
		switch (a_entryObject.weightClass)
		{
			default:
				if (a_entryObject.keywords != undefined)
				{
					if (a_entryObject.keywords.VendorItemClothing != undefined)
					{
						a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_CLOTHING;
					}
					else if (a_entryObject.keywords.VendorItemJewelry != undefined)
					{
						a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_JEWELRY;
					}
				}
			case skyui.defines.Armor.WEIGHT_LIGHT:
			case skyui.defines.Armor.WEIGHT_HEAVY:
				return;
		}
	}

	private function processArmorPartMask(a_entryObject)
	{
		if (a_entryObject.partMask == undefined)
		{
			return undefined;
		}
		// Sets subType as the most important bitmask index.
		var i = 0;
		while (i < skyui.defines.Armor.PARTMASK_PRECEDENCE.length)
		{
			if (a_entryObject.partMask & skyui.defines.Armor.PARTMASK_PRECEDENCE[i])
			{
				a_entryObject.mainPartMask = skyui.defines.Armor.PARTMASK_PRECEDENCE[i];
				break;
			}
			i = i + 1;
		}
		if (a_entryObject.mainPartMask == undefined)
		{
			return undefined;
		}
		switch (a_entryObject.mainPartMask)
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
			default:
				a_entryObject.subType = a_entryObject.mainPartMask;
				return;
		}
	}

	private function processArmorOther(a_entryObject)
	{
		if (a_entryObject.weightClass != null)
		{
			return undefined;
		}
		switch (a_entryObject.mainPartMask)
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

	private function processArmorBaseId(a_entryObject)
	{
		switch (a_entryObject.baseId)
		{
			case skyui.defines.Form.BASEID_CLOTHESWEDDINGWREATH:
				a_entryObject.weightClass = skyui.defines.Armor.WEIGHT_JEWELRY;
				break;
			case skyui.defines.Form.BASEID_DLC1CLOTHESVAMPIRELORDARMOR:
				a_entryObject.subType = skyui.defines.Armor.EQUIP_BODY;
			default:
				return;
		}
	}

	private function processArmorIcon(a_entryObject)
	{
		a_entryObject.iconLabel = "default_armor";
		switch (a_entryObject.weightClass)
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

	private function processLightArmorIcon(a_entryObject)
	{
		switch (a_entryObject.subType)
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

	private function processHeavyArmorIcon(a_entryObject)
	{
		switch (a_entryObject.subType)
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

	private function processJewelryArmorIcon(a_entryObject)
	{
		switch (a_entryObject.subType)
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

	private function processClothingArmorIcon(a_entryObject)
	{
		switch (a_entryObject.subType)
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

	private function processWeaponType(a_entryObject)
	{
		a_entryObject.subType = null;
		switch (a_entryObject.weaponType)
		{
			case skyui.defines.Weapon.ANIM_HANDTOHANDMELEE:
			case skyui.defines.Weapon.ANIM_H2H:
				a_entryObject.subType = skyui.defines.Weapon.TYPE_MELEE;
				break;
			case skyui.defines.Weapon.ANIM_ONEHANDSWORD:
			case skyui.defines.Weapon.ANIM_1HS:
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
				if (a_entryObject.keywords != undefined && a_entryObject.keywords.WeapTypeWarhammer != undefined)
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

	private function processWeaponBaseId(a_entryObject)
	{
		switch (a_entryObject.baseId)
		{
			case skyui.defines.Form.BASEID_WEAPPICKAXE:
			case skyui.defines.Form.BASEID_SSDROCKSPLINTERPICKAXE:
			case skyui.defines.Form.BASEID_DUNVOLUNRUUDPICKAXE:
				a_entryObject.subType = skyui.defines.Weapon.TYPE_PICKAXE;
				break;
			case skyui.defines.Form.BASEID_AXE01:
			case skyui.defines.Form.BASEID_DUNHALTEDSTREAMPOACHERSAXE:
				a_entryObject.subType = skyui.defines.Weapon.TYPE_WOODAXE;
			default:
				return;
		}
	}

	// Weapons
	private function processWeaponIcon(a_entryObject)
	{
		a_entryObject.iconLabel = "default_weapon";
		switch (a_entryObject.subType)
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
			case skyui.defines.Weapon.TYPE_WOODAXE:
				a_entryObject.iconLabel = "weapon_woodaxe";
			case skyui.defines.Weapon.TYPE_MELEE:
			default:
				return;
		}
	}

	private function processAmmoType(a_entryObject)
	{
		if ((a_entryObject.flags & skyui.defines.Weapon.AMMOFLAG_NONBOLT) != 0)
		{
			a_entryObject.subType = skyui.defines.Weapon.AMMO_ARROW;
		}
		else
		{
			a_entryObject.subType = skyui.defines.Weapon.AMMO_BOLT;
		}
	}

	// Ammo
	private function processAmmoIcon(a_entryObject)
	{
		a_entryObject.iconLabel = "weapon_arrow";
		switch (a_entryObject.subType)
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

	private function processPotionType(a_entryObject)
	{
		a_entryObject.subType = skyui.defines.Item.POTION_POTION;
		if ((a_entryObject.flags & skyui.defines.Item.ALCHFLAG_FOOD) != 0)
		{
			a_entryObject.subType = skyui.defines.Item.POTION_FOOD;
			// SKSE >= 1.6.6
			if (a_entryObject.useSound.formId != undefined && a_entryObject.useSound.formId == skyui.defines.Form.FORMID_ITMPotionUse)
			{
				a_entryObject.subType = skyui.defines.Item.POTION_DRINK;
			}
		}
		else if ((a_entryObject.flags & skyui.defines.Item.ALCHFLAG_POISON) != 0)
		{
			a_entryObject.subType = skyui.defines.Item.POTION_POISON;
		}
		else
		{
			switch (a_entryObject.actorValue)
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

	private function processPotionIcon(a_entryObject)
	{
		a_entryObject.iconLabel = "default_potion";
		switch (a_entryObject.subType)
		{
			case skyui.defines.Item.POTION_DRINK:
				a_entryObject.iconLabel = "food_wine";
				break;
			case skyui.defines.Item.POTION_FOOD:
				a_entryObject.iconLabel = "default_food";
				break;
			case skyui.defines.Item.POTION_POISON:
				a_entryObject.iconLabel = "potion_poison";
				break;
			case skyui.defines.Item.POTION_HEALTH:
			case skyui.defines.Item.POTION_HEALRATE:
			case skyui.defines.Item.POTION_HEALRATEMULT:
				a_entryObject.iconLabel = "potion_health";
				break;
			case skyui.defines.Item.POTION_MAGICKA:
			case skyui.defines.Item.POTION_MAGICKARATE:
			case skyui.defines.Item.POTION_MAGICKARATEMULT:
				a_entryObject.iconLabel = "potion_magic";
				break;
			case skyui.defines.Item.POTION_STAMINA:
			case skyui.defines.Item.POTION_STAMINARATE:
			case skyui.defines.Item.POTION_STAMINARATEMULT:
				a_entryObject.iconLabel = "potion_stam";
				break;
			case skyui.defines.Item.POTION_FIRERESIST:
				a_entryObject.iconLabel = "potion_fire";
				break;
			case skyui.defines.Item.POTION_ELECTRICRESIST:
				a_entryObject.iconLabel = "potion_shock";
				break;
			case skyui.defines.Item.POTION_FROSTRESIST:
				a_entryObject.iconLabel = "potion_frost";
			default:
				return;
		}
	}

	private function processSpellIcon(a_entryObject)
	{
		a_entryObject.iconLabel = "default_power";
		switch (a_entryObject.school)
		{
			case skyui.defines.Actor.AV_ALTERATION:
				a_entryObject.iconLabel = "default_alteration";
				break;
			case skyui.defines.Actor.AV_CONJURATION:
				a_entryObject.iconLabel = "default_conjuration";
				break;
			case skyui.defines.Actor.AV_DESTRUCTION:
				a_entryObject.iconLabel = "default_destruction";
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
}
