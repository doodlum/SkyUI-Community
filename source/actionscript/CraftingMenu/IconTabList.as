class IconTabList extends skyui.components.list.BasicList
{
   var __get__selectedEntry;
   var _bFastSwitch;
   var _bRequestInvalidate;
   var _bRequestUpdate;
   var _bSuspended;
   var _contentWidth;
   var _entryClipManager;
   var _entryList;
   var _selectedIndex;
   var _selectorPos;
   var _targetSelectorPos;
   var _totalWidth;
   var background;
   var disableInput;
   var disableSelection;
   var dispatchEvent;
   var doSetSelectedIndex;
   var getClipByIndex;
   var iconSize;
   var isMouseDrivenNav;
   var listEnumeration;
   var listState;
   var onInvalidate;
   var selectorCenter;
   var selectorLeft;
   var selectorRight;
   var setClipCount;
   static var LEFT_SEGMENT = 0;
   static var RIGHT_SEGMENT = 1;
   function IconTabList()
   {
      super();
      this._selectorPos = 0;
      this._targetSelectorPos = 0;
      this._bFastSwitch = false;
      if(this.iconSize == undefined)
      {
         this.iconSize = 32;
      }
   }
   function clearList()
   {
      this._entryList.splice(0);
   }
   function InvalidateData()
   {
      if(this._bSuspended)
      {
         this._bRequestInvalidate = true;
         return undefined;
      }
      this.listEnumeration.invalidate();
      if(this._selectedIndex >= this.listEnumeration.size())
      {
         this._selectedIndex = this.listEnumeration.size() - 1;
      }
      this.UpdateList();
      if(this.onInvalidate)
      {
         this.onInvalidate();
      }
   }
   function UpdateList()
   {
      if(this._bSuspended)
      {
         this._bRequestUpdate = true;
         return undefined;
      }
      var _loc5_ = this.listEnumeration.size();
      this.setClipCount(_loc5_);
      var _loc6_ = 0;
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < _loc5_)
      {
         _loc3_ = this.getClipByIndex(_loc2_);
         _loc3_.setEntry(this.listEnumeration.at(_loc2_),this.listState);
         this.listEnumeration.at(_loc2_).clipIndex = _loc2_;
         _loc3_.itemIndex = _loc2_;
         _loc6_ += this.iconSize;
         _loc2_ = _loc2_ + 1;
      }
      this._contentWidth = _loc6_;
      this._totalWidth = this.background._width;
      var _loc7_ = (this._totalWidth - this._contentWidth) / (_loc5_ + 1);
      var _loc4_ = this.background._x + _loc7_;
      _loc2_ = 0;
      while(_loc2_ < _loc5_)
      {
         _loc3_ = this.getClipByIndex(_loc2_);
         _loc3_._x = _loc4_;
         _loc4_ = _loc4_ + this.iconSize + _loc7_;
         _loc3_._visible = true;
         _loc2_ = _loc2_ + 1;
      }
      this.updateSelector();
   }
   function moveSelectionLeft()
   {
      if(this.disableSelection)
      {
         return undefined;
      }
      var _loc2_ = this._selectedIndex;
      var _loc3_ = this._selectedIndex;
      do
      {
         if(_loc2_ > 0)
         {
            _loc2_ = _loc2_ - 1;
         }
         else
         {
            this._bFastSwitch = true;
            _loc2_ = this.listEnumeration.size() - 1;
         }
      }
      while(_loc2_ != _loc3_ && this.listEnumeration.at(_loc2_).enabled == false);
      
      this.onItemPress(_loc2_,0);
   }
   function moveSelectionRight()
   {
      if(this.disableSelection)
      {
         return undefined;
      }
      var _loc2_ = this._selectedIndex;
      var _loc3_ = this._selectedIndex;
      do
      {
         if(_loc2_ < this.listEnumeration.size() - 1)
         {
            _loc2_ = _loc2_ + 1;
         }
         else
         {
            this._bFastSwitch = true;
            _loc2_ = 0;
         }
      }
      while(_loc2_ != _loc3_ && this.listEnumeration.at(_loc2_).enabled == false);
      
      this.onItemPress(_loc2_,0);
   }
   function handleInput(details, pathToFocus)
   {
      if(this.disableInput)
      {
         return false;
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
   function onEnterFrame()
   {
      super.onEnterFrame();
      if(this._bFastSwitch && this._selectorPos != this._targetSelectorPos)
      {
         this._selectorPos = this._targetSelectorPos;
         this._bFastSwitch = false;
         this.refreshSelector();
      }
      else if(this._selectorPos < this._targetSelectorPos)
      {
         this._selectorPos = this._selectorPos + (this._targetSelectorPos - this._selectorPos) * 0.2 + 1;
         this.refreshSelector();
         if(this._selectorPos > this._targetSelectorPos)
         {
            this._selectorPos = this._targetSelectorPos;
         }
      }
      else if(this._selectorPos > this._targetSelectorPos)
      {
         this._selectorPos = this._selectorPos - (this._selectorPos - this._targetSelectorPos) * 0.2 - 1;
         this.refreshSelector();
         if(this._selectorPos < this._targetSelectorPos)
         {
            this._selectorPos = this._targetSelectorPos;
         }
      }
   }
   function onItemPress(a_index, a_keyboardOrMouse)
   {
      if(this.disableInput || this.disableSelection || a_index == -1)
      {
         return undefined;
      }
      this.doSetSelectedIndex(a_index,a_keyboardOrMouse);
      this.updateSelector();
      this.dispatchEvent({type:"itemPress",index:this._selectedIndex,entry:this.selectedEntry,keyboardOrMouse:a_keyboardOrMouse});
   }
   function onItemPressAux(a_index, a_keyboardOrMouse, a_buttonIndex)
   {
      if(this.disableInput || this.disableSelection || a_index == -1 || a_buttonIndex != 1)
      {
         return undefined;
      }
      this.doSetSelectedIndex(a_index,a_keyboardOrMouse);
      this.updateSelector();
      this.dispatchEvent({type:"itemPressAux",index:this._selectedIndex,entry:this.selectedEntry,keyboardOrMouse:a_keyboardOrMouse});
   }
   function onItemRollOver(a_index)
   {
      if(this.disableInput || this.disableSelection)
      {
         return undefined;
      }
      this.isMouseDrivenNav = true;
      if(a_index == this._selectedIndex)
      {
         return undefined;
      }
      var _loc2_ = this.getClipByIndex(a_index);
      _loc2_._alpha = 75;
   }
   function onItemRollOut(a_index)
   {
      if(this.disableInput || this.disableSelection)
      {
         return undefined;
      }
      this.isMouseDrivenNav = true;
      if(a_index == this._selectedIndex)
      {
         return undefined;
      }
      var _loc2_ = this.getClipByIndex(a_index);
      _loc2_._alpha = 50;
   }
   function updateSelector()
   {
      if(this.selectorCenter == undefined)
      {
         return undefined;
      }
      if(this._selectedIndex == -1)
      {
         this.selectorCenter._visible = false;
         if(this.selectorLeft != undefined)
         {
            this.selectorLeft._visible = false;
         }
         if(this.selectorRight != undefined)
         {
            this.selectorRight._visible = false;
         }
         return undefined;
      }
      var _loc2_ = this._entryClipManager.getClip(this._selectedIndex);
      this._targetSelectorPos = _loc2_._x + (_loc2_.background._width - this.selectorCenter._width) / 2;
      this.selectorCenter._visible = true;
      this.selectorCenter._y = _loc2_._y + _loc2_.background._height;
      if(this.selectorLeft != undefined)
      {
         this.selectorLeft._visible = true;
         this.selectorLeft._x = 0;
         this.selectorLeft._y = this.selectorCenter._y;
      }
      if(this.selectorRight != undefined)
      {
         this.selectorRight._visible = true;
         this.selectorRight._y = this.selectorCenter._y;
         this.selectorRight._width = this._totalWidth - this.selectorRight._x;
      }
   }
   function refreshSelector()
   {
      this.selectorCenter._visible = true;
      var _loc2_ = this._entryClipManager.getClip(this._selectedIndex);
      this.selectorCenter._x = this._selectorPos;
      if(this.selectorLeft != undefined)
      {
         this.selectorLeft._width = this.selectorCenter._x;
      }
      if(this.selectorRight != undefined)
      {
         this.selectorRight._x = this.selectorCenter._x + this.selectorCenter._width;
         this.selectorRight._width = this._totalWidth - this.selectorRight._x;
      }
   }
}
