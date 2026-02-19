class skyui.util.DialogManager
{
   static var _activeDialog;
   static var _previousFocus;
   function DialogManager()
   {
   }
   static function open(a_target, a_linkageID, a_init)
   {
      if(skyui.util.DialogManager._activeDialog)
      {
         skyui.util.DialogManager.close();
      }
      skyui.util.DialogManager._previousFocus = gfx.managers.FocusHandler.instance.getFocus(0);
      skyui.util.DialogManager._activeDialog = skyui.components.dialog.BasicDialog(a_target.attachMovie(a_linkageID,"dialog",a_target.getNextHighestDepth(),a_init));
      gfx.managers.FocusHandler.instance.setFocus(skyui.util.DialogManager._activeDialog,0);
      skyui.util.DialogManager._activeDialog.openDialog();
      return skyui.util.DialogManager._activeDialog;
   }
   static function close()
   {
      gfx.managers.FocusHandler.instance.setFocus(skyui.util.DialogManager._previousFocus,0);
      skyui.util.DialogManager._activeDialog.closeDialog();
      skyui.util.DialogManager._activeDialog = null;
   }
}
