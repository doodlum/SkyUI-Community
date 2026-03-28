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
   var MessageButtons;
   var MessageText;
   var iPlatform;
   
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
      return (aText == this._cancelStr || aText == this._backStr || aText == this._exitStr || aText == this._doneStr || aText == this._returnStr);
   }

   function handleInput(details, pathToFocus)
   {
      var bHandled = false;
      if (Shared.GlobalFunc.IsKeyPressed(details)) 
      {
         if (details.navEquivalent == gfx.ui.NavigationCode.ESCAPE) 
         {
            for (var i = 0; i < this.MessageButtons.length; i++) {
               if (this.IsExitButton(this.MessageButtons[i].ButtonText.text)) {
                  gfx.io.GameDelegate.call("buttonPress", [i]);
                  return true;
               }
            }
            if (this.IsCancellable) {
               gfx.io.GameDelegate.call("buttonPress", [this.CancelOptionIndex]);
               return true;
            }
         }
         
         if (details.code == 9) // TAB Key
         {
            var currentFocus = Selection.getFocus();
            for (var i = 0; i < this.MessageButtons.length; i++) {
               if (this.IsExitButton(this.MessageButtons[i].ButtonText.text)) {
                  Selection.setFocus(this.MessageButtons[i]);
                  return true;
               }
            }
         }
      }

      if (!bHandled) {
         bHandled = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
      }
      return bHandled;
   }

   function setupButtons()
   {
      if(undefined != this.ButtonContainer) {
         this.ButtonContainer.removeMovieClip();
         this.ButtonContainer = undefined;
      }
      this.MessageButtons.length = 0;
      
      var bFocusFirst = arguments[0];
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
            }
         }
         
         this.InitButtons();
         this.ResetDimensions();

         Selection.setFocus(this.MessageButtons[0]);
         this.MessageButtons[0].focused = 1;
      }
   }

   function InitButtons()
   {
      for (var i = 0; i < this.MessageButtons.length; i++)
      {
         this.MessageButtons[i].addEventListener("press", this.ClickCallback);
         this.MessageButtons[i].addEventListener("focusIn", this.FocusCallback);
         this.MessageButtons[i].addEventListener("rollOver", this.HoverCallback);
         
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
      if(0 > diff) {
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
   }
   function onKeyDown()
   {
      var code = Key.getCode();
      for (var i = 0; i < this.MessageButtons.length; i++) {
         var btnText = this.MessageButtons[i].ButtonText.text;
         
         if (code == 89 && btnText == this._yesStr) { 
            gfx.io.GameDelegate.call("buttonPress",[i]); 
            return; 
         } 
         if (code == 78 && btnText == this._noStr) { 
            gfx.io.GameDelegate.call("buttonPress",[i]); 
            return; 
         }
         if (code == 65 && btnText == this._yesToAllStr) { 
            gfx.io.GameDelegate.call("buttonPress",[i]); 
            return; 
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
         Selection.setFocus(this.MessageButtons[0]);
         this.MessageButtons[0].focused = 1;
      }
   }
}