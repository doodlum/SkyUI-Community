class Shared.CenteredScrollingList extends Shared.BSScrollingList
{
   var EntriesA;
   var GetClipByIndex;
   var SetEntryText;
   var _filterer;
   var bDisableInput;
   var bMouseDrivenNav;
   var bPointerHighlight;
   var bRecenterSelection;
   var border;
   var dispatchEvent;
   var doSetSelectedIndex;
   var fListHeight;
   var iDividerIndex;
   var iListItemsShown;
   var iMaxItemsShown;
   var iMaxScrollPosition;
   var iMaxTextLength;
   var iNumTopHalfEntries;
   var iNumUnfilteredItems;
   var iPlatform;
   var iScrollPosition;
   var iSelectedIndex;
   var scrollPosition;
   var selectedEntry;

   function CenteredScrollingList()
   {
      super();
      this._filterer = new Shared.ListFilterer();
      this._filterer.addEventListener("filterChange",this,"onFilterChange");
      this.bRecenterSelection = false;
      this.iMaxTextLength = 256;
      this.iDividerIndex = -1;
      this.iNumUnfilteredItems = 0;
      this.bPointerHighlight = false;
   }
   function get filterer()
   {
      return this._filterer;
   }
   function set maxTextLength(aLength)
   {
      if(aLength > 3)
      {
         this.iMaxTextLength = aLength;
      }
   }
   function get numUnfilteredItems()
   {
      return this.iNumUnfilteredItems;
   }
   function get maxTextLength()
   {
      return this.iMaxTextLength;
   }
   function get numTopHalfEntries()
   {
      return this.iNumTopHalfEntries;
   }
   function set numTopHalfEntries(aiNum)
   {
      this.iNumTopHalfEntries = aiNum;
   }
   function get centeredEntry()
   {
      return this.EntriesA[this.GetClipByIndex(this.iNumTopHalfEntries).itemIndex];
   }
   function IsDivider(aEntry)
   {
      return aEntry.divider == true || aEntry.flag == 0;
   }

   function get dividerIndex()
   {
      return this.iDividerIndex;
   }

   function RestoreScrollPosition(aiNewPosition, abRecenterSelection)
   {
      this.iScrollPosition = aiNewPosition;
      if(this.iScrollPosition < 0)
      {
         this.iScrollPosition = 0;
      }
      if(this.iScrollPosition > this.iMaxScrollPosition)
      {
         this.iScrollPosition = this.iMaxScrollPosition;
      }
      this.bRecenterSelection = abRecenterSelection;
   }
   function onMouseMove()
   {
      if (this.bPointerHighlight)
      {
         this.bPointerHighlight = false;
         this.UpdateList(); 
      }
   }

   function doSetSelectedIndex(aiNewIndex, aiKeyboardOrMouse)
   {
      if (this.bPointerHighlight && aiKeyboardOrMouse == 0) return;

      if(!this.bDisableSelection && aiNewIndex != this.iSelectedIndex)
      {
         this.bPointerHighlight = false; 
         this.iSelectedIndex = aiNewIndex;

         var _loc2_ = 0;
         while(_loc2_ < this.iMaxItemsShown)
         {
            var _cl_ = this.GetClipByIndex(_loc2_);
            if(_cl_ != undefined && _cl_.itemIndex != undefined)
            {
               this.SetEntry(_cl_, this.EntriesA[_cl_.itemIndex]);
            }
            _loc2_++;
         }

         this.dispatchEvent({type:"selectionChange",
                             index:this.iSelectedIndex,
                             keyboardOrMouse:aiKeyboardOrMouse});
      }
   }

   function UpdateList()
   {
      var _loc10_ = this.GetClipByIndex(0)._y;
      var _loc6_ = 0;
      var _loc2_ = this.filterer.ClampIndex(0);
      this.iDividerIndex = -1;
      var _loc7_ = 0;
      while(_loc7_ < this.EntriesA.length)
      {
         if(this.IsDivider(this.EntriesA[_loc7_]))
         {
            this.iDividerIndex = _loc7_;
         }
         _loc7_ = _loc7_ + 1;
      }
      if(this.bRecenterSelection || this.iPlatform != 0)
      {
         this.iSelectedIndex = -1;
      }
      else if(!this.bPointerHighlight)
      {
         this.iSelectedIndex = this.filterer.ClampIndex(this.iSelectedIndex);
      }
      var _loc9_ = 0;
      while(_loc9_ < this.iScrollPosition - this.iNumTopHalfEntries)
      {
         this.EntriesA[_loc2_].clipIndex = undefined;
         _loc2_ = this.filterer.GetNextFilterMatch(_loc2_);
         _loc9_ = _loc9_ + 1;
      }
      this.iListItemsShown = 0;
      this.iNumUnfilteredItems = 0;
      var _loc4_ = 0;
      var _loc5_;
      while(_loc4_ < this.iNumTopHalfEntries)
      {
         _loc5_ = this.GetClipByIndex(_loc4_);
         if(this.iScrollPosition - this.iNumTopHalfEntries + _loc4_ >= 0)
         {
            this.SetEntry(_loc5_,this.EntriesA[_loc2_]);
            _loc5_._visible = true;
            _loc5_.itemIndex = this.IsDivider(this.EntriesA[_loc2_]) == true ? undefined : _loc2_;
            this.EntriesA[_loc2_].clipIndex = _loc4_;
            _loc2_ = this.filterer.GetNextFilterMatch(_loc2_);
            this.iNumUnfilteredItems++;
         }
         else
         {
            _loc5_._visible = false;
            _loc5_.itemIndex = undefined;
         }
         _loc5_._y = _loc10_ + _loc6_;
         _loc6_ += _loc5_._height;
         this.iListItemsShown++;
         _loc4_ = _loc4_ + 1;
      }
      if(_loc2_ != undefined && (this.bRecenterSelection || this.iPlatform != 0 || this.bPointerHighlight))
      {
         this.iSelectedIndex = _loc2_;
      }
      while(_loc2_ != undefined && _loc2_ != -1 && _loc2_ < this.EntriesA.length && this.iListItemsShown < this.iMaxItemsShown && _loc6_ <= this.fListHeight)
      {
         _loc5_ = this.GetClipByIndex(this.iListItemsShown);
         this.SetEntry(_loc5_,this.EntriesA[_loc2_]);
         this.EntriesA[_loc2_].clipIndex = this.iListItemsShown;
         _loc5_.itemIndex = this.IsDivider(this.EntriesA[_loc2_]) == true ? undefined : _loc2_;
         _loc5_._y = _loc10_ + _loc6_;
         _loc5_._visible = true;
         _loc6_ += _loc5_._height;
         if(_loc6_ <= this.fListHeight && this.iListItemsShown < this.iMaxItemsShown)
         {
            this.iListItemsShown++;
            this.iNumUnfilteredItems++;
         }
         _loc2_ = this.filterer.GetNextFilterMatch(_loc2_);
      }
      var _loc8_ = this.iListItemsShown;
      while(_loc8_ < this.iMaxItemsShown)
      {
         this.GetClipByIndex(_loc8_)._visible = false;
         this.GetClipByIndex(_loc8_).itemIndex = undefined;
         _loc8_ = _loc8_ + 1;
      }
      var _loc3_;
      if(this.bMouseDrivenNav && !this.bRecenterSelection && !this.bPointerHighlight)
      {
         _loc3_ = Mouse.getTopMostEntity();
         while(_loc3_ != undefined)
         {
            if(_loc3_._parent == this && _loc3_._visible && _loc3_.itemIndex != undefined)
            {
               this.doSetSelectedIndex(_loc3_.itemIndex,0);
            }
            _loc3_ = _loc3_._parent;
         }
      }
      this.bRecenterSelection = false;
   }
   function InvalidateData()
   {
      this.bPointerHighlight = false;
      this.filterer.filterArray = this.EntriesA;
      this.fListHeight = this.border._height;
      this.CalculateMaxScrollPosition();
      if(this.iScrollPosition > this.iMaxScrollPosition)
      {
         this.iScrollPosition = this.iMaxScrollPosition;
      }
      this.UpdateList();
   }
   function onFilterChange()
   {
      this.iSelectedIndex = this.filterer.ClampIndex(this.iSelectedIndex);
      this.CalculateMaxScrollPosition();
   }
   function moveSelectionUp()
   {
      if(!this.bPointerHighlight)
      {
         var _centerClip_ = this.GetClipByIndex(this.iNumTopHalfEntries);
         if(_centerClip_ != undefined && _centerClip_.itemIndex != undefined)
         {
            this.iSelectedIndex = _centerClip_.itemIndex;
         }
      }
      this.bPointerHighlight = true;

      var _loc4_ = this.GetClipByIndex(this.iNumTopHalfEntries);
      var _loc2_ = this.filterer.GetPrevFilterMatch(this.iSelectedIndex);
      var _loc3_ = this.iScrollPosition;
      if(_loc2_ != undefined && this.IsDivider(this.EntriesA[_loc2_]) == true)
      {
         this.iScrollPosition--;
         _loc2_ = this.filterer.GetPrevFilterMatch(_loc2_);
      }
      if(_loc2_ != undefined)
      {
         this.iSelectedIndex = _loc2_;
         if(this.iScrollPosition > 0)
         {
            this.iScrollPosition--;
         }
         this.bMouseDrivenNav = false;
         this.UpdateList();
         this.dispatchEvent({type:"listMovedUp",index:this.iSelectedIndex,scrollChanged:_loc3_ != this.iScrollPosition});
      }
   }
   function moveSelectionDown()
   {
      if(!this.bPointerHighlight)
      {
         var _centerClip_ = this.GetClipByIndex(this.iNumTopHalfEntries);
         if(_centerClip_ != undefined && _centerClip_.itemIndex != undefined)
         {
            this.iSelectedIndex = _centerClip_.itemIndex;
         }
      }
      this.bPointerHighlight = true;

      var _loc4_ = this.GetClipByIndex(this.iNumTopHalfEntries);
      var _loc2_ = this.filterer.GetNextFilterMatch(this.iSelectedIndex);
      var _loc3_ = this.iScrollPosition;
      if(_loc2_ != undefined && this.IsDivider(this.EntriesA[_loc2_]) == true)
      {
         this.iScrollPosition++;
         _loc2_ = this.filterer.GetNextFilterMatch(_loc2_);
      }
      if(_loc2_ != undefined)
      {
         this.iSelectedIndex = _loc2_;
         if(this.iScrollPosition < this.iMaxScrollPosition)
         {
            this.iScrollPosition++;
         }
         this.bMouseDrivenNav = false;
         this.UpdateList();
         this.dispatchEvent({type:"listMovedDown",index:this.iSelectedIndex,scrollChanged:_loc3_ != this.iScrollPosition});
      }
   }
   function onMouseWheel(delta)
   {
      var _loc2_;
      var _loc4_;
      var _loc3_;
      if(!this.bDisableInput)
      {
         _loc2_ = Mouse.getTopMostEntity();
         while(_loc2_ && _loc2_ != undefined)
         {
            if(_loc2_ == this)
            {
               this.bPointerHighlight = true;

               if(delta < 0)
               {
                  _loc4_ = this.GetClipByIndex(this.iNumTopHalfEntries + 1);
                  if(_loc4_._visible == true)
                  {
                     if(_loc4_.itemIndex == undefined)
                     {
                        this.scrollPosition += 2;
                     }
                     else
                     {
                        this.scrollPosition += 1;
                     }
                  }
               }
               else if(delta > 0)
               {
                  _loc3_ = this.GetClipByIndex(this.iNumTopHalfEntries - 1);
                  if(_loc3_._visible == true)
                  {
                     if(_loc3_.itemIndex == undefined)
                     {
                        this.scrollPosition -= 2;
                     }
                     else
                     {
                        this.scrollPosition -= 1;
                     }
                  }
               }
            }
            _loc2_ = _loc2_._parent;
         }
         this.bMouseDrivenNav = true;
      }
   }
   function CalculateMaxScrollPosition()
   {
      this.iMaxScrollPosition = -1;
      var _loc2_ = this.filterer.ClampIndex(0);
      while(_loc2_ != undefined)
      {
         this.iMaxScrollPosition++;
         _loc2_ = this.filterer.GetNextFilterMatch(_loc2_);
      }
      if(this.iMaxScrollPosition == undefined || this.iMaxScrollPosition < 0)
      {
         this.iMaxScrollPosition = 0;
      }
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      var _loc3_;
      if(aEntryClip != undefined)
      {
         if(this.IsDivider(aEntryObject) == true)
         {
            aEntryClip.gotoAndStop("Divider");
         }
         else
         {
            aEntryClip.gotoAndStop("Normal");
         }
         if(!this.bPointerHighlight && this.iPlatform == 0)
         {
            aEntryClip._alpha = aEntryObject != this.selectedEntry ? 60 : 100;
         }
         else
         {
            _loc3_ = 4;
            if(aEntryClip.clipIndex < this.iNumTopHalfEntries)
            {
               aEntryClip._alpha = 60 - _loc3_ * (this.iNumTopHalfEntries - aEntryClip.clipIndex);
            }
            else if(aEntryClip.clipIndex > this.iNumTopHalfEntries)
            {
               aEntryClip._alpha = 60 - _loc3_ * (aEntryClip.clipIndex - this.iNumTopHalfEntries);
            }
            else
            {
               aEntryClip._alpha = 100;
            }
         }
         this.SetEntryText(aEntryClip,aEntryObject);
      }
   }
   function onItemPress(aiKeyboardOrMouse)
   {
      if(aiKeyboardOrMouse == undefined)
      {
         var _centerClip_ = this.GetClipByIndex(this.iNumTopHalfEntries);
         var _pointerIndex_ = (_centerClip_ != undefined) ? _centerClip_.itemIndex : undefined;

         if(!this.bDisableInput && !this.bDisableSelection && _pointerIndex_ != undefined)
         {
            if(!this.bPointerHighlight)
            {
               this.bPointerHighlight = true;
               this.iSelectedIndex = _pointerIndex_;
               this.UpdateList();
            }
            this.dispatchEvent({type:"itemPress",
                                index:_pointerIndex_,
                                entry:this.EntriesA[_pointerIndex_],
                                keyboardOrMouse:aiKeyboardOrMouse});
         }
         else if(!this.bDisableInput)
         {
            this.dispatchEvent({type:"listPress"});
         }
      }
      else
      {
         super.onItemPress(aiKeyboardOrMouse);
      }
   }
}
