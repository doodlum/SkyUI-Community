class QuestNotification extends MovieClip
{
   var AnimatedLetter_mc;
   var LevelMeterBaseInstance;
   var LevelUpMeter;
   var ObjText;
   var ObjectiveLineInstance;
   var ObjectivesA;
   var ObjectivesCount;
   var ShoutAnimatedLetter;
   static var AnimLetter;
   static var Instance;
   static var LevelUpMeterIntervalIndex;
   static var LevelUpMeterKillIntervalIndex;
   static var ShoutLetter;
   static var QuestNotificationIntervalIndex = 0;
   static var AnimationCount = 0;
   var ShowNotifications = true;
   static var QUEST_UPDATE = 0;
   static var SKILL_LEVEL_UPDATE = 1;
   static var PLAYER_LEVEL_UPDATE = 2;
   static var SHOUT_UPDATE = 3;
   static var bPlayerLeveled = false;
   static var PlayerLevel = 0;
   function QuestNotification()
   {
      super();
      QuestNotification.Instance = this;
      this.ObjectivesA = new Array();
      QuestNotification.AnimLetter = this.AnimatedLetter_mc;
      QuestNotification.AnimLetter.AnimationBase_mc = this.AnimatedLetter_mc;
      QuestNotification.ShoutLetter = this.ShoutAnimatedLetter;
      QuestNotification.ShoutLetter.AnimationBase_mc = this.ShoutAnimatedLetter;
      this.ObjText = this.ObjectiveLineInstance;
      this.LevelUpMeter = new Components.UniformTimeMeter(this.LevelMeterBaseInstance.LevelUpMeterInstance,"UILevelUp",this.LevelMeterBaseInstance.LevelUpMeterInstance.FlashInstance,"StartFlash");
      this.LevelUpMeter.FillSpeed = 0.2;
      this.LevelMeterBaseInstance.gotoAndStop("FadeIn");
      QuestNotification.LevelUpMeterIntervalIndex = 0;
      QuestNotification.LevelUpMeterKillIntervalIndex = 0;
   }
   static function Update()
   {
      QuestNotification.Instance.ObjText.UpdateObjectives(QuestNotification.Instance.ObjectivesA);
   }
   function EvaluateNotifications()
   {
      if(QuestNotification.AnimationCount == 0 || QuestNotification.AnimationCount == QuestNotification.AnimLetter.QuestName.length)
      {
         QuestNotification.RestartAnimations();
         clearInterval(QuestNotification.QuestNotificationIntervalIndex);
         QuestNotification.QuestNotificationIntervalIndex = 0;
      }
   }
   static function DecAnimCount()
   {
      QuestNotification.AnimationCount--;
      if(QuestNotification.AnimationCount == 0)
      {
         QuestNotification.Instance.ShowObjectives(QuestNotification.Instance.ObjectivesCount);
      }
   }
   static function CheckContinue()
   {
      QuestNotification.Instance.EvaluateNotifications();
      return true;
   }
   function CanShowNotification()
   {
      return this.ShowNotifications && QuestNotification.AnimationCount == 0;
   }
   function ShowNotification(aNotificationText, aStatus, aSoundID, aObjectiveCount, aNotificationType, aLevel, aStartPercent, aEndPercent, aDragonText)
   {
      this.ShowNotifications = false;
      if(aSoundID.length > 0)
      {
         gfx.io.GameDelegate.call("PlaySound",[aSoundID]);
      }
      this.EvaluateNotifications();
      QuestNotification.QuestNotificationIntervalIndex = setInterval(mx.utils.Delegate.create(this,this.EvaluateNotifications),30);
      if(aNotificationType == QuestNotification.QUEST_UPDATE || aNotificationType == undefined)
      {
         this.LevelMeterBaseInstance.gotoAndStop("FadeIn");
         if(aNotificationText.length == 0)
         {
            this.ShowObjectives(aObjectiveCount);
         }
         else
         {
            QuestNotification.AnimLetter.ShowQuestUpdate(aNotificationText.toUpperCase(),aStatus.toUpperCase());
            this.ObjectivesCount = aObjectiveCount;
         }
      }
      else
      {
         QuestNotification.AnimLetter.ShowQuestUpdate(aNotificationText.toUpperCase());
         if(aDragonText && aNotificationType == QuestNotification.SHOUT_UPDATE)
         {
            QuestNotification.ShoutLetter.EndPosition = 128;
            QuestNotification.ShoutLetter.ShowQuestUpdate(aDragonText.toUpperCase());
         }
         else
         {
            QuestNotification.bPlayerLeveled = aStartPercent < 1 && aEndPercent >= 1;
            this.LevelMeterBaseInstance.gotoAndPlay("FadeIn");
            this.LevelUpMeter.SetPercent(aStartPercent * 100);
            this.LevelUpMeter.SetTargetPercent(aEndPercent * 100);
            this.LevelMeterBaseInstance.LevelTextBaseInstance.levelValue.SetText(!aLevel ? 101 : aLevel);
            QuestNotification.PlayerLevel = aLevel;
            clearInterval(QuestNotification.LevelUpMeterIntervalIndex);
            clearInterval(QuestNotification.LevelUpMeterKillIntervalIndex);
            QuestNotification.LevelUpMeterKillIntervalIndex = setInterval(QuestNotification.KillLevelUpMeter,1000);
         }
      }
   }
   static function UpdateLevelUpMeter()
   {
      QuestNotification.Instance.LevelUpMeter.Update();
   }
   static function KillLevelUpMeter()
   {
      if(QuestNotification.AnimationCount == 0)
      {
         if(QuestNotification.bPlayerLeveled)
         {
            QuestNotification.bPlayerLeveled = false;
            QuestNotification.AnimLetter.ShowQuestUpdate(QuestNotification.Instance.LevelUpTextInstance.text);
            QuestNotification.Instance.LevelMeterBaseInstance.LevelTextBaseInstance.levelValue.SetText(QuestNotification.PlayerLevel + 1);
         }
         else
         {
            clearInterval(QuestNotification.LevelUpMeterIntervalIndex);
            clearInterval(QuestNotification.LevelUpMeterKillIntervalIndex);
            QuestNotification.Instance.LevelMeterBaseInstance.gotoAndPlay("FadeOut");
         }
      }
   }
   function ShowObjectives(aObjectiveCount)
   {
      this.ObjText.ShowObjectives(aObjectiveCount,this.ObjectivesA);
      this.ShowNotifications = true;
   }
   function GetDepth()
   {
      return this.getNextHighestDepth();
   }
   static function RestartAnimations()
   {
      var _loc1_ = QuestNotification.Instance.AnimLetter._parent;
      for(var _loc2_ in _loc1_)
      {
         if(_loc1_[_loc2_] instanceof AnimatedLetter && _loc1_[_loc2_] != QuestNotification.Instance.AnimLetter)
         {
            _loc1_[_loc2_].gotoAndPlay(_loc1_[_loc2_]._currentFrame);
         }
      }
   }
}
