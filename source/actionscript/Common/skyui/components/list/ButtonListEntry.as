/*
 *  A generic entry.
 *  Sets this.selectIndicator visible for the selected entry, if defined.
 *  Sets this.textField to obj.text.
 *  Forwards to label obj.state, if defined.
 */
class skyui.components.list.ButtonListEntry extends skyui.components.list.BasicListEntry
{
  /* PRIVATE VARIABLES */


  /* STAGE ELEMENTS */

    public var activeIndicator: MovieClip;
    public var selectIndicator: MovieClip;
    public var textField: TextField;
    public var icon: MovieClip;


  /* PROPERTIES */

    public static var defaultTextColor: Number = 0xffffff;
    public static var activeTextColor: Number = 0xffffff;
    public static var selectedTextColor: Number = 0xffffff;
    public static var disabledTextColor: Number = 0x505050;


  /* PUBLIC FUNCTIONS */

    public function setEntry(a_entryObject: Object, a_state: ListState)
    {
        // Not using "enabled" directly, because we still want to be able to receive onMouseX events,
        // even if we chose not to process them.
        this.isEnabled = a_entryObject.enabled;
        
        var isSelected = a_entryObject == a_state.list.selectedEntry;
        var isActive = (a_state.activeEntry != undefined && a_entryObject == a_state.activeEntry);

        if (a_entryObject.state != undefined)
            this.gotoAndPlay(a_entryObject.state);

        if (this.textField != undefined) {
            this.textField.autoSize = a_entryObject.align ? a_entryObject.align : "left";
            
            if (!a_entryObject.enabled)
                this.textField.textColor = skyui.components.list.ButtonListEntry.disabledTextColor;
            else if (isActive)
                this.textField.textColor = skyui.components.list.ButtonListEntry.activeTextColor;
            else if (isSelected)
                this.textField.textColor = skyui.components.list.ButtonListEntry.selectedTextColor;
            else
                this.textField.textColor = skyui.components.list.ButtonListEntry.defaultTextColor;
                
            this.textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
        }
        
        if (this.selectIndicator != undefined)
            this.selectIndicator._visible = isSelected;
            
        if (this.activeIndicator != undefined) {
            this.activeIndicator._visible = isActive;
            this.activeIndicator._x = this.textField._x - this.activeIndicator._width - 5;
        }
        
        if (this.icon != undefined && a_entryObject.iconLabel != undefined) {
            this.icon.gotoAndStop(a_entryObject.iconLabel);
        }
    }
}