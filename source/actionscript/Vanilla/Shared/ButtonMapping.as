class Shared.ButtonMapping
{
   var m_ButtonMap;
   var m_DefaultMap;
   var m_ownerName;
   static var s_ButtonMapping = null;
   function ButtonMapping(ownerName)
   {
      this.m_ownerName = ownerName;
      trace("ButtonMapping::ButtonMapping " + this.m_ownerName);
      this.m_ButtonMap = new Array();
      this.m_DefaultMap = new Array();
      this.m_DefaultMap.push({mapName:"Right Attack/Block",buttonName:"Mouse1"});
      this.m_DefaultMap.push({mapName:"Left Attack/Block",buttonName:"Mouse2"});
      this.m_DefaultMap.push({mapName:"Pause",buttonName:"Esc"});
      this.m_DefaultMap.push({mapName:"Tween Menu",buttonName:"Tab"});
      this.m_DefaultMap.push({mapName:"Favorites",buttonName:"Q"});
      this.m_DefaultMap.push({mapName:"Forward",buttonName:"W"});
      this.m_DefaultMap.push({mapName:"Activate",buttonName:"E"});
      this.m_DefaultMap.push({mapName:"Ready Weapon",buttonName:"R"});
      this.m_DefaultMap.push({mapName:"Wait",buttonName:"T"});
      this.m_DefaultMap.push({mapName:"Quick Inventory",buttonName:"I"});
      this.m_DefaultMap.push({mapName:"Quick Magic",buttonName:"P"});
      this.m_DefaultMap.push({mapName:"Sneak",buttonName:"L-Ctrl"});
      this.m_DefaultMap.push({mapName:"Strafe Left",buttonName:"A"});
      this.m_DefaultMap.push({mapName:"Back",buttonName:"S"});
      this.m_DefaultMap.push({mapName:"Strafe Right",buttonName:"D"});
      this.m_DefaultMap.push({mapName:"Toggle POV",buttonName:"F"});
      this.m_DefaultMap.push({mapName:"Journal",buttonName:"J"});
      this.m_DefaultMap.push({mapName:"Run",buttonName:"L-Shift"});
      this.m_DefaultMap.push({mapName:"Shout",buttonName:"Z"});
      this.m_DefaultMap.push({mapName:"Auto-Move",buttonName:"C"});
      this.m_DefaultMap.push({mapName:"Quick Map",buttonName:"M"});
      this.m_DefaultMap.push({mapName:"Quick Stats",buttonName:"Slash"});
      this.m_DefaultMap.push({mapName:"Sprint",buttonName:"L-Alt"});
      this.m_DefaultMap.push({mapName:"Jump",buttonName:"Space"});
      this.m_DefaultMap.push({mapName:"Toggle Always Run",buttonName:"CapsLock"});
      this.m_DefaultMap.push({mapName:"Quicksave",buttonName:"F5"});
      this.m_DefaultMap.push({mapName:"Quickload",buttonName:"F9"});
      gfx.io.GameDelegate.addCallBack("SetButtonMapping",this,"SetButtonMapping");
   }
   function SetButtonMapping(buttonMapping)
   {
      trace("ButtonMapping::SetButtonMapping " + this.m_ownerName);
      this.m_ButtonMap = buttonMapping;
   }
   function buildTraceString(desc)
   {
      return desc + "::" + this.m_ownerName + " ";
   }
   function findMappedButtonFromDefault(defaultButton)
   {
      trace(this.buildTraceString("ButtonMapping::FindMappedButtonFromDefault") + "find button " + defaultButton);
      var _loc2_;
      var _loc3_;
      if(this.m_ButtonMap.length > 0)
      {
         _loc2_ = 0;
         while(_loc2_ < this.m_DefaultMap.length)
         {
            _loc3_ = this.m_DefaultMap[_loc2_];
            if(_loc3_.buttonName == defaultButton)
            {
               trace(this.buildTraceString("ButtonMapping::FindMappedButtonFromDefault") + "found map " + _loc3_.mapName);
               return this.findButton(_loc3_.mapName);
            }
            _loc2_ = _loc2_ + 1;
         }
         trace(this.buildTraceString("ButtonMapping::FindMappedButtonFromDefault") + "couldn\'t find the default for " + defaultButton);
      }
      else
      {
         trace(this.buildTraceString("ButtonMapping::FindMappedButtonFromDefault") + "Haven\'t gotten the current map yet");
      }
      return "";
   }
   function findButton(findMapName)
   {
      trace(this.buildTraceString("ButtonMapping::FindButton") + findMapName);
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < this.m_ButtonMap.length)
      {
         _loc3_ = this.m_ButtonMap[_loc2_];
         if(_loc3_.mapName == findMapName)
         {
            return _loc3_.buttonName;
         }
         _loc2_ = _loc2_ + 1;
      }
      return "";
   }
   function correctLabel(updateButton)
   {
      var _loc4_ = Components.CrossPlatformButtons(updateButton);
      var _loc2_ = _loc4_.GetArt();
      var _loc3_ = Shared.ButtonMapping.FindMappedButtonFromDefault(_loc2_.PCArt);
      if(_loc3_)
      {
         trace(this.buildTraceString("ButtonMapping::CorrectLabel") + "changed " + _loc2_.PCArt + " to " + _loc3_);
         _loc2_.PCArt = _loc3_;
         _loc4_.SetArt(_loc2_);
      }
   }
   static function Initialize(ownerName)
   {
      trace("ButtonMapping::Initialize:  " + ownerName);
      if(Shared.ButtonMapping.s_ButtonMapping == null)
      {
         Shared.ButtonMapping.s_ButtonMapping = new Shared.ButtonMapping(ownerName);
      }
      else
      {
         trace("ButtonMapping::Get:  " + ownerName + " will share with " + Shared.ButtonMapping.s_ButtonMapping.m_ownerName);
         Shared.ButtonMapping.s_ButtonMapping.m_ownerName = Shared.ButtonMapping.s_ButtonMapping.m_ownerName + " + " + ownerName;
      }
   }
   static function FindMappedButtonFromDefault(defaultButton)
   {
      if(Shared.ButtonMapping.s_ButtonMapping != null)
      {
         return Shared.ButtonMapping.s_ButtonMapping.findMappedButtonFromDefault(defaultButton);
      }
      return "";
   }
   static function CorrectLabel(updateButton)
   {
      if(Shared.ButtonMapping.s_ButtonMapping != null)
      {
         Shared.ButtonMapping.s_ButtonMapping.correctLabel(updateButton);
      }
   }
}
