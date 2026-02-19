class skyui.props.CompoundProperty
{
   var defaultValues;
   var itemFilter;
   var numPadding;
   var overwrite;
   var padString;
   var propertyList;
   var propertyToSet;
   function CompoundProperty(configObject)
   {
      this.propertyToSet = configObject.propertyToSet;
      this.itemFilter = new skyui.props.ItemFilter(configObject.filter);
      this.defaultValues = configObject.defaultValues;
      this.padString = configObject.padString;
      if(this.padString == undefined)
      {
         this.padString = "0";
      }
      this.numPadding = configObject.numPadding;
      if(this.numPadding == undefined)
      {
         this.numPadding = 3;
      }
      this.overwrite = configObject.overwrite;
      if(this.overwrite == undefined)
      {
         this.overwrite = false;
      }
      this.propertyList = configObject.concatenateList;
   }
   function _padString(_str, _n, _pStr)
   {
      var _loc6_ = _str;
      if(_pStr == undefined || _pStr == null || _pStr.length < 1)
      {
         _pStr = " ";
      }
      var _loc4_;
      var _loc1_;
      if(_str.length < _n)
      {
         _loc4_ = "";
         _loc1_ = 0;
         while(_loc1_ < _n - _str.length)
         {
            _loc4_ += _pStr;
            _loc1_ = _loc1_ + 1;
         }
         _loc6_ = _loc4_ + _str;
      }
      return _loc6_;
   }
   function processCompoundProperty(obj)
   {
      if(!this.itemFilter.passesFilter(obj))
      {
         return false;
      }
      if(!this.overwrite && obj[this.propertyToSet] != undefined && obj[this.propertyToSet] != this.defaultValues[this.propertyToSet])
      {
         return false;
      }
      var _loc6_ = "";
      var _loc3_ = 0;
      var _loc2_;
      var _loc5_;
      while(_loc3_ < this.propertyList.length)
      {
         _loc2_ = this.propertyList[_loc3_];
         _loc5_ = String(this.defaultValues[_loc2_]);
         if(obj.hasOwnProperty(_loc2_) && obj[_loc2_] != undefined && obj[_loc2_] != "")
         {
            _loc5_ = String(obj[_loc2_]);
         }
         _loc6_ += this._padString(_loc5_,this.numPadding,this.padString);
         _loc3_ = _loc3_ + 1;
      }
      if(_loc6_ == "" && this.defaultValues[this.propertyToSet])
      {
         _loc6_ = this.defaultValues[this.propertyToSet];
      }
      obj[this.propertyToSet] = _loc6_;
      return true;
   }
}
