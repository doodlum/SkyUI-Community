class skyui.components.list.BasicList extends skyui.components.list.BSList
{
   var _dataProcessors;
   var _entryClipManager;
   var _entryList;
   var _invalidateRequestID;
   var _selectedIndex;
   var _updateRequestID;
   var background;
   var dispatchEvent;
   var listEnumeration;
   var listState;
   var onInvalidate;
   var onUnsuspend;
   static var PLATFORM_PC = 0;
   static var SELECT_MOUSE = 0;
   static var SELECT_KEYBOARD = 1;
   var _bRequestInvalidate = false;
   var _bRequestUpdate = false;
   var topBorder = 0;
   var bottomBorder = 0;
   var leftBorder = 0;
   var rightBorder = 0;
   var _platform = skyui.components.list.BasicList.PLATFORM_PC;
   var isMouseDrivenNav = false;
   var isListAnimating = false;
   var disableInput = false;
   var disableSelection = false;
   var isAutoUnselect = false;
   var canSelectDisabled = false;
   var _bSuspended = false;
   function BasicList()
   {
      super();
      this._entryClipManager = new skyui.components.list.EntryClipManager(this);
      this._dataProcessors = [];
      this.listState = new skyui.components.list.ListState(this);
      gfx.events.EventDispatcher.initialize(this);
      Mouse.addListener(this);
   }
   function get width()
   {
      return this.background._width;
   }
   function set width(a_val)
   {
      this.background._width = a_val;
   }
   function get height()
   {
      return this.background._height;
   }
   function set height(a_val)
   {
      this.background._height = a_val;
   }
   function get platform()
   {
      return this._platform;
   }
   function get selectedIndex()
   {
      return this._selectedIndex;
   }
   function set selectedIndex(a_newIndex)
   {
      this.doSetSelectedIndex(a_newIndex,skyui.components.list.BasicList.SELECT_MOUSE);
   }
   function get itemCount()
   {
      return this.getListEnumSize();
   }
   function get selectedClip()
   {
      return this._entryClipManager.getClip(this.selectedEntry.clipIndex);
   }
   function get suspended()
   {
      return this._bSuspended;
   }
   function set suspended(a_flag)
   {
      if(this._bSuspended == a_flag)
      {
         return;
      }
      if(a_flag)
      {
         this._bSuspended = true;
      }
      else
      {
         this._bSuspended = false;
         if(this._bRequestInvalidate)
         {
            this.InvalidateData();
         }
         else if(this._bRequestUpdate)
         {
            this.UpdateList();
         }
         this._bRequestInvalidate = false;
         this._bRequestUpdate = false;
         if(this.onUnsuspend != undefined)
         {
            this.onUnsuspend();
         }
      }
   }
   function setPlatform(a_platform, a_bPS3Switch)
   {
      this._platform = a_platform;
      this.isMouseDrivenNav = this._platform == skyui.components.list.BasicList.PLATFORM_PC;
   }
   function addDataProcessor(a_dataProcessor)
   {
      this._dataProcessors.push(a_dataProcessor);
   }
   function clearList()
   {
      this._entryList.splice(0);
   }
   function requestInvalidate()
   {
      this._bRequestInvalidate = true;
      if(this._updateRequestID)
      {
         this._bRequestUpdate = false;
         clearInterval(this._updateRequestID);
         delete this._updateRequestID;
      }
      if(!this._bSuspended && !this._invalidateRequestID)
      {
         this._invalidateRequestID = setInterval(this,"commitInvalidate",1);
      }
   }
   function requestUpdate()
   {
      this._bRequestUpdate = true;
      if(this._invalidateRequestID)
      {
         return undefined;
      }
      if(!this._bSuspended && !this._invalidateRequestID)
      {
         this._updateRequestID = setInterval(this,"commitUpdate",1);
      }
   }
   function commitInvalidate()
   {
      clearInterval(this._invalidateRequestID);
      delete this._invalidateRequestID;
      if(this._updateRequestID)
      {
         this._bRequestUpdate = false;
         clearInterval(this._updateRequestID);
         delete this._updateRequestID;
      }
      this._bRequestInvalidate = false;
      this.InvalidateData();
   }
   function commitUpdate()
   {
      clearInterval(this._updateRequestID);
      delete this._updateRequestID;
      this._bRequestUpdate = false;
      this.UpdateList();
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
      this.UpdateList();
      if(this.onInvalidate)
      {
         this.onInvalidate();
      }
   }
   function UpdateList()
   {
   }
   function onItemPress(a_index, a_keyboardOrMouse)
   {
      if(this.disableInput || this.disableSelection || this._selectedIndex == -1)
      {
         return undefined;
      }
      if(a_keyboardOrMouse == undefined)
      {
         a_keyboardOrMouse = skyui.components.list.BasicList.SELECT_KEYBOARD;
      }
      this.dispatchEvent({type:"itemPress",index:this._selectedIndex,entry:this.selectedEntry,clip:this.selectedClip,keyboardOrMouse:a_keyboardOrMouse});
   }
   function onItemPressAux(a_index, a_keyboardOrMouse, a_buttonIndex)
   {
      if(this.disableInput || this.disableSelection || this._selectedIndex == -1 || a_buttonIndex != 1)
      {
         return undefined;
      }
      if(a_keyboardOrMouse == undefined)
      {
         a_keyboardOrMouse = skyui.components.list.BasicList.SELECT_KEYBOARD;
      }
      this.dispatchEvent({type:"itemPressAux",index:this._selectedIndex,entry:this.selectedEntry,clip:this.selectedClip,keyboardOrMouse:a_keyboardOrMouse});
   }
   function onItemRollOver(a_index)
   {
      if(this.isListAnimating || this.disableSelection || this.disableInput)
      {
         return undefined;
      }
      this.doSetSelectedIndex(a_index,skyui.components.list.BasicList.SELECT_MOUSE);
      this.isMouseDrivenNav = true;
   }
   function onItemRollOut(a_index)
   {
      if(!this.isAutoUnselect)
      {
         return undefined;
      }
      if(this.isListAnimating || this.disableSelection || this.disableInput)
      {
         return undefined;
      }
      this.doSetSelectedIndex(-1,skyui.components.list.BasicList.SELECT_MOUSE);
      this.isMouseDrivenNav = true;
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
      var _loc2_ = this._selectedIndex;
      this._selectedIndex = a_newIndex;
      var _loc4_;
      if(_loc2_ != -1)
      {
         _loc4_ = this._entryClipManager.getClip(this._entryList[_loc2_].clipIndex);
         _loc4_.setEntry(this._entryList[_loc2_],this.listState);
      }
      if(this._selectedIndex != -1)
      {
         _loc4_ = this._entryClipManager.getClip(this._entryList[this._selectedIndex].clipIndex);
         _loc4_.setEntry(this._entryList[this._selectedIndex],this.listState);
      }
      this.dispatchEvent({type:"selectionChange",index:this._selectedIndex,keyboardOrMouse:a_keyboardOrMouse});
   }
   function getClipByIndex(a_index)
   {
      return this._entryClipManager.getClip(a_index);
   }
   function setClipCount(a_count)
   {
      this._entryClipManager.clipCount = a_count;
   }
   function getSelectedListEnumIndex()
   {
      return this.listEnumeration.lookupEnumIndex(this._selectedIndex);
   }
   function getListEnumIndex(a_index)
   {
      return this.listEnumeration.lookupEnumIndex(a_index);
   }
   function getListEntryIndex(a_index)
   {
      return this.listEnumeration.lookupEntryIndex(a_index);
   }
   function getListEnumSize()
   {
      return this.listEnumeration.size();
   }
   function getListEnumEntry(a_index)
   {
      return this.listEnumeration.at(a_index);
   }
   function getListEnumFirstIndex()
   {
      return this.listEnumeration.lookupEntryIndex(0);
   }
   function getListEnumLastIndex()
   {
      return this.listEnumeration.lookupEntryIndex(this.getListEnumSize() - 1);
   }
   function getListEnumRelativeIndex(a_offset)
   {
      return this.listEnumeration.lookupEntryIndex(this.getSelectedListEnumIndex() + a_offset);
   }
}
