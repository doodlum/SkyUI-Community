// Velocity-based momentum scroller. Each call to impulse() adds (or, on direction reversal,
// resets) velocity. tick() returns the per-frame position delta and decays the velocity by
// an exponential friction factor. Settles when velocity falls below a threshold.
//
// NOTE: This is a *new class*, which the JPEXS/FFDec CLI cannot inject into an existing SWF
// on its own. The class must first be authored into source/swf/skyui/inventorylists.xml via
// the FFDec GUI, once that's done, the standard build pipeline will keep its body in sync
// from this file.
//
// AS2 detail: static fields must be referenced by their fully qualified class path from
// inside instance methods. Unqualified names resolve to undefined, which silently turns all
// arithmetic involving them into NaN.
class skyui.components.list.ScrollTweener
{
    private var _velocity: Number = 0;          // rows per ms, signed
    private var _lastTickTime: Number = 0;
    private var _lastImpulseTime: Number = 0;   // for cadence-based acceleration
    private var _chainCount: Number = 0;        // consecutive rapid ticks (resets on long gap or reversal)
    private var _active: Boolean = false;

    // Shared timing/threshold tunables. ACCEL_WINDOW_MS is the gap below which a tick counts
    // as "rapid" (extends a chain in curve mode, gets a larger multiplier in classic mode).
    private static var FRAME_REFERENCE_MS: Number = 16;
    private static var VELOCITY_STOP_THRESHOLD: Number = 0.0005;
    private static var ACCEL_WINDOW_MS: Number = 300;

    // Mode-specific tunables. Each cadence mode has its own friction and max multiplier so
    // each keeps its own well-tuned feel.
    //
    //   Curve   (FRICTION 0.85, MAX_MULT 12, RAMP_STEPS 3):
    //     - Velocity survives between rapid ticks, letting chain-count cadence compound into
    //       noticeable acceleration. Single isolated tick settles in ~300ms with a gentle tail.
    //
    //   Classic (FRICTION 0.50, MAX_MULT 18):
    //     - Aggressive friction for a snappy single-tick feel (~50ms settle). Spam relies on
    //       gap-based per-tick multiplier rather than velocity stacking; high cap keeps fast
    //       spam fast even without compounding.
    private static var CURVE_FRICTION_PER_FRAME: Number = 0.85;
    private static var CURVE_ACCEL_MAX_MULT:    Number = 12;
    private static var CURVE_ACCEL_RAMP_STEPS:  Number = 3;
    private static var CLASSIC_FRICTION_PER_FRAME: Number = 0.50;
    private static var CLASSIC_ACCEL_MAX_MULT:     Number = 18;

    // Cadence mode. CURVE (default) compounds across spam: each consecutive rapid tick gets a
    // larger multiplier than the previous, producing acceleration that "curves up" until the
    // chain reaches CURVE_ACCEL_MAX_MULT. CLASSIC applies a fixed multiplier per tick based
    // purely on gap-since-last; spam feels uniformly fast but doesn't accelerate further
    // across the chain — velocity converges to a steady-state plateau. CADENCE_MODE is the
    // active mode and can be flipped at runtime (e.g. from an MCM toggle) by writing to
    // _global.skyui.components.list.ScrollTweener.CADENCE_MODE.
    private static var CADENCE_MODE_CURVE:   Number = 0;
    private static var CADENCE_MODE_CLASSIC: Number = 1;
    private static var CADENCE_MODE:         Number = 0;

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

