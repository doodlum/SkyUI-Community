"""Minimal AVM1 (ActionScript 2 bytecode) disassembler, stack tracker and rewriter.

Used by xml_fps_patcher.py (to rescale frame-number references when a SWF's
timelines are stretched) and by check_fps_patch.py (to prove that no raw
frame-number reference survived the rewrite).

Only what the FPS patch needs is modelled:
  * decoding every action (so branch/function/with/try sizes can be relocated),
  * a per-basic-block symbolic stack so we know which literal fed which call,
  * re-encoding with all relative offsets / block sizes fixed up after edits.
"""

import struct

# Frame-number properties of a MovieClip.
FRAME_PROPS = ("_currentframe", "_totalframes", "_framesloaded")
# GetProperty/SetProperty indices for the same properties.
FRAME_PROP_INDEX = {4: "_currentframe", 5: "_totalframes", 12: "_framesloaded"}
# MovieClip methods whose numeric argument (or effect) is a frame number.
FRAME_METHODS = ("gotoAndStop", "gotoAndPlay", "nextFrame", "prevFrame")

NAMES = {
    0x00: "End", 0x04: "NextFrame", 0x05: "PrevFrame", 0x06: "Play", 0x07: "Stop",
    0x08: "ToggleQuality", 0x09: "StopSounds", 0x0A: "Add", 0x0B: "Subtract",
    0x0C: "Multiply", 0x0D: "Divide", 0x0E: "Equals", 0x0F: "Less", 0x10: "And",
    0x11: "Or", 0x12: "Not", 0x13: "StringEquals", 0x14: "StringLength",
    0x15: "StringExtract", 0x17: "Pop", 0x18: "ToInteger", 0x1C: "GetVariable",
    0x1D: "SetVariable", 0x20: "SetTarget2", 0x21: "StringAdd", 0x22: "GetProperty",
    0x23: "SetProperty", 0x24: "CloneSprite", 0x25: "RemoveSprite", 0x26: "Trace",
    0x27: "StartDrag", 0x28: "EndDrag", 0x29: "StringLess", 0x2A: "Throw",
    0x2B: "CastOp", 0x2C: "ImplementsOp", 0x30: "RandomNumber",
    0x31: "MBStringLength", 0x32: "CharToAscii", 0x33: "AsciiToChar", 0x34: "GetTime",
    0x35: "MBStringExtract", 0x36: "MBCharToAscii", 0x37: "MBAsciiToChar",
    0x3A: "Delete", 0x3B: "Delete2", 0x3C: "DefineLocal", 0x3D: "CallFunction",
    0x3E: "Return", 0x3F: "Modulo", 0x40: "NewObject", 0x41: "DefineLocal2",
    0x42: "InitArray", 0x43: "InitObject", 0x44: "TypeOf", 0x45: "TargetPath",
    0x46: "Enumerate", 0x47: "Add2", 0x48: "Less2", 0x49: "Equals2", 0x4A: "ToNumber",
    0x4B: "ToString", 0x4C: "PushDuplicate", 0x4D: "StackSwap", 0x4E: "GetMember",
    0x4F: "SetMember", 0x50: "Increment", 0x51: "Decrement", 0x52: "CallMethod",
    0x53: "NewMethod", 0x54: "InstanceOf", 0x55: "Enumerate2", 0x60: "BitAnd",
    0x61: "BitOr", 0x62: "BitXor", 0x63: "BitLShift", 0x64: "BitRShift",
    0x65: "BitURShift", 0x66: "StrictEquals", 0x67: "Greater", 0x68: "StringGreater",
    0x69: "Extends", 0x81: "GotoFrame", 0x83: "GetURL", 0x87: "StoreRegister",
    0x88: "ConstantPool", 0x8A: "WaitForFrame", 0x8B: "SetTarget", 0x8C: "GotoLabel",
    0x8D: "WaitForFrame2", 0x8E: "DefineFunction2", 0x8F: "Try", 0x94: "With",
    0x96: "Push", 0x99: "Jump", 0x9A: "GetURL2", 0x9B: "DefineFunction", 0x9D: "If",
    0x9E: "Call", 0x9F: "GotoFrame2",
}

