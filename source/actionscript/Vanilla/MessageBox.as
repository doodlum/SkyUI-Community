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
   function handleInput(details, pathToFocus)
   {
      var _loc3_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if((details.navEquivalent == gfx.ui.NavigationCode.ESCAPE || details.navEquivalent == gfx.ui.NavigationCode.GAMEPAD_B || details.navEquivalent == gfx.ui.NavigationCode.TAB || details.code == 9) && this.IsCancellable)
         {
            gfx.io.GameDelegate.call("buttonPress",[this.CancelOptionIndex]);
            _loc3_ = true;
         }
      }
      if(!_loc3_)
      {
         pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      return _loc3_;
   }
   function setupButtons()
   {
      if(undefined != this.ButtonContainer)
      {
         this.ButtonContainer.removeMovieClip();
         this.ButtonContainer = undefined;
      }
      this.MessageButtons.length = 0;
      var _loc9_ = arguments[0];
      var _loc7_;
      var _loc8_;
      var _loc5_;
      var _loc6_;
      var _loc3_;
      var _loc4_;
      if(arguments.length > 1)
      {
         this.ButtonContainer = this.createEmptyMovieClip("Buttons",this.getNextHighestDepth());
         _loc7_ = 0;
         _loc8_ = 0;
         _loc5_ = 1;
         while(_loc5_ < arguments.length)
         {
            if(arguments[_loc5_] != " ")
            {
               _loc6_ = _loc5_ - 1;
               _loc3_ = gfx.controls.Button(this.ButtonContainer.attachMovie("MessageBoxButton",MessageBox.BUTTON_PREFIX + _loc6_,this.ButtonContainer.getNextHighestDepth()));
               _loc3_.disableFocus = this.iPlatform == 0;
               _loc4_ = _loc3_.ButtonText;
               _loc4_.autoSize = "center";
               _loc4_.verticalAlign = "center";
               _loc4_.verticalAutoSize = "center";
               _loc4_.html = true;
               _loc4_.SetText(arguments[_loc5_],true);
               _loc3_.SelectionIndicatorHolder.SelectionIndicator._width = _loc4_._width + MessageBox.SELECTION_INDICATOR_WIDTH;
               _loc3_.SelectionIndicatorHolder.SelectionIndicator._y = _loc4_._y + _loc4_._height / 2;
               if(this.IsVertical)
               {
                  _loc3_._x = _loc3_._width / 2;
                  _loc3_._y = _loc8_;
                  _loc8_ += _loc3_._height / 2 + MessageBox.SELECTION_INDICATOR_HEIGHT;
                  _loc3_.HitArea._x = _loc4_._x;
                  _loc3_.HitArea._y = _loc4_._y;
                  _loc3_.HitArea._width = _loc4_._width;
                  _loc3_.HitArea._height = _loc4_._height;
               }
               else
               {
                  _loc3_._x = _loc7_ + _loc3_._width / 2;
                  _loc7_ += _loc3_._width + MessageBox.SELECTION_INDICATOR_WIDTH;
               }
               this.MessageButtons.push(_loc3_);
            }
            _loc5_ = _loc5_ + 1;
         }
         this.InitButtons();
         this.ResetDimensions();
         if(_loc9_)
         {
            Selection.setFocus(this.MessageButtons[0]);
            this.MessageButtons[0].focused = 1;
         }
      }
   }
   function InitButtons()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.MessageButtons.length)
      {
         this.MessageButtons[_loc2_].handlePress = function()
         {
         };
         this.MessageButtons[_loc2_].addEventListener("press",this.ClickCallback);
         this.MessageButtons[_loc2_].addEventListener("focusIn",this.FocusCallback);
         this.MessageButtons[_loc2_].ButtonText.noTranslate = true;
         _loc2_ = _loc2_ + 1;
      }
   }
   function SetMessage(aText, abHTML)
   {
      this.Message.autoSize = "center";
      this.Message.textAutoSize = "none";
      this.Message.setTextFormat(this.DefaultTextFormat);
      this.Message.setNewTextFormat(this.DefaultTextFormat);
      this.Message.html = abHTML;
      if(abHTML)
      {
         this.Message.htmlText = aText;
      }
      else
      {
         this.Message.SetText(aText);
      }
      this.ResetDimensions();
   }
   function SetIsVertical(aIsVertical)
   {
      this.IsVertical = aIsVertical;
   }
   function SetIsCancellable(aIsCancellable, aCancelOptionIndex)
   {
      this.IsCancellable = aIsCancellable;
      this.CancelOptionIndex = aCancelOptionIndex;
   }
   function ResetDimensions()
   {
      this.PositionElements();
      var _loc3_ = this.getBounds(this._parent);
      var _loc2_ = Stage.height * 0.85 - _loc3_.yMax;
      var _loc4_;
      if(0 > _loc2_)
      {
         this.Message.autoSize = false;
         this.Message.textAutoSize = "shrink";
         _loc4_ = _loc2_ * 100 / this._yscale;
         this.Message._height += _loc4_;
         this.PositionElements();
      }
   }
   function PositionElements()
   {
      var _loc4_ = this.Background_mc;
      var _loc3_ = 0;
      var _loc2_ = 0;
      while(_loc2_ < this.Message.numLines)
      {
         _loc3_ = Math.max(_loc3_,this.Message.getLineMetrics(_loc2_).width);
         _loc2_ = _loc2_ + 1;
      }
      var _loc6_ = 0;
      var _loc5_ = 0;
      if(this.ButtonContainer != undefined)
      {
         _loc6_ = this.ButtonContainer._width;
         _loc5_ = this.ButtonContainer._height;
      }
      _loc4_._width = Math.max(_loc3_ + 60,_loc6_ + MessageBox.WIDTH_MARGIN * 2);
      _loc4_._height = this.Message._height + _loc5_ + MessageBox.HEIGHT_MARGIN * 2 + MessageBox.MESSAGE_TO_BUTTON_SPACER;
      this.Message._y = (- _loc4_._height) / 2 + MessageBox.HEIGHT_MARGIN;
      this.ButtonContainer._y = _loc4_._height / 2 - MessageBox.HEIGHT_MARGIN - this.ButtonContainer._height / 2;
      this.ButtonContainer._x = (- this.ButtonContainer._width) / 2;
      this.Divider._width = _loc4_._width - MessageBox.WIDTH_MARGIN * 2;
      this.Divider._y = this.ButtonContainer._y - this.ButtonContainer._height / 2 - MessageBox.MESSAGE_TO_BUTTON_SPACER / 2;
      if(this.IsVertical)
      {
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
      if(Key.getCode() == 89 && this.MessageButtons[0].ButtonText.text == "Yes")
      {
         gfx.io.GameDelegate.call("buttonPress",[0]);
      }
      else if(Key.getCode() == 78 && this.MessageButtons[1].ButtonText.text == "No")
      {
         gfx.io.GameDelegate.call("buttonPress",[1]);
      }
      else if(Key.getCode() == 65 && this.MessageButtons[2].ButtonText.text == "Yes to All")
      {
         gfx.io.GameDelegate.call("buttonPress",[2]);
      }
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.iPlatform = aiPlatform;
      if(aiPlatform != 0 && this.MessageButtons.length > 0)
      {
         Selection.setFocus(this.MessageButtons[0]);
         this.MessageButtons[0].focused = 1;
      }
   }
}
