class BottomBar extends MovieClip
{   
  /* PRIVATE VARIABLES */	

    private var _lastItemType: Number;
    
    private var _healthMeter: Meter;
    private var _magickaMeter: Meter;
    private var _staminaMeter: Meter;
    private var _levelMeter: Meter;

    private var _playerInfoObj: Object;
    
    
  /* STAGE ELEMENTS */

    public var playerInfoCard: MovieClip;
    
    
  /* PROPERTIES */

    public var buttonPanel: ButtonPanel;
    
    
  /* INITIALIZATION */

    public function BottomBar()
    {
        super();
        this._lastItemType = skyui.defines.Inventory.ICT_NONE;
        this._healthMeter = new Components.Meter(this.playerInfoCard.HealthRect.MeterInstance.Meter_mc);
        this._magickaMeter = new Components.Meter(this.playerInfoCard.MagickaRect.MeterInstance.Meter_mc);
        this._staminaMeter = new Components.Meter(this.playerInfoCard.StaminaRect.MeterInstance.Meter_mc);
        this._levelMeter = new Components.Meter(this.playerInfoCard.LevelMeterInstance.Meter_mc);
    }
    
    
  /* PUBLIC FUNCTIONS */

    public function positionElements(a_leftOffset: Number, a_rightOffset: Number)
    {
        this.buttonPanel._x = a_leftOffset;
        this.buttonPanel.updateButtons(true);
        this.playerInfoCard._x = a_rightOffset - this.playerInfoCard._width;
    }

    public function showPlayerInfo()
    {
        this.playerInfoCard._alpha = 100;
    }

    public function hidePlayerInfo()
    {
        this.playerInfoCard._alpha = 0;
    }

    // @API
    public function UpdatePlayerInfo(a_playerUpdateObj: Object, a_itemUpdateObj: Object)
    {
        this._playerInfoObj = a_playerUpdateObj;
        this.updatePerItemInfo(a_itemUpdateObj);
    }