    // Adds an impulse in a_direction (+1/-1). pageSize is the natural rows-per-tick magnitude.
    // durationMs scales the impulse so longer durations produce a longer glide per tick.
    //
    // Cadence has two modes (CADENCE_MODE selects which is live):
    //   CURVE: chain-count tracking. Each tick within ACCEL_WINDOW_MS in the same direction
    //          extends a chain; per-tick impulse grows along a quadratic curve up to
    //          ACCEL_MAX_MULT after ACCEL_RAMP_STEPS rapid ticks. Spam keeps accelerating.
    //   CLASSIC: gap-based per-tick multiplier. Faster ticks (smaller gap) get a larger
    //          one-shot multiplier; the curve does not compound across the chain.
    //
    // Other knobs to tune:
    //   ScrollTweener: ACCEL_MAX_MULT (ceiling), ACCEL_RAMP_STEPS (curve mode only)
    //   ScrollingList: smoothScrollDuration (lower = faster glide per tick)
    //   ScrollingList: this.scrollDelta (rows-per-tick at base; default 1)
    public function impulse(a_direction: Number, a_pageSize: Number, a_durationMs: Number)
    {
        var frameMs: Number = skyui.components.list.ScrollTweener.FRAME_REFERENCE_MS;
        var window: Number  = skyui.components.list.ScrollTweener.ACCEL_WINDOW_MS;
        var mode: Number    = skyui.components.list.ScrollTweener.CADENCE_MODE;
        var classicMode: Number = skyui.components.list.ScrollTweener.CADENCE_MODE_CLASSIC;

        // Mode-specific tunables (see static fields above for the chosen values).
        var friction: Number;
        var maxMult: Number;
        var rampSteps: Number;
        if (mode == classicMode) {
            friction = skyui.components.list.ScrollTweener.CLASSIC_FRICTION_PER_FRAME;
            maxMult  = skyui.components.list.ScrollTweener.CLASSIC_ACCEL_MAX_MULT;
            rampSteps = 1;  // unused in classic mode
        } else {
            friction = skyui.components.list.ScrollTweener.CURVE_FRICTION_PER_FRAME;
            maxMult  = skyui.components.list.ScrollTweener.CURVE_ACCEL_MAX_MULT;
            rampSteps = skyui.components.list.ScrollTweener.CURVE_ACCEL_RAMP_STEPS;
        }

        var now: Number = getTimer();
        var sinceLast: Number = now - this._lastImpulseTime;
        this._lastImpulseTime = now;

        var reversing: Boolean = (this._velocity * a_direction < 0);
        var cadenceMult: Number = 1;

        if (mode == classicMode) {
            // Classic: per-tick multiplier from gap-since-last only. Velocity stacks via
            // friction-decay residue + new impulse; spam plateaus at a fixed equilibrium.
            if (sinceLast > 0 && sinceLast < window) {
                var rampClassic: Number = (window - sinceLast) / window;     // 0 (slow) -> 1 (instant)
                cadenceMult = 1 + (maxMult - 1) * rampClassic * rampClassic; // quadratic
            }
        } else {
            // Curve (default): chain-count tracking. Each rapid tick within window in the same
            // direction extends the chain; per-tick multiplier grows with chain length.
            if (reversing || sinceLast <= 0 || sinceLast >= window) {
                this._chainCount = 1;
            } else {
                this._chainCount = this._chainCount + 1;
            }
            var progress: Number = (this._chainCount - 1) / rampSteps;
            if (progress > 1) progress = 1;
            cadenceMult = 1 + (maxMult - 1) * progress * progress;
        }

        var durationScale: Number = a_durationMs > 0 ? a_durationMs / 250 : 1;
        var imp: Number = a_pageSize * (1 - friction) / frameMs * durationScale * cadenceMult;

        if (reversing)
            this._velocity = a_direction * imp;     // reversing -> halt + new direction
        else
            this._velocity += a_direction * imp;    // same direction or starting -> accumulate

        if (!this._active) {
            this._active = true;
            this._lastTickTime = getTimer();
        }
    }

    // Returns the position delta (rows) for this frame and decays velocity. Caller is
    // responsible for clamping to bounds and reading isSettled() to terminate.
    public function tick()
    {
        if (!this._active)
            return 0;

        var frameMs: Number = skyui.components.list.ScrollTweener.FRAME_REFERENCE_MS;
        var friction: Number = (skyui.components.list.ScrollTweener.CADENCE_MODE == skyui.components.list.ScrollTweener.CADENCE_MODE_CLASSIC)
            ? skyui.components.list.ScrollTweener.CLASSIC_FRICTION_PER_FRAME
            : skyui.components.list.ScrollTweener.CURVE_FRICTION_PER_FRAME;

        var now: Number = getTimer();
        var dt: Number = now - this._lastTickTime;
        this._lastTickTime = now;
        if (dt < 0 || dt > 200)
            dt = frameMs;        // sanity clamp (paused tab, very slow frame, etc.)

        var delta: Number = this._velocity * dt;
        this._velocity *= Math.pow(friction, dt / frameMs);

        return delta;
    }

    public function isSettled()
    {
        return Math.abs(this._velocity) < skyui.components.list.ScrollTweener.VELOCITY_STOP_THRESHOLD;
    }

    public function settle()
    {
        this._velocity = 0;
        this._active = false;
    }

    public function cancel()
    {
        this._velocity = 0;
        this._active = false;
    }
}
