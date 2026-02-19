class skyui.components.dialog.BasicDialog extends MovieClip
{
   var _fadeTween;
   var dispatchEvent;
   var onDialogClosed;
   var onDialogClosing;
   var onDialogOpen;
   var onDialogOpening;
   var removeAllEventListeners;
   static var OPEN = 0;
   static var CLOSED = 1;
   static var OPENING = 2;
   static var CLOSING = 3;
   var _dialogState = -1;
   function BasicDialog()
   {
      super();
      gfx.events.EventDispatcher.initialize(this);
      Mouse.addListener(this);
   }
   function openDialog()
   {
      this.setDialogState(skyui.components.dialog.BasicDialog.OPENING);
      if(this._fadeTween)
      {
         this._fadeTween.stop();
         delete this._fadeTween;
      }
      this._fadeTween = new mx.transitions.Tween(this,"_alpha",mx.transitions.easing.None.easeNone,0,100,0.4,true);
      this._fadeTween.FPS = 40;
      this._fadeTween.onMotionFinished = mx.utils.Delegate.create(this,this.fadedInFunc);
   }
   function closeDialog()
   {
      this.setDialogState(skyui.components.dialog.BasicDialog.CLOSING);
      if(this._fadeTween)
      {
         this._fadeTween.stop();
         delete this._fadeTween;
      }
      this._fadeTween = new mx.transitions.Tween(this,"_alpha",mx.transitions.easing.None.easeNone,100,0,0.4,true);
      this._fadeTween.FPS = 40;
      this._fadeTween.onMotionFinished = mx.utils.Delegate.create(this,this.fadedOutFunc);
   }
   function setDialogState(a_newState)
   {
      if(this._dialogState == a_newState)
      {
         return undefined;
      }
      this._dialogState = a_newState;
      if(a_newState == skyui.components.dialog.BasicDialog.OPENING)
      {
         if(this.onDialogOpening)
         {
            this.onDialogOpening();
         }
         this.dispatchEvent({type:"dialogOpening"});
      }
      else if(a_newState == skyui.components.dialog.BasicDialog.OPEN)
      {
         if(this.onDialogOpen)
         {
            this.onDialogOpen();
         }
         this.dispatchEvent({type:"dialogOpen"});
      }
      else if(a_newState == skyui.components.dialog.BasicDialog.CLOSING)
      {
         if(this.onDialogClosing)
         {
            this.onDialogClosing();
         }
         this.dispatchEvent({type:"dialogClosing"});
      }
      else if(a_newState == skyui.components.dialog.BasicDialog.CLOSED)
      {
         if(this.onDialogClosed)
         {
            this.onDialogClosed();
         }
         this.dispatchEvent({type:"dialogClosed"});
         this.removeAllEventListeners();
         this.removeMovieClip();
      }
   }
   function fadedInFunc()
   {
      this.setDialogState(skyui.components.dialog.BasicDialog.OPEN);
   }
   function fadedOutFunc()
   {
      this.setDialogState(skyui.components.dialog.BasicDialog.CLOSED);
   }
}
