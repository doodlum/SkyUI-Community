class BethesdaNetLogin extends MovieClip
{
   var AcceptButton;
   var CancelButton;
   var CreateAccountButton;
   var EULAPage_mc;
   var EULAPagesA;
   var EmailButton;
   var EnterTextButton;
   var Error_NotSignedInOrbis;
   var EulaButton;
   var LibraryButton;
   var LoginPage_mc;
   var NewAccountPage_mc;
   var NextButton;
   var SkipButton;
   var Spinner_mc;
   var UseSkipInsteadOfCancel;
   var _CurrEULAIndex;
   var _LastLoginScreen;
   var _QuickAcctAcceptedEULAIDs;
   var _ViewingEulaWithoutAcceptance;
   var _currentScreen;
   var bottomButtons;
   var codeObj;
   var dispatchEvent;
   var iPlatform;
   var onEnterFrame;
   var ps3Switch;
   static var CONTROLLER_PC = 0;
   static var CONTROLLER_PCGAMEPAD = 1;
   static var CONTROLLER_DURANGO = 2;
   static var CONTROLLER_ORBIS = 3;
   static var CONTROLLER_SCARLETT = 4;
   static var CONTROLLER_PROSPERO = 5;
   static var LOGIN_ACTIVATED = "BethesdaNetLogin.LoginActivated";
   static var LOGIN_CANCELED = "BethesdaNetLogin.LoginCanceled";
   static var LOGIN_ERROR = "BethesdaNetLogin.LoginError";
   static var EULA_CANCELED = "BethesdaNetLogin.EulaCanceled";
   static var VIEW_EULA = {PCArt:"End",XBoxArt:"360_X",PS3Art:"PS3_X",Label:"$View Eula",KeyCode:35};
   static var ENTER_TEXT = {PCArt:"End",XBoxArt:"360_RB",PS3Art:"PS3_RB",Label:"$Enter Text",KeyCode:0};
   static var NEXT = {PCArt:"Enter",XBoxArt:"360_A",PS3Art:"PS3_A",Label:"$Next",KeyCode:13};
   static var CONSOLE_EMAIL = {PCArt:"Enter",XBoxArt:"360_A",PS3Art:"PS3_A",Label:"$USE CONSOLE EMAIL",KeyCode:13};
   static var CREATE_ACCOUNT = {PCArt:"Enter",XBoxArt:"360_A",PS3Art:"PS3_A",Label:"$CREATE ACCOUNT",KeyCode:13};
   static var SKIP = {PCArt:"Esc",XBoxArt:"360_B",PS3Art:"PS3_B",Label:"$Skip",KeyCode:9};
   var DefaultEmail = "";
   var constructed = false;
   var GetNewsByDefault = false;
   var _lastQuickAccountFocus = null;
   var ShowLoadOrderButton = true;
   var _QueuedButtonUpdate = false;
   function BethesdaNetLogin()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      _global.gfxExtensions = true;
      Shared.GlobalFunc.MaintainTextFormat();
      this.constructed = true;
      this._QuickAcctAcceptedEULAIDs = new Array();
      this.EULAPagesA = new Array();
      this.Error_NotSignedInOrbis._visible = false;
      this.EULAPage_mc.focusEnabled = true;
      var _loc4_ = new Object();
      _loc4_.onMouseWheel = Shared.Proxy.create(this,this.onMouseWheel);
      Mouse.addListener(_loc4_);
      this.EULAPage_mc.ScrollUp.onRelease = Shared.Proxy.create(this,this.onEULAScrollUpClicked);
      this.EULAPage_mc.ScrollDown.onRelease = Shared.Proxy.create(this,this.onEULAScrollDownClicked);
      this.UpdateEULAScrollIndicators();
      this.NewAccountPage_mc.Error_tf.textAutoSize = "shrink";
      this.NewAccountPage_mc.LoginHeader_tf.textAutoSize = "shrink";
      this._LastLoginScreen = this.NewAccountPage_mc;
   }
   function get Constructed()
   {
      return this.constructed;
   }
   function get CodeObject()
   {
      return this.codeObj;
   }
   function set CodeObject(value)
   {
      this.codeObj = value;
   }
   function ShowLoginScreen(aUserName, strError)
   {
      this.ShowCurrentScreen(this.LoginPage_mc);
      if(this.iPlatform == BethesdaNetLogin.CONTROLLER_PC || this.iPlatform == BethesdaNetLogin.CONTROLLER_PCGAMEPAD)
      {
         this.codeObj.startEditText();
      }
      this.dispatchEvent({type:BethesdaNetLogin.LOGIN_ACTIVATED,target:this});
      if(aUserName != undefined)
      {
         this.LoginPage_mc.UsernameInput_tf.text = aUserName;
      }
      else
      {
         this.LoginPage_mc.UsernameInput_tf.text = "";
      }
      this.LoginPage_mc.UsernameInput_tf.onChanged = Shared.Proxy.create(this,this.OnUsernameFieldUpdate);
      this.LoginPage_mc.PasswordInput_tf.text = "";
      this.LoginPage_mc.PasswordInput_tf.onChanged = Shared.Proxy.create(this,this.OnPasswordFieldUpdate);
      this.LoginPage_mc.UsernameGrayText_tf._visible = this.LoginPage_mc.UsernameInput_tf.text.length <= 0;
      this.LoginPage_mc.PasswordGrayText_tf._visible = this.LoginPage_mc.PasswordInput_tf.text.length <= 0;
      Selection.setFocus(this.LoginPage_mc.UsernameInput_tf);
      if(strError != undefined)
      {
         this.LoginPage_mc.Error_tf.text = "$LoginError_" + strError;
      }
      else
      {
         this.LoginPage_mc.Error_tf.text = "";
      }
      this._LastLoginScreen = this.LoginPage_mc;
      this.codeObj.onLoginScreenOpen();
   }
   function ReenterLogin()
   {
      if(this.LoginPage_mc == this._LastLoginScreen)
      {
         this.ShowLoginScreen(this.LoginPage_mc.UsernameInput_tf.text);
      }
      else if(this.NewAccountPage_mc == this._LastLoginScreen)
      {
         this.ShowNewAccountPage(this.NewAccountPage_mc.NewEmailInput_tf.text);
      }
   }
   function SetLoginInfo(vars)
   {
      var _loc2_ = vars[0];
      var _loc3_ = vars[1];
      this.LoginPage_mc.UsernameInput_tf.text = _loc2_;
      this.LoginPage_mc.PasswordInput_tf.text = _loc3_;
      this.LoginPage_mc.UsernameGrayText_tf._visible = this.LoginPage_mc.UsernameInput_tf.text.length <= 0;
      this.LoginPage_mc.PasswordGrayText_tf._visible = this.LoginPage_mc.PasswordInput_tf.text.length <= 0;
   }
   function ShowLoginScreen_AfterFailure(strErrorString)
   {
      this.dispatchEvent({type:BethesdaNetLogin.LOGIN_ERROR,target:this});
      this.dispatchEvent({type:BethesdaNetLogin.LOGIN_ACTIVATED,target:this});
      if(this.LoginPage_mc == this._LastLoginScreen)
      {
         this.ShowLoginScreen(this.LoginPage_mc.UsernameInput_tf.text,strErrorString);
      }
      else if(this.NewAccountPage_mc == this._LastLoginScreen)
      {
         this.ShowNewAccountPage(this.NewAccountPage_mc.NewEmailInput_tf.text,strErrorString);
      }
   }
   function ShowSpinner(aMessageText)
   {
      this.ShowCurrentScreen(this.Spinner_mc);
      this.dispatchEvent({type:BethesdaNetLogin.LOGIN_ACTIVATED,target:this});
      this.Spinner_mc.textField.SetText(aMessageText,false);
      Selection.setFocus(undefined);
   }
   function onEULAPopulated()
   {
      this.ShowCurrentScreen(this.EULAPage_mc);
      this._CurrEULAIndex = 0;
      this._QuickAcctAcceptedEULAIDs.splice(0);
      Selection.setFocus(this.EULAPage_mc);
      this.LoadEULAPage();
   }
   function onVKBTextEntered(astrEnteredText)
   {
      if(astrEnteredText.length > 0)
      {
         if(Selection.getFocus() == targetPath(this.LoginPage_mc.UsernameInput_tf))
         {
            this.LoginPage_mc.UsernameInput_tf.SetText(astrEnteredText,false);
            Selection.setFocus(this.LoginPage_mc.PasswordInput_tf);
            this.LoginPage_mc.PasswordGrayText_tf._visible = false;
            setTimeout(Shared.Proxy.create(this,this.onNextEditTimerDone),1000);
         }
         else if(Selection.getFocus() == targetPath(this.LoginPage_mc.PasswordInput_tf))
         {
            this.LoginPage_mc.PasswordInput_tf.SetText(astrEnteredText,false);
         }
         else if(Selection.getFocus() == targetPath(this.NewAccountPage_mc.NewEmailInput_tf))
         {
            this.NewAccountPage_mc.NewEmailInput_tf.SetText(astrEnteredText,false);
         }
      }
      if(this.LoginPage_mc.UsernameInput_tf.text.length > 0)
      {
         this.LoginPage_mc.UsernameGrayText_tf._visible = false;
      }
      if(this.LoginPage_mc.PasswordInput_tf.text.length > 0)
      {
         this.LoginPage_mc.PasswordGrayText_tf._visible = false;
      }
      if(this.NewAccountPage_mc.NewEmailInput_tf.text.length > 0)
      {
         this.NewAccountPage_mc.EmailGrayText_tf._visible = false;
      }
      this.UpdateButtons();
   }
   function GetNotSignedInError()
   {
      return this.Error_NotSignedInOrbis.text;
   }
   function ExitLoginFlow()
   {
      this.HideCurrentScreen();
   }
   function HideLoginScreen()
   {
      if(this.LoginPage_mc._visible)
      {
         this.codeObj.endEditText();
         this.LoginPage_mc._visible = false;
         this.codeObj.onLoginScreenClose();
      }
   }
   function HideSpinner()
   {
      this.Spinner_mc._visible = false;
      this.bottomButtons.Hide(false);
   }
   function InitView()
   {
      this.LoginPage_mc._visible = false;
      this.EULAPage_mc._visible = false;
      this.Spinner_mc._visible = false;
      this.NewAccountPage_mc._visible = false;
      this._currentScreen = null;
   }
   function Destroy()
   {
      return delete this.codeObj;
   }
   function SetBottomButtons(buttons)
   {
      this.bottomButtons = buttons;
      this.bottomButtons.addEventListener(BottomButtons.BUTTON_CLICKED,Shared.Proxy.create(this,this.OnBottomButtonClicked));
      if(this.iPlatform == BethesdaNetLogin.CONTROLLER_PROSPERO)
      {
         this.bottomButtons.SetButtons([BethesdaNetLogin.NEXT,BottomButtons.ACCEPT,BethesdaNetLogin.CREATE_ACCOUNT,BethesdaNetLogin.ENTER_TEXT,BottomButtons.CANCEL,BethesdaNetLogin.SKIP,BottomButtons.LIBRARY_LOGIN,BethesdaNetLogin.VIEW_EULA]);
      }
      else
      {
         this.bottomButtons.SetButtons([BethesdaNetLogin.NEXT,BottomButtons.ACCEPT,BethesdaNetLogin.CONSOLE_EMAIL,BethesdaNetLogin.CREATE_ACCOUNT,BethesdaNetLogin.ENTER_TEXT,BottomButtons.CANCEL,BethesdaNetLogin.SKIP,BottomButtons.LIBRARY_LOGIN,BethesdaNetLogin.VIEW_EULA]);
      }
      var _loc2_ = 0;
      this.NextButton = this.bottomButtons.GetButtonByIndex(_loc2_++);
      this.AcceptButton = this.bottomButtons.GetButtonByIndex(_loc2_++);
      if(this.iPlatform != BethesdaNetLogin.CONTROLLER_PROSPERO)
      {
         this.EmailButton = this.bottomButtons.GetButtonByIndex(_loc2_++);
      }
      this.CreateAccountButton = this.bottomButtons.GetButtonByIndex(_loc2_++);
      this.EnterTextButton = this.bottomButtons.GetButtonByIndex(_loc2_++);
      this.CancelButton = this.bottomButtons.GetButtonByIndex(_loc2_++);
      this.SkipButton = this.bottomButtons.GetButtonByIndex(_loc2_++);
      this.LibraryButton = this.bottomButtons.GetButtonByIndex(_loc2_++);
      this.EulaButton = this.bottomButtons.GetButtonByIndex(_loc2_++);
      this._QueuedButtonUpdate = true;
      this.onEnterFrame = Shared.Proxy.create(this,this.DoUpdateButtons);
   }
   function DoUpdateButtons()
   {
      this.onEnterFrame = null;
      this._QueuedButtonUpdate = false;
      this.UpdateButtons();
   }
   function UpdateButtons()
   {
      if(this._QueuedButtonUpdate)
      {
         return undefined;
      }
      var _loc2_ = !(this.IsPlatformXBox() || this.IsPlatformSony());
      var _loc3_;
      if(this.LoginPage_mc._visible)
      {
         this.AcceptButton._visible = true;
         this.AcceptButton.disabled = !_loc2_ && !(this.LoginPage_mc.UsernameInput_tf.text.length > 0 && this.LoginPage_mc.PasswordInput_tf.text.length > 0);
         this.NextButton._visible = false;
         this.EmailButton._visible = false;
         this.CreateAccountButton._visible = false;
         this.EnterTextButton._visible = !_loc2_;
         this.CancelButton._visible = true;
         this.SkipButton._visible = false;
         this.LibraryButton._visible = this.ShowLoadOrderButton;
         this.EulaButton._visible = false;
         this.bottomButtons._visible = true;
      }
      else if(this.EULAPage_mc._visible)
      {
         this.AcceptButton._visible = false;
         this.NextButton._visible = true;
         this.EmailButton._visible = false;
         this.CreateAccountButton._visible = false;
         this.EnterTextButton._visible = false;
         this.CancelButton._visible = true;
         this.SkipButton._visible = false;
         this.LibraryButton._visible = false;
         this.EulaButton._visible = false;
         this.bottomButtons._visible = true;
      }
      else if(this.NewAccountPage_mc._visible)
      {
         this.AcceptButton._visible = false;
         this.NextButton._visible = false;
         _loc3_ = !_loc2_ && this.NewAccountPage_mc.NewEmailInput_tf.text.length == 0;
         this.EmailButton._visible = _loc3_;
         this.CreateAccountButton._visible = !_loc3_;
         this.EnterTextButton._visible = !_loc2_;
         this.CancelButton._visible = !this.UseSkipInsteadOfCancel;
         this.SkipButton._visible = this.UseSkipInsteadOfCancel;
         this.LibraryButton._visible = this.ShowLoadOrderButton;
         this.EulaButton._visible = true;
         this.EulaButton.disabled = this.EULAPagesA == null || this.EULAPagesA.length == 0;
         this.bottomButtons._visible = true;
      }
      else
      {
         this.AcceptButton._visible = false;
         this.NextButton._visible = false;
         this.EmailButton._visible = false;
         this.CreateAccountButton._visible = false;
         this.EnterTextButton._visible = false;
         this.CancelButton._visible = false;
         this.SkipButton._visible = false;
         this.LibraryButton._visible = false;
         this.EulaButton._visible = false;
         this.bottomButtons.Hide(true);
      }
      this.bottomButtons.Reposition();
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.iPlatform = aiPlatform;
      this.ps3Switch = abPS3Switch;
      if(this.IsPlatformSony())
      {
         this.LoginPage_mc.LoginFooter_tf.SetText("$LoginPage_Footer_PS4",false);
      }
   }
   function SpinnerVisible()
   {
      return this.Spinner_mc._visible;
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      if(pathToFocus[0].handleInput != undefined)
      {
         _loc2_ = pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      if(!_loc2_ && Shared.GlobalFunc.IsKeyPressed(details) && !this.SpinnerVisible())
      {
         _loc2_ = this.DoHandleInput(details.navEquivalent,details.code,false);
      }
      return _loc2_;
   }
   function DoHandleInput(nav, keyCode, usingMouse)
   {
      var _loc2_ = false;
      if(nav == gfx.ui.NavigationCode.UP || keyCode == 38)
      {
         this.handleUpInput();
         _loc2_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.DOWN || keyCode == 40)
      {
         this.handleDownInput();
         _loc2_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.TAB || keyCode == 9)
      {
         this.handleTabInput();
         _loc2_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.ENTER || keyCode == 13)
      {
         this.onLoginAccept();
         _loc2_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.ESCAPE || keyCode == 27)
      {
         this.OnEscape();
         _loc2_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.END || nav == gfx.ui.NavigationCode.GAMEPAD_X || keyCode == 35)
      {
         if(this.EulaButton._visible && !this.EulaButton.disabled)
         {
            this.onEulaPress();
         }
         _loc2_ = true;
      }
      else if(nav == gfx.ui.NavigationCode.GAMEPAD_R1)
      {
         if(this.EnterTextButton._visible)
         {
            this.onTextEditPress();
         }
         _loc2_ = true;
      }
      return _loc2_;
   }
   function onTextEditPress()
   {
      if(Selection.getFocus() == targetPath(this.LoginPage_mc.UsernameInput_tf))
      {
         this.LoginPage_mc.UsernameGrayText_tf._visible = false;
         this.codeObj.startEditText(this.LoginPage_mc.UsernameInput_tf.text.length <= 0 ? this.LoginPage_mc.UsernameGrayText_tf.text : this.LoginPage_mc.UsernameInput_tf.text,false);
      }
      else if(Selection.getFocus() == targetPath(this.LoginPage_mc.PasswordInput_tf))
      {
         this.LoginPage_mc.PasswordGrayText_tf._visible = false;
         this.codeObj.startEditText(this.LoginPage_mc.PasswordInput_tf.text.length <= 0 ? this.LoginPage_mc.PasswordGrayText_tf.text : this.LoginPage_mc.PasswordInput_tf.text,true);
      }
      else if(Selection.getFocus() == targetPath(this.NewAccountPage_mc.NewEmailInput_tf))
      {
         this.NewAccountPage_mc.EmailGrayText_tf._visible = false;
         this.codeObj.startEditText(this.NewAccountPage_mc.NewEmailInput_tf.text,false);
      }
      return true;
   }
   function AcceptLogin()
   {
      this.onLoginAccept();
   }
   function LoadEULAPage()
   {
      this.EULAPage_mc.Title_tf.SetText(this.EULAPagesA[this._CurrEULAIndex].title,true);
      this.EULAPage_mc.EULA_tf.SetText(this.EULAPagesA[this._CurrEULAIndex].text,true);
      this.EULAPage_mc.EULA_tf.scroll = 0;
      this.UpdateEULAScrollIndicators();
      Selection.setFocus(this.EULAPage_mc);
   }
   function onLoginAccept()
   {
      if(this.LoginPage_mc._visible)
      {
         if(this.LoginPage_mc.UsernameInput_tf.text.length > 0 && this.LoginPage_mc.PasswordInput_tf.text.length > 0)
         {
            this.codeObj.attemptLogin(this.LoginPage_mc.UsernameInput_tf.text,this.LoginPage_mc.PasswordInput_tf.text);
            this.codeObj.PlaySound("UIMenuOK");
         }
         else if(this.iPlatform != BethesdaNetLogin.CONTROLLER_PC && this.iPlatform != BethesdaNetLogin.CONTROLLER_PCGAMEPAD)
         {
            if(Selection.getFocus() == targetPath(this.LoginPage_mc.UsernameInput_tf))
            {
               this.LoginPage_mc.UsernameGrayText_tf._visible = false;
               this.codeObj.startEditText(this.LoginPage_mc.UsernameInput_tf.text.length <= 0 ? "" : this.LoginPage_mc.UsernameInput_tf.text);
            }
            else if(Selection.getFocus() == targetPath(this.LoginPage_mc.PasswordInput_tf))
            {
               this.LoginPage_mc.PasswordGrayText_tf._visible = false;
               this.codeObj.startEditText(this.LoginPage_mc.PasswordInput_tf.text.length <= 0 ? this.LoginPage_mc.PasswordGrayText_tf.text : this.LoginPage_mc.PasswordInput_tf.text,true);
            }
         }
      }
      else if(this.EULAPage_mc._visible)
      {
         if(!this._ViewingEulaWithoutAcceptance)
         {
            this.codeObj.AcceptLegalDoc(this.EULAPagesA[this._CurrEULAIndex].id);
         }
         this.codeObj.PlaySound("UIMenuOK");
         if(this._CurrEULAIndex < this.EULAPagesA.length - 1)
         {
            this._CurrEULAIndex = this._CurrEULAIndex + 1;
            this.LoadEULAPage();
         }
         else if(!this._ViewingEulaWithoutAcceptance)
         {
            this.HideEULAScreen();
            this.codeObj.attemptLogin(this.LoginPage_mc.UsernameInput_tf.text,this.LoginPage_mc.PasswordInput_tf.text);
         }
         else
         {
            this.HideEULAScreen();
            this.ShowNewAccountPage(this.NewAccountPage_mc.NewEmailInput_tf.text);
         }
      }
      else if(this.NewAccountPage_mc._visible)
      {
         if(Selection.getFocus() == targetPath(this.NewAccountPage_mc.NewEmailInput_tf) && this.iPlatform != BethesdaNetLogin.CONTROLLER_PC && this.iPlatform != BethesdaNetLogin.CONTROLLER_PCGAMEPAD && this.NewAccountPage_mc.NewEmailInput_tf.text.length == 0)
         {
            this.NewAccountPage_mc.EmailGrayText_tf._visible = false;
            this.NewAccountPage_mc.NewEmailInput_tf.text = this.DefaultEmail;
            this.UpdateButtons();
         }
         else if(this.NewAccountPage_mc.NewEmailInput_tf.text.length > 0)
         {
            this.codeObj.PlayOKSound();
            this.HideNewAccountPage();
            this.codeObj.createQuickAccount(this.NewAccountPage_mc.NewEmailInput_tf.text,true,this.GetNewsByDefault);
         }
      }
   }
   function onLogin_CreateNew()
   {
      this.HideLoginScreen();
      this.codeObj.PopulateEULA(this);
   }
   function HideEULAScreen()
   {
      Selection.setFocus(null);
      this._ViewingEulaWithoutAcceptance = false;
      this.EULAPage_mc._visible = false;
   }
   function ShowNewAccountPage(strUsername, strErrorText)
   {
      this.HideSpinner();
      this.ShowCurrentScreen(this.NewAccountPage_mc);
      if(this.iPlatform == BethesdaNetLogin.CONTROLLER_PC || this.iPlatform == BethesdaNetLogin.CONTROLLER_PCGAMEPAD)
      {
         this.codeObj.startEditText();
      }
      this.NewAccountPage_mc.NewEmailInput_tf.text = strUsername == undefined ? "" : strUsername;
      this.NewAccountPage_mc.EmailGrayText_tf._visible = this.NewAccountPage_mc.NewEmailInput_tf.text.length <= 0;
      this.NewAccountPage_mc.NewEmailInput_tf.onChanged = Shared.Proxy.create(this,this.OnEmailTextChange);
      Selection.setFocus(this.NewAccountPage_mc.NewEmailInput_tf);
      if(this.NewAccountPage_mc.NewEmailInput_tf.text.length > 0)
      {
         this.NewAccountPage_mc.NewEmailInput_tf.setSelection(0,this.NewAccountPage_mc.NewEmailInput_tf.text.length);
      }
      if(strErrorText != undefined)
      {
         if(strErrorText == "BNET_INTERNAL")
         {
            strErrorText = "BNET_NOT_FOUND";
         }
         this.NewAccountPage_mc.Error_tf.text = "$CreateAcct_" + strErrorText;
      }
      else
      {
         this.NewAccountPage_mc.Error_tf.text = " ";
      }
      this._LastLoginScreen = this.NewAccountPage_mc;
   }
   function HideNewAccountPage()
   {
      if(this.NewAccountPage_mc._visible)
      {
         this.codeObj.endEditText();
         this.NewAccountPage_mc._visible = false;
      }
   }
   function handleTabInput()
   {
      if(this.iPlatform == BethesdaNetLogin.CONTROLLER_PC && this.LoginPage_mc._visible)
      {
         if(Selection.getFocus() == targetPath(this.LoginPage_mc.UsernameInput_tf))
         {
            Selection.setFocus(this.LoginPage_mc.PasswordInput_tf);
         }
         else if(Selection.getFocus() == targetPath(this.LoginPage_mc.PasswordInput_tf))
         {
            Selection.setFocus(this.LoginPage_mc.UsernameInput_tf);
         }
      }
      else
      {
         this.OnEscape();
      }
   }
   function handleUpInput()
   {
      if(this.LoginPage_mc._visible && this.iPlatform != BethesdaNetLogin.CONTROLLER_PC)
      {
         if(Selection.getFocus() == targetPath(this.LoginPage_mc.PasswordInput_tf))
         {
            Selection.setFocus(this.LoginPage_mc.UsernameInput_tf);
         }
      }
      else if(this.EULAPage_mc._visible)
      {
         this.EULAPage_mc.EULA_tf.scroll--;
         this.UpdateEULAScrollIndicators();
      }
   }
   function handleDownInput()
   {
      if(this.LoginPage_mc._visible && this.iPlatform != BethesdaNetLogin.CONTROLLER_PC)
      {
         if(Selection.getFocus() == targetPath(this.LoginPage_mc.UsernameInput_tf))
         {
            Selection.setFocus(this.LoginPage_mc.PasswordInput_tf);
         }
      }
      else if(this.EULAPage_mc._visible)
      {
         this.EULAPage_mc.EULA_tf.scroll = this.EULAPage_mc.EULA_tf.scroll + 1;
         this.UpdateEULAScrollIndicators();
      }
   }
   function OnEscape()
   {
      if(this.EULAPage_mc._visible)
      {
         if(!this._ViewingEulaWithoutAcceptance)
         {
            this.HideEULAScreen();
            this.dispatchEvent({type:BethesdaNetLogin.EULA_CANCELED,target:this});
         }
         else
         {
            this.HideEULAScreen();
            this.ShowNewAccountPage(this.NewAccountPage_mc.NewEmailInput_tf.text);
         }
      }
      else if(this.NewAccountPage_mc._visible)
      {
         this.dispatchEvent({type:BethesdaNetLogin.LOGIN_CANCELED,target:this});
      }
      else if(this.LoginPage_mc._visible)
      {
         this.HideLoginScreen();
         this.ShowNewAccountPage();
      }
      this.codeObj.PlaySound("UIMenuCancel");
   }
   function ShowCurrentScreen(screen)
   {
      this.HideCurrentScreen();
      this._currentScreen = screen;
      screen._visible = true;
      this.UpdateButtons();
   }
   function HideCurrentScreen()
   {
      if(this.LoginPage_mc == this._currentScreen)
      {
         this.HideLoginScreen();
      }
      else if(this.EULAPage_mc == this._currentScreen)
      {
         this.HideEULAScreen();
      }
      else if(this.Spinner_mc == this._currentScreen)
      {
         this.HideSpinner();
      }
      else if(this.NewAccountPage_mc == this._currentScreen)
      {
         this.HideNewAccountPage();
      }
      this._currentScreen = null;
   }
   function OnUsernameFieldUpdate()
   {
      this.LoginPage_mc.UsernameGrayText_tf._visible = this.LoginPage_mc.UsernameInput_tf.text.length <= 0;
   }
   function OnPasswordFieldUpdate()
   {
      this.LoginPage_mc.PasswordGrayText_tf._visible = this.LoginPage_mc.PasswordInput_tf.text.length <= 0;
   }
   function OnBottomButtonClicked(event)
   {
      var _loc2_ = event.data.KeyCode;
      if(_loc2_ == 9 && this._currentScreen == this.LoginPage_mc)
      {
         _loc2_ = 27;
      }
      this.DoHandleInput("",_loc2_,true);
   }
   function onNextEditTimerDone()
   {
      if(this.IsPlatformSony())
      {
         this.codeObj.startEditText(this.LoginPage_mc.PasswordInput_tf.text.length <= 0 ? "" : this.LoginPage_mc.PasswordInput_tf.text,true);
      }
      else
      {
         this.codeObj.startEditText(this.LoginPage_mc.PasswordInput_tf.text.length <= 0 ? this.LoginPage_mc.PasswordGrayText_tf.text : this.LoginPage_mc.PasswordInput_tf.text,true);
      }
   }
   function onMouseWheel(delta)
   {
      var _loc2_ = false;
      if(this.EULAPage_mc._visible)
      {
         _loc2_ = true;
         if(delta < 0)
         {
            this.EULAPage_mc.EULA_tf.scroll = this.EULAPage_mc.EULA_tf.scroll + 1;
            this.UpdateEULAScrollIndicators();
         }
         else if(delta > 0)
         {
            this.EULAPage_mc.EULA_tf.scroll--;
            this.UpdateEULAScrollIndicators();
         }
      }
      return _loc2_;
   }
   function onEULAScrollUpClicked()
   {
      this.EULAPage_mc.EULA_tf.scroll--;
      this.UpdateEULAScrollIndicators();
   }
   function onEULAScrollDownClicked()
   {
      this.EULAPage_mc.EULA_tf.scroll = this.EULAPage_mc.EULA_tf.scroll + 1;
      this.UpdateEULAScrollIndicators();
   }
   function UpdateEULAScrollIndicators()
   {
      this.EULAPage_mc.ScrollUp._visible = this.EULAPage_mc.EULA_tf.scroll > 1;
      this.EULAPage_mc.ScrollDown._visible = this.EULAPage_mc.EULA_tf.bottomScroll < this.EULAPage_mc.EULA_tf.numLines;
   }
   function IsAtLogin()
   {
      return this.LoginPage_mc._visible || this.NewAccountPage_mc._visible;
   }
   function OnEmailTextChange()
   {
      this.NewAccountPage_mc.EmailGrayText_tf._visible = this.NewAccountPage_mc.NewEmailInput_tf.text.length <= 0;
   }
   function onEulaPress()
   {
      this._ViewingEulaWithoutAcceptance = true;
      this.onEULAPopulated();
   }
   function EulaEnabled()
   {
      return this.EULAPagesA != null && this.EULAPagesA.length > 0;
   }
   function IsPlatformSony()
   {
      return this.iPlatform == BethesdaNetLogin.CONTROLLER_ORBIS || this.iPlatform == BethesdaNetLogin.CONTROLLER_PROSPERO;
   }
   function IsPlatformXBox()
   {
      return this.iPlatform == BethesdaNetLogin.CONTROLLER_DURANGO || this.iPlatform == BethesdaNetLogin.CONTROLLER_SCARLETT;
   }
}