# Fixed (pops, pushes) stack effects. None = variable, handled in code.
_FIXED = {
    0x04: (0, 0), 0x05: (0, 0), 0x06: (0, 0), 0x07: (0, 0), 0x08: (0, 0), 0x09: (0, 0),
    0x0A: (2, 1), 0x0B: (2, 1), 0x0C: (2, 1), 0x0D: (2, 1), 0x0E: (2, 1), 0x0F: (2, 1),
    0x10: (2, 1), 0x11: (2, 1), 0x12: (1, 1), 0x13: (2, 1), 0x14: (1, 1), 0x15: (3, 1),
    0x17: (1, 0), 0x18: (1, 1), 0x1C: (1, 1), 0x1D: (2, 0), 0x20: (1, 0), 0x21: (2, 1),
    0x22: (2, 1), 0x23: (3, 0), 0x24: (3, 0), 0x25: (1, 0), 0x26: (1, 0), 0x28: (0, 0),
    0x29: (2, 1), 0x2A: (1, 0), 0x2B: (2, 1), 0x30: (1, 1), 0x31: (1, 1), 0x32: (1, 1),
    0x33: (1, 1), 0x34: (0, 1), 0x35: (3, 1), 0x36: (1, 1), 0x37: (1, 1), 0x3A: (2, 1),
    0x3B: (1, 1), 0x3C: (2, 0), 0x3E: (1, 0), 0x3F: (2, 1), 0x41: (1, 0), 0x44: (1, 1),
    0x45: (1, 1), 0x47: (2, 1), 0x48: (2, 1), 0x49: (2, 1), 0x4A: (1, 1), 0x4B: (1, 1),
    0x4E: (2, 1), 0x4F: (3, 0), 0x50: (1, 1), 0x51: (1, 1), 0x54: (2, 1), 0x60: (2, 1),
    0x61: (2, 1), 0x62: (2, 1), 0x63: (2, 1), 0x64: (2, 1), 0x65: (2, 1), 0x66: (2, 1),
    0x67: (2, 1), 0x68: (2, 1), 0x69: (2, 0), 0x81: (0, 0), 0x83: (0, 0), 0x87: (0, 0),
    0x88: (0, 0), 0x8B: (0, 0), 0x8C: (0, 0), 0x8D: (1, 0), 0x94: (1, 0), 0x9A: (2, 0),
    0x9D: (1, 0), 0x9E: (1, 0), 0x9F: (1, 0), 0x99: (0, 0), 0x8A: (0, 0), 0x8F: (0, 0),
}


def _cstr(buf, pos):
    end = buf.index(b"\x00", pos)
    return buf[pos:end].decode("utf-8", "replace"), end + 1


class PushValue:
    __slots__ = ("type", "value")

    def __init__(self, t, v):
        self.type = t
        self.value = v

    def encode(self):
        t, v = self.type, self.value
        if t == 0:
            return b"\x00" + v.encode("utf-8") + b"\x00"
        if t == 1:
            return b"\x01" + struct.pack("<f", v)
        if t in (2, 3):
            return bytes([t])
        if t in (4, 5, 8):
            return bytes([t, v])
        if t == 6:
            raw = struct.pack("<d", v)
            return b"\x06" + raw[4:8] + raw[0:4]
        if t == 7:
            return b"\x07" + struct.pack("<i", v)
        if t == 9:
            return b"\x09" + struct.pack("<H", v)
        raise ValueError("bad push type %r" % t)

    def is_number(self):
        return self.type in (1, 6, 7)

    def __repr__(self):
        return "PushValue(%d,%r)" % (self.type, self.value)


