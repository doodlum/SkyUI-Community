class ModDetailsPage extends Components.BSUIComponent
{
   var AuthorLabel_tf;
   var AuthorName_tf;
   var Description_tf;
   var DownloadsCount_tf;
   var DownloadsLabel_tf;
   var Error_tf;
   var FavoritesCount_tf;
   var FavoritesLabel_tf;
   var FilesizeLabel_tf;
   var Filesize_tf;
   var LocalizationLabel_Downloading;
   var OptionsList_mc;
   var RatingHolder_mc;
   var ScreenshotScrollLeft;
   var ScreenshotScrollRight;
   var Screenshot_mc;
   var TextScrollDeltaAccum;
   var TextScrollDown;
   var TextScrollUp;
   var Title_tf;
   var _DataObj;
   var _MaxScreenshotIndex;
   var _OrigScreenshotHeight;
   var _OrigScreenshotWidth;
   var _RatingChanged;
   var _ScreenshotIndex;
   var _ScreenshotLoadState;
   var _ScreenshotLoader;
   var _ScreenshotStateChange;
   var _ScreenshotURL;
   var _TempRating;
   var _visible;
   var _xmouse;
   var _ymouse;
   var dispatchEvent;
   var focusEnabled;
   var hitTest;
   var onEnterFrame;
   var RIGHT_INPUT_SCROLL_THRESHOLD = 3;
   var _DlcStrings = new Array("");
   static var FOLLOW_ID = 0;
   static var UNFOLLOW_ID = 1;
   static var DOWNLOAD_ID = 2;
   static var UPDATE_ID = 3;
   static var INSTALL_ID = 4;
   static var UNINSTALL_ID = 5;
   static var DELETE_ID = 6;
   static var RATE_ID = 7;
   static var DOWNLOAD_STATUS_AVAILABLE = 0;
   static var DOWNLOAD_STATUS_QUEUE_EXCEEDED = 1;
   static var DOWNLOAD_STATUS_MOD_SLOT_EXCEEDED = 2;
   static var OUT_OF_THE_STAGE = -10000;
   var optionsList = [{text:"$Follow",id:ModDetailsPage.FOLLOW_ID},{text:"$Unfollow",id:ModDetailsPage.UNFOLLOW_ID,filterFlag:0},{text:"$Download",id:ModDetailsPage.DOWNLOAD_ID,filterFlag:0},{text:"$Update",id:ModDetailsPage.UPDATE_ID,filterFlag:0},{text:"$EnableMod",id:ModDetailsPage.INSTALL_ID,filterFlag:0},{text:"$DisableMod",id:ModDetailsPage.UNINSTALL_ID,filterFlag:0},{text:"$Delete",id:ModDetailsPage.DELETE_ID,filterFlag:0},{text:"$Rate",id:ModDetailsPage.RATE_ID,showStars:true}];
   function ModDetailsPage()
   {
      super();
      this.focusEnabled = true;
      this._TempRating = 0;
      this._RatingChanged = false;
      this.TextScrollDeltaAccum = 0;
      this._ScreenshotURL = "";
      this._ScreenshotIndex = 0;
      this._MaxScreenshotIndex = 0;
      this._ScreenshotStateChange = false;
      this._OrigScreenshotWidth = this.Screenshot_mc._width;
      this._OrigScreenshotHeight = this.Screenshot_mc._height;
      this.TextScrollUp.onRelease = Shared.Proxy.create(this,this.onTextScrollUpClicked);
      this.TextScrollDown.onRelease = Shared.Proxy.create(this,this.onTextScrollDownClicked);
      this.ScreenshotScrollLeft.onRelease = Shared.Proxy.create(this,this.onScreenshotLeftClick);
      this.ScreenshotScrollRight.onRelease = Shared.Proxy.create(this,this.onScreenshotRightClick);
      var _loc3_ = new Object();
      _loc3_.onLoadInit = Shared.Proxy.create(this,this.onScreenshotLoaded);
      this._ScreenshotLoader = new MovieClipLoader();
      this._ScreenshotLoader.addListener(_loc3_);
      this.LocalizationLabel_Downloading._x = ModDetailsPage.OUT_OF_THE_STAGE;
      this.Screenshot_mc.background_mc._visible = false;
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function handleInput(details, pathToFocus)
   {
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.UP)
         {
            this.OptionsList_mc.moveSelectionUp();
         }
         if(details.navEquivalent == gfx.ui.NavigationCode.DOWN)
         {
            this.OptionsList_mc.moveSelectionDown();
         }
         if(this.OptionsList_mc.selectedEntry.showStars)
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.LEFT && this._TempRating > 0.5 && !this.OptionsList_mc.selectedEntry.disabled)
            {
               this._TempRating = Math.min(Math.max(this._TempRating - 0.5,0.5),ModListEntry.MAX_RATING);
               this._RatingChanged = true;
               this.OptionsList_mc.selectedEntry.rating = this._TempRating;
               this.OptionsList_mc.UpdateSelectedEntry();
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT && this._TempRating < ModListEntry.MAX_RATING && !this.OptionsList_mc.selectedEntry.disabled)
            {
               this._TempRating = Math.min(Math.max(this._TempRating + 0.5,0.5),ModListEntry.MAX_RATING);
               this._RatingChanged = true;
               this.OptionsList_mc.selectedEntry.rating = this._TempRating;
               this.OptionsList_mc.UpdateSelectedEntry();
            }
         }
         else
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.LEFT)
            {
               this.onScreenshotLeftClick();
            }
            if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT)
            {
               this.onScreenshotRightClick();
            }
         }
      }
      return true;
   }
   function Init()
   {
      this.onEnterFrame = null;
      this.Screenshot_mc.background_mc._visible = false;
      var _loc2_ = new Object();
      _loc2_.onMouseWheel = Shared.Proxy.create(this,this.onMouseWheel);
      Mouse.addListener(_loc2_);
      this.OptionsList_mc.ScrollUp.onRelease = Shared.Proxy.create(this,this.onOptionsScrollUp);
      this.OptionsList_mc.ScrollDown.onRelease = Shared.Proxy.create(this,this.onOptionsScrollDown);
      this.OptionsList_mc.addEventListener("itemPress",Shared.Proxy.create(this,this.onItemPress));
      this.OptionsList_mc.addEventListener("selectionChange",Shared.Proxy.create(this,this.onSelectionChange));
      this.OptionsList_mc.UpdateList();
   }
   function get dataObj()
   {
      return this._DataObj;
   }
   function set dataObj(aObj)
   {
      if(aObj == null || !(aObj.detailedImages instanceof Array) || aObj.detailedImages.length == 0)
      {
         this._ScreenshotStateChange = this._ScreenshotURL.length > 0;
         this._ScreenshotURL = "";
      }
      else if(this._ScreenshotURL != aObj.detailedImages[this._ScreenshotIndex].imageTextureName || this._ScreenshotLoadState != aObj.detailedImages[this._ScreenshotIndex].imageLoadState)
      {
         this._ScreenshotURL = aObj.detailedImages[this._ScreenshotIndex].imageTextureName;
         this._ScreenshotLoadState = aObj.detailedImages[this._ScreenshotIndex].imageLoadState;
         this._ScreenshotStateChange = true;
      }
      var _loc2_;
      if(this._DataObj != null && aObj == null)
      {
         _loc2_ = 0;
         while(_loc2_ < this._DataObj.detailedImages.length)
         {
            if(this.CurrentScreenshotLoadedOrLoading(_loc2_))
            {
               this.dispatchEvent({type:ListEntryBase.UNREGISTER_IMAGE,target:this,data:this._DataObj.detailedImages[_loc2_]});
               this._ScreenshotLoader.unloadClip(this.Screenshot_mc.holder_mc);
            }
            _loc2_ = _loc2_ + 1;
         }
         this._ScreenshotIndex = 0;
      }
      if(this._DataObj == null && aObj != null)
      {
         this._TempRating = aObj.rating;
         this._RatingChanged = false;
         this.optionsList[ModDetailsPage.RATE_ID].rating = this._TempRating;
         this.OptionsList_mc.selectedIndex = 0;
         this.Description_tf.scrollV = 1;
      }
      this.Screenshot_mc.background_mc._visible = aObj.detailedImages === null || aObj.detailedImages.length === 0;
      this.Screenshot_mc.Spinner_mc._visible = !this.Screenshot_mc.background_mc._visible && this._ScreenshotLoadState != ListEntryBase.ILS_DOWNLOADED;
      this._DataObj = aObj;
      this.SetIsDirty();
   }
   function get selectedEntry()
   {
      return this.OptionsList_mc.selectedEntry;
   }
   function get tempRating()
   {
      return this._TempRating;
   }
   function get hasRatingChanged()
   {
      return this._RatingChanged;
   }
   function InvalidateData()
   {
      this.SetIsDirty();
   }
   function RedrawUIComponent()
   {
      super.RedrawUIComponent();
      var _loc8_;
      var _loc10_;
      var _loc4_;
      var _loc3_;
      var _loc5_;
      var _loc9_;
      var _loc7_;
      var _loc6_;
      if(this._DataObj != null)
      {
         this.Title_tf.SetText(this._DataObj.text,false);
         this.AuthorName_tf.SetText(this._DataObj.author,false);
         this.AuthorName_tf._x = this.AuthorLabel_tf._x + this.AuthorLabel_tf.textWidth + 4;
         this.DownloadsCount_tf.SetText(this._DataObj.downloads,false);
         this.DownloadsCount_tf._x = this.DownloadsLabel_tf._x + this.DownloadsLabel_tf.textWidth + 4;
         this.FavoritesCount_tf.SetText(this._DataObj.favorites,false);
         this.FavoritesCount_tf._x = this.FavoritesLabel_tf._x + this.FavoritesLabel_tf.textWidth + 4;
         this.Description_tf.text = "$Version:";
         _loc8_ = this._DataObj.releaseNotes.length <= 0 ? "" : "\n" + this._DataObj.releaseNotes;
         _loc10_ = this.Description_tf.text + this._DataObj.version + _loc8_ + "\n\n";
         _loc4_ = "";
         if(this._DataObj.requiredDlcIds != undefined && this._DataObj.requiredDlcIds.length > 0)
         {
            this.Description_tf.text = "$REQUIRED_DLC";
            _loc4_ = this.Description_tf.text + "\n";
            _loc3_ = 0;
            while(_loc3_ < this._DataObj.requiredDlcIds.length)
            {
               if(0 < this._DataObj.requiredDlcIds[_loc3_] && this._DataObj.requiredDlcIds[_loc3_] < this._DlcStrings.length)
               {
                  this.Description_tf.text = this._DlcStrings[this._DataObj.requiredDlcIds[_loc3_]];
                  _loc4_ += this.Description_tf.text + "\n";
               }
               else
               {
                  if(0 < this._DataObj.requiredDlcIds[_loc3_] == 0)
                  {
                     _loc4_ = "";
                     break;
                  }
                  trace("Unknown DLC index required for mod");
               }
               _loc3_ = _loc3_ + 1;
            }
            if(_loc4_ != "")
            {
               _loc4_ += "\n";
            }
         }
         _loc5_ = "";
         if(this._DataObj.requiredModNames != undefined && this._DataObj.requiredModNames.length > 0)
         {
            this.Description_tf.text = "$REQUIRED_MODS";
            _loc5_ = this.Description_tf.text + "<br>";
            _loc3_ = 0;
            while(_loc3_ < this._DataObj.requiredModNames.length)
            {
               _loc5_ += this._DataObj.requiredModNames[_loc3_] + "<br>";
               _loc3_ = _loc3_ + 1;
            }
            _loc5_ += "<br>";
         }
         this.Description_tf.html = true;
         this.Description_tf.SetText(_loc10_ + _loc4_ + _loc5_ + this._DataObj.description,true);
         this.UpdateTextScrollIndicators();
         this.Filesize_tf.SetText(ModUtils.GetFileSizeString(this._DataObj.fileSizeDisplay),false);
         this.FilesizeLabel_tf._x = this.Filesize_tf._x - this.Filesize_tf.textWidth - 4;
         this.RatingHolder_mc.rating = this._DataObj.rating;
         this.RatingHolder_mc.ratingCount = this._DataObj.ratingCount;
         this._MaxScreenshotIndex = !(this._DataObj.detailedImages instanceof Array) ? 0 : this._DataObj.detailedImages.length - 1;
         this.ScreenshotScrollLeft._visible = this._ScreenshotIndex > 0;
         this.ScreenshotScrollRight._visible = this._ScreenshotIndex < this._MaxScreenshotIndex;
         this.optionsList[ModDetailsPage.FOLLOW_ID].filterFlag = this._DataObj.followed == true ? 0 : 1;
         this.optionsList[ModDetailsPage.FOLLOW_ID].text = this._DataObj.followSyncing != true ? "$Follow" : "$Following";
         this.optionsList[ModDetailsPage.FOLLOW_ID].disabled = this._DataObj.authored == true;
         this.optionsList[ModDetailsPage.UNFOLLOW_ID].filterFlag = this._DataObj.followed != true ? 0 : 1;
         this.optionsList[ModDetailsPage.UNFOLLOW_ID].text = this._DataObj.followSyncing != true ? "$Unfollow" : "$Unfollowing";
         this.optionsList[ModDetailsPage.UNFOLLOW_ID].disabled = this._DataObj.authored == true;
         this.optionsList[ModDetailsPage.DOWNLOAD_ID].filterFlag = this._DataObj.downloaded == true ? 0 : 1;
         if(this._DataObj.subscribeSyncing || typeof this._DataObj.downloadProgress == "number" && this._DataObj.downloadProgress == 0)
         {
            this.optionsList[ModDetailsPage.DOWNLOAD_ID].text = "$Queued...";
         }
         else if(typeof this._DataObj.downloadProgress == "number")
         {
            this.optionsList[ModDetailsPage.DOWNLOAD_ID].text = this.LocalizationLabel_Downloading.text + " " + Math.floor(this._DataObj.downloadProgress) + "%";
         }
         else
         {
            this.optionsList[ModDetailsPage.DOWNLOAD_ID].text = "$Download";
            this.optionsList[ModDetailsPage.DOWNLOAD_ID].disabled = false;
            if(this._DataObj.canDownloadStatus != undefined)
            {
               if(this._DataObj.canDownloadStatus != ModDetailsPage.DOWNLOAD_STATUS_AVAILABLE)
               {
                  _loc9_ = this.LocalizationLabel_Downloading.text;
                  this.LocalizationLabel_Downloading.text = "$Download";
                  _loc7_ = this.LocalizationLabel_Downloading.text;
                  switch(this._DataObj.canDownloadStatus)
                  {
                     case ModDetailsPage.DOWNLOAD_STATUS_QUEUE_EXCEEDED:
                        this.LocalizationLabel_Downloading.text = "$DownloadStatus_QueueExceeded";
                        _loc6_ = this.LocalizationLabel_Downloading.text;
                        break;
                     case ModDetailsPage.DOWNLOAD_STATUS_MOD_SLOT_EXCEEDED:
                        this.LocalizationLabel_Downloading.text = "$DownloadStatus_ModSlotExceeded";
                        _loc6_ = this.LocalizationLabel_Downloading.text;
                  }
                  this.LocalizationLabel_Downloading.text = _loc9_;
                  this.optionsList[ModDetailsPage.DOWNLOAD_ID].text = _loc7_ + " (" + _loc6_ + ")";
                  this.optionsList[ModDetailsPage.DOWNLOAD_ID].disabled = true;
               }
            }
         }
         this.optionsList[ModDetailsPage.UPDATE_ID].filterFlag = !(this._DataObj.downloaded == true && this._DataObj.needsUpdate == true) ? 0 : 1;
         if(typeof this._DataObj.downloadProgress == "number")
         {
            this.optionsList[ModDetailsPage.UPDATE_ID].text = this.LocalizationLabel_Downloading.text + " " + Math.floor(this._DataObj.downloadProgress) + "%";
         }
         else
         {
            this.optionsList[ModDetailsPage.UPDATE_ID].text = "$Update";
         }
         this.optionsList[ModDetailsPage.DELETE_ID].filterFlag = this._DataObj.downloaded != true ? 0 : 1;
         this.optionsList[ModDetailsPage.DELETE_ID].text = this._DataObj.deleteSyncing != true ? "$Delete" : "$Deleting";
         this.optionsList[ModDetailsPage.RATE_ID].filterFlag = this._DataObj.downloaded != true ? 0 : 1;
         this.optionsList[ModDetailsPage.RATE_ID].disabled = this._DataObj.authored == true || this._DataObj.WIP == true;
         this.optionsList[ModDetailsPage.INSTALL_ID].filterFlag = !(this._DataObj.downloaded == true && (this._DataObj.installed != true || this._DataObj.uninstallQueued == true) && this._DataObj.installQueued != true) ? 0 : 1;
         this.optionsList[ModDetailsPage.INSTALL_ID].text = "$EnableMod";
         this.optionsList[ModDetailsPage.UNINSTALL_ID].filterFlag = !(this._DataObj.downloaded == true && (this._DataObj.installed == true || this._DataObj.installQueued == true) && this._DataObj.uninstallQueued != true) ? 0 : 1;
         this.optionsList[ModDetailsPage.UNINSTALL_ID].text = "$DisableMod";
         this.OptionsList_mc.entryList.splice(0);
         _loc3_ = 0;
         while(_loc3_ < this.optionsList.length)
         {
            if(this.optionsList[_loc3_].filterFlag != 0)
            {
               this.OptionsList_mc.entryList.push(this.optionsList[_loc3_]);
            }
            _loc3_ = _loc3_ + 1;
         }
         this.OptionsList_mc.InvalidateData();
         if(this._ScreenshotStateChange)
         {
            if(this._ScreenshotURL == "")
            {
               this.Screenshot_mc.Spinner_mc._visible = false;
               this.Screenshot_mc.Spinner_mc.gotoAndStop(1);
               this.Screenshot_mc.background_mc._visible = true;
               if(this.Screenshot_mc.holder_mc)
               {
                  this._ScreenshotLoader.unloadClip(this.Screenshot_mc.holder_mc);
               }
            }
            else if(this._ScreenshotLoadState == ListEntryBase.ILS_DOWNLOADING)
            {
               this.Screenshot_mc.Spinner_mc._visible = true;
               this.Screenshot_mc.Spinner_mc.gotoAndPlay(1);
            }
            else if(this._ScreenshotLoadState == ListEntryBase.ILS_DOWNLOADED)
            {
               this.Screenshot_mc.Spinner_mc._visible = true;
               this.Screenshot_mc.Spinner_mc.gotoAndPlay(1);
               this._ScreenshotLoader.loadClip("img://" + this._ScreenshotURL,this.Screenshot_mc.createEmptyMovieClip("holder_mc",this.Screenshot_mc.getNextHighestDepth()));
            }
            this._ScreenshotStateChange = false;
         }
         this._visible = true;
      }
      else
      {
         this._visible = false;
      }
   }
   function ShowError(astrErrorText)
   {
      this.Error_tf.SetText(astrErrorText,false);
      setTimeout(Shared.Proxy.create(this,this.onShowErrorTimerDone),2000);
   }
   function onShowErrorTimerDone()
   {
      this.Error_tf.SetText(" ",false);
   }
   function UpdateTextScrollIndicators()
   {
      this.TextScrollUp._visible = this.Description_tf.scroll > 1;
      this.TextScrollDown._visible = this.Description_tf.scroll < this.Description_tf.maxscroll;
   }
   function OnRightStickInput(afXDelta, afYDelta)
   {
      this.TextScrollDeltaAccum += Math.abs(afYDelta);
      if(this.TextScrollDeltaAccum >= this.RIGHT_INPUT_SCROLL_THRESHOLD)
      {
         this.TextScrollDeltaAccum = 0;
         if(afYDelta > 0.1)
         {
            this.Description_tf.scroll--;
         }
         if(afYDelta < -0.1)
         {
            this.Description_tf.scroll = this.Description_tf.scroll + 1;
         }
         this.UpdateTextScrollIndicators();
      }
   }
   function onTextScrollUpClicked()
   {
      this.Description_tf.scroll--;
      this.UpdateTextScrollIndicators();
   }
   function onTextScrollDownClicked()
   {
      this.Description_tf.scroll = this.Description_tf.scroll + 1;
      this.UpdateTextScrollIndicators();
   }
   function onMouseWheel(delta)
   {
      if(!this.OptionsList_mc.hitTest(this._xmouse,this._ymouse,true) && this.hitTest(this._xmouse,this._ymouse,true))
      {
         if(delta < 0)
         {
            this.Description_tf.scroll = this.Description_tf.scroll + 1;
         }
         else if(delta > 0)
         {
            this.Description_tf.scroll--;
         }
         this.UpdateTextScrollIndicators();
      }
   }
   function onOptionsScrollUp()
   {
      this.OptionsList_mc.moveSelectionUp();
   }
   function onOptionsScrollDown()
   {
      this.OptionsList_mc.moveSelectionDown();
   }
   function onScreenshotLeftClick()
   {
      if(this._ScreenshotIndex > 0)
      {
         if(this.CurrentScreenshotLoadedOrLoading(this._ScreenshotIndex))
         {
            this.dispatchEvent({type:ListEntryBase.UNREGISTER_IMAGE,target:this,data:this._DataObj.detailedImages[this._ScreenshotIndex]});
         }
         this._ScreenshotIndex = this._ScreenshotIndex - 1;
         this._ScreenshotURL = this._DataObj.detailedImages[this._ScreenshotIndex].imageTextureName;
         this._ScreenshotLoadState = this._DataObj.detailedImages[this._ScreenshotIndex].imageLoadState;
         this._ScreenshotStateChange = true;
         this.SetIsDirty();
      }
   }
   function onScreenshotRightClick()
   {
      if(this._ScreenshotIndex < this._MaxScreenshotIndex)
      {
         if(this.CurrentScreenshotLoadedOrLoading(this._ScreenshotIndex))
         {
            this.dispatchEvent({type:ListEntryBase.UNREGISTER_IMAGE,target:this,data:this._DataObj.detailedImages[this._ScreenshotIndex]});
         }
         this._ScreenshotIndex = this._ScreenshotIndex + 1;
         this._ScreenshotURL = this._DataObj.detailedImages[this._ScreenshotIndex].imageTextureName;
         this._ScreenshotLoadState = this._DataObj.detailedImages[this._ScreenshotIndex].imageLoadState;
         this._ScreenshotStateChange = true;
         this.SetIsDirty();
      }
   }
   function onScreenshotLoaded()
   {
      this.Screenshot_mc.holder_mc._width = this._OrigScreenshotWidth;
      this.Screenshot_mc.holder_mc._height = this._OrigScreenshotHeight;
      this.Screenshot_mc.Spinner_mc._visible = false;
      this.Screenshot_mc.background_mc._visible = false;
      this.dispatchEvent({type:ListEntryBase.DISPLAY_IMAGE,target:this,data:this._DataObj.detailedImages[this._ScreenshotIndex]});
   }
   function onItemPress(event)
   {
      this.dispatchEvent(event);
   }
   function onSelectionChange(event)
   {
      this.dispatchEvent({type:ModCategoryList.PLAY_SOUND,target:this,sound:"UIMenuFocus"});
   }
   function CurrentScreenshotLoadedOrLoading(index)
   {
      return (this._ScreenshotLoadState == ListEntryBase.ILS_DOWNLOADING || this._ScreenshotLoadState == ListEntryBase.ILS_DOWNLOADED) && this._DataObj.detailedImages[index].imageTextureName != undefined;
   }
}
