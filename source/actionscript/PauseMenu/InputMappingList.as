class InputMappingList extends Shared.BSScrollingList
{
   var EntriesA;
   var GetClipByIndex;
   var iPlatform;
   var selectedEntry;
   static var CONTROLLER_PROSPERO = 5;
   function InputMappingList()
   {
      super();
   }
   function GetEntryHeight(aiEntryIndex)
   {
      var _loc2_ = this.GetClipByIndex(0);
      return _loc2_._height;
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      aEntryClip.textField.textAutoSize = "shrink";
      aEntryClip.textField.SetText("$" + aEntryObject.text);
      aEntryClip.textField._alpha = aEntryObject != this.selectedEntry ? 30 : 100;
      if(aEntryClip.ButtonArt != undefined)
      {
         aEntryClip.ButtonArt.removeMovieClip();
      }
      var _loc2_ = aEntryObject.buttonName;
      var _loc7_ = _loc2_;
      if(this.iPlatform == InputMappingList.CONTROLLER_PROSPERO)
      {
         if(_loc2_ == "PS3_A")
         {
            _loc2_ = "PS5_A";
         }
         else if(_loc2_ == "PS3_B")
         {
            _loc2_ = "PS5_B";
         }
         else if(_loc2_ == "PS3_X")
         {
            _loc2_ = "PS5_X";
         }
         else if(_loc2_ == "PS3_Y")
         {
            _loc2_ = "PS5_Y";
         }
         else if(_loc2_ == "PS3_LT")
         {
            _loc2_ = "PS5_LT";
         }
         else if(_loc2_ == "PS3_RT")
         {
            _loc2_ = "PS5_RT";
         }
         else if(_loc2_ == "PS3_LB")
         {
            _loc2_ = "PS5_LB";
         }
         else if(_loc2_ == "PS3_RB")
         {
            _loc2_ = "PS5_RB";
         }
         else if(_loc2_ == "PS3_LTRT")
         {
            _loc2_ = "PS5_LTRT";
         }
         else if(_loc2_ == "PS3_LS")
         {
            _loc2_ = "PS5_LS";
         }
         else if(_loc2_ == "PS3_RS")
         {
            _loc2_ = "PS5_RS";
         }
         else if(_loc2_ == "PS3_L3")
         {
            _loc2_ = "PS5_L3";
         }
         else if(_loc2_ == "PS3_R3")
         {
            _loc2_ = "PS5_R3";
         }
         else if(_loc2_ == "PS3_Back")
         {
            _loc2_ = "PS5_Back";
         }
         else if(_loc2_ == "PS3_Start")
         {
            _loc2_ = "PS5_Start";
         }
      }
      var _loc3_ = aEntryClip.attachMovie(_loc2_,"ButtonArt",aEntryClip.getNextHighestDepth());
      if(this.iPlatform == InputMappingList.CONTROLLER_PROSPERO)
      {
         if(_loc3_ == undefined)
         {
            trace("PS5 Button not found [" + String(_loc2_) + "] Will ReAttach");
            _loc3_ = aEntryClip.attachMovie(_loc7_,"ButtonArt",aEntryClip.getNextHighestDepth());
            if(_loc3_ != undefined)
            {
               trace("ReAttached");
            }
            else
            {
               trace("Failed to attach!");
            }
         }
      }
      var _loc5_ = aEntryClip.buttonPlacing;
      if(_loc3_ == undefined)
      {
         _loc3_ = aEntryClip.attachMovie("UnknownKey","ButtonArt",aEntryClip.getNextHighestDepth());
         if(aEntryObject.buttonID != undefined)
         {
            _loc3_.textField.SetText(this.GetHexString(aEntryObject.buttonID));
         }
         else
         {
            _loc3_.textField.SetText("???");
         }
         _loc5_ = aEntryClip.buttonPlacing;
      }
      var _loc8_;
      if(_loc3_ != undefined)
      {
         _loc8_ = _loc3_._width / _loc3_._height;
         _loc3_._height = _loc5_._height;
         _loc3_._width = _loc8_ * _loc5_._height;
         _loc3_._y = _loc5_._y;
         _loc3_._x = _loc5_._x + (_loc5_._width - _loc3_._width) / 2;
         _loc3_._alpha = aEntryObject != this.selectedEntry ? 30 : 100;
         _loc5_._visible = false;
      }
      else
      {
         _loc5_._visible = true;
      }
   }
   function GetHexString(aiNumber)
   {
      var _loc3_ = "";
      var _loc1_ = aiNumber;
      var _loc4_ = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"];
      var _loc2_;
      while(_loc1_ > 0)
      {
         _loc2_ = _loc1_ % 16;
         _loc3_ = _loc4_[_loc2_] + _loc3_;
         _loc1_ = Math.floor(_loc1_ / 16);
      }
      _loc3_ = "0x" + _loc3_;
      return _loc3_;
   }
   function FindEntryButtonName(findLabel)
   {
      trace("InputMappingList::FindEntryButtonName find " + findLabel);
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < this.EntriesA.length)
      {
         _loc3_ = this.EntriesA[_loc2_];
         if(_loc3_.text == findLabel)
         {
            return _loc3_.buttonName;
         }
         trace("InputMappingList::FindEntryButtonName skipped " + _loc3_.text);
         _loc2_ = _loc2_ + 1;
      }
      return "";
   }
}