class Action:
    __slots__ = ("offset", "code", "payload", "size", "values", "pool")

    def __init__(self, offset, code, payload):
        self.offset = offset
        self.code = code
        self.payload = payload
        self.size = 1 + (2 + len(payload) if code >= 0x80 else 0)
        self.values = None
        self.pool = None

    @property
    def name(self):
        return NAMES.get(self.code, "0x%02X" % self.code)

    @property
    def end(self):
        return self.offset + self.size

    # --- payload accessors -------------------------------------------------
    def push_values(self):
        if self.values is None:
            vals, p, b = [], 0, self.payload
            while p < len(b):
                t = b[p]
                p += 1
                if t == 0:
                    s, p = _cstr(b, p)
                    vals.append(PushValue(0, s))
                elif t == 1:
                    vals.append(PushValue(1, struct.unpack_from("<f", b, p)[0]))
                    p += 4
                elif t in (2, 3):
                    vals.append(PushValue(t, None))
                elif t in (4, 5, 8):
                    vals.append(PushValue(t, b[p]))
                    p += 1
                elif t == 6:
                    raw = b[p + 4:p + 8] + b[p:p + 4]
                    vals.append(PushValue(6, struct.unpack("<d", raw)[0]))
                    p += 8
                elif t == 7:
                    vals.append(PushValue(7, struct.unpack_from("<i", b, p)[0]))
                    p += 4
                elif t == 9:
                    vals.append(PushValue(9, struct.unpack_from("<H", b, p)[0]))
                    p += 2
                else:
                    raise ValueError("unknown push type %d" % t)
            self.values = vals
        return self.values

    def constant_pool(self):
        b = self.payload
        n = struct.unpack_from("<H", b, 0)[0]
        p, out = 2, []
        for _ in range(n):
            s, p = _cstr(b, p)
            out.append(s)
        return out

    def branch_offset(self):  # Jump / If
        return struct.unpack_from("<h", self.payload, 0)[0]

    def block_sizes(self):
        """Sizes (in bytes) of the code blocks that follow this action inline."""
        b = self.payload
        if self.code == 0x9B:  # DefineFunction
            _, p = _cstr(b, 0)
            n = struct.unpack_from("<H", b, p)[0]
            p += 2
            for _ in range(n):
                _, p = _cstr(b, p)
            return [struct.unpack_from("<H", b, p)[0]]
        if self.code == 0x8E:  # DefineFunction2
            _, p = _cstr(b, 0)
            n = struct.unpack_from("<H", b, p)[0]
            p += 2 + 1 + 2
            for _ in range(n):
                p += 1
                _, p = _cstr(b, p)
            return [struct.unpack_from("<H", b, p)[0]]
        if self.code == 0x94:  # With
            return [struct.unpack_from("<H", b, 0)[0]]
        if self.code == 0x8F:  # Try
            return list(struct.unpack_from("<HHH", b, 1))
        return []

    def with_block_sizes(self, sizes):
        b = bytearray(self.payload)
        if self.code in (0x9B, 0x8E):
            struct.pack_into("<H", b, len(b) - 2, sizes[0])
        elif self.code == 0x94:
            struct.pack_into("<H", b, 0, sizes[0])
        elif self.code == 0x8F:
            struct.pack_into("<HHH", b, 1, *sizes)
        return bytes(b)

    def function_name(self):
        return _cstr(self.payload, 0)[0] if self.code in (0x9B, 0x8E) else None

    def encode(self):
        if self.code < 0x80:
            return bytes([self.code])
        return bytes([self.code]) + struct.pack("<H", len(self.payload)) + self.payload

    def __repr__(self):
        extra = ""
        if self.code == 0x96:
            extra = " " + ", ".join(repr(v) for v in self.push_values())
        return "<%04x %s%s>" % (self.offset, self.name, extra)


def parse(code):
    actions, p = [], 0
    while p < len(code):
        c = code[p]
        if c >= 0x80:
            ln = struct.unpack_from("<H", code, p + 1)[0]
            a = Action(p, c, bytes(code[p + 3:p + 3 + ln]))
        else:
            a = Action(p, c, b"")
        actions.append(a)
        p += a.size
        if c == 0 and p >= len(code):
            break
    return actions


