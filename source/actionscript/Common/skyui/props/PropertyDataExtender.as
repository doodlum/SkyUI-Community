class skyui.props.PropertyDataExtender implements skyui.components.list.IListProcessor
{
   var _compoundPropertyList;
   var _iconList;
   var _noIconColors;
   var _propertyList;
   var compoundPropVar;
   var iconsVar;
   var propertiesVar;
   function PropertyDataExtender(a_configAppearance, a_dataSource, a_propertiesVar, a_iconsVar, a_compoundPropVar)
   {
      this.propertiesVar = a_propertiesVar;
      this.iconsVar = a_iconsVar;
      this.compoundPropVar = a_compoundPropVar;
      this._propertyList = new Array();
      this._iconList = new Array();
      this._compoundPropertyList = new Array();
      this._noIconColors = a_configAppearance.icons.item.noColor;
      var _loc11_ = "props";
      var _loc12_ = "compoundProps";
      var _loc10_;
      var _loc2_;
      var _loc7_;
      var _loc6_;
      var _loc5_;
      if(this.propertiesVar)
      {
         _loc10_ = a_dataSource[this.propertiesVar];
         if(_loc10_ instanceof Array)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc10_.length)
            {
               _loc7_ = _loc10_[_loc2_];
               _loc6_ = a_dataSource[_loc11_][_loc7_];
               _loc5_ = new skyui.props.PropertyLookup(_loc6_);
               this._propertyList.push(_loc5_);
               _loc2_ = _loc2_ + 1;
            }
         }
      }
      var _loc9_;
      if(this.iconsVar)
      {
         _loc9_ = a_dataSource[this.iconsVar];
         if(_loc9_ instanceof Array)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc9_.length)
            {
               _loc7_ = _loc9_[_loc2_];
               _loc6_ = a_dataSource[_loc11_][_loc7_];
               _loc5_ = new skyui.props.PropertyLookup(_loc6_);
               this._iconList.push(_loc5_);
               _loc2_ = _loc2_ + 1;
            }
         }
      }
      var _loc8_;
      var _loc4_;
      if(this.compoundPropVar)
      {
         _loc8_ = a_dataSource[this.compoundPropVar];
         if(_loc8_ instanceof Array)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc8_.length)
            {
               _loc7_ = _loc8_[_loc2_];
               _loc6_ = a_dataSource[_loc12_][_loc7_];
               _loc4_ = new skyui.props.CompoundProperty(_loc6_);
               this._compoundPropertyList.push(_loc4_);
               _loc2_ = _loc2_ + 1;
            }
         }
      }
   }
   function processList(a_list)
   {
      var _loc3_ = a_list.entryList;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_.length)
      {
         this.processEntry(_loc3_[_loc2_]);
         _loc2_ = _loc2_ + 1;
      }
   }
   function processEntry(a_entryObject)
   {
      var _loc2_ = 0;
      while(_loc2_ < this._propertyList.length)
      {
         this._propertyList[_loc2_].processProperty(a_entryObject);
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < this._iconList.length)
      {
         this._iconList[_loc2_].processProperty(a_entryObject);
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < this._compoundPropertyList.length)
      {
         this._compoundPropertyList[_loc2_].processCompoundProperty(a_entryObject);
         _loc2_ = _loc2_ + 1;
      }
      if(this._noIconColors && a_entryObject.iconColor != undefined)
      {
         delete a_entryObject.iconColor;
      }
   }
}
