class SettingsOptionItem extends MovieClip
{
   var CheckBox_mc;
   var OptionStepper_mc;
   var ScrollBar_mc;
   var bSendChangeEvent;
   var checkBox;
   var iID;
   var iMovieType;
   var optionStepper;
   var scrollBar;
   var textField;
   function SettingsOptionItem()
   {
      super();
      Mouse.addListener(this);
      this.ScrollBar_mc = this.scrollBar;
      this.OptionStepper_mc = this.optionStepper;
      this.CheckBox_mc = this.checkBox;
      this.bSendChangeEvent = true;
      this.textField.textAutoSize = "shrink";
   }
   function onLoad()
   {
      this.ScrollBar_mc.setScrollProperties(0.7,0,20);
      this.ScrollBar_mc.addEventListener("scroll",this,"onScroll");
      this.OptionStepper_mc.addEventListener("change",this,"onStepperChange");
      this.bSendChangeEvent = true;
   }
   function get movieType()
   {
      return this.iMovieType;
   }
   function set movieType(aiMovieType)
   {
      this.iMovieType = aiMovieType;
      this.ScrollBar_mc.disabled = true;
      this.ScrollBar_mc.visible = false;
      this.OptionStepper_mc.disabled = true;
      this.OptionStepper_mc.visible = false;
      this.CheckBox_mc._visible = false;
      switch(this.iMovieType)
      {
         case 0:
            this.ScrollBar_mc.disabled = false;
            this.ScrollBar_mc.visible = true;
            break;
         case 1:
            this.OptionStepper_mc.disabled = false;
            this.OptionStepper_mc.visible = true;
            break;
         case 2:
            this.CheckBox_mc._visible = true;
      }
   }
   function get ID()
   {
      return this.iID;
   }
   function set ID(aiNewValue)
   {
      this.iID = aiNewValue;
   }
   function get value()
   {
      var _loc2_;
      switch(this.iMovieType)
      {
         case 0:
            _loc2_ = this.ScrollBar_mc.position / 20;
            break;
         case 1:
            _loc2_ = this.OptionStepper_mc.selectedIndex;
            break;
         case 2:
            _loc2_ = this.CheckBox_mc._currentframe - 1;
      }
      return _loc2_;
   }
   function set value(afNewValue)
   {
      switch(this.iMovieType)
      {
         case 0:
            this.bSendChangeEvent = false;
            this.ScrollBar_mc.position = afNewValue * 20;
            this.bSendChangeEvent = true;
            break;
         case 1:
            this.bSendChangeEvent = false;
            this.OptionStepper_mc.selectedIndex = afNewValue;
            this.bSendChangeEvent = true;
            break;
         case 2:
            this.CheckBox_mc.gotoAndStop(afNewValue + 1);
      }
   }
   function get text()
   {
      return this.textField.text;
   }
   function set text(astrNew)
   {
      this.textField.SetText(astrNew);
   }
   function get selected()
   {
      return this.textField._alpha == 100;
   }
   function set selected(abSelected)
   {
      this.textField._alpha = !abSelected ? 30 : 100;
      this.ScrollBar_mc._alpha = !abSelected ? 30 : 100;
      this.OptionStepper_mc._alpha = !abSelected ? 30 : 100;
      this.CheckBox_mc._alpha = !abSelected ? 30 : 100;
   }
   function handleInput(details, pathToFocus)
   {
      var _loc3_ = false;
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         switch(this.iMovieType)
         {
            case 0:
               if(details.navEquivalent == gfx.ui.NavigationCode.LEFT)
               {
                  this.ScrollBar_mc.position -= 1;
                  _loc3_ = true;
                  break;
               }
               if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT)
               {
                  this.ScrollBar_mc.position += 1;
                  _loc3_ = true;
               }
               break;
            case 1:
               if(details.navEquivalent == gfx.ui.NavigationCode.LEFT || details.navEquivalent == gfx.ui.NavigationCode.RIGHT)
               {
                  _loc3_ = this.OptionStepper_mc.handleInput(details,pathToFocus);
               }
               break;
            case 2:
               if(details.navEquivalent == gfx.ui.NavigationCode.ENTER)
               {
                  this.ToggleCheckbox();
                  _loc3_ = true;
               }
         }
      }
      return _loc3_;
   }
   function SetOptionStepperOptions(aOptions)
   {
      this.bSendChangeEvent = false;
      this.OptionStepper_mc.dataProvider = aOptions;
      this.bSendChangeEvent = true;
   }
   function onMousePress()
   {
      var _loc2_ = Mouse.getTopMostEntity();
      switch(this.iMovieType)
      {
         case 0:
            if(_loc2_ == this.ScrollBar_mc.thumb)
            {
               this.ScrollBar_mc.thumb.onPress();
            }
            else if(_loc2_._parent == this.ScrollBar_mc.upArrow)
            {
               this.ScrollBar_mc.upArrow.onPress();
            }
            else if(_loc2_._parent == this.ScrollBar_mc.downArrow)
            {
               this.ScrollBar_mc.downArrow.onPress();
            }
            else if(_loc2_ == this.ScrollBar_mc.track)
            {
               this.ScrollBar_mc.track.onPress();
            }
            break;
         case 1:
            if(_loc2_ == this.OptionStepper_mc.nextBtn || _loc2_ == this.OptionStepper_mc.textField)
            {
               this.OptionStepper_mc.nextBtn.onPress();
            }
            else if(_loc2_ == this.OptionStepper_mc.prevBtn)
            {
               this.OptionStepper_mc.prevBtn.onPress();
            }
         case 2:
         default:
            return;
      }
   }
   function onRelease()
   {
      var _loc2_ = Mouse.getTopMostEntity();
      switch(this.iMovieType)
      {
         case 0:
            if(_loc2_ == this.ScrollBar_mc.thumb)
            {
               this.ScrollBar_mc.thumb.onRelease();
            }
            else if(_loc2_._parent == this.ScrollBar_mc.upArrow)
            {
               this.ScrollBar_mc.upArrow.onRelease();
            }
            else if(_loc2_._parent == this.ScrollBar_mc.downArrow)
            {
               this.ScrollBar_mc.downArrow.onRelease();
            }
            else if(_loc2_ == this.ScrollBar_mc.track)
            {
               this.ScrollBar_mc.track.onRelease();
            }
            break;
         case 1:
            if(_loc2_ == this.OptionStepper_mc.nextBtn || _loc2_ == this.OptionStepper_mc.textField)
            {
               this.OptionStepper_mc.nextBtn.onRelease();
            }
            else if(_loc2_ == this.OptionStepper_mc.prevBtn)
            {
               this.OptionStepper_mc.prevBtn.onRelease();
            }
            break;
         case 2:
            if(_loc2_._parent == this.CheckBox_mc)
            {
               this.ToggleCheckbox();
            }
         default:
            return;
      }
   }
   function ToggleCheckbox()
   {
      if(this.CheckBox_mc._currentframe == 1)
      {
         this.CheckBox_mc.gotoAndStop(2);
      }
      else if(this.CheckBox_mc._currentframe == 2)
      {
         this.CheckBox_mc.gotoAndStop(1);
      }
      this.DoOptionChange();
   }
   function onStepperChange(event)
   {
      if(this.bSendChangeEvent)
      {
         this.DoOptionChange();
      }
   }
   function onScroll(event)
   {
      if(this.bSendChangeEvent)
      {
         this.DoOptionChange();
      }
   }
   function DoOptionChange()
   {
      gfx.io.GameDelegate.call("OptionChange",[this.ID,this.value]);
      gfx.io.GameDelegate.call("PlaySound",["UIMenuPrevNext"]);
      this._parent.onValueChange(MovieClip(this).itemIndex,this.value);
   }
}
