class CCModDetails extends MovieClip
{
   var BuyNow_mc;
   var Description_tf;
   var Details_mc;
   var Error_tf;
   var Gallery_mc;
   var Gallery_tf;
   var Name_tf;
   var SaleBanner_mc;
   var Screenshot_mc;
   var ScrollDown;
   var ScrollLeft;
   var ScrollRight;
   var ScrollUp;
   var _Item;
   var _LoaderListener;
   var _OriginalScreenshotHeight;
   var _OriginalScreenshotWidth;
   var _ScrollFade;
   var _ThumbnailLoaded;
   var _ThumbnailLoader;
   var dispatchEvent;
   var onEnterFrame;
   static var ILS_NOT_LOADED = 0;
   static var ILS_DOWNLOADING = 1;
   static var ILS_DOWNLOADED = 2;
   static var ILS_DISPLAYED = 3;
   static var LOAD_THUMBNAIL = "ModDetails::loadThumbnail";
   static var UNREGISTER_IMAGE = "ModDetails::unregisterImage";
   static var DISPLAY_IMAGE = "ModDetails::displayImage";
   static var STATE_DETAILS = "STATE_DETAILS";
   static var STATE_GALLERY = "STATE_GALLERY";
   static var SCROLL_DETAILS = "ModDetails::SCROLL";
   var _CurrentState = CCModDetails.STATE_DETAILS;
   var _Timeout = null;
   static var ERROR_TEXT_TIMER = 2000;
   var eLanguage = "en";
   function CCModDetails()
   {
      super();
      this.focusEnabled = true;
      gfx.events.EventDispatcher.initialize(this);
      this.Name_tf = this.Details_mc.Name_tf;
      this.BuyNow_mc = this.Details_mc.BuyNow_mc;
      this.Description_tf = this.Details_mc.Description_tf;
      this.Screenshot_mc = this.Details_mc.Screenshot_mc;
      this.SaleBanner_mc = this.Details_mc.Screenshot_mc.SaleBanner_mc;
      this.ScrollUp = this.Details_mc.ScrollUp;
      this.ScrollDown = this.Details_mc.ScrollDown;
      this._OriginalScreenshotWidth = this.Screenshot_mc.Screenshot_mc._width;
      this._OriginalScreenshotHeight = this.Screenshot_mc.Screenshot_mc._height;
      this._ThumbnailLoaded = false;
      this._LoaderListener = new Object();
      this._LoaderListener.onLoadInit = Shared.Proxy.create(this,this.onThumbnailLoadComplete);
      this._ThumbnailLoader = new MovieClipLoader();
      this.ScrollUp.onRelease = Shared.Proxy.create(this,this.OnScrollUp);
      this.ScrollDown.onRelease = Shared.Proxy.create(this,this.OnScrollDown);
      this.ScrollLeft.onRelease = Shared.Proxy.create(this,this.OnScrollLeftClick);
      this.ScrollRight.onRelease = Shared.Proxy.create(this,this.OnScrollRightClick);
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
      var _loc3_ = new Object();
      _loc3_.onMouseWheel = Shared.Proxy.create(this,this.onMouseWheel);
      Mouse.addListener(_loc3_);
      this.Error_tf.SetText("",false);
      this.Name_tf.textAutoSize = "shrink";
      this.UpdateUpDownScroll();
   }
   function get Item()
   {
      return this._Item;
   }
   function set Item(avalue)
   {
      if(avalue == null)
      {
         trace("avalue is null in CCModDetails.as Item setter");
      }
      if(this._Item != null && avalue.imageTextureName != this._Item.imageTextureName)
      {
         this.UnloadThumbnail();
      }
      this._Item = avalue;
      if(this._Item.imageLoadState == CCModDetails.ILS_NOT_LOADED)
      {
         this.Screenshot_mc.Spinner_mc._visible = true;
         this.Screenshot_mc.Border_mc._visible = true;
         this.dispatchEvent({type:CCModDetails.LOAD_THUMBNAIL,target:this,data:this._Item});
      }
      if(this._Item.imageLoadState == CCModDetails.ILS_DOWNLOADED && !this._ThumbnailLoaded)
      {
         this.Screenshot_mc.Spinner_mc._visible = true;
         this.Screenshot_mc.Border_mc._visible = true;
         this._ThumbnailLoader.addListener(this._LoaderListener);
         this._ThumbnailLoader.loadClip("img://" + this._Item.imageTextureName,this.Screenshot_mc.Screenshot_mc);
      }
      this.Name_tf.text = this._Item.text;
      this.Description_tf.text = this._Item.description;
      if(this.SupportsPurchase() == false)
      {
         this.BuyNow_mc._visible = this._Item.owned;
      }
      this.BuyNow_mc.UpdateCreditDisplay(this._Item);
      var _loc3_;
      if(this.SupportsPurchase())
      {
         this.SaleBanner_mc._visible = this.Item.onSale;
         if(this.Item.onSale)
         {
            _loc3_ = Math.round((1 - this.Item.price / this.Item.normalPrice) * 100);
            this.SaleBanner_mc.Discount_tf.text = "$OFF";
            this.SaleBanner_mc.Discount_tf.text = _loc3_ + "% " + this.SaleBanner_mc.Discount_tf.text;
         }
      }
      else
      {
         this.SaleBanner_mc._visible = false;
      }
      this.Gallery_mc.SetFeaturedItems(this._Item.gallery,false,Selection.getFocus() != targetPath(this));
      this.Gallery_mc._visible = this._Item.gallery.length > 0;
      this.Gallery_tf._visible = this._Item.gallery.length > 0;
      if(Selection.getFocus() == targetPath(this))
      {
         this.ResetScreen();
      }
   }
   function Init()
   {
      this.Gallery_mc.addEventListener(CarouselButton.LOAD_THUMBNAIL,Shared.Proxy.create(this,this.BubbleEvent));
      this.Gallery_mc.addEventListener(CarouselButton.UNREGISTER_IMAGE,Shared.Proxy.create(this,this.BubbleEvent));
      this.Gallery_mc.addEventListener(CarouselButton.DISPLAY_IMAGE,Shared.Proxy.create(this,this.BubbleEvent));
      this.Gallery_mc.addEventListener(CCCarousel.UPDATE_SCROLL,Shared.Proxy.create(this,this.UpdateLeftRightScroll));
      this.onEnterFrame = null;
   }
   function onThumbnailLoadComplete(mc)
   {
      this._ThumbnailLoaded = true;
      this._ThumbnailLoader.removeListener(this._LoaderListener);
      this.Screenshot_mc.Spinner_mc._visible = false;
      this.Screenshot_mc.Border_mc._visible = false;
      this.Screenshot_mc.Screenshot_mc._width = this._OriginalScreenshotWidth;
      this.Screenshot_mc.Screenshot_mc._height = this._OriginalScreenshotHeight;
      this.dispatchEvent({type:CCModDetails.DISPLAY_IMAGE,target:this,data:this._Item});
   }
   function UnloadThumbnail()
   {
      if(this._Item != null)
      {
         if(this._Item.imageLoadState == CCModDetails.ILS_DOWNLOADING || this._Item.imageLoadState == CCModDetails.ILS_DOWNLOADED)
         {
            this.dispatchEvent({type:CCModDetails.UNREGISTER_IMAGE,target:this,data:this._Item});
         }
         this.Screenshot_mc.Spinner_mc._visible = false;
         this.Screenshot_mc.Border_mc._visible = false;
         this._ThumbnailLoader.removeListener(this._LoaderListener);
         this._ThumbnailLoader.unloadClip(this.Screenshot_mc.Screenshot_mc);
         this._ThumbnailLoaded = false;
      }
   }
   function handleInput(details, pathToFocus)
   {
      var _loc3_ = false;
      if(pathToFocus.length > 0)
      {
         _loc3_ = pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      if(!_loc3_ && Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.UP || details.code == 38)
         {
            this.OnScrollUp();
            _loc3_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.DOWN || details.code == 40)
         {
            this.OnScrollDown();
            _loc3_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.LEFT || details.code == 37)
         {
            this.OnScrollLeft();
            _loc3_ = true;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT || details.code == 39)
         {
            this.OnScrollRight();
            _loc3_ = true;
         }
      }
      return _loc3_;
   }
   function OnScrollUp()
   {
      if(this.Description_tf.scroll > 1)
      {
         this.Description_tf.scroll--;
      }
      this.UpdateUpDownScroll();
   }
   function OnScrollDown()
   {
      if(this.Description_tf.scroll < this.Description_tf.maxscroll)
      {
         this.Description_tf.scroll = this.Description_tf.scroll + 1;
      }
      this.UpdateUpDownScroll();
   }
   function OnScrollLeft()
   {
      if(this.ScrollLeft._visible)
      {
         this.gotoAndPlay("ToDetails");
         this._CurrentState = CCModDetails.STATE_DETAILS;
         this.Gallery_mc.Unfocus(false);
         Selection.setFocus(this);
         this.dispatchEvent({type:CCModDetails.SCROLL_DETAILS,target:this});
      }
      this.UpdateLeftRightScroll();
   }
   function OnScrollRight()
   {
      if(this.ScrollRight._visible)
      {
         this.gotoAndPlay("ToGallery");
         this._CurrentState = CCModDetails.STATE_GALLERY;
         this.Gallery_mc.Focus();
         this.dispatchEvent({type:CCModDetails.SCROLL_DETAILS,target:this});
      }
      this.UpdateLeftRightScroll();
   }
   function OnScrollLeftClick()
   {
      if(!this.Gallery_mc.DoHandleInput("",37))
      {
         this.OnScrollLeft();
      }
   }
   function OnScrollRightClick()
   {
      if(this._CurrentState == CCModDetails.STATE_DETAILS || !this.Gallery_mc.DoHandleInput("",39))
      {
         this.OnScrollRight();
      }
   }
   function ResetScreen()
   {
      this.gotoAndStop("Details");
      this._CurrentState = CCModDetails.STATE_DETAILS;
      this.Gallery_mc.Unfocus(true);
      Selection.setFocus(this);
      this.UpdateLeftRightScroll();
      this.UpdateUpDownScroll();
   }
   function UpdateUpDownScroll()
   {
      var _loc3_ = this.Description_tf.scroll > 1;
      var _loc2_ = this.Description_tf.scroll < this.Description_tf.maxscroll;
      if(!_loc3_ && !_loc2_)
      {
         this.ScrollUp._alpha = 0;
         this.ScrollDown._alpha = 0;
      }
      else
      {
         this.ScrollUp._alpha = !_loc3_ ? this._ScrollFade : 100;
         this.ScrollDown._alpha = !_loc2_ ? this._ScrollFade : 100;
      }
   }
   function UpdateLeftRightScroll()
   {
      this.ScrollLeft._visible = this._CurrentState == CCModDetails.STATE_GALLERY;
      this.ScrollRight._visible = this._Item.gallery.length > 0 && this._CurrentState == CCModDetails.STATE_DETAILS || this._CurrentState == CCModDetails.STATE_GALLERY && this.Gallery_mc.CanScrollRight();
   }
   function onMouseWheel(delta)
   {
      if(delta > 0)
      {
         this.OnScrollUp();
      }
      else
      {
         this.OnScrollDown();
      }
   }
   function BubbleEvent(event)
   {
      this.dispatchEvent({type:event.type,target:event.target,data:event.data});
   }
   function ShowError(astrErrorText)
   {
      this.Error_tf.SetText(astrErrorText,false);
      if(this._Timeout != null)
      {
         clearTimeout(this._Timeout);
      }
      this._Timeout = setTimeout(Shared.Proxy.create(this,this.HideErrorText),CCModDetails.ERROR_TEXT_TIMER);
   }
   function HideErrorText()
   {
      this.Error_tf.SetText("",false);
      if(this._Timeout != null)
      {
         clearTimeout(this._Timeout);
         this._Timeout = null;
      }
   }
   function SetFocus(focus)
   {
      if(this._CurrentState == CCModDetails.STATE_DETAILS)
      {
         Selection.setFocus(!focus ? null : this);
      }
      else
      {
         !focus ? this.Gallery_mc.Unfocus() : this.Gallery_mc.Focus();
      }
   }
   function SupportsPurchase()
   {
      if(this.eLanguage == "DD")
      {
         return false;
      }
      if(this.eLanguage == "ja")
      {
         return false;
      }
      if(this.eLanguage == "zhhant")
      {
         return false;
      }
      return true;
   }
}
