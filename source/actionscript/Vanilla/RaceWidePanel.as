class RaceWidePanel extends FilteredList
{
   var EntriesA;
   var SelectedEntry;
   var callbackName;
   var dispatchEvent;
   var iSelectedIndex;
   var position;
   var sliderID;
   function RaceWidePanel()
   {
      super();
   }
   function handleInput(details, pathToFocus)
   {
      var _loc5_ = false;
      super.handleInput(details,pathToFocus);
      var _loc4_;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.LEFT || details.navEquivalent == gfx.ui.NavigationCode.RIGHT || details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R1 || details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_L1)
         {
            _loc4_ = false;
            if(details.navEquivalent == gfx.ui.NavigationCode.LEFT && this.SelectedEntry.SliderInstance.position != this.SelectedEntry.SliderInstance.minimum)
            {
               _loc4_ = true;
               this.SelectedEntry.SliderInstance.position -= this.EntriesA[this.iSelectedIndex].interval;
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT && this.SelectedEntry.SliderInstance.position != this.SelectedEntry.SliderInstance.maximum)
            {
               _loc4_ = true;
               this.SelectedEntry.SliderInstance.position += this.EntriesA[this.iSelectedIndex].interval;
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_L1 && this.SelectedEntry.SliderInstance.position != this.SelectedEntry.SliderInstance.minimum)
            {
               _loc4_ = true;
               this.SelectedEntry.SliderInstance.position -= this.EntriesA[this.iSelectedIndex].interval * 5;
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R1 && this.SelectedEntry.SliderInstance.position != this.SelectedEntry.SliderInstance.maximum)
            {
               _loc4_ = true;
               this.SelectedEntry.SliderInstance.position += this.EntriesA[this.iSelectedIndex].interval * 5;
            }
            if(_loc4_)
            {
               gfx.io.GameDelegate.call(this.EntriesA[this.iSelectedIndex].callbackName,[this.SelectedEntry.SliderInstance.position,this.EntriesA[this.iSelectedIndex].sliderID]);
               gfx.io.GameDelegate.call("PlaySound",["UIMenuPrevNext"]);
            }
            this.EntriesA[this.iSelectedIndex].position = this.SelectedEntry.SliderInstance.position;
            _loc5_ = true;
         }
      }
      return _loc5_;
   }
   function moveListUp()
   {
      var _loc2_ = this.GetNextFilterMatch(this.iSelectedIndex);
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
      if(_loc2_ != undefined)
      {
         this.iSelectedIndex = _loc2_;
         this.UpdateList();
         this.dispatchEvent({type:"listMovedDown"});
      }
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      if(aEntryObject.text != undefined)
      {
         aEntryClip.textField.SetText(aEntryObject.text);
         aEntryClip.SliderInstance._alpha = 100;
         aEntryClip.SliderInstance.minimum = aEntryObject.sliderMin;
         aEntryClip.SliderInstance.maximum = aEntryObject.sliderMax;
         aEntryClip.SliderInstance.position = aEntryObject.position;
         aEntryClip.SliderInstance.snapInterval = aEntryObject.interval;
         aEntryClip.SliderInstance.callbackName = aEntryObject.callbackName;
         aEntryClip.SliderInstance.sliderID = aEntryObject.sliderID;
         aEntryClip.SliderInstance.changedCallback = function()
         {
            gfx.io.GameDelegate.call(this.callbackName,[this.position,this.sliderID]);
            aEntryObject.position = this.position;
         };
         aEntryClip.SliderInstance.addEventListener("change",aEntryClip.SliderInstance,"changedCallback");
      }
      else
      {
         aEntryClip.textField.SetText(" ");
         aEntryClip.SliderInstance._alpha = 0;
      }
   }
   function onLoad()
   {
      Mouse.addListener(this);
   }
   function onPress()
   {
      var _loc2_ = Mouse.getTopMostEntity();
      if(_loc2_._parent.onPress)
      {
         _loc2_._parent.onPress();
      }
      gfx.managers.FocusHandler.instance.setFocus(this,0);
   }
   function onRelease()
   {
      var _loc2_ = Mouse.getTopMostEntity();
      if(_loc2_._parent.onRelease)
      {
         _loc2_._parent.onRelease();
      }
      gfx.managers.FocusHandler.instance.setFocus(this,0);
   }
}
