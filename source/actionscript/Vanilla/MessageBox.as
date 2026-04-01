class MessageBox extends MovieClip
{
   var Background_mc;
   var ButtonContainer;
   var CancelOptionIndex;
   var DefaultTextFormat;
   var Divider;
   var IsCancellable;
   var IsVertical;
   var Message;
   var MessageBtnLabels;
   var MessageButtons;
   var MessageText;
   var iPlatform;
   var lastTabIndex = -1;
   
   var _yesStr;
   var _noStr;
   var _yesToAllStr;
   var _cancelStr;
   var _backStr;
   var _exitStr;
   var _doneStr;
   var _returnStr;

   static var WIDTH_MARGIN = 20;
   static var HEIGHT_MARGIN = 30;
   static var MESSAGE_TO_BUTTON_SPACER = 10;
   static var SELECTION_INDICATOR_WIDTH = 25;
   static var SELECTION_INDICATOR_HEIGHT = 5;
   static var BUTTON_PREFIX = "Button";
   
   static var SELECTION_ROLLOVER_ALPHA = 120;
   static var SELECTION_ROLLOUT_ALPHA = 80;

   static var SKSE_KEY_ESC = 1; // Esc
   static var HOTKEY_YES = 89; // Y
   static var HOTKEY_NO = 78; // N
   static var HOTKEY_YES_TO_ALL = 65; // A

   function MessageBox()
   {
      super();
      this.Message = this.MessageText;
      this.Divider = this.Divider;
      this.MessageButtons = new Array();
      this.ButtonContainer = undefined;
      this.DefaultTextFormat = this.Message.getTextFormat();
      this.IsVertical = false;
      Key.addListener(this);
      
      gfx.io.GameDelegate.addCallBack("setMessageText",this,"SetMessage");
      gfx.io.GameDelegate.addCallBack("setButtons",this,"setupButtons");
      gfx.io.GameDelegate.addCallBack("setIsVertical",this,"SetIsVertical");
      gfx.io.GameDelegate.addCallBack("setIsCancellable",this,"SetIsCancellable");
   }

   function InitExtensions()
   {
      Stage.scaleMode = "showAll";
      this.InitLocalization();
   }

   /* 
   * Forces localized string resolution by using a temporary text field.
   * This is required because the engine performs localization instantly when assigning "$" strings,
   * which prevents retrieving their resolved values directly from variables.
   */
   function InitLocalization()
   {
      this.createTextField("temp_txt", this.getNextHighestDepth(), 0, 0, 1, 1);
      this.temp_txt._visible = false;

      this.temp_txt.text = "$Yes";
      this._yesStr = this.temp_txt.text;

      this.temp_txt.text = "$No";
      this._noStr = this.temp_txt.text;

      this.temp_txt.text = "$YesToAll";
      this._yesToAllStr = this.temp_txt.text;

      this.temp_txt.text = "$Cancel";
      this._cancelStr = this.temp_txt.text;

      this.temp_txt.text = "$Back";
      this._backStr = this.temp_txt.text;

      this.temp_txt.text = "$Exit";
      this._exitStr = this.temp_txt.text;

      this.temp_txt.text = "$Done";
      this._doneStr = this.temp_txt.text;

      this.temp_txt.text = "$Return";
      this._returnStr = this.temp_txt.text;

      this.temp_txt.removeTextField();
   }

   function IsExitButton(aText)
   {
      if (aText == this._cancelStr || 
          aText == this._backStr || 
          aText == this._exitStr || 
          aText == this._doneStr || 
          aText == this._returnStr ||
          aText == this._noStr) {
         return true;
      }
      
      var lower = aText.toLowerCase();
      return (lower == "cancel" || 
              lower == "back" || 
              lower == "exit" || 
              lower == "done" || 
              lower == "return" ||
              lower == "no");
   }

   function findNextExitButton(iStartFrom)
   {
      var len = this.MessageButtons.length;
      if (len == 0) return -1;
      
      var start = (iStartFrom === undefined || iStartFrom < 0) ? -1 : iStartFrom;
      
      for (var i = 0; i < len; i++) {
         var idx = (start + 1 + i) % len;
         if (this.IsExitButton(this.MessageBtnLabels[idx])) {
            return idx;
         }
      }
      return -1;
   }

   function findButtonArrayIndexById(aButtonId)
   {
      for (var i = 0; i < this.MessageButtons.length; i++) {
         if (this.getButtonId(this.MessageButtons[i]) === aButtonId) {
            return i;
         }
      }
      return -1;
   }

   function getButtonId(button)
   {
      return Number(button._name.split(MessageBox.BUTTON_PREFIX)[1]);
   }

   function handleInput(details, pathToFocus)
   {
      if (!Shared.GlobalFunc.IsKeyPressed(details)) {
         return pathToFocus[0].handleInput(details, pathToFocus.slice(1));
      }

      // It is necessary to separate ESC from Tab because without SKSE the behavior of Esc = Tab
      var skseKeyCode = !skse ? 0 : skse.GetLastKeycode(true);
      var keyCode = details.code;
      var nav = details.navEquivalent;

      var isCancelKey = (skseKeyCode === MessageBox.SKSE_KEY_ESC || nav == gfx.ui.NavigationCode.GAMEPAD_B);

      if (isCancelKey) {
         var cancelIdx = -1;
         
         if (this.IsCancellable && this.CancelOptionIndex != undefined) {
            cancelIdx = this.findButtonArrayIndexById(this.CancelOptionIndex);
         } else {
            cancelIdx = this.findNextExitButton(-1);
         }
         
         if (cancelIdx != -1) {
            this.setFocusToButton(cancelIdx);
            var btnId = this.getButtonId(this.MessageButtons[cancelIdx]);
            gfx.io.GameDelegate.call("buttonPress", [btnId]);
            return true;
         }
      }

      if (nav == gfx.ui.NavigationCode.TAB) {
         var tabIdx = this.findNextExitButton(this.lastTabIndex);
         if (tabIdx != -1) {
            this.setFocusToButton(tabIdx);
            this.lastTabIndex = tabIdx;
         }
         return true;
      }
      
      var buttons = this.MessageButtons;
      var buttonsLen = buttons.length;
      
      for (var i = 0; i < buttonsLen; i++) {
         var btnTxt = buttons[i].ButtonText.text;
         var btnTxtLower = btnTxt.toLowerCase();
         
         var isYes      = (keyCode == MessageBox.HOTKEY_YES) && (btnTxt == this._yesStr || btnTxtLower == "yes");
         var isNo       = (keyCode == MessageBox.HOTKEY_NO) && (btnTxt == this._noStr || btnTxtLower == "no");
         var isYesToAll = (keyCode == MessageBox.HOTKEY_YES_TO_ALL) && (btnTxt == this._yesToAllStr || btnTxtLower == "yes to all");

         if (isYes || isNo || isYesToAll) {
            this.setFocusToButton(i);
            var btnId = this.getButtonId(buttons[i]);
            gfx.io.GameDelegate.call("buttonPress", [btnId]);
            return true;
         }
      }

      return pathToFocus[0].handleInput(details, pathToFocus.slice(1));
   }

   function setFocusToButton(aiIndex) {
      var btn = this.MessageButtons[aiIndex];
      if (btn != undefined) {
         if (Selection.getFocus() != btn) {
            Selection.setFocus(btn);
         }
         btn.focused = 1;
      }
   }

   function setupButtons()
   {
      if(undefined != this.ButtonContainer) {
         this.ButtonContainer.removeMovieClip();
         this.ButtonContainer = undefined;
      }
      this.MessageButtons = [];
      this.MessageBtnLabels = [];
      
      var totalWidth = 0;
      var totalHeight = 0;

      if(arguments.length > 1)
      {
         this.ButtonContainer = this.createEmptyMovieClip("Buttons", this.getNextHighestDepth());
         
         for (var i = 1; i < arguments.length; i++)
         {
            if(arguments[i] != " ")
            {
               var btnIdx = i - 1;
               var btn = gfx.controls.Button(this.ButtonContainer.attachMovie("MessageBoxButton", MessageBox.BUTTON_PREFIX + btnIdx, this.ButtonContainer.getNextHighestDepth()));
               
               btn.disableFocus = false; 
               
               var txt = btn.ButtonText;
               txt.autoSize = "center";
               txt.html = true;
               txt.SetText(arguments[i], true);
               
               txt._alpha = MessageBox.SELECTION_ROLLOUT_ALPHA;

               btn.SelectionIndicatorHolder.SelectionIndicator._width = txt._width + MessageBox.SELECTION_INDICATOR_WIDTH;
               
               btn.HitArea._width = txt._width + MessageBox.SELECTION_INDICATOR_WIDTH;
               btn.HitArea._height = txt._height + 10; 
               btn.HitArea._x = txt._x - (MessageBox.SELECTION_INDICATOR_WIDTH / 2);
               btn.HitArea._y = txt._y - 5;

               if(this.IsVertical) {
                  btn._x = btn._width / 2;
                  btn._y = totalHeight;
                  totalHeight += btn._height / 2 + MessageBox.SELECTION_INDICATOR_HEIGHT;
               } else {
                  btn._x = totalWidth + btn._width / 2;
                  totalWidth += btn._width + MessageBox.SELECTION_INDICATOR_WIDTH;
               }
               
               this.MessageButtons.push(btn);
               this.MessageBtnLabels.push(arguments[i]);
            }
         }
         
         this.InitButtons();
         this.ResetDimensions();

         if (this.MessageButtons.length > 0) {
            this.setFocusToButton(0);
         }
      }
   }

   function InitButtons()
   {
      for (var i = 0; i < this.MessageButtons.length; i++)
      {
         // Intentional no-op: suppresses Scaleform's native Enter/E button activation.
         this.MessageButtons[i].handlePress = function() {};

         this.MessageButtons[i].addEventListener("press", this, "ClickCallback");
         this.MessageButtons[i].addEventListener("focusIn", this, "FocusCallback");
         this.MessageButtons[i].addEventListener("rollOver", this, "HoverCallback");
         this.MessageButtons[i].ButtonText.noTranslate = true;
      }
   }

   function SetMessage(aText, abHTML)
   {
      this.Message.autoSize = "center";
      this.Message.html = abHTML;
      if(abHTML) {
         this.Message.htmlText = aText;
      } else {
         this.Message.SetText(aText);
      }
      this.ResetDimensions();
   }

   function SetIsVertical(aIsVertical) { this.IsVertical = aIsVertical; }

   function SetIsCancellable(aIsCancellable, aCancelOptionIndex)
   {
      this.IsCancellable = aIsCancellable;
      this.CancelOptionIndex = aCancelOptionIndex;
   }

   function ResetDimensions()
   {
      this.PositionElements();
      var bounds = this.getBounds(this._parent);
      var diff = Stage.height * 0.85 - bounds.yMax;
      if(diff < 0) {
         this.Message.autoSize = false;
         this.Message.textAutoSize = "shrink";
         this.Message._height += (diff * 100 / this._yscale);
         this.PositionElements();
      }
   }

   function PositionElements()
   {
      var bg = this.Background_mc;
      var maxLineWidth = 0;
      
      for (var i = 0; i < this.Message.numLines; i++) {
         maxLineWidth = Math.max(maxLineWidth, this.Message.getLineMetrics(i).width);
      }
      
      var btnW = 0;
      var btnH = 0;
      if(this.ButtonContainer != undefined) {
         btnW = this.ButtonContainer._width;
         btnH = this.ButtonContainer._height;
      }

      bg._width = Math.max(maxLineWidth + 60, btnW + MessageBox.WIDTH_MARGIN * 2);
      bg._height = this.Message._height + btnH + MessageBox.HEIGHT_MARGIN * 2 + MessageBox.MESSAGE_TO_BUTTON_SPACER;
      
      this.Message._y = (- bg._height) / 2 + MessageBox.HEIGHT_MARGIN;
      this.ButtonContainer._y = bg._height / 2 - MessageBox.HEIGHT_MARGIN - this.ButtonContainer._height / 2;
      this.ButtonContainer._x = (- this.ButtonContainer._width) / 2;
      
      this.Divider._width = bg._width - MessageBox.WIDTH_MARGIN * 2;
      this.Divider._y = this.ButtonContainer._y - this.ButtonContainer._height / 2 - MessageBox.MESSAGE_TO_BUTTON_SPACER / 2;

      if(this.IsVertical) {
         this.ButtonContainer._y = this.Message._y + this.Message._height + MessageBox.MESSAGE_TO_BUTTON_SPACER + MessageBox.HEIGHT_MARGIN / 2;
         this.Divider._y = this.Message._y + this.Message._height + MessageBox.MESSAGE_TO_BUTTON_SPACER / 2;
      }
   }

   function ClickCallback(aEvent)
   {
      gfx.io.GameDelegate.call("buttonPress",[Number(aEvent.target._name.split(MessageBox.BUTTON_PREFIX)[1])]);
   }

   function FocusCallback(aEvent)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      
      for (var i = 0; i < this.MessageButtons.length; i++) {
         var isTarget = (this.MessageButtons[i] === aEvent.target);
         this.MessageButtons[i].ButtonText._alpha = isTarget ? MessageBox.SELECTION_ROLLOVER_ALPHA : MessageBox.SELECTION_ROLLOUT_ALPHA;
         if(isTarget) {
            this.lastTabIndex = i;
         }
      }
   }

   function HoverCallback(aEvent)
   {
      Selection.setFocus(aEvent.target);
   }

   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.iPlatform = aiPlatform;
      
      if(this.MessageButtons.length > 0) {
         this.setFocusToButton(0);
      }
   }
}