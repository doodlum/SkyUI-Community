class ItemCard extends MovieClip
{
    var ActiveEffectTimeValue: TextField;
    var ApparelArmorValue: TextField;
    var ApparelEnchantedLabel: TextField;
    var BookDescriptionLabel: TextField;
    var EnchantmentLabel: TextField;
    var ItemName: TextField;
    var ItemText: TextField;
    var ItemValueText: TextField;
    var ItemWeightText: TextField;
    var MagicCostLabel: TextField;
    var MagicCostPerSec: TextField;
    var MagicCostTimeLabel: TextField;
    var MagicCostTimeValue: TextField;
    var MagicCostValue: TextField;
    var MagicEffectsLabel: TextField;
    var MessageText: TextField;
    var PotionsLabel: TextField;
    var SecsText: TextField;
    var ShoutCostValue: TextField;
    var ShoutEffectsLabel: TextField;
    var SkillLevelText: TextField;
    var SkillTextInstance: TextField;
    var SliderValueText: TextField;
    var SoulLevel: TextField;
    var StolenTextInstance: TextField;
    var TotalChargesValue: TextField;
    var WeaponDamageValue: TextField;
    var WeaponEnchantedLabel: TextField;
    
    var ButtonRect: MovieClip;
    var ButtonRect_mc: MovieClip;
    var CardList_mc: MovieClip;
    var ChargeMeter_Default: MovieClip;
    var ChargeMeter_Enchantment: MovieClip;
    var ChargeMeter_SoulGem: MovieClip;
    var ChargeMeter_Weapon: MovieClip;
    var EnchantingSlider_mc: MovieClip;
    var Enchanting_Background: MovieClip;
    var Enchanting_Slim_Background: MovieClip;
    var ItemList: MovieClip;
    var ListChargeMeter: MovieClip;
    var PoisonInstance: MovieClip;
    var PrevFocus: MovieClip;
    var QuantitySlider_mc: MovieClip;
    var WeaponChargeMeter: MovieClip;
    
    var InputHandler: Function;
    var dispatchEvent: Function;
    
    var ItemCardMeters: Object;
    var LastUpdateObj: Object;
    
    var _bEditNameMode: Boolean;
    var bFadedIn: Boolean;
    

    function ItemCard()
    {
        super();
        Shared.GlobalFunc.MaintainTextFormat();
        Shared.GlobalFunc.AddReverseFunctions();
        gfx.events.EventDispatcher.initialize(this);
        this.QuantitySlider_mc = this.QuantitySlider_mc;
        this.ButtonRect_mc = this.ButtonRect;
        this.ItemList = this.CardList_mc.List_mc;
        this.SetupItemName();
        this.bFadedIn = false;
        this.InputHandler = undefined;
        this._bEditNameMode = false;
    }

    function get bEditNameMode()
    {
        return this._bEditNameMode;
    }

    function GetItemName()
    {
        return this.ItemName;
    }

    function SetupItemName(aPrevName: String)
    {
        this.ItemName = this.ItemText.ItemTextField;
        if (this.ItemName != undefined) {
            this.ItemName.textAutoSize = "shrink";
            this.ItemName.htmlText = aPrevName;
            this.ItemName.selectable = false;
        }
    }

    function onLoad()
    {
        this.QuantitySlider_mc.addEventListener("change", this, "onSliderChange");
        this.ButtonRect_mc.AcceptMouseButton.addEventListener("click", this, "onAcceptMouseClick");
        this.ButtonRect_mc.CancelMouseButton.addEventListener("click", this, "onCancelMouseClick");
        this.ButtonRect_mc.AcceptMouseButton.SetPlatform(0, false);
        this.ButtonRect_mc.CancelMouseButton.SetPlatform(0, false);
    }

    function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean)
    {
        this.ButtonRect_mc.AcceptGamepadButton._visible = aiPlatform != 0;
        this.ButtonRect_mc.CancelGamepadButton._visible = aiPlatform != 0;
        this.ButtonRect_mc.AcceptMouseButton._visible = aiPlatform == 0;
        this.ButtonRect_mc.CancelMouseButton._visible = aiPlatform == 0;
        if (aiPlatform != 0) {
            this.ButtonRect_mc.AcceptGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
            this.ButtonRect_mc.CancelGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
        }
        this.ItemList.SetPlatform(aiPlatform, abPS3Switch);
    }

    function onAcceptMouseClick()
    {
        if (this.ButtonRect_mc._alpha == 100 && this.ButtonRect_mc.AcceptMouseButton._visible == true && this.InputHandler != undefined) {
            var inputEnterObj: Object = {value: "keyDown", navEquivalent: gfx.ui.NavigationCode.ENTER};
            this.InputHandler(inputEnterObj);
        }
    }

    function onCancelMouseClick()
    {
        if (this.ButtonRect_mc._alpha == 100 && this.ButtonRect_mc.CancelMouseButton._visible == true && this.InputHandler != undefined) {
            var inputTabObj: Object = {value: "keyDown", navEquivalent: gfx.ui.NavigationCode.TAB};
            this.InputHandler(inputTabObj);
        }
    }

    function FadeInCard()
    {
        if (this.bFadedIn)
            return;
        this._visible = true;
        this._parent.gotoAndPlay("fadeIn");
        this.bFadedIn = true;
    }

    function FadeOutCard()
    {
        if (this.bFadedIn) {
            this._parent.gotoAndPlay("fadeOut");
            this.bFadedIn = false;
        }
    }

    function get quantitySlider()
    {
        return this.QuantitySlider_mc;
    }

    function get weaponChargeMeter()
    {
        return this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON];
    }

    function get itemInfo()
    {
        return this.LastUpdateObj;
    }

    function set itemInfo(aUpdateObj: Object)
    {
        this.ItemCardMeters = new Array();
        var strItemNameHtml: String = this.ItemName == undefined ? "" : this.ItemName.htmlText;
        var _iItemType: Number = aUpdateObj.type;
        
        
        switch (_iItemType) {
            case skyui.defines.Inventory.ICT_ARMOR:
                if (aUpdateObj.effects.length == 0) {
                    if (aUpdateObj.warmth != undefined)
                        this.gotoAndStop("Apparel_Survival_reg");
                    else
                        this.gotoAndStop("Apparel_reg");
                } else if(aUpdateObj.warmth != undefined) {
                    this.gotoAndStop("Apparel_Survival_Enchanted");
                } else {
                    this.gotoAndStop("Apparel_Enchanted");
                }
                this.ApparelWarmthValue.textAutoSize = "shrink";
                this.ApparelWarmthValue.SetText(aUpdateObj.warmth);
                this.ApparelArmorValue.textAutoSize = "shrink";
                this.ApparelArmorValue.SetText(aUpdateObj.armor);
                this.ApparelEnchantedLabel.enableShrinkToFit = true;
                this.ApparelEnchantedLabel.overflowMode = "ellipsis";
                this.ApparelEnchantedLabel.SetText(aUpdateObj.effects, true);
                this.SkillTextInstance.text = aUpdateObj.skillText;
                break;
                
            case skyui.defines.Inventory.ICT_WEAPON:
                if (aUpdateObj.effects.length == 0) {
                    this.gotoAndStop("Weapons_reg");
                } else {
                    this.gotoAndStop("Weapons_Enchanted");
                    if (this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] == undefined)
                        this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(this.WeaponChargeMeter.MeterInstance);
                    if (aUpdateObj.usedCharge != undefined && aUpdateObj.charge != undefined) {
                        this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].SetPercent(aUpdateObj.usedCharge);
                        this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].SetDeltaPercent(aUpdateObj.charge);
                        this.WeaponChargeMeter._visible = true;
                    } else {
                        this.WeaponChargeMeter._visible = false;
                    }
                }
                var strIsPoisoned: String = aUpdateObj.poisoned == true ? "On" : "Off";
                this.PoisonInstance.gotoAndStop(strIsPoisoned);
                this.WeaponDamageValue.textAutoSize = "shrink";
                this.WeaponDamageValue.SetText(aUpdateObj.damage);
                this.WeaponEnchantedLabel.enableShrinkToFit = true;
                this.WeaponEnchantedLabel.overflowMode = "ellipsis";
                this.WeaponEnchantedLabel.SetText(aUpdateObj.effects, true);
                break;
                
            case skyui.defines.Inventory.ICT_BOOK: 
                if (aUpdateObj.description != undefined && aUpdateObj.description != "") {
                    this.gotoAndStop("Books_Description");
                    this.BookDescriptionLabel.enableShrinkToFit = true;
                    this.BookDescriptionLabel.overflowMode = "ellipsis";
                    this.BookDescriptionLabel.SetText(aUpdateObj.description, true);
                } else {
                    this.gotoAndStop("Books_reg");
                }
                break;
                
            case skyui.defines.Inventory.ICT_POTION:
            case skyui.defines.Inventory.ICT_FOOD:
                this.gotoAndStop("Potions_reg");
                this.PotionsLabel.enableShrinkToFit = true;
                this.PotionsLabel.overflowMode = "ellipsis";
                this.PotionsLabel.SetText(aUpdateObj.effects, true);
                this.SkillTextInstance.text = aUpdateObj.skillName == undefined ? "" : aUpdateObj.skillName;
                break;
                
            case skyui.defines.Inventory.ICT_SPELL_DEFAULT:
                this.gotoAndStop("Power_reg");
                this.MagicEffectsLabel.enableShrinkToFit = true;
                this.MagicEffectsLabel.overflowMode = "ellipsis";
                this.MagicEffectsLabel.SetText(aUpdateObj.effects, true);
                if (aUpdateObj.spellCost <= 0) {
                    this.MagicCostValue._alpha = 0;
                    this.MagicCostTimeValue._alpha = 0;
                    this.MagicCostLabel._alpha = 0;
                    this.MagicCostTimeLabel._alpha = 0;
                    this.MagicCostPerSec._alpha = 0;
                } else {
                    this.MagicCostValue._alpha = 100;
                    this.MagicCostLabel._alpha = 100;
                    this.MagicCostValue.text = aUpdateObj.spellCost.toString();
                }
                break;
                
            case skyui.defines.Inventory.ICT_SPELL:
                var bCastTime: Boolean = aUpdateObj.castTime == 0;
                if (bCastTime)
                    this.gotoAndStop("Magic_time_label");
                else
                    this.gotoAndStop("Magic_reg");
                this.SkillLevelText.text = aUpdateObj.castLevel.toString();
                this.MagicEffectsLabel.enableShrinkToFit = true;
                this.MagicEffectsLabel.overflowMode = "ellipsis";
                this.MagicEffectsLabel.SetText(aUpdateObj.effects, true);
                this.MagicCostValue.textAutoSize = "shrink";
                this.MagicCostTimeValue.textAutoSize = "shrink";
                if (bCastTime)
                    this.MagicCostTimeValue.text = aUpdateObj.spellCost.toString();
                else
                    this.MagicCostValue.text = aUpdateObj.spellCost.toString();
                break;
                
            case skyui.defines.Inventory.ICT_INGREDIENT:
                this.gotoAndStop("Ingredients_reg");
                for (var i: Number = 0; i < 4; i++) {
                    this["EffectLabel" + i].textAutoSize = "shrink";
                    if (aUpdateObj["itemEffect" + i] != undefined && aUpdateObj["itemEffect" + i] != "") {
                        this["EffectLabel" + i].textColor = 0xFFFFFF;
                        this["EffectLabel" + i].SetText(aUpdateObj["itemEffect" + i]);
                    } else if (i < aUpdateObj.numItemEffects) {
                        this["EffectLabel" + i].textColor = 0x999999;
                        this["EffectLabel" + i].SetText("$UNKNOWN");
                    } else {
                        this["EffectLabel" + i].SetText("");
                    }
                }
                break;
                
            case skyui.defines.Inventory.ICT_MISC:
                this.gotoAndStop("Misc_reg");
                break;
                
            case skyui.defines.Inventory.ICT_SHOUT:
                this.gotoAndStop("Shouts_reg");
                var iLastWord: Number = 0;
                for (var i: Number = 0; i < 3; i++) {
                    if (aUpdateObj["word" + i] != undefined && aUpdateObj["word" + i] != "" && aUpdateObj["unlocked" + i] == true)
                        iLastWord = i;
                }
                for (var i: Number = 0; i < 3; i++) {
                    var strDragonWord: String = aUpdateObj["dragonWord" + i] == undefined ? "" : aUpdateObj["dragonWord" + i];
                    var strWord: String = aUpdateObj["word" + i] == undefined ? "" : aUpdateObj["word" + i];
                    var bWordKnown: Boolean = aUpdateObj["unlocked" + i] == true;
                    this["ShoutTextInstance" + i].DragonShoutLabelInstance.ShoutWordsLabel.textAutoSize = "shrink";
                    this["ShoutTextInstance" + i].ShoutLabelInstance.ShoutWordsLabelTranslation.textAutoSize = "shrink";
                    this["ShoutTextInstance" + i].DragonShoutLabelInstance.ShoutWordsLabel.SetText(strDragonWord.toUpperCase());
                    this["ShoutTextInstance" + i].ShoutLabelInstance.ShoutWordsLabelTranslation.SetText(strWord);
                    if (bWordKnown && i == iLastWord && this.LastUpdateObj.soulSpent == true) {
                        this["ShoutTextInstance" + i].gotoAndPlay("Learn");
                    } else if (bWordKnown) {
                        this["ShoutTextInstance" + i].gotoAndStop("Known");
                        this["ShoutTextInstance" + i].gotoAndStop("Known");
                    } else {
                        this["ShoutTextInstance" + i].gotoAndStop("Unlocked");
                        this["ShoutTextInstance" + i].gotoAndStop("Unlocked");
                    }
                }
                this.ShoutEffectsLabel.enableShrinkToFit = true;
                this.ShoutEffectsLabel.overflowMode = "ellipsis";
                this.ShoutEffectsLabel.SetText(aUpdateObj.effects, true);
                this.ShoutCostValue.text = aUpdateObj.spellCost.toString();
                break;
                
            case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
                this.gotoAndStop("ActiveEffects");
                this.MagicEffectsLabel.enableShrinkToFit = true;
                this.MagicEffectsLabel.overflowMode = "ellipsis";
                this.MagicEffectsLabel.SetText(aUpdateObj.effects,true);
                if (aUpdateObj.timeRemaining > 0) {
                    var iEffectTimeRemaining: Number = Math.floor(aUpdateObj.timeRemaining);
                    this.ActiveEffectTimeValue._alpha = 100;
                    this.SecsText._alpha = 100;
                    if (iEffectTimeRemaining >= 3600) {
                        iEffectTimeRemaining = Math.floor(iEffectTimeRemaining / 3600);
                        this.ActiveEffectTimeValue.text = iEffectTimeRemaining.toString();
                        if (iEffectTimeRemaining == 1)
                            this.SecsText.text = "$hour";
                        else
                            this.SecsText.text = "$hours";
                    } else if (iEffectTimeRemaining >= 60) {
                        iEffectTimeRemaining = Math.floor(iEffectTimeRemaining / 60);
                        this.ActiveEffectTimeValue.text = iEffectTimeRemaining.toString();
                        if (iEffectTimeRemaining == 1)
                            this.SecsText.text = "$min";
                        else
                            this.SecsText.text = "$mins";
                    } else {
                        this.ActiveEffectTimeValue.text = iEffectTimeRemaining.toString();
                        if (iEffectTimeRemaining == 1)
                            this.SecsText.text = "$sec";
                        else
                            this.SecsText.text = "$secs";
                    }
                } else {
                    this.ActiveEffectTimeValue._alpha = 0;
                    this.SecsText._alpha = 0;
                }
                break;
                
            case skyui.defines.Inventory.ICT_SOUL_GEMS:
                this.gotoAndStop("SoulGem");
                this.SoulLevel.text = aUpdateObj.soulLVL;
                break;
                
            case skyui.defines.Inventory.ICT_LIST:
                this.gotoAndStop("Item_list");
                if (aUpdateObj.listItems != undefined) {
                    this.ItemList.entryList = aUpdateObj.listItems;
                    this.ItemList.InvalidateData();
                    this.ItemCardMeters[skyui.defines.Inventory.ICT_LIST] = new Components.DeltaMeter(this.ListChargeMeter.MeterInstance);
                    this.ItemCardMeters[skyui.defines.Inventory.ICT_LIST].SetPercent(aUpdateObj.currentCharge);
                    this.ItemCardMeters[skyui.defines.Inventory.ICT_LIST].SetDeltaPercent(aUpdateObj.currentCharge + this.ItemList.selectedEntry.chargeAdded);
                    this.OpenListMenu();
                }
                break;
                
            case skyui.defines.Inventory.ICT_CRAFT_ENCHANTING:
            case skyui.defines.Inventory.ICT_HOUSE_PART:
                if (aUpdateObj.type == skyui.defines.Inventory.ICT_HOUSE_PART) {
                    this.gotoAndStop("Magic_short");
                    if (aUpdateObj.effects == undefined)
                        this.MagicEffectsLabel.SetText("", true);
                    else
                        this.MagicEffectsLabel.SetText(aUpdateObj.effects, true);
                } else if (aUpdateObj.sliderShown == true) {
                    this.gotoAndStop("Craft_Enchanting");
                    this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_Default.MeterInstance);
                    if (aUpdateObj.totalCharges != undefined && aUpdateObj.totalCharges != 0)
                        this.TotalChargesValue.text = aUpdateObj.totalCharges;
                } else if (aUpdateObj.damage == undefined) {
                    if (aUpdateObj.armor == undefined) {
                        if (aUpdateObj.soulLVL == undefined) {
                            if (this.QuantitySlider_mc._alpha == 0) {
                                this.gotoAndStop("Craft_Enchanting_Enchantment");
                                this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_Enchantment.MeterInstance);
                            }
                        } else {
                            this.gotoAndStop("Craft_Enchanting_SoulGem");
                            this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_SoulGem.MeterInstance);
                            this.SoulLevel.text = aUpdateObj.soulLVL;
                        }
                    } else {
                        this.gotoAndStop("Craft_Enchanting_Armor");
                        this.ApparelArmorValue.SetText(aUpdateObj.armor);
                        this.SkillTextInstance.text = aUpdateObj.skillText;
                    }
                } else {
                    this.gotoAndStop("Craft_Enchanting_Weapon");
                    this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_Weapon.MeterInstance);
                    this.WeaponDamageValue.textAutoSize = "shrink";
                    this.WeaponDamageValue.SetText(aUpdateObj.damage);
                }
                
                if (aUpdateObj.usedCharge == 0 && aUpdateObj.totalCharges == 0)
                    this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].DeltaMeterMovieClip._parent._parent._alpha = 0;
                else if (aUpdateObj.usedCharge != undefined)
                    this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].SetPercent(aUpdateObj.usedCharge);
                
                if (aUpdateObj.effects != undefined && aUpdateObj.effects.length > 0) {
                    if (this.EnchantmentLabel != undefined) {
                        this.EnchantmentLabel.enableShrinkToFit = true;
                        this.EnchantmentLabel.overflowMode = "ellipsis";
                        this.EnchantmentLabel.SetText(aUpdateObj.effects,true);
                    }
                    this.WeaponChargeMeter._alpha = 100;
                    this.Enchanting_Background._alpha = 60;
                    this.Enchanting_Slim_Background._alpha = 0;
                } else {
                    if (this.EnchantmentLabel != undefined)
                        this.EnchantmentLabel.SetText("", true);
                    
                    this.WeaponChargeMeter._alpha = 0;
                    this.Enchanting_Slim_Background._alpha = 60;
                    this.Enchanting_Background._alpha = 0;
                }
                break;
            
            case skyui.defines.Inventory.ICT_KEY:
            case skyui.defines.Inventory.ICT_NONE:
            default:
                this.gotoAndStop("Empty");
        }
        
        this.SetupItemName(strItemNameHtml);
        if (aUpdateObj.name != undefined) {
            var strItemName: String = aUpdateObj.count != undefined && aUpdateObj.count > 1 ? aUpdateObj.name + " (" + aUpdateObj.count + ")" : aUpdateObj.name;
            this.ItemText.ItemTextField.SetText(this._bEditNameMode || aUpdateObj.upperCaseName == false ? strItemName : strItemName.toUpperCase(), false);
            this.ItemText.ItemTextField.textColor = aUpdateObj.negativeEffect == true ? 0xFF0000 : 0xFFFFFF;
        }
        this.ItemValueText.textAutoSize = "shrink";
        this.ItemWeightText.textAutoSize = "shrink";
        if (aUpdateObj.value != undefined && this.ItemValueText != undefined)
            this.ItemValueText.SetText(aUpdateObj.value.toString());
        if (aUpdateObj.weight != undefined && this.ItemWeightText != undefined)
            this.ItemWeightText.SetText(this.RoundDecimal(aUpdateObj.weight, 2).toString());
        this.StolenTextInstance._visible = aUpdateObj.stolen == true;
        this.LastUpdateObj = aUpdateObj;
    }

    function RoundDecimal(aNumber: Number, aPrecision: Number)
    {
        var significantFigures = Math.pow(10, aPrecision);
        return Math.round(significantFigures * aNumber) / significantFigures;
    }

    function PrepareInputElements(aActiveClip: MovieClip)
    {
        var iQuantitySlider_yOffset = 92;
        var iCardList_yOffset = 98;
        var iEnchantingSlider_yOffset = 147.3;
        var iButtonRect_iOffset = 130;
        var iButtonRect_iOffsetEnchanting = 166;
        
        switch (aActiveClip) {
            case this.EnchantingSlider_mc: 
                this.QuantitySlider_mc._y = -100;
                this.ButtonRect._y = iButtonRect_iOffsetEnchanting;
                this.EnchantingSlider_mc._y = iEnchantingSlider_yOffset;
                this.CardList_mc._y = -100;
                this.QuantitySlider_mc._alpha = 0;
                this.ButtonRect._alpha = 100;
                this.EnchantingSlider_mc._alpha = 100;
                this.CardList_mc._alpha = 0;
                break;
                
            case this.QuantitySlider_mc: 
                this.QuantitySlider_mc._y = iQuantitySlider_yOffset;
                this.ButtonRect._y = iButtonRect_iOffset;
                this.EnchantingSlider_mc._y = -100;
                this.CardList_mc._y = -100;
                this.QuantitySlider_mc._alpha = 100;
                this.ButtonRect._alpha = 100;
                this.EnchantingSlider_mc._alpha = 0;
                this.CardList_mc._alpha = 0;
                break;
                
            case this.CardList_mc: 
                this.QuantitySlider_mc._y = -100;
                this.ButtonRect._y = -100;
                this.EnchantingSlider_mc._y = -100;
                this.CardList_mc._y = iCardList_yOffset;
                this.QuantitySlider_mc._alpha = 0;
                this.ButtonRect._alpha = 0;
                this.EnchantingSlider_mc._alpha = 0;
                this.CardList_mc._alpha = 100;
                break;
                
            case this.ButtonRect: 
                this.QuantitySlider_mc._y = -100;
                this.ButtonRect._y = iButtonRect_iOffset;
                this.EnchantingSlider_mc._y = -100;
                this.CardList_mc._y = -100;
                this.QuantitySlider_mc._alpha = 0;
                this.ButtonRect._alpha = 100;
                this.EnchantingSlider_mc._alpha = 0;
                this.CardList_mc._alpha = 0;
                break;
        }
    }

    function ShowEnchantingSlider(aiMaxValue: Number, aiMinValue: Number, aiCurrentValue: Number)
    {
        this.gotoAndStop("Craft_Enchanting");
        this.QuantitySlider_mc = this.EnchantingSlider_mc;
        this.QuantitySlider_mc.addEventListener("change", this, "onSliderChange");
        this.PrepareInputElements(this.EnchantingSlider_mc);
        this.QuantitySlider_mc.maximum = aiMaxValue;
        this.QuantitySlider_mc.minimum = aiMinValue;
        this.QuantitySlider_mc.value = aiCurrentValue;
        this.PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
        gfx.managers.FocusHandler.instance.setFocus(this.QuantitySlider_mc, 0);
        this.InputHandler = this.HandleQuantityMenuInput;
        this.dispatchEvent({type: "subMenuAction", opening: true, menu: "quantity"});
    }

    function ShowQuantityMenu(aiMaxAmount: Number)
    {
        this.gotoAndStop("Quantity");
        this.PrepareInputElements(this.QuantitySlider_mc);
        this.QuantitySlider_mc.maximum = aiMaxAmount;
        this.QuantitySlider_mc.value = aiMaxAmount;
        this.SliderValueText.textAutoSize = "shrink";
        this.SliderValueText.SetText(Math.floor(this.QuantitySlider_mc.value).toString());
        this.PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
        gfx.managers.FocusHandler.instance.setFocus(this.QuantitySlider_mc, 0);
        this.InputHandler = this.HandleQuantityMenuInput;
        this.dispatchEvent({type: "subMenuAction", opening: true, menu: "quantity"});
    }

    function HideQuantityMenu(abCanceled: Boolean)
    {
        gfx.managers.FocusHandler.instance.setFocus(this.PrevFocus, 0);
        this.QuantitySlider_mc._alpha = 0;
        this.ButtonRect_mc._alpha = 0;
        this.InputHandler = undefined;
        this.dispatchEvent({type: "subMenuAction", opening: false, canceled: abCanceled, menu: "quantity"});
    }

    function OpenListMenu()
    {
        this.PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
        gfx.managers.FocusHandler.instance.setFocus(this.ItemList, 0);
        this.ItemList._visible = true;
        this.ItemList.addEventListener("itemPress", this, "onListItemPress");
        this.ItemList.addEventListener("listMovedUp", this, "onListSelectionChange");
        this.ItemList.addEventListener("listMovedDown", this, "onListSelectionChange");
        this.ItemList.addEventListener("selectionChange", this, "onListMouseSelectionChange");
        this.PrepareInputElements(this.CardList_mc);
        this.ListChargeMeter._alpha = 100;
        this.InputHandler = this.HandleListMenuInput;
        this.dispatchEvent({type: "subMenuAction", opening: true, menu: "list"});
    }

    function HideListMenu()
    {
        gfx.managers.FocusHandler.instance.setFocus(this.PrevFocus, 0);
        this.ListChargeMeter._alpha = 0;
        this.CardList_mc._alpha = 0;
        this.ItemCardMeters[skyui.defines.Inventory.ICT_LIST] = undefined;
        this.InputHandler = undefined;
        this.ItemList._visible = true;
        this.dispatchEvent({type: "subMenuAction", opening: false, menu: "list"});
    }

    function ShowConfirmMessage(astrMessage: String)
    {
        this.gotoAndStop("ConfirmMessage");
        this.PrepareInputElements(this.ButtonRect_mc);
        var messageArray: Array = astrMessage.split("\r\n");
        var strMessageText = messageArray.join("\n");
        this.MessageText.SetText(strMessageText);
        this.PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
        gfx.managers.FocusHandler.instance.setFocus(this, 0);
        this.InputHandler = this.HandleConfirmMessageInput;
        this.dispatchEvent({type: "subMenuAction", opening: true, menu: "message"});
    }

    function HideConfirmMessage()
    {
        gfx.managers.FocusHandler.instance.setFocus(this.PrevFocus, 0);
        this.ButtonRect_mc._alpha = 0;
        this.InputHandler = undefined;
        this.dispatchEvent({type: "subMenuAction", opening: false, menu: "message"});
    }

    function StartEditName(aInitialText: String, aiMaxChars: Number)
    {
        if (Selection.getFocus() != this.ItemName) {
            this.PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
            if (aInitialText != undefined)
                this.ItemName.text = aInitialText;
            this.ItemName.type = "input";
            this.ItemName.noTranslate = true;
            this.ItemName.selectable = true;
            this.ItemName.maxChars = aiMaxChars == undefined ? null : aiMaxChars;
            Selection.setFocus(this.ItemName, 0);
            Selection.setSelection(0, 0);
            this.InputHandler = this.HandleEditNameInput;
            this.dispatchEvent({type: "subMenuAction", opening: true, menu: "editName"});
            this._bEditNameMode = true;
        }
    }

    function EndEditName()
    {
        this.ItemName.type = "dynamic";
        this.ItemName.noTranslate = false;
        this.ItemName.selectable = false;
        this.ItemName.maxChars = null;
        var bPreviousFocusEnabled: Boolean = this.PrevFocus.focusEnabled;
        this.PrevFocus.focusEnabled = true;
        Selection.setFocus(this.PrevFocus, 0);
        this.PrevFocus.focusEnabled = bPreviousFocusEnabled;
        this.InputHandler = undefined;
        this.dispatchEvent({type: "subMenuAction", opening: false, menu: "editName"});
        this._bEditNameMode = false;
    }

    function handleInput(details: InputDetails, pathToFocus: Array)
    {
        var bHandledInput: Boolean = false;
        if (pathToFocus.length > 0 && pathToFocus[0].handleInput != undefined) 
            pathToFocus[0].handleInput(details, pathToFocus.slice(1));
        if (this.InputHandler != undefined)
            bHandledInput = this.InputHandler(details);
        return bHandledInput;
    }

    function HandleQuantityMenuInput(details: Object)
    {
        var bValidKeyPressed: Boolean = false;
        if (Shared.GlobalFunc.IsKeyPressed(details))
            if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
                this.HideQuantityMenu(false);
                if (this.QuantitySlider_mc.value > 0)
                    this.dispatchEvent({type: "quantitySelect", amount: Math.floor(this.QuantitySlider_mc.value)});
                else
                    this.itemInfo = this.LastUpdateObj;
                bValidKeyPressed = true;
            } else if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
                this.HideQuantityMenu(true);
                this.itemInfo = this.LastUpdateObj;
                bValidKeyPressed = true;
            }
        return bValidKeyPressed;
    }

    function HandleListMenuInput(details: Object)
    {
        var bValidKeyPressed: Boolean = false;
        if (Shared.GlobalFunc.IsKeyPressed(details) && details.navEquivalent == gfx.ui.NavigationCode.TAB) {
            this.HideListMenu();
            bValidKeyPressed = true;
        }
        return bValidKeyPressed;
    }

    function HandleConfirmMessageInput(details: Object)
    {
        var bValidKeyPressed: Boolean = false;
        if (Shared.GlobalFunc.IsKeyPressed(details)) {
            if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
                this.HideConfirmMessage();
                this.dispatchEvent({type: "messageConfirm"});
                bValidKeyPressed = true;
            } else if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
                this.HideConfirmMessage();
                this.dispatchEvent({type: "messageCancel"});
                this.itemInfo = this.LastUpdateObj;
                bValidKeyPressed = true;
            }
        }
        return bValidKeyPressed;
    }

    function HandleEditNameInput(details: Object)
    {
        Selection.setFocus(this.ItemName, 0);
        if (Shared.GlobalFunc.IsKeyPressed(details)) {
            if (details.navEquivalent == gfx.ui.NavigationCode.ENTER && details.code != 32)
                this.dispatchEvent({type: "endEditItemName", useNewName: true, newName: this.ItemName.text});
            else if (details.navEquivalent == gfx.ui.NavigationCode.TAB)
                this.dispatchEvent({type: "endEditItemName", useNewName: false, newName: ""});
        }
        return true;
    }

    function onSliderChange()
    {
        var currentValue_tf: TextField = this.EnchantingSlider_mc._alpha <= 0 ? this.SliderValueText : this.TotalChargesValue;
        var iCurrentValue: Number = Number(currentValue_tf.text);
        var iNewValue: Number = Math.floor(this.QuantitySlider_mc.value);
        if (iCurrentValue != iNewValue) {
            currentValue_tf.SetText(iNewValue.toString());
            gfx.io.GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
            this.dispatchEvent({type: "sliderChange", value: iNewValue});
        }
    }

    function onListItemPress(event: Object)
    {
        this.dispatchEvent(event);
        this.HideListMenu();
    }

    function onListMouseSelectionChange(event: Object)
    {
        if (event.keyboardOrMouse == 0) 
            this.onListSelectionChange(event);
    }

    function onListSelectionChange(event: Object)
    {
        this.ItemCardMeters[skyui.defines.Inventory.ICT_LIST].SetDeltaPercent(this.ItemList.selectedEntry.chargeAdded + this.LastUpdateObj.currentCharge);
    }

}