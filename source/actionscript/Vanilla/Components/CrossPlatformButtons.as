class Components.CrossPlatformButtons extends gfx.controls.Button
{
   var ButtonArt;
   var ButtonArtSecondary;
   var ButtonArtSecondary_mc;
   var ButtonArt_mc;
   var CurrentPlatform;
   var OnTextFieldChanged;
   var PCButton;
   var PS3Button;
   var PS3Swapped;
   var XBoxButton;
   var _height;
   var _parent;
   var attachMovie;
   var border;
   var getNextHighestDepth;
   var textField;
   var XBoxButtonSecondary = null;
   var PS3ButtonSecondary = null;
   var PCButtonSecondary = null;
   function CrossPlatformButtons()
   {
      super();
      this.textField.onChanged = Shared.Proxy.create(this,this.Reposition);
      gfx.io.GameDelegate.call("myLog",["CrossPlatformButtons::CrossPlatformButtons"]);
   }
   function onLoad()
   {
      super.onLoad();
      if(this._parent.onButtonLoad != undefined)
      {
         this._parent.onButtonLoad(this);
      }
      gfx.io.GameDelegate.call("myLog",["CrossPlatformButtons::onLoad"]);
   }
   function SetPlatform(aiPlatform, aSwapPS3)
   {
      gfx.io.GameDelegate.call("myLog",["CrossPlatformButtons::SetPlatform"]);
      if(aiPlatform != undefined)
      {
         this.CurrentPlatform = aiPlatform;
      }
      if(aSwapPS3 != undefined)
      {
         this.PS3Swapped = aSwapPS3;
      }
      this.RefreshArt();
   }
   function RefreshArt()
   {
      if(undefined != this.ButtonArt)
      {
         this.ButtonArt.removeMovieClip();
      }
      if(undefined != this.ButtonArtSecondary)
      {
         this.ButtonArtSecondary.removeMovieClip();
      }
      var _loc2_;
      var _loc3_;
      var _loc5_;
      var _loc4_;
      switch(this.CurrentPlatform)
      {
         case Shared.ButtonChange.PLATFORM_PC:
            if(this.PCButton != "None")
            {
               this.ButtonArt_mc = this.attachMovie(this.PCButton,"ButtonArt",this.getNextHighestDepth());
            }
            if(this.PCButtonSecondary != null)
            {
               this.ButtonArtSecondary_mc = this.attachMovie(this.PCButtonSecondary,"ButtonArtSecondary",this.getNextHighestDepth());
            }
            break;
         case Shared.ButtonChange.PLATFORM_PC_GAMEPAD:
         case Shared.ButtonChange.PLATFORM_360:
         case Shared.ButtonChange.PLATFORM_SCARLETT:
            this.ButtonArt_mc = this.attachMovie(this.XBoxButton,"ButtonArt",this.getNextHighestDepth());
            if(this.XBoxButtonSecondary != null)
            {
               this.ButtonArtSecondary_mc = this.attachMovie(this.XBoxButtonSecondary,"ButtonArtSecondary",this.getNextHighestDepth());
            }
            break;
         case Shared.ButtonChange.PLATFORM_PS3:
         case Shared.ButtonChange.PLATFORM_PROSPERO:
         default:
            _loc2_ = this.PS3Button;
            _loc3_ = this.PS3ButtonSecondary;
            gfx.io.GameDelegate.call("myLog",[String(_loc2_)]);
            if(this.PS3Swapped)
            {
               if(_loc2_ == "PS3_A")
               {
                  _loc2_ = "PS3_B";
               }
               else if(_loc2_ == "PS3_B")
               {
                  _loc2_ = "PS3_A";
               }
               if(_loc3_ == "PS3_A")
               {
                  _loc3_ = "PS3_B";
               }
               else if(_loc3_ == "PS3_B")
               {
                  _loc3_ = "PS3_A";
               }
            }
            _loc5_ = _loc2_;
            _loc4_ = _loc3_;
            if(this.CurrentPlatform == Shared.ButtonChange.PLATFORM_PROSPERO)
            {
               if(_loc2_ == "PS3_A")
               {
                  _loc2_ = "PS5_A";
               }
               else if(_loc2_ == "PS3_B")
               {
                  _loc2_ = "PS5_B";
               }
               else if(_loc2_ == "PS3_X")
               {
                  _loc2_ = "PS5_X";
               }
               else if(_loc2_ == "PS3_Y")
               {
                  _loc2_ = "PS5_Y";
               }
               else if(_loc2_ == "PS3_LT")
               {
                  _loc2_ = "PS5_LT";
               }
               else if(_loc2_ == "PS3_RT")
               {
                  _loc2_ = "PS5_RT";
               }
               else if(_loc2_ == "PS3_LB")
               {
                  _loc2_ = "PS5_LB";
               }
               else if(_loc2_ == "PS3_RB")
               {
                  _loc2_ = "PS5_RB";
               }
               else if(_loc2_ == "PS3_LTRT")
               {
                  _loc2_ = "PS5_LTRT";
               }
               else if(_loc2_ == "PS3_LS")
               {
                  _loc2_ = "PS5_LS";
               }
               else if(_loc2_ == "PS3_RS")
               {
                  _loc2_ = "PS5_RS";
               }
               else if(_loc2_ == "PS3_L3")
               {
                  _loc2_ = "PS5_L3";
               }
               else if(_loc2_ == "PS3_R3")
               {
                  _loc2_ = "PS5_R3";
               }
               else if(_loc2_ == "PS3_Back")
               {
                  _loc2_ = "PS5_Back";
               }
               else if(_loc2_ == "PS3_Start")
               {
                  _loc2_ = "PS5_Start";
               }
               if(_loc3_ == "PS3_A")
               {
                  _loc3_ = "PS5_A";
               }
               else if(_loc3_ == "PS3_B")
               {
                  _loc3_ = "PS5_B";
               }
               else if(_loc3_ == "PS3_X")
               {
                  _loc3_ = "PS5_X";
               }
               else if(_loc3_ == "PS3_Y")
               {
                  _loc3_ = "PS5_Y";
               }
               else if(_loc3_ == "PS3_LT")
               {
                  _loc3_ = "PS5_LT";
               }
               else if(_loc3_ == "PS3_RT")
               {
                  _loc3_ = "PS5_RT";
               }
               else if(_loc3_ == "PS3_LB")
               {
                  _loc3_ = "PS5_LB";
               }
               else if(_loc3_ == "PS3_RB")
               {
                  _loc3_ = "PS5_RB";
               }
               else if(_loc3_ == "PS3_LTRT")
               {
                  _loc3_ = "PS5_LTRT";
               }
               else if(_loc3_ == "PS3_LS")
               {
                  _loc3_ = "PS5_LS";
               }
               else if(_loc3_ == "PS3_RS")
               {
                  _loc3_ = "PS5_RS";
               }
               else if(_loc3_ == "PS3_L3")
               {
                  _loc3_ = "PS5_L3";
               }
               else if(_loc3_ == "PS3_R3")
               {
                  _loc3_ = "PS5_R3";
               }
               else if(_loc3_ == "PS3_Back")
               {
                  _loc3_ = "PS5_Back";
               }
               else if(_loc3_ == "PS3_Start")
               {
                  _loc3_ = "PS5_Start";
               }
            }
            gfx.io.GameDelegate.call("myLog",[String(_loc2_)]);
            this.ButtonArt_mc = this.attachMovie(_loc2_,"ButtonArt",this.getNextHighestDepth());
            if(this.ButtonArt_mc == undefined)
            {
               this.ButtonArt_mc = this.attachMovie(_loc5_,"ButtonArt",this.getNextHighestDepth());
            }
            if(_loc3_ != null)
            {
               this.ButtonArtSecondary_mc = this.attachMovie(_loc3_,"ButtonArtSecondary",this.getNextHighestDepth());
               if(this.ButtonArtSecondary_mc == undefined)
               {
                  this.ButtonArtSecondary_mc = this.attachMovie(_loc4_,"ButtonArtSecondary",this.getNextHighestDepth());
               }
            }
      }
      this.ButtonArt_mc._x -= this.ButtonArt_mc._width;
      this.ButtonArt_mc._y = (this._height - this.ButtonArt_mc._height) / 2;
      this.ButtonArtSecondary_mc._y = this.ButtonArt_mc._y;
      this.Reposition();
      this.border._visible = false;
   }
   function GetArt()
   {
      var _loc2_ = null;
      if(this.PCArtSecondary != undefined)
      {
         _loc2_ = {PCArt:this.PCButton,XBoxArt:this.XBoxButton,PS3Art:this.PS3Button,PCArtSecondary:this.PCButtonSecondary,XBoxArtSecondary:this.XBoxButtonSecondary,PS3ArtSecondary:this.PS3ButtonSecondary};
      }
      else
      {
         _loc2_ = {PCArt:this.PCButton,XBoxArt:this.XBoxButton,PS3Art:this.PS3Button};
      }
      return _loc2_;
   }
   function SetArt(aPlatformArt)
   {
      this.PCArt = aPlatformArt.PCArt;
      this.XBoxArt = aPlatformArt.XBoxArt;
      this.PS3Art = aPlatformArt.PS3Art;
      if(aPlatformArt.PCArtSecondary != undefined)
      {
         this.PCArtSecondary = aPlatformArt.PCArtSecondary;
         this.XBoxArtSecondary = aPlatformArt.XBoxArtSecondary;
         this.PS3ArtSecondary = aPlatformArt.PS3ArtSecondary;
      }
      this.RefreshArt();
   }
   function get XBoxArt()
   {
      return null;
   }
   function set XBoxArt(aValue)
   {
      if(aValue != "")
      {
         this.XBoxButton = aValue;
      }
   }
   function get XBoxArtSecondary()
   {
      return null;
   }
   function set XBoxArtSecondary(aValue)
   {
      if(aValue != "")
      {
         this.XBoxButtonSecondary = aValue;
      }
   }
   function get PS3Art()
   {
      return null;
   }
   function set PS3Art(aValue)
   {
      if(aValue != "")
      {
         this.PS3Button = aValue;
      }
   }
   function get PS3ArtSecondary()
   {
      return null;
   }
   function set PS3ArtSecondary(aValue)
   {
      if(aValue != "")
      {
         this.PS3ButtonSecondary = aValue;
      }
   }
   function get PCArt()
   {
      return null;
   }
   function set PCArt(aValue)
   {
      if(aValue != "")
      {
         this.PCButton = aValue;
      }
   }
   function get PCArtSecondary()
   {
      return null;
   }
   function set PCArtSecondary(aValue)
   {
      if(aValue != "")
      {
         this.PCButtonSecondary = aValue;
      }
   }
   function Reposition()
   {
      this.ButtonArtSecondary_mc._x = this.textField._width;
      if(this.OnTextFieldChanged != undefined)
      {
         this.OnTextFieldChanged.call();
      }
   }
}
