class skyui.widgets.activeeffects.ActiveEffectsGroup extends MovieClip
{
   var _effectsArray;
   var dispatchEvent;
   var effectBaseSize;
   var effectFadeInDuration;
   var effectFadeOutDuration;
   var effectMoveDuration;
   var effectSpacing;
   var hAnchor;
   var iconLocation;
   var index;
   var orientation;
   var vAnchor;
   function ActiveEffectsGroup()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this._effectsArray = new Array();
      var _loc3_ = this.determinePosition(this.index);
      this._x = _loc3_[0];
      this._y = _loc3_[1];
   }
   function get length()
   {
      return this._effectsArray.length;
   }
   function addEffect(a_effectData)
   {
      var _loc15_ = this._effectsArray.length;
      var _loc3_ = {index:this._effectsArray.length,effectData:a_effectData,iconLocation:this.iconLocation,effectBaseSize:this.effectBaseSize,effectSpacing:this.effectSpacing,effectFadeInDuration:this.effectFadeInDuration,effectFadeOutDuration:this.effectFadeOutDuration,effectMoveDuration:this.effectMoveDuration,hAnchor:this.hAnchor,vAnchor:this.vAnchor,orientation:this.orientation};
      var _loc2_ = this.attachMovie("ActiveEffect",a_effectData.id,this.getNextHighestDepth(),_loc3_);
      _loc2_.addEventListener("effectRemoved",this,"onEffectRemoved");
      this._effectsArray.push(_loc2_);
      return _loc2_;
   }
   function updatePosition(a_newIndex)
   {
      this.index = a_newIndex;
      var _loc2_ = this.determinePosition(this.index);
      skyui.util.Tween.LinearTween(this,"_x",this._x,_loc2_[0],this.effectMoveDuration,null);
      skyui.util.Tween.LinearTween(this,"_y",this._y,_loc2_[1],this.effectMoveDuration,null);
   }
   function onEffectRemoved(event)
   {
      var _loc5_ = event.target;
      var _loc4_ = _loc5_.index;
      this._effectsArray.splice(_loc4_,1);
      _loc5_.removeMovieClip();
      var _loc3_;
      var _loc2_;
      if(this._effectsArray.length > 0)
      {
         _loc2_ = _loc4_;
         while(_loc2_ < this._effectsArray.length)
         {
            _loc3_ = this._effectsArray[_loc2_];
            _loc3_.updatePosition(_loc2_);
            _loc2_ = _loc2_ + 1;
         }
      }
      else
      {
         this.dispatchEvent({type:"groupRemoved"});
      }
   }
   function determinePosition(a_index)
   {
      var _loc3_ = 0;
      var _loc2_ = 0;
      if(this.orientation == "vertical")
      {
         if(this.hAnchor == "right")
         {
            _loc3_ = - (this.effectSpacing + this.index * (this.effectBaseSize + this.effectSpacing));
         }
         else
         {
            _loc3_ = this.effectSpacing + this.index * (this.effectBaseSize + this.effectSpacing);
         }
      }
      else if(this.vAnchor == "bottom")
      {
         _loc2_ = - (this.effectSpacing + this.index * (this.effectBaseSize + this.effectSpacing));
      }
      else
      {
         _loc2_ = this.effectSpacing + this.index * (this.effectBaseSize + this.effectSpacing);
      }
      return [_loc3_,_loc2_];
   }
}