    public function updatePerItemInfo(a_itemUpdateObj: Object)
    {
        var infoCard = this.playerInfoCard;
        var itemType: Number = a_itemUpdateObj.type;
        var bHasWeightandValue = true;
        
        if (itemType == undefined) {
            itemType = this._lastItemType;
            if (a_itemUpdateObj == undefined)
                a_itemUpdateObj = {type: this._lastItemType};
        } else {
            this._lastItemType = itemType;
        }
        if (this._playerInfoObj != undefined && a_itemUpdateObj != undefined) {
            switch(itemType) {
                case skyui.defines.Inventory.ICT_ARMOR:
                    infoCard.gotoAndStop("Armor");
                    var strArmor: String = Math.floor(this._playerInfoObj.armor).toString();
                    if (a_itemUpdateObj.armorChange != undefined) {
                        var iArmorDelta = Math.round(a_itemUpdateObj.armorChange);
                        if (iArmorDelta > 0) 
                            strArmor = strArmor + " <font color=\'#189515\'>(+" + iArmorDelta.toString() + ")</font>";
                        else if (iArmorDelta < 0) 
                            strArmor = strArmor + " <font color=\'#FF0000\'>(" + iArmorDelta.toString() + ")</font>";
                    }
                    infoCard.ArmorRatingValue.textAutoSize = "shrink";
                    infoCard.ArmorRatingValue.html = true;
                    infoCard.ArmorRatingValue.SetText(strArmor, true);
                    
                    var strWarmth  = this._playerInfoObj.warmth != undefined ? Math.floor(this._playerInfoObj.warmth).toString() : "0";
                    if (a_itemUpdateObj.warmthChange != undefined)
                    {
                        var iWarmthDelta = Math.round(a_itemUpdateObj.warmthChange);
                        if (iWarmthDelta > 0)
                            strWarmth = strWarmth + " <font color=\'#189515\'>(+" + iWarmthDelta.toString() + ")</font>";
                        else if (iWarmthDelta < 0)
                            strWarmth = strWarmth + " <font color=\'#FF0000\'>(" + iWarmthDelta.toString() + ")</font>";
                    }
                    infoCard.WarmthRatingLabel._visible = this._playerInfoObj.warmth != undefined;
                    infoCard.WarmthRatingValue._visible = this._playerInfoObj.warmth != undefined;
                    infoCard.WarmthRatingValue.textAutoSize = "shrink";
                    infoCard.WarmthRatingValue.html = true;
                    infoCard.WarmthRatingValue.SetText(strWarmth, true);
                    break;
                    
                case skyui.defines.Inventory.ICT_WEAPON:
                    infoCard.gotoAndStop("Weapon");
                    var strDamage: String = Math.floor(this._playerInfoObj.damage).toString();
                    if (a_itemUpdateObj.damageChange != undefined) {
                        var iDamageDelta = Math.round(a_itemUpdateObj.damageChange);
                        if (iDamageDelta > 0) 
                            strDamage = strDamage + " <font color=\'#189515\'>(+" + iDamageDelta.toString() + ")</font>";
                        else if (iDamageDelta < 0) 
                            strDamage = strDamage + " <font color=\'#FF0000\'>(" + iDamageDelta.toString() + ")</font>";
                    }
                    infoCard.DamageValue.textAutoSize = "shrink";
                    infoCard.DamageValue.html = true;
                    infoCard.DamageValue.SetText(strDamage, true);
                    break;
                    
                case skyui.defines.Inventory.ICT_POTION:
                case skyui.defines.Inventory.ICT_FOOD:
                    var EF_HEALTH: Number = 0;
                    var EF_MAGICKA: Number = 1;
                    var EF_STAMINA: Number = 2;
                    if (a_itemUpdateObj.potionType == EF_MAGICKA) 
                        infoCard.gotoAndStop("MagickaPotion");
                    else if (a_itemUpdateObj.potionType == EF_STAMINA) 
                        infoCard.gotoAndStop("StaminaPotion");
                    else if (a_itemUpdateObj.potionType == EF_HEALTH) 
                        infoCard.gotoAndStop("HealthPotion");
                    break;
                    
                case skyui.defines.Inventory.ICT_SPELL_DEFAULT:
                case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
                    infoCard.gotoAndStop("Magic");
                    bHasWeightandValue = false;
                    break;
                    
                case skyui.defines.Inventory.ICT_SPELL:
                    infoCard.gotoAndStop("MagicSkill");
                    if (a_itemUpdateObj.magicSchoolName != undefined) 
                        this.updateSkillBar(a_itemUpdateObj.magicSchoolName, a_itemUpdateObj.magicSchoolLevel, a_itemUpdateObj.magicSchoolPct);
                    bHasWeightandValue = false;
                    break;
                    
                case skyui.defines.Inventory.ICT_SHOUT:
                    infoCard.gotoAndStop("Shout");
                    infoCard.DragonSoulTextInstance.SetText(this._playerInfoObj.dragonSoulText);
                    bHasWeightandValue = false;
                    break;
                    
                case skyui.defines.Inventory.ICT_BOOK:
                case skyui.defines.Inventory.ICT_INGREDIENT:
                case skyui.defines.Inventory.ICT_MISC:
                case skyui.defines.Inventory.ICT_KEY:
                default:
                    infoCard.gotoAndStop("Default");
            }
            
            if (bHasWeightandValue) {
                infoCard.CarryWeightValue.textAutoSize = "shrink";
                infoCard.CarryWeightValue.SetText(Math.ceil(this._playerInfoObj.encumbrance) + "/" + Math.floor(this._playerInfoObj.maxEncumbrance));
                infoCard.PlayerGoldValue.textAutoSize = "shrink";
                infoCard.PlayerGoldValue.SetText(this._playerInfoObj.gold.toString());
                infoCard.PlayerGoldLabel._x = infoCard.PlayerGoldValue._x + infoCard.PlayerGoldValue.getLineMetrics(0).x - infoCard.PlayerGoldLabel._width;
                infoCard.CarryWeightValue._x = infoCard.PlayerGoldLabel._x + infoCard.PlayerGoldLabel.getLineMetrics(0).x - infoCard.CarryWeightValue._width - 5;
                infoCard.CarryWeightLabel._x = infoCard.CarryWeightValue._x + infoCard.CarryWeightValue.getLineMetrics(0).x - infoCard.CarryWeightLabel._width;
                if (itemType === skyui.defines.Inventory.ICT_ARMOR) {
                    infoCard.ArmorRatingValue._x = infoCard.CarryWeightLabel._x + infoCard.CarryWeightLabel.getLineMetrics(0).x - infoCard.ArmorRatingValue._width - 5;
                    infoCard.ArmorRatingLabel._x = infoCard.ArmorRatingValue._x + infoCard.ArmorRatingValue.getLineMetrics(0).x - infoCard.ArmorRatingLabel._width;
                    infoCard.WarmthRatingValue._x = infoCard.ArmorRatingLabel._x + infoCard.ArmorRatingLabel.getLineMetrics(0).x - infoCard.WarmthRatingValue._width - 5;
                    infoCard.WarmthRatingLabel._x = infoCard.WarmthRatingValue._x + infoCard.WarmthRatingValue.getLineMetrics(0).x - infoCard.WarmthRatingLabel._width;
                } else if (itemType === skyui.defines.Inventory.ICT_WEAPON) {
                    infoCard.DamageValue._x = infoCard.CarryWeightLabel._x + infoCard.CarryWeightLabel.getLineMetrics(0).x - infoCard.DamageValue._width - 5;
                    infoCard.DamageLabel._x = infoCard.DamageValue._x + infoCard.DamageValue.getLineMetrics(0).x - infoCard.DamageLabel._width;
                }
            }
            this.updateStatMeter(infoCard.HealthRect, this._healthMeter, this._playerInfoObj.health, this._playerInfoObj.maxHealth, this._playerInfoObj.healthColor);
            this.updateStatMeter(infoCard.MagickaRect, this._magickaMeter, this._playerInfoObj.magicka, this._playerInfoObj.maxMagicka, this._playerInfoObj.magickaColor);
            this.updateStatMeter(infoCard.StaminaRect, this._staminaMeter, this._playerInfoObj.stamina, this._playerInfoObj.maxStamina, this._playerInfoObj.staminaColor);
        }
    }

