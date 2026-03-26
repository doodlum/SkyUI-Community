class Map.MapMarker extends gfx.controls.Button
{
   var HitArea;
   var IconClip;
   var __set__disableFocus;
   var _markerSize;
   var _parent;
   var _visible;
   var gotoAndPlay;
   var hitArea;
   var isUndiscovered;
   var markerType;
   var onRollOut;
   var onRollOver;
   var removeMovieClip;
   var state;
   var swapDepths;
   static var ICON_MAP = ["EmptyMarker","CityMarker","TownMarker","SettlementMarker","CaveMarker","CampMarker","FortMarker","NordicRuinMarker","DwemerMarker","ShipwreckMarker","GroveMarker","LandmarkMarker","DragonlairMarker","FarmMarker","WoodMillMarker","MineMarker","ImperialCampMarker","StormcloakCampMarker","DoomstoneMarker","WheatMillMarker","SmelterMarker","StableMarker","ImperialTowerMarker","ClearingMarker","PassMarker","AltarMarker","RockMarker","LighthouseMarker","OrcStrongholdMarker","GiantCampMarker","ShackMarker","NordicTowerMarker","NordicDwellingMarker","DocksMarker","ShrineMarker","RiftenCastleMarker","RiftenCapitolMarker","WindhelmCastleMarker","WindhelmCapitolMarker","WhiterunCastleMarker","WhiterunCapitolMarker","SolitudeCastleMarker","SolitudeCapitolMarker","MarkarthCastleMarker","MarkarthCapitolMarker","WinterholdCastleMarker","WinterholdCapitolMarker","MorthalCastleMarker","MorthalCapitolMarker","FalkreathCastleMarker","FalkreathCapitolMarker","DawnstarCastleMarker","DawnstarCapitolMarker","DLC02MiraakTempleMarker","DLC02RavenRockMarker","DLC02StandingStonesMarker","DLC02TelvanniTowerMarker","DLC02ToSkyrimMarker","DLC02ToSolstheimMarker","DLC02CastleKarstaagMarker","","DoorMarker","QuestTargetMarker","QuestTargetDoorMarker","MultipleQuestTargetMarker","PlayerSetMarker","YouAreHereMarker"];
   static var UNDISCOVERED_OFFSET = 80;
   static var MARKER_BASE_SIZE = 30;
   static var MARKER_SCALE_MAX = 150;
   static var MARKER_ALPHA_MIN = 60;
   static var TWEEN_TIME = 0.2;
   static var topDepth = 0;
   var index = -1;
   var _fadingIn = false;
   var _fadingOut = false;
   var iconFrame = 1;
   var _iconName = "";
   function MapMarker()
   {
      super();
      this.hitArea = this.HitArea;
      this.disableFocus = true;
      this._markerSize = Map.MapMarker.MARKER_BASE_SIZE;
      this._iconName = Map.MapMarker.ICON_MAP[this.markerType];
      this.iconFrame = this._iconName != null ? this.markerType : 0;
      this.iconFrame += (this.isUndiscovered != true ? 0 : Map.MapMarker.UNDISCOVERED_OFFSET) + 1;
   }
   function get FadingIn()
   {
      return this._fadingIn;
   }
   function set FadingIn(value)
   {
      if(value != this._fadingIn)
      {
         this._fadingIn = value;
         if(this._fadingIn)
         {
            this._visible = true;
            this.gotoAndPlay("fade_in");
         }
      }
   }
   function get FadingOut()
   {
      return this._fadingOut;
   }
   function set FadingOut(value)
   {
      if(value != this._fadingOut)
      {
         this._fadingOut = value;
         if(this._fadingOut)
         {
            this.gotoAndPlay("fade_out");
         }
      }
   }
   function configUI()
   {
      super.configUI();
      this.onRollOver = function()
      {
      };
      this.onRollOut = function()
      {
      };
      var _loc4_ = this.IconClip.iconHolder;
      var _loc3_ = _loc4_.icon;
      _loc4_.background._visible = false;
      _loc3_.gotoAndStop(this.iconFrame);
      this.IconClip._alpha = Map.MapMarker.MARKER_ALPHA_MIN;
      switch(this._iconName)
      {
         case "MineMarker":
         case "SmelterMarker":
         case "StableMarker":
         case "CampMarker":
         case "CaveMarker":
         case "GiantCampMarker":
         case "GroveMarker":
         case "SettlementMarker":
         case "ShackMarker":
         case "AltarMarker":
         case "ClearingMarker":
         case "FarmMarker":
         case "NordicDwellingMarker":
         case "WheatMillMarker":
         case "WoodMillMarker":
            this._markerSize -= this._markerSize / 3;
            break;
         case "DoorMarker":
            this.IconClip._alpha = 100;
            break;
         case "YouAreHereMarker":
         case "QuestTargetMarker":
         case "MultipleQuestTargetMarker":
            this.IconClip.gotoAndPlay("StartBlink");
         case "CityMarker":
         case "TownMarker":
         case "RiftenCapitolMarker":
         case "WindhelmCapitolMarker":
         case "WhiterunCapitolMarker":
         case "SolitudeCapitolMarker":
         case "MarkarthCapitolMarker":
         case "WinterholdCapitolMarker":
         case "MorthalCapitolMarker":
         case "FalkreathCapitolMarker":
         case "DawnstarCapitolMarker":
         case "PlayerSetMarker":
            this._markerSize += this._markerSize / 3;
            break;
         case "QuestTargetDoorMarker":
            this.IconClip.gotoAndPlay("StartBlink");
            this._markerSize += 2 * this._markerSize / 3;
            break;
         case "EmptyMarker":
            this.IconClip._alpha = 0;
      }
      if(_loc3_._width > _loc3_._height)
      {
         _loc3_._height *= this._markerSize / _loc3_._width;
         _loc3_._width = this._markerSize;
      }
      else
      {
         _loc3_._width *= this._markerSize / _loc3_._height;
         _loc3_._height = this._markerSize;
      }
   }
   function setState(a_state)
   {
      if(this._fadingOut || this._fadingIn)
      {
         return undefined;
      }
      super.setState(a_state);
      switch(this._iconName)
      {
         case "PlayerSetMarker":
         case "DoorMarker":
         default:
            if(this._iconName != "PlayerSetMarker")
            {
               if(a_state == "over")
               {
                  skyui.util.Tween.LinearTween(this.IconClip,"_xscale",100,Map.MapMarker.MARKER_SCALE_MAX,Map.MapMarker.TWEEN_TIME,null);
                  skyui.util.Tween.LinearTween(this.IconClip,"_yscale",100,Map.MapMarker.MARKER_SCALE_MAX,Map.MapMarker.TWEEN_TIME,null);
               }
               else
               {
                  skyui.util.Tween.LinearTween(this.IconClip,"_xscale",Map.MapMarker.MARKER_SCALE_MAX,100,Map.MapMarker.TWEEN_TIME,null);
                  skyui.util.Tween.LinearTween(this.IconClip,"_yscale",Map.MapMarker.MARKER_SCALE_MAX,100,Map.MapMarker.TWEEN_TIME,null);
               }
            }
            if(this._iconName != "DoorMarker")
            {
               if(a_state == "over")
               {
                  skyui.util.Tween.LinearTween(this.IconClip,"_alpha",Map.MapMarker.MARKER_ALPHA_MIN,100,Map.MapMarker.TWEEN_TIME,null);
               }
               else
               {
                  skyui.util.Tween.LinearTween(this.IconClip,"_alpha",100,Map.MapMarker.MARKER_ALPHA_MIN,Map.MapMarker.TWEEN_TIME,null);
               }
            }
         case "QuestTargetMarker":
         case "QuestTargetDoorMarker":
         case "MultipleQuestTargetMarker":
         case "YouAreHereMarker":
            return;
      }
   }
   function MarkerRollOver()
   {
      if(this.IconClip.foundIcon)
      {
         skyui.util.Tween.LinearTween(this.IconClip.foundIcon,"_alpha",100,0,Map.MapMarker.TWEEN_TIME,mx.utils.Delegate.create(this.IconClip.foundIcon,this.removeMovieClip));
      }
      var _loc2_ = false;
      this.setState("over");
      _loc2_ = this.state == "over";
      var _loc3_;
      if(_loc2_)
      {
         _loc3_ = this._parent.getInstanceAtDepth(Map.MapMarker.topDepth);
         if(_loc3_ != null)
         {
            _loc3_.swapDepths(Map.MapMarker(_loc3_).index);
         }
         this.swapDepths(Map.MapMarker.topDepth);
         gfx.io.GameDelegate.call("PlaySound",["UIMapRollover"]);
      }
      return _loc2_;
   }
   function MarkerRollOut()
   {
      this.setState("out");
   }
   function MarkerClick()
   {
      gfx.io.GameDelegate.call("MarkerClick",[this.index]);
   }
}
