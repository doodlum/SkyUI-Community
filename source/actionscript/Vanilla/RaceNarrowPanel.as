class RaceNarrowPanel extends Shared.CenteredList
{
   var moveListDown;
   var moveListUp;
   function RaceNarrowPanel()
   {
      super();
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      super.SetEntry(aEntryClip,aEntryObject);
      aEntryClip.EquipIcon_mc.gotoAndStop("None");
   }
   function onLoad()
   {
      Mouse.addListener(this);
   }
   function onPress()
   {
      var _loc3_ = Mouse.getTopMostEntity();
      while(_loc3_)
      {
         if(_loc3_ == _root.RaceSexMenuBaseInstance.RaceSexPanelsInstance.PanelTwoNarrowInstance.List_mc.BottomHalf)
         {
            this.moveListUp();
            break;
         }
         if(_loc3_ == _root.RaceSexMenuBaseInstance.RaceSexPanelsInstance.PanelTwoNarrowInstance.List_mc.TopHalf)
         {
            this.moveListDown();
            break;
         }
         _loc3_ = _loc3_._parent;
      }
      gfx.managers.FocusHandler.instance.setFocus(this,0);
   }
}
