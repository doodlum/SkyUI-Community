class LoadWaitSpinner extends MovieClip
{
   var LoadingIconHolder;
   var bFadedIn;
   function LoadWaitSpinner()
   {
      super();
      this.bFadedIn = false;
   }
   function InitExtensions()
   {
      Shared.GlobalFunc.SetLockFunction();
      this.LoadingIconHolder.Lock("BR");
   }
   function FadeInMenu()
   {
      if(!this.bFadedIn)
      {
         this._parent.gotoAndPlay("fadeIn");
         this.bFadedIn = true;
      }
   }
   function FadeOutMenu()
   {
      if(this.bFadedIn)
      {
         this._parent.gotoAndPlay("fadeOut");
         this.bFadedIn = false;
      }
   }
}
