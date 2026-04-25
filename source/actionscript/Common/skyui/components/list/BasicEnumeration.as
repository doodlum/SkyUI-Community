class skyui.components.list.BasicEnumeration implements skyui.components.list.BasicEnumeration.IEntryEnumeration
{
  /* PROPERTIES */

    private var _entryData: Array;


  /* INITIALIZATION */

    public function BasicEnumeration(a_data: Array)
    {
        this._entryData = a_data;
    }


  /* PUBLIC FUNCTIONS */

    // @override skyui.IEntryEnumeration
    public function size()
    {
        return this._entryData.length;
    }

    // @override skyui.IEntryEnumeration
    public function at(a_index: Number)
    {
        return this._entryData[a_index];
    }

    // @override skyui.IEntryEnumeration
    public function lookupEntryIndex(a_enumIndex: Number)
    {
        return a_enumIndex;
    }

    // @override skyui.IEntryEnumeration
    public function lookupEnumIndex(a_entryIndex: Number)
    {
        return a_entryIndex;
    }

    // @override skyui.IEntryEnumeration
    public function invalidate()
    {
        // Do nothing.
    }
}