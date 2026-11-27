"""Verify the FPS patch of a build, independently of how xml_fps_patcher.py works.

For every SWF in tools/fps_patch_plan.json it compares the unpatched SWF (build/fps_unpatched/<swf>, the
script-injected SWF the patcher started from) with the shipped one (build/interface/<swf>), both exported to
XML with FFDec, and fails loudly unless:

  timing   - the frame rate is target_fps for converted SWFs (an integer multiple k of the original) and
             unchanged otherwise;
           - every timeline (main timeline and every DefineSprite) has exactly k times as many frames, so its
             duration in seconds (frames / fps) is unchanged;
           - original frame f's tags (placements, labels, scripts, sounds, definitions) all sit, in the same
             order and otherwise unchanged, on stretched frame (f-1)*k+1, so every frame label and frame script
             fires at the same time in seconds; the frames in between only hold PlaceObject2 moves of objects
             already on stage (tween interpolation);
           - the only new timeline is the "__fpsScale" marker (k frames) on the main timeline's first frame,
             plus a 1-frame marker placed in each timeline listed under keep_timelines (engine-driven sprites
             left unstretched, reported as such);
  code     - undoing the documented substitutions (FpsScale.prop/go/throttle calls, GotoFrame index * k,
             onClipEvent(enterFrame) tick guard) gives back the original bytecode byte for byte, i.e. nothing
             else was changed;
           - no raw frame-number reference is left: no _currentframe/_totalframes/_framesloaded read,
             gotoAndStop/gotoAndPlay/nextFrame/prevFrame call, GotoFrame2/NextFrame/PrevFrame action or
             GetProperty of a frame property outside skyui.util.FpsScale itself;
           - every onEnterFrame handler is throttled to the original rate, except code listed under
             enterframe_free_running in the plan, and every mx.transitions.Tween is time-based
             (useSeconds=true) and nothing but TweenNano itself mentions useFrames.

Usage:
  python tools/check_fps_patch.py --build build/agent [--ffdec tools/ffdec-cli.cmd] [--swf hudmenu.swf ...]
"""

import argparse
import copy
import glob
import json
import os
import subprocess
import sys
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fps_avm1 as avm1  # noqa: E402
import fps_swfxml as sx  # noqa: E402

HELPER_EXPORT = "__Packages.skyui.util.FpsScale"
HELPER_PATH = ("skyui", "util", "FpsScale")
MARKER = "__fpsScale"


class Fail(Exception):
    pass


# ---------------------------------------------------------------------------
# XML helpers
# ---------------------------------------------------------------------------

def export(ffdec, swf, out_xml):
    os.makedirs(os.path.dirname(out_xml), exist_ok=True)
    for attempt in range(2):
        r = subprocess.run([ffdec, "-swf2xml", swf, out_xml], stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           shell=(os.name == "nt" and ffdec.lower().endswith((".cmd", ".bat"))))
        if r.returncode == 0 and os.path.exists(out_xml):
            return
    raise Fail("FFDec could not export %s:\n%s" % (swf, r.stdout.decode("utf-8", "replace")[-2000:]))


def canonical(el):
    if sx.tag_type(el) == "DefineSpriteTag":
        # a sprite's frames are checked as a timeline of their own
        return "<DefineSprite %s>" % el.get("spriteId")
    c = copy.deepcopy(el)
    for x in c.iter():
        x.attrib.pop("actionBytes", None)
    return ET.tostring(c, encoding="unicode")


def frames_of(tl):
    out, cur, nshow = [], [], 0
    for el in tl.container:
        if sx.tag_type(el) == "ShowFrameTag":
            out.append(cur)
            cur = []
            nshow += 1
        else:
            cur.append(el)
    return out, cur, nshow


def code_tags(tags):
    """Code-carrying elements of a frame, in order (DoAction, DoInitAction and clip action records)."""
    res = []
    for el in tags:
        t = sx.tag_type(el)
        if t in ("DoActionTag", "DoInitActionTag"):
            res.append(el)
        elif t.startswith("PlaceObject"):
            for rec in el.iter("item"):
                if sx.tag_type(rec) == "CLIPACTIONRECORD":
                    res.append(rec)
    return res


