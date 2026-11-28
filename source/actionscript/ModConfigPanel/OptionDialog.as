// @abstract
class OptionDialog extends skyui.components.dialog.BasicDialog
{	
/* PRIVATE VARIABLES */

    private var _updateButtonID: Number;
    

/* STAGE ELEMENTS */

    public var background: MovieClip;
    public var leftButtonPanel: ButtonPanel;
    public var rightButtonPanel: ButtonPanel;
    
    public var titleTextField: TextField;

    
/* PROPERTIES */

    public var platform: Number;
    
    public var titleText: String;
    
    
/* INITIALIZATION */

    public function OptionDialog()
    {
        super();
    }
    
    // @override MovieClip
    private function onLoad()
    {
        this.leftButtonPanel.setPlatform(this.platform, false);
        this.rightButtonPanel.setPlatform(this.platform, false);
        
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
