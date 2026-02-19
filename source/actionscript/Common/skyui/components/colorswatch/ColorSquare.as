class skyui.components.colorswatch.ColorSquare extends gfx.controls.Button
{
   var _color;
   var pigment;
   var selector;
   function ColorSquare()
   {
      super();
   }
   function set color(a_color)
   {
      this._color = a_color;
      this.setColor(this._color);
   }
   function get color()
   {
      return this._color;
   }
   function setColor(a_color)
   {
      var _loc2_ = new flash.geom.ColorTransform();
      _loc2_.rgb = a_color;
      var _loc3_ = new flash.geom.Transform(this.pigment);
      _loc3_.colorTransform = _loc2_;
      _loc2_.rgb = skyui.util.ColorFunctions.hexToHsv(a_color)[2] >= 75 ? 0 : 16777215;
      _loc3_ = new flash.geom.Transform(this.selector);
      _loc3_.colorTransform = _loc2_;
      this.selector._alpha = 0;
   }
}
