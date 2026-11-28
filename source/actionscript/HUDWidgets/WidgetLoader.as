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
   }

   /* 3D ITEM POSITION
    * The game reads the 3D item position when an item menu opens, before the menu's code runs, so it has to be right
    * beforehand. The HUD is always loaded: it reads the item card settings from config.txt, gets the MCM overrides and
    * the item menus' measured layout from Papyrus (SKI_SettingsManager / SKI_ConfigMenu), and applies the position
    * skyui.util.ItemCardLayout computes, the same code the item menus place the card with. */

   // config.txt is read when the HUD loads and again whenever the inventory reports its layout (it re-reads config.txt
   // on every open), so the HUD never computes from an older config.txt than the menus use.
   var _itemCardFile;          // {values: name -> value, vars: section -> {var -> value}} from config.txt
   var _itemCardOverrides;     // name -> value, from the MCM (SKI_SettingsManager)
   var _itemCardVarOverrides;  // section -> {var -> value}, from the MCM
   var _itemCardOverrideKeys;
   var _itemCardMetrics;       // reported by the inventory menu
   var _itemCardReadySent;

   static var ITEMCARD_KEYS = {
      ListLayout$defaults$entryWidth: "entryWidth",
      ItemInfo$itemcard$align: "align",
      ItemInfo$itemcard$xOffset: "xOffset",
      ItemInfo$itemcard$yOffset: "yOffset",
      ItemInfo$item3D$xOffset: "item3DX",
      ItemInfo$item3D$yOffset: "item3DZ",
      ItemInfo$item3D$disabled: "item3DDisabled"
   };

   function loadItemCardConfig()
   {
      var loader = this;
      var lv = new LoadVars();
      lv.onData = function(a_data)
      {
         loader.parseItemCardConfig(a_data);
      };
      lv.load("skyui/config.txt");
   }

   // Reads the keys the item card and 3D item depend on, and the section variables they may refer to, the way
   // skyui.util.ConfigManager reads config.txt (inline "; comments" removed, "name = varName" resolved).
   function parseItemCardConfig(a_data)
   {
      var file = {values:{},vars:{}};
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
            var value = WidgetLoader.parseItemCardValue(line.slice(line.indexOf("=") + 1));
            var parts = key.split(".");
            if(parts.length == 3 && parts[0] == "vars" && parts[2] == "value")
            {
               if(file.vars[section] == undefined)
               {
                  file.vars[section] = {};
               }
               file.vars[section][parts[1]] = value;
               continue;
            }
            var name = WidgetLoader.ITEMCARD_KEYS[section + "$" + parts.join("$")];
            if(name != undefined)
            {
               file.values[name] = value;
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
      var raw = String(a_str);
      // Like GlobalFunctions.clean: drop an inline comment.
      if(raw.indexOf(";") > 0)
      {
         raw = raw.slice(0,raw.indexOf(";"));
      }
      var s = WidgetLoader.trimItemCardText(raw);
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
      this._itemCardVarOverrides = {};
      for(var i = 0; i < arguments.length; i++)
      {
         var k = this._itemCardOverrideKeys[i];
         if(k == undefined || k == "")
         {
            continue;
         }
         if(WidgetLoader.ITEMCARD_KEYS[k] != undefined)
         {
            this._itemCardOverrides[WidgetLoader.ITEMCARD_KEYS[k]] = WidgetLoader.parseItemCardValue(arguments[i]);
            continue;
         }
         // "Section$vars$name$value": an overridden section variable
         var p = k.split("$");
         if(p.length == 4 && p[1] == "vars" && p[3] == "value")
         {
            if(this._itemCardVarOverrides[p[0]] == undefined)
            {
               this._itemCardVarOverrides[p[0]] = {};
            }
            this._itemCardVarOverrides[p[0]][p[2]] = WidgetLoader.parseItemCardValue(arguments[i]);
         }
      }
      this.updateItem3D();
   }

   function setItemCardMetrics(a_panel, a_w, a_xMin, a_xMax, a_yMin, a_y, a_safe, a_ox, a_oy, a_cardX, a_cardY)
   {
      if(isNaN(a_panel) || !(a_w > 0))
      {
         return undefined;
      }
      this._itemCardMetrics = {panel:a_panel,w:a_w,xMin:a_xMin,xMax:a_xMax,yMin:a_yMin,y:a_y,safe:a_safe,ox:a_ox,oy:a_oy,cardX:(isNaN(a_cardX) ? 0 : a_cardX),cardY:(isNaN(a_cardY) ? -24 : a_cardY)};
      // The inventory just opened with whatever config.txt says now: re-read it before computing, so this never writes
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
         var v = (this._itemCardOverrides != undefined && this._itemCardOverrides[name] != undefined) ? this._itemCardOverrides[name] : this._itemCardFile.values[name];
         eff[name] = this.resolveItemCardVar(k.slice(0,k.indexOf("$")),v);
      }
      var settings = skyui.util.ItemCardLayout.cardSettings(eff.entryWidth,eff.align,eff.xOffset,eff.yOffset);
      var vr = skyui.util.ItemCardLayout.visibleRectForAspect(Stage.visibleRect.width / Stage.visibleRect.height);
      var m = this._itemCardMetrics != undefined ? this._itemCardMetrics : skyui.util.ItemCardLayout.DEFAULT_METRICS;

      var item3D = skyui.util.ItemCardLayout.item3DSettings(eff.item3DX,eff.item3DZ,eff.item3DDisabled);
      if(item3D.disabled)
      {
         return undefined;
      }
      var pos = skyui.util.ItemCardLayout.withOffsets(skyui.util.ItemCardLayout.predictItem3D(settings,vr,m),item3D);
      // Write when the live values differ (not just when this computation changed), so a value something else set is
      // replaced too.
      if(!skyui.util.ItemCardLayout.isApplied(pos))
      {
         skyui.util.ItemCardLayout.applyItem3D(pos);
      }
   }

   // A value naming a section variable (vars.<name>.value) resolves to that variable, an MCM override of it first.
   function resolveItemCardVar(a_section, a_value)
   {
      if(typeof a_value != "string")
      {
         return a_value;
      }
      if(this._itemCardVarOverrides != undefined && this._itemCardVarOverrides[a_section] != undefined && this._itemCardVarOverrides[a_section][a_value] != undefined)
      {
         return this._itemCardVarOverrides[a_section][a_value];
      }
      if(this._itemCardFile.vars[a_section] != undefined && this._itemCardFile.vars[a_section][a_value] != undefined)
      {
         return this._itemCardFile.vars[a_section][a_value];
      }
      return a_value;
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
