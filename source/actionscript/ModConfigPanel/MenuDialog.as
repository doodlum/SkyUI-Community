class MenuDialog extends OptionDialog
{
   var _closeControls;
   var _defaultControls;
   var leftButtonPanel;
   var menuDefaultIndex;
   var menuList;
   var menuOptions;
   var menuStartIndex;
   var platform;
   var rightButtonPanel;
   function MenuDialog()
   {
      super();
   }
   function initButtons()
   {
      if(this.platform == 0)
      {
         this._defaultControls = skyui.defines.Input.ReadyWeapon;
         this._closeControls = skyui.defines.Input.Tab;
      }
      else
      {
         this._defaultControls = skyui.defines.Input.YButton;
         this._closeControls = skyui.defines.Input.Cancel;
      }
      this.leftButtonPanel.clearButtons();
      var _loc3_ = this.leftButtonPanel.addButton({text:"$Default",controls:this._defaultControls});
      _loc3_.addEventListener("press",this,"onDefaultPress");
      this.leftButtonPanel.updateButtons();
      this.rightButtonPanel.clearButtons();
      var _loc2_ = this.rightButtonPanel.addButton({text:"$Exit",controls:this._closeControls});
      _loc2_.addEventListener("press",this,"onExitPress");
      this.rightButtonPanel.updateButtons();
   }
   function initContent()
   {
      this.menuList.addEventListener("itemPress",this,"onMenuListPress");
      this.menuList.listEnumeration = new skyui.components.list.BasicEnumeration(this.menuList.entryList);
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < this.menuOptions.length)
      {
         _loc3_ = {text:this.menuOptions[_loc2_],align:"center",enabled:true,state:"normal"};
         this.menuList.entryList.push(_loc3_);
         _loc2_ = _loc2_ + 1;
      }
      var _loc8_ = this.menuList.entryList[this.menuStartIndex];
      this.menuList.listState.activeEntry = _loc8_;
      this.menuList.selectedIndex = this.menuStartIndex;
      this.menuList.InvalidateData();
      gfx.managers.FocusHandler.instance.setFocus(this.menuList,0);
   }
   function handleInput(details, pathToFocus)
   {
      var _loc3_ = pathToFocus.shift();
      if(_loc3_.handleInput(details,pathToFocus))
      {
         return true;
      }
      if(Shared.GlobalFunc.IsKeyPressed(details,false))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
         {
            this.onExitPress();
            return true;
         }
         if(details.control == this._defaultControls.name)
         {
            this.onDefaultPress();
            return true;
         }
      }
      return true;
   }
   function onMenuListPress(a_event)
   {
      var _loc2_ = a_event.entry;
      if(_loc2_ == undefined)
      {
         return undefined;
      }
      this.menuList.listState.activeEntry = _loc2_;
      this.menuList.UpdateList();
   }
   function onDefaultPress()
   {
      this.setActiveMenuIndex(this.menuDefaultIndex);
      this.menuList.selectedIndex = this.menuDefaultIndex;
   }
   function onExitPress()
   {
      skse.SendModEvent("SKICP_menuAccepted",null,this.getActiveMenuIndex());
      skyui.util.DialogManager.close();
   }
   function setActiveMenuIndex(a_index)
   {
      var _loc2_ = this.menuList.entryList[a_index];
      this.menuList.listState.activeEntry = _loc2_;
      this.menuList.UpdateList();
   }
   function getActiveMenuIndex()
   {
      var _loc2_ = this.menuList.listState.activeEntry.itemIndex;
      return _loc2_ == undefined ? -1 : _loc2_;
   }
}
