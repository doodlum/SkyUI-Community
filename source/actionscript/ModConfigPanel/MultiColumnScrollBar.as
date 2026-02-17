class MultiColumnScrollBar extends gfx.controls.ScrollBar
{
   var _position;
   var _scrollDelta = 1;
   var _trackScrollPageSize = 1;
   function MultiColumnScrollBar()
   {
      super();
   }
   function get trackScrollPageSize()
   {
      return this._trackScrollPageSize;
   }
   function set trackScrollPageSize(a_val)
   {
      this._trackScrollPageSize = Math.ceil(a_val / this._scrollDelta) * this._scrollDelta;
   }
   function get scrollDelta()
   {
      return this._scrollDelta;
   }
   function set scrollDelta(a_val)
   {
      this._scrollDelta = a_val;
      this._trackScrollPageSize = Math.ceil(this._trackScrollPageSize / a_val) * a_val;
   }
   function get position()
   {
      return this._position;
   }
   function set position(a_val)
   {
      a_val -= a_val % this._scrollDelta;
      super.position = a_val;
   }
   function scrollWheel(a_delta)
   {
      this.position -= a_delta * this._trackScrollPageSize;
   }
   function scrollUp()
   {
      this.position -= this._scrollDelta;
   }
   function scrollDown()
   {
      this.position += this._scrollDelta;
   }
}
