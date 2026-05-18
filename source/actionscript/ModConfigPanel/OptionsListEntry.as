class OptionsListEntry extends skyui.components.list.BasicListEntry
{
  /* CONSTANTS */
    
    // 1 byte
    public static var OPTION_EMPTY = 0x00;
    public static var OPTION_HEADER = 0x01;
    public static var OPTION_TEXT = 0x02;
    public static var OPTION_TOGGLE = 0x03;
    public static var OPTION_SLIDER = 0x04;
    public static var OPTION_MENU = 0x05;
    public static var OPTION_COLOR = 0x06;
    public static var OPTION_KEYMAP = 0x07;
    public static var OPTION_INPUT = 0x08;
    
    // 1 byte
    public static var FLAG_DISABLED = 0x01;
    public static var FLAG_HIDDEN = 0x02;
    public static var FLAG_WITH_UNMAP = 0x04;
    
    public static var ALPHA_SELECTED = 100;
    public static var ALPHA_ACTIVE = 75;

    public static var ALPHA_ENABLED = 100;
    public static var ALPHA_DISABLED = 50;
    
    
  /* STAGE ELMENTS */

    public var selectIndicator: MovieClip;

    public var labelTextField: TextField;
    public var valueTextField: TextField;
    
    public var headerDecor: MovieClip;
    public var sliderIcon: MovieClip;
    public var menuIcon: MovieClip;
    public var toggleIcon: MovieClip;
    public var colorIcon: MovieClip;
    public var buttonArt: MovieClip;
    
    
  /* PROPERTIES */
    
    public function get width()
    {
        return this.background._width;
    }

    public function set width(a_val: Number)
    {
        this.background._width = a_val;
        this.selectIndicator._width = a_val;
    }
    
    
  /* PUBLIC FUNCTIONS */

    public function OptionsListEntry()
    {
        super();
    }
    
    public function initialize(a_index: Number, a_list: ScrollingList)
    {
        this.gotoAndStop("empty");
    }
    
    public function setEntry(a_entryObject: Object, a_state: ListState)
    {
        var entryWidth = this.background._width;
        var isSelected = a_entryObject == a_state.list.selectedEntry;

        var flags = a_entryObject.flags;
        var isEnabled = !(flags & (OptionsListEntry.FLAG_DISABLED | OptionsListEntry.FLAG_HIDDEN));
        
        this.selectIndicator._visible = isSelected;
        
        this._alpha = isEnabled ? OptionsListEntry.ALPHA_ENABLED : OptionsListEntry.ALPHA_DISABLED;
        
        // If entry is hidden, treat like empty option
        var optionType = a_entryObject.optionType;
        if (flags & OptionsListEntry.FLAG_HIDDEN)
            optionType = OptionsListEntry.OPTION_EMPTY;
        
        switch (optionType) {
            
            case OptionsListEntry.OPTION_HEADER:
                this.enabled = false;
                this.gotoAndStop("header");
                
                this.labelTextField._width = entryWidth;
                this.labelTextField.SetText(a_entryObject.text, true);
                this.labelTextField._alpha = 100;

                this.headerDecor._x = this.labelTextField.getLineMetrics(0).width + 10;
                this.headerDecor._width = entryWidth - this.headerDecor._x;
                
                break;
                
            case OptionsListEntry.OPTION_TEXT:
                this.enabled = isEnabled;
                this.gotoAndStop("text");
                
                this.labelTextField._width = entryWidth;
                this.labelTextField.SetText(a_entryObject.text, true);
                this.labelTextField._alpha = isSelected ? OptionsListEntry.ALPHA_SELECTED : OptionsListEntry.ALPHA_ACTIVE;
                
                this.valueTextField._width = entryWidth;
                this.valueTextField.SetText(skyui.util.Translator.translateNested(a_entryObject.strValue).toUpperCase(), true);
                
                break;
                
            case OptionsListEntry.OPTION_TOGGLE:
                this.enabled = isEnabled;
                this.gotoAndStop("toggle");
                
                this.labelTextField._width = entryWidth;
                this.labelTextField.SetText(a_entryObject.text, true);
                this.labelTextField._alpha = isSelected ? OptionsListEntry.ALPHA_SELECTED : OptionsListEntry.ALPHA_ACTIVE;
                
                this.toggleIcon._x = entryWidth - this.toggleIcon._width;
                this.toggleIcon.gotoAndStop(a_entryObject.numValue? "on" : "off");
                
                break;
                
            case OptionsListEntry.OPTION_SLIDER:
                this.enabled = isEnabled;
                this.gotoAndStop("slider");
                
                this.labelTextField._width = entryWidth;
                this.labelTextField.SetText(a_entryObject.text, true);
                this.labelTextField._alpha = isSelected ? OptionsListEntry.ALPHA_SELECTED : OptionsListEntry.ALPHA_ACTIVE;
                
                this.valueTextField._width = entryWidth;
                this.valueTextField.SetText(skyui.util.GlobalFunctions.formatString(skyui.util.Translator.translate(a_entryObject.strValue), a_entryObject.numValue).toUpperCase(), true);
            
                this.sliderIcon._x = this.valueTextField.getLineMetrics(0).x - this.sliderIcon._width;
                
                break;
                
            case OptionsListEntry.OPTION_MENU:
                this.enabled = isEnabled;
                this.gotoAndStop("menu");
                
                this.labelTextField._width = entryWidth;
                this.labelTextField.SetText(a_entryObject.text, true);
                this.labelTextField._alpha = isSelected ? OptionsListEntry.ALPHA_SELECTED : OptionsListEntry.ALPHA_ACTIVE;
                
                this.valueTextField._width = entryWidth;
                this.valueTextField.SetText(skyui.util.Translator.translateNested(a_entryObject.strValue).toUpperCase(), true);
                
                this.menuIcon._x = this.valueTextField.getLineMetrics(0).x - this.menuIcon._width;
                
                break;

            case OptionsListEntry.OPTION_COLOR:
                this.enabled = isEnabled;
                this.gotoAndStop("color");
                
                this.labelTextField._width = entryWidth;
                this.labelTextField.SetText(a_entryObject.text, true);
                this.labelTextField._alpha = isSelected ? OptionsListEntry.ALPHA_SELECTED : OptionsListEntry.ALPHA_ACTIVE;
                
                this.colorIcon._x = entryWidth - this.colorIcon._width;

                var color: Color = new Color(this.colorIcon.pigment);
                color.setRGB(a_entryObject.numValue);
                
                break;
                
            case OptionsListEntry.OPTION_KEYMAP:
                this.enabled = isEnabled;
                this.gotoAndStop("keymap");
                
                this.labelTextField._width = entryWidth;
                this.labelTextField.SetText(a_entryObject.text, true);
                this.labelTextField._alpha = isSelected ? OptionsListEntry.ALPHA_SELECTED : OptionsListEntry.ALPHA_ACTIVE;
                
                var keyCode = a_entryObject.numValue;
                if (keyCode == -1)
                    keyCode = 282; // "???"
                this.buttonArt.gotoAndStop(keyCode);
                this.buttonArt._x = entryWidth - this.buttonArt._width;
                
                break;
            case OptionsListEntry.OPTION_INPUT:
                this.enabled = isEnabled;
                this.gotoAndStop("input");
                
                this.labelTextField._width = entryWidth;
                this.labelTextField.SetText(a_entryObject.text, true);
                this.labelTextField._alpha = isSelected ? OptionsListEntry.ALPHA_SELECTED : OptionsListEntry.ALPHA_ACTIVE;
                
                this.valueTextField._width = entryWidth;
                this.valueTextField.SetText(a_entryObject.strValue, true);
                this.valueTextField.SetText(skyui.util.Translator.translateNested(a_entryObject.strValue).toUpperCase(), true);
                
                this.inputIcon._x = this.valueTextField.getLineMetrics(0).x - this.inputIcon._width - 3;
                
                break;
                
            case OptionsListEntry.OPTION_EMPTY:
            default:
                this.enabled = false;
                this.gotoAndStop("empty");
        }
    }
}
