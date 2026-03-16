class FilteredList extends Shared.CenteredList
{
   var BottomHalf;
   var EntriesA;
   var EntryMatchesFunc;
   var RepositionEntries;
   var SelectedEntry;
   var TopHalf;
   var __get__selectedIndex;
   var bMultilineList;
   var bToFitList;
   var dispatchEvent;
   var iDividerIndex;
   var iItemFilter;
   var iMaxEntriesBottomHalf;
   var iMaxEntriesTopHalf;
   var iSelectedIndex;
   function FilteredList()
   {
      super();
      this.iItemFilter = 4294967295;
      this.EntryMatchesFunc = this.EntryMatchesFilter;
      this.iDividerIndex = -1;
   }
   function get itemFilter()
   {
      return this.iItemFilter;
   }
   function set itemFilter(aiNewFilter)
   {
      this.iItemFilter = aiNewFilter;
   }
   function SetPartitionedFilterMode(abPartition)
   {
      this.EntryMatchesFunc = !abPartition ? this.EntryMatchesFilter : this.EntryMatchesPartitionedFilter;
   }
   function IsDivider(aEntry)
   {
      return aEntry.divider == true || aEntry.flag == 0;
   }
   function moveListUp()
   {
      var _loc2_ = this.GetNextFilterMatch(this.iSelectedIndex);
      if(_loc2_ != undefined && this.IsDivider(this.EntriesA[_loc2_]))
      {
         _loc2_ = this.GetNextFilterMatch(_loc2_);
      }
      if(_loc2_ != undefined)
      {
         this.iSelectedIndex = _loc2_;
         this.UpdateList();
         this.dispatchEvent({type:"listMovedUp"});
      }
   }
   function moveListDown()
   {
      var _loc2_ = this.GetPrevFilterMatch(this.iSelectedIndex);
      if(_loc2_ != undefined && this.IsDivider(this.EntriesA[_loc2_]))
      {
         _loc2_ = this.GetPrevFilterMatch(_loc2_);
      }
      if(_loc2_ != undefined)
      {
         this.iSelectedIndex = _loc2_;
         this.UpdateList();
         this.dispatchEvent({type:"listMovedDown"});
      }
   }
   function EntryMatchesFilter(aiIndex)
   {
      return this.EntriesA[aiIndex] != undefined && (this.EntriesA[aiIndex].filterFlag & this.iItemFilter) != 0;
   }
   function EntryMatchesPartitionedFilter(aiIndex)
   {
      var _loc3_ = false;
      var _loc2_;
      var _loc4_;
      var _loc7_;
      var _loc6_;
      var _loc5_;
      if(this.EntriesA[aiIndex] != undefined)
      {
         if(this.iItemFilter == 4294967295)
         {
            _loc3_ = true;
         }
         else
         {
            _loc2_ = this.EntriesA[aiIndex].filterFlag;
            _loc4_ = _loc2_ & 0xFF;
            _loc7_ = (_loc2_ & 0xFF00) >>> 8;
            _loc6_ = (_loc2_ & 0xFF0000) >>> 16;
            _loc5_ = (_loc2_ & 0xFF000000) >>> 24;
            _loc3_ = _loc4_ == this.iItemFilter || _loc7_ == this.iItemFilter || _loc6_ == this.iItemFilter || _loc5_ == this.iItemFilter;
         }
      }
      return _loc3_;
   }
   function GetPrevFilterMatch(aiStartIndex)
   {
      var _loc3_;
      var _loc2_ = aiStartIndex - 1;
      while(_loc2_ >= 0 && _loc3_ == undefined)
      {
         if(this.EntryMatchesFunc(_loc2_))
         {
            _loc3_ = _loc2_;
         }
         _loc2_ = _loc2_ - 1;
      }
      return _loc3_;
   }
   function GetNextFilterMatch(aiStartIndex)
   {
      var _loc3_;
      var _loc2_ = aiStartIndex + 1;
      while(_loc2_ < this.EntriesA.length && _loc3_ == undefined)
      {
         if(this.EntryMatchesFunc(_loc2_))
         {
            _loc3_ = _loc2_;
         }
         _loc2_ = _loc2_ + 1;
      }
      return _loc3_;
   }
   function UpdateList()
   {
      if(this.iSelectedIndex == undefined)
      {
         this.iSelectedIndex = 0;
      }
      this.iDividerIndex = -1;
      var _loc2_ = 0;
      while(_loc2_ < this.EntriesA.length)
      {
         if(this.IsDivider(this.EntriesA[_loc2_]))
         {
            this.iDividerIndex = _loc2_;
         }
         _loc2_ = _loc2_ + 1;
      }
      var _loc3_;
      if(!this.EntryMatchesFunc(this.iSelectedIndex))
      {
         _loc3_ = this.GetNextFilterMatch(this.iSelectedIndex);
         if(_loc3_ == undefined)
         {
            _loc3_ = this.GetPrevFilterMatch(this.iSelectedIndex);
         }
         if(_loc3_ == undefined)
         {
            _loc3_ = -1;
         }
         this.iSelectedIndex = _loc3_;
      }
      this.UpdateTopHalf();
      this.SetEntry(this.SelectedEntry,this.EntriesA[this.iSelectedIndex]);
      this.UpdateBottomHalf();
      this.RepositionEntries();
   }
   function IsSelectionAboveDivider()
   {
      return this.iDividerIndex == -1 || this.selectedIndex < this.iDividerIndex;
   }
   function UpdateTopHalf()
   {
      var _loc3_ = this.GetPrevFilterMatch(this.iSelectedIndex);
      var _loc2_ = this.iMaxEntriesTopHalf - 1;
      while(_loc2_ >= 0)
      {
         if(_loc3_ != undefined)
         {
            this.SetEntry(this.TopHalf["Entry" + _loc2_],this.EntriesA[_loc3_]);
            _loc3_ = this.GetPrevFilterMatch(_loc3_);
         }
         else
         {
            this.SetEntry(this.TopHalf["Entry" + _loc2_]);
         }
         _loc2_ = _loc2_ - 1;
      }
   }
   function UpdateBottomHalf()
   {
      var _loc3_ = this.GetNextFilterMatch(this.iSelectedIndex);
      var _loc2_ = 0;
      while(_loc2_ < this.iMaxEntriesBottomHalf)
      {
         if(_loc3_ != undefined)
         {
            this.SetEntry(this.BottomHalf["Entry" + _loc2_],this.EntriesA[_loc3_]);
            _loc3_ = this.GetNextFilterMatch(_loc3_);
         }
         else
         {
            this.SetEntry(this.BottomHalf["Entry" + _loc2_]);
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      if(this.IsDivider(aEntryObject))
      {
         aEntryClip.gotoAndStop("Divider");
      }
      else
      {
         aEntryClip.gotoAndStop(aEntryObject.enabled != false ? "Normal" : "Disabled");
      }
      if(aEntryClip.textField != undefined)
      {
         if(aEntryObject.text == undefined)
         {
            aEntryClip.textField.SetText(" ");
         }
         else
         {
            aEntryClip.textField.SetText(aEntryObject.text);
         }
         if(this.bMultilineList == true)
         {
            aEntryClip.textField.verticalAutoSize = "top";
         }
         if(this.bToFitList == true)
         {
            aEntryClip.textField.textAutoSize = "shrink";
         }
      }
   }
}
