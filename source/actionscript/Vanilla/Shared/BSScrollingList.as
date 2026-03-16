class Shared.BSScrollingList extends MovieClip
{
   var EntriesA;
   var ListScrollbar;
   var ScrollDown;
   var ScrollUp;
   var bDisableInput;
   var bDisableSelection;
   var bListAnimating;
   var bMouseDrivenNav;
   var border;
   var dispatchEvent;
   var fListHeight;
   var iListItemsShown;
   var iMaxItemsShown;
   var iMaxScrollPosition;
   var iPlatform;
   var iScrollPosition;
   var iScrollbarDrawTimerID;
   var iSelectedIndex;
   var iHighlightedIndex;
   var iTextOption;
   var itemIndex;
   var onMousePress;
   var scrollbar;
   static var TEXT_OPTION_NONE = 0;
   static var TEXT_OPTION_SHRINK_TO_FIT = 1;
   static var TEXT_OPTION_MULTILINE = 2;
   function BSScrollingList()
   {
      super();
      this.EntriesA = new Array();
      this.bDisableSelection = false;
      this.bDisableInput = false;
      this.bMouseDrivenNav = false;
      gfx.events.EventDispatcher.initialize(this);
      Mouse.addListener(this);
      this.iSelectedIndex = -1;
      this.iHighlightedIndex = -1;
      this.iScrollPosition = 0;
      this.iMaxScrollPosition = 0;
      this.iListItemsShown = 0;
      this.iPlatform = 1;
      this.fListHeight = this.border._height;
      this.ListScrollbar = this.scrollbar;
      this.iMaxItemsShown = 0;
      var _loc3_ = this.GetClipByIndex(this.iMaxItemsShown);
      while(_loc3_ != undefined)
      {
         _loc3_.clipIndex = this.iMaxItemsShown;
         _loc3_.onRollOver = function()
         {
            if(!this._parent.listAnimating && !this._parent.bDisableInput && this.itemIndex != undefined)
            {
               this._parent.doSetSelectedIndex(this.itemIndex, 0, true);
               this._parent.bMouseDrivenNav = true;
            }
         };
         _loc3_.onPress = function(aiMouseIndex, aiKeyboardOrMouse)
         {
            if(this.itemIndex != undefined)
            {
               this._parent.onItemPress(aiKeyboardOrMouse);
               if(!this._parent.bDisableInput && this.onMousePress != undefined)
               {
                  this.onMousePress();
               }
            }
         };
         _loc3_.onPressAux = function(aiMouseIndex, aiKeyboardOrMouse, aiButtonIndex)
         {
            if(this.itemIndex != undefined)
            {
               this._parent.onItemPressAux(aiKeyboardOrMouse,aiButtonIndex);
            }
         };
         _loc3_ = this.GetClipByIndex(++this.iMaxItemsShown);
      }
   }
   function onLoad()
   {
      if(this.ListScrollbar != undefined)
      {
         this.ListScrollbar.position = 0;
         this.ListScrollbar.addEventListener("scroll",this,"onScroll");
      }
   }
   function ClearList()
   {
      this.EntriesA.splice(0,this.EntriesA.length);
      this.iHighlightedIndex = -1;
   }
   function GetClipByIndex(aiIndex)
   {
      return this["Entry" + aiIndex];
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      var _loc4_;
      if(!this.bDisableInput)
      {
         _loc4_ = this.GetClipByIndex(this.selectedIndex - this.scrollPosition);
         _loc2_ = _loc4_ != undefined && _loc4_.handleInput != undefined && _loc4_.handleInput(details,pathToFocus.slice(1));
         if(!_loc2_ && Shared.GlobalFunc.IsKeyPressed(details))
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.UP)
            {
               this.moveSelectionUp();
               _loc2_ = true;
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.DOWN)
            {
               this.moveSelectionDown();
               _loc2_ = true;
            }
            else if(!this.bDisableSelection && details.navEquivalent == gfx.ui.NavigationCode.ENTER)
            {
               this.onItemPress();
               _loc2_ = true;
            }
         }
      }
      return _loc2_;
   }
   function onMouseWheel(delta)
   {
      var _loc2_;
      if(!this.bDisableInput)
      {
         _loc2_ = Mouse.getTopMostEntity();
         while(_loc2_ && _loc2_ != undefined)
         {
            if(_loc2_ == this)
            {
               this.doSetSelectedIndex(-1, 0, false);
               if(delta < 0)
               {
                  this.scrollPosition = this.scrollPosition + 1;
               }
               else if(delta > 0)
               {
                  this.scrollPosition = this.scrollPosition - 1;
               }
            }
            _loc2_ = _loc2_._parent;
         }
      }
   }
   function get selectedIndex()
   {
      return this.iSelectedIndex;
   }
   function set selectedIndex(aiNewIndex)
   {
      this.doSetSelectedIndex(aiNewIndex, 0, false);
   }
   function get length()
   {
      return this.EntriesA.length;
   }
   function get listAnimating()
   {
      return this.bListAnimating;
   }
   function set listAnimating(abFlag)
   {
      this.bListAnimating = abFlag;
   }
   function doSetSelectedIndex(aiNewIndex, aiKeyboardOrMouse, abMouseFocus)
   {
      var iCurHighlightIndex = this.iHighlightedIndex;

      if(!this.bDisableSelection)
      {
         if(abMouseFocus !== true)
         {
            this.iSelectedIndex = aiNewIndex;
         }

         if(aiNewIndex != iCurHighlightIndex)
         {
            var iCurrentIndex = this.iHighlightedIndex;
            this.iHighlightedIndex = aiNewIndex;

            if(iCurrentIndex != -1)
            {
               this.SetEntry(
                  this.GetClipByIndex(this.EntriesA[iCurrentIndex].clipIndex),
                  this.EntriesA[iCurrentIndex]
               );
            }

            if(this.iHighlightedIndex != -1)
            {
               if(this.iPlatform != 0)
               {
                  if(this.iHighlightedIndex < this.iScrollPosition)
                  {
                     this.scrollPosition = this.iHighlightedIndex;
                  }
                  else if(this.iHighlightedIndex >= this.iScrollPosition + this.iListItemsShown)
                  {
                     this.scrollPosition = Math.min(
                        this.iHighlightedIndex - this.iListItemsShown + 1,
                        this.iMaxScrollPosition
                     );
                  }
                  else
                  {
                     this.SetEntry(
                        this.GetClipByIndex(this.EntriesA[this.iHighlightedIndex].clipIndex),
                        this.EntriesA[this.iHighlightedIndex]
                     );
                  }
               }
               else
               {
                  this.SetEntry(
                     this.GetClipByIndex(this.EntriesA[this.iHighlightedIndex].clipIndex),
                     this.EntriesA[this.iHighlightedIndex]
                  );
               }
            }

            if(abMouseFocus === true)
            {
               dispatchEvent({type:"highlightChange", index:iHighlightedIndex});
            }
            else
            {
               dispatchEvent({type:"selectionChange", index:iSelectedIndex, keyboardOrMouse:aiKeyboardOrMouse});
            }
         }
      }
   }
   function get scrollPosition()
   {
      return this.iScrollPosition;
   }
   function get maxScrollPosition()
   {
      return this.iMaxScrollPosition;
   }
   function set scrollPosition(aiNewPosition)
   {
      if(aiNewPosition != this.iScrollPosition && aiNewPosition >= 0 && aiNewPosition <= this.iMaxScrollPosition)
      {
         if(this.ListScrollbar != undefined)
         {
            this.ListScrollbar.position = aiNewPosition;
         }
         else
         {
            this.updateScrollPosition(aiNewPosition);
         }
      }
   }
   function updateScrollPosition(aiPosition)
   {
      this.iScrollPosition = aiPosition;
      this.UpdateList();
   }
   function get selectedEntry()
   {
      return this.EntriesA[this.iSelectedIndex];
   }
   function get entryList()
   {
      return this.EntriesA;
   }
   function set entryList(anewArray)
   {
      this.EntriesA = anewArray;
   }
   function get disableSelection()
   {
      return this.bDisableSelection;
   }
   function set disableSelection(abFlag)
   {
      this.bDisableSelection = abFlag;
   }
   function get disableInput()
   {
      return this.bDisableInput;
   }
   function set disableInput(abFlag)
   {
      this.bDisableInput = abFlag;
   }
   function get maxEntries()
   {
      return this.iMaxItemsShown;
   }
   function get textOption()
   {
      return this.iTextOption;
   }
   function set textOption(strNewOption)
   {
      if(strNewOption == "None")
      {
         this.iTextOption = Shared.BSScrollingList.TEXT_OPTION_NONE;
      }
      else if(strNewOption == "Shrink To Fit")
      {
         this.iTextOption = Shared.BSScrollingList.TEXT_OPTION_SHRINK_TO_FIT;
      }
      else if(strNewOption == "Multi-Line")
      {
         this.iTextOption = Shared.BSScrollingList.TEXT_OPTION_MULTILINE;
      }
   }
   function UpdateList()
   {
      var _loc6_ = this.GetClipByIndex(0)._y;
      var _loc5_ = 0;
      var _loc2_ = 0;
      while(_loc2_ < this.iScrollPosition)
      {
         this.EntriesA[_loc2_].clipIndex = undefined;
         _loc2_ = _loc2_ + 1;
      }
      this.iListItemsShown = 0;
      _loc2_ = this.iScrollPosition;
      var _loc3_;
      while(_loc2_ < this.EntriesA.length && this.iListItemsShown < this.iMaxItemsShown && _loc5_ <= this.fListHeight)
      {
         _loc3_ = this.GetClipByIndex(this.iListItemsShown);
         this.SetEntry(_loc3_,this.EntriesA[_loc2_]);
         this.EntriesA[_loc2_].clipIndex = this.iListItemsShown;
         _loc3_.itemIndex = _loc2_;
         _loc3_._y = _loc6_ + _loc5_;
         _loc3_._visible = true;
         _loc5_ += _loc3_._height;
         if(_loc5_ <= this.fListHeight && this.iListItemsShown < this.iMaxItemsShown)
         {
            this.iListItemsShown = this.iListItemsShown + 1;
         }
         _loc2_ = _loc2_ + 1;
      }
      var _loc4_ = this.iListItemsShown;
      while(_loc4_ < this.iMaxItemsShown)
      {
         this.GetClipByIndex(_loc4_)._visible = false;
         _loc4_ = _loc4_ + 1;
      }
      if(this.ScrollUp != undefined)
      {
         this.ScrollUp._visible = this.scrollPosition > 0;
      }
      if(this.ScrollDown != undefined)
      {
         this.ScrollDown._visible = this.scrollPosition < this.iMaxScrollPosition;
      }
   }
   function InvalidateData()
   {
      var _loc2_ = this.iMaxScrollPosition;
      this.fListHeight = this.border._height;
      this.CalculateMaxScrollPosition();
      if(this.ListScrollbar != undefined)
      {
         if(_loc2_ != this.iMaxScrollPosition)
         {
            this.ListScrollbar._visible = false;
            this.ListScrollbar.setScrollProperties(this.iMaxItemsShown,0,this.iMaxScrollPosition);
            if(this.iScrollbarDrawTimerID != undefined)
            {
               clearInterval(this.iScrollbarDrawTimerID);
            }
            this.iScrollbarDrawTimerID = setInterval(this,"SetScrollbarVisibility",50);
         }
         else
         {
            this.SetScrollbarVisibility();
         }
      }
      if(this.iSelectedIndex >= this.EntriesA.length)
      {
         this.iSelectedIndex = this.EntriesA.length - 1;
      }
      if(this.iScrollPosition > this.iMaxScrollPosition)
      {
         this.iScrollPosition = this.iMaxScrollPosition;
      }
      this.UpdateList();
   }
   function SetScrollbarVisibility()
   {
      clearInterval(this.iScrollbarDrawTimerID);
      this.iScrollbarDrawTimerID = undefined;
      this.ListScrollbar._visible = this.iMaxScrollPosition > 0;
   }
   function CalculateMaxScrollPosition()
   {
      var _loc3_ = 0;
      var _loc2_ = this.EntriesA.length - 1;
      while(_loc2_ >= 0 && _loc3_ <= this.fListHeight)
      {
         _loc3_ += this.GetEntryHeight(_loc2_);
         if(_loc3_ <= this.fListHeight)
         {
            _loc2_ = _loc2_ - 1;
         }
      }
      this.iMaxScrollPosition = _loc2_ + 1;
   }
   function GetEntryHeight(aiEntryIndex)
   {
      var _loc2_ = this.GetClipByIndex(0);
      this.SetEntry(_loc2_,this.EntriesA[aiEntryIndex]);
      return _loc2_._height;
   }
   function moveSelectionUp()
   {
      if(this.EntriesA.length != 1)
      {
         if(!this.bDisableSelection)
         {
            if(this.selectedIndex > 0)
            {
               this.selectedIndex = this.selectedIndex - 1;
            }
         }
         else
         {
            this.scrollPosition = this.scrollPosition - 1;
         }
      }
   }
   function moveSelectionDown()
   {
      if(this.EntriesA.length != 1)
      {
         if(!this.bDisableSelection)
         {
            if(this.selectedIndex < this.EntriesA.length - 1)
            {
               this.selectedIndex = this.selectedIndex + 1;
            }
         }
         else
         {
            this.scrollPosition = this.scrollPosition + 1;
         }
      }
   }
   function onItemPress(aiKeyboardOrMouse)
   {
      if(!this.bDisableInput && !this.bDisableSelection && this.iSelectedIndex != -1)
      {
         this.dispatchEvent({type:"itemPress",index:this.iSelectedIndex,entry:this.EntriesA[this.iSelectedIndex],keyboardOrMouse:aiKeyboardOrMouse});
         return;
      }
      this.dispatchEvent({type:"listPress"});
   }
   function onItemPressAux(aiKeyboardOrMouse, aiButtonIndex)
   {
      if(!this.bDisableInput && !this.bDisableSelection && this.iSelectedIndex != -1 && aiButtonIndex == 1)
      {
         this.dispatchEvent({type:"itemPressAux",index:this.iSelectedIndex,entry:this.EntriesA[this.iSelectedIndex],keyboardOrMouse:aiKeyboardOrMouse});
      }
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      var aSelectedEntry = this.EntriesA[this.iHighlightedIndex];
      if(aEntryClip != undefined)
      {
         if(aEntryObject == aSelectedEntry)
         {
            aEntryClip.gotoAndStop("Selected");
         }
         else
         {
            aEntryClip.gotoAndStop("Normal");
         }
         this.SetEntryText(aEntryClip,aEntryObject);
      }
   }
   function SetEntryText(aEntryClip, aEntryObject)
   {
      if(aEntryClip.textField != undefined)
      {
         if(this.textOption == Shared.BSScrollingList.TEXT_OPTION_SHRINK_TO_FIT)
         {
            aEntryClip.textField.textAutoSize = "shrink";
         }
         else if(this.textOption == Shared.BSScrollingList.TEXT_OPTION_MULTILINE)
         {
            aEntryClip.textField.verticalAutoSize = "top";
         }
         if(aEntryObject.text != undefined)
         {
            aEntryClip.textField.SetText(aEntryObject.text);
         }
         else
         {
            aEntryClip.textField.SetText(" ");
         }
         if(aEntryObject.enabled != undefined)
         {
            aEntryClip.textField.textColor = aEntryObject.enabled != false ? 16777215 : 6316128;
         }
         if(aEntryObject.disabled != undefined)
         {
            aEntryClip.textField.textColor = aEntryObject.disabled != true ? 16777215 : 6316128;
         }
      }
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.iPlatform = aiPlatform;
      this.bMouseDrivenNav = this.iPlatform == 0;
   }
   function onScroll(event)
   {
      this.updateScrollPosition(Math.floor(event.position + 0.5));
   }
}
