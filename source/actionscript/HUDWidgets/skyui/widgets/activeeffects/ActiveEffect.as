class skyui.widgets.activeeffects.ActiveEffect extends MovieClip
{
	/* CONSTANTS */

	private static var METER_WIDTH = 15;
	private static var METER_PADDING = 5;


	/* PRIVATE VARIABLES */

	private var _meter;

	private var _meterEmptyIdx;
	private var _meterFullIdx;

	// Icon
	private var _iconLoader;
	private var _icon;
	private var _iconHolder;

	private var _iconBaseLabel;
	private var _iconEmblemLabel;


	/* STAGE ELEMENTS */

	private var content;
	private var background;


	/* PUBLIC VARIABLES */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent;

	// initObject
	public var index;
	public var effectData;
	public var iconLocation;
	public var effectBaseSize;
	public var effectSpacing;
	public var effectFadeInDuration;
	public var effectFadeOutDuration;
	public var effectMoveDuration;

	public var hAnchor;
	public var vAnchor;
	public var orientation;


	/* INITIALIZATION */

	public function ActiveEffect()
	{
		super();
		gfx.events.EventDispatcher.initialize(this);
		this._iconLoader = new MovieClipLoader();
		this._iconLoader.addListener(this);
		this._iconHolder = this.content.iconContent;
		this._icon = this._iconHolder.createEmptyMovieClip("icon", this._iconHolder.getNextHighestDepth());
		this._icon.noIconLoaded = true; // Is removed when MovieClipLoader loads a clip
		this._width = this._height = this.effectBaseSize;

		// Force position
		var p = this.determinePosition(this.index);
		this._x = p[0];
		this._y = p[1];
		this.background._alpha = 0;
		this._iconHolder.iconBackground._alpha = 0;
		this.initEffect();
		this.updateEffect(this.effectData);
		this._alpha = 0;
		skyui.util.Tween.LinearTween(this, "_alpha", 0, 100, this.effectFadeInDuration, null);
	}


	/* PUBLIC FUNCTIONS */

	public function updateEffect(a_effectData)
	{
		this.effectData = a_effectData;
		this.updateMeter();
	}

	public function updatePosition(a_newIndex)
	{
		this.index = a_newIndex;
		var p = this.determinePosition(this.index);
		skyui.util.Tween.LinearTween(this, "_x", this._x, p[0], this.effectMoveDuration, null);
		skyui.util.Tween.LinearTween(this, "_y", this._y, p[1], this.effectMoveDuration, null);
	}

	public function remove(a_immediate)
	{
		if (a_immediate == true)
		{
			this._alpha = 0;
			this.dispatchEvent({type:"effectRemoved"});
			return;
		}
		skyui.util.Tween.LinearTween(this, "_alpha", 100, 0, this.effectFadeOutDuration, mx.utils.Delegate.create(this, function()
		{
			this.dispatchEvent({type:"effectRemoved"});
		}
		));
	}


	/* PRIVATE FUNCTIONS */

	private function initEffect()
	{
		var iconData = skyui.util.EffectIconMap.lookupIconLabel(this.effectData);
		this._iconBaseLabel = iconData.baseLabel;
		this._iconEmblemLabel = iconData.emblemLabel;
		if (this._iconBaseLabel == "default_effect" || this._iconBaseLabel == undefined || this._iconBaseLabel == "")
		{
			skyui.util.Debug.log("[SkyUI Active Effects]: Missing icon");
			for (var s in this.effectData)
			{
				skyui.util.Debug.log("\t\t" + s + ": " + this.effectData[s]);
			}
		}
		this._iconHolder._width = this._iconHolder._height = this.background._width - skyui.widgets.activeeffects.ActiveEffect.METER_PADDING - skyui.widgets.activeeffects.ActiveEffect.METER_WIDTH;
		this._iconHolder._y = (this.background._height - this._iconHolder._height) / 2;
		if (this.effectData.duration - this.effectData.elapsed > 1)
		{
			this.initMeter();
		}
		this._iconLoader.loadClip(this.iconLocation, this._icon);
	}

	private function initMeter()
	{
		this._meter = this.content.attachMovie("SimpleMeter", "meter", this.content.getNextHighestDepth(), {_x:this.background._width - skyui.widgets.activeeffects.ActiveEffect.METER_WIDTH, _y:this._iconHolder._y, _width:skyui.widgets.activeeffects.ActiveEffect.METER_WIDTH, _height:this._iconHolder._height});
		this._meter.background._alpha = 50;
		this._meter.gotoAndStop("Empty");
		this._meterEmptyIdx = this._meter._currentframe;
		this._meter.gotoAndStop("Full");
		this._meterFullIdx = this._meter._currentframe;
	}

	private function updateMeter()
	{
		if (this._meter == undefined) // Constant effects, no timer
		{
			return;
		}
		var newPercent = 100 * (this.effectData.duration - this.effectData.elapsed) / this.effectData.duration;
		newPercent = Math.min(100, Math.max(newPercent, 0));
		var meterFrame = Math.floor(Shared.GlobalFunc.Lerp(this._meterEmptyIdx, this._meterFullIdx, 0, 100, newPercent));
		this._meter.gotoAndStop(meterFrame);
	}

	private function onLoadInit(a_mc)
	{
		// Fix for spamming effects causing MovieClipLoader to do strange things
		if (this._icon.noIconLoaded == true)
		{
			this.remove(true);
			return;
		}
		this._icon._x = 0;
		this._icon._y = 0;
		this._icon._width = this._icon._height = this._iconHolder.iconBackground._width;
		this._icon.baseIcon.gotoAndStop(this._iconBaseLabel);
		this._icon.emblemIcon.gotoAndStop(this._iconEmblemLabel);
		this.updateEffect(this.effectData);
	}

	private function onLoadError(a_mc, a_errorCode)
	{
		var errorTextField = this._iconHolder.createTextField("ErrorTextField", this._icon.getNextHighestDepth(), 0, 0, this._iconHolder.iconBackground._width, this._iconHolder.iconBackground._height);
		errorTextField.verticalAlign = "center";
		errorTextField.textAutoSize = "fit";
		errorTextField.multiLine = true;
		var tf = new TextFormat();
		tf.align = "center";
		tf.color = 16777215;
		tf.indent = 20;
		tf.font = "$EverywhereBoldFont";
		errorTextField.setNewTextFormat(tf);
		errorTextField.text = "No Icon\nSource";
	}

	private function determinePosition(a_index)
	{
		var newX = 0;
		var newY = 0;

		// Orientation is the orientation of the EffectsGroups
		if (this.orientation == "vertical")
		{
			// Orientation vertical means the ActiveEffect is in a column
			if (this.vAnchor == "bottom")
			{
				// Widget is anchored vertically to the bottom, add next ActiveEffect above
				newY = - this.index * (this.effectBaseSize + this.effectSpacing);
			}
			else
			{
				newY = this.index * (this.effectBaseSize + this.effectSpacing);
			}
		}
		else
		{
			// Orientation horizontal means the ActiveEffect is in a row
			if (this.hAnchor == "right")
			{
				// Widget is anchored horizontally to the right, add next ActiveEffect to the left
				newX = - this.index * (this.effectBaseSize + this.effectSpacing);
			}
			else
			{
				newX = this.index * (this.effectBaseSize + this.effectSpacing);
			}
		}
		return [newX, newY];
	}

	private function parseTime(a_s)
	{
		var s = Math.floor(a_s);
		var m = 0;
		var h = 0;
		var d = 0;
		if (s >= 60)
		{
			m = Math.floor(s / 60);
			s %= 60;
		}
		if (m >= 60)
		{
			h = Math.floor(m / 60);
			m %= 60;
		}
		if (h >= 24)
		{
			d = Math.floor(h / 24);
			h %= 24;
		}
		return (d == 0 ? "" : d + "d ") + (!(h != 0 || d) ? "" : h + "h ") + (!(m != 0 || d || h) ? "" : m + "m ") + (s + "s");
	}
}
