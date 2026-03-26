class Map.MarkerDescription extends MovieClip
{
   var DescriptionList;
   var LineItem0;
   var Title;
   function MarkerDescription()
   {
      super();
      this.Title = this.Title;
      this.Title.autoSize = "left";
      this.DescriptionList = new Array();
      this.DescriptionList.push(this.LineItem0);
      this.DescriptionList[0]._visible = false;
   }
   function SetDescription(aTitle, aLineItems)
   {
      this.Title.text = aTitle != undefined ? aTitle : "";
      var _loc8_ = this.Title.text.length > 0 ? this.Title._height : 0;
      var _loc3_ = 0;
      var _loc2_;
      var _loc4_;
      var _loc5_;
      while(_loc3_ < aLineItems.length)
      {
         if(_loc3_ >= this.DescriptionList.length)
         {
            this.DescriptionList.push(this.attachMovie("DescriptionLineItem","LineItem" + _loc3_,this.getNextHighestDepth()));
            this.DescriptionList[_loc3_]._x = this.DescriptionList[0]._x;
            this.DescriptionList[_loc3_]._y = this.DescriptionList[0]._y;
         }
         this.DescriptionList[_loc3_]._visible = true;
         _loc2_ = this.DescriptionList[_loc3_].Item;
         _loc4_ = this.DescriptionList[_loc3_].Value;
         _loc5_ = aLineItems[_loc3_].Item;
         _loc2_.autoSize = "left";
         _loc2_.text = !(_loc5_ != undefined && _loc5_.length > 0) ? "" : _loc5_ + ": ";
         _loc4_.autoSize = "left";
         _loc4_.text = aLineItems[_loc3_].Value != undefined ? aLineItems[_loc3_].Value : "";
         _loc4_._x = _loc2_._x + _loc2_._width;
         _loc8_ += this.DescriptionList[_loc3_]._height;
         _loc3_ = _loc3_ + 1;
      }
      _loc3_ = aLineItems.length;
      while(_loc3_ < this.DescriptionList.length)
      {
         this.DescriptionList[_loc3_]._visible = false;
         _loc3_ = _loc3_ + 1;
      }
      var _loc7_ = (- _loc8_) / 2;
      this.Title._y = _loc7_;
      _loc7_ += this.Title.text.length > 0 ? this.Title._height : 0;
      _loc3_ = 0;
      while(_loc3_ < this.DescriptionList.length)
      {
         this.DescriptionList[_loc3_]._y = _loc7_;
         _loc7_ += this.DescriptionList[_loc3_]._height;
         _loc3_ = _loc3_ + 1;
      }
   }
   function OnShowFinish()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMapRolloverFlyout"]);
   }
}
