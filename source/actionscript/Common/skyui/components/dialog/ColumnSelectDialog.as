class skyui.components.dialog.ColumnSelectDialog extends skyui.components.dialog.BasicDialog
{
   var layout;
   var list;
   function ColumnSelectDialog()
   {
      super();
   }
   function onLoad()
   {
      this.list.listEnumeration = new skyui.components.list.BasicEnumeration(this.list.entryList);
      this.list.addEventListener("itemPress",this,"onColumnToggle");
      this.layout.addEventListener("layoutChange",this,"onLayoutChange");
      this.setColumnListData();
   }
   function onDialogOpening()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
      gfx.managers.FocusHandler.instance.setFocus(this.list,0);
   }
   function onDialogClosing()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
      this.layout.removeEventListener("layoutChange",this,"onLayoutChange");
   }
   function onColumnToggle(event)
   {
      var _loc1_ = event.entry;
      skyui.util.ConfigManager.setOverride("ListLayout","columns." + _loc1_.id + ".hidden",!_loc1_.value,!_loc1_.value ? "true" : "false");
   }
   function onLayoutChange(event)
   {
      this.setColumnListData();
   }
   function handleInput(details, pathToFocus)
   {
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.TAB || details.navEquivalent == gfx.ui.NavigationCode.ESCAPE || details.navEquivalent == gfx.ui.NavigationCode.LEFT || details.navEquivalent == gfx.ui.NavigationCode.RIGHT)
         {
            skyui.util.DialogManager.close();
            return true;
         }
      }
      var _loc2_ = pathToFocus.shift();
      return _loc2_.handleInput(details,pathToFocus);
   }
   function onMouseDown()
   {
      var _loc2_ = Mouse.getTopMostEntity();
      while(_loc2_ != undefined)
      {
         if(_loc2_ == this)
         {
            return undefined;
         }
         _loc2_ = _loc2_._parent;
      }
      skyui.util.DialogManager.close();
   }
   function setColumnListData()
   {
      this.list.clearList();
      var _loc4_ = this.layout.columnDescriptors;
      var _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < _loc4_.length)
      {
         _loc2_ = _loc4_[_loc3_];
         if(_loc2_.type == skyui.components.list.ListLayout.COL_TYPE_TEXT)
         {
            this.list.entryList.push({enabled:true,text:_loc2_.longName,value:_loc2_.hidden,state:(!_loc2_.hidden ? "on" : "off"),id:_loc2_.identifier});
         }
         _loc3_ = _loc3_ + 1;
      }
      this.list.InvalidateData();
   }
}
