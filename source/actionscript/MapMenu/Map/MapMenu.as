class Map.MapMenu
{
   var LocalMapMenu;
   var MarkerData;
   var MarkerDescriptionObj;
   var PlayerLocationMarkerType;
   var YouAreHereMarker;
   var _bottomBar;
   var _findLocButton;
   var _findLocControls;
   var _journalButton;
   var _journalControls;
   var _localMapButton;
   var _localMapControls;
   var _locationFinder;
   var _mapMovie;
   var _markerContainer;
   var _markerDescriptionHolder;
   var _markerList;
   var _platform;
   var _playerLocButton;
   var _playerLocControls;
   var _searchButton;
   var _selectedMarker;
   var _setDestControls;
   var _zoomControls;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = Map.MapMenu.SKYUI_VERSION_MAJOR + "." + Map.MapMenu.SKYUI_VERSION_MINOR + " SE";
   static var REFRESH_SHOW = 0;
   static var REFRESH_X = 1;
   static var REFRESH_Y = 2;
   static var REFRESH_ROTATION = 3;
   static var REFRESH_STRIDE = 4;
   static var CREATE_NAME = 0;
   static var CREATE_ICONTYPE = 1;
   static var CREATE_UNDISCOVERED = 2;
   static var CREATE_STRIDE = 3;
   static var MARKER_CREATE_PER_FRAME = 10;
   var _nextCreateIndex = -1;
   var _mapWidth = 0;
   var _mapHeight = 0;
   var bPCControlsReady = true;
   function MapMenu(a_mapMovie)
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
   function InitExtensions()
   {
      Stage.scaleMode = "showAll";
      skse.EnableMapMenuMouseWheel(true);
   }
   function initialize()
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
   function SetNumMarkers(a_numMarkers)
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
   function GetCreatingMarkers()
   {
      return this._nextCreateIndex != -1;
   }
   function CreateMarkers()
   {
      if(this._nextCreateIndex == -1 || this._markerContainer == null)
      {
         return undefined;
      }
      var _loc6_ = 0;
      var _loc3_ = this._nextCreateIndex * Map.MapMenu.CREATE_STRIDE;
      var _loc8_ = this._markerList.length;
      var _loc9_ = this.MarkerData.length;
      var _loc4_;
      var _loc5_;
      var _loc7_;
      var _loc2_;
      while(this._nextCreateIndex < _loc8_ && _loc3_ < _loc9_ && _loc6_ < Map.MapMenu.MARKER_CREATE_PER_FRAME)
      {
         _loc4_ = this.MarkerData[_loc3_ + Map.MapMenu.CREATE_ICONTYPE];
         _loc5_ = this.MarkerData[_loc3_ + Map.MapMenu.CREATE_NAME];
         _loc7_ = this.MarkerData[_loc3_ + Map.MapMenu.CREATE_UNDISCOVERED];
         _loc2_ = this._markerContainer.attachMovie("MapMarker","Marker" + this._nextCreateIndex,this._nextCreateIndex,{markerType:_loc4_,isUndiscovered:_loc7_});
         this._markerList[this._nextCreateIndex] = _loc2_;
         if(_loc4_ == this.PlayerLocationMarkerType)
         {
            this.YouAreHereMarker = _loc2_.IconClip;
         }
         _loc2_.index = this._nextCreateIndex;
         _loc2_.label = _loc5_;
         _loc2_.visible = false;
         if(0 < _loc4_ && _loc4_ < Map.LocationFinder.TYPE_RANGE)
         {
            this._locationFinder.list.entryList.push(_loc2_);
         }
         _loc6_ = _loc6_ + 1;
         this._nextCreateIndex = this._nextCreateIndex + 1;
         _loc3_ += Map.MapMenu.CREATE_STRIDE;
      }
      this._locationFinder.list.InvalidateData();
      if(this._nextCreateIndex >= _loc8_)
      {
         this._locationFinder.setLoading(false);
         this._nextCreateIndex = -1;
      }
   }
   function RefreshMarkers()
   {
      var _loc4_ = 0;
      var _loc3_ = 0;
      var _loc6_ = this._markerList.length;
      var _loc5_ = this.MarkerData.length;
      var _loc2_;
      while(_loc4_ < _loc6_ && _loc3_ < _loc5_)
      {
         _loc2_ = this._markerList[_loc4_];
         _loc2_._visible = this.MarkerData[_loc3_ + Map.MapMenu.REFRESH_SHOW];
         if(_loc2_._visible)
         {
            _loc2_._x = this.MarkerData[_loc3_ + Map.MapMenu.REFRESH_X] * this._mapWidth;
            _loc2_._y = this.MarkerData[_loc3_ + Map.MapMenu.REFRESH_Y] * this._mapHeight;
            _loc2_._rotation = this.MarkerData[_loc3_ + Map.MapMenu.REFRESH_ROTATION];
         }
         _loc4_ = _loc4_ + 1;
         _loc3_ += Map.MapMenu.REFRESH_STRIDE;
      }
      if(this._selectedMarker != undefined)
      {
         this._markerDescriptionHolder._x = this._selectedMarker._x + this._markerContainer._x;
         this._markerDescriptionHolder._y = this._selectedMarker._y + this._markerContainer._y;
      }
   }
   function SetSelectedMarker(a_selectedMarkerIndex)
   {
      var _loc3_ = a_selectedMarkerIndex >= 0 ? this._markerList[a_selectedMarkerIndex] : null;
      if(_loc3_ == this._selectedMarker)
      {
         return undefined;
      }
      if(this._selectedMarker != null)
      {
         this._selectedMarker.MarkerRollOut();
         this._selectedMarker = null;
         this._markerDescriptionHolder.gotoAndPlay("Hide");
      }
      if(_loc3_ != null && !this._bottomBar.hitTest(_root._xmouse,_root._ymouse) && _loc3_.visible && _loc3_.MarkerRollOver())
      {
         this._selectedMarker = _loc3_;
         this._markerDescriptionHolder._visible = true;
         this._markerDescriptionHolder.gotoAndPlay("Show");
         return undefined;
      }
      this._selectedMarker = null;
   }
   function ClickSelectedMarker()
   {
      if(this._selectedMarker != undefined)
      {
         this._selectedMarker.MarkerClick();
      }
   }
   function SetPlatform(a_platform, a_bPS3Switch)
   {
      if(a_platform == Shared.ButtonChange.PLATFORM_PC)
      {
         this._localMapControls = {keyCode:38};
         this._journalControls = {name:"Journal",context:skyui.defines.Input.CONTEXT_GAMEPLAY};
         this._zoomControls = {keyCode:283};
         this._playerLocControls = {keyCode:18};
         this._setDestControls = {keyCode:256};
         this._findLocControls = {keyCode:33};
      }
      else
      {
         this._localMapControls = {keyCode:278};
         this._journalControls = {keyCode:270};
         this._zoomControls = [{keyCode:280},{keyCode:281}];
         this._playerLocControls = {keyCode:279};
         this._setDestControls = {keyCode:276};
         this._findLocControls = {keyCode:273};
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
   function SetDateString(a_strDate)
   {
      this._bottomBar.DateText.SetText(a_strDate);
   }
   function ShowJournal(a_bShow)
   {
      if(this._bottomBar != undefined)
      {
         this._bottomBar._visible = !a_bShow;
      }
   }
   function SetCurrentLocationEnabled(a_bEnabled)
   {
      if(this._bottomBar != undefined && this._platform == Shared.ButtonChange.PLATFORM_PC)
      {
         this._bottomBar.PlayerLocButton.disabled = !a_bEnabled;
      }
   }
   function handleInput(details, pathToFocus)
   {
      var _loc3_ = pathToFocus.shift();
      if(_loc3_.handleInput(details,pathToFocus))
      {
         return true;
      }
      if(this._platform == Shared.ButtonChange.PLATFORM_PC || skse.version != undefined)
      {
         if(Shared.GlobalFunc.IsKeyPressed(details) && (details.skseKeycode == this._findLocControls.keyCode))
         {
            this.LocalMapMenu.showLocationFinder();
         }
      }
      return false;
   }
   function OnLocalButtonClick()
   {
      gfx.io.GameDelegate.call("ToggleMapCallback",[]);
   }
   function OnJournalButtonClick()
   {
      gfx.io.GameDelegate.call("OpenJournalCallback",[]);
   }
   function OnPlayerLocButtonClick()
   {
      gfx.io.GameDelegate.call("CurrentLocationCallback",[]);
   }
   function OnFindLocButtonClick()
   {
      this.LocalMapMenu.showLocationFinder();
   }
   function onMouseDown()
   {
      if(this._bottomBar.hitTest(_root._xmouse,_root._ymouse))
      {
         return undefined;
      }
      gfx.io.GameDelegate.call("ClickCallback",[]);
   }
   function onResize()
   {
      this._mapWidth = Stage.visibleRect.right - Stage.visibleRect.left;
      this._mapHeight = Stage.visibleRect.bottom - Stage.visibleRect.top;
      var _loc3_;
      if(this._mapMovie == _root)
      {
         this._markerContainer._x = Stage.visibleRect.left;
         this._markerContainer._y = Stage.visibleRect.top;
      }
      else
      {
         _loc3_ = Map.LocalMap(this._mapMovie);
         if(_loc3_ != undefined)
         {
            this._mapWidth = _loc3_.TextureWidth;
            this._mapHeight = _loc3_.TextureHeight;
         }
      }
      Shared.GlobalFunc.SetLockFunction();
      this._bottomBar.Lock("B");
      var marginBottomBar = 12;
      this._bottomBar._y += Stage.safeRect.y + marginBottomBar;
   }
   function createButtons(a_bGamepad)
   {
      var _loc2_ = this._bottomBar.buttonPanel;
      _loc2_.clearButtons();
      this._localMapButton = _loc2_.addButton({text:"$Local Map",controls:this._localMapControls});
      this._journalButton = _loc2_.addButton({text:"$Journal",controls:this._journalControls});
      _loc2_.addButton({text:"$Zoom",controls:this._zoomControls});
      this._playerLocButton = _loc2_.addButton({text:"$Current Location",controls:this._playerLocControls});
      this._findLocButton = _loc2_.addButton({text:"$Find Location",controls:this._findLocControls});
      _loc2_.addButton({text:"$Set Destination",controls:this._setDestControls});
      this._searchButton = _loc2_.addButton({text:"$Search",controls:skyui.defines.Input.Space});
      this._localMapButton.addEventListener("click",this,"OnLocalButtonClick");
      this._journalButton.addEventListener("click",this,"OnJournalButtonClick");
      this._playerLocButton.addEventListener("click",this,"OnPlayerLocButtonClick");
      this._findLocButton.addEventListener("click",this,"OnFindLocButtonClick");
      this._localMapButton.disabled = a_bGamepad;
      this._journalButton.disabled = a_bGamepad;
      this._playerLocButton.disabled = a_bGamepad;
      this._findLocButton.disabled = a_bGamepad;
      this._findLocButton.visible = (skse.version == undefined) ? !a_bGamepad : a_bGamepad;
      this._searchButton.visible = false;
      _loc2_.updateButtons(true);
   }
}
