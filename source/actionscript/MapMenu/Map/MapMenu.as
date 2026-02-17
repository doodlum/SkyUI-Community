class Map.MapMenu
{
	/* CONSTANTS */

	static var SKYUI_RELEASE_IDX = 2018;
	static var SKYUI_VERSION_MAJOR = 5;
	static var SKYUI_VERSION_MINOR = 2;
	static var SKYUI_VERSION_STRING = Map.MapMenu.SKYUI_VERSION_MAJOR + "." + Map.MapMenu.SKYUI_VERSION_MINOR + " SE";

	private static var REFRESH_SHOW = 0;
	private static var REFRESH_X = 1;
	private static var REFRESH_Y = 2;
	private static var REFRESH_ROTATION = 3;
	private static var REFRESH_STRIDE = 4;
	private static var CREATE_NAME = 0;
	private static var CREATE_ICONTYPE = 1;
	private static var CREATE_UNDISCOVERED = 2;
	private static var CREATE_STRIDE = 3;
	private static var MARKER_CREATE_PER_FRAME = 10;


	/* PRIVATE VARIABLES */

	private var _markerList;

	private var _bottomBar;

	private var _nextCreateIndex = -1;
	private var _mapWidth = 0;
	private var _mapHeight = 0;

	private var _mapMovie;
	private var _markerDescriptionHolder;
	private var _markerContainer;

	private var _selectedMarker;

	private var _platform;

	private var _localMapButton;
	private var _journalButton;
	private var _playerLocButton;
	private var _findLocButton;
	private var _searchButton;

	private var _locationFinder;

	private var _localMapControls;
	private var _journalControls;
	private var _zoomControls;
	private var _playerLocControls;
	private var _setDestControls;
	private var _findLocControls;


	/* STAGE ELEMENTS */

	public var locationFinderFader;
	public var localMapFader;


	/* PROPERTIES */

	// @API
	public var LocalMapMenu;

	// @API
	public var MarkerDescriptionObj;

	// @API
	public var PlayerLocationMarkerType;

	// @API
	public var MarkerData;

	// @API
	public var YouAreHereMarker;

	// @GFx
	public var bPCControlsReady = true;


	/* INITIALIZATION */

	public function MapMenu(a_mapMovie)
	{
		this._mapMovie = a_mapMovie != undefined ? a_mapMovie : _root;
		this._markerContainer = this._mapMovie.createEmptyMovieClip("MarkerClips",1);

		this._markerList = new Array();
		this._nextCreateIndex = -1;

		this.LocalMapMenu = this._mapMovie.localMapFader.MapClip;

		this._locationFinder = this._mapMovie.locationFinderFader.locationFinder;

		this._bottomBar = _root.bottomBar;

		if(this.LocalMapMenu != undefined)
		{
			this.LocalMapMenu.setBottomBar(this._bottomBar);
			this.LocalMapMenu.setLocationFinder(this._locationFinder);

			Mouse.addListener(this);
			gfx.managers.FocusHandler.instance.setFocus(this,0);
		}

		this._markerDescriptionHolder = this._mapMovie.attachMovie("DescriptionHolder","markerDescriptionHolder",this._mapMovie.getNextHighestDepth());
		this._markerDescriptionHolder._visible = false;
		this._markerDescriptionHolder.hitTestDisable = true;

		this.MarkerDescriptionObj = this._markerDescriptionHolder.Description;

		Stage.addListener(this);

		this.initialize();
	}

	public function InitExtensions()
	{
		skse.EnableMapMenuMouseWheel(true);
	}

	private function initialize()
	{
		this.onResize();

		if(this._bottomBar != undefined)
		{
			this._bottomBar.swapDepths(4);
		}

		if(this._mapMovie.localMapFader != undefined)
		{
			this._mapMovie.localMapFader.swapDepths(3);
			this._mapMovie.localMapFader.gotoAndStop("hide");
		}

		if(this._mapMovie.locationFinderFader != undefined)
		{
			this._mapMovie.locationFinderFader.swapDepths(6);
		}

		gfx.io.GameDelegate.addCallBack("RefreshMarkers",this,"RefreshMarkers");
		gfx.io.GameDelegate.addCallBack("SetSelectedMarker",this,"SetSelectedMarker");
		gfx.io.GameDelegate.addCallBack("ClickSelectedMarker",this,"ClickSelectedMarker");
		gfx.io.GameDelegate.addCallBack("SetDateString",this,"SetDateString");
		gfx.io.GameDelegate.addCallBack("ShowJournal",this,"ShowJournal");
	}


	/* PUBLIC FUNCTIONS */

	// @API
	public function SetNumMarkers(a_numMarkers)
	{
		if(this._markerContainer != null)
		{
			this._markerContainer.removeMovieClip();
			this._markerContainer = this._mapMovie.createEmptyMovieClip("MarkerClips",1);
			this.onResize();
		}

		delete this._markerList;
		this._markerList = new Array(a_numMarkers);

		Map.MapMarker.topDepth = a_numMarkers;

		this._nextCreateIndex = 0;
		this.SetSelectedMarker(-1);

		this._locationFinder.list.clearList();
		this._locationFinder.setLoading(true);
	}

	// @API
	public function GetCreatingMarkers()
	{
		return this._nextCreateIndex != -1;
	}

	// @API
	public function CreateMarkers()
	{
		if(this._nextCreateIndex == -1 || this._markerContainer == null)
		{
			return undefined;
		}

		var i = 0;
		var idx = this._nextCreateIndex * Map.MapMenu.CREATE_STRIDE;
		var markersLen = this._markerList.length;
		var dataLen = this.MarkerData.length;
		var markerType;
		var markerName;
		var isUndiscovered;
		var mapMarker;

		while(this._nextCreateIndex < markersLen && idx < dataLen && i < Map.MapMenu.MARKER_CREATE_PER_FRAME)
		{
			markerType = this.MarkerData[idx + Map.MapMenu.CREATE_ICONTYPE];
			markerName = this.MarkerData[idx + Map.MapMenu.CREATE_NAME];
			isUndiscovered = this.MarkerData[idx + Map.MapMenu.CREATE_UNDISCOVERED];

			mapMarker = this._markerContainer.attachMovie("MapMarker","Marker" + this._nextCreateIndex,this._nextCreateIndex,{markerType:markerType,isUndiscovered:isUndiscovered});
			this._markerList[this._nextCreateIndex] = mapMarker;

			if(markerType == this.PlayerLocationMarkerType)
			{
				this.YouAreHereMarker = mapMarker.IconClip;
			}
			mapMarker.index = this._nextCreateIndex;
			mapMarker.label = markerName;
			mapMarker.visible = false;

			// Adding the markers directly so we don't have to create data objects.
			// NOTE: Make sure internal entry properties (mappedIndex etc) dont conflict with marker properties
			if(0 < markerType && markerType < Map.LocationFinder.TYPE_RANGE)
			{
				this._locationFinder.list.entryList.push(mapMarker);
			}

			i = i + 1;
			this._nextCreateIndex = this._nextCreateIndex + 1;
			idx += Map.MapMenu.CREATE_STRIDE;
		}

		this._locationFinder.list.InvalidateData();

		if(this._nextCreateIndex >= markersLen)
		{
			this._locationFinder.setLoading(false);
			this._nextCreateIndex = -1;
		}
	}

	// @API
	public function RefreshMarkers()
	{
		var i = 0;
		var idx = 0;
		var markersLen = this._markerList.length;
		var dataLen = this.MarkerData.length;
		var marker;

		while(i < markersLen && idx < dataLen)
		{
			marker = this._markerList[i];
			marker._visible = this.MarkerData[idx + Map.MapMenu.REFRESH_SHOW];
			if(marker._visible)
			{
				marker._x = this.MarkerData[idx + Map.MapMenu.REFRESH_X] * this._mapWidth;
				marker._y = this.MarkerData[idx + Map.MapMenu.REFRESH_Y] * this._mapHeight;
				marker._rotation = this.MarkerData[idx + Map.MapMenu.REFRESH_ROTATION];
			}
			i = i + 1;
			idx += Map.MapMenu.REFRESH_STRIDE;
		}

		if(this._selectedMarker != undefined)
		{
			this._markerDescriptionHolder._x = this._selectedMarker._x + this._markerContainer._x;
			this._markerDescriptionHolder._y = this._selectedMarker._y + this._markerContainer._y;
		}
	}

	// @API
	public function SetSelectedMarker(a_selectedMarkerIndex)
	{
		var marker = a_selectedMarkerIndex >= 0 ? this._markerList[a_selectedMarkerIndex] : null;

		if(marker == this._selectedMarker)
		{
			return undefined;
		}

		if(this._selectedMarker != null)
		{
			this._selectedMarker.MarkerRollOut();
			this._selectedMarker = null;
			this._markerDescriptionHolder.gotoAndPlay("Hide");
		}

		if(marker != null && !this._bottomBar.hitTest(_root._xmouse,_root._ymouse) && marker.visible && marker.MarkerRollOver())
		{
			this._selectedMarker = marker;
			this._markerDescriptionHolder._visible = true;
			this._markerDescriptionHolder.gotoAndPlay("Show");
			return undefined;
		}

		this._selectedMarker = null;
	}

	// @API
	public function ClickSelectedMarker()
	{
		if(this._selectedMarker != undefined)
		{
			this._selectedMarker.MarkerClick();
		}
	}

	// @API
	public function SetPlatform(a_platform, a_bPS3Switch)
	{
		if(a_platform == Shared.ButtonChange.PLATFORM_PC)
		{
			this._localMapControls = {keyCode:38}; // L
			this._journalControls = {name:"Journal",context: skyui.defines.Input.CONTEXT_GAMEPLAY};
			this._zoomControls = {keyCode:283}; // special: mouse wheel
			this._playerLocControls = {keyCode:18}; // E
			this._setDestControls = {keyCode:256}; // Mouse1
			this._findLocControls = {keyCode:33}; // F
		}
		else
		{
			this._localMapControls = {keyCode:278}; // X
			this._journalControls = {keyCode:270}; // START
			this._zoomControls = [{keyCode:280},{keyCode:281}]; // LT/RT
			this._playerLocControls = {keyCode:279}; // Y
			this._setDestControls = {keyCode:276}; // A
			this._findLocControls = {keyCode:273}; // RS
		}

		if(this._bottomBar != undefined)
		{
			this._bottomBar.buttonPanel.setPlatform(a_platform,a_bPS3Switch);

			this.createButtons(a_platform != Shared.ButtonChange.PLATFORM_PC);
		}

		gfx.managers.InputDelegate.instance.isGamepad = a_platform != Shared.ButtonChange.PLATFORM_PC;
		gfx.managers.InputDelegate.instance.enableControlFixup(true);

		this._platform = a_platform;
	}

	// @API
	public function SetDateString(a_strDate)
	{
		this._bottomBar.DateText.SetText(a_strDate);
	}

	// @API
	public function ShowJournal(a_bShow)
	{
		if(this._bottomBar != undefined)
		{
			this._bottomBar._visible = !a_bShow;
		}
	}

	// @API
	public function SetCurrentLocationEnabled(a_bEnabled)
	{
		if(this._bottomBar != undefined && this._platform == Shared.ButtonChange.PLATFORM_PC)
		{
			this._bottomBar.PlayerLocButton.disabled = !a_bEnabled;
		}
	}

	// @GFx
	public function handleInput(details, pathToFocus)
	{
		var nextClip = pathToFocus.shift();
		if(nextClip.handleInput(details,pathToFocus))
		{
			return true;
		}

		// Find Location - F
		if(this._platform == Shared.ButtonChange.PLATFORM_PC)
		{
			if(Shared.GlobalFunc.IsKeyPressed(details) && details.skseKeycode == 33)
			{
				this.LocalMapMenu.showLocationFinder();
			}
		}

		return false;
	}


	/* PRIVATE FUNCTIONS */

	private function OnLocalButtonClick()
	{
		gfx.io.GameDelegate.call("ToggleMapCallback",[]);
	}

	private function OnJournalButtonClick()
	{
		gfx.io.GameDelegate.call("OpenJournalCallback",[]);
	}

	private function OnPlayerLocButtonClick()
	{
		gfx.io.GameDelegate.call("CurrentLocationCallback",[]);
	}

	private function OnFindLocButtonClick()
	{
		this.LocalMapMenu.showLocationFinder();
	}

	private function onMouseDown()
	{
		if(this._bottomBar.hitTest(_root._xmouse,_root._ymouse))
		{
			return undefined;
		}
		gfx.io.GameDelegate.call("ClickCallback",[]);
	}

	private function onResize()
	{
		this._mapWidth = Stage.visibleRect.right - Stage.visibleRect.left;
		this._mapHeight = Stage.visibleRect.bottom - Stage.visibleRect.top;
		var localMap;

		if(this._mapMovie == _root)
		{
			this._markerContainer._x = Stage.visibleRect.left;
			this._markerContainer._y = Stage.visibleRect.top;
		}
		else
		{
			localMap = Map.LocalMap(this._mapMovie);
			if(localMap != undefined)
			{
				this._mapWidth = localMap.TextureWidth;
				this._mapHeight = localMap.TextureHeight;
			}
		}

		Shared.GlobalFunc.SetLockFunction();
		this._bottomBar.Lock("B");
	}

	private function createButtons(a_bGamepad)
	{
		var buttonPanel = this._bottomBar.buttonPanel;
		buttonPanel.clearButtons();

		this._localMapButton = buttonPanel.addButton({text:"$Local Map",controls: this._localMapControls});        // 0
		this._journalButton = buttonPanel.addButton({text:"$Journal",controls: this._journalControls});            // 1
		buttonPanel.addButton({text:"$Zoom",controls: this._zoomControls});                                        // 2
		this._playerLocButton = buttonPanel.addButton({text:"$Current Location",controls: this._playerLocControls}); // 3
		this._findLocButton = buttonPanel.addButton({text:"$Find Location",controls: this._findLocControls});      // 4
		buttonPanel.addButton({text:"$Set Destination",controls: this._setDestControls});                          // 5
		this._searchButton = buttonPanel.addButton({text:"$Search",controls: skyui.defines.Input.Space});          // 6

		this._localMapButton.addEventListener("click",this,"OnLocalButtonClick");
		this._journalButton.addEventListener("click",this,"OnJournalButtonClick");
		this._playerLocButton.addEventListener("click",this,"OnPlayerLocButtonClick");
		this._findLocButton.addEventListener("click",this,"OnFindLocButtonClick");

		this._localMapButton.disabled = a_bGamepad;
		this._journalButton.disabled = a_bGamepad;
		this._playerLocButton.disabled = a_bGamepad;
		this._findLocButton.disabled = a_bGamepad;

		this._findLocButton.visible = !a_bGamepad;
		this._searchButton.visible = false;

		buttonPanel.updateButtons(true);
	}
}
