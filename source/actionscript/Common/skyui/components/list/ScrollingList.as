class skyui.components.list.ScrollingList extends skyui.components.list.BasicList
{
   var __get__selectedEntry;
   var __get__selectedIndex;
   var _bRequestInvalidate;
   var _bRequestUpdate;
   var _bSuspended;
   var _dataProcessors;
   var _entryClipManager;
   var _entryList;
   var _listHeight;
   var _maxListIndex;
   var _platform;
   var _selectedIndex;
   var background;
   var bottomBorder;
   var disableInput;
   var disableSelection;
   var dispatchEvent;
   var getListEnumEntry;
   var getListEnumIndex;
   var getListEnumRelativeIndex;
   var getListEnumSize;
   var getSelectedListEnumIndex;
   var isMouseDrivenNav;
   var leftBorder;
   var listEnumeration;
   var listState;
   var onInvalidate;
   var onItemPress;
   var scrollDownButton;
   var scrollUpButton;
   var scrollbar;
   var setClipCount;
   var topBorder;
   var _listIndex = 0;
   var _curClipIndex = -1;
   var entryHeight = 28;
   var scrollDelta = 1;
   var isPressOnMove = false;
   var _scrollPosition = 0;
   var _maxScrollPosition = 0;
   function ScrollingList()
   {
      super();
      this._listHeight = this.background._height - this.topBorder - this.bottomBorder;
      this._maxListIndex = Math.floor(this._listHeight / this.entryHeight);
   }
   function get scrollPosition()
   {
      return this._scrollPosition;
   }
   function set scrollPosition(a_newPosition)
   {
      if(a_newPosition == this._scrollPosition || a_newPosition < 0 || a_newPosition > this._maxScrollPosition)
      {
         return;
      }
      if(this.scrollbar != undefined)
      {
         this.scrollbar.position = a_newPosition;
      }
      else
      {
         this.updateScrollPosition(a_newPosition);
      }
   }
   function get maxScrollPosition()
   {
      return this._maxScrollPosition;
   }
   function get listHeight()
   {
      return this._listHeight;
   }
   function set listHeight(a_height)
   {
      this._listHeight = this.background._height = a_height;
      if(this.scrollbar != undefined)
      {
         this.scrollbar.height = this._listHeight;
      }
   }
   function onLoad()
   {
      if(this.scrollbar != undefined)
      {
         this.scrollbar.position = 0;
         this.scrollbar.addEventListener("scroll",this,"onScroll");
         this.scrollbar._y = this.background._x + this.topBorder;
         this.scrollbar.height = this._listHeight;
      }
   }
   function setPlatform(a_platform, a_bPS3Switch)
   {
      super.setPlatform(a_platform,a_bPS3Switch);
   }
   function handleInput(details, pathToFocus)
   {
      if(this.disableInput)
      {
         return false;
      }
      var _loc3_ = this.getClipByIndex(this.selectedIndex);
      var _loc4_ = _loc3_ != undefined && _loc3_.handleInput != undefined && _loc3_.handleInput(details,pathToFocus.slice(1));
      if(_loc4_)
      {
         return true;
      }
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.UP || details.navEquivalent == gfx.ui.NavigationCode.PAGE_UP)
         {
            this.moveSelectionUp(details.navEquivalent == gfx.ui.NavigationCode.PAGE_UP);
            return true;
         }
         if(details.navEquivalent == gfx.ui.NavigationCode.DOWN || details.navEquivalent == gfx.ui.NavigationCode.PAGE_DOWN)
         {
            this.moveSelectionDown(details.navEquivalent == gfx.ui.NavigationCode.PAGE_DOWN);
            return true;
         }
         if(!this.disableSelection && details.navEquivalent == gfx.ui.NavigationCode.ENTER)
         {
            if(details.code == 96 && this._platform == skyui.components.list.BasicList.PLATFORM_PC)
            {
               return false;
            }
            this.onItemPress();
            return true;
         }
      }
      return false;
   }
   function UpdateList()
   {
      if(this._bSuspended)
      {
         this._bRequestUpdate = true;
         return undefined;
      }
      this.setClipCount(this._maxListIndex);
      var _loc8_ = this.background._x + this.leftBorder;
      var _loc7_ = this.background._y + this.topBorder;
      var _loc6_ = 0;
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
         _loc3_.setEntry(_loc4_,this.listState);
         _loc3_._x = _loc8_;
         _loc3_._y = _loc7_ + _loc6_;
         _loc3_._visible = true;
         _loc6_ += this.entryHeight;
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
      if(this.scrollUpButton != undefined)
      {
         this.scrollUpButton._visible = this._scrollPosition > 0;
      }
      if(this.scrollDownButton != undefined)
      {
         this.scrollDownButton._visible = this._scrollPosition < this._maxScrollPosition;
      }
   }
   function InvalidateData()
   {
      if(this._bSuspended)
      {
         this._bRequestInvalidate = true;
         return undefined;
      }
      var _loc2_ = 0;
      while(_loc2_ < this._entryList.length)
      {
         this._entryList[_loc2_].itemIndex = _loc2_;
         this._entryList[_loc2_].clipIndex = undefined;
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < this._dataProcessors.length)
      {
         this._dataProcessors[_loc2_].processList(this);
         _loc2_ = _loc2_ + 1;
      }
      this.listEnumeration.invalidate();
      if(this._selectedIndex >= this.listEnumeration.size())
      {
         this._selectedIndex = this.listEnumeration.size() - 1;
      }
      if(this.listEnumeration.lookupEnumIndex(this._selectedIndex) == null)
      {
         this._selectedIndex = -1;
      }
      this.calculateMaxScrollPosition();
      this.UpdateList();
      var _loc3_;
      if(this._curClipIndex != undefined && this._curClipIndex != -1 && this._listIndex > 0)
      {
         if(this._curClipIndex >= this._listIndex)
         {
            this._curClipIndex = this._listIndex - 1;
         }
         _loc3_ = this.getClipByIndex(this._curClipIndex);
         this.doSetSelectedIndex(_loc3_.itemIndex,skyui.components.list.BasicList.SELECT_MOUSE);
      }
      if(this.onInvalidate)
      {
         this.onInvalidate();
      }
   }
   function moveSelectionUp(a_bScrollPage)
   {
      var _loc2_;
      if(!this.disableSelection && !a_bScrollPage)
      {
         if(this._selectedIndex == -1)
         {
            this.selectDefaultIndex(false);
         }
         else if(this.getSelectedListEnumIndex() >= this.scrollDelta)
         {
            this.doSetSelectedIndex(this.getListEnumRelativeIndex(- this.scrollDelta),skyui.components.list.BasicList.SELECT_KEYBOARD);
            this.isMouseDrivenNav = false;
            if(this.isPressOnMove)
            {
               this.onItemPress();
            }
         }
      }
      else if(a_bScrollPage)
      {
         _loc2_ = this.scrollPosition - this._listIndex;
         this.scrollPosition = _loc2_ <= 0 ? 0 : _loc2_;
         this.doSetSelectedIndex(-1,skyui.components.list.BasicList.SELECT_MOUSE);
      }
      else
      {
         this.scrollPosition = this.scrollPosition - this.scrollDelta;
      }
   }
   function moveSelectionDown(a_bScrollPage)
   {
      var _loc2_;
      if(!this.disableSelection && !a_bScrollPage)
      {
         if(this._selectedIndex == -1)
         {
            this.selectDefaultIndex(true);
         }
         else if(this.getSelectedListEnumIndex() < this.getListEnumSize() - this.scrollDelta)
         {
            this.doSetSelectedIndex(this.getListEnumRelativeIndex(this.scrollDelta),skyui.components.list.BasicList.SELECT_KEYBOARD);
            this.isMouseDrivenNav = false;
            if(this.isPressOnMove)
            {
               this.onItemPress();
            }
         }
      }
      else if(a_bScrollPage)
      {
         _loc2_ = this.scrollPosition + this._listIndex;
         this.scrollPosition = _loc2_ >= this._maxScrollPosition ? this._maxScrollPosition : _loc2_;
         this.doSetSelectedIndex(-1,skyui.components.list.BasicList.SELECT_MOUSE);
      }
      else
      {
         this.scrollPosition = this.scrollPosition + this.scrollDelta;
      }
   }
   function selectDefaultIndex(a_bTop)
   {
      if(this._listIndex <= 0)
      {
         return undefined;
      }
      var _loc3_;
      var _loc2_;
      if(a_bTop)
      {
         _loc3_ = this.getClipByIndex(0);
         if(_loc3_.itemIndex != undefined)
         {
            this.doSetSelectedIndex(_loc3_.itemIndex,skyui.components.list.BasicList.SELECT_KEYBOARD);
         }
      }
      else
      {
         _loc2_ = this.getClipByIndex(this._listIndex - 1);
         if(_loc2_.itemIndex != undefined)
         {
            this.doSetSelectedIndex(_loc2_.itemIndex,skyui.components.list.BasicList.SELECT_KEYBOARD);
         }
      }
   }
   function onMouseWheel(a_delta)
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
            if(a_delta < 0)
            {
               this.scrollPosition = this.scrollPosition + this.scrollDelta;
            }
            else if(a_delta > 0)
            {
               this.scrollPosition = this.scrollPosition - this.scrollDelta;
            }
         }
         _loc2_ = _loc2_._parent;
      }
      this.isMouseDrivenNav = true;
   }
   function onScroll(event)
   {
      this.updateScrollPosition(Math.floor(event.position + 0.5));
   }
   function doSetSelectedIndex(a_newIndex, a_keyboardOrMouse)
   {
      if(this.disableSelection || a_newIndex == this._selectedIndex)
      {
         return undefined;
      }
      if(a_newIndex != -1 && this.getListEnumIndex(a_newIndex) == undefined)
      {
         return undefined;
      }
      var _loc3_ = this.selectedEntry;
      this._selectedIndex = a_newIndex;
      var _loc5_;
      if(_loc3_.clipIndex != undefined)
      {
         _loc5_ = this.getClipByIndex(_loc3_.clipIndex);
         _loc5_.setEntry(_loc3_,this.listState);
      }
      var _loc2_;
      if(this._selectedIndex != -1)
      {
         _loc2_ = this.getSelectedListEnumIndex();
         if(_loc2_ < this._scrollPosition)
         {
            this.scrollPosition = _loc2_;
         }
         else if(_loc2_ >= this._scrollPosition + this._listIndex)
         {
            this.scrollPosition = Math.min(_loc2_ - this._listIndex + this.scrollDelta,this._maxScrollPosition);
         }
         else
         {
            _loc5_ = this.getClipByIndex(this.selectedEntry.clipIndex);
            _loc5_.setEntry(this.selectedEntry,this.listState);
         }
         this._curClipIndex = this.selectedEntry.clipIndex;
      }
      else
      {
         this._curClipIndex = -1;
      }
      this.dispatchEvent({type:"selectionChange",index:this._selectedIndex,keyboardOrMouse:a_keyboardOrMouse});
   }
   function calculateMaxScrollPosition()
   {
      var _loc2_ = this.getListEnumSize() - this._maxListIndex;
      this._maxScrollPosition = _loc2_ <= 0 ? 0 : _loc2_;
      this.updateScrollbar();
      if(this._scrollPosition > this._maxScrollPosition)
      {
         this.scrollPosition = this._maxScrollPosition;
      }
   }
   function updateScrollPosition(a_position)
   {
      this._scrollPosition = a_position;
      this.UpdateList();
   }
   function updateScrollbar()
   {
      if(this.scrollbar != undefined)
      {
         this.scrollbar._visible = this._maxScrollPosition > 0;
         this.scrollbar.setScrollProperties(this._maxListIndex,0,this._maxScrollPosition);
      }
   }
   function getClipByIndex(a_index)
   {
      if(a_index < 0 || a_index >= this._maxListIndex)
      {
         return undefined;
      }
      return this._entryClipManager.getClip(a_index);
   }
}
