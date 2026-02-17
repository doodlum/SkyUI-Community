class SliderDialog extends OptionDialog
{
   var _acceptControls;
   var _cancelControls;
   var _defaultControls;
   var leftButtonPanel;
   var platform;
   var rightButtonPanel;
   var sliderDefault;
   var sliderFormatString;
   var sliderInterval;
   var sliderMax;
   var sliderMin;
   var sliderPanel;
   var sliderValue;
   function SliderDialog()
   {
      super();
   }
   function initButtons()
   {
      if(this.platform == 0)
      {
         this._acceptControls = skyui.defines.Input.Enter;
         this._defaultControls = skyui.defines.Input.ReadyWeapon;
         this._cancelControls = skyui.defines.Input.Tab;
      }
      else
      {
         this._acceptControls = skyui.defines.Input.Accept;
         this._defaultControls = skyui.defines.Input.YButton;
         this._cancelControls = skyui.defines.Input.Cancel;
      }
      this.leftButtonPanel.clearButtons();
      var _loc4_ = this.leftButtonPanel.addButton({text:"$Default",controls:this._defaultControls});
      _loc4_.addEventListener("press",this,"onDefaultPress");
      this.leftButtonPanel.updateButtons();
      this.rightButtonPanel.clearButtons();
      var _loc3_ = this.rightButtonPanel.addButton({text:"$Cancel",controls:this._cancelControls});
      _loc3_.addEventListener("press",this,"onCancelPress");
      var _loc2_ = this.rightButtonPanel.addButton({text:"$Accept",controls:this._acceptControls});
      _loc2_.addEventListener("press",this,"onAcceptPress");
      this.rightButtonPanel.updateButtons();
   }
   function initContent()
   {
      this.sliderPanel.slider.maximum = this.sliderMax;
      this.sliderPanel.slider.minimum = this.sliderMin;
      this.sliderPanel.slider.liveDragging = true;
      this.sliderPanel.slider.snapInterval = this.sliderInterval;
      this.sliderPanel.slider.snapping = true;
      this.sliderPanel.slider.value = this.sliderValue;
      this.sliderFormatString = skyui.util.Translator.translate(this.sliderFormatString);
      this.updateValueText();
      this.sliderPanel.slider.addEventListener("change",this,"onValueChange");
      gfx.managers.FocusHandler.instance.setFocus(this.sliderPanel.slider,0);
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
         if(details.control == this._defaultControls.name)
         {
            this.onDefaultPress();
            return true;
         }
      }
      return true;
   }
   function onValueChange(event)
   {
      this.sliderValue = event.target.value;
      this.updateValueText();
   }
   function onAcceptPress()
   {
      skse.SendModEvent("SKICP_sliderAccepted",null,this.sliderValue);
      skyui.util.DialogManager.close();
   }
   function onDefaultPress()
   {
      this.sliderValue = this.sliderPanel.slider.value = this.sliderDefault;
      this.updateValueText();
   }
   function onCancelPress()
   {
      skse.SendModEvent("SKICP_dialogCanceled");
      skyui.util.DialogManager.close();
   }
   function updateValueText()
   {
      var _loc2_ = !this.sliderFormatString ? Math.round(this.sliderValue * 100) / 100 : skyui.util.GlobalFunctions.formatString(this.sliderFormatString,this.sliderValue);
      this.sliderPanel.valueTextField.SetText(_loc2_);
   }
}
