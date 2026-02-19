class skyui.components.list.SortedListHeader extends MovieClip
{
   var _columns;
   var _layout;
   var columnIndex;
   var iconColumnIndicator;
   var sortIcon;
   function SortedListHeader()
   {
      super();
      this._columns = new Array();
   }
   function get layout()
   {
      return this._layout;
   }
   function set layout(a_layout)
   {
      if(this._layout)
      {
         this._layout.removeEventListener("layoutChange",this,"onLayoutChange");
      }
      this._layout = a_layout;
      this._layout.addEventListener("layoutChange",this,"onLayoutChange");
   }
   function columnPress(a_columnIndex)
   {
      this._layout.selectColumn(a_columnIndex);
   }
   function clearColumns()
   {
      var _loc2_ = 0;
      while(_loc2_ < this._columns.length)
      {
         this._columns[_loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
   function addColumn(a_index)
   {
      if(a_index < 0)
      {
         return undefined;
      }
      var _loc2_ = this["Column" + a_index];
      if(_loc2_ != undefined)
      {
         this._columns[a_index] = _loc2_;
         this._columns[a_index]._visible = true;
         return _loc2_;
      }
      _loc2_ = this.attachMovie("HeaderColumn","Column" + a_index,this.getNextHighestDepth());
      _loc2_.columnIndex = a_index;
      _loc2_.onPress = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
      {
         if(!this.columnIndex != undefined)
         {
            this._parent.columnPress(this.columnIndex);
         }
      };
      _loc2_.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
      {
         if(!this.columnIndex != undefined)
         {
            this._parent.columnPress(this.columnIndex);
         }
      };
      this._columns[a_index] = _loc2_;
      return _loc2_;
   }
   function onLayoutChange(event)
   {
      this.clearColumns();
      var _loc5_ = this._layout.activeColumnIndex;
      var _loc3_ = 0;
      var _loc4_;
      var _loc2_;
      while(_loc3_ < this._layout.columnCount)
      {
         _loc4_ = this._layout.columnLayoutData[_loc3_];
         _loc2_ = this.addColumn(_loc3_);
         _loc2_.label._x = 0;
         _loc2_._x = _loc4_.labelX;
         _loc2_.label._width = _loc4_.labelWidth;
         _loc2_.label.setTextFormat(_loc4_.labelTextFormat);
         _loc2_.label.SetText(_loc4_.labelValue);
         if(_loc5_ == _loc3_)
         {
            this.sortIcon.gotoAndStop(!_loc4_.labelArrowDown ? "asc" : "desc");
         }
         _loc3_ = _loc3_ + 1;
      }
      this.positionButtons();
   }
   function positionButtons()
   {
      var _loc4_ = this._layout.activeColumnIndex;
      var _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < this._columns.length)
      {
         _loc2_ = this._columns[_loc3_];
         _loc2_.label._y = - _loc2_.label._height;
         _loc2_.buttonArea._x = _loc2_.label.getLineMetrics(0).x - 4;
         _loc2_.buttonArea._width = _loc2_.label.getLineMetrics(0).width + 8;
         _loc2_.buttonArea._y = _loc2_.label._y - 2;
         _loc2_.buttonArea._height = _loc2_.label._height + 2;
         if(this._layout.columnLayoutData[_loc3_].type == skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON)
         {
            this.iconColumnIndicator._x = _loc2_._x + _loc2_.buttonArea._x + _loc2_.buttonArea._width;
            this.iconColumnIndicator._y = - _loc2_._height + (_loc2_._height - this.iconColumnIndicator._height) / 2;
         }
         if(_loc4_ == _loc3_)
         {
            this.sortIcon._x = _loc2_._x + _loc2_.buttonArea._x + _loc2_.buttonArea._width;
            this.sortIcon._y = - _loc2_._height + (_loc2_._height - this.sortIcon._height) / 2 - 1;
            this.iconColumnIndicator._visible = this._layout.columnLayoutData[_loc3_].type != skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON;
         }
         _loc3_ = _loc3_ + 1;
      }
   }
}
