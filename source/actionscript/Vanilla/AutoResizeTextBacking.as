class AutoResizeTextBacking extends MovieClip
{
   var _LeftMargin;
   var _LowerMargin;
   var _RightMargin;
   var _Text_tf;
   var _UpperMargin;
   function AutoResizeTextBacking()
   {
      super();
   }
   function SetTextToFit(tf)
   {
      this._Text_tf = tf;
      this._Text_tf.onChanged = Shared.Proxy.create(this,this.ResizeBacking);
      this.ResizeBacking();
   }
   function ResizeBacking()
   {
      var _loc2_;
      switch(this._Text_tf.autoSize)
      {
         case "left":
            this._Text_tf._x = this._x - this._LeftMargin;
            this._y = this._Text_tf._y + this._UpperMargin;
            this._width = this._Text_tf._width + this._RightMargin - this._LeftMargin;
            this._height = this._Text_tf._height + this._LowerMargin - this._UpperMargin;
            return;
         case "right":
            _loc2_ = this._x + this._width;
            this._Text_tf._x = _loc2_ - this._Text_tf._width - this._RightMargin;
            this._x = this._Text_tf._x + this._LeftMargin;
            this._y = this._Text_tf._y + this._UpperMargin;
            this._width = this._Text_tf._width + this._RightMargin - this._LeftMargin;
            this._height = this._Text_tf._height + this._LowerMargin - this._UpperMargin;
            return;
         default:
            this._x = this._Text_tf._x + this._LeftMargin;
            this._y = this._Text_tf._y + this._UpperMargin;
            this._width = this._Text_tf._width + this._RightMargin - this._LeftMargin;
            this._height = this._Text_tf._height + this._LowerMargin - this._UpperMargin;
            return;
      }
   }
}