    // @API
    public function UpdateCraftingInfo(a_skillName: String, a_levelStart: Number, a_levelPercent: Number)
    {
        this.playerInfoCard.gotoAndStop("Crafting");
        this.updateSkillBar(a_skillName, a_levelStart, a_levelPercent);
    }

    public function updateBarterInfo(a_playerUpdateObj: Object, a_itemUpdateObj: Object, a_playerGold: Number, a_vendorGold: Number, a_vendorName: String)
    {
        this._playerInfoObj = a_playerUpdateObj;

        var infoCard = this.playerInfoCard;

        infoCard.gotoAndStop("Barter");

        infoCard.CarryWeightValue.textAutoSize = "shrink";
        infoCard.CarryWeightValue.SetText(Math.ceil(this._playerInfoObj.encumbrance) + "/" + Math.floor(this._playerInfoObj.maxEncumbrance));

        infoCard.VendorGoldLabel.textAutoSize = "shrink";
        if (a_vendorName != undefined) {
            infoCard.VendorGoldLabel.SetText("$Gold");
            infoCard.VendorGoldLabel.SetText(a_vendorName + " " + infoCard.VendorGoldLabel.text);
        }

        this.updateBarterPriceInfo(a_playerGold, a_vendorGold, a_itemUpdateObj);
    }

