class skyui.components.TabBar extends MovieClip
{
   var _activeTab;
   var dispatchEvent;
   var image;
   var leftButton;
   var leftIcon;
   var leftLabel;
   var rightButton;
   var rightIcon;
   var rightLabel;
   static var LEFT_TAB = 0;
   static var RIGHT_TAB = 1;
   function TabBar()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this.activeTab = skyui.components.TabBar.LEFT_TAB;
   }
   function get activeTab()
   {
      return this._activeTab;
   }
   function set activeTab(a_index)
   {
      this._activeTab = a_index;
      if(a_index == skyui.components.TabBar.LEFT_TAB)
      {
         this.leftIcon._alpha = 100;
         this.leftLabel._alpha = 100;
         this.rightIcon._alpha = 50;
         this.rightLabel._alpha = 50;
         this.image.gotoAndStop("left");
      }
      else
      {
         this.leftIcon._alpha = 50;
         this.leftLabel._alpha = 50;
         this.rightIcon._alpha = 100;
         this.rightLabel._alpha = 100;
         this.image.gotoAndStop("right");
      }
   }
   function onLoad()
   {
      this.leftLabel.textAutoSize = "shrink";
      this.rightLabel.textAutoSize = "shrink";
      this.leftButton.onPress = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
      {
         this._parent.tabPress(skyui.components.TabBar.LEFT_TAB);
      };
      this.leftButton.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
      {
         this._parent.tabPress(skyui.components.TabBar.LEFT_TAB);
      };
      this.leftButton.onRollOver = function()
      {
         if(this._parent._activeTab != skyui.components.TabBar.LEFT_TAB)
         {
            this._parent.leftIcon._alpha = 75;
            this._parent.leftLabel._alpha = 75;
         }
      };
      this.leftButton.onRollOut = function()
      {
         if(this._parent._activeTab != skyui.components.TabBar.LEFT_TAB)
         {
            this._parent.leftIcon._alpha = 50;
            this._parent.leftLabel._alpha = 50;
         }
      };
      this.rightButton.onPress = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
      {
         this._parent.tabPress(skyui.components.TabBar.RIGHT_TAB);
      };
      this.rightButton.onPressAux = function(a_mouseIndex, a_keyboardOrMouse, a_buttonIndex)
      {
         this._parent.tabPress(skyui.components.TabBar.RIGHT_TAB);
      };
      this.rightButton.onRollOver = function()
      {
         if(this._parent._activeTab != skyui.components.TabBar.RIGHT_TAB)
         {
            this._parent.rightIcon._alpha = 75;
            this._parent.rightLabel._alpha = 75;
         }
      };
      this.rightButton.onRollOut = function()
      {
         if(this._parent._activeTab != skyui.components.TabBar.RIGHT_TAB)
         {
            this._parent.rightIcon._alpha = 50;
            this._parent.rightLabel._alpha = 50;
         }
      };
   }
   function setIcons(a_leftName, a_rightName)
   {
      this.leftIcon.gotoAndStop(a_leftName);
      this.rightIcon.gotoAndStop(a_rightName);
   }
   function setLabelText(a_leftText, a_rightText)
   {
      this.leftLabel.SetText(a_leftText.toUpperCase());
      this.rightLabel.SetText(a_rightText.toUpperCase());
   }
   function tabPress(a_tabIndex)
   {
      this.dispatchEvent({type:"tabPress",index:a_tabIndex});
   }
   function tabToggle()
   {
      this.tabPress(this._activeTab != skyui.components.TabBar.LEFT_TAB ? skyui.components.TabBar.LEFT_TAB : skyui.components.TabBar.RIGHT_TAB);
   }
}
