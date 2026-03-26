class Map.LocationFinder extends MovieClip
{
   var _foundMarker;
   var _nameFilter;
   var _sortFilter;
   var list;
   var loadIcon;
   var searchWidget;
   static var TYPE_RANGE = 60;
   var _bShown = false;
   function LocationFinder()
   {
      super();
      this._nameFilter = new skyui.filter.NameFilter();
      this._nameFilter.nameAttribute = "_label";
      this._sortFilter = new skyui.filter.SortFilter();
      this._sortFilter.setSortBy(["_label"],[Array.CASEINSENSITIVE]);
   }
   function onLoad()
   {
      var _loc2_ = new skyui.components.list.FilteredEnumeration(this.list.entryList);
      _loc2_.addFilter(this._nameFilter);
      _loc2_.addFilter(this._sortFilter);
      this.list.listEnumeration = _loc2_;
      this._nameFilter.addEventListener("filterChange",this,"onNameFilterChange");
      this.list.addEventListener("itemPress",this,"onLocationListPress");
      this.searchWidget.addEventListener("inputStart",this,"onSearchInputStart");
      this.searchWidget.addEventListener("inputEnd",this,"onSearchInputEnd");
      this.searchWidget.addEventListener("inputChange",this,"onSearchInputChange");
      this.setLoading(false);
      this.hide(true);
   }
   function onNameFilterChange(a_event)
   {
      this.list.requestInvalidate();
   }
   function setLoading(a_bLoading)
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
   function show()
   {
      gfx.managers.FocusHandler.instance.setFocus(this.list,0);
      this._bShown = true;
      this._parent.gotoAndPlay("fadeIn");
      this.searchWidget.isDisabled = false;
      this.list.disableInput = this.list.disableSelection = false;
      this.list.selectedIndex = -1;
      this.clearFoundMarker();
   }
   function hide(a_bInstant)
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
   function handleInput(details, pathToFocus)
   {
      if(this._bShown)
      {
         if(Shared.GlobalFunc.IsKeyPressed(details))
         {
            if(details.skseKeycode == 57)
            {
               this.searchWidget.startInput();
               return true;
            }
         }
      }
      var _loc3_ = pathToFocus.shift();
      return _loc3_.handleInput(details,pathToFocus);
   }
   function onLocationListPress(a_event)
   {
      var _loc2_ = a_event.entry;
      if(_loc2_ == null)
      {
         return undefined;
      }
      this.setFoundMarker(_loc2_);
      skse.ShowOnMap(_loc2_.index);
   }
   function clearFoundMarker()
   {
      if(this._foundMarker)
      {
         this._foundMarker.removeMovieClip();
         this._foundMarker = null;
      }
   }
   function setFoundMarker(a_marker)
   {
      this.clearFoundMarker();
      var _loc3_;
      if(a_marker.IconClip != null)
      {
         _loc3_ = a_marker.IconClip.getNextHighestDepth();
         this._foundMarker = a_marker.IconClip.attachMovie("FoundMarker","foundIcon",_loc3_);
      }
   }
   function onSearchInputStart(event)
   {
      this.list.disableInput = this.list.disableSelection = true;
      gfx.managers.InputDelegate.instance.enableControlFixup(false);
      this._nameFilter.filterText = "";
   }
   function onSearchInputChange(event)
   {
      this._nameFilter.filterText = event.data;
   }
   function onSearchInputEnd(event)
   {
      this.list.disableInput = this.list.disableSelection = false;
      gfx.managers.InputDelegate.instance.enableControlFixup(true);
      this._nameFilter.filterText = event.data;
   }
}