def mk(code, payload=b""):
    return Action(-1, code, payload)


def mk_push(*vals):
    """vals: python str / int / float. ints -> int32, floats -> double."""
    out = []
    for v in vals:
        if isinstance(v, PushValue):
            out.append(v)
        elif isinstance(v, str):
            out.append(PushValue(0, v))
        elif isinstance(v, bool):
            out.append(PushValue(5, int(v)))
        elif isinstance(v, int):
            out.append(PushValue(7, v))
        elif isinstance(v, float):
            out.append(PushValue(6, v))
        else:
            raise TypeError(v)
    a = mk(0x96, b"".join(x.encode() for x in out))
    a.values = out
    return a


# ---------------------------------------------------------------------------
# Symbolic stack tracking
# ---------------------------------------------------------------------------

class Slot:
    """One stack entry: either a literal (value known) or the result of an action."""
    __slots__ = ("lit", "value", "src")

    def __init__(self, lit, value, src):
        self.lit = lit      # True if value is a known literal
        self.value = value  # python value (str/int/float/None)
        self.src = src      # (action index, push value index) or action index

    def __repr__(self):
        return "Lit(%r)" % (self.value,) if self.lit else "Unk"


UNK = Slot(False, None, None)


def scopes(actions):
    """For each action, the index of the innermost DefineFunction whose body
    contains it (-1 for top level)."""
    res = []
    open_ = []  # (end_offset, func_index)
    for i, a in enumerate(actions):
        while open_ and a.offset >= open_[-1][0]:
            open_.pop()
        res.append(open_[-1][1] if open_ else -1)
        if a.code in (0x9B, 0x8E):
            open_.append((a.end + a.block_sizes()[0], i))
    return res


