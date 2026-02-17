class WidgetLoader extends MovieClip
{
   var _hudMetrics;
   var _hudModeDispatcher;
   var _mcLoader;
   var _widgetContainer;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = WidgetLoader.SKYUI_VERSION_MAJOR + "." + WidgetLoader.SKYUI_VERSION_MINOR + " SE";
   var _rootPath = "";
   function WidgetLoader()
   {
      super();
      this._mcLoader = new MovieClipLoader();
      this._mcLoader.addListener(this);
      skyui.util.GlobalFunctions.addArrayFunctions();
   }
   function onLoad()
   {
      var _loc3_ = {x:Stage.safeRect.x,y:Stage.safeRect.y};
      var _loc4_ = {x:Stage.visibleRect.width - Stage.safeRect.x,y:Stage.visibleRect.height - Stage.safeRect.y};
      _root.globalToLocal(_loc3_);
      _root.globalToLocal(_loc4_);
      this._hudMetrics = {hMin:_loc3_.x,hMax:_loc4_.x,vMin:_loc3_.y,vMax:_loc4_.y};
      var _loc5_ = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
      skse.SendModEvent("SKIWF_hudModeChanged",_loc5_);
      this._hudModeDispatcher = new MovieClip();
      this._hudModeDispatcher.onModeChange = function(a_hudMode)
      {
         skse.SendModEvent("SKIWF_hudModeChanged",a_hudMode);
      };
      _root.HUDMovieBaseInstance.HudElements.push(this._hudModeDispatcher);
      _root.HUDMovieBaseInstance.WeightTranslated._alpha = 0;
      _root.HUDMovieBaseInstance.ValueTranslated._alpha = 0;
      _root.HUDMovieBaseInstance.QuestUpdateBaseInstance.LevelUpTextInstance._alpha = 0;
   }
   function onLoadInit(a_widgetHolder)
   {
      if(a_widgetHolder.widget == undefined)
      {
         skse.SendModEvent("SKIWF_widgetError","WidgetInitFailure",Number(a_widgetHolder._name));
         return undefined;
      }
      a_widgetHolder.onModeChange = function(a_hudMode)
      {
         var _loc2_ = this;
         if(_loc2_.widget.onModeChange != undefined)
         {
            _loc2_.widget.onModeChange(a_hudMode);
         }
      };
      a_widgetHolder.widget.setHudMetrics(this._hudMetrics);
      a_widgetHolder.widget.setRootPath(this._rootPath);
      skse.SendModEvent("SKIWF_widgetLoaded",a_widgetHolder._name);
   }
   function onLoadError(a_widgetHolder, a_errorCode)
   {
      skse.SendModEvent("SKIWF_widgetError","WidgetLoadFailure",Number(a_widgetHolder._name));
   }
   function setRootPath(a_path)
   {
      skse.Log("WidgetLoader.as: setRootPath(a_path = " + a_path + ")");
      this._rootPath = a_path;
   }
   function loadWidgets()
   {
      var _loc5_;
      var _loc6_;
      if(this._widgetContainer != undefined)
      {
         for(var _loc7_ in this._widgetContainer)
         {
            _loc5_ = this._widgetContainer[_loc7_];
            if(_loc5_ != null && _loc5_ instanceof MovieClip)
            {
               this._mcLoader.unloadClip(_loc5_);
               _loc6_ = _root.HUDMovieBaseInstance.HudElements.indexOf(_loc5_);
               if(_loc6_ != undefined)
               {
                  _root.HUDMovieBaseInstance.HudElements.splice(_loc6_,1);
               }
            }
         }
      }
      var _loc4_ = 0;
      while(_loc4_ < arguments.length)
      {
         if(arguments[_loc4_] != undefined && arguments[_loc4_] != "")
         {
            this.loadWidget(String(_loc4_),arguments[_loc4_]);
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   function loadWidget(a_widgetID, a_widgetSource)
   {
      skse.Log("WidgetLoader.as: loadWidget(a_widgetID = " + a_widgetID + ", a_widgetSource = " + a_widgetSource + ")");
      if(this._widgetContainer == undefined)
      {
         this.createWidgetContainer();
      }
      var _loc2_ = this._widgetContainer.createEmptyMovieClip(a_widgetID,this._widgetContainer.getNextHighestDepth());
      this._mcLoader.loadClip(this._rootPath + "widgets/" + a_widgetSource,_loc2_);
   }
   function createWidgetContainer()
   {
      this._widgetContainer = _root.createEmptyMovieClip("WidgetContainer",-16384);
      this._widgetContainer.Lock("TL");
   }
}
