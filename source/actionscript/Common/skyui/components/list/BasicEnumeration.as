class skyui.components.list.BasicEnumeration implements skyui.components.list.IEntryEnumeration
{
   var _entryData;
   function BasicEnumeration(a_data)
   {
      this._entryData = a_data;
   }
   function size()
   {
      return this._entryData.length;
   }
   function at(a_index)
   {
      return this._entryData[a_index];
   }
   function lookupEntryIndex(a_enumIndex)
   {
      return a_enumIndex;
   }
   function lookupEnumIndex(a_entryIndex)
   {
      return a_entryIndex;
   }
   function invalidate()
   {
   }
}
