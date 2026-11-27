/*
 *  A simple, general-purpose button list.
 */
class skyui.components.list.ButtonList extends skyui.components.list.BasicList
{
  /* CONSTANTS */
  
	public var ALIGN_LEFT = 0;
	public var ALIGN_RIGHT = 1;
	
	
  /* PROPERTIES */
	
	private var _bAutoScale: Boolean = true;
	
	public function get autoScale()
	{
		return this._bAutoScale;
	}
	
	public function set autoScale(a_bAutoScale: Boolean)
	{
		this._bAutoScale = a_bAutoScale;
	}
	
	private var _minButtonWidth: Number = 10;
	
	public function get minButtonWidth()
	{
		return this._minButtonWidth;
	}
	
	public function set minButtonWidth(a_minButtonWidth: Number)
	{
		this._minButtonWidth = a_minButtonWidth;
	}
	
	private var _buttonWidth: Number = 0;
	
	public function get buttonWidth()
	{
		return this._buttonWidth;
	}

	private var _align: Number = skyui.components.list.ButtonList.prototype.ALIGN_RIGHT;
	
	public function set align(a_align: String)
	{
		if (a_align == "LEFT")
			this._align = this.ALIGN_LEFT;
		else if (a_align == "RIGHT")
			this._align = this.ALIGN_RIGHT;
	}
	
	
  /* INITIALIZATION */
	
	public function ButtonList()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// @override BasicList
	public function UpdateList()
	{
		if (this._bSuspended) {
			this._bRequestUpdate = true;
			return;
		}
		
		this.setClipCount(this.getListEnumSize());
		
		var h = 0;

		this._buttonWidth = 4;

		// Set entries
		for (var i = 0; i < this.getListEnumSize(); i++) {
			var entryClip = this.getClipByIndex(i);
			var entryItem = this.getListEnumEntry(i);

			entryClip.itemIndex = i;
			entryItem.clipIndex = i;
			
			entryClip.setEntry(entryItem, this.listState);

			entryClip._y = this.topBorder + h;
			entryClip._visible = true;
			
			entryClip.selectIndicator._width = 4;
			entryClip.background._width = 4;
			
			if (this._buttonWidth < entryClip._width)
				this._buttonWidth = entryClip._width + 4;

			h = h + entryClip._height;
		}
		
		for (var i = 0; i < this.getListEnumSize(); i++) {
			entryClip._x = (this._align == this.ALIGN_LEFT) ? this.leftBorder : -(this.buttonWidth + this.rightBorder);
			
			var entryClip = this.getClipByIndex(i);
			entryClip.selectIndicator._width = this._buttonWidth;
			entryClip.background._width = this._buttonWidth;
		}
		
		this.background._width = this.leftBorder + this._buttonWidth + this.rightBorder;
		this.background._height = this.topBorder + h + this.bottomBorder;

		this.background._x = (this._align == this.ALIGN_LEFT) ? 0 : -this.background._width;
	}
	
	// @GFx
	public function handleInput(details, pathToFocus)
	{
		var processed = false;

		if (this.disableInput)
			return false;

		var entry = this.getClipByIndex(this._selectedIndex);
		var processed = entry != undefined && entry.handleInput != undefined && entry.handleInput(details, pathToFocus.slice(1));

		if (!processed && Shared.GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == gfx.ui.NavigationCode.UP || details.navEquivalent == gfx.ui.NavigationCode.PAGE_UP) {
				this.moveSelectionUp();
				processed = true;
			} else if (details.navEquivalent == gfx.ui.NavigationCode.DOWN || details.navEquivalent == gfx.ui.NavigationCode.PAGE_DOWN) {
				this.moveSelectionDown();
				processed = true;
			} else if (!this.disableSelection && details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
				this.onItemPress();
				processed = true;
			}
		}
		return processed;
	}
	
	public function moveSelectionUp()
	{
		if (this.disableSelection)
			return;
			
		if (this._selectedIndex == -1) {
			this.doSetSelectedIndex(this.getListEnumLastIndex(), skyui.components.list.BasicList.SELECT_KEYBOARD);
			this.isMouseDrivenNav = false;
		} else if (this.getSelectedListEnumIndex() > 0) {
			this.doSetSelectedIndex(this.getListEnumRelativeIndex(-1), skyui.components.list.BasicList.SELECT_KEYBOARD);
			this.isMouseDrivenNav = false;
			this.dispatchEvent({type: "listMovedUp", index: this._selectedIndex, scrollChanged: true});
		}
	}

	public function moveSelectionDown()
	{
		if (this.disableSelection)
			return;
			
		if (this._selectedIndex == -1) {
			this.doSetSelectedIndex(this.getListEnumFirstIndex(), skyui.components.list.BasicList.SELECT_KEYBOARD);
			this.isMouseDrivenNav = false;
		} else if (this.getSelectedListEnumIndex() < this.getListEnumSize() - 1) {
			this.doSetSelectedIndex(this.getListEnumRelativeIndex(1), skyui.components.list.BasicList.SELECT_KEYBOARD);
			this.isMouseDrivenNav = false;
			this.dispatchEvent({type: "listMovedDown", index: this._selectedIndex, scrollChanged: true});
		}
	}


  /* PRIVATE FUNCTIONS */

	// @GFx
	private function onMouseWheel(delta)
	{
		if (this.disableInput)
			return;
			
		for (var target = Mouse.getTopMostEntity(); target && target != undefined; target = target._parent) {
			if (target == this) {
				if (delta < 0)
					this.moveSelectionDown();
				else if (delta > 0)
					this.moveSelectionUp();
			}
		}
		
		this.isMouseDrivenNav = true;
	}
}