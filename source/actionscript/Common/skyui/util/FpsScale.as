/*
 * Runtime side of the FPS patch (tools/xml_fps_patcher.py).
 *
 * The patch raises a SWF's frame rate by an integer factor k (e.g. 24 -> 120 fps, k = 5) and stretches every
 * timeline by the same factor, so original frame f becomes frames (f-1)*k+1 .. f*k and animations keep their
 * real-time length. ActionScript keeps working in ORIGINAL frame numbers: the patcher rewrites every
 *   mc._currentframe / _totalframes / _framesloaded   -> FpsScale.prop(name, mc)
 *   mc.gotoAndStop / gotoAndPlay / nextFrame / prevFrame(...) -> FpsScale.go(name, mc, nargs, ...)
 *   x.onEnterFrame = fn                                 -> x.onEnterFrame = FpsScale.throttle(fn)
 * in the compiled bytecode, and these functions translate between original and stretched frame numbers.
 *
 * k is looked up per clip, because SWFs with different original rates load into each other (itemcard.swf at
 * 30 fps inside inventorymenu.swf at 60 fps): the patcher puts a child clip named "__fpsScale" on every patched
 * SWF's main timeline whose _totalframes is that SWF's k (1 for SWFs it leaves at their original rate). Clips
 * with no marker above them (FPS patch off, or third-party SWFs) get k = 1, i.e. no translation at all.
 *
 * This class itself is never rewritten by the patcher, so the property reads and calls below are native.
 */
class skyui.util.FpsScale
{
   static var MARKER = "__fpsScale";
   static var _nextId = 0;

   function FpsScale()
   {
   }

   // Stretch factor of the timeline `a_mc` belongs to.
   static function factor(a_mc)
   {
      var p = a_mc;
      var m;
      while(p != undefined && p != null)
      {
         m = p[skyui.util.FpsScale.MARKER];
         if(m != undefined && m._totalframes > 0)
         {
            return m._totalframes;
         }
         p = p._parent;
      }
      return 1;
   }

   // Original frame number of stretched frame a_frame.
   static function toOriginal(a_frame, a_k)
   {
      return Math.floor((a_frame - 1) / a_k) + 1;
   }

   // First stretched frame of original frame a_frame (fractions map inside the stretched span).
   static function toStretched(a_frame, a_k)
   {
      return Math.floor((a_frame - 1) * a_k) + 1;
   }

   // Replacement for reading a_mc[a_name] where a_name is _currentframe, _totalframes or _framesloaded.
   static function prop(a_name, a_mc)
   {
      var v = a_mc[a_name];
      if(typeof a_mc != "movieclip" || typeof v != "number")
      {
         return v;
      }
      var k = skyui.util.FpsScale.factor(a_mc);
      if(k == 1)
      {
         return v;
      }
      if(a_name.toLowerCase() == "_currentframe")
      {
         return skyui.util.FpsScale.toOriginal(v,k);
      }
      return Math.ceil(v / k);
   }

   // Replacement for a_mc[a_name](args...) where a_name is gotoAndStop, gotoAndPlay, nextFrame or prevFrame.
   static function go(a_name, a_mc, a_nargs, a_frame, a_arg2)
   {
      var args = [];
      var i = 0;
      while(i < a_nargs)
      {
         args.push(arguments[3 + i]);
         i++;
      }
      if(typeof a_mc != "movieclip")
      {
         // Not a timeline (e.g. mx.transitions.Tween has its own nextFrame/prevFrame): plain call.
         return a_mc[a_name].apply(a_mc,args);
      }
      var k = skyui.util.FpsScale.factor(a_mc);
      if(k == 1)
      {
         return a_mc[a_name].apply(a_mc,args);
      }
      var lname = a_name.toLowerCase();
      var cur = skyui.util.FpsScale.toOriginal(a_mc._currentframe,k);
      if(lname == "nextframe" || lname == "prevframe")
      {
         var total = Math.ceil(a_mc._totalframes / k);
         var target = lname == "nextframe" ? cur + 1 : cur - 1;
         if(target < 1 || target > total)
         {
            a_mc.stop();
            return undefined;
         }
         a_mc.gotoAndStop(skyui.util.FpsScale.toStretched(target,k));
         return undefined;
      }
      if(a_nargs >= 1 && typeof a_frame == "number")
      {
         // Going to the original frame the clip is already on keeps the exact stretched position, so idioms like
         // mc.gotoAndPlay(mc._currentframe) called every frame still let the clip advance.
         // Code outside the patched SWFs (SKSE plugins, other mods' SWFs) reads the raw stretched frame and resumes
         // from it, e.g. Health.PlayForward(Health._currentframe) -> gotoAndPlay(raw): that raw number is the clip's
         // own current frame, so it is kept as is rather than scaled a second time.
         var raw = a_mc._currentframe;
         args[0] = a_frame == cur || (lname == "gotoandplay" && a_frame == raw) ? raw : skyui.util.FpsScale.toStretched(a_frame,k);
      }
      return a_mc[a_name].apply(a_mc,args);
   }

   // Wraps an onEnterFrame handler so it runs once per ORIGINAL frame (every k-th frame of the clip it is
   // called on): per-frame counters and steps written for the original rate keep their real-time speed.
   static function throttle(a_fn)
   {
      if(typeof a_fn != "function" || a_fn.__fpsInner != undefined)
      {
         return a_fn;
      }
      var key = "__fpsTick" + skyui.util.FpsScale._nextId++;
      var wrapper = function()
      {
         if(!skyui.util.FpsScale.tick(this,key))
         {
            return undefined;
         }
         return a_fn.apply(this,arguments);
      };
      wrapper.__fpsInner = a_fn;
      return wrapper;
   }

   // True on every k-th call for (a_mc, a_key); used by throttle() and by onClipEvent(enterFrame) guards.
   static function tick(a_mc, a_key)
   {
      var k = skyui.util.FpsScale.factor(a_mc);
      if(k <= 1)
      {
         return true;
      }
      var t = a_mc[a_key];
      if(t == undefined)
      {
         t = 0;
         a_mc[a_key] = 0;
         _global.ASSetPropFlags(a_mc,a_key,1);
      }
      t = t + 1;
      if(t >= k)
      {
         a_mc[a_key] = 0;
         return true;
      }
      a_mc[a_key] = t;
      return false;
   }
}
