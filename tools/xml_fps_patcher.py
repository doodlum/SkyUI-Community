"""FPS patch for SkyUI SWFs (FFDec XML export of the FINAL, script-injected SWF).

For every SWF listed as "convert" in tools/fps_patch_plan.json the frame rate is raised to --fps (an integer
multiple k of the original rate) and EVERY timeline - the main timeline and every DefineSprite - is stretched
by k, so animations keep their length in seconds:

  * original frame f becomes frames (f-1)*k+1 .. f*k; its tags (frame scripts, labels, placements, ...) stay
    on the first of them, in their original order;
  * the k-1 new frames hold the display list, except that objects moved by a run of consecutive keyframes
    (classic tweens) get interpolated PlaceObject2 moves, so tweens render at the higher rate.

All ActionScript in the SWF (frame scripts, onClipEvent handlers and the classes injected by the build) is
rewritten so it keeps working in ORIGINAL frame numbers, through skyui.util.FpsScale (which must be compiled
into the SWF):

  * mc._currentframe / _totalframes / _framesloaded  -> FpsScale.prop(name, mc)
  * mc.gotoAndStop/gotoAndPlay/nextFrame/prevFrame()  -> FpsScale.go(name, mc, nargs, args...)
  * GotoFrame (frame scripts' gotoAndStop(n) literal) -> frame index * k
  * x.onEnterFrame = fn                               -> x.onEnterFrame = FpsScale.throttle(fn)
    (per-frame code then still runs at the original rate), and onClipEvent(enterFrame) handlers get the
    same guard; handlers listed under "enterframe_free_running" in the plan (time-based tweens) are left alone.

Any frame-related construct the patcher cannot rewrite safely aborts the build with its location.
SWFs listed as "keep" keep their frame rate and timelines; their code is still rewritten (with k = 1 for their
own clips) because it may drive clips of converted SWFs loaded into them.

A child clip "__fpsScale" with k frames is added to every patched main timeline; FpsScale reads k from it.
check_fps_patch.py verifies the result independently.
"""

import argparse
import copy
import json
import math
import os
import struct
import sys
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fps_avm1 as avm1  # noqa: E402
import fps_swfxml as sx  # noqa: E402

HELPER_EXPORT = "__Packages.skyui.util.FpsScale"
HELPER_PATH = ("skyui", "util", "FpsScale")
MARKER_NAME = "__fpsScale"
ROTATION_LIMIT = math.radians(45)


class PatchError(Exception):
    pass


# ---------------------------------------------------------------------------
# Plan
# ---------------------------------------------------------------------------

