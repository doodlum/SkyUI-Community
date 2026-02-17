class OptionsListEntry extends skyui.components.list.BasicListEntry
{
	/* CONSTANTS */

	// 1 byte
	public static var OPTION_EMPTY = 0;
	public static var OPTION_HEADER = 1;
	public static var OPTION_TEXT = 2;
	public static var OPTION_TOGGLE = 3;
	public static var OPTION_SLIDER = 4;
	public static var OPTION_MENU = 5;
	public static var OPTION_COLOR = 6;
	public static var OPTION_KEYMAP = 7;
	public static var OPTION_INPUT = 8;

	// 1 byte
	public static var FLAG_DISABLED = 1;
	public static var FLAG_HIDDEN = 2;
	public static var FLAG_WITH_UNMAP = 4;

	public static var ALPHA_SELECTED = 100;
	public static var ALPHA_ACTIVE = 75;

	public static var ALPHA_ENABLED = 100;
	public static var ALPHA_DISABLED = 50;


	/* STAGE ELEMENTS */

	public var selectIndicator;

	public var labelTextField;
	public var valueTextField;

	public var headerDecor;
	public var sliderIcon;
	public var menuIcon;
	public var toggleIcon;
	public var colorIcon;
	public var buttonArt;
	public var inputIcon;


	/* PROPERTIES */

	public function get width()
	{
		return background._width;
	}

	public function set width(a_val)
	{
		background._width = a_val;
		selectIndicator._width = a_val;
	}


	/* INITIALIZATION */

	public function OptionsListEntry()
	{
		super();
	}


	/* PUBLIC FUNCTIONS */

	public function initialize(a_index, a_list)
	{
		gotoAndStop("empty");
	}

	public function setEntry(a_entryObject, a_state)
	{
		var entryWidth = background._width;
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		var flags = a_entryObject.flags;
		var isEnabled = !(flags & (FLAG_DISABLED | FLAG_HIDDEN));

		selectIndicator._visible = isSelected;

		_alpha = isEnabled ? ALPHA_ENABLED : ALPHA_DISABLED;

		// If entry is hidden, treat like empty option
		var optionType = a_entryObject.optionType;
		if (flags & FLAG_HIDDEN)
			optionType = OPTION_EMPTY;

		var color;
		var keyCode;
		switch (optionType) {
			case OPTION_HEADER:
				enabled = false;
				gotoAndStop("header");

				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = 100;

				headerDecor._x = labelTextField.getLineMetrics(0).width + 10;
				headerDecor._width = entryWidth - headerDecor._x;
				return;

			case OPTION_TEXT:
				enabled = isEnabled;
				gotoAndStop("text");

				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;

				valueTextField._width = entryWidth;
				valueTextField.SetText(skyui.util.Translator.translateNested(a_entryObject.strValue).toUpperCase(), true);
				return;

			case OPTION_TOGGLE:
				enabled = isEnabled;
				gotoAndStop("toggle");

				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;

				toggleIcon._x = entryWidth - toggleIcon._width;
				toggleIcon.gotoAndStop(!a_entryObject.numValue ? "off" : "on");
				return;

			case OPTION_SLIDER:
				enabled = isEnabled;
				gotoAndStop("slider");

				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;

				valueTextField._width = entryWidth;
				valueTextField.SetText(skyui.util.GlobalFunctions.formatString(skyui.util.Translator.translate(a_entryObject.strValue), a_entryObject.numValue).toUpperCase(), true);

				sliderIcon._x = valueTextField.getLineMetrics(0).x - sliderIcon._width;
				return;

			case OPTION_MENU:
				enabled = isEnabled;
				gotoAndStop("menu");

				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;

				valueTextField._width = entryWidth;
				valueTextField.SetText(skyui.util.Translator.translateNested(a_entryObject.strValue).toUpperCase(), true);

				menuIcon._x = valueTextField.getLineMetrics(0).x - menuIcon._width;
				return;

			case OPTION_COLOR:
				enabled = isEnabled;
				gotoAndStop("color");

				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;

				colorIcon._x = entryWidth - colorIcon._width;

				color = new Color(colorIcon.pigment);
				color.setRGB(a_entryObject.numValue);
				return;

			case OPTION_KEYMAP:
				enabled = isEnabled;
				gotoAndStop("keymap");

				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;

				keyCode = a_entryObject.numValue;
				if (keyCode == -1)
					keyCode = 282; // "???"
				buttonArt.gotoAndStop(keyCode);
				buttonArt._x = entryWidth - buttonArt._width;
				return;

			case OPTION_INPUT:
				enabled = isEnabled;
				gotoAndStop("input");

				labelTextField._width = entryWidth;
				labelTextField.SetText(a_entryObject.text, true);
				labelTextField._alpha = isSelected ? ALPHA_SELECTED : ALPHA_ACTIVE;

				valueTextField._width = entryWidth;
				valueTextField.SetText(a_entryObject.strValue, true);
				valueTextField.SetText(skyui.util.Translator.translateNested(a_entryObject.strValue).toUpperCase(), true);

				inputIcon._x = valueTextField.getLineMetrics(0).x - inputIcon._width - 3;
				return;

			case OPTION_EMPTY:
			default:
				enabled = false;
				gotoAndStop("empty");
				return;
		}
	}
}