    public function updateBarterPriceInfo(a_playerGold: Number, a_vendorGold: Number, a_itemUpdateObj: Object, a_goldDelta: Number)
    {
        var infoCard = this.playerInfoCard;

        infoCard.PlayerGoldValue.textAutoSize = "shrink";
        if (a_goldDelta == undefined) {
            infoCard.PlayerGoldValue.SetText(a_playerGold.toString(), true);
        } else if (a_goldDelta >= 0) {
            infoCard.PlayerGoldValue.SetText(a_playerGold.toString() + " <font color=\'#189515\'>(+" + a_goldDelta.toString() + ")</font>", true);
        } else {
            infoCard.PlayerGoldValue.SetText(a_playerGold.toString() + " <font color=\'#FF0000\'>(" + a_goldDelta.toString() + ")</font>", true);
        }

        infoCard.VendorGoldValue.textAutoSize = "shrink";
        infoCard.VendorGoldValue.SetText(a_vendorGold.toString());

        infoCard.VendorGoldLabel._x = infoCard.VendorGoldValue._x + infoCard.VendorGoldValue.getLineMetrics(0).x - infoCard.VendorGoldLabel._width;
        infoCard.PlayerGoldValue._x = infoCard.VendorGoldLabel._x + infoCard.VendorGoldLabel.getLineMetrics(0).x - infoCard.PlayerGoldValue._width - 10;
        infoCard.PlayerGoldLabel._x = infoCard.PlayerGoldValue._x + infoCard.PlayerGoldValue.getLineMetrics(0).x - infoCard.PlayerGoldLabel._width;
        infoCard.CarryWeightValue._x = infoCard.PlayerGoldLabel._x + infoCard.PlayerGoldLabel.getLineMetrics(0).x - infoCard.CarryWeightValue._width - 5;
        infoCard.CarryWeightLabel._x = infoCard.CarryWeightValue._x + infoCard.CarryWeightValue.getLineMetrics(0).x - infoCard.CarryWeightLabel._width;

        this.updateBarterPerItemInfo(a_itemUpdateObj);
    }

    public function updateBarterPerItemInfo(a_itemUpdateObj: Object)
    {
        var infoCard = this.playerInfoCard;
        var itemType: Number = a_itemUpdateObj.type;

        if (itemType == undefined) {
            itemType = this._lastItemType;
            if (a_itemUpdateObj == undefined)
                a_itemUpdateObj = {type: this._lastItemType};
        } else {
            this._lastItemType = itemType;
        }

        if (a_itemUpdateObj != undefined) {
            var itemType: Number = a_itemUpdateObj.type;
            
            switch(itemType) {
                case skyui.defines.Inventory.ICT_ARMOR:
                    infoCard.gotoAndStop("Barter_Armor");
                    var strArmor: String = Math.floor(_playerInfoObj.armor).toString();
                    if (a_itemUpdateObj.armorChange != undefined) {
                        var iArmorDelta: Number = Math.round(a_itemUpdateObj.armorChange);
                        if (iArmorDelta > 0) 
                            strArmor = strArmor + " <font color=\'#189515\'>(+" + iArmorDelta.toString() + ")</font>";
                        else if (iArmorDelta < 0) 
                            strArmor = strArmor + " <font color=\'#FF0000\'>(" + iArmorDelta.toString() + ")</font>";
                    }
                    infoCard.ArmorRatingValue.textAutoSize = "shrink";
                    infoCard.ArmorRatingValue.html = true;
                    infoCard.ArmorRatingValue.SetText(strArmor, true);
                    infoCard.ArmorRatingValue._x = infoCard.CarryWeightLabel._x + infoCard.CarryWeightLabel.getLineMetrics(0).x - infoCard.ArmorRatingValue._width - 5;
                    infoCard.ArmorRatingLabel._x = infoCard.ArmorRatingValue._x + infoCard.ArmorRatingValue.getLineMetrics(0).x - infoCard.ArmorRatingLabel._width;

                    var strWarmth  = this._playerInfoObj.warmth != undefined ? Math.floor(this._playerInfoObj.warmth).toString() : "0";
                    if (a_itemUpdateObj.warmthChange != undefined)
                    {
                        var iWarmthDelta = Math.round(a_itemUpdateObj.warmthChange);
                        if (iWarmthDelta > 0)
                            strWarmth = strWarmth + " <font color=\'#189515\'>(+" + iWarmthDelta.toString() + ")</font>";
                        else if (iWarmthDelta < 0)
                            strWarmth = strWarmth + " <font color=\'#FF0000\'>(" + iWarmthDelta.toString() + ")</font>";
                    }
                    infoCard.WarmthRatingLabel._visible = this._playerInfoObj.warmth != undefined;
                    infoCard.WarmthRatingValue._visible = this._playerInfoObj.warmth != undefined;
                    infoCard.WarmthRatingValue.textAutoSize = "shrink";
                    infoCard.WarmthRatingValue.html = true;
                    infoCard.WarmthRatingValue.SetText(strWarmth, true);
                    infoCard.WarmthRatingValue._x = infoCard.ArmorRatingLabel._x + infoCard.ArmorRatingLabel.getLineMetrics(0).x - infoCard.WarmthRatingValue._width - 5;
                    infoCard.WarmthRatingLabel._x = infoCard.WarmthRatingValue._x + infoCard.WarmthRatingValue.getLineMetrics(0).x - infoCard.WarmthRatingLabel._width;
                    break;
                    
                case skyui.defines.Inventory.ICT_WEAPON:
                    infoCard.gotoAndStop("Barter_Weapon");
                    var strDamage: String = Math.floor(this._playerInfoObj.damage).toString();
                    if (a_itemUpdateObj.damageChange != undefined) {
                        var iDamageDelta: Number = Math.round(a_itemUpdateObj.damageChange);
                        if (iDamageDelta > 0) 
                            strDamage = strDamage + " <font color=\'#189515\'>(+" + iDamageDelta.toString() + ")</font>";
                        else if (iDamageDelta < 0) 
                            strDamage = strDamage + " <font color=\'#FF0000\'>(" + iDamageDelta.toString() + ")</font>";
                    }
                    infoCard.DamageValue.textAutoSize = "shrink";
                    infoCard.DamageValue.html = true;
                    infoCard.DamageValue.SetText(strDamage, true);
                    infoCard.DamageValue._x = infoCard.CarryWeightLabel._x + infoCard.CarryWeightLabel.getLineMetrics(0).x - infoCard.DamageValue._width - 5;
                    infoCard.DamageLabel._x = infoCard.DamageValue._x + infoCard.DamageValue.getLineMetrics(0).x - infoCard.DamageLabel._width;
                    break;
                    
                default:
                    infoCard.gotoAndStop("Barter");
                    break;
            }
        }
    }

