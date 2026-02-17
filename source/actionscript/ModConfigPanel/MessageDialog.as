class MessageDialog extends OptionDialog
{
	/* PRIVATE VARIABLES */

	private var _acceptControls;
	private var _cancelControls;

	private var _bWithCancel = true;


	/* STAGE ELEMENTS */

	public var background;
	public var buttonPanel;

	public var textField;

	public var seperator;


	/* PROPERTIES */

	public var messageText;
	public var acceptLabel;
	public var cancelLabel;


	/* INITIALIZATION */

	public function MessageDialog()
	{
		super();
	}

	// @override MovieClip
	private function onLoad()
	{
		this.buttonPanel.setPlatform(this.platform,false);
		this._bWithCancel = this.cancelLabel != "";
		this.initButtons();
		this.textField.wordWrap = true;
		this.messageText = skyui.util.Translator.translateNested(this.messageText);
		this.textField.SetText(skyui.util.GlobalFunctions.unescape(this.messageText));
		this.textField.verticalAutoSize = "top";
		this.positionElements();
	}


	/* PUBLIC FUNCTIONS */

	public function initButtons()
	{
		if(this.platform == 0)
		{
			this._acceptControls = skyui.defines.Input.Enter;
			this._cancelControls = skyui.defines.Input.Tab;
		}
		else
		{
			this._acceptControls = skyui.defines.Input.Accept;
			this._cancelControls = skyui.defines.Input.Cancel;
		}

		this.buttonPanel.clearButtons();
		var cancelButton;
		if(this._bWithCancel)
		{
			var cancelButton = buttonPanel.addButton({text: cancelLabel, controls: _cancelControls});
			cancelButton.addEventListener("press",this,"onCancelPress");
		}
		var acceptButton = buttonPanel.addButton({text: acceptLabel, controls: _acceptControls});
		acceptButton.addEventListener("press",this,"onAcceptPress");
		this.buttonPanel.updateButtons();
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		var nextClip = pathToFocus.shift();
		if(nextClip.handleInput(details,pathToFocus))
		{
			return true;
		}

		if(Shared.GlobalFunc.IsKeyPressed(details,false))
		{
			if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
			{
				if(this._bWithCancel)
				{
					this.onCancelPress();
				}
				else
				{
					this.onAcceptPress();
				}
				return true;
			}
			if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
			{
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
		skse.SendModEvent("SKICP_messageDialogClosed",null,1);
		skyui.util.DialogManager.close();
	}

	private function onCancelPress()
	{
		skse.SendModEvent("SKICP_messageDialogClosed",null,0);
		skyui.util.DialogManager.close();
	}

	private function positionElements()
	{
		var contentHeight = Math.max(75,this.textField.textHeight);
		this.background._height = contentHeight + 78;
		var yOffset = - this.background._height / 2;
		this.seperator._y = yOffset + this.background._height - 50;
		this.buttonPanel._y = yOffset + this.background._height - 42;
		this.textField._y = yOffset + 14 + (contentHeight - this.textField.textHeight) / 2;
	}
}
