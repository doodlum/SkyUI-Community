class LoginCheckbox extends MovieClip
{
   var FocusRect_mc;
   var _Checked;
   var dispatchEvent;
   var onRelease;
   var textField;
   static var ON_CHECK = "LoginCheckbox::checked";
   function LoginCheckbox()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this._Checked = false;
      this.FocusRect_mc._visible = false;
      this.onRelease = Shared.Proxy.create(this,this.onCheckboxClicked);
      this.FocusRect_mc.focusEnabled = true;
   }
   function get text()
   {
      return this.textField.text;
   }
   function set text(value)
   {
      this.textField.SetText(value);
   }
   function get checked()
   {
      return this._Checked;
   }
   function set checked(value)
   {
      this._Checked = value;
      this.gotoAndStop(!this._Checked ? "unchecked" : "checked");
   }
   function ToggleCheckbox()
   {
      this._Checked = !this._Checked;
      this.gotoAndStop(!this._Checked ? "unchecked" : "checked");
      this.dispatchEvent({type:LoginCheckbox.ON_CHECK,target:this});
   }
   function onCheckboxClicked()
   {
      this.ToggleCheckbox();
   }
   function UpdateFocus()
   {
      this.FocusRect_mc._visible = Selection.getFocus() == targetPath(this.FocusRect_mc);
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      var _loc0_;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if((_loc0_ = details.navEquivalent) === gfx.ui.NavigationCode.GAMEPAD_Y)
         {
            this.ToggleCheckbox();
            _loc2_ = true;
         }
         if(!_loc2_)
         {
            if((_loc0_ = details.code) === 84)
            {
               this.ToggleCheckbox();
               _loc2_ = true;
            }
         }
      }
      return _loc2_;
   }
}
