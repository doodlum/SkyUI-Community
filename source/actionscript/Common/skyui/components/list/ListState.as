/*
 * Used to dynamically add additional properties to a list that are passed
 * along to IListEntry.setData(), i.e. activeEntry.
 */

class skyui.components.list.ListState
{
    public function ListState(a_list: BasicList)
    {
        this.list = a_list;
    }

    // Parent list
    public var list: BasicList;

    // ...
}