class Components.BSUIComponent extends MovieClip
{
   var _Beacon;
   var _IsDirty = false;
   function BSUIComponent()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this.focusEnabled = true;
      this._Beacon = this.createEmptyMovieClip("Beacon",this.getInstanceAtDepth(-1) != undefined ? 0 : -1);
   }
   function SetIsDirty()
   {
      this._IsDirty = true;
      this._Beacon.onEnterFrame = Shared.Proxy.create(this,this.RedrawUIComponent);
   }
   function RedrawUIComponent()
   {
      this._Beacon.onEnterFrame = null;
      this._IsDirty = false;
   }
}
