class StatsPage extends MovieClip
{
   var CategoryList;
   var CategoryList_mc;
   var StatsList_mc;
   var _StatsList;
   var bUpdated;
   function StatsPage()
   {
      super();
      this.CategoryList = this.CategoryList_mc.List_mc;
      this._StatsList = this.StatsList_mc;
      this.bUpdated = false;
   }
   function onLoad()
   {
      this.CategoryList.entryList.push({text:"$GENERAL",stats:new Array(),savedHighlight:0});
      this.CategoryList.entryList.push({text:"$QUEST",stats:new Array(),savedHighlight:0});
      this.CategoryList.entryList.push({text:"$COMBAT",stats:new Array(),savedHighlight:0});
      this.CategoryList.entryList.push({text:"$MAGIC",stats:new Array(),savedHighlight:0});
      this.CategoryList.entryList.push({text:"$CRAFTING",stats:new Array(),savedHighlight:0});
      this.CategoryList.entryList.push({text:"$CRIME",stats:new Array(),savedHighlight:0});
      this.CategoryList.InvalidateData();
      this.CategoryList.addEventListener("listMovedUp",this,"onCategoryListMoveUp");
      this.CategoryList.addEventListener("listMovedDown",this,"onCategoryListMoveDown");
      this.CategoryList.addEventListener("selectionChange",this,"onCategoryListMouseSelectionChange");
      this.CategoryList.disableInput = true;
      this._StatsList.disableSelection = true;
   }
   function startPage()
   {
      this.CategoryList.disableInput = false;
      gfx.managers.FocusHandler.instance.setFocus(this.CategoryList,0);
      if(this.bUpdated)
      {
         return undefined;
      }
      gfx.io.GameDelegate.call("updateStats",[],this,"PopulateStatsList");
      this.bUpdated = true;
   }
   function endPage()
   {
      this.CategoryList.disableInput = true;
   }
   function PopulateStatsList()
   {
      var _loc10_ = 0;
      var _loc9_ = 1;
      var _loc7_ = 2;
      var _loc11_ = 3;
      var _loc8_ = 4;
      var _loc3_ = 0;
      var _loc4_;
      while(_loc3_ < arguments.length)
      {
         _loc4_ = {text:"$" + arguments[_loc3_ + _loc10_],value:arguments[_loc3_ + _loc9_]};
         this.CategoryList.entryList[arguments[_loc3_ + _loc7_]].stats.push(_loc4_);
         _loc3_ += _loc8_;
      }
      this.onCategoryHighlight();
   }
   function onCategoryHighlight()
   {
      var _loc3_ = this.CategoryList.selectedEntry.stats;
      this._StatsList.ClearList();
      this._StatsList.scrollPosition = 0;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_.length)
      {
         this._StatsList.entryList.push(_loc3_[_loc2_]);
         _loc2_ = _loc2_ + 1;
      }
      this._StatsList.InvalidateData();
   }
   function onCategoryListMoveUp(event)
   {
      this.onCategoryHighlight();
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      if(event.scrollChanged == true)
      {
         this.CategoryList._parent.gotoAndPlay("moveUp");
      }
   }
   function onCategoryListMoveDown(event)
   {
      this.onCategoryHighlight();
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      if(event.scrollChanged == true)
      {
         this.CategoryList._parent.gotoAndPlay("moveDown");
      }
   }
   function onCategoryListMouseSelectionChange(event)
   {
      if(event.keyboardOrMouse == 0 && event.index != -1)
      {
         this.onCategoryHighlight();
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      }
   }
   function onRightStickInput(afX, afY)
   {
      if(afY < 0)
      {
         this._StatsList.moveSelectionDown();
         return undefined;
      }
      this._StatsList.moveSelectionUp();
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.CategoryList.SetPlatform(aiPlatform,abPS3Switch);
      this._StatsList.SetPlatform(aiPlatform,abPS3Switch);
   }
}
