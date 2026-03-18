class WidgetOverlay.Overlay
{
   var BackgroundClip;
   var Clip;
   var FocusClip;
   var _NumWidgets;
   function Overlay(aMovie)
   {
      this.Clip = aMovie;
      this.BackgroundClip = this.Clip.Background;
      this._NumWidgets = 0;
      this.FocusClip = this.Clip.Focus;
      this.FocusClip._visible = false;
   }
   function AddWidget(aWidgetName, aSymbol)
   {
      var _loc4_ = this.Clip.getNextHighestDepth();
      var _loc2_ = aWidgetName + _loc4_.toString();
      var _loc3_;
      if(undefined != aSymbol && aSymbol.length > 0)
      {
         _loc3_ = this.Clip.attachMovie(aSymbol,_loc2_,_loc4_);
      }
      else
      {
         _loc3_ = this.Clip.createEmptyMovieClip(_loc2_,_loc4_);
      }
      if(undefined != _loc3_)
      {
         this._NumWidgets = this._NumWidgets + 1;
      }
      else
      {
         _loc2_ = new String();
      }
      return _loc2_;
   }
   function RemoveWidget(aWidgetName)
   {
      if(undefined != this.Clip[aWidgetName])
      {
         this.Clip[aWidgetName].removeMovieClip();
         this._NumWidgets = this._NumWidgets - 1;
      }
   }
   function SetPosition(aX, aY)
   {
      this.Clip._x = aX;
      this.Clip._y = aY;
   }
   function SetDimensions(aWidth, aHeight)
   {
      this.BackgroundClip._width = aWidth;
      this.BackgroundClip._height = aHeight;
   }
   function SetFocus(abFocus)
   {
      this.FocusClip._visible = abFocus;
   }
   function get NumWidgets()
   {
      return this._NumWidgets;
   }
}
