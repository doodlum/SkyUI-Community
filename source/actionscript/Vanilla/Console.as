class Console extends MovieClip
{
   var Animating;
   var Background;
   var CommandEntry;
   var CommandHistory;
   var CurrentSelection;
   var CurrentSelectionYOffset;
   var Hiding;
   var OriginalHeight;
   var OriginalWidth;
   var PreviousCommandOffset;
   var ScreenPercent;
   var Shown;
   var TextXOffset;
   static var PREVIOUS_COMMANDS = 32;
   static var HistoryCharBufferSize = 8192;
   static var ConsoleInstance = null;
   var Commands = new Array();
   function Console()
   {
      super();
      _global.gfxExtensions = true;
      Shared.GlobalFunc.MaintainTextFormat();
      Console.ConsoleInstance = this;
      this.Background = this.Background;
      this.CommandEntry = this.CommandEntry;
      this.CurrentSelection = this.CurrentSelection;
      this.CurrentSelectionYOffset = this._height + this.CurrentSelection._y;
      this.CommandHistory = this.CommandHistory;
      this.TextXOffset = this.CommandEntry._x;
      this.OriginalHeight = Stage.height;
      this.OriginalWidth = Stage.width;
      this.ScreenPercent = 100 * (this._height / Stage.height);
      this.PreviousCommandOffset = 0;
      this.Shown = false;
      this.Animating = false;
      this.Hiding = false;
      this.CommandEntry.setNewTextFormat(this.CommandEntry.getTextFormat());
      this.CommandEntry.text = "";
      this.CommandEntry.noTranslate = true;
      this.CurrentSelection.setNewTextFormat(this.CurrentSelection.getTextFormat());
      this.CurrentSelection.text = "";
      this.CurrentSelection.noTranslate = true;
      this.CommandHistory.setNewTextFormat(this.CommandHistory.getTextFormat());
      this.CommandHistory.text = "";
      this.CommandHistory.noTranslate = true;
      Stage.align = "BL";
      Stage.scaleMode = "noScale";
      Stage.addListener(this);
      Key.addListener(this);
      this.onResize();
   }
   static function Show()
   {
      if(Console.ConsoleInstance != null && !Console.ConsoleInstance.Animating)
      {
         Console.ConsoleInstance._parent._y = Console.ConsoleInstance.OriginalHeight;
         Console.ConsoleInstance._parent.gotoAndPlay("show_anim");
         Selection.setFocus(Console.ConsoleInstance.CommandEntry,0);
         Console.ConsoleInstance.Animating = true;
         Selection.setSelection(Console.ConsoleInstance.CommandEntry.length,Console.ConsoleInstance.CommandEntry.length);
      }
   }
   static function ShowComplete()
   {
      if(Console.ConsoleInstance != null)
      {
         Console.ConsoleInstance.Shown = true;
         Console.ConsoleInstance.Animating = false;
      }
   }
   static function Hide()
   {
      if(Console.ConsoleInstance != null && !Console.ConsoleInstance.Animating)
      {
         Console.ConsoleInstance._parent.gotoAndPlay("hide_anim");
         Selection.setFocus(null,0);
         Console.ConsoleInstance.ResetCommandEntry();
         Console.ConsoleInstance.Animating = true;
         Console.ConsoleInstance.Hiding = true;
      }
   }
   static function HideComplete()
   {
      if(Console.ConsoleInstance != null)
      {
         Console.ConsoleInstance.Shown = false;
         Console.ConsoleInstance.Animating = false;
         Console.ConsoleInstance.Hiding = false;
         gfx.io.GameDelegate.call("HideComplete",[]);
      }
   }
   static function Minimize()
   {
      if(Console.ConsoleInstance != null)
      {
         Console.ConsoleInstance._parent._y = Console.ConsoleInstance.OriginalHeight - Console.ConsoleInstance.CommandHistory._y;
      }
   }
   static function SetCurrentSelection(selectionText)
   {
      if(Console.ConsoleInstance != null)
      {
         Console.ConsoleInstance.CurrentSelection.text = selectionText;
      }
   }
   static function QShown()
   {
      return Console.ConsoleInstance != null && Console.ConsoleInstance.Shown && !Console.ConsoleInstance.Animating;
   }
   static function QHiding()
   {
      return Console.ConsoleInstance != null && Console.ConsoleInstance.Hiding;
   }
   static function PreviousCommand()
   {
      if(Console.ConsoleInstance != null)
      {
         if(Console.ConsoleInstance.PreviousCommandOffset < Console.ConsoleInstance.Commands.length)
         {
            Console.ConsoleInstance.PreviousCommandOffset = Console.ConsoleInstance.PreviousCommandOffset + 1;
         }
         if(0 != Console.ConsoleInstance.Commands.length && 0 != Console.ConsoleInstance.PreviousCommandOffset)
         {
            Console.ConsoleInstance.CommandEntry.text = Console.ConsoleInstance.Commands[Console.ConsoleInstance.Commands.length - Console.ConsoleInstance.PreviousCommandOffset];
            Selection.setSelection(Console.ConsoleInstance.CommandEntry.length,Console.ConsoleInstance.CommandEntry.length);
         }
      }
   }
   static function NextCommand()
   {
      if(Console.ConsoleInstance != null)
      {
         if(Console.ConsoleInstance.PreviousCommandOffset > 1)
         {
            Console.ConsoleInstance.PreviousCommandOffset--;
         }
         if(0 != Console.ConsoleInstance.Commands.length && 0 != Console.ConsoleInstance.PreviousCommandOffset)
         {
            Console.ConsoleInstance.CommandEntry.text = Console.ConsoleInstance.Commands[Console.ConsoleInstance.Commands.length - Console.ConsoleInstance.PreviousCommandOffset];
            Selection.setSelection(Console.ConsoleInstance.CommandEntry.length,Console.ConsoleInstance.CommandEntry.length);
         }
      }
   }
   static function AddHistory(aText)
   {
      if(Console.ConsoleInstance != null)
      {
         Console.ConsoleInstance.CommandHistory.text += aText;
         if(Console.ConsoleInstance.CommandHistory.text.length > Console.HistoryCharBufferSize)
         {
            Console.ConsoleInstance.CommandHistory.text = Console.ConsoleInstance.CommandHistory.text.substr(- Console.HistoryCharBufferSize);
         }
         Console.ConsoleInstance.CommandHistory.scroll = Console.ConsoleInstance.CommandHistory.maxscroll;
      }
   }
   static function ClearHistory()
   {
      if(Console.ConsoleInstance != null)
      {
         Console.ConsoleInstance.CommandHistory.text = "";
      }
   }
   static function SetHistoryCharBufferSize(aNumChars)
   {
      Console.HistoryCharBufferSize = aNumChars;
   }
   static function SetTextColor(aColor)
   {
      Console.ConsoleInstance.CommandEntry.textColor = aColor;
      Console.ConsoleInstance.CurrentSelection.textColor = aColor;
   }
   static function SetTextSize(aPointSize)
   {
      var _loc1_;
      _loc1_ = Console.ConsoleInstance.CurrentSelection.getNewTextFormat();
      _loc1_.size = Math.max(1,aPointSize);
      Console.ConsoleInstance.CurrentSelection.setTextFormat(_loc1_);
      Console.ConsoleInstance.CurrentSelection.setNewTextFormat(_loc1_);
      _loc1_ = Console.ConsoleInstance.CommandHistory.getNewTextFormat();
      _loc1_.size = Math.max(1,aPointSize - 2);
      Console.ConsoleInstance.CommandHistory.setTextFormat(_loc1_);
      Console.ConsoleInstance.CommandHistory.setNewTextFormat(_loc1_);
      _loc1_ = Console.ConsoleInstance.CommandEntry.getNewTextFormat();
      _loc1_.size = Math.max(1,aPointSize);
      Console.ConsoleInstance.CommandEntry.setTextFormat(_loc1_);
      Console.ConsoleInstance.CommandEntry.setNewTextFormat(_loc1_);
      Console.PositionTextFields();
   }
   static function SetHistoryTextColor(aColor)
   {
      Console.ConsoleInstance.CommandHistory.textColor = aColor;
   }
   static function SetSize(aPercent)
   {
      Console.ConsoleInstance.ScreenPercent = aPercent;
      aPercent /= 100;
      Console.ConsoleInstance.Background._height = Stage.height * aPercent;
      Console.PositionTextFields();
   }
   static function PositionTextFields()
   {
      var _loc2_ = Console.ConsoleInstance.CurrentSelection;
      var _loc1_ = Console.ConsoleInstance.CommandHistory;
      _loc2_._y = Console.ConsoleInstance.CurrentSelectionYOffset - Console.ConsoleInstance.Background._height;
      _loc1_._y = _loc2_._y + _loc2_._height;
      _loc1_._height = Console.ConsoleInstance.CommandEntry._y - _loc1_._y;
   }
   function ResetCommandEntry()
   {
      this.CommandEntry.text = "";
      this.PreviousCommandOffset = 0;
   }
   function onKeyDown()
   {
      var _loc3_;
      var _loc2_;
      if(Key.getCode() == 13 || Key.getCode() == 108)
      {
         if(this.CommandEntry.text.length != 0)
         {
            if(this.Commands.length >= Console.PREVIOUS_COMMANDS)
            {
               this.Commands.shift();
            }
            this.Commands.push(this.CommandEntry.text);
            Console.AddHistory(this.CommandEntry.text + "\n");
            gfx.io.GameDelegate.call("ExecuteCommand",[this.CommandEntry.text]);
            this.ResetCommandEntry();
         }
      }
      else if(Key.getCode() == 33)
      {
         _loc3_ = this.CommandHistory.bottomScroll - this.CommandHistory.scroll;
         _loc2_ = this.CommandHistory.scroll - _loc3_;
         this.CommandHistory.scroll = _loc2_ <= 0 ? 0 : _loc2_;
      }
      else if(Key.getCode() == 34)
      {
         _loc3_ = this.CommandHistory.bottomScroll - this.CommandHistory.scroll;
         _loc2_ = this.CommandHistory.scroll + _loc3_;
         this.CommandHistory.scroll = _loc2_ > this.CommandHistory.maxscroll ? this.CommandHistory.maxscroll : _loc2_;
      }
   }
   function onResize()
   {
      this.Background._width = Stage.width;
      this.CommandEntry._width = this.CommandHistory._width = this.CurrentSelection._width = Stage.width - this.TextXOffset * 2;
      Console.SetSize(this.ScreenPercent);
   }
}
