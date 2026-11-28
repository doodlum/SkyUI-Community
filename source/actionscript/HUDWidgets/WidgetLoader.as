class WidgetLoader extends MovieClip
{
   var _hudMetrics;
   var _hudModeDispatcher;
   var _mcLoader;
   var _widgetContainer;
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
      this.loadItemCardConfig();
      this.measureItemCard();
      // config.txt can change while the game runs (the item menus re-read it on every open): keep up with it, so the
      // position applied here never lags behind what the next menu will use.
      setInterval(this,"loadItemCardConfig",WidgetLoader.ITEMCARD_POLL_MS);
   }

   /* 3D ITEM POSITION
    * The game reads the 3D item position when an item menu opens, before the menu's code runs, so it has to be right
    * beforehand. The HUD is always loaded: it reads the item card settings from config.txt, gets the MCM overrides and
    * the item menus' measured layout from Papyrus (SKI_SettingsManager / SKI_ConfigMenu), and applies the position
    * skyui.util.ItemCardLayout computes, the same code the item menus place the card with. */

   var _itemCardFile;          // {entryWidth, align, xOffset, yOffset} from config.txt (undefined until loaded)
   var _itemCardOverrides;     // "Section$key" -> value string, from the MCM
   var _itemCardOverrideKeys;
   var _itemCardMetrics;       // reported by the item menus
   var _itemCardReadySent;
   var _itemCardRaw;           // config.txt text last parsed
   var _itemCardSymbol;        // bounds of the item card symbol in skyui/ItemCard.swf, measured here
   var _itemCardProbeLoader;

   // Short enough that nobody can edit config.txt, switch back to the game and open a menu in between; unchanged file
   // text is not parsed again.
   static var ITEMCARD_POLL_MS = 250;

   static var ITEMCARD_KEYS = {
      ListLayout$defaults$entryWidth: "entryWidth",
      ItemInfo$itemcard$align: "align",
      ItemInfo$itemcard$xOffset: "xOffset",
      ItemInfo$itemcard$yOffset: "yOffset"
   };

   function loadItemCardConfig()
   {
      var loader = this;
      var lv = new LoadVars();
      lv.onData = function(a_data)
      {
         if(a_data != undefined && a_data == loader._itemCardRaw && loader._itemCardFile != undefined)
         {
            loader.updateItem3D();
            return undefined;
         }
         loader._itemCardRaw = a_data;
         loader.parseItemCardConfig(a_data);
      };
      lv.load("skyui/config.txt");
   }

   // Reads the four keys the item card depends on, the way skyui.util.ConfigManager reads config.txt.
   function parseItemCardConfig(a_data)
   {
      var file = {};
      if(a_data != undefined)
      {
         var lines = a_data.split("\r\n");
         if(lines.length == 1)
         {
            lines = a_data.split("\n");
         }
         var section = undefined;
         for(var i = 0; i < lines.length; i++)
         {
            var line = lines[i];
            if(line.charAt(0) == ";")
            {
               continue;
            }
            if(line.charAt(0) == "[")
            {
               section = line.slice(1,line.lastIndexOf("]"));
               continue;
            }
            if(line.length < 3 || section == undefined || line.indexOf("=") == -1)
            {
               continue;
            }
            var key = WidgetLoader.trimItemCardText(line.slice(0,line.indexOf("=")));
            var name = WidgetLoader.ITEMCARD_KEYS[section + "$" + key.split(".").join("$")];
            if(name != undefined)
            {
               file[name] = WidgetLoader.parseItemCardValue(line.slice(line.indexOf("=") + 1));
            }
         }
      }
      this._itemCardFile = file;
      this.updateItem3D();
      if(!this._itemCardReadySent)
      {
         // Ask Papyrus for the MCM overrides and the item menus' metrics (they call the setters below).
         this._itemCardReadySent = true;
         skse.SendModEvent("SKIIM_hudItemCardReady");
      }
   }

   static function parseItemCardValue(a_str)
   {
      var s = WidgetLoader.trimItemCardText(a_str);
      if(s == undefined || s == "")
      {
         return undefined;
      }
      if(!isNaN(s))
      {
         return Number(s);
      }
      if(s.charAt(0) == "'" && s.lastIndexOf("'") > 0)
      {
         return s.slice(1,s.lastIndexOf("'"));
      }
      return s;
   }

   static function trimItemCardText(a_str)
   {
      if(a_str == undefined)
      {
         return undefined;
      }
      var s = String(a_str);
      var i = 0;
      var j = s.length - 1;
      while(i <= j && (s.charAt(i) == " " || s.charAt(i) == "\t"))
      {
         i++;
      }
      while(j >= i && (s.charAt(j) == " " || s.charAt(j) == "\t" || s.charAt(j) == "\r"))
      {
         j--;
      }
      return s.slice(i,j + 1);
   }

   // Same two-phase call as ConfigManager.setExternalOverrideKeys / Values.
   function setItemCardOverrideKeys()
   {
      this._itemCardOverrideKeys = [];
      for(var i = 0; i < arguments.length; i++)
      {
         this._itemCardOverrideKeys[i] = arguments[i];
      }
   }

   function setItemCardOverrideValues()
   {
      this._itemCardOverrides = {};
      for(var i = 0; i < arguments.length; i++)
      {
         var k = this._itemCardOverrideKeys[i];
         if(k != undefined && k != "" && WidgetLoader.ITEMCARD_KEYS[k] != undefined)
         {
            this._itemCardOverrides[WidgetLoader.ITEMCARD_KEYS[k]] = WidgetLoader.parseItemCardValue(arguments[i]);
         }
      }
      this.updateItem3D();
   }

   // Loads the item card on its own (hidden) and measures it, so a replaced item card of a different size is right
   // before any item menu has reported. The ItemCard code only sets itself up (no calls into the game).
   function measureItemCard()
   {
      var holder = _root.createEmptyMovieClip("itemCardProbe",_root.getNextHighestDepth());
      holder._visible = false;
      holder._x = -10000;
      var target = holder.createEmptyMovieClip("swf",1);
      var owner = this;
      var listener = {};
      listener.onLoadInit = function(a_target)
      {
         var card = a_target.attachMovie("ItemCard","card",1);
         if(card != undefined)
         {
            var b = card.getBounds(card);
            if(b.xMax > b.xMin)
            {
               owner._itemCardSymbol = {xMin:b.xMin,xMax:b.xMax,yMin:b.yMin};
            }
         }
         owner._itemCardProbeLoader.unloadClip(a_target);
         holder.removeMovieClip();
         owner.updateItem3D();
      };
      listener.onLoadError = function(a_target)
      {
         holder.removeMovieClip();
      };
      this._itemCardProbeLoader = new MovieClipLoader();
      this._itemCardProbeLoader.addListener(listener);
      this._itemCardProbeLoader.loadClip("skyui/ItemCard.swf",target);
   }

   function setItemCardMetrics(a_panel, a_w, a_xMin, a_xMax, a_yMin, a_y, a_safe, a_ox, a_oy, a_cardX, a_cardY)
   {
      if(isNaN(a_panel) || !(a_w > 0))
      {
         return undefined;
      }
      this._itemCardMetrics = {panel:a_panel,w:a_w,xMin:a_xMin,xMax:a_xMax,yMin:a_yMin,y:a_y,safe:a_safe,ox:a_ox,oy:a_oy,cardX:(isNaN(a_cardX) ? 0 : a_cardX),cardY:(isNaN(a_cardY) ? -24 : a_cardY)};
      // An item menu just opened with whatever config.txt says now: re-read it before computing, so this never writes
      // a position from an older config over the one the menu just set.
      this.loadItemCardConfig();
   }

   function updateItem3D()
   {
      if(this._itemCardFile == undefined)
      {
         return undefined;
      }
      var eff = {};
      for(var k in WidgetLoader.ITEMCARD_KEYS)
      {
         var name = WidgetLoader.ITEMCARD_KEYS[k];
         eff[name] = (this._itemCardOverrides != undefined && this._itemCardOverrides[name] != undefined) ? this._itemCardOverrides[name] : this._itemCardFile[name];
      }
      var settings = skyui.util.ItemCardLayout.cardSettings(eff.entryWidth,eff.align,eff.xOffset,eff.yOffset);
      var vr = skyui.util.ItemCardLayout.visibleRectForAspect(Stage.visibleRect.width / Stage.visibleRect.height);
      var m = this._itemCardMetrics != undefined ? this._itemCardMetrics : skyui.util.ItemCardLayout.DEFAULT_METRICS;
      if(this._itemCardSymbol != undefined)
      {
         // The card measured here reflects the installed skyui/ItemCard.swf even if the saved metrics are older.
         m = skyui.util.ItemCardLayout.withCardSymbol(m,this._itemCardSymbol);
      }
      var pos = skyui.util.ItemCardLayout.predictItem3D(settings,vr,m);
      // Write when the live values differ (not just when this computation changed), so a value set by anything else,
      // another mod or an older SkyUI script, is corrected within one poll.
      if(!skyui.util.ItemCardLayout.isApplied(pos))
      {
         skyui.util.ItemCardLayout.applyItem3D(pos);
      }
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