def analyse(actions):
    """Annotate each action with the slots it pops: returns list `popped`
    where popped[i] is a list of Slots, top of stack first (None if the
    action was not reached with a tracked stack).  Also returns the constant
    pool in effect for each action."""
    # branch targets reset the tracked stack (we do not merge paths); a
    # target only counts inside the function scope the jump comes from.
    scope = scopes(actions)
    targets = set()
    for i, a in enumerate(actions):
        if a.code in (0x99, 0x9D):
            targets.add((scope[i], a.end + a.branch_offset()))
    popped = [None] * len(actions)
    pools = [None] * len(actions)
    stack = []
    pool = []
    frames = []  # (end_offset, saved_stack, anonymous)
    for i, a in enumerate(actions):
        while frames and a.offset >= frames[-1][0]:
            end, saved, anon = frames.pop()
            stack = saved
            if anon:
                stack.append(Slot(False, None, ("func", end)))
        if (scope[i], a.offset) in targets:
            stack = []
        pools[i] = pool

        def pop():
            return stack.pop() if stack else UNK

        c = a.code
        if c == 0x88:
            pool = a.constant_pool()
            pools[i] = pool
            popped[i] = []
            continue
        if c == 0x96:
            for vi, v in enumerate(a.push_values()):
                if v.type in (0, 1, 6, 7):
                    stack.append(Slot(True, v.value, (i, vi)))
                elif v.type in (8, 9):
                    val = pool[v.value] if v.value < len(pool) else None
                    stack.append(Slot(val is not None, val, (i, vi)))
                elif v.type == 2:
                    stack.append(Slot(True, None, (i, vi)))
                elif v.type == 5:
                    stack.append(Slot(True, bool(v.value), (i, vi)))
                else:
                    stack.append(Slot(False, None, (i, vi)))
            popped[i] = []
            continue
        if c in (0x9B, 0x8E):
            size = a.block_sizes()[0]
            anon = a.function_name() == ""
            frames.append((a.end + size, stack, anon))
            stack = []
            popped[i] = []
            continue
        if c == 0x4C:  # PushDuplicate
            t = pop()
            popped[i] = [t]
            stack += [t, t]
            continue
        if c == 0x4D:  # StackSwap
            t1, t2 = pop(), pop()
            popped[i] = [t1, t2]
            stack += [t1, t2]
            continue
        if c in (0x3D, 0x52, 0x53, 0x40):  # CallFunction, CallMethod, NewMethod, NewObject
            name = pop()
            got = [name]
            if c in (0x52, 0x53):
                got.append(pop())  # object
            n = pop()
            got.append(n)
            if n.lit and isinstance(n.value, (int, float)) and n.value == int(n.value) and 0 <= n.value < 256:
                for _ in range(int(n.value)):
                    got.append(pop())
                stack.append(Slot(False, None, i))
            else:
                stack = []  # unknown arg count: lose track
                stack.append(Slot(False, None, i))
            popped[i] = got
            continue
        if c in (0x42,):  # InitArray
            n = pop()
            got = [n]
            if n.lit and isinstance(n.value, (int, float)):
                for _ in range(int(n.value)):
                    got.append(pop())
            else:
                stack = []
            stack.append(Slot(False, None, i))
            popped[i] = got
            continue
        if c == 0x43:  # InitObject
            n = pop()
            got = [n]
            if n.lit and isinstance(n.value, (int, float)):
                for _ in range(2 * int(n.value)):
                    got.append(pop())
            else:
                stack = []
            stack.append(Slot(False, None, i))
            popped[i] = got
            continue
        if c in (0x27, 0x2C, 0x46, 0x55):  # variable / enumerations: lose track
            popped[i] = [pop()]
            stack = []
            continue
        if c in (0x99, 0x3E, 0x2A):  # Jump/Return/Throw: next action unreachable linearly
            eff = _FIXED.get(c, (0, 0))
            popped[i] = [pop() for _ in range(eff[0])]
            stack = []
            continue
        if c in _FIXED:
            np, nq = _FIXED[c]
            popped[i] = [pop() for _ in range(np)]
            for _ in range(nq):
                stack.append(Slot(False, None, i))
            continue
        popped[i] = []
        stack = []  # unknown action
    return popped, pools


# ---------------------------------------------------------------------------
# Re-encoding with relocation
# ---------------------------------------------------------------------------

def assemble(actions, replacements, original_len):
    """Rebuild bytecode.  `replacements` maps an action index to a list of
    new Action objects that take its place (an empty list deletes it).
    Branch targets and block sizes that pointed at an action now point at
    the start of its replacement."""
    # compute new size per original index
    seq = []
    for i, a in enumerate(actions):
        seq.append(replacements.get(i, [a]))
    new_start = {}
    pos = 0
    for i, a in enumerate(actions):
        new_start[a.offset] = pos
        pos += sum(x.size for x in seq[i])
    new_start[original_len] = pos  # end-of-code target
    # also allow targets at the end of the last action
    if actions:
        new_start.setdefault(actions[-1].end, pos)

    def remap(old_off):
        if old_off not in new_start:
            raise ValueError("branch into the middle of an action at %d" % old_off)
        return new_start[old_off]

    out = bytearray()
    for i, a in enumerate(actions):
        for x in seq[i]:
            if x is a:
                if a.code in (0x99, 0x9D):
                    tgt = remap(a.end + a.branch_offset())
                    my_end = len(out) + a.size
                    a2 = Action(-1, a.code, struct.pack("<h", tgt - my_end))
                    out += a2.encode()
                    continue
                sizes = a.block_sizes()
                if sizes:
                    start = a.end
                    new_sizes = []
                    cur_old = start
                    cur_new = len(out) + a.size
                    for s in sizes:
                        e_new = remap(cur_old + s)
                        new_sizes.append(e_new - cur_new)
                        cur_old += s
                        cur_new = e_new
                    out += Action(-1, a.code, a.with_block_sizes(new_sizes)).encode()
                    continue
            out += x.encode()
    return bytes(out)
