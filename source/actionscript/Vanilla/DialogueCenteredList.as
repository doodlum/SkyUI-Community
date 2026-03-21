class DialogueCenteredList extends Shared.CenteredScrollingList
{
   var EntriesA;
   var GetClipByIndex;
   var SetEntry;
   var _parent;
   var bDisableInput;
   var bMouseDrivenNav;
   var bPointerHighlight;
   var bRecenterSelection;
   var doSetSelectedIndex;
   var fCenterY;
   var fListHeight;
   var iListItemsShown;
   var iMaxItemsShown;
   var iNumTopHalfEntries;
   var iPlatform;
   var iScrollPosition;
   var iSelectedIndex;
   var scrollPosition;
   function DialogueCenteredList()
   {
      super();
      this.fCenterY = this.GetClipByIndex(this.iNumTopHalfEntries)._y + this.GetClipByIndex(this.iNumTopHalfEntries)._height / 2;
   }
   function SetEntryText(aEntryClip, aEntryObject)
   {
      super.SetEntryText(aEntryClip,aEntryObject);
      if(aEntryClip.textField != undefined)
      {
         aEntryClip.textField.textColor = !(aEntryObject.topicIsNew == undefined || aEntryObject.topicIsNew) ? 6316128 : 16777215;
      }
   }
   function UpdateList()
   {
      if(this.bPointerHighlight)
      {
         this.iSelectedIndex = this.iScrollPosition;
      }

      var _loc8_ = 0; var _loc6_ = 0; var _loc2_ = 0;
      while(_loc2_ < this.iScrollPosition - this.iNumTopHalfEntries) { _loc2_++; }
      
      this.iListItemsShown = 0;
      var _loc4_ = 0;
      var _loc5_;
      while(_loc4_ < this.iNumTopHalfEntries)
      {
         _loc5_ = this.GetClipByIndex(_loc4_);
         if(this.iScrollPosition - this.iNumTopHalfEntries + _loc4_ >= 0)
         {
            this.SetEntry(_loc5_, this.EntriesA[_loc2_]);
            _loc5_._visible = true;
            _loc5_.itemIndex = _loc2_;
            this.EntriesA[_loc2_].clipIndex = _loc4_;
            _loc2_ = _loc2_ + 1;
         }
         else
         {
            this.SetEntry(_loc5_, {text:" "});
            _loc5_._visible = false;
            _loc5_.itemIndex = undefined;
         }
         _loc5_._y = _loc8_ + _loc6_;
         _loc6_ += _loc5_._height;
         this.iListItemsShown++;
         _loc4_ = _loc4_ + 1;
      }

      if(this.bPointerHighlight) { this.iSelectedIndex = _loc2_; }

      while(_loc2_ < this.EntriesA.length && this.iListItemsShown < this.iMaxItemsShown && _loc6_ <= this.fListHeight)
      {
         _loc5_ = this.GetClipByIndex(this.iListItemsShown);
         this.SetEntry(_loc5_, this.EntriesA[_loc2_]);
         this.EntriesA[_loc2_].clipIndex = this.iListItemsShown;
         _loc5_.itemIndex = _loc2_;
         _loc5_._y = _loc8_ + _loc6_;
         _loc5_._visible = true;
         _loc6_ += _loc5_._height;
         if(_loc6_ <= this.fListHeight && this.iListItemsShown < this.iMaxItemsShown) { this.iListItemsShown++; }
         _loc2_ = _loc2_ + 1;
      }

      var _loc7_ = this.iListItemsShown;
      while(_loc7_ < this.iMaxItemsShown)
      {
         this.GetClipByIndex(_loc7_)._visible = false;
         this.GetClipByIndex(_loc7_).itemIndex = undefined;
         _loc7_ = _loc7_ + 1;
      }

      if(!this.bPointerHighlight && !this.bRecenterSelection)
      {
         var _loc3_ = Mouse.getTopMostEntity();
         while(_loc3_ != undefined)
         {
            if(_loc3_._parent == this && _loc3_._visible && _loc3_.itemIndex != undefined)
            {
               if (_loc3_.itemIndex != this.iSelectedIndex) {
                  this.doSetSelectedIndex(_loc3_.itemIndex, 0);
               }
               break;
            }
            _loc3_ = _loc3_._parent;
         }
      }

      this.bRecenterSelection = false;
      this.RepositionEntries();

      var _locIndicatorLimit = 3;
      this._parent.ScrollIndicators.Up._visible = this.scrollPosition > this.iNumTopHalfEntries;
      this._parent.ScrollIndicators.Down._visible = this.EntriesA.length - this.scrollPosition - 1 > _locIndicatorLimit || _loc6_ > this.fListHeight;
   }

   function RepositionEntries()
   {
      var _loc4_ = this.GetClipByIndex(this.iNumTopHalfEntries)._y + this.GetClipByIndex(this.iNumTopHalfEntries)._height / 2;
      var _loc3_ = this.fCenterY - _loc4_;
      var _loc2_ = 0;
      while(_loc2_ < this.iMaxItemsShown)
      {
         this.GetClipByIndex(_loc2_)._y = this.GetClipByIndex(_loc2_)._y + _loc3_;
         _loc2_ = _loc2_ + 1;
      }
   }

   function onMouseWheel(delta)
   {
      if(!this.bDisableInput)
      {
         this.bPointerHighlight = true;

         if(delta < 0)
         {
            var _next_ = this.GetClipByIndex(this.iNumTopHalfEntries + 1);
            if(_next_._visible == true) this.scrollPosition += 1;
         }
         else if(delta > 0)
         {
            var _prev_ = this.GetClipByIndex(this.iNumTopHalfEntries - 1);
            if(_prev_._visible == true) this.scrollPosition -= 1;
         }

         this.iSelectedIndex = this.iScrollPosition;
         this.UpdateList();
      }
   }

   function SetSelectedTopic(aiTopicIndex)
   {
      this.bPointerHighlight = true;
      this.iSelectedIndex = 0;
      this.iScrollPosition = 0;
      var _loc2_ = 0;
      while(_loc2_ < this.EntriesA.length)
      {
         if(this.EntriesA[_loc2_].topicIndex == aiTopicIndex)
         {
            this.iScrollPosition = _loc2_;
            this.iSelectedIndex = _loc2_;
         }
         _loc2_ = _loc2_ + 1;
      }
      this.UpdateList();
   }
}
