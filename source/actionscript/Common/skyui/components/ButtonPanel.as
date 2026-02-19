class skyui.components.ButtonPanel extends MovieClip
{
   var _updateID;
   var buttonInitializer;
   var buttonRenderer;
   var buttons;
   var _buttonCount = 0;
   var isReversed = false;
   var maxButtons = 0;
   var spacing = 10;
   function ButtonPanel(a_buttonRenderer, a_maxButtons, a_buttonInitializer)
   {
      super();
      this.buttons = [];
      if(a_buttonRenderer != undefined)
      {
         this.buttonRenderer = a_buttonRenderer;
      }
      if(a_maxButtons != undefined)
      {
         this.maxButtons = a_maxButtons;
      }
      if(a_buttonInitializer != undefined)
      {
         this.buttonInitializer = a_buttonInitializer;
      }
      var _loc3_ = 0;
      var _loc4_;
      while(_loc3_ < this.maxButtons)
      {
         _loc4_ = this.attachMovie(this.buttonRenderer,"button" + _loc3_,this.getNextHighestDepth(),this.buttonInitializer);
         _loc4_._visible = false;
         this.buttons.push(_loc4_);
         _loc3_ = _loc3_ + 1;
      }
   }
   function setPlatform(a_platform, a_bPS3Switch)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.buttons.length)
      {
         this.buttons[_loc2_].setPlatform(a_platform,a_bPS3Switch);
         _loc2_ = _loc2_ + 1;
      }
   }
   function showButtons()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.buttons.length)
      {
         this.buttons[_loc2_]._visible = this.buttons[_loc2_].label.length > 0;
         _loc2_ = _loc2_ + 1;
      }
   }
   function hideButtons()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.buttons.length)
      {
         this.buttons[_loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
   function clearButtons()
   {
      this._buttonCount = 0;
      var _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < this.buttons.length)
      {
         _loc2_ = this.buttons[_loc3_];
         _loc2_._visible = false;
         _loc2_.label = "";
         _loc2_._x = 0;
         _loc3_ = _loc3_ + 1;
      }
   }
   function addButton(a_buttonData)
   {
      if(this._buttonCount >= this.buttons.length)
      {
         return undefined;
      }
      var _loc2_ = this.buttons[this._buttonCount];
      _loc2_.setButtonData(a_buttonData);
      _loc2_._visible = true;
      this._buttonCount = this._buttonCount + 1;
      return _loc2_;
   }
   function updateButtons(a_bInstant)
   {
      if(a_bInstant)
      {
         this.doUpdateButtons();
      }
      else if(!this._updateID)
      {
         this._updateID = setInterval(this,"doUpdateButtons",1);
      }
   }
   function doUpdateButtons()
   {
      clearInterval(this._updateID);
      delete this._updateID;
      var _loc3_ = 0;
      var _loc4_ = 0;
      var _loc2_;
      while(_loc4_ < this.buttons.length)
      {
         _loc2_ = this.buttons[_loc4_];
         if(_loc2_.label.length > 0 && _loc2_._visible)
         {
            _loc2_.update();
            if(this.isReversed)
            {
               _loc3_ -= _loc2_.width;
               _loc2_._x = _loc3_;
               _loc3_ -= this.spacing;
            }
            else
            {
               _loc2_._x = _loc3_;
               _loc3_ += _loc2_.width + this.spacing;
            }
         }
         _loc4_ = _loc4_ + 1;
      }
   }
}
