class ItemCard extends MovieClip
{
   var ActiveEffectTimeValue;
   var ApparelArmorValue;
   var ApparelEnchantedLabel;
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
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = ItemCard.SKYUI_VERSION_MAJOR + "." + ItemCard.SKYUI_VERSION_MINOR + " SE";
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
      if(this.bFadedIn)
      {
         return undefined;
      }
      this._visible = true;
      this._parent.gotoAndPlay("fadeIn");
      this.bFadedIn = true;
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
      return this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON];
   }
   function get itemInfo()
   {
      return this.LastUpdateObj;
   }
   function set itemInfo(aUpdateObj)
   {
      this.ItemCardMeters = new Array();
      var _loc3_ = this.ItemName != undefined ? this.ItemName.htmlText : "";
      var _loc4_ = aUpdateObj.type;
      var _loc5_;
      var _loc6_;
      var _loc7_;
      var _loc8_;
      var _loc9_;
      var _loc10_;
      var _loc11_;
      var _loc12_;
      switch(_loc4_)
      {
         case skyui.defines.Inventory.ICT_ARMOR:
            if(aUpdateObj.effects.length == 0)
            {
               this.gotoAndStop("Apparel_reg");
            }
            else
            {
               this.gotoAndStop("Apparel_Enchanted");
            }
            this.ApparelArmorValue.textAutoSize = "shrink";
            this.ApparelArmorValue.SetText(aUpdateObj.armor);
            this.ApparelEnchantedLabel.htmlText = aUpdateObj.effects;
            this.ShrinkToFit(this.ApparelEnchantedLabel);
            this.SkillTextInstance.text = aUpdateObj.skillText;
            break;
         case skyui.defines.Inventory.ICT_WEAPON:
            if(aUpdateObj.effects.length == 0)
            {
               this.gotoAndStop("Weapons_reg");
            }
            else
            {
               this.gotoAndStop("Weapons_Enchanted");
               if(this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] == undefined)
               {
                  this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(this.WeaponChargeMeter.MeterInstance);
               }
               if(aUpdateObj.usedCharge != undefined && aUpdateObj.charge != undefined)
               {
                  this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].SetPercent(aUpdateObj.usedCharge);
                  this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].SetDeltaPercent(aUpdateObj.charge);
                  this.WeaponChargeMeter._visible = true;
               }
               else
               {
                  this.WeaponChargeMeter._visible = false;
               }
            }
            _loc5_ = aUpdateObj.poisoned != true ? "Off" : "On";
            this.PoisonInstance.gotoAndStop(_loc5_);
            this.WeaponDamageValue.textAutoSize = "shrink";
            this.WeaponDamageValue.SetText(aUpdateObj.damage);
            this.WeaponEnchantedLabel.htmlText = aUpdateObj.effects;
            this.ShrinkToFit(this.WeaponEnchantedLabel);
            break;
         case skyui.defines.Inventory.ICT_BOOK:
            if(aUpdateObj.description != undefined && aUpdateObj.description != "")
            {
               this.gotoAndStop("Books_Description");
               this.BookDescriptionLabel.SetText(aUpdateObj.description, true);
               this.ShrinkToFit(this.BookDescriptionLabel);
               break;
            }
            this.gotoAndStop("Books_reg");
            break;
         case skyui.defines.Inventory.ICT_POTION:
         case skyui.defines.Inventory.ICT_FOOD:
            this.gotoAndStop("Potions_reg");
            this.PotionsLabel.htmlText = aUpdateObj.effects;
            this.ShrinkToFit(this.PotionsLabel);
            this.SkillTextInstance.text = aUpdateObj.skillName != undefined ? aUpdateObj.skillName : "";
            break;
         case skyui.defines.Inventory.ICT_SPELL_DEFAULT:
            this.gotoAndStop("Power_reg");
            this.MagicEffectsLabel.SetText(aUpdateObj.effects,true);
            this.ShrinkToFit(this.MagicEffectsLabel);
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
         case skyui.defines.Inventory.ICT_SPELL:
            _loc6_ = aUpdateObj.castTime == 0;
            if(_loc6_)
            {
               this.gotoAndStop("Magic_time_label");
            }
            else
            {
               this.gotoAndStop("Magic_reg");
            }
            this.SkillLevelText.text = aUpdateObj.castLevel.toString();
            this.MagicEffectsLabel.SetText(aUpdateObj.effects,true);
            this.ShrinkToFit(this.MagicEffectsLabel);
            this.MagicCostValue.textAutoSize = "shrink";
            this.MagicCostTimeValue.textAutoSize = "shrink";
            if(_loc6_)
            {
               this.MagicCostTimeValue.text = aUpdateObj.spellCost.toString();
               break;
            }
            this.MagicCostValue.text = aUpdateObj.spellCost.toString();
            break;
         case skyui.defines.Inventory.ICT_INGREDIENT:
            this.gotoAndStop("Ingredients_reg");
            _loc7_ = 0;
            while(_loc7_ < 4)
            {
               this["EffectLabel" + _loc7_].textAutoSize = "shrink";
               if(aUpdateObj["itemEffect" + _loc7_] != undefined && aUpdateObj["itemEffect" + _loc7_] != "")
               {
                  this["EffectLabel" + _loc7_].textColor = 16777215;
                  this["EffectLabel" + _loc7_].SetText(aUpdateObj["itemEffect" + _loc7_]);
               }
               else if(_loc7_ < aUpdateObj.numItemEffects)
               {
                  this["EffectLabel" + _loc7_].textColor = 10066329;
                  this["EffectLabel" + _loc7_].SetText("$UNKNOWN");
               }
               else
               {
                  this["EffectLabel" + _loc7_].SetText("");
               }
               _loc7_ += 1;
            }
            break;
         case skyui.defines.Inventory.ICT_MISC:
            this.gotoAndStop("Misc_reg");
            break;
         case skyui.defines.Inventory.ICT_SHOUT:
            this.gotoAndStop("Shouts_reg");
            _loc8_ = 0;
            _loc7_ = 0;
            while(_loc7_ < 3)
            {
               if(aUpdateObj["word" + _loc7_] != undefined && aUpdateObj["word" + _loc7_] != "" && aUpdateObj["unlocked" + _loc7_] == true)
               {
                  _loc8_ = _loc7_;
               }
               _loc7_ += 1;
            }
            _loc7_ = 0;
            while(_loc7_ < 3)
            {
               _loc9_ = aUpdateObj["dragonWord" + _loc7_] != undefined ? aUpdateObj["dragonWord" + _loc7_] : "";
               _loc10_ = aUpdateObj["word" + _loc7_] != undefined ? aUpdateObj["word" + _loc7_] : "";
               _loc11_ = aUpdateObj["unlocked" + _loc7_] == true;
               this["ShoutTextInstance" + _loc7_].DragonShoutLabelInstance.ShoutWordsLabel.textAutoSize = "shrink";
               this["ShoutTextInstance" + _loc7_].ShoutLabelInstance.ShoutWordsLabelTranslation.textAutoSize = "shrink";
               this["ShoutTextInstance" + _loc7_].DragonShoutLabelInstance.ShoutWordsLabel.SetText(_loc9_.toUpperCase());
               this["ShoutTextInstance" + _loc7_].ShoutLabelInstance.ShoutWordsLabelTranslation.SetText(_loc10_);
               if(_loc11_ && _loc7_ == _loc8_ && this.LastUpdateObj.soulSpent == true)
               {
                  this["ShoutTextInstance" + _loc7_].gotoAndPlay("Learn");
               }
               else if(_loc11_)
               {
                  this["ShoutTextInstance" + _loc7_].gotoAndStop("Known");
                  this["ShoutTextInstance" + _loc7_].gotoAndStop("Known");
               }
               else
               {
                  this["ShoutTextInstance" + _loc7_].gotoAndStop("Unlocked");
                  this["ShoutTextInstance" + _loc7_].gotoAndStop("Unlocked");
               }
               _loc7_ += 1;
            }
            this.ShoutEffectsLabel.htmlText = aUpdateObj.effects;
            this.ShrinkToFit(this.ShoutEffectsLabel);
            this.ShoutCostValue.text = aUpdateObj.spellCost.toString();
            break;
         case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
            this.gotoAndStop("ActiveEffects");
            this.MagicEffectsLabel.SetText(aUpdateObj.effects,true);
            this.ShrinkToFit(this.MagicEffectsLabel);
            if(aUpdateObj.timeRemaining > 0)
            {
               _loc12_ = Math.floor(aUpdateObj.timeRemaining);
               this.ActiveEffectTimeValue._alpha = 100;
               this.SecsText._alpha = 100;
               if(_loc12_ >= 3600)
               {
                  _loc12_ = Math.floor(_loc12_ / 3600);
                  this.ActiveEffectTimeValue.text = _loc12_.toString();
                  if(_loc12_ == 1)
                  {
                     this.SecsText.text = "$hour";
                     break;
                  }
                  this.SecsText.text = "$hours";
                  break;
               }
               if(_loc12_ >= 60)
               {
                  _loc12_ = Math.floor(_loc12_ / 60);
                  this.ActiveEffectTimeValue.text = _loc12_.toString();
                  if(_loc12_ == 1)
                  {
                     this.SecsText.text = "$min";
                     break;
                  }
                  this.SecsText.text = "$mins";
                  break;
               }
               this.ActiveEffectTimeValue.text = _loc12_.toString();
               if(_loc12_ == 1)
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
         case skyui.defines.Inventory.ICT_SOUL_GEMS:
            this.gotoAndStop("SoulGem");
            this.SoulLevel.text = aUpdateObj.soulLVL;
            break;
         case skyui.defines.Inventory.ICT_LIST:
            this.gotoAndStop("Item_list");
            if(aUpdateObj.listItems != undefined)
            {
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
            if(aUpdateObj.type == skyui.defines.Inventory.ICT_HOUSE_PART)
            {
               this.gotoAndStop("Magic_short");
               if(aUpdateObj.effects == undefined)
               {
                  this.MagicEffectsLabel.SetText("",true);
               }
               else
               {
                  this.MagicEffectsLabel.SetText(aUpdateObj.effects,true);
               }
            }
            else if(aUpdateObj.sliderShown == true)
            {
               this.gotoAndStop("Craft_Enchanting");
               this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_Default.MeterInstance);
               if(aUpdateObj.totalCharges != undefined && aUpdateObj.totalCharges != 0)
               {
                  this.TotalChargesValue.text = aUpdateObj.totalCharges;
               }
            }
            else if(aUpdateObj.damage == undefined)
            {
               if(aUpdateObj.armor == undefined)
               {
                  if(aUpdateObj.soulLVL == undefined)
                  {
                     if(this.QuantitySlider_mc._alpha == 0)
                     {
                        this.gotoAndStop("Craft_Enchanting_Enchantment");
                        this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_Enchantment.MeterInstance);
                     }
                  }
                  else
                  {
                     this.gotoAndStop("Craft_Enchanting_SoulGem");
                     this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_SoulGem.MeterInstance);
                     this.SoulLevel.text = aUpdateObj.soulLVL;
                  }
               }
               else
               {
                  this.gotoAndStop("Craft_Enchanting_Armor");
                  this.ApparelArmorValue.SetText(aUpdateObj.armor);
                  this.SkillTextInstance.text = aUpdateObj.skillText;
               }
            }
            else
            {
               this.gotoAndStop("Craft_Enchanting_Weapon");
               this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON] = new Components.DeltaMeter(this.ChargeMeter_Weapon.MeterInstance);
               this.WeaponDamageValue.textAutoSize = "shrink";
               this.WeaponDamageValue.SetText(aUpdateObj.damage);
            }
            if(aUpdateObj.usedCharge == 0 && aUpdateObj.totalCharges == 0)
            {
               this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].DeltaMeterMovieClip._parent._parent._alpha = 0;
            }
            else if(aUpdateObj.usedCharge != undefined)
            {
               this.ItemCardMeters[skyui.defines.Inventory.ICT_WEAPON].SetPercent(aUpdateObj.usedCharge);
            }
            if(aUpdateObj.effects != undefined && aUpdateObj.effects.length > 0)
            {
               if(this.EnchantmentLabel != undefined)
               {
                  this.EnchantmentLabel.SetText(aUpdateObj.effects,true);
                  this.ShrinkToFit(this.EnchantmentLabel);
               }
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
         case skyui.defines.Inventory.ICT_KEY:
         case skyui.defines.Inventory.ICT_NONE:
         default:
            this.gotoAndStop("Empty");
      }
      this.SetupItemName(_loc3_);
      var _loc13_;
      if(aUpdateObj.name != undefined)
      {
         _loc13_ = !(aUpdateObj.count != undefined && aUpdateObj.count > 1) ? aUpdateObj.name : aUpdateObj.name + " (" + aUpdateObj.count + ")";
         this.ItemText.ItemTextField.SetText(!(this._bEditNameMode || aUpdateObj.upperCaseName == false) ? _loc13_.toUpperCase() : _loc13_,false);
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
         this.ItemWeightText.SetText(this.RoundDecimal(aUpdateObj.weight,2).toString());
      }
      this.StolenTextInstance._visible = aUpdateObj.stolen == true;
      this.LastUpdateObj = aUpdateObj;
   }
   function RoundDecimal(aNumber, aPrecision)
   {
      var _loc3_ = Math.pow(10,aPrecision);
      return Math.round(_loc3_ * aNumber) / _loc3_;
   }
   function PrepareInputElements(aActiveClip)
   {
      var _loc3_ = 92;
      var _loc4_ = 98;
      var _loc5_ = 147.3;
      var _loc6_ = 130;
      var _loc7_ = 166;
      switch(aActiveClip)
      {
         case this.EnchantingSlider_mc:
            this.QuantitySlider_mc._y = -100;
            this.ButtonRect._y = _loc7_;
            this.EnchantingSlider_mc._y = _loc5_;
            this.CardList_mc._y = -100;
            this.QuantitySlider_mc._alpha = 0;
            this.ButtonRect._alpha = 100;
            this.EnchantingSlider_mc._alpha = 100;
            this.CardList_mc._alpha = 0;
            break;
         case this.QuantitySlider_mc:
            this.QuantitySlider_mc._y = _loc3_;
            this.ButtonRect._y = _loc6_;
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
            this.CardList_mc._y = _loc4_;
            this.QuantitySlider_mc._alpha = 0;
            this.ButtonRect._alpha = 0;
            this.EnchantingSlider_mc._alpha = 0;
            this.CardList_mc._alpha = 100;
            break;
         case this.ButtonRect:
            this.QuantitySlider_mc._y = -100;
            this.ButtonRect._y = _loc6_;
            this.EnchantingSlider_mc._y = -100;
            this.CardList_mc._y = -100;
            this.QuantitySlider_mc._alpha = 0;
            this.ButtonRect._alpha = 100;
            this.EnchantingSlider_mc._alpha = 0;
            this.CardList_mc._alpha = 0;
         default:
            return;
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
   function HideQuantityMenu(abCanceled)
   {
      gfx.managers.FocusHandler.instance.setFocus(this.PrevFocus,0);
      this.QuantitySlider_mc._alpha = 0;
      this.ButtonRect_mc._alpha = 0;
      this.InputHandler = undefined;
      this.dispatchEvent({type:"subMenuAction",opening:false,canceled:abCanceled,menu:"quantity"});
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
      this.ItemCardMeters[skyui.defines.Inventory.ICT_LIST] = undefined;
      this.InputHandler = undefined;
      this.ItemList._visible = true;
      this.dispatchEvent({type:"subMenuAction",opening:false,menu:"list"});
   }
   function ShowConfirmMessage(astrMessage)
   {
      this.gotoAndStop("ConfirmMessage");
      this.PrepareInputElements(this.ButtonRect_mc);
      var _loc3_ = astrMessage.split("\r\n");
      var _loc4_ = _loc3_.join("\n");
      this.MessageText.SetText(_loc4_);
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
   function StartEditName(aInitialText, aiMaxChars)
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
         this.ItemName.maxChars = aiMaxChars != undefined ? aiMaxChars : null;
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
      var _loc4_ = false;
      if(pathToFocus.length > 0 && pathToFocus[0].handleInput != undefined)
      {
         pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      if(this.InputHandler != undefined)
      {
         _loc4_ = this.InputHandler(details);
      }
      return _loc4_;
   }
   function HandleQuantityMenuInput(details)
   {
      var _loc3_ = false;
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
            _loc3_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
         {
            this.HideQuantityMenu(true);
            this.itemInfo = this.LastUpdateObj;
            _loc3_ = true;
         }
      }
      return _loc3_;
   }
   function HandleListMenuInput(details)
   {
      var _loc3_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details) && details.navEquivalent == gfx.ui.NavigationCode.TAB)
      {
         this.HideListMenu();
         _loc3_ = true;
      }
      return _loc3_;
   }
   function HandleConfirmMessageInput(details)
   {
      var _loc3_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
         {
            this.HideConfirmMessage();
            this.dispatchEvent({type:"messageConfirm"});
            _loc3_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
         {
            this.HideConfirmMessage();
            this.dispatchEvent({type:"messageCancel"});
            this.itemInfo = this.LastUpdateObj;
            _loc3_ = true;
         }
      }
      return _loc3_;
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
      var _loc2_ = this.EnchantingSlider_mc._alpha > 0 ? this.TotalChargesValue : this.SliderValueText;
      var _loc3_ = Number(_loc2_.text);
      var _loc4_ = Math.floor(this.QuantitySlider_mc.value);
      if(_loc3_ != _loc4_)
      {
         _loc2_.SetText(_loc4_.toString());
         gfx.io.GameDelegate.call("PlaySound",["UIMenuPrevNext"]);
         this.dispatchEvent({type:"sliderChange",value:_loc4_});
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
      this.ItemCardMeters[skyui.defines.Inventory.ICT_LIST].SetDeltaPercent(this.ItemList.selectedEntry.chargeAdded + this.LastUpdateObj.currentCharge);
   }
   function ShrinkToFit(tf:TextField)
   {
      if (tf == undefined || tf.text == "") return;

      if (tf.origHeight == undefined) {
         tf.origHeight = tf._height;
      }
      
      tf._height = tf.origHeight;

      tf.multiline = true;
      tf.wordWrap = true;
      tf.textAutoSize = "none";

      var tfText:String = tf.htmlText;
      var formatSize = tf.getTextFormat().size;
      var fontSize:Number = (formatSize != undefined) ? formatSize : 20;

      tf.SetText(tfText, true);
      
      var tfHeight:Number = tf.getLineMetrics(0).height * tf.numLines;
      var baseHeight:Number = tf.origHeight;

      for (var prop in this)
      {
         var obj = this[prop];
         if ((obj instanceof MovieClip || obj instanceof TextField) && obj != tf && obj._parent == this)
         {
            if (obj.origY != undefined) {
               obj._y = obj.origY;
            }
         }
      }
      
      if (this.background != undefined && this.background.origHeight != undefined) {
         this.background._height = this.background.origHeight;
      } else if (this.background != undefined) {
         this.background.origHeight = this.background._height;
      }

      if (tfHeight > baseHeight)
      {
         var neededDelta:Number = (tfHeight - baseHeight) + 6;
         var actualExpansion:Number = Math.min(neededDelta, 80);
         
         tf._height = tf.origHeight + actualExpansion;

         var bg:MovieClip = (this.background != undefined) ? this.background : undefined;
         
         if (bg != undefined) {
            bg._height = bg.origHeight + actualExpansion;
         }

         for (var prop in this)
         {
            var obj = this[prop];
            if ((obj instanceof MovieClip || obj instanceof TextField) && obj != tf && obj != bg && obj._parent == this)
            {
               if (obj.origY == undefined) obj.origY = obj._y;
               
               if (obj._y > tf._y) {
                  obj._y = obj.origY + actualExpansion;
               }
            }
         }

         tfHeight = tf.getLineMetrics(0).height * tf.numLines;
      }

      while (tfHeight > tf._height && fontSize > 5)
      {
         var beforeHtmlSize:String = "SIZE=\"" + fontSize.toString() + "\"";
         fontSize -= 1;
         var htmlSize:String = "SIZE=\"" + fontSize.toString() + "\"";

         var newText:String = tfText.split(beforeHtmlSize).join(htmlSize);
         
         if (newText == tfText) break;
         tfText = newText;

         tf.textAutoSize = "none";
         tf.SetText(tfText, true);
         tfHeight = tf.getLineMetrics(0).height * tf.numLines;
      }
   }
}