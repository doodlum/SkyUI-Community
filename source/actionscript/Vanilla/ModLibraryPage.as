class ModLibraryPage extends Components.BSUIComponent
{
   var DescriptionLabelInputCatcher_mc;
   var DescriptionLabel_tf;
   var Description_tf;
   var EmptyWarning_tf;
   var FreeSpaceLabel_tf;
   var FreeSpace_tf;
   var List_mc;
   var ReorderIcon_mc;
   var TextScrollDeltaAccum;
   var TextScrollDown;
   var TextScrollUp;
   var TotalModSpaceLabel_tf;
   var TotalModSpace_tf;
   var _ReorderingMode;
   var _xmouse;
   var _ymouse;
   var bottomButtons;
   var dispatchEvent;
   var focusEnabled;
   var onEnterFrame;
   static var PLAY_SOUND = "PlaySound";
   static var LIBRARY_ITEM_PRESSED = "LibraryItemPressed";
   var _FreeSpace = 0;
   var _TotalModSpace = 0;
   var RIGHT_INPUT_SCROLL_THRESHOLD = 3;
   function ModLibraryPage()
   {
      super();
      this.focusEnabled = true;
      this._ReorderingMode = false;
      this.EmptyWarning_tf._visible = false;
      this.ReorderIcon_mc._visible = false;
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function get dataArray()
   {
      return this.List_mc.entryList;
   }
   function get reorderMode()
   {
      return this._ReorderingMode;
   }
   function set reorderMode(aVal)
   {
      if(!aVal || this.List_mc.selectedEntry != undefined && !this.List_mc.selectedEntry.disabled)
      {
         this._ReorderingMode = aVal;
         this.List_mc.disableInput = this._ReorderingMode;
         this.UpdateReorderIconPosition();
      }
   }
   function get freeSpace()
   {
      return this._FreeSpace;
   }
   function set freeSpace(aVal)
   {
      this._FreeSpace = aVal;
      this.InvalidateData(false);
   }
   function GetModSpaceRemaining()
   {
      return this._FreeSpace - this._TotalModSpace;
   }
   function SetBottomButtons(buttons)
   {
      this.bottomButtons = buttons;
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = this.List_mc.selectedIndex;
      var _loc4_;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.UP && this.List_mc.selectedIndex > 0 && this.List_mc.entryList[this.List_mc.selectedIndex - 1].disabled != true)
         {
            this.List_mc.moveSelectionUp();
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.DOWN && this.List_mc.selectedIndex < this.List_mc.entryList.length - 1 && this.List_mc.entryList[this.List_mc.selectedIndex + 1].disabled != true)
         {
            this.List_mc.moveSelectionDown();
         }
         if(_loc2_ != this.List_mc.selectedIndex && this.reorderMode)
         {
            _loc4_ = this.List_mc.entryList.splice(_loc2_,1)[0];
            this.List_mc.entryList.splice(this.List_mc.selectedIndex,0,_loc4_);
            this.List_mc.UpdateList();
            this.UpdateReorderIconPosition();
         }
         if(details.navEquivalent == gfx.ui.NavigationCode.ENTER && !this.reorderMode && this.List_mc.selectedEntry)
         {
            this.onItemPress();
         }
      }
      return true;
   }
   function OnRightStickInput(afXDelta, afYDelta)
   {
      this.TextScrollDeltaAccum += Math.abs(afYDelta);
      if(this.TextScrollDeltaAccum >= this.RIGHT_INPUT_SCROLL_THRESHOLD)
      {
         this.TextScrollDeltaAccum = 0;
         if(afYDelta > 0.1)
         {
            this.Description_tf.scroll--;
         }
         if(afYDelta < -0.1)
         {
            this.Description_tf.scroll = this.Description_tf.scroll + 1;
         }
         this.UpdateTextScrollIndicators();
      }
   }
   function Refresh()
   {
      this.onSelectionChange();
      this.InvalidateData();
   }
   function Init()
   {
      this.onEnterFrame = null;
      this.List_mc.ScrollUp.onRelease = Shared.Proxy.create(this,this.onListScrollUp);
      this.List_mc.ScrollDown.onRelease = Shared.Proxy.create(this,this.onListScrollDown);
      this.List_mc.addEventListener("selectionChange",Shared.Proxy.create(this,this.onSelectionChange));
      this.List_mc.addEventListener("itemPress",Shared.Proxy.create(this,this.onItemPress));
      this.List_mc.addEventListener(ListEntryBase.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.BubbleEvent));
      this.TextScrollUp.onRelease = Shared.Proxy.create(this,this.onTextScrollUpClicked);
      this.TextScrollDown.onRelease = Shared.Proxy.create(this,this.onTextScrollDownClicked);
      var _loc2_ = new Object();
      _loc2_.onMouseWheel = Shared.Proxy.create(this,this.onMouseWheel);
      Mouse.addListener(_loc2_);
   }
   function UpdateReorderIconPosition()
   {
      if(!this._ReorderingMode || this.List_mc.selectedIndex == -1)
      {
         this.ReorderIcon_mc._visible = false;
      }
      else
      {
         this.ReorderIcon_mc._y = this.List_mc._y + this.List_mc.GetClipByIndex(this.List_mc.selectedEntry.clipIndex)._y + this.List_mc.GetClipByIndex(this.List_mc.selectedEntry.clipIndex)._height / 2;
         this.ReorderIcon_mc._visible = true;
      }
   }
   function InvalidateData()
   {
      this.List_mc.InvalidateData();
      this._TotalModSpace = 0;
      for(var _loc2_ in this.List_mc.entryList)
      {
         this._TotalModSpace += this.List_mc.entryList[_loc2_].fileSizeDisplay;
      }
      var _loc3_ = this._FreeSpace - this._TotalModSpace;
      this.TotalModSpace_tf.SetText(ModUtils.GetFileSizeString(this._TotalModSpace),false);
      this.TotalModSpace_tf._x = this.TotalModSpaceLabel_tf._x + this.TotalModSpaceLabel_tf.textWidth + 4;
      this.FreeSpace_tf.SetText(ModUtils.GetFileSizeString(_loc3_),false);
      this.FreeSpaceLabel_tf._x = this.FreeSpace_tf._x - this.FreeSpace_tf.textWidth;
      this.FreeSpaceLabel_tf._visible = this.FreeSpace_tf._visible = _loc3_ > 0;
      this.EmptyWarning_tf._visible = this.List_mc.entryList.length == 0;
      if(this.List_mc.entryList.length == 0)
      {
         this.Description_tf.SetText("");
      }
      if(this.List_mc.selectedEntry && this.List_mc.selectedEntry.dataObj instanceof Object)
      {
         this.setDescription(this.List_mc.selectedEntry.dataObj);
      }
   }
   function onDataObjectChange(aUpdatedObj)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.List_mc.entryList.length)
      {
         if(this.List_mc.entryList[_loc2_].dataObj == aUpdatedObj)
         {
            this.List_mc.UpdateEntry(this.List_mc.entryList[_loc2_]);
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function ClearArray()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.List_mc.entryList.length)
      {
         this.List_mc.entryList[_loc2_].dataObj = null;
         _loc2_ = _loc2_ + 1;
      }
      this.List_mc.ClearList();
   }
   function onListScrollUp()
   {
      this.List_mc.moveSelectionUp();
   }
   function onListScrollDown()
   {
      this.List_mc.moveSelectionDown();
   }
   function onSelectionChange()
   {
      this.Description_tf.SetText("");
      if(!this._ReorderingMode)
      {
         if(this.List_mc.selectedEntry != null && this.List_mc.selectedEntry != undefined)
         {
            if(this.List_mc.selectedEntry.dataObj instanceof Object)
            {
               this.setDescription(this.List_mc.selectedEntry.dataObj);
            }
            if(!ModManager.MinimalMode)
            {
               this.bottomButtons.GetButtonByIndex(0).label = !this.List_mc.selectedEntry.checked ? "$Mod_LibraryEnable" : "$Mod_LibraryDisable";
            }
            this.bottomButtons.GetButtonByIndex(0).invalidate();
         }
         this.UpdateTextScrollIndicators();
         this.dispatchEvent({type:ModLibraryPage.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
      }
   }
   function setDescription(dataObj)
   {
      this.Description_tf.text = "$Version:";
      var _loc3_ = dataObj.releaseNotes.length <= 0 ? "" : "\n" + dataObj.releaseNotes;
      var _loc4_ = this.Description_tf.text + dataObj.version + _loc3_ + "\n\n";
      this.Description_tf._visible = dataObj.description.length > 0;
      this.DescriptionLabel_tf._visible = dataObj.description.length > 0;
      if(dataObj.description.length > 0)
      {
         this.Description_tf.SetText(_loc4_ + dataObj.description,true);
      }
   }
   function onItemPress()
   {
      if(this.List_mc.selectedEntry != null && this.List_mc.selectedEntry.disabled != true)
      {
         this.dispatchEvent({type:ModLibraryPage.LIBRARY_ITEM_PRESSED,target:this,data:this.List_mc.selectedEntry});
      }
   }
   function UpdateTextScrollIndicators()
   {
      this.TextScrollUp._visible = this.Description_tf.scroll > 1;
      this.TextScrollDown._visible = this.Description_tf.scroll < this.Description_tf.maxscroll;
   }
   function onTextScrollUpClicked()
   {
      this.Description_tf.scroll--;
      this.UpdateTextScrollIndicators();
   }
   function onTextScrollDownClicked()
   {
      this.Description_tf.scroll = this.Description_tf.scroll + 1;
      this.UpdateTextScrollIndicators();
   }
   function onMouseWheel(delta)
   {
      if(this.DescriptionLabelInputCatcher_mc.hitTest(this._xmouse,this._ymouse,true))
      {
         if(delta < 0)
         {
            this.Description_tf.scroll = this.Description_tf.scroll + 1;
         }
         else if(delta > 0)
         {
            this.Description_tf.scroll--;
         }
         this.UpdateTextScrollIndicators();
      }
   }
   function BubbleEvent(event)
   {
      this.dispatchEvent({type:event.type,target:event.target,data:event.data});
   }
}
