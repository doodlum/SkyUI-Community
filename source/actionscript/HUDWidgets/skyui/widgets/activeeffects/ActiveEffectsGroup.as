class skyui.widgets.activeeffects.ActiveEffectsGroup extends MovieClip
{
	/* PRIVATE VARIABLES */

	private var _effectsArray;


	/* PUBLIC VARIABLES */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent;

	// initObject
	public var index;
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

	public function ActiveEffectsGroup()
	{
		super();
		gfx.events.EventDispatcher.initialize(this);
		this._effectsArray = new Array();
		var p = this.determinePosition(this.index);
		this._x = p[0];
		this._y = p[1];
	}


	/* PROPERTIES */

	public function get length()
	{
		return this._effectsArray.length;
	}


	/* PUBLIC FUNCTIONS */

	public function addEffect(a_effectData)
	{
		var effectIdx = this._effectsArray.length;
		var initObject = {index:this._effectsArray.length, effectData: a_effectData, iconLocation: this.iconLocation, effectBaseSize: this.effectBaseSize, effectSpacing: this.effectSpacing, effectFadeInDuration: this.effectFadeInDuration, effectFadeOutDuration: this.effectFadeOutDuration, effectMoveDuration: this.effectMoveDuration, hAnchor: this.hAnchor, vAnchor: this.vAnchor, orientation: this.orientation};
		var effectClip = this.attachMovie("ActiveEffect", a_effectData.id, this.getNextHighestDepth(), initObject);
		effectClip.addEventListener("effectRemoved", this, "onEffectRemoved");
		this._effectsArray.push(effectClip);
		return effectClip;
	}

	public function updatePosition(a_newIndex)
	{
		this.index = a_newIndex;
		var p = this.determinePosition(this.index);
		skyui.util.Tween.LinearTween(this, "_x", this._x, p[0], this.effectMoveDuration, null);
		skyui.util.Tween.LinearTween(this, "_y", this._y, p[1], this.effectMoveDuration, null);
	}


	/* PRIVATE FUNCTIONS */

	private function onEffectRemoved(event)
	{
		var removedEffectClip = event.target;
		var effectIdx = removedEffectClip.index;
		this._effectsArray.splice(effectIdx, 1);
		removedEffectClip.removeMovieClip();
		var effectClip;
		var i;
		if (this._effectsArray.length > 0)
		{
			i = effectIdx;
			while (i < this._effectsArray.length)
			{
				effectClip = this._effectsArray[i];
				effectClip.updatePosition(i);
				i = i + 1;
			}
		}
		else
		{
			this.dispatchEvent({type:"groupRemoved"});
		}
	}

	private function determinePosition(a_index)
	{
		var newX = 0;
		var newY = 0;

		// Orientation is the orientation of the EffectsGroups
		if (this.orientation == "vertical")
		{
			// Orientation vertical means the EffectsGroup acts as a column
			if (this.hAnchor == "right")
			{
				// Widget is anchored horizontally to the right, add next EffectsGroup to the left
				newX = - (this.effectSpacing + this.index * (this.effectBaseSize + this.effectSpacing));
			}
			else
			{
				newX = this.effectSpacing + this.index * (this.effectBaseSize + this.effectSpacing);
			}
		}
		else
		{
			// Orientation horizontal means the EffectsGroup acts as a row
			if (this.vAnchor == "bottom")
			{
				// Widget is anchored vertically to the bottom, add next EffectsGroup above
				newY = - (this.effectSpacing + this.index * (this.effectBaseSize + this.effectSpacing));
			}
			else
			{
				newY = this.effectSpacing + this.index * (this.effectBaseSize + this.effectSpacing);
			}
		}
		return [newX, newY];
	}
}
