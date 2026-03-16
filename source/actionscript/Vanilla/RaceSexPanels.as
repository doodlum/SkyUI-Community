class RaceSexPanels extends MovieClip
{
   var BackButton;
   var DoneButton;
   var Mode;
   var NAME_ENTRY;
   var NameEntryInstance;
   var PANEL_ONE;
   var PANEL_TWO_NARROW;
   var PANEL_TWO_WIDE;
   var PanelTwoNarrowInstance;
   var PanelTwoWideInstance;
   var PlayerName;
   var PlayerRace;
   var RaceDescriptionInstance;
   var _CategoriesList;
   var _SubList1;
   var _SubList2;
   var _TextEntryField;
   var bLimitedMenu;
   var bShowTextEntry;
   var iPlatform;
   var onEnterFrame;
   static var RACE_CATEGORY = 0;
   static var BODY_CATEGORY = 1;
   static var HEAD_CATEGORY = 2;
   static var UpdateInterval = -1;
   function RaceSexPanels()
   {
      super();
      Shared.GlobalFunc.MaintainTextFormat();
      Shared.GlobalFunc.SetLockFunction();
      this._CategoriesList = this._parent.CagetoryLockBaseInstance.CategoryInstance.List_mc;
      this._SubList1 = this.PanelTwoNarrowInstance.List_mc;
      this._SubList2 = this.PanelTwoWideInstance.List_mc;
      this._TextEntryField = this.NameEntryInstance;
      this.BackButton = _root.RaceSexMenuBaseInstance.BottomBarInstance.ButtonsInstance.BackInstance;
      this.BackButton._alpha = 0;
      this.DoneButton = _root.RaceSexMenuBaseInstance.BottomBarInstance.ButtonsInstance.XButtonInstance;
      this.PlayerName = _root.RaceSexMenuBaseInstance.BottomBarInstance.PlayerInfo_mc.PlayerName;
      this.PlayerName.textAutoSize = "shrink";
      this.PlayerRace = _root.RaceSexMenuBaseInstance.BottomBarInstance.PlayerInfo_mc.PlayerRace;
      this._TextEntryField._alpha = 0;
      this._TextEntryField._x = -2500;
      gfx.io.GameDelegate.addCallBack("SetCategoriesList",this,"SetCategoriesList");
      gfx.io.GameDelegate.addCallBack("ShowTextEntry",this,"ShowTextEntry");
      gfx.io.GameDelegate.addCallBack("SetNameText",this,"SetNameText");
      gfx.io.GameDelegate.addCallBack("SetRaceText",this,"SetRaceText");
      gfx.io.GameDelegate.addCallBack("SetRaceList",this,"SetRaceList");
      gfx.io.GameDelegate.addCallBack("SetOptionSliders",this,"SetSliders");
      gfx.io.GameDelegate.addCallBack("ShowTextEntryField",this,"ShowTextEntryField");
      gfx.io.GameDelegate.addCallBack("moveCategoriesUp",this,"moveCategoriesUp");
      gfx.io.GameDelegate.addCallBack("HideLoadingIcon",this,"HideLoadingIcon");
      gfx.io.GameDelegate.addCallBack("FadeOut",this,"FadeOut");
      gfx.events.EventDispatcher.initialize(this);
      gfx.managers.FocusHandler.instance.setFocus(this._CategoriesList,0);
      this.NAME_ENTRY = 0;
      this.gotoAndStop("1st stop on position");
      this.PANEL_ONE = this._currentframe;
      this.gotoAndStop("NarrowPanelIn");
      this.PANEL_TWO_NARROW = this._currentframe;
      this.gotoAndStop("WidePanelIn");
      this.PANEL_TWO_WIDE = this._currentframe;
      this.Mode = this.PANEL_TWO_NARROW;
      _root.RaceSexMenuBaseInstance.LoadingIconInstance._visible = false;
   }
   function InitExtensions()
   {
      _root.RaceSexMenuBaseInstance.RaceSexPanelsInstance.Lock("L");
      _root.RaceSexMenuBaseInstance.BottomBarInstance.Lock("B");
      _root.RaceSexMenuBaseInstance.BottomBarInstance.ButtonsInstance.Lock("L");
      _root.RaceSexMenuBaseInstance.BottomBarInstance.PlayerInfo_mc.Lock("R");
      _root.RaceSexMenuBaseInstance.CagetoryLockBaseInstance.Lock("T");
      this._TextEntryField.SetupButtons();
      this._TextEntryField.TextInputInstance.maxChars = 26;
   }
   static function CallCode(callBack, sliderValue, sliderID)
   {
      clearInterval(RaceSexPanels.UpdateInterval);
      RaceSexPanels.UpdateInterval = -1;
      gfx.io.GameDelegate.call(callBack,[sliderValue,sliderID]);
   }
   static function PrepForCallCode(callBack, sliderValue, sliderID)
   {
      clearInterval(RaceSexPanels.UpdateInterval);
      RaceSexPanels.UpdateInterval = -1;
      _root.RaceSexMenuBaseInstance.LoadingIconInstance._visible = true;
      RaceSexPanels.UpdateInterval = setInterval(RaceSexPanels.CallCode,30,callBack,sliderValue,sliderID);
   }
   function HideLoadingIcon()
   {
      _root.RaceSexMenuBaseInstance.LoadingIconInstance._visible = false;
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.iPlatform = aiPlatform;
      this._TextEntryField.SetPlatform(aiPlatform,abPS3Switch);
      _root.RaceSexMenuBaseInstance.BottomBarInstance.ButtonsInstance.XButtonInstance.SetPlatform(aiPlatform,abPS3Switch);
      _root.RaceSexMenuBaseInstance.BottomBarInstance.ButtonsInstance.BackInstance.SetPlatform(aiPlatform,abPS3Switch);
      _root.RaceSexMenuBaseInstance.CagetoryLockBaseInstance.CategoryInstance.ButtonHintRightInstance.SetPlatform(aiPlatform,abPS3Switch);
      _root.RaceSexMenuBaseInstance.CagetoryLockBaseInstance.CategoryInstance.ButtonHintRightInstance.label = "";
      _root.RaceSexMenuBaseInstance.CagetoryLockBaseInstance.CategoryInstance.ButtonHintLeftInstance.SetPlatform(aiPlatform,abPS3Switch);
      _root.RaceSexMenuBaseInstance.CagetoryLockBaseInstance.CategoryInstance.ButtonHintLeftInstance.label = "";
   }
   function ShowTextEntry(abShowTextEntry)
   {
      this.bShowTextEntry = abShowTextEntry;
   }
   function SetNameText(astrPlayerName)
   {
      this.PlayerName.SetText(astrPlayerName);
   }
   function SetRaceText(astrPlayerRace)
   {
      this.PlayerRace.SetText(astrPlayerRace);
   }
   function onLoad()
   {
      this._CategoriesList.addEventListener("listMovedUp",this,"onFiltersListMoveUp");
      this._CategoriesList.addEventListener("listMovedDown",this,"onFiltersListMoveDown");
      this._CategoriesList.addEventListener("itemPress",this,"onItemSelect");
      this._parent.LeftClickInstance.addEventListener("click",this,"moveCategoriesDown");
      this._parent.RightClickInstance.addEventListener("click",this,"moveCategoriesUp");
      this._SubList1.addEventListener("listMovedUp",this,"onNarrowListMoveUp");
      this._SubList1.addEventListener("listMovedDown",this,"onNarrowListMoveDown");
      this._SubList1.addEventListener("itemPress",this,"onRaceSelect");
      this._SubList2.addEventListener("listMovedUp",this,"onWideListMoveUp");
      this._SubList2.addEventListener("listMovedDown",this,"onWideListMoveDown");
      this._TextEntryField.addEventListener("nameChange",this,"onNameChange");
      this.DoneButton.addEventListener("click",this,"onDoneClicked");
   }
   function onDoneClicked()
   {
      gfx.io.GameDelegate.call("ConfirmDone",[]);
   }
   function SetCategoriesList()
   {
      var _loc9_ = 0;
      var _loc10_ = 1;
      var _loc8_ = 2;
      this._CategoriesList.entryList.splice(0,this._CategoriesList.entryList.length);
      var _loc3_ = 0;
      var _loc4_;
      while(_loc3_ < arguments.length)
      {
         _loc4_ = {text:arguments[_loc3_ + _loc9_],flag:arguments[_loc3_ + _loc10_],savedItemIndex:-1};
         this._CategoriesList.entryList.push(_loc4_);
         _loc3_ += _loc8_;
      }
      if(this.bLimitedMenu)
      {
         this._CategoriesList.selectedIndex = RaceSexPanels.BODY_CATEGORY;
      }
      this._CategoriesList.UpdateList();
   }
   function SetRaceList()
   {
      var _loc5_ = 0;
      var _loc6_ = 1;
      var _loc12_ = 2;
      var _loc7_ = 3;
      this._SubList1.entryList.splice(0,this._SubList1.entryList.length);
      var _loc3_ = 0;
      var _loc4_;
      while(_loc3_ < arguments.length)
      {
         _loc4_ = {text:arguments[_loc3_ + _loc5_],flag:(!this.bLimitedMenu ? RaceSexPanels.RACE_CATEGORY : RaceSexPanels.BODY_CATEGORY),raceDescription:(arguments[_loc3_ + _loc6_].length <= 0 ? "No race description for " + arguments[_loc3_ + _loc5_] : arguments[_loc3_ + _loc6_]),equipState:arguments[_loc3_ + _loc12_]};
         if(_loc4_.equipState > 0)
         {
            this._CategoriesList.entryList[_loc4_.flag].savedItemIndex = _loc3_ / _loc7_;
            this.SetRaceText(_loc4_.text);
         }
         this._SubList1.entryList.push(_loc4_);
         _loc3_ += _loc7_;
      }
      this._SubList1.UpdateList();
      if(this.bLimitedMenu)
      {
         this._CategoriesList.selectedIndex = RaceSexPanels.BODY_CATEGORY;
      }
      else
      {
         this._CategoriesList.selectedIndex = RaceSexPanels.RACE_CATEGORY;
      }
      this.ShowItemsList();
   }
   function SetSliders()
   {
      var _loc13_ = 0;
      var _loc21_ = 1;
      var _loc14_ = 2;
      var _loc16_ = 3;
      var _loc17_ = 4;
      var _loc18_ = 5;
      var _loc19_ = 6;
      var _loc20_ = 7;
      var _loc15_ = 8;
      this._SubList2.entryList.splice(0,this._SubList2.entryList.length);
      var _loc3_ = 0;
      var _loc4_;
      while(_loc3_ < arguments.length)
      {
         _loc4_ = {text:arguments[_loc3_ + _loc13_],filterFlag:arguments[_loc3_ + _loc21_],callbackName:arguments[_loc3_ + _loc14_],sliderMin:arguments[_loc3_ + _loc16_],sliderMax:arguments[_loc3_ + _loc17_],sliderID:arguments[_loc3_ + _loc20_],position:arguments[_loc3_ + _loc18_],interval:arguments[_loc3_ + _loc19_]};
         this._SubList2.entryList.push(_loc4_);
         _loc3_ += _loc15_;
      }
      this._SubList2.UpdateList();
   }
   function handleInput(details, pathToFocus)
   {
      var _loc3_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.ENTER && this.Mode == this.NAME_ENTRY)
         {
            this._TextEntryField.onAccept();
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.TAB && this.Mode == this.NAME_ENTRY)
         {
            this._TextEntryField.onCancel();
            gfx.io.GameDelegate.call("ChangeName",[]);
            _loc3_ = true;
            if(this._CategoriesList.selectedIndex == RaceSexPanels.RACE_CATEGORY)
            {
               gfx.managers.FocusHandler.instance.setFocus(this._SubList1,0);
            }
            else
            {
               gfx.managers.FocusHandler.instance.setFocus(this._SubList2,0);
            }
         }
         else if(this.iPlatform != 0)
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_R2 && RaceSexPanels.UpdateInterval == -1)
            {
               this.moveCategoriesUp();
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_L2 && RaceSexPanels.UpdateInterval == -1)
            {
               this.moveCategoriesDown();
            }
         }
      }
      if(!_loc3_ && (RaceSexPanels.UpdateInterval == -1 || this._CategoriesList.selectedIndex == RaceSexPanels.RACE_CATEGORY))
      {
         pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      return true;
   }
   function moveCategoriesUp()
   {
      var _loc0_;
      if((_loc0_ = this._CategoriesList.selectedIndex) !== RaceSexPanels.RACE_CATEGORY)
      {
         this._CategoriesList.selectedEntry.savedItemIndex = this._SubList2.selectedIndex;
      }
      else
      {
         this._CategoriesList.selectedEntry.savedItemIndex = this._SubList1.selectedIndex;
      }
      this._CategoriesList.moveListUp();
   }
   function moveCategoriesDown()
   {
      var _loc0_;
      if((_loc0_ = this._CategoriesList.selectedIndex) !== RaceSexPanels.RACE_CATEGORY)
      {
         this._CategoriesList.selectedEntry.savedItemIndex = this._SubList2.selectedIndex;
      }
      else
      {
         this._CategoriesList.selectedEntry.savedItemIndex = this._SubList1.selectedIndex;
      }
      if(this.bLimitedMenu != true || this._CategoriesList.selectedIndex > RaceSexPanels.BODY_CATEGORY)
      {
         this._CategoriesList.moveListDown();
      }
   }
   function onFiltersListMoveUp()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      this._CategoriesList._parent.gotoAndPlay("moveLeft");
      if(this._CategoriesList.selectedIndex == RaceSexPanels.HEAD_CATEGORY)
      {
         gfx.io.GameDelegate.call("ZoomPC",[true]);
      }
      else if(this._CategoriesList.selectedIndex == RaceSexPanels.BODY_CATEGORY)
      {
         gfx.io.GameDelegate.call("ZoomPC",[false]);
      }
      this.ShowItemsList();
   }
   function onFiltersListMoveDown(event)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      this._CategoriesList._parent.gotoAndPlay("moveRight");
      if(this._CategoriesList.selectedIndex == RaceSexPanels.BODY_CATEGORY)
      {
         gfx.io.GameDelegate.call("ZoomPC",[false]);
      }
      else if(this._CategoriesList.selectedIndex == RaceSexPanels.RACE_CATEGORY)
      {
         gfx.io.GameDelegate.call("ZoomPC",[true]);
      }
      this.ShowItemsList();
   }
   function ShowTextEntryField()
   {
      if(this.bShowTextEntry)
      {
         this._TextEntryField.TextInputInstance.text = "";
         this._TextEntryField.TextInputInstance.focused = true;
         this.FadeTextEntry(true);
         gfx.io.GameDelegate.call("SetAllowTextInput",[]);
      }
      else
      {
         gfx.io.GameDelegate.call("ShowVirtualKeyboard",[]);
      }
   }
   function onItemSelect(event)
   {
      if(this._currentframe == this.PANEL_ONE)
      {
         this.ShowItemsList();
      }
   }
   function onNarrowListMoveUp()
   {
      if(this._CategoriesList.selectedIndex == RaceSexPanels.RACE_CATEGORY)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
         this._SubList1._parent.gotoAndPlay("moveUp");
         this.RaceDescriptionInstance.RaceTextInstance.SetText(this._SubList1.entryList[this._SubList1.selectedIndex].raceDescription);
         if(RaceSexPanels.UpdateInterval >= 0)
         {
            clearInterval(RaceSexPanels.UpdateInterval);
            RaceSexPanels.UpdateInterval = -1;
            _root.RaceSexMenuBaseInstance.LoadingIconInstance._visible = false;
         }
         RaceSexPanels.UpdateInterval = setInterval(RaceSexPanels.PrepForCallCode,600,"ChangeRace",this._SubList1.selectedIndex,this._SubList1.entryList[this._SubList1.selectedIndex].sliderID);
      }
   }
   function onNarrowListMoveDown(event)
   {
      if(this._CategoriesList.selectedIndex == RaceSexPanels.RACE_CATEGORY)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
         this._SubList1._parent.gotoAndPlay("moveDown");
         this.RaceDescriptionInstance.RaceTextInstance.SetText(this._SubList1.entryList[this._SubList1.selectedIndex].raceDescription);
         if(RaceSexPanels.UpdateInterval >= 0)
         {
            clearInterval(RaceSexPanels.UpdateInterval);
            RaceSexPanels.UpdateInterval = -1;
            _root.RaceSexMenuBaseInstance.LoadingIconInstance._visible = false;
         }
         RaceSexPanels.UpdateInterval = setInterval(RaceSexPanels.PrepForCallCode,600,"ChangeRace",this._SubList1.selectedIndex,this._SubList1.entryList[this._SubList1.selectedIndex].sliderID);
      }
   }
   function onWideListMoveUp()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      if(RaceSexPanels.UpdateInterval >= 0)
      {
         this._SubList2._parent.gotoAndPlay("moveUp");
      }
   }
   function onWideListMoveDown(event)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      if(RaceSexPanels.UpdateInterval >= 0)
      {
         this._SubList2._parent.gotoAndPlay("moveDown");
      }
   }
   function onNameChange(event)
   {
      if(event.nameChanged == true)
      {
         gfx.io.GameDelegate.call("ChangeName",[this._TextEntryField.TextInputInstance.text]);
      }
      if(this._CategoriesList.selectedIndex == RaceSexPanels.RACE_CATEGORY)
      {
         gfx.managers.FocusHandler.instance.setFocus(this._SubList1,0);
      }
      else
      {
         gfx.managers.FocusHandler.instance.setFocus(this._SubList2,0);
      }
      this.FadeTextEntry(false);
   }
   function FadeTextEntry(bIn)
   {
      this.Mode = !bIn ? this.PANEL_ONE : this.NAME_ENTRY;
      if(bIn)
      {
         this._TextEntryField._x = 500;
      }
      this._TextEntryField.onEnterFrame = function()
      {
         this._alpha += !bIn ? -10 : 10;
         if(!bIn ? this._alpha <= 0 : this._alpha >= 100)
         {
            if(!bIn)
            {
               if(this._TextEntryField.TextInputInstance.text != undefined)
               {
                  gfx.io.GameDelegate.call("ChangeName",[this._TextEntryField.TextInputInstance.text]);
               }
               else
               {
                  gfx.io.GameDelegate.call("ChangeName",[]);
               }
            }
            delete this.onEnterFrame;
            if(!bIn)
            {
               this._x = -2500;
            }
         }
      };
   }
   function ShowItemsList()
   {
      var _loc0_;
      if((_loc0_ = this._CategoriesList.selectedIndex) !== RaceSexPanels.RACE_CATEGORY)
      {
         this.gotoAndPlay("widePanel2Show");
         this.FadeTextEntry(false);
         gfx.managers.FocusHandler.instance.setFocus(this._SubList2,0);
         this._SubList2.itemFilter = this._CategoriesList.selectedEntry.flag;
         this._SubList2.selectedIndex = this._CategoriesList.selectedEntry.savedItemIndex;
         this._SubList2.UpdateList();
      }
      else
      {
         this.gotoAndPlay("narrowPanel2Show");
         this.FadeTextEntry(false);
         gfx.managers.FocusHandler.instance.setFocus(this._SubList1,0);
         this._SubList1.selectedIndex = this._CategoriesList.selectedEntry.savedItemIndex;
         this._SubList1.UpdateList();
         this.RaceDescriptionInstance.RaceTextInstance.SetText(this._SubList1.entryList[this._SubList1.selectedIndex].raceDescription);
      }
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
   }
   function HideItemsList()
   {
      var _loc0_;
      if((_loc0_ = this._CategoriesList.selectedIndex) !== RaceSexPanels.RACE_CATEGORY)
      {
         this.gotoAndPlay("widePanel2Hide");
         gfx.managers.FocusHandler.instance.setFocus(this._CategoriesList,0);
         this._CategoriesList.selectedEntry.savedItemIndex = this._SubList2.selectedIndex;
         this.BackButton._alpha = 0;
      }
      else
      {
         this.gotoAndPlay("narrowPanel2Hide");
         gfx.managers.FocusHandler.instance.setFocus(this._CategoriesList,0);
         this._CategoriesList.selectedEntry.savedItemIndex = this._SubList1.selectedIndex;
      }
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
   }
   function FadeOut()
   {
      _root.gotoAndPlay(2);
   }
}
