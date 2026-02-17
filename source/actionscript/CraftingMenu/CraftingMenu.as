class CraftingMenu extends MovieClip
{
   var AdditionalDescription;
   var AdditionalDescriptionHolder;
   var BottomBarInfo;
   var ButtonText;
   var CategoryList;
   var ExitMenuRect;
   var InventoryLists;
   var ItemInfo;
   var ItemInfoHolder;
   var ItemList;
   var MenuDescription;
   var MenuDescriptionHolder;
   var MenuName;
   var MenuNameHolder;
   var MouseRotationRect;
   var _acceptControls;
   var _cancelControls;
   var _config;
   var _searchControls;
   var _searchKey;
   var _sortColumnControls;
   var _sortOrderControls;
   var _subtypeName;
   var bCanExpandPanel;
   var bHideAdditionalDescription;
   var navPanel;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = CraftingMenu.SKYUI_VERSION_MAJOR + "." + CraftingMenu.SKYUI_VERSION_MINOR + " SE";
   static var LIST_OFFSET = 20;
   static var SELECT_BUTTON = 0;
   static var EXIT_BUTTON = 1;
   static var AUX_BUTTON = 2;
   static var CRAFT_BUTTON = 3;
   static var SUBTYPE_NAMES = ["ConstructibleObject","Smithing","EnchantConstruct","EnchantDestruct","Alchemy"];
   var _bCanCraft = false;
   var _bCanFadeItemInfo = true;
   var _bItemCardAdditionalDescription = false;
   var _platform = 0;
   var currentMenuType = "";
   var dbgIntvl = 0;
   function CraftingMenu()
   {
      super();
      this.bCanExpandPanel = true;
      this.bHideAdditionalDescription = false;
      this.ButtonText = new Array("","","","");
      this.CategoryList = this.InventoryLists;
      this.ItemInfo = this.ItemInfoHolder.ItemInfo;
      Mouse.addListener(this);
      skyui.util.ConfigManager.registerLoadCallback(this,"onConfigLoad");
      this.navPanel = this.BottomBarInfo.buttonPanel;
   }
   function get bCanCraft()
   {
      return this._bCanCraft;
   }
   function set bCanCraft(abCanCraft)
   {
      this._bCanCraft = abCanCraft;
      this.UpdateButtonText();
   }
   function get bCanFadeItemInfo()
   {
      gfx.io.GameDelegate.call("CanFadeItemInfo",[],this,"SetCanFadeItemInfo");
      return this._bCanFadeItemInfo;
   }
   function SetCanFadeItemInfo(abCanFade)
   {
      this._bCanFadeItemInfo = abCanFade;
   }
   function get bItemCardAdditionalDescription()
   {
      return this._bItemCardAdditionalDescription;
   }
   function set bItemCardAdditionalDescription(abItemCardDesc)
   {
      this._bItemCardAdditionalDescription = abItemCardDesc;
      if(abItemCardDesc)
      {
         this.AdditionalDescription.text = "";
      }
   }
   function Initialize()
   {
      skse.ExtendData(true);
      skse.ExtendAlchemyCategories(true);
      this._subtypeName = CraftingMenu.SUBTYPE_NAMES[this._currentframe - 1];
      this.ItemInfoHolder = this.ItemInfoHolder;
      this.ItemInfoHolder.gotoAndStop("default");
      this.ItemInfo.addEventListener("endEditItemName",this,"onEndEditItemName");
      this.ItemInfo.addEventListener("subMenuAction",this,"onSubMenuAction");
      this.BottomBarInfo = this.BottomBarInfo;
      this.AdditionalDescriptionHolder = this.ItemInfoHolder.AdditionalDescriptionHolder;
      this.AdditionalDescription = this.AdditionalDescriptionHolder.AdditionalDescription;
      this.AdditionalDescription.textAutoSize = "shrink";
      this.MenuName = this.MenuNameHolder.MenuName;
      this.MenuName.autoSize = "left";
      this.MenuNameHolder._visible = false;
      this.MenuDescription = this.MenuDescriptionHolder.MenuDescription;
      this.MenuDescription.autoSize = "center";
      this.CategoryList.InitExtensions(this._subtypeName);
      gfx.managers.FocusHandler.instance.setFocus(this.CategoryList,0);
      this.CategoryList.addEventListener("itemHighlightChange",this,"onItemHighlightChange");
      this.CategoryList.addEventListener("showItemsList",this,"onShowItemsList");
      this.CategoryList.addEventListener("hideItemsList",this,"onHideItemsList");
      this.CategoryList.addEventListener("categoryChange",this,"onCategoryListChange");
      this.ItemList = this.CategoryList.itemList;
      this.ItemList.addEventListener("itemPress",this,"onItemSelect");
      this.ExitMenuRect.onPress = function()
      {
         gfx.io.GameDelegate.call("CloseMenu",[]);
      };
      this.bCanCraft = false;
      this.positionFixedElements();
   }
   function SetPartitionedFilterMode(a_bPartitioned)
   {
      this.CategoryList.setPartitionedFilterMode(a_bPartitioned);
   }
   function GetNumCategories()
   {
      return this.CategoryList.CategoriesList.entryList.length;
   }
   function UpdateButtonText()
   {
      this.navPanel.clearButtons();
      if(this.getItemShown())
      {
         this.navPanel.addButton({text:this.ButtonText[CraftingMenu.SELECT_BUTTON],controls:skyui.defines.Input.Activate});
      }
      else
      {
         this.navPanel.addButton({text:"$Exit",controls:this._cancelControls});
         this.navPanel.addButton({text:"$Search",controls:this._searchControls});
         if(this._platform != 0)
         {
            this.navPanel.addButton({text:"$Column",controls:this._sortColumnControls});
            this.navPanel.addButton({text:"$Order",controls:this._sortOrderControls});
         }
      }
      if(this.bCanCraft && this.ButtonText[CraftingMenu.CRAFT_BUTTON] != "")
      {
         this.navPanel.addButton({text:this.ButtonText[CraftingMenu.CRAFT_BUTTON],controls:skyui.defines.Input.XButton});
      }
      if(this.bCanCraft && this.ButtonText[CraftingMenu.AUX_BUTTON] != "")
      {
         this.navPanel.addButton({text:this.ButtonText[CraftingMenu.AUX_BUTTON],controls:skyui.defines.Input.YButton});
      }
      this.navPanel.updateButtons(true);
   }
   function UpdateItemList(abFullRebuild)
   {
      if(this._subtypeName == "ConstructibleObject")
      {
         abFullRebuild = true;
      }
      if(abFullRebuild == true)
      {
         this.CategoryList.InvalidateListData();
      }
      else
      {
         this.ItemList.UpdateList();
      }
   }
   function UpdateItemDisplay()
   {
      var _loc2_ = this.getItemShown();
      this.FadeInfoCard(!_loc2_);
      this.SetSelectedItem(this.ItemList.selectedIndex);
      gfx.io.GameDelegate.call("ShowItem3D",[_loc2_]);
   }
   function FadeInfoCard(abFadeOut)
   {
      if(abFadeOut && this.bCanFadeItemInfo)
      {
         this.ItemInfo.FadeOutCard();
         if(this.bHideAdditionalDescription)
         {
            this.AdditionalDescriptionHolder._visible = false;
         }
         return undefined;
      }
      if(abFadeOut)
      {
         return undefined;
      }
      this.ItemInfo.FadeInCard();
      if(this.bHideAdditionalDescription)
      {
         this.AdditionalDescriptionHolder._visible = true;
      }
   }
   function SetSelectedItem(aSelection)
   {
      gfx.io.GameDelegate.call("SetSelectedItem",[aSelection]);
   }
   function PreRebuildList()
   {
   }
   function PostRebuildList(abRestoreSelection)
   {
   }
   function SetPlatform(a_platform, a_bPS3Switch)
   {
      this._platform = a_platform;
      if(a_platform == 0)
      {
         this._acceptControls = skyui.defines.Input.Enter;
         this._cancelControls = skyui.defines.Input.Tab;
      }
      else
      {
         this._acceptControls = skyui.defines.Input.Accept;
         this._cancelControls = skyui.defines.Input.Cancel;
         this._sortColumnControls = skyui.defines.Input.SortColumn;
         this._sortOrderControls = skyui.defines.Input.SortOrder;
      }
      this._searchControls = skyui.defines.Input.Space;
      this.ItemInfo.SetPlatform(a_platform,a_bPS3Switch);
      this.BottomBarInfo.setPlatform(a_platform,a_bPS3Switch);
      this.CategoryList.setPlatform(a_platform,a_bPS3Switch);
   }
   function UpdateIngredients(aLineTitle, aIngredients, abShowPlayerCount)
   {
      var _loc4_ = !this.bItemCardAdditionalDescription ? this.AdditionalDescription : this.ItemInfo.GetItemName();
      _loc4_.text = !(aLineTitle != undefined && aLineTitle.length > 0) ? "" : aLineTitle + ": ";
      var _loc12_ = _loc4_.getNewTextFormat();
      var _loc9_ = _loc4_.getNewTextFormat();
      var _loc3_ = 0;
      var _loc2_;
      var _loc6_;
      var _loc5_;
      var _loc8_;
      while(_loc3_ < aIngredients.length)
      {
         _loc2_ = aIngredients[_loc3_];
         _loc9_.color = _loc2_.PlayerCount >= _loc2_.RequiredCount ? 16777215 : 7829367;
         _loc4_.setNewTextFormat(_loc9_);
         _loc6_ = "";
         if(_loc2_.RequiredCount > 1)
         {
            _loc6_ = _loc2_.RequiredCount + " ";
         }
         _loc5_ = "";
         if(abShowPlayerCount && _loc2_.PlayerCount >= 1)
         {
            _loc5_ = " (" + _loc2_.PlayerCount + ")";
         }
         _loc8_ = _loc6_ + _loc2_.Name + _loc5_ + (_loc3_ < aIngredients.length - 1 ? ", " : "");
         _loc4_.replaceText(_loc4_.length,_loc4_.length + 1,_loc8_);
         _loc3_ = _loc3_ + 1;
      }
      _loc4_.setNewTextFormat(_loc12_);
   }
   function EditItemName(aInitialText, aMaxChars)
   {
      this.ItemInfo.StartEditName(aInitialText,aMaxChars);
   }
   function ShowSlider(aiMaxValue, aiMinValue, aiCurrentValue, aiSnapInterval)
   {
      this.ItemInfo.ShowEnchantingSlider(aiMaxValue,aiMinValue,aiCurrentValue);
      this.ItemInfo.quantitySlider.snapping = true;
      this.ItemInfo.quantitySlider.snapInterval = aiSnapInterval;
      this.ItemInfo.quantitySlider.addEventListener("change",this,"onSliderChanged");
      this.onSliderChanged();
   }
   function SetSliderValue(aValue)
   {
      this.ItemInfo.quantitySlider.value = aValue;
   }
   function handleInput(aInputEvent, aPathToFocus)
   {
      aPathToFocus[0].handleInput(aInputEvent,aPathToFocus.slice(1));
      return true;
   }
   function positionFixedElements()
   {
      Shared.GlobalFunc.SetLockFunction();
      MovieClip(this.CategoryList).Lock("L");
      this.CategoryList._x -= CraftingMenu.LIST_OFFSET;
      this.MenuNameHolder.Lock("L");
      this.MenuNameHolder._x -= CraftingMenu.LIST_OFFSET;
      this.MenuDescriptionHolder.Lock("TR");
      var _loc5_ = Stage.visibleRect.x + Stage.safeRect.x;
      var _loc2_ = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
      var _loc3_ = this.CategoryList.getContentBounds();
      var _loc4_ = this.CategoryList._x + _loc3_[0] + _loc3_[2] + 25;
      this.MenuDescriptionHolder._x = 10 + _loc4_ + (_loc2_ - _loc4_) / 2 + this.MenuDescriptionHolder._width / 2;
      this.BottomBarInfo.positionElements(_loc5_,_loc2_);
      MovieClip(this.ExitMenuRect).Lock("TL");
      this.ExitMenuRect._x -= Stage.safeRect.x + 10;
      this.ExitMenuRect._y -= Stage.safeRect.y;
   }
   function positionFloatingElements()
   {
      var _loc9_ = Stage.visibleRect.x + Stage.safeRect.x;
      var _loc7_ = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
      var _loc8_ = this.CategoryList.getContentBounds();
      var _loc6_ = this.CategoryList._x + _loc8_[0] + _loc8_[2] + 25;
      var _loc2_ = this.ItemInfo._parent;
      var _loc3_ = this._config.ItemInfo.itemcard;
      var _loc5_;
      if(this.ItemInfo.background != undefined)
      {
         _loc5_ = this.ItemInfo.background._width;
      }
      else
      {
         _loc5_ = this.ItemInfo._width;
      }
      var _loc4_ = (_loc7_ - _loc6_) / _loc2_._width;
      if(_loc4_ < 1)
      {
         _loc2_._width *= _loc4_;
         _loc2_._height *= _loc4_;
         _loc5_ *= _loc4_;
      }
      if(_loc3_.align == "left")
      {
         _loc2_._x = _loc6_ + _loc3_.xOffset;
      }
      else if(_loc3_.align == "right")
      {
         _loc2_._x = _loc7_ - _loc5_ + _loc3_.xOffset;
      }
      else
      {
         _loc2_._x = _loc6_ + _loc3_.xOffset + (Stage.visibleRect.x + Stage.visibleRect.width - _loc6_ - _loc5_) / 2;
      }
      _loc2_._y += _loc3_.yOffset;
      MovieClip(this.MouseRotationRect).Lock("T");
      this.MouseRotationRect._x = this.ItemInfo._parent._x;
      this.MouseRotationRect._width = this.ItemInfo._parent._width;
      this.MouseRotationRect._height = 0.55 * Stage.visibleRect.height;
   }
   function onConfigLoad(event)
   {
      this.setConfig(event.config);
      this.CategoryList.showPanel();
   }
   function setConfig(a_config)
   {
      this._config = a_config;
      this.ItemList.addDataProcessor(new CraftingDataSetter());
      this.ItemList.addDataProcessor(new CraftingIconSetter(a_config.Appearance));
      this.positionFloatingElements();
      var _loc3_ = this.CategoryList.itemList.listState;
      var _loc4_ = a_config.Appearance;
      _loc3_.iconSource = _loc4_.icons.item.source;
      _loc3_.showStolenIcon = _loc4_.icons.item.showStolen;
      _loc3_.defaultEnabledColor = _loc4_.colors.text.enabled;
      _loc3_.negativeEnabledColor = _loc4_.colors.negative.enabled;
      _loc3_.stolenEnabledColor = _loc4_.colors.stolen.enabled;
      _loc3_.defaultDisabledColor = _loc4_.colors.text.disabled;
      _loc3_.negativeDisabledColor = _loc4_.colors.negative.disabled;
      _loc3_.stolenDisabledColor = _loc4_.colors.stolen.disabled;
      var _loc5_;
      if(this._subtypeName == "EnchantConstruct")
      {
         _loc5_ = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout,"EnchantListLayout");
      }
      else if(this._subtypeName == "Smithing")
      {
         _loc5_ = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout,"SmithingListLayout");
      }
      else if(this._subtypeName == "ConstructibleObject")
      {
         _loc5_ = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout,"ConstructListLayout");
      }
      else
      {
         _loc5_ = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout,"AlchemyListLayout");
         _loc5_.entryWidth -= CraftingLists.SHORT_LIST_OFFSET;
      }
      this.ItemList.layout = _loc5_;
      var _loc7_ = a_config.Input.controls.gamepad.prevColumn;
      var _loc6_ = a_config.Input.controls.gamepad.nextColumn;
      var _loc8_ = a_config.Input.controls.gamepad.sortOrder;
      this._sortColumnControls = [{keyCode:_loc7_},{keyCode:_loc6_}];
      this._sortOrderControls = {keyCode:_loc8_};
      this._searchKey = a_config.Input.controls.pc.search;
      this._searchControls = {keyCode:this._searchKey};
   }
   function onItemListPressed(event)
   {
      gfx.io.GameDelegate.call("CraftSelectedItem",[this.ItemList.selectedIndex]);
      gfx.io.GameDelegate.call("SetSelectedItem",[this.ItemList.selectedIndex]);
   }
   function onItemSelect(event)
   {
      gfx.io.GameDelegate.call("ChooseItem",[event.index]);
      gfx.io.GameDelegate.call("ShowItem3D",[event.index != -1]);
      this.UpdateButtonText();
   }
   function onItemHighlightChange(event)
   {
      this.SetSelectedItem(event.index);
      this.FadeInfoCard(event.index == -1);
      this.UpdateButtonText();
      gfx.io.GameDelegate.call("ShowItem3D",[event.index != -1]);
   }
   function onShowItemsList(event)
   {
      if(this._platform == 0)
      {
         gfx.io.GameDelegate.call("SetSelectedCategory",[this.CategoryList.CategoriesList.selectedIndex]);
      }
      this.onItemHighlightChange(event);
   }
   function onHideItemsList(event)
   {
      this.SetSelectedItem(event.index);
      this.FadeInfoCard(true);
      this.UpdateButtonText();
      gfx.io.GameDelegate.call("ShowItem3D",[false]);
   }
   function onCategoryListChange(event)
   {
      if(this._platform != 0)
      {
         gfx.io.GameDelegate.call("SetSelectedCategory",[event.index]);
      }
   }
   function onSliderChanged(event)
   {
      gfx.io.GameDelegate.call("CalculateCharge",[this.ItemInfo.quantitySlider.value],this,"SetChargeValues");
   }
   function onSubMenuAction(event)
   {
      if(event.opening == true)
      {
         this.ItemList.disableSelection = true;
         this.ItemList.disableInput = true;
         this.CategoryList.CategoriesList.disableSelection = true;
         this.CategoryList.CategoriesList.disableInput = true;
      }
      else if(event.opening == false)
      {
         this.ItemList.disableSelection = false;
         this.ItemList.disableInput = false;
         this.CategoryList.CategoriesList.disableSelection = false;
         this.CategoryList.CategoriesList.disableInput = false;
      }
      if(event.menu == "quantity")
      {
         if(event.opening)
         {
            return undefined;
         }
         gfx.io.GameDelegate.call("SliderClose",[!event.canceled,event.value]);
      }
   }
   function onCraftButtonPress()
   {
      if(this.bCanCraft)
      {
         gfx.io.GameDelegate.call("CraftButtonPress",[]);
      }
   }
   function onExitButtonPress()
   {
      gfx.io.GameDelegate.call("CloseMenu",[]);
   }
   function onAuxButtonPress()
   {
      gfx.io.GameDelegate.call("AuxButtonPress",[]);
   }
   function onEndEditItemName(event)
   {
      this.ItemInfo.EndEditName();
      gfx.io.GameDelegate.call("EndItemRename",[event.useNewName,event.newName]);
   }
   function getItemShown()
   {
      return this.ItemList.selectedIndex >= 0;
   }
   function onMouseUp()
   {
      if(this.ItemInfo.bEditNameMode && !this.ItemInfo.hitTest(_root._xmouse,_root._ymouse))
      {
         this.onEndEditItemName({useNewName:false,newName:""});
      }
   }
   function onMouseRotationStart()
   {
      gfx.io.GameDelegate.call("StartMouseRotation",[]);
      this.CategoryList.CategoriesList.disableSelection = true;
      this.ItemList.disableSelection = true;
   }
   function onMouseRotationStop()
   {
      gfx.io.GameDelegate.call("StopMouseRotation",[]);
      this.CategoryList.CategoriesList.disableSelection = false;
      this.ItemList.disableSelection = false;
   }
   function onItemsListInputCatcherClick()
   {
   }
   function onMouseRotationFastClick(aiMouseButton)
   {
      if(aiMouseButton == 0)
      {
         this.onItemsListInputCatcherClick();
      }
   }
}
