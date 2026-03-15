class ItemCard extends MovieClip
{
   var ActiveEffectTimeValue;
   var ApparelArmorValue;
   var ApparelEnchantedLabel;
   var ApparelWarmthValue;
   var BookDescriptionLabel;
   var ButtonRect;
   var ButtonRect_mc;
   var CardList_mc;
   var ChargeMeter_Default;
   var ChargeMeter_Enchantment;
   var ChargeMeter_SoulGem;
   var ChargeMeter_Weapon;
   var EnchantingSlider_mc;
   var Enchanting_Background;
   var Enchanting_Slim_Background;
   var EnchantmentLabel;
   var InputHandler;
   var ItemCardMeters;
   var ItemList;
   var ItemName;
   var ItemText;
   var ItemValueText;
   var ItemWeightText;
   var LastUpdateObj;
   var ListChargeMeter;
   var MagicCostLabel;
   var MagicCostPerSec;
   var MagicCostTimeLabel;
   var MagicCostTimeValue;
   var MagicCostValue;
   var MagicEffectsLabel;
   var MessageText;
   var PoisonInstance;
   var PotionsLabel;
   var PrevFocus;
   var QuantitySlider_mc;
   var SecsText;
   var ShoutCostValue;
   var ShoutEffectsLabel;
   var SkillLevelText;
   var SkillTextInstance;
   var SliderValueText;
   var SoulLevel;
   var StolenTextInstance;
   var TotalChargesValue;
   var WeaponChargeMeter;
   var WeaponDamageValue;
   var WeaponEnchantedLabel;
   var _bEditNameMode;
   var bFadedIn;
   var dispatchEvent;
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
   function SetupItemName(aPrevName)
   {
      this.ItemName = this.ItemText.ItemTextField;
      if(this.ItemName != undefined)
      {
         this.ItemName.textAutoSize = "shrink";
         this.ItemName.htmlText = aPrevName;
         this.ItemName.selectable = false;
      }
   }
   function onLoad()
   {
      this.QuantitySlider_mc.addEventListener("change",this,"onSliderChange");
      this.ButtonRect_mc.AcceptMouseButton.addEventListener("click",this,"onAcceptMouseClick");
      this.ButtonRect_mc.CancelMouseButton.addEventListener("click",this,"onCancelMouseClick");
      this.ButtonRect_mc.AcceptMouseButton.SetPlatform(0,false);
      this.ButtonRect_mc.CancelMouseButton.SetPlatform(0,false);
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.ButtonRect_mc.AcceptGamepadButton._visible = aiPlatform != 0;
      this.ButtonRect_mc.CancelGamepadButton._visible = aiPlatform != 0;
      this.ButtonRect_mc.AcceptMouseButton._visible = aiPlatform == 0;
      this.ButtonRect_mc.CancelMouseButton._visible = aiPlatform == 0;
      if(aiPlatform != 0)
      {
         this.ButtonRect_mc.AcceptGamepadButton.SetPlatform(aiPlatform,abPS3Switch);
         this.ButtonRect_mc.CancelGamepadButton.SetPlatform(aiPlatform,abPS3Switch);
      }
      this.ItemList.SetPlatform(aiPlatform,abPS3Switch);
   }
   function onAcceptMouseClick()
   {
      var _loc2_;
      if(this.ButtonRect_mc._alpha == 100 && this.ButtonRect_mc.AcceptMouseButton._visible == true && this.InputHandler != undefined)
      {
         _loc2_ = {value:"keyDown",navEquivalent:gfx.ui.NavigationCode.ENTER};
         this.InputHandler(_loc2_);
      }
   }
   function onCancelMouseClick()
   {
      var _loc2_;
      if(this.ButtonRect_mc._alpha == 100 && this.ButtonRect_mc.CancelMouseButton._visible == true && this.InputHandler != undefined)
      {
         _loc2_ = {value:"keyDown",navEquivalent:gfx.ui.NavigationCode.TAB};
         this.InputHandler(_loc2_);
      }
   }
   function FadeInCard()
   {
      if(!this.bFadedIn)
      {
         this._visible = true;
         this._parent.gotoAndPlay("fadeIn");
         this.bFadedIn = true;
      }
   }
   function FadeOutCard()
   {
      if(this.bFadedIn)
      {
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
      return this.ItemCardMeters[InventoryDefines.ICT_WEAPON];
   }
   function get itemInfo()
   {
      return this.LastUpdateObj;
   }
   function set itemInfo(aUpdateObj)
   {
      this.ItemCardMeters = new Array();
      var _loc12_ = this.ItemName == undefined ? "" : this.ItemName.htmlText;
      var _loc13_;
      var _loc11_;
      var _loc4_;
      var _loc9_;
      var _loc3_;
      var _loc7_;
      var _loc6_;
      var _loc5_;
      var _loc8_;
      switch(aUpdateObj.type)
      {
         case InventoryDefines.ICT_ARMOR:
            if(aUpdateObj.effects.length == 0)
            {
               if(aUpdateObj.warmth != undefined)
               {
                  this.gotoAndStop("Apparel_Survival_reg");
               }
               else
               {
                  this.gotoAndStop("Apparel_reg");
               }
            }
            else if(aUpdateObj.warmth != undefined)
            {
               this.gotoAndStop("Apparel_Survival_Enchanted");
            }
            else
            {
               this.gotoAndStop("Apparel_Enchanted");
            }
            this.ApparelArmorValue.textAutoSize = "shrink";
            this.ApparelArmorValue.SetText(aUpdateObj.armor);
            if(this.ApparelWarmthValue != undefined)
            {
               this.ApparelWarmthValue.textAutoSize = "shrink";
               this.ApparelWarmthValue.SetText(aUpdateObj.warmth);
            }
            this.ApparelEnchantedLabel.textAutoSize = "shrink";
            this.ApparelEnchantedLabel.htmlText = aUpdateObj.effects;
            this.SkillTextInstance.text = aUpdateObj.skillText;
            break;
         case InventoryDefines.ICT_WEAPON:
            if(aUpdateObj.effects.length == 0)
            {
               this.gotoAndStop("Weapons_reg");
            }
            else
            {
               this.gotoAndStop("Weapons_Enchanted");
               if(this.ItemCardMeters[InventoryDefines.ICT_WEAPON] == undefined)
               {
                  this.ItemCardMeters[InventoryDefines.ICT_WEAPON] = new Components.DeltaMeter(this.WeaponChargeMeter.MeterInstance);
               }
               if(aUpdateObj.usedCharge != undefined && aUpdateObj.charge != undefined)
               {
                  this.ItemCardMeters[InventoryDefines.ICT_WEAPON].SetPercent(aUpdateObj.usedCharge);
                  this.ItemCardMeters[InventoryDefines.ICT_WEAPON].SetDeltaPercent(aUpdateObj.charge);
                  this.WeaponChargeMeter._visible = true;
               }
               else
               {
                  this.WeaponChargeMeter._visible = false;
               }
            }
            _loc13_ = aUpdateObj.poisoned != true ? "Off" : "On";
            this.PoisonInstance.gotoAndStop(_loc13_);
            this.WeaponDamageValue.SetText(aUpdateObj.damage);
            this.WeaponEnchantedLabel.textAutoSize = "shrink";
            this.WeaponEnchantedLabel.htmlText = aUpdateObj.effects;
            break;
         case InventoryDefines.ICT_BOOK:
            if(aUpdateObj.description != undefined && aUpdateObj.description != "")
            {
               this.gotoAndStop("Books_Description");
               this.BookDescriptionLabel.SetText(aUpdateObj.description);
               break;
            }
            this.gotoAndStop("Books_reg");
            break;
         case InventoryDefines.ICT_POTION:
         case InventoryDefines.ICT_FOOD:
            this.gotoAndStop("Potions_reg");
            this.PotionsLabel.textAutoSize = "shrink";
            this.PotionsLabel.htmlText = aUpdateObj.effects;
            this.SkillTextInstance.text = aUpdateObj.skillName == undefined ? "" : aUpdateObj.skillName;
            break;
         case InventoryDefines.ICT_SPELL_DEFAULT:
            this.gotoAndStop("Power_reg");
            this.MagicEffectsLabel.SetText(aUpdateObj.effects,true);
            this.MagicEffectsLabel.textAutoSize = "shrink";
            if(aUpdateObj.spellCost <= 0)
            {
               this.MagicCostValue._alpha = 0;
               this.MagicCostTimeValue._alpha = 0;
               this.MagicCostLabel._alpha = 0;
               this.MagicCostTimeLabel._alpha = 0;
               this.MagicCostPerSec._alpha = 0;
               break;
            }
            this.MagicCostValue._alpha = 100;
            this.MagicCostLabel._alpha = 100;
            this.MagicCostValue.text = aUpdateObj.spellCost.toString();
            break;
         case InventoryDefines.ICT_SPELL:
            _loc11_ = aUpdateObj.castTime == 0;
            if(!_loc11_)
            {
               this.gotoAndStop("Magic_reg");
            }
            else
            {
               this.gotoAndStop("Magic_time_label");
            }
            this.SkillLevelText.text = aUpdateObj.castLevel.toString();
            this.MagicEffectsLabel.SetText(aUpdateObj.effects,true);
            this.MagicEffectsLabel.textAutoSize = "shrink";
            this.MagicCostValue.textAutoSize = "shrink";
            this.MagicCostTimeValue.textAutoSize = "shrink";
            if(!_loc11_)
            {
               this.MagicCostValue.text = aUpdateObj.spellCost.toString();
               break;
            }
            this.MagicCostTimeValue.text = aUpdateObj.spellCost.toString();
            break;
         case InventoryDefines.ICT_INGREDIENT:
            this.gotoAndStop("Ingredients_reg");
            _loc4_ = 0;
            while(_loc4_ < 4)
            {
               this["EffectLabel" + _loc4_].textAutoSize = "shrink";
               if(aUpdateObj["itemEffect" + _loc4_] != undefined && aUpdateObj["itemEffect" + _loc4_] != "")
               {
                  this["EffectLabel" + _loc4_].textColor = 16777215;
                  this["EffectLabel" + _loc4_].SetText(aUpdateObj["itemEffect" + _loc4_]);
               }
               else if(_loc4_ < aUpdateObj.numItemEffects)
               {
                  this["EffectLabel" + _loc4_].textColor = 10066329;
                  this["EffectLabel" + _loc4_].SetText("$UNKNOWN");
               }
               else
               {
                  this["EffectLabel" + _loc4_].SetText("");
               }
               _loc4_ = _loc4_ + 1;
            }
            break;
         case InventoryDefines.ICT_MISC:
            this.gotoAndStop("Misc_reg");
            break;
         case InventoryDefines.ICT_SHOUT:
            this.gotoAndStop("Shouts_reg");
            _loc9_ = 0;
            _loc3_ = 0;
            while(_loc3_ < 3)
            {
               if(aUpdateObj["word" + _loc3_] != undefined && aUpdateObj["word" + _loc3_] != "" && aUpdateObj["unlocked" + _loc3_] == true)
               {
                  _loc9_ = _loc3_;
               }
               _loc3_ = _loc3_ + 1;
            }
            _loc3_ = 0;
            while(_loc3_ < 3)
            {
               _loc7_ = aUpdateObj["dragonWord" + _loc3_] != undefined ? aUpdateObj["dragonWord" + _loc3_] : "";
               _loc6_ = aUpdateObj["word" + _loc3_] != undefined ? aUpdateObj["word" + _loc3_] : "";
               _loc5_ = aUpdateObj["unlocked" + _loc3_] == true;
               this["ShoutTextInstance" + _loc3_].DragonShoutLabelInstance.ShoutWordsLabel.textAutoSize = "shrink";
               this["ShoutTextInstance" + _loc3_].ShoutLabelInstance.ShoutWordsLabelTranslation.textAutoSize = "shrink";
               this["ShoutTextInstance" + _loc3_].DragonShoutLabelInstance.ShoutWordsLabel.SetText(_loc7_.toUpperCase());
               this["ShoutTextInstance" + _loc3_].ShoutLabelInstance.ShoutWordsLabelTranslation.SetText(_loc6_);
               if(_loc5_ && _loc3_ == _loc9_ && this.LastUpdateObj.soulSpent == true)
               {
                  this["ShoutTextInstance" + _loc3_].gotoAndPlay("Learn");
               }
               else if(_loc5_)
               {
                  this["ShoutTextInstance" + _loc3_].gotoAndStop("Known");
                  this["ShoutTextInstance" + _loc3_].gotoAndStop("Known");
               }
               else
               {
                  this["ShoutTextInstance" + _loc3_].gotoAndStop("Unlocked");
                  this["ShoutTextInstance" + _loc3_].gotoAndStop("Unlocked");
               }
               _loc3_ = _loc3_ + 1;
            }
            this.ShoutEffectsLabel.htmlText = aUpdateObj.effects;
            this.ShoutCostValue.text = aUpdateObj.spellCost.toString();
            break;
         case InventoryDefines.ICT_ACTIVE_EFFECT:
            this.gotoAndStop("ActiveEffects");
            this.MagicEffectsLabel.html = true;
            this.MagicEffectsLabel.SetText(aUpdateObj.effects,true);
            this.MagicEffectsLabel.textAutoSize = "shrink";
            if(aUpdateObj.timeRemaining > 0)
            {
               _loc8_ = Math.floor(aUpdateObj.timeRemaining);
               this.ActiveEffectTimeValue._alpha = 100;
               this.SecsText._alpha = 100;
               if(_loc8_ >= 3600)
               {
                  _loc8_ = Math.floor(_loc8_ / 3600);
                  this.ActiveEffectTimeValue.text = _loc8_.toString();
                  if(_loc8_ == 1)
                  {
                     this.SecsText.text = "$hour";
                     break;
                  }
                  this.SecsText.text = "$hours";
                  break;
               }
               if(_loc8_ >= 60)
               {
                  _loc8_ = Math.floor(_loc8_ / 60);
                  this.ActiveEffectTimeValue.text = _loc8_.toString();
                  if(_loc8_ == 1)
                  {
                     this.SecsText.text = "$min";
                     break;
                  }
                  this.SecsText.text = "$mins";
                  break;
               }
               this.ActiveEffectTimeValue.text = _loc8_.toString();
               if(_loc8_ == 1)
               {
                  this.SecsText.text = "$sec";
                  break;
               }
               this.SecsText.text = "$secs";
               break;
            }
            this.ActiveEffectTimeValue._alpha = 0;
            this.SecsText._alpha = 0;
            break;
         case InventoryDefines.ICT_SOUL_GEMS:
            this.gotoAndStop("SoulGem");
            this.SoulLevel.text = aUpdateObj.soulLVL;
            break;
         case InventoryDefines.ICT_LIST:
            this.gotoAndStop("Item_list");
            if(aUpdateObj.listItems != undefined)
            {
               this.ItemList.entryList = aUpdateObj.listItems;
               this.ItemList.InvalidateData();
               this.ItemCardMeters[InventoryDefines.ICT_LIST] = new Components.DeltaMeter(this.ListChargeMeter.MeterInstance);
               this.ItemCardMeters[InventoryDefines.ICT_LIST].SetPercent(aUpdateObj.currentCharge);
               this.ItemCardMeters[InventoryDefines.ICT_LIST].SetDeltaPercent(aUpdateObj.currentCharge + this.ItemList.selectedEntry.chargeAdded);
               this.OpenListMenu();
            }
            break;
         case InventoryDefines.ICT_CRAFT_ENCHANTING:
         case InventoryDefines.ICT_HOUSE_PART:
            if(aUpdateObj.type == InventoryDefines.ICT_HOUSE_PART)
            {
               this.gotoAndStop("Magic_short");
               if(aUpdateObj.effects != undefined)
               {
                  this.MagicEffectsLabel.SetText(aUpdateObj.effects,true);
               }
               else
               {
                  this.MagicEffectsLabel.SetText("",true);
               }
            }
            else if(aUpdateObj.sliderShown == true)
            {
               this.gotoAndStop("Craft_Enchanting");
               this.ItemCardMeters[InventoryDefines.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_Default.MeterInstance);
               if(aUpdateObj.totalCharges != undefined && aUpdateObj.totalCharges != 0)
               {
                  this.TotalChargesValue.text = aUpdateObj.totalCharges;
               }
            }
            else if(aUpdateObj.damage != undefined)
            {
               this.gotoAndStop("Craft_Enchanting_Weapon");
               this.ItemCardMeters[InventoryDefines.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_Weapon.MeterInstance);
               this.WeaponDamageValue.SetText(aUpdateObj.damage);
            }
            else if(aUpdateObj.armor != undefined)
            {
               this.gotoAndStop("Craft_Enchanting_Armor");
               this.ApparelArmorValue.SetText(aUpdateObj.armor);
               this.SkillTextInstance.text = aUpdateObj.skillText;
            }
            else if(aUpdateObj.soulLVL != undefined)
            {
               this.gotoAndStop("Craft_Enchanting_SoulGem");
               this.ItemCardMeters[InventoryDefines.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_SoulGem.MeterInstance);
               this.SoulLevel.text = aUpdateObj.soulLVL;
            }
            else if(this.QuantitySlider_mc._alpha == 0)
            {
               this.gotoAndStop("Craft_Enchanting_Enchantment");
               this.ItemCardMeters[InventoryDefines.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_Enchantment.MeterInstance);
            }
            if(aUpdateObj.usedCharge == 0 && aUpdateObj.totalCharges == 0)
            {
               this.ItemCardMeters[InventoryDefines.ICT_WEAPON].DeltaMeterMovieClip._parent._parent._alpha = 0;
            }
            else if(aUpdateObj.usedCharge != undefined)
            {
               this.ItemCardMeters[InventoryDefines.ICT_WEAPON].SetPercent(aUpdateObj.usedCharge);
            }
            if(aUpdateObj.effects != undefined && aUpdateObj.effects.length > 0)
            {
               if(this.EnchantmentLabel != undefined)
               {
                  this.EnchantmentLabel.SetText(aUpdateObj.effects,true);
               }
               this.EnchantmentLabel.textAutoSize = "shrink";
               this.WeaponChargeMeter._alpha = 100;
               this.Enchanting_Background._alpha = 60;
               this.Enchanting_Slim_Background._alpha = 0;
               break;
            }
            if(this.EnchantmentLabel != undefined)
            {
               this.EnchantmentLabel.SetText("",true);
            }
            this.WeaponChargeMeter._alpha = 0;
            this.Enchanting_Slim_Background._alpha = 60;
            this.Enchanting_Background._alpha = 0;
            break;
         case InventoryDefines.ICT_KEY:
         case InventoryDefines.ICT_NONE:
         default:
            this.gotoAndStop("Empty");
      }
      this.SetupItemName(_loc12_);
      var _loc10_;
      if(aUpdateObj.name != undefined)
      {
         _loc10_ = !(aUpdateObj.count != undefined && aUpdateObj.count > 1) ? aUpdateObj.name : aUpdateObj.name + " (" + aUpdateObj.count + ")";
         this.ItemText.ItemTextField.SetText(!(this._bEditNameMode || aUpdateObj.upperCaseName == false) ? _loc10_.toUpperCase() : _loc10_,false);
         this.ItemText.ItemTextField.textColor = aUpdateObj.negativeEffect != true ? 16777215 : 16711680;
      }
      this.ItemValueText.textAutoSize = "shrink";
      this.ItemWeightText.textAutoSize = "shrink";
      if(aUpdateObj.value != undefined && this.ItemValueText != undefined)
      {
         this.ItemValueText.SetText(aUpdateObj.value.toString());
      }
      if(aUpdateObj.weight != undefined && this.ItemWeightText != undefined)
      {
         this.ItemWeightText.SetText(this.RoundDecimal(aUpdateObj.weight,1).toString());
      }
      this.StolenTextInstance._visible = aUpdateObj.stolen == true;
      this.LastUpdateObj = aUpdateObj;
   }
   function RoundDecimal(aNumber, aPrecision)
   {
      var _loc1_ = Math.pow(10,aPrecision);
      return Math.round(_loc1_ * aNumber) / _loc1_;
   }
   function PrepareInputElements(aActiveClip)
   {
      var _loc4_ = 92;
      var _loc6_ = 98;
      var _loc5_ = 147.3;
      var _loc2_ = 130;
      var _loc7_ = 166;
      if(aActiveClip == this.EnchantingSlider_mc)
      {
         this.QuantitySlider_mc._y = -100;
         this.ButtonRect._y = _loc7_;
         this.EnchantingSlider_mc._y = _loc5_;
         this.CardList_mc._y = -100;
         this.QuantitySlider_mc._alpha = 0;
         this.ButtonRect._alpha = 100;
         this.EnchantingSlider_mc._alpha = 100;
         this.CardList_mc._alpha = 0;
      }
      else if(aActiveClip == this.QuantitySlider_mc)
      {
         this.QuantitySlider_mc._y = _loc4_;
         this.ButtonRect._y = _loc2_;
         this.EnchantingSlider_mc._y = -100;
         this.CardList_mc._y = -100;
         this.QuantitySlider_mc._alpha = 100;
         this.ButtonRect._alpha = 100;
         this.EnchantingSlider_mc._alpha = 0;
         this.CardList_mc._alpha = 0;
      }
      else if(aActiveClip == this.CardList_mc)
      {
         this.QuantitySlider_mc._y = -100;
         this.ButtonRect._y = -100;
         this.EnchantingSlider_mc._y = -100;
         this.CardList_mc._y = _loc6_;
         this.QuantitySlider_mc._alpha = 0;
         this.ButtonRect._alpha = 0;
         this.EnchantingSlider_mc._alpha = 0;
         this.CardList_mc._alpha = 100;
      }
      else if(aActiveClip == this.ButtonRect)
      {
         this.QuantitySlider_mc._y = -100;
         this.ButtonRect._y = _loc2_;
         this.EnchantingSlider_mc._y = -100;
         this.CardList_mc._y = -100;
         this.QuantitySlider_mc._alpha = 0;
         this.ButtonRect._alpha = 100;
         this.EnchantingSlider_mc._alpha = 0;
         this.CardList_mc._alpha = 0;
      }
   }
   function ShowEnchantingSlider(aiMaxValue, aiMinValue, aiCurrentValue)
   {
      this.gotoAndStop("Craft_Enchanting");
      this.QuantitySlider_mc = this.EnchantingSlider_mc;
      this.QuantitySlider_mc.addEventListener("change",this,"onSliderChange");
      this.PrepareInputElements(this.EnchantingSlider_mc);
      this.QuantitySlider_mc.maximum = aiMaxValue;
      this.QuantitySlider_mc.minimum = aiMinValue;
      this.QuantitySlider_mc.value = aiCurrentValue;
      this.PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
      gfx.managers.FocusHandler.instance.setFocus(this.QuantitySlider_mc,0);
      this.InputHandler = this.HandleQuantityMenuInput;
      this.dispatchEvent({type:"subMenuAction",opening:true,menu:"quantity"});
   }
   function ShowQuantityMenu(aiMaxAmount)
   {
      this.gotoAndStop("Quantity");
      this.PrepareInputElements(this.QuantitySlider_mc);
      this.QuantitySlider_mc.maximum = aiMaxAmount;
      this.QuantitySlider_mc.value = aiMaxAmount;
      this.SliderValueText.textAutoSize = "shrink";
      this.SliderValueText.SetText(Math.floor(this.QuantitySlider_mc.value).toString());
      this.PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
      gfx.managers.FocusHandler.instance.setFocus(this.QuantitySlider_mc,0);
      this.InputHandler = this.HandleQuantityMenuInput;
      this.dispatchEvent({type:"subMenuAction",opening:true,menu:"quantity"});
   }
   function HideQuantityMenu(aCanceled)
   {
      gfx.managers.FocusHandler.instance.setFocus(this.PrevFocus,0);
      this.QuantitySlider_mc._alpha = 0;
      this.ButtonRect_mc._alpha = 0;
      this.InputHandler = undefined;
      this.dispatchEvent({type:"subMenuAction",opening:false,canceled:aCanceled,menu:"quantity"});
   }
   function OpenListMenu()
   {
      this.PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
      gfx.managers.FocusHandler.instance.setFocus(this.ItemList,0);
      this.ItemList._visible = true;
      this.ItemList.addEventListener("itemPress",this,"onListItemPress");
      this.ItemList.addEventListener("listMovedUp",this,"onListSelectionChange");
      this.ItemList.addEventListener("listMovedDown",this,"onListSelectionChange");
      this.ItemList.addEventListener("selectionChange",this,"onListMouseSelectionChange");
      this.PrepareInputElements(this.CardList_mc);
      this.ListChargeMeter._alpha = 100;
      this.InputHandler = this.HandleListMenuInput;
      this.dispatchEvent({type:"subMenuAction",opening:true,menu:"list"});
   }
   function HideListMenu()
   {
      gfx.managers.FocusHandler.instance.setFocus(this.PrevFocus,0);
      this.ListChargeMeter._alpha = 0;
      this.CardList_mc._alpha = 0;
      this.ItemCardMeters[InventoryDefines.ICT_LIST] = undefined;
      this.InputHandler = undefined;
      this.ItemList._visible = false;
      this.dispatchEvent({type:"subMenuAction",opening:false,menu:"list"});
   }
   function ShowConfirmMessage(strMessage)
   {
      this.gotoAndStop("ConfirmMessage");
      this.PrepareInputElements(this.ButtonRect_mc);
      var _loc2_ = strMessage.split("\r\n");
      var _loc3_ = _loc2_.join("\n");
      this.MessageText.SetText(_loc3_);
      this.PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
      gfx.managers.FocusHandler.instance.setFocus(this,0);
      this.InputHandler = this.HandleConfirmMessageInput;
      this.dispatchEvent({type:"subMenuAction",opening:true,menu:"message"});
   }
   function HideConfirmMessage()
   {
      gfx.managers.FocusHandler.instance.setFocus(this.PrevFocus,0);
      this.ButtonRect_mc._alpha = 0;
      this.InputHandler = undefined;
      this.dispatchEvent({type:"subMenuAction",opening:false,menu:"message"});
   }
   function StartEditName(aInitialText, aMaxChars)
   {
      if(Selection.getFocus() != this.ItemName)
      {
         this.PrevFocus = gfx.managers.FocusHandler.instance.getFocus(0);
         if(aInitialText != undefined)
         {
            this.ItemName.text = aInitialText;
         }
         this.ItemName.type = "input";
         this.ItemName.noTranslate = true;
         this.ItemName.selectable = true;
         this.ItemName.maxChars = aMaxChars == undefined ? null : aMaxChars;
         Selection.setFocus(this.ItemName,0);
         Selection.setSelection(0,0);
         this.InputHandler = this.HandleEditNameInput;
         this.dispatchEvent({type:"subMenuAction",opening:true,menu:"editName"});
         this._bEditNameMode = true;
      }
   }
   function EndEditName()
   {
      this.ItemName.type = "dynamic";
      this.ItemName.noTranslate = false;
      this.ItemName.selectable = false;
      this.ItemName.maxChars = null;
      var _loc2_ = this.PrevFocus.focusEnabled;
      this.PrevFocus.focusEnabled = true;
      Selection.setFocus(this.PrevFocus,0);
      this.PrevFocus.focusEnabled = _loc2_;
      this.InputHandler = undefined;
      this.dispatchEvent({type:"subMenuAction",opening:false,menu:"editName"});
      this._bEditNameMode = false;
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      if(pathToFocus.length > 0 && pathToFocus[0].handleInput != undefined)
      {
         pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      if(!_loc2_ && this.InputHandler != undefined)
      {
         _loc2_ = this.InputHandler(details);
      }
      return _loc2_;
   }
   function HandleQuantityMenuInput(details)
   {
      var _loc2_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
         {
            this.HideQuantityMenu(false);
            if(this.QuantitySlider_mc.value > 0)
            {
               this.dispatchEvent({type:"quantitySelect",amount:Math.floor(this.QuantitySlider_mc.value)});
            }
            else
            {
               this.itemInfo = this.LastUpdateObj;
            }
            _loc2_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
         {
            this.HideQuantityMenu(true);
            this.itemInfo = this.LastUpdateObj;
            _loc2_ = true;
         }
      }
      return _loc2_;
   }
   function HandleListMenuInput(details)
   {
      var _loc2_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details) && details.navEquivalent == gfx.ui.NavigationCode.TAB)
      {
         this.HideListMenu();
         _loc2_ = true;
      }
      return _loc2_;
   }
   function HandleConfirmMessageInput(details)
   {
      var _loc2_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
         {
            this.HideConfirmMessage();
            this.dispatchEvent({type:"messageConfirm"});
            _loc2_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
         {
            this.HideConfirmMessage();
            this.dispatchEvent({type:"messageCancel"});
            this.itemInfo = this.LastUpdateObj;
            _loc2_ = true;
         }
      }
      return _loc2_;
   }
   function HandleEditNameInput(details)
   {
      Selection.setFocus(this.ItemName,0);
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.ENTER && details.code != 32)
         {
            this.dispatchEvent({type:"endEditItemName",useNewName:true,newName:this.ItemName.text});
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
         {
            this.dispatchEvent({type:"endEditItemName",useNewName:false,newName:""});
         }
      }
      return true;
   }
   function onSliderChange()
   {
      var _loc3_ = this.EnchantingSlider_mc._alpha <= 0 ? this.SliderValueText : this.TotalChargesValue;
      var _loc4_ = Number(_loc3_.text);
      var _loc2_ = Math.floor(this.QuantitySlider_mc.value);
      if(_loc4_ != _loc2_)
      {
         _loc3_.SetText(_loc2_.toString());
         gfx.io.GameDelegate.call("PlaySound",["UIMenuPrevNext"]);
         this.dispatchEvent({type:"sliderChange",value:_loc2_});
      }
   }
   function onListItemPress(event)
   {
      this.dispatchEvent(event);
      this.HideListMenu();
   }
   function onListMouseSelectionChange(event)
   {
      if(event.keyboardOrMouse == 0)
      {
         this.onListSelectionChange(event);
      }
   }
   function onListSelectionChange(event)
   {
      this.ItemCardMeters[InventoryDefines.ICT_LIST].SetDeltaPercent(this.ItemList.selectedEntry.chargeAdded + this.LastUpdateObj.currentCharge);
   }
}
