class ModCategoryList extends MovieClip
{
   var CategoryName_tf;
   var EmptyClip_mc;
   var EntryHolder_mc;
   var ScrollLeft;
   var ScrollRight;
   var Selection_mc;
   var _CurrScrollPage;
   var _DataObj;
   var _EntryClipsA;
   var _IsDirtyCustomFlag;
   var _MaxScrollPage;
   var _MaxSelectedIndex;
   var _SelectedIndex;
   var dispatchEvent;
   var onEnterFrame;
   var onKillFocus;
   var onSetFocus;
   static var PLAY_SOUND = "PlaySound";
   var SELECTION_RECT_DIRTY = 1;
   var NAME_DIRTY = 2;
   var SCROLL_DIRTY = 4;
   var ALL_DIRTY = 4294967295;
   var MAX_ENTRIES = 7;
   var ENTRY_SPACING = 7.5;
   function ModCategoryList()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this.focusEnabled = true;
      this._CurrScrollPage = 0;
      this._MaxScrollPage = 0;
      this._EntryClipsA = new Array();
      this._SelectedIndex = 1.7976931348623157e+308;
      this._MaxSelectedIndex = 1.7976931348623157e+308;
      this._IsDirtyCustomFlag = 0;
      this.onEnterFrame = Shared.Proxy.create(this,this.redrawUIComponent);
      this.onSetFocus = Shared.Proxy.create(this,this.onListSetFocus);
      this.onKillFocus = Shared.Proxy.create(this,this.onListKillFocus);
      this.ScrollLeft.onRelease = Shared.Proxy.create(this,this.onScrollLeftClick);
      this.ScrollRight.onRelease = Shared.Proxy.create(this,this.onScrollRightClick);
      this.PopulateEntryClips();
      this.SetIsDirty_Custom(this.SELECTION_RECT_DIRTY);
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
         {
            this.dispatchEvent({type:gfx.events.EventTypes.ITEM_CLICK,target:this});
            _loc2_ = true;
         }
         if(details.navEquivalent == gfx.ui.NavigationCode.LEFT)
         {
            this.moveSelectionLeft();
            _loc2_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT)
         {
            this.moveSelectionRight();
            _loc2_ = true;
         }
      }
      return _loc2_;
   }
   function SetIsDirty_Custom(aFlag)
   {
      this._IsDirtyCustomFlag |= aFlag;
   }
   function get selectedIndex()
   {
      return this._SelectedIndex;
   }
   function set selectedIndex(aVal)
   {
      this._SelectedIndex = aVal;
      if(this._SelectedIndex != 1.7976931348623157e+308)
      {
         this._SelectedIndex = Math.min(this._SelectedIndex,this._MaxSelectedIndex);
      }
      this.SetIsDirty_Custom(this.SELECTION_RECT_DIRTY);
   }
   function get selectedEntry()
   {
      return this._SelectedIndex == 1.7976931348623157e+308 ? null : this._DataObj.entries[this._CurrScrollPage + this._SelectedIndex];
   }
   function get currScrollPage()
   {
      return this._CurrScrollPage;
   }
   function set currScrollPage(aVal)
   {
      var _loc6_;
      var _loc2_;
      var _loc5_;
      var _loc3_;
      if(aVal == this._CurrScrollPage - 1 && this._CurrScrollPage > 0)
      {
         this._CurrScrollPage = this._CurrScrollPage - 1;
         this._EntryClipsA[this.MAX_ENTRIES - 1].UnloadThumbnail();
         _loc6_ = this._EntryClipsA[0]._x;
         _loc2_ = 0;
         while(_loc2_ < this.MAX_ENTRIES - 1)
         {
            this._EntryClipsA[_loc2_]._x = this._EntryClipsA[_loc2_ + 1]._x;
            this._EntryClipsA[_loc2_].itemIndex = this._EntryClipsA[_loc2_].itemIndex + 1;
            _loc2_ = _loc2_ + 1;
         }
         this._EntryClipsA.splice(0,0,this._EntryClipsA.pop());
         this._EntryClipsA[0]._x = _loc6_;
         this._EntryClipsA[0].dataObj = this._DataObj.entries[this._CurrScrollPage];
         this._EntryClipsA[0].itemIndex = 0;
         this.SetIsDirty_Custom(this.SCROLL_DIRTY);
      }
      else if(aVal == this._CurrScrollPage + 1 && this._CurrScrollPage < this._MaxScrollPage)
      {
         this._CurrScrollPage = this._CurrScrollPage + 1;
         this._EntryClipsA[0].UnloadThumbnail();
         _loc5_ = this._EntryClipsA[this.MAX_ENTRIES - 1]._x;
         _loc3_ = this.MAX_ENTRIES - 1;
         while(_loc3_ >= 1)
         {
            this._EntryClipsA[_loc3_]._x = this._EntryClipsA[_loc3_ - 1]._x;
            this._EntryClipsA[_loc3_].itemIndex--;
            _loc3_ = _loc3_ - 1;
         }
         this._EntryClipsA.push(this._EntryClipsA.shift());
         this._EntryClipsA[this.MAX_ENTRIES - 1]._x = _loc5_;
         this._EntryClipsA[this.MAX_ENTRIES - 1].dataObj = this._DataObj.entries[this._CurrScrollPage + this.MAX_ENTRIES - 1];
         this._EntryClipsA[this.MAX_ENTRIES - 1].itemIndex = this.MAX_ENTRIES - 1;
         this.SetIsDirty_Custom(this.SCROLL_DIRTY);
      }
      else if(aVal >= 0 && aVal <= this._MaxScrollPage)
      {
         this._CurrScrollPage = aVal;
         this.RefreshScrollVars();
         this.RefreshEntryData();
      }
      if(this._DataObj != null)
      {
         this._DataObj.savedScrollPage = this._CurrScrollPage;
      }
   }
   function get dataObj()
   {
      return this._DataObj;
   }
   function set dataObj(aObj)
   {
      var _loc3_ = this._SelectedIndex;
      var _loc2_ = this.NAME_DIRTY;
      this._DataObj = aObj;
      if(typeof this._DataObj.savedScrollPage == "number")
      {
         this._CurrScrollPage = this._DataObj.savedScrollPage;
      }
      else
      {
         this._CurrScrollPage = 0;
         this._DataObj.savedScrollPage = 0;
      }
      this.RefreshScrollVars();
      this.RefreshEntryData();
      if(this._SelectedIndex != _loc3_)
      {
         _loc2_ |= this.SELECTION_RECT_DIRTY;
      }
      this.SetIsDirty_Custom(_loc2_);
   }
   function onDataObjectChange(aUpdatedObj)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.MAX_ENTRIES)
      {
         if(this._DataObj.entries[this._CurrScrollPage + _loc2_] == aUpdatedObj)
         {
            this._EntryClipsA[_loc2_].dataObj = aUpdatedObj;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function JumpLeft()
   {
      var _loc2_;
      if(this._CurrScrollPage > 0)
      {
         _loc2_ = 0;
         while(_loc2_ < this.MAX_ENTRIES)
         {
            this._EntryClipsA[_loc2_].UnloadThumbnail();
            _loc2_ = _loc2_ + 1;
         }
         this.currScrollPage = this.currScrollPage - Math.min(this.currScrollPage,this.MAX_ENTRIES);
         this.dispatchEvent({type:ModCategoryList.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
      }
   }
   function JumpRight()
   {
      var _loc2_;
      if(this._CurrScrollPage < this._MaxScrollPage)
      {
         _loc2_ = 0;
         while(_loc2_ < this.MAX_ENTRIES)
         {
            this._EntryClipsA[_loc2_].UnloadThumbnail();
            _loc2_ = _loc2_ + 1;
         }
         this.currScrollPage = this.currScrollPage + Math.min(this._MaxScrollPage - this.currScrollPage,this.MAX_ENTRIES);
         this.dispatchEvent({type:ModCategoryList.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
      }
   }
   function PopulateEntryClips()
   {
      if(this._EntryClipsA.length > 0)
      {
         for(var _loc3_ in this._EntryClipsA)
         {
            MovieClip(this._EntryClipsA[_loc3_]).removeMovieClip();
         }
      }
      this._EntryClipsA.splice(0);
      var _loc2_ = 0;
      while(_loc2_ < this.MAX_ENTRIES)
      {
         this.AddModListEntry(_loc2_);
         _loc2_ = _loc2_ + 1;
      }
   }
   function AddModListEntry(index)
   {
      if(index == undefined)
      {
         index = 0;
      }
      var _loc2_ = ListEntryBase(this.EntryHolder_mc.attachMovie("ModListEntry","ModListEntry" + index,this.EntryHolder_mc.getNextHighestDepth()));
      _loc2_.onRelease = Shared.Proxy.create(this,this.onEntryPress,_loc2_);
      _loc2_.onRollOver = Shared.Proxy.create(this,this.onEntryRollover,_loc2_);
      _loc2_.addEventListener(ListEntryBase.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.BubbleEvent));
      _loc2_.addEventListener(ListEntryBase.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.BubbleEvent));
      _loc2_.addEventListener(ListEntryBase.DISPLAY_IMAGE,Shared.Proxy.create(this,this.BubbleEvent));
      _loc2_._x = (_loc2_._width + this.ENTRY_SPACING) * index;
      _loc2_._visible = false;
      _loc2_.itemIndex = index;
      this._EntryClipsA.push(_loc2_);
      return _loc2_;
   }
   function RefreshEntryData()
   {
      this._MaxSelectedIndex = 1.7976931348623157e+308;
      var _loc2_ = 0;
      while(_loc2_ < this._EntryClipsA.length)
      {
         if(this._DataObj != null && this._DataObj.entries != null && this._CurrScrollPage + _loc2_ < this._DataObj.entries.length)
         {
            this._EntryClipsA[_loc2_].dataObj = this._DataObj.entries[this._CurrScrollPage + _loc2_];
            this._MaxSelectedIndex = _loc2_;
         }
         else
         {
            this._EntryClipsA[_loc2_].dataObj = null;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(this._DataObj == null || this._DataObj.entries.length == 0)
      {
         this.EmptyClip_mc._visible = true;
         this._MaxSelectedIndex = 0;
      }
      else
      {
         this.EmptyClip_mc._visible = false;
      }
      if(this._MaxSelectedIndex == 1.7976931348623157e+308)
      {
         this._SelectedIndex = 1.7976931348623157e+308;
      }
      else if(this._SelectedIndex != 1.7976931348623157e+308)
      {
         this._SelectedIndex = Math.min(this._SelectedIndex,this._MaxSelectedIndex);
      }
   }
   function GetParentEntry(aChildClip)
   {
      var _loc1_ = aChildClip;
      while(_loc1_ != null && !(_loc1_ instanceof ListEntryBase))
      {
         _loc1_ = _loc1_._parent;
      }
      return ListEntryBase(_loc1_);
   }
   function onEntryRollover(value1, value2, value3, mc)
   {
      var _loc2_ = this.GetParentEntry(mc);
      var _loc3_;
      if(_loc2_ != undefined)
      {
         _loc3_ = this._SelectedIndex;
         this.selectedIndex = _loc2_.itemIndex;
         if(_loc3_ != this._SelectedIndex)
         {
            this.dispatchEvent({type:ModCategoryList.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
         }
         this.dispatchEvent({type:gfx.events.EventTypes.ITEM_ROLL_OVER,target:mc});
      }
   }
   function onEntryPress(value1, value2, value3, mc)
   {
      if(this.GetParentEntry(mc) != undefined)
      {
         this.dispatchEvent({type:gfx.events.EventTypes.ITEM_CLICK,target:this});
      }
   }
   function RefreshScrollVars()
   {
      if(this._DataObj == null || this._DataObj.entries == null || this._DataObj.entries.length <= this.MAX_ENTRIES)
      {
         this._MaxScrollPage = 0;
      }
      else
      {
         this._MaxScrollPage = this._DataObj.entries.length - this.MAX_ENTRIES;
      }
      this._CurrScrollPage = Math.min(this._CurrScrollPage,this._MaxScrollPage);
   }
   function redrawUIComponent()
   {
      var _loc2_;
      var _loc3_;
      if((this._IsDirtyCustomFlag & this.NAME_DIRTY) != 0)
      {
         this.CategoryName_tf.SetText(this._DataObj.text);
         if(this._DataObj.modLimitExist != undefined && this._DataObj.modLimitExist)
         {
            _loc2_ = this.CategoryName_tf.text;
            this.CategoryName_tf.SetText("$ModLimitLabel");
            _loc3_ = this.CategoryName_tf.text;
            this.CategoryName_tf.text = _loc2_ + " - " + _loc3_ + " : " + this._DataObj.modCount + "/" + this._DataObj.modLimit;
         }
      }
      if((this._IsDirtyCustomFlag & this.SELECTION_RECT_DIRTY) != 0)
      {
         if(Selection.getFocus() != targetPath(this))
         {
            this.Selection_mc._visible = false;
         }
         else
         {
            this.Selection_mc._x = this._EntryClipsA[this._SelectedIndex]._x + 0;
            this.Selection_mc._y = this._EntryClipsA[this._SelectedIndex]._y + 0;
            this.Selection_mc._visible = true;
         }
      }
      if(this.ScrollLeft != null)
      {
         this.ScrollLeft._visible = this._CurrScrollPage > 0;
      }
      if(this.ScrollRight != null)
      {
         this.ScrollRight._visible = this._MaxScrollPage > 0 && this._CurrScrollPage < this._MaxScrollPage;
      }
      this._IsDirtyCustomFlag = 0;
   }
   function onListSetFocus()
   {
      this.SetIsDirty_Custom(this.SELECTION_RECT_DIRTY);
   }
   function onListKillFocus()
   {
      this.SetIsDirty_Custom(this.SELECTION_RECT_DIRTY);
   }
   function moveSelectionLeft()
   {
      if(this.selectedIndex > 0)
      {
         this.selectedIndex = this.selectedIndex - 1;
         this.dispatchEvent({type:ModCategoryList.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
      }
      else if(this._CurrScrollPage > 0)
      {
         this.currScrollPage = this.currScrollPage - 1;
         this.dispatchEvent({type:ModCategoryList.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
      }
   }
   function moveSelectionRight()
   {
      if(this.selectedIndex < this.MAX_ENTRIES - 1)
      {
         this.selectedIndex = this.selectedIndex + 1;
         this.dispatchEvent({type:ModCategoryList.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
      }
      else if(this._CurrScrollPage < this._MaxScrollPage)
      {
         this.currScrollPage = this.currScrollPage + 1;
         this.dispatchEvent({type:ModCategoryList.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
      }
   }
   function onScrollLeftClick()
   {
      if(this._CurrScrollPage > 0)
      {
         this.currScrollPage = this.currScrollPage - 1;
         this.dispatchEvent({type:ModCategoryList.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
      }
   }
   function onScrollRightClick()
   {
      if(this._CurrScrollPage < this._MaxScrollPage)
      {
         this.currScrollPage = this.currScrollPage + 1;
         this.dispatchEvent({type:ModCategoryList.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
      }
   }
   function BubbleEvent(event)
   {
      this.dispatchEvent({type:event.type,target:event.target,data:event.data});
   }
}
