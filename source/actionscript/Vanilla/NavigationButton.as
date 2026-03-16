class NavigationButton extends MovieClip
{
   var OnFocus;
   var Selected_mc;
   var _DownButton;
   var _LeftButton;
   var _RightButton;
   var _UpButton;
   var dispatchEvent;
   var onEnterFrame;
   var RememberButtonSelectedFrom = true;
   var LeftNav = null;
   var RightNav = null;
   var DownNav = null;
   var UpNav = null;
   var CanNavigateTo = true;
   function NavigationButton()
   {
      super();
      this.focusEnabled = true;
      gfx.events.EventDispatcher.initialize(this);
      this.onEnterFrame = Shared.Proxy.create(this,this.Init);
   }
   function Init()
   {
      if(this._LeftButton != "" && this._LeftButton == null)
      {
         this.LeftNav = this._parent[this._LeftButton];
         if(this.LeftNav == undefined)
         {
            this.LeftNav = null;
         }
      }
      else
      {
         this.LeftNav = null;
      }
      if(this._RightButton != "" && this._RightButton == null)
      {
         this.RightNav = this._parent[this._RightButton];
         if(this.RightNav == undefined)
         {
            this.RightNav = null;
         }
      }
      else
      {
         this.RightNav = null;
      }
      if(this._DownButton != "" && this._DownButton == null)
      {
         this.DownNav = this._parent[this._DownButton];
         if(this.DownNav == undefined)
         {
            this.DownNav = null;
         }
      }
      else
      {
         this.DownNav = null;
      }
      if(this._UpButton != "" && this._UpButton == null)
      {
         this.UpNav = this._parent[this._UpButton];
         if(this.UpNav == undefined)
         {
            this.UpNav = null;
         }
      }
      else
      {
         this.UpNav = null;
      }
      this.onEnterFrame = null;
   }
   function SetFocus(focus)
   {
      if(focus)
      {
         Selection.setFocus(this);
      }
      this.Selected_mc._visible = focus;
      if(this.OnFocus != undefined && this.OnFocus != null)
      {
         this.OnFocus(focus,this);
      }
   }
   function handleInput(details, pathToFocus)
   {
      var _loc3_ = false;
      if(pathToFocus.length > 0)
      {
         _loc3_ = pathToFocus[0].handleInput(details,pathToFocus.slice(1));
      }
      if(!_loc3_ && Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.UP || details.code == 38)
         {
            if(this.UpNav != null && this.UpNav.CanNavigateTo && this.UpNav._visible)
            {
               this.SetFocus(false);
               this.UpNav.SetFocus(true);
               if(this.UpNav.RememberButtonSelectedFrom)
               {
                  this.UpNav.DownNav = this;
               }
               this.dispatchEvent({type:gfx.events.EventTypes.ITEM_ROLL_OVER,target:this.UpNav});
               _loc3_ = true;
            }
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.DOWN || details.code == 40)
         {
            if(this.DownNav != null && this.DownNav.CanNavigateTo && this.DownNav._visible)
            {
               this.SetFocus(false);
               this.DownNav.SetFocus(true);
               if(this.DownNav.RememberButtonSelectedFrom)
               {
                  this.DownNav.UpNav = this;
               }
               this.dispatchEvent({type:gfx.events.EventTypes.ITEM_ROLL_OVER,target:this.DownNav});
               _loc3_ = true;
            }
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.LEFT || details.code == 37)
         {
            if(this.LeftNav != null && this.LeftNav.CanNavigateTo && this.LeftNav._visible)
            {
               this.SetFocus(false);
               this.LeftNav.SetFocus(true);
               if(this.LeftNav.RememberButtonSelectedFrom)
               {
                  this.LeftNav.RightNav = this;
               }
               this.dispatchEvent({type:gfx.events.EventTypes.ITEM_ROLL_OVER,target:this.RightNav});
               _loc3_ = true;
            }
         }
         else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT || details.code == 39)
         {
            if(this.RightNav != null && this.RightNav.CanNavigateTo && this.RightNav._visible)
            {
               this.SetFocus(false);
               this.RightNav.SetFocus(true);
               if(this.RightNav.RememberButtonSelectedFrom)
               {
                  this.RightNav.LeftNav = this;
               }
               this.dispatchEvent({type:gfx.events.EventTypes.ITEM_ROLL_OVER,target:this.LeftNav});
               _loc3_ = true;
            }
         }
      }
      return _loc3_;
   }
}
