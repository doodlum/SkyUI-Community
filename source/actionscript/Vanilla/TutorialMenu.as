class TutorialMenu extends MovieClip
{
   var ButtonArtHolder;
   var ButtonHolder;
   var ButtonRect;
   var HelpScrollingText;
   var HelpText;
   var TitleText;
   function TutorialMenu()
   {
      super();
      this.HelpScrollingText = this.HelpText;
      this.ButtonHolder = this.ButtonArtHolder;
      Shared.ButtonMapping.Initialize("TutorialMenu");
   }
   function InitExtensions()
   {
      trace("TutorialMenu::InitExtensions");
      this.TitleText.textAutoSize = "shrink";
      this.ButtonRect.ExitMouseButton.addEventListener("press",this,"onExitPress");
      this.ButtonRect.ExitMouseButton.SetPlatform(0,false);
      gfx.managers.FocusHandler.instance.setFocus(this.HelpScrollingText,0);
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      trace("TutorialMenu::SetPlatform");
      this.ButtonRect.ExitGamepadButton._visible = aiPlatform != 0;
      this.ButtonRect.ExitMouseButton._visible = aiPlatform == 0;
      var _loc3_;
      if(aiPlatform != 0)
      {
         this.ButtonRect.ExitGamepadButton.SetPlatform(aiPlatform,abPS3Switch);
         this.ButtonHolder.SetPlatform(aiPlatform,abPS3Switch);
      }
      else
      {
         _loc3_ = this.ButtonRect.ExitMouseButton;
         Shared.ButtonMapping.CorrectLabel(_loc3_);
      }
   }
   function ApplyButtonArt()
   {
      trace("TutorialMenu::ApplyButtonArt");
      var _loc2_ = this.ButtonHolder.CreateButtonArt(this.HelpScrollingText.textField);
      if(_loc2_ != undefined)
      {
         this.HelpScrollingText.textField.html = true;
         this.HelpScrollingText.textField.htmlText = _loc2_;
      }
   }
   function onExitPress()
   {
      trace("TutorialMenu::onExitPress");
      gfx.io.GameDelegate.call("CloseMenu",[]);
   }
}
