class skyui.widgets.WidgetBase extends MovieClip
{
	/* CONSTANTS */

	private static var MODES = ["All", "Favor", "MovementDisabled", "Swimming", "WarHorseMode", "HorseMode", "InventoryMode", "BookMode", "DialogueMode", "StealthMode", "SleepWaitMode", "BarterMode", "TweenMode", "WorldMapMode", "JournalMode", "CartMode", "VATSPlayback"];

	private static var MODEMAP = {all:"All", favor:"Favor", movementdisabled:"MovementDisabled", swimming:"Swimming", warhorsemode:"WarHorseMode", horsemode:"HorseMode", inventorymode:"InventoryMode", bookmode:"BookMode", dialoguemode:"DialogueMode", stealthmode:"StealthMode", sleepwaitmode:"SleepWaitMode", bartermode:"BarterMode", tweenmode:"TweenMode", worldmapmode:"WorldMapMode", journalmode:"JournalMode", cartmode:"CartMode", vatsplayback:"VATSPlayback"};

	private static var ANCHOR_LEFT = "left";
	private static var ANCHOR_RIGHT = "right";
	private static var ANCHOR_CENTER = "center";
	private static var ANCHOR_TOP = "top";
	private static var ANCHOR_BOTTOM = "bottom";


	/* PRIVATE VARIABLES */

	private var _rootPath = "";

	private var _hudMetrics;

	private var _clientInfo;
	private var _widgetID;
	private var _widgetHolder;

	private var __x = 0;
	private var __y = 0;

	private var _vAnchor = "top";
	private var _hAnchor = "left";


	/* INITIALIZATION */

	public function WidgetBase()
	{
		super();
		this._clientInfo = {};
		this._widgetHolder = this._parent;
		this._widgetID = this._widgetHolder._name;
		// Allows for preview in Flash Player
		if (_global.gfxPlayer)
		{
			_global.gfxExtensions = true;
		}
		else
		{
			this._widgetHolder._visible = false;
		}
	}


	/* PUBLIC FUNCTIONS */

	public function setRootPath(a_path)
	{
		this._rootPath = a_path;
	}

	public function setHudMetrics(a_hudMetrics)
	{
		this._hudMetrics = a_hudMetrics;
	}

	// @Papyrus
	public function setClientInfo(a_clientString)
	{
		var widget = this;
		var clientInfo = new Object();
		//[ScriptName <formName (formID)>]
		var lBrackIdx = 0;
		var lInequIdx = a_clientString.indexOf("<");
		var lParenIdx = a_clientString.indexOf("(");
		var rParenIdx = a_clientString.indexOf(")");
		clientInfo.scriptName = a_clientString.slice(lBrackIdx + 1, lInequIdx - 1);
		clientInfo.formName = a_clientString.slice(lInequIdx + 1, lParenIdx - 1);
		clientInfo.formID = a_clientString.slice(lParenIdx + 1, rParenIdx);
		widget.clientInfo = clientInfo;
	}

	// @Papyrus
	public function setModes(/* a_visibleMode0: String, a_visibleMode1, ... */)
	{
		var numValidModes = 0;
		// Clear all modes
		var i = 0;
		while (i < skyui.widgets.WidgetBase.MODES.length)
		{
			delete this._widgetHolder[skyui.widgets.WidgetBase.MODES[i]];
			i = i + 1;
		}
		i = 0;
		var m;
		while (i < arguments.length)
		{
			m = skyui.widgets.WidgetBase.MODEMAP[arguments[i].toLowerCase()];
			if (m != undefined)
			{
				this._widgetHolder[m] = true;
				numValidModes = numValidModes + 1;
			}
			i = i + 1;
		}
		if (numValidModes == 0)
		{
			skse.SendModEvent("SKIWF_widgetError", "NoValidModes", Number(this._widgetID));
		}
		var hudMode = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
		this._widgetHolder._visible = this._widgetHolder.hasOwnProperty(hudMode);
		_root.HUDMovieBaseInstance.HudElements.push(this._widgetHolder);
	}

