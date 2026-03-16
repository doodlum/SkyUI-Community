class LockpickingMenu extends MovieClip
{
   var BottomBar_mc;
   var ButtonRect_mc;
   var DebugDisplay_mc;
   var InfoRect_mc;
   var LockAngleText;
   var PickAngleText;
   var PickIndicator_mc;
   var SkillMeter;
   var SweetSpotHolder_mc;
   var fPickMaxAngle;
   var fPickMinAngle;
   var iDebugRectBaseWidth;
   function LockpickingMenu()
   {
      super();
      this.PickAngleText = this.DebugDisplay_mc.PickAngleText;
      this.LockAngleText = this.DebugDisplay_mc.LockAngleText;
      this.PickIndicator_mc = this.DebugDisplay_mc.PickIndicator_mc;
      this.SweetSpotHolder_mc = this.DebugDisplay_mc.SweetSpotRects_mc;
      this.iDebugRectBaseWidth = 1000;
      this.ButtonRect_mc = this.BottomBar_mc.ButtonRect_mc;
      this.InfoRect_mc = this.BottomBar_mc.InfoRect_mc;
      this.SkillMeter = new Components.Meter(this.BottomBar_mc.InfoRect_mc.LevelMeterInstance.Meter_mc);
      this.fPickMinAngle = 0;
      this.fPickMaxAngle = 0;
   }
   function InitExtensions()
   {
      Stage.scaleMode = "showAll";
      Shared.GlobalFunc.SetLockFunction();
      this.BottomBar_mc.Lock("B");
      this.InfoRect_mc.Lock("R");
      this.ButtonRect_mc.Lock("L");
      gfx.io.GameDelegate.addCallBack("UpdatePickAngle",this,"UpdatePickAngle");
      gfx.io.GameDelegate.addCallBack("UpdateLockAngle",this,"UpdateLockAngle");
      gfx.io.GameDelegate.addCallBack("UpdateSweetSpot",this,"UpdateSweetSpot");
      gfx.io.GameDelegate.addCallBack("UpdatePickHealth",this,"UpdatePickHealth");
      gfx.io.GameDelegate.addCallBack("SetLockInfo",this,"SetLockInfo");
      gfx.io.GameDelegate.addCallBack("SetPickMinMax",this,"SetPickMinMax");
      gfx.io.GameDelegate.addCallBack("ToggleDebugMode",this,"ToggleDebugMode");
      this.DebugDisplay_mc._visible = false;
      this.BottomBar_mc._visible = false;
      this.InfoRect_mc.LockLevelText.textAutoSize = "shrink";
      this.InfoRect_mc.NumLockpicksText.textAutoSize = "shrink";
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      var _loc2_ = 20;
      this.ButtonRect_mc.RotatePickButton.SetPlatform(aiPlatform,abPS3Switch);
      this.ButtonRect_mc.RotateLockButton.SetPlatform(aiPlatform,abPS3Switch);
      this.ButtonRect_mc.ExitButton.SetPlatform(aiPlatform,abPS3Switch);
      this.ButtonRect_mc.RotateLockButton._x = this.ButtonRect_mc.RotatePickButton._x + this.ButtonRect_mc.RotatePickButton.textField.getLineMetrics(0).width + _loc2_ + this.ButtonRect_mc.RotateLockButton.ButtonArt._width;
      this.ButtonRect_mc.ExitButton._x = this.ButtonRect_mc.RotateLockButton._x + this.ButtonRect_mc.RotateLockButton.textField.getLineMetrics(0).width + _loc2_ + this.ButtonRect_mc.ExitButton.ButtonArt._width;
   }
   function ToggleDebugMode()
   {
      this.DebugDisplay_mc._visible = !this.DebugDisplay_mc._visible;
   }
   function UpdatePickAngle(afAngle)
   {
      this.PickAngleText.SetText("PICK ANGLE: " + Math.floor(afAngle) + "°");
      this.PickIndicator_mc._x = this.PickAngleToX(afAngle);
   }
   function PickAngleToX(afAngle)
   {
      var _loc2_ = (afAngle - this.fPickMinAngle) / (this.fPickMaxAngle - this.fPickMinAngle);
      return this.SweetSpotHolder_mc._x + this.iDebugRectBaseWidth * _loc2_;
   }
   function UpdateLockAngle(afAngle)
   {
      this.LockAngleText.SetText("LOCK ANGLE: " + Math.floor(afAngle) + "°");
   }
   function UpdatePickHealth(afHealth)
   {
      this.DebugDisplay_mc.PickHealthText.SetText("PICK HEALTH: " + Math.floor(afHealth) + "%");
   }
   function UpdateSweetSpot(afSweetSpotCenter, afSweetSpotLength, afPartialPickLength)
   {
      this.SweetSpotHolder_mc.SweetSpotRect._x = this.PickAngleToX(afSweetSpotCenter - afSweetSpotLength / 2);
      this.SweetSpotHolder_mc.SweetSpotRect._width = this.PickAngleToX(afSweetSpotCenter + afSweetSpotLength / 2) - this.SweetSpotHolder_mc.SweetSpotRect._x;
      this.SweetSpotHolder_mc.PartialPickRect._x = this.PickAngleToX(afSweetSpotCenter - afSweetSpotLength / 2 - afPartialPickLength);
      this.SweetSpotHolder_mc.PartialPickRect._width = this.PickAngleToX(afSweetSpotCenter + afSweetSpotLength / 2 + afPartialPickLength) - this.SweetSpotHolder_mc.PartialPickRect._x;
      this.DebugDisplay_mc.SweetSpotText.SetText("SWEET SPOT: " + afSweetSpotLength + "°");
      this.DebugDisplay_mc.PartialPickText.SetText("PARTIAL PICK: " + afPartialPickLength + "°");
   }
   function SetPickMinMax(afPickMinAngle, afPickMaxAngle)
   {
      this.fPickMinAngle = afPickMinAngle;
      this.fPickMaxAngle = afPickMaxAngle;
   }
   function SetLockInfo()
   {
      this.InfoRect_mc.SkillLevelCurrent.SetText(arguments[0]);
      this.InfoRect_mc.SkillLevelNext.SetText(arguments[1]);
      this.InfoRect_mc.LevelMeterInstance.gotoAndStop("Pause");
      this.SkillMeter.SetPercent(arguments[2]);
      var _loc4_ = this.InfoRect_mc.LockLevelText;
      _loc4_.SetText("$Lock Level");
      _loc4_.SetText(_loc4_.text + ": " + arguments[3]);
      var _loc3_ = this.InfoRect_mc.NumLockpicksText;
      _loc3_.SetText("$Lockpicks Left");
      if(arguments[4] < 99)
      {
         _loc3_.SetText(_loc3_.text + ": " + arguments[4]);
      }
      else
      {
         _loc3_.SetText(_loc3_.text + ": 99+");
      }
      this.BottomBar_mc._visible = true;
   }
}
