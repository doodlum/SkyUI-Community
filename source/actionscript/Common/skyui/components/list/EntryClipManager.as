class skyui.components.list.EntryClipManager
{ 
  /* PRIVATE VARIABLES */

    private var _clipPool: Array;
    
    private var _list: BasicList;
    
    private var _entryRenderer: String;
    
    private var _nextIndex: Number = 0;
    
    
  /* PROPERTIES */
    
    private var _clipCount: Number = -1;
    
    public function get clipCount()
    {
        return this._clipCount;
    }
    
    // Allocates the necessary number of clips in the pool, clears any existing clips for reuse.
    public function set clipCount(a_clipCount: Number)
    {
        this._clipCount = a_clipCount;
        
        var d = a_clipCount - this._clipPool.length;
        if (d > 0)
            this.growPool(d);
            
        for (var i = 0; i < this._clipPool.length; i++) {
            this._clipPool[i]._visible = false;
            this._clipPool[i].itemIndex = undefined;
        }
    }
    
    
  /* INITIALIZATION */

    public function EntryClipManager(a_list: BasicList)
    {
        this._list = a_list;
        this._clipPool = [];
    }


  /* PUBLIC FUNCTIONS */
    
    public function getClip(a_index: Number)
    {
        if (a_index >= this._clipCount)
            return undefined;

        return this._clipPool[a_index];
    }
    
    
  /* PRIVATE FUNCTIONS */
    
    private function growPool(a_size: Number)
    {
        var entryRenderer = this._list.entryRenderer;
        
        for (var i = 0; i < a_size; i++) {
            var entryClip = this._list.attachMovie(entryRenderer, entryRenderer + this._nextIndex, this._list.getNextHighestDepth());
            entryClip.initialize(this._nextIndex, this._list.listState);

            this._clipPool[this._nextIndex] = entryClip;
            this._nextIndex++;
        }
    }
}