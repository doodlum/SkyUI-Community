/*
 *  Basic list API expected by the game.
 */

// @abstract
class skyui.components.list.BSList extends MovieClip
{
  /* PROPERTIES */
  
  	// Entries of the list, represented by dynamic objects.
	// When the internal representation of the entry list, changes are pushed directly into entryList.
	// As such, the order of this array should not be modified for certain lists.
	private var _entryList: Array;
	
	public function get entryList()
	{
		return this._entryList;
	}

	// Indicates the selected index and is read by the game directly.
	private var _selectedIndex: Number;
	
	public function get selectedIndex()
	{
		return this._selectedIndex;
	}

	function set selectedIndex(a_newIndex: Number)
	{
		this._selectedIndex = a_newIndex;
	}
	
	// The selected entry.
	public function get selectedEntry()
	{
		return this._entryList[this._selectedIndex];
	}
	
	
  /* CONSTRUCTORS */
  
	public function BSList()
	{
		this._entryList = new Array();
		this._selectedIndex = -1;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// Indicates that entryList has been updated.
	// @abstract
	public function InvalidateData() { }
	
	// Redraws the list.
	// @abstract
	public function UpdateList() { }
}