# ---------------------------------------------------------------------------
# Bytecode: undo the patcher's substitutions
# ---------------------------------------------------------------------------

def _push_vals(a):
    return [v.value for v in a.push_values()] if a.code == 0x96 else None


def match_helper(actions, i):
    """If actions[i:] starts with a call to skyui.util.FpsScale.<m>, return (m, nargs, length)."""
    if i + 7 >= len(actions):
        return None
    a0 = actions[i]
    v0 = _push_vals(a0)
    if not v0 or v0[-1] != HELPER_PATH[0] or len(v0) not in (1, 2):
        return None
    seq = actions[i:i + 8]
    codes = [x.code for x in seq]
    if codes != [0x96, 0x1C, 0x96, 0x4E, 0x96, 0x4E, 0x96, 0x52]:
        return None
    if _push_vals(seq[2]) != [HELPER_PATH[1]] or _push_vals(seq[4]) != [HELPER_PATH[2]]:
        return None
    m = _push_vals(seq[6])
    if not m or len(m) != 1:
        return None
    nargs = v0[0] if len(v0) == 2 else None
    return m[0], nargs, 8


def unrewrite(after_code, k, where):
    """Return (original_code_bytes, stats) by undoing the documented substitutions."""
    acts = avm1.parse(after_code)
    stats = {"prop": 0, "go": 0, "throttle": 0, "gotoframe": 0, "guard": 0}
    repl = {}
    i = 0
    # onClipEvent(enterFrame) guard: Push key,"this"; GetVariable; <FpsScale.tick 2>; Not; If
    if len(acts) > 12 and acts[0].code == 0x96 and _push_vals(acts[0])[-1:] == ["this"] and acts[1].code == 0x1C:
        h = match_helper(acts, 2)
        if h and h[0] == "tick" and acts[10].code == 0x12 and acts[11].code == 0x9D:
            for j in range(12):
                repl[j] = []
            stats["guard"] += 1
            i = 12
    while i < len(acts):
        h = match_helper(acts, i)
        if h:
            m, nargs, ln = h
            if m == "prop" and nargs == 2:
                repl[i] = [avm1.mk(0x4E)]
            elif m == "go" and nargs is not None and nargs >= 3:
                repl[i] = [avm1.mk(0x52)]
            elif m == "throttle" and nargs == 1:
                nxt = acts[i + ln] if i + ln < len(acts) else None
                if nxt is None or nxt.code not in (0x4F, 0x1D):
                    raise Fail("%s: FpsScale.throttle result is not assigned" % where)
                repl[i] = []
            else:
                raise Fail("%s: unexpected FpsScale.%s call (nargs %r)" % (where, m, nargs))
            stats[m] += 1
            for j in range(i + 1, i + ln):
                repl[j] = []
            i += ln
            continue
        a = acts[i]
        if a.code == 0x81:
            idx = int.from_bytes(a.payload[:2], "little")
            if idx % k:
                raise Fail("%s: GotoFrame %d is not on a stretched keyframe (k=%d)" % (where, idx + 1, k))
            if k > 1:
                repl[i] = [avm1.mk(0x81, (idx // k).to_bytes(2, "little"))]
                stats["gotoframe"] += 1
        i += 1
    return (avm1.assemble(acts, repl, len(after_code)) if repl else after_code), stats


# ---------------------------------------------------------------------------
# Per SWF check
# ---------------------------------------------------------------------------

RAW_KINDS = ("member_read", "call_method", "call_function", "var_read", "getprop", "getprop_dynamic",
             "gotoframe2", "nextframe", "prevframe", "waitforframe")


def check_swf(key, entry, plan, before_xml, after_xml, notes):
    target = float(plan["target_fps"])
    free_running = set(plan.get("enterframe_free_running", {}))
    override_ok = set(plan.get("method_override_allowed", {}))
    tb, ta = sx.load(before_xml), sx.load(after_xml)
    fb, fa = float(tb.getroot().get("frameRate")), float(ta.getroot().get("frameRate"))
    convert = bool(entry.get("convert"))
    errors = []

    def err(msg):
        errors.append(msg)

    if convert:
        if abs(fa - target) > 1e-6:
            err("frame rate %g, expected %g" % (fa, target))
    elif abs(fa - fb) > 1e-6:
        err("frame rate changed %g -> %g although the plan keeps it" % (fb, fa))
    k = int(round(fa / fb))
    if abs(fa / fb - k) > 1e-9:
        err("frame rate %g is not an integer multiple of %g" % (fa, fb))
        return errors, {}

    exports_a = sx.export_names(ta)
    helper_ids = {cid for cid, n in exports_a.items() if n == HELPER_EXPORT}
    if not helper_ids:
        err("skyui.util.FpsScale is not compiled into the patched SWF")

    # --- timelines -----------------------------------------------------------
    tls_b = {t.id: t for t in sx.timelines(tb)}
    tls_a = {t.id: t for t in sx.timelines(ta)}
    extra = [tid for tid in tls_a if tid not in tls_b]
    missing = [tid for tid in tls_b if tid not in tls_a]
    if missing:
        err("timelines missing after patch: %s" % missing)
    # timelines the plan leaves unstretched (engine-driven), with everything nested in them
    listed = list(plan.get("keep_timelines", {}).get(key, {}).keys()) if k > 1 else []
    kept = keep_closure(tls_b, listed)
    for i in listed:
        if i not in tls_b:
            err("keep_timelines lists unknown sprite %s" % i)

    marker_id = one_id = None
    for tid in extra:
        n = tls_a[tid].frame_count
        if n == k and marker_id is None:
            marker_id = tid
        elif n == 1 and kept and one_id is None:
            one_id = tid
        else:
            err("unexpected new timeline %s (%d frames)" % (tid, n))
    if marker_id is None:
        err("the %s marker (a %d-frame sprite) is missing" % (MARKER, k))
    if kept and one_id is None:
        err("the 1-frame %s marker for unstretched timelines is missing" % MARKER)

    stats = {"timelines": 0, "animated": 0, "labels": 0, "scripts": 0, "interp_moves": 0, "kept": len(kept),
             "dur_min": None, "dur_max": None, "prop": 0, "go": 0, "throttle": 0, "gotoframe": 0, "guard": 0}
    exports_b = sx.export_names(tb)

    for tid, tl_b in tls_b.items():
        if tid not in tls_a:
            continue
        tl_a = tls_a[tid]
        name = "main timeline" if tid == sx.ROOT else "sprite %s%s" % (tid, " (%s)" % exports_b[tid] if tid in exports_b else "")
        kt = 1 if tid in kept else k
        nb, na = tl_b.frame_count, tl_a.frame_count
        stats["timelines"] += 1
        if na != nb * kt:
            err("%s: %d frames -> %d, expected %d (duration %.4fs -> %.4fs)" % (name, nb, na, nb * kt, nb / fb, na / fa))
        dur_b, dur_a = nb / fb, na / fa
        if tid in kept:
            if nb > 1:
                notes.append("%s: %s left unstretched (%d frames, engine-driven): plays %dx faster if played" % (key, name, nb, k))
        elif abs(dur_b - dur_a) > 1e-9:
            err("%s: duration %.6fs -> %.6fs" % (name, dur_b, dur_a))
        if nb > 1 and tid not in kept:
            stats["animated"] += 1
            stats["dur_min"] = dur_b if stats["dur_min"] is None else min(stats["dur_min"], dur_b)
            stats["dur_max"] = dur_b if stats["dur_max"] is None else max(stats["dur_max"], dur_b)

        frames_b, trail_b, show_b = frames_of(tl_b)
        frames_a, trail_a, show_a = frames_of(tl_a)
        if show_a != show_b * kt:
            err("%s: %d ShowFrame tags -> %d, expected %d" % (name, show_b, show_a, show_b * kt))
            continue
        if [canonical(e) for e in trail_b] != [canonical(e) for e in trail_a]:
            err("%s: trailing tags changed" % name)
        live_depths = set()
        for f, tags_b in enumerate(frames_b):
            tags_a = list(frames_a[f * kt])
            if tid == sx.ROOT and f == 0:
                defs = [e for e in tags_a if sx.tag_type(e) == "DefineSpriteTag" and e.get("spriteId") in (marker_id, one_id)]
                places = [e for e in tags_a if sx.tag_type(e).startswith("PlaceObject") and e.get("name") == MARKER]
                if len(defs) != len([x for x in (marker_id, one_id) if x]) or len(places) != 1 \
                        or places[0].get("characterId") != marker_id:
                    err("main timeline frame 1: %s marker definition/placement not found" % MARKER)
                tags_a = [e for e in tags_a if not any(e is m for m in defs + places)]
            elif tid in kept and f == 0:
                places = [e for e in tags_a if sx.tag_type(e).startswith("PlaceObject") and e.get("name") == MARKER]
                if len(places) != 1 or places[0].get("characterId") != one_id:
                    err("%s: 1-frame %s marker not placed on frame 1" % (name, MARKER))
                tags_a = [e for e in tags_a if not any(e is m for m in places)]
            cb = [canonical(e) for e in tags_b]
            ca = [canonical(e) for e in tags_a]
            if cb != ca:
                err("%s: original frame %d differs from stretched frame %d (tags %d vs %d)" % (name, f + 1, f * kt + 1, len(cb), len(ca)))
                continue
            for e in tags_b:
                t = sx.tag_type(e)
                if t == "FrameLabelTag":
                    stats["labels"] += 1
                if t.startswith("PlaceObject"):
                    live_depths.add(e.get("depth"))
                elif t.startswith("RemoveObject"):
                    live_depths.discard(e.get("depth"))
            for j in range(1, kt):
                for e in frames_a[f * kt + j]:
                    ok = (sx.tag_type(e) == "PlaceObject2Tag" and e.get("placeFlagMove") == "true"
                          and e.get("placeFlagHasCharacter") == "false" and e.get("placeFlagHasClipActions") == "false"
                          and e.get("placeFlagHasName") == "false" and e.get("depth") in live_depths)
                    if not ok:
                        err("%s: stretched frame %d holds %s, only moves of objects on stage are allowed" % (name, f * kt + j + 1, sx.tag_type(e)))
                    stats["interp_moves"] += 1

            # --- code in this frame -------------------------------------------
            code_b = code_tags(tags_b)
            code_a = code_tags(tags_a)
            if len(code_b) != len(code_a):
                err("%s frame %d: %d code tags -> %d" % (name, f + 1, len(code_b), len(code_a)))
                continue
            for eb, ea in zip(code_b, code_a):
                stats["scripts"] += 1
                where = _where(eb, name, f, exports_b)
                bb, ba = bytes.fromhex(eb.get("actionBytes")), bytes.fromhex(ea.get("actionBytes"))
                is_helper = sx.tag_type(eb) == "DoInitActionTag" and eb.get("spriteId") in helper_ids
                if is_helper:
                    if bb != ba:
                        err("%s: FpsScale itself was rewritten" % where)
                    continue
                try:
                    orig, st = unrewrite(ba, kt, where)
                except (Fail, ValueError) as e:
                    err(str(e))
                    continue
                if orig != bb:
                    err("%s: bytecode differs from the original beyond the documented substitutions" % where)
                    continue
                for kk, v in st.items():
                    stats[kk] += v
                # what the original needed
                acts_b = avm1.parse(bb)
                refs_b = sx.scan(acts_b)
                need = {"prop": 0, "go": 0, "gotoframe": 0, "throttle": 0}
                for r in refs_b:
                    if r.kind == "member_read":
                        need["prop"] += 1
                    elif r.kind == "call_method":
                        need["go"] += 1
                    elif r.kind == "gotoframe" and kt > 1:
                        need["gotoframe"] += 1
                    elif r.kind == "enterframe_assign" and where_key(where) not in free_running:
                        need["throttle"] += 1
                    elif r.kind == "method_override" and where_key(where) not in override_ok:
                        err("%s: defines %s() itself" % (where, r.detail))
                    elif r.kind == "tween_new" and not r.ok:
                        err("%s: frame-based mx.transitions.Tween (%s)" % (where, r.detail))
                    elif r.kind == "tween_useframes" and where_key(where) not in free_running:
                        err("%s: TweenNano/TweenLite useFrames" % where)
                for kk, v in need.items():
                    if st[kk] != v:
                        err("%s: %d %s reference(s) in the original, %d rescaled" % (where, v, kk, st[kk]))
                is_ef_clip = sx.tag_type(eb) == "CLIPACTIONRECORD" and eb.find("eventFlags") is not None \
                    and eb.find("eventFlags").get("clipEventEnterFrame") == "true"
                if is_ef_clip and where_key(where) not in free_running and st["guard"] != 1:
                    err("%s: onClipEvent(enterFrame) is not throttled" % where)
                if st["guard"] and not is_ef_clip:
                    err("%s: tick guard on a handler that is not onClipEvent(enterFrame)" % where)
                if st["throttle"] or st["guard"]:
                    notes.append("%s: %s throttled to %g fps" % (key, where, fb))
                # nothing raw may be left
                acts_a = avm1.parse(ba)
                for r in sx.scan(acts_a):
                    if r.kind in RAW_KINDS:
                        err("%s: raw frame reference left after patch: %s" % (where, r))
    return errors, stats


def keep_closure(tls, ids):
    todo, seen = list(ids), set()
    while todo:
        i = todo.pop()
        if i in seen or i not in tls or i == sx.ROOT:
            continue
        seen.add(i)
        for el in tls[i].container:
            if sx.tag_type(el).startswith("PlaceObject") and el.get("characterId") in tls:
                todo.append(el.get("characterId"))
    return seen


def where_key(where):
    return where.split(" @ ")[0]


def _where(el, tlname, f, exports):
    t = sx.tag_type(el)
    if t == "DoInitActionTag":
        sid = el.get("spriteId")
        return "init %s" % exports.get(sid, "sprite " + str(sid))
    if t == "DoActionTag":
        return "%s frame %d" % (tlname, f + 1)
    return "%s frame %d clip action" % (tlname, f + 1)


def main():
    ap = argparse.ArgumentParser(description="Verify the FPS patch of a build (see module docstring)")
    ap.add_argument("--build", required=True, help="CMake build folder configured with ENABLE_FPS_PATCH=ON")
    ap.add_argument("--ffdec", default=os.environ.get("FFDEC_CLI", "ffdec-cli"), help="FFDec CLI launcher")
    ap.add_argument("--plan", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "fps_patch_plan.json"))
    ap.add_argument("--swf", action="append", help="only check these SWFs (relative to interface/)")
    ap.add_argument("--work", help="folder for the XML exports (default: <build>/staging/fps_check)")
    args = ap.parse_args()

    with open(args.plan, "r", encoding="utf-8") as f:
        plan = json.load(f)
    build = os.path.abspath(args.build)
    unpatched_dir = os.path.join(build, "fps_unpatched")
    final_dir = os.path.join(build, "interface")
    work = args.work or os.path.join(build, "staging", "fps_check")
    if not os.path.isdir(unpatched_dir):
        print("check_fps_patch: %s does not exist - was the build configured with -DENABLE_FPS_PATCH=ON?" % unpatched_dir)
        return 2

    built = sorted(os.path.relpath(p, unpatched_dir).replace("\\", "/").lower()
                   for p in glob.glob(os.path.join(unpatched_dir, "**", "*.swf"), recursive=True))
    failures = 0
    unknown = [s for s in built if s not in plan["swfs"]]
    for s in unknown:
        print("FAIL %s: built but not listed in fps_patch_plan.json" % s)
        failures += 1
    wanted = [x.replace("\\", "/").lower() for x in (args.swf or [])]
    excluded = [s for s, e in plan["swfs"].items() if e.get("exclude") and (not wanted or s in wanted)]
    for s in plan["swfs"]:
        if s not in built and s not in excluded:
            print("note: %s is in the plan but was not built (e.g. SKIP_IN_RELEASE)" % s)

    # excluded SWFs must be byte-for-byte what a patch-off build produces: original rate, no trace of the patch
    for s in excluded:
        final = os.path.join(final_dir, s)
        if not os.path.exists(final):
            print("note: %s is excluded in the plan but was not built" % s)
            continue
        src = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "source", "swf", s[:-4] + ".xml")
        after_xml = os.path.join(work, s[:-4] + ".after.xml")
        errors = []
        try:
            export(args.ffdec, final, after_xml)
            ta = sx.load(after_xml)
            fa = float(ta.getroot().get("frameRate"))
            fs = float(sx.load(src).getroot().get("frameRate")) if os.path.exists(src) else None
            if fs is not None and abs(fa - fs) > 1e-6:
                errors.append("frame rate %g, source XML has %g" % (fa, fs))
            if HELPER_EXPORT in sx.export_names(ta).values():
                errors.append("contains skyui.util.FpsScale")
            if any(el.get("name") == MARKER for el in ta.getroot().iter("item")):
                errors.append("contains a %s marker" % MARKER)
            needle = b"FpsScale".hex()
            if any(needle in (el.get("actionBytes") or "") for el in ta.getroot().iter("item")):
                errors.append("bytecode references FpsScale")
        except Fail as e:
            errors.append(str(e))
        if errors:
            failures += 1
            print("FAIL %s (excluded)" % s)
            for e in errors:
                print("     - %s" % e)
        else:
            print("OK   %-42s excluded: built without the FPS patch, %g fps (%s)" % (s, fa, plan["swfs"][s].get("reason", "")[:90]))

    todo = [s for s in built if s in plan["swfs"] and s not in excluded and (not wanted or s in wanted)]
    notes = []
    for s in todo:
        entry = plan["swfs"][s]
        noext = s[:-4]
        before_xml = os.path.join(build, "staging", "fps", noext + ".unpatched.xml")
        if not os.path.exists(before_xml):
            before_xml = os.path.join(work, noext + ".before.xml")
            export(args.ffdec, os.path.join(unpatched_dir, s), before_xml)
        after_xml = os.path.join(work, noext + ".after.xml")
        try:
            export(args.ffdec, os.path.join(final_dir, s), after_xml)
            errors, st = check_swf(s, entry, plan, before_xml, after_xml, notes)
        except Fail as e:
            errors, st = [str(e)], {}
        if errors:
            failures += 1
            print("FAIL %s" % s)
            for e in errors[:40]:
                print("     - %s" % e)
            if len(errors) > 40:
                print("     ... %d more" % (len(errors) - 40))
            continue
        tb = sx.load(before_xml)
        fb = float(tb.getroot().get("frameRate"))
        k = st and int(round(float(plan["target_fps"]) / fb)) if entry.get("convert") else 1
        dur = ("%.2fs..%.2fs" % (st["dur_min"], st["dur_max"])) if st.get("dur_min") is not None else "-"
        mode = "%g -> %g fps (x%d)" % (fb, fb * k, k) if entry.get("convert") else "kept at %g fps (%s)" % (fb, entry.get("reason", ""))
        print("OK   %-42s %s; %d timelines (%d animated, %s, all durations equal; %d unstretched), %d labels, %d scripts; "
              "rescaled: %d prop, %d goto, %d GotoFrame, %d+%d onEnterFrame throttled; %d interpolated moves"
              % (s, mode, st["timelines"], st["animated"], dur, st["kept"], st["labels"], st["scripts"], st["prop"], st["go"],
                 st["gotoframe"], st["throttle"], st["guard"], st["interp_moves"]))
    if notes:
        print("\nNotes (throttled per-frame handlers run once per original frame):")
        for n in sorted(set(notes)):
            print("  " + n)
    print("\n%d SWF(s) checked, %d failure(s)" % (len(todo) + len(excluded), failures))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
