class skyui.defines.Armor
{
	public static var WEIGHT_LIGHT: Number		= 0;
	public static var WEIGHT_HEAVY: Number		= 1;
	public static var WEIGHT_NONE: Number		= 2;

	// SkyUI
	public static var WEIGHT_CLOTHING: Number	= 3;
	public static var WEIGHT_JEWELRY: Number	= 4;
   
	public static var PARTMASK_HEAD: Number           = 0x00000001;
	public static var PARTMASK_HAIR: Number           = 0x00000002;
	public static var PARTMASK_BODY: Number           = 0x00000004;
	public static var PARTMASK_HANDS: Number          = 0x00000008;
	public static var PARTMASK_FOREARMS: Number       = 0x00000010;
	public static var PARTMASK_AMULET: Number         = 0x00000020;
	public static var PARTMASK_RING: Number           = 0x00000040;
	public static var PARTMASK_FEET: Number           = 0x00000080;
	public static var PARTMASK_CALVES: Number         = 0x00000100;
	public static var PARTMASK_SHIELD: Number         = 0x00000200;
	public static var PARTMASK_TAIL: Number           = 0x00000400;
	public static var PARTMASK_LONGHAIR: Number       = 0x00000800;
	public static var PARTMASK_CIRCLET: Number        = 0x00001000;
	public static var PARTMASK_EARS: Number           = 0x00002000;
	public static var PARTMASK_UNNAMED14: Number      = 0x00004000;
	public static var PARTMASK_UNNAMED15: Number      = 0x00008000;
	public static var PARTMASK_CLOAK: Number          = 0x00010000;
	public static var PARTMASK_BACKPACK: Number       = 0x00020000;
	public static var PARTMASK_UNNAMED18: Number      = 0x00040000;
	public static var PARTMASK_UNNAMED19: Number      = 0x00080000;
	public static var PARTMASK_DECAPITATEHEAD: Number = 0x00100000;
	public static var PARTMASK_DECAPITATE: Number     = 0x00200000;
	public static var PARTMASK_UNNAMED22: Number      = 0x00400000;
	public static var PARTMASK_UNNAMED23: Number      = 0x00800000;
	public static var PARTMASK_UNNAMED24: Number      = 0x01000000;
	public static var PARTMASK_UNNAMED25: Number      = 0x02000000;
	public static var PARTMASK_UNNAMED26: Number      = 0x04000000;
	public static var PARTMASK_UNNAMED27: Number      = 0x08000000;
	public static var PARTMASK_UNNAMED28: Number      = 0x10000000;
	public static var PARTMASK_UNNAMED29: Number      = 0x20000000;
	public static var PARTMASK_UNNAMED30: Number      = 0x40000000;
	public static var PARTMASK_FX01: Number           = 0x80000000;

   public static var PARTMASK_PRECEDENCE = [
      skyui.defines.Armor.PARTMASK_BODY,
      skyui.defines.Armor.PARTMASK_HAIR,
      skyui.defines.Armor.PARTMASK_HANDS,
      skyui.defines.Armor.PARTMASK_FOREARMS,
      skyui.defines.Armor.PARTMASK_FEET,
      skyui.defines.Armor.PARTMASK_CALVES,
      skyui.defines.Armor.PARTMASK_SHIELD,
      skyui.defines.Armor.PARTMASK_AMULET,
      skyui.defines.Armor.PARTMASK_RING,
      skyui.defines.Armor.PARTMASK_LONGHAIR,
      skyui.defines.Armor.PARTMASK_EARS,
      skyui.defines.Armor.PARTMASK_HEAD,
      skyui.defines.Armor.PARTMASK_CIRCLET,
      skyui.defines.Armor.PARTMASK_TAIL,
      skyui.defines.Armor.PARTMASK_UNNAMED14,
      skyui.defines.Armor.PARTMASK_UNNAMED15,
      skyui.defines.Armor.PARTMASK_CLOAK,
      skyui.defines.Armor.PARTMASK_BACKPACK,
      skyui.defines.Armor.PARTMASK_UNNAMED18,
      skyui.defines.Armor.PARTMASK_UNNAMED19,
      skyui.defines.Armor.PARTMASK_DECAPITATEHEAD,
      skyui.defines.Armor.PARTMASK_DECAPITATE,
      skyui.defines.Armor.PARTMASK_UNNAMED22,
      skyui.defines.Armor.PARTMASK_UNNAMED23,
      skyui.defines.Armor.PARTMASK_UNNAMED24,
      skyui.defines.Armor.PARTMASK_UNNAMED25,
      skyui.defines.Armor.PARTMASK_UNNAMED26,
      skyui.defines.Armor.PARTMASK_UNNAMED27,
      skyui.defines.Armor.PARTMASK_UNNAMED28,
      skyui.defines.Armor.PARTMASK_UNNAMED29,
      skyui.defines.Armor.PARTMASK_UNNAMED30,
      skyui.defines.Armor.PARTMASK_FX01
   ];

   // SkyUI
   public static var EQUIP_HEAD: Number     = 0;
   public static var EQUIP_HAIR: Number     = 1;
   public static var EQUIP_LONGHAIR: Number = 2;
   public static var EQUIP_BODY: Number     = 3;
   public static var EQUIP_FOREARMS: Number = 4;
   public static var EQUIP_HANDS: Number    = 5;
   public static var EQUIP_SHIELD: Number   = 6;
   public static var EQUIP_CALVES: Number   = 7;
   public static var EQUIP_FEET: Number     = 8;
   public static var EQUIP_CIRCLET: Number  = 9;
   public static var EQUIP_AMULET: Number   = 10;
   public static var EQUIP_EARS: Number     = 11;
   public static var EQUIP_RING: Number     = 12;
   public static var EQUIP_TAIL: Number     = 13;
   public static var EQUIP_BACKPACK: Number = 14;
   public static var EQUIP_CLOAK: Number    = 15;
}
