class CCCarousel extends MovieClip
{
   var ButtonName;
   var FeaturedItems;
   var Message_mc;
   var _ButtonsWide;
   var _CurrentButton;
   var _LeftBuffer;
   var _Message_tf;
   var _PaddingX;
   var _RightBuffer;
   var _ScrollOffset;
   var _SmallWidth;
   var _StartX;
   var _StartY;
   var dispatchEvent;
   var onEnterFrame;
   static var UPDATE_SCROLL = "CCCarousel::UpdateScroll";
   var _buttons = [];
   var _lockInput = false;
   var ScrollDirection = 0;
   var _AllowMouseFocus = false;
   var eLanguage = "en";
   function CCCarousel()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this._Message_tf = this.Message_mc.Message_tf;
      this._Message_tf.text = "";
      this._ScrollOffset = - this._LeftBuffer;
      this._buttons = new Array();
      var _loc3_ = - this._LeftBuffer;
      while(_loc3_ < this._ButtonsWide + this._RightBuffer)
      {
         this._buttons.push(this.attachMovie(this.ButtonName,"x" + _loc3_,this.getNextHighestDepth(),{_y:this._StartY,GridX:_loc3_}));
         _loc3_ = _loc3_ + 1;
      }
      this._SmallWidth = this._buttons[0].Mask_mc._width;
      this.PositionButtons();
      this.focusEnabled = true;
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function get CurrentButton()
   {
      return this._CurrentButton;
   }
   function Init()
   {
      this.InitNavigation("x0");
      this.onEnterFrame = Shared.Proxy.create(this,this.OnUpdate);
   }
   function OnUpdate()
   {
      this.PositionButtons();
   }
   function PositionButtons()
   {
      this._buttons[0]._x = this._StartX - (this._PaddingX + this._SmallWidth) * this._LeftBuffer;
      var _loc2_ = 1;
      while(_loc2_ < this._buttons.length)
      {
         this._buttons[_loc2_]._x = this._PaddingX + this._buttons[_loc2_ - 1].Mask_mc._width + this._buttons[_loc2_ - 1]._x;
         _loc2_ = _loc2_ + 1;
      }
   }
   function InitNavigation(initialButton)
   {
      var _loc3_ = this._LeftBuffer;
      var _loc4_ = this._LeftBuffer + this._ButtonsWide;
      var _loc2_ = 0;
      while(_loc2_ < this._ButtonsWide + this._LeftBuffer + this._RightBuffer)
      {
         this._buttons[_loc2_].Label = "Small_mc";
         this._buttons[_loc2_].RememberButtonSelectedFrom = false;
         if(_loc3_ <= _loc2_ && _loc2_ < _loc4_)
         {
            this.LinkNavigationSmall(_loc2_);
            this.InitializeButton(this._buttons[_loc2_]._name,initialButton == this._buttons[_loc2_]._name);
         }
         else
         {
            this.InitializeBufferButton(this._buttons[_loc2_]._name);
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function InitializeButton(buttonName, focus)
   {
      var _loc2_ = this[buttonName];
      _loc2_.OnFocus = Shared.Proxy.create(this,this.OnButtonFocus);
      _loc2_.SetFocus(focus);
      _loc2_.onRelease = Shared.Proxy.create(this,this.onEntryPress,_loc2_);
      _loc2_.onRollOver = Shared.Proxy.create(this,this.onEntryRollover,_loc2_);
      _loc2_.addEventListener(gfx.events.EventTypes.ITEM_ROLL_OVER,Shared.Proxy.create(this,this.BubbleEvent));
      _loc2_.addEventListener(CarouselButton.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.BubbleEvent));
      _loc2_.addEventListener(CarouselButton.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.BubbleEvent));
      _loc2_.addEventListener(CarouselButton.DISPLAY_IMAGE,Shared.Proxy.create(this,this.BubbleEvent));
   }
   function InitializeBufferButton(buttonName)
   {
      var _loc2_ = this[buttonName];
      _loc2_.SetFocus(false);
      _loc2_.OnFocus = Shared.Proxy.create(this,this.OnButtonFocus);
      _loc2_.addEventListener(CarouselButton.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.BubbleEvent));
      _loc2_.addEventListener(CarouselButton.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.BubbleEvent));
      _loc2_.addEventListener(CarouselButton.DISPLAY_IMAGE,Shared.Proxy.create(this,this.BubbleEvent));
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      if(pathToFocus.length > 0)
      {
         _loc2_ = pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      if(!_loc2_ && Shared.GlobalFunc.IsKeyPressed(details))
      {
         _loc2_ = this.DoHandleInput(details.navEquivalent,details.code,false);
      }
      return _loc2_;
   }
   function DoHandleInput(nav, keyCode)
   {
      var _loc2_ = false;
      if(!this._lockInput)
      {
         if(nav == gfx.ui.NavigationCode.ENTER)
         {
            this.dispatchEvent({type:gfx.events.EventTypes.ITEM_CLICK,target:this});
            _loc2_ = true;
         }
         else if(nav == gfx.ui.NavigationCode.LEFT || keyCode == 37)
         {
            if(this.CanScrollLeft())
            {
               this._lockInput = true;
               this._ScrollOffset = this._ScrollOffset - 1;
               this.ScrollDirection = -1;
               this.SetFeaturedItems(this.FeaturedItems);
               this._CurrentButton.gotoAndPlay("ToLarge");
               this._CurrentButton.RightNav.gotoAndPlay("ToSmall");
               this._parent.gotoAndPlay("SmallShiftLeft");
               this.dispatchEvent({type:CCCarousel.UPDATE_SCROLL,target:this});
               this.dispatchEvent({type:gfx.events.EventTypes.ITEM_ROLL_OVER,target:this});
               _loc2_ = true;
            }
         }
         else if(nav == gfx.ui.NavigationCode.RIGHT || keyCode == 39)
         {
            if(this.CanScrollRight())
            {
               this._lockInput = true;
               this._ScrollOffset = this._ScrollOffset + 1;
               this.ScrollDirection = 1;
               this.SetFeaturedItems(this.FeaturedItems);
               this._CurrentButton.gotoAndPlay("ToLarge");
               this._CurrentButton.LeftNav.gotoAndPlay("ToSmall");
               this._parent.gotoAndPlay("SmallShiftRight");
               this.dispatchEvent({type:CCCarousel.UPDATE_SCROLL,target:this});
               this.dispatchEvent({type:gfx.events.EventTypes.ITEM_ROLL_OVER,target:this});
               _loc2_ = true;
            }
         }
      }
      else
      {
         _loc2_ = true;
      }
      return _loc2_;
   }
   function CanScrollLeft()
   {
      return this._LeftBuffer + this._ScrollOffset > 0;
   }
   function CanScrollRight()
   {
      return this._ScrollOffset + this._LeftBuffer + this._ButtonsWide < this.FeaturedItems.length && this._CurrentButton.RightNav._visible;
   }
   function OnSmallScrollLeftFinished()
   {
      this._CurrentButton.SetFocus(true);
      this._lockInput = false;
   }
   function OnSmallScrollRightFinished()
   {
      this._CurrentButton.SetFocus(true);
      this._lockInput = false;
   }
   function OnButtonFocus(focused, button)
   {
      if(focused)
      {
         if(this._CurrentButton != button)
         {
            if(this._CurrentButton != null)
            {
               this._CurrentButton.gotoAndPlay("ToSmall");
               this._CurrentButton.SetFocus(false);
            }
            this._CurrentButton = button;
            this._CurrentButton.gotoAndPlay("ToLarge");
         }
      }
      else if(this._CurrentButton != null && this._CurrentButton == button)
      {
         this._CurrentButton.gotoAndPlay("ToSmall");
      }
   }
   function Focus()
   {
      this._AllowMouseFocus = true;
      if(this._CurrentButton == undefined || this._CurrentButton == null)
      {
         this._buttons[this._LeftBuffer].SetFocus(true);
      }
      else
      {
         this._CurrentButton.SetFocus(true);
      }
   }
   function Unfocus(resetScroll)
   {
      this._AllowMouseFocus = false;
      if(this._CurrentButton != null)
      {
         this._CurrentButton.SetFocus(false);
         this._CurrentButton.gotoAndStop("Large");
      }
      if(resetScroll)
      {
         this.SetFeaturedItems(this.FeaturedItems,true);
      }
   }
   function SetFeaturedItems(items, resetScroll, focus)
   {
      if(focus == undefined)
      {
         focus = true;
      }
      if(resetScroll)
      {
         this._ScrollOffset = - this._LeftBuffer;
      }
      this.FeaturedItems = items;
      var _loc3_ = 0;
      var _loc2_ = 0;
      while(_loc2_ < this._buttons.length)
      {
         this._buttons[_loc2_].eLanguage = this.eLanguage;
         this._buttons[_loc2_].Label = "Small_mc";
         this._buttons[_loc2_].LargeButtonOwner = null;
         this.LinkNavigationSmall(_loc2_);
         if(this._LeftBuffer <= _loc2_ && _loc2_ < this._ButtonsWide + this._LeftBuffer)
         {
            this._buttons[_loc2_].CanNavigateTo = true;
         }
         else
         {
            this._buttons[_loc2_].CanNavigateTo = false;
         }
         if(0 <= _loc3_ + this._ScrollOffset && _loc3_ + this._ScrollOffset < items.length)
         {
            if(this.ScrollDirection == 1)
            {
               if(_loc2_ == 0)
               {
                  this._buttons[_loc2_].UnregisterImage = true;
               }
               else
               {
                  this._buttons[_loc2_].UnregisterImage = false;
               }
            }
            else if(this.ScrollDirection == -1)
            {
               if(_loc2_ == this._buttons.length - 1)
               {
                  this._buttons[_loc2_].UnregisterImage = true;
               }
               else
               {
                  this._buttons[_loc2_].UnregisterImage = false;
               }
            }
            else
            {
               this._buttons[_loc2_].UnregisterImage = true;
            }
            this._buttons[_loc2_].Item = items[_loc3_ + this._ScrollOffset];
         }
         else
         {
            this._buttons[_loc2_].Item = null;
         }
         _loc3_ = _loc3_ + 1;
         _loc2_ = _loc2_ + 1;
      }
      if(this._CurrentButton != null && !this._CurrentButton._visible)
      {
         resetScroll = true;
      }
      var _loc5_;
      if(resetScroll)
      {
         _loc5_ = this._CurrentButton;
         if(_loc5_ != null)
         {
            _loc5_.SetFocus(false);
         }
         if(focus)
         {
            this._buttons[this._LeftBuffer].SetFocus(true);
         }
         if(_loc5_ != null)
         {
            _loc5_.gotoAndStop("Small");
         }
         this._CurrentButton.gotoAndStop("Large");
      }
      this.ScrollDirection = 0;
   }
   function LinkNavigationSmall(i)
   {
      if(i < this._buttons.length - 1)
      {
         this._buttons[i].RightNav = this._buttons[i + 1];
         this._buttons[i + 1].LeftNav = this._buttons[i];
      }
   }
   function onEntryRollover(value1, value2, value3, mc)
   {
      if(this._AllowMouseFocus)
      {
         if(mc.FrameLabel == "Small" || mc.FrameLabel == "Large")
         {
            if(this._CurrentButton != mc)
            {
               this.dispatchEvent({type:gfx.events.EventTypes.ITEM_ROLL_OVER,target:this});
            }
            mc.SetFocus(true);
         }
      }
   }
   function onEntryPress(value1, value2, value3, mc)
   {
      this.dispatchEvent({type:gfx.events.EventTypes.ITEM_CLICK,target:this});
   }
   function BubbleEvent(event)
   {
      this.dispatchEvent({type:event.type,target:event.target,data:event.data});
   }
   function onDataObjectChange(aUpdatedObj)
   {
      var _loc2_ = 0;
      while(_loc2_ < this._buttons.length)
      {
         if(this._buttons[_loc2_].Item == aUpdatedObj)
         {
            this._buttons[_loc2_].Item = aUpdatedObj;
            return undefined;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
}
