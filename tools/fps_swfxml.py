"""Helpers for FFDec SWF XML exports: timelines, code blobs and frame-reference scanning.

Shared by xml_fps_patcher.py and check_fps_patch.py.
"""

import xml.etree.ElementTree as ET

import fps_avm1 as avm1

ROOT = "root"


def load(path):
    return ET.parse(path)


def save(tree, path):
    tree.write(path, encoding="UTF-8", xml_declaration=True)


def tag_type(el):
    return el.get("type", "")


class Timeline:
    """A main timeline or a DefineSprite.  `container` is the element whose
    children are the timeline's tags (swf/tags or DefineSprite/subTags)."""

    def __init__(self, tid, container, header):
        self.id = tid
        self.container = container
        self.header = header  # element holding frameCount (swf root or DefineSprite)

    @property
    def frame_count(self):
        return int(self.header.get("frameCount"))

    def frames(self):
        """List of frames, each a list of tag elements (ShowFrame excluded)."""
        out, cur = [], []
        for el in list(self.container):
            if tag_type(el) == "ShowFrameTag":
                out.append(cur)
                cur = []
            else:
                cur.append(el)
        if cur:
            out.append(cur)  # trailing tags (End etc.) after last ShowFrame
        return out

    def labels(self):
        res = []
        for i, f in enumerate(self.frames()):
            for el in f:
                if tag_type(el) == "FrameLabelTag":
                    res.append((el.get("name"), i))
        return res


def timelines(tree):
    swf = tree.getroot()
    tags = swf.find("tags")
    res = [Timeline(ROOT, tags, swf)]
    for el in tags:
        if tag_type(el) == "DefineSpriteTag":
            res.append(Timeline(el.get("spriteId"), el.find("subTags"), el))
    return res


def export_names(tree):
    """characterId -> export name (e.g. '__Packages.skyui.util.Tween')."""
    out = {}
    for el in tree.getroot().find("tags"):
        if tag_type(el) == "ExportAssetsTag":
            tags = el.find("tags")
            names = el.find("names")
            if tags is None or names is None:
                continue
            ids = [x.text for x in tags]
            nms = [x.text for x in names]
            for i, n in zip(ids, nms):
                out[i] = n
    return out


class Blob:
    def __init__(self, el, kind, timeline, frame, where, enter_frame=False):
        self.el = el
        self.kind = kind          # DoAction / DoInitAction / ClipAction
        self.timeline = timeline  # timeline id that holds the tag
        self.frame = frame        # 0-based frame index in that timeline
        self.where = where        # human readable location
        self.enter_frame = enter_frame

    @property
    def code(self):
        return bytes.fromhex(self.el.get("actionBytes"))

    @code.setter
    def code(self, b):
        self.el.set("actionBytes", b.hex())


def blobs(tree):
    exports = export_names(tree)
    for tl in timelines(tree):
        for fi, frame in enumerate(tl.frames()):
            for el in frame:
                t = tag_type(el)
                if t == "DoActionTag":
                    yield Blob(el, "DoAction", tl.id, fi, "%s frame %d" % (_tl_name(tl.id, exports), fi + 1))
                elif t == "DoInitActionTag":
                    sid = el.get("spriteId")
                    yield Blob(el, "DoInitAction", tl.id, fi, "init %s" % exports.get(sid, "sprite " + str(sid)))
                elif t.startswith("PlaceObject"):
                    ca = el.find("clipActions")
                    if ca is None:
                        continue
                    recs = ca.find("clipActionRecords")
                    for rec in (recs if recs is not None else []):
                        flags = rec.find("eventFlags")
                        ef = flags is not None and flags.get("clipEventEnterFrame") == "true"
                        ev = [k[len("clipEvent"):] for k, v in (flags.attrib.items() if flags is not None else []) if k.startswith("clipEvent") and v == "true"]
                        yield Blob(rec, "ClipAction", tl.id, fi,
                                   "%s frame %d onClipEvent(%s) char %s" % (_tl_name(tl.id, exports), fi + 1, ",".join(ev), el.get("characterId") or "?"),
                                   enter_frame=ef)


def _tl_name(tid, exports):
    if tid == ROOT:
        return "main timeline"
    n = exports.get(tid)
    return "sprite %s%s" % (tid, " (%s)" % n if n else "")


# ---------------------------------------------------------------------------
# Frame reference scanning
# ---------------------------------------------------------------------------

def _lit_name(slot):
    return slot.value if (slot is not None and slot.lit and isinstance(slot.value, str)) else None


# AS2 resolves MovieClip properties case-insensitively (vanilla Messages.as reads "_currentFrame"),
# so names are compared lower-cased.
_PROPS = {p.lower() for p in avm1.FRAME_PROPS}
_METHODS = {m.lower() for m in avm1.FRAME_METHODS}


def is_frame_prop(name):
    return name is not None and name.lower() in _PROPS


