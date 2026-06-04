class SkyUISplash extends MovieClip
{
  /* STAGE ELEMENTS */

    public var versionText: TextField;

    public function SkyUISplash()
    {
    }

    // @override MovieClip
    private function onLoad()
    {
        super.onLoad();

        this.versionText.text = ("v" + SkyUISplash.SKYUI_VERSION_STRING);
    }
}
