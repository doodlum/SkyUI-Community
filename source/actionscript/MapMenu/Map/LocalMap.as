class Map.LocalMap extends MovieClip
{
   var ClearedDescription;
   var ClearedText;
   var IconDisplay;
   var LocalMapHolder_mc;
   var LocationDescription;
   var LocationTextClip;
   var TextureHolder;
   var _bottomBar;
   var _locationFinder;
   var _mapImageLoader;
   static var STATE_HIDDEN = 0;
   static var STATE_LOCALMAP = 1;
   static var STATE_FINDLOCATION = 2;
   var _bUpdated = false;
   var _bShow = false;
   var _state = Map.LocalMap.STATE_HIDDEN;
   var _bRequestFindLoc = false;
   var _textureWidth = 800;
   var _textureHeight = 450;
   function LocalMap()
   {
      super();
      this.IconDisplay = new Map.MapMenu(this);
      this._mapImageLoader = new MovieClipLoader();
      this._mapImageLoader.addListener(this);
      this.LocationDescription = this.LocationTextClip.LocationText;
      this.LocationDescription.noTranslate = true;
      this.LocationTextClip.swapDepths(3);
      this.ClearedDescription = this.ClearedText;
      this.ClearedDescription.noTranslate = true;
      this.TextureHolder = this.LocalMapHolder_mc;
   }
   function get TextureWidth()
   {
      return this._textureWidth;
   }
   function get TextureHeight()
   {
      return this._textureHeight;
   }
   function InitMap()
   {
      if(!this._bUpdated)
      {
         this._mapImageLoader.loadClip("img://Local_Map",this.TextureHolder);
         this._bUpdated = true;
      }
      this.updateLocalMapExtends(true);
   }
   function Show(a_bShow)
   {
      this._bShow = a_bShow;
      if(a_bShow)
      {
         if(this._bRequestFindLoc)
         {
            this.setState(Map.LocalMap.STATE_FINDLOCATION);
         }
         else
         {
            this.setState(Map.LocalMap.STATE_LOCALMAP);
         }
      }
      else
      {
         this.setState(Map.LocalMap.STATE_HIDDEN);
      }
      this._bRequestFindLoc = false;
   }
   function SetTitle(a_name, a_cleared)
   {
      this.LocationDescription.text = a_name != undefined ? a_name : "";
      this.ClearedDescription.text = a_cleared != undefined ? "(" + a_cleared + ")" : "";
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
   function setBottomBar(a_bottomBar)
   {
      this._bottomBar = a_bottomBar;
   }
   function setLocationFinder(a_locationFinder)
   {
      this._locationFinder = a_locationFinder;
   }
   function onLoadInit(a_targetClip)
   {
      a_targetClip._width = this._textureWidth;
      a_targetClip._height = this._textureHeight;
   }
   function setState(a_newState)
   {
      var _loc3_ = this._state;
      var _loc2_ = this._bottomBar.buttonPanel;
      if(a_newState == Map.LocalMap.STATE_LOCALMAP)
      {
         this.updateLocalMapExtends(true);
         this._parent.gotoAndPlay("fadeIn");
         this._parent._visible = true;
         _loc2_.button0.label = "$World Map";
         _loc2_.button2.visible = true;
         _loc2_.button3.visible = true;
         if(!_loc2_.button4.disabled)
         {
            _loc2_.button4.visible = true;
         }
         _loc2_.button5.visible = false;
         _loc2_.button6.visible = false;
      }
      else if(a_newState == Map.LocalMap.STATE_FINDLOCATION)
      {
         this.updateLocalMapExtends(false);
         if(_loc3_ == Map.LocalMap.STATE_LOCALMAP)
         {
            this._parent.gotoAndPlay("fadeOut");
            this._parent._visible = true;
         }
         else
         {
            this._parent._visible = false;
         }
         this._locationFinder.show();
         _loc2_.button0.label = "$World Map";
         _loc2_.button2.visible = false;
         _loc2_.button3.visible = false;
         _loc2_.button4.visible = false;
         _loc2_.button5.visible = false;
         _loc2_.button6.visible = true;
      }
      else if(a_newState == Map.LocalMap.STATE_HIDDEN)
      {
         if(_loc3_ == Map.LocalMap.STATE_LOCALMAP)
         {
            this._parent.gotoAndPlay("fadeOut");
         }
         else if(_loc3_ == Map.LocalMap.STATE_FINDLOCATION)
         {
            this._locationFinder.hide();
         }
         this._parent._visible = true;
         _loc2_.button0.label = "$Local Map";
         _loc2_.button2.visible = true;
         _loc2_.button3.visible = true;
         if(!_loc2_.button4.disabled)
         {
            _loc2_.button4.visible = true;
         }
         _loc2_.button5.visible = true;
         _loc2_.button6.visible = false;
      }
      _loc2_.updateButtons(true);
      this._state = a_newState;
   }
   function updateLocalMapExtends(a_bEnabled)
   {
      var _loc3_;
      var _loc2_;
      if(a_bEnabled)
      {
         _loc3_ = {x:this._x,y:this._y};
         _loc2_ = {x:this._x + this._textureWidth,y:this._y + this._textureHeight};
         this._parent.localToGlobal(_loc3_);
         this._parent.localToGlobal(_loc2_);
         gfx.io.GameDelegate.call("SetLocalMapExtents",[_loc3_.x,_loc3_.y,_loc2_.x,_loc2_.y]);
      }
      else
      {
         gfx.io.GameDelegate.call("SetLocalMapExtents",[0,0,0,0]);
      }
   }
}
