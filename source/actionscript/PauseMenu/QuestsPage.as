class QuestsPage extends MovieClip
{
   var BottomBar_mc;
   var DescriptionText;
   var Divider;
   var NoQuestsText;
   var ObjectiveList;
   var ObjectivesHeader;
   var QuestTitleText;
   var ShowOnMapButton;
   var TitleList;
   var TitleList_mc;
   var ToggleActiveButton;
   var bAllowShowOnMap;
   var bHasMiscQuests;
   var bUpdated;
   var iPlatform;
   var objectiveList;
   var objectivesHeader;
   var questDescriptionText;
   var questTitleEndpieces;
   var questTitleText;
   function QuestsPage()
   {
      super();
      this.TitleList = this.TitleList_mc.List_mc;
      this.DescriptionText = this.questDescriptionText;
      this.QuestTitleText = this.questTitleText;
      this.ObjectiveList = this.objectiveList;
      this.ObjectivesHeader = this.objectivesHeader;
      this.bHasMiscQuests = false;
      this.bUpdated = false;
   }
   function onLoad()
   {
      this.BottomBar_mc = this._parent._parent.BottomBar_mc;
      this.QuestTitleText.SetText(" ");
      this.DescriptionText.SetText(" ");
      this.DescriptionText.verticalAutoSize = "top";
      this.QuestTitleText.textAutoSize = "shrink";
      this.ObjectiveList.addEventListener("itemPress",this,"onObjectiveListSelect");
      this.ObjectiveList.addEventListener("selectionChange",this,"onObjectiveListHighlight");
   }
   function startPage()
   {
      if(!this.bUpdated)
      {
         gfx.io.GameDelegate.call("RequestQuestsData",[this.TitleList],this,"onQuestsDataComplete");
         this.ToggleActiveButton = this.BottomBar_mc.Buttons[0];
         this.ShowOnMapButton = this.BottomBar_mc.Buttons[1];
         this.bUpdated = true;
      }
      this.UpdateButtonsVisibility();
      this.TitleList.addEventListener("itemPress",this,"onTitleListSelect");
      this.TitleList.addEventListener("listMovedUp",this,"onTitleListMoveUp");
      this.TitleList.addEventListener("listMovedDown",this,"onTitleListMoveDown");
      this.TitleList.addEventListener("selectionChange",this,"onTitleListMouseSelectionChange");
      this.SwitchFocusToTitles();
      this.BottomBar_mc.addEventListener("OnBottomBarButtonMousePress",Shared.Proxy.create(this,this.OnBottomBarButtonMousePress));
   }
   function endPage()
   {
      this.TitleList.removeEventListener("itemPress",this,"onTitleListSelect");
      this.TitleList.removeEventListener("listMovedUp",this,"onTitleListMoveUp");
      this.TitleList.removeEventListener("listMovedDown",this,"onTitleListMoveDown");
      this.TitleList.removeEventListener("selectionChange",this,"onTitleListMouseSelectionChange");
      this.BottomBar_mc.removeAllEventListeners();
   }
   function get selectedQuestID()
   {
      return this.TitleList.entryList.length <= 0 ? undefined : this.TitleList.centeredEntry.formID;
   }
   function get selectedQuestInstance()
   {
      return this.TitleList.entryList.length <= 0 ? undefined : this.TitleList.centeredEntry.instance;
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 77) && this.bAllowShowOnMap)
         {
            this.onShowOnMap();
            _loc2_ = true;
         }
         else if(this.TitleList.entryList.length > 0)
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.LEFT && gfx.managers.FocusHandler.instance.getFocus(0) != this.TitleList)
            {
               this.SwitchFocusToTitles();
               _loc2_ = true;
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT && gfx.managers.FocusHandler.instance.getFocus(0) != this.ObjectiveList)
            {
               this.SwitchFocusToObjectives();
               _loc2_ = true;
            }
         }
      }
      if(!_loc2_ && pathToFocus != undefined && pathToFocus.length > 0)
      {
         _loc2_ = pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      return _loc2_;
   }
   function OnBottomBarButtonMousePress(evt)
   {
      var _loc2_ = evt.target;
      switch(evt.data)
      {
         case 0:
            if(_loc2_.label == "$Toggle Active")
            {
               this.onTitleListSelect();
            }
            break;
         case 1:
            if(_loc2_.label == "$Show on Map")
            {
               this.onShowOnMap();
            }
         default:
            return;
      }
   }
   function IsViewingMiscObjectives()
   {
      return this.bHasMiscQuests && this.TitleList.selectedEntry.formID == 0;
   }
   function onTitleListSelect()
   {
      if(this.TitleList.selectedEntry != undefined && !this.TitleList.selectedEntry.completed)
      {
         if(!this.IsViewingMiscObjectives())
         {
            gfx.io.GameDelegate.call("ToggleQuestActiveStatus",[this.TitleList.selectedEntry.formID,this.TitleList.selectedEntry.instance],this,"ToggleQuestActiveCallback");
         }
         else
         {
            this.TitleList.selectedEntry.active = !this.TitleList.selectedEntry.active;
            gfx.io.GameDelegate.call("ToggleShowMiscObjectives",[this.TitleList.selectedEntry.active]);
            this.TitleList.UpdateList();
         }
      }
   }
   function onObjectiveListSelect()
   {
      if(this.IsViewingMiscObjectives())
      {
         gfx.io.GameDelegate.call("ToggleQuestActiveStatus",[this.ObjectiveList.selectedEntry.formID,this.ObjectiveList.selectedEntry.instance],this,"ToggleQuestActiveCallback");
      }
   }
   function SwitchFocusToTitles()
   {
      gfx.managers.FocusHandler.instance.setFocus(this.TitleList,0);
      this.Divider.gotoAndStop("Right");
      this.ToggleActiveButton._alpha = 100;
      this.ObjectiveList.selectedIndex = -1;
      if(this.iPlatform != 0)
      {
         this.ObjectiveList.disableSelection = true;
      }
      this.UpdateShowOnMapButtonAlpha(0);
   }
   function SwitchFocusToObjectives()
   {
      gfx.managers.FocusHandler.instance.setFocus(this.ObjectiveList,0);
      this.Divider.gotoAndStop("Left");
      this.ToggleActiveButton._alpha = !this.IsViewingMiscObjectives() ? 50 : 100;
      if(this.iPlatform != 0)
      {
         this.ObjectiveList.disableSelection = false;
      }
      this.ObjectiveList.selectedIndex = 0;
      this.UpdateShowOnMapButtonAlpha(0);
   }
   function onObjectiveListHighlight(event)
   {
      this.UpdateShowOnMapButtonAlpha(event.index);
   }
   function UpdateShowOnMapButtonAlpha(aiObjIndex)
   {
      var _loc2_ = 50;
      if(aiObjIndex >= 0 && this.ObjectiveList.entryList[aiObjIndex].questTargetID != undefined || this.ObjectiveList.entryList.length > 0 && this.ObjectiveList.entryList[0].questTargetID != undefined)
      {
         _loc2_ = 100;
      }
      this.ShowOnMapButton._alpha = _loc2_;
   }
   function ToggleQuestActiveCallback(abNewActiveStatus)
   {
      var _loc3_;
      var _loc2_;
      if(this.IsViewingMiscObjectives())
      {
         _loc3_ = this.ObjectiveList.selectedEntry.formID;
         _loc2_ = this.ObjectiveList.selectedEntry.instance;
         for(var _loc5_ in this.ObjectiveList.entryList)
         {
            if(this.ObjectiveList.entryList[_loc5_].formID == _loc3_ && this.ObjectiveList.entryList[_loc5_].instance == _loc2_)
            {
               this.ObjectiveList.entryList[_loc5_].active = abNewActiveStatus;
            }
         }
         this.ObjectiveList.UpdateList();
      }
      else
      {
         this.TitleList.selectedEntry.active = abNewActiveStatus;
         this.TitleList.UpdateList();
      }
      if(abNewActiveStatus)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIQuestActive"]);
      }
      else
      {
         gfx.io.GameDelegate.call("PlaySound",["UIQuestInactive"]);
      }
   }
   function onQuestsDataComplete(auiSavedFormID, auiSavedInstance, abAddMiscQuest, abMiscQuestActive, abAllowShowOnMap)
   {
      this.bAllowShowOnMap = abAllowShowOnMap;
      if(abAddMiscQuest)
      {
         this.TitleList.entryList.push({text:"$MISCELLANEOUS",formID:0,instance:0,active:abMiscQuestActive,completed:false,type:0});
         this.bHasMiscQuests = true;
      }
      var _loc3_;
      var _loc5_ = false;
      var _loc6_ = false;
      var _loc2_ = 0;
      while(_loc2_ < this.TitleList.entryList.length)
      {
         if(this.TitleList.entryList[_loc2_].formID == 0)
         {
            this.TitleList.entryList[_loc2_].timeIndex = 1.7976931348623157e+308;
         }
         else
         {
            this.TitleList.entryList[_loc2_].timeIndex = _loc2_;
         }
         if(this.TitleList.entryList[_loc2_].completed)
         {
            if(_loc3_ == undefined)
            {
               _loc3_ = this.TitleList.entryList[_loc2_].timeIndex - 0.5;
            }
            _loc5_ = true;
         }
         else
         {
            _loc6_ = true;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(_loc3_ != undefined && _loc5_ && _loc6_)
      {
         this.TitleList.entryList.push({divider:true,completed:true,timeIndex:_loc3_});
      }
      this.TitleList.entryList.sort(this.completedQuestSort);
      var _loc4_ = 0;
      _loc2_ = 0;
      while(_loc2_ < this.TitleList.entryList.length)
      {
         if(this.TitleList.entryList[_loc2_].text != undefined)
         {
            this.TitleList.entryList[_loc2_].text = this.TitleList.entryList[_loc2_].text.toUpperCase();
         }
         if(this.TitleList.entryList[_loc2_].formID == auiSavedFormID && this.TitleList.entryList[_loc2_].instance == auiSavedInstance)
         {
            _loc4_ = _loc2_;
         }
         _loc2_ = _loc2_ + 1;
      }
      this.TitleList.InvalidateData();
      this.TitleList.RestoreScrollPosition(_loc4_,true);
      this.TitleList.UpdateList();
      this.onQuestHighlight();
   }
   function completedQuestSort(aObj1, aObj2)
   {
      if(!aObj1.completed && aObj2.completed)
      {
         return -1;
      }
      if(aObj1.completed && !aObj2.completed)
      {
         return 1;
      }
      if(aObj1.timeIndex < aObj2.timeIndex)
      {
         return -1;
      }
      if(aObj1.timeIndex > aObj2.timeIndex)
      {
         return 1;
      }
      return 0;
   }
   function onQuestHighlight()
   {
      var _loc2_;
      if(this.TitleList.entryList.length > 0)
      {
         _loc2_ = ["Misc","Main","MagesGuild","ThievesGuild","DarkBrotherhood","Companion","Favor","Daedric","Misc","CivilWar","DLC01","DLC02"];
         this.QuestTitleText.SetText(this.TitleList.selectedEntry.text);
         if(this.TitleList.selectedEntry.objectives == undefined)
         {
            gfx.io.GameDelegate.call("RequestObjectivesData",[]);
         }
         this.ObjectiveList.entryList = this.TitleList.selectedEntry.objectives;
         this.SetDescriptionText();
         this.questTitleEndpieces.gotoAndStop(_loc2_[this.TitleList.selectedEntry.type]);
         this.questTitleEndpieces._visible = true;
         this.ObjectivesHeader._visible = !this.IsViewingMiscObjectives();
         this.ObjectiveList.selectedIndex = -1;
         this.ObjectiveList.scrollPosition = 0;
         if(this.iPlatform != 0)
         {
            this.ObjectiveList.disableSelection = true;
         }
         this.UpdateShowOnMapButtonAlpha(0);
      }
      else
      {
         this.NoQuestsText.SetText("No Active Quests");
         this.DescriptionText.SetText(" ");
         this.QuestTitleText.SetText(" ");
         this.ObjectiveList.ClearList();
         this.questTitleEndpieces._visible = false;
         this.ObjectivesHeader._visible = false;
      }
      this.UpdateButtonsVisibility();
      this.ObjectiveList.InvalidateData();
   }
   function UpdateButtonsVisibility()
   {
      var _loc2_ = this.TitleList.entryList.length > 0 && this.TitleList.selectedEntry != null;
      this.ToggleActiveButton._visible = _loc2_ && !this.TitleList.selectedEntry.completed;
      this.ShowOnMapButton._visible = _loc2_ && !this.TitleList.selectedEntry.completed && this.bAllowShowOnMap;
   }
   function SetDescriptionText()
   {
      var _loc2_ = 25;
      var _loc5_ = 10;
      var _loc3_ = 470;
      var _loc4_ = 40;
      this.DescriptionText.SetText(this.TitleList.selectedEntry.description);
      var _loc6_ = this.DescriptionText.getCharBoundaries(this.DescriptionText.getLineOffset(this.DescriptionText.numLines - 1));
      this.ObjectivesHeader._y = this.DescriptionText._y + _loc6_.bottom + _loc2_;
      if(this.IsViewingMiscObjectives())
      {
         this.ObjectiveList._y = this.DescriptionText._y;
      }
      else
      {
         this.ObjectiveList._y = this.ObjectivesHeader._y + this.ObjectivesHeader._height + _loc5_;
      }
      this.ObjectiveList.border._height = Math.max(_loc3_ - this.ObjectiveList._y,_loc4_);
      this.ObjectiveList.scrollbar.height = this.ObjectiveList.border._height - 20;
   }
   function onTitleListMoveUp(event)
   {
      this.onQuestHighlight();
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      if(event.scrollChanged == true)
      {
         this.TitleList._parent.gotoAndPlay("moveUp");
      }
   }
   function onTitleListMoveDown(event)
   {
      this.onQuestHighlight();
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      if(event.scrollChanged == true)
      {
         this.TitleList._parent.gotoAndPlay("moveDown");
      }
   }
   function onTitleListMouseSelectionChange(event)
   {
      if(event.keyboardOrMouse == 0 && event.index != -1)
      {
         this.onQuestHighlight();
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      }
   }
   function onRightStickInput(afX, afY)
   {
      if(afY < 0)
      {
         this.ObjectiveList.moveSelectionDown();
      }
      else
      {
         this.ObjectiveList.moveSelectionUp();
      }
   }
   function onShowOnMap()
   {
      var _loc2_;
      if(this.ObjectiveList.selectedEntry != undefined && this.ObjectiveList.selectedEntry.questTargetID != undefined)
      {
         _loc2_ = this.ObjectiveList.selectedEntry;
      }
      else
      {
         _loc2_ = this.ObjectiveList.entryList[0];
      }
      if(_loc2_ != undefined && _loc2_.questTargetID != undefined)
      {
         this._parent._parent.CloseMenu();
         gfx.io.GameDelegate.call("ShowTargetOnMap",[_loc2_.questTargetID]);
      }
      else
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
      }
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.iPlatform = aiPlatform;
      this.TitleList.SetPlatform(aiPlatform,abPS3Switch);
      this.ObjectiveList.SetPlatform(aiPlatform,abPS3Switch);
   }
}
