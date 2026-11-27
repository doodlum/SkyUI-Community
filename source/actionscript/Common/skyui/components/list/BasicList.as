// @abstract
class skyui.components.list.BasicList extends skyui.components.list.BSList
{
  /* CONSTANTS */
  
	public static var PLATFORM_PC = 0;

	public static var SELECT_MOUSE = 0;
	public static var SELECT_KEYBOARD = 1;

	
  /* STAGE ELEMENTS */

	public var background: MovieClip;
	
	
  /* PRIVATE VARIABLES */

  	private var _bRequestInvalidate: Boolean = false;
  	private var _bRequestUpdate: Boolean = false;
	private var _invalidateRequestID: Number;
	private var _updateRequestID: Number;
	
	private var _entryClipManager: EntryClipManager;
	
	private var _dataProcessors: Array;
	

  /* PROPERTIES */
  
  	public var topBorder: Number = 0;
	public var bottomBorder: Number = 0;
	public var leftBorder: Number = 0;
	public var rightBorder: Number = 0;
	
	public function get width()
	{
		return this.background._width;
	}
	
	public function set width(a_val: Number)
	{
		this.background._width = a_val;
	}
	
	public function get height()
	{
		return this.background._height;
	}
	
	public function set height(a_val: Number)
	{
		this.background._height = a_val;
	}
  
	private var _platform: Number = skyui.components.list.BasicList.PLATFORM_PC;
	
	public function get platform()
	{
		return this._platform;
	}
	
	/*
	// Removed 2012/12/18, use setPlatform()
	public function set platform(a_platform: Number)
	{
		this._platform = a_platform;
		this.isMouseDrivenNav = this._platform == skyui.components.list.BasicList.PLATFORM_PC;
	}
	*/
	
	public var isMouseDrivenNav: Boolean = false;
	
	public var isListAnimating: Boolean = false;
	
	public var disableInput: Boolean = false;
	
	public var disableSelection: Boolean = false;
	
	public var isAutoUnselect: Boolean = false;
	
	public var canSelectDisabled: Boolean = false;

	// @override BSList
	public function get selectedIndex()
	{
		return this._selectedIndex;
	}
	
	// @override BSList
	public function set selectedIndex(a_newIndex: Number)
	{
		this.doSetSelectedIndex(a_newIndex, skyui.components.list.BasicList.SELECT_MOUSE);
	}
	
	public var entryRenderer: String;
	
	public var listEnumeration: IEntryEnumeration;
	
	public var listState: ListState;
	
	public function get itemCount()
	{
		return this.getListEnumSize();
	}
	
	// The selected entry.
	public function get selectedClip()
	{
		return this._entryClipManager.getClip(this.selectedEntry.clipIndex);
	}
	
	
	private var _bSuspended: Boolean = false;
	
	public function get suspended()
	{
		return this._bSuspended;
	}
	
	public function set suspended(a_flag: Boolean)
	{
		if (this._bSuspended == a_flag)
			return;
		
		// Lock
		if (a_flag) {
			this._bSuspended = true;
		} else {
			this._bSuspended = false;
			
			if (this._bRequestInvalidate)
				this.InvalidateData();
			else if(this._bRequestUpdate)
				this.UpdateList();

			this._bRequestInvalidate = false;
			this._bRequestUpdate = false;
			
			// Allow custom handlers
			if (this.onUnsuspend != undefined)
				this.onUnsuspend();
		}
	}
	
	
  /* INITIALIZATION */
  
