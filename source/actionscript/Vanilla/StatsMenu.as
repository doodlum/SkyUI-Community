class StatsMenu extends MovieClip
{
   var AddPerkButtonInstance;
   var AddPerkTextInstance;
   var BottomBarInstance;
   var CameraMovementInstance;
   var CurrentPerkFrame;
   var DescriptionCardMeter;
   var LevelMeter;
   var PerkEndFrame;
   var PerkName0;
   var PerksLeft;
   var Platform;
   var SkillsListInstance;
   var State;
   var TopPlayerInfo;
   static var HealthMeter;
   static var HealthMeterBase;
   static var MagickaMeter;
   static var MagickaMeterBase;
   static var MeterText;
   static var SkillRing_mc;
   static var SkillsA;
   static var StaminaMeter;
   static var StaminaMeterBase;
   static var StatsMenuInstance = null;
   static var MAGICKA_METER = 0;
   static var HEALTH_METER = 1;
   static var STAMINA_METER = 2;
   static var CURRENT_METER_TEXT = 0;
   static var MAX_METER_TEXT = 1;
   static var ALTERATION = 0;
   static var CONJURATION = 1;
   static var DESTRUCTION = 2;
   static var MYSTICISM = 3;
   static var RESTORATION = 4;
   static var ENCHANTING = 5;
   static var LIGHT_ARMOR = 6;
   static var PICKPOCKET = 7;
   static var LOCKPICKING = 8;
   static var SNEAK = 9;
   static var ALCHEMY = 10;
   static var SPEECHCRAFT = 11;
   static var ONE_HANDED_WEAPONS = 12;
   static var TWO_HANDED_WEAPONS = 13;
   static var MARKSMAN = 14;
   static var BLOCK = 15;
   static var SMITHING = 16;
   static var HEAVY_ARMOR = 17;
   static var SkillStatsA = new Array();
   static var PerkNamesA = new Array();
   static var BeginAnimation = 0;
   static var EndAnimation = 1000;
   static var STATS = 0;
   static var LEVEL_UP = 1;
   static var MaxPerkNameHeight = 115;
   static var MaxPerkNameHeightLevelMode = 175;
   static var MaxPerkNamesDisplayed = 64;
   var CameraUpdateInterval = 0;
   var bLegendaryInstalled = false;
   var iCurrentSkillLevel = 15;
   var bInPerkMode = false;
   function StatsMenu()
   {
      super();
      StatsMenu.StatsMenuInstance = this;
      this.DescriptionCardMeter = new Components.Meter(StatsMenu.StatsMenuInstance.DescriptionCardInstance.animate);
      StatsMenu.SkillsA = new Array();
      StatsMenu.SkillRing_mc = this.SkillsListInstance;
      this.SetDirection(0);
      var _loc5_ = this.BottomBarInstance.BottomBarPlayerInfoInstance.PlayerInfoCardInstance;
      StatsMenu.MagickaMeterBase = _loc5_.MagickaMeterInstance;
      StatsMenu.HealthMeterBase = _loc5_.HealthMeterInstance;
      StatsMenu.StaminaMeterBase = _loc5_.StaminaMeterInstance;
      StatsMenu.MagickaMeter = new Components.Meter(StatsMenu.MagickaMeterBase.MagickaMeter_mc);
      StatsMenu.HealthMeter = new Components.Meter(StatsMenu.HealthMeterBase.HealthMeter_mc);
      StatsMenu.StaminaMeter = new Components.Meter(StatsMenu.StaminaMeterBase.StaminaMeter_mc);
      StatsMenu.MagickaMeterBase.Magicka.gotoAndStop("Pause");
      StatsMenu.HealthMeterBase.Health.gotoAndStop("Pause");
      StatsMenu.StaminaMeterBase.Stamina.gotoAndStop("Pause");
      StatsMenu.MeterText = [_loc5_.magicValue,_loc5_.healthValue,_loc5_.enduranceValue];
      this.SetMeter(StatsMenu.MAGICKA_METER,50,100);
      this.SetMeter(StatsMenu.HEALTH_METER,75,100);
      this.SetMeter(StatsMenu.STAMINA_METER,25,100);
      this.Platform = Shared.ButtonChange.PLATFORM_PC;
      this.AddPerkButtonInstance._alpha = 0;
      var _loc3_ = 0;
      var _loc4_;
      while(_loc3_ < StatsMenu.MaxPerkNamesDisplayed)
      {
         _loc4_ = this.attachMovie("PerkName","PerkName" + _loc3_,this.getNextHighestDepth());
         _loc4_._x = -100 - this._x;
         _loc3_ = _loc3_ + 1;
      }
      // Fix: duplicate TopPlayerInfo
      // this.TopPlayerInfo.swapDepths(this.getNextHighestDepth());
      this.SetStatsMode(true,0);
      this.CurrentPerkFrame = 0;
      this.PerkName0.gotoAndStop("Visible");
      this.PerkEndFrame = this.PerkName0._currentFrame;
      this.PerkName0.gotoAndStop("Invisible");
   }
   function GetSkillClip(aSkillName)
   {
      return this.SkillsListInstance.BaseRingInstance[aSkillName].Val.ValText;
   }
   function UpdatePerkText(abShow)
   {
      var _loc2_ = 0;
      var _loc3_;
      var _loc4_;
      if(abShow == true || abShow == undefined)
      {
         _loc3_ = 0;
         while(_loc3_ < StatsMenu.PerkNamesA.length)
         {
            _loc4_ = false;
            if(StatsMenu.PerkNamesA[_loc3_] != undefined)
            {
               if(Shared.GlobalFunc.Lerp(0,720,0,1,StatsMenu.PerkNamesA[_loc3_ + 2]) > (this.State != StatsMenu.LEVEL_UP ? StatsMenu.MaxPerkNameHeight : StatsMenu.MaxPerkNameHeightLevelMode))
               {
                  this["PerkName" + _loc2_].PerkNameClipInstance.NameText.html = true;
                  this["PerkName" + _loc2_].PerkNameClipInstance.NameText.SetText(StatsMenu.PerkNamesA[_loc3_],true);
                  this["PerkName" + _loc2_]._xscale = StatsMenu.PerkNamesA[_loc3_ + 2] * 165 + 10;
                  this["PerkName" + _loc2_]._yscale = StatsMenu.PerkNamesA[_loc3_ + 2] * 165 + 10;
                  this["PerkName" + _loc2_]._x = Shared.GlobalFunc.Lerp(0,1280,0,1,StatsMenu.PerkNamesA[_loc3_ + 1]) - this._x;
                  this["PerkName" + _loc2_]._y = Shared.GlobalFunc.Lerp(0,720,0,1,StatsMenu.PerkNamesA[_loc3_ + 2]) - this._y;
                  this["PerkName" + _loc2_].bPlaying = true;
                  if(this["PerkName" + _loc2_] != undefined)
                  {
                     this["PerkName" + _loc2_].gotoAndStop(this.CurrentPerkFrame);
                  }
                  _loc2_ = _loc2_ + 1;
                  _loc4_ = true;
               }
            }
            else if(!_loc4_ && this["PerkName" + _loc2_] != undefined)
            {
               this["PerkName" + _loc2_].gotoAndStop("Invisible");
            }
            _loc3_ += 3;
         }
         _loc3_ = _loc2_;
         while(_loc3_ <= StatsMenu.MaxPerkNamesDisplayed)
         {
            if(this["PerkName" + _loc3_] != undefined)
            {
               this["PerkName" + _loc3_].gotoAndStop("Invisible");
            }
            _loc3_ = _loc3_ + 1;
         }
         if(this.CurrentPerkFrame <= this.PerkEndFrame)
         {
            this.CurrentPerkFrame = this.CurrentPerkFrame + 1;
         }
      }
      else if(abShow == false)
      {
         this.CurrentPerkFrame = 0;
         _loc3_ = 0;
         while(_loc3_ < StatsMenu.MaxPerkNamesDisplayed)
         {
            if(this["PerkName" + _loc3_] != undefined)
            {
               this["PerkName" + _loc3_].gotoAndStop("Invisible");
            }
            _loc3_ = _loc3_ + 1;
         }
      }
   }
   function InitExtensions()
   {
      Shared.GlobalFunc.SetLockFunction();
      Shared.GlobalFunc.MaintainTextFormat();
      gfx.io.GameDelegate.addCallBack("SetDescriptionCard",this,"SetDescriptionCard");
      gfx.io.GameDelegate.addCallBack("SetPlayerInfo",this,"SetPlayerInfo");
      gfx.io.GameDelegate.addCallBack("UpdateSkillList",this,"UpdateSkillList");
      gfx.io.GameDelegate.addCallBack("SetDirection",this,"SetDirection");
      gfx.io.GameDelegate.addCallBack("HideRing",this,"HideRing");
      gfx.io.GameDelegate.addCallBack("SetStatsMode",this,"SetStatsMode");
      gfx.io.GameDelegate.addCallBack("SetPerkCount",this,"SetPerkCount");
      gfx.io.GameDelegate.addCallBack("ShowLegendaryButtonHint",this,"ShowLegendaryButtonHint");
      // Fix: a gray animated square visible at the bottom of the screen at 4:3 resolution
      this.CameraMovementInstance.CameraPositionAlpha._visible = false;
      // Fix: visible localization text "$Perks to increase" at 4:3 resolution
      _root.PerksInstance._visible = false;
   }
   function SetStatsMode(abStats, aPerkCount)
   {
      this.State = !abStats ? StatsMenu.LEVEL_UP : StatsMenu.STATS;
      this.PerksLeft = aPerkCount;
      if(aPerkCount != undefined)
      {
         this.SetPerkCount(aPerkCount);
      }
   }
   function ShowLegendaryButtonHint()
   {
      this.bLegendaryInstalled = true;
      this.AddPerkTextInstance._alpha = 100;
      this.AddPerkTextInstance.gotoAndStop("Legendary");
      this.AddPerkTextInstance.LegendaryButtonInstance.SetPlatform(StatsMenu.StatsMenuInstance.Platform,false);
   }
   function SetPerkCount(aPerkCount)
   {
      var _loc3_ = this.bLegendaryInstalled && this.iCurrentSkillLevel >= 100 && !this.bInPerkMode;
      if(!_loc3_)
      {
         this.AddPerkTextInstance.gotoAndStop("Normal");
         if(aPerkCount > 0)
         {
            this.AddPerkTextInstance._alpha = 100;
            this.AddPerkTextInstance.AddPerkTextField.text = _root.PerksInstance.text + " " + aPerkCount;
         }
         else
         {
            this.AddPerkTextInstance._alpha = 0;
         }
      }
   }
   static function SetPlatform(aiPlatformIndex, abPS3Switch)
   {
      StatsMenu.StatsMenuInstance.Platform = aiPlatformIndex;
   }
   function UpdateCamera()
   {
      var _loc2_;
      if(StatsMenu.StatsMenuInstance.CameraMovementInstance._currentFrame < 100)
      {
         _loc2_ = StatsMenu.StatsMenuInstance.CameraMovementInstance._currentFrame + 8;
         if(_loc2_ > 100)
         {
            _loc2_ = 100;
         }
         gfx.io.GameDelegate.call("MoveCamera",[this.CameraMovementInstance.CameraPositionAlpha._alpha / 100]);
      }
      else
      {
         clearInterval(this.CameraUpdateInterval);
         this.CameraUpdateInterval = 0;
      }
   }
   static function StartCameraAnimation()
   {
      clearInterval(StatsMenu.StatsMenuInstance.CameraUpdateInterval);
      gfx.io.GameDelegate.call("MoveCamera",[0]);
      StatsMenu.StatsMenuInstance.CameraUpdateInterval = setInterval(mx.utils.Delegate.create(StatsMenu.StatsMenuInstance,StatsMenu.StatsMenuInstance.UpdateCamera),41);
   }
   function UpdateSkillList(aCapitalizeSkillNames)
   {
      StatsMenu.StatsMenuInstance.AnimatingSkillTextInstance.InitAnimatedSkillText(StatsMenu.SkillStatsA,aCapitalizeSkillNames);
   }
   function HideRing()
   {
      StatsMenu.StatsMenuInstance.AnimatingSkillTextInstance.HideRing();
   }
   function SetDirection(aAngle)
   {
      StatsMenu.StatsMenuInstance.AnimatingSkillTextInstance.SetAngle(aAngle);
   }
   function SetPlayerInfo()
   {
      StatsMenu.StatsMenuInstance.TopPlayerInfo.FirstLastLabel.textAutoSize = "shrink";
      StatsMenu.StatsMenuInstance.TopPlayerInfo.FirstLastLabel.SetText(arguments[0]);
      StatsMenu.StatsMenuInstance.TopPlayerInfo.LevelNumberLabel.textAutoSize = "shrink";
      StatsMenu.StatsMenuInstance.TopPlayerInfo.LevelNumberLabel.SetText(arguments[1]);
      if(this.LevelMeter == undefined)
      {
         this.LevelMeter = new Components.Meter(StatsMenu.StatsMenuInstance.TopPlayerInfo.animate);
      }
      this.LevelMeter.SetPercent(arguments[2]);
      StatsMenu.StatsMenuInstance.TopPlayerInfo.RacevalueLabel.SetText(arguments[3]);
      this.SetMeter(0,arguments[4],arguments[5],arguments[6]);
      this.SetMeter(1,arguments[7],arguments[8],arguments[9]);
      this.SetMeter(2,arguments[10],arguments[11],arguments[12]);
   }
   function SetMeter(aMeter, aCurrentValue, aMaxValue, aColor)
   {
      var _loc2_;
      if(aMeter >= StatsMenu.MAGICKA_METER && aMeter <= StatsMenu.STAMINA_METER)
      {
         _loc2_ = 100 * (Math.max(0,Math.min(aCurrentValue,aMaxValue)) / aMaxValue);
         switch(aMeter)
         {
            case StatsMenu.MAGICKA_METER:
               StatsMenu.MagickaMeter.SetPercent(_loc2_);
               break;
            case StatsMenu.HEALTH_METER:
               StatsMenu.HealthMeter.SetPercent(_loc2_);
               break;
            case StatsMenu.STAMINA_METER:
               StatsMenu.StaminaMeter.SetPercent(_loc2_);
         }
         StatsMenu.MeterText[aMeter].html = true;
         StatsMenu.MeterText[aMeter].textAutoSize = "shrink";
         if(aColor != undefined)
         {
            StatsMenu.MeterText[aMeter].SetText("<font color=\'" + aColor + "\'>" + aCurrentValue + "/" + aMaxValue + "</font>",true);
         }
         else
         {
            StatsMenu.MeterText[aMeter].SetText(aCurrentValue + "/" + aMaxValue,true);
         }
         StatsMenu.MagickaMeter.Update();
         StatsMenu.HealthMeter.Update();
         StatsMenu.StaminaMeter.Update();
      }
   }
   function SetDescriptionCard(abPerkMode, aName, aMeterPercent, aDescription, aRequirements, aSkillLevel, aSkill, aLegendaryCount)
   {
      if(StatsMenu.StatsMenuInstance != undefined)
      {
         StatsMenu.StatsMenuInstance.gotoAndStop(!abPerkMode ? "Skills" : "Perks");
      }
      var _loc2_ = StatsMenu.StatsMenuInstance.DescriptionCardInstance;
      _loc2_.CardDescriptionTextInstance.SetText(aDescription,true);
      this.AddPerkButtonInstance._alpha = !(this.State == StatsMenu.LEVEL_UP && abPerkMode && this.Platform != Shared.ButtonChange.PLATFORM_PC) ? 0 : 100;
      this.iCurrentSkillLevel = aSkillLevel;
      this.bInPerkMode = abPerkMode;
      if(!abPerkMode)
      {
         _loc2_.CardNameTextInstance.html = true;
         _loc2_.CardNameTextInstance.htmlText = aName.toUpperCase() + " <font face=\'$EverywhereBoldFont\' size=\'32\' color=\'#FFFFFF\'>" + aSkillLevel + "</font>";
         StatsMenu.StatsMenuInstance.DescriptionCardMeter.SetPercent(aMeterPercent);
      }
      else
      {
         _loc2_.CardNameTextInstance.SetText("");
         _loc2_.SkillRequirementText.html = true;
         _loc2_.SkillRequirementText.htmlText = aSkill.toUpperCase() + "          " + aRequirements.toUpperCase();
         if(this.PerksLeft != undefined)
         {
            this.SetPerkCount(this.PerksLeft);
         }
         _loc2_.Perktype.SetText(aSkill);
      }
   }
}
