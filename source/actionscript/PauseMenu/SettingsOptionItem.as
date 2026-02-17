class SettingsOptionItem extends MovieClip
{
	/* STAGE ELEMENTS */

	var CheckBox_mc;
	var OptionStepper_mc;
	var ScrollBar_mc;
	var checkBox;
	var optionStepper;
	var scrollBar;
	var textField;

	/* PRIVATE VARIABLES */

	var bSendChangeEvent;
	var iID;
	var iMovieType;

	/* CONSTRUCTOR */

	public function SettingsOptionItem()
	{
		super();
		Mouse.addListener(this);
		ScrollBar_mc = scrollBar;
		OptionStepper_mc = optionStepper;
		CheckBox_mc = checkBox;
		bSendChangeEvent = true;
		textField.textAutoSize = "shrink";
	}

	/* PUBLIC FUNCTIONS */

	public function onLoad()
	{
		ScrollBar_mc.setScrollProperties(0.7, 0, 20);
		ScrollBar_mc.addEventListener("scroll", this, "onScroll");
		OptionStepper_mc.addEventListener("change", this, "onStepperChange");
		bSendChangeEvent = true;
	}

	public function get movieType()
	{
		return iMovieType;
	}

	public function set movieType(aiMovieType)
	{
		iMovieType = aiMovieType;

		ScrollBar_mc.disabled = true;
		ScrollBar_mc.visible = false;

		OptionStepper_mc.disabled = true;
		OptionStepper_mc.visible = false;

		CheckBox_mc._visible = false;

		switch (iMovieType) {
			case 0:
				ScrollBar_mc.disabled = false;
				ScrollBar_mc.visible = true;
				break;
			case 1:
				OptionStepper_mc.disabled = false;
				OptionStepper_mc.visible = true;
				break;
			case 2:
				CheckBox_mc._visible = true;
		}
	}

	public function get ID()
	{
		return iID;
	}

	public function set ID(aiNewValue)
	{
		iID = aiNewValue;
	}

	public function get value()
	{
		var iFrameValue;
		switch (iMovieType) {
			case 0:
				iFrameValue = ScrollBar_mc.position / 20;
				break;
			case 1:
				iFrameValue = OptionStepper_mc.selectedIndex;
				break;
			case 2:
				iFrameValue = CheckBox_mc._currentframe - 1;
		}
		return iFrameValue;
	}

	public function set value(afNewValue)
	{
		switch (iMovieType) {
			case 0:
				bSendChangeEvent = false;
				ScrollBar_mc.position = afNewValue * 20;
				bSendChangeEvent = true;
				break;
			case 1:
				bSendChangeEvent = false;
				OptionStepper_mc.selectedIndex = afNewValue;
				bSendChangeEvent = true;
				break;
			case 2:
				CheckBox_mc.gotoAndStop(afNewValue + 1);
		}
	}

	public function get text()
	{
		return textField.text;
	}

	public function set text(astrNew)
	{
		textField.SetText(astrNew);
	}

	public function get selected()
	{
		return textField._alpha == 100;
	}

	public function set selected(abSelected)
	{
		textField._alpha = !abSelected ? 30 : 100;
		ScrollBar_mc._alpha = !abSelected ? 30 : 100;
		OptionStepper_mc._alpha = !abSelected ? 30 : 100;
		CheckBox_mc._alpha = !abSelected ? 30 : 100;
	}

	public function handleInput(details, pathToFocus)
	{
		var bHandledInput = false;
		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			switch (iMovieType) {
				case 0:
					if (details.navEquivalent == gfx.ui.NavigationCode.LEFT) {
						ScrollBar_mc.position -= 1;
						bHandledInput = true;
						break;
					}
					if (details.navEquivalent == gfx.ui.NavigationCode.RIGHT) {
						ScrollBar_mc.position += 1;
						bHandledInput = true;
					}
					break;
				case 1:
					if (details.navEquivalent == gfx.ui.NavigationCode.LEFT || details.navEquivalent == gfx.ui.NavigationCode.RIGHT) {
						bHandledInput = OptionStepper_mc.handleInput(details, pathToFocus);
					}
					break;
				case 2:
					if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
						ToggleCheckbox();
						bHandledInput = true;
					}
			}
		}
		return bHandledInput;
	}

	public function SetOptionStepperOptions(aOptions)
	{
		bSendChangeEvent = false;
		OptionStepper_mc.dataProvider = aOptions;
		bSendChangeEvent = true;
	}

	public function onMousePress()
	{
		var topMostEntity = Mouse.getTopMostEntity();
		switch (iMovieType) {
			case 0:
				if (topMostEntity == ScrollBar_mc.thumb) {
					ScrollBar_mc.thumb.onPress();
				} else if (topMostEntity._parent == ScrollBar_mc.upArrow) {
					ScrollBar_mc.upArrow.onPress();
				} else if (topMostEntity._parent == ScrollBar_mc.downArrow) {
					ScrollBar_mc.downArrow.onPress();
				} else if (topMostEntity == ScrollBar_mc.track) {
					ScrollBar_mc.track.onPress();
				}
				break;
			case 1:
				if (topMostEntity == OptionStepper_mc.nextBtn || topMostEntity == OptionStepper_mc.textField) {
					OptionStepper_mc.nextBtn.onPress();
				} else if (topMostEntity == OptionStepper_mc.prevBtn) {
					OptionStepper_mc.prevBtn.onPress();
				}
			default:
				return;
		}
	}

	public function onRelease()
	{
		var topMostEntity = Mouse.getTopMostEntity();
		switch (iMovieType) {
			case 0:
				if (topMostEntity == ScrollBar_mc.thumb) {
					ScrollBar_mc.thumb.onRelease();
				} else if (topMostEntity._parent == ScrollBar_mc.upArrow) {
					ScrollBar_mc.upArrow.onRelease();
				} else if (topMostEntity._parent == ScrollBar_mc.downArrow) {
					ScrollBar_mc.downArrow.onRelease();
				} else if (topMostEntity == ScrollBar_mc.track) {
					ScrollBar_mc.track.onRelease();
				}
				break;
			case 1:
				if (topMostEntity == OptionStepper_mc.nextBtn || topMostEntity == OptionStepper_mc.textField) {
					OptionStepper_mc.nextBtn.onRelease();
				} else if (topMostEntity == OptionStepper_mc.prevBtn) {
					OptionStepper_mc.prevBtn.onRelease();
				}
				break;
			case 2:
				if (topMostEntity._parent == CheckBox_mc) {
					ToggleCheckbox();
				}
			default:
				return;
		}
	}

	public function ToggleCheckbox()
	{
		if (CheckBox_mc._currentframe == 1) {
			CheckBox_mc.gotoAndStop(2);
		} else if (CheckBox_mc._currentframe == 2) {
			CheckBox_mc.gotoAndStop(1);
		}
		DoOptionChange();
	}

	public function onStepperChange(event)
	{
		if (bSendChangeEvent) {
			DoOptionChange();
		}
	}

	public function onScroll(event)
	{
		if (bSendChangeEvent) {
			DoOptionChange();
		}
	}

	public function DoOptionChange()
	{
		gfx.io.GameDelegate.call("OptionChange", [ID, value]);
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
		_parent.onValueChange(MovieClip(this).itemIndex, value);
	}
}
