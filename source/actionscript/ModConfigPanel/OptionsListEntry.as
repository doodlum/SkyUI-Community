class OptionsListEntry extends skyui.components.list.BasicListEntry
{
   var _alpha;
   var background;
   var buttonArt;
   var colorIcon;
   var enabled;
   var gotoAndStop;
   var headerDecor;
   var inputIcon;
   var labelTextField;
   var menuIcon;
   var selectIndicator;
   var sliderIcon;
   var toggleIcon;
   var valueTextField;
   static var OPTION_EMPTY = 0;
   static var OPTION_HEADER = 1;
   static var OPTION_TEXT = 2;
   static var OPTION_TOGGLE = 3;
   static var OPTION_SLIDER = 4;
   static var OPTION_MENU = 5;
   static var OPTION_COLOR = 6;
   static var OPTION_KEYMAP = 7;
   static var OPTION_INPUT = 8;
   static var FLAG_DISABLED = 1;
   static var FLAG_HIDDEN = 2;
   static var FLAG_WITH_UNMAP = 4;
   static var ALPHA_SELECTED = 100;
   static var ALPHA_ACTIVE = 75;
   static var ALPHA_ENABLED = 100;
   static var ALPHA_DISABLED = 50;
   function OptionsListEntry()
   {
      super();
   }
   function get width()
   {
      return this.background._width;
   }
   function set width(a_val)
   {
      this.background._width = a_val;
      this.selectIndicator._width = a_val;
   }
   function initialize(a_index, a_list)
   {
      this.gotoAndStop("empty");
   }
   function setEntry(a_entryObject, a_state)
   {
      var _loc3_ = this.background._width;
      var _loc5_ = a_entryObject == a_state.list.selectedEntry;
      var _loc8_ = a_entryObject.flags;
      var _loc4_ = !(_loc8_ & (OptionsListEntry.FLAG_DISABLED | OptionsListEntry.FLAG_HIDDEN));
      this.selectIndicator._visible = _loc5_;
      this._alpha = !_loc4_ ? OptionsListEntry.ALPHA_DISABLED : OptionsListEntry.ALPHA_ENABLED;
      var _loc7_ = a_entryObject.optionType;
      if(_loc8_ & OptionsListEntry.FLAG_HIDDEN)
      {
         _loc7_ = OptionsListEntry.OPTION_EMPTY;
      }
      var _loc9_;
      var _loc6_;
      switch(_loc7_)
      {
         case OptionsListEntry.OPTION_HEADER:
            this.enabled = false;
            this.gotoAndStop("header");
            this.labelTextField._width = _loc3_;
            this.labelTextField.SetText(a_entryObject.text,true);
            this.labelTextField._alpha = 100;
            this.headerDecor._x = this.labelTextField.getLineMetrics(0).width + 10;
            this.headerDecor._width = _loc3_ - this.headerDecor._x;
            return;
         case OptionsListEntry.OPTION_TEXT:
            this.enabled = _loc4_;
            this.gotoAndStop("text");
            this.labelTextField._width = _loc3_;
            this.labelTextField.SetText(a_entryObject.text,true);
            this.labelTextField._alpha = !_loc5_ ? OptionsListEntry.ALPHA_ACTIVE : OptionsListEntry.ALPHA_SELECTED;
            this.valueTextField._width = _loc3_;
            this.valueTextField.SetText(skyui.util.Translator.translateNested(a_entryObject.strValue).toUpperCase(),true);
            return;
         case OptionsListEntry.OPTION_TOGGLE:
            this.enabled = _loc4_;
            this.gotoAndStop("toggle");
            this.labelTextField._width = _loc3_;
            this.labelTextField.SetText(a_entryObject.text,true);
            this.labelTextField._alpha = !_loc5_ ? OptionsListEntry.ALPHA_ACTIVE : OptionsListEntry.ALPHA_SELECTED;
            this.toggleIcon._x = _loc3_ - this.toggleIcon._width;
            this.toggleIcon.gotoAndStop(!a_entryObject.numValue ? "off" : "on");
            return;
         case OptionsListEntry.OPTION_SLIDER:
            this.enabled = _loc4_;
            this.gotoAndStop("slider");
            this.labelTextField._width = _loc3_;
            this.labelTextField.SetText(a_entryObject.text,true);
            this.labelTextField._alpha = !_loc5_ ? OptionsListEntry.ALPHA_ACTIVE : OptionsListEntry.ALPHA_SELECTED;
            this.valueTextField._width = _loc3_;
            this.valueTextField.SetText(skyui.util.GlobalFunctions.formatString(skyui.util.Translator.translate(a_entryObject.strValue),a_entryObject.numValue).toUpperCase(),true);
            this.sliderIcon._x = this.valueTextField.getLineMetrics(0).x - this.sliderIcon._width;
            return;
         case OptionsListEntry.OPTION_MENU:
            this.enabled = _loc4_;
            this.gotoAndStop("menu");
            this.labelTextField._width = _loc3_;
            this.labelTextField.SetText(a_entryObject.text,true);
            this.labelTextField._alpha = !_loc5_ ? OptionsListEntry.ALPHA_ACTIVE : OptionsListEntry.ALPHA_SELECTED;
            this.valueTextField._width = _loc3_;
            this.valueTextField.SetText(skyui.util.Translator.translateNested(a_entryObject.strValue).toUpperCase(),true);
            this.menuIcon._x = this.valueTextField.getLineMetrics(0).x - this.menuIcon._width;
            return;
         case OptionsListEntry.OPTION_COLOR:
            this.enabled = _loc4_;
            this.gotoAndStop("color");
            this.labelTextField._width = _loc3_;
            this.labelTextField.SetText(a_entryObject.text,true);
            this.labelTextField._alpha = !_loc5_ ? OptionsListEntry.ALPHA_ACTIVE : OptionsListEntry.ALPHA_SELECTED;
            this.colorIcon._x = _loc3_ - this.colorIcon._width;
            _loc9_ = new Color(this.colorIcon.pigment);
            _loc9_.setRGB(a_entryObject.numValue);
            return;
         case OptionsListEntry.OPTION_KEYMAP:
            this.enabled = _loc4_;
            this.gotoAndStop("keymap");
            this.labelTextField._width = _loc3_;
            this.labelTextField.SetText(a_entryObject.text,true);
            this.labelTextField._alpha = !_loc5_ ? OptionsListEntry.ALPHA_ACTIVE : OptionsListEntry.ALPHA_SELECTED;
            _loc6_ = a_entryObject.numValue;
            if(_loc6_ == -1)
            {
               _loc6_ = 282;
            }
            this.buttonArt.gotoAndStop(_loc6_);
            this.buttonArt._x = _loc3_ - this.buttonArt._width;
            return;
         case OptionsListEntry.OPTION_INPUT:
            this.enabled = _loc4_;
            this.gotoAndStop("input");
            this.labelTextField._width = _loc3_;
            this.labelTextField.SetText(a_entryObject.text,true);
            this.labelTextField._alpha = !_loc5_ ? OptionsListEntry.ALPHA_ACTIVE : OptionsListEntry.ALPHA_SELECTED;
            this.valueTextField._width = _loc3_;
            this.valueTextField.SetText(a_entryObject.strValue,true);
            this.valueTextField.SetText(skyui.util.Translator.translateNested(a_entryObject.strValue).toUpperCase(),true);
            this.inputIcon._x = this.valueTextField.getLineMetrics(0).x - this.inputIcon._width - 3;
            return;
         case OptionsListEntry.OPTION_EMPTY:
         default:
            this.enabled = false;
            this.gotoAndStop("empty");
            return;
      }
   }
}
