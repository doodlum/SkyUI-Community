class skyui.components.colorswatch.ColorSwatch extends MovieClip
{
   var _buttonGroup;
   var _colorCols;
   var _highestColorDepth;
   var _selectedColor;
   var background;
   var colorList;
   var colorRows = 2;
   var colorSize = 25;
   function ColorSwatch()
   {
      super();
      if(this.colorList == null)
      {
         this.colorList = [10027059,11337843,10581760,8404237,12406553,31367,1450612,5188991,5649997,6393346,34114,6047798,10066329,0,13369395,15231909,15379200,12092500,14905890,10092543,4219055,9202896,9397880,10398469,1684081,11181199,13421772,16777215];
      }
      skyui.util.GlobalFunctions.addArrayFunctions();
      this._colorCols = Math.floor(this.colorList.length / this.colorRows);
      this._buttonGroup = new gfx.controls.ButtonGroup();
      this._buttonGroup.name = "colorButtons";
      var _loc5_;
      var _loc6_;
      var _loc3_;
      var _loc4_ = 0;
      while(_loc4_ < this.colorList.length)
      {
         _loc6_ = _loc4_ % this._colorCols;
         _loc5_ = Math.floor(_loc4_ / this._colorCols);
         _loc3_ = this.attachMovie("ColorSquare","ColorSquare" + _loc4_,this.getNextHighestDepth());
         _loc3_._x = _loc6_ * this.colorSize - _loc6_;
         _loc3_._y = _loc5_ * this.colorSize - _loc5_;
         _loc3_._width = _loc3_._height = this.colorSize;
         _loc3_.color = this.colorList[_loc4_];
         _loc3_.addEventListener("select",this,"onColorClipSelect");
         this._buttonGroup.addButton(skyui.components.colorswatch.ColorSquare(_loc3_));
         _loc4_ = _loc4_ + 1;
      }
      this.background._width = this._width;
      this.background._height = this._height;
      this._highestColorDepth = !(_loc3_ != undefined && this.colorList.length > 0) ? this.getNextHighestDepth() : _loc3_.getDepth();
   }
   function set selectedColor(a_color)
   {
      this._selectedColor = a_color;
      this.attemptSelectColor(this._selectedColor);
   }
   function get selectedColor()
   {
      return this._selectedColor;
   }
   function handleInput(a_details, a_pathToFocus)
   {
      var _loc3_ = false;
      var _loc4_;
      var _loc8_;
      var _loc2_;
      var _loc5_;
      var _loc6_;
      if(Shared.GlobalFunc.IsKeyPressed(a_details,false))
      {
         _loc4_ = this._buttonGroup.indexOf(this._buttonGroup.selectedButton);
         _loc8_ = this._buttonGroup.length - 1;
         _loc2_ = _loc4_;
         _loc5_ = Math.floor(_loc4_ / this._colorCols);
         _loc6_ = _loc4_ % this._colorCols;
         if(_loc2_ == -1)
         {
            switch(a_details.navEquivalent)
            {
               case gfx.ui.NavigationCode.RIGHT:
               case gfx.ui.NavigationCode.DOWN:
                  _loc2_ = 0;
                  _loc3_ = true;
                  break;
               case gfx.ui.NavigationCode.LEFT:
               case gfx.ui.NavigationCode.UP:
                  _loc2_ = _loc8_;
                  _loc3_ = true;
            }
         }
         else
         {
            switch(a_details.navEquivalent)
            {
               case gfx.ui.NavigationCode.UP:
                  if(_loc5_ > 0)
                  {
                     _loc2_ -= this._colorCols;
                  }
                  else
                  {
                     _loc2_ += this._colorCols;
                  }
                  _loc3_ = true;
                  break;
               case gfx.ui.NavigationCode.DOWN:
                  if(_loc5_ < this.colorRows - 1)
                  {
                     _loc2_ += this._colorCols;
                  }
                  else
                  {
                     _loc2_ -= this._colorCols;
                  }
                  _loc3_ = true;
                  break;
               case gfx.ui.NavigationCode.LEFT:
                  if(_loc6_ > 0)
                  {
                     _loc2_ -= 1;
                  }
                  else
                  {
                     _loc2_ += this._colorCols - 1;
                  }
                  _loc3_ = true;
                  break;
               case gfx.ui.NavigationCode.RIGHT:
                  if(_loc6_ < this._colorCols - 1)
                  {
                     _loc2_ += 1;
                  }
                  else
                  {
                     _loc2_ -= this._colorCols - 1;
                  }
                  _loc3_ = true;
            }
         }
         if(_loc2_ != _loc4_)
         {
            this._buttonGroup.setSelectedButton(this._buttonGroup.getButtonAt(_loc2_));
         }
      }
      return _loc3_;
   }
   function onColorClipSelect(event)
   {
      var _loc2_ = event.target;
      if(_loc2_.selected)
      {
         this._selectedColor = _loc2_.color;
         _loc2_._x -= this.colorSize * 0.5 / 2;
         _loc2_._y -= this.colorSize * 0.5 / 2;
         _loc2_._width = _loc2_._height = this.colorSize * 1.5;
         _loc2_.swapDepths(this._highestColorDepth);
         _loc2_.selector._alpha = 100;
      }
      else
      {
         _loc2_._x += this.colorSize * 0.5 / 2;
         _loc2_._y += this.colorSize * 0.5 / 2;
         _loc2_._width = _loc2_._height = this.colorSize;
         _loc2_.selector._alpha = 0;
      }
   }
   function attemptSelectColor(a_color)
   {
      var _loc3_ = this.colorList.indexOf(a_color);
      var _loc2_;
      if(_loc3_ == undefined)
      {
         _loc2_ = skyui.components.colorswatch.ColorSquare(this._buttonGroup.getButtonAt(0));
      }
      else
      {
         _loc2_ = skyui.components.colorswatch.ColorSquare(this._buttonGroup.getButtonAt(_loc3_));
         this._buttonGroup.setSelectedButton(_loc2_);
      }
      gfx.managers.FocusHandler.instance.setFocus(_loc2_,0);
   }
}
