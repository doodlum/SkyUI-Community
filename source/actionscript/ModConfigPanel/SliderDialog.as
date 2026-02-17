class SliderDialog extends OptionDialog
{
	/* PRIVATE VARIABLES */

	private var _acceptControls;
	private var _defaultControls;
	private var _cancelControls;


	/* STAGE ELEMENTS */

	public var sliderPanel;


	/* PROPERTIES */

	public var sliderValue;
	public var sliderDefault;
	public var sliderMax;
	public var sliderMin;
	public var sliderInterval;
	public var sliderFormatString;


	/* INITIALIZATION */

	public function SliderDialog()
	{
		super();
	}


	/* PUBLIC FUNCTIONS */

	// @override OptionDialog
	public function initButtons()
	{
		if (platform == 0) {
			_acceptControls = skyui.defines.Input.Enter;
			_defaultControls = skyui.defines.Input.ReadyWeapon;
			_cancelControls = skyui.defines.Input.Tab;
		} else {
			_acceptControls = skyui.defines.Input.Accept;
			_defaultControls = skyui.defines.Input.YButton;
			_cancelControls = skyui.defines.Input.Cancel;
		}

		leftButtonPanel.clearButtons();
		var defaultButton = leftButtonPanel.addButton({text: "$Default", controls: _defaultControls});
		defaultButton.addEventListener("press", this, "onDefaultPress");
		leftButtonPanel.updateButtons();

		rightButtonPanel.clearButtons();
		var cancelButton = rightButtonPanel.addButton({text: "$Cancel", controls: _cancelControls});
		cancelButton.addEventListener("press", this, "onCancelPress");
		var acceptButton = rightButtonPanel.addButton({text: "$Accept", controls: _acceptControls});
		acceptButton.addEventListener("press", this, "onAcceptPress");
		rightButtonPanel.updateButtons();
	}

	// @override OptionDialog
	public function initContent()
	{
		sliderPanel.slider.maximum = sliderMax;
		sliderPanel.slider.minimum = sliderMin;
		sliderPanel.slider.liveDragging = true;
		sliderPanel.slider.snapInterval = sliderInterval;
		sliderPanel.slider.snapping = true;
		sliderPanel.slider.value = sliderValue;

		sliderFormatString = skyui.util.Translator.translate(sliderFormatString);
		updateValueText();

		sliderPanel.slider.addEventListener("change", this, "onValueChange");

		gfx.managers.FocusHandler.instance.setFocus(sliderPanel.slider, 0);
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;

		if (Shared.GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
				onCancelPress();
				return true;
			} else if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
				onAcceptPress();
				return true;
			} else if (details.control == _defaultControls.name) {
				onDefaultPress();
				return true;
			}
		}

		// Don't forward to higher level
		return true;
	}


	/* PRIVATE FUNCTIONS */

	private function onValueChange(event)
	{
		sliderValue = event.target.value;
		updateValueText();
	}

	private function onAcceptPress()
	{
		skse.SendModEvent("SKICP_sliderAccepted", null, sliderValue);
		skyui.util.DialogManager.close();
	}

	private function onDefaultPress()
	{
		sliderValue = sliderPanel.slider.value = sliderDefault;
		updateValueText();
	}

	private function onCancelPress()
	{
		skse.SendModEvent("SKICP_dialogCanceled");
		skyui.util.DialogManager.close();
	}

	private function updateValueText()
	{
		var t = !sliderFormatString ? Math.round(sliderValue * 100) / 100 : skyui.util.GlobalFunctions.formatString(sliderFormatString, sliderValue);
		sliderPanel.valueTextField.SetText(t);
	}
}
