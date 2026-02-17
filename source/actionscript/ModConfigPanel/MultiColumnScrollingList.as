class MultiColumnScrollingList extends skyui.components.list.ScrollingList
{
	/* PRIVATE VARIABLES */

	private var _separators;


	/* PROPERTIES */

	public var columnSpacing = 0;

	public var separatorRenderer;

	private var _columnCount = 1;

	public function get columnCount()
	{
		return _columnCount;
	}

	public function set columnCount(a_value)
	{
		_columnCount = a_value;
		refreshSeparators();
	}


	/* INITIALIZATION */

	public function MultiColumnScrollingList()
	{
		super();

		scrollDelta = columnCount;
		_maxListIndex *= columnCount;

		if (_separators == null)
			_separators = [];
	}

	public function onLoad()
	{
		super.onLoad();

		if (scrollbar != undefined) {
			scrollbar.scrollDelta = scrollDelta;
		}
	}


	/* PUBLIC FUNCTIONS */

	// @override ScrollingList
	public function UpdateList()
	{
		// Prepare clips
		setClipCount(_maxListIndex);

		var xStart = background._x + leftBorder;
		var yStart = background._y + topBorder;
		var h = 0;
		var w = 0;
		var lastColumnIndex = columnCount - 1;
		var columnWidth = (background._width - leftBorder - rightBorder - (columnCount - 1) * columnSpacing) / columnCount;

		// Clear clipIndex for everything before the selected list part
		var i = 0;
		while (i < getListEnumSize() && i < _scrollPosition) {
			getListEnumEntry(i).clipIndex = undefined;
			i = i + 1;
		}

		_listIndex = 0;

		// Display the selected part of the list
		i = _scrollPosition;
		var entryClip;
		var entryItem;
		while (i < getListEnumSize() && _listIndex < _maxListIndex) {
			entryClip = getClipByIndex(_listIndex);
			entryItem = getListEnumEntry(i);

			entryClip.itemIndex = entryItem.itemIndex;
			entryItem.clipIndex = _listIndex;

			entryClip.width = columnWidth;
			entryClip.setEntry(entryItem, listState);

			entryClip._x = xStart + w;
			entryClip._y = yStart + h;
			entryClip._visible = true;

			if (i % columnCount == lastColumnIndex) {
				w = 0;
				h += entryHeight;
			} else {
				w = w + columnWidth + columnSpacing;
			}

			_listIndex = _listIndex + 1;
			i = i + 1;
		}

		// Clear clipIndex for everything after the selected list part
		i = _scrollPosition + _listIndex;
		while (i < getListEnumSize()) {
			getListEnumEntry(i).clipIndex = undefined;
			i = i + 1;
		}

		// Select entry under the cursor for mouse-driven navigation
		var e;
		if (isMouseDrivenNav) {
			e = Mouse.getTopMostEntity();
			while (e != undefined) {
				if (e._parent == this && e._visible && e.itemIndex != undefined)
					doSetSelectedIndex(e.itemIndex, skyui.components.list.BasicList.SELECT_MOUSE);
				e = e._parent;
			}
		}

		var bShowSeparators = _listIndex > 0;
		i = 0;
		while (i < _separators.length) {
			_separators[i]._visible = bShowSeparators;
			i = i + 1;
		}
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		if (disableInput)
			return false;

		if (super.handleInput(details, pathToFocus))
			return true;

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

	public function moveSelectionLeft()
	{
		if (disableSelection)
			return;

		if (_selectedIndex == -1) {
			selectDefaultIndex(false);
		} else if ((getSelectedListEnumIndex() % columnCount) > 0) {
			doSetSelectedIndex(getListEnumRelativeIndex(-1), skyui.components.list.BasicList.SELECT_KEYBOARD);
			isMouseDrivenNav = false;
		}
	}

	public function moveSelectionRight()
	{
		if (disableSelection)
			return;

		if (_selectedIndex == -1) {
			selectDefaultIndex(false);
		} else if ((getSelectedListEnumIndex() % columnCount) < (columnCount - 1)) {
			doSetSelectedIndex(getListEnumRelativeIndex(1), skyui.components.list.BasicList.SELECT_KEYBOARD);
			isMouseDrivenNav = false;
		}
	}


	/* PRIVATE FUNCTIONS */

	private function refreshSeparators()
	{
		if (_separators == null)
			_separators = [];

		var e;
		while (_separators.length > 0) {
			e = _separators.pop();
			e.removeMovieClip();
		}

		// Create separators
		if (!separatorRenderer)
			return;

		var columnWidth = (background._width - leftBorder - rightBorder - (columnCount - 1) * columnSpacing) / columnCount;
		var t = background._x + leftBorder;
		var d = columnSpacing / 2;

		var i = 0;
		while (i < columnCount - 1) {
			e = attachMovie(separatorRenderer, separatorRenderer + i, getNextHighestDepth());
			t += columnWidth + d;
			e._x = t;
			e._y = background._y;
			e._height = background._height;
			e._alpha = 50;
			_separators.push(e);
			t += d;
			i = i + 1;
		}
	}
}
