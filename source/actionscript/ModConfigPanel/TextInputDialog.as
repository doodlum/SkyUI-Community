class TextInputDialog extends OptionDialog
{
  /* PRIVATE VARIABLES */

    private var _acceptControls: Object;
    private var _cancelControls: Object;


  /* STAGE ELEMENTS */

    public var textInput: MovieClip;


  /* PUBLIC VARIABLES */

    public var initialText: String;


  /* INITIALIZATION */

    public function TextInputDialog()
    {
        super();
    }


  /* PUBLIC FUNCTIONS */

    // @override OptionDialog
    public function initButtons()
    {	
        if (this.platform == 0) {
            this._acceptControls = skyui.defines.Input.Enter;
            this._cancelControls = skyui.defines.Input.Tab;
        } else {
            this._acceptControls = skyui.defines.Input.Accept;
            this._cancelControls = skyui.defines.Input.Cancel;
        }

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
        gfx.managers.FocusHandler.instance.setFocus(this.textInput.textField, 0);
        this.textInput.focused = true;
        Selection.setFocus(this.textInput.textField);
        this.textInput.maxChars = 30;
        this.textInput.text = skyui.util.Translator.translateNested(this.initialText);
        Selection.setSelection(0, 99);
        skse.AllowTextInput(true);
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
            }
            if (details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
                this.onAcceptPress();
                return true;
            }
        }

        // Don't forward to higher level
        return true;
    }


  /* PRIVATE FUNCTIONS */

    private function onAcceptPress()
    {
        skse.AllowTextInput(false);
        skse.SendModEvent("SKICP_inputAccepted", this.textInput.text, 0);
        skyui.util.DialogManager.close();
    }

    private function onCancelPress()
    {
        skse.AllowTextInput(false);
        skse.SendModEvent("SKICP_dialogCanceled");
        skyui.util.DialogManager.close();
    }
}
