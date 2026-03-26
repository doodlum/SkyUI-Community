class Map.LocalMap extends MovieClip
{
   var BottomBar;
   var ClearedDescription;
   var ClearedText;
   var IconDisplay;
   var LocalMapHolder_mc;
   var LocationDescription;
   var LocationTextClip;
   var MapImageLoader;
   var TextureHolder;
   var _TextureHeight;
   var _TextureWidth;
   var bUpdated;
   var _locationFinder;
   static var STATE_HIDDEN = 0;
   static var STATE_LOCALMAP = 1;
   static var STATE_FINDLOCATION = 2;
   var _state = Map.LocalMap.STATE_HIDDEN;
   var _bRequestFindLoc = false;
   function LocalMap()
   {
      super();
      this.IconDisplay = new Map.MapMenu(this);
      this.MapImageLoader = new MovieClipLoader();
      this.MapImageLoader.addListener(this);
      this._TextureWidth = 800;
      this._TextureHeight = 450;
      this.LocationDescription = this.LocationTextClip.LocationText;
      this.LocationDescription.noTranslate = true;
      this.LocationTextClip.swapDepths(3);
      this.ClearedDescription = this.ClearedText;
      this.ClearedDescription.noTranslate = true;
      this.TextureHolder = this.LocalMapHolder_mc;
   }
   function get TextureWidth()
   {
      return this._TextureWidth;
   }
   function get TextureHeight()
   {
      return this._TextureHeight;
   }
   function onLoadInit(TargetClip)
   {
      TargetClip._width = this._TextureWidth;
      TargetClip._height = this._TextureHeight;
   }
   function InitMap()
   {
      Stage.scaleMode = "showAll";
      if(!this.bUpdated)
      {
         this.MapImageLoader.loadClip("img://Local_Map",this.TextureHolder);
         this.bUpdated = true;
      }
      this.updateLocalMapExtends(true);
   }
   function Show(abShow)
   {
      if(abShow)
      {
         if(this._bRequestFindLoc)
            this.setState(Map.LocalMap.STATE_FINDLOCATION);
         else
            this.setState(Map.LocalMap.STATE_LOCALMAP);
      }
      else
      {
         this.setState(Map.LocalMap.STATE_HIDDEN);
      }
      this._bRequestFindLoc = false;
   }
   function SetBottomBar(aBottomBar)
   {
      this.BottomBar = aBottomBar;
   }
   function setLocationFinder(a_locationFinder)
   {
      this._locationFinder = a_locationFinder;
   }
   function showLocationFinder()
   {
      if(this._state == Map.LocalMap.STATE_LOCALMAP)
      {
         this.setState(Map.LocalMap.STATE_FINDLOCATION);
      }
      else if(this._state == Map.LocalMap.STATE_HIDDEN)
      {
         this._bRequestFindLoc = true;
         gfx.io.GameDelegate.call("ToggleMapCallback",[]);
      }
   }

   function setState(a_newState)
   {
      var prevState = this._state;
      
      if(a_newState == Map.LocalMap.STATE_LOCALMAP)
      {
         this.updateLocalMapExtends(true);
         this._parent.gotoAndPlay("fadeIn");
         this.BottomBar.RightButton.visible = false;
         this.BottomBar.LocalMapButton.label = "$World Map";
         
         if(prevState == Map.LocalMap.STATE_FINDLOCATION)
            this._locationFinder.hide(false);
      }
      else if(a_newState == Map.LocalMap.STATE_FINDLOCATION)
      {
         this.updateLocalMapExtends(false);
         if(prevState == Map.LocalMap.STATE_LOCALMAP)
            this._parent.gotoAndPlay("fadeOut");

         this._locationFinder.show();
         this.BottomBar.RightButton.visible = false;
         this.BottomBar.LocalMapButton.label = "$World Map";
      }
      else if(a_newState == Map.LocalMap.STATE_HIDDEN)
      {
         if(prevState == Map.LocalMap.STATE_LOCALMAP)
            this._parent.gotoAndPlay("fadeOut");
         else if(prevState == Map.LocalMap.STATE_FINDLOCATION)
            this._locationFinder.hide(false);

         this.BottomBar.RightButton.visible = true;
         this.BottomBar.LocalMapButton.label = "$Local Map";
      }
      
      this._state = a_newState;
   }

   function updateLocalMapExtends(a_bEnabled)
   {
      if(a_bEnabled)
      {
         var _loc3_ = {x:this._x,y:this._y};
         var _loc2_ = {x:this._x + this._TextureWidth,y:this._y + this._TextureHeight};
         this._parent.localToGlobal(_loc3_);
         this._parent.localToGlobal(_loc2_);
         gfx.io.GameDelegate.call("SetLocalMapExtents",[_loc3_.x,_loc3_.y,_loc2_.x,_loc2_.y]);
      }
      else
      {
         gfx.io.GameDelegate.call("SetLocalMapExtents",[0,0,0,0]);
      }
   }

   function SetTitle(aName, aCleared)
   {
      this.LocationDescription.text = aName == undefined ? "" : aName;
      this.ClearedDescription.text = aCleared == undefined ? "" : "(" + aCleared + ")";
   }
}
