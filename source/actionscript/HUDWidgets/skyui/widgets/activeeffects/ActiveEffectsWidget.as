class skyui.widgets.activeeffects.ActiveEffectsWidget extends skyui.widgets.WidgetBase
{
	/* CONSTANTS */

	private static var EFFECT_SPACING = 5;
	private static var EFFECT_FADE_IN_DURATION = 0.25;
	private static var EFFECT_FADE_OUT_DURATION = 0.75;
	private static var EFFECT_MOVE_DURATION = 1;

	private static var ICON_SOURCE = "skyui/icons_effect_psychosteve.swf";


	// config
	private var _effectBaseSize;
	private var _groupEffectCount;
	private var _orientation;


	/* PRIVATE VARIABLES */

	// Phases between 0 and 1 during update intervals
	private var _marker = 1;

	private var _sortFlag = true;

	private var _effectsHash;
	private var _effectsGroups;

	private var _intervalId;
	private var _updateInterval = 150;

	private var _enabled;

	private var _minTimeLeft = 180;


	/* PUBLIC VARIABLES */

	// Passed from SKSE
	public var effectDataArray;

	// MovieClip builtins used by decompiler
	public var attachMovie;
	public var getNextHighestDepth;


	/* INITIALIZATION */

	public function ActiveEffectsWidget()
	{
		super();
		gfx.events.EventDispatcher.initialize(this);
		this._effectsHash = new Object();
		this._effectsGroups = new Array();
		this.effectDataArray = new Array();
	}


	/* PUBLIC FUNCTIONS */

	// @overrides WidgetBase
	public function getWidth()
	{
		return this._effectBaseSize;
	}

	// @overrides WidgetBase
	public function getHeight()
	{
		return this._effectBaseSize;
	}

	// @Papyrus
	public function initNumbers(a_enabled, a_effectSize, a_groupEffectCount, a_minTimeLeft)
	{
		this._enabled = a_enabled;
		this._effectBaseSize = a_effectSize;
		this._groupEffectCount = a_groupEffectCount;
		this._minTimeLeft = a_minTimeLeft;
	}

	// @Papyrus
	public function initStrings(a_orientation)
	{
		this._orientation = a_orientation.toLowerCase();
	}

	// @Papyrus
	public function initCommit()
	{
		this.invalidateSize();
		if (this._enabled)
		{
			this.drawEffects();
		}
	}

	// @Papyrus
	public function setEffectSize(a_effectBaseSize)
	{
		this._effectBaseSize = a_effectBaseSize;
		this.invalidateSize();
		this.invalidateEffects();
	}

	// @Papyrus
	public function setGroupEffectCount(a_groupEffectCount)
	{
		this._groupEffectCount = a_groupEffectCount;
		this.invalidateEffects();
	}

	// @Papyrus
	public function setEnabled(a_enabled)
	{
		this._enabled = a_enabled;
		if (this._enabled)
		{
			this.eraseEffects();
			this.drawEffects();
		}
		else
		{
			this.eraseEffects();
		}
	}

	// @Papyrus
	public function setOrientation(a_orientation)
	{
		this._orientation = a_orientation.toLowerCase();
		this.invalidateEffects();
	}

	// @Papyrus
	public function setMinTimeLeft(a_seconds)
	{
		this._minTimeLeft = a_seconds;
	}


	/* PRIVATE FUNCTIONS */

	// @override WidgetBase
	private function updatePosition()
	{
		super.updatePosition();
		this.invalidateEffects();
	}

	private function onIntervalUpdate()
	{
		this.effectDataArray.splice(0);
		skse.RequestActivePlayerEffects(this.effectDataArray);
		if (this._sortFlag)
		{
			// Make sure oldest effects are at the top
			this.effectDataArray.sortOn("elapsed", Array.DESCENDING | Array.NUMERIC);
			this._sortFlag = false;
		}
		var i = 0;
		var effectData;
		var effectClip;
		var effectsGroup;
		while (i < this.effectDataArray.length)
		{
			effectData = this.effectDataArray[i];
			// Ignore if time left is > minimum, i.e. for blessings that last several hours
			if (!(this._minTimeLeft != 0 && this._minTimeLeft < effectData.duration - effectData.elapsed))
			{
				effectClip = this._effectsHash[effectData.id];
				if (!effectClip)
				{
					// New Effect
					effectsGroup = this.getFreeEffectsGroup();
					effectClip = effectsGroup.addEffect(effectData);
					this._effectsHash[effectData.id] = effectClip;
				}
				else
				{
					// Existing Effect
					effectClip.updateEffect(effectData);
				}
				effectClip.marker = this._marker;
			}
			i = i + 1;
		}
		for (var s in this._effectsHash)
		{
			effectClip = this._effectsHash[s];
			if (effectClip.marker != this._marker)
			{
				effectClip.remove();
				delete this._effectsHash[s];
			}
		}
		this._marker = 1 - this._marker;
	}

	private function getFreeEffectsGroup()
	{
		// Existing group has free slots?
		var i = 0;
		var group;
		while (i < this._effectsGroups.length)
		{
			group = this._effectsGroups[i];
			if (group.length < this._groupEffectCount)
			{
				return group;
			}
			i = i + 1;
		}

		// No free slots, create new group
		var newGroupIdx = this._effectsGroups.length;
		var initObject = {
			index: newGroupIdx,
			iconLocation: this._rootPath + skyui.widgets.activeeffects.ActiveEffectsWidget.ICON_SOURCE,
			effectBaseSize: this._effectBaseSize,
			effectSpacing: skyui.widgets.activeeffects.ActiveEffectsWidget.EFFECT_SPACING,
			effectFadeInDuration: skyui.widgets.activeeffects.ActiveEffectsWidget.EFFECT_FADE_IN_DURATION,
			effectFadeOutDuration: skyui.widgets.activeeffects.ActiveEffectsWidget.EFFECT_FADE_OUT_DURATION,
			effectMoveDuration: skyui.widgets.activeeffects.ActiveEffectsWidget.EFFECT_MOVE_DURATION,
			hAnchor: this._hAnchor,
			vAnchor: this._vAnchor,
			orientation: this._orientation
		};
		// Name needs to be unique so append getNextHighestDepth() to the name
		var newGroup = this.attachMovie("ActiveEffectsGroup", "effectsGroup" + this.getNextHighestDepth(), this.getNextHighestDepth(), initObject);
		newGroup.addEventListener("groupRemoved", this, "onGroupRemoved");
		this._effectsGroups.push(newGroup);
		return newGroup;
	}

	// Called from ActiveEffectsGroup
	public function onGroupRemoved(event)
	{
		var removedGroup = event.target;
		var groupIdx = removedGroup.index;
		this._effectsGroups.splice(groupIdx, 1);
		removedGroup.removeMovieClip();
		var effectsGroup;
		var i = groupIdx;
		while (i < this._effectsGroups.length)
		{
			effectsGroup = this._effectsGroups[i];
			effectsGroup.updatePosition(i);
			i = i + 1;
		}
	}

	private function invalidateEffects()
	{
		if (!this._enabled)
		{
			return;
		}
		this.eraseEffects();
		this.drawEffects();
	}

	private function eraseEffects()
	{
		clearInterval(this._intervalId);
		var effectsGroup;
		var i = 0;
		while (i < this._effectsGroups.length)
		{
			effectsGroup = this._effectsGroups[i];
			effectsGroup.removeMovieClip();
			i = i + 1;
		}
		this._effectsHash = new Object();
		this._effectsGroups = new Array();
	}

	private function drawEffects()
	{
		clearInterval(this._intervalId);
		this._sortFlag = true;
		this._intervalId = setInterval(this, "onIntervalUpdate", this._updateInterval);
	}
}
