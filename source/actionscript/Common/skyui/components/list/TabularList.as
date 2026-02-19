class skyui.components.list.TabularList extends skyui.components.list.ScrollingList
{
   var _layout;
   var _listHeight;
   var _maxListIndex;
   var _platform;
   var disableInput;
   var dispatchEvent;
   var entryHeight;
   var header;
   var leftBorder;
   var requestUpdate;
   var _previousColumnKey = -1;
   var _nextColumnKey = -1;
   var _sortOrderKey = -1;
   function TabularList()
   {
      super();
      skyui.util.ConfigManager.registerLoadCallback(this,"onConfigLoad");
   }
   function get layout()
   {
      return this._layout;
   }
   function set layout(a_layout)
   {
      if(this._layout)
      {
         this._layout.removeEventListener("layoutChange",this,"onLayoutChange");
      }
      this._layout = a_layout;
      this._layout.addEventListener("layoutChange",this,"onLayoutChange");
      if(this.header)
      {
         this.header.layout = a_layout;
      }
   }
   function handleInput(details, pathToFocus)
   {
      if(super.handleInput(details,pathToFocus))
      {
         return true;
      }
      if(!this.disableInput && this._platform != 0)
      {
         if(Shared.GlobalFunc.IsKeyPressed(details))
         {
            if(details.skseKeycode == this._previousColumnKey)
            {
               this._layout.selectColumn(this._layout.activeColumnIndex - 1);
               return true;
            }
            if(details.skseKeycode == this._nextColumnKey)
            {
               this._layout.selectColumn(this._layout.activeColumnIndex + 1);
               return true;
            }
            if(details.skseKeycode == this._sortOrderKey)
            {
               this._layout.selectColumn(this._layout.activeColumnIndex);
               return true;
            }
         }
      }
      return false;
   }
   function onConfigLoad(event)
   {
      var _loc2_ = event.config;
      if(this._platform != 0)
      {
         this._previousColumnKey = _loc2_.Input.controls.gamepad.prevColumn;
         this._nextColumnKey = _loc2_.Input.controls.gamepad.nextColumn;
         this._sortOrderKey = _loc2_.Input.controls.gamepad.sortOrder;
      }
   }
   function onLayoutChange(event)
   {
      this.entryHeight = this._layout.entryHeight;
      this.header._x = this.leftBorder;
      this._maxListIndex = Math.floor(this._listHeight / this.entryHeight + 0.05);
      if(this._layout.sortAttributes && this._layout.sortOptions)
      {
         this.dispatchEvent({type:"sortChange",attributes:this._layout.sortAttributes,options:this._layout.sortOptions});
      }
      this.requestUpdate();
   }
}
