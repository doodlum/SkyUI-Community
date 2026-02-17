class ModListPanel extends MovieClip
{
	/* CONSTANTS */

	private var INIT = 0;
	private var LIST_ACTIVE = 1;
	private var SUBLIST_ACTIVE = 2;
	private var TRANSITION_TO_SUBLIST = 3;
	private var TRANSITION_TO_LIST = 4;

	private var ANIM_LIST_FADE_OUT = 0;
	private var ANIM_LIST_FADE_IN = 1;
	private var ANIM_SUBLIST_FADE_OUT = 2;
	private var ANIM_SUBLIST_FADE_IN = 3;
	private var ANIM_DECORTITLE_FADE_OUT = 4;
	private var ANIM_DECORTITLE_FADE_IN = 5;
	private var ANIM_DECORTITLE_TWEEN = 6;


	/* PRIVATE VARIABLES */

	private var _state = ModListPanel.prototype.INIT;

	private var _titleText;

	private var _modList;
	private var _subList;

	private var _bDisabled = false;


	/* STAGE ELEMENTS */

	public var decorTop;
	public var decorTitle;
	public var decorBottom;

	public var modListFader;
	public var subListFader;

	public var sublistIndicator;


	/* INITIALIZATION */

	public function ModListPanel()
	{
		super();
		_modList = modListFader.list;
		_subList = subListFader.list;

		gfx.events.EventDispatcher.initialize(this);
	}

	// @override MovieClip
	private function onLoad()
	{
		// Init state
		hideDecorTitle(true);
		modListFader.gotoAndStop("show");
		subListFader.gotoAndStop("hide");
		sublistIndicator._visible = false;

		_state = LIST_ACTIVE;

		_subList.addEventListener("itemPress", this, "onSubListPress");
	}


	/* PROPERTIES */

	public function get selectedEntry()
	{
		if (_state == LIST_ACTIVE)
			return _modList.selectedEntry;
		else if (_state == SUBLIST_ACTIVE)
			return _subList.selectedEntry;
		else
			return null;
	}

	public function get isDisabled()
	{
		return _bDisabled;
	}

	public function set isDisabled(a_bDisabled)
	{
		_bDisabled = a_bDisabled;
		_subList.disableSelection = _subList.disableInput = a_bDisabled;
		_modList.disableSelection = _modList.disableInput = a_bDisabled;
	}


	/* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent;

	public function isSublistActive()
	{
		return (_state == SUBLIST_ACTIVE);
	}

	public function isListActive()
	{
		return (_state == LIST_ACTIVE);
	}

	public function showList()
	{
		setState(TRANSITION_TO_LIST);
	}

	public function showSublist()
	{
		if (_modList.selectedClip == null || _modList.selectedEntry == null)
			return;

		setState(TRANSITION_TO_SUBLIST);
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		var nextClip = pathToFocus.shift();
		if (nextClip && nextClip.handleInput(details, pathToFocus))
			return true;

		if (_bDisabled)
			return false;

		if (_state == LIST_ACTIVE) {
			if (_modList.handleInput(details, pathToFocus))
				return true;
		} else if (_state == SUBLIST_ACTIVE) {
			if (Shared.GlobalFunc.IsKeyPressed(details, false)) {
				if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
					showList();
					return true;
				}
			}

			if (_subList.handleInput(details, pathToFocus))
				return true;
		}

		return false;
	}


	/* PRIVATE FUNCTIONS */

	private function setState(a_state)
	{
		var restored;
		switch (a_state) {
			case LIST_ACTIVE:
				modListFader.gotoAndStop("show");
				_modList.disableInput = false;
				_modList.disableSelection = false;
				restored = _modList.listState.savedIndex;
				_modList.selectedIndex = (restored > -1) ? restored : 0;

				if (modListFader.getDepth() < subListFader.getDepth())
					modListFader.swapDepths(subListFader);

				dispatchEvent({type: "modListEnter"});
				break;

			case SUBLIST_ACTIVE:
				subListFader.gotoAndStop("show");
				_subList.disableInput = false;
				_subList.disableSelection = false;
				_subList.selectedIndex = -1;

				if (subListFader.getDepth() < modListFader.getDepth())
					subListFader.swapDepths(modListFader);

				decorTitle.onPress = function()
				{
					if (!this._parent.isDisabled)
						this._parent.showList();
				};

				dispatchEvent({type: "subListEnter"});
				break;

			case TRANSITION_TO_SUBLIST:
				_titleText = _modList.selectedEntry.text;
				decorTitle._y = _modList.selectedClip._y;
				hideDecorTitle(false);
				decorTitle.gotoAndPlay("fadeIn");
				decorTitle.textHolder.textField.text = _titleText;
				modListFader.gotoAndPlay("fadeOut");

				_modList.listState.savedIndex = _modList.selectedIndex;
				_modList.disableInput = true;
				_modList.disableSelection = true;

				sublistIndicator._visible = false;

				dispatchEvent({type: "modListExit"});
				break;

			case TRANSITION_TO_LIST:
				decorTitle.gotoAndPlay("fadeOut");
				subListFader.gotoAndPlay("fadeOut");

				delete decorTitle.onPress;

				_subList.disableInput = true;
				_subList.disableSelection = true;

				dispatchEvent({type: "subListExit"});
				break;

			default:
				return;
		}

		_state = a_state;
	}

	private function onAnimFinish(a_animID)
	{
		var tween;
		switch (a_animID) {
			case ANIM_DECORTITLE_FADE_IN:
				// Should happen at the same time as ANIM_LIST_FADE_OUT, we just need to handle one of them.
				tween = new mx.transitions.Tween(decorTitle, "_y", mx.transitions.easing.Strong.easeOut, decorTitle._y, _modList._x + _modList.topBorder, 0.75, true);
				tween.FPS = 60;
				tween.onMotionFinished = mx.utils.Delegate.create(this, decorMotionFinishedFunc);
				tween.onMotionChanged = mx.utils.Delegate.create(this, decorMotionUpdateFunc);
				break;

			case ANIM_DECORTITLE_TWEEN:
				subListFader.gotoAndPlay("fadeIn");
				break;

			case ANIM_SUBLIST_FADE_IN:
				setState(SUBLIST_ACTIVE);
				break;

			case ANIM_SUBLIST_FADE_OUT:
				// Should happen at the same time as ANIM_DECORTITLE_FADE_OUT, we just need to handle one of them.
				modListFader.gotoAndPlay("fadeIn");
				hideDecorTitle(true);
				break;

			case ANIM_LIST_FADE_IN:
				setState(LIST_ACTIVE);

			default:
				return;
		}
	}

	private function onSubListPress(a_event)
	{
	}

	private function decorMotionFinishedFunc()
	{
		onAnimFinish(ANIM_DECORTITLE_TWEEN);
	}

	private function decorMotionUpdateFunc()
	{
		decorTop._y = _modList._y;
		decorTop._height = decorTitle._y - decorTop._y;

		decorBottom._y = decorTitle._y + decorTitle._height;
		decorBottom._height = decorBottom._y - _modList._height;
	}

	private function hideDecorTitle(a_hide)
	{
		if (a_hide) {
			decorTop._visible = true;
			decorTop._y = _modList._y;
			decorTop._height = _modList._height;
			decorTitle._visible = false;
			decorBottom._visible = false;
		} else {
			decorTitle._visible = true;
			decorTop._visible = true;
			decorTop._y = _modList._y;
			decorTop._height = decorTitle._y - decorTop._y;
			decorBottom._visible = true;
			decorBottom._y = decorTitle._y + decorTitle._height;
			decorBottom._height = decorBottom._y - _modList._height;
		}
	}
}
