class ColorDialog extends OptionDialog
{
   var _defaultControls;
   var colorSwatch;
   var currentColor;
   var defaultColor;
   var leftButtonPanel;
   var platform;
   var rightButtonPanel;
   function ColorDialog()
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
         this._defaultControls = skyui.defines.Input.ReadyWeapon;
         _loc3_ = skyui.defines.Input.Tab;
      }
      else
      {
         _loc2_ = skyui.defines.Input.Accept;
         this._defaultControls = skyui.defines.Input.YButton;
         _loc3_ = skyui.defines.Input.Cancel;
      }
      this.leftButtonPanel.clearButtons();
      var _loc6_ = this.leftButtonPanel.addButton({text:"$Default",controls:this._defaultControls});
      _loc6_.addEventListener("press",this,"onDefaultPress");
      this.leftButtonPanel.updateButtons();
      this.rightButtonPanel.clearButtons();
      var _loc5_ = this.rightButtonPanel.addButton({text:"$Cancel",controls:_loc3_});
      _loc5_.addEventListener("press",this,"onCancelPress");
      var _loc4_ = this.rightButtonPanel.addButton({text:"$Accept",controls:_loc2_});
      _loc4_.addEventListener("press",this,"onAcceptPress");
      this.rightButtonPanel.updateButtons();
   }
   function initContent()
   {
      this.colorSwatch._x = (- this.colorSwatch._width) / 2;
      this.colorSwatch._y = (- this.colorSwatch._height) / 2;
      this.colorSwatch.selectedColor = this.currentColor;
      gfx.managers.FocusHandler.instance.setFocus(this.colorSwatch,0);
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
   function onAcceptPress()
   {
      skse.SendModEvent("SKICP_colorAccepted",null,this.colorSwatch.selectedColor);
      skyui.util.DialogManager.close();
   }
   function onDefaultPress()
   {
      this.colorSwatch.selectedColor = this.defaultColor;
   }
   function onCancelPress()
   {
      skse.SendModEvent("SKICP_dialogCanceled");
      skyui.util.DialogManager.close();
   }
}
