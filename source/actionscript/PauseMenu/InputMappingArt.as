class InputMappingArt extends MovieClip
{
	/* PRIVATE VARIABLES */

	private var _keyCodes;

	private var _buttonNameMap = {esc:1, hyphen:12, equal:13, backspace:14, tab:15, q:16, w:17, e:18, r:19, t:20, y:21, u:22, i:23, o:24, p:25, bracketleft:26, bracketright:27, enter:28, a:30, s:31, d:32, f:33, g:34, h:35, j:36, k:37, l:38, semicolon:39, quotesingle:40, tilde:41, backslash:43, z:44, x:45, c:46, v:47, b:48, n:49, m:50, comma:51, period:52, slash:53, numpadmult:55, space:57, capslock:58, f1:59, f2:60, f3:61, f4:62, f5:63, f6:64, f7:65, f8:66, f9:67, f10:68, numlock:69, scrolllock:70, numpad7:71, numpad8:72, numpad9:73, numpadminus:74, numpad4:75, numpad5:76, numpad6:77, numpadplus:78, numpad1:79, numpad2:80, numpad3:81, numpad0:82, numpaddec:83, f11:87, f12:88, numpadenter:156, numpaddivide:158, printsrc:183, pause:197, home:199, up:200, pgup:201, left:203, right:205, end:207, down:208, pgdn:209, insert:210, mouse1:256, mouse2:257, mouse3:258, mouse4:259, mouse5:260, mouse6:261, mouse7:262, mouse8:263, mousewheelup:264, mousewheeldown:265, ps3_start:270, ps3_back:271, ps3_l3:272, ps3_r3:273, ps3_lb:274, ps3_rb:275, ps3_a:276, ps3_b:277, ps3_x:278, ps3_y:279, ps3_lt:280, ps3_rt:281};


	/* STAGE ELEMENTS */

	public var background;
	public var buttonArt;
	public var textField;


	/* PROPERTIES */

	public function set hiddenBackground(a_flag)
	{
		this.background._visible = !a_flag;
	}

	public function get hiddenBackground()
	{
		return this.background._visible;
	}

	public function get width()
	{
		return this.background._width;
	}

	public function set width(a_value)
	{
		this.background._width = a_value;
	}


	/* INITIALIZATION */

	function MappedButton()
	{
		super();
		Shared.GlobalFunc.MaintainTextFormat();
	}

	public function onLoad()
	{
		this.buttonArt = [];
		this._keyCodes = [];

		this.textField.textAutoSize = "shrink";
		this.textField._visible = false;
		this.background._visible = false;

		for (var i = 0; this["buttonArt" + i] != undefined; i++) {
			this["buttonArt" + i]._visible = false;
			this.buttonArt.push(this["buttonArt" + i]);
		}

		// These Button names can't be set in the object constructor since they're 'invalid' names
		this._buttonNameMap["1"]			= 2;
		this._buttonNameMap["2"]			= 3;
		this._buttonNameMap["3"]			= 4;
		this._buttonNameMap["4"]			= 5;
		this._buttonNameMap["5"]			= 6;
		this._buttonNameMap["6"]			= 7;
		this._buttonNameMap["7"]			= 8;
		this._buttonNameMap["8"]			= 9;
		this._buttonNameMap["9"]			= 10;
		this._buttonNameMap["0"]			= 11;
		this._buttonNameMap["l-ctrl"]		= 29;
		this._buttonNameMap["l-shift"]		= 42;
		this._buttonNameMap["r-shift"]		= 54;
		this._buttonNameMap["l-alt"]		= 56;
		this._buttonNameMap["r-ctrl"]		= 157;
		this._buttonNameMap["r-alt"]		= 184;
		this._buttonNameMap["delete"]		= 211;
		this._buttonNameMap["360_start"]	= 270;
		this._buttonNameMap["360_back"]		= 271;
		this._buttonNameMap["360_l3"]		= 272;
		this._buttonNameMap["360_r3"]		= 273;
		this._buttonNameMap["360_lb"]		= 274;
		this._buttonNameMap["360_rb"]		= 275;
		this._buttonNameMap["360_a"]		= 276;
		this._buttonNameMap["360_b"]		= 277;
		this._buttonNameMap["360_x"]		= 278;
		this._buttonNameMap["360_y"]		= 279;
		this._buttonNameMap["360_lt"]		= 280;
		this._buttonNameMap["360_rt"]		= 281;
	}


	/* PUBLIC FUNCTIONS */

	public function setButtonName(a_buttonName)
	{
		this.textField._visible = false;

		var keyCodes = this._buttonNameMap[a_buttonName.toLowerCase()];

		if (keyCodes instanceof Array) {
			this._keyCodes = keyCodes;
		} else {
			this._keyCodes = [keyCodes];
		}

		if (this._keyCodes[0] == null) {
			for (var i = 0; i < this.buttonArt.length; i++) {
				this.buttonArt[i]._visible = false;
			}
			this.textField.SetText(a_buttonName);
			this.textField._width = this.textField.getLineMetrics(0).width;
			this.textField._visible = true;
			this.background._width = this.textField._width;
			return undefined;
		}

		var xOffset = 0;
		for (var i = 0; i < this.buttonArt.length; i++) {
			var icon = this.buttonArt[i];

			if (this._keyCodes[i] > 0) {
				icon._visible = true;
				icon.gotoAndStop(this._keyCodes[i]);
				icon._x = xOffset;
				icon._y = 0;
				xOffset += icon._width;
			} else {
				icon._visible = false;
			}
		}

		this.background._width = xOffset;
	}
}
