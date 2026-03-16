class BookBottomBar extends MovieClip
{
   var ButtonRect;
   var PageTurnButton;
   var TakeButton;
   function BookBottomBar()
   {
      super();
      this.PageTurnButton = this.ButtonRect.TurnPageButtonInstance;
      this.TakeButton = this.ButtonRect.TakeButtonInstance;
   }
   function InitExtensions()
   {
      Stage.scaleMode = "showAll";
      gfx.io.GameDelegate.addCallBack("ShowTakeButton",this,"ShowTakeButton");
      Shared.GlobalFunc.SetLockFunction();
      MovieClip(this).Lock("B");
      this._y -= 3;
   }
   function ShowTakeButton(abShow, abSteal)
   {
      this.TakeButton.visible = abShow;
      this.TakeButton.label = !abSteal ? "$Take" : "$Steal";
   }
   function SetPlatform(aiPlatformIndex, abPS3Switch)
   {
      this.PageTurnButton.SetPlatform(aiPlatformIndex,abPS3Switch);
      this.TakeButton.SetPlatform(aiPlatformIndex,abPS3Switch);
   }
}
