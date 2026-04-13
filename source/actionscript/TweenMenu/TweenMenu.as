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
      Stage.scaleMode = "showAll";
      Shared.GlobalFunc.SetLockFunction();
      gfx.io.GameDelegate.addCallBack("StartOpenMenuAnim",this,"StartOpenMenuAnim");
      gfx.io.GameDelegate.addCallBack("StartCloseMenuAnim",this,"StartCloseMenuAnim");
      gfx.io.GameDelegate.addCallBack("ShowMenu",this,"ShowMenu");
      gfx.io.GameDelegate.addCallBack("HideMenu",this,"HideMenu");
      gfx.io.GameDelegate.addCallBack("ResetStatsButton",this,"ResetStatsButton");
      gfx.io.GameDelegate.addCallBack("SetDateString",this,"SetDateString");
      gfx.io.GameDelegate.addCallBack("SetPlayerInfo",this,"SetPlayerInfo");
      this.LevelMeter = new Components.Meter(this.BottomBarTweener_mc.BottomBar_mc.LevelProgressBar);
      gfx.managers.FocusHandler.instance.setFocus(this,0);
      var marginBottomBar = 32;

      MovieClip(this.BottomBarTweener_mc).Lock("B");
      this.BottomBarTweener_mc._y += Stage.safeRect.y + marginBottomBar;
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
      this.SetPlayerInfo(arguments[0], arguments[2], arguments[3]);

      this.gotoAndPlay("startExpand");
      this.BottomBarTweener_mc._alpha = 100;
      if(arguments[1] != undefined)
      {
         this.SetDateString(arguments[1]);
         this.BottomBarTweener_mc.gotoAndPlay("startExpand");
      }
   }
   function SetPlayerInfo(a_bLevelUp, a_fLevel, a_fPercent)
   {
      this.bLevelUp = a_bLevelUp;

      this.BottomBarTweener_mc.BottomBar_mc.LevelNumberLabel.textAutoSize = "shrink";
      this.BottomBarTweener_mc.BottomBar_mc.LevelNumberLabel.SetText(a_fLevel);

      this.LevelMeter.SetPercent(a_fPercent);

      if(this.bLevelUp)
      {
         this.Selections_mc.SkillsText_mc.textField.SetText("$LEVEL UP");
      }
      else
      {
         this.Selections_mc.SkillsText_mc.textField.SetText("$SKILLS");
      }
   }
   function SetDateString(a_strDate)
   {
      if(a_strDate != undefined)
      {
         this.BottomBarTweener_mc.BottomBar_mc.DateText.SetText(a_strDate);
      }
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
      var menuFrameIdx;
      if(!this.bClosing && Shared.GlobalFunc.IsKeyPressed(details))
      {
         menuFrameIdx = 0;
         if(details.navEquivalent == gfx.ui.NavigationCode.UP)
         {
            menuFrameIdx = 1;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.LEFT)
         {
            menuFrameIdx = 2;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT)
         {
            menuFrameIdx = 3;
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.DOWN)
         {
            menuFrameIdx = 4;
         }
         if(menuFrameIdx > 0)
         {
            if(menuFrameIdx != this.Selections_mc._currentframe - 1)
            {
               this.Selections_mc.gotoAndStop(TweenMenu.FrameToLabelMap[menuFrameIdx]);
               gfx.io.GameDelegate.call("HighlightMenu",[menuFrameIdx]);
            }
            else
            {
               gfx.io.GameDelegate.call("OpenHighlightedMenu",[menuFrameIdx]);
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
