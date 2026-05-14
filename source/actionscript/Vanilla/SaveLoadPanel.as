class SaveLoadPanel extends MovieClip
{
   var BackGamepadButton;
   var BackMouseButton;
   var CharacterSelectionHint_mc;
   var List_mc;
   var PS3Switch;
   var PlayerInfoText;
   var SaveLoadList_mc;
   var ScreenShotRect_mc;
   var ScreenshotHolder;
   var ScreenshotLoader;
   var ScreenshotRect;
   var SelectGamepadButton;
   var SelectMouseButton;
   var bSaving;
   var dispatchEvent;
   var iBatchSize;
   var iPlatform;
   var iScreenshotTimerID;
   var isForceStopping;
   var lastSelectedIndexMemory;
   var showCharacterBackHint;
   var showingCharacterList;
   var uiSaveLoadManagerNumElementsToLoad;
   var uiSaveLoadManagerProcessedElements;
   static var SCREENSHOT_DELAY = 750;
   static var CONTROLLER_PC = 0;
   static var CONTROLLER_PC_GAMEPAD = 1;
   static var CONTROLLER_DURANGO = 2;
   static var CONTROLLER_ORBIS = 3;
   static var CONTROLLER_SCARLETT = 4;
   static var CONTROLLER_PROSPERO = 5;
   function SaveLoadPanel()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this.SaveLoadList_mc = this.List_mc;
      this.bSaving = true;
      this.showCharacterBackHint = false;
      this.showingCharacterList = false;
      this.lastSelectedIndexMemory = 0;
      this.uiSaveLoadManagerProcessedElements = 0;
      this.uiSaveLoadManagerNumElementsToLoad = 0;
      this.isForceStopping = false;
   }
   function onLoad()
   {
      this.ScreenshotLoader = new MovieClipLoader();
      this.ScreenshotLoader.addListener(this);
      gfx.io.GameDelegate.addCallBack("ConfirmOKToLoad",this,"onOKToLoadConfirm");
      gfx.io.GameDelegate.addCallBack("onSaveLoadBatchComplete",this,"onSaveLoadBatchComplete");
      gfx.io.GameDelegate.addCallBack("onFillCharacterListComplete",this,"onFillCharacterListComplete");
      gfx.io.GameDelegate.addCallBack("ScreenshotReady",this,"ShowScreenshot");
      this.SaveLoadList_mc.addEventListener("itemPress",this,"onSaveLoadItemPress");
      this.SaveLoadList_mc.addEventListener("selectionChange",this,"onSaveLoadItemHighlight");
      this.iBatchSize = this.SaveLoadList_mc.maxEntries;
      this.PlayerInfoText.createTextField("LevelText",this.PlayerInfoText.getNextHighestDepth(),0,0,200,30);
      this.PlayerInfoText.LevelText.text = "$Level";
      this.PlayerInfoText.LevelText._visible = false;
   }
   function get isSaving()
   {
      return this.bSaving;
   }
   function set isSaving(abFlag)
   {
      this.bSaving = abFlag;
   }
   function get isShowingCharacterList()
   {
      return this.showingCharacterList;
   }
   function set isShowingCharacterList(abFlag)
   {
      this.showingCharacterList = abFlag;
      if(this.iPlatform != 3)
      {
         this.ScreenshotHolder._visible = !this.showingCharacterList;
         this.ScreenShotRect_mc._visible = !this.showingCharacterList;
      }
      this.PlayerInfoText._visible = !this.showingCharacterList;
   }
   function get selectedIndex()
   {
      return this.SaveLoadList_mc.selectedIndex;
   }
   function get platform()
   {
      return this.iPlatform;
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      trace("SaveLoadPanel::SetPlatform " + aiPlatform.toString() + ", abPS3Switch = " + abPS3Switch.toString());
      this.iPlatform = aiPlatform;
      this.PS3Switch = abPS3Switch;
      var _loc2_;
      if(this.iPlatform == SaveLoadPanel.CONTROLLER_PC)
      {
         this.BackMouseButton.SetPlatform(this.iPlatform);
         this.SelectMouseButton.SetPlatform(this.iPlatform);
         this.BackMouseButton.addEventListener("click",Shared.Proxy.create(this,this.OnBackClicked));
         this.SelectMouseButton.addEventListener("click",Shared.Proxy.create(this,this.OnSelectClicked));
         _loc2_ = this.SelectMouseButton.getBounds(this);
         this.SelectMouseButton._x += this.CharacterSelectionHint_mc._x - _loc2_.xMin;
      }
      else
      {
         this.BackGamepadButton.SetPlatform(this.iPlatform,this.PS3Switch);
         this.SelectGamepadButton.SetPlatform(this.iPlatform,this.PS3Switch);
      }
      this.BackMouseButton._visible = this.SelectMouseButton._visible = this.iPlatform == SaveLoadPanel.CONTROLLER_PC;
      this.BackGamepadButton._visible = this.SelectGamepadButton._visible = this.iPlatform != SaveLoadPanel.CONTROLLER_PC;
      if(this.IsPlatformSony())
      {
         this.ScreenshotHolder._visible = false;
         this.ScreenShotRect_mc._visible = false;
      }
   }
   function get batchSize()
   {
      return this.iBatchSize;
   }
   function get numSaves()
   {
      return this.SaveLoadList_mc.length;
   }
   function get selectedEntry()
   {
      return this.SaveLoadList_mc.entryList[this.SaveLoadList_mc.selectedIndex];
   }
   function get LastSelectedIndexMemory()
   {
      if(this.lastSelectedIndexMemory > this.SaveLoadList_mc.entryList.length - 1)
      {
         this.lastSelectedIndexMemory = Math.max(0,this.SaveLoadList_mc.entryList.length - 1);
      }
      return this.lastSelectedIndexMemory;
   }
   function onSaveLoadItemPress(event)
   {
      this.lastSelectedIndexMemory = this.SaveLoadList_mc.selectedIndex;
      var _loc4_;
      var _loc3_;
      var _loc2_;
      if(this.isShowingCharacterList)
      {
         _loc4_ = this.SaveLoadList_mc.entryList[this.SaveLoadList_mc.selectedIndex];
         if(_loc4_ != undefined)
         {
            if(this.iPlatform != 0)
            {
               this.SaveLoadList_mc.selectedIndex = 0;
            }
            _loc3_ = _loc4_.flags;
            if(_loc3_ == undefined)
            {
               _loc3_ = 0;
            }
            _loc2_ = _loc4_.id;
            if(_loc2_ == undefined)
            {
               _loc2_ = 4294967295;
            }
            gfx.io.GameDelegate.call("CharacterSelected",[_loc2_,_loc3_,this.bSaving,this.SaveLoadList_mc.entryList,this.iBatchSize]);
            this.dispatchEvent({type:"OnCharacterSelected"});
         }
      }
      else if(!this.bSaving)
      {
         gfx.io.GameDelegate.call("IsOKtoLoad",[this.SaveLoadList_mc.selectedIndex]);
      }
      else
      {
         this.dispatchEvent({type:"saveGameSelected",index:this.SaveLoadList_mc.selectedIndex});
      }
   }
   function ShowSelectionButtons(show)
   {
      if(this.iPlatform == SaveLoadPanel.CONTROLLER_PC)
      {
         this.SelectMouseButton._visible = this.BackMouseButton._visible = show;
      }
      else
      {
         this.SelectGamepadButton._visible = this.BackGamepadButton._visible = show;
      }
   }
   function onOKToLoadConfirm()
   {
      this.dispatchEvent({type:"loadGameSelected",index:this.SaveLoadList_mc.selectedIndex});
   }
   function ForceStopLoading()
   {
      this.isForceStopping = true;
      if(this.uiSaveLoadManagerProcessedElements < this.uiSaveLoadManagerNumElementsToLoad)
      {
         gfx.io.GameDelegate.call("ForceStopSaveListLoading",[]);
      }
   }
   function RemoveScreenshot()
   {
      if(this.iScreenshotTimerID != undefined)
      {
         clearInterval(this.iScreenshotTimerID);
         this.iScreenshotTimerID = undefined;
      }
      if(this.ScreenshotRect != undefined)
      {
         this.ScreenshotRect.removeMovieClip();
         this.PlayerInfoText.textField.SetText(" ");
         this.PlayerInfoText.DateText.SetText(" ");
         this.PlayerInfoText.PlayTimeText.SetText(" ");
         this.ScreenshotRect = undefined;
      }
   }
   function onSaveLoadItemHighlight(event)
   {
      if(this.isForceStopping)
      {
         return undefined;
      }
      this.RemoveScreenshot();
      if(!this.isShowingCharacterList)
      {
         if(event.index != -1)
         {
            this.iScreenshotTimerID = setInterval(this,"PrepScreenshot",SaveLoadPanel.SCREENSHOT_DELAY);
         }
         this.dispatchEvent({type:"saveHighlighted",index:this.SaveLoadList_mc.selectedIndex});
      }
   }
   function PrepScreenshot()
   {
      clearInterval(this.iScreenshotTimerID);
      this.iScreenshotTimerID = undefined;
      if(this.bSaving)
      {
         gfx.io.GameDelegate.call("PrepSaveGameScreenshot",[this.SaveLoadList_mc.selectedIndex - 1,this.SaveLoadList_mc.selectedEntry]);
      }
      else
      {
         gfx.io.GameDelegate.call("PrepSaveGameScreenshot",[this.SaveLoadList_mc.selectedIndex,this.SaveLoadList_mc.selectedEntry]);
      }
   }
   function ShowScreenshot()
   {
      this.ScreenshotRect = this.ScreenshotHolder.createEmptyMovieClip("ScreenshotRect",0);
      this.ScreenshotLoader.loadClip("img://BGSSaveLoadHeader_Screenshot",this.ScreenshotRect);
      var _loc2_;
      var _loc3_;
      if(this.SaveLoadList_mc.selectedEntry.corrupt == true)
      {
         this.PlayerInfoText.textField.SetText("$SAVE CORRUPT");
      }
      else if(this.SaveLoadList_mc.selectedEntry.obsolete == true)
      {
         this.PlayerInfoText.textField.SetText("$SAVE OBSOLETE");
      }
      else if(this.SaveLoadList_mc.selectedEntry.name != undefined)
      {
         _loc2_ = this.SaveLoadList_mc.selectedEntry.name;
         _loc3_ = 20;
         if(_loc2_.length > _loc3_)
         {
            _loc2_ = _loc2_.substr(0,_loc3_ - 3) + "...";
         }
         if(this.SaveLoadList_mc.selectedEntry.raceName != undefined && this.SaveLoadList_mc.selectedEntry.raceName.length > 0)
         {
            _loc2_ += ", " + this.SaveLoadList_mc.selectedEntry.raceName;
         }
         if(this.SaveLoadList_mc.selectedEntry.level != undefined && this.SaveLoadList_mc.selectedEntry.level > 0)
         {
            _loc2_ += ", " + this.PlayerInfoText.LevelText.text + " " + this.SaveLoadList_mc.selectedEntry.level;
         }
         this.PlayerInfoText.textField.textAutoSize = "shrink";
         this.PlayerInfoText.textField.SetText(_loc2_);
      }
      else
      {
         this.PlayerInfoText.textField.SetText(" ");
      }
      if(this.SaveLoadList_mc.selectedEntry.playTime != undefined)
      {
         this.PlayerInfoText.PlayTimeText.SetText(this.SaveLoadList_mc.selectedEntry.playTime);
      }
      else
      {
         this.PlayerInfoText.PlayTimeText.SetText(" ");
      }
      if(this.SaveLoadList_mc.selectedEntry.dateString != undefined)
      {
         this.PlayerInfoText.DateText.SetText(this.SaveLoadList_mc.selectedEntry.dateString);
      }
      else
      {
         this.PlayerInfoText.DateText.SetText(" ");
      }
   }
   function onLoadInit(aTargetClip)
   {
      aTargetClip._width = this.ScreenshotHolder.sizer._width;
      aTargetClip._height = this.ScreenshotHolder.sizer._height;
   }
   function onFillCharacterListComplete(abDoInitialUpdate)
   {
      this.isShowingCharacterList = true;
      var _loc2_ = 20;
      for(var _loc3_ in this.SaveLoadList_mc.entryList)
      {
         if(this.SaveLoadList_mc.entryList[_loc3_].text.length > _loc2_)
         {
            this.SaveLoadList_mc.entryList[_loc3_].text = this.SaveLoadList_mc.entryList[_loc3_].text.substr(0,_loc2_ - 3) + "...";
         }
      }
      this.SaveLoadList_mc.InvalidateData();
      if(this.iPlatform != 0)
      {
         this.onSaveLoadItemHighlight({index:this.LastSelectedIndexMemory});
         this.SaveLoadList_mc.selectedIndex = this.LastSelectedIndexMemory;
         this.SaveLoadList_mc.UpdateList();
      }
      this.dispatchEvent({type:"saveListCharactersPopulated"});
   }
   function onSaveLoadBatchComplete(abDoInitialUpdate, aNumProcessed, aSaveCount)
   {
      var _loc2_ = 20;
      this.uiSaveLoadManagerProcessedElements = aNumProcessed;
      this.uiSaveLoadManagerNumElementsToLoad = aSaveCount;
      for(var _loc3_ in this.SaveLoadList_mc.entryList)
      {
         if(this.IsPlatformSony())
         {
            if(this.SaveLoadList_mc.entryList[_loc3_].text == undefined)
            {
               this.SaveLoadList_mc.entryList.splice(_loc3_,1);
            }
         }
         if(this.SaveLoadList_mc.entryList[_loc3_].text.length > _loc2_)
         {
            this.SaveLoadList_mc.entryList[_loc3_].text = this.SaveLoadList_mc.entryList[_loc3_].text.substr(0,_loc2_ - 3) + "...";
         }
      }
      var _loc4_ = "$[NEW SAVE]";
      var _loc5_;
      if(this.bSaving && this.SaveLoadList_mc.entryList[0].text != _loc4_)
      {
         _loc5_ = {name:" ",playTime:" ",text:_loc4_};
         this.SaveLoadList_mc.entryList.unshift(_loc5_);
      }
      else if(!this.bSaving && this.SaveLoadList_mc.entryList[0].text == _loc4_)
      {
         this.SaveLoadList_mc.entryList.shift();
      }
      this.SaveLoadList_mc.InvalidateData();
      if(this.IsPlatformSony())
      {
         this.lastSelectedIndexMemory = 0;
      }
      if(abDoInitialUpdate)
      {
         this.isForceStopping = false;
         this.isShowingCharacterList = false;
         this.onSaveLoadItemHighlight({index:this.LastSelectedIndexMemory});
         this.SaveLoadList_mc.selectedIndex = this.LastSelectedIndexMemory;
         this.SaveLoadList_mc.UpdateList();
         this.dispatchEvent({type:"saveListPopulated"});
      }
      else if(!this.isForceStopping)
      {
         this.dispatchEvent({type:"saveListOnBatchAdded"});
      }
   }
   function DeleteSelectedSave()
   {
      if(!this.bSaving || this.SaveLoadList_mc.selectedIndex != 0)
      {
         if(this.bSaving)
         {
            gfx.io.GameDelegate.call("DeleteSave",[this.SaveLoadList_mc.selectedIndex - 1]);
         }
         else
         {
            gfx.io.GameDelegate.call("DeleteSave",[this.SaveLoadList_mc.selectedIndex]);
         }
         this.SaveLoadList_mc.entryList.splice(this.SaveLoadList_mc.selectedIndex,1);
         this.SaveLoadList_mc.InvalidateData();
         this.onSaveLoadItemHighlight({index:this.SaveLoadList_mc.selectedIndex});
      }
   }
   function PopulateEmptySaveList()
   {
      this.SaveLoadList_mc.ClearList();
      this.SaveLoadList_mc.entryList().push(new Object());
      this.onSaveLoadBatchComplete(true,0,0);
   }
   function OnSelectClicked()
   {
      this.onSaveLoadItemPress(null);
   }
   function OnBackClicked()
   {
      this.dispatchEvent({type:"OnSaveLoadPanelBackClicked"});
   }
   function IsPlatformSony()
   {
      return this.iPlatform == SaveLoadPanel.CONTROLLER_ORBIS || this.iPlatform == SaveLoadPanel.CONTROLLER_PROSPERO;
   }
   function IsPlatformXBox()
   {
      return this.iPlatform == SaveLoadPanel.CONTROLLER_DURANGO || this.iPlatform == SaveLoadPanel.CONTROLLER_SCARLETT;
   }
}
