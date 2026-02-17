class SnowEffect extends ParticleEmitter
{
	/* PUBLIC VARIABLES */

	public var minWindSpeed = 0;
	public var maxWindSpeed = 400;
	public var initialWindSpeed = 0;
	public var particleRotationFactor = 1;


	/* PRIVATE VARIABLES */

	private var _framesPerSpawn = 5;
	private var _frameTicker = 0;

	private var _windSpeed;


	/* INITIALIZATION */

	public function SnowEffect()
	{
		super();

		_windSpeed = initialWindSpeed;
		windLoop();

		onEnterFrame = emitter;
	}


	/* PRIVATE FUNCTIONS */

	// @Override ParticleEmitter
	private function initParticle(a_particle)
	{
		var particle = a_particle;
		particle._alpha = 100;
		particle._x = Math.random() * (_effectWidth + 2 * effectBuffer) - effectBuffer;
		particle._y = -Math.random() * effectBuffer;
		particle._xscale = particle._yscale = Math.max(0.5, Math.random()) * particleScaleFactor * 100;
		xLoop(particle);
		yLoop(particle);
		return particle;
	}

	private function emitter()
	{
		_frameTicker = (_frameTicker + 1) % _framesPerSpawn;
		if (_frameTicker <= 0) {
			if (addParticle() == undefined) {
				delete onEnterFrame;
				return;
			}
			if (_particles.length % 100 == 0 && _particles.length < maxParticles) {
				particleScaleFactor += 0.15;
			}
			if (_particles.length % 20 == 0 && _framesPerSpawn > 1) {
				_framesPerSpawn = _framesPerSpawn - 1;
			}
		}
	}

	private function windLoop()
	{
		var time = Math.random() * 3 + 1;
		var nextSpeed = Math.random() * (2 * maxWindSpeed - minWindSpeed) - (minWindSpeed + maxWindSpeed);
		var nextWind = Math.random() * 2 + 1;
		Tween.LinearTween(this, "_windSpeed", this._windSpeed, nextSpeed, time, null);
	}

	private function xLoop(a_particle)
	{
		if (a_particle._x > _effectWidth + effectBuffer) {
			a_particle._x = Math.random() * (-effectBuffer);
		} else if (a_particle._x < -effectBuffer) {
			a_particle._x = _effectWidth + Math.random() * effectBuffer;
		}
		com.greensock.TweenNano.to(a_particle, Math.random() * 2 + 1, {_x: a_particle._x + (Math.random() * 80 - 40 + _windSpeed) * (a_particle._xscale / 100), _rotation: Math.random() * particleRotationFactor * 900, onComplete: xLoop, onCompleteParams: [a_particle], onCompleteScope: this, ease: com.greensock.easing.Quad.easeInOut, overwrite: false});
	}

	private function yLoop(a_particle)
	{
		if (a_particle._y > _effectHeight + effectBuffer) {
			a_particle._y = Math.random() * (-effectBuffer);
			if (Math.floor(4096 * Math.random()) == 0 && _particles.length > 375) {
				a_particle.gotoAndStop("snow2");
			} else if (a_particle.frameLabel != particleFrameLabel) {
				a_particle.gotoAndStop(particleFrameLabel);
			}
		} else if (a_particle._y < -effectBuffer) {
			a_particle._y = _effectHeight + Math.random() * effectBuffer;
		}
		com.greensock.TweenNano.to(a_particle, Math.random() * 2 + 1, {_y: a_particle._y + (Math.random() * 60 + 70) * (a_particle._xscale / 100) * 3, onComplete: yLoop, onCompleteParams: [a_particle], onCompleteScope: this, ease: com.greensock.easing.Linear.easeInOut, overwrite: false});
	}
}
