class skyui.components.list.BSList extends MovieClip
{
   var _entryList;
   var _selectedIndex;
   function BSList()
   {
      super();
      this._entryList = new Array();
      this._selectedIndex = -1;
   }
   function get entryList()
   {
      return this._entryList;
   }
   function get selectedIndex()
   {
      return this._selectedIndex;
   }
   function set selectedIndex(a_newIndex)
   {
      this._selectedIndex = a_newIndex;
   }
   function get selectedEntry()
   {
      return this._entryList[this._selectedIndex];
   }
   function InvalidateData()
   {
   }
   function UpdateList()
   {
   }
}
