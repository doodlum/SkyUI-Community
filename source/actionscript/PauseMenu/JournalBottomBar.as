class JournalBottomBar extends MovieClip
{
   var ButtonRect;
   var Buttons;
   var DateText;
   var GamePadButton1_mc;
   var GamePadButton2_mc;
   var GamePadButton3_mc;
   var LevelMeterRect;
   var LevelMeter_mc;
   var MouseButton1_mc;
   var MouseButton2_mc;
   var MouseButton3_mc;
   var dispatchEvent;
   static var TAB_QUEST = 0;
   static var TAB_STATS = 1;
   static var TAB_SYSTEM = 2;
   static var PLATFORM_PC_KBMOUSE = 0;
   static var PLATFORM_PC_GAMEPAD = 1;
   static var IDX_BUTTON1 = 0;
   static var IDX_BUTTON2 = 1;
   static var IDX_BUTTON3 = 2;
   static var IDX_LASTBUTTON = JournalBottomBar.IDX_BUTTON3;
   function JournalBottomBar()
   {
      super();
      this.GamePadButton1_mc = this.ButtonRect.Button1;
      this.GamePadButton2_mc = this.ButtonRect.Button2;
      this.GamePadButton3_mc = this.ButtonRect.Button3;
      this.MouseButton1_mc = this.ButtonRect.MouseButton1;
      this.MouseButton2_mc = this.ButtonRect.MouseButton2;
      this.MouseButton3_mc = this.ButtonRect.MouseButton3;
      this.Buttons = new Array();
      this.Buttons[JournalBottomBar.IDX_BUTTON1] = undefined;
      this.Buttons[JournalBottomBar.IDX_BUTTON2] = undefined;
      this.Buttons[JournalBottomBar.IDX_BUTTON2] = undefined;
      gfx.events.EventDispatcher.initialize(this);
      Shared.ButtonMapping.Initialize("JournalBottomBar");
   }
   function InitBar()
   {
      this.LevelMeter_mc = new Components.Meter(this.LevelMeterRect.LevelProgressBar);
      gfx.io.GameDelegate.call("RequestPlayerInfo",[],this,"SetPlayerInfo");
   }
   function SetPlayerInfo()
   {
      this.DateText.SetText(arguments[0]);
      this.LevelMeterRect.LevelNumberLabel.textAutoSize = "shrink";
      this.LevelMeterRect.LevelNumberLabel.SetText(arguments[1]);
      this.LevelMeter_mc.SetPercent(arguments[2]);
   }
   function SetMode(aiTab)
   {
      trace("JournalBottomBar::SetMode " + aiTab.toString());
      this.LevelMeterRect._visible = aiTab == 1 || aiTab == 2;
      this.Buttons[JournalBottomBar.IDX_BUTTON1]._visible = this.Buttons[JournalBottomBar.IDX_BUTTON2]._visible = this.Buttons[JournalBottomBar.IDX_BUTTON3]._visible = false;
      var _loc0_;
      switch(aiTab)
      {
         case JournalBottomBar.TAB_QUEST:
            this.Buttons[JournalBottomBar.IDX_BUTTON1].label = "$Toggle Active";
            this.Buttons[JournalBottomBar.IDX_BUTTON1].SetArt({PCArt:"Enter",XBoxArt:"360_A",PS3Art:"PS3_A"});
            this.Buttons[JournalBottomBar.IDX_BUTTON2].label = "$Show on Map";
            this.Buttons[JournalBottomBar.IDX_BUTTON2].SetArt({PCArt:"M",XBoxArt:"360_X",PS3Art:"PS3_X"});
            var _temp_2 = this.Buttons[JournalBottomBar.IDX_BUTTON1];
            var _temp_1 = "_visible";
            this.Buttons[JournalBottomBar.IDX_BUTTON2]._visible = _loc0_ = true;
            _temp_2[_temp_1] = _loc0_;
            this.Buttons[JournalBottomBar.IDX_BUTTON3].visible = false;
            this.CorrectButton(JournalBottomBar.IDX_BUTTON1);
            this.CorrectButton(JournalBottomBar.IDX_BUTTON2);
            this.PositionButtons();
            break;
         case JournalBottomBar.TAB_SYSTEM:
            this.Buttons[JournalBottomBar.IDX_BUTTON1].label = "$Delete";
            this.Buttons[JournalBottomBar.IDX_BUTTON1].SetArt({PCArt:"X",XBoxArt:"360_X",PS3Art:"PS3_X"});
            this.Buttons[JournalBottomBar.IDX_BUTTON2].label = "$CharacterSelection";
            this.Buttons[JournalBottomBar.IDX_BUTTON2].SetArt({PCArt:"T",XBoxArt:"360_Y",PS3Art:"PS3_Y"});
            this.CorrectButton(JournalBottomBar.IDX_BUTTON1);
            this.CorrectButton(JournalBottomBar.IDX_BUTTON2);
            this.PositionButtons();
      }
      gfx.io.GameDelegate.call("RememberCurrentTabIndex",[aiTab]);
   }
   function PositionButtons()
   {
      var _loc2_ = 20;
      this.Buttons[JournalBottomBar.IDX_BUTTON1]._x = this.Buttons[JournalBottomBar.IDX_BUTTON1].ButtonArt._width;
      this.Buttons[JournalBottomBar.IDX_BUTTON2]._x = this.Buttons[JournalBottomBar.IDX_BUTTON1]._x + this.Buttons[JournalBottomBar.IDX_BUTTON1].textField.getLineMetrics(0).width + _loc2_ + this.Buttons[JournalBottomBar.IDX_BUTTON2].ButtonArt._width;
      this.Buttons[JournalBottomBar.IDX_BUTTON3]._x = this.Buttons[JournalBottomBar.IDX_BUTTON2]._x + this.Buttons[JournalBottomBar.IDX_BUTTON2].textField.getLineMetrics(0).width + _loc2_ + this.Buttons[JournalBottomBar.IDX_BUTTON2].ButtonArt._width;
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      trace("JournalBottomBar::SetPlatform " + aiPlatform.toString());
      var _loc3_;
      var _loc9_ = this.Buttons[JournalBottomBar.IDX_BUTTON1] != undefined || this.Buttons[JournalBottomBar.IDX_BUTTON2] != undefined || this.Buttons[JournalBottomBar.IDX_BUTTON3] && aiPlatform <= JournalBottomBar.PLATFORM_PC_GAMEPAD;
      var _loc2_;
      if(_loc9_)
      {
         _loc3_ = new Array();
         _loc2_ = JournalBottomBar.IDX_BUTTON1;
         while(_loc2_ <= JournalBottomBar.IDX_LASTBUTTON)
         {
            if(this.Buttons[_loc2_] != undefined)
            {
               _loc3_[_loc2_] = {Visible:this.Buttons[_loc2_]._visible,Label:this.Buttons[_loc2_].label,Art:this.Buttons[_loc2_].GetArt()};
            }
            _loc2_ = _loc2_ + 1;
         }
      }
      if(aiPlatform == JournalBottomBar.PLATFORM_PC_KBMOUSE)
      {
         this.GamePadButton1_mc._visible = false;
         this.GamePadButton2_mc._visible = false;
         this.GamePadButton3_mc._visible = false;
         this.MouseButton1_mc.SetPlatform(aiPlatform,abPS3Switch);
         this.MouseButton2_mc.SetPlatform(aiPlatform,abPS3Switch);
         this.MouseButton3_mc.SetPlatform(aiPlatform,abPS3Switch);
         this.Buttons[JournalBottomBar.IDX_BUTTON1] = this.MouseButton1_mc;
         this.Buttons[JournalBottomBar.IDX_BUTTON2] = this.MouseButton2_mc;
         this.Buttons[JournalBottomBar.IDX_BUTTON3] = this.MouseButton3_mc;
         this.CorrectButton(JournalBottomBar.IDX_BUTTON1);
         this.CorrectButton(JournalBottomBar.IDX_BUTTON2);
         this.CorrectButton(JournalBottomBar.IDX_BUTTON3);
         this.EnableMouseControl();
      }
      else
      {
         this.MouseButton1_mc._visible = false;
         this.MouseButton2_mc._visible = false;
         this.MouseButton3_mc._visible = false;
         this.GamePadButton1_mc.SetPlatform(aiPlatform,abPS3Switch);
         this.GamePadButton2_mc.SetPlatform(aiPlatform,abPS3Switch);
         this.GamePadButton3_mc.SetPlatform(aiPlatform,abPS3Switch);
         this.Buttons[JournalBottomBar.IDX_BUTTON1] = this.GamePadButton1_mc;
         this.Buttons[JournalBottomBar.IDX_BUTTON2] = this.GamePadButton2_mc;
         this.Buttons[JournalBottomBar.IDX_BUTTON3] = this.GamePadButton3_mc;
      }
      if(_loc9_)
      {
         _loc2_ = JournalBottomBar.IDX_BUTTON1;
         while(_loc2_ <= JournalBottomBar.IDX_LASTBUTTON)
         {
            if(this.Buttons[_loc2_] != undefined)
            {
               this.Buttons[_loc2_]._visible = _loc3_[_loc2_].Visible;
               this.Buttons[_loc2_].label = _loc3_[_loc2_].Label;
               this.Buttons[_loc2_].SetArt(_loc3_[_loc2_].Art);
            }
            _loc2_ = _loc2_ + 1;
         }
      }
   }
   function SetButtonVisibility(aiButtonIndex, abVisible, afAlpha)
   {
      var _loc2_ = aiButtonIndex - 1;
      if(abVisible != undefined)
      {
         this.Buttons[_loc2_]._visible = abVisible;
      }
      if(afAlpha != undefined)
      {
         this.Buttons[_loc2_]._alpha = afAlpha;
      }
   }
   function IsButtonVisible(aiButtonIndex)
   {
      var _loc2_ = aiButtonIndex - 1;
      return this.Buttons[_loc2_]._visible == true && this.Buttons[_loc2_]._alpha == 100;
   }
   function CorrectButton(aiButtonIndex)
   {
      trace("JournalBottomBar::CorrectButton " + aiButtonIndex.toString());
      var _loc2_ = this.Buttons[aiButtonIndex];
      Shared.ButtonMapping.CorrectLabel(_loc2_);
   }
   function SetButtonInfo(aiButtonIndex, astrText, aArtInfo)
   {
      trace("JournalBottomBar::SetButtonInfo " + aiButtonIndex.toString());
      var _loc2_ = aiButtonIndex - 1;
      this.Buttons[_loc2_].label = astrText;
      this.Buttons[_loc2_].SetArt(aArtInfo);
      this.CorrectButton(_loc2_);
      this.PositionButtons();
   }
   function EnableMouseControl()
   {
      this.Buttons[JournalBottomBar.IDX_BUTTON1].trackAsMenu = true;
      this.Buttons[JournalBottomBar.IDX_BUTTON2].trackAsMenu = true;
      this.Buttons[JournalBottomBar.IDX_BUTTON3].trackAsMenu = true;
      this.Buttons[JournalBottomBar.IDX_BUTTON1].onPress = Shared.Proxy.create(this,this.onButton1Click);
      this.Buttons[JournalBottomBar.IDX_BUTTON2].onPress = Shared.Proxy.create(this,this.onButton2Click);
      this.Buttons[JournalBottomBar.IDX_BUTTON3].onPress = Shared.Proxy.create(this,this.onButton3Click);
      this.Buttons[JournalBottomBar.IDX_BUTTON1].addEventListener("rollOver",Shared.Proxy.create(this,this.onButtonRollOver));
      this.Buttons[JournalBottomBar.IDX_BUTTON2].addEventListener("rollOver",Shared.Proxy.create(this,this.onButtonRollOver));
      this.Buttons[JournalBottomBar.IDX_BUTTON3].addEventListener("rollOver",Shared.Proxy.create(this,this.onButtonRollOver));
      this.PositionButtons();
   }
   function onButton1Click()
   {
      this.dispatchEvent({type:"OnBottomBarButtonMousePress",target:this.Buttons[JournalBottomBar.IDX_BUTTON1],data:JournalBottomBar.IDX_BUTTON1});
   }
   function onButton2Click()
   {
      this.dispatchEvent({type:"OnBottomBarButtonMousePress",target:this.Buttons[JournalBottomBar.IDX_BUTTON2],data:JournalBottomBar.IDX_BUTTON2});
   }
   function onButton3Click()
   {
      this.dispatchEvent({type:"OnBottomBarButtonMousePress",target:this.Buttons[JournalBottomBar.IDX_BUTTON3],data:JournalBottomBar.IDX_BUTTON3});
   }
   function onButtonRollOver(event)
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
   }
}
