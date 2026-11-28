class SnowEffect extends ParticleEmitter
{
  /* PUBLIC VARIABLES */

    public var minWindSpeed: Number = 0;
    public var maxWindSpeed: Number = 400;
    public var initialWindSpeed: Number = 0;
    public var particleRotationFactor:Number = 1;
    

  /* PRIVATE VARIABLES */

    private var _framesPerSpawn: Number = 5;
    
    private var _windSpeed: Number;


  /* INITIALIZATION */

    public function SnowEffect()
    {
        super();
        
        this._windSpeed = this.initialWindSpeed;
        this.windLoop();
        
        this.onEnterFrame = this.emitter;
    }


  /* PRIVATE FUNCTIONS */

    // @override ParticleEmitter
    private function initParticle(a_particle: MovieClip)
    {
        var particle: MovieClip = a_particle;
        particle._alpha = 100; //todo
        particle._x = Math.random() * (this._effectWidth + 2 * this.effectBuffer) - this.effectBuffer;
        particle._y = -Math.random() * this.effectBuffer;
        particle._xscale = particle._yscale = (Math.max(0.5, Math.random()) * this.particleScaleFactor) * 100;
        this.xLoop(particle);
        this.yLoop(particle);
        return particle;
    }
    
    private function emitter()
    {
        this._frameTicker = (this._frameTicker + 1) % this._framesPerSpawn;
        if (this._frameTicker <= 0) {
            if (this.addParticle() == undefined) {
                delete this.onEnterFrame;
                return undefined;
            }
            if (this._particles.length % 100 == 0 && this._particles.length < this.maxParticles)
                this.particleScaleFactor += 0.15;

            if (this._particles.length % 20 == 0 && this._framesPerSpawn > 1)
                this._framesPerSpawn = this._framesPerSpawn - 1;
        }
    }
    
    private function windLoop()
    {
        var time: Number = Math.random() * 3 + 1;
        var nextSpeed: Number = Math.random() * (2 * this.maxWindSpeed - this.minWindSpeed) - (this.minWindSpeed + this.maxWindSpeed);
        var nextWind: Number = Math.random() * (2) + 1;

        com.greensock.TweenNano.to(this, time, {_windSpeed: nextSpeed, delay: nextWind, onComplete:this.windLoop, onCompleteScope: this});
    }
    
    private function xLoop(a_particle: MovieClip) {
        if (a_particle._x > this._effectWidth + this.effectBuffer)
            a_particle._x = Math.random() * -this.effectBuffer;
        else if (a_particle._x < -this.effectBuffer)
            a_particle._x = this._effectWidth + Math.random() * this.effectBuffer;

        com.greensock.TweenNano.to(
            a_particle,
            Math.random() * 2 + 1,
            {
                _x: a_particle._x + (Math.random() * 80 - 40 + this._windSpeed) * (a_particle._xscale / 100),
                _rotation: Math.random() * this.particleRotationFactor * 900,
                onComplete: this.xLoop,
                onCompleteParams: [a_particle],
                onCompleteScope: this,
                ease: com.greensock.easing.Quad.easeInOut,
                overwrite: 0
            }
        );
    }

    private function yLoop(a_particle: MovieClip) {
        if (a_particle._y > this._effectHeight + this.effectBuffer) {
            a_particle._y = Math.random() * -this.effectBuffer;
            if (Math.floor(4096 * Math.random()) == 0 && this._particles.length > 375)
                a_particle.gotoAndStop("snow2");
            else if (a_particle.frameLabel != this.particleFrameLabel)
                a_particle.gotoAndStop(this.particleFrameLabel);
        } else if (a_particle._y < -this.effectBuffer) {
            a_particle._y = this._effectHeight + Math.random() * this.effectBuffer;
        }

        com.greensock.TweenNano.to(
            a_particle,
            Math.random() * 2 + 1,
            {
                _y: a_particle._y + (Math.random() * 60 + 70) * (a_particle._xscale / 100) * 3,
                onComplete: this.yLoop,
                onCompleteParams: [a_particle],
                onCompleteScope: this,
                ease: com.greensock.easing.Linear.easeInOut,
                overwrite: 0
            }
        );
    }
}
