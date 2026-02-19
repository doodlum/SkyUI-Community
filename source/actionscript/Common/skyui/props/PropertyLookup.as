class skyui.props.PropertyLookup
{
   var dataMembers;
   var defaultValues;
   var itemFilter;
   var keywords;
   var propertiesToSet;
   static var dataMemberLimit = 200;
   static var _delimiter = ";;";
   var lastValue = -1;
   function PropertyLookup(a_configObject)
   {
      this.propertiesToSet = a_configObject.propertiesToSet;
      this.itemFilter = new skyui.props.ItemFilter(a_configObject.filter);
      this.defaultValues = a_configObject.defaultValues;
      this.keywords = a_configObject.keywords;
      this._parseDataMemberList(a_configObject);
      this.lastValue = -1;
   }
   function _getPropertyValFromFilter(a_filter)
   {
      var _loc3_ = 0;
      var _loc2_ = new Array();
      for(var _loc6_ in a_filter)
      {
         _loc2_.push(_loc6_);
         _loc3_ = _loc3_ + 1;
      }
      if(_loc3_ <= 0)
      {
         return new Array("extended","true");
      }
      if(_loc3_ == 1)
      {
         return new Array(_loc2_[0],a_filter[_loc2_[0]]);
      }
      _loc2_.sort();
      var _loc6_ = _loc2_.join(skyui.props.PropertyLookup._delimiter);
      var _loc5_ = new Array();
      var _loc1_ = 0;
      while(_loc1_ < _loc3_)
      {
         _loc5_.push(a_filter[_loc2_[_loc1_]]);
         _loc1_ = _loc1_ + 1;
      }
      var _loc7_ = _loc5_.join(skyui.props.PropertyLookup._delimiter);
      return new Array(_loc6_,_loc7_);
   }
   function _parseDataMemberList(a_configObject)
   {
      this.dataMembers = new Object();
      var _loc6_;
      var _loc3_ = 1;
      var _loc4_;
      var _loc7_;
      var _loc5_;
      var _loc2_;
      var _loc8_;
      while(_loc3_ < skyui.props.PropertyLookup.dataMemberLimit)
      {
         _loc4_ = "dataMember" + _loc3_;
         if(a_configObject[_loc4_] == undefined)
         {
            break;
         }
         _loc6_ = a_configObject[_loc4_];
         _loc7_ = _loc6_.filter;
         _loc5_ = this._getPropertyValFromFilter(_loc7_);
         _loc2_ = _loc5_[0];
         _loc8_ = _loc5_[1];
         if(this.dataMembers[_loc2_] == undefined)
         {
            this.dataMembers[_loc2_] = new Object();
         }
         this.dataMembers[_loc2_][_loc8_] = _loc6_["set"];
         _loc3_ = _loc3_ + 1;
      }
   }
   function getKeywordValues(a_keyword)
   {
      return this.keywords[a_keyword];
   }
   function getDataMemberValues(a_dataMember, a_sourceValue)
   {
      return this.dataMembers[a_dataMember][a_sourceValue];
   }
   function keywordMatches(a_keyword)
   {
      return this.keywords[a_keyword] != undefined;
   }
   function dataMemberMatches(keyword, sourceValue)
   {
      return this.dataMembers[keyword][sourceValue] != undefined;
   }
   function _getMultSourceVal(a_object, a_dataMember)
   {
      var _loc2_ = a_dataMember.split(skyui.props.PropertyLookup._delimiter);
      if(_loc2_.length <= 0)
      {
         return undefined;
      }
      if(_loc2_.length == 1)
      {
         return a_object[a_dataMember];
      }
      var _loc4_ = new Array();
      var _loc1_ = 0;
      while(_loc1_ < _loc2_.length)
      {
         if(!a_object.hasOwnProperty(_loc2_[_loc1_]))
         {
            return undefined;
         }
         _loc4_.push(a_object[_loc2_[_loc1_]]);
         _loc1_ = _loc1_ + 1;
      }
      return _loc4_.join(skyui.props.PropertyLookup._delimiter);
   }
   function processProperty(a_obj)
   {
      if(!this.itemFilter.passesFilter(a_obj))
      {
         return undefined;
      }
      for(var _loc8_ in this.defaultValues)
      {
         if(this.defaultValues[_loc8_] != undefined)
         {
            a_obj[_loc8_] = this.defaultValues[_loc8_];
         }
      }
      var _loc2_;
      var _loc4_;
      for(var _loc9_ in a_obj.keywords)
      {
         _loc4_ = this.getKeywordValues(_loc9_);
         if(_loc4_ != undefined)
         {
            for(var _loc7_ in _loc4_)
            {
               _loc2_ = _loc4_[_loc7_];
               if(_loc2_ != undefined && _loc2_ != this.defaultValues[_loc7_])
               {
                  a_obj[_loc7_] = _loc2_;
               }
            }
            break;
         }
      }
      var _loc6_;
      var _loc5_;
      for(var _loc10_ in this.dataMembers)
      {
         _loc6_ = this._getMultSourceVal(a_obj,_loc10_);
         if(_loc6_ != undefined)
         {
            _loc5_ = this.getDataMemberValues(_loc10_,_loc6_);
            if(_loc5_ != undefined)
            {
               for(_loc7_ in _loc5_)
               {
                  _loc2_ = _loc5_[_loc7_];
                  if(_loc2_ != undefined && _loc2_ != this.defaultValues[_loc7_])
                  {
                     a_obj[_loc7_] = _loc2_;
                  }
               }
               break;
            }
         }
      }
   }
}
