class GroupButton extends gfx.controls.Button
{
   var groupNum;
   var text;
   var _groupIndex = 0;
   var _filterFlag = 0;
   function GroupButton()
   {
      super();
      this.text = skyui.util.Translator.translate("$GROUP") + " " + (this.groupIndex + 1);
   }
   function get groupIndex()
   {
      return this._groupIndex;
   }
   function set groupIndex(a_index)
   {
      this._groupIndex = a_index;
      this._filterFlag = FilterDataExtender.FILTERFLAG_GROUP_0 << this.groupIndex | FilterDataExtender.FILTERFLAG_GROUP_ADD;
      this.groupNum.gotoAndStop(this.groupIndex + 1);
   }
   function get filterFlag()
   {
      return this._filterFlag;
   }
}
