class IconTabList extends skyui.components.list.BasicList
{
	/* CONSTANTS */

	public static var LEFT_SEGMENT = 0;
	public static var RIGHT_SEGMENT = 1;


	/* STAGE ELEMENTS */

	public var selectorCenter;
	public var selectorLeft;
	public var selectorRight;
	public var background;


	/* PRIVATE VARIABLES */

	private var _contentWidth;
	private var _totalWidth;
	private var _selectorPos;
	private var _targetSelectorPos;
	private var _bFastSwitch;


	/* PROPERTIES */

	// Size of the icon.
	public var iconSize;

	// Array that contains the icon label for category at position i.
	// The category list uses fixed lengths/icons, so this is assigned statically.
	public var iconArt;


	/* INITIALIZATION */

	public function IconTabList()
	{
		super();

		_selectorPos = 0;
		_targetSelectorPos = 0;
		_bFastSwitch = false;

		if (iconSize == undefined)
			iconSize = 32;
	}


	/* PUBLIC FUNCTIONS */

	// Clears the list. For the category list, that's ok since the entryList isn't manipulated directly.
	// @override BasicList
	public function clearList()
	{
		_entryList.splice(0);
	}

	// @override BasicList
	public function InvalidateData()
	{
		if (_bSuspended) {
			_bRequestInvalidate = true;
			return;
		}

		listEnumeration.invalidate();

		if (_selectedIndex >= listEnumeration.size())
			_selectedIndex = listEnumeration.size() - 1;

		UpdateList();

		if (onInvalidate)
			onInvalidate();
	}

	// @override BasicList
	public function UpdateList()
	{
		if (_bSuspended) {
			_bRequestUpdate = true;
			return;
		}

		var clipCount = listEnumeration.size();

		setClipCount(clipCount);

		var cw = 0;
		var i = 0;
		var entryClip;

		while (i < clipCount) {
			entryClip = getClipByIndex(i);

			entryClip.setEntry(listEnumeration.at(i), listState);

			listEnumeration.at(i).clipIndex = i;
			entryClip.itemIndex = i;

			cw += iconSize;
			i = i + 1;
		}

		_contentWidth = cw;
		_totalWidth = background._width;

		var spacing = (_totalWidth - _contentWidth) / (clipCount + 1);

		var xPos = background._x + spacing;

		i = 0;
		while (i < clipCount) {
			entryClip = getClipByIndex(i);
			entryClip._x = xPos;

			xPos = xPos + iconSize + spacing;
			entryClip._visible = true;
			i = i + 1;
		}

		updateSelector();
	}

	// Moves the selection left to the next element. Wraps around.
	public function moveSelectionLeft()
	{
		if (disableSelection)
			return;

		var curIndex = _selectedIndex;
		var startIndex = _selectedIndex;

		do {
			if (curIndex > 0) {
				curIndex = curIndex - 1;
			} else {
				_bFastSwitch = true;
				curIndex = listEnumeration.size() - 1;
			}
		} while (curIndex != startIndex && listEnumeration.at(curIndex).enabled == false);

		onItemPress(curIndex, 0);
	}

