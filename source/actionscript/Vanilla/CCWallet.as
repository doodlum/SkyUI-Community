class CCWallet extends MovieClip
{
   var Backing_mc;
   var WalletText_tf;
   var _Credits;
   var onEnterFrame;
   function CCWallet()
   {
      super();
      this.WalletText_tf.autoSize = "left";
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function get Credits()
   {
      return this._Credits;
   }
   function set Credits(acredits)
   {
      this._Credits = acredits;
      this.WalletText_tf.text = this._Credits + "";
      if(this.Backing_mc != null)
      {
         this.Backing_mc.SetTextToFit(this.WalletText_tf);
      }
   }
   function Init()
   {
      this.onEnterFrame = null;
   }
}
