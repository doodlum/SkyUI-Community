class ConfigPanel extends MovieClip
{
   var _acceptControls;
   var _bottomBarStartY;
   var _buttonPanelL;
   var _buttonPanelR;
   var _cancelControls;
   var _customContent;
   var _defaultControls;
   var _focus;
   var _highlightIntervalID;
   var _menuDialogOptions;
   var _modList;
   var _modListPanel;
   var _optionFlagsBuffer;
   var _optionNumValueBuffer;
   var _optionStrValueBuffer;
   var _optionTextBuffer;
   var _optionsList;
   var _parentMenu;
   var _platform;
   var _remapDelayID;
   var _state;
   var _subList;
   var _unmapControls;
   var bottomBar;
   var contentHolder;
   var titlebar;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = ConfigPanel.SKYUI_VERSION_MAJOR + "." + ConfigPanel.SKYUI_VERSION_MINOR + " SE";
   static var READY = 0;
   static var WAIT_FOR_OPTION_DATA = 1;
   static var WAIT_FOR_SLIDER_DATA = 2;
   static var WAIT_FOR_MENU_DATA = 3;
   static var WAIT_FOR_COLOR_DATA = 4;
   static var WAIT_FOR_INPUT_DATA = 5;
   static var WAIT_FOR_SELECT = 6;
   static var WAIT_FOR_DEFAULT = 7;
   static var DIALOG = 8;
   static var FOCUS_MODLIST = 0;
   static var FOCUS_OPTIONS = 1;
   var _customContentX = 0;
   var _customContentY = 0;
   var _titleText = "";
   var _infoText = "";
   var _dialogTitleText = "";
   var _highlightIndex = -1;
   var _sliderDialogFormatString = "";
   var _currentRemapOption = -1;
   var _bRemapMode = false;
   var _bDefaultEnabled = false;
   var _bRequestPageReset = false;
   var selectedKeyCode = -1;
   var optionCursorIndex = -1;
   function ConfigPanel()
   {
      super();
      this._parentMenu = _root.QuestJournalFader.Menu_mc;
      this._modListPanel = this.contentHolder.modListPanel;
      this._modList = this._modListPanel.modListFader.list;
      this._subList = this._modListPanel.subListFader.list;
      this._optionsList = this.contentHolder.optionsPanel.optionsList;
      this._buttonPanelL = this.bottomBar.buttonPanelL;
      this._buttonPanelR = this.bottomBar.buttonPanelR;
      this._state = ConfigPanel.READY;
      this._optionFlagsBuffer = [];
      this._optionTextBuffer = [];
      this._optionStrValueBuffer = [];
      this._optionNumValueBuffer = [];
      this._menuDialogOptions = [];
      this.contentHolder.infoPanel.textField.verticalAutoSize = "top";
   }
   function onLoad()
   {
      super.onLoad();
      this._modList.listEnumeration = new skyui.components.list.BasicEnumeration(this._modList.entryList);
      this._subList.listEnumeration = new skyui.components.list.BasicEnumeration(this._subList.entryList);
      this._optionsList.listEnumeration = new skyui.components.list.BasicEnumeration(this._optionsList.entryList);
      this._modList.addEventListener("itemPress",this,"onModListPress");
      this._modList.addEventListener("selectionChange",this,"onModListChange");
      this._subList.addEventListener("itemPress",this,"onSubListPress");
      this._subList.addEventListener("selectionChange",this,"onSubListChange");
      this._optionsList.addEventListener("itemPress",this,"onOptionPress");
      this._optionsList.addEventListener("selectionChange",this,"onOptionChange");
      this._modListPanel.addEventListener("modListEnter",this,"onModListEnter");
      this._modListPanel.addEventListener("modListExit",this,"onModListExit");
      this._modListPanel.addEventListener("subListEnter",this,"onSubListEnter");
      this._modListPanel.addEventListener("subListExit",this,"onSubListExit");
      this._optionsList._visible = false;
   }
   function unlock()
   {
      this._state = ConfigPanel.READY;
      var _loc2_;
      if(this._bRequestPageReset)
      {
         this._bRequestPageReset = false;
         _loc2_ = this._subList.listState.activeEntry;
         this.selectPage(_loc2_);
         return undefined;
      }
   }
   function setModNames()
   {
      this._modList.clearList();
      this._modList.listState.savedIndex = null;
      var _loc3_ = 0;
      var _loc4_;
      while(_loc3_ < arguments.length)
      {
         _loc4_ = arguments[_loc3_];
         if(_loc4_ != "")
         {
            this._modList.entryList.push({modIndex:_loc3_,modName:_loc4_,text:skyui.util.Translator.translate(_loc4_),align:"right",enabled:true});
         }
         _loc3_ = _loc3_ + 1;
      }
      this._modList.entryList.sortOn("text",Array.CASEINSENSITIVE);
      this._modList.InvalidateData();
   }
   function setPageNames()
   {
      this._subList.clearList();
      this._subList.listState.savedIndex = null;
      var _loc3_ = 0;
      var _loc4_;
      while(_loc3_ < arguments.length)
      {
         _loc4_ = arguments[_loc3_];
         if(_loc4_.toLowerCase() != "none")
         {
            this._subList.entryList.push({pageIndex:_loc3_,pageName:_loc4_,text:skyui.util.Translator.translate(_loc4_),align:"right",enabled:true});
         }
         _loc3_ = _loc3_ + 1;
      }
      this._subList.InvalidateData();
   }
   function setCustomContentParams(a_x, a_y)
   {
      this._customContentX = a_x;
      this._customContentY = a_y;
   }
   function loadCustomContent(a_source)
   {
      this.unloadCustomContent();
      var _loc2_ = this.contentHolder.optionsPanel;
      this._customContent = _loc2_.createEmptyMovieClip("customContent",_loc2_.getNextHighestDepth());
      this._customContent._x = this._customContentX;
      this._customContent._y = this._customContentY;
      this._customContent.loadMovie(a_source);
      this._optionsList._visible = false;
   }
   function unloadCustomContent()
   {
      if(!this._customContent)
      {
         return undefined;
      }
      this._customContent.removeMovieClip();
      this._customContent = undefined;
      this._optionsList._visible = true;
   }
   function setTitleText(a_text)
   {
      this._titleText = skyui.util.Translator.translate(a_text).toUpperCase();
      if(this._state != ConfigPanel.WAIT_FOR_OPTION_DATA)
      {
         this.applyTitleText();
      }
   }
   function setInfoText(a_text)
   {
      this._infoText = skyui.util.Translator.translateNested(a_text);
      if(this._state != ConfigPanel.WAIT_FOR_OPTION_DATA)
      {
         this.applyInfoText();
      }
   }
   function setOptionFlagsBuffer()
   {
      var _loc3_ = 0;
      while(_loc3_ < arguments.length)
      {
         this._optionFlagsBuffer[_loc3_] = arguments[_loc3_];
         _loc3_ = _loc3_ + 1;
      }
   }
   function setOptionTextBuffer()
   {
      var _loc3_ = 0;
      while(_loc3_ < arguments.length)
      {
         this._optionTextBuffer[_loc3_] = skyui.util.Translator.translateNested(arguments[_loc3_]);
         _loc3_ = _loc3_ + 1;
      }
   }
   function setOptionStrValueBuffer()
   {
      var _loc3_ = 0;
      while(_loc3_ < arguments.length)
      {
         this._optionStrValueBuffer[_loc3_] = arguments[_loc3_].toLowerCase() != "none" ? arguments[_loc3_] : null;
         _loc3_ = _loc3_ + 1;
      }
   }
   function setOptionNumValueBuffer()
   {
      var _loc3_ = 0;
      while(_loc3_ < arguments.length)
      {
         this._optionNumValueBuffer[_loc3_] = arguments[_loc3_];
         _loc3_ = _loc3_ + 1;
      }
   }
   function setSliderDialogParams(a_value, a_default, a_min, a_max, a_interval)
   {
      this._state = ConfigPanel.DIALOG;
      var _loc3_ = {_x:719,_y:265,platform:this._platform,titleText:this._dialogTitleText,sliderValue:a_value,sliderDefault:a_default,sliderMax:a_max,sliderMin:a_min,sliderInterval:a_interval,sliderFormatString:this._sliderDialogFormatString};
      var _loc2_ = skyui.util.DialogManager.open(this,"OptionSliderDialog",_loc3_);
      _loc2_.addEventListener("dialogClosed",this,"onOptionChangeDialogClosed");
      _loc2_.addEventListener("dialogClosing",this,"onOptionChangeDialogClosing");
      this.dimOut();
   }
   function setMenuDialogOptions()
   {
      this._menuDialogOptions.splice(0);
      var _loc3_ = 0;
      var _loc4_;
      while(_loc3_ < arguments.length)
      {
         _loc4_ = arguments[_loc3_];
         if(_loc4_.toLowerCase() == "none" || _loc4_ == "")
         {
            break;
         }
         this._menuDialogOptions[_loc3_] = skyui.util.Translator.translateNested(arguments[_loc3_]);
         _loc3_ = _loc3_ + 1;
      }
   }
   function setMenuDialogParams(a_startIndex, a_defaultIndex)
   {
      this._state = ConfigPanel.DIALOG;
      var _loc3_ = {_x:719,_y:265,platform:this._platform,titleText:this._dialogTitleText,menuOptions:this._menuDialogOptions,menuStartIndex:a_startIndex,menuDefaultIndex:a_defaultIndex};
      var _loc2_ = skyui.util.DialogManager.open(this,"OptionMenuDialog",_loc3_);
      _loc2_.addEventListener("dialogClosed",this,"onOptionChangeDialogClosed");
      _loc2_.addEventListener("dialogClosing",this,"onOptionChangeDialogClosing");
      this.dimOut();
   }
   function setColorDialogParams(a_currentColor, a_defaultColor)
   {
      this._state = ConfigPanel.DIALOG;
      var _loc3_ = {_x:719,_y:265,platform:this._platform,titleText:this._dialogTitleText,currentColor:a_currentColor,defaultColor:a_defaultColor};
      var _loc2_ = skyui.util.DialogManager.open(this,"OptionColorDialog",_loc3_);
      _loc2_.addEventListener("dialogClosed",this,"onOptionChangeDialogClosed");
      _loc2_.addEventListener("dialogClosing",this,"onOptionChangeDialogClosing");
      this.dimOut();
   }
   function setInputDialogParams(a_initialText)
   {
      this._state = ConfigPanel.DIALOG;
      var _loc3_ = {_x:719,_y:265,platform:this._platform,titleText:this._dialogTitleText,initialText:a_initialText};
      var _loc2_ = skyui.util.DialogManager.open(this,"OptionTextInputDialog",_loc3_);
      _loc2_.addEventListener("dialogClosed",this,"onOptionChangeDialogClosed");
      _loc2_.addEventListener("dialogClosing",this,"onOptionChangeDialogClosing");
      this.dimOut();
   }
   function flushOptionBuffers(a_optionCount)
   {
      this._optionsList.clearList();
      this._optionsList.listState.savedIndex = null;
      var _loc2_ = 0;
      var _loc8_;
      var _loc5_;
      while(_loc2_ < a_optionCount)
      {
         _loc8_ = this._optionFlagsBuffer[_loc2_] & 0xFF;
         _loc5_ = this._optionFlagsBuffer[_loc2_] >>> 8 & 0xFF;
         this._optionsList.entryList.push({optionType:_loc8_,text:this._optionTextBuffer[_loc2_],strValue:this._optionStrValueBuffer[_loc2_],numValue:this._optionNumValueBuffer[_loc2_],flags:_loc5_});
         _loc2_ = _loc2_ + 1;
      }
      if(this._optionsList.entryList.length % 2 != 0)
      {
         this._optionsList.entryList.push({optionType:OptionsListEntry.OPTION_EMPTY});
      }
      this._optionsList.InvalidateData();
      this._optionsList.selectedIndex = -1;
      this._optionFlagsBuffer.splice(0);
      this._optionTextBuffer.splice(0);
      this._optionStrValueBuffer.splice(0);
      this._optionNumValueBuffer.splice(0);
      this.applyTitleText();
      this._highlightIndex = -1;
      clearInterval(this._highlightIntervalID);
      this._infoText = "";
      this.applyInfoText();
   }
   function get optionCursor()
   {
      return this._optionsList.entryList[this.optionCursorIndex];
   }
   function invalidateOptionData()
   {
      this._optionsList.InvalidateData();
   }
   function setOptionFlags()
   {
      var _loc4_ = arguments[0];
      var _loc3_ = arguments[1];
      this._optionsList.entryList[_loc4_].flags = _loc3_;
   }
   function forcePageReset()
   {
      this._bRequestPageReset = true;
   }
   function showMessageDialog(a_text, a_acceptLabel, a_cancelLabel)
   {
      if(this._state == ConfigPanel.READY)
      {
         skse.SendModEvent("SKICP_messageDialogClosed",null,0);
         return undefined;
      }
      var _loc2_ = {_x:719,_y:265,platform:this._platform,messageText:a_text,acceptLabel:a_acceptLabel,cancelLabel:a_cancelLabel};
      var _loc3_ = skyui.util.DialogManager.open(this,"MessageDialog",_loc2_);
      _loc3_.addEventListener("dialogClosing",this,"onMessageDialogClosing");
      this.dimOut();
   }
   function initExtensions()
   {
      Stage.scaleMode = "showAll";
      Shared.GlobalFunc.SetLockFunction();
      this.bottomBar.Lock("B");
      var marginBottomBar = 8;

      this.bottomBar._y += Stage.safeRect.y - marginBottomBar;

      this._bottomBarStartY = this.bottomBar._y;
      this.showWelcomeScreen();
   }
   function setPlatform(a_platform, a_bPS3Switch)
   {
      this._platform = a_platform;
      if(a_platform == 0)
      {
         this._acceptControls = skyui.defines.Input.Enter;
         this._cancelControls = skyui.defines.Input.Tab;
         this._defaultControls = skyui.defines.Input.ReadyWeapon;
         this._unmapControls = skyui.defines.Input.JournalYButton;
      }
      else
      {
         this._acceptControls = skyui.defines.Input.Accept;
         this._cancelControls = skyui.defines.Input.Cancel;
         this._defaultControls = skyui.defines.Input.JournalXButton;
         this._unmapControls = skyui.defines.Input.JournalYButton;
      }
      this._buttonPanelL.setPlatform(a_platform,a_bPS3Switch);
      this._buttonPanelR.setPlatform(a_platform,a_bPS3Switch);
      this.updateModListButtons(false);
   }
   function startPage()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuOK"]);
      this._parent.gotoAndPlay("fadeIn");
      this.changeFocus(ConfigPanel.FOCUS_MODLIST);
      this.showWelcomeScreen();
   }
   function endPage()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuCancel"]);
      this._parent.gotoAndPlay("fadeOut");
   }
   function handleInput(details, pathToFocus)
   {
      if(this._bRemapMode)
      {
         return true;
      }
      var _loc5_;
      var _loc4_;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(this._focus == ConfigPanel.FOCUS_OPTIONS)
         {
            _loc5_ = !this._optionsList.disableInput && this._optionsList.selectedIndex % 2 == 0 && this._subList.entryList.length > 0 && this._subList._visible;
            if(_loc5_ && details.navEquivalent == gfx.ui.NavigationCode.LEFT)
            {
               this.changeFocus(ConfigPanel.FOCUS_MODLIST);
               this._optionsList.listState.savedIndex = this._optionsList.selectedIndex;
               this._optionsList.selectedIndex = -1;
               _loc4_ = this._subList.listState.savedIndex;
               this._subList.selectedIndex = _loc4_ <= -1 ? (this._subList.listState.activeEntry.itemIndex <= -1 ? 0 : this._subList.listState.activeEntry.itemIndex) : _loc4_;
               return true;
            }
         }
         else if(this._focus == ConfigPanel.FOCUS_MODLIST)
         {
            _loc5_ = !this._subList.disableInput && this._optionsList.entryList.length > 0 && this._optionsList._visible;
            if(_loc5_ && details.navEquivalent == gfx.ui.NavigationCode.RIGHT)
            {
               this.changeFocus(ConfigPanel.FOCUS_OPTIONS);
               this._subList.listState.savedIndex = this._subList.selectedIndex;
               this._subList.selectedIndex = -1;
               _loc4_ = this._optionsList.listState.savedIndex;
               this._optionsList.selectedIndex = _loc4_ <= -1 ? 0 : _loc4_;
               return true;
            }
         }
      }
      var _loc3_ = pathToFocus.shift();
      if(_loc3_ && _loc3_.handleInput(details,pathToFocus))
      {
         return true;
      }
      if(Shared.GlobalFunc.IsKeyPressed(details,false))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
         {
            if(this._modListPanel.isSublistActive())
            {
               this.changeFocus(ConfigPanel.FOCUS_MODLIST);
               this._modListPanel.showList();
            }
            else if(this._modListPanel.isListActive())
            {
               this._parentMenu.ConfigPanelClose();
            }
            return true;
         }
         if(details.control == this._defaultControls.name)
         {
            this.requestDefaults();
            return true;
         }
         if(details.control == this._unmapControls.name)
         {
            this.requestUnmap();
            return true;
         }
      }
      return true;
   }
   function requestDefaults()
   {
      if(this._state != ConfigPanel.READY)
      {
         return undefined;
      }
      var _loc2_ = this._optionsList.selectedIndex;
      if(_loc2_ == -1)
      {
         return undefined;
      }
      if(this._optionsList.selectedEntry.flags & OptionsListEntry.FLAG_DISABLED)
      {
         return undefined;
      }
      this._state = ConfigPanel.WAIT_FOR_DEFAULT;
      skse.SendModEvent("SKICP_optionDefaulted",null,_loc2_);
   }
   function requestUnmap()
   {
      if(this._state != ConfigPanel.READY)
      {
         return undefined;
      }
      var _loc2_ = this._optionsList.selectedIndex;
      if(_loc2_ == -1)
      {
         return undefined;
      }
      if(this._optionsList.selectedEntry.flags & (OptionsListEntry.FLAG_DISABLED | OptionsListEntry.FLAG_HIDDEN))
      {
         return undefined;
      }
      if(!(this._optionsList.selectedEntry.flags & OptionsListEntry.FLAG_WITH_UNMAP))
      {
         return undefined;
      }
      this.selectedKeyCode = -1;
      this._state = ConfigPanel.WAIT_FOR_SELECT;
      skse.SendModEvent("SKICP_keymapChanged",null,_loc2_);
   }
   function onModListEnter(event)
   {
      this.showWelcomeScreen();
   }
   function onModListExit(event)
   {
   }
   function onSubListEnter(event)
   {
   }
   function onSubListExit(event)
   {
      this._optionsList.clearList();
      this._optionsList.InvalidateData();
      this.unloadCustomContent();
   }
   function onModListPress(a_event)
   {
      this.selectMod(a_event.entry);
   }
   function onModListChange(a_event)
   {
      if(a_event.index != -1)
      {
         this.changeFocus(ConfigPanel.FOCUS_MODLIST);
      }
      this.updateModListButtons(false);
   }
   function onSubListPress(a_event)
   {
      this.selectPage(a_event.entry);
   }
   function onSubListChange(a_event)
   {
      if(a_event.index != -1)
      {
         this.changeFocus(ConfigPanel.FOCUS_MODLIST);
      }
      this.updateModListButtons(true);
   }
   function onOptionPress(a_event)
   {
      this.selectOption(a_event.index);
   }
   function onOptionChange(a_event)
   {
      if(a_event.index != -1)
      {
         this.changeFocus(ConfigPanel.FOCUS_OPTIONS);
      }
      this.initHighlightOption(a_event.index);
      this.updateOptionButtons();
   }
   function onOptionChangeDialogClosing(event)
   {
      this.dimIn();
   }
   function onMessageDialogClosing(event)
   {
      this.dimIn();
   }
   function onOptionChangeDialogClosed(event)
   {
   }
   function selectMod(a_entry)
   {
      if(this._state != ConfigPanel.READY)
      {
         return undefined;
      }
      this._subList.listState.activeEntry = null;
      this._subList.clearList();
      this._subList.InvalidateData();
      this._optionsList.clearList();
      this._optionsList.InvalidateData();
      this.unloadCustomContent();
      this._state = ConfigPanel.WAIT_FOR_OPTION_DATA;
      skse.SendModEvent("SKICP_modSelected",null,a_entry.modIndex);
      this._modListPanel.showSublist();
   }
   function selectPage(a_entry)
   {
      if(this._state != ConfigPanel.READY)
      {
         return undefined;
      }
      if(a_entry != null)
      {
         this._subList.listState.activeEntry = a_entry;
         this._subList.UpdateList();
         this._state = ConfigPanel.WAIT_FOR_OPTION_DATA;
         skse.SendModEvent("SKICP_pageSelected",a_entry.pageName,a_entry.pageIndex);
      }
      else
      {
         this._state = ConfigPanel.WAIT_FOR_OPTION_DATA;
         skse.SendModEvent("SKICP_pageSelected","",-1);
      }
   }
   function selectOption(a_index)
   {
      if(this._state != ConfigPanel.READY)
      {
         return undefined;
      }
      var _loc2_ = this._optionsList.selectedEntry;
      if(_loc2_ == undefined)
      {
         return undefined;
      }
      if(_loc2_.flags & OptionsListEntry.FLAG_DISABLED)
      {
         return undefined;
      }
      switch(_loc2_.optionType)
      {
         case OptionsListEntry.OPTION_TEXT:
         case OptionsListEntry.OPTION_TOGGLE:
            this._state = ConfigPanel.WAIT_FOR_SELECT;
            skse.SendModEvent("SKICP_optionSelected",null,a_index);
            break;
         case OptionsListEntry.OPTION_SLIDER:
            this._dialogTitleText = _loc2_.text;
            this._sliderDialogFormatString = _loc2_.strValue;
            this._state = ConfigPanel.WAIT_FOR_SLIDER_DATA;
            skse.SendModEvent("SKICP_sliderSelected",null,a_index);
            break;
         case OptionsListEntry.OPTION_MENU:
            this._dialogTitleText = _loc2_.text;
            this._state = ConfigPanel.WAIT_FOR_MENU_DATA;
            skse.SendModEvent("SKICP_menuSelected",null,a_index);
            break;
         case OptionsListEntry.OPTION_COLOR:
            this._dialogTitleText = _loc2_.text;
            this._state = ConfigPanel.WAIT_FOR_COLOR_DATA;
            skse.SendModEvent("SKICP_colorSelected",null,a_index);
            break;
         case OptionsListEntry.OPTION_KEYMAP:
            if(!this._bRemapMode)
            {
               this._currentRemapOption = a_index;
               this.initRemapMode();
            }
            break;
         case OptionsListEntry.OPTION_INPUT:
            this._dialogTitleText = _loc2_.text;
            this._state = ConfigPanel.WAIT_FOR_INPUT_DATA;
            skse.SendModEvent("SKICP_inputSelected",null,a_index);
         case OptionsListEntry.OPTION_EMPTY:
         case OptionsListEntry.OPTION_HEADER:
         default:
            return;
      }
   }
   function initRemapMode()
   {
      this.dimOut();
      var _loc2_ = skyui.util.DialogManager.open(this,"KeymapDialog",{_x:719,_y:240});
      _loc2_.background._width = _loc2_.textField.textWidth + 100;
      this._bRemapMode = true;
      skse.StartRemapMode(this);
   }
   function EndRemapMode(a_keyCode)
   {
      this.selectedKeyCode = a_keyCode;
      this._state = ConfigPanel.WAIT_FOR_SELECT;
      skse.SendModEvent("SKICP_keymapChanged",null,this._currentRemapOption);
      this._remapDelayID = setInterval(this,"clearRemap",200);
      skyui.util.DialogManager.close();
      this.dimIn();
   }
   function clearRemap()
   {
      clearInterval(this._remapDelayID);
      delete this._remapDelayID;
      this._bRemapMode = false;
      this._currentRemapOption = -1;
   }
   function initHighlightOption(a_index)
   {
      if(this._state != ConfigPanel.READY)
      {
         return undefined;
      }
      if(a_index == this._highlightIndex)
      {
         return undefined;
      }
      this._highlightIndex = a_index;
      clearInterval(this._highlightIntervalID);
      this._highlightIntervalID = setInterval(this,"doHighlightOption",200,a_index);
   }
   function doHighlightOption(a_index)
   {
      clearInterval(this._highlightIntervalID);
      delete this._highlightIntervalID;
      skse.SendModEvent("SKICP_optionHighlighted",null,a_index);
   }
   function applyTitleText()
   {
      this.titlebar.textField.text = this._titleText;
      var _loc2_ = this.titlebar.textField.textWidth + 100;
      if(_loc2_ < 300)
      {
         _loc2_ = 300;
      }
      this.titlebar.background._width = _loc2_;
   }
   function applyInfoText()
   {
      var _loc2_ = this.contentHolder.infoPanel;
      _loc2_.textField.text = skyui.util.GlobalFunctions.unescape(this._infoText);
      var _loc3_;
      if(this._infoText != "")
      {
         _loc3_ = _loc2_.textField.textHeight + 22;
         _loc2_.background._height = _loc3_;
      }
      else
      {
         _loc2_.background._height = 32;
      }
   }
   function changeFocus(a_focus)
   {
      this._focus = a_focus;
      gfx.managers.FocusHandler.instance.setFocus(a_focus != ConfigPanel.FOCUS_OPTIONS ? this._modListPanel : this._optionsList,0);
   }
   function dimOut()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
      this._optionsList.disableSelection = this._optionsList.disableInput = true;
      this._modListPanel.isDisabled = true;
      skyui.util.Tween.LinearTween(this.bottomBar,"_alpha",100,0,0.5,null);
      skyui.util.Tween.LinearTween(this.bottomBar,"_y",this._bottomBarStartY,this._bottomBarStartY + 50,0.5,null);
      skyui.util.Tween.LinearTween(this.contentHolder,"_alpha",100,75,0.5,null);
   }
   function dimIn()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
      this._optionsList.disableSelection = this._optionsList.disableInput = false;
      this._modListPanel.isDisabled = false;
      skyui.util.Tween.LinearTween(this.bottomBar,"_alpha",0,100,0.5,null);
      skyui.util.Tween.LinearTween(this.bottomBar,"_y",this._bottomBarStartY + 50,this._bottomBarStartY,0.5,null);
      skyui.util.Tween.LinearTween(this.contentHolder,"_alpha",75,100,0.5,null);
   }
   function showWelcomeScreen()
   {
      this.setCustomContentParams(150,50);
      this.loadCustomContent("skyui/mcm_splash.swf");
      this.setTitleText("$MOD CONFIGURATION");
      this.setInfoText("");
   }
   function updateModListButtons(a_bSubList)
   {
      var _loc2_ = this._modListPanel.selectedEntry;
      this._buttonPanelL.clearButtons();
      if(_loc2_ != null)
      {
         this._buttonPanelL.addButton({text:"$Select",controls:this._acceptControls});
      }
      this._buttonPanelL.updateButtons(true);
      this._buttonPanelR.clearButtons();
      this._buttonPanelR.addButton({text:(!a_bSubList ? "$Exit" : "$Back"),controls:this._cancelControls});
      this._buttonPanelR.updateButtons(true);
   }
   function updateOptionButtons()
   {
      var _loc2_ = this._optionsList.selectedEntry;
      this._buttonPanelL.clearButtons();
      var _loc3_;
      if(_loc2_ != null && !(_loc2_.flags & (OptionsListEntry.FLAG_DISABLED | OptionsListEntry.FLAG_HIDDEN)))
      {
         _loc3_ = _loc2_.optionType;
         switch(_loc3_)
         {
            case OptionsListEntry.OPTION_TOGGLE:
               this._buttonPanelL.addButton({text:"$Toggle",controls:this._acceptControls});
               break;
            case OptionsListEntry.OPTION_TEXT:
               this._buttonPanelL.addButton({text:"$Select",controls:this._acceptControls});
               break;
            case OptionsListEntry.OPTION_SLIDER:
               this._buttonPanelL.addButton({text:"$Open Slider",controls:this._acceptControls});
               break;
            case OptionsListEntry.OPTION_MENU:
               this._buttonPanelL.addButton({text:"$Open Menu",controls:this._acceptControls});
               break;
            case OptionsListEntry.OPTION_COLOR:
               this._buttonPanelL.addButton({text:"$Pick Color",controls:this._acceptControls});
               break;
            case OptionsListEntry.OPTION_INPUT:
               this._buttonPanelL.addButton({text:"$Input Text",controls:this._acceptControls});
               break;
            case OptionsListEntry.OPTION_KEYMAP:
               this._buttonPanelL.addButton({text:"$Remap",controls:this._acceptControls});
               if(_loc2_.flags & OptionsListEntry.FLAG_WITH_UNMAP)
               {
                  this._buttonPanelL.addButton({text:"$Unmap",controls:this._unmapControls});
               }
               break;
            case OptionsListEntry.OPTION_EMPTY:
            case OptionsListEntry.OPTION_HEADER:
         }
         if(_loc3_ != OptionsListEntry.OPTION_EMPTY && _loc3_ != OptionsListEntry.OPTION_HEADER)
         {
            this._buttonPanelL.addButton({text:"$Default",controls:this._defaultControls});
            this._bDefaultEnabled = true;
         }
         else
         {
            this._bDefaultEnabled = false;
         }
      }
      else
      {
         this._bDefaultEnabled = false;
      }
      this._buttonPanelL.updateButtons(true);
      this._buttonPanelR.clearButtons();
      this._buttonPanelR.addButton({text:"$Back",controls:this._cancelControls});
      this._buttonPanelR.updateButtons(true);
   }
}
