class JournalBottomBar extends MovieClip
{
   var DateText;
   var LevelMeterRect;
   var LevelMeter_mc;
   var buttonPanel;
   function JournalBottomBar()
   {
      super();
   }
   function InitBar()
   {
      this.LevelMeter_mc = new Components.Meter(this.LevelMeterRect.LevelProgressBar);
      gfx.io.GameDelegate.call("RequestPlayerInfo",[],this,"SetPlayerInfo");
   }
   function SetPlayerInfo()
   {
      this.DateText.SetText(arguments[0]);
      this.LevelMeterRect.LevelNumberLabel.textAutoSize = "shrink";
      this.LevelMeterRect.LevelNumberLabel.SetText(arguments[1]);
      this.LevelMeter_mc.SetPercent(arguments[2]);
   }
   function setPlatform(a_platform, a_bPS3Switch)
   {
      this.buttonPanel.setPlatform(a_platform,a_bPS3Switch);
   }
}
