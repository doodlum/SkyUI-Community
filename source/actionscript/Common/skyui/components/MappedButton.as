class skyui.components.MappedButton extends gfx.controls.Button
{
   var __get__label;
   var __set__label;
   var _height;
   var _keyCodes;
   var _label;
   var _parent;
   var _platform;
   var background;
   var buttonArt;
   var constraints;
   var dispatchEvent;
   var state;
   var textField;
   static var _arrayWrap = [];
   function MappedButton()
   {
      super();
      this._keyCodes = [];
      this.buttonArt = [];
      var _loc3_ = 0;
      while(this["buttonArt" + _loc3_] != undefined)
      {
         this.buttonArt.push(this["buttonArt" + _loc3_]);
         _loc3_ = _loc3_ + 1;
      }
   }
   function set hiddenBackground(a_flag)
   {
      this.background._visible = !a_flag;
   }
   function get hiddenBackground()
   {
      return this.background._visible;
   }
   function get width()
   {
      return this.background._width;
   }
   function set width(a_value)
   {
      this.background._width = a_value;
   }
   function onLoad()
   {
      super.onLoad();
      if(this._parent.onButtonLoad != undefined)
      {
         this._parent.onButtonLoad(this);
      }
   }
   function updateAfterStateChange()
   {
      if(this.textField != null && this._label != null)
      {
         this.textField.autoSize = "left";
         this.textField.text = this._label;
         this.textField._width = this.textField.getLineMetrics(0).width;
      }
      this.update();
      this.dispatchEvent({type:"stateChange",state:this.state});
   }
   function setPlatform(a_platform)
   {
      this._platform = a_platform;
      if(this.label != null && this.label.length > 0)
      {
         this.update();
      }
   }
   function setButtonData(a_buttonData)
   {
      this.textField.autoSize = "left";
      this.label = a_buttonData.text;
      this.textField._width = this.textField.getLineMetrics(0).width;
      this.setMappedControls(a_buttonData.controls);
   }
   function setMappedControls(a_controls)
   {
      this.constraints = null;
      this._keyCodes.splice(0);
      var _loc7_;
      if(a_controls instanceof Array)
      {
         _loc7_ = a_controls;
      }
      else
      {
         skyui.components.MappedButton._arrayWrap[0] = a_controls;
         _loc7_ = skyui.components.MappedButton._arrayWrap;
      }
      var _loc4_ = 0;
      var _loc2_;
      var _loc3_;
      var _loc5_;
      var _loc6_;
      while(_loc4_ < _loc7_.length)
      {
         _loc2_ = _loc7_[_loc4_];
         if(_loc2_ != null)
         {
            _loc3_ = -1;
            if(_loc2_.keyCode != null)
            {
               _loc3_ = _loc2_.keyCode;
            }
            else
            {
               _loc5_ = String(_loc2_.name);
               _loc6_ = Number(_loc2_.context);
               _loc3_ = skyui.util.GlobalFunctions.getMappedKey(_loc5_,_loc6_,this._platform != 0);
            }
            if(_loc3_ == -1)
            {
               _loc3_ = 282;
            }
            this._keyCodes.push(_loc3_);
         }
         _loc4_ = _loc4_ + 1;
      }
      this.update();
   }
   function update()
   {
      var _loc4_ = 0;
      var _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < this.buttonArt.length)
      {
         _loc2_ = this.buttonArt[_loc3_];
         if(this._keyCodes[_loc3_] > 0)
         {
            _loc2_._visible = true;
            _loc2_.gotoAndStop(this._keyCodes[_loc3_]);
            _loc2_._x = _loc4_;
            _loc2_._y = (this._height - _loc2_._height) / 2;
            _loc4_ += _loc2_._width - 2;
         }
         else
         {
            _loc2_._visible = false;
         }
         _loc3_ = _loc3_ + 1;
      }
      this.textField._x = _loc4_ + 1;
      _loc4_ += this.textField._width + 6;
      this.background._width = _loc4_;
   }
}
