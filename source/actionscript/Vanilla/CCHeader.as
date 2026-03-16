class CCHeader extends MovieClip
{
   var Backing_mc;
   var Header_tf;
   var onEnterFrame;
   function CCHeader()
   {
      super();
      this.Header_tf.autoSize = "left";
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function Init()
   {
      if(this.Backing_mc != null)
      {
         this.Backing_mc.SetTextToFit(this.Header_tf);
      }
      this.onEnterFrame = null;
   }
}
