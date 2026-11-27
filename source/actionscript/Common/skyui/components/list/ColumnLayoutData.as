class skyui.components.list.ColumnLayoutData
{
	public var type: Number = -1;

    // Entry  ---------------------------------

    // Position relative to the entry.
    public var x: Number = 0;
    public var y: Number = 0;

    public var width: Number = 0;
    public var height: Number = 0;

    // These are the names like textField0, equipIcon etc 
    public var stageName: String;

    // Only defined for text fields
    public var entryValue: String;
    public var textFormat: TextFormat;

    public var colorAttribute: String; // support for dynamic entry coloring that overrides static textFormat

    // Label ---------------------------------

    public var labelX: Number = 0;

    public var labelWidth: Number = 0;

    public var labelArrowDown: Boolean = false;

    public var labelValue: String;

    public var labelTextFormat: TextFormat;

    public function clear()
    {
        this.type = -1;
        this.x = this.y = this.width = this.height = this.labelX = this.labelWidth = 0;
        this.stageName = this.entryValue = this.labelValue = this.colorAttribute = null;
        this.textFormat = this.labelTextFormat = null;
        this.labelArrowDown = false;
    }
}