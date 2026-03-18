class Shared.CenteredList extends MovieClip
{
   var BottomHalf;
   var EntriesA;
   var SelectedEntry;
   var TopHalf;
   var bMultilineList;
   var bRepositionEntries;
   var bToFitList;
   var dispatchEvent;
   var fCenterY;
   var iMaxEntriesBottomHalf;
   var iMaxEntriesTopHalf;
   var iSelectedIndex;
   function CenteredList()
   {
      super();
      this.TopHalf = this.TopHalf;
      this.SelectedEntry = this.SelectedEntry;
      this.BottomHalf = this.BottomHalf;
      this.EntriesA = new Array();
      gfx.events.EventDispatcher.initialize(this);
      Mouse.addListener(this);
      this.iSelectedIndex = 0;
      this.fCenterY = this.SelectedEntry._y + this.SelectedEntry._height / 2;
      this.bRepositionEntries = true;
      this.iMaxEntriesTopHalf = 0;
      while(this.TopHalf["Entry" + this.iMaxEntriesTopHalf] != undefined)
      {
         this.iMaxEntriesTopHalf = this.iMaxEntriesTopHalf + 1;
      }
      this.iMaxEntriesBottomHalf = 0;
      while(this.BottomHalf["Entry" + this.iMaxEntriesBottomHalf] != undefined)
      {
         this.iMaxEntriesBottomHalf = this.iMaxEntriesBottomHalf + 1;
      }
   }
   function ClearList()
   {
      this.EntriesA.splice(0,this.EntriesA.length);
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.UP)
         {
            this.moveListDown();
            _loc2_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.DOWN)
         {
            this.moveListUp();
            _loc2_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.ENTER && this.iSelectedIndex != -1)
         {
            this.dispatchEvent({type:"itemPress",index:this.iSelectedIndex,entry:this.EntriesA[this.iSelectedIndex]});
            _loc2_ = true;
         }
      }
      return _loc2_;
   }
   function onMouseWheel(delta)
   {
      var _loc2_ = Mouse.getTopMostEntity();
      while(_loc2_ && _loc2_ != undefined && gfx.managers.FocusHandler.instance.getFocus(0) == this)
      {
         if(_loc2_ == this)
         {
            if(delta < 0)
            {
               this.moveListUp();
            }
            else if(delta > 0)
            {
               this.moveListDown();
            }
         }
         _loc2_ = _loc2_._parent;
      }
   }
   function onPress(aiMouseIndex, aiKeyboardOrMouse)
   {
      var _loc2_ = Mouse.getTopMostEntity();
      while(_loc2_ && _loc2_ != undefined)
      {
         if(_loc2_ == this.SelectedEntry)
         {
            this.dispatchEvent({type:"itemPress",index:this.iSelectedIndex,entry:this.EntriesA[this.iSelectedIndex],keyboardOrMouse:aiKeyboardOrMouse});
         }
         _loc2_ = _loc2_._parent;
      }
   }
   function onPressAux(aiMouseIndex, aiKeyboardOrMouse, aiButtonIndex)
   {
      var _loc2_;
      if(aiButtonIndex == 1)
      {
         _loc2_ = Mouse.getTopMostEntity();
         while(_loc2_ && _loc2_ != undefined)
         {
            if(_loc2_ == this.SelectedEntry)
            {
               this.dispatchEvent({type:"itemPressAux",index:this.iSelectedIndex,entry:this.EntriesA[this.iSelectedIndex],keyboardOrMouse:aiKeyboardOrMouse});
            }
            _loc2_ = _loc2_._parent;
         }
      }
   }
   function get selectedTextString()
   {
      return this.EntriesA[this.iSelectedIndex].text;
   }
   function get selectedIndex()
   {
      return this.iSelectedIndex;
   }
   function set selectedIndex(aiNewIndex)
   {
      this.iSelectedIndex = aiNewIndex;
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
   function moveListUp()
   {
      if(this.iSelectedIndex < this.EntriesA.length - 1)
      {
         this.iSelectedIndex = this.iSelectedIndex + 1;
         this.UpdateList();
         this.dispatchEvent({type:"listMovedUp"});
      }
   }
   function moveListDown()
   {
      if(this.iSelectedIndex > 0)
      {
         this.iSelectedIndex = this.iSelectedIndex - 1;
         this.UpdateList();
         this.dispatchEvent({type:"listMovedDown"});
      }
   }
   function UpdateList()
   {
      var _loc2_;
      this.iSelectedIndex = Math.min(Math.max(this.iSelectedIndex,0),this.EntriesA.length - 1);
      if(this.iSelectedIndex > 0)
      {
         this.UpdateTopHalf(this.EntriesA.slice(0,this.iSelectedIndex));
      }
      else
      {
         this.UpdateTopHalf(_loc2_);
      }
      this.SetEntry(this.SelectedEntry,this.EntriesA[this.iSelectedIndex]);
      if(this.iSelectedIndex < this.EntriesA.length - 1)
      {
         this.UpdateBottomHalf(this.EntriesA.slice(this.iSelectedIndex + 1));
      }
      else
      {
         this.UpdateBottomHalf(_loc2_);
      }
      this.RepositionEntries();
   }
   function UpdateTopHalf(aEntryArray)
   {
      var _loc2_ = this.iMaxEntriesTopHalf - 1;
      var _loc3_;
      while(_loc2_ >= 0)
      {
         _loc3_ = _loc2_ - (this.iMaxEntriesTopHalf - aEntryArray.length);
         if(_loc3_ >= 0 && _loc3_ < aEntryArray.length)
         {
            this.SetEntry(this.TopHalf["Entry" + _loc2_],aEntryArray[_loc3_]);
         }
         else
         {
            this.SetEntry(this.TopHalf["Entry" + _loc2_]);
         }
         _loc2_ = _loc2_ - 1;
      }
   }
   function UpdateBottomHalf(aTextArray)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.iMaxEntriesBottomHalf)
      {
         if(_loc2_ < aTextArray.length)
         {
            this.SetEntry(this.BottomHalf["Entry" + _loc2_],aTextArray[_loc2_]);
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
      if(this.bMultilineList == true)
      {
         aEntryClip.textField.verticalAutoSize = "top";
      }
      if(this.bToFitList == true)
      {
         aEntryClip.textField.textAutoSize = "shrink";
      }
      if(aEntryObject.text != undefined)
      {
         if(aEntryObject.count > 1)
         {
            aEntryClip.textField.SetText(aEntryObject.text + " (" + aEntryObject.count + ")");
         }
         else
         {
            aEntryClip.textField.SetText(aEntryObject.text);
         }
      }
      else
      {
         aEntryClip.textField.SetText(" ");
      }
   }
   function SetupMultilineList()
   {
      this.bMultilineList = true;
      var _loc2_ = 0;
      while(_loc2_ < this.iMaxEntriesTopHalf)
      {
         this.TopHalf["Entry" + _loc2_].textField.verticalAutoSize = "top";
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < this.iMaxEntriesBottomHalf)
      {
         this.BottomHalf["Entry" + _loc2_].textField.verticalAutoSize = "top";
         _loc2_ = _loc2_ + 1;
      }
      if(this.SelectedEntry != undefined)
      {
         this.SelectedEntry.textField.verticalAutoSize = "top";
      }
   }
   function SetupToFitList()
   {
      this.bToFitList = true;
      var _loc2_ = 0;
      while(_loc2_ < this.iMaxEntriesTopHalf)
      {
         this.TopHalf["Entry" + _loc2_].textField.textAutoSize = "shrink";
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < this.iMaxEntriesBottomHalf)
      {
         this.BottomHalf["Entry" + _loc2_].textField.textAutoSize = "shrink";
         _loc2_ = _loc2_ + 1;
      }
      if(this.SelectedEntry != undefined)
      {
         this.SelectedEntry.textField.textAutoSize = "shrink";
      }
   }
   function RepositionEntries()
   {
      var _loc3_;
      var _loc2_;
      if(this.bRepositionEntries)
      {
         _loc3_ = 0;
         _loc2_ = 0;
         while(_loc2_ < this.iMaxEntriesTopHalf)
         {
            this.TopHalf["Entry" + _loc2_]._y = _loc3_;
            _loc3_ += this.TopHalf["Entry" + _loc2_]._height;
            _loc2_ = _loc2_ + 1;
         }
         _loc3_ = 0;
         _loc2_ = 0;
         while(_loc2_ < this.iMaxEntriesBottomHalf)
         {
            this.BottomHalf["Entry" + _loc2_]._y = _loc3_;
            _loc3_ += this.BottomHalf["Entry" + _loc2_]._height;
            _loc2_ = _loc2_ + 1;
         }
         this.SelectedEntry._y = this.fCenterY - this.SelectedEntry._height / 2;
         this.TopHalf._y = this.SelectedEntry._y - this.TopHalf._height;
         this.BottomHalf._y = this.SelectedEntry._y + this.SelectedEntry._height;
      }
   }
}
