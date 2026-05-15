class CategoryListEntry extends skyui.components.list.BasicListEntry
{
  /* PRIVATE VARIABLES */

    private var _iconLabel: String;
    private var _iconSize: Number;
    
    
  /* STAGE ELMENTS */

    public var icon: MovieClip;

    
  /* PUBLIC FUNCTIONS */

    public function CategoryListEntry()
    {
        super();
    }
    
    public function initialize(a_index: Number, a_state: ListState)
    {
        super.initialize();

        var iconLoader = new MovieClipLoader();
        iconLoader.addListener(this);

        this._iconLabel = CategoryList(a_state.list).iconArt[a_index];
        this._iconSize = CategoryList(a_state.list).iconSize;

        iconLoader.loadClip(a_state.iconSource, this.icon);
    }
    
    public function setEntry(a_entryObject: Object, a_state: ListState)
    {
        if (a_entryObject.filterFlag == 0 && !a_entryObject.bDontHide) {
            this._alpha = 15;
            this.enabled = false;
        } else if (a_entryObject == a_state.list.selectedEntry) {
            this._alpha = 100;
            this.enabled = true;
        } else {
            this._alpha = 50;
            this.enabled = true;
        }
    }

  /* PRIVATE FUNCTIONS */

    // @implements MovieClipLoader
    private function onLoadInit(a_mc: MovieClip)
    {
        if (a_mc.background != undefined) {
            // If the icon set has a background, scale the icon until background size would = icon size
            a_mc._xscale = a_mc._yscale = (this._iconSize / a_mc.background._width) * 100;
        } else {
            a_mc._width = a_mc._height = this._iconSize;
        }
        
        a_mc.gotoAndStop(this._iconLabel);
    }
}
