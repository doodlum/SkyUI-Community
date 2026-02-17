class QuestsPage extends MovieClip
{
   var DescriptionText;
   var Divider;
   var NoQuestsText;
   var ObjectiveList;
   var ObjectivesHeader;
   var QuestTitleText;
   var TitleList;
   var TitleList_mc;
   var _bottomBar;
   var _deleteControls;
   var _showOnMapButton;
   var _showOnMapControls;
   var _toggleActiveButton;
   var _toggleActiveControls;
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
      this._bottomBar = this._parent._parent.BottomBar_mc;
   }
   function onLoad()
   {
      this.QuestTitleText.SetText(" ");
      this.DescriptionText.SetText(" ");
      this.DescriptionText.verticalAutoSize = "top";
      this.QuestTitleText.textAutoSize = "shrink";
      this.TitleList.addEventListener("itemPress",this,"onTitleListSelect");
      this.TitleList.addEventListener("listMovedUp",this,"onTitleListMoveUp");
      this.TitleList.addEventListener("listMovedDown",this,"onTitleListMoveDown");
      this.TitleList.addEventListener("selectionChange",this,"onTitleListMouseSelectionChange");
      this.TitleList.disableInput = true;
      this.ObjectiveList.addEventListener("itemPress",this,"onObjectiveListSelect");
      this.ObjectiveList.addEventListener("selectionChange",this,"onObjectiveListHighlight");
   }
   function startPage()
   {
      this.TitleList.disableInput = false;
      if(!this.bUpdated)
      {
         gfx.io.GameDelegate.call("RequestQuestsData",[this.TitleList],this,"onQuestsDataComplete");
         this.bUpdated = true;
      }
      this._bottomBar.buttonPanel.clearButtons();
      this._toggleActiveButton = this._bottomBar.buttonPanel.addButton({text:"$Toggle Active",controls:this._toggleActiveControls});
      if(this.bAllowShowOnMap)
      {
         this._showOnMapButton = this._bottomBar.buttonPanel.addButton({text:"$Show on Map",controls:this._showOnMapControls});
      }
      this._bottomBar.buttonPanel.updateButtons(true);
      this.switchFocusToTitles();
   }
   function endPage()
   {
      this._showOnMapButton._alpha = 100;
      this._toggleActiveButton._alpha = 100;
      this._bottomBar.buttonPanel.clearButtons();
      this.TitleList.disableInput = true;
   }
   function get selectedQuestID()
   {
      return this.TitleList.entryList.length > 0 ? this.TitleList.centeredEntry.formID : undefined;
   }
   function get selectedQuestInstance()
   {
      return this.TitleList.entryList.length > 0 ? this.TitleList.centeredEntry.instance : undefined;
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if((details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_X || details.code == 77) && this.bAllowShowOnMap)
         {
            this.onShowMap();
            _loc2_ = true;
         }
         else if(this.TitleList.entryList.length > 0)
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.LEFT && gfx.managers.FocusHandler.instance.getFocus(0) != this.TitleList)
            {
               this.switchFocusToTitles();
               _loc2_ = true;
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT && gfx.managers.FocusHandler.instance.getFocus(0) != this.ObjectiveList)
            {
               this.switchFocusToObjectives();
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
   function onShowMap()
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
   function isViewingMiscObjectives()
   {
      return this.bHasMiscQuests && this.TitleList.selectedEntry.formID == 0;
   }
   function onTitleListSelect()
   {
      if(this.TitleList.selectedEntry != undefined && !this.TitleList.selectedEntry.completed)
      {
         if(!this.isViewingMiscObjectives())
         {
            gfx.io.GameDelegate.call("ToggleQuestActiveStatus",[this.TitleList.selectedEntry.formID,this.TitleList.selectedEntry.instance],this,"onToggleQuestActive");
            return undefined;
         }
         this.TitleList.selectedEntry.active = !this.TitleList.selectedEntry.active;
         gfx.io.GameDelegate.call("ToggleShowMiscObjectives",[this.TitleList.selectedEntry.active]);
         this.TitleList.UpdateList();
      }
   }
   function onObjectiveListSelect()
   {
      if(this.isViewingMiscObjectives())
      {
         gfx.io.GameDelegate.call("ToggleQuestActiveStatus",[this.ObjectiveList.selectedEntry.formID,this.ObjectiveList.selectedEntry.instance],this,"onToggleQuestActive");
      }
   }
   function switchFocusToTitles()
   {
      gfx.managers.FocusHandler.instance.setFocus(this.TitleList,0);
      this.Divider.gotoAndStop("Right");
      this._toggleActiveButton._alpha = 100;
      this.ObjectiveList.selectedIndex = -1;
      if(this.iPlatform != 0)
      {
         this.ObjectiveList.disableSelection = true;
      }
      this.updateShowOnMapButtonAlpha(0);
   }
   function switchFocusToObjectives()
   {
      gfx.managers.FocusHandler.instance.setFocus(this.ObjectiveList,0);
      this.Divider.gotoAndStop("Left");
      this._toggleActiveButton._alpha = !this.isViewingMiscObjectives() ? 50 : 100;
      if(this.iPlatform != 0)
      {
         this.ObjectiveList.disableSelection = false;
      }
      this.ObjectiveList.selectedIndex = 0;
      this.updateShowOnMapButtonAlpha(0);
   }
   function onObjectiveListHighlight(event)
   {
      this.updateShowOnMapButtonAlpha(event.index);
   }
   function updateShowOnMapButtonAlpha(a_entryIdx)
   {
      var _loc2_ = 50;
      if(this.bAllowShowOnMap && (a_entryIdx >= 0 && this.ObjectiveList.entryList[a_entryIdx].questTargetID != undefined) || this.ObjectiveList.entryList.length > 0 && this.ObjectiveList.entryList[0].questTargetID != undefined)
      {
         _loc2_ = 100;
      }
      this._toggleActiveButton._alpha = this.TitleList.selectedEntry.completed ? 50 : 100;
      this._showOnMapButton._alpha = _loc2_;
   }
   function onToggleQuestActive(a_bnewActiveStatus)
   {
      var _loc2_;
      var _loc4_;
      if(this.isViewingMiscObjectives())
      {
         _loc2_ = this.ObjectiveList.selectedEntry.formID;
         _loc4_ = this.ObjectiveList.selectedEntry.instance;
         for(var _loc5_ in this.ObjectiveList.entryList)
         {
            if(this.ObjectiveList.entryList[_loc5_].formID == _loc2_ && this.ObjectiveList.entryList[_loc5_].instance == _loc4_)
            {
               this.ObjectiveList.entryList[_loc5_].active = a_bnewActiveStatus;
            }
         }
         this.ObjectiveList.UpdateList();
      }
      else
      {
         this.TitleList.selectedEntry.active = a_bnewActiveStatus;
         this.TitleList.UpdateList();
      }
      if(a_bnewActiveStatus)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIQuestActive"]);
         return undefined;
      }
      gfx.io.GameDelegate.call("PlaySound",["UIQuestInactive"]);
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
      var _loc6_ = false;
      var _loc4_ = false;
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
            _loc6_ = true;
         }
         else
         {
            _loc4_ = true;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(_loc3_ != undefined && _loc6_ && _loc4_)
      {
         this.TitleList.entryList.push({divider:true,completed:true,timeIndex:_loc3_});
      }
      this.TitleList.entryList.sort(this.completedQuestSort);
      var _loc5_ = 0;
      _loc2_ = 0;
      while(_loc2_ < this.TitleList.entryList.length)
      {
         if(this.TitleList.entryList[_loc2_].text != undefined)
         {
            this.TitleList.entryList[_loc2_].text = this.TitleList.entryList[_loc2_].text.toUpperCase();
         }
         if(this.TitleList.entryList[_loc2_].formID == auiSavedFormID && this.TitleList.entryList[_loc2_].instance == auiSavedInstance)
         {
            _loc5_ = _loc2_;
         }
         _loc2_ = _loc2_ + 1;
      }
      this.TitleList.InvalidateData();
      this.TitleList.RestoreScrollPosition(_loc5_,true);
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
         this.ObjectivesHeader._visible = !this.isViewingMiscObjectives();
         this.ObjectiveList.selectedIndex = -1;
         this.ObjectiveList.scrollPosition = 0;
         if(this.iPlatform != 0)
         {
            this.ObjectiveList.disableSelection = true;
         }
         this.updateShowOnMapButtonAlpha(0);
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
      this.UpdateButtonVisiblity();
      this.ObjectiveList.InvalidateData();
   }
   function UpdateButtonVisiblity()
   {
      var _loc2_ = this.TitleList.entryList.length > 0 && this.TitleList.entryList.selectedEntry != null;
      this._toggleActiveButton._visible = _loc2_ && !this.TitleList.selectedEntry.completed;
      this._showOnMapButton._visible = _loc2_ && !this.TitleList.selectedEntry.completed && this.bAllowShowOnMap;
   }
   function SetDescriptionText()
   {
      var _loc2_ = 25;
      var _loc4_ = 10;
      var _loc3_ = 470;
      var _loc5_ = 40;
      this.DescriptionText.SetText(this.TitleList.selectedEntry.description);
      var _loc6_ = this.DescriptionText.getCharBoundaries(this.DescriptionText.getLineOffset(this.DescriptionText.numLines - 1));
      this.ObjectivesHeader._y = this.DescriptionText._y + _loc6_.bottom + _loc2_;
      if(this.isViewingMiscObjectives())
      {
         this.ObjectiveList._y = this.DescriptionText._y;
      }
      else
      {
         this.ObjectiveList._y = this.ObjectivesHeader._y + this.ObjectivesHeader._height + _loc4_;
      }
      this.ObjectiveList.border._height = Math.max(_loc3_ - this.ObjectiveList._y,_loc5_);
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
         return undefined;
      }
      this.ObjectiveList.moveSelectionUp();
   }
   function SetPlatform(a_platform, a_bPS3Switch)
   {
      if(a_platform == 0)
      {
         this._toggleActiveControls = {keyCode:28};
         this._showOnMapControls = {keyCode:50};
         this._deleteControls = {keyCode:45};
      }
      else
      {
         this._toggleActiveControls = {keyCode:276};
         this._showOnMapControls = {keyCode:278};
         this._deleteControls = {keyCode:278};
      }
      this.iPlatform = a_platform;
      this.TitleList.SetPlatform(a_platform,a_bPS3Switch);
      this.ObjectiveList.SetPlatform(a_platform,a_bPS3Switch);
   }
}