def is_frame_method(name):
    return name is not None and name.lower() in _METHODS


def _is_frame_var(name):
    if name is None:
        return None
    low = name.lower()
    for p in _PROPS:
        if low == p or low.endswith("." + p) or low.endswith(":" + p) or low.endswith("/" + p):
            return p
    return None


class Ref:
    __slots__ = ("kind", "idx", "detail", "ok")

    def __init__(self, kind, idx, detail, ok=True):
        self.kind = kind
        self.idx = idx
        self.detail = detail
        self.ok = ok  # False: the patcher cannot rescale this reference automatically

    def __repr__(self):
        return "%s(%s)%s" % (self.kind, self.detail, "" if self.ok else "!")


def scan(actions, popped=None):
    """Return a list of Ref describing every frame-number related operation."""
    if popped is None:
        popped, _ = avm1.analyse(actions)
    refs = []
    for i, a in enumerate(actions):
        c = a.code
        pp = popped[i] or []
        if c == 0x4E:  # GetMember
            n = _lit_name(pp[0]) if pp else None
            if is_frame_prop(n):
                refs.append(Ref("member_read", i, n))
            elif n is None and pp and not pp[0].lit:
                pass  # dynamic member name (obj[expr]); see dynamic_names check in check_fps_patch.py
        elif c == 0x4F:  # SetMember
            n = _lit_name(pp[1]) if len(pp) > 1 else None
            if is_frame_method(n):
                refs.append(Ref("method_override", i, n, ok=False))
            elif n is not None and n.lower() == "onenterframe":
                refs.append(Ref("enterframe_assign", i, n))
        elif c in (0x1D, 0x3C):  # SetVariable / DefineLocal
            n = _lit_name(pp[1]) if len(pp) > 1 else None
            if n is not None and n.lower().split(".")[-1] == "onenterframe":
                refs.append(Ref("enterframe_assign", i, n, ok=(c == 0x1D and "." not in n)))
        elif c in (0x40, 0x53):  # NewObject / NewMethod: frame-based tween engines
            n = _lit_name(pp[0]) if pp else None
            if n == "Tween":
                nslot = pp[2] if c == 0x53 else pp[1]
                args = pp[3:] if c == 0x53 else pp[2:]
                use_seconds = len(args) >= 7 and args[6].lit and args[6].value is True
                refs.append(Ref("tween_new", i, "useSeconds=%s" % use_seconds, ok=use_seconds))
        elif c == 0x43:  # InitObject: TweenNano/TweenLite vars {useFrames: true}
            names = [s.value for s in pp[2::2] if s.lit and isinstance(s.value, str)] if pp else []
            if "useFrames" in names:
                refs.append(Ref("tween_useframes", i, "", ok=False))
        elif c == 0x1C:  # GetVariable
            n = _lit_name(pp[0]) if pp else None
            p = _is_frame_var(n)
            if p:
                refs.append(Ref("var_read", i, n, ok=(n == p)))
        elif c == 0x22:  # GetProperty
            idx = pp[0] if pp else None
            tgt = pp[1] if len(pp) > 1 else None
            if idx is not None and idx.lit and isinstance(idx.value, (int, float)):
                if int(idx.value) in avm1.FRAME_PROP_INDEX:
                    own = tgt is not None and tgt.lit and tgt.value == ""
                    refs.append(Ref("getprop", i, "%s on %s" % (avm1.FRAME_PROP_INDEX[int(idx.value)], "this" if own else "target"), ok=own))
            else:
                refs.append(Ref("getprop_dynamic", i, "?", ok=False))
        elif c in (0x52, 0x3D):  # CallMethod / CallFunction
            n = _lit_name(pp[0]) if pp else None
            if is_frame_method(n):
                nslot = pp[2] if c == 0x52 else pp[1]
                nargs = int(nslot.value) if (nslot.lit and isinstance(nslot.value, (int, float))) else None
                kind = "call_method" if c == 0x52 else "call_function"
                refs.append(Ref(kind, i, "%s/%s" % (n, nargs), ok=(nargs is not None and nargs <= 2 and c == 0x52)))
        elif c == 0x81:
            refs.append(Ref("gotoframe", i, str(int.from_bytes(a.payload[:2], "little") + 1)))
        elif c == 0x9F:
            bias = a.payload[0] & 2
            refs.append(Ref("gotoframe2", i, "play" if a.payload[0] & 1 else "stop", ok=not bias))
        elif c in (0x04, 0x05):
            refs.append(Ref("nextframe" if c == 0x04 else "prevframe", i, ""))
        elif c in (0x8B, 0x20):
            refs.append(Ref("settarget", i, "", ok=False))
        elif c in (0x8A, 0x8D):
            refs.append(Ref("waitforframe", i, "", ok=False))
        elif c == 0x34:
            refs.append(Ref("gettime", i, ""))
        elif c == 0x96:
            pass
    return refs
