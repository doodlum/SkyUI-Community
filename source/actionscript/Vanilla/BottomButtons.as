class BottomButtons extends MovieClip
{
   var _buttonBgSide;
   var _hide;
   var bg_mc;
   var dispatchEvent;
   var onEnterFrame;
   static var ACCEPT = {PCArt:"Enter",XBoxArt:"360_A",PS3Art:"PS3_A",Label:"$Accept",KeyCode:13};
   static var ENTER_TEXT = {PCArt:"Enter",XBoxArt:"360_A",PS3Art:"PS3_A",Label:"$Enter Text",KeyCode:13};
   static var CANCEL = {PCArt:"Esc",XBoxArt:"360_B",PS3Art:"PS3_B",Label:"$Back",KeyCode:9};
   static var LIBRARY_LOGIN = {PCArt:"Home",XBoxArt:"360_Y",PS3Art:"PS3_Y",Label:"$Mod_MyLibrary",KeyCode:36};
   static var LIBRARY = {PCArt:"T",XBoxArt:"360_Y",PS3Art:"PS3_Y",Label:"$Mod_MyLibrary",KeyCode:84};
   static var DETAILS = {PCArt:"Enter",XBoxArt:"360_A",PS3Art:"PS3_A",Label:"$Mod_Details",KeyCode:13};
   static var ENABLE_MOD = {PCArt:"Enter",XBoxArt:"360_A",PS3Art:"PS3_A",Label:"$Mod_LibraryEnable",KeyCode:13};
   static var REORDER_MOD = {PCArt:"X",XBoxArt:"360_X",PS3Art:"PS3_X",Label:"$Mod_Reorder",KeyCode:88};
   static var DONE_REORDER_MOD = {PCArt:"X",XBoxArt:"360_X",PS3Art:"PS3_X",Label:"$Done",KeyCode:88};
   static var DELETE_MOD = {PCArt:"T",XBoxArt:"360_Y",PS3Art:"PS3_Y",Label:"$Mod_LibraryDelete",KeyCode:84};
   static var SEARCH = {PCArt:"X",XBoxArt:"360_X",PS3Art:"PS3_X",Label:"$Mod_Search",KeyCode:88};
   static var SEARCH_CONFIRM = {PCArt:"Enter",XBoxArt:"360_A",PS3Art:"PS3_A",Label:"$Mod_Search",KeyCode:13};
   static var OPTIONS = {PCArt:"V",XBoxArt:"360_Back",PS3Art:"PS3_Back",Label:"$Mod_AccountSettings",KeyCode:86};
   static var CONFIRM = {PCArt:"Enter",XBoxArt:"360_A",PS3Art:"PS3_A",Label:"$Select",KeyCode:13};
   static var MOD_TIME_FILTER = {PCArt:"Home",PCArtSecondary:"End",XBoxArt:"360_LT",XBoxArtSecondary:"360_RT",PS3Art:"PS3_LT",PS3ArtSecondary:"PS3_RT",Label:"$TimeFilterToday",KeyCode:36,KeyCodeSecondary:35};
   static var NEW_ACCOUNT = {PCArt:"End",XBoxArt:"360_X",PS3Art:"PS3_X",Label:"$Login_CreateNew",KeyCode:35};
   static var TOGGLE = {PCArt:"T",XBoxArt:"360_Y",PS3Art:"PS3_Y",Label:"$Toggle",KeyCode:84};
   static var BUTTON_CLICKED = "BottomButtons_ButtonClicked";
   static var BUTTON_HORIZONTAL_SPACING = 26;
   static var BUTTON_UPDATE_TIMER = 70;
   var _platform = 0;
   var _ps3Switch = false;
   var _initialized = false;
   var _buttons = [];
   var _buttonMap = {};
   var _lastSetButtons = [];
   static var CENTER_ALIGN = "center";
   static var RIGHT_ALIGN = "right";
   var Align = BottomButtons.CENTER_ALIGN;
   var Margin = 60;
   var OUT_OF_THE_STAGE = -10000;
   var GamepadButton = "GamepadButton";
   var MouseButton = "MouseButton";
   var _Timeout = null;
   function BottomButtons()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this._visible = false;
      this._hide = false;
      this._buttonBgSide = this.bg_mc._width / 2;
      this._buttons = new Array();
      this._buttonMap = {};
      this._lastSetButtons = new Array();
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function Init()
   {
      this.onEnterFrame = null;
      this._initialized = true;
      this.SetPlatform(this._platform,this._ps3Switch);
   }
   function Hide(hide)
   {
      this._hide = hide;
      if(this._hide)
      {
         this._visible = false;
         if(this._Timeout != null)
         {
            clearTimeout(this._Timeout);
            this._Timeout = null;
         }
      }
      else
      {
         this._Timeout = setTimeout(Shared.Proxy.create(this,this.DelayedHide),BottomButtons.BUTTON_UPDATE_TIMER);
      }
   }
   function DelayedHide()
   {
      this._visible = !this._hide;
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this._platform = aiPlatform;
      this._ps3Switch = abPS3Switch;
      var _loc2_ = 0;
      while(_loc2_ < this._buttons.length)
      {
         this._buttons[_loc2_].SetPlatform(this._platform,this._ps3Switch);
         _loc2_ = _loc2_ + 1;
      }
   }
   function SetButtons(buttons)
   {
      var _loc6_ = buttons.length != this._lastSetButtons.length;
      var _loc3_ = 0;
      while(!_loc6_ && _loc3_ < buttons.length)
      {
         _loc6_ = buttons[_loc3_].Label != this._lastSetButtons[_loc3_].Label;
         _loc3_ = _loc3_ + 1;
      }
      var _loc5_;
      var _loc2_;
      if(_loc6_)
      {
         this._lastSetButtons = buttons;
         _loc3_ = 0;
         while(_loc3_ < this._buttons.length)
         {
            _loc5_ = this._buttons[_loc3_];
            _loc5_.removeAllEventListeners();
            _loc5_.removeMovieClip();
            _loc3_ = _loc3_ + 1;
         }
         this._buttons.splice(0);
         this._buttonMap = {};
         _loc3_ = 0;
         while(_loc3_ < buttons.length)
         {
            _loc2_ = Components.CrossPlatformButtons(this.attachMovie(this.GetButtonID(this._platform),this.GetButtonID(this._platform) + "_" + _loc3_,this.getNextHighestDepth()));
            _loc2_.addEventListener("stateChange",Shared.Proxy.create(this,this.ButtonStateChange));
            _loc2_.addEventListener("click",Shared.Proxy.create(this,this.ButtonClick));
            _loc2_.addEventListener("releaseOutside",Shared.Proxy.create(this,this.ButtonClick));
            _loc2_.OnTextFieldChanged = Shared.Proxy.create(this,this.Reposition);
            _loc2_.textField.autoSize = true;
            _loc2_.SetArt(buttons[_loc3_]);
            _loc2_.label = buttons[_loc3_].Label;
            _loc2_._visible = true;
            _loc2_._x = this.OUT_OF_THE_STAGE;
            _loc2_.SetPlatform(this._platform,this._ps3Switch);
            this._buttons.push(_loc2_);
            this._buttonMap[_loc2_] = buttons[_loc3_];
            _loc3_ = _loc3_ + 1;
         }
         if(this._buttons.length > 0)
         {
            this.Hide(false);
         }
      }
   }
   function GetButtonByIndex(index)
   {
      return this._buttons[index];
   }
   function ToggleButtonVisibleByIndex(index, visible)
   {
      var _loc2_ = this.GetButtonByIndex(index);
      _loc2_._visible = visible;
      this.Reposition();
   }
   function GetButtonID(platform)
   {
      return platform != 0 ? this.GamepadButton : this.MouseButton;
   }
   function Reposition()
   {
      var _loc7_ = 0;
      var _loc6_ = 0;
      var _loc4_ = 0;
      var _loc3_;
      while(_loc4_ < this._buttons.length)
      {
         if(this._buttons[_loc4_]._visible)
         {
            _loc3_ = this._buttons[_loc4_].getBounds(this._buttons[_loc4_]);
            _loc7_ += _loc3_.xMax - _loc3_.xMin;
            _loc6_ = _loc6_ + 1;
         }
         _loc4_ = _loc4_ + 1;
      }
      if(_loc6_ > 0)
      {
         _loc7_ += (_loc6_ - 1) * BottomButtons.BUTTON_HORIZONTAL_SPACING;
      }
      var _loc9_ = _loc7_ + this._buttonBgSide * 2;
      var _loc5_ = 0;
      switch(this.Align)
      {
         case BottomButtons.CENTER_ALIGN:
            _loc5_ = Math.round(Stage.width / 2 - _loc9_ / 2);
            break;
         case BottomButtons.RIGHT_ALIGN:
            _loc5_ = Stage.width - this.Margin - _loc9_;
      }
      this.bg_mc._x = _loc5_;
      this.bg_mc._width = _loc9_;
      var _loc8_ = this.bg_mc._y + (this.bg_mc._height - this._buttons[0]._height) / 2;
      _loc5_ += this._buttonBgSide;
      _loc4_ = 0;
      var _loc2_;
      while(_loc4_ < this._buttons.length)
      {
         _loc2_ = this._buttons[_loc4_];
         if(_loc2_._visible)
         {
            _loc3_ = _loc2_.getBounds(_loc2_);
            _loc2_._x = _loc5_ - _loc3_.xMin;
            _loc2_._y = _loc8_;
            _loc5_ += _loc3_.xMax - _loc3_.xMin + BottomButtons.BUTTON_HORIZONTAL_SPACING;
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   function ButtonStateChange(event)
   {
      var _loc1_ = event.target;
      _loc1_.textField.autoSize = true;
   }
   function ButtonClick(event)
   {
      var _loc2_ = event.target;
      this.dispatchEvent({type:BottomButtons.BUTTON_CLICKED,target:this,data:this._buttonMap[_loc2_]});
   }
}
