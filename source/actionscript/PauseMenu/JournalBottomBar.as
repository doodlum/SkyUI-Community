class JournalBottomBar extends MovieClip
{
	var ButtonRect;
	var DateText;
	var LevelMeter_mc;

	public var LevelMeterRect;
	public var buttonPanel;
	public var deleteButton;

	public function JournalBottomBar()
	{
		super();
	}

	public function InitBar()
	{
		this.LevelMeter_mc = new Components.Meter(this.LevelMeterRect.LevelProgressBar);
		gfx.io.GameDelegate.call("RequestPlayerInfo", [], this, "SetPlayerInfo");
	}

	public function SetPlayerInfo()
	{
		this.DateText.SetText(arguments[0]);
		this.LevelMeterRect.LevelNumberLabel.textAutoSize = "shrink";
		this.LevelMeterRect.LevelNumberLabel.SetText(arguments[1]);
		this.LevelMeter_mc.SetPercent(arguments[2]);
	}

	public function setPlatform(a_platform, a_bPS3Switch)
	{
		this.buttonPanel.setPlatform(a_platform, a_bPS3Switch);
	}
}
