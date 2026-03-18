class ModLibrary_ListEntry extends MovieClip
{
   var EquipIcon_mc;
   var ORIG_BORDER_HEIGHT;
   var Order_tf;
   var ScreenshotHolder_mc;
   var _DataObj;
   var _HasDynamicHeight;
   var _OriginalScreenshotHeight;
   var _OriginalScreenshotWidth;
   var _ThumbnailLoaded;
   var _ThumbnailLoader;
   var _ThumbnailLoaderListener;
   var _selected;
   var border;
   var dispatchEvent;
   var fileSize_tf;
   var textField;
   static var MAX_TEXT_LEN = 30;
   function ModLibrary_ListEntry()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      _global.gfxExtensions = true;
      this.ORIG_BORDER_HEIGHT = this.border == null ? 0 : this.border.height;
      this._HasDynamicHeight = false;
      this._ThumbnailLoaded = false;
      this._OriginalScreenshotWidth = this.ScreenshotHolder_mc._width / (this.ScreenshotHolder_mc._xscale / 100);
      this._OriginalScreenshotHeight = this.ScreenshotHolder_mc._height / (this.ScreenshotHolder_mc._yscale / 100);
      this._ThumbnailLoaderListener = new Object();
      this._ThumbnailLoaderListener.onLoadInit = Shared.Proxy.create(this,this.onThumbnailLoadComplete);
      this._ThumbnailLoader = new MovieClipLoader();
      this._ThumbnailLoader.addListener(this._ThumbnailLoaderListener);
   }
   function get selected()
   {
      return this._selected;
   }
   function set selected(flag)
   {
      this._selected = flag;
   }
   function SetEntryData(aEntryObject, selected)
   {
      if(aEntryObject.text.length >= ModLibrary_ListEntry.MAX_TEXT_LEN)
      {
         this.textField.SetText(aEntryObject.text.substr(0,ModLibrary_ListEntry.MAX_TEXT_LEN) + "...",false);
      }
      this.fileSize_tf.SetText(ModUtils.GetFileSizeString(aEntryObject.fileSizeDisplay),false);
      if(this._DataObj != null && aEntryObject.dataObj == null)
      {
         this.UnloadThumbnail();
      }
      else if(this._DataObj != null && aEntryObject.dataObj.imageTextureName != this._DataObj.imageTextureName)
      {
         this.UnloadThumbnail();
      }
      this._DataObj = typeof aEntryObject.dataObj != "object" ? null : aEntryObject.dataObj;
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
            this._ThumbnailLoader.addListener(this._ThumbnailLoaderListener);
            this._ThumbnailLoader.loadClip("img://" + this._DataObj.imageTextureName,this.ScreenshotHolder_mc.Screenshot_mc);
         }
      }
      else
      {
         this.ScreenshotHolder_mc.Spinner_mc._visible = false;
      }
      this.EquipIcon_mc._visible = aEntryObject.checked == true;
      var _loc2_ = this.transform.colorTransform;
      _loc2_.redOffset = !aEntryObject.disabled ? 0 : -128;
      _loc2_.greenOffset = !aEntryObject.disabled ? 0 : -128;
      _loc2_.blueOffset = !aEntryObject.disabled ? 0 : -128;
      this.transform.colorTransform = _loc2_;
      _loc2_ = this.EquipIcon_mc.transform.colorTransform;
      _loc2_.redOffset = !selected ? 0 : -255;
      _loc2_.greenOffset = !selected ? 0 : -255;
      _loc2_.blueOffset = !selected ? 0 : -255;
      this.EquipIcon_mc.transform.colorTransform = _loc2_;
      this.Order_tf.textColor = !this.selected ? 16777215 : 0;
      this.textField.textColor = !selected ? 16777215 : 0;
      this.fileSize_tf.textColor = !selected ? 16777215 : 0;
      this.border._alpha = !selected ? 0 : 100;
   }
   function LoadThumbnail()
   {
      if(this._DataObj != null)
      {
         if(this._DataObj.imageLoadState == ListEntryBase.ILS_NOT_LOADED)
         {
            this.dispatchEvent({type:ListEntryBase.LOAD_THUMBNAIL,target:this,data:this._DataObj});
         }
         if(this._DataObj.imageLoadState == ListEntryBase.ILS_DOWNLOADED && !this._ThumbnailLoaded)
         {
            this._ThumbnailLoader.loadClip("img://" + this._DataObj.imageTextureName,this.ScreenshotHolder_mc.Screenshot_mc);
         }
      }
      else
      {
         this.ScreenshotHolder_mc.Spinner_mc._visible = false;
      }
   }
   function onThumbnailLoadComplete(mc)
   {
      this._ThumbnailLoaded = true;
      this._ThumbnailLoader.removeListener(this._ThumbnailLoaderListener);
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
         this._ThumbnailLoader.removeListener(this._ThumbnailLoaderListener);
         this._ThumbnailLoader.unloadClip(this.ScreenshotHolder_mc.Screenshot_mc);
         this._ThumbnailLoaded = false;
      }
   }
}
