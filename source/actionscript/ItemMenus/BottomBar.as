class BottomBar extends MovieClip
{
   var _healthMeter;
   var _lastItemType;
   var _levelMeter;
   var _magickaMeter;
   var _playerInfoObj;
   var _staminaMeter;
   var buttonPanel;
   var playerInfoCard;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = BottomBar.SKYUI_VERSION_MAJOR + "." + BottomBar.SKYUI_VERSION_MINOR + " SE";
   function BottomBar()
   {
      super();
      this._lastItemType = skyui.defines.Inventory.ICT_NONE;
      this._healthMeter = new Components.Meter(this.playerInfoCard.HealthRect.MeterInstance.Meter_mc);
      this._magickaMeter = new Components.Meter(this.playerInfoCard.MagickaRect.MeterInstance.Meter_mc);
      this._staminaMeter = new Components.Meter(this.playerInfoCard.StaminaRect.MeterInstance.Meter_mc);
      this._levelMeter = new Components.Meter(this.playerInfoCard.LevelMeterInstance.Meter_mc);
   }
   function positionElements(a_leftOffset, a_rightOffset)
   {
      this.buttonPanel._x = a_leftOffset;
      this.buttonPanel.updateButtons(true);
      this.playerInfoCard._x = a_rightOffset - this.playerInfoCard._width;
   }
   function showPlayerInfo()
   {
      this.playerInfoCard._alpha = 100;
   }
   function hidePlayerInfo()
   {
      this.playerInfoCard._alpha = 0;
   }
   function UpdatePlayerInfo(a_playerUpdateObj, a_itemUpdateObj)
   {
      this._playerInfoObj = a_playerUpdateObj;
      this.updatePerItemInfo(a_itemUpdateObj);
   }
   function updatePerItemInfo(a_itemUpdateObj)
   {
      var _loc2_ = this.playerInfoCard;
      var _loc4_ = a_itemUpdateObj.type;
      var _loc11_ = true;
      if(_loc4_ == undefined)
      {
         _loc4_ = this._lastItemType;
         if(a_itemUpdateObj == undefined)
         {
            a_itemUpdateObj = {type:this._lastItemType};
         }
      }
      else
      {
         this._lastItemType = _loc4_;
      }
      var _loc7_;
      var _loc10_;
      var _loc6_;
      var _loc9_;
      var _loc5_;
      var _loc8_;
      var _loc14_;
      var _loc13_;
      var _loc12_;
      if(this._playerInfoObj != undefined && a_itemUpdateObj != undefined)
      {
         switch(_loc4_)
         {
            case skyui.defines.Inventory.ICT_ARMOR:
               _loc2_.gotoAndStop("Armor");
               _loc7_ = Math.floor(this._playerInfoObj.armor).toString();
               if(a_itemUpdateObj.armorChange != undefined)
               {
                  _loc10_ = Math.round(a_itemUpdateObj.armorChange);
                  if(_loc10_ > 0)
                  {
                     _loc7_ = _loc7_ + " <font color=\'#189515\'>(+" + _loc10_.toString() + ")</font>";
                  }
                  else if(_loc10_ < 0)
                  {
                     _loc7_ = _loc7_ + " <font color=\'#FF0000\'>(" + _loc10_.toString() + ")</font>";
                  }
               }
               _loc2_.ArmorRatingValue.textAutoSize = "shrink";
               _loc2_.ArmorRatingValue.html = true;
               _loc2_.ArmorRatingValue.SetText(_loc7_,true);
               _loc6_ = this._playerInfoObj.warmth != undefined ? Math.floor(this._playerInfoObj.warmth).toString() : "0";
               if(a_itemUpdateObj.warmthChange != undefined)
               {
                  _loc9_ = Math.round(a_itemUpdateObj.warmthChange);
                  if(_loc9_ > 0)
                  {
                     _loc6_ = _loc6_ + " <font color=\'#189515\'>(+" + _loc9_.toString() + ")</font>";
                  }
                  else if(_loc9_ < 0)
                  {
                     _loc6_ = _loc6_ + " <font color=\'#FF0000\'>(" + _loc9_.toString() + ")</font>";
                  }
               }
               _loc2_.WarmthRatingLabel._visible = this._playerInfoObj.warmth != undefined;
               _loc2_.WarmthRatingValue._visible = this._playerInfoObj.warmth != undefined;
               _loc2_.WarmthRatingValue.textAutoSize = "shrink";
               _loc2_.WarmthRatingValue.html = true;
               _loc2_.WarmthRatingValue.SetText(_loc6_,true);
               break;
            case skyui.defines.Inventory.ICT_WEAPON:
               _loc2_.gotoAndStop("Weapon");
               _loc5_ = Math.floor(this._playerInfoObj.damage).toString();
               if(a_itemUpdateObj.damageChange != undefined)
               {
                  _loc8_ = Math.round(a_itemUpdateObj.damageChange);
                  if(_loc8_ > 0)
                  {
                     _loc5_ = _loc5_ + " <font color=\'#189515\'>(+" + _loc8_.toString() + ")</font>";
                  }
                  else if(_loc8_ < 0)
                  {
                     _loc5_ = _loc5_ + " <font color=\'#FF0000\'>(" + _loc8_.toString() + ")</font>";
                  }
               }
               _loc2_.DamageValue.textAutoSize = "shrink";
               _loc2_.DamageValue.html = true;
               _loc2_.DamageValue.SetText(_loc5_,true);
               break;
            case skyui.defines.Inventory.ICT_POTION:
            case skyui.defines.Inventory.ICT_FOOD:
               _loc14_ = 0;
               _loc13_ = 1;
               _loc12_ = 2;
               if(a_itemUpdateObj.potionType == _loc13_)
               {
                  _loc2_.gotoAndStop("MagickaPotion");
                  break;
               }
               if(a_itemUpdateObj.potionType == _loc12_)
               {
                  _loc2_.gotoAndStop("StaminaPotion");
                  break;
               }
               if(a_itemUpdateObj.potionType == _loc14_)
               {
                  _loc2_.gotoAndStop("HealthPotion");
               }
               break;
            case skyui.defines.Inventory.ICT_SPELL_DEFAULT:
            case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
               _loc2_.gotoAndStop("Magic");
               _loc11_ = false;
               break;
            case skyui.defines.Inventory.ICT_SPELL:
               _loc2_.gotoAndStop("MagicSkill");
               if(a_itemUpdateObj.magicSchoolName != undefined)
               {
                  this.updateSkillBar(a_itemUpdateObj.magicSchoolName,a_itemUpdateObj.magicSchoolLevel,a_itemUpdateObj.magicSchoolPct);
               }
               _loc11_ = false;
               break;
            case skyui.defines.Inventory.ICT_SHOUT:
               _loc2_.gotoAndStop("Shout");
               _loc2_.DragonSoulTextInstance.SetText(this._playerInfoObj.dragonSoulText);
               _loc11_ = false;
               break;
            case skyui.defines.Inventory.ICT_BOOK:
            case skyui.defines.Inventory.ICT_INGREDIENT:
            case skyui.defines.Inventory.ICT_MISC:
            case skyui.defines.Inventory.ICT_KEY:
            default:
               _loc2_.gotoAndStop("Default");
         }
         if(_loc11_)
         {
            _loc2_.CarryWeightValue.textAutoSize = "shrink";
            _loc2_.CarryWeightValue.SetText(Math.ceil(this._playerInfoObj.encumbrance) + "/" + Math.floor(this._playerInfoObj.maxEncumbrance));
            _loc2_.PlayerGoldValue.textAutoSize = "shrink";
            _loc2_.PlayerGoldValue.SetText(this._playerInfoObj.gold.toString());
            _loc2_.PlayerGoldLabel._x = _loc2_.PlayerGoldValue._x + _loc2_.PlayerGoldValue.getLineMetrics(0).x - _loc2_.PlayerGoldLabel._width;
            _loc2_.CarryWeightValue._x = _loc2_.PlayerGoldLabel._x + _loc2_.PlayerGoldLabel.getLineMetrics(0).x - _loc2_.CarryWeightValue._width - 5;
            _loc2_.CarryWeightLabel._x = _loc2_.CarryWeightValue._x + _loc2_.CarryWeightValue.getLineMetrics(0).x - _loc2_.CarryWeightLabel._width;
            if(_loc4_ === skyui.defines.Inventory.ICT_ARMOR)
            {
               _loc2_.ArmorRatingValue._x = _loc2_.CarryWeightLabel._x + _loc2_.CarryWeightLabel.getLineMetrics(0).x - _loc2_.ArmorRatingValue._width - 5;
               _loc2_.ArmorRatingLabel._x = _loc2_.ArmorRatingValue._x + _loc2_.ArmorRatingValue.getLineMetrics(0).x - _loc2_.ArmorRatingLabel._width;
               _loc2_.WarmthRatingValue._x = _loc2_.ArmorRatingLabel._x + _loc2_.ArmorRatingLabel.getLineMetrics(0).x - _loc2_.WarmthRatingValue._width - 5;
               _loc2_.WarmthRatingLabel._x = _loc2_.WarmthRatingValue._x + _loc2_.WarmthRatingValue.getLineMetrics(0).x - _loc2_.WarmthRatingLabel._width;
            }
            else if(_loc4_ === skyui.defines.Inventory.ICT_WEAPON)
            {
               _loc2_.DamageValue._x = _loc2_.CarryWeightLabel._x + _loc2_.CarryWeightLabel.getLineMetrics(0).x - _loc2_.DamageValue._width - 5;
               _loc2_.DamageLabel._x = _loc2_.DamageValue._x + _loc2_.DamageValue.getLineMetrics(0).x - _loc2_.DamageLabel._width;
            }
         }
         this.updateStatMeter(_loc2_.HealthRect,this._healthMeter,this._playerInfoObj.health,this._playerInfoObj.maxHealth,this._playerInfoObj.healthColor);
         this.updateStatMeter(_loc2_.MagickaRect,this._magickaMeter,this._playerInfoObj.magicka,this._playerInfoObj.maxMagicka,this._playerInfoObj.magickaColor);
         this.updateStatMeter(_loc2_.StaminaRect,this._staminaMeter,this._playerInfoObj.stamina,this._playerInfoObj.maxStamina,this._playerInfoObj.staminaColor);
      }
   }
   function UpdateCraftingInfo(a_skillName, a_levelStart, a_levelPercent)
   {
      this.playerInfoCard.gotoAndStop("Crafting");
      this.updateSkillBar(a_skillName,a_levelStart,a_levelPercent);
   }
   function updateBarterInfo(a_playerUpdateObj, a_itemUpdateObj, a_playerGold, a_vendorGold, a_vendorName)
   {
      this._playerInfoObj = a_playerUpdateObj;
      var _loc2_ = this.playerInfoCard;
      _loc2_.gotoAndStop("Barter");
      _loc2_.CarryWeightValue.textAutoSize = "shrink";
      _loc2_.CarryWeightValue.SetText(Math.ceil(this._playerInfoObj.encumbrance) + "/" + Math.floor(this._playerInfoObj.maxEncumbrance));
      _loc2_.VendorGoldLabel.textAutoSize = "shrink";
      if(a_vendorName != undefined)
      {
         _loc2_.VendorGoldLabel.SetText("$Gold");
         _loc2_.VendorGoldLabel.SetText(a_vendorName + " " + _loc2_.VendorGoldLabel.text);
      }
      this.updateBarterPriceInfo(a_playerGold,a_vendorGold,a_itemUpdateObj);
   }
   function updateBarterPriceInfo(a_playerGold, a_vendorGold, a_itemUpdateObj, a_goldDelta)
   {
      var _loc2_ = this.playerInfoCard;
      _loc2_.PlayerGoldValue.textAutoSize = "shrink";
      if(a_goldDelta == undefined)
      {
         _loc2_.PlayerGoldValue.SetText(a_playerGold.toString(),true);
      }
      else if(a_goldDelta >= 0)
      {
         _loc2_.PlayerGoldValue.SetText(a_playerGold.toString() + " <font color=\'#189515\'>(+" + a_goldDelta.toString() + ")</font>",true);
      }
      else
      {
         _loc2_.PlayerGoldValue.SetText(a_playerGold.toString() + " <font color=\'#FF0000\'>(" + a_goldDelta.toString() + ")</font>",true);
      }
      _loc2_.VendorGoldValue.textAutoSize = "shrink";
      _loc2_.VendorGoldValue.SetText(a_vendorGold.toString());
      _loc2_.VendorGoldLabel._x = _loc2_.VendorGoldValue._x + _loc2_.VendorGoldValue.getLineMetrics(0).x - _loc2_.VendorGoldLabel._width;
      _loc2_.PlayerGoldValue._x = _loc2_.VendorGoldLabel._x + _loc2_.VendorGoldLabel.getLineMetrics(0).x - _loc2_.PlayerGoldValue._width - 10;
      _loc2_.PlayerGoldLabel._x = _loc2_.PlayerGoldValue._x + _loc2_.PlayerGoldValue.getLineMetrics(0).x - _loc2_.PlayerGoldLabel._width;
      _loc2_.CarryWeightValue._x = _loc2_.PlayerGoldLabel._x + _loc2_.PlayerGoldLabel.getLineMetrics(0).x - _loc2_.CarryWeightValue._width - 5;
      _loc2_.CarryWeightLabel._x = _loc2_.CarryWeightValue._x + _loc2_.CarryWeightValue.getLineMetrics(0).x - _loc2_.CarryWeightLabel._width;
      this.updateBarterPerItemInfo(a_itemUpdateObj);
   }
   function updateBarterPerItemInfo(a_itemUpdateObj)
   {
      var _loc2_ = this.playerInfoCard;
      var _loc10_ = a_itemUpdateObj.type;
      if(_loc10_ == undefined)
      {
         _loc10_ = this._lastItemType;
         if(a_itemUpdateObj == undefined)
         {
            a_itemUpdateObj = {type:this._lastItemType};
         }
      }
      else
      {
         this._lastItemType = _loc10_;
      }
      var _loc6_;
      var _loc9_;
      var _loc5_;
      var _loc8_;
      var _loc4_;
      var _loc7_;
      if(a_itemUpdateObj != undefined)
      {
         _loc10_ = a_itemUpdateObj.type;
         switch(_loc10_)
         {
            case skyui.defines.Inventory.ICT_ARMOR:
               _loc2_.gotoAndStop("Barter_Armor");
               _loc6_ = Math.floor(this._playerInfoObj.armor).toString();
               if(a_itemUpdateObj.armorChange != undefined)
               {
                  _loc9_ = Math.round(a_itemUpdateObj.armorChange);
                  if(_loc9_ > 0)
                  {
                     _loc6_ = _loc6_ + " <font color=\'#189515\'>(+" + _loc9_.toString() + ")</font>";
                  }
                  else if(_loc9_ < 0)
                  {
                     _loc6_ = _loc6_ + " <font color=\'#FF0000\'>(" + _loc9_.toString() + ")</font>";
                  }
               }
               _loc2_.ArmorRatingValue.textAutoSize = "shrink";
               _loc2_.ArmorRatingValue.html = true;
               _loc2_.ArmorRatingValue.SetText(_loc6_,true);
               _loc2_.ArmorRatingValue._x = _loc2_.CarryWeightLabel._x + _loc2_.CarryWeightLabel.getLineMetrics(0).x - _loc2_.ArmorRatingValue._width - 5;
               _loc2_.ArmorRatingLabel._x = _loc2_.ArmorRatingValue._x + _loc2_.ArmorRatingValue.getLineMetrics(0).x - _loc2_.ArmorRatingLabel._width;
               _loc5_ = Math.floor(this._playerInfoObj.warmth).toString();
               if(a_itemUpdateObj.warmthChange != undefined)
               {
                  _loc8_ = Math.round(a_itemUpdateObj.warmthChange);
                  if(_loc8_ > 0)
                  {
                     _loc5_ = _loc5_ + " <font color=\'#189515\'>(+" + _loc8_.toString() + ")</font>";
                  }
                  else if(_loc8_ < 0)
                  {
                     _loc5_ = _loc5_ + " <font color=\'#FF0000\'>(" + _loc8_.toString() + ")</font>";
                  }
               }
               _loc2_.WarmthRatingLabel._visible = this._playerInfoObj.warmth != undefined;
               _loc2_.WarmthRatingValue._visible = this._playerInfoObj.warmth != undefined;
               _loc2_.WarmthRatingValue.textAutoSize = "shrink";
               _loc2_.WarmthRatingValue.html = true;
               _loc2_.WarmthRatingValue.SetText(_loc5_,true);
               _loc2_.WarmthRatingValue._x = _loc2_.ArmorRatingLabel._x + _loc2_.ArmorRatingLabel.getLineMetrics(0).x - _loc2_.WarmthRatingValue._width - 5;
               _loc2_.WarmthRatingLabel._x = _loc2_.WarmthRatingValue._x + _loc2_.WarmthRatingValue.getLineMetrics(0).x - _loc2_.WarmthRatingLabel._width;
               return;
            case skyui.defines.Inventory.ICT_WEAPON:
               _loc2_.gotoAndStop("Barter_Weapon");
               _loc4_ = Math.floor(this._playerInfoObj.damage).toString();
               if(a_itemUpdateObj.damageChange != undefined)
               {
                  _loc7_ = Math.round(a_itemUpdateObj.damageChange);
                  if(_loc7_ > 0)
                  {
                     _loc4_ = _loc4_ + " <font color=\'#189515\'>(+" + _loc7_.toString() + ")</font>";
                  }
                  else if(_loc7_ < 0)
                  {
                     _loc4_ = _loc4_ + " <font color=\'#FF0000\'>(" + _loc7_.toString() + ")</font>";
                  }
               }
               _loc2_.DamageValue.textAutoSize = "shrink";
               _loc2_.DamageValue.html = true;
               _loc2_.DamageValue.SetText(_loc4_,true);
               _loc2_.DamageValue._x = _loc2_.CarryWeightLabel._x + _loc2_.CarryWeightLabel.getLineMetrics(0).x - _loc2_.DamageValue._width - 5;
               _loc2_.DamageLabel._x = _loc2_.DamageValue._x + _loc2_.DamageValue.getLineMetrics(0).x - _loc2_.DamageLabel._width;
               return;
            default:
               _loc2_.gotoAndStop("Barter");
               return;
         }
      }
   }
   function setGiftInfo(a_favorPoints)
   {
      this.playerInfoCard.gotoAndStop("Gift");
   }
   function setPlatform(a_platform, a_bPS3Switch)
   {
      this.buttonPanel.setPlatform(a_platform,a_bPS3Switch);
   }
   function updateStatMeter(a_meterRect, a_meterObj, a_currValue, a_maxValue, a_colorStr)
   {
      if(a_colorStr == undefined)
      {
         a_colorStr = "#FFFFFF";
      }
      if(a_meterRect._alpha > 0)
      {
         if(a_meterRect.MeterText != undefined)
         {
            a_meterRect.MeterText.textAutoSize = "shrink";
            a_meterRect.MeterText.html = true;
            a_meterRect.MeterText.SetText("<font color=\'" + a_colorStr + "\'>" + Math.floor(a_currValue) + "/" + Math.floor(a_maxValue) + "</font>",true);
         }
         a_meterRect.MeterInstance.gotoAndStop("Pause");
         a_meterObj.SetPercent(a_currValue / a_maxValue * 100);
      }
   }
   function updateSkillBar(a_skillName, a_levelStart, a_levelPercent)
   {
      var _loc2_ = this.playerInfoCard;
      _loc2_.SkillLevelLabel.SetText(a_skillName);
      _loc2_.SkillLevelCurrent.SetText(a_levelStart);
      _loc2_.SkillLevelNext.SetText(a_levelStart + 1);
      _loc2_.LevelMeterInstance.gotoAndStop("Pause");
      this._levelMeter.SetPercent(a_levelPercent);
   }
}
