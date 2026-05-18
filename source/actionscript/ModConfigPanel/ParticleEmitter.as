class ParticleEmitter extends MovieClip
{
  /* STAGE ELEMENTS */

    private var _particleHolder: MovieClip;
    

  /* COMPONENT DEFINITIONS */

    public var particleLinkageName: String;
    public var particleFrameLabel: String;
    public var particleScaleFactor: Number;
    
    public var maxParticles: Number;
    
    public var effectBuffer: Number;
    

  /* PRIVATE VARIABLES */

    private var _effectWidth: Number;
    private var _effectHeight: Number;
    
    private var _particles: Array;
    

  /* PROPERTIES */

    public function set width(a_val: Number)
    {
        this._width = a_val;
        this._effectWidth = a_val * 100 / this._particleHolder._xscale;
    }
    public function get width() { return this._width; }
    
    public function set height(a_val: Number)
    {
        this._height = a_val;
        this._effectHeight = a_val * 100 / this._particleHolder._yscale;
    }
    public function get height() { return this._height; }
    
    public function set visible(a_val: Boolean) { this._particleHolder._visible = a_val; }
    public function get visible(): Boolean { return this._particleHolder._visible; }
    
    public function set alpha(a_val: Number) { this._particleHolder._alpha = a_val; }
    public function get alpha() { return this._particleHolder._alpha; }
    
    public function set xscale(a_val: Number)
    {
        this._particleHolder._xscale = a_val;
        this._width = this._effectWidth * a_val/100;
    }
    public function get xscale() { return this._particleHolder._xscale; }
    
    public function set yscale(a_val: Number)
    {
        this._particleHolder._yscale = a_val;
        this._height *= a_val / 100;
    }
    public function get yscale() { return this._particleHolder._yscale; }
    

  /* PUBLIC FUNCTIONS */

    public function ParticleEmitter()
    {
        // The ParticleEmitter MovieClip(this) is actually a mask, the real magic bappens in _particleHolder
        this._visible = false;
        
        this._effectWidth = this._width;
        this._effectHeight = this._height;
        
        var particleHolderName: String = "_particleHolder";
        
        while (this._parent[particleHolderName] != undefined)
            particleHolderName = "_" + particleHolderName;
        
        this._particleHolder = this._parent.createEmptyMovieClip(particleHolderName, this._parent.getNextHighestDepth());
        this._particleHolder.swapDepths(this); //Swap depths so the _particleHolder is on the correct "layer"
        this._particleHolder.setMask(this);
        
        this._particles = new Array();
    }
    

  /* PRIVATE FUNCTIONS */

    private function setParticleFrameLabel(a_frameLabel: String)
    {
        this.particleFrameLabel = a_frameLabel;
        for (var i: Number = 0; i < this._particles.length; i++) {
            if (this._particles[i].frameLabel == this.particleFrameLabel)
                continue;
            this._particles[i].frameLabel = this.particleFrameLabel;
            this._particles[i].gotoAndStop(this.particleFrameLabel);
        }
    }
    
    private function addParticle(a_particleInitFunc: Function, a_forceAdd: Boolean)
    {
        if (this._particles.length >= this.maxParticles && !a_forceAdd)
            return undefined;
            
        var initFunc: Function = a_particleInitFunc || this.initParticle;
        var particle: MovieClip = this._particleHolder.attachMovie(this.particleLinkageName, "particle" + this._particles.length, this._particleHolder.getNextHighestDepth());
        particle.frameLabel = this.particleFrameLabel;
        particle.gotoAndStop(this.particleFrameLabel);
        
        particle = initFunc(particle);
        
        this._particles.push(particle);
        
        return particle;
    }
    
    private function initParticle(a_particle: MovieClip)
    {
        var particle: MovieClip = a_particle;
        particle._visible = false;
        return particle;
    }
}
