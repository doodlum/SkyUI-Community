class CategoryListEntry extends skyui.components.list.BasicListEntry
{
   var _alpha;
   var _iconLabel;
   var _iconSize;
   var enabled;
   var icon;
   function CategoryListEntry()
   {
      super();
   }
   function initialize(a_index, a_state)
   {
      super.initialize();
      var _loc3_ = new MovieClipLoader();
      _loc3_.addListener(this);
      this._iconLabel = CategoryList(a_state.list).iconArt[a_index];
      this._iconSize = CategoryList(a_state.list).iconSize;
      _loc3_.loadClip(a_state.iconSource,this.icon);
   }
   function setEntry(a_entryObject, a_state)
   {
      if(a_entryObject.filterFlag == 0 && !a_entryObject.bDontHide)
      {
         this._alpha = 15;
         this.enabled = false;
      }
      else if(a_entryObject == a_state.list.selectedEntry)
      {
         this._alpha = 100;
         this.enabled = true;
      }
      else
      {
         this._alpha = 50;
         this.enabled = true;
      }
   }
   function onLoadInit(a_mc)
   {
      if(a_mc.background != undefined)
      {
         a_mc._xscale = a_mc._yscale = this._iconSize / a_mc.background._width * 100;
      }
      else
      {
         a_mc._width = a_mc._height = this._iconSize;
      }
      a_mc.gotoAndStop(this._iconLabel);
   }
}
