class skyui.widgets.activeeffects.ActiveEffectsWidget extends skyui.widgets.WidgetBase
{
   var _effectBaseSize;
   var _effectsGroups;
   var _effectsHash;
   var _enabled;
   var _groupEffectCount;
   var _intervalId;
   var _orientation;
   var attachMovie;
   var effectDataArray;
   var getNextHighestDepth;
   static var EFFECT_SPACING = 5;
   static var EFFECT_FADE_IN_DURATION = 0.25;
   static var EFFECT_FADE_OUT_DURATION = 0.75;
   static var EFFECT_MOVE_DURATION = 1;
   static var ICON_SOURCE = "skyui/icons_effect_psychosteve.swf";
   var _marker = 1;
   var _sortFlag = true;
   var _updateInterval = 150;
   var _minTimeLeft = 180;
   function ActiveEffectsWidget()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this._effectsHash = new Object();
      this._effectsGroups = new Array();
      this.effectDataArray = new Array();
   }
   function getWidth()
   {
      return this._effectBaseSize;
   }
   function getHeight()
   {
      return this._effectBaseSize;
   }
   function initNumbers(a_enabled, a_effectSize, a_groupEffectCount, a_minTimeLeft)
   {
      this._enabled = a_enabled;
      this._effectBaseSize = a_effectSize;
      this._groupEffectCount = a_groupEffectCount;
      this._minTimeLeft = a_minTimeLeft;
   }
   function initStrings(a_orientation)
   {
      this._orientation = a_orientation.toLowerCase();
   }
   function initCommit()
   {
      this.invalidateSize();
      if(this._enabled)
      {
         this.drawEffects();
      }
   }
   function setEffectSize(a_effectBaseSize)
   {
      this._effectBaseSize = a_effectBaseSize;
      this.invalidateSize();
      this.invalidateEffects();
   }
   function setGroupEffectCount(a_groupEffectCount)
   {
      this._groupEffectCount = a_groupEffectCount;
      this.invalidateEffects();
   }
   function setEnabled(a_enabled)
   {
      this._enabled = a_enabled;
      if(this._enabled)
      {
         this.eraseEffects();
         this.drawEffects();
      }
      else
      {
         this.eraseEffects();
      }
   }
   function setOrientation(a_orientation)
   {
      this._orientation = a_orientation.toLowerCase();
      this.invalidateEffects();
   }
   function setMinTimeLeft(a_seconds)
   {
      this._minTimeLeft = a_seconds;
   }
   function updatePosition()
   {
      super.updatePosition();
      this.invalidateEffects();
   }
   function onIntervalUpdate()
   {
      this.effectDataArray.splice(0);
      skse.RequestActivePlayerEffects(this.effectDataArray);
      if(this._sortFlag)
      {
         this.effectDataArray.sortOn("elapsed",Array.DESCENDING | Array.NUMERIC);
         this._sortFlag = false;
      }
      var _loc3_ = 0;
      var _loc2_;
      var _loc4_;
      var _loc5_;
      while(_loc3_ < this.effectDataArray.length)
      {
         _loc2_ = this.effectDataArray[_loc3_];
         if(!(this._minTimeLeft != 0 && this._minTimeLeft < _loc2_.duration - _loc2_.elapsed))
         {
            _loc4_ = this._effectsHash[_loc2_.id];
            if(!_loc4_)
            {
               _loc5_ = this.getFreeEffectsGroup();
               _loc4_ = _loc5_.addEffect(_loc2_);
               this._effectsHash[_loc2_.id] = _loc4_;
            }
            else
            {
               _loc4_.updateEffect(_loc2_);
            }
            _loc4_.marker = this._marker;
         }
         _loc3_ = _loc3_ + 1;
      }
      for(var _loc6_ in this._effectsHash)
      {
         _loc4_ = this._effectsHash[_loc6_];
         if(_loc4_.marker != this._marker)
         {
            _loc4_.remove();
            delete this._effectsHash[_loc6_];
         }
      }
      this._marker = 1 - this._marker;
   }
   function getFreeEffectsGroup()
   {
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < this._effectsGroups.length)
      {
         _loc3_ = this._effectsGroups[_loc2_];
         if(_loc3_.length < this._groupEffectCount)
         {
            return _loc3_;
         }
         _loc2_ = _loc2_ + 1;
      }
      var _loc5_ = this._effectsGroups.length;
      var _loc6_ = {index:_loc5_,iconLocation:this._rootPath + skyui.widgets.activeeffects.ActiveEffectsWidget.ICON_SOURCE,effectBaseSize:this._effectBaseSize,effectSpacing:skyui.widgets.activeeffects.ActiveEffectsWidget.EFFECT_SPACING,effectFadeInDuration:skyui.widgets.activeeffects.ActiveEffectsWidget.EFFECT_FADE_IN_DURATION,effectFadeOutDuration:skyui.widgets.activeeffects.ActiveEffectsWidget.EFFECT_FADE_OUT_DURATION,effectMoveDuration:skyui.widgets.activeeffects.ActiveEffectsWidget.EFFECT_MOVE_DURATION,hAnchor:this._hAnchor,vAnchor:this._vAnchor,orientation:this._orientation};
      var _loc4_ = this.attachMovie("ActiveEffectsGroup","effectsGroup" + this.getNextHighestDepth(),this.getNextHighestDepth(),_loc6_);
      _loc4_.addEventListener("groupRemoved",this,"onGroupRemoved");
      this._effectsGroups.push(_loc4_);
      return _loc4_;
   }
   function onGroupRemoved(event)
   {
      var _loc5_ = event.target;
      var _loc4_ = _loc5_.index;
      this._effectsGroups.splice(_loc4_,1);
      _loc5_.removeMovieClip();
      var _loc3_;
      var _loc2_ = _loc4_;
      while(_loc2_ < this._effectsGroups.length)
      {
         _loc3_ = this._effectsGroups[_loc2_];
         _loc3_.updatePosition(_loc2_);
         _loc2_ = _loc2_ + 1;
      }
   }
   function invalidateEffects()
   {
      if(!this._enabled)
      {
         return undefined;
      }
      this.eraseEffects();
      this.drawEffects();
   }
   function eraseEffects()
   {
      clearInterval(this._intervalId);
      var _loc3_;
      var _loc2_ = 0;
      while(_loc2_ < this._effectsGroups.length)
      {
         _loc3_ = this._effectsGroups[_loc2_];
         _loc3_.removeMovieClip();
         _loc2_ = _loc2_ + 1;
      }
      this._effectsHash = new Object();
      this._effectsGroups = new Array();
   }
   function drawEffects()
   {
      clearInterval(this._intervalId);
      this._sortFlag = true;
      this._intervalId = setInterval(this,"onIntervalUpdate",this._updateInterval);
   }
}
