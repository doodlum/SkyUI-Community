class skyui.widgets.activeeffects.ActiveEffect extends MovieClip
{
   var _icon;
   var _iconBaseLabel;
   var _iconEmblemLabel;
   var _iconHolder;
   var _iconLoader;
   var _meter;
   var _meterEmptyIdx;
   var _meterFullIdx;
   var background;
   var content;
   var dispatchEvent;
   var effectBaseSize;
   var effectData;
   var effectFadeInDuration;
   var effectFadeOutDuration;
   var effectMoveDuration;
   var effectSpacing;
   var hAnchor;
   var iconLocation;
   var index;
   var orientation;
   var vAnchor;
   static var METER_WIDTH = 15;
   static var METER_PADDING = 5;
   function ActiveEffect()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this._iconLoader = new MovieClipLoader();
      this._iconLoader.addListener(this);
      this._iconHolder = this.content.iconContent;
      this._icon = this._iconHolder.createEmptyMovieClip("icon",this._iconHolder.getNextHighestDepth());
      this._icon.noIconLoaded = true;
      this._width = this._height = this.effectBaseSize;
      var _loc3_ = this.determinePosition(this.index);
      this._x = _loc3_[0];
      this._y = _loc3_[1];
      this.background._alpha = 0;
      this._iconHolder.iconBackground._alpha = 0;
      this.initEffect();
      this.updateEffect(this.effectData);
      this._alpha = 0;
      skyui.util.Tween.LinearTween(this,"_alpha",0,100,this.effectFadeInDuration,null);
   }
   function updateEffect(a_effectData)
   {
      this.effectData = a_effectData;
      this.updateMeter();
   }
   function updatePosition(a_newIndex)
   {
      this.index = a_newIndex;
      var _loc2_ = this.determinePosition(this.index);
      skyui.util.Tween.LinearTween(this,"_x",this._x,_loc2_[0],this.effectMoveDuration,null);
      skyui.util.Tween.LinearTween(this,"_y",this._y,_loc2_[1],this.effectMoveDuration,null);
   }
   function remove(a_immediate)
   {
      if(a_immediate == true)
      {
         this._alpha = 0;
         this.dispatchEvent({type:"effectRemoved"});
         return undefined;
      }
      skyui.util.Tween.LinearTween(this,"_alpha",100,0,this.effectFadeOutDuration,mx.utils.Delegate.create(this,function()
      {
         this.dispatchEvent({type:"effectRemoved"});
      }
      ));
   }
   function initEffect()
   {
      var _loc3_ = skyui.util.EffectIconMap.lookupIconLabel(this.effectData);
      this._iconBaseLabel = _loc3_.baseLabel;
      this._iconEmblemLabel = _loc3_.emblemLabel;
      if(this._iconBaseLabel == "default_effect" || this._iconBaseLabel == undefined || this._iconBaseLabel == "")
      {
         skyui.util.Debug.log("[SkyUI Active Effects]: Missing icon");
         for(var _loc2_ in this.effectData)
         {
            skyui.util.Debug.log("\t\t" + _loc2_ + ": " + this.effectData[_loc2_]);
         }
      }
      this._iconHolder._width = this._iconHolder._height = this.background._width - skyui.widgets.activeeffects.ActiveEffect.METER_PADDING - skyui.widgets.activeeffects.ActiveEffect.METER_WIDTH;
      this._iconHolder._y = (this.background._height - this._iconHolder._height) / 2;
      if(this.effectData.duration - this.effectData.elapsed > 1)
      {
         this.initMeter();
      }
      this._iconLoader.loadClip(this.iconLocation,this._icon);
   }
   function initMeter()
   {
      this._meter = this.content.attachMovie("SimpleMeter","meter",this.content.getNextHighestDepth(),{_x:this.background._width - skyui.widgets.activeeffects.ActiveEffect.METER_WIDTH,_y:this._iconHolder._y,_width:skyui.widgets.activeeffects.ActiveEffect.METER_WIDTH,_height:this._iconHolder._height});
      this._meter.background._alpha = 50;
      this._meter.gotoAndStop("Empty");
      this._meterEmptyIdx = this._meter._currentframe;
      this._meter.gotoAndStop("Full");
      this._meterFullIdx = this._meter._currentframe;
   }
   function updateMeter()
   {
      if(this._meter == undefined)
      {
         return undefined;
      }
      var _loc2_ = 100 * (this.effectData.duration - this.effectData.elapsed) / this.effectData.duration;
      _loc2_ = Math.min(100,Math.max(_loc2_,0));
      var _loc3_ = Math.floor(Shared.GlobalFunc.Lerp(this._meterEmptyIdx,this._meterFullIdx,0,100,_loc2_));
      this._meter.gotoAndStop(_loc3_);
   }
   function onLoadInit(a_mc)
   {
      if(this._icon.noIconLoaded == true)
      {
         this.remove(true);
         return undefined;
      }
      this._icon._x = 0;
      this._icon._y = 0;
      this._icon._width = this._icon._height = this._iconHolder.iconBackground._width;
      this._icon.baseIcon.gotoAndStop(this._iconBaseLabel);
      this._icon.emblemIcon.gotoAndStop(this._iconEmblemLabel);
      this.updateEffect(this.effectData);
   }
   function onLoadError(a_mc, a_errorCode)
   {
      var _loc3_ = this._iconHolder.createTextField("ErrorTextField",this._icon.getNextHighestDepth(),0,0,this._iconHolder.iconBackground._width,this._iconHolder.iconBackground._height);
      _loc3_.verticalAlign = "center";
      _loc3_.textAutoSize = "fit";
      _loc3_.multiLine = true;
      var _loc2_ = new TextFormat();
      _loc2_.align = "center";
      _loc2_.color = 16777215;
      _loc2_.indent = 20;
      _loc2_.font = "$EverywhereBoldFont";
      _loc3_.setNewTextFormat(_loc2_);
      _loc3_.text = "No Icon\nSource";
   }
   function determinePosition(a_index)
   {
      var _loc3_ = 0;
      var _loc2_ = 0;
      if(this.orientation == "vertical")
      {
         if(this.vAnchor == "bottom")
         {
            _loc2_ = - this.index * (this.effectBaseSize + this.effectSpacing);
         }
         else
         {
            _loc2_ = this.index * (this.effectBaseSize + this.effectSpacing);
         }
      }
      else if(this.hAnchor == "right")
      {
         _loc3_ = - this.index * (this.effectBaseSize + this.effectSpacing);
      }
      else
      {
         _loc3_ = this.index * (this.effectBaseSize + this.effectSpacing);
      }
      return [_loc3_,_loc2_];
   }
   function parseTime(a_s)
   {
      var _loc4_ = Math.floor(a_s);
      var _loc2_ = 0;
      var _loc1_ = 0;
      var _loc3_ = 0;
      if(_loc4_ >= 60)
      {
         _loc2_ = Math.floor(_loc4_ / 60);
         _loc4_ %= 60;
      }
      if(_loc2_ >= 60)
      {
         _loc1_ = Math.floor(_loc2_ / 60);
         _loc2_ %= 60;
      }
      if(_loc1_ >= 24)
      {
         _loc3_ = Math.floor(_loc1_ / 24);
         _loc1_ %= 24;
      }
      return (_loc3_ == 0 ? "" : _loc3_ + "d ") + (!(_loc1_ != 0 || _loc3_) ? "" : _loc1_ + "h ") + (!(_loc2_ != 0 || _loc3_ || _loc1_) ? "" : _loc2_ + "m ") + (_loc4_ + "s");
   }
}
