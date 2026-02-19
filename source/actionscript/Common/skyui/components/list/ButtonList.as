class skyui.components.list.ButtonList extends skyui.components.list.BasicList
{
   var _bRequestUpdate;
   var _bSuspended;
   var _selectedIndex;
   var background;
   var bottomBorder;
   var disableInput;
   var disableSelection;
   var dispatchEvent;
   var doSetSelectedIndex;
   var getClipByIndex;
   var getListEnumEntry;
   var getListEnumFirstIndex;
   var getListEnumLastIndex;
   var getListEnumRelativeIndex;
   var getListEnumSize;
   var getSelectedListEnumIndex;
   var isMouseDrivenNav;
   var leftBorder;
   var listState;
   var onItemPress;
   var rightBorder;
   var setClipCount;
   var topBorder;
   var ALIGN_LEFT = 0;
   var ALIGN_RIGHT = 1;
   var _bAutoScale = true;
   var _minButtonWidth = 10;
   var _buttonWidth = 0;
   var _align = skyui.components.list.ButtonList.prototype.ALIGN_RIGHT;
   function ButtonList()
   {
      super();
   }
   function get autoScale()
   {
      return this._bAutoScale;
   }
   function set autoScale(a_bAutoScale)
   {
      this._bAutoScale = a_bAutoScale;
   }
   function get minButtonWidth()
   {
      return this._minButtonWidth;
   }
   function set minButtonWidth(a_minButtonWidth)
   {
      this._minButtonWidth = a_minButtonWidth;
   }
   function get buttonWidth()
   {
      return this._buttonWidth;
   }
   function set align(a_align)
   {
      if(a_align == "LEFT")
      {
         this._align = this.ALIGN_LEFT;
      }
      else if(a_align == "RIGHT")
      {
         this._align = this.ALIGN_RIGHT;
      }
   }
   function UpdateList()
   {
      if(this._bSuspended)
      {
         this._bRequestUpdate = true;
         return undefined;
      }
      this.setClipCount(this.getListEnumSize());
      var _loc5_ = 0;
      this._buttonWidth = 4;
      var _loc2_ = 0;
      var _loc4_;
      var _loc3_;
      while(_loc2_ < this.getListEnumSize())
      {
         _loc4_ = this.getClipByIndex(_loc2_);
         _loc3_ = this.getListEnumEntry(_loc2_);
         _loc4_.itemIndex = _loc2_;
         _loc3_.clipIndex = _loc2_;
         _loc4_.setEntry(_loc3_,this.listState);
         _loc4_._y = this.topBorder + _loc5_;
         _loc4_._visible = true;
         _loc4_.selectIndicator._width = 4;
         _loc4_.background._width = 4;
         if(this._buttonWidth < _loc4_._width)
         {
            this._buttonWidth = _loc4_._width + 4;
         }
         _loc5_ += _loc4_._height;
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < this.getListEnumSize())
      {
         _loc4_._x = this._align != this.ALIGN_LEFT ? - (this.buttonWidth + this.rightBorder) : this.leftBorder;
         _loc4_ = this.getClipByIndex(_loc2_);
         _loc4_.selectIndicator._width = this._buttonWidth;
         _loc4_.background._width = this._buttonWidth;
         _loc2_ = _loc2_ + 1;
      }
      this.background._width = this.leftBorder + this._buttonWidth + this.rightBorder;
      this.background._height = this.topBorder + _loc5_ + this.bottomBorder;
      this.background._x = this._align != this.ALIGN_LEFT ? - this.background._width : 0;
   }
   function handleInput(details, pathToFocus)
   {
      var _loc3_ = false;
      if(this.disableInput)
      {
         return false;
      }
      var _loc4_ = this.getClipByIndex(this._selectedIndex);
      _loc3_ = _loc4_ != undefined && _loc4_.handleInput != undefined && _loc4_.handleInput(details,pathToFocus.slice(1));
      if(!_loc3_ && Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.UP || details.navEquivalent == gfx.ui.NavigationCode.PAGE_UP)
         {
            this.moveSelectionUp();
            _loc3_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.DOWN || details.navEquivalent == gfx.ui.NavigationCode.PAGE_DOWN)
         {
            this.moveSelectionDown();
            _loc3_ = true;
         }
         else if(!this.disableSelection && details.navEquivalent == gfx.ui.NavigationCode.ENTER)
         {
            this.onItemPress();
            _loc3_ = true;
         }
      }
      return _loc3_;
   }
   function moveSelectionUp()
   {
      if(this.disableSelection)
      {
         return undefined;
      }
      if(this._selectedIndex == -1)
      {
         this.doSetSelectedIndex(this.getListEnumLastIndex(),skyui.components.list.BasicList.SELECT_KEYBOARD);
         this.isMouseDrivenNav = false;
      }
      else if(this.getSelectedListEnumIndex() > 0)
      {
         this.doSetSelectedIndex(this.getListEnumRelativeIndex(-1),skyui.components.list.BasicList.SELECT_KEYBOARD);
         this.isMouseDrivenNav = false;
         this.dispatchEvent({type:"listMovedUp",index:this._selectedIndex,scrollChanged:true});
      }
   }
   function moveSelectionDown()
   {
      if(this.disableSelection)
      {
         return undefined;
      }
      if(this._selectedIndex == -1)
      {
         this.doSetSelectedIndex(this.getListEnumFirstIndex(),skyui.components.list.BasicList.SELECT_KEYBOARD);
         this.isMouseDrivenNav = false;
      }
      else if(this.getSelectedListEnumIndex() < this.getListEnumSize() - 1)
      {
         this.doSetSelectedIndex(this.getListEnumRelativeIndex(1),skyui.components.list.BasicList.SELECT_KEYBOARD);
         this.isMouseDrivenNav = false;
         this.dispatchEvent({type:"listMovedDown",index:this._selectedIndex,scrollChanged:true});
      }
   }
   function onMouseWheel(delta)
   {
      if(this.disableInput)
      {
         return undefined;
      }
      var _loc2_ = Mouse.getTopMostEntity();
      while(_loc2_ && _loc2_ != undefined)
      {
         if(_loc2_ == this)
         {
            if(delta < 0)
            {
               this.moveSelectionDown();
            }
            else if(delta > 0)
            {
               this.moveSelectionUp();
            }
         }
         _loc2_ = _loc2_._parent;
      }
      this.isMouseDrivenNav = true;
   }
}
