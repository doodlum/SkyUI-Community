class skyui.widgets.WidgetBase extends MovieClip
{
   var _clientInfo;
   var _hudMetrics;
   var _widgetHolder;
   var _widgetID;
   static var MODES = ["All","Favor","MovementDisabled","Swimming","WarHorseMode","HorseMode","InventoryMode","BookMode","DialogueMode","StealthMode","SleepWaitMode","BarterMode","TweenMode","WorldMapMode","JournalMode","CartMode","VATSPlayback"];
   static var MODEMAP = {all:"All",favor:"Favor",movementdisabled:"MovementDisabled",swimming:"Swimming",warhorsemode:"WarHorseMode",horsemode:"HorseMode",inventorymode:"InventoryMode",bookmode:"BookMode",dialoguemode:"DialogueMode",stealthmode:"StealthMode",sleepwaitmode:"SleepWaitMode",bartermode:"BarterMode",tweenmode:"TweenMode",worldmapmode:"WorldMapMode",journalmode:"JournalMode",cartmode:"CartMode",vatsplayback:"VATSPlayback"};
   static var ANCHOR_LEFT = "left";
   static var ANCHOR_RIGHT = "right";
   static var ANCHOR_CENTER = "center";
   static var ANCHOR_TOP = "top";
   static var ANCHOR_BOTTOM = "bottom";
   var _rootPath = "";
   var __x = 0;
   var __y = 0;
   var _vAnchor = "top";
   var _hAnchor = "left";
   function WidgetBase()
   {
      super();
      this._clientInfo = {};
      this._widgetHolder = this._parent;
      this._widgetID = this._widgetHolder._name;
      if(_global.gfxPlayer)
      {
         _global.gfxExtensions = true;
      }
      else
      {
         this._widgetHolder._visible = false;
      }
   }
   function setRootPath(a_path)
   {
      this._rootPath = a_path;
   }
   function setHudMetrics(a_hudMetrics)
   {
      this._hudMetrics = a_hudMetrics;
   }
   function setClientInfo(a_clientString)
   {
      var _loc8_ = this;
      var _loc3_ = new Object();
      var _loc7_ = 0;
      var _loc4_ = a_clientString.indexOf("<");
      var _loc5_ = a_clientString.indexOf("(");
      var _loc6_ = a_clientString.indexOf(")");
      _loc3_.scriptName = a_clientString.slice(_loc7_ + 1,_loc4_ - 1);
      _loc3_.formName = a_clientString.slice(_loc4_ + 1,_loc5_ - 1);
      _loc3_.formID = a_clientString.slice(_loc5_ + 1,_loc6_);
      _loc8_.clientInfo = _loc3_;
   }
   function setModes()
   {
      var _loc6_ = 0;
      var _loc4_ = 0;
      while(_loc4_ < skyui.widgets.WidgetBase.MODES.length)
      {
         delete this._widgetHolder[skyui.widgets.WidgetBase.MODES[_loc4_]];
         _loc4_ = _loc4_ + 1;
      }
      _loc4_ = 0;
      var _loc5_;
      while(_loc4_ < arguments.length)
      {
         _loc5_ = skyui.widgets.WidgetBase.MODEMAP[arguments[_loc4_].toLowerCase()];
         if(_loc5_ != undefined)
         {
            this._widgetHolder[_loc5_] = true;
            _loc6_ = _loc6_ + 1;
         }
         _loc4_ = _loc4_ + 1;
      }
      if(_loc6_ == 0)
      {
         skse.SendModEvent("SKIWF_widgetError","NoValidModes",Number(this._widgetID));
      }
      var _loc7_ = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
      this._widgetHolder._visible = this._widgetHolder.hasOwnProperty(_loc7_);
      _root.HUDMovieBaseInstance.HudElements.push(this._widgetHolder);
   }
   function setHAnchor(a_hAnchor)
   {
      var _loc2_ = a_hAnchor.toLowerCase();
      if(this._hAnchor == _loc2_)
      {
         return undefined;
      }
      this._hAnchor = _loc2_;
      this.invalidateSize();
   }
   function setVAnchor(a_vAnchor)
   {
      var _loc2_ = a_vAnchor.toLowerCase();
      if(this._vAnchor == _loc2_)
      {
         return undefined;
      }
      this._vAnchor = _loc2_;
      this.invalidateSize();
   }
   function setPositionX(a_positionX)
   {
      this.__x = a_positionX;
      this.updatePosition();
   }
   function setPositionY(a_positionY)
   {
      this.__y = a_positionY;
      this.updatePosition();
   }
   function setAlpha(a_alpha)
   {
      this._alpha = a_alpha;
   }
   function tweenTo(a_newX, a_newY, a_duration)
   {
      var _loc4_ = Shared.GlobalFunc.Lerp(- this._hudMetrics.hMin,this._hudMetrics.hMax,0,1280,a_newX);
      var _loc3_ = Shared.GlobalFunc.Lerp(- this._hudMetrics.vMin,this._hudMetrics.vMax,0,720,a_newY);
      var _loc2_ = Math.max(0,a_duration || 0);
      skyui.util.Tween.LinearTween(this,"_x",this._x,_loc4_,_loc2_,null);
      skyui.util.Tween.LinearTween(this,"_y",this._y,_loc3_,_loc2_,null);
   }
   function fadeTo(a_alpha, a_duration)
   {
      var _loc2_ = Math.max(0,a_duration || 0);
      skyui.util.Tween.LinearTween(this,"_alpha",this._alpha,a_alpha,_loc2_,null);
   }
   function getWidth()
   {
      return this._width;
   }
   function getHeight()
   {
      return this._height;
   }
   function invalidateSize()
   {
      this.updateAnchor();
   }
   function updateAnchor()
   {
      var _loc3_ = this.getWidth();
      var _loc2_ = this.getHeight();
      if(this._hAnchor == skyui.widgets.WidgetBase.ANCHOR_RIGHT)
      {
         this._widgetHolder._x = - _loc3_;
      }
      else if(this._hAnchor == skyui.widgets.WidgetBase.ANCHOR_CENTER)
      {
         this._widgetHolder._x = (- _loc3_) / 2;
      }
      else
      {
         this._widgetHolder._x = 0;
      }
      if(this._vAnchor == skyui.widgets.WidgetBase.ANCHOR_BOTTOM)
      {
         this._widgetHolder._y = - _loc2_;
      }
      else if(this._vAnchor == skyui.widgets.WidgetBase.ANCHOR_CENTER)
      {
         this._widgetHolder._y = (- _loc2_) / 2;
      }
      else
      {
         this._widgetHolder._y = 0;
      }
      this.updatePosition();
   }
   function updatePosition()
   {
      this._x = Shared.GlobalFunc.Lerp(- this._hudMetrics.hMin,this._hudMetrics.hMax,0,1280,this.__x);
      this._y = Shared.GlobalFunc.Lerp(- this._hudMetrics.vMin,this._hudMetrics.vMax,0,720,this.__y);
   }
}
