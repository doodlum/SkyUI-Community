scriptname SKI_Main extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

int property		ERR_SKSE_MISSING		= 1 autoReadonly
int property		ERR_SKSE_VERSION_RT		= 2 autoReadonly
int property		ERR_SKSE_VERSION_SCPT	= 3 autoReadonly
int property		ERR_INI_PAPYRUS			= 4 autoReadonly
int property		ERR_SKSE_BROKEN			= 7 autoReadonly


; PROPERTIES --------------------------------------------------------------------------------------

int property		MinSKSERelease	= 53		autoReadonly
string property		MinSKSEVersion	= "2.0.4"	autoReadonly

int property		ReqSWFRelease	= 2018		autoReadonly
string property		ReqSWFVersion	= "5.2 SE"	autoReadonly

bool property		ErrorDetected	= false auto


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnGameReload()
	ErrorDetected = false

	if (SKSE.GetVersionRelease() == 0)
		Error(ERR_SKSE_MISSING, "The Skyrim Script Extender (SKSE64) is not running.\nSkyUI will not work correctly!\n\n" \
			+ "This message may also appear if a new Skyrim Patch has been released. In this case, wait until SKSE64 has been updated, then install the new version.")
		return

	elseIf (GetType() == 0)
		Error(ERR_SKSE_BROKEN, "The SKSE64 scripts have been overwritten or are not properly loaded.\nReinstalling SKSE64 might fix this.")
		return

	elseIf (SKSE.GetVersionRelease() < MinSKSERelease)
		Error(ERR_SKSE_VERSION_RT, "SKSE64 is outdated.\nSkyUI will not work correctly!\n" \
			+ "Required version: " + MinSKSEVersion + " or newer\n" \
			+ "Detected version: " + SKSE.GetVersion() + "." + SKSE.GetVersionMinor() + "." + SKSE.GetVersionBeta())
		return

	elseIf (SKSE.GetScriptVersionRelease() < MinSKSERelease)
		Error(ERR_SKSE_VERSION_SCPT, "SKSE64 scripts are outdated.\nYou probably forgot to install/update them with the rest of SKSE64.\nSkyUI will not work correctly!")
		return
	endIf

	if (Utility.GetINIInt("iMinMemoryPageSize:Papyrus") <= 0 || Utility.GetINIInt("iMaxMemoryPageSize:Papyrus") <= 0 || Utility.GetINIInt("iMaxAllocatedMemoryBytes:Papyrus") <= 0)
		Error(ERR_INI_PAPYRUS, "Your Papyrus INI settings are invalid. Please fix this, otherwise SkyUI will stop working at some point.")
		return
	endIf
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

function Error(int a_errId, string a_msg)
	Debug.MessageBox("SKYUI ERROR CODE " + a_errId + "\n\n" + a_msg + "\n\nFor more help, visit the SkyUI SE Nexus or Workshop pages.")
	ErrorDetected = true
endFunction
