class CategoryListEntry extends skyui.components.list.BasicListEntry
{
  /* PRIVATE VARIABLES */

	private var _iconLabel;
	private var _iconSize;


  /* STAGE ELEMENTS */

	public var icon;


  /* PUBLIC FUNCTIONS */

	public function initialize(a_index, a_state)
	{
		super.initialize();

		var iconLoader = new MovieClipLoader();
		iconLoader.addListener(this);

		_iconLabel = CategoryList(a_state.list).iconArt[a_index];
		_iconSize = CategoryList(a_state.list).iconSize;

		iconLoader.loadClip(a_state.iconSource, icon);
	}

	public function setEntry(a_entryObject, a_state)
	{
		if (a_entryObject.filterFlag == 0 && !a_entryObject.bDontHide) {
			_alpha = 15;
			enabled = false;
		} else if (a_entryObject == a_state.list.selectedEntry) {
			_alpha = 100;
			enabled = true;
		} else {
			_alpha = 50;
			enabled = true;
		}
	}


  /* PRIVATE FUNCTIONS */

	// @implements MovieClipLoader
	private function onLoadInit(a_mc)
	{
		if (a_mc.background != undefined) {
			// If the icon set has a background, scale the icon until background size would = icon size
			a_mc._xscale = a_mc._yscale = (_iconSize / a_mc.background._width) * 100;
		} else {
			a_mc._width = a_mc._height = _iconSize;
		}

		a_mc.gotoAndStop(_iconLabel);
	}
}
