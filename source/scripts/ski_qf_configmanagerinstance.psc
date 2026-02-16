scriptName SKI_QF_ConfigManagerInstance extends Quest hidden

;-- Properties --------------------------------------
referencealias property Alias_PlayerRef auto

;-- Variables ---------------------------------------

;-- Functions ---------------------------------------

function Fragment_0()

	Quest __temp = self as Quest
	ski_configmanager kmyQuest = __temp as ski_configmanager
	kmyQuest.ForceReset()
endFunction

; Skipped compiler generated GetState

; Skipped compiler generated GotoState
