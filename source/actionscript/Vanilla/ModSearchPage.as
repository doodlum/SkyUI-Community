class ModSearchPage extends MovieClip
{
   var Input_tf;
   var SearchGrayText_tf;
   var SpinnerHolder_mc;
   var codeObj;
   var iPlatform;
   function ModSearchPage()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      this.SpinnerHolder_mc._visible = false;
      var _loc3_ = new Object();
      _loc3_.onChanged = Shared.Proxy.create(this,this.onSearchTextChanged);
      this.Input_tf.addListener(_loc3_);
   }
   function get CodeObject()
   {
      return this.codeObj;
   }
   function set CodeObject(value)
   {
      this.codeObj = value;
   }
   function SetPlatform(platform)
   {
      this.iPlatform = platform;
   }
   function Destroy()
   {
      return delete this.codeObj;
   }
   function SearchForMods()
   {
      if(this.iPlatform == BethesdaNetLogin.CONTROLLER_PC || this.iPlatform == BethesdaNetLogin.CONTROLLER_PCGAMEPAD)
      {
         if(this.Input_tf.text.length > 0)
         {
            this.SpinnerHolder_mc.EmptyWarning_tf._visible = false;
            this.SpinnerHolder_mc.Spinner_mc._visible = true;
            this.SpinnerHolder_mc._visible = true;
            this.codeObj.searchForMods(this.Input_tf.text);
         }
      }
      else if(this.Input_tf.text.length > 0 && Selection.getBeginIndex(this.Input_tf) == Selection.getEndIndex(this.Input_tf))
      {
         this.SpinnerHolder_mc.EmptyWarning_tf._visible = false;
         this.SpinnerHolder_mc.Spinner_mc._visible = true;
         this.SpinnerHolder_mc._visible = true;
         this.codeObj.searchForMods(this.Input_tf.text);
      }
      else
      {
         this.codeObj.startEditText();
      }
   }
   function SearchReturned(category)
   {
      if(category == -1)
      {
         Selection.setFocus(this.Input_tf);
         Selection.setSelection(0,this.Input_tf.length);
         this.SpinnerHolder_mc.EmptyWarning_tf._visible = true;
         this.SpinnerHolder_mc.Spinner_mc._visible = false;
      }
      else
      {
         this.ClearSearchField();
      }
   }
   function onVKBTextEntered(astrEnteredText)
   {
      if(astrEnteredText.length > 0 && Selection.getFocus() == targetPath(this.Input_tf))
      {
         this.Input_tf.text = astrEnteredText;
         this.SearchGrayText_tf._visible = false;
         this.SpinnerHolder_mc.EmptyWarning_tf._visible = false;
      }
   }
   function handleInput(details, pathToFocus)
   {
      return true;
   }
   function ClearSearchField()
   {
      this.Input_tf.text = "";
      this.SearchGrayText_tf._visible = true;
      Selection.setFocus(this.Input_tf);
      this.SpinnerHolder_mc.EmptyWarning_tf._visible = false;
      this.SpinnerHolder_mc.Spinner_mc._visible = false;
   }
   function onSearchTextChanged()
   {
      this.SearchGrayText_tf._visible = this.Input_tf.text.length == 0;
   }
}
