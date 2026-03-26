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
      this.Title.text = aTitle == undefined ? "" : aTitle;
      var _loc8_ = this.Title.text.length <= 0 ? 0 : this.Title._height;
      var _loc2_ = 0;
      var _loc3_;
      var _loc5_;
      var _loc4_;
      while(_loc2_ < aLineItems.length)
      {
         if(_loc2_ >= this.DescriptionList.length)
         {
            this.DescriptionList.push(this.attachMovie("DescriptionLineItem","LineItem" + _loc2_,this.getNextHighestDepth()));
            this.DescriptionList[_loc2_]._x = this.DescriptionList[0]._x;
            this.DescriptionList[_loc2_]._y = this.DescriptionList[0]._y;
         }
         this.DescriptionList[_loc2_]._visible = true;
         _loc3_ = this.DescriptionList[_loc2_].Item;
         _loc5_ = this.DescriptionList[_loc2_].Value;
         _loc4_ = aLineItems[_loc2_].Item;
         _loc3_.autoSize = "left";
         _loc3_.text = !(_loc4_ != undefined && _loc4_.length > 0) ? "" : _loc4_ + ": ";
         _loc5_.autoSize = "left";
         _loc5_.text = aLineItems[_loc2_].Value == undefined ? "" : aLineItems[_loc2_].Value;
         _loc5_._x = _loc3_._x + _loc3_._width;
         _loc8_ += this.DescriptionList[_loc2_]._height;
         _loc2_ = _loc2_ + 1;
      }
      while(_loc2_ < this.DescriptionList.length)
      {
         this.DescriptionList[_loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
      var _loc7_ = (- _loc8_) / 2;
      _loc2_ = 0;
      this.Title._y = _loc7_;
      _loc7_ += this.Title.text.length <= 0 ? 0 : this.Title._height;
      while(_loc2_ < this.DescriptionList.length)
      {
         this.DescriptionList[_loc2_]._y = _loc7_;
         _loc7_ += this.DescriptionList[_loc2_]._height;
         _loc2_ = _loc2_ + 1;
      }
   }
   function OnShowFinish()
   {
      gfx.io.GameDelegate.call("PlaySound",["UIMapRolloverFlyout"]);
   }
}
