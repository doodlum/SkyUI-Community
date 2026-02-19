class skyui.components.SearchWidget extends MovieClip
{
   var _bActive;
   var _bEnableAutoupdate;
   var _currentInput;
   var _lastInput;
   var _previousFocus;
   var _updateDelay;
   var _updateTimerId;
   var dispatchEvent;
   var onEnterFrame;
   var textField;
   static var S_FILTER = "$FILTER";
   var _bRestoreFocus = false;
   var isDisabled = false;
   function SearchWidget()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this.textField.onKillFocus = function(a_newFocus)
      {
         this._parent.endInput();
      };
      this.textField.SetText(skyui.components.SearchWidget.S_FILTER);
      skyui.util.ConfigManager.registerLoadCallback(this,"onConfigLoad");
   }
   function onConfigLoad(event)
   {
      var _loc2_ = event.config;
      this._bEnableAutoupdate = _loc2_.SearchBox.autoupdate.enable;
      this._updateDelay = _loc2_.SearchBox.autoupdate.delay;
   }
   function onPress(a_mouseIndex, a_keyboardOrMouse)
   {
      this.startInput();
   }
   function startInput()
   {
      if(this._bActive || this.isDisabled)
      {
         return undefined;
      }
      this._previousFocus = gfx.managers.FocusHandler.instance.getFocus(0);
      this._currentInput = this._lastInput = undefined;
      this.textField.SetText("");
      this.textField.type = "input";
      this.textField.noTranslate = true;
      this.textField.selectable = true;
      Selection.setFocus(this.textField);
      Selection.setSelection(0,0);
      this._bActive = true;
      skse.AllowTextInput(true);
      this.dispatchEvent({type:"inputStart"});
      if(this._bEnableAutoupdate)
      {
         this.onEnterFrame = function()
         {
            this.refreshInput();
            if(this._currentInput != this._lastInput)
            {
               this._lastInput = this._currentInput;
               if(this._updateTimerId != undefined)
               {
                  clearInterval(this._updateTimerId);
               }
               this._updateTimerId = setInterval(this,"updateInput",this._updateDelay);
            }
         };
      }
   }
   function endInput()
   {
      if(!this._bActive)
      {
         return undefined;
      }
      delete this.onEnterFrame;
      this.textField.type = "dynamic";
      this.textField.noTranslate = false;
      this.textField.selectable = false;
      this.textField.maxChars = null;
      var _loc2_ = this._previousFocus.focusEnabled;
      this._previousFocus.focusEnabled = true;
      Selection.setFocus(this._previousFocus,0);
      this._previousFocus.focusEnabled = _loc2_;
      this._bActive = false;
      skse.AllowTextInput(false);
      this.refreshInput();
      if(this._currentInput != undefined)
      {
         this.dispatchEvent({type:"inputEnd",data:this._currentInput});
      }
      else
      {
         this.textField.SetText(skyui.components.SearchWidget.S_FILTER);
         this.dispatchEvent({type:"inputEnd",data:""});
      }
   }
   function handleInput(details, pathToFocus)
   {
      var _loc3_;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
         {
            this.endInput();
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.TAB || details.navEquivalent == gfx.ui.NavigationCode.ESCAPE)
         {
            this.clearText();
            this.endInput();
         }
         _loc3_ = pathToFocus.shift();
         if(_loc3_.handleInput(details,pathToFocus))
         {
            return true;
         }
      }
      return false;
   }
   function clearText()
   {
      this.textField.SetText("");
   }
   function refreshInput()
   {
      var _loc2_ = Shared.GlobalFunc.StringTrim(this.textField.text);
      if(_loc2_ != undefined && _loc2_ != "" && _loc2_ != skyui.components.SearchWidget.S_FILTER)
      {
         this._currentInput = _loc2_;
      }
      else
      {
         this._currentInput = undefined;
      }
   }
   function updateInput()
   {
      if(this._updateTimerId != undefined)
      {
         clearInterval(this._updateTimerId);
         this._updateTimerId = undefined;
         if(this._currentInput != undefined)
         {
            this.dispatchEvent({type:"inputChange",data:this._currentInput});
         }
         else
         {
            this.dispatchEvent({type:"inputChange",data:""});
         }
      }
   }
}
