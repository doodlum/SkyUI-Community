class skyui.util.DialogManager
{
    
  /* PRIVATE VARIABLES */

    // There can only be one open dialog at a time.
    private static var _activeDialog: BasicDialog;
    private static var _previousFocus: Object;
    private static var _closeCallback: Function;
    
    
  /* PUBLIC FUNCTIONS */
    
    public static function open(a_target: MovieClip, a_linkageID: String, a_init: Object)
    {
        if (skyui.util.DialogManager._activeDialog)
            skyui.util.DialogManager.close();
        
        skyui.util.DialogManager._previousFocus = gfx.managers.FocusHandler.instance.getFocus(0);

        skyui.util.DialogManager._activeDialog = skyui.components.dialog.BasicDialog(a_target.attachMovie(a_linkageID, "dialog", a_target.getNextHighestDepth(), a_init));
        gfx.managers.FocusHandler.instance.setFocus(skyui.util.DialogManager._activeDialog, 0);
        
        skyui.util.DialogManager._activeDialog.openDialog();
        
        return skyui.util.DialogManager._activeDialog;
    }
    
    public static function close()
    {
        gfx.managers.FocusHandler.instance.setFocus(skyui.util.DialogManager._previousFocus, 0);
        
        skyui.util.DialogManager._activeDialog.closeDialog();
        skyui.util.DialogManager._activeDialog = null;
    }
}
