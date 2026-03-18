class CarouselButton extends NavigationButton
{
   var Border_mc;
   var Screenshot_mc;
   var Spinner_mc;
   var _Item;
   var _LoaderListener;
   var _OriginalScreenshotHeight;
   var _OriginalScreenshotWidth;
   var _ThumbnailLoaded;
   var _ThumbnailLoader;
   var _visible;
   var dispatchEvent;
   static var ILS_NOT_LOADED = 0;
   static var ILS_DOWNLOADING = 1;
   static var ILS_DOWNLOADED = 2;
   static var ILS_DISPLAYED = 3;
   static var LOAD_THUMBNAIL = "CarouselButton::loadThumbnail";
   static var UNREGISTER_IMAGE = "CarouselButton::unregisterImage";
   static var DISPLAY_IMAGE = "CarouselButton::displayImage";
   var UnregisterImage = false;
   function CarouselButton()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this._OriginalScreenshotWidth = this.Screenshot_mc._width;
      this._OriginalScreenshotHeight = this.Screenshot_mc._height;
      this._ThumbnailLoaded = false;
      this._LoaderListener = new Object();
      this._LoaderListener.onLoadInit = Shared.Proxy.create(this,this.onThumbnailLoadComplete);
      this._ThumbnailLoader = new MovieClipLoader();
   }
   function get Item()
   {
      return this._Item;
   }
   function set Item(avalue)
   {
      if(this._Item != null && avalue == null)
      {
         this.UnloadThumbnail();
      }
      else if(this._Item != null && avalue.imageTextureName != this._Item.imageTextureName)
      {
         this.UnloadThumbnail();
      }
      this._Item = avalue;
      if(this._Item != null)
      {
         if(this._Item.imageLoadState == CarouselButton.ILS_NOT_LOADED)
         {
            this.Spinner_mc._visible = true;
            this.Border_mc._visible = true;
            this.dispatchEvent({type:CarouselButton.LOAD_THUMBNAIL,target:this,data:this._Item});
         }
         if(this._Item.imageLoadState == CarouselButton.ILS_DOWNLOADED && !this._ThumbnailLoaded)
         {
            this.Spinner_mc._visible = true;
            this.Border_mc._visible = true;
            this._ThumbnailLoader.addListener(this._LoaderListener);
            this._ThumbnailLoader.loadClip("img://" + this._Item.imageTextureName,this.Screenshot_mc.Screenshot_mc);
         }
         this._visible = true;
      }
      else
      {
         this._visible = false;
      }
   }
   function onThumbnailLoadComplete(mc)
   {
      this._ThumbnailLoaded = true;
      this._ThumbnailLoader.removeListener(this._LoaderListener);
      this.Spinner_mc._visible = false;
      this.Border_mc._visible = false;
      this.Screenshot_mc.Screenshot_mc._width = this._OriginalScreenshotWidth;
      this.Screenshot_mc.Screenshot_mc._height = this._OriginalScreenshotHeight;
      this.dispatchEvent({type:CarouselButton.DISPLAY_IMAGE,target:this,data:this._Item});
   }
   function UnloadThumbnail()
   {
      if(this._Item != null)
      {
         if(this.UnregisterImage && (this._Item.imageLoadState == CarouselButton.ILS_DOWNLOADING || this._Item.imageLoadState == CarouselButton.ILS_DOWNLOADED))
         {
            this.dispatchEvent({type:CarouselButton.UNREGISTER_IMAGE,target:this,data:this._Item});
         }
         this.Spinner_mc._visible = false;
         this.Border_mc._visible = false;
         this._ThumbnailLoader.removeListener(this._LoaderListener);
         this._ThumbnailLoader.unloadClip(this.Screenshot_mc.Screenshot_mc);
         this._ThumbnailLoaded = false;
      }
   }
}
