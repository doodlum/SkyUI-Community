class skyui.defines.Input
{
   static var DEVICE_KEYBOARD = 0;
   static var DEVICE_MOUSE = 1;
   static var DEVICE_GAMEPAD = 2;
   static var CONTEXT_GAMEPLAY = 0;
   static var CONTEXT_MENUMODE = 1;
   static var CONTEXT_CONSOLE = 2;
   static var CONTEXT_ITEMMENU = 3;
   static var CONTEXT_INVENTORY = 4;
   static var CONTEXT_DEBUGTEXT = 5;
   static var CONTEXT_FAVORITES = 6;
   static var CONTEXT_MAP = 7;
   static var CONTEXT_STATS = 8;
   static var CONTEXT_CURSOR = 9;
   static var CONTEXT_BOOK = 10;
   static var CONTEXT_DEBUGOVERLAY = 11;
   static var CONTEXT_JOURNAL = 12;
   static var CONTEXT_TFCMODE = 13;
   static var CONTEXT_MAPDEBUG = 14;
   static var CONTEXT_LOCKPICKING = 15;
   static var CONTEXT_FAVOR = 16;
   static var ChargeItem = {name:"ChargeItem",context:skyui.defines.Input.CONTEXT_INVENTORY};
   static var XButton = {name:"XButton",context:skyui.defines.Input.CONTEXT_ITEMMENU};
   static var YButton = {name:"YButton",context:skyui.defines.Input.CONTEXT_ITEMMENU};
   static var Wait = {name:"Wait",context:skyui.defines.Input.CONTEXT_GAMEPLAY};
   static var Jump = {name:"Jump",context:skyui.defines.Input.CONTEXT_GAMEPLAY};
   static var Sprint = {name:"Sprint",context:skyui.defines.Input.CONTEXT_GAMEPLAY};
   static var Shout = {name:"Shout",context:skyui.defines.Input.CONTEXT_GAMEPLAY};
   static var Activate = {name:"Activate",context:skyui.defines.Input.CONTEXT_GAMEPLAY};
   static var ReadyWeapon = {name:"Ready Weapon",context:skyui.defines.Input.CONTEXT_GAMEPLAY};
   static var TogglePOV = {name:"Toggle POV",context:skyui.defines.Input.CONTEXT_GAMEPLAY};
   static var Accept = {name:"Accept",context:skyui.defines.Input.CONTEXT_MENUMODE};
   static var Cancel = {name:"Cancel",context:skyui.defines.Input.CONTEXT_MENUMODE};
   static var JournalXButton = {name:"XButton",context:skyui.defines.Input.CONTEXT_JOURNAL};
   static var JournalYButton = {name:"YButton",context:skyui.defines.Input.CONTEXT_JOURNAL};
   static var LeftRight = [{name:"Left",context:skyui.defines.Input.CONTEXT_MENUMODE},{name:"Right",context:skyui.defines.Input.CONTEXT_MENUMODE}];
   static var Equip = [{name:"RightEquip",context:skyui.defines.Input.CONTEXT_ITEMMENU},{name:"LeftEquip",context:skyui.defines.Input.CONTEXT_ITEMMENU}];
   static var SortColumn = [{keyCode:274},{keyCode:275}];
   static var SortOrder = {keyCode:272};
   static var GamepadBack = {keyCode:271};
   static var Enter = {keyCode:28};
   static var Tab = {keyCode:15};
   static var Shift = {keyCode:42};
   static var Space = {keyCode:57};
   static var Alt = {keyCode:56};
   function Input()
   {
   }
}
