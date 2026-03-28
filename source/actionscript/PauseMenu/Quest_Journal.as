class Quest_Journal extends MovieClip
{
   var BottomBar;
   var BottomBar_mc;
   var ConfigPanel;
   var PageArray;
   var QuestsFader;
   var QuestsTab;
   var StatsFader;
   var StatsTab;
   var SystemFader;
   var SystemTab;
   var TabButtonGroup;
   var TabButtonHelp;
   var TopmostPage;
   var bTabsDisabled;
   var iCurrentTab;
   static var PAGE_QUEST = 0;
   static var PAGE_STATS = 1;
   static var PAGE_SYSTEM = 2;
   function Quest_Journal()
   {
      super();
      this.QuestsTab = this.QuestsTab;
      this.StatsTab = this.StatsTab;
      this.SystemTab = this.SystemTab;
      this.BottomBar_mc = this.BottomBar;
      this.PageArray = new Array(this.QuestsFader.Page_mc,this.StatsFader.Page_mc,this.SystemFader.Page_mc);
      this.TopmostPage = this.QuestsFader;
      this.bTabsDisabled = false;
   }
   function InitExtensions()
   {
      Stage.scaleMode = "showAll";
      Shared.GlobalFunc.SetLockFunction();

      var marginBottomBar = 12;

      MovieClip(this.BottomBar_mc).Lock("B");
      this.BottomBar_mc._y += Stage.safeRect.y + marginBottomBar;

      this.ConfigPanel = _root.ConfigPanelFader.configPanel;
      _root.ConfigPanelFader._visible = false;
      this.QuestsTab.disableFocus = true;
      this.StatsTab.disableFocus = true;
      this.SystemTab.disableFocus = true;
      this.TabButtonGroup = gfx.controls.ButtonGroup(this.QuestsTab.group);
      this.TabButtonGroup.addEventListener("itemClick",this,"onTabClick");
      this.TabButtonGroup.addEventListener("change",this,"onTabChange");
      gfx.io.GameDelegate.addCallBack("RestoreSavedSettings",this,"RestoreSavedSettings");
      gfx.io.GameDelegate.addCallBack("onRightStickInput",this,"onRightStickInput");
      gfx.io.GameDelegate.addCallBack("HideMenu",this,"DoHideMenu");
      gfx.io.GameDelegate.addCallBack("ShowMenu",this,"DoShowMenu");
      gfx.io.GameDelegate.addCallBack("StartCloseMenu",this,"CloseMenu");
      gfx.io.GameDelegate.call("ShouldShowMod",[],this,"SetShowMod");
      this.BottomBar_mc.InitBar();
      this.ConfigPanel.initExtensions();
   }
   function SetShowMod()
   {
      SystemPage(this.PageArray[Quest_Journal.PAGE_SYSTEM]).SetShowMod(arguments[0]);
   }
   function RestoreSavedSettings(aiSavedTab, abTabsDisabled)
   {
      this.iCurrentTab = Math.min(Math.max(aiSavedTab,0),this.TabButtonGroup.length - 1);
      this.bTabsDisabled = abTabsDisabled;
      if(this.bTabsDisabled)
      {
         this.iCurrentTab = this.TabButtonGroup.length - 1;
         this.QuestsTab.disabled = true;
         this.StatsTab.disabled = true;
      }
      this.SwitchPageToFront(this.iCurrentTab,true);
      this.TabButtonGroup.setSelectedButton(this.TabButtonGroup.getButtonAt(this.iCurrentTab));
   }
   function SwitchPageToFront(aiTab, abForceFade)
   {
      if(this.TopmostPage != this.PageArray[this.iCurrentTab]._parent)
      {
         this.TopmostPage.gotoAndStop("hide");
         this.PageArray[this.iCurrentTab]._parent.swapDepths(this.TopmostPage);
         this.TopmostPage = this.PageArray[this.iCurrentTab]._parent;
      }
      this.TopmostPage.gotoAndPlay(!abForceFade ? "fadeIn" : "ForceFade");
      this.BottomBar_mc.SetMode(this.iCurrentTab);
   }
   function handleInput(details, pathToFocus)
   {
      var _loc6_ = false;
      if(pathToFocus != undefined && pathToFocus.length > 0)
      {
         _loc6_ = pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      var _loc2_ = gfx.ui.NavigationCode.GAMEPAD_L2;
      var _loc5_ = gfx.ui.NavigationCode.GAMEPAD_R2;
      var _loc7_ = SystemPage(this.PageArray[Quest_Journal.PAGE_SYSTEM]);
      var _loc8_ = _loc7_.GetIsRemoteDevice();
      if(_loc8_)
      {
         _loc2_ = gfx.ui.NavigationCode.GAMEPAD_L1;
         _loc5_ = gfx.ui.NavigationCode.GAMEPAD_R1;
      }
      if(!_loc6_ && Shared.GlobalFunc.IsKeyPressed(details,false))
      {
         switch(details.navEquivalent)
         {
            case gfx.ui.NavigationCode.TAB:
               this.CloseMenu();
               break;
            case _loc2_:
            case _loc5_:
               if(!this.bTabsDisabled)
               {
                  this.PageArray[this.iCurrentTab].endPage();
                  this.iCurrentTab += details.navEquivalent != _loc2_ ? 1 : -1;
                  if(this.iCurrentTab == -1)
                  {
                     this.iCurrentTab = this.TabButtonGroup.length - 1;
                  }
                  if(this.iCurrentTab == this.TabButtonGroup.length)
                  {
                     this.iCurrentTab = 0;
                  }
                  this.SwitchPageToFront(this.iCurrentTab,false);
                  this.TabButtonGroup.setSelectedButton(this.TabButtonGroup.getButtonAt(this.iCurrentTab));
               }
         }
      }
      return true;
   }
   function CloseMenu(abForceClose)
   {
      if(abForceClose != true)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIJournalClose"]);
      }
      gfx.io.GameDelegate.call("CloseMenu",[this.iCurrentTab,this.QuestsFader.Page_mc.selectedQuestID,this.QuestsFader.Page_mc.selectedQuestInstance]);
   }
   function onTabClick(event)
   {
      var _loc2_;
      if(!this.bTabsDisabled)
      {
         _loc2_ = this.iCurrentTab;
         if(event.item == this.QuestsTab)
         {
            this.iCurrentTab = 0;
         }
         else if(event.item == this.StatsTab)
         {
            this.iCurrentTab = 1;
         }
         else if(event.item == this.SystemTab)
         {
            this.iCurrentTab = 2;
         }
         if(_loc2_ != this.iCurrentTab)
         {
            this.PageArray[_loc2_].endPage();
         }
         this.SwitchPageToFront(this.iCurrentTab,false);
      }
   }
   function onTabChange(event)
   {
      event.item.gotoAndPlay("selecting");
      this.PageArray[this.iCurrentTab].startPage();
      gfx.io.GameDelegate.call("PlaySound",["UIJournalTabsSD"]);
   }
   function onRightStickInput(afX, afY)
   {
      if(this.PageArray[this.iCurrentTab].onRightStickInput != undefined)
      {
         this.PageArray[this.iCurrentTab].onRightStickInput(afX,afY);
      }
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      for(var _loc4_ in this.PageArray)
      {
         if(this.PageArray[_loc4_].SetPlatform != undefined)
         {
            this.PageArray[_loc4_].SetPlatform(aiPlatform,abPS3Switch);
         }
      }
      this.BottomBar_mc.SetPlatform(aiPlatform,abPS3Switch);
      this.ConfigPanel.setPlatform(aiPlatform,abPS3Switch);
      this.TabButtonHelp.gotoAndStop(aiPlatform + 1);
   }
   function DoHideMenu()
   {
      this._parent.gotoAndPlay("fadeOut");
   }
   function DoShowMenu()
   {
      this._parent.gotoAndPlay("fadeIn");
   }
   function DisableTabs(abEnable)
   {
      this.QuestsTab.disabled = abEnable;
      this.StatsTab.disabled = abEnable;
      this.SystemTab.disabled = abEnable;
   }
   function ConfigPanelOpen()
   {
      this.DisableTabs(true);
      this.SystemFader.Page_mc.endPage();
      this.DoHideMenu();
      _root.ConfigPanelFader._visible = true;
      _root.ConfigPanelFader.swapDepths(_root.QuestJournalFader);
      gfx.managers.FocusHandler.instance.setFocus(this.ConfigPanel,0);
      this.ConfigPanel.startPage();
   }
   function ConfigPanelClose()
   {
      this.ConfigPanel.endPage();
      _root.QuestJournalFader.swapDepths(_root.ConfigPanelFader);
      _root.ConfigPanelFader._visible = false;
      gfx.managers.FocusHandler.instance.setFocus(this,0);
      this.DoShowMenu();
      this.SystemFader.Page_mc.startPage();
      this.DisableTabs(false);
   }
}
