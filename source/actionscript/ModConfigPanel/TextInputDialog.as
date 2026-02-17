class TextInputDialog extends OptionDialog
{
   var initialText;
   var platform;
   var rightButtonPanel;
   var textInput;
   function TextInputDialog()
   {
      super();
   }
   function initButtons()
   {
      var _loc2_;
      var _loc3_;
      if(this.platform == 0)
      {
         _loc2_ = skyui.defines.Input.Enter;
         _loc3_ = skyui.defines.Input.Tab;
      }
      else
      {
         _loc2_ = skyui.defines.Input.Accept;
         _loc3_ = skyui.defines.Input.Cancel;
      }
      this.rightButtonPanel.clearButtons();
      var _loc5_ = this.rightButtonPanel.addButton({text:"$Cancel",controls:_loc3_});
      _loc5_.addEventListener("press",this,"onCancelPress");
      var _loc4_ = this.rightButtonPanel.addButton({text:"$Accept",controls:_loc2_});
      _loc4_.addEventListener("press",this,"onAcceptPress");
      this.rightButtonPanel.updateButtons();
   }
   function initContent()
   {
      gfx.managers.FocusHandler.instance.setFocus(this.textInput.textField,0);
      this.textInput.focused = true;
      Selection.setFocus(this.textInput.textField);
      this.textInput.maxChars = 30;
      this.textInput.text = skyui.util.Translator.translateNested(this.initialText);
      Selection.setSelection(0,99);
      skse.AllowTextInput(true);
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
            this.onCancelPress();
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
      skse.AllowTextInput(false);
      skse.SendModEvent("SKICP_inputAccepted",this.textInput.text,0);
      skyui.util.DialogManager.close();
   }
   function onCancelPress()
   {
      skse.AllowTextInput(false);
      skse.SendModEvent("SKICP_dialogCanceled");
      skyui.util.DialogManager.close();
   }
}
