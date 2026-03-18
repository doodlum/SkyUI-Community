class BookMenu extends MovieClip
{
   var BookPages;
   var PageInfoA;
   var RefTextFieldTextFormat;
   var ReferenceTextField;
   var ReferenceTextInstance;
   var ReferenceText_mc;
   var bNote;
   var iCurrentLine;
   var iLeftPageNumber;
   var iMaxPageHeight;
   var iNextPageBreak;
   var iPageSetIndex;
   var iPaginationIndex;
   static var BookMenuInstance;
   static var PAGE_BREAK_TAG = "[pagebreak]";
   static var NOTE_WIDTH = 400;
   static var NOTE_X_OFFSET = 20;
   static var NOTE_Y_OFFSET = 10;
   static var CACHED_PAGES = 4;
   function BookMenu()
   {
      super();
      BookMenu.BookMenuInstance = this;
      this.BookPages = new Array();
      this.PageInfoA = new Array();
      this.iLeftPageNumber = 0;
      this.iPageSetIndex = 0;
      this.bNote = false;
      this.ReferenceText_mc = this.ReferenceTextInstance;
      this.RefTextFieldTextFormat = this.ReferenceText_mc.PageTextField.getTextFormat();
   }
   function onLoad()
   {
      this.ReferenceText_mc._visible = false;
      this.ReferenceTextField = this.ReferenceText_mc.PageTextField;
      this.ReferenceTextField.noTranslate = true;
      this.ReferenceTextField.setTextFormat(this.RefTextFieldTextFormat);
      this.iMaxPageHeight = this.ReferenceTextField._height;
      gfx.io.GameDelegate.addCallBack("SetBookText",this,"SetBookText");
      gfx.io.GameDelegate.addCallBack("TurnPage",this,"TurnPage");
      gfx.io.GameDelegate.addCallBack("PrepForClose",this,"PrepForClose");
   }
   function SetBookText(astrText, abNote)
   {
      this.bNote = abNote;
      this.ReferenceTextField.verticalAutoSize = "top";
      this.ReferenceTextField.SetText(astrText,true);
      if(abNote)
      {
         this.ReferenceTextField._width = BookMenu.NOTE_WIDTH;
      }
      this.PageInfoA.push({pageTop:0,pageHeight:this.iMaxPageHeight});
      this.iCurrentLine = 0;
      this.iPaginationIndex = setInterval(this,"CalculatePagination",30);
      this.iNextPageBreak = this.iMaxPageHeight;
      this.SetLeftPageNumber(0);
   }
   function CreateDisplayPage(PageTop, PageBottom, aPageNum)
   {
      var _loc2_ = this.ReferenceText_mc.duplicateMovieClip("Page",this.getNextHighestDepth());
      var _loc3_ = _loc2_.PageTextField;
      _loc3_.noTranslate = true;
      _loc3_.SetText(this.ReferenceTextField.htmlText,true);
      var _loc4_ = this.ReferenceTextField.getLineOffset(this.ReferenceTextField.getLineIndexAtPoint(0,PageTop));
      var _loc5_ = this.ReferenceTextField.getLineOffset(this.ReferenceTextField.getLineIndexAtPoint(0,PageBottom));
      _loc3_.replaceText(0,_loc4_,"");
      _loc3_.replaceText(_loc5_ - _loc4_,this.ReferenceTextField.length,"");
      _loc3_.autoSize = "left";
      if(this.bNote)
      {
         _loc3_._width = BookMenu.NOTE_WIDTH;
         _loc2_._x = Stage.visibleRect.x + BookMenu.NOTE_X_OFFSET;
         _loc2_._y = Stage.visibleRect.y + BookMenu.NOTE_Y_OFFSET;
      }
      else
      {
         _loc2_._x = this.ReferenceText_mc._x;
         _loc2_._y = this.ReferenceText_mc._y;
      }
      _loc2_._visible = false;
      _loc2_.pageNum = aPageNum;
      this.BookPages.push(_loc2_);
   }
   function CalculatePagination()
   {
      var _loc7_ = false;
      var _loc5_;
      var _loc6_;
      var _loc3_;
      var _loc4_;
      var _loc2_;
      while(!_loc7_ && this.iCurrentLine <= this.ReferenceTextField.numLines)
      {
         _loc5_ = this.ReferenceTextField.getLineOffset(this.iCurrentLine);
         _loc6_ = this.ReferenceTextField.getLineOffset(this.iCurrentLine + 1);
         _loc3_ = this.ReferenceTextField.getCharBoundaries(_loc5_);
         _loc4_ = _loc6_ == -1 ? this.ReferenceTextField.text.substring(_loc5_) : this.ReferenceTextField.text.substring(_loc5_,_loc6_);
         _loc4_ = Shared.GlobalFunc.StringTrim(_loc4_);
         if(_loc3_.bottom > this.iNextPageBreak || _loc4_ == BookMenu.PAGE_BREAK_TAG || this.iCurrentLine >= this.ReferenceTextField.numLines)
         {
            _loc2_ = {pageTop:0,pageHeight:this.iMaxPageHeight};
            if(_loc4_ == BookMenu.PAGE_BREAK_TAG)
            {
               _loc2_.pageTop = _loc3_.bottom + this.ReferenceTextField.getLineMetrics(this.iCurrentLine).leading;
               this.PageInfoA[this.PageInfoA.length - 1].pageHeight = _loc3_.top - this.PageInfoA[this.PageInfoA.length - 1].pageTop;
            }
            else
            {
               _loc2_.pageTop = _loc3_.top;
               this.PageInfoA[this.PageInfoA.length - 1].pageHeight = _loc2_.pageTop - this.PageInfoA[this.PageInfoA.length - 1].pageTop;
            }
            this.iNextPageBreak = _loc2_.pageTop + this.iMaxPageHeight;
            if(_loc2_.pageTop != undefined || this.bNote)
            {
               this.PageInfoA.push(_loc2_);
            }
            _loc7_ = true;
         }
         this.iCurrentLine = this.iCurrentLine + 1;
      }
      if(this.iCurrentLine >= this.ReferenceTextField.numLines)
      {
         clearInterval(this.iPaginationIndex);
         this.iPaginationIndex = -1;
      }
      this.UpdatePages();
   }
   function SetLeftPageNumber(aiPageNum)
   {
      if(aiPageNum < this.PageInfoA.length)
      {
         this.iLeftPageNumber = aiPageNum;
      }
   }
   function ShowPageAtOffset(aiPageOffset)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.BookPages.length)
      {
         if(this.BookPages[_loc2_].pageNum == this.iPageSetIndex + aiPageOffset)
         {
            this.BookPages[_loc2_]._visible = true;
         }
         else
         {
            this.BookPages[_loc2_]._visible = false;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function PrepForClose()
   {
      this.iPageSetIndex = this.iLeftPageNumber;
   }
   function TurnPage(aiDelta)
   {
      var _loc2_ = this.iLeftPageNumber + aiDelta;
      var _loc4_ = _loc2_ >= 0 && _loc2_ < this.PageInfoA.length;
      if(this.bNote)
      {
         _loc4_ = _loc2_ >= 0 && _loc2_ < this.PageInfoA.length - 1;
      }
      var _loc3_ = Math.abs(aiDelta);
      var _loc5_;
      if(_loc4_)
      {
         _loc5_ = _loc3_ != 1 ? 4 : 1;
         this.SetLeftPageNumber(_loc2_);
         if(this.iLeftPageNumber < this.iPageSetIndex)
         {
            this.iPageSetIndex -= _loc3_;
         }
         else if(this.iLeftPageNumber >= this.iPageSetIndex + _loc5_)
         {
            this.iPageSetIndex += _loc3_;
         }
         this.UpdatePages();
      }
      return _loc4_;
   }
   function UpdatePages()
   {
      var _loc2_ = 0;
      var _loc4_;
      var _loc3_;
      while(_loc2_ < BookMenu.CACHED_PAGES)
      {
         _loc4_ = false;
         _loc3_ = 0;
         while(!_loc4_ && _loc3_ < this.BookPages.length)
         {
            if(this.BookPages[_loc3_].pageNum == this.iPageSetIndex + _loc2_)
            {
               _loc4_ = true;
            }
            _loc3_ = _loc3_ + 1;
         }
         if(!_loc4_ && (this.PageInfoA.length > this.iPageSetIndex + _loc2_ + 1 || this.iPaginationIndex == -1 && this.PageInfoA.length > this.iPageSetIndex + _loc2_))
         {
            this.CreateDisplayPage(this.PageInfoA[this.iPageSetIndex + _loc2_].pageTop,this.PageInfoA[this.iPageSetIndex + _loc2_].pageTop + this.PageInfoA[this.iPageSetIndex + _loc2_].pageHeight,this.iPageSetIndex + _loc2_);
         }
         _loc2_ = _loc2_ + 1;
      }
      var _loc5_ = 0;
      while(_loc5_ < this.BookPages.length)
      {
         if(this.BookPages[_loc5_].pageNum < this.iPageSetIndex || this.BookPages[_loc5_].pageNum >= this.iPageSetIndex + BookMenu.CACHED_PAGES)
         {
            this.BookPages.splice(_loc5_,1)[0].removeMovieClip();
         }
         _loc5_ = _loc5_ + 1;
      }
   }
}
