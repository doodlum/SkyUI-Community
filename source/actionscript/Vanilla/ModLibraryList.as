class ModLibraryList extends Shared.BSScrollingList
{
   var EntriesA;
   var SetEntry;
   var __get__entryList;
   var __get__length;
   var __get__scrollPosition;
   var __get__selectedEntry;
   var __set__scrollPosition;
   var bDisableInput;
   var dispatchEvent;
   var doSetSelectedIndex;
   var iSelectedIndex;
   var STAR_SPACING = 2.5;
   function ModLibraryList()
   {
      super();
   }
   function onLoad()
   {
      super.onLoad();
      var _loc4_ = 0;
      var _loc3_ = ModLibrary_ListEntry(this.GetClipByIndex(_loc4_));
      while(_loc3_ != undefined)
      {
         _loc3_.addEventListener(ListEntryBase.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.BubbleEvent));
         _loc3_.addEventListener(ListEntryBase.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.BubbleEvent));
         _loc3_.addEventListener(ListEntryBase.DISPLAY_IMAGE,Shared.Proxy.create(this,this.BubbleEvent));
         _loc3_ = ModLibrary_ListEntry(this.GetClipByIndex(_loc4_ = _loc4_ + 1));
      }
   }
   function UpdateEntry(data)
   {
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < this.length)
      {
         if(this.entryList[_loc2_] == data && this.entryList[_loc2_].clipIndex != undefined)
         {
            _loc3_ = ModLibrary_ListEntry(this.GetClipByIndex(this.entryList[_loc2_].clipIndex));
            _loc3_.SetEntryData(data,this.entryList[_loc2_] == this.selectedEntry);
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function SetEntryText(aEntryClip, aEntryObject)
   {
      super.SetEntryText(aEntryClip,aEntryObject);
      aEntryClip.SetEntryData(aEntryObject,aEntryObject == this.selectedEntry);
   }
   function GetClipByIndex(aiIndex)
   {
      return super.GetClipByIndex(aiIndex);
   }
   function UpdateSelectedEntry()
   {
      if(this.iSelectedIndex != -1)
      {
         this.SetEntry(this.GetClipByIndex(this.EntriesA[this.iSelectedIndex].clipIndex),this.EntriesA[this.iSelectedIndex]);
      }
   }
   function BubbleEvent(event)
   {
      this.dispatchEvent({type:event.type,target:event.target,data:event.data});
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
   function UpdateList()
   {
      super.UpdateList();
      var _loc4_ = 0;
      while(_loc4_ < this.length)
      {
         if(this.entryList[_loc4_].clipIndex != undefined && ModLibrary_ListEntry(this.GetClipByIndex(this.entryList[_loc4_].clipIndex)).hitTest(_root._xmouse,_root._ymouse))
         {
            this.doSetSelectedIndex(_loc4_);
         }
         _loc4_ = _loc4_ + 1;
      }
   }
}