	public function BasicList()
	{
		super();
		
		this._entryClipManager = new skyui.components.list.EntryClipManager(this);
		this._dataProcessors = [];
		this.listState = new skyui.components.list.ListState(this);

		gfx.events.EventDispatcher.initialize(this);
		Mouse.addListener(this);
	}

	
  /* PUBLIC FUNCTIONS */
  
	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean)
	{
		this._platform = a_platform;
		this.isMouseDrivenNav = this._platform == skyui.components.list.BasicList.PLATFORM_PC;
	}
	
	// Custom handlers
	public var onUnsuspend: Function;
	public var onInvalidate: Function;
	
	public function addDataProcessor(a_dataProcessor: IListProcessor)
	{
		this._dataProcessors.push(a_dataProcessor);
	}
	
	public function clearList()
	{
		this._entryList.splice(0);
	}
	
	public function requestInvalidate()
	{
		this._bRequestInvalidate = true;
		
		// Invalidate request replaces update request
		if (this._updateRequestID) {
			this._bRequestUpdate = false;
			clearInterval(this._updateRequestID);
			delete this._updateRequestID;
		}
		
		// If suspsend, the unsuspend will trigger the requested invaliate.
		if (!this._bSuspended && !this._invalidateRequestID)
			this._invalidateRequestID = setInterval(this, "commitInvalidate", 1);
	}
	
	public function requestUpdate()
	{
		this._bRequestUpdate = true;
		
		// Invalidate already requested? Includes update
		if (this._invalidateRequestID)
			return;
			
		// If suspsend, the unsuspend will trigger the requested invaliate.
		if (!this._bSuspended && !this._invalidateRequestID)
			this._updateRequestID = setInterval(this, "commitUpdate", 1);
	}
	
	public function commitInvalidate()
	{
		clearInterval(this._invalidateRequestID);
		delete this._invalidateRequestID;
		
		// Invalidate request replaces update request
		if (this._updateRequestID) {
			this._bRequestUpdate = false;
			clearInterval(this._updateRequestID);
			delete this._updateRequestID;
		}
		
		this._bRequestInvalidate = false;
		this.InvalidateData();
	}
	
	public function commitUpdate()
	{
		clearInterval(this._updateRequestID);
		delete this._updateRequestID;
		
		this._bRequestUpdate = false;
		this.UpdateList();
	}
	
	// @override BSList
	public function InvalidateData()
	{
		if (this._bSuspended) {
			this._bRequestInvalidate = true;
			return;
		}
		
		for (var i = 0; i < this._entryList.length; i++) {
			this._entryList[i].itemIndex = i;
			this._entryList[i].clipIndex = undefined;
		}
		
		for (var i = 0; i < this._dataProcessors.length; i++)
			this._dataProcessors[i].processList(this);
		
		this.listEnumeration.invalidate();
		
		if (this._selectedIndex >= this.listEnumeration.size())
			this._selectedIndex = this.listEnumeration.size() - 1;

		this.UpdateList();
		
		if (this.onInvalidate)
			this.onInvalidate();
	}

	// @override BSList
	// @abstract
	public function UpdateList() { }
	
	
  /* PRIVATE FUNCTIONS */
  
	private function onItemPress(a_index: Number, a_keyboardOrMouse: Number)
	{
		if (this.disableInput || this.disableSelection || this._selectedIndex == -1)
			return;
			
		if (a_keyboardOrMouse == undefined)
			a_keyboardOrMouse = skyui.components.list.BasicList.SELECT_KEYBOARD;
			
		this.dispatchEvent({type: "itemPress", index: this._selectedIndex, entry: this.selectedEntry, clip: this.selectedClip, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	private function onItemPressAux(a_index: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number)
	{
		if (this.disableInput || this.disableSelection || this._selectedIndex == -1 || a_buttonIndex != 1)
			return;
			
		if (a_keyboardOrMouse == undefined)
			a_keyboardOrMouse = skyui.components.list.BasicList.SELECT_KEYBOARD;
		
		this.dispatchEvent({type: "itemPressAux", index: this._selectedIndex, entry: this.selectedEntry, clip: this.selectedClip, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	private function onItemRollOver(a_index: Number)
	{
		if (this.isListAnimating || this.disableSelection || this.disableInput)
			return;
			
		this.doSetSelectedIndex(a_index, skyui.components.list.BasicList.SELECT_MOUSE);
		this.isMouseDrivenNav = true;
	}

	private function onItemRollOut(a_index: Number)
	{
		if (!this.isAutoUnselect)
			return;
		
		if (this.isListAnimating || this.disableSelection || this.disableInput)
			return;
			
		this.doSetSelectedIndex(-1, skyui.components.list.BasicList.SELECT_MOUSE);
		this.isMouseDrivenNav = true;
	}

	private function doSetSelectedIndex(a_newIndex: Number, a_keyboardOrMouse: Number)
	{
		if (this.disableSelection || a_newIndex == this._selectedIndex)
			return;
			
		// Selection is not contained in current entry enumeration, ignore
		if (a_newIndex != -1 && this.getListEnumIndex(a_newIndex) == undefined)
			return;
			
		var oldIndex = this._selectedIndex;
		this._selectedIndex = a_newIndex;

		if (oldIndex != -1) {
			var clip = this._entryClipManager.getClip(this._entryList[oldIndex].clipIndex);
			clip.setEntry(this._entryList[oldIndex], this.listState);
		}

		if (this._selectedIndex != -1) {
			var clip = this._entryClipManager.getClip(this._entryList[this._selectedIndex].clipIndex);
			clip.setEntry(this._entryList[this._selectedIndex], this.listState);
		}

		this.dispatchEvent({type: "selectionChange", index: this._selectedIndex, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	private function getClipByIndex(a_index: Number)
	{
		return this._entryClipManager.getClip(a_index);
	}
	
	private function setClipCount(a_count: Number)
	{
		this._entryClipManager.clipCount = a_count;
	}
	
	private function getSelectedListEnumIndex()
	{
		return this.listEnumeration.lookupEnumIndex(this._selectedIndex);
	}
	
	private function getListEnumIndex(a_index: Number)
	{
		return this.listEnumeration.lookupEnumIndex(a_index);
	}
	
	private function getListEntryIndex(a_index: Number)
	{
		return this.listEnumeration.lookupEntryIndex(a_index);
	}
	
	private function getListEnumSize()
	{
		return this.listEnumeration.size();
	}
	
	private function getListEnumEntry(a_index: Number)
	{
		return this.listEnumeration.at(a_index);
	}
	
	private function getListEnumFirstIndex()
	{
		return this.listEnumeration.lookupEntryIndex(0);
	}
	
	private function getListEnumLastIndex()
	{
		return this.listEnumeration.lookupEntryIndex(this.getListEnumSize() - 1);
	}
	
	private function getListEnumRelativeIndex(a_offset: Number)
	{
		return this.listEnumeration.lookupEntryIndex(this.getSelectedListEnumIndex() + a_offset);
	}
}
