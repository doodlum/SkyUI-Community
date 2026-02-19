class skyui.components.list.ListLayout
{
   var _columnData;
   var _columnDescriptors;
   var _columnLayoutData;
   var _columnList;
   var _defaultEntryTextFormat;
   var _defaultLabelTextFormat;
   var _defaultsData;
   var _entryHeight;
   var _entryWidth;
   var _hiddenStageNames;
   var _layoutData;
   var _prefData;
   var _sortAttributes;
   var _sortOptions;
   var _viewData;
   var _viewList;
   var dispatchEvent;
   static var MAX_TEXTFIELD_INDEX = 10;
   static var LEFT = 0;
   static var RIGHT = 1;
   static var TOP = 2;
   static var BOTTOM = 3;
   static var COL_TYPE_ITEM_ICON = 0;
   static var COL_TYPE_EQUIP_ICON = 1;
   static var COL_TYPE_TEXT = 2;
   static var COL_TYPE_NAME = 3;
   var _activeViewIndex = -1;
   var _lastViewIndex = -1;
   var _lastFilterFlag = -1;
   var _activeColumnIndex = -1;
   var _activeColumnState = 1;
   var _layoutUpdateCount = 1;
   function ListLayout(a_layoutData, a_viewData, a_columnData, a_defaultsData)
   {
      skyui.util.GlobalFunctions.addArrayFunctions();
      gfx.events.EventDispatcher.initialize(this);
      this._prefData = {column:null,stateIndex:1};
      this._viewList = [];
      this._columnList = [];
      this._columnLayoutData = [];
      this._hiddenStageNames = [];
      this._columnDescriptors = [];
      this._layoutData = a_layoutData;
      this._viewData = a_viewData;
      this._columnData = a_columnData;
      this._defaultsData = a_defaultsData;
      if(this._entryWidth == undefined)
      {
         this._entryWidth = this._defaultsData.entryWidth;
      }
      this.updateViewList();
      this.updateColumnList();
      this._defaultEntryTextFormat = new TextFormat();
      this._defaultLabelTextFormat = new TextFormat();
      for(var _loc2_ in this._defaultsData.entry.textFormat)
      {
         if(this._defaultEntryTextFormat.hasOwnProperty(_loc2_))
         {
            this._defaultEntryTextFormat[_loc2_] = this._defaultsData.entry.textFormat[_loc2_];
         }
      }
      for(_loc2_ in this._defaultsData.label.textFormat)
      {
         if(this._defaultLabelTextFormat.hasOwnProperty(_loc2_))
         {
            this._defaultLabelTextFormat[_loc2_] = this._defaultsData.label.textFormat[_loc2_];
         }
      }
   }
   function get currentView()
   {
      return this._viewList[this._activeViewIndex];
   }
   function get activeColumnIndex()
   {
      return this._activeColumnIndex;
   }
   function get columnCount()
   {
      return this._columnLayoutData.length;
   }
   function get activeColumnState()
   {
      return this._activeColumnState;
   }
   function get columnLayoutData()
   {
      return this._columnLayoutData;
   }
   function get hiddenStageNames()
   {
      return this._hiddenStageNames;
   }
   function get entryWidth()
   {
      return this._entryWidth;
   }
   function set entryWidth(a_width)
   {
      this._entryWidth = a_width;
   }
   function get entryHeight()
   {
      return this._entryHeight;
   }
   function get layoutUpdateCount()
   {
      return this._layoutUpdateCount;
   }
   function get columnDescriptors()
   {
      return this._columnDescriptors;
   }
   function get sortOptions()
   {
      return this._sortOptions;
   }
   function get sortAttributes()
   {
      return this._sortAttributes;
   }
   function refresh()
   {
      this.updateViewList();
      this._lastViewIndex = -1;
      this.changeFilterFlag(this._lastFilterFlag);
   }
   function changeFilterFlag(a_flag)
   {
      this._lastFilterFlag = a_flag;
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < this._viewList.length)
      {
         _loc3_ = !(this._viewList[_loc2_].category instanceof Array) ? [this._viewList[_loc2_].category] : this._viewList[_loc2_].category;
         if(_loc3_.indexOf(a_flag) != undefined || _loc2_ == this._viewList.length - 1)
         {
            this._activeViewIndex = _loc2_;
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(this._activeViewIndex == -1 || this._lastViewIndex == this._activeViewIndex)
      {
         return undefined;
      }
      this._lastViewIndex = this._activeViewIndex;
      this.updateColumnList();
      if(!this.restorePrefState())
      {
         this._activeColumnIndex = this.currentView.columns.indexOf(this.currentView.primaryColumn);
         if(this._activeColumnIndex == undefined)
         {
            this._activeColumnIndex = 0;
         }
         this._activeColumnState = 1;
      }
      this.updateLayout();
   }
   function selectColumn(a_index)
   {
      var _loc3_ = this.toColumnListIndex(a_index);
      var _loc2_ = this._columnList[_loc3_];
      if(_loc2_ == null || _loc2_.passive)
      {
         return undefined;
      }
      if(this._activeColumnIndex != a_index)
      {
         this._activeColumnIndex = a_index;
         this._activeColumnState = 1;
      }
      else if(this._activeColumnState < _loc2_.states)
      {
         this._activeColumnState = this._activeColumnState + 1;
      }
      else
      {
         this._activeColumnState = 1;
      }
      this._prefData.column = _loc2_;
      this._prefData.stateIndex = this._activeColumnState;
      this.updateLayout();
   }
   function restoreColumnState(a_activeIndex, a_activeState)
   {
      var _loc3_ = this.toColumnListIndex(a_activeIndex);
      var _loc2_ = this._columnList[_loc3_];
      if(_loc2_ == null || _loc2_.passive)
      {
         return undefined;
      }
      if(a_activeState < 1 || a_activeState > _loc2_.states)
      {
         return undefined;
      }
      this._activeColumnIndex = a_activeIndex;
      this._activeColumnState = a_activeState;
      this._prefData.column = _loc2_;
      this._prefData.stateIndex = this._activeColumnState;
      this.updateLayout();
   }
   function updateLayout()
   {
      this._layoutUpdateCount = this._layoutUpdateCount + 1;
      var _loc14_ = 0;
      var _loc12_ = 0;
      this._hiddenStageNames.splice(0);
      this._columnLayoutData.splice(0);
      var _loc9_ = 0;
      var _loc10_ = 0;
      var _loc13_ = 0;
      var _loc3_;
      var _loc2_;
      var _loc6_;
      while(_loc10_ < this._columnList.length)
      {
         _loc3_ = this._columnList[_loc10_];
         if(_loc3_.hidden != true)
         {
            _loc2_ = new skyui.components.list.ColumnLayoutData();
            this._columnLayoutData[_loc13_] = _loc2_;
            if(_loc13_ == this._activeColumnIndex)
            {
               _loc6_ = _loc3_["state" + this._activeColumnState];
               this.updateSortParams(_loc6_);
            }
            else
            {
               _loc6_ = _loc3_.state1;
            }
            _loc2_.type = _loc3_.type;
            _loc2_.labelArrowDown = !_loc6_.label.arrowDown ? false : true;
            _loc2_.labelValue = _loc6_.label.text;
            _loc2_.entryValue = _loc6_.entry.text;
            _loc2_.colorAttribute = _loc6_.colorAttribute;
            _loc13_ = _loc13_ + 1;
         }
         _loc10_ = _loc10_ + 1;
      }
      var _loc7_ = this._entryWidth - 12;
      var _loc11_ = 0;
      var _loc17_ = false;
      var _loc16_ = false;
      _loc10_ = 0;
      _loc13_ = 0;
      var _loc8_;
      var _loc0_;
      var _loc4_;
      while(_loc10_ < this._columnList.length)
      {
         _loc3_ = this._columnList[_loc10_];
         if(_loc3_.hidden != true)
         {
            _loc2_ = this._columnLayoutData[_loc13_++];
            if(_loc3_.weight != undefined)
            {
               _loc11_ += _loc3_.weight;
               _loc9_ = (_loc9_ | 1) << 1;
            }
            else
            {
               _loc9_ = (_loc9_ | 0) << 1;
            }
            if(_loc3_.indent != undefined)
            {
               _loc7_ -= _loc3_.indent;
            }
            _loc8_ = 0;
            switch(_loc3_.type)
            {
               case skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON:
               case skyui.components.list.ListLayout.COL_TYPE_EQUIP_ICON:
                  if(_loc3_.type == skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON)
                  {
                     _loc2_.stageName = "itemIcon";
                     _loc17_ = true;
                  }
                  else
                  {
                     _loc2_.stageName = "equipIcon";
                     _loc16_ = true;
                  }
                  this._columnLayoutData[_loc10_].height = _loc0_ = _loc3_.icon.size;
                  _loc2_.width = _loc0_;
                  _loc7_ -= _loc3_.icon.size;
                  _loc8_ += _loc3_.icon.size;
                  break;
               default:
                  _loc2_.stageName = "textField" + _loc12_++;
                  if(_loc3_.width != undefined)
                  {
                     _loc2_.width = _loc3_.width >= 1 ? _loc3_.width : _loc3_.width * this._entryWidth;
                     _loc7_ -= _loc2_.width;
                  }
                  else
                  {
                     _loc2_.width = 0;
                  }
                  if(_loc3_.height != undefined)
                  {
                     _loc2_.height = _loc3_.height >= 1 ? _loc3_.height : _loc3_.height * this._entryWidth;
                  }
                  else
                  {
                     _loc2_.height = 0;
                  }
                  if(_loc3_.entry.textFormat != undefined)
                  {
                     _loc4_ = new TextFormat();
                     for(var _loc15_ in this._defaultEntryTextFormat)
                     {
                        _loc4_[_loc15_] = this._defaultEntryTextFormat[_loc15_];
                     }
                     for(_loc15_ in _loc3_.entry.textFormat)
                     {
                        if(_loc4_.hasOwnProperty(_loc15_))
                        {
                           _loc4_[_loc15_] = _loc3_.entry.textFormat[_loc15_];
                        }
                     }
                     _loc2_.textFormat = _loc4_;
                  }
                  else
                  {
                     _loc2_.textFormat = this._defaultEntryTextFormat;
                  }
                  if(_loc3_.label.textFormat != undefined)
                  {
                     _loc4_ = new TextFormat();
                     for(_loc15_ in this._defaultLabelTextFormat)
                     {
                        _loc4_[_loc15_] = this._defaultLabelTextFormat[_loc15_];
                     }
                     for(_loc15_ in _loc3_.label.textFormat)
                     {
                        if(_loc4_.hasOwnProperty(_loc15_))
                        {
                           _loc4_[_loc15_] = _loc3_.label.textFormat[_loc15_];
                        }
                     }
                     _loc2_.labelTextFormat = _loc4_;
                     break;
                  }
                  _loc2_.labelTextFormat = this._defaultLabelTextFormat;
            }
            if(_loc3_.border != undefined)
            {
               _loc7_ -= _loc3_.border[skyui.components.list.ListLayout.LEFT] + _loc3_.border[skyui.components.list.ListLayout.RIGHT];
               _loc8_ += _loc3_.border[skyui.components.list.ListLayout.TOP] + _loc3_.border[skyui.components.list.ListLayout.BOTTOM];
               _loc2_.y = _loc3_.border[skyui.components.list.ListLayout.TOP];
            }
            else
            {
               _loc2_.y = 0;
            }
            if(_loc8_ > _loc14_)
            {
               _loc14_ = _loc8_;
            }
         }
         _loc10_ = _loc10_ + 1;
      }
      if(_loc11_ > 0 && _loc7_ > 0 && _loc9_ != 0)
      {
         _loc10_ = this._columnList.length - 1;
         _loc13_ = this._columnLayoutData.length - 1;
         while(_loc10_ >= 0)
         {
            _loc3_ = this._columnList[_loc10_];
            if(_loc3_.hidden != true)
            {
               _loc2_ = this._columnLayoutData[_loc13_--];
               if((_loc9_ >>>= 1) & 1)
               {
                  if(_loc3_.border != undefined)
                  {
                     _loc2_.width += _loc3_.weight / _loc11_ * _loc7_ - _loc3_.border[skyui.components.list.ListLayout.LEFT] - _loc3_.border[skyui.components.list.ListLayout.RIGHT];
                  }
                  else
                  {
                     _loc2_.width += _loc3_.weight / _loc11_ * _loc7_;
                  }
               }
            }
            _loc10_ = _loc10_ - 1;
         }
      }
      var _loc5_ = 0;
      _loc10_ = 0;
      _loc13_ = 0;
      while(_loc10_ < this._columnList.length)
      {
         _loc3_ = this._columnList[_loc10_];
         if(_loc3_.hidden != true)
         {
            _loc2_ = this._columnLayoutData[_loc13_++];
            if(_loc3_.indent != undefined)
            {
               _loc5_ += _loc3_.indent;
            }
            _loc2_.labelX = _loc5_;
            if(_loc3_.border != undefined)
            {
               _loc2_.labelWidth = _loc2_.width + _loc3_.border[skyui.components.list.ListLayout.LEFT] + _loc3_.border[skyui.components.list.ListLayout.RIGHT];
               _loc2_.x = _loc5_;
               _loc5_ += _loc3_.border[skyui.components.list.ListLayout.LEFT];
               _loc2_.x = _loc5_;
               _loc5_ += _loc3_.border[skyui.components.list.ListLayout.RIGHT] + _loc2_.width;
            }
            else
            {
               _loc2_.labelWidth = _loc2_.width;
               _loc2_.x = _loc5_;
               _loc5_ += _loc2_.width;
            }
         }
         _loc10_ = _loc10_ + 1;
      }
      while(_loc12_ < skyui.components.list.ListLayout.MAX_TEXTFIELD_INDEX)
      {
         this._hiddenStageNames.push("textField" + _loc12_++);
      }
      if(!_loc17_)
      {
         this._hiddenStageNames.push("itemIcon");
      }
      if(!_loc16_)
      {
         this._hiddenStageNames.push("equipIcon");
      }
      this._entryHeight = _loc14_;
      this.dispatchEvent({type:"layoutChange"});
   }
   function updateSortParams(stateData)
   {
      var _loc2_ = stateData.sortAttributes;
      var _loc3_ = stateData.sortOptions;
      if(!_loc3_)
      {
         this._sortOptions = null;
         this._sortAttributes = null;
         return undefined;
      }
      if(!_loc2_)
      {
         if(stateData.entry.text.charAt(0) == "@")
         {
            _loc2_ = [stateData.entry.text.slice(1)];
         }
      }
      if(!_loc2_)
      {
         this._sortOptions = null;
         this._sortAttributes = null;
         return undefined;
      }
      if(!(_loc2_ instanceof Array))
      {
         _loc2_ = [_loc2_];
      }
      if(!(_loc3_ instanceof Array))
      {
         _loc3_ = [_loc3_];
      }
      this._sortOptions = _loc3_;
      this._sortAttributes = _loc2_;
   }
   function restorePrefState()
   {
      if(!this._prefData.column)
      {
         return false;
      }
      var _loc3_ = this._columnList.indexOf(this._prefData.column);
      var _loc2_ = this.toColumnLayoutDataIndex(_loc3_);
      if(_loc3_ > -1 && _loc2_ > -1)
      {
         this._activeColumnIndex = _loc2_;
         this._activeColumnState = this._prefData.stateIndex;
         return true;
      }
      this._prefData.column = null;
      this._prefData.stateIndex = 1;
      return false;
   }
   function toColumnListIndex(a_index)
   {
      var _loc2_ = 0;
      var _loc3_ = 0;
      while(_loc2_ < this._columnList.length)
      {
         if(this._columnList[_loc2_].hidden != true)
         {
            if(_loc3_ == a_index)
            {
               return _loc2_;
            }
            _loc3_ = _loc3_ + 1;
         }
         _loc2_ = _loc2_ + 1;
      }
      return -1;
   }
   function toColumnLayoutDataIndex(a_index)
   {
      var _loc2_ = 0;
      var _loc3_ = 0;
      while(_loc2_ < this._columnList.length)
      {
         if(this._columnList[_loc2_].hidden != true)
         {
            if(_loc2_ == a_index)
            {
               return _loc3_;
            }
            _loc3_ = _loc3_ + 1;
         }
         _loc2_ = _loc2_ + 1;
      }
      return -1;
   }
   function updateViewList()
   {
      this._viewList.splice(0);
      var _loc3_ = this._layoutData.views;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_.length)
      {
         this._viewList.push(this._viewData[_loc3_[_loc2_]]);
         _loc2_ = _loc2_ + 1;
      }
   }
   function updateColumnList()
   {
      this._columnList.splice(0);
      this._columnDescriptors.splice(0);
      var _loc5_ = this.currentView.columns;
      var _loc3_ = 0;
      var _loc4_;
      var _loc2_;
      while(_loc3_ < _loc5_.length)
      {
         _loc4_ = this._columnData[_loc5_[_loc3_]];
         _loc2_ = new skyui.components.list.ColumnDescriptor();
         _loc2_.hidden = _loc4_.hidden;
         _loc2_.identifier = _loc5_[_loc3_];
         _loc2_.longName = _loc4_.name;
         _loc2_.type = _loc4_.type;
         this._columnList.push(_loc4_);
         this._columnDescriptors.push(_loc2_);
         _loc3_ = _loc3_ + 1;
      }
   }
}
