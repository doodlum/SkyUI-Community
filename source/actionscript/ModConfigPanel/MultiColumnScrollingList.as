class MultiColumnScrollingList extends skyui.components.list.ScrollingList
{
   var _listIndex;
   var _maxListIndex;
   var _scrollPosition;
   var _selectedIndex;
   var _separators;
   var attachMovie;
   var background;
   var disableInput;
   var disableSelection;
   var doSetSelectedIndex;
   var entryHeight;
   var getClipByIndex;
   var getListEnumEntry;
   var getListEnumRelativeIndex;
   var getListEnumSize;
   var getNextHighestDepth;
   var getSelectedListEnumIndex;
   var isMouseDrivenNav;
   var leftBorder;
   var listState;
   var rightBorder;
   var scrollDelta;
   var scrollbar;
   var selectDefaultIndex;
   var separatorRenderer;
   var setClipCount;
   var topBorder;
   var columnSpacing = 0;
   var _columnCount = 1;
   function MultiColumnScrollingList()
   {
      super();
      this.scrollDelta = this.columnCount;
      this._maxListIndex *= this.columnCount;
      if(this._separators == null)
      {
         this._separators = [];
      }
   }
   function get columnCount()
   {
      return this._columnCount;
   }
   function set columnCount(a_value)
   {
      this._columnCount = a_value;
      this.refreshSeparators();
   }
   function onLoad()
   {
      super.onLoad();
      if(this.scrollbar != undefined)
      {
         this.scrollbar.scrollDelta = this.scrollDelta;
      }
   }
   function UpdateList()
   {
      this.setClipCount(this._maxListIndex);
      var _loc12_ = this.background._x + this.leftBorder;
      var _loc10_ = this.background._y + this.topBorder;
      var _loc7_ = 0;
      var _loc6_ = 0;
      var _loc11_ = this.columnCount - 1;
      var _loc8_ = (this.background._width - this.leftBorder - this.rightBorder - (this.columnCount - 1) * this.columnSpacing) / this.columnCount;
      var _loc5_ = 0;
      while(_loc5_ < this.getListEnumSize() && _loc5_ < this._scrollPosition)
      {
         this.getListEnumEntry(_loc5_).clipIndex = undefined;
         _loc5_ = _loc5_ + 1;
      }
      this._listIndex = 0;
      _loc5_ = this._scrollPosition;
      var _loc3_;
      var _loc4_;
      while(_loc5_ < this.getListEnumSize() && this._listIndex < this._maxListIndex)
      {
         _loc3_ = this.getClipByIndex(this._listIndex);
         _loc4_ = this.getListEnumEntry(_loc5_);
         _loc3_.itemIndex = _loc4_.itemIndex;
         _loc4_.clipIndex = this._listIndex;
         _loc3_.width = _loc8_;
         _loc3_.setEntry(_loc4_,this.listState);
         _loc3_._x = _loc12_ + _loc6_;
         _loc3_._y = _loc10_ + _loc7_;
         _loc3_._visible = true;
         if(_loc5_ % this.columnCount == _loc11_)
         {
            _loc6_ = 0;
            _loc7_ += this.entryHeight;
         }
         else
         {
            _loc6_ = _loc6_ + _loc8_ + this.columnSpacing;
         }
         this._listIndex = this._listIndex + 1;
         _loc5_ = _loc5_ + 1;
      }
      _loc5_ = this._scrollPosition + this._listIndex;
      while(_loc5_ < this.getListEnumSize())
      {
         this.getListEnumEntry(_loc5_).clipIndex = undefined;
         _loc5_ = _loc5_ + 1;
      }
      var _loc2_;
      if(this.isMouseDrivenNav)
      {
         _loc2_ = Mouse.getTopMostEntity();
         while(_loc2_ != undefined)
         {
            if(_loc2_._parent == this && _loc2_._visible && _loc2_.itemIndex != undefined)
            {
               this.doSetSelectedIndex(_loc2_.itemIndex,skyui.components.list.BasicList.SELECT_MOUSE);
            }
            _loc2_ = _loc2_._parent;
         }
      }
      var _loc9_ = this._listIndex > 0;
      _loc5_ = 0;
      while(_loc5_ < this._separators.length)
      {
         this._separators[_loc5_]._visible = _loc9_;
         _loc5_ = _loc5_ + 1;
      }
   }
   function handleInput(details, pathToFocus)
   {
      if(this.disableInput)
      {
         return false;
      }
      if(super.handleInput(details,pathToFocus))
      {
         return true;
      }
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.LEFT)
         {
            this.moveSelectionLeft();
            return true;
         }
         if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT)
         {
            this.moveSelectionRight();
            return true;
         }
      }
      return false;
   }
   function moveSelectionLeft()
   {
      if(this.disableSelection)
      {
         return undefined;
      }
      if(this._selectedIndex == -1)
      {
         this.selectDefaultIndex(false);
      }
      else if(this.getSelectedListEnumIndex() % this.columnCount > 0)
      {
         this.doSetSelectedIndex(this.getListEnumRelativeIndex(-1),skyui.components.list.BasicList.SELECT_KEYBOARD);
         this.isMouseDrivenNav = false;
      }
   }
   function moveSelectionRight()
   {
      if(this.disableSelection)
      {
         return undefined;
      }
      if(this._selectedIndex == -1)
      {
         this.selectDefaultIndex(false);
      }
      else if(this.getSelectedListEnumIndex() % this.columnCount < this.columnCount - 1)
      {
         this.doSetSelectedIndex(this.getListEnumRelativeIndex(1),skyui.components.list.BasicList.SELECT_KEYBOARD);
         this.isMouseDrivenNav = false;
      }
   }
   function refreshSeparators()
   {
      if(this._separators == null)
      {
         this._separators = [];
      }
      var _loc2_;
      while(this._separators.length > 0)
      {
         _loc2_ = this._separators.pop();
         _loc2_.removeMovieClip();
      }
      if(!this.separatorRenderer)
      {
         return undefined;
      }
      var _loc6_ = (this.background._width - this.leftBorder - this.rightBorder - (this.columnCount - 1) * this.columnSpacing) / this.columnCount;
      var _loc4_ = this.background._x + this.leftBorder;
      var _loc5_ = this.columnSpacing / 2;
      var _loc3_ = 0;
      while(_loc3_ < this.columnCount - 1)
      {
         _loc2_ = this.attachMovie(this.separatorRenderer,this.separatorRenderer + _loc3_,this.getNextHighestDepth());
         _loc4_ += _loc6_ + _loc5_;
         _loc2_._x = _loc4_;
         _loc2_._y = this.background._y;
         _loc2_._height = this.background._height;
         _loc2_._alpha = 50;
         this._separators.push(_loc2_);
         _loc4_ += _loc5_;
         _loc3_ = _loc3_ + 1;
      }
   }
}
