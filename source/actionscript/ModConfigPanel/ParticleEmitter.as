class ParticleEmitter extends MovieClip
{
	/* STAGE ELEMENTS */

	private var _particleHolder;


	/* COMPONENT DEFINITIONS */

	public var particleLinkageName;
	public var particleFrameLabel;
	public var particleScaleFactor;

	public var maxParticles;

	public var effectBuffer;


	/* PRIVATE VARIABLES */

	private var _effectWidth;
	private var _effectHeight;

	private var _particles;


	/* PROPERTIES */

	public function set width(a_val)
	{
		_width = a_val;
		_effectWidth = a_val * 100 / _particleHolder._xscale;
	}

	public function get width()
	{
		return _width;
	}

	public function set height(a_val)
	{
		_height = a_val;
		_effectHeight = a_val * 100 / _particleHolder._yscale;
	}

	public function get height()
	{
		return _height;
	}

	public function set visible(a_val)
	{
		_particleHolder._visible = a_val;
	}

	public function get visible()
	{
		return _particleHolder._visible;
	}

	public function set alpha(a_val)
	{
		_particleHolder._alpha = a_val;
	}

	public function get alpha()
	{
		return _particleHolder._alpha;
	}

	public function set xscale(a_val)
	{
		_particleHolder._xscale = a_val;
		_width = _effectWidth * a_val / 100;
	}

	public function get xscale()
	{
		return _particleHolder._xscale;
	}

	public function set yscale(a_val)
	{
		_particleHolder._yscale = a_val;
		_height *= a_val / 100;
	}

	public function get yscale()
	{
		return _particleHolder._yscale;
	}


	/* INITIALIZATION */

	public function ParticleEmitter()
	{
		super();

		// The ParticleEmitter MovieClip(this) is actually a mask, the real magic happens in _particleHolder
		_visible = false;

		_effectWidth = _width;
		_effectHeight = _height;

		var particleHolderName = "_particleHolder";

		while (_parent[particleHolderName] != undefined)
			particleHolderName = "_" + particleHolderName;

		_particleHolder = _parent.createEmptyMovieClip(particleHolderName, _parent.getNextHighestDepth());
		_particleHolder.swapDepths(this); // Swap depths so the _particleHolder is on the correct "layer"
		_particleHolder.setMask(this);

		_particles = new Array();
	}


	/* PRIVATE FUNCTIONS */

	private function setParticleFrameLabel(a_frameLabel)
	{
		particleFrameLabel = a_frameLabel;

		var i = 0;
		while (i < _particles.length) {
			if (_particles[i].frameLabel != particleFrameLabel) {
				_particles[i].frameLabel = particleFrameLabel;
				_particles[i].gotoAndStop(particleFrameLabel);
			}
			i = i + 1;
		}
	}

	private function addParticle(a_particleInitFunc, a_forceAdd)
	{
		if (_particles.length >= maxParticles && !a_forceAdd)
			return undefined;

		var initFunc = a_particleInitFunc || initParticle;
		var particle = _particleHolder.attachMovie(particleLinkageName, "particle" + _particles.length, _particleHolder.getNextHighestDepth());
		particle.frameLabel = particleFrameLabel;
		particle.gotoAndStop(particleFrameLabel);

		particle = initFunc(particle);

		_particles.push(particle);

		return particle;
	}

	private function initParticle(a_particle)
	{
		var particle = a_particle;
		particle._visible = false;
		return particle;
	}
}
