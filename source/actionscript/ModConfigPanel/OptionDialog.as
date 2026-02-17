// @abstract
class OptionDialog extends skyui.components.dialog.BasicDialog
{
	/* STAGE ELEMENTS */

	public var leftButtonPanel;
	public var rightButtonPanel;

	public var titleTextField;


	/* PROPERTIES */

	public var platform;

	public var titleText;


	/* INITIALIZATION */

	public function OptionDialog()
	{
		super();
	}

	// @override MovieClip
	private function onLoad()
	{
		this.leftButtonPanel.setPlatform(this.platform,false);
		this.rightButtonPanel.setPlatform(this.platform,false);
		this.initButtons();
		this.titleTextField.textAutoSize = "shrink";
		this.titleText = skyui.util.Translator.translate(this.titleText);
		this.titleTextField.SetText(this.titleText.toUpperCase());
		this.initContent();
	}


	/* PUBLIC FUNCTIONS */

	// @abstract
	public function initButtons() {}

	// @abstract
	public function initContent() {}
}
