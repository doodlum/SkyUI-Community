class SliderDialog extends OptionDialog
{
  /* PRIVATE VARIABLES */

    private var _acceptControls: Object;
    private var _defaultControls: Object;
    private var _cancelControls: Object;
    

  /* STAGE ELEMENTS */

    public var sliderPanel: MovieClip;

    
  /* PROPERTIES */
    
    public var sliderValue: Number;
    public var sliderDefault: Number;
    public var sliderMax: Number;
    public var sliderMin: Number;
    public var sliderInterval: Number;
    public var sliderFormatString: String;

    
  /* INITIALIZATION */

    public function SliderDialog()
    {
        super();
    }
    

  /* PUBLIC FUNCTIONS */

    // @override OptionDialog
    public function initButtons()
    {	
        if (this.platform == 0) {
            this._acceptControls = skyui.defines.Input.Enter;
            this._defaultControls = skyui.defines.Input.ReadyWeapon;
            this._cancelControls = skyui.defines.Input.Tab;
        } else {
            this._acceptControls = skyui.defines.Input.Accept;
            this._defaultControls = skyui.defines.Input.YButton;
            this._cancelControls = skyui.defines.Input.Cancel;
        }
        
        this.leftButtonPanel.clearButtons();
        var defaultButton = this.leftButtonPanel.addButton({text: "$Default", controls: this._defaultControls});
        defaultButton.addEventListener("press", this, "onDefaultPress");
        this.leftButtonPanel.updateButtons();
        
        this.rightButtonPanel.clearButtons();
        var cancelButton = this.rightButtonPanel.addButton({text: "$Cancel", controls: this._cancelControls});
        cancelButton.addEventListener("press", this, "onCancelPress");
        var acceptButton = this.rightButtonPanel.addButton({text: "$Accept", controls: this._acceptControls});
        acceptButton.addEventListener("press", this, "onAcceptPress");
        this.rightButtonPanel.updateButtons();
    }

    // @override OptionDialog
    public function initContent()
    {
        this.sliderPanel.slider.maximum = this.sliderMax;
        this.sliderPanel.slider.minimum = this.sliderMin;
        this.sliderPanel.slider.liveDragging = true;
        this.sliderPanel.slider.snapInterval = this.sliderInterval;
        this.sliderPanel.slider.snapping = true;
        this.sliderPanel.slider.value = this.sliderValue;

        this.sliderFormatString = skyui.util.Translator.translate(this.sliderFormatString);
        this.updateValueText();

        this.sliderPanel.slider.addEventListener("change", this, "onValueChange");

        gfx.managers.FocusHandler.instance.setFocus(this.sliderPanel.slider, 0);
    }
    
    // @GFx
    public function handleInput(details, pathToFocus)
    {
        var nextClip = pathToFocus.shift();
        if (nextClip.handleInput(details, pathToFocus))
            return true;
        
        if (Shared.GlobalFunc.IsKeyPressed(details, false)) {
            if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
                this.onCancelPress();
                return true;
            } else if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
                this.onAcceptPress();
                return true;
            } else if (details.control == this._defaultControls.name) {
                this.onDefaultPress();
                return true;
            }
        }
        
        // Don't forward to higher level
        return true;
    }
    
    
  /* PRIVATE FUNCTIONS */

    private function onValueChange(event: Object)
    {
        this.sliderValue = event.target.value;
        this.updateValueText();
    }
    
    private function onAcceptPress()
    {
        skse.SendModEvent("SKICP_sliderAccepted", null, this.sliderValue);
        skyui.util.DialogManager.close();
    }
    
    private function onDefaultPress()
    {
        this.sliderValue = this.sliderPanel.slider.value = this.sliderDefault;
        this.updateValueText();
    }

    private function onCancelPress()
    {
        skse.SendModEvent("SKICP_dialogCanceled");
        skyui.util.DialogManager.close();
    }

    private function updateValueText()
    {
        var t = this.sliderFormatString	? skyui.util.GlobalFunctions.formatString(this.sliderFormatString, this.sliderValue)
                                    : Math.round(this.sliderValue * 100) / 100;
        this.sliderPanel.valueTextField.SetText(t);
    }
}
