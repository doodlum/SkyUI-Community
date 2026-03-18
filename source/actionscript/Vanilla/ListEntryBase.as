class ListEntryBase extends MovieClip
{
   var IconHolder_mc;
   var ScreenshotHolder_mc;
   var _DataObj;
   var _ItemIndex;
   var _LoaderListener;
   var _OriginalScreenshotHeight;
   var _OriginalScreenshotWidth;
   var _ThumbnailLoaded;
   var _ThumbnailLoader;
   var dispatchEvent;
   var textField;
   static var ILS_NOT_LOADED = 0;
   static var ILS_DOWNLOADING = 1;
   static var ILS_DOWNLOADED = 2;
   static var ILS_DISPLAYED = 3;
   var ICON_SPACING = 5;
   static var MAX_TEXT_LEN = 30;
   static var LOAD_THUMBNAIL = "ModListEntry::loadThumbnail";
   static var UNREGISTER_IMAGE = "ModListEntry::unregisterImage";
   static var DISPLAY_IMAGE = "ModListEntry::displayImage";
   function ListEntryBase()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this._ItemIndex = 1.7976931348623157e+308;
      this._OriginalScreenshotWidth = this.ScreenshotHolder_mc._width;
      this._OriginalScreenshotHeight = this.ScreenshotHolder_mc._height;
      this._ThumbnailLoaded = false;
      this._LoaderListener = new Object();
      this._LoaderListener.onLoadInit = Shared.Proxy.create(this,this.onThumbnailLoadComplete);
      this._ThumbnailLoader = new MovieClipLoader();
   }
   function get itemIndex()
   {
      return this._ItemIndex;
   }
   function set itemIndex(aVal)
   {
      this._ItemIndex = aVal;
   }
   function get dataObj()
   {
      return this._DataObj;
   }
   function set dataObj(aObj)
   {
      if(this._DataObj != null && aObj == null)
      {
         this.UnloadThumbnail();
      }
      else if(this._DataObj != null && aObj.imageTextureName != this._DataObj.imageTextureName)
      {
         this.UnloadThumbnail();
      }
      this._DataObj = aObj;
      if(this._DataObj != null)
      {
         if(this._DataObj.imageLoadState == ListEntryBase.ILS_NOT_LOADED)
         {
            this.ScreenshotHolder_mc.Spinner_mc._visible = true;
            this.dispatchEvent({type:ListEntryBase.LOAD_THUMBNAIL,target:this,data:this._DataObj});
         }
         if(this._DataObj.imageLoadState == ListEntryBase.ILS_DOWNLOADED && !this._ThumbnailLoaded)
         {
            this.ScreenshotHolder_mc.Spinner_mc._visible = true;
            this._ThumbnailLoader.addListener(this._LoaderListener);
            this._ThumbnailLoader.loadClip("img://" + this._DataObj.imageTextureName,this.ScreenshotHolder_mc.Screenshot_mc);
         }
      }
      this.redrawUIComponent();
   }
   function onThumbnailLoadComplete(mc)
   {
      this._ThumbnailLoaded = true;
      this._ThumbnailLoader.removeListener(this._LoaderListener);
      this.ScreenshotHolder_mc.Spinner_mc._visible = false;
      this.ScreenshotHolder_mc.Screenshot_mc._width = this._OriginalScreenshotWidth;
      this.ScreenshotHolder_mc.Screenshot_mc._height = this._OriginalScreenshotHeight;
      this.dispatchEvent({type:ListEntryBase.DISPLAY_IMAGE,target:this,data:this._DataObj});
   }
   function UnloadThumbnail()
   {
      if(this._DataObj != null)
      {
         if(this._DataObj.imageLoadState == ListEntryBase.ILS_DOWNLOADING || this._DataObj.imageLoadState == ListEntryBase.ILS_DOWNLOADED)
         {
            this.dispatchEvent({type:ListEntryBase.UNREGISTER_IMAGE,target:this,data:this._DataObj});
         }
         this.ScreenshotHolder_mc.Spinner_mc._visible = false;
         this._ThumbnailLoader.removeListener(this._LoaderListener);
         this._ThumbnailLoader.unloadClip(this.ScreenshotHolder_mc.Screenshot_mc);
         this._ThumbnailLoaded = false;
      }
   }
   function redrawUIComponent()
   {
      var _loc3_;
      var _loc2_;
      var _loc4_;
      if(this._DataObj == null)
      {
         this._visible = false;
      }
      else
      {
         if(this._DataObj.text.length < ListEntryBase.MAX_TEXT_LEN)
         {
            this.textField.SetText(this._DataObj.text);
         }
         else
         {
            this.textField.SetText(this._DataObj.text.substr(0,ListEntryBase.MAX_TEXT_LEN) + "...");
         }
         _loc3_ = 0;
         for(var _loc5_ in this.IconHolder_mc)
         {
            if(this.IconHolder_mc[_loc5_] instanceof MovieClip)
            {
               this.IconHolder_mc[_loc5_].removeMovieClip();
            }
         }
         if(this._DataObj.followed == true)
         {
            _loc2_ = this.IconHolder_mc.attachMovie("Icon_Followed","Icon",this.IconHolder_mc.getNextHighestDepth());
            _loc2_._x = _loc3_ - _loc2_._width;
            _loc3_ -= _loc2_._width + this.ICON_SPACING;
         }
         if(this._DataObj.downloaded == true)
         {
            _loc2_ = this.IconHolder_mc.attachMovie("Icon_Downloaded","Icon",this.IconHolder_mc.getNextHighestDepth());
            _loc2_._x = _loc3_ - _loc2_._width;
            _loc3_ -= _loc2_._width + this.ICON_SPACING;
         }
         if((this._DataObj.installed == true || this._DataObj.installQueued == true) && this._DataObj.uninstallQueued != true)
         {
            _loc2_ = this.IconHolder_mc.attachMovie("Icon_Installed","Icon",this.IconHolder_mc.getNextHighestDepth());
            _loc2_._x = _loc3_ - _loc2_._width;
            _loc4_ = _loc2_.transform.colorTransform;
            _loc4_.redOffset = !(this._DataObj.installQueued == true || this._DataObj.uninstallQueued == true) ? 0 : -128;
            _loc4_.greenOffset = !(this._DataObj.installQueued == true || this._DataObj.uninstallQueued == true) ? 0 : -128;
            _loc4_.blueOffset = !(this._DataObj.installQueued == true || this._DataObj.uninstallQueued == true) ? 0 : -128;
            _loc2_.transform.colorTransform = _loc4_;
            _loc3_ -= _loc2_.width + this.ICON_SPACING;
         }
         this._visible = true;
      }
   }
}
