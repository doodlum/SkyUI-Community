class HUDMenu extends Shared.PlatformChangeUser
{
   var ActivateButton_tf;
   var ArrowInfoInstance;
   var BottomLeftLockInstance;
   var BottomRightLockInstance;
   var BottomRightRefInstance;
   var BottomRightRefX;
   var BottomRightRefY;
   var CompassMarkerEnemy;
   var CompassMarkerLocations;
   var CompassMarkerPlayerSet;
   var CompassMarkerQuest;
   var CompassMarkerQuestDoor;
   var CompassMarkerUndiscovered;
   var CompassRect;
   var CompassShoutMeterHolder;
   var CompassTargetDataA;
   var CompassThreeSixtyX;
   var CompassZeroX;
   var Crosshair;
   var CrosshairAlert;
   var CrosshairInstance;
   var EnemyHealthMeter;
   var EnemyHealth_mc;
   var FavorBackButtonBase;
   var FavorBackButton_mc;
   var FloatingQuestMarkerInstance;
   var FloatingQuestMarker_mc;
   var GrayBarInstance;
   var HUDModes;
   var Health;
   var HealthMeterAnim;
   var HealthMeterLeft;
   var HudElements;
   var LeftChargeMeter;
   var LeftChargeMeterAnim;
   var LocationLockBase;
   var Magica;
   var MagickaMeter;
   var MagickaMeterAnim;
   var MessagesBlock;
   var MessagesInstance;
   var QuestUpdateBaseInstance;
   var RightChargeMeter;
   var RightChargeMeterAnim;
   var RolloverButton_tf;
   var RolloverGrayBar_mc;
   var RolloverInfoInstance;
   var RolloverInfoText;
   var RolloverNameInstance;
   var RolloverText;
   var ShoutMeter_mc;
   var Stamina;
   var StaminaMeter;
   var StaminaMeterAnim;
   var StealthMeterInstance;
   var SubtitleText;
   var SubtitleTextHolder;
   var TemperatureMeter_mc;
   var TopLeftRefInstance;
   var TopLeftRefX;
   var TopLeftRefY;
   var TutorialHintsArtHolder;
   var TutorialHintsText;
   var TutorialLockInstance;
   var ValueTranslated;
   var WeightTranslated;
   var _currentframe;
   var bCrosshairEnabled;
   var gotoAndStop;
   var SavedRolloverText = "";
   var ItemInfoArray = new Array();
   var CompassMarkerList = new Array();
   var METER_PAUSE_FRAME = 40;
   var HealthPenaltyPercent = 0;
   var StaminaPenaltyPercent = 0;
   var MagickaPenaltyPercent = 0;
   var lastHealthMeterPercent = 0;
   var lastStaminaMeterPercent = 0;
   var lastMagickaMeterPercent = 0;
   var lastHealthPenaltyPercent = 0;
   var lastStaminaPenaltyPercent = 0;
   var lastMagickaPenaltyPercent = 0;
   var targetTempLevelFrame = 0;
   var temperatureMeterTempLevelFrames = new Array();
   var HUNGER_THRESHOLD_1 = 0;
   var HUNGER_THRESHOLD_2 = 20;
   var HUNGER_THRESHOLD_3 = 42;
   var COLD_THRESHOLD_1 = 0;
   var COLD_THRESHOLD_2 = 19;
   var COLD_THRESHOLD_3 = 42;
   var EXHAUSTION_THRESHOLD_1 = 0;
   var EXHAUSTION_THRESHOLD_2 = 20;
   var EXHAUSTION_THRESHOLD_3 = 46;
   var iPlatform = 1;
   static var CONTROLLER_ORBIS = 3;
   static var CONTROLLER_SCARLETT = 4;
   static var CONTROLLER_PROSPERO = 5;
   function HUDMenu()
   {
      super();
      Shared.GlobalFunc.MaintainTextFormat();
      Shared.GlobalFunc.AddReverseFunctions();
      Key.addListener(this);
      this.MagickaMeter = new Components.BlinkOnDemandPenaltyMeter(this.Magica.MagickaMeter_mc,this.Magica.MagickaFlashInstance,this.Magica.MagickaPenaltyMeter_mc);
      this.HealthMeterLeft = new Components.BlinkOnEmptyPenaltyMeter(this.Health.HealthMeter_mc.HealthLeft,this.Health.HealthPenaltyMeter_mc);
      this.StaminaMeter = new Components.BlinkOnDemandPenaltyMeter(this.Stamina.StaminaMeter_mc,this.Stamina.StaminaFlashInstance,this.Stamina.StaminaPenaltyMeter_mc);
      this.ShoutMeter_mc = new ShoutMeter(this.CompassShoutMeterHolder.ShoutMeterInstance,this.CompassShoutMeterHolder.ShoutWarningInstance);
      this.LeftChargeMeter = new Components.Meter(this.BottomLeftLockInstance.LeftHandChargeMeterInstance.ChargeMeter_mc);
      this.RightChargeMeter = new Components.Meter(this.BottomRightLockInstance.RightHandChargeMeterInstance.ChargeMeter_mc);
      this.MagickaMeterAnim = this.Magica;
      this.HealthMeterAnim = this.Health;
      this.StaminaMeterAnim = this.Stamina;
      this.LeftChargeMeterAnim = this.BottomLeftLockInstance.LeftHandChargeMeterInstance;
      this.RightChargeMeterAnim = this.BottomRightLockInstance.RightHandChargeMeterInstance;
      this.LeftChargeMeterAnim.gotoAndStop(1);
      this.RightChargeMeterAnim.gotoAndStop(1);
      this.MagickaMeterAnim.gotoAndStop(1);
      this.HealthMeterAnim.gotoAndStop(1);
      this.StaminaMeterAnim.gotoAndStop(1);
      this.ArrowInfoInstance.gotoAndStop(1);
      this.EnemyHealthMeter = new Components.Meter(this.EnemyHealth_mc);
      this.EnemyHealth_mc.BracketsInstance.RolloverNameInstance.textAutoSize = "shrink";
      this.TemperatureMeter_mc = this.CompassShoutMeterHolder.Compass.CompassTemperatureHolderInstance;
      this.EnemyHealthMeter.SetPercent(0);
      this.gotoAndStop("Alert");
      this.CrosshairAlert = this.Crosshair;
      this.CrosshairAlert.gotoAndStop("NoTarget");
      this.gotoAndStop("Normal");
      this.CrosshairInstance = this.Crosshair;
      this.CrosshairInstance.gotoAndStop("NoTarget");
      this.RolloverText = this.RolloverNameInstance;
      this.RolloverButton_tf = this.ActivateButton_tf;
      this.RolloverInfoText = this.RolloverInfoInstance;
      this.RolloverGrayBar_mc = this.GrayBarInstance;
      this.RolloverGrayBar_mc._alpha = 0;
      this.RolloverInfoText.html = true;
      this.FavorBackButton_mc = this.FavorBackButtonBase;
      this.CompassRect = this.CompassShoutMeterHolder.Compass.DirectionRect;
      this.InitCompass();
      this.FloatingQuestMarker_mc = this.FloatingQuestMarkerInstance;
      this.MessagesInstance = this.MessagesBlock;
      this.SetCrosshairTarget(false,"");
      this.bCrosshairEnabled = true;
      this.SubtitleText = this.SubtitleTextHolder.textField;
      this.TutorialHintsText = this.TutorialLockInstance.TutorialHintsInstance.FadeHolder.TutorialHintsTextInstance;
      this.TutorialHintsArtHolder = this.TutorialLockInstance.TutorialHintsInstance.FadeHolder.TutorialHintsArtInstance;
      this.TutorialLockInstance.TutorialHintsInstance.gotoAndStop("FadeIn");
      this.CompassTargetDataA = new Array();
      this.SetModes();
      this.StealthMeterInstance.gotoAndStop("FadedOut");
   }
   function RegisterComponents()
   {
      gfx.io.GameDelegate.call("RegisterHUDComponents",[this,this.HudElements,this.QuestUpdateBaseInstance,this.EnemyHealthMeter,this.StealthMeterInstance,this.StealthMeterInstance.SneakAnimInstance,this.EnemyHealth_mc.BracketsInstance,this.EnemyHealth_mc.BracketsInstance.RolloverNameInstance,this.StealthMeterInstance.SneakTextHolder,this.StealthMeterInstance.SneakTextHolder.SneakTextClip.SneakTextInstance]);
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.iPlatform = aiPlatform;
      this.FavorBackButton_mc.FavorBackButtonInstance.SetPlatform(aiPlatform,abPS3Switch);
      this.TutorialHintsArtHolder.SetPlatform(aiPlatform,abPS3Switch);
   }
   function SetModes()
   {
      this.HudElements = new Array();
      this.HUDModes = new Array();
      this.HudElements.push(this.Health);
      this.HudElements.push(this.Magica);
      this.HudElements.push(this.Stamina);
      this.HudElements.push(this.LeftChargeMeterAnim);
      this.HudElements.push(this.RightChargeMeterAnim);
      this.HudElements.push(this.CrosshairInstance);
      this.HudElements.push(this.CrosshairAlert);
      this.HudElements.push(this.RolloverText);
      this.HudElements.push(this.RolloverInfoText);
      this.HudElements.push(this.RolloverGrayBar_mc);
      this.HudElements.push(this.RolloverButton_tf);
      this.HudElements.push(this.CompassShoutMeterHolder);
      this.HudElements.push(this.MessagesBlock);
      this.HudElements.push(this.SubtitleTextHolder);
      this.HudElements.push(this.QuestUpdateBaseInstance);
      this.HudElements.push(this.EnemyHealth_mc);
      this.HudElements.push(this.StealthMeterInstance);
      this.HudElements.push(this.StealthMeterInstance.SneakTextHolder.SneakTextClip);
      this.HudElements.push(this.StealthMeterInstance.SneakTextHolder.SneakTextClip.SneakTextInstance);
      this.HudElements.push(this.ArrowInfoInstance);
      this.HudElements.push(this.FavorBackButton_mc);
      this.HudElements.push(this.FloatingQuestMarker_mc);
      this.HudElements.push(this.LocationLockBase);
      this.HudElements.push(this.TutorialLockInstance);
      
      this.Health.All = true;
      this.Magica.All = true;
      this.Stamina.All = true;
      this.LeftChargeMeterAnim.All = true;
      this.RightChargeMeterAnim.All = true;
      this.CrosshairInstance.All = true;
      this.CrosshairAlert.All = true;
      this.RolloverText.All = true;
      this.RolloverInfoText.All = true;
      this.RolloverGrayBar_mc.All = true;
      this.RolloverButton_tf.All = true;
      this.CompassShoutMeterHolder.All = true;
      this.MessagesBlock.All = true;
      this.SubtitleTextHolder.All = true;
      this.QuestUpdateBaseInstance.All = true;
      this.EnemyHealth_mc.All = true;
      this.StealthMeterInstance.All = true;
      this.ArrowInfoInstance.All = true;
      this.FloatingQuestMarker_mc.All = true;
      this.StealthMeterInstance.SneakTextHolder.SneakTextClip.All = true;
      this.StealthMeterInstance.SneakTextHolder.SneakTextClip.SneakTextInstance.All = true;    
      this.LocationLockBase.All = true;
      this.TutorialLockInstance.All = true;
      
      this.CrosshairInstance.Favor = true;
      this.RolloverText.Favor = true;
      this.RolloverInfoText.Favor = true;
      this.RolloverGrayBar_mc.Favor = true;
      this.RolloverButton_tf.Favor = true;
      this.CompassShoutMeterHolder.Favor = true;
      this.MessagesBlock.Favor = true;
      this.SubtitleTextHolder.Favor = true;
      this.QuestUpdateBaseInstance.Favor = true;
      this.EnemyHealth_mc.Favor = true;
      this.StealthMeterInstance.Favor = true;
      this.FavorBackButton_mc.Favor = true;
      this.FavorBackButton_mc._visible = false;
      this.FloatingQuestMarker_mc.Favor = true;
      this.LocationLockBase.Favor = true;
      this.TutorialLockInstance.Favor = true;
      
      this.MessagesBlock.InventoryMode = true;
      this.QuestUpdateBaseInstance.InventoryMode = true;
      this.LocationLockBase.InventoryMode = true;
      
      this.MessagesBlock.TweenMode = true;
      this.QuestUpdateBaseInstance.TweenMode = true;
      this.LocationLockBase.TweenMode = true;
      
      this.MessagesBlock.BookMode = true;
      this.QuestUpdateBaseInstance.BookMode = true;
      this.LocationLockBase.BookMode = true;
      
      this.QuestUpdateBaseInstance.DialogueMode = true;
      this.CompassShoutMeterHolder.DialogueMode = true;
      this.MessagesBlock.DialogueMode = true;
      this.LocationLockBase.DialogueMode = true;
      
      this.QuestUpdateBaseInstance.BarterMode = true;
      this.MessagesBlock.BarterMode = true;
      this.LocationLockBase.BarterMode = true;
      
      this.MessagesBlock.WorldMapMode = true;
      this.LocationLockBase.WorldMapMode = true;
      this.QuestUpdateBaseInstance.WorldMapMode = true;
      
      this.MessagesBlock.MovementDisabled = true;
      this.QuestUpdateBaseInstance.MovementDisabled = true;
      this.SubtitleTextHolder.MovementDisabled = true;
      this.TutorialLockInstance.MovementDisabled = true;
      this.LocationLockBase.MovementDisabled = true;
      
      this.Health.StealthMode = true;
      this.Magica.StealthMode = true;
      this.Stamina.StealthMode = true;
      this.LeftChargeMeterAnim.StealthMode = true;
      this.RightChargeMeterAnim.StealthMode = true;
      this.RolloverText.StealthMode = true;
      this.RolloverButton_tf.StealthMode = true;
      this.RolloverInfoText.StealthMode = true;
      this.RolloverGrayBar_mc.StealthMode = true;
      this.CompassShoutMeterHolder.StealthMode = true;
      this.MessagesBlock.StealthMode = true;
      this.SubtitleTextHolder.StealthMode = true;
      this.QuestUpdateBaseInstance.StealthMode = true;
      this.EnemyHealth_mc.StealthMode = true;
      this.StealthMeterInstance.StealthMode = true;
      this.StealthMeterInstance.SneakTextHolder.SneakTextClip.StealthMode = true;
      this.StealthMeterInstance.SneakTextHolder.SneakTextClip.SneakTextInstance.StealthMode = true;
      this.ArrowInfoInstance.StealthMode = true;
      this.FloatingQuestMarker_mc.StealthMode = true;
      this.LocationLockBase.StealthMode = true;
      this.TutorialLockInstance.StealthMode = true;
      
      this.Health.Swimming = true;
      this.Magica.Swimming = true;
      this.Stamina.Swimming = true;
      this.LeftChargeMeterAnim.Swimming = true;
      this.RightChargeMeterAnim.Swimming = true;
      this.CrosshairInstance.Swimming = true;
      this.RolloverText.Swimming = true;
      this.RolloverInfoText.Swimming = true;
      this.RolloverGrayBar_mc.Swimming = true;
      this.RolloverButton_tf.Swimming = true;
      this.CompassShoutMeterHolder.Swimming = true;
      this.MessagesBlock.Swimming = true;
      this.SubtitleTextHolder.Swimming = true;
      this.QuestUpdateBaseInstance.Swimming = true;
      this.EnemyHealth_mc.Swimming = true;
      this.ArrowInfoInstance.Swimming = true;
      this.FloatingQuestMarker_mc.Swimming = true;
      this.LocationLockBase.Swimming = true;
      this.TutorialLockInstance.Swimming = true;
      
      this.Health.HorseMode = true;
      this.Magica.HorseMode = true;
      this.CompassShoutMeterHolder.HorseMode = true;
      this.MessagesBlock.HorseMode = true;
      this.SubtitleTextHolder.HorseMode = true;
      this.QuestUpdateBaseInstance.HorseMode = true;
      this.EnemyHealth_mc.HorseMode = true;
      this.FloatingQuestMarker_mc.HorseMode = true;
      this.LocationLockBase.HorseMode = true;
      this.TutorialLockInstance.HorseMode = true;
      
      this.Health.WarHorseMode = true;
      this.Magica.WarHorseMode = true;
      this.CompassShoutMeterHolder.WarHorseMode = true;
      this.MessagesBlock.WarHorseMode = true;
      this.SubtitleTextHolder.WarHorseMode = true;
      this.QuestUpdateBaseInstance.WarHorseMode = true;
      this.EnemyHealth_mc.WarHorseMode = true;
      this.FloatingQuestMarker_mc.WarHorseMode = true;
      this.LocationLockBase.WarHorseMode = true;
      this.TutorialLockInstance.WarHorseMode = true;
      this.CrosshairInstance.WarHorseMode = true;
      this.Stamina.WarHorseMode = true;
      this.RightChargeMeterAnim.WarHorseMode = true;
      this.ArrowInfoInstance.WarHorseMode = true;
      
      this.MessagesBlock.CartMode = true;
      this.SubtitleTextHolder.CartMode = true;
      this.LocationLockBase.CartMode = true;
      this.TutorialLockInstance.CartMode = true;
      
      this.MessagesBlock.SleepWaitMode = true
      this.LocationLockBase.SleepWaitMode = true;
      this.QuestUpdateBaseInstance.SleepWaitMode = true;
      
      this.MessagesBlock.JournalMode = true
      this.LocationLockBase.JournalMode = true;
      this.QuestUpdateBaseInstance.JournalMode = true;
   }
   function ShowElements(aMode, abShow)
   {
      var _loc4_ = "All";
      var _loc3_;
      var _loc6_;
      if(abShow)
      {
         _loc3_ = this.HUDModes.length - 1;
         while(_loc3_ >= 0)
         {
            if(this.HUDModes[_loc3_] == aMode)
            {
               this.HUDModes.splice(_loc3_,1);
            }
            _loc3_ = _loc3_ - 1;
         }
         this.HUDModes.push(aMode);
         _loc4_ = aMode;
      }
      else
      {
         if(aMode.length > 0)
         {
            _loc6_ = false;
            _loc3_ = this.HUDModes.length - 1;
            while(_loc3_ >= 0 && !_loc6_)
            {
               if(this.HUDModes[_loc3_] == aMode)
               {
                  this.HUDModes.splice(_loc3_,1);
                  _loc6_ = true;
               }
               _loc3_ = _loc3_ - 1;
            }
         }
         else
         {
            this.HUDModes.pop();
         }
         if(this.HUDModes.length > 0)
         {
            _loc4_ = String(this.HUDModes[this.HUDModes.length - 1]);
         }
      }
      var _loc2_ = 0;
      while(_loc2_ < this.HudElements.length)
      {
         if(this.HudElements[_loc2_] != undefined)
         {
            this.HudElements[_loc2_]._visible = this.HudElements[_loc2_].hasOwnProperty(_loc4_);
            if(this.HudElements[_loc2_].onModeChange != undefined)
            {
               this.HudElements[_loc2_].onModeChange(_loc4_);
            }
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function SetLocationName(aLocation)
   {
      this.LocationLockBase.LocationNameBase.LocationTextBase.LocationTextInstance.SetText(aLocation);
      this.LocationLockBase.LocationNameBase.gotoAndPlay(1);
   }
   function CheckAgainstHudMode(aObj)
   {
      var _loc2_ = "All";
      if(this.HUDModes.length > 0)
      {
         _loc2_ = String(this.HUDModes[this.HUDModes.length - 1]);
      }
      return _loc2_ == "All" || aObj != undefined && aObj.hasOwnProperty(_loc2_);
   }
   function InitExtensions()
   {
      Stage.scaleMode = "showAll";
      var _loc4_ = this.QuestUpdateBaseInstance._y - this.CompassShoutMeterHolder._y;
      Shared.GlobalFunc.SetLockFunction();
      this.HealthMeterAnim.Lock("B");
      this.MagickaMeterAnim.Lock("BL");
      this.StaminaMeterAnim.Lock("BR");
      this.TopLeftRefInstance.Lock("TL");
      this.BottomRightRefInstance.Lock("BR");
      this.BottomLeftLockInstance.Lock("BL");
      this.BottomRightLockInstance.Lock("BR");
      this.ArrowInfoInstance.Lock("BR");
      this.FavorBackButton_mc.Lock("BR");
      this.LocationLockBase.Lock("TR");
      this.LocationLockBase.LocationNameBase.gotoAndStop(1);
      var _loc2_ = {x:this.TopLeftRefInstance.LocationRefInstance._x,y:this.TopLeftRefInstance.LocationRefInstance._y};
      this.TopLeftRefInstance.localToGlobal(_loc2_);
      this.TopLeftRefX = _loc2_.x;
      this.TopLeftRefY = _loc2_.y;
      var _loc3_ = {x:this.BottomRightRefInstance.LocationRefInstance._x,y:this.BottomRightRefInstance.LocationRefInstance._y};
      this.BottomRightRefInstance.localToGlobal(_loc3_);
      this.BottomRightRefX = _loc3_.x;
      this.BottomRightRefY = _loc3_.y;
      this.CompassShoutMeterHolder.Lock("T");
      this.EnemyHealth_mc.Lock("T");
      this.MessagesBlock.Lock("TL");
      this.QuestUpdateBaseInstance._y = this.CompassShoutMeterHolder._y + _loc4_;
      this.SubtitleTextHolder.Lock("B");
      this.SubtitleText._visible = false;
      this.SubtitleText.enabled = true;
      this.SubtitleText.verticalAutoSize = "bottom";
      this.SubtitleText.SetText(" ",true);
      this.RolloverText.verticalAutoSize = "top";
      this.RolloverText.html = true;
      gfx.io.GameDelegate.addCallBack("SetCrosshairTarget",this,"SetCrosshairTarget");
      gfx.io.GameDelegate.addCallBack("SetLoadDoorInfo",this,"SetLoadDoorInfo");
      gfx.io.GameDelegate.addCallBack("ShowMessage",this,"ShowMessage");
      gfx.io.GameDelegate.addCallBack("ShowSubtitle",this,"ShowSubtitle");
      gfx.io.GameDelegate.addCallBack("HideSubtitle",this,"HideSubtitle");
      gfx.io.GameDelegate.addCallBack("SetCrosshairEnabled",this,"SetCrosshairEnabled");
      gfx.io.GameDelegate.addCallBack("SetSubtitlesEnabled",this,"SetSubtitlesEnabled");
      gfx.io.GameDelegate.addCallBack("SetHealthMeterPercent",this,"SetHealthMeterPercent");
      gfx.io.GameDelegate.addCallBack("SetMagickaMeterPercent",this,"SetMagickaMeterPercent");
      gfx.io.GameDelegate.addCallBack("SetStaminaMeterPercent",this,"SetStaminaMeterPercent");
      gfx.io.GameDelegate.addCallBack("SetShoutMeterPercent",this,"SetShoutMeterPercent");
      gfx.io.GameDelegate.addCallBack("FlashShoutMeter",this,"FlashShoutMeter");
      gfx.io.GameDelegate.addCallBack("SetChargeMeterPercent",this,"SetChargeMeterPercent");
      gfx.io.GameDelegate.addCallBack("StartMagickaMeterBlinking",this,"StartMagickaBlinking");
      gfx.io.GameDelegate.addCallBack("StartStaminaMeterBlinking",this,"StartStaminaBlinking");
      gfx.io.GameDelegate.addCallBack("FadeOutStamina",this,"FadeOutStamina");
      gfx.io.GameDelegate.addCallBack("FadeOutChargeMeters",this,"FadeOutChargeMeters");
      gfx.io.GameDelegate.addCallBack("SetCompassAngle",this,"SetCompassAngle");
      gfx.io.GameDelegate.addCallBack("SetCompassTemperature",this,"SetCompassTemperature");
      gfx.io.GameDelegate.addCallBack("SetCompassMarkers",this,"SetCompassMarkers");
      gfx.io.GameDelegate.addCallBack("SetEnemyHealthPercent",this.EnemyHealthMeter,"SetPercent");
      gfx.io.GameDelegate.addCallBack("SetEnemyHealthTargetPercent",this.EnemyHealthMeter,"SetTargetPercent");
      gfx.io.GameDelegate.addCallBack("ShowNotification",this.QuestUpdateBaseInstance,"ShowNotification");
      gfx.io.GameDelegate.addCallBack("ShowElements",this,"ShowElements");
      gfx.io.GameDelegate.addCallBack("SetLocationName",this,"SetLocationName");
      gfx.io.GameDelegate.addCallBack("ShowTutorialHintText",this,"ShowTutorialHintText");
      gfx.io.GameDelegate.addCallBack("ValidateCrosshair",this,"ValidateCrosshair");
   }
   function InitCompass()
   {
      this.CompassShoutMeterHolder.Compass.gotoAndStop("ThreeSixty");
      this.CompassThreeSixtyX = this.CompassRect._x;
      this.CompassShoutMeterHolder.Compass.gotoAndStop("Zero");
      this.CompassZeroX = this.CompassRect._x;
      var _loc2_ = this.CompassRect.attachMovie("Compass Marker","temp",this.CompassRect.getNextHighestDepth());
      _loc2_.gotoAndStop("Quest");
      this.CompassMarkerQuest = _loc2_._currentframe == undefined ? 0 : _loc2_._currentframe;
      _loc2_.gotoAndStop("QuestDoor");
      this.CompassMarkerQuestDoor = _loc2_._currentframe == undefined ? 0 : _loc2_._currentframe;
      _loc2_.gotoAndStop("PlayerSet");
      this.CompassMarkerPlayerSet = _loc2_._currentframe == undefined ? 0 : _loc2_._currentframe;
      _loc2_.gotoAndStop("Enemy");
      this.CompassMarkerEnemy = _loc2_._currentframe == undefined ? 0 : _loc2_._currentframe;
      _loc2_.gotoAndStop("LocationMarkers");
      this.CompassMarkerLocations = _loc2_._currentframe == undefined ? 0 : _loc2_._currentframe;
      _loc2_.gotoAndStop("UndiscoveredMarkers");
      this.CompassMarkerUndiscovered = _loc2_._currentframe == undefined ? 0 : _loc2_._currentframe;
      _loc2_.removeMovieClip();
      this.TemperatureMeter_mc.gotoAndStop("Neutral");
      this.temperatureMeterTempLevelFrames[0] = this.TemperatureMeter_mc._currentframe;
      this.TemperatureMeter_mc.gotoAndStop("Fire");
      this.temperatureMeterTempLevelFrames[1] = this.TemperatureMeter_mc._currentframe;
      this.TemperatureMeter_mc.gotoAndStop("Warm");
      this.temperatureMeterTempLevelFrames[2] = this.TemperatureMeter_mc._currentframe;
      this.TemperatureMeter_mc.gotoAndStop("Cold");
      this.temperatureMeterTempLevelFrames[3] = this.TemperatureMeter_mc._currentframe;
      this.TemperatureMeter_mc.gotoAndStop("Freezing");
      this.temperatureMeterTempLevelFrames[4] = this.TemperatureMeter_mc._currentframe;
      this.TemperatureMeter_mc.gotoAndStop("Neutral");
   }
   function RunMeterAnim(aMeter)
   {
      aMeter.PlayForward(aMeter._currentframe);
   }
   function FadeOutMeter(aMeter)
   {
      if(aMeter._currentframe > this.METER_PAUSE_FRAME)
      {
         aMeter.gotoAndStop("Pause");
      }
      aMeter.PlayReverse();
   }
   function FadeOutStamina(aPercent)
   {
      this.FadeOutMeter(this.Stamina);
      this.StaminaMeter.CurrentPercent = aPercent;
      this.StaminaMeter.TargetPercent = aPercent;
   }
   function FadeOutChargeMeters()
   {
      this.FadeOutMeter(this.LeftChargeMeterAnim);
      this.FadeOutMeter(this.RightChargeMeterAnim);
   }
   function SetChargeMeterPercent(aPercent, abForce, abLeftHand, abShow)
   {
      var _loc2_ = !abLeftHand ? this.RightChargeMeter : this.LeftChargeMeter;
      var _loc3_ = !abLeftHand ? this.RightChargeMeterAnim : this.LeftChargeMeterAnim;
      if(!abShow)
      {
         _loc3_.gotoAndStop(1);
      }
      else if(abForce)
      {
         this.RunMeterAnim(_loc3_);
         _loc2_.SetPercent(aPercent);
         _loc2_.SetPercent(aPercent);
      }
      else
      {
         this.RunMeterAnim(_loc3_);
         _loc2_.SetTargetPercent(aPercent);
         _loc2_.SetTargetPercent(aPercent);
      }
   }
   function SetHealthMeterPercent(aPercent, abForce)
   {
      var _loc3_ = aPercent === this.lastHealthMeterPercent;
      this.lastHealthMeterPercent = aPercent;
      aPercent = aPercent * (100 - this.HealthPenaltyPercent) / 100;
      if(abForce)
      {
         this.HealthMeterLeft.SetPercent(aPercent);
      }
      else
      {
         if(!_loc3_ || this.HealthPenaltyPercent < this.lastHealthPenaltyPercent)
         {
            this.RunMeterAnim(this.HealthMeterAnim);
         }
         this.HealthMeterLeft.SetTargetPercent(aPercent);
      }
   }
   function SetMagickaMeterPercent(aPercent, abForce)
   {
      var _loc3_ = aPercent === this.lastMagickaMeterPercent;
      this.lastMagickaMeterPercent = aPercent;
      aPercent = aPercent * (100 - this.MagickaPenaltyPercent) / 100;
      if(abForce)
      {
         this.MagickaMeter.SetPercent(aPercent);
      }
      else
      {
         if(!_loc3_ || this.MagickaPenaltyPercent < this.lastMagickaPenaltyPercent)
         {
            this.RunMeterAnim(this.MagickaMeterAnim);
         }
         this.MagickaMeter.SetTargetPercent(aPercent);
      }
   }
   function SetStaminaMeterPercent(aPercent, abForce)
   {
      var _loc3_ = aPercent === this.lastStaminaMeterPercent;
      this.lastStaminaMeterPercent = aPercent;
      aPercent = aPercent * (100 - this.StaminaPenaltyPercent) / 100;
      if(abForce)
      {
         this.StaminaMeter.SetPercent(aPercent);
      }
      else
      {
         if(!_loc3_ || this.StaminaPenaltyPercent < this.lastStaminaPenaltyPercent)
         {
            this.RunMeterAnim(this.StaminaMeterAnim);
         }
         this.StaminaMeter.SetTargetPercent(aPercent);
      }
   }
   function SetShoutMeterPercent(aPercent, abForce)
   {
      this.ShoutMeter_mc.SetPercent(aPercent);
   }
   function FlashShoutMeter()
   {
      this.ShoutMeter_mc.FlashMeter();
   }
   function StartMagickaBlinking()
   {
      this.MagickaMeter.StartBlinking();
   }
   function StartStaminaBlinking()
   {
      this.StaminaMeter.StartBlinking();
   }
   function SetCompassAngle(aPlayerAngle, aCompassAngle, abShowCompass)
   {
      this.CompassRect._parent._visible = abShowCompass;
      var _loc2_;
      if(abShowCompass)
      {
         _loc2_ = Shared.GlobalFunc.Lerp(this.CompassZeroX,this.CompassThreeSixtyX,0,360,aCompassAngle);
         this.CompassRect._x = _loc2_;
         this.UpdateCompassMarkers(aPlayerAngle);
      }
   }
   function ShowSurvivalElements(abShow, aUpdateData, abForce)
   {
      if(abShow)
      {
         this.SetCompassTemperature(aUpdateData.aTemperatureLevel,abForce);
         this.SetColdPenaltyMeter(aUpdateData.aColdPenaltyPercent,abForce);
         this.SetHungerPenaltyMeter(aUpdateData.aHungerPenaltyPercent,abForce);
         this.SetExhaustionPenaltyMeter(aUpdateData.aExhaustionPenaltyPercent,abForce);
      }
      else
      {
         this.SetCompassTemperature(0,false);
         this.SetColdPenaltyMeter(undefined,false);
         this.SetHungerPenaltyMeter(undefined,false);
         this.SetExhaustionPenaltyMeter(undefined,false);
      }
   }
   function SetCompassTemperature(aTemperatureLevel, abForce)
   {
      this.targetTempLevelFrame = this.temperatureMeterTempLevelFrames[aTemperatureLevel];
      if(abForce)
      {
         this.TemperatureMeter_mc.gotoAndStop(this.temperatureMeterTempLevelFrames[aTemperatureLevel]);
      }
   }
   function TemperatureMeterAnim()
   {
      var _loc2_ = this.TemperatureMeter_mc._currentframe;
      if(_loc2_ < this.targetTempLevelFrame)
      {
         this.TemperatureMeter_mc.nextFrame();
      }
      else if(_loc2_ > this.targetTempLevelFrame)
      {
         this.TemperatureMeter_mc.prevFrame();
      }
   }
   function SetColdPenaltyMeter(aPercent, abForce)
   {
      if(aPercent)
      {
         this.HealthPenaltyPercent = aPercent;
      }
      else
      {
         this.HealthPenaltyPercent = 0;
      }
      this.SetHealthMeterPercent(this.lastHealthMeterPercent,false);
      if(abForce)
      {
         this.HealthMeterLeft.SetPenaltyPercent(this.HealthPenaltyPercent);
      }
      else
      {
         this.HealthMeterLeft.SetPenaltyTargetPercent(this.HealthPenaltyPercent);
         if(aPercent > this.lastHealthPenaltyPercent)
         {
            if(this.lastHealthPenaltyPercent <= this.COLD_THRESHOLD_1 && aPercent > this.COLD_THRESHOLD_1)
            {
               this.RunMeterAnim(this.HealthMeterAnim);
            }
         }
      }
      this.lastHealthPenaltyPercent = aPercent;
   }
   function SetHungerPenaltyMeter(aPercent, abForce)
   {
      if(aPercent)
      {
         this.StaminaPenaltyPercent = aPercent;
      }
      else
      {
         this.StaminaPenaltyPercent = 0;
      }
      this.SetStaminaMeterPercent(this.lastStaminaMeterPercent,false);
      if(abForce)
      {
         this.StaminaMeter.SetPenaltyPercent(this.StaminaPenaltyPercent);
      }
      else
      {
         this.StaminaMeter.SetPenaltyTargetPercent(this.StaminaPenaltyPercent);
         if(aPercent > this.lastStaminaPenaltyPercent)
         {
            if(this.lastStaminaPenaltyPercent <= this.HUNGER_THRESHOLD_1 && aPercent > this.HUNGER_THRESHOLD_1)
            {
               this.RunMeterAnim(this.StaminaMeterAnim);
            }
         }
      }
      this.lastStaminaPenaltyPercent = aPercent;
   }
   function SetExhaustionPenaltyMeter(aPercent, abForce)
   {
      if(aPercent)
      {
         this.MagickaPenaltyPercent = aPercent;
      }
      else
      {
         this.MagickaPenaltyPercent = 0;
      }
      this.SetMagickaMeterPercent(this.lastMagickaMeterPercent,false);
      if(abForce)
      {
         this.MagickaMeter.SetPenaltyPercent(this.MagickaPenaltyPercent);
      }
      else
      {
         this.MagickaMeter.SetPenaltyTargetPercent(this.MagickaPenaltyPercent);
         if(aPercent > this.lastMagickaPenaltyPercent)
         {
            if(this.lastMagickaPenaltyPercent <= this.EXHAUSTION_THRESHOLD_1 && aPercent > this.EXHAUSTION_THRESHOLD_1)
            {
               this.RunMeterAnim(this.MagickaMeterAnim);
            }
         }
      }
      this.lastMagickaPenaltyPercent = aPercent;
   }
   function SetCrosshairTarget(abActivate, aName, abShowButton, abTextOnly, abFavorMode, abShowCrosshair, aWeight, aCost, aFieldValue, aFieldText)
   {
      var _loc4_ = !abFavorMode ? "NoTarget" : "Favor";
      var _loc6_ = !abFavorMode ? "Target" : "Favor";
      var _loc3_ = this._currentframe != 1 ? this.CrosshairAlert : this.CrosshairInstance;
      _loc3_._visible = this.CheckAgainstHudMode(_loc3_) && abShowCrosshair != false;
      _loc3_._alpha = !this.bCrosshairEnabled ? 0 : 100;
      if(!abActivate && this.SavedRolloverText.length > 0)
      {
         _loc3_.gotoAndStop(_loc4_);
         this.RolloverText.SetText(this.SavedRolloverText,true);
         this.RolloverText._alpha = 100;
         this.RolloverButton_tf._alpha = 0;
      }
      else if(abTextOnly || abActivate)
      {
         if(!abTextOnly)
         {
            _loc3_.gotoAndStop(_loc6_);
         }
         this.RolloverText.SetText(aName,true);
         this.RolloverText._alpha = 100;
         this.RolloverButton_tf._alpha = !abShowButton ? 0 : 100;
         this.RolloverButton_tf._x = this.RolloverText._x + this.RolloverText.getLineMetrics(0).x - 103;
      }
      else
      {
         _loc3_.gotoAndStop(_loc4_);
         this.RolloverText.SetText(" ",true);
         this.RolloverText._alpha = 0;
         this.RolloverButton_tf._alpha = 0;
      }
      var _loc2_ = "";
      if(aCost != undefined)
      {
         _loc2_ = this.ValueTranslated.text + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + Math.round(aCost) + "</font>" + _loc2_;
      }
      if(aWeight != undefined)
      {
         _loc2_ = this.WeightTranslated.text + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + Shared.GlobalFunc.RoundDecimal(aWeight,1) + "</font>      " + _loc2_;
      }
      var _loc5_;
      if(aFieldValue != undefined)
      {
         _loc5_ = new TextField();
         _loc5_.text = aFieldText.toString();
         _loc2_ = _loc5_.text + " <font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + Math.round(aFieldValue) + "</font>      " + _loc2_;
      }
      if(_loc2_.length > 0)
      {
         this.RolloverGrayBar_mc._alpha = 100;
      }
      else
      {
         this.RolloverGrayBar_mc._alpha = 0;
      }
      this.RolloverInfoText.htmlText = _loc2_;
   }
   function RefreshActivateButtonArt(astrButtonName)
   {
      var _loc2_;
      var _loc4_;
      var _loc5_;
      if(astrButtonName == undefined)
      {
         this.RolloverButton_tf.SetText(" ",true);
      }
      else
      {
         if(this.iPlatform == HUDMenu.CONTROLLER_PROSPERO)
         {
            if(astrButtonName == "PS3_Start")
            {
               astrButtonName = "PS5_Start";
            }
         }
         _loc2_ = flash.display.BitmapData.loadBitmap(astrButtonName + ".png");
         if(_loc2_ != undefined && _loc2_.height > 0)
         {
            _loc4_ = 26;
            _loc5_ = Math.floor(_loc4_ / _loc2_.height * _loc2_.width);
            this.RolloverButton_tf.SetText("<img src=\'" + astrButtonName + ".png\' height=\'" + _loc4_ + "\' width=\'" + _loc5_ + "\'>",true);
         }
         else
         {
            this.RolloverButton_tf.SetText(" ",true);
         }
      }
   }
   function SetLoadDoorInfo(abShow, aDoorName)
   {
      if(abShow)
      {
         this.SavedRolloverText = aDoorName;
         this.SetCrosshairTarget(true,this.SavedRolloverText,false,true,false);
      }
      else
      {
         this.SavedRolloverText = "";
         this.SetCrosshairTarget(false,this.SavedRolloverText,false,false,false);
      }
   }
   function SetSubtitlesEnabled(abEnable)
   {
      this.SubtitleText.enabled = abEnable;
      if(!abEnable)
      {
         this.SubtitleText._visible = false;
      }
      else if(this.SubtitleText.htmlText != " ")
      {
         this.SubtitleText._visible = true;
      }
   }
   function ShowMessage(asMessage)
   {
      this.MessagesInstance.MessageArray.push(asMessage);
   }
   function ShowSubtitle(astrText)
   {
      this.SubtitleText.SetText(astrText,true);
      if(this.SubtitleText.enabled)
      {
         this.SubtitleText._visible = true;
      }
   }
   function HideSubtitle()
   {
      this.SubtitleText.SetText(" ",true);
      this.SubtitleText._visible = false;
   }
   function ShowArrowCount(aCount, abHide, aArrows)
   {
      var _loc2_ = 15;
      if(abHide)
      {
         if(this.ArrowInfoInstance._currentframe > _loc2_)
         {
            this.ArrowInfoInstance.gotoAndStop(_loc2_);
         }
         this.ArrowInfoInstance.PlayReverse();
      }
      else
      {
         this.ArrowInfoInstance.PlayForward(this.ArrowInfoInstance._currentframe);
         this.ArrowInfoInstance.ArrowCountInstance.ArrowNumInstance.SetText(aArrows + " (" + aCount.toString() + ")");
      }
   }
   function onEnterFrame()
   {
      this.MagickaMeter.UpdatePenalty();
      this.MagickaMeter.Update();
      this.HealthMeterLeft.UpdatePenalty();
      this.HealthMeterLeft.Update();
      this.StaminaMeter.UpdatePenalty();
      this.StaminaMeter.Update();
      this.EnemyHealthMeter.Update();
      this.LeftChargeMeter.Update();
      this.RightChargeMeter.Update();
      this.MessagesInstance.Update();
      this.TemperatureMeterAnim();
      if(this.lastMagickaPenaltyPercent > this.EXHAUSTION_THRESHOLD_1)
      {
         this.RunMeterAnim(this.MagickaMeterAnim);
      }
      if(this.lastHealthPenaltyPercent > this.COLD_THRESHOLD_1)
      {
         this.RunMeterAnim(this.HealthMeterAnim);
      }
      if(this.lastStaminaPenaltyPercent > this.HUNGER_THRESHOLD_1)
      {
         this.RunMeterAnim(this.StaminaMeterAnim);
      }
   }
   function SetCompassMarkers()
   {
      var _loc12_ = 0;
      var _loc13_ = 1;
      var _loc7_ = 2;
      var _loc9_ = 3;
      var _loc6_ = 4;
      while(this.CompassMarkerList.length > this.CompassTargetDataA.length / _loc6_)
      {
         this.CompassMarkerList.pop().movie.removeMovieClip();
      }
      var _loc2_ = 0;
      var _loc3_;
      var _loc5_;
      var _loc4_;
      var _loc8_;
      while(_loc2_ < this.CompassTargetDataA.length / _loc6_)
      {
         _loc3_ = _loc2_ * _loc6_;
         if(this.CompassMarkerList[_loc2_].movie == undefined)
         {
            _loc5_ = {movie:undefined,heading:0};
            if(this.CompassTargetDataA[_loc3_ + _loc7_] == this.CompassMarkerQuest || this.CompassTargetDataA[_loc3_ + _loc7_] == this.CompassMarkerQuestDoor)
            {
               _loc5_.movie = this.CompassRect.QuestHolder.attachMovie("Compass Marker","CompassMarker" + this.CompassMarkerList.length,this.CompassRect.QuestHolder.getNextHighestDepth());
            }
            else
            {
               _loc5_.movie = this.CompassRect.MarkerHolder.attachMovie("Compass Marker","CompassMarker" + this.CompassMarkerList.length,this.CompassRect.MarkerHolder.getNextHighestDepth());
            }
            this.CompassMarkerList.push(_loc5_);
         }
         else
         {
            _loc4_ = this.CompassMarkerList[_loc2_].movie._currentframe;
            if(_loc4_ == this.CompassMarkerQuest || _loc4_ == this.CompassMarkerQuestDoor)
            {
               if(this.CompassMarkerList[_loc2_].movie._parent == this.CompassRect.MarkerHolder)
               {
                  _loc5_ = {movie:undefined,heading:0};
                  _loc5_.movie = this.CompassRect.QuestHolder.attachMovie("Compass Marker","CompassMarker" + this.CompassMarkerList.length,this.CompassRect.QuestHolder.getNextHighestDepth());
                  _loc8_ = this.CompassMarkerList.splice(_loc2_,1,_loc5_);
                  _loc8_[0].movie.removeMovieClip();
               }
            }
            else if(this.CompassMarkerList[_loc2_].movie._parent == this.CompassRect.QuestHolder)
            {
               _loc5_ = {movie:undefined,heading:0};
               _loc5_.movie = this.CompassRect.MarkerHolder.attachMovie("Compass Marker","CompassMarker" + this.CompassMarkerList.length,this.CompassRect.MarkerHolder.getNextHighestDepth());
               _loc8_ = this.CompassMarkerList.splice(_loc2_,1,_loc5_);
               _loc8_[0].movie.removeMovieClip();
            }
         }
         this.CompassMarkerList[_loc2_].heading = this.CompassTargetDataA[_loc3_ + _loc12_];
         this.CompassMarkerList[_loc2_].movie._alpha = this.CompassTargetDataA[_loc3_ + _loc13_];
         this.CompassMarkerList[_loc2_].movie.gotoAndStop(this.CompassTargetDataA[_loc3_ + _loc7_]);
         this.CompassMarkerList[_loc2_].movie._xscale = this.CompassTargetDataA[_loc3_ + _loc9_];
         this.CompassMarkerList[_loc2_].movie._yscale = this.CompassTargetDataA[_loc3_ + _loc9_];
         _loc2_ = _loc2_ + 1;
      }
   }
   function UpdateCompassMarkers(aiCenterAngle)
   {
      var _loc12_ = this.CompassShoutMeterHolder.Compass.CompassMask_mc._width;
      var _loc9_ = _loc12_ * 180 / Math.abs(this.CompassThreeSixtyX - this.CompassZeroX);
      var _loc5_ = aiCenterAngle - _loc9_;
      var _loc7_ = aiCenterAngle + _loc9_;
      var _loc10_ = - this.CompassRect._x - _loc12_ / 2;
      var _loc11_ = - this.CompassRect._x + _loc12_ / 2;
      var _loc3_ = 0;
      var _loc2_;
      var _loc4_;
      var _loc8_;
      while(_loc3_ < this.CompassMarkerList.length)
      {
         _loc2_ = this.CompassMarkerList[_loc3_].heading;
         if(_loc5_ < 0 && _loc2_ > 360 - aiCenterAngle - _loc9_)
         {
            _loc2_ -= 360;
         }
         if(_loc7_ > 360 && _loc2_ < _loc9_ - (360 - aiCenterAngle))
         {
            _loc2_ += 360;
         }
         if(_loc2_ > _loc5_ && _loc2_ < _loc7_)
         {
            this.CompassMarkerList[_loc3_].movie._x = Shared.GlobalFunc.Lerp(_loc10_,_loc11_,_loc5_,_loc7_,_loc2_);
         }
         else
         {
            _loc4_ = this.CompassMarkerList[_loc3_].movie._currentframe;
            if(_loc4_ == this.CompassMarkerQuest || _loc4_ == this.CompassMarkerQuestDoor)
            {
               _loc8_ = Math.sin((_loc2_ - aiCenterAngle) * 3.141592653589793 / 180);
               this.CompassMarkerList[_loc3_].movie._x = _loc8_ <= 0 ? _loc10_ + 2 : _loc11_;
            }
            else
            {
               this.CompassMarkerList[_loc3_].movie._x = 0;
            }
         }
         _loc3_ = _loc3_ + 1;
      }
   }
   function ShowTutorialHintText(astrHint, abShow)
   {
      var _loc2_;
      if(abShow)
      {
         this.TutorialHintsText.text = astrHint;
         _loc2_ = this.TutorialHintsArtHolder.CreateButtonArt(this.TutorialHintsText);
         if(_loc2_ != undefined)
         {
            this.TutorialHintsText.html = true;
            this.TutorialHintsText.htmlText = _loc2_;
         }
      }
      if(abShow)
      {
         this.TutorialLockInstance.TutorialHintsInstance.gotoAndPlay("FadeIn");
      }
      else
      {
         this.TutorialLockInstance.TutorialHintsInstance.gotoAndPlay("FadeOut");
      }
   }
   function SetCrosshairEnabled(abFlag)
   {
      this.bCrosshairEnabled = abFlag;
      var _loc2_ = this._currentframe != 1 ? this.CrosshairAlert : this.CrosshairInstance;
      _loc2_._alpha = !this.bCrosshairEnabled ? 0 : 100;
   }
   function ValidateCrosshair()
   {
      var _loc2_ = this._currentframe != 1 ? this.CrosshairAlert : this.CrosshairInstance;
      _loc2_._visible = this.CheckAgainstHudMode(_loc2_);
      this.StealthMeterInstance._visible = this.CheckAgainstHudMode(this.StealthMeterInstance);
   }
}