	// @Papyrus
	public function setHAnchor(a_hAnchor)
	{
		var hAnchor = a_hAnchor.toLowerCase();
		if (this._hAnchor == hAnchor)
		{
			return;
		}
		this._hAnchor = hAnchor;
		this.invalidateSize();
	}

	// @Papyrus
	public function setVAnchor(a_vAnchor)
	{
		var vAnchor = a_vAnchor.toLowerCase();
		if (this._vAnchor == vAnchor)
		{
			return;
		}
		this._vAnchor = vAnchor;
		this.invalidateSize();
	}

	// @Papyrus
	public function setPositionX(a_positionX)
	{
		this.__x = a_positionX;
		this.updatePosition();
	}

	// @Papyrus
	public function setPositionY(a_positionY)
	{
		this.__y = a_positionY;
		this.updatePosition();
	}

	// @Papyrus
	public function setAlpha(a_alpha)
	{
		this._alpha = a_alpha;
	}

	// @Papyrus
	public function tweenTo(a_newX, a_newY, a_duration)
	{
		var newX = Shared.GlobalFunc.Lerp(- this._hudMetrics.hMin, this._hudMetrics.hMax, 0, 1280, a_newX);
		var newY = Shared.GlobalFunc.Lerp(- this._hudMetrics.vMin, this._hudMetrics.vMax, 0, 720, a_newY);
		var duration = Math.max(0, a_duration || 0);
		skyui.util.Tween.LinearTween(this, "_x", this._x, newX, duration, null);
		skyui.util.Tween.LinearTween(this, "_y", this._y, newY, duration, null);
	}

	// @Papyrus
	public function fadeTo(a_alpha, a_duration)
	{
		var duration = Math.max(0, a_duration || 0);
		skyui.util.Tween.LinearTween(this, "_alpha", this._alpha, a_alpha, duration, null);
	}


	/* PRIVATE FUNCTIONS */

	// Override if widget width depends on property other than _width
	private function getWidth()
	{
		return this._width;
	}

	// Override if widget height depends on property other than _height
	private function getHeight()
	{
		return this._height;
	}

	private function invalidateSize()
	{
		this.updateAnchor();
	}

	private function updateAnchor()
	{
		var xOffset = this.getWidth();
		var yOffset = this.getHeight();
		if (this._hAnchor == skyui.widgets.WidgetBase.ANCHOR_RIGHT)
		{
			this._widgetHolder._x = - xOffset;
		}
		else if (this._hAnchor == skyui.widgets.WidgetBase.ANCHOR_CENTER)
		{
			this._widgetHolder._x = (- xOffset) / 2;
		}
		else
		{
			this._widgetHolder._x = 0;
		}
		if (this._vAnchor == skyui.widgets.WidgetBase.ANCHOR_BOTTOM)
		{
			this._widgetHolder._y = - yOffset;
		}
		else if (this._vAnchor == skyui.widgets.WidgetBase.ANCHOR_CENTER)
		{
			this._widgetHolder._y = (- yOffset) / 2;
		}
		else
		{
			this._widgetHolder._y = 0;
		}
		// Anchor or offsets could have changed, so update position
		this.updatePosition();
	}

	private function updatePosition()
	{
		// 0 -> -_hudMetrics.hMin
		// 1280 -> _hudMetrics.hMax
		this._x = Shared.GlobalFunc.Lerp(- this._hudMetrics.hMin, this._hudMetrics.hMax, 0, 1280, this.__x);
		// 0 -> -_hudMetrics.vMin
		// 720 -> _hudMetrics.vMax
		this._y = Shared.GlobalFunc.Lerp(- this._hudMetrics.vMin, this._hudMetrics.vMax, 0, 720, this.__y);
	}
}
