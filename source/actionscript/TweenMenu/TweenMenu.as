class TweenMenu extends MovieClip
{
   var BottomBarTweener_mc;
   var ItemsInputRect;
   var LevelMeter;
   var MagicInputRect;
   var MapInputRect;
   var Selections_mc;
   var SkillsInputRect;
   var bClosing;
   var bLevelUp;
   static var FrameToLabelMap = ["None","Skills","Magic","Inventory","Map"];
   function TweenMenu()
   {
      super();
      this.Selections_mc = this.Selections_mc;
      this.BottomBarTweener_mc = this.BottomBarTweener_mc;
      this.bClosing = false;
      this.bLevelUp = false;
   }
   function InitExtensions()
   {
      gfx.io.GameDelegate.addCallBack("StartOpenMenuAnim",this,"StartOpenMenuAnim");
      gfx.io.GameDelegate.addCallBack("StartCloseMenuAnim",this,"StartCloseMenuAnim");
      gfx.io.GameDelegate.addCallBack("ShowMenu",this,"ShowMenu");
      gfx.io.GameDelegate.addCallBack("HideMenu",this,"HideMenu");
      gfx.io.GameDelegate.addCallBack("ResetStatsButton",this,"ResetStatsButton");
      this.LevelMeter = new Components.Meter(this.BottomBarTweener_mc.BottomBar_mc.LevelProgressBar);
      gfx.managers.FocusHandler.instance.setFocus(this,0);
      Shared.GlobalFunc.SetLockFunction();
      MovieClip(this.BottomBarTweener_mc).Lock("B");
      this.SkillsInputRect.onRollOver = function()
      {
         this._parent.onInputRectMouseOver(1);
      };
      this.SkillsInputRect.onMouseDown = function()
      {
         if(Mouse.getTopMostEntity() == this)
         {
            this._parent.onInputRectClick(1);
         }
      };
      this.MagicInputRect.onRollOver = function()
      {
         this._parent.onInputRectMouseOver(2);
      };
      this.MagicInputRect.onMouseDown = function()
      {
         if(Mouse.getTopMostEntity() == this)
         {
            this._parent.onInputRectClick(2);
         }
      };
      this.ItemsInputRect.onRollOver = function()
      {
         this._parent.onInputRectMouseOver(3);
      };
      this.ItemsInputRect.onMouseDown = function()
      {
         if(Mouse.getTopMostEntity() == this)
         {
            this._parent.onInputRectClick(3);
         }
      };
      this.MapInputRect.onRollOver = function()
      {
         this._parent.onInputRectMouseOver(4);
      };
      this.MapInputRect.onMouseDown = function()
      {
         if(Mouse.getTopMostEntity() == this)
         {
            this._parent.onInputRectClick(4);
         }
      };
   }
   function onInputRectMouseOver(aiSelection)
   {
      if(!this.bClosing && this.Selections_mc._currentframe - 1 != aiSelection)
      {
         this.Selections_mc.gotoAndStop(TweenMenu.FrameToLabelMap[aiSelection]);
         gfx.io.GameDelegate.call("HighlightMenu",[aiSelection]);
      }
   }
   function onInputRectClick(aiSelection)
   {
      if(!this.bClosing)
      {
         gfx.io.GameDelegate.call("OpenHighlightedMenu",[aiSelection]);
      }
   }
   function ResetStatsButton()
   {
      this.Selections_mc.SkillsText_mc.textField.SetText("$SKILLS");
      this.bLevelUp = false;
   }
   function StartOpenMenuAnim()
   {
      if(arguments[0])
      {
         this.Selections_mc.SkillsText_mc.textField.SetText("$LEVEL UP");
         this.bLevelUp = true;
      }
      else
      {
         this.bLevelUp = false;
      }
      this.gotoAndPlay("startExpand");
      this.BottomBarTweener_mc._alpha = 100;
      if(arguments[1] != undefined)
      {
         this.BottomBarTweener_mc.BottomBar_mc.DateText.SetText(arguments[1]);
         this.BottomBarTweener_mc.gotoAndPlay("startExpand");
      }
      this.BottomBarTweener_mc.BottomBar_mc.LevelNumberLabel.textAutoSize = "shrink";
      this.BottomBarTweener_mc.BottomBar_mc.LevelNumberLabel.SetText(arguments[2]);
      this.LevelMeter.SetPercent(arguments[3]);
   }
   function onFinishOpenMenuAnim()
   {
      gfx.io.GameDelegate.call("OpenAnimFinished",[]);
   }
   function StartCloseMenuAnim()
   {
      this.gotoAndPlay("endExpand");
      this.BottomBarTweener_mc.gotoAndPlay("endExpand");
   }
   function ShowMenu()
   {
      this.gotoAndStop("showMenu");
      this.BottomBarTweener_mc._alpha = 100;
   }
   function HideMenu()
   {
      this.gotoAndStop("hideMenu");
      this.BottomBarTweener_mc._alpha = 0;
   }
   function onCloseComplete()
   {
      gfx.io.GameDelegate.call("CloseMenu",[]);
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_;
      if(!this.bClosing && Shared.GlobalFunc.IsKeyPressed(details))
      {
         _loc2_ = 0;
         if(details.navEquivalent == gfx.ui.NavigationCode.UP)
         {
            _loc2_ = 1;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.LEFT)
         {
            _loc2_ = 2;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT)
         {
            _loc2_ = 3;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.DOWN)
         {
            _loc2_ = 4;
         }
         if(_loc2_ > 0)
         {
            if(_loc2_ != this.Selections_mc._currentframe - 1)
            {
               this.Selections_mc.gotoAndStop(TweenMenu.FrameToLabelMap[_loc2_]);
               gfx.io.GameDelegate.call("HighlightMenu",[_loc2_]);
            }
            else
            {
               gfx.io.GameDelegate.call("OpenHighlightedMenu",[_loc2_]);
            }
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.ENTER && this.Selections_mc._currentframe > 1)
         {
            gfx.io.GameDelegate.call("OpenHighlightedMenu",[this.Selections_mc._currentframe - 1]);
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.TAB)
         {
            this.StartCloseMenuAnim();
            gfx.io.GameDelegate.call("StartCloseMenu",[]);
            this.bClosing = true;
         }
      }
      if(this.bLevelUp)
      {
         this.Selections_mc.SkillsText_mc.textField.SetText("$LEVEL UP");
      }
      return true;
   }
}
