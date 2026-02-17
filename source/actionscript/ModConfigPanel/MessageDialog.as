class MessageDialog extends OptionDialog
{
   var _acceptControls;
   var _cancelControls;
   var acceptLabel;
   var background;
   var buttonPanel;
   var cancelLabel;
   var messageText;
   var platform;
   var seperator;
   var textField;
   var _bWithCancel = true;
   function MessageDialog()
   {
      super();
   }
   function onLoad()
   {
      this.buttonPanel.setPlatform(this.platform,false);
      this._bWithCancel = this.cancelLabel != "";
      this.initButtons();
      this.textField.wordWrap = true;
      this.messageText = skyui.util.Translator.translateNested(this.messageText);
      this.textField.SetText(skyui.util.GlobalFunctions.unescape(this.messageText));
      this.textField.verticalAutoSize = "top";
      this.positionElements();
   }
   function initButtons()
   {
      if(this.platform == 0)
      {
         this._acceptControls = skyui.defines.Input.Enter;
         this._cancelControls = skyui.defines.Input.Tab;
      }
      else
      {
         this._acceptControls = skyui.defines.Input.Accept;
         this._cancelControls = skyui.defines.Input.Cancel;
      }
      this.buttonPanel.clearButtons();
      var _loc3_;
      if(this._bWithCancel)
      {
         _loc3_ = this.buttonPanel.addButton({text:this.cancelLabel,controls:this._cancelControls});
         _loc3_.addEventListener("press",this,"onCancelPress");
      }
      var _loc2_ = this.buttonPanel.addButton({text:this.acceptLabel,controls:this._acceptControls});
      _loc2_.addEventListener("press",this,"onAcceptPress");
      this.buttonPanel.updateButtons();
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
            if(this._bWithCancel)
            {
               this.onCancelPress();
            }
            else
            {
               this.onAcceptPress();
            }
            return true;
         }
         if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
         {
            this.onAcceptPress();
            return true;
         }
      }
      return true;
   }
   function onAcceptPress()
   {
      skse.SendModEvent("SKICP_messageDialogClosed",null,1);
      skyui.util.DialogManager.close();
   }
   function onCancelPress()
   {
      skse.SendModEvent("SKICP_messageDialogClosed",null,0);
      skyui.util.DialogManager.close();
   }
   function positionElements()
   {
      var _loc3_ = Math.max(75,this.textField.textHeight);
      this.background._height = _loc3_ + 78;
      var _loc2_ = - this.background._height / 2;
      this.seperator._y = _loc2_ + this.background._height - 50;
      this.buttonPanel._y = _loc2_ + this.background._height - 42;
      this.textField._y = _loc2_ + 14 + (_loc3_ - this.textField.textHeight) / 2;
   }
}
