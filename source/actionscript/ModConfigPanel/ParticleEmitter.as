class ParticleEmitter extends MovieClip
{
   var _effectHeight;
   var _effectWidth;
   var _particleHolder;
   var _particles;
   var maxParticles;
   var particleFrameLabel;
   var particleLinkageName;
   function ParticleEmitter()
   {
      super();
      this._visible = false;
      this._effectWidth = this._width;
      this._effectHeight = this._height;
      var _loc3_ = "_particleHolder";
      while(this._parent[_loc3_] != undefined)
      {
         _loc3_ = "_" + _loc3_;
      }
      this._particleHolder = this._parent.createEmptyMovieClip(_loc3_,this._parent.getNextHighestDepth());
      this._particleHolder.swapDepths(this);
      this._particleHolder.setMask(this);
      this._particles = new Array();
   }
   function set width(a_val)
   {
      this._width = a_val;
      this._effectWidth = a_val * 100 / this._particleHolder._xscale;
   }
   function get width()
   {
      return this._width;
   }
   function set height(a_val)
   {
      this._height = a_val;
      this._effectHeight = a_val * 100 / this._particleHolder._yscale;
   }
   function get height()
   {
      return this._height;
   }
   function set visible(a_val)
   {
      this._particleHolder._visible = a_val;
   }
   function get visible()
   {
      return this._particleHolder._visible;
   }
   function set alpha(a_val)
   {
      this._particleHolder._alpha = a_val;
   }
   function get alpha()
   {
      return this._particleHolder._alpha;
   }
   function set xscale(a_val)
   {
      this._particleHolder._xscale = a_val;
      this._width = this._effectWidth * a_val / 100;
   }
   function get xscale()
   {
      return this._particleHolder._xscale;
   }
   function set yscale(a_val)
   {
      this._particleHolder._yscale = a_val;
      this._height *= a_val / 100;
   }
   function get yscale()
   {
      return this._particleHolder._yscale;
   }
   function setParticleFrameLabel(a_frameLabel)
   {
      this.particleFrameLabel = a_frameLabel;
      var _loc2_ = 0;
      while(_loc2_ < this._particles.length)
      {
         if(this._particles[_loc2_].frameLabel != this.particleFrameLabel)
         {
            this._particles[_loc2_].frameLabel = this.particleFrameLabel;
            this._particles[_loc2_].gotoAndStop(this.particleFrameLabel);
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function addParticle(a_particleInitFunc, a_forceAdd)
   {
      if(this._particles.length >= this.maxParticles && !a_forceAdd)
      {
         return undefined;
      }
      var _loc3_ = a_particleInitFunc || this.initParticle;
      var _loc2_ = this._particleHolder.attachMovie(this.particleLinkageName,"particle" + this._particles.length,this._particleHolder.getNextHighestDepth());
      _loc2_.frameLabel = this.particleFrameLabel;
      _loc2_.gotoAndStop(this.particleFrameLabel);
      _loc2_ = _loc3_(_loc2_);
      this._particles.push(_loc2_);
      return _loc2_;
   }
   function initParticle(a_particle)
   {
      var _loc1_ = a_particle;
      _loc1_._visible = false;
      return _loc1_;
   }
}
