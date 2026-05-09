// Velocity-based momentum scroller. impulse() adds velocity (or resets it on direction
// reversal); tick() returns the per-frame position delta and decays velocity.
class skyui.components.list.ScrollTweener
{
    private var _velocity: Number = 0;
    private var _lastTickTime: Number = 0;
    private var _lastImpulseTime: Number = 0;
    private var _chainCount: Number = 0;
    private var _active: Boolean = false;

    private static var FRAME_REFERENCE_MS: Number = 16;
    private static var VELOCITY_STOP_THRESHOLD: Number = 0.0005;
    private static var ACCEL_WINDOW_MS: Number = 300;

    private static var FRICTION_PER_FRAME: Number = 0.85;
    private static var ACCEL_MAX_MULT: Number = 12;
    private static var ACCEL_RAMP_STEPS: Number = 3;

    public function ScrollTweener()
    {
    }

    public function get velocity()
    {
        return this._velocity;
    }

    public function get isActive()
    {
        return this._active;
    }

    public function impulse(a_direction: Number, a_pageSize: Number, a_durationMs: Number)
    {
        var frameMs: Number   = skyui.components.list.ScrollTweener.FRAME_REFERENCE_MS;
        var window: Number    = skyui.components.list.ScrollTweener.ACCEL_WINDOW_MS;
        var friction: Number  = skyui.components.list.ScrollTweener.FRICTION_PER_FRAME;
        var maxMult: Number   = skyui.components.list.ScrollTweener.ACCEL_MAX_MULT;
        var rampSteps: Number = skyui.components.list.ScrollTweener.ACCEL_RAMP_STEPS;

        var now: Number = getTimer();
        var sinceLast: Number = now - this._lastImpulseTime;
        this._lastImpulseTime = now;

        var reversing: Boolean = (this._velocity * a_direction < 0);

        // Chain-count cadence: rapid ticks in the same direction extend a chain; per-tick
        // multiplier grows along a quadratic curve to ACCEL_MAX_MULT after ACCEL_RAMP_STEPS.
        if (reversing || sinceLast <= 0 || sinceLast >= window)
            this._chainCount = 1;
        else
            this._chainCount = this._chainCount + 1;

        var progress: Number = (this._chainCount - 1) / rampSteps;
        if (progress > 1) progress = 1;
        var cadenceMult: Number = 1 + (maxMult - 1) * progress * progress;

        var durationScale: Number = a_durationMs > 0 ? a_durationMs / 250 : 1;
        var imp: Number = a_pageSize * (1 - friction) / frameMs * durationScale * cadenceMult;

        if (reversing)
            this._velocity = a_direction * imp;
        else
            this._velocity += a_direction * imp;

        if (!this._active) {
            this._active = true;
            this._lastTickTime = getTimer();
        }
    }

    public function tick()
    {
        if (!this._active)
            return 0;

        var frameMs: Number = skyui.components.list.ScrollTweener.FRAME_REFERENCE_MS;
        var friction: Number = skyui.components.list.ScrollTweener.FRICTION_PER_FRAME;

        var now: Number = getTimer();
        var dt: Number = now - this._lastTickTime;
        this._lastTickTime = now;
        if (dt < 0 || dt > 200)
            dt = frameMs;

        var delta: Number = this._velocity * dt;
        this._velocity *= Math.pow(friction, dt / frameMs);

        return delta;
    }

    public function isSettled()
    {
        return Math.abs(this._velocity) < skyui.components.list.ScrollTweener.VELOCITY_STOP_THRESHOLD;
    }

    public function cancel()
    {
        this._velocity = 0;
        this._active = false;
    }
}
