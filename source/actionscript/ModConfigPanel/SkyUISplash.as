class SkyUISplash extends MovieClip
{
   var versionText;
   function SkyUISplash()
   {
      super();
   }
   function onLoad()
   {
      super.onLoad();
      this.versionText.text = "v" + SkyUISplash.SKYUI_VERSION_STRING;
   }
}
