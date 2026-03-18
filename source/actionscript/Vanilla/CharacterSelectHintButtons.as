class CharacterSelectHintButtons extends MovieClip
{
   var DURANGO_Y;
   var KEY_T;
   var Label_mc;
   var PS_Y;
   var buttonArt_Durango;
   var buttonArt_Orbis;
   var buttonArt_keyboard;
   var dispatchEvent;
   var onPress;
   var onRollOut;
   var onRollOver;
   var textField;
   static var CONTROLLER_PC = 0;
   static var CONTROLLER_PC_GAMEPAD = 1;
   static var CONTROLLER_DURANGO = 2;
   static var CONTROLLER_ORBIS = 3;
   static var CONTROLLER_SCARLETT = 4;
   static var CONTROLLER_PROSPERO = 5;
   function CharacterSelectHintButtons()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
   }
   function SetPlatform(aiPlatform)
   {
      this.buttonArt_keyboard = this.KEY_T;
      this.buttonArt_keyboard._visible = false;
      this.buttonArt_Durango = this.DURANGO_Y;
      this.buttonArt_Durango._visible = false;
      this.buttonArt_Orbis = this.PS_Y;
      this.buttonArt_Orbis._visible = false;
      this.Label_mc = this.textField;
      this.Label_mc.text = "$CharacterSelection";
      switch(aiPlatform)
      {
         case CharacterSelectHintButtons.CONTROLLER_PC:
            this.buttonArt_keyboard._visible = true;
            this.gotoAndStop(1);
            this.EnableMouseControl();
            break;
         case CharacterSelectHintButtons.CONTROLLER_PC_GAMEPAD:
         case CharacterSelectHintButtons.CONTROLLER_DURANGO:
            this.buttonArt_Durango._visible = true;
            this.gotoAndStop(2);
            break;
         case CharacterSelectHintButtons.CONTROLLER_ORBIS:
         case CharacterSelectHintButtons.CONTROLLER_PROSPERO:
            this.buttonArt_Orbis._visible = true;
            this.gotoAndStop(2);
         default:
            return;
      }
   }
   function EnableMouseControl()
   {
      this.trackAsMenu = true;
      this.onPress = this.ButtonClick;
      this.onRollOver = this.RollOver;
      this.onRollOut = this.RollOut;
   }
   function ButtonClick(event)
   {
      this.dispatchEvent({type:"OnMousePressCharacterChange",target:this,data:[]});
   }
   function RollOver(event)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      this.gotoAndStop(2);
   }
   function RollOut()
   {
      this.gotoAndStop(1);
   }
}