    public function setGiftInfo(a_favorPoints: Number)
    {
        this.playerInfoCard.gotoAndStop("Gift");
    }

    public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean)
    {
        this.buttonPanel.setPlatform(a_platform, a_bPS3Switch);
    }


  /* PRIVATE FUNCTIONS */
    
    private function updateStatMeter(a_meterRect: MovieClip, a_meterObj: Meter, a_currValue: Number, a_maxValue: Number, a_colorStr: String)
    {
        if (a_colorStr == undefined) 
            a_colorStr = "#FFFFFF";
        if (a_meterRect._alpha > 0) {
            if (a_meterRect.MeterText != undefined) {
                a_meterRect.MeterText.textAutoSize = "shrink";
                a_meterRect.MeterText.html = true;
                a_meterRect.MeterText.SetText("<font color=\'" + a_colorStr + "\'>" + Math.floor(a_currValue) + "/" + Math.floor(a_maxValue) + "</font>", true);
            }
            a_meterRect.MeterInstance.gotoAndStop("Pause");
            a_meterObj.SetPercent(a_currValue / a_maxValue * 100);
        }
    }
    
    private function updateSkillBar(a_skillName: String, a_levelStart: Number, a_levelPercent: Number)
    {
        var infoCard = this.playerInfoCard;
        
        infoCard.SkillLevelLabel.SetText(a_skillName);
        infoCard.SkillLevelCurrent.SetText(a_levelStart);
        infoCard.SkillLevelNext.SetText(a_levelStart + 1);
        infoCard.LevelMeterInstance.gotoAndStop("Pause");
        this._levelMeter.SetPercent(a_levelPercent);
    }

}