def load_plan(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def plan_entry(plan, swf_rel):
    key = swf_rel.replace("\\", "/").lower()
    entry = plan["swfs"].get(key)
    if entry is None:
        raise PatchError("%s is not listed in fps_patch_plan.json; add it under \"swfs\" with "
                         "\"convert\": true/false and a reason" % key)
    return key, entry


# ---------------------------------------------------------------------------
# Bytecode rewriting
# ---------------------------------------------------------------------------

def helper_call(method, nargs_push=None):
    """Actions that call skyui.util.FpsScale.<method> with the arguments already on the stack.
    If nargs_push is given it is pushed as the argument count first."""
    out = []
    if nargs_push is not None:
        out.append(avm1.mk_push(nargs_push, HELPER_PATH[0]))
    else:
        out.append(avm1.mk_push(HELPER_PATH[0]))
    out.append(avm1.mk(0x1C))  # GetVariable skyui
    for part in HELPER_PATH[1:]:
        out.append(avm1.mk_push(part))
        out.append(avm1.mk(0x4E))  # GetMember
    out.append(avm1.mk_push(method))
    out.append(avm1.mk(0x52))  # CallMethod
    return out


def guard_prefix(key, code_len_after):
    """if (!FpsScale.tick(this, key)) skip the rest of the handler."""
    acts = [avm1.mk_push(key, "this"), avm1.mk(0x1C)] + helper_call("tick", 2) + [avm1.mk(0x12)]
    head = b"".join(a.encode() for a in acts)
    jump = avm1.mk(0x9D, struct.pack("<h", code_len_after))
    return head + jump.encode()


# frame operations that act on "the current timeline" and so would follow a tellTarget()
TIMELINE_OPS = ("gotoframe", "gotoframe2", "nextframe", "prevframe", "getprop", "var_read", "call_function")


def rewrite_blob(blob, k_own, free_running, override_ok, stats, guard_key):
    code = blob.code
    actions = avm1.parse(code)
    popped, _ = avm1.analyse(actions)
    refs = sx.scan(actions, popped)
    kinds = {r.kind for r in refs}
    if "settarget" in kinds and kinds & set(TIMELINE_OPS):
        raise PatchError("%s: tellTarget combined with timeline actions" % blob.where)
    repl = {}
    for r in refs:
        a = actions[r.idx]
        if r.kind in ("settarget", "gettime") or (r.kind == "tween_new" and r.ok):
            continue
        if r.kind == "tween_useframes" and blob.where in free_running:
            continue  # the tween engine's own reserved-property table
        if r.kind == "method_override":
            if blob.where in override_ok:
                continue
            raise PatchError("%s: defines its own %s(); if this is not a MovieClip class add it to "
                             "\"method_override_allowed\" in the plan" % (blob.where, r.detail))
        if not r.ok:
            raise PatchError("%s: cannot rescale %s %s (action %d)" % (blob.where, r.kind, r.detail, r.idx))
        if r.kind == "member_read":
            repl[r.idx] = helper_call("prop", 2)
            stats["prop"] += 1
        elif r.kind == "call_method":
            nargs = int(r.detail.split("/")[1])
            repl[r.idx] = helper_call("go", nargs + 3)
            stats["go"] += 1
        elif r.kind == "gotoframe":
            idx = int.from_bytes(a.payload[:2], "little")
            new = idx * k_own
            if new > 0xFFFF:
                raise PatchError("%s: GotoFrame %d out of range after stretching" % (blob.where, idx + 1))
            repl[r.idx] = [avm1.mk(0x81, new.to_bytes(2, "little"))]
            stats["gotoframe"] += 1
        elif r.kind == "enterframe_assign":
            if blob.where in free_running:
                stats["enterframe_free"] += 1
                continue
            repl[r.idx] = helper_call("throttle", 1) + [a]
            stats["throttle"] += 1
        else:
            raise PatchError("%s: unhandled frame reference %s" % (blob.where, r))
    new_code = avm1.assemble(actions, repl, len(code)) if repl else code
    if blob.enter_frame and blob.where not in free_running:
        flags = blob.el.find("eventFlags")
        others = [k for k, v in flags.attrib.items()
                  if k.startswith("clipEvent") and v == "true" and k != "clipEventEnterFrame"]
        if others:
            raise PatchError("%s: onClipEvent(enterFrame) shares its handler with %s" % (blob.where, others))
        body = new_code
        last = avm1.parse(body)[-1] if body else None
        target = last.offset if (last is not None and last.code == 0x00) else len(body)  # skip to End
        new_code = guard_prefix(guard_key, target) + body
        stats["clip_guard"] += 1
    if new_code != code:
        blob.code = new_code


# ---------------------------------------------------------------------------
# Timeline stretching
# ---------------------------------------------------------------------------

def _f(el, name, default=0.0):
    v = el.get(name)
    return float(v) if v is not None else default


def read_matrix(el):
    if el is None:
        return None
    hs = el.get("hasScale") == "true"
    hr = el.get("hasRotate") == "true"
    return {
        "hasScale": hs, "hasRotate": hr,
        "a": _f(el, "scaleX") if hs else 1.0,
        "d": _f(el, "scaleY") if hs else 1.0,
        "b": _f(el, "rotateSkew0") if hr else 0.0,
        "c": _f(el, "rotateSkew1") if hr else 0.0,
        "tx": int(el.get("translateX", "0")),
        "ty": int(el.get("translateY", "0")),
    }


CX_TERMS = ("redMultTerm", "greenMultTerm", "blueMultTerm", "alphaMultTerm",
            "redAddTerm", "greenAddTerm", "blueAddTerm", "alphaAddTerm")


def read_cx(el):
    if el is None:
        return None
    hm = el.get("hasMultTerms") == "true"
    ha = el.get("hasAddTerms") == "true"
    res = {"type": el.get("type"), "hasMult": hm, "hasAdd": ha}
    for t in CX_TERMS:
        if t.endswith("MultTerm"):
            res[t] = int(el.get(t, "256")) if hm else 256
        else:
            res[t] = int(el.get(t, "0")) if ha else 0
    return res


def sbits(vals):
    vals = [int(v) for v in vals]
    if not any(vals):
        return 0
    return max((v if v >= 0 else ~v).bit_length() for v in vals) + 1


def fixed(v):
    return round(v * 65536) / 65536.0


def _angle(x, y):
    return math.atan2(y, x)


def _adiff(a1, a2):
    d = abs(a1 - a2) % (2 * math.pi)
    return min(d, 2 * math.pi - d)


def lerp_matrix(m1, m2, t):
    if _adiff(_angle(m1["a"], m1["b"]), _angle(m2["a"], m2["b"])) > ROTATION_LIMIT:
        return None
    if _adiff(_angle(m1["d"], -m1["c"]), _angle(m2["d"], -m2["c"])) > ROTATION_LIMIT:
        return None
    r = {k: m1[k] + (m2[k] - m1[k]) * t for k in ("a", "b", "c", "d")}
    r["tx"] = int(math.floor(m1["tx"] + (m2["tx"] - m1["tx"]) * t + 0.5))
    r["ty"] = int(math.floor(m1["ty"] + (m2["ty"] - m1["ty"]) * t + 0.5))
    r["hasScale"] = m1["hasScale"] or m2["hasScale"]
    r["hasRotate"] = m1["hasRotate"] or m2["hasRotate"]
    return r


def matrix_el(m):
    a, d = (fixed(m["a"]), fixed(m["d"])) if m["hasScale"] else (0.0, 0.0)
    b, c = (fixed(m["b"]), fixed(m["c"])) if m["hasRotate"] else (0.0, 0.0)
    el = ET.Element("matrix")
    el.set("type", "MATRIX")
    el.set("hasRotate", "true" if m["hasRotate"] else "false")
    el.set("hasScale", "true" if m["hasScale"] else "false")
    el.set("nRotateBits", str(sbits([b * 65536, c * 65536]) if m["hasRotate"] else 0))
    el.set("nScaleBits", str(sbits([a * 65536, d * 65536]) if m["hasScale"] else 0))
    el.set("nTranslateBits", str(sbits([m["tx"], m["ty"]])))
    el.set("rotateSkew0", repr(b))
    el.set("rotateSkew1", repr(c))
    el.set("scaleX", repr(a))
    el.set("scaleY", repr(d))
    el.set("translateX", str(m["tx"]))
    el.set("translateY", str(m["ty"]))
    return el


def lerp_cx(c1, c2, t):
    r = {"type": "CXFORMWITHALPHA", "hasMult": c1["hasMult"] or c2["hasMult"], "hasAdd": c1["hasAdd"] or c2["hasAdd"]}
    for term in CX_TERMS:
        r[term] = int(math.floor(c1[term] + (c2[term] - c1[term]) * t + 0.5))
    return r


def cx_el(c):
    el = ET.Element("colorTransform")
    el.set("type", "CXFORMWITHALPHA")
    vals = []
    for term in CX_TERMS:
        on = c["hasMult"] if term.endswith("MultTerm") else c["hasAdd"]
        v = c[term] if on else 0
        el.set(term, str(v))
        if on:
            vals.append(v)
    el.set("hasAddTerms", "true" if c["hasAdd"] else "false")
    el.set("hasMultTerms", "true" if c["hasMult"] else "false")
    el.set("nbits", str(max(1, sbits(vals))))
    return el


def move_tag(depth, matrix=None, cx=None, ratio=None):
    el = ET.Element("item")
    el.set("type", "PlaceObject2Tag")
    el.set("characterId", "0")
    el.set("clipDepth", "0")
    el.set("depth", str(depth))
    el.set("forceWriteAsLong", "false")
    el.set("placeFlagHasCharacter", "false")
    el.set("placeFlagHasClipActions", "false")
    el.set("placeFlagHasClipDepth", "false")
    el.set("placeFlagHasColorTransform", "true" if cx else "false")
    el.set("placeFlagHasMatrix", "true" if matrix else "false")
    el.set("placeFlagHasName", "false")
    el.set("placeFlagHasRatio", "true" if ratio is not None else "false")
    el.set("placeFlagMove", "true")
    el.set("ratio", str(ratio if ratio is not None else 0))
    if matrix:
        el.append(matrix_el(matrix))
    if cx:
        el.append(cx_el(cx))
    return el


def display_states(frames):
    """Per frame: (state dict depth->(inst, matrix, cx, ratio), moved depths, placed depths)."""
    state = {}
    inst_counter = 0
    res = []
    for tags in frames:
        moved, placed = set(), set()
        for el in tags:
            t = sx.tag_type(el)
            if t.startswith("PlaceObject"):
                d = int(el.get("depth"))
                has_char = t == "PlaceObjectTag" or el.get("placeFlagHasCharacter") == "true"
                mx = read_matrix(el.find("matrix")) if (t == "PlaceObjectTag" or el.get("placeFlagHasMatrix") == "true") else None
                cxe = el.find("colorTransform")
                cx = read_cx(cxe) if (cxe is not None and (t == "PlaceObjectTag" or el.get("placeFlagHasColorTransform") == "true")) else None
                ratio = int(el.get("ratio")) if el.get("placeFlagHasRatio") == "true" else None
                if has_char or d not in state:
                    inst_counter += 1
                    state[d] = [inst_counter, mx, cx, ratio]
                    placed.add(d)
                else:
                    s = state[d]
                    if mx is not None:
                        s[1] = mx
                    if cx is not None:
                        s[2] = cx
                    if ratio is not None:
                        s[3] = ratio
                    moved.add(d)
            elif t.startswith("RemoveObject"):
                state.pop(int(el.get("depth")), None)
        res.append(({d: tuple(v) for d, v in state.items()}, moved, placed))
    return res


def stretch_timeline(tl, k, show_proto, stats):
    frames = []
    cur = []
    trailing = []
    children = list(tl.container)
    nshow = 0
    for el in children:
        if sx.tag_type(el) == "ShowFrameTag":
            frames.append(cur)
            cur = []
            nshow += 1
        else:
            cur.append(el)
    trailing = cur
    states = display_states(frames)
    n = len(frames)
    new_children = []
    for i in range(n):
        new_children.extend(frames[i])
        new_children.append(copy.copy(show_proto))
        nxt = states[i + 1] if i + 1 < n else None
        interp = []
        if nxt is not None:
            s_i, moved_i, placed_i = states[i]
            s_n, moved_n, _ = nxt
            moved_n2 = states[i + 2][1] if i + 2 < n else set()
            for d in sorted(moved_n):
                if d not in s_i or d not in s_n or s_i[d][0] != s_n[d][0]:
                    continue
                if not (d in moved_i or d in placed_i or d in moved_n2):
                    continue  # isolated jump, not a tween: keep the snap
                interp.append((d, s_i[d], s_n[d]))
        for j in range(1, k):
            t = j / float(k)
            for d, a, b in interp:
                mx = cx = ratio = None
                if a[1] is not None and b[1] is not None and a[1] != b[1]:
                    mx = lerp_matrix(a[1], b[1], t)
                if a[2] is not None and b[2] is not None and a[2] != b[2]:
                    cx = lerp_cx(a[2], b[2], t)
                if a[3] is not None and b[3] is not None and a[3] != b[3]:
                    ratio = int(math.floor(a[3] + (b[3] - a[3]) * t + 0.5))
                if mx or cx or ratio is not None:
                    new_children.append(move_tag(d, mx, cx, ratio))
                    stats["interp_tags"] += 1
            new_children.append(copy.copy(show_proto))
    new_children.extend(trailing)
    for el in children:
        tl.container.remove(el)
    for el in new_children:
        tl.container.append(el)
    tl.header.set("frameCount", str(int(tl.header.get("frameCount")) * k))
    stats["timelines"] += 1


# ---------------------------------------------------------------------------
# Marker
# ---------------------------------------------------------------------------

def free_character_id(tree):
    used = {int(v) for el in tree.getroot().iter() for a, v in el.attrib.items()
            if (a.endswith("Id") or a.endswith("ID")) and v.isdigit()}
    i = 1
    while i in used:
        i += 1
    if i > 65535:
        raise PatchError("no free character id")
    return i


def _marker_sprite(sprite_id, frames):
    sprite = ET.Element("item", {"type": "DefineSpriteTag", "forceWriteAsLong": "true", "frameCount": str(frames),
                                 "hasEndTag": "true", "spriteId": str(sprite_id)})
    sub = ET.SubElement(sprite, "subTags")
    for _ in range(frames):
        ET.SubElement(sub, "item", {"type": "ShowFrameTag", "forceWriteAsLong": "false"})
    return sprite


def _marker_place(sprite_id, depth):
    if depth >= 16384:
        raise PatchError("no free timeline depth for the FPS marker")
    return ET.Element("item", {
        "type": "PlaceObject2Tag", "characterId": str(sprite_id), "clipDepth": "0", "depth": str(depth),
        "forceWriteAsLong": "true", "name": MARKER_NAME, "placeFlagHasCharacter": "true",
        "placeFlagHasClipActions": "false", "placeFlagHasClipDepth": "false", "placeFlagHasColorTransform": "false",
        "placeFlagHasMatrix": "false", "placeFlagHasName": "true", "placeFlagHasRatio": "false",
        "placeFlagMove": "false", "ratio": "0"})


def _first_frame_pos(container):
    """Index of the first PlaceObject/ShowFrame tag (where frame 1's display list starts)."""
    for i, el in enumerate(list(container)):
        t = sx.tag_type(el)
        if t.startswith("PlaceObject") or t == "ShowFrameTag":
            return i
    return len(list(container))


def add_markers(tree, k, kept):
    """Main timeline: child "__fpsScale" with k frames.  Every timeline in `kept` (left unstretched inside a
    converted SWF) gets its own 1-frame "__fpsScale" child, so FpsScale.factor() returns 1 for it and for
    everything nested in it."""
    swf = tree.getroot()
    tags = swf.find("tags")
    head = 0
    for i, el in enumerate(list(tags)):
        if sx.tag_type(el) in ("FileAttributesTag", "MetadataTag", "SetBackgroundColorTag", "ScriptLimitsTag",
                               "EnableDebuggerTag", "EnableDebugger2Tag", "ProductInfoTag"):
            head = i + 1
        else:
            break
    root_id = free_character_id(tree)
    tags.insert(head, _marker_sprite(root_id, k))
    depth = max([int(el.get("depth")) for el in tags if sx.tag_type(el).startswith("PlaceObject")] + [0]) + 1
    tags.insert(_first_frame_pos(tags), _marker_place(root_id, depth))
    if kept:
        one_id = free_character_id(tree)
        tags.insert(head, _marker_sprite(one_id, 1))
        for tl in sx.timelines(tree):
            if tl.id in kept:
                d = max([int(el.get("depth")) for el in tl.container if sx.tag_type(el).startswith("PlaceObject")] + [0]) + 1
                tl.container.insert(_first_frame_pos(tl.container), _marker_place(one_id, d))


def kept_closure(tree, ids):
    """`ids` plus every sprite placed (directly or indirectly) inside them."""
    tls = {tl.id: tl for tl in sx.timelines(tree)}
    todo, seen = [i for i in ids], set()
    while todo:
        i = todo.pop()
        if i in seen or i not in tls or i == sx.ROOT:
            continue
        seen.add(i)
        for el in tls[i].container:
            if sx.tag_type(el).startswith("PlaceObject") and el.get("characterId") in tls:
                todo.append(el.get("characterId"))
    return seen

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def patch(tree, swf_key, entry, plan, target_fps):
    swf = tree.getroot()
    if entry.get("exclude"):
        raise PatchError("%s is excluded in the plan; the build must not run the patcher on it "
                         "(reconfigure CMake after editing fps_patch_plan.json)" % swf_key)
    orig_fps = float(swf.get("frameRate"))
    convert = bool(entry.get("convert"))
    k = 1
    if convert:
        ratio = target_fps / orig_fps
        k = int(round(ratio))
        if abs(ratio - k) > 1e-6 or k < 1:
            raise PatchError("%s: %g fps is not an integer multiple of %g fps" % (swf_key, target_fps, orig_fps))
    stats = {"prop": 0, "go": 0, "gotoframe": 0, "throttle": 0, "enterframe_free": 0, "clip_guard": 0,
             "timelines": 0, "kept_timelines": 0, "interp_tags": 0}
    listed = list(plan.get("keep_timelines", {}).get(swf_key, {}).keys())
    kept = kept_closure(tree, listed)
    missing = [i for i in listed if i not in kept]
    if missing:
        raise PatchError("%s: keep_timelines lists unknown sprite(s) %s" % (swf_key, missing))

    if convert and k > 1:
        for el in swf.iter("item"):
            t = sx.tag_type(el)
            if t in ("SoundStreamHeadTag", "SoundStreamHead2Tag", "SoundStreamBlockTag", "DefineVideoStreamTag", "VideoFrameTag"):
                raise PatchError("%s: contains %s, which is frame-synchronised and cannot be stretched" % (swf_key, t))

    exports = sx.export_names(tree)
    helper_ids = {cid for cid, name in exports.items() if name == HELPER_EXPORT}
    if not helper_ids:
        raise PatchError("%s: skyui.util.FpsScale is not compiled into this SWF (the build adds it when "
                         "ENABLE_FPS_PATCH is ON)" % swf_key)

    # code blobs may only live where fps_swfxml.blobs() looks for them
    for el in swf.iter("item"):
        if el.get("actionBytes") is not None and sx.tag_type(el) not in ("DoActionTag", "DoInitActionTag", "CLIPACTIONRECORD"):
            raise PatchError("%s: unexpected code in %s" % (swf_key, sx.tag_type(el)))

    free_running = set(plan.get("enterframe_free_running", {}).keys())
    override_ok = set(plan.get("method_override_allowed", {}).keys())
    guard_n = 0
    for blob in list(sx.blobs(tree)):
        if blob.kind == "DoInitAction" and blob.el.get("spriteId") in helper_ids:
            continue
        guard_n += 1
        # GotoFrame acts on the timeline the script sits on; unstretched timelines keep their numbers
        k_own = 1 if blob.timeline in kept else k
        rewrite_blob(blob, k_own, free_running, override_ok, stats, "__fpsTickCE%d" % guard_n)

    if convert and k > 1:
        show_proto = None
        for el in swf.iter("item"):
            if sx.tag_type(el) == "ShowFrameTag":
                show_proto = copy.copy(el)
                break
        for tl in sx.timelines(tree):
            if tl.id in kept:
                stats["kept_timelines"] += 1
                continue
            stretch_timeline(tl, k, show_proto, stats)
        swf.set("frameRate", "%.1f" % (orig_fps * k))

    add_markers(tree, k, kept if k > 1 else set())
    return k, stats


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--in", dest="inp", required=True, help="FFDec XML export of the unpatched SWF")
    ap.add_argument("--out", required=True, help="patched XML to write")
    ap.add_argument("--swf", required=True, help="SWF path relative to interface/, e.g. skyui/itemcard.swf")
    ap.add_argument("--plan", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "fps_patch_plan.json"))
    ap.add_argument("--fps", type=float, default=None, help="target frame rate (default: plan target_fps)")
    args = ap.parse_args()

    plan = load_plan(args.plan)
    fps = args.fps if args.fps is not None else float(plan["target_fps"])
    try:
        key, entry = plan_entry(plan, args.swf)
        tree = sx.load(args.inp)
        k, stats = patch(tree, key, entry, plan, fps)
    except PatchError as e:
        print("xml_fps_patcher: ERROR: %s" % e, file=sys.stderr)
        return 1
    sx.save(tree, args.out)
    mode = "x%d -> %g fps" % (k, fps) if entry.get("convert") else "kept at original rate"
    print("[fps] %s: %s; %s" % (key, mode, ", ".join("%s=%d" % kv for kv in stats.items())))
    return 0


if __name__ == "__main__":
    sys.exit(main())