	// Moves the selection right to the next element. Wraps around.
	public function moveSelectionRight()
	{
		if (disableSelection)
			return;

		var curIndex = _selectedIndex;
		var startIndex = _selectedIndex;

		do {
			if (curIndex < listEnumeration.size() - 1) {
				curIndex = curIndex + 1;
			} else {
				_bFastSwitch = true;
				curIndex = 0;
			}
		} while (curIndex != startIndex && listEnumeration.at(curIndex).enabled == false);

		onItemPress(curIndex, 0);
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		if (disableInput)
			return false;

		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == gfx.ui.NavigationCode.LEFT) {
				moveSelectionLeft();
				return true;
			} else if (details.navEquivalent == gfx.ui.NavigationCode.RIGHT) {
				moveSelectionRight();
				return true;
			}
		}
		return false;
	}

	// @override BasicList
	public function onEnterFrame()
	{
		super.onEnterFrame();

		if (_bFastSwitch && _selectorPos != _targetSelectorPos) {
			_selectorPos = _targetSelectorPos;
			_bFastSwitch = false;
			refreshSelector();

		} else if (_selectorPos < _targetSelectorPos) {
			_selectorPos = _selectorPos + (_targetSelectorPos - _selectorPos) * 0.2 + 1;

			refreshSelector();

			if (_selectorPos > _targetSelectorPos)
				_selectorPos = _targetSelectorPos;

		} else if (_selectorPos > _targetSelectorPos) {
			_selectorPos = _selectorPos - (_selectorPos - _targetSelectorPos) * 0.2 - 1;

			refreshSelector();

			if (_selectorPos < _targetSelectorPos)
				_selectorPos = _targetSelectorPos;
		}
	}

	// @override BasicList
	public function onItemPress(a_index, a_keyboardOrMouse)
	{
		if (disableInput || disableSelection || a_index == -1)
			return;

		doSetSelectedIndex(a_index, a_keyboardOrMouse);
		updateSelector();
		dispatchEvent({type:"itemPress", index:_selectedIndex, entry:selectedEntry, keyboardOrMouse:a_keyboardOrMouse});
	}

	// @override BasicList
	public function onItemPressAux(a_index, a_keyboardOrMouse, a_buttonIndex)
	{
		if (disableInput || disableSelection || a_index == -1 || a_buttonIndex != 1)
			return;

		doSetSelectedIndex(a_index, a_keyboardOrMouse);
		updateSelector();
		dispatchEvent({type:"itemPressAux", index:_selectedIndex, entry:selectedEntry, keyboardOrMouse:a_keyboardOrMouse});
	}

	// @override BasicList
	public function onItemRollOver(a_index)
	{
		if (disableInput || disableSelection)
			return;

		isMouseDrivenNav = true;

		if (a_index == _selectedIndex)
			return;

		var entryClip = getClipByIndex(a_index);
		entryClip._alpha = 75;
	}

	// @override BasicList
	public function onItemRollOut(a_index)
	{
		if (disableInput || disableSelection)
			return;

		isMouseDrivenNav = true;

		if (a_index == _selectedIndex)
			return;

		var entryClip = getClipByIndex(a_index);
		entryClip._alpha = 50;
	}


	/* PRIVATE FUNCTIONS */

	private function updateSelector()
	{
		if (selectorCenter == undefined) {
			return;
		}

		if (_selectedIndex == -1) {
			selectorCenter._visible = false;

			if (selectorLeft != undefined)
				selectorLeft._visible = false;

			if (selectorRight != undefined)
				selectorRight._visible = false;

			return;
		}

		var selectedClip = _entryClipManager.getClip(_selectedIndex);

		_targetSelectorPos = selectedClip._x + (selectedClip.background._width - selectorCenter._width) / 2;

		selectorCenter._visible = true;
		selectorCenter._y = selectedClip._y + selectedClip.background._height;

		if (selectorLeft != undefined) {
			selectorLeft._visible = true;
			selectorLeft._x = 0;
			selectorLeft._y = selectorCenter._y;
		}

		if (selectorRight != undefined) {
			selectorRight._visible = true;
			selectorRight._y = selectorCenter._y;
			selectorRight._width = _totalWidth - selectorRight._x;
		}
	}

	private function refreshSelector()
	{
		selectorCenter._visible = true;
		var selectedClip = _entryClipManager.getClip(_selectedIndex);

		selectorCenter._x = _selectorPos;

		if (selectorLeft != undefined)
			selectorLeft._width = selectorCenter._x;

		if (selectorRight != undefined) {
			selectorRight._x = selectorCenter._x + selectorCenter._width;
			selectorRight._width = _totalWidth - selectorRight._x;
		}
	}
}
