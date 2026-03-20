class SkyUISplash extends MovieClip
{
   var versionText;
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 6;
   static var SKYUI_VERSION_MINOR = 0;
   static var SKYUI_VERSION_STRING = SkyUISplash.SKYUI_VERSION_MAJOR + "." + SkyUISplash.SKYUI_VERSION_MINOR + " SE";
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
