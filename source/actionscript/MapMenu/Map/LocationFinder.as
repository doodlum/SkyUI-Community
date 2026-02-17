class Map.LocationFinder extends MovieClip
{
	/* CONSTANTS */

	public static var TYPE_RANGE = 60;


	/* PRIVATE VARIABLES */

	private var _foundMarker;

	private var _nameFilter;
	private var _sortFilter;

	private var _bShown = false;


	/* STAGE ELEMENTS */

	public var list;

	public var searchWidget;

	public var loadIcon;


	/* INITIALIZATION */

	public function LocationFinder()
	{
		super();

		this._nameFilter = new skyui.filter.NameFilter();
		this._nameFilter.nameAttribute = "_label";

		this._sortFilter = new skyui.filter.SortFilter();
		this._sortFilter.setSortBy(["_label"],[Array.CASEINSENSITIVE]);
	}

	// @override MovieClip
	private function onLoad()
	{
		var e = new skyui.components.list.FilteredEnumeration(this.list.entryList);
		e.addFilter(this._nameFilter);
		e.addFilter(this._sortFilter);
		this.list.listEnumeration = e;

		this._nameFilter.addEventListener("filterChange",this,"onNameFilterChange");

		this.list.addEventListener("itemPress",this,"onLocationListPress");

		this.searchWidget.addEventListener("inputStart",this,"onSearchInputStart");
		this.searchWidget.addEventListener("inputEnd",this,"onSearchInputEnd");
		this.searchWidget.addEventListener("inputChange",this,"onSearchInputChange");

		this.setLoading(false);
		this.hide(true);
	}

	private function onNameFilterChange(a_event)
	{
		this.list.requestInvalidate();
	}


	/* PUBLIC FUNCTIONS */

	public function setLoading(a_bLoading)
	{
		if(a_bLoading)
		{
			this.loadIcon._visible = true;
			this.loadIcon.gotoAndPlay(0);
			this.list._visible = false;
		}
		else
		{
			this.loadIcon._visible = false;
			this.loadIcon.stop();
			this.list._visible = true;
		}
	}

	public function show()
	{
		gfx.managers.FocusHandler.instance.setFocus(this.list,0);

		this._bShown = true;
		this._parent.gotoAndPlay("fadeIn");
		this.searchWidget.isDisabled = false;
		this.list.disableInput = this.list.disableSelection = false;
		this.list.selectedIndex = -1;

		this.clearFoundMarker();
	}

	public function hide(a_bInstant)
	{
		this._bShown = false;
		if(a_bInstant)
		{
			this._parent.gotoAndStop("hide");
		}
		else
		{
			this._parent.gotoAndPlay("fadeOut");
		}
		this.searchWidget.isDisabled = true;
		this.list.disableInput = this.list.disableSelection = true;
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		if(this._bShown)
		{
			if(Shared.GlobalFunc.IsKeyPressed(details))
			{
				// Search hotkey (default space)
				if(details.skseKeycode == 57)
				{
					this.searchWidget.startInput();
					return true;
				}
			}
		}
		var nextClip = pathToFocus.shift();
		return nextClip.handleInput(details,pathToFocus);
	}


	/* PRIVATE FUNCTIONS */

	private function onLocationListPress(a_event)
	{
		var entry = a_event.entry;
		if(entry == null)
		{
			return undefined;
		}

		this.setFoundMarker(entry);

		skse.ShowOnMap(entry.index);
		// hide will be called from local map menu as soon as its state changes
	}

	private function clearFoundMarker()
	{
		if(this._foundMarker)
		{
			this._foundMarker.removeMovieClip();
			this._foundMarker = null;
		}
	}

	private function setFoundMarker(a_marker)
	{
		this.clearFoundMarker();

		if(a_marker.IconClip != null)
		{
			var depth = a_marker.IconClip.getNextHighestDepth();
			this._foundMarker = a_marker.IconClip.attachMovie("FoundMarker","foundIcon",depth);
		}
	}

	private function onSearchInputStart(event)
	{
		this.list.disableInput = this.list.disableSelection = true;
		gfx.managers.InputDelegate.instance.enableControlFixup(false);
		this._nameFilter.filterText = "";
	}

	private function onSearchInputChange(event)
	{
		this._nameFilter.filterText = event.data;
	}

	private function onSearchInputEnd(event)
	{
		this.list.disableInput = this.list.disableSelection = false;
		gfx.managers.InputDelegate.instance.enableControlFixup(true);
		this._nameFilter.filterText = event.data;
	}
}
