class FilterTabs extends MovieClip
{
   var LeftAnchor_mc;
   var RightAnchor_mc;
   var Selector_mc;
   var TextParent_mc;
   var _AnimationFrameCount;
   var _FrameCount;
   var _LabelBuffer;
   var _LeftButton;
   var _LeftMargin;
   var _Margin;
   var _RightButton;
   var _RightMargin;
   var _ScrollPadding;
   var _SelectorEndWidth;
   var _SelectorEndX;
   var _SelectorStartWidth;
   var _SelectorStartX;
   var _TextY;
   var _UnderlinePadding;
   var _UnderlineWidthAdd;
   var _UnselectedFade;
   var dispatchEvent;
   var onEnterFrame;
   var _Labels = new Array();
   var _CurrentIndex = -1;
   var _LeftShift = 0;
   var _platform = 0;
   var _ps3Switch = false;
   var _buttonMap = {};
   static var CC_FILTER_LEFT = {PCArt:"CCHome",XBoxArt:"CC360_LB",PS3Art:"CCPS3_LB",Label:"",KeyCode:36};
   static var CC_FILTER_RIGHT = {PCArt:"CCEnd",XBoxArt:"CC360_RB",PS3Art:"CCPS3_RB",Label:"",KeyCode:35};
   static var PLAY_SCROLL_LEFT_SOUND = "FilterTabs::PlayScrollLeftSound";
   static var PLAY_SCROLL_RIGHT_SOUND = "FilterTabs::PlayScrollRightSound";
   static var BUTTON_CLICKED = "FilterTab_ButtonClicked";
   var _LockInput = false;
   function FilterTabs()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this._LeftButton = Components.CrossPlatformButtons(this.attachMovie(this.GetButtonID(this._platform),this.GetButtonID(this._platform) + "_Left",this.getNextHighestDepth()));
      this._LeftButton.addEventListener("click",Shared.Proxy.create(this,this.ButtonClick));
      this._LeftButton.addEventListener("releaseOutside",Shared.Proxy.create(this,this.ButtonClick));
      this._LeftButton.textField.autoSize = true;
      this._LeftButton.label = "";
      this._LeftButton.SetArt(FilterTabs.CC_FILTER_LEFT);
      this._LeftButton._visible = true;
      this._LeftButton._y = this.LeftAnchor_mc._y;
      this._LeftButton.SetPlatform(this._platform,this._ps3Switch);
      this._LeftButton.textField._x = this._LeftButton.ButtonArt._x;
      this._buttonMap[this._LeftButton] = FilterTabs.CC_FILTER_LEFT;
      this._RightButton = Components.CrossPlatformButtons(this.attachMovie(this.GetButtonID(this._platform),this.GetButtonID(this._platform) + "_Right",this.getNextHighestDepth()));
      this._RightButton.addEventListener("click",Shared.Proxy.create(this,this.ButtonClick));
      this._RightButton.addEventListener("releaseOutside",Shared.Proxy.create(this,this.ButtonClick));
      this._RightButton.textField.autoSize = true;
      this._RightButton.label = "";
      this._RightButton.SetArt(FilterTabs.CC_FILTER_RIGHT);
      this._RightButton._visible = true;
      this._RightButton._y = this.RightAnchor_mc._y;
      this._RightButton.SetPlatform(this._platform,this._ps3Switch);
      this._RightButton.textField._x = this._RightButton.ButtonArt._x;
      this._buttonMap[this._RightButton] = FilterTabs.CC_FILTER_RIGHT;
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function get Index()
   {
      return this._CurrentIndex;
   }
   function Init()
   {
      this._LeftButton._x = this.LeftAnchor_mc._x + this._LeftButton.ButtonArt._width;
      this._RightButton._x = this.RightAnchor_mc._x;
      this._LeftMargin = this.LeftAnchor_mc._x + this._LeftButton.ButtonArt._width + this._Margin;
      this._RightMargin = this.RightAnchor_mc._x - this._RightButton.ButtonArt._width - this._Margin;
      this.onEnterFrame = null;
   }
   function OnUpdate()
   {
      this._FrameCount = this._FrameCount + 1;
      if(this._FrameCount >= this._AnimationFrameCount)
      {
         this.onEnterFrame = null;
         this.Selector_mc._x = this._SelectorEndX;
         this.Selector_mc._width = this._SelectorEndWidth;
      }
      else
      {
         this.Selector_mc._x = (this._SelectorEndX - this._SelectorStartX) * this._FrameCount / this._AnimationFrameCount + this._SelectorStartX;
         this.Selector_mc._width = (this._SelectorEndWidth - this._SelectorStartWidth) * this._FrameCount / this._AnimationFrameCount + this._SelectorStartWidth;
      }
   }
   function SetLabels(dataArr)
   {
      var _loc3_ = 0;
      while(_loc3_ < this._Labels.length)
      {
         this._Labels[_loc3_].removeMovieClip();
         _loc3_ = _loc3_ + 1;
      }
      this._Labels.splice(0);
      _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < dataArr.length)
      {
         _loc2_ = this.TextParent_mc.attachMovie("TabText","TabText" + _loc3_,this.TextParent_mc.getNextHighestDepth(),{_y:this._TextY});
         this._Labels.push(_loc2_);
         _loc2_.Wrapper_mc.Tab_tf.autoSize = "left";
         _loc2_.Wrapper_mc.Tab_tf.SetText(dataArr[_loc3_].text,false);
         _loc2_.WrapperBold_mc.Tab_tf.autoSize = "left";
         _loc2_.WrapperBold_mc.Tab_tf.SetText(dataArr[_loc3_].text,false);
         _loc2_.onRelease = Shared.Proxy.create(this,this.onItemPress,_loc3_);
         _loc2_._visible = dataArr[_loc3_].entries.length > 0;
         _loc2_.stop();
         _loc3_ = _loc3_ + 1;
      }
      this.OnChanged();
   }
   function OnChanged()
   {
      var _loc5_ = 0;
      var _loc4_ = 0;
      var _loc2_ = 0;
      while(_loc2_ < this._Labels.length)
      {
         if(this._Labels[_loc2_]._visible)
         {
            _loc5_ += this._Labels[_loc2_].WrapperBold_mc.Tab_tf._width;
            _loc4_ = _loc4_ + 1;
         }
         _loc2_ = _loc2_ + 1;
      }
      var _loc6_;
      var _loc3_;
      if(_loc4_ > 0)
      {
         _loc5_ += (_loc4_ - 1) * this._LabelBuffer;
         _loc6_ = this._RightMargin - this._LeftMargin;
         _loc3_ = this._LeftMargin;
         _loc2_ = 0;
         while(_loc2_ < this._Labels.length)
         {
            if(this._Labels[_loc2_]._visible)
            {
               this._Labels[_loc2_]._x = _loc3_;
               _loc3_ += this._Labels[_loc2_].WrapperBold_mc.Tab_tf._width + this._LabelBuffer;
               this._Labels[_loc2_].InputCatcher_mc._width = this._Labels[_loc2_].WrapperBold_mc.Tab_tf._width;
            }
            _loc2_ = _loc2_ + 1;
         }
      }
   }
   function SetTab(index)
   {
      var _loc8_;
      var _loc7_;
      var _loc4_;
      var _loc5_;
      var _loc2_;
      var _loc6_;
      if(0 <= index && index < this._Labels.length)
      {
         _loc8_ = index < this._CurrentIndex;
         _loc7_ = index > this._CurrentIndex;
         if(this._CurrentIndex >= 0)
         {
            this._Labels[this._CurrentIndex].gotoAndStop("Idle");
            if(_loc8_)
            {
               this.dispatchEvent({type:FilterTabs.PLAY_SCROLL_LEFT_SOUND,target:this});
            }
            else if(_loc7_)
            {
               this.dispatchEvent({type:FilterTabs.PLAY_SCROLL_RIGHT_SOUND,target:this});
            }
         }
         this._Labels[index].gotoAndStop("Selected");
         this.TextParent_mc._x = 0;
         if(_loc8_)
         {
            _loc4_ = index;
            _loc5_ = 0;
            _loc2_ = index - 1;
            while(_loc2_ >= 0)
            {
               if(this._Labels[_loc2_]._visible)
               {
                  _loc5_ = _loc5_ + 1;
                  _loc4_ = _loc2_;
                  if(_loc5_ == this._ScrollPadding)
                  {
                     break;
                  }
               }
               _loc2_ = _loc2_ - 1;
            }
            if(this._Labels[_loc4_]._x - this._LeftShift < this._LeftMargin)
            {
               this._LeftShift = this._Labels[_loc4_]._x - this._LeftMargin;
            }
         }
         else if(_loc7_)
         {
            _loc4_ = index;
            _loc5_ = 0;
            _loc2_ = index + 1;
            while(_loc2_ < this._Labels.length)
            {
               if(this._Labels[_loc2_]._visible)
               {
                  _loc5_ = _loc5_ + 1;
                  _loc4_ = _loc2_;
                  if(_loc5_ == this._ScrollPadding)
                  {
                     break;
                  }
               }
               _loc2_ = _loc2_ + 1;
            }
            if(this._Labels[_loc4_]._x + this._Labels[_loc4_].WrapperBold_mc.Tab_tf._width - this._LeftShift > this._RightMargin)
            {
               this._LeftShift = this._Labels[_loc4_]._x + this._Labels[_loc4_].WrapperBold_mc.Tab_tf._width - this._RightMargin;
               _loc2_ = 0;
               while(_loc2_ < this._Labels.length)
               {
                  if(this._Labels[_loc2_]._x - this._LeftShift >= this._LeftMargin)
                  {
                     this._LeftShift = this._Labels[_loc2_]._x - this._LeftMargin;
                     break;
                  }
                  _loc2_ = _loc2_ + 1;
               }
            }
         }
         _loc6_ = this._RightMargin;
         this.TextParent_mc._x = - this._LeftShift;
         _loc2_ = 0;
         while(_loc2_ < this._Labels.length)
         {
            if(this._Labels[_loc2_]._x + this.TextParent_mc._x < this._LeftMargin - 0.05 || this._Labels[_loc2_]._x + this.TextParent_mc._x + this._Labels[_loc2_].WrapperBold_mc.Tab_tf._width > this._RightMargin + 0.05)
            {
               this._Labels[_loc2_]._alpha = 0;
            }
            else
            {
               this._Labels[_loc2_]._alpha = 100;
               _loc6_ = this._Labels[_loc2_]._x + this.TextParent_mc._x + this._Labels[_loc2_].WrapperBold_mc.Tab_tf._width + this._Margin + this._RightButton.ButtonArt._width;
            }
            _loc2_ = _loc2_ + 1;
         }
         this._RightButton._x = _loc6_;
         if(this._CurrentIndex != -1)
         {
            this._SelectorStartX = this.Selector_mc._x;
            this._SelectorStartWidth = this.Selector_mc._width;
            this._SelectorEndX = this._Labels[index]._x + this.TextParent_mc._x + this._UnderlinePadding;
            this._SelectorEndWidth = this._Labels[index].WrapperBold_mc.Tab_tf._width - this._UnderlinePadding * 2 + this._UnderlineWidthAdd;
            this._FrameCount = 0;
            this.onEnterFrame = Shared.Proxy.create(this,this.OnUpdate);
         }
         else
         {
            this.Selector_mc._x = this._Labels[index]._x + this.TextParent_mc._x + this._UnderlinePadding;
            this.Selector_mc._width = this._Labels[index].WrapperBold_mc.Tab_tf._width - this._UnderlinePadding * 2 + this._UnderlineWidthAdd;
         }
         this._CurrentIndex = index;
         this._LeftButton._alpha = !this.CanScrollLeft() ? this._UnselectedFade : 100;
         this._RightButton._alpha = !this.CanScrollRight() ? this._UnselectedFade : 100;
      }
   }
   function CanScrollLeft()
   {
      var _loc2_ = this._CurrentIndex - 1;
      while(_loc2_ >= 0)
      {
         if(this._Labels[_loc2_]._visible)
         {
            return true;
         }
         _loc2_ = _loc2_ - 1;
      }
      return false;
   }
   function CanScrollRight()
   {
      var _loc2_ = this._CurrentIndex + 1;
      while(_loc2_ < this._Labels.length)
      {
         if(this._Labels[_loc2_]._visible)
         {
            return true;
         }
         _loc2_ = _loc2_ + 1;
      }
      return false;
   }
   function onItemPress(value1, value2, value3, index)
   {
      if(!this._LockInput)
      {
         this.SetTab(index);
         this.dispatchEvent({type:gfx.events.EventTypes.ITEM_CLICK,target:this});
      }
   }
   function ButtonClick(event)
   {
      var _loc2_;
      if(!this._LockInput)
      {
         _loc2_ = event.target;
         this.dispatchEvent({type:FilterTabs.BUTTON_CLICKED,target:this,data:this._buttonMap[_loc2_]});
      }
   }
   function LockInput(lock)
   {
      this._LeftButton._visible = !lock;
      this._RightButton._visible = !lock;
      this._alpha = !lock ? 100 : this._UnselectedFade;
      this._LockInput = lock;
   }
   function GetButtonID(platform)
   {
      return platform != 0 ? "GamepadButton" : "MouseButton";
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this._platform = aiPlatform;
      this._ps3Switch = abPS3Switch;
      this._LeftButton.SetPlatform(this._platform,this._ps3Switch);
      this._RightButton.SetPlatform(this._platform,this._ps3Switch);
   }
}
