class Shared.ButtonTextArtHolder extends MovieClip
{
   var strButtonName;
   function ButtonTextArtHolder()
   {
      super();
   }
   function SetButtonName(aText)
   {
      this.strButtonName = aText;
   }
   function CreateButtonArt(aInputText)
   {
      var _loc6_ = aInputText.text.indexOf("[");
      var _loc3_ = _loc6_ != -1 ? aInputText.text.indexOf("]",_loc6_) : -1;
      var _loc2_;
      var _loc11_;
      var _loc7_;
      var _loc8_;
      var _loc10_;
      var _loc5_;
      var _loc9_;
      if(_loc6_ != -1 && _loc3_ != -1)
      {
         _loc2_ = aInputText.text.substr(0,_loc6_);
         while(_loc6_ != -1 && _loc3_ != -1)
         {
            _loc11_ = aInputText.text.substring(_loc6_ + 1,_loc3_);
            gfx.io.GameDelegate.call("GetButtonFromUserEvent",[_loc11_],this,"SetButtonName");
            if(this.strButtonName == undefined)
            {
               _loc2_ += aInputText.text.substring(_loc6_,_loc3_ + 1);
            }
            else
            {
               _loc7_ = flash.display.BitmapData.loadBitmap(this.strButtonName + ".png");
               if(_loc7_ != undefined && _loc7_.height > 0)
               {
                  _loc8_ = 26;
                  _loc10_ = Math.floor(_loc8_ / _loc7_.height * _loc7_.width);
                  _loc2_ += "<img src=\'" + this.strButtonName + ".png\' vspace=\'-5\' height=\'" + _loc8_ + "\' width=\'" + _loc10_ + "\'>";
               }
               else
               {
                  _loc2_ += aInputText.text.substring(_loc6_,_loc3_ + 1);
               }
            }
            _loc5_ = aInputText.text.indexOf("[",_loc3_);
            _loc9_ = _loc5_ != -1 ? aInputText.text.indexOf("]",_loc5_) : -1;
            if(_loc5_ != -1 && _loc9_ != -1)
            {
               _loc2_ += aInputText.text.substring(_loc3_ + 1,_loc5_);
            }
            else
            {
               _loc2_ += aInputText.text.substr(_loc3_ + 1);
            }
            _loc6_ = _loc5_;
            _loc3_ = _loc9_;
         }
      }
      return _loc2_;
   }
}
