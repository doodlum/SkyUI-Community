class skyui.util.ConfigManager
{
   static var _config;
   static var _eventDummy;
   static var _timeoutID;
   static var CONFIG_PATH = "skyui/config.txt";
   static var TIMEOUT = 3000;
   static var LOAD_NONE = 0;
   static var LOAD_FILE = 1;
   static var LOAD_PAPYRUS = 2;
   static var _constantTable = {ASCENDING:0,DESCENDING:Array.DESCENDING,CASEINSENSITIVE:Array.CASEINSENSITIVE,NUMERIC:Array.NUMERIC};
   static var _extConstantTableNames = [];
   static var _extConstantTables = {};
   static var _loadPhase = skyui.util.ConfigManager.LOAD_NONE;
   static var _initialized = skyui.util.ConfigManager.initialize();
   static var out_overrides = {};
   static var in_overrideKeys = [];
   function ConfigManager()
   {
   }
   static function initialize()
   {
      skyui.util.GlobalFunctions.addArrayFunctions();
      skyui.util.ConfigManager._eventDummy = {};
      gfx.events.EventDispatcher.initialize(skyui.util.ConfigManager._eventDummy);
      var _loc1_ = new LoadVars();
      _loc1_.onData = skyui.util.ConfigManager.parseData;
      _loc1_.load(skyui.util.ConfigManager.CONFIG_PATH);
      return true;
   }
   static function setExternalOverrideKeys()
   {
      skyui.util.ConfigManager.in_overrideKeys.splice(0);
      var _loc2_ = 0;
      while(_loc2_ < arguments.length)
      {
         skyui.util.ConfigManager.in_overrideKeys[_loc2_] = arguments[_loc2_];
         _loc2_ = _loc2_ + 1;
      }
   }
   static function setExternalOverrideValues()
   {
      if(skyui.util.ConfigManager._loadPhase == skyui.util.ConfigManager.LOAD_NONE)
      {
         return undefined;
      }
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < arguments.length)
      {
         _loc3_ = skyui.util.ConfigManager.in_overrideKeys[_loc2_];
         if(_loc3_ && _loc3_ != "")
         {
            skyui.util.ConfigManager.parseExternalOverride(_loc3_,arguments[_loc2_]);
         }
         _loc2_ = _loc2_ + 1;
      }
      if(skyui.util.ConfigManager._loadPhase != skyui.util.ConfigManager.LOAD_PAPYRUS)
      {
         clearInterval(skyui.util.ConfigManager._timeoutID);
         delete skyui.util.ConfigManager._timeoutID;
         skyui.util.ConfigManager._loadPhase = skyui.util.ConfigManager.LOAD_PAPYRUS;
         skyui.util.ConfigManager._eventDummy.dispatchEvent({type:"configLoad",config:skyui.util.ConfigManager._config});
      }
      else
      {
         skyui.util.ConfigManager._eventDummy.dispatchEvent({type:"configUpdate",config:skyui.util.ConfigManager._config});
      }
   }
   static function registerLoadCallback(a_scope, a_callBack)
   {
      skyui.util.ConfigManager._eventDummy.addEventListener("configLoad",a_scope,a_callBack);
   }
   static function registerUpdateCallback(a_scope, a_callBack)
   {
      skyui.util.ConfigManager._eventDummy.addEventListener("configUpdate",a_scope,a_callBack);
   }
   static function setConstant(a_name, a_value)
   {
      var _loc1_ = typeof a_value;
      if(_loc1_ != "number" && _loc1_ != "boolean" && _loc1_ != "string")
      {
         return undefined;
      }
      skyui.util.ConfigManager._constantTable[a_name] = a_value;
   }
   static function addConstantTable(a_name, a_class)
   {
      skyui.util.ConfigManager._extConstantTableNames.push(a_name);
   }
   static function getConstant(a_name)
   {
      if(skyui.util.ConfigManager._constantTable[a_name] != undefined)
      {
         return skyui.util.ConfigManager._constantTable[a_name];
      }
      var _loc1_ = a_name.split(".");
      if(_loc1_.length < 2)
      {
         return undefined;
      }
      var _loc3_ = _loc1_[_loc1_.length - 2];
      var _loc2_ = _loc1_[_loc1_.length - 1];
      if(skyui.util.ConfigManager._extConstantTables[_loc3_][_loc2_] != undefined)
      {
         return skyui.util.ConfigManager._extConstantTables[_loc3_][_loc2_];
      }
      return undefined;
   }
   static function setOverride(a_section, a_key, a_value, a_valueStr)
   {
      if(skyui.util.ConfigManager._config[a_section] == undefined)
      {
         skyui.util.ConfigManager._config[a_section] = {};
      }
      var _loc3_ = a_key.split(".");
      var _loc4_ = skyui.util.ConfigManager._config[a_section];
      var _loc5_ = null;
      if(_loc3_[0] == "vars")
      {
         _loc5_ = _loc4_.vars[_loc3_[1]];
      }
      var _loc1_ = 0;
      while(_loc1_ < _loc3_.length - 1)
      {
         if(_loc4_[_loc3_[_loc1_]] == undefined)
         {
            _loc4_[_loc3_[_loc1_]] = {};
         }
         _loc4_ = _loc4_[_loc3_[_loc1_]];
         _loc1_ = _loc1_ + 1;
      }
      _loc4_[_loc3_[_loc3_.length - 1]] = a_value;
      a_key = a_key.split(".").join("$");
      var _loc9_ = a_section + "$" + a_key;
      skyui.util.ConfigManager.out_overrides[_loc9_] = a_valueStr;
      skse.SendModEvent("SKICO_setConfigOverride",_loc9_);
      var _loc2_;
      var _loc6_;
      var _loc7_;
      if(_loc5_)
      {
         _loc2_ = 0;
         while(_loc2_ < _loc5_._refLocs.length)
         {
            _loc6_ = _loc5_._refLocs[_loc2_];
            _loc7_ = _loc5_._refKeys[_loc2_];
            _loc6_[_loc7_] = a_value;
            _loc2_ = _loc2_ + 1;
         }
      }
      skyui.util.ConfigManager._eventDummy.dispatchEvent({type:"configUpdate",config:skyui.util.ConfigManager._config});
   }
   static function parseExternalOverride(a_key, a_valueStr)
   {
      var _loc9_ = a_key.indexOf("$");
      var _loc12_ = skyui.util.GlobalFunctions.clean(a_key.slice(0,_loc9_));
      var _loc10_ = skyui.util.GlobalFunctions.clean(a_key.slice(_loc9_ + 1));
      var _loc8_ = skyui.util.ConfigManager.parseValueString(skyui.util.GlobalFunctions.clean(a_valueStr),null);
      var _loc3_ = _loc10_.split("$");
      var _loc4_ = skyui.util.ConfigManager._config[_loc12_];
      var _loc5_ = null;
      if(_loc3_[0] == "vars")
      {
         _loc5_ = _loc4_.vars[_loc3_[1]];
      }
      var _loc1_ = 0;
      while(_loc1_ < _loc3_.length - 1)
      {
         if(_loc4_[_loc3_[_loc1_]] == undefined)
         {
            _loc4_[_loc3_[_loc1_]] = {};
         }
         _loc4_ = _loc4_[_loc3_[_loc1_]];
         _loc1_ = _loc1_ + 1;
      }
      _loc4_[_loc3_[_loc3_.length - 1]] = _loc8_;
      var _loc2_;
      var _loc6_;
      var _loc7_;
      if(_loc5_)
      {
         _loc2_ = 0;
         while(_loc2_ < _loc5_._refLocs.length)
         {
            _loc6_ = _loc5_._refLocs[_loc2_];
            _loc7_ = _loc5_._refKeys[_loc2_];
            _loc6_[_loc7_] = _loc8_;
            _loc2_ = _loc2_ + 1;
         }
      }
   }
   static function parseData(a_data)
   {
      skyui.util.ConfigManager._config = {};
      var _loc4_ = 0;
      var _loc2_;
      var _loc11_;
      var _loc7_;
      var _loc3_;
      while(_loc4_ < skyui.util.ConfigManager._extConstantTableNames.length)
      {
         _loc2_ = skyui.util.ConfigManager._extConstantTableNames[_loc4_].split(".");
         _loc11_ = _loc2_[_loc2_.length - 1];
         _loc7_ = _global[_loc2_[0]];
         _loc3_ = 1;
         while(_loc3_ < _loc2_.length)
         {
            _loc7_ = _loc7_[_loc2_[_loc3_]];
            _loc3_ = _loc3_ + 1;
         }
         skyui.util.ConfigManager._extConstantTables[_loc11_] = _loc7_;
         _loc4_ = _loc4_ + 1;
      }
      var _loc6_ = a_data.split("\r\n");
      if(_loc6_.length == 1)
      {
         _loc6_ = a_data.split("\n");
      }
      var _loc8_;
      _loc4_ = 0;
      var _loc10_;
      var _loc5_;
      var _loc9_;
      while(_loc4_ < _loc6_.length)
      {
         if(_loc6_[_loc4_].charAt(0) != ";")
         {
            if(_loc6_[_loc4_].charAt(0) == "[")
            {
               _loc8_ = _loc6_[_loc4_].slice(1,_loc6_[_loc4_].lastIndexOf("]"));
               if(skyui.util.ConfigManager._config[_loc8_] == undefined)
               {
                  skyui.util.ConfigManager._config[_loc8_] = {};
               }
            }
            else if(!(_loc6_[_loc4_].length < 3 || _loc8_ == undefined))
            {
               _loc10_ = skyui.util.GlobalFunctions.clean(_loc6_[_loc4_].slice(0,_loc6_[_loc4_].indexOf("=")));
               if(_loc10_ != undefined)
               {
                  _loc2_ = _loc10_.split(".");
                  _loc5_ = skyui.util.ConfigManager._config[_loc8_];
                  _loc3_ = 0;
                  while(_loc3_ < _loc2_.length - 1)
                  {
                     if(_loc5_[_loc2_[_loc3_]] == undefined)
                     {
                        _loc5_[_loc2_[_loc3_]] = {};
                     }
                     _loc5_ = _loc5_[_loc2_[_loc3_]];
                     _loc3_ = _loc3_ + 1;
                  }
                  _loc9_ = skyui.util.ConfigManager.parseValueString(skyui.util.GlobalFunctions.clean(_loc6_[_loc4_].slice(_loc6_[_loc4_].indexOf("=") + 1)),skyui.util.ConfigManager._config[_loc8_],_loc5_,_loc2_[_loc2_.length - 1]);
                  if(_loc9_ != undefined)
                  {
                     _loc5_[_loc2_[_loc2_.length - 1]] = _loc9_;
                  }
               }
            }
         }
         _loc4_ = _loc4_ + 1;
      }
      skyui.util.ConfigManager._loadPhase = skyui.util.ConfigManager.LOAD_FILE;
      skyui.util.ConfigManager._timeoutID = setInterval(skyui.util.ConfigManager.onTimeout,skyui.util.ConfigManager.TIMEOUT);
   }
   static function onTimeout()
   {
      clearInterval(skyui.util.ConfigManager._timeoutID);
      delete skyui.util.ConfigManager._timeoutID;
      if(skyui.util.ConfigManager._loadPhase != skyui.util.ConfigManager.LOAD_PAPYRUS)
      {
         skyui.util.ConfigManager._loadPhase = skyui.util.ConfigManager.LOAD_PAPYRUS;
         skyui.util.ConfigManager._eventDummy.dispatchEvent({type:"configLoad",config:skyui.util.ConfigManager._config});
      }
   }
   static function parseValueString(a_str, a_root, a_loc, a_key)
   {
      if(a_str == undefined)
      {
         return undefined;
      }
      var _loc6_;
      if(!isNaN(a_str))
      {
         return Number(a_str);
      }
      if(a_str.toLowerCase() == "true")
      {
         return true;
      }
      if(a_str.toLowerCase() == "false")
      {
         return false;
      }
      if(a_str.toLowerCase() == "undefined")
      {
         return undefined;
      }
      if(a_str.charAt(0) == "\'")
      {
         return skyui.util.GlobalFunctions.extract(a_str,"\'","\'");
      }
      if(a_str.charAt(0) == "@")
      {
         return a_str;
      }
      var _loc8_;
      var _loc11_;
      var _loc3_;
      var _loc2_;
      var _loc5_;
      var _loc7_;
      if(a_str.charAt(0) == "<" && a_str.indexOf(":") != -1)
      {
         _loc8_ = new Object();
         _loc11_ = skyui.util.GlobalFunctions.extract(a_str,"<",">").split(",");
         _loc3_ = 0;
         while(_loc3_ < _loc11_.length)
         {
            _loc2_ = _loc11_[_loc3_].split(":");
            if(_loc2_.length == 2)
            {
               _loc5_ = skyui.util.ConfigManager.parseValueString(skyui.util.GlobalFunctions.clean(_loc2_[0]),a_root,null,null);
               _loc7_ = skyui.util.ConfigManager.parseValueString(skyui.util.GlobalFunctions.clean(_loc2_[1]),a_root,_loc8_,_loc5_);
               _loc8_[_loc5_] = _loc7_;
            }
            _loc3_ = _loc3_ + 1;
         }
         return _loc8_;
      }
      var _loc10_;
      if(a_str.charAt(0) == "<")
      {
         if(a_str.charAt(1) == ">")
         {
            return new Array();
         }
         _loc10_ = skyui.util.GlobalFunctions.extract(a_str,"<",">").split(",");
         _loc3_ = 0;
         while(_loc3_ < _loc10_.length)
         {
            _loc10_[_loc3_] = skyui.util.ConfigManager.parseValueString(skyui.util.GlobalFunctions.clean(_loc10_[_loc3_]),a_root,_loc10_,_loc3_);
            _loc3_ = _loc3_ + 1;
         }
         return _loc10_;
      }
      var _loc9_;
      if(a_str.charAt(0) == "{")
      {
         _loc10_ = skyui.util.GlobalFunctions.extract(a_str,"{","}").split("|");
         _loc9_ = 0;
         _loc3_ = 0;
         while(_loc3_ < _loc10_.length)
         {
            _loc6_ = skyui.util.ConfigManager.parseValueString(skyui.util.GlobalFunctions.clean(_loc10_[_loc3_]),a_root,a_loc,a_key);
            if(isNaN(_loc6_))
            {
               return undefined;
            }
            _loc9_ |= _loc6_;
            _loc3_ = _loc3_ + 1;
         }
         return _loc9_;
      }
      if((_loc6_ = skyui.util.ConfigManager.getConstant(a_str)) != undefined)
      {
         return _loc6_;
      }
      if(a_root.vars[a_str] != undefined)
      {
         if(a_loc && a_key)
         {
            if(a_root.vars[a_str]._refLocs == undefined)
            {
               a_root.vars[a_str]._refLocs = [];
               a_root.vars[a_str]._refKeys = [];
            }
            a_root.vars[a_str]._refLocs.push(a_loc);
            a_root.vars[a_str]._refKeys.push(a_key);
         }
         return a_root.vars[a_str].value;
      }
      return a_str;
   }
}
