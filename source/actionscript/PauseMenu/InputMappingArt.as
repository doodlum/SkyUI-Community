class InputMappingArt extends MovieClip
{
   var _keyCodes;
   var background;
   var buttonArt;
   var textField;
   var _buttonNameMap = {esc:1,hyphen:12,equal:13,backspace:14,tab:15,q:16,w:17,e:18,r:19,t:20,y:21,u:22,i:23,o:24,p:25,bracketleft:26,bracketright:27,enter:28,a:30,s:31,d:32,f:33,g:34,h:35,j:36,k:37,l:38,semicolon:39,quotesingle:40,tilde:41,backslash:43,z:44,x:45,c:46,v:47,b:48,n:49,m:50,comma:51,period:52,slash:53,numpadmult:55,space:57,capslock:58,f1:59,f2:60,f3:61,f4:62,f5:63,f6:64,f7:65,f8:66,f9:67,f10:68,numlock:69,scrolllock:70,numpad7:71,numpad8:72,numpad9:73,numpadminus:74,numpad4:75,numpad5:76,numpad6:77,numpadplus:78,numpad1:79,numpad2:80,numpad3:81,numpad0:82,numpaddec:83,f11:87,f12:88,numpadenter:156,numpaddivide:158,printsrc:183,pause:197,home:199,up:200,pgup:201,left:203,right:205,end:207,down:208,pgdn:209,insert:210,mouse1:256,mouse2:257,mouse3:258,mouse4:259,mouse5:260,mouse6:261,mouse7:262,mouse8:263,mousewheelup:264,mousewheeldown:265,ps3_start:270,ps3_back:271,ps3_l3:272,ps3_r3:273,ps3_lb:274,ps3_rb:275,ps3_a:276,ps3_b:277,ps3_x:278,ps3_y:279,ps3_lt:280,ps3_rt:281};
   function InputMappingArt()
   {
      super();
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
   function MappedButton()
   {
      super();
      Shared.GlobalFunc.MaintainTextFormat();
   }
   function onLoad()
   {
      this.buttonArt = [];
      this._keyCodes = [];
      this.textField.textAutoSize = "shrink";
      this.textField._visible = false;
      this.background._visible = false;
      var _loc2_ = 0;
      while(this["buttonArt" + _loc2_] != undefined)
      {
         this["buttonArt" + _loc2_]._visible = false;
         this.buttonArt.push(this["buttonArt" + _loc2_]);
         _loc2_ = _loc2_ + 1;
      }
      this._buttonNameMap["1"] = 2;
      this._buttonNameMap["2"] = 3;
      this._buttonNameMap["3"] = 4;
      this._buttonNameMap["4"] = 5;
      this._buttonNameMap["5"] = 6;
      this._buttonNameMap["6"] = 7;
      this._buttonNameMap["7"] = 8;
      this._buttonNameMap["8"] = 9;
      this._buttonNameMap["9"] = 10;
      this._buttonNameMap["0"] = 11;
      this._buttonNameMap["l-ctrl"] = 29;
      this._buttonNameMap["l-shift"] = 42;
      this._buttonNameMap["r-shift"] = 54;
      this._buttonNameMap["l-alt"] = 56;
      this._buttonNameMap["r-ctrl"] = 157;
      this._buttonNameMap["r-alt"] = 184;
      this._buttonNameMap["delete"] = 211;
      this._buttonNameMap["360_start"] = 270;
      this._buttonNameMap["360_back"] = 271;
      this._buttonNameMap["360_l3"] = 272;
      this._buttonNameMap["360_r3"] = 273;
      this._buttonNameMap["360_lb"] = 274;
      this._buttonNameMap["360_rb"] = 275;
      this._buttonNameMap["360_a"] = 276;
      this._buttonNameMap["360_b"] = 277;
      this._buttonNameMap["360_x"] = 278;
      this._buttonNameMap["360_y"] = 279;
      this._buttonNameMap["360_lt"] = 280;
      this._buttonNameMap["360_rt"] = 281;
   }
   function setButtonName(a_buttonName)
   {
      this.textField._visible = false;
      var _loc5_ = this._buttonNameMap[a_buttonName.toLowerCase()];
      if(_loc5_ instanceof Array)
      {
         this._keyCodes = _loc5_;
      }
      else
      {
         this._keyCodes = [_loc5_];
      }
      var _loc3_;
      if(this._keyCodes[0] == null)
      {
         _loc3_ = 0;
         while(_loc3_ < this.buttonArt.length)
         {
            this.buttonArt[_loc3_]._visible = false;
            _loc3_ = _loc3_ + 1;
         }
         this.textField.SetText(a_buttonName);
         this.textField._width = this.textField.getLineMetrics(0).width;
         this.textField._visible = true;
         this.background._width = this.textField._width;
         return undefined;
      }
      var _loc4_ = 0;
      _loc3_ = 0;
      var _loc2_;
      while(_loc3_ < this.buttonArt.length)
      {
         _loc2_ = this.buttonArt[_loc3_];
         if(this._keyCodes[_loc3_] > 0)
         {
            _loc2_._visible = true;
            _loc2_.gotoAndStop(this._keyCodes[_loc3_]);
            _loc2_._x = _loc4_;
            _loc2_._y = 0;
            _loc4_ += _loc2_._width;
         }
         else
         {
            _loc2_._visible = false;
         }
         _loc3_ = _loc3_ + 1;
      }
      this.background._width = _loc4_;
   }
}
