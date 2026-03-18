class BuyNowButton extends WideCreditCost
{
   var Owned_mc;
   var gotoAndStop;
   function BuyNowButton()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this.Owned_mc.textAutoSize = "shrink";
   }
   function UpdateCreditDisplay(avalue)
   {
      if(avalue.owned)
      {
         if(avalue.downloadProgress != undefined)
         {
            this.gotoAndStop("Downloading");
            this.Owned_mc.SetText("$Downloading",false);
            if(avalue.bundleDownloadsFinished != undefined)
            {
               this.Owned_mc.SetText(this.Owned_mc.text + " (" + (avalue.bundleDownloadsFinished + 1) + "/" + avalue.numBundleDownloads + ")... " + avalue.downloadProgress + "%",false);
            }
            else
            {
               this.Owned_mc.SetText(this.Owned_mc.text + "... " + avalue.downloadProgress + "%",false);
            }
         }
         else if(avalue.needsUpdate)
         {
            this.gotoAndStop("Update");
         }
         else if(avalue.installed || avalue.installQueued)
         {
            this.gotoAndStop("Installed");
         }
         else
         {
            this.gotoAndStop("Download");
         }
      }
      else if(avalue.onSale)
      {
         this.gotoAndStop("Sale");
      }
      else
      {
         this.gotoAndStop("Normal");
      }
      super.UpdateCreditDisplay(avalue);
   }
}
