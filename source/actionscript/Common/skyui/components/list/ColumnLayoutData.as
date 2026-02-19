class skyui.components.list.ColumnLayoutData
{
   var colorAttribute;
   var entryValue;
   var labelTextFormat;
   var labelValue;
   var stageName;
   var textFormat;
   var type = -1;
   var x = 0;
   var y = 0;
   var width = 0;
   var height = 0;
   var labelX = 0;
   var labelWidth = 0;
   var labelArrowDown = false;
   function ColumnLayoutData()
   {
   }
   function clear()
   {
      this.type = -1;
      this.x = this.y = this.width = this.height = this.labelX = this.labelWidth = 0;
      this.stageName = this.entryValue = this.labelValue = this.colorAttribute = null;
      this.textFormat = this.labelTextFormat = null;
      this.labelArrowDown = false;
   }
}
