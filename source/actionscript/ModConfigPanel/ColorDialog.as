class ColorDialog extends OptionDialog
{
	/* PRIVATE VARIABLES */

	private var _defaultControls;


	/* STAGE ELEMENTS */

	public var colorSwatch;


	/* PROPERTIES */

	public var currentColor;
	public var defaultColor;


	/* INITIALIZATION */

	public function ColorDialog()
	{
		super();
	}


	/* PUBLIC FUNCTIONS */

	// @override OptionDialog
	private function initButtons()
	{
		var acceptControls;
		var cancelControls;

		if(this.platform == 0)
		{
			acceptControls = skyui.defines.Input.Enter;
			this._defaultControls = skyui.defines.Input.ReadyWeapon;
			cancelControls = skyui.defines.Input.Tab;
		}
		else
		{
			acceptControls = skyui.defines.Input.Accept;
			this._defaultControls = skyui.defines.Input.YButton;
			cancelControls = skyui.defines.Input.Cancel;
		}

		this.leftButtonPanel.clearButtons();
		var defaultButton = this.leftButtonPanel.addButton({text:"$Default", controls:this._defaultControls});
		defaultButton.addEventListener("press",this,"onDefaultPress");
		this.leftButtonPanel.updateButtons();

		this.rightButtonPanel.clearButtons();
		var cancelButton = this.rightButtonPanel.addButton({text:"$Cancel", controls:cancelControls});
		cancelButton.addEventListener("press",this,"onCancelPress");
		var acceptButton = this.rightButtonPanel.addButton({text:"$Accept", controls:acceptControls});
		acceptButton.addEventListener("press",this,"onAcceptPress");
		this.rightButtonPanel.updateButtons();
	}

	// @override OptionDialog
	public function initContent()
	{
		this.colorSwatch._x = (- this.colorSwatch._width) / 2;
		this.colorSwatch._y = (- this.colorSwatch._height) / 2;
		this.colorSwatch.selectedColor = this.currentColor;
		gfx.managers.FocusHandler.instance.setFocus(this.colorSwatch,0);
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
				this.onCancelPress();
				return true;
			}
			if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
			{
				this.onAcceptPress();
				return true;
			}
			if(details.control == this._defaultControls.name)
			{
				this.onDefaultPress();
				return true;
			}
		}

		// Don't forward to higher level
		return true;
	}


	/* PRIVATE FUNCTIONS */

	private function onAcceptPress()
	{
		skse.SendModEvent("SKICP_colorAccepted",null,this.colorSwatch.selectedColor);
		skyui.util.DialogManager.close();
	}

	private function onDefaultPress()
	{
		this.colorSwatch.selectedColor = this.defaultColor;
	}

	private function onCancelPress()
	{
		skse.SendModEvent("SKICP_dialogCanceled");
		skyui.util.DialogManager.close();
	}
}
