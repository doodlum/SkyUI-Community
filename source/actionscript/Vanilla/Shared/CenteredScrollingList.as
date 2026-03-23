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
   static var PLATFORM_PC = 0;

   function CenteredScrollingList()
   {
      super();
      this._filterer = new Shared.ListFilterer();
      this._filterer.addEventListener("filterChange", this, "onFilterChange");
      this.bRecenterSelection = false;
      this.iMaxTextLength = 256;
      this.iDividerIndex = -1;
      this.iNumUnfilteredItems = 0;
      this.bPointerHighlight = false;
   }

   function get filterer() { return this._filterer; }
   function set maxTextLength(aLength) { if (aLength > 3) this.iMaxTextLength = aLength; }
   function get numUnfilteredItems() { return this.iNumUnfilteredItems; }
   function get numTopHalfEntries() { return this.iNumTopHalfEntries; }

   function set numTopHalfEntries(aiNum) { this.iNumTopHalfEntries = aiNum; }

   function get centeredEntry()
   {
      var centerClip = this.GetClipByIndex(this.iNumTopHalfEntries);
      return (centerClip && centerClip.itemIndex != undefined) ? this.EntriesA[centerClip.itemIndex] : null;
   }

   function IsDivider(aEntry) { return aEntry.divider == true || aEntry.flag == 0; }

   function RestoreScrollPosition(aiNewPosition, abRecenterSelection)
   {
      this.iScrollPosition = Math.max(0, Math.min(aiNewPosition, this.iMaxScrollPosition));
      this.bRecenterSelection = abRecenterSelection;
   }

   function InvalidateData()
   {
      this.bPointerHighlight = false;
      this.filterer.filterArray = this.EntriesA;
      this.fListHeight = this.border._height;
      this.CalculateMaxScrollPosition();
      this.iScrollPosition = Math.min(this.iScrollPosition, this.iMaxScrollPosition);
      this.UpdateList();
   }

   function UpdateList()
   {
      var baseY = this.GetClipByIndex(0)._y;
      var currentY = 0;
      var entryIdx = this.filterer.ClampIndex(0);
      
      var shouldRecenter = this.bRecenterSelection || this.iPlatform != Shared.CenteredScrollingList.PLATFORM_PC || this.bPointerHighlight;
      
      this.iDividerIndex = -1;
      this.iListItemsShown = 0;
      this.iNumUnfilteredItems = 0;

      for (var i = 0; i < this.EntriesA.length; i++) {
         if (this.IsDivider(this.EntriesA[i])) {
            this.iDividerIndex = i;
         }
      }

      if (shouldRecenter) {
         this.iSelectedIndex = -1;
      }

      var skipCount = Math.max(0, this.iScrollPosition - this.iNumTopHalfEntries);
      for (var s = 0; s < skipCount && entryIdx != undefined; s++) {
         entryIdx = this.filterer.GetNextFilterMatch(entryIdx);
      }

      var firstVisibleSlot = Math.max(0, this.iNumTopHalfEntries - this.iScrollPosition);

      for (var clipIdx = 0; clipIdx < this.iMaxItemsShown; clipIdx++) {
         var clip = this.GetClipByIndex(clipIdx);
         var isVisible = (clipIdx >= firstVisibleSlot) && (entryIdx != undefined) && (entryIdx < this.EntriesA.length);

         if (isVisible && currentY <= this.fListHeight) {
            var entry = this.EntriesA[entryIdx];
            
            clip.itemIndex = this.IsDivider(entry) ? undefined : entryIdx;
            clip.clipIndex = clipIdx;
            clip._visible = true;

            if (clipIdx == this.iNumTopHalfEntries && shouldRecenter) {
               this.iSelectedIndex = entryIdx;
            }

            this.SetEntry(clip, entry);

            entryIdx = this.filterer.GetNextFilterMatch(entryIdx);
            this.iNumUnfilteredItems++;
            this.iListItemsShown++;
         } else {
            clip._visible = false;
            clip.itemIndex = undefined;
            clip.clipIndex = undefined;
         }
         
         clip._y = baseY + currentY;
         currentY += clip._height;
      }

      if (this.bMouseDrivenNav && !shouldRecenter) {
         var mouseTarget = Mouse.getTopMostEntity();
         while (mouseTarget != undefined) {
            if (mouseTarget._parent == this && mouseTarget._visible && mouseTarget.itemIndex != undefined) {
               this.doSetSelectedIndex(mouseTarget.itemIndex, 0);
               break;
            }
            mouseTarget = mouseTarget._parent;
         }
      }
      
      this.bRecenterSelection = false;
   }

   function SetEntry(aEntryClip, aEntryObject)
   {
      if (!aEntryClip) return;
      
      var isDivider = this.IsDivider(aEntryObject);
      aEntryClip.gotoAndStop(isDivider ? "Divider" : "Normal");
      
      var dist = Math.abs(aEntryClip.clipIndex - this.iNumTopHalfEntries);

      if (this.iPlatform == Shared.CenteredScrollingList.PLATFORM_PC) {
         var isSelected = (aEntryObject == this.EntriesA[this.iSelectedIndex]);
         aEntryClip._alpha = isSelected ? 100 : 60;
      } else {
         var dist = Math.abs(aEntryClip.clipIndex - this.iNumTopHalfEntries);
         aEntryClip._alpha = (dist == 0) ? 100 : Math.max(20, 60 - dist * 10);
      }
      
      this.SetEntryText(aEntryClip, aEntryObject);
   }

   function _moveSelection(direction, eventType)
   {
      this.bPointerHighlight = true;
      this.bMouseDrivenNav = false;

      var oldScroll = this.iScrollPosition;
      var newScroll = this.iScrollPosition + direction;
      
      this.iScrollPosition = Math.max(0, Math.min(this.iMaxScrollPosition, newScroll));

      if (oldScroll != this.iScrollPosition) {
         this.UpdateList();
         this.dispatchEvent({
            type: eventType, 
            index: this.iSelectedIndex, 
            scrollChanged: true
         });
      }
   }

   function moveSelectionUp() { this._moveSelection(-1, "listMovedUp"); }

   function moveSelectionDown() { this._moveSelection(1, "listMovedDown"); }

   function onMouseMove()
   {
      this.bMouseDrivenNav = true;
      this.bPointerHighlight = false;

      var item = this.GetItemUnderMouse();
      if (item) {
         this.doSetSelectedIndex(item.itemIndex, 0);
      }
   }
   function onMouseDown()
   {
      if (this.bDisableInput) return;

      this.bMouseDrivenNav = true;
      this.bPointerHighlight = false;

      var item = this.GetItemUnderMouse();
      if (item) {
         this.doSetSelectedIndex(item.itemIndex, 0);
         this.dispatchEvent({type: "itemClicked", index: item.itemIndex});
      }
   }
   function onMouseWheel(delta)
   {
      if (this.bDisableInput) return;
      
      var target = Mouse.getTopMostEntity();
      while (target != undefined && target != this) {
         target = target._parent;
      }
      if (target != this) return;

      this.bPointerHighlight = true;
      this.bMouseDrivenNav = true;
      
      var oldScroll = this.iScrollPosition;
      var direction = (delta > 0) ? -1 : 1;
      
      this.iScrollPosition = Math.max(0, Math.min(this.iMaxScrollPosition, this.iScrollPosition + direction));
      
      if (oldScroll != this.iScrollPosition) {
         this.UpdateList();
      }
   }
   function GetItemUnderMouse()
   {
      var mouseTarget = Mouse.getTopMostEntity();
      while (mouseTarget != undefined) {
         if (mouseTarget._parent == this && mouseTarget._visible && mouseTarget.itemIndex != undefined) {
            return mouseTarget;
         }
         mouseTarget = mouseTarget._parent;
      }
      return null;
   }

   function CalculateMaxScrollPosition()
   {
      var count = 0;
      var idx = this.filterer.ClampIndex(0);
      while (idx != undefined) {
         count++;
         idx = this.filterer.GetNextFilterMatch(idx);
      }
      this.iMaxScrollPosition = Math.max(0, count - 1);
   }

   function onFilterChange()
   {
      this.iSelectedIndex = this.filterer.ClampIndex(this.iSelectedIndex);
      this.CalculateMaxScrollPosition();
      this.UpdateList();
   }

   function doSetSelectedIndex(aiNewIndex, aiKeyboardOrMouse)
   {
      if (this.bPointerHighlight && aiKeyboardOrMouse == 0) return;

      if (!this.bDisableSelection && aiNewIndex != this.iSelectedIndex) {
         this.iSelectedIndex = aiNewIndex;
         for (var i = 0; i < this.iMaxItemsShown; i++) {
            var clip = this.GetClipByIndex(i);
            if (clip && clip.itemIndex != undefined) {
               this.SetEntry(clip, this.EntriesA[clip.itemIndex]);
            }
         }
         this.dispatchEvent({type: "selectionChange", index: this.iSelectedIndex, keyboardOrMouse: aiKeyboardOrMouse});
      }
   }

   function onItemPress(aiKeyboardOrMouse)
   {
      if (aiKeyboardOrMouse == undefined) 
      {
         var centerClip = this.GetClipByIndex(this.iNumTopHalfEntries);
         var centerIndex = (centerClip != undefined) ? centerClip.itemIndex : undefined;

         if (!this.bDisableInput && !this.bDisableSelection && centerIndex != undefined)
         {
            if (!this.bPointerHighlight || this.iSelectedIndex != centerIndex)
            {
               this.bPointerHighlight = true;
               this.bMouseDrivenNav = false;
               this.iSelectedIndex = centerIndex;
               
               this.UpdateList(); 
            }

            this.dispatchEvent({
               type: "itemPress",
               index: this.iSelectedIndex,
               entry: this.EntriesA[this.iSelectedIndex],
               keyboardOrMouse: aiKeyboardOrMouse
            });
         }
         else if (!this.bDisableInput)
         {
            this.dispatchEvent({type: "listPress"});
         }
      }
      else 
      {
         super.onItemPress(aiKeyboardOrMouse);
      }
   }
}
