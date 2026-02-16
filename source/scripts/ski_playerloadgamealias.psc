scriptName SKI_PlayerLoadGameAlias extends ReferenceAlias

;-- Properties --------------------------------------

;-- Variables ---------------------------------------

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

function OnPlayerLoadGame()

	(self.GetOwningQuest() as ski_questbase).OnGameReload()
endFunction

; Skipped compiler generated GotoState
