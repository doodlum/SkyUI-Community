class SnowEffect extends ParticleEmitter
{
   var _effectHeight;
   var _effectWidth;
   var _particles;
   var _windSpeed;
   var effectBuffer;
   var maxParticles;
   var onEnterFrame;
   var particleFrameLabel;
   var particleScaleFactor;
   var minWindSpeed = 0;
   var maxWindSpeed = 400;
   var initialWindSpeed = 0;
   var particleRotationFactor = 1;
   var _framesPerSpawn = 5;
   var _frameTicker = 0;
   function SnowEffect()
   {
      super();
      this._windSpeed = this.initialWindSpeed;
      this.windLoop();
      this.onEnterFrame = this.emitter;
   }
   function initParticle(a_particle)
   {
      var _loc2_ = a_particle;
      _loc2_._alpha = 100;
      _loc2_._x = Math.random() * (this._effectWidth + 2 * this.effectBuffer) - this.effectBuffer;
      _loc2_._y = - Math.random() * this.effectBuffer;
      _loc2_._xscale = _loc2_._yscale = Math.max(0.5,Math.random()) * this.particleScaleFactor * 100;
      this.xLoop(_loc2_);
      this.yLoop(_loc2_);
      return _loc2_;
   }
   function emitter()
   {
      this._frameTicker = (this._frameTicker + 1) % this._framesPerSpawn;
      if(this._frameTicker <= 0)
      {
         if(this.addParticle() == undefined)
         {
            delete this.onEnterFrame;
            return undefined;
         }
         if(this._particles.length % 100 == 0 && this._particles.length < this.maxParticles)
         {
            this.particleScaleFactor += 0.15;
         }
         if(this._particles.length % 20 == 0 && this._framesPerSpawn > 1)
         {
            this._framesPerSpawn = this._framesPerSpawn - 1;
         }
      }
   }
   function windLoop()
   {
      var _loc2_ = Math.random() * 3 + 1;
      var _loc3_ = Math.random() * (2 * this.maxWindSpeed - this.minWindSpeed) - (this.minWindSpeed + this.maxWindSpeed);
      var _loc4_ = Math.random() * 2 + 1;
      com.greensock.TweenNano.to(this,_loc2_,{_windSpeed:_loc3_,delay:_loc4_,onComplete:this.windLoop,onCompleteScope:this});
   }
   function xLoop(a_particle)
   {
      if(a_particle._x > this._effectWidth + this.effectBuffer)
      {
         a_particle._x = Math.random() * (- this.effectBuffer);
      }
      else if(a_particle._x < - this.effectBuffer)
      {
         a_particle._x = this._effectWidth + Math.random() * this.effectBuffer;
      }
      com.greensock.TweenNano.to(a_particle,Math.random() * 2 + 1,{_x:a_particle._x + (Math.random() * 80 - 40 + this._windSpeed) * (a_particle._xscale / 100),_rotation:Math.random() * this.particleRotationFactor * 900,onComplete:this.xLoop,onCompleteParams:[a_particle],onCompleteScope:this,ease:com.greensock.easing.Quad.easeInOut,overwrite:0});
   }
   function yLoop(a_particle)
   {
      if(a_particle._y > this._effectHeight + this.effectBuffer)
      {
         a_particle._y = Math.random() * (- this.effectBuffer);
         if(Math.floor(4096 * Math.random()) == 0 && this._particles.length > 375)
         {
            a_particle.gotoAndStop("snow2");
         }
         else if(a_particle.frameLabel != this.particleFrameLabel)
         {
            a_particle.gotoAndStop(this.particleFrameLabel);
         }
      }
      else if(a_particle._y < - this.effectBuffer)
      {
         a_particle._y = this._effectHeight + Math.random() * this.effectBuffer;
      }
      com.greensock.TweenNano.to(a_particle,Math.random() * 2 + 1,{_y:a_particle._y + (Math.random() * 60 + 70) * (a_particle._xscale / 100) * 3,onComplete:this.yLoop,onCompleteParams:[a_particle],onCompleteScope:this,ease:com.greensock.easing.Linear.easeInOut,overwrite:0});
   }
}
