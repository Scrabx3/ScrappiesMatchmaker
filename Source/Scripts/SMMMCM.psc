Scriptname SMMMCM extends SKI_ConfigBase Conditional

SMMPlayer Property PlayerScr Auto
; ----------------------- Variables
String[] classColors
; ---- General
; -- Scan
bool Property bPaused = true Auto Hidden
int Property iTickIntervall = 20 Auto Hidden
int Property iPauseKey = -1 Auto Hidden
; ---- Locations
String[] Property lProfiles Auto
; ---- Profiles
; Use JContainer to handle Profiles.. Most variables will be stored in .jsons
String filePath = "Data\\SKSE\\SMM\\"
String[] smmProfiles
int smmProfileIndex
;
String[] lConsiderList
String[] lConsiderListCrt

; ===============================================================
; =============================	STARTUP // UTILITY
; ===============================================================
int Function GetVersion()
	return 1
EndFunction

Event OnVersionUpdate(int newVers)
	;
EndEvent

Event OnConfigInit()
	Initialize()
EndEvent

Function Initialize()
	Pages = new string[3]
	Pages[0] = "$SMM_General"
	Pages[1] = "$SMM_Locs"
	Pages[2] = "$SMM_Profiles"

	; Colors
	classColors = new String[3]
	classColors[0] = "<font color = '#ffff00'>" ; Player - Yellow
	classColors[1] = "<font color = '#00c707'>" ; Follower - Green
	classColors[2] = "<font color = '#f536ff'>"	; NPC - Magnetta

	lConsiderList = new String[3]
	lConsiderList[0] = "$SMM_considerEither" ; Either
	lConsiderList[1] = "$SMM_considerFriendly" ; Friendly Only
	lConsiderList[2] = "$SMM_considerHostile" ; Hostile Only

	lConsiderListCrt = new String[3]
	lConsiderListCrt[0] = "$SMM_considerEither" ; Either
	lConsiderListCrt[1] = "$SMM_considerHuman" ; Human only
	lConsiderListCrt[2] = "$SMM_considerCreature" ; Creature only

	lProfiles = Utility.CreateStringArray(28, "$SMM_Disabled")
EndFunction

; ===============================================================
; =============================	MENU
; ===============================================================
int jProfile

Event OnPageReset(string Page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If(Page == "")
    Page = "$SMM_Profiles"
	ELseIf(jProfile != 0)
		SaveJson()
  EndIf
  If(Page == "$SMM_General")
		AddToggleOptionST("Enabled", "$SMM_Enabled", !bPaused)
		AddKeyMapOptionST("PauseKey", "$SMM_PauseHotkey", iPauseKey)
		AddSliderOptionST("TickInterval", "$SMM_Interval", iTickIntervall, "{0}s")

	ElseIf(Page == "$SMM_Locs")
		CreateMenuProfiles(1)
		SetCursorFillMode(LEFT_TO_RIGHT)
		AddEmptyOption()
		AddTextOptionST("locProfileHelp", "$SMM_Help", none)
		AddHeaderOption("")
		AddHeaderOption("")
		int i = 0
		While(i < lProfiles.length)
			AddMenuOptionST("locProfile_" + i, "$SMM_locProfile_" + i, lProfiles[i])
			i += 1
		EndWhile

	ElseIf(Page == "$SMM_Profiles")
		CreateMenuProfiles()
		String thisProfile
		If(!smmProfiles || smmProfileIndex >= smmProfiles.Length)
			thisProfile = ""
		else
			thisProfile = smmProfiles[smmProfileIndex]
		EndIf
		jProfile = JValue.retain(JValue.readFromFile(filePath + thisProfile + ".json"), "SMM")
		AddMenuOptionST("smmProfilesLoad", "$SMM_ProfileLoad", thisProfile)
		AddInputOptionST("smmProfilesAdd", "$SMM_ProfileAdd", none)
		SetCursorPosition(1)
		AddTextOptionST("ProfilesHelp", "SMM_Help", none)
		SetCursorPosition(4)
		AddHeaderOption(thisProfile)
		If(thisProfile == "")
			AddTextOption("$SMM_NoProfileError", "", OPTION_FLAG_DISABLED)
			return
		EndIf
		AddMenuOptionST("consider", "$SMM_Consider", lConsiderList[JMap.getInt(jProfile, "lConsider")])
		AddMenuOptionST("considerCrt", "$SMM_ConsiderCrt", lConsiderListCrt[JMap.getInt(jProfile, "lConsiderCreature")])
		AddToggleOptionST("considerPlayer", "$SMM_ConsiderPlayer", JMap.getInt(jProfile, "bConsiderPlayer"))
		AddToggleOptionST("considerFollower", "$SMM_ConsiderFollower", JMap.getInt(jProfile, "bConsiderFollowers"))
		SetCursorPosition(5)
		AddHeaderOption("")
  EndIf
endEvent

Event OnConfigClose()
	If(jProfile != 0)
		SaveJson()
	EndIf
	JValue.releaseObjectsWithTag("SMM")
EndEvent

; ===============================================================
; =============================	SELECTION STATES
; ===============================================================
Event OnSelectST()
	String option = GetState()
	If(option == "considerPlayer")
		int val = JMap.getInt(jProfile, "bConsiderPlayer")
		JMap.setInt(jProfile, "bConsiderPlayer", Math.abs(val - 1) as int)
		SetToggleOptionValueST(JMap.getInt(jProfile, "bConsiderPlayer"))
	ElseIf(option == "considerFollower")
		int val = JMap.getInt(jProfile, "bConsiderFollowers")
		JMap.setInt(jProfile, "bConsiderFollowers", Math.abs(val - 1) as int)
		SetToggleOptionValueST(JMap.getInt(jProfile, "bConsiderFollowers"))
	EndIf
EndEvent

; ===============================================================
; =============================	SLIDER STATES
; ===============================================================
Event OnSliderOpenST()
	String option = GetState()
	If(option == "TickIntervall") ; General
		SetSliderDialogStartValue(iTickIntervall)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(5, 300)
		SetSliderDialogInterval(1)
	EndIf
EndEvent

Event OnSliderAcceptST(Float afValue)
	String option = GetState()
	If(option == "TickIntervall") ; General
		iTickIntervall = afValue as Int
		SetSliderOptionValueST(iTickIntervall)
	EndIf
EndEvent

; ===============================================================
; =============================	MENU STATES
; ===============================================================
Event OnMenuOpenST()
	String[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "consider") ; Profiles
		SetMenuDialogStartIndex(JMap.getInt(jProfile, "lConsider"))
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(lConsiderList)
	ElseIf(option[0] == "considerCrt")
		SetMenuDialogStartIndex(JMap.getInt(jProfile, "lConsiderCreature"))
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(lConsiderListCrt)

	ElseIf(option[0] == "locProfile")
		int i = option[1] as int
		int c = smmProfiles.Find(lProfiles[i])
		SetMenuDialogStartIndex(c)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(smmProfiles)
	EndIf
EndEvent

Event OnMenuAcceptST(Int aiIndex)
	String[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "consider") ; Profiles
		JMap.setInt(jProfile, "lConsider", aiIndex)
		SetMenuOptionValueST(lConsiderList[aiIndex])
	ElseIf(option[0] == "considerCrt")
		JMap.setInt(jProfile, "lConsiderCreature", aiIndex)
		SetMenuOptionValueST(lConsiderListCrt[aiIndex])

	ElseIf(option[0] == "locProfile")
		int i = option[1] as int
		lProfiles[i] = smmProfiles[aiIndex]
		SetMenuOptionValueST(lProfiles[i])
	EndIf
EndEvent

; ===============================================================
; =============================	HIGHLIGHTS
; ===============================================================
Event OnHighlightST()
	String[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "consider") ; Profiles
		SetInfoText("$SMM_ConsiderHighlight")
	ElseIf(option[0] == "considerCrt")
		SetInfoText("$SMM_ConsiderCrtHighlight")
	EndIf
EndEvent

; ===============================================================
; =============================	FULL STATES
; ===============================================================

State Enabled
	Event OnSelectST()
		bPaused = !bPaused
		SetToggleOptionValueST(bPaused)
		PlayerScr.ContinueScan()
	EndEvent
EndState
State PauseKey
	Event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		If(newKeyCode == 1) ; Esc
			PlayerScr.UnregisterForKey(iPauseKey)
			iPauseKey = -1
			SetKeyMapOptionValueST(iPauseKey)
			return
		EndIf
		bool continue = true
		If(conflictControl != "")
			string msg
			If(conflictName != "")
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n\nAre you sure you want to continue?"
			EndIf
			continue = ShowMessage(msg, true, "$Yes", "$No")
		EndIf
			If(continue)
				iPauseKey = newKeyCode
				SetKeyMapOptionValueST(iPauseKey)
				PlayerScr.ResetKey(iPauseKey)
			EndIf
		EndEvent
	Event OnDefaultST()
		iPauseKey = 47
		SetKeyMapOptionValueST(iPauseKey)
		PlayerScr.ResetKey(iPauseKey)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Hotkey to pause or unpause the mod.\nEsc to unset")
	EndEvent
EndState

; ===============================================================
; =============================	PROFILE SYSTEM
; ===============================================================
Function SaveJson()
	JValue.writeToFile(jProfile, filePath + smmProfiles[smmProfileIndex] + ".json")
	jProfile = JValue.release(jProfile)
EndFunction

Function CreateMenuProfiles(int append0 = 0)
	int jFiles = JValue.readFromDirectory(filePath)
	String[] files = JMap.allKeysPArray(jFiles)
	JValue.zeroLifetime(jFiles)
	smmProfiles = Utility.CreateStringArray(files.length + append0)
	If(append0 == 1)
		smmProfiles[0] = "$SMM_Disabled"
	EndIf
	int i = 0
	While(i < files.length)
		smmProfiles[i + append0] = StringUtil.SubString(files[i], 0, StringUtil.GetLength(files[i]) - 5)
		i += 1
	EndWhile
EndFunction

State smmProfilesAdd
	Event OnInputOpenST()
		SetInputDialogStartText("Profile")
	EndEvent
	Event OnInputAcceptST(string a_input)
		String profileName
		int t = StringUtil.GetLength(a_input) - 5
		If(StringUtil.SubString(a_input, t) != ".json")
			profileName = a_input
			a_input += ".json"
		Else
			profileName = StringUtil.Substring(a_input, 0, t)
		EndIf
		If(StringUtil.GetLength(profileName) < 1)
			ShowMessage("$SMM_AddProfileError", false, "$SMM_Ok")
			return
		ElseIf(smmProfiles.Find(profileName) != -1)
			If(!ShowMessage("$SMM_AddProfileDuplica", true, "$SMM_Yes", "$SMM_Cancel"))
				return
			EndIf
		EndIf
		SaveJson()
		int newFile = JValue.readFromFile(filePath + "Definition\\Definition.json")
		JValue.writeToFile(JValue.zeroLifetime(newFile), filePath + a_input)
		CreateMenuProfiles()
		smmProfileIndex = smmProfiles.Find(profileName)
		ForcePageReset()
	EndEvent
EndState

State smmProfilesLoad
	Event OnMenuOpenST()
		SetMenuDialogStartIndex(smmProfileIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(smmProfiles)
	EndEvent
	Event OnMenuAcceptST(Int aiIndex)
		SaveJson()
		smmProfileIndex = aiIndex
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		smmProfileIndex = 1
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SMM_ProfileLoadHighlight")
	EndEvent
EndState

;/ =============================================================
; ===================================== TOGGLE & TEXT
; =============================================================
Event OnSelectST()
	string[] options = PapyrusUtil.StringSplit(GetState(), "_")
	If(options[0] == "Enabled") ; General
		Player.bPaused = !Player.bPaused
		SetToggleOptionValueST(!Player.bPaused)
		If(Player.bPaused)
			Player.UnregisterForUpdate()
		else
			Player.RegisterForSingleUpdate(iTickIntervall)
		EndIf
	ElseIf(options[0] == "AllowHostile")
		bAllowHostile = !bAllowHostile
		SetToggleOptionValueST(bAllowHostile)
	ElseIf(options[0] == "AllowCreatures")
		bAllowCreatures = !bAllowCreatures
		SetToggleOptionValueST(bAllowCreatures)

	ElseIf(options[0] == "LocReadMe") ; Read Mes
		ShowMessage("$SMM_LocReadMe", false, "$SMM_OK")
	EndIf
EndEvent

; =============================================================
; ===================================== SLIDER
; =============================================================
Event OnSliderOpenST()
	string[] options = PapyrusUtil.StringSplit(GetState(), "_")
	If(options[0] == "TickInterval") ; General
		SetSliderDialogStartValue(iTickIntervall)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(5, 300)
		SetSliderDialogInterval(1)
	EndIf

EndEvent

Event OnSliderAcceptST(float value)
	string[] options = PapyrusUtil.StringSplit(GetState(), "_")
	If(options[0] == "TickInterval") ; General
		iTickIntervall = value as int
		SetSliderOptionValueST(iTickIntervall)
	EndIf

EndEvent

; =============================================================
; ===================================== MENU
; =============================================================
Event OnMenuOpenST()
	string[] options = PapyrusUtil.StringSplit(GetState(), "_")
	If(options[0] == "location") ; Location
		int i = options[1] as int
		SetMenuDialogStartIndex(locationTable[i])
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(profiles)
	EndIf
EndEvent

Event OnMenuAcceptST(int index)
	string[] options = PapyrusUtil.StringSplit(GetState(), "_")
	If(options[0] == "location") ; Location
		int i = options[1] as int
		locationTable[i] = index
		SetMenuOptionValueST(profiles[i])
	EndIf
EndEvent

; =============================================================
; ===================================== HIGHLIGHT
; =============================================================
Event OnHighlightST()
	string[] options = PapyrusUtil.StringSplit(GetState(), "_")
	If(options[0] == "Enabled") ; General
		SetInfoText("$SMM_EnabledHighlight")
	ElseIf(options[0] == "TickInterval")
		SetInfoText("$SMM_IntervalHighlight")
	ElseIf(options[0] == "AllowHostile")
		SetInfoText("$SMM_AllowHostileHighlight")
	ElseIf(options[0] == "AllowCreatures")
		SetInfoText("$SMM_AllowCreaturesHighlight")
	EndIf
EndEvent

; =============================================================
; ===================================== STATES
; =============================================================
Event OnPageReset(string Page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If(Page == "")
    Page = "General"
  EndIf
  If(Page == " General")

		AddHeaderOption(" SexLab")
    AddToggleOptionST("TreatVictim", "Treat as Victim", bTreatAsVictim)
    AddSliderOptionST("MaxActor", "Maximum allowed Actors in a Scene", iMaxActor)
    AddSliderOptionST("Twosome", "Twosome Weight", iTwoCh, "{0}")
    AddSliderOptionST("Threesome", "Threesome Weight", iThreeCh, "{0}", CheckFlag3p())
    AddSliderOptionST("Foursome", "Foursome Weight", iFourCh, "{0}", CheckFlag4p())
    AddSliderOptionST("Fivesome", "Fivesome Weight", iFiveCh, "{0}", CheckFlag5p())
		AddToggleOptionST("Notify", "Notification when Engage happens?", bNotify)
		AddToggleOptionST("SupportFilter", "More Filter Options", bSupportFilter)
    AddToggleOptionST("UseBed", "Use bed in friendly Locations?", bUseBed)
    SetCursorPosition(1)
		AddHeaderOption(" Tagging")
		AddTextOptionST("ReadMeTagging", "Read Me", none)
		AddToggleOptionST("UseAggressiveAnim", "Use Aggressive Animations", bUseAggressive)
		AddEmptyOption()
		o2PFemaleMale = AddInputOption("2P: Female/Male", s2PFM)
		o2PMaleFemale = AddInputOption("2P: Male/Female", s2PMF)
		o2PFemaleFemale = AddInputOption("2P: Female/Female", s2PFF)
		o2PMaleMale = AddInputOption("2P: Male/Male", s2PMM)
		o3PFemaleFirst = AddInputOption("3P: Female Victim", s3PF)
		o3PMaleFirst = AddInputOption("3P: Male Victim", s3PM)
		o4PFemaleFirst = AddInputOption("4P: Female Victim", s4PM)
		o4PMaleFirst = AddInputOption("4P: Male Victim", s4PF)
		o5PFemaleFirst = AddInputOption("5P: Female Victim", s5PM)
		o5PMaleFirst = AddInputOption("5P: Male Victim", s5PF)
    AddEmptyOption()
		AddHeaderOption(" Debug")
		AddToggleOptionST("PrintTraces", "Print Traces", bPrintTraces)

  ElseIf(Page == " Profiles" && ProfileViewerList[ProfileViewerIndex] == " Sheep")
    AddMenuOptionST("ProfileView", "Active Profile: ", ProfileViewerList[ProfileViewerIndex])
    SheepProfile()
	ElseIf(Page == " Profiles" &&  ProfileViewerList[ProfileViewerIndex] == " Wolf")
		AddMenuOptionST("ProfileView", "Active Profile: ", ProfileViewerList[ProfileViewerIndex])
		WolfProfile()
	ElseIf(Page == " Profiles" &&  ProfileViewerList[ProfileViewerIndex] == " Bunny")
		AddMenuOptionST("ProfileView", "Active Profile: ", ProfileViewerList[ProfileViewerIndex])
		BunnyProfile()
	ElseIf(Page == " Filter")
		SetCursorFillMode(LEFT_TO_RIGHT)
		AddHeaderOption(" The Player can be engaged by..")
		AddTextOptionST("ReadMeFilter", "", "READ ME")
		oMaleFollowerPlayer = AddToggleOption("Followers: Male", bMalFolAssPl)
		oMaleNPCPlayer = AddToggleOption("NPC: Male", bAssMalPl)
		oFemaleFollowerPlayer = AddToggleOption("Followers: Female", bFemFolAssPl)
		oFemaleNPCPlayer = AddToggleOption("NPC: Female", bAssFemPl)
		oCreatureMaleFollowerPlayer = AddToggleOption("Pets", bCrMFolAssPl)
		oCreatureMaleNPCPlayer = AddToggleOption("Creatures", bAssMalCrPl)
		If(bSupportFilter)
			oFutaFollowerPlayer = AddToggleOption("Followers: Futa", bFutFolAssPl)
			oFutaNPCPlayer = AddToggleOption("NPC: Futa", bAssFutPl)
			oCreatureFemaleFollowerPlayer = AddToggleOption("Pets (Female)", bCrFFolAssPl)
			oCreatureFemaleNPCPlayer = AddToggleOption("Creatures (Female)", bAssFemCrPl)
		EndIf
		AddEmptyOption()
		AddEmptyOption()
		; ----------------------------------------------------------
		AddHeaderOption(" Followers can be engaged by..")
		AddEmptyOption()
		oMaleFollowerFollower = AddToggleOption("Followers: Male", bMalFolAssFol)
		oMaleNPCFollower = AddToggleOption("NPC: Male", bAssMalFol)
		oFemaleFollowerFollower = AddToggleOption("Followers: Female", bFemFolAssFol)
		oFemaleNPCFollower = AddToggleOption("NPC: Female", bAssFemFol)
		oCreatureMaleFollowerFollower = AddToggleOption("Pets", bCrMFolAssFol)
		oCreatureMaleNPCFollower = AddToggleOption("Creatures", bAssMalCrFol)
		If(bSupportFilter)
			oFutaFollowerFollower = AddToggleOption("Followers: Futa", bFutFolAssFol)
			oFutaNPCFollower = AddToggleOption("NPC: Futa", bAssFutFol)
			oCreatureFemaleFollowerFollower = AddToggleOption("Pets (Female)", bCrFFolAssFol)
			oCreatureFemaleNPCFollower = AddToggleOption("Creature (Female)", bAssFemCrFol)
		EndIf
		AddEmptyOption()
		AddEmptyOption()
		; ----------------------------------------------------------
		AddHeaderOption(" Male NPC can be engaged by..")
		AddEmptyOption()
		oMaleFollowerMale = AddToggleOption("Followers: Male", bMalFolAssMal)
		oMaleNPCMale = AddToggleOption("NPC: Male", bAssMalMal)
		oFemaleFollowerMale = AddToggleOption("Followers: Female", bFemFolAssMal)
		oFemaleNPCMale = AddToggleOption("NPC: Female", bAssFemMal)
		oCreatureMaleFollowerMale = AddToggleOption("Pets", bCrMFolAssMal)
		oCreatureMaleNPCMale = AddToggleOption("Creatures", bAssMalCrMal)
		If(bSupportFilter)
			oFutaFollowerMale = AddToggleOption("Followers: Futa", bFutFolAssMal)
			oFutaNPCMale = AddToggleOption("NPC: Futa", bAssFutMal)
			oCreatureFemaleFollowerMale = AddToggleOption("Pets (Female)", bCrFFolAssMal)
			oCreatureFemaleNPCMale = AddToggleOption("Creatures (Female)", bAssFemCrMal)
		EndIf
		AddEmptyOption()
		AddEmptyOption()
		; ----------------------------------------------------------
		AddHeaderOption(" Female NPC can be engaged by..")
		AddEmptyOption()
		oMaleFollowerFemale = AddToggleOption("Followers: Male", bMalFolAssFem)
		oMaleNPCFemale = AddToggleOption("NPC: Male", bAssMalFem)
		oFemaleFollowerFemale = AddToggleOption("Followers: Female", bFemFolAssFem)
		oFemaleNPCFemale = AddToggleOption("NPC: Female", bAssFemFem)
		oCreatureMaleFollowerFemale = AddToggleOption("Pets", bCrMFolAssFem)
		oCreatureMaleNPCFemale = AddToggleOption("Creatures", bAssMalCrFem)
		If(bSupportFilter)
			oFutaFollowerFemale = AddToggleOption("Followers: Futa", bFutFolAssFem)
			oFutaNPCFemale = AddToggleOption("NPC: Futa", bAssFutFem)
			oCreatureFemaleFollowerFemale = AddToggleOption("Pets (Female)", bCrFFolAssFem)
			oCreatureFemaleNPCFemale = AddToggleOption("Creatures (Female)", bAssFemCrFem)
		EndIf
		AddEmptyOption()
		AddEmptyOption()
		; ----------------------------------------------------------
		AddHeaderOption(" Creatures can be engaged by..")
		AddEmptyOption()
		oMaleFollowerCreatureMale = AddToggleOption("Followers: Male", bMalFolAssCrM)
		oMaleNPCCreatureMale = AddToggleOption("NPC: Male", bAssMalCreat)
		oFemaleFollowerCreatureMale = AddToggleOption("Followers: Female", bFemFolAssCrM)
		oFemaleNPCCreatureMale = AddToggleOption("NPC: Female", bAssFemCreat)
		oCreatureMaleFollowerCreatureMale = AddToggleOption("Pets", bCrMFolAssCrM)
		oCreatureMaleNPCCreatureMale = AddToggleOption("Creatures", bAssMalCrCreat)
		If(bSupportFilter)
			oFutaFollowerCreatureMale = AddToggleOption("Followers: Futa", bFutFolAssCrM)
			oFutaNPCCreatureMale = AddToggleOption("NPC: Futa", bAssFutCreat)
			oCreatureFemaleFollowerCreatureMale = AddToggleOption("Pets (Female)", bCrFFolAssCrM)
			oCreatureFemaleNPCCreatureMale = AddToggleOption("Creatures (Female)", bAssFemCrCreat)
		EndIf
		AddEmptyOption()
		AddEmptyOption()
		; ----------------------------------------------------------
		If(bSupportFilter)
			AddHeaderOption(" Futa NPC can be engaged by..")
			AddEmptyOption()
			oMaleFollowerFuta = AddToggleOption("Followers: Male", bMalFolAssFut)
			oMaleNPCFuta = AddToggleOption("NPC: Male", bAssMalFut)
			oFemaleFollowerFuta = AddToggleOption("Followers: Female", bFemFolAssFut)
			oFemaleNPCFuta = AddToggleOption("NPC: Female", bAssFemFut)
			oCreatureMaleFollowerFuta = AddToggleOption("Pets", bCrMFolAssFut)
			oCreatureMaleNPCFuta = AddToggleOption("Creatures", bAssMalCrFut)
			; If(bSupportFilter)
			oFutaFollowerFuta = AddToggleOption("Followers: Futa", bFutFolAssFut)
			oFutaNPCFuta = AddToggleOption("NPC: Futa", bAssFutFut)
			oCreatureFemaleFollowerFuta = AddToggleOption("Pets (Female)", bCrFFolAssFut)
			oCreatureFemaleNPCFuta = AddToggleOption("Creatures (Female)", bAssFemCrFut)
			; EndIf
			AddEmptyOption()
			AddEmptyOption()
			; --------------------------------------------------------
			AddHeaderOption(" Creatures (Female) can be engaged by..")
			AddEmptyOption()
			oMaleFollowerCreatureFemale = AddToggleOption("Followers: Male", bMalFolAssCrF)
			oMaleNPCCreatureFemale = AddToggleOption("NPC: Male", bAssMalFemCreat)
			oFemaleFollowerCreatureFemale = AddToggleOption("Followers: Female", bFemFolAssCrF)
			oFemaleNPCCreatureFemale = AddToggleOption("NPC: Female", bAssFemFemCreat)
			oCreatureMaleFollowerCreatureFemale = AddToggleOption("Pets", bCrMFolAssCrF)
			oCreatureMaleNPCCreatureFemale = AddToggleOption("Creatures", bAssMalCrFemCreat)
			; If(bSupportFilter)
			oFutaFollowerCreatureFemale = AddToggleOption("Followers: Futa", bFutFolAssCrF)
			oFutaNPCCreatureFemale = AddToggleOption("NPC: Futa", bAssFutFemCreat)
 			oCreatureFemaleFollowerCreatureFemale = AddToggleOption("Pets (Female)", bCrFFolAssCrF)
			oCreatureFemaleNPCCreatureFemale = AddToggleOption("Creatures (Female)", bAssFemCrFemCreat)
			; EndIf
		ElseIf(Page == " SexLab")

		EndIf
  endIf
endEvent




int Function getFlag(bool option, bool master = true)
	If(option && master)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
EndFunction







; -------------------------- Properties
RMMPlayer Property Player Auto
GlobalVariable Property RMM_MaxRadius Auto
GlobalVariable Property RMM_AllowHostiles Auto
GlobalVariable Property RMM_AllowCreatures Auto

; -------------------------- Variables
; -- General
int Property iTickIntervall = 30 Auto Hidden
int Property iScanCooldown = 3 Auto Hidden
float Property fMaxRadius = 30.0 Auto Hidden
int Property iRecoveryTime = 20 Auto Hidden
bool Property bAllowHostiles = false Auto Hidden
bool Property bAllowCreatures = false Auto Hidden
; SexLab
bool Property bTreatAsVictim Auto Hidden
int Property iMaxActor = 5 Auto Hidden
int Property iTwoCh = 100 Auto Hidden
int Property iThreeCh = 50 Auto Hidden
int Property iFourCh = 25 Auto Hidden
int Property iFiveCh = 10 Auto Hidden
bool Property bNotify = false Auto Hidden
bool Property bUseBed = false Auto Hidden
; Tagging
bool Property bUseAggressive = false Auto Hidden
string Property s2PFM = "" Auto Hidden
string Property s2PMF = "Femdom" Auto Hidden
string Property s2PFF = "ff" Auto Hidden
string Property s2PMM = "mm" Auto Hidden
string Property s3PM = "" Auto Hidden
string Property s3PF = "" Auto Hidden
string Property s4PM = "" Auto Hidden
string Property s4PF = "" Auto Hidden
string Property s5PM = "" Auto Hidden
string Property s5PF = "" Auto Hidden
; Debug
int Property iPauseKey = -1 Auto Hidden
bool Property bPrintTraces = false Auto Hidden

; -- Locations
string[] Property ProfileList Auto Hidden
; Neutral
int Property iWildIndex = 1 Auto Hidden
; Friendly
int Property iCityIndex = 1 Auto Hidden
int Property iTownIndex = 1 Auto Hidden
int Property iSettlementIndex = 1 Auto Hidden
int Property iPlayerHomeIndex = 1 Auto Hidden
int Property iInnIndex = 1 Auto Hidden
int Property iFriendLocIndex = 1 Auto Hidden
; Hostile
int Property iIfClearedIndex = 1 Auto Hidden
int Property iDragonIndex = 0 Auto Hidden
int Property iFortIndex = 0 Auto Hidden
int Property iBanditIndex = 0 Auto Hidden
int Property iGiantIndex = 0 Auto Hidden
int Property iNoridRuinIndex = 0 Auto Hidden
int Property iDwarvenRuinIndex = 0 Auto Hidden
int Property iFalmerIndex = 0 Auto Hidden
int Property iCavesIndex = 0 Auto Hidden
int Property iHagravenIndex = 0 Auto Hidden
int Property iHostileLocIndex = 0 Auto Hidden

; -- Profiles
string[] Property ProfileViewerList Auto Hidden
int Property ProfileViewerIndex Auto Hidden
string[] EngageOptionList
; -- Wolf
bool Property bCombatSkipSheep = true Auto Hidden
int Property iEngageChanceSheep = 40 Auto Hidden
; Engage
int Property EngageOptionSheep = 1 Auto Hidden
bool Property bHostVicSheep = false Auto Hidden
bool Property bHostOnFriendSheep = false Auto Hidden
; Victim
bool Property bEngagePlSheep = false Auto Hidden
int Property iPrefPlSheep = 33 Auto Hidden
bool Property bEngageFolSheep = true Auto Hidden
bool Property bRestrictGenFolSheep = false Auto Hidden
bool Property bEngageNPCSheep = true Auto Hidden
bool Property bRestrictGenNPCSheep = false Auto Hidden
bool Property bEngageCreatureSheep = false Auto Hidden
bool Property bRestrictGenCrtSheep = false Auto Hidden

bool Property bEngageMaleSheep = true Auto Hidden
bool Property bEngageFemaleSheep = true Auto Hidden
bool Property bEngageFutaSheep = true Auto Hidden
bool Property bEngageCrMSheep = true Auto Hidden
bool Property bEngageCrFSheep = true Auto Hidden
; Engage
bool Property bUseArousalSheep = true Auto Hidden Conditional
int Property iArousalThreshSheep = 40 Auto Hidden

;------fluffy edit -----------
int Property iArousalThreshPlayerSheep = 60 Auto Hidden
;------fluffy end edit -------
bool Property bIgnoreVicArousalSheep = false Auto Hidden
bool Property bUseDistSheep = true Auto Hidden
float Property fMaxDistanceSheep = 12.0 Auto Hidden
bool Property bUseLoSSheep = false Auto Hidden
bool Property bUseDispotionSheep = false Auto Hidden
int Property iMinDispPlSheep = 1 Auto Hidden
int Property iMinDispFolSheep = 1 Auto Hidden
int Property iMinDispNPCSheep = 0 Auto Hidden
; -- Wolf
bool Property bCombatSkipWolf = true Auto Hidden
int Property iEngageChanceWolf = 40 Auto Hidden
; Engage
int Property EngageOptionWolf = 1 Auto Hidden
bool Property bHostVicWolf = false Auto Hidden
bool Property bHostOnFriendWolf = false Auto Hidden
; Victim
bool Property bEngagePlWolf = false Auto Hidden
int Property iPrefPlWolf = 33 Auto Hidden
bool Property bEngageFolWolf = true Auto Hidden
bool Property bRestrictGenFolWolf = false Auto Hidden
bool Property bEngageNPCWolf = true Auto Hidden
bool Property bRestrictGenNPCWolf = false Auto Hidden
bool Property bEngageCreatureWolf = false Auto Hidden
bool Property bRestrictGenCrtWolf = false Auto Hidden

bool Property bEngageMaleWolf = true Auto Hidden
bool Property bEngageFemaleWolf = true Auto Hidden
bool Property bEngageFutaWolf = true Auto Hidden
bool Property bEngageCrMWolf = true Auto Hidden
bool Property bEngageCrFWolf = true Auto Hidden
; Engage
bool Property bUseArousalWolf = true Auto Hidden Conditional
int Property iArousalThreshWolf = 40 Auto Hidden
bool Property bIgnoreVicArousalWolf = false Auto Hidden
bool Property bUseDistWolf = true Auto Hidden
float Property fMaxDistanceWolf = 12.0 Auto Hidden
bool Property bUseLoSWolf = false Auto Hidden
bool Property bUseDispotionWolf = false Auto Hidden
int Property iMinDispPlWolf = 1 Auto Hidden
int Property iMinDispFolWolf = 1 Auto Hidden
int Property iMinDispNPCWolf = 0 Auto Hidden
; -- Bunny
bool Property bCombatSkipBunny = true Auto Hidden
int Property iEngageChanceBunny = 40 Auto Hidden
; Engage
int Property EngageOptionBunny = 1 Auto Hidden
bool Property bHostVicBunny = false Auto Hidden
bool Property bHostOnFriendBunny = false Auto Hidden
; Victim
bool Property bEngagePlBunny = false Auto Hidden
int Property iPrefPlBunny = 33 Auto Hidden
bool Property bEngageFolBunny = true Auto Hidden
bool Property bRestrictGenFolBunny = false Auto Hidden
bool Property bEngageNPCBunny = true Auto Hidden
bool Property bRestrictGenNPCBunny = false Auto Hidden
bool Property bEngageCreatureBunny = false Auto Hidden
bool Property bRestrictGenCrtBunny = false Auto Hidden

bool Property bEngageMaleBunny = true Auto Hidden
bool Property bEngageFemaleBunny = true Auto Hidden
bool Property bEngageFutaBunny = true Auto Hidden
bool Property bEngageCrMBunny = true Auto Hidden
bool Property bEngageCrFBunny = true Auto Hidden
; Engage
bool Property bUseArousalBunny = true Auto Hidden Conditional
int Property iArousalThreshBunny = 40 Auto Hidden
bool Property bIgnoreVicArousalBunny = false Auto Hidden
bool Property bUseDistBunny = true Auto Hidden
float Property fMaxDistanceBunny = 12.0 Auto Hidden
bool Property bUseLoSBunny = false Auto Hidden
bool Property bUseDispotionBunny = false Auto Hidden
int Property iMinDispPlBunny = 1 Auto Hidden
int Property iMinDispFolBunny = 1 Auto Hidden
int Property iMinDispNPCBunny = 0 Auto Hidden


; -- Filter
bool Property bSupportFilter = false Auto Hidden
; Follower
bool Property bMalFolAssPl = false Auto Hidden ; Male Follower
bool Property bMalFolAssFol = false Auto Hidden
bool Property bMalFolAssMal = true Auto Hidden
bool Property bMalFolAssFem = true Auto Hidden
bool Property bMalFolAssFut = false Auto Hidden
bool Property bMalFolAssCrM = false Auto Hidden
bool Property bMalFolAssCrF = false Auto Hidden
bool Property bFemFolAssPl = false Auto Hidden ; Female Follower
bool Property bFemFolAssFol = false Auto Hidden
bool Property bFemFolAssMal = true Auto Hidden
bool Property bFemFolAssFem = true Auto Hidden
bool Property bFemFolAssFut = false Auto Hidden
bool Property bFemFolAssCrM = false Auto Hidden
bool Property bFemFolAssCrF = false Auto Hidden
bool Property bFutFolAssPl = false Auto Hidden ; Futa Follower
bool Property bCrMFolAssFol = false Auto Hidden
bool Property bFutFolAssMal = true Auto Hidden
bool Property bFutFolAssFem = true Auto Hidden
bool Property bFutFolAssFut = false Auto Hidden
bool Property bFutFolAssCrM = false Auto Hidden
bool Property bFutFolAssCrF = false Auto Hidden
bool Property bCrMFolAssPl = false Auto Hidden ; Male Creature Follower
bool Property bCrFFolAssFol = false Auto Hidden
bool Property bCrMFolAssMal = true Auto Hidden
bool Property bCrMFolAssFem = true Auto Hidden
bool Property bCrMFolAssFut = false Auto Hidden
bool Property bCrMFolAssCrM = false Auto Hidden
bool Property bCrMFolAssCrF = false Auto Hidden
bool Property bCrFFolAssPl = false Auto Hidden ; Female Creature Follower
bool Property bFutFolAssFol = false Auto Hidden
bool Property bCrFFolAssMal = true Auto Hidden
bool Property bCrFFolAssFem = true Auto Hidden
bool Property bCrFFolAssFut = false Auto Hidden
bool Property bCrFFolAssCrM = false Auto Hidden
bool Property bCrFFolAssCrF = false Auto Hidden
; NPCs & Creatures
bool Property bAssMalPl = true Auto Hidden ; Male NPC
bool Property bAssMalFol = true Auto Hidden
bool Property bAssMalMal = true Auto Hidden
bool Property bAssMalFem = true Auto Hidden
bool Property bAssMalFut = false Auto Hidden
bool Property bAssMalCreat = false Auto Hidden
bool Property bAssMalFemCreat = false Auto Hidden
bool Property bAssFemPl = true Auto Hidden ; Female NPC
bool Property bAssFemFol = true Auto Hidden
bool Property bAssFemMal = true Auto Hidden
bool Property bAssFemFem = true Auto Hidden
bool Property bAssFemFut = false Auto Hidden
bool Property bAssFemCreat = false Auto Hidden
bool Property bAssFemFemCreat = false Auto Hidden
bool Property bAssFutPl = false Auto Hidden; Futa NPC
bool Property bAssFutFol = true Auto Hidden
bool Property bAssFutMal = true Auto Hidden
bool Property bAssFutFem = true Auto Hidden
bool Property bAssFutFut = false Auto Hidden
bool Property bAssFutCreat = false Auto Hidden
bool Property bAssFutFemCreat = false Auto Hidden
bool Property bAssMalCrPl = true Auto Hidden ; Male Creature
bool Property bAssMalCrFol = true Auto Hidden
bool Property bAssMalCrMal = true Auto Hidden
bool Property bAssMalCrFem = true Auto Hidden
bool Property bAssMalCrFut = false Auto Hidden
bool Property bAssMalCrCreat = false Auto Hidden
bool Property bAssMalCrFemCreat = false Auto Hidden
bool Property bAssFemCrPl = false Auto Hidden ; Female Creature
bool Property bAssFemCrFol = true Auto Hidden
bool Property bAssFemCrMal = true Auto Hidden
bool Property bAssFemCrFem = true Auto Hidden
bool Property bAssFemCrFut = false Auto Hidden
bool Property bAssFemCrCreat = false Auto Hidden
bool Property bAssFemCrFemCreat = false Auto Hidden


;/ Follower
bool Property bFolEngage = true Auto Hidden
bool Property bRespFolGenAggr = false Auto Hidden
; Male
bool Property bEngMalPl = false Auto Hidden
bool Property bEngMalFol = true Auto Hidden
int Property iEngMalFol = 6 Auto Hidden
bool Property bEngMalMal = true Auto Hidden
bool Property bEngMalFem = true Auto Hidden
bool Property bEngMalFut = false Auto Hidden
bool Property bEngMalCrea = false Auto Hidden
; Female
bool Property bEngFemPl = false Auto Hidden
bool Property bEngFemFol = true Auto Hidden
int Property iEngFemFol = 6 Auto Hidden
bool Property bEngFemMal = true Auto Hidden
bool Property bEngFemFem = true Auto Hidden
bool Property bEngFemFut = false Auto Hidden
bool Property bEngFemCrea = false Auto Hidden
; Futa
bool Property bEngFutPl = false Auto Hidden
bool Property bEngFutFol = true Auto Hidden
int Property iEngFutFol = 6 Auto Hidden
bool Property bEngFutMal = true Auto Hidden
bool Property bEngFutFem = true Auto Hidden
bool Property bEngFutFut = false Auto Hidden
bool Property bEngFutCrea = false Auto Hidden
; Creature
bool Property bEngCreaPl = false Auto Hidden
bool Property bEngCreaFol = true Auto Hidden
int Property iEngCreaFol = 6 Auto Hidden
bool Property bEngCreaMal = true Auto Hidden
bool Property bEngCreaFem = true Auto Hidden
bool Property bEngCreaFut = false Auto Hidden
bool Property bEngCreaCrea = false Auto Hidden

; -------------------------- OIDS
; ----- Animations
int o2PFemaleMale
int o2PMaleFemale
int o2PFemaleFemale
int o2PMaleMale
int o3PFemaleFirst
int o3PMaleFirst
int o4PFemaleFirst
int o4PMaleFirst
int o5PFemaleFirst
int o5PMaleFirst

; ----- Location
int oLocWild
int oLocCities
int oLocTowns
int oLocSettlement
int oLocPlayerHome
int oLocInn
int oLocFriendlyLoc
int oLocDragonLair
int oLocNordicRuin
int oLocDwarvenRuin
int oLocCaves
int oLocFalmerHive
int oLocFort
int oLocBanditCamp
int oLocGiantCamp
int oLocHagNest
int oLocHostileLoc

; ----- Profiles
; --- Sheep
; Victim
int allowPlSheep
int allowFolSheep
int allowNPCSheep
int allowCrtSheep
int allowMalSheep
int allowFemSheep
int allowFutSheep
int allowCrMSheep
int allowCrFSheep
; Engage
int ArousalSheep
int DistanceSheep
int LOSSheep

; --- Wolf
; Victim
int allowPlWolf
int allowFolWolf
int allowNPCWolf
int allowCrtWolf
int allowMalWolf
int allowFemWolf
int allowFutWolf
int allowCrMWolf
int allowCrFWolf
; Engage
int ArousalWolf
int DistanceWolf
int LOSWolf

; --- Bunny
; Victim
int allowPlBunny
int allowFolBunny
int allowNPCBunny
int allowCrtBunny
int allowMalBunny
int allowFemBunny
int allowFutBunny
int allowCrMBunny
int allowCrFBunny
; Engage
int ArousalBunny
int DistanceBunny
int LOSBunny

; ----- Filter
; Syntax: o + Aggressor + Victim
; Male Follower
int oMaleFollowerPlayer
int oMaleFollowerFollower
int oMaleFollowerMale
int oMaleFollowerFemale
int oMaleFollowerFuta
int oMaleFollowerCreatureMale
int oMaleFollowerCreatureFemale

; Female Follower
int oFemaleFollowerPlayer
int oFemaleFollowerFollower
int oFemaleFollowerMale
int oFemaleFollowerFemale
int oFemaleFollowerFuta
int oFemaleFollowerCreatureMale
int oFemaleFollowerCreatureFemale

; Futa Followers
int oFutaFollowerPlayer
int oFutaFollowerFollower
int oFutaFollowerMale
int oFutaFollowerFemale
int oFutaFollowerFuta
int oFutaFollowerCreatureMale
int oFutaFollowerCreatureFemale

; Pets
int oCreatureMaleFollowerPlayer
int oCreatureMaleFollowerFollower
int oCreatureMaleFollowerMale
int oCreatureMaleFollowerFemale
int oCreatureMaleFollowerFuta
int oCreatureMaleFollowerCreatureMale
int oCreatureMaleFollowerCreatureFemale

; Pets (Female)
int oCreatureFemaleFollowerPlayer
int oCreatureFemaleFollowerFollower
int oCreatureFemaleFollowerMale
int oCreatureFemaleFollowerFemale
int oCreatureFemaleFollowerFuta
int oCreatureFemaleFollowerCreatureMale
int oCreatureFemaleFollowerCreatureFemale

; Male NPCs
int oMaleNPCPlayer
int oMaleNPCFollower
int oMaleNPCMale
int oMaleNPCFemale
int oMaleNPCFuta
int oMaleNPCCreatureMale
int oMaleNPCCreatureFemale

; Female NPCs
int oFemaleNPCPlayer
int oFemaleNPCFollower
int oFemaleNPCMale
int oFemaleNPCFemale
int oFemaleNPCFuta
int oFemaleNPCCreatureMale
int oFemaleNPCCreatureFemale

; Futa NPCs
int oFutaNPCPlayer
int oFutaNPCFollower
int oFutaNPCMale
int oFutaNPCFemale
int oFutaNPCFuta
int oFutaNPCCreatureMale
int oFutaNPCCreatureFemale

; (Male) Creatures
int oCreatureMaleNPCPlayer
int oCreatureMaleNPCFollower
int oCreatureMaleNPCMale
int oCreatureMaleNPCFemale
int oCreatureMaleNPCFuta
int oCreatureMaleNPCCreatureMale
int oCreatureMaleNPCCreatureFemale

; Female Creature
int oCreatureFemaleNPCPlayer
int oCreatureFemaleNPCFollower
int oCreatureFemaleNPCMale
int oCreatureFemaleNPCFemale
int oCreatureFemaleNPCFuta
int oCreatureFemaleNPCCreatureMale
int oCreatureFemaleNPCCreatureFemale

; -------------------------- Code
int Function GetVersion()
	return 1
endFunction


Function Initialize()
	Pages = new string[4]
	Pages[0] = " General"
	Pages[1] = " Locations"
	Pages[2] = " Profiles"
	Pages[3] = " Filter"

	ProfileViewerList = new string[3]
	ProfileViewerList[0] = " Sheep"
	ProfileViewerList[1] = " Wolf"
	ProfileViewerList[2] = " Bunny"

	ProfileList = new string[4]
	ProfileList[0] = " Disabled"
	ProfileList[1] = " Sheep"
	ProfileList[2] = " Wolf"
	ProfileList[3] = " Bunny"
endFunction

; ==================================
; 							MENU
; ==================================
Event OnConfigInit()
	Initialize()
endEvent

Event OnVersionUpdate(int newVers)
	Initialize()
endEvent

Event OnPageReset(string Page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If(Page == "")
    Page = "General"
  EndIf
  If(Page == " General")
    AddHeaderOption(" Scan")
    AddToggleOptionST("ModActive", "Mod active", !Player.modPaused)
    AddSliderOptionST("ScanInterv", "Scan Interval", iTickIntervall, "{0}s")
    AddSliderOptionST("ScanCd", "Scan Cooldown", iScanCooldown, "{0}h")
    AddSliderOptionST("ScanRadius", "Scan Radius", fMaxRadius, "{0}m")
    AddEmptyOption()
    AddToggleOptionST("AllowHostile", "Allow Hostile NPCs/Creatures", bAllowHostiles)
    AddToggleOptionST("AllowCreatures", "Allow Creatures", bAllowCreatures)
		AddHeaderOption(" SexLab")
    AddToggleOptionST("TreatVictim", "Treat as Victim", bTreatAsVictim)
    AddSliderOptionST("MaxActor", "Maximum allowed Actors in a Scene", iMaxActor)
    AddSliderOptionST("Twosome", "Twosome Weight", iTwoCh, "{0}")
    AddSliderOptionST("Threesome", "Threesome Weight", iThreeCh, "{0}", CheckFlag3p())
    AddSliderOptionST("Foursome", "Foursome Weight", iFourCh, "{0}", CheckFlag4p())
    AddSliderOptionST("Fivesome", "Fivesome Weight", iFiveCh, "{0}", CheckFlag5p())
		AddToggleOptionST("Notify", "Notification when Engage happens?", bNotify)
		AddToggleOptionST("SupportFilter", "More Filter Options", bSupportFilter)
    AddToggleOptionST("UseBed", "Use bed in friendly Locations?", bUseBed)
    SetCursorPosition(1)
		AddHeaderOption(" Tagging")
		AddTextOptionST("ReadMeTagging", "Read Me", none)
		AddToggleOptionST("UseAggressiveAnim", "Use Aggressive Animations", bUseAggressive)
		AddEmptyOption()
		o2PFemaleMale = AddInputOption("2P: Female/Male", s2PFM)
		o2PMaleFemale = AddInputOption("2P: Male/Female", s2PMF)
		o2PFemaleFemale = AddInputOption("2P: Female/Female", s2PFF)
		o2PMaleMale = AddInputOption("2P: Male/Male", s2PMM)
		o3PFemaleFirst = AddInputOption("3P: Female Victim", s3PF)
		o3PMaleFirst = AddInputOption("3P: Male Victim", s3PM)
		o4PFemaleFirst = AddInputOption("4P: Female Victim", s4PM)
		o4PMaleFirst = AddInputOption("4P: Male Victim", s4PF)
		o5PFemaleFirst = AddInputOption("5P: Female Victim", s5PM)
		o5PMaleFirst = AddInputOption("5P: Male Victim", s5PF)
    AddEmptyOption()
		AddHeaderOption(" Debug")
		AddKeyMapOptionST("PauseKey", "Pause/Unpause Hotkey", iPauseKey)
		AddToggleOptionST("PrintTraces", "Print Traces", bPrintTraces)
  ElseIf(Page == " Locations")
    AddTextOptionST("LocReadMe", "Read me", none)
    AddHeaderOption("Neutral Locations")
    oLocWild = AddMenuOption("Wilderness", ProfileList[iWildIndex])
    AddHeaderOption("Friendly Locations")
    oLocCities = AddMenuOption("Cities", ProfileList[iCityIndex])
    oLocTowns = AddMenuOption("Towns", ProfileList[iTownIndex])
    oLocSettlement = AddMenuOption("Settlement", ProfileList[iSettlementIndex])
    oLocPlayerHome = AddMenuOption("Player Home", ProfileList[iPlayerHomeIndex])
    oLocInn = AddMenuOption("Inns", ProfileList[iInnIndex])
    oLocFriendlyLoc = AddMenuOption("Other Friendly Locations", ProfileList[iFriendLocIndex])
    SetCursorPosition(1)
    AddHeaderOption("Hostile Locations")
    AddMenuOptionST("Cleared", "Cleared Locations*", ProfileList[iIfClearedIndex])
    oLocDragonLair = AddMenuOption("Dragon Lair", ProfileList[iDragonIndex])
    oLocNordicRuin = AddMenuOption("Nordic Ruins", ProfileList[iNoridRuinIndex])
    oLocDwarvenRuin = AddMenuOption("Dwarven Ruins", ProfileList[iDwarvenRuinIndex])
    oLocCaves = AddMenuOption("Caves", ProfileList[iCavesIndex])
    oLocFalmerHive = AddMenuOption("Falmer Hives", ProfileList[iFalmerIndex])
    oLocFort = AddMenuOption("Forts", ProfileList[iFortIndex])
    oLocBanditCamp = AddMenuOption("Bandit Camps", ProfileList[iBanditIndex])
    oLocGiantCamp = AddMenuOption("Giant Camps", ProfileList[iGiantIndex])
    oLocHagNest = AddMenuOption("Hagraven Nests", ProfileList[iHagravenIndex])
    oLocHostileLoc = AddMenuOption("Other Hostile Locations", ProfileList[iHostileLocIndex])
  ElseIf(Page == " Profiles" && ProfileViewerList[ProfileViewerIndex] == " Sheep")
    AddMenuOptionST("ProfileView", "Active Profile: ", ProfileViewerList[ProfileViewerIndex])
    SheepProfile()
	ElseIf(Page == " Profiles" &&  ProfileViewerList[ProfileViewerIndex] == " Wolf")
		AddMenuOptionST("ProfileView", "Active Profile: ", ProfileViewerList[ProfileViewerIndex])
		WolfProfile()
	ElseIf(Page == " Profiles" &&  ProfileViewerList[ProfileViewerIndex] == " Bunny")
		AddMenuOptionST("ProfileView", "Active Profile: ", ProfileViewerList[ProfileViewerIndex])
		BunnyProfile()
	ElseIf(Page == " Filter")
		SetCursorFillMode(LEFT_TO_RIGHT)
		AddHeaderOption(" The Player can be engaged by..")
		AddTextOptionST("ReadMeFilter", "", "READ ME")
		oMaleFollowerPlayer = AddToggleOption("Followers: Male", bMalFolAssPl)
		oMaleNPCPlayer = AddToggleOption("NPC: Male", bAssMalPl)
		oFemaleFollowerPlayer = AddToggleOption("Followers: Female", bFemFolAssPl)
		oFemaleNPCPlayer = AddToggleOption("NPC: Female", bAssFemPl)
		oCreatureMaleFollowerPlayer = AddToggleOption("Pets", bCrMFolAssPl)
		oCreatureMaleNPCPlayer = AddToggleOption("Creatures", bAssMalCrPl)
		If(bSupportFilter)
			oFutaFollowerPlayer = AddToggleOption("Followers: Futa", bFutFolAssPl)
			oFutaNPCPlayer = AddToggleOption("NPC: Futa", bAssFutPl)
			oCreatureFemaleFollowerPlayer = AddToggleOption("Pets (Female)", bCrFFolAssPl)
			oCreatureFemaleNPCPlayer = AddToggleOption("Creatures (Female)", bAssFemCrPl)
		EndIf
		AddEmptyOption()
		AddEmptyOption()
		; ----------------------------------------------------------
		AddHeaderOption(" Followers can be engaged by..")
		AddEmptyOption()
		oMaleFollowerFollower = AddToggleOption("Followers: Male", bMalFolAssFol)
		oMaleNPCFollower = AddToggleOption("NPC: Male", bAssMalFol)
		oFemaleFollowerFollower = AddToggleOption("Followers: Female", bFemFolAssFol)
		oFemaleNPCFollower = AddToggleOption("NPC: Female", bAssFemFol)
		oCreatureMaleFollowerFollower = AddToggleOption("Pets", bCrMFolAssFol)
		oCreatureMaleNPCFollower = AddToggleOption("Creatures", bAssMalCrFol)
		If(bSupportFilter)
			oFutaFollowerFollower = AddToggleOption("Followers: Futa", bFutFolAssFol)
			oFutaNPCFollower = AddToggleOption("NPC: Futa", bAssFutFol)
			oCreatureFemaleFollowerFollower = AddToggleOption("Pets (Female)", bCrFFolAssFol)
			oCreatureFemaleNPCFollower = AddToggleOption("Creature (Female)", bAssFemCrFol)
		EndIf
		AddEmptyOption()
		AddEmptyOption()
		; ----------------------------------------------------------
		AddHeaderOption(" Male NPC can be engaged by..")
		AddEmptyOption()
		oMaleFollowerMale = AddToggleOption("Followers: Male", bMalFolAssMal)
		oMaleNPCMale = AddToggleOption("NPC: Male", bAssMalMal)
		oFemaleFollowerMale = AddToggleOption("Followers: Female", bFemFolAssMal)
		oFemaleNPCMale = AddToggleOption("NPC: Female", bAssFemMal)
		oCreatureMaleFollowerMale = AddToggleOption("Pets", bCrMFolAssMal)
		oCreatureMaleNPCMale = AddToggleOption("Creatures", bAssMalCrMal)
		If(bSupportFilter)
			oFutaFollowerMale = AddToggleOption("Followers: Futa", bFutFolAssMal)
			oFutaNPCMale = AddToggleOption("NPC: Futa", bAssFutMal)
			oCreatureFemaleFollowerMale = AddToggleOption("Pets (Female)", bCrFFolAssMal)
			oCreatureFemaleNPCMale = AddToggleOption("Creatures (Female)", bAssFemCrMal)
		EndIf
		AddEmptyOption()
		AddEmptyOption()
		; ----------------------------------------------------------
		AddHeaderOption(" Female NPC can be engaged by..")
		AddEmptyOption()
		oMaleFollowerFemale = AddToggleOption("Followers: Male", bMalFolAssFem)
		oMaleNPCFemale = AddToggleOption("NPC: Male", bAssMalFem)
		oFemaleFollowerFemale = AddToggleOption("Followers: Female", bFemFolAssFem)
		oFemaleNPCFemale = AddToggleOption("NPC: Female", bAssFemFem)
		oCreatureMaleFollowerFemale = AddToggleOption("Pets", bCrMFolAssFem)
		oCreatureMaleNPCFemale = AddToggleOption("Creatures", bAssMalCrFem)
		If(bSupportFilter)
			oFutaFollowerFemale = AddToggleOption("Followers: Futa", bFutFolAssFem)
			oFutaNPCFemale = AddToggleOption("NPC: Futa", bAssFutFem)
			oCreatureFemaleFollowerFemale = AddToggleOption("Pets (Female)", bCrFFolAssFem)
			oCreatureFemaleNPCFemale = AddToggleOption("Creatures (Female)", bAssFemCrFem)
		EndIf
		AddEmptyOption()
		AddEmptyOption()
		; ----------------------------------------------------------
		AddHeaderOption(" Creatures can be engaged by..")
		AddEmptyOption()
		oMaleFollowerCreatureMale = AddToggleOption("Followers: Male", bMalFolAssCrM)
		oMaleNPCCreatureMale = AddToggleOption("NPC: Male", bAssMalCreat)
		oFemaleFollowerCreatureMale = AddToggleOption("Followers: Female", bFemFolAssCrM)
		oFemaleNPCCreatureMale = AddToggleOption("NPC: Female", bAssFemCreat)
		oCreatureMaleFollowerCreatureMale = AddToggleOption("Pets", bCrMFolAssCrM)
		oCreatureMaleNPCCreatureMale = AddToggleOption("Creatures", bAssMalCrCreat)
		If(bSupportFilter)
			oFutaFollowerCreatureMale = AddToggleOption("Followers: Futa", bFutFolAssCrM)
			oFutaNPCCreatureMale = AddToggleOption("NPC: Futa", bAssFutCreat)
			oCreatureFemaleFollowerCreatureMale = AddToggleOption("Pets (Female)", bCrFFolAssCrM)
			oCreatureFemaleNPCCreatureMale = AddToggleOption("Creatures (Female)", bAssFemCrCreat)
		EndIf
		AddEmptyOption()
		AddEmptyOption()
		; ----------------------------------------------------------
		If(bSupportFilter)
			AddHeaderOption(" Futa NPC can be engaged by..")
			AddEmptyOption()
			oMaleFollowerFuta = AddToggleOption("Followers: Male", bMalFolAssFut)
			oMaleNPCFuta = AddToggleOption("NPC: Male", bAssMalFut)
			oFemaleFollowerFuta = AddToggleOption("Followers: Female", bFemFolAssFut)
			oFemaleNPCFuta = AddToggleOption("NPC: Female", bAssFemFut)
			oCreatureMaleFollowerFuta = AddToggleOption("Pets", bCrMFolAssFut)
			oCreatureMaleNPCFuta = AddToggleOption("Creatures", bAssMalCrFut)
			; If(bSupportFilter)
			oFutaFollowerFuta = AddToggleOption("Followers: Futa", bFutFolAssFut)
			oFutaNPCFuta = AddToggleOption("NPC: Futa", bAssFutFut)
			oCreatureFemaleFollowerFuta = AddToggleOption("Pets (Female)", bCrFFolAssFut)
			oCreatureFemaleNPCFuta = AddToggleOption("Creatures (Female)", bAssFemCrFut)
			; EndIf
			AddEmptyOption()
			AddEmptyOption()
			; --------------------------------------------------------
			AddHeaderOption(" Creatures (Female) can be engaged by..")
			AddEmptyOption()
			oMaleFollowerCreatureFemale = AddToggleOption("Followers: Male", bMalFolAssCrF)
			oMaleNPCCreatureFemale = AddToggleOption("NPC: Male", bAssMalFemCreat)
			oFemaleFollowerCreatureFemale = AddToggleOption("Followers: Female", bFemFolAssCrF)
			oFemaleNPCCreatureFemale = AddToggleOption("NPC: Female", bAssFemFemCreat)
			oCreatureMaleFollowerCreatureFemale = AddToggleOption("Pets", bCrMFolAssCrF)
			oCreatureMaleNPCCreatureFemale = AddToggleOption("Creatures", bAssMalCrFemCreat)
			; If(bSupportFilter)
			oFutaFollowerCreatureFemale = AddToggleOption("Followers: Futa", bFutFolAssCrF)
			oFutaNPCCreatureFemale = AddToggleOption("NPC: Futa", bAssFutFemCreat)
 			oCreatureFemaleFollowerCreatureFemale = AddToggleOption("Pets (Female)", bCrFFolAssCrF)
			oCreatureFemaleNPCCreatureFemale = AddToggleOption("Creatures (Female)", bAssFemCrFemCreat)
			; EndIf
		ElseIf(Page == " SexLab")

		EndIf
  endIf
endEvent

Event OnConfigClose()
  RMM_MaxRadius.Value = fMaxRadius*70
  If(bAllowHostiles)
    RMM_AllowHostiles.Value = 1
  else
    RMM_AllowHostiles.Value = 0
  EndIf
  If(bAllowCreatures)
    RMM_AllowCreatures.Value = 1
  else
    RMM_AllowCreatures.Value = 0
  EndIf
EndEvent

; ==================================
; 			 	States // General
; ==================================

State ScanCd
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iScanCooldown)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(0, 60)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iScanCooldown = value as int
    SetSliderOptionValueST(iScanCooldown)
  EndEvent
  Event OnHighlightST()
    SetInfoText("After a successfull engagenement, no engagenement will happen until this Cooldown is finished. This is in in-Game hours.")
  EndEvent
endState

State ScanRadius
  Event OnSliderOpenST()
    SetSliderDialogStartValue(fMaxRadius)
    SetSliderDialogDefaultValue(30)
    SetSliderDialogRange(5, 100)
    SetSliderDialogInterval(5)
  EndEvent
  Event OnSliderAcceptST(float value)
    fMaxRadius = value as int
    SetSliderOptionValueST(fMaxRadius)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The maxium distance away from the Player in which NPCs can still be detected. This is primarily useful to ensure that Scenes dont start far away from the Player/Outside their LoS.\nDo not confuse this with \"Use Radius\" in Profiles! This Setting defines how far an Actor can be away from the Player to start a Scene, while \"Use Radius\" defines how far away an \"engaging Actor\" can be away from an \"engaged one\".")
  EndEvent
EndState

; SexLab
State TreatVictim
	Event OnSelectST()
		bTreatAsVictim = !bTreatAsVictim
		SetToggleOptionValueST(bTreatAsVictim)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Whether or not an engaged Actor should be considerd a Victim by SL")
	EndEvent
EndState

State MaxActor
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iMaxActor)
    SetSliderDialogDefaultValue(5)
    SetSliderDialogRange(2, 5)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iMaxActor = value as int
    SetSliderOptionValueST(iMaxActor)
    If(iMaxActor == 2)
      SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "Threesome")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "Foursome")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "Fivesome")
    ElseIf(iMaxActor == 3)
      SetOptionFlagsST(OPTION_FLAG_NONE, true, "Threesome")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "Foursome")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "Fivesome")
    ElseIf(iMaxActor == 4)
      SetOptionFlagsST(OPTION_FLAG_NONE, true, "Threesome")
      SetOptionFlagsST(OPTION_FLAG_NONE, true, "Foursome")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "Fivesome")
    ElseIf(iMaxActor == 5)
      SetOptionFlagsST(OPTION_FLAG_NONE, true, "Threesome")
      SetOptionFlagsST(OPTION_FLAG_NONE, true, "Foursome")
      SetOptionFlagsST(OPTION_FLAG_NONE, true, "Fivesome")
    EndIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("Maximum amount of Actors that can participate in a Scene.")
  EndEvent
EndState

State Twosome
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iTwoCh)
    SetSliderDialogDefaultValue(100)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iTwoCh = value as int
    SetSliderOptionValueST(iTwoCh)
  EndEvent
  Event OnHighlightST()
    SetInfoText("If only 2 Actors can be found, this will be treated as 100%, even when you set it to 0.")
  EndEvent
EndState

State Threesome
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iThreeCh)
    SetSliderDialogDefaultValue(100)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iThreeCh = value as int
    SetSliderOptionValueST(iThreeCh)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Relative Chance for a Threesome to happen.")
  EndEvent
endState

State Foursome
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iFourCh)
    SetSliderDialogDefaultValue(100)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iFourCh = value as int
    SetSliderOptionValueST(iFourCh)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Relative Chance for a Foursome to happen.")
  EndEvent
endState

State Fivesome
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iFiveCh)
    SetSliderDialogDefaultValue(100)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iFiveCh = value as int
    SetSliderOptionValueST(iFiveCh)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Relative Chance for a Fivesome to happen.")
  EndEvent
endState

State Notify
  Event OnSelectST()
    bNotify = !bNotify
    SetToggleOptionValueST(bNotify)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Get a notification everytime when an Engage happens and tells you who is being engaged by who.")
  EndEvent
EndState

State UseBed
  Event OnSelectST()
    bUseBed = !bUseBed
    SetToggleOptionValueST(bUseBed)
  EndEvent
  Event OnHighlightST()
    SetInfoText("If you are in a friendly location, and SL can find a bed nearby, Actors will use this bed to play a Scene instead of doing it where they stand.")
  EndEvent
EndState

State SupportFilter
	Event OnSelectST()
		bSupportFilter = !bSupportFilter
		SetToggleOptionValueST(bSupportFilter)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Enabling this adds additional Filter Options for Futas & Gendered Creatures to the \"Filter\" and \"Profiles\" Page.")
	EndEvent
EndState

; --------- Tagging
State ReadMeTagging
	Event OnSelectST()
		Debug.MessageBox("Below are Input Options to let you ask for specific Animation Tags for specific Animation Classes.\nIf you want to use multiple Tags for one Class, you must divide them with commas (e.g. \"doggy, anal\" will make the System look for animations tagged with \"doggy\" and \"anal\"). Capitalisation doesnt matter.\nRemember that too many tags can significantly reduce the Animations that can play.\nFor 2p Animations, the first Gender is always the Victim whereas the second is the Aggressor.")
	EndEvent
	Event OnHighlightST()
		SetInfoText("Click me")
	EndEvent
EndState

State UseAggressiveAnim
	Event OnSelectST()
		bUseAggressive = !bUseAggressive
		SetToggleOptionValueST(bUseAggressive)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If the mod should look for Animations tagged with \"Aggressive\".")
	EndEvent
EndState

; --------- Debug
State PrintTraces
	Event OnSelectST()
		bPrintTraces = !bPrintTraces
		SetToggleOptionValueST(bPrintTraces)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Print Traces to the log. This is meant for testing only and can impact performance in crowded Places.")
	EndEvent
EndState
; ==================================
; 	    	States // Location
; ==================================
State Cleared
  Event OnMenuOpenST()
		SetMenuDialogStartIndex(iIfClearedIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	EndEvent
	Event OnMenuAcceptST(int index)
		iIfClearedIndex = index
		SetMenuOptionValueST(ProfileList[iIfClearedIndex])
	EndEvent
	Event OnDefaultST()
		iIfClearedIndex = 1
		SetMenuOptionValueST(ProfileList[iIfClearedIndex])
	EndEvent
  Event OnHighlightST()
    SetInfoText("*If this is assigned a Profile, the mod will use that Profile for any Hostile Location that is considered \"Cleared\", ignoring your Settings below")
  EndEvent
EndState

; ==================================
; 	    	States // Profiles
; ==================================
State ProfileView
  Event OnMenuOpenST()
		SetMenuDialogStartIndex(ProfileViewerIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileViewerList)
	EndEvent
	Event OnMenuAcceptST(int index)
		ProfileViewerIndex = index
		SetMenuOptionValueST(ProfileViewerList[ProfileViewerIndex])
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		ProfileViewerIndex = 0
		SetMenuOptionValueST(ProfileViewerList[ProfileViewerIndex])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
		SetInfoText("Your currently viewed Profile.\nLocations will only use the Profile that is assigned to them (See \"Locations\" Tab)")
	endEvent
EndState

; ------------------ Profiles
; --------- Sheep
Function SheepProfile()
	AddHeaderOption(" Sheep")
	AddToggleOptionST("CombatSkipSheep", "Allow engagement while in Combat", bCombatSkipSheep)
	AddSliderOptionST("EngChanceSheep", "Chance for Engagement", iEngageChanceSheep)
	int HostileFlag = getFlag(bAllowHostiles)
	AddToggleOptionST("HostileVictimSheep", "Allow Hostile Victims", bHostVicSheep, HostileFlag)
	AddToggleOptionST("HostileOnFriendlySheep", "Hostiles engage Allies", bHostOnFriendSheep, HostileFlag)
	AddHeaderOption(" Engagement")
	ArousalSheep = AddToggleOption("Check for Arousal?", bUseArousalSheep)
	int ArousalFlag = getFlag(bUseArousalSheep)
	AddSliderOptionST("ArousThreshSheep", "NPC Arousal Threshhold", iArousalThreshSheep, "{0}", ArousalFlag)
	;---------fluffy edit --------
	AddSliderOptionST("ArousThreshPlayerSheep", "Player Arousal Threshhold", iArousalThreshPlayerSheep, "{0}", ArousalFlag)
	;---------fluffy end edit -----
	AddToggleOptionST("IgnoreVicArousalSheep", "Ignore Victim Arousal", bIgnoreVicArousalSheep, ArousalFlag)
	DistanceSheep = AddToggleOption("Check for Distance?", bUseDistSheep)
	AddSliderOptionST("maxDistanceSheep", "Maximum allowed Distance", fMaxDistanceSheep, "{0}m", getFlag(bUseDistSheep))
	LOSSheep = AddToggleOption("Check for LoS?", bUseLoSSheep)
	AddToggleOptionST("UseDispSheep", "Check for Disposition?", bUseDispotionSheep)
	int DispFlag = getFlag(bUseDispotionSheep)
	AddSliderOptionST("PlDispositionSheep", "Min Disposition (Player)", iMinDispPlSheep, "{0}", DispFlag)
	AddSliderOptionST("FolDispositionSheep", "Min Disposition (Follower)", iMinDispFolSheep, "{0}", DispFlag)
	AddSliderOptionST("NPCDispositionSheep", "Min Disposition (NPC)", iMinDispNPCSheep, "{0}", DispFlag)
	SetCursorPosition(3)
	AddHeaderOption(" Victim")
	allowPlSheep = AddToggleOption("Allow Player to be engaged", bEngagePlSheep)
	AddSliderOptionST("PreferPlSheep", "Prefer Player-Engagements", iPrefPlSheep, "{0}%", getFlag(bEngagePlSheep))
	allowFolSheep = AddToggleOption("Allow Followers to be engaged", bEngageFolSheep)
	AddToggleOptionST("RestrictFolGenderSheep", "Restrict Gender", bRestrictGenFolSheep, getFlag(bEngageFolSheep))
	allowNPCSheep = AddToggleOption("Allow NPCs to be engaged", bEngageNPCSheep)
	AddToggleOptionST("RestrictNPCGenderSheep", "Restrict Gender", bRestrictGenNPCSheep, getFlag(bEngageNPCSheep))
	allowCrtSheep = AddToggleOption("Allow Creatures to be engaged", bEngageCreatureSheep)
	If(bSupportFilter)
		AddToggleOptionST("RestrictCrtGenderSheep", "Restrict Gender", bRestrictGenCrtSheep, getFlag(bEngageCreatureSheep))
	EndIf
	AddEmptyOption()
	allowMalSheep = AddToggleOption("Allow Male Actors", bEngageMaleSheep, getFlagOR(bRestrictGenFolSheep, bRestrictGenNPCSheep, bRestrictGenCrtSheep))
	allowFemSheep = AddToggleOption("Allow Female Actors", bEngageFemaleSheep, getFlagOR(bRestrictGenFolSheep, bRestrictGenNPCSheep, bRestrictGenCrtSheep))
	If(bSupportFilter)
		allowFutSheep = AddToggleOption("Allow Futa Actors", bEngageFutaSheep, getFlagOR(bRestrictGenFolSheep, bRestrictGenNPCSheep, bRestrictGenCrtSheep))
		allowCrMSheep = AddToggleOption("Allow Male Creatures", bEngageCrMSheep, getFlagOR(bRestrictGenFolSheep, bRestrictGenNPCSheep, bRestrictGenCrtSheep))
		allowCrFSheep = AddToggleOption("Allow Female Creatures", bEngageCrFSheep, getFlagOR(bRestrictGenFolSheep, bRestrictGenNPCSheep, bRestrictGenCrtSheep))
	EndIf
EndFunction

State CombatSkipSheep
  Event OnSelectST()
    bCombatSkipSheep = !bCombatSkipSheep
    SetToggleOptionValueST(bCombatSkipSheep)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Should Scan be skipped when you are currently in Combat?")
  EndEvent
EndState

State EngChanceSheep
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iEngageChanceSheep)
    SetSliderDialogDefaultValue(40)
    SetSliderDialogRange(1, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iEngageChanceSheep = value as int
    SetSliderOptionValueST(iEngageChanceSheep)
  EndEvent
EndState

State HostileVictimSheep
	Event OnSelectST()
		bHostVicSheep = !bHostVicSheep
		SetToggleOptionValueST(bHostVicSheep)
	endEvent
	Event OnHighlightST()
		SetInfoText("Are hostile Actors allowed to be engaged?")
	EndEvent
EndState

State HostileOnFriendlySheep
	Event OnSelectST()
		bHostOnFriendSheep = !bHostOnFriendSheep
		SetToggleOptionValueST(bHostOnFriendSheep)
	endEvent
	Event OnHighlightST()
		SetInfoText("Are hostile Actors are allowed to attack friendly ones?")
	EndEvent
EndState
;	--------- Victim Settings
State PreferPlSheep
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iPrefPlSheep)
    SetSliderDialogDefaultValue(33)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iPrefPlSheep = value as int
    SetSliderOptionValueST(iPrefPlSheep)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The chance the Player will be evaluated as a potential Victim before any other Actors.\nA setting of 0 does NOT prevent the Player from being engaged. It will only cause them to be treated like any other NPC nearby.")
  EndEvent
EndState

State RestrictFolGenderSheep
	Event OnSelectST()
		bRestrictGenFolSheep = !bRestrictGenFolSheep
		SetToggleOptionValueST(bRestrictGenFolSheep)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, only Followers with a Valid Gender (set below) will be valid as Victim.")
	EndEvent
EndState

State RestrictNPCGenderSheep
	Event OnSelectST()
		bRestrictGenNPCSheep = !bRestrictGenNPCSheep
		SetToggleOptionValueST(bRestrictGenNPCSheep)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, only Actors with a Valid Gender (set below) will be valid as Victim.")
	EndEvent
EndState

State RestrictCrtGenderSheep
	Event OnSelectST()
		bRestrictGenCrtSheep = !bRestrictGenCrtSheep
		SetToggleOptionValueST(bRestrictGenCrtSheep)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, only Creatures with a Valid Gender (set below) will be valid as Victim.")
	EndEvent
EndState

;	--------- Engagement Settings
State ArousThreshSheep
  Event OnSliderOpenST()
		SetSliderDialogStartValue(iArousalThreshSheep)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(5, 101)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iArousalThreshSheep = value as int
		SetSliderOptionValueST(iArousalThreshSheep)
	EndEvent
	Event OnHighlightST()
		SetInfoText("The minimum arousal required for a Scene to start with NPC (set to 101 to disable).")
	EndEvent
EndState

;----------fluffy edit ------

State ArousThreshPlayerSheep
  Event OnSliderOpenST()
		SetSliderDialogStartValue(iArousalThreshPlayerSheep)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(5, 101)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iArousalThreshPlayerSheep = value as int
		SetSliderOptionValueST(iArousalThreshPlayerSheep)
	EndEvent
	Event OnHighlightST()
		SetInfoText("The minimum arousal required for a Scene to start with player (set to 101 to disable).")
	EndEvent
EndState

;----------fluffy end edit -------------

State IgnoreVicArousalSheep
  Event OnSelectST()
    bIgnoreVicArousalSheep = !bIgnoreVicArousalSheep
    SetToggleOptionValueST(bIgnoreVicArousalSheep)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Whether or not to ignore the Arousal of an engaged/Victim Actor")
  EndEvent
EndState

State maxDistanceSheep
  Event OnSliderOpenST()
    SetSliderDialogStartValue(fMaxDistanceSheep)
    SetSliderDialogDefaultValue(12)
    SetSliderDialogRange(5, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    fMaxDistanceSheep = value
    SetSliderOptionValueST(fMaxDistanceSheep)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The maximum distance 2 Actors are allowed to be apart from each other for a Scene to start.")
  EndEvent
EndState

State UseDispSheep
  Event OnSelectST()
    bUseDispotionSheep  = !bUseDispotionSheep
    SetToggleOptionValueST(bUseDispotionSheep)
    If(bUseDispotionSheep)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "PlDispositionSheep")
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "FolDispositionSheep")
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "NPCDispositionSheep")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "PlDispositionSheep")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "FolDispositionSheep")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "NPCDispositionSheep")
    endIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("Check what Disposition the Engaging has with the Engaged?\nNote that this can massively reduce the amount of Engagements, especially in an early save.")
  EndEvent
EndState

State PlDispositionSheep
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iMinDispPlSheep)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(-4, 4)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iMinDispPlSheep = value as int
    SetSliderOptionValueST(iMinDispPlSheep)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The minimum required Disposition an engaging Actor needs to have towards the Player to engage them.\nSetting this to -4 effectively disables this Setting.")
  EndEvent
EndState

State FolDispositionSheep
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iMinDispFolSheep)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(-4, 4)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iMinDispFolSheep = value as int
    SetSliderOptionValueST(iMinDispFolSheep)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The minimum required Disposition an engaging Actor needs to have towards the Player to engage the Follower.\nThis checks for Player Disposition as most Followers dont have any custom Dispotion to NPCs outside their home town (and custom Followers usually dont even have that).\nSetting this to -4 effectively disables this Setting.")
  EndEvent
EndState

State NPCDispositionSheep
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iMinDispNPCSheep)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(-4, 4)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iMinDispNPCSheep = value as int
    SetSliderOptionValueST(iMinDispNPCSheep)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The minimum required Disposition an engaging Actor needs to have towards their Target (every valid Target that isnt the Player or a Follower) to engage them.\nSetting this to -4 effectively disables this Setting.")
  EndEvent
EndState

; --------- Wolf
Function WolfProfile()
	AddHeaderOption(" Wolf")
	AddToggleOptionST("CombatSkipWolf", "Allow engagement while in Combat", bCombatSkipWolf)
	AddSliderOptionST("EngChanceWolf", "Chance for Engagement", iEngageChanceWolf)
	int HostileFlag = getFlag(bAllowHostiles)
	AddToggleOptionST("HostileVictimWolf", "Allow Hostile Victims", bHostVicWolf, HostileFlag)
	AddToggleOptionST("HostileOnFriendlyWolf", "Hostiles engage Allies", bHostOnFriendWolf, HostileFlag)
	AddHeaderOption(" Engagement")
	ArousalWolf = AddToggleOption("Check for Arousal?", bUseArousalWolf)
	int ArousalFlag = getFlag(bUseArousalWolf)
	AddSliderOptionST("ArousThreshWolf", "Arousal Threshhold", iArousalThreshWolf, "{0}", ArousalFlag)
	AddToggleOptionST("IgnoreVicArousalWolf", "Ignore Victim Arousal", bIgnoreVicArousalWolf, ArousalFlag)
	DistanceWolf = AddToggleOption("Check for Distance?", bUseDistWolf)
	AddSliderOptionST("maxDistanceWolf", "Maximum allowed Distance", fMaxDistanceWolf, "{0}m", getFlag(bUseDistWolf))
	LOSWolf = AddToggleOption("Check for LoS?", bUseLoSWolf)
	AddToggleOptionST("UseDispWolf", "Check for Disposition?", bUseDispotionWolf)
	int DispFlag = getFlag(bUseDispotionWolf)
	AddSliderOptionST("PlDispositionWolf", "Min Disposition (Player)", iMinDispPlWolf, "{0}", DispFlag)
	AddSliderOptionST("FolDispositionWolf", "Min Disposition (Follower)", iMinDispFolWolf, "{0}", DispFlag)
	AddSliderOptionST("NPCDispositionWolf", "Min Disposition (NPC)", iMinDispNPCWolf, "{0}", DispFlag)
	SetCursorPosition(3)
	AddHeaderOption(" Victim")
	allowPlWolf = AddToggleOption("Allow Player to be engaged", bEngagePlWolf)
	AddSliderOptionST("PreferPlWolf", "Prefer Player-Engagements", iPrefPlWolf, "{0}%", getFlag(bEngagePlWolf))
	allowFolWolf = AddToggleOption("Allow Followers to be engaged", bEngageFolWolf)
	AddToggleOptionST("RestrictFolGenderWolf", "Restrict Gender", bRestrictGenFolWolf, getFlag(bEngageFolWolf))
	allowNPCWolf = AddToggleOption("Allow NPCs to be engaged", bEngageNPCWolf)
	AddToggleOptionST("RestrictNPCGenderWolf", "Restrict Gender", bRestrictGenNPCWolf, getFlag(bEngageNPCWolf))
	allowCrtWolf = AddToggleOption("Allow Creatures to be engaged", bEngageCreatureWolf)
	If(bSupportFilter)
		AddToggleOptionST("RestrictCrtGenderWolf", "Restrict Gender", bRestrictGenCrtWolf, getFlag(bEngageCreatureWolf))
	EndIf
	AddEmptyOption()
	allowMalWolf = AddToggleOption("Allow Male Actors", bEngageMaleWolf, getFlagOR(bRestrictGenFolWolf, bRestrictGenNPCWolf, bRestrictGenCrtWolf))
	allowFemWolf = AddToggleOption("Allow Female Actors", bEngageFemaleWolf, getFlagOR(bRestrictGenFolWolf, bRestrictGenNPCWolf, bRestrictGenCrtWolf))
	If(bSupportFilter)
		allowFutWolf = AddToggleOption("Allow Futa Actors", bEngageFutaWolf, getFlagOR(bRestrictGenFolWolf, bRestrictGenNPCWolf, bRestrictGenCrtWolf))
		allowCrMWolf = AddToggleOption("Allow Male Creatures", bEngageCrMWolf, getFlagOR(bRestrictGenFolWolf, bRestrictGenNPCWolf, bRestrictGenCrtWolf))
		allowCrFWolf = AddToggleOption("Allow Female Creatures", bEngageCrFWolf, getFlagOR(bRestrictGenFolWolf, bRestrictGenNPCWolf, bRestrictGenCrtWolf))
	EndIf
EndFunction

State CombatSkipWolf
  Event OnSelectST()
    bCombatSkipWolf = !bCombatSkipWolf
    SetToggleOptionValueST(bCombatSkipWolf)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Should Scan be skipped when you are currently in Combat?")
  EndEvent
EndState

State EngChanceWolf
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iEngageChanceWolf)
    SetSliderDialogDefaultValue(40)
    SetSliderDialogRange(1, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iEngageChanceWolf = value as int
    SetSliderOptionValueST(iEngageChanceWolf)
  EndEvent
EndState

State HostileVictimWolf
	Event OnSelectST()
		bHostVicWolf = !bHostVicWolf
		SetToggleOptionValueST(bHostVicWolf)
	endEvent
	Event OnHighlightST()
		SetInfoText("Are hostile Actors allowed to be engaged?")
	EndEvent
EndState

State HostileOnFriendlyWolf
	Event OnSelectST()
		bHostOnFriendWolf = !bHostOnFriendWolf
		SetToggleOptionValueST(bHostOnFriendWolf)
	endEvent
	Event OnHighlightST()
		SetInfoText("Are hostile Actors are allowed to attack friendly ones?")
	EndEvent
EndState
;	--------- Victim Settings
State PreferPlWolf
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iPrefPlWolf)
    SetSliderDialogDefaultValue(33)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iPrefPlWolf = value as int
    SetSliderOptionValueST(iPrefPlWolf)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The chance the Player will be evaluated as a potential Victim before any other Actors.\nA setting of 0 does NOT prevent the Player from being engaged. It will only cause them to be treated like any other NPC nearby.")
  EndEvent
EndState

State RestrictFolGenderWolf
	Event OnSelectST()
		bRestrictGenFolWolf = !bRestrictGenFolWolf
		SetToggleOptionValueST(bRestrictGenFolWolf)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, only Followers with a Valid Gender (set below) will be valid as Victim.")
	EndEvent
EndState

State RestrictNPCGenderWolf
	Event OnSelectST()
		bRestrictGenNPCWolf = !bRestrictGenNPCWolf
		SetToggleOptionValueST(bRestrictGenNPCWolf)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, only Actors with a Valid Gender (set below) will be valid as Victim.")
	EndEvent
EndState

State RestrictCrtGenderWolf
	Event OnSelectST()
		bRestrictGenCrtWolf = !bRestrictGenCrtWolf
		SetToggleOptionValueST(bRestrictGenCrtWolf)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, only Creatures with a Valid Gender (set below) will be valid as Victim.")
	EndEvent
EndState

;	--------- Engagement Settings
State ArousThreshWolf
  Event OnSliderOpenST()
		SetSliderDialogStartValue(iArousalThreshWolf)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(5, 60)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iArousalThreshWolf = value as int
		SetSliderOptionValueST(iArousalThreshWolf)
	EndEvent
	Event OnHighlightST()
		SetInfoText("The minimum arousal recruited for a Scene to start.")
	EndEvent
EndState

State IgnoreVicArousalWolf
  Event OnSelectST()
    bIgnoreVicArousalWolf = !bIgnoreVicArousalWolf
    SetToggleOptionValueST(bIgnoreVicArousalWolf)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Whether or not to ignore the Arousal of an engaged/Victim Actor")
  EndEvent
EndState

State maxDistanceWolf
  Event OnSliderOpenST()
    SetSliderDialogStartValue(fMaxDistanceWolf)
    SetSliderDialogDefaultValue(12)
    SetSliderDialogRange(5, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    fMaxDistanceWolf = value
    SetSliderOptionValueST(fMaxDistanceWolf)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The maximum distance 2 Actors are allowed to be apart from each other for a Scene to start.")
  EndEvent
EndState

State UseDispWolf
  Event OnSelectST()
    bUseDispotionWolf  = !bUseDispotionWolf
    SetToggleOptionValueST(bUseDispotionWolf)
    If(bUseDispotionWolf)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "PlDispositionWolf")
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "FolDispositionWolf")
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "NPCDispositionWolf")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "PlDispositionWolf")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "FolDispositionWolf")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "NPCDispositionWolf")
    endIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("Check what Disposition the Engaging has with the Engaged?\nNote that this can massively reduce the amount of Engagements, especially in an early save.")
  EndEvent
EndState

State PlDispositionWolf
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iMinDispPlWolf)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(-4, 4)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iMinDispPlWolf = value as int
    SetSliderOptionValueST(iMinDispPlWolf)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The minimum required Disposition an engaging Actor needs to have towards the Player to engage them.\nSetting this to -4 effectively disables this Setting.")
  EndEvent
EndState

State FolDispositionWolf
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iMinDispFolWolf)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(-4, 4)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iMinDispFolWolf = value as int
    SetSliderOptionValueST(iMinDispFolWolf)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The minimum required Disposition an engaging Actor needs to have towards the Player to engage the Follower.\nThis checks for Player Disposition as most Followers dont have any custom Dispotion to NPCs outside their home town (and custom Followers usually dont even have that).\nSetting this to -4 effectively disables this Setting.")
  EndEvent
EndState

State NPCDispositionWolf
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iMinDispNPCWolf)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(-4, 4)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iMinDispNPCWolf = value as int
    SetSliderOptionValueST(iMinDispNPCWolf)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The minimum required Disposition an engaging Actor needs to have towards their Target (every valid Target that isnt the Player or a Follower) to engage them.\nSetting this to -4 effectively disables this Setting.")
  EndEvent
EndState

; --------- Bunny
Function BunnyProfile()
	AddHeaderOption(" Bunny")
	AddToggleOptionST("CombatSkipBunny", "Allow engagement while in Combat", bCombatSkipBunny)
	AddSliderOptionST("EngChanceBunny", "Chance for Engagement", iEngageChanceBunny)
	int HostileFlag = getFlag(bAllowHostiles)
	AddToggleOptionST("HostileVictimBunny", "Allow Hostile Victims", bHostVicBunny, HostileFlag)
	AddToggleOptionST("HostileOnFriendlyBunny", "Hostiles engage Allies", bHostOnFriendBunny, HostileFlag)
	AddHeaderOption(" Engagement")
	ArousalBunny = AddToggleOption("Check for Arousal?", bUseArousalBunny)
	int ArousalFlag = getFlag(bUseArousalBunny)
	AddSliderOptionST("ArousThreshBunny", "Arousal Threshhold", iArousalThreshBunny, "{0}", ArousalFlag)
	AddToggleOptionST("IgnoreVicArousalBunny", "Ignore Victim Arousal", bIgnoreVicArousalBunny, ArousalFlag)
	DistanceBunny = AddToggleOption("Check for Distance?", bUseDistBunny)
	AddSliderOptionST("maxDistanceBunny", "Maximum allowed Distance", fMaxDistanceBunny, "{0}m", getFlag(bUseDistBunny))
	LOSBunny = AddToggleOption("Check for LoS?", bUseLoSBunny)
	AddToggleOptionST("UseDispBunny", "Check for Disposition?", bUseDispotionBunny)
	int DispFlag = getFlag(bUseDispotionBunny)
	AddSliderOptionST("PlDispositionBunny", "Min Disposition (Player)", iMinDispPlBunny, "{0}", DispFlag)
	AddSliderOptionST("FolDispositionBunny", "Min Disposition (Follower)", iMinDispFolBunny, "{0}", DispFlag)
	AddSliderOptionST("NPCDispositionBunny", "Min Disposition (NPC)", iMinDispNPCBunny, "{0}", DispFlag)
	SetCursorPosition(3)
	AddHeaderOption(" Victim")
	allowPlBunny = AddToggleOption("Allow Player to be engaged", bEngagePlBunny)
	AddSliderOptionST("PreferPlBunny", "Prefer Player-Engagements", iPrefPlBunny, "{0}%", getFlag(bEngagePlBunny))
	allowFolBunny = AddToggleOption("Allow Followers to be engaged", bEngageFolBunny)
	AddToggleOptionST("RestrictFolGenderBunny", "Restrict Gender", bRestrictGenFolBunny, getFlag(bEngageFolBunny))
	allowNPCBunny = AddToggleOption("Allow NPCs to be engaged", bEngageNPCBunny)
	AddToggleOptionST("RestrictNPCGenderBunny", "Restrict Gender", bRestrictGenNPCBunny, getFlag(bEngageNPCBunny))
	allowCrtBunny = AddToggleOption("Allow Creatures to be engaged", bEngageCreatureBunny)
	If(bSupportFilter)
		AddToggleOptionST("RestrictCrtGenderBunny", "Restrict Gender", bRestrictGenCrtBunny, getFlag(bEngageCreatureBunny))
	EndIf
	AddEmptyOption()
	allowMalBunny = AddToggleOption("Allow Male Actors", bEngageMaleBunny, getFlagOR(bRestrictGenFolBunny, bRestrictGenNPCBunny, bRestrictGenCrtBunny))
	allowFemBunny = AddToggleOption("Allow Female Actors", bEngageFemaleBunny, getFlagOR(bRestrictGenFolBunny, bRestrictGenNPCBunny, bRestrictGenCrtBunny))
	If(bSupportFilter)
		allowFutBunny = AddToggleOption("Allow Futa Actors", bEngageFutaBunny, getFlagOR(bRestrictGenFolBunny, bRestrictGenNPCBunny, bRestrictGenCrtBunny))
		allowCrMBunny = AddToggleOption("Allow Male Creatures", bEngageCrMBunny, getFlagOR(bRestrictGenFolBunny, bRestrictGenNPCBunny, bRestrictGenCrtBunny))
		allowCrFBunny = AddToggleOption("Allow Female Creatures", bEngageCrFBunny, getFlagOR(bRestrictGenFolBunny, bRestrictGenNPCBunny, bRestrictGenCrtBunny))
	EndIf
EndFunction

State CombatSkipBunny
  Event OnSelectST()
    bCombatSkipBunny = !bCombatSkipBunny
    SetToggleOptionValueST(bCombatSkipBunny)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Should Scan be skipped when you are currently in Combat?")
  EndEvent
EndState

State EngChanceBunny
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iEngageChanceBunny)
    SetSliderDialogDefaultValue(40)
    SetSliderDialogRange(1, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iEngageChanceBunny = value as int
    SetSliderOptionValueST(iEngageChanceBunny)
  EndEvent
EndState

State HostileVictimBunny
	Event OnSelectST()
		bHostVicBunny = !bHostVicBunny
		SetToggleOptionValueST(bHostVicBunny)
	endEvent
	Event OnHighlightST()
		SetInfoText("Are hostile Actors allowed to be engaged?")
	EndEvent
EndState

State HostileOnFriendlyBunny
	Event OnSelectST()
		bHostOnFriendBunny = !bHostOnFriendBunny
		SetToggleOptionValueST(bHostOnFriendBunny)
	endEvent
	Event OnHighlightST()
		SetInfoText("Are hostile Actors are allowed to attack friendly ones?")
	EndEvent
EndState
;	--------- Victim Settings
State PreferPlBunny
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iPrefPlBunny)
    SetSliderDialogDefaultValue(33)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iPrefPlBunny = value as int
    SetSliderOptionValueST(iPrefPlBunny)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The chance the Player will be evaluated as a potential Victim before any other Actors.\nA setting of 0 does NOT prevent the Player from being engaged. It will only cause them to be treated like any other NPC nearby.")
  EndEvent
EndState

State RestrictFolGenderBunny
	Event OnSelectST()
		bRestrictGenFolBunny = !bRestrictGenFolBunny
		SetToggleOptionValueST(bRestrictGenFolBunny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, only Followers with a Valid Gender (set below) will be valid as Victim.")
	EndEvent
EndState

State RestrictNPCGenderBunny
	Event OnSelectST()
		bRestrictGenNPCBunny = !bRestrictGenNPCBunny
		SetToggleOptionValueST(bRestrictGenNPCBunny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, only Actors with a Valid Gender (set below) will be valid as Victim.")
	EndEvent
EndState

State RestrictCrtGenderBunny
	Event OnSelectST()
		bRestrictGenCrtBunny = !bRestrictGenCrtBunny
		SetToggleOptionValueST(bRestrictGenCrtBunny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, only Creatures with a Valid Gender (set below) will be valid as Victim.")
	EndEvent
EndState

;	--------- Engagement Settings
State ArousThreshBunny
  Event OnSliderOpenST()
		SetSliderDialogStartValue(iArousalThreshBunny)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(5, 60)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iArousalThreshBunny = value as int
		SetSliderOptionValueST(iArousalThreshBunny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("The minimum arousal recruited for a Scene to start.")
	EndEvent
EndState

State IgnoreVicArousalBunny
  Event OnSelectST()
    bIgnoreVicArousalBunny = !bIgnoreVicArousalBunny
    SetToggleOptionValueST(bIgnoreVicArousalBunny)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Whether or not to ignore the Arousal of an engaged/Victim Actor")
  EndEvent
EndState

State maxDistanceBunny
  Event OnSliderOpenST()
    SetSliderDialogStartValue(fMaxDistanceBunny)
    SetSliderDialogDefaultValue(12)
    SetSliderDialogRange(5, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    fMaxDistanceBunny = value
    SetSliderOptionValueST(fMaxDistanceBunny)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The maximum distance 2 Actors are allowed to be apart from each other for a Scene to start.")
  EndEvent
EndState

State UseDispBunny
  Event OnSelectST()
    bUseDispotionBunny  = !bUseDispotionBunny
    SetToggleOptionValueST(bUseDispotionBunny)
    If(bUseDispotionBunny)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "PlDispositionBunny")
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "FolDispositionBunny")
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "NPCDispositionBunny")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "PlDispositionBunny")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "FolDispositionBunny")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "NPCDispositionBunny")
    endIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("Check what Disposition the Engaging has with the Engaged?\nNote that this can massively reduce the amount of Engagements, especially in an early save.")
  EndEvent
EndState

State PlDispositionBunny
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iMinDispPlBunny)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(-4, 4)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iMinDispPlBunny = value as int
    SetSliderOptionValueST(iMinDispPlBunny)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The minimum required Disposition an engaging Actor needs to have towards the Player to engage them.\nSetting this to -4 effectively disables this Setting.")
  EndEvent
EndState

State FolDispositionBunny
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iMinDispFolBunny)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(-4, 4)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iMinDispFolBunny = value as int
    SetSliderOptionValueST(iMinDispFolBunny)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The minimum required Disposition an engaging Actor needs to have towards the Player to engage the Follower.\nThis checks for Player Disposition as most Followers dont have any custom Dispotion to NPCs outside their home town (and custom Followers usually dont even have that).\nSetting this to -4 effectively disables this Setting.")
  EndEvent
EndState

State NPCDispositionBunny
  Event OnSliderOpenST()
    SetSliderDialogStartValue(iMinDispNPCBunny)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(-4, 4)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(float value)
    iMinDispNPCBunny = value as int
    SetSliderOptionValueST(iMinDispNPCBunny)
  EndEvent
  Event OnHighlightST()
    SetInfoText("The minimum required Disposition an engaging Actor needs to have towards their Target (every valid Target that isnt the Player or a Follower) to engage them.\nSetting this to -4 effectively disables this Setting.")
  EndEvent
EndState

; ==================================
;				 	States // Filter
; ==================================
State ReadMeFilter
	Event OnSelectST()
		Debug.MessageBox("The Options here let you decide who can engage who. All of them are from the Victims PoV\n(\"Can [Headline] be engaged by [Option]?\")")
	EndEvent
	Event OnHighlightST()
		SetInfoText("Click me")
	EndEvent
EndState

; ==================================
; 					NON STATE MCM
; ==================================
Event OnOptionSelect(int option)
	; ======================== Profile ========================
	; ========================= Sheep =========================
	If(option == allowPlSheep)
		bEngagePlSheep = !bEngagePlSheep
		If(bEngagePlSheep)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "PreferPlSheep")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "PreferPlSheep")
		EndIf
		SetToggleOptionValue(allowPlSheep, bEngagePlSheep)
	ElseIf(option == allowFolSheep)
		bEngageFolSheep = !bEngageFolSheep
		If(bEngageFolSheep)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "RestrictFolGenderSheep")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "RestrictFolGenderSheep")
		EndIf
		SetToggleOptionValue(allowFolSheep, bEngageFolSheep)
	ElseIf(option == allowNPCSheep)
		bEngageNPCSheep = !bEngageNPCSheep
		If(bEngageNPCSheep)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "RestrictNPCGenderSheep")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "RestrictNPCGenderSheep")
		EndIf
		SetToggleOptionValue(allowNPCSheep, bEngageNPCSheep)
	ElseIf(option == allowCrtSheep)
		bEngageCreatureSheep = !bEngageCreatureSheep
		If(bEngageCreatureSheep)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "RestrictCrtGenderSheep")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "RestrictCrtGenderSheep")
		EndIf
		SetToggleOptionValue(allowCrtSheep, bEngageCreatureSheep)
	ElseIf(option == allowMalSheep)
		bEngageMaleSheep = !bEngageMaleSheep
		SetToggleOptionValue(allowMalSheep, bEngageMaleSheep)
	ElseIf(option == allowFemSheep)
		bEngageFemaleSheep = !bEngageFemaleSheep
		SetToggleOptionValue(allowFemSheep, bEngageFemaleSheep)
	ElseIf(option == allowFutSheep)
		bEngageFutaSheep = !bEngageFutaSheep
		SetToggleOptionValue(allowFutSheep, bEngageFutaSheep)
	ElseIf(option == ArousalSheep)
		bUseArousalSheep = !bUseArousalSheep
		If(bUseArousalSheep)
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "ArousThreshSheep")
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "IgnoreVicArousalSheep")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "ArousThreshSheep")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "IgnoreVicArousalSheep")
		EndIf
		SetToggleOptionValue(ArousalSheep, bUseArousalSheep)
	ElseIf(option == LOSSheep)
		bUseLoSSheep = !bUseLoSSheep
		SetToggleOptionValue(LOSSheep, bUseLoSSheep)
	ElseIf(option == DistanceSheep)
		bUseDistSheep = !bUseDistSheep
		If(bUseDistSheep)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "maxDistanceSheep")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "maxDistanceSheep")
		EndIf
		SetToggleOptionValue(DistanceSheep, bUseDistSheep)
	ElseIf(option == allowCrMSheep)
		bEngageCrMSheep = !bEngageCrMSheep
		SetToggleOptionValue(allowCrMSheep, bEngageCrMSheep)
	ElseIf(option == allowCrFSheep)
		bEngageCrFSheep = !bEngageCrFSheep
		SetToggleOptionValue(allowCrFSheep, bEngageCrFSheep)
		; ========================= Wolf =========================
	ElseIf(option == allowPlWolf)
		bEngagePlWolf = !bEngagePlWolf
		If(bEngagePlWolf)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "PreferPlWolf")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "PreferPlWolf")
		EndIf
		SetToggleOptionValue(allowPlWolf, bEngagePlWolf)
	ElseIf(option == allowFolWolf)
		bEngageFolWolf = !bEngageFolWolf
		If(bEngageFolWolf)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "RestrictFolGenderWolf")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "RestrictFolGenderWolf")
		EndIf
		SetToggleOptionValue(allowFolWolf, bEngageFolWolf)
	ElseIf(option == allowNPCWolf)
		bEngageNPCWolf = !bEngageNPCWolf
		If(bEngageNPCWolf)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "RestrictNPCGenderWolf")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "RestrictNPCGenderWolf")
		EndIf
		SetToggleOptionValue(allowNPCWolf, bEngageNPCWolf)
	ElseIf(option == allowCrtWolf)
		bEngageCreatureWolf = !bEngageCreatureWolf
		If(bEngageCreatureWolf)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "RestrictCrtGenderWolf")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "RestrictCrtGenderWolf")
		EndIf
		SetToggleOptionValue(allowCrtWolf, bEngageCreatureWolf)
	ElseIf(option == allowMalWolf)
		bEngageMaleWolf = !bEngageMaleWolf
		SetToggleOptionValue(allowMalWolf, bEngageMaleWolf)
	ElseIf(option == allowFemWolf)
		bEngageFemaleWolf = !bEngageFemaleWolf
		SetToggleOptionValue(allowFemWolf, bEngageFemaleWolf)
	ElseIf(option == allowFutWolf)
		bEngageFutaWolf = !bEngageFutaWolf
		SetToggleOptionValue(allowFutWolf, bEngageFutaWolf)
	ElseIf(option == ArousalWolf)
		bUseArousalWolf = !bUseArousalWolf
		If(bUseArousalWolf)
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "ArousThreshWolf")
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "IgnoreVicArousalWolf")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "ArousThreshWolf")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "IgnoreVicArousalWolf")
		EndIf
		SetToggleOptionValue(ArousalWolf, bUseArousalWolf)
	ElseIf(option == LOSWolf)
		bUseLoSWolf = !bUseLoSWolf
		SetToggleOptionValue(LOSWolf, bUseLoSWolf)
	ElseIf(option == DistanceWolf)
		bUseDistWolf = !bUseDistWolf
		If(bUseDistWolf)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "maxDistanceWolf")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "maxDistanceWolf")
		EndIf
		SetToggleOptionValue(DistanceWolf, bUseDistWolf)
	ElseIf(option == allowCrMWolf)
		bEngageCrMWolf = !bEngageCrMWolf
		SetToggleOptionValue(allowCrMWolf, bEngageCrMWolf)
	ElseIf(option == allowCrFWolf)
		bEngageCrFWolf = !bEngageCrFWolf
		SetToggleOptionValue(allowCrFWolf, bEngageCrFWolf)
		; ========================= Bunny =========================
	ElseIf(option == allowPlBunny)
		bEngagePlBunny = !bEngagePlBunny
		If(bEngagePlBunny)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "PreferPlBunny")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "PreferPlBunny")
		EndIf
		SetToggleOptionValue(allowPlBunny, bEngagePlBunny)
	ElseIf(option == allowFolBunny)
		bEngageFolBunny = !bEngageFolBunny
		If(bEngageFolBunny)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "RestrictFolGenderBunny")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "RestrictFolGenderBunny")
		EndIf
		SetToggleOptionValue(allowFolBunny, bEngageFolBunny)
	ElseIf(option == allowNPCBunny)
		bEngageNPCBunny = !bEngageNPCBunny
		If(bEngageNPCBunny)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "RestrictNPCGenderBunny")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "RestrictNPCGenderBunny")
		EndIf
		SetToggleOptionValue(allowNPCBunny, bEngageNPCBunny)
	ElseIf(option == allowCrtBunny)
		bEngageCreatureBunny = !bEngageCreatureBunny
		If(bEngageCreatureBunny)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "RestrictCrtGenderBunny")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "RestrictCrtGenderBunny")
		EndIf
		SetToggleOptionValue(allowCrtBunny, bEngageCreatureBunny)
	ElseIf(option == allowMalBunny)
		bEngageMaleBunny = !bEngageMaleBunny
		SetToggleOptionValue(allowMalBunny, bEngageMaleBunny)
	ElseIf(option == allowFemBunny)
		bEngageFemaleBunny = !bEngageFemaleBunny
		SetToggleOptionValue(allowFemBunny, bEngageFemaleBunny)
	ElseIf(option == allowFutBunny)
		bEngageFutaBunny = !bEngageFutaBunny
		SetToggleOptionValue(allowFutBunny, bEngageFutaBunny)
	ElseIf(option == ArousalBunny)
		bUseArousalBunny = !bUseArousalBunny
		If(bUseArousalBunny)
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "ArousThreshBunny")
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "IgnoreVicArousalBunny")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "ArousThreshBunny")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "IgnoreVicArousalBunny")
		EndIf
		SetToggleOptionValue(ArousalBunny, bUseArousalBunny)
	ElseIf(option == LOSBunny)
		bUseLoSBunny = !bUseLoSBunny
		SetToggleOptionValue(LOSBunny, bUseLoSBunny)
	ElseIf(option == DistanceBunny)
		bUseDistBunny = !bUseDistBunny
		If(bUseDistBunny)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "maxDistanceBunny")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "maxDistanceBunny")
		EndIf
		SetToggleOptionValue(DistanceBunny, bUseDistBunny)
	ElseIf(option == allowCrMBunny)
		bEngageCrMBunny = !bEngageCrMBunny
		SetToggleOptionValue(allowCrMBunny, bEngageCrMBunny)
	ElseIf(option == allowCrFBunny)
		bEngageCrFBunny = !bEngageCrFBunny
		SetToggleOptionValue(allowCrFBunny, bEngageCrFBunny)
		; ========================= Filter =========================
		; ======================== Follower ========================
		; Male Followers
	ElseIf(option == oMaleFollowerPlayer)
		bMalFolAssPl = !bMalFolAssPl
		SetToggleOptionValue(oMaleFollowerPlayer, bMalFolAssPl)
	ElseIf(option == oMaleFollowerFollower)
		bMalFolAssFol = !bMalFolAssFol
			SetToggleOptionValue(oMaleFollowerFollower, bMalFolAssFol)
	ElseIf(option == oMaleFollowerMale)
		bMalFolAssMal = !bMalFolAssMal
		SetToggleOptionValue(oMaleFollowerMale, bMalFolAssMal)
	ElseIf(option == oMaleFollowerFemale)
		bMalFolAssFem = !bMalFolAssFem
		SetToggleOptionValue(oMaleFollowerFemale, bMalFolAssFem)
	ElseIf(option == oMaleFollowerFuta)
		bMalFolAssFut = !bMalFolAssFut
		SetToggleOptionValue(oMaleFollowerFuta, bMalFolAssFut)
	ElseIf(option == oMaleFollowerCreatureMale)
		bMalFolAssCrM = !bMalFolAssCrM
		SetToggleOptionValue(oMaleFollowerCreatureMale, bMalFolAssCrM)
	ElseIf(option == oMaleFollowerCreatureFemale)
		bMalFolAssCrF = !bMalFolAssCrF
		SetToggleOptionValue(oMaleFollowerCreatureFemale, bMalFolAssCrF)
		; Female Followers
	ElseIf(option == oFemaleFollowerPlayer)
		bFemFolAssPl = !bFemFolAssPl
		SetToggleOptionValue(oFemaleFollowerPlayer, bFemFolAssPl)
	ElseIf(option == oFemaleFollowerFollower)
		bFemFolAssFol = !bFemFolAssFol
		SetToggleOptionValue(oFemaleFollowerFollower, bFemFolAssFol)
	ElseIf(option == oFemaleFollowerMale)
		bFemFolAssMal = !bFemFolAssMal
		SetToggleOptionValue(oFemaleFollowerMale, bFemFolAssMal)
	ElseIf(option == oFemaleFollowerFemale)
		bFemFolAssFem = !bFemFolAssFem
		SetToggleOptionValue(oFemaleFollowerFemale, bFemFolAssFem)
	ElseIf(option == oFemaleFollowerFuta)
		bFemFolAssFut = !bFemFolAssFut
		SetToggleOptionValue(oFemaleFollowerFuta, bFemFolAssFut)
	ElseIf(option == oFemaleFollowerCreatureMale)
		bFemFolAssCrM = !bFemFolAssCrM
		SetToggleOptionValue(oFemaleFollowerCreatureMale, bFemFolAssCrM)
	ElseIf(option == oFemaleFollowerCreatureFemale)
		bFemFolAssCrF = !bFemFolAssCrF
		SetToggleOptionValue(oFemaleFollowerCreatureFemale, bFemFolAssCrF)
		; Futa Followers
	ElseIf(option == oFutaFollowerPlayer)
		bFutFolAssPl = !bFutFolAssPl
		SetToggleOptionValue(oFutaFollowerPlayer, bFutFolAssPl)
	ElseIf(option == oFutaFollowerFollower)
		bFutFolAssFol = !bFutFolAssFol
		SetToggleOptionValue(oFutaFollowerFollower, bFutFolAssFol)
	ElseIf(option == oFutaFollowerMale)
		bFutFolAssMal = !bFutFolAssMal
		SetToggleOptionValue(oFutaFollowerMale, bFutFolAssMal)
	ElseIf(option == oFutaFollowerFemale)
		bFutFolAssFem = !bFutFolAssFem
		SetToggleOptionValue(oFutaFollowerFemale, bFutFolAssFem)
	ElseIf(option == oFutaFollowerFuta)
		bFutFolAssFut = !bFutFolAssFut
		SetToggleOptionValue(oFutaFollowerFuta, bFutFolAssFut)
	ElseIf(option == oFutaFollowerCreatureMale)
		bFutFolAssCrM = !bFutFolAssCrM
		SetToggleOptionValue(oFutaFollowerCreatureMale, bFutFolAssCrM)
	ElseIf(option == oFutaFollowerCreatureFemale)
		bFutFolAssCrF = !bFutFolAssCrF
		SetToggleOptionValue(oFutaFollowerCreatureFemale, bFutFolAssCrF)
		; (Male) Creature Followers
	ElseIf(option == oCreatureMaleFollowerPlayer)
		bCrMFolAssPl = !bCrMFolAssPl
		SetToggleOptionValue(oCreatureMaleFollowerPlayer, bCrMFolAssPl)
	ElseIf(option == oCreatureMaleFollowerFollower)
		bCrMFolAssFol = !bCrMFolAssFol
		SetToggleOptionValue(oCreatureMaleFollowerFollower, bCrMFolAssFol)
	ElseIf(option == oCreatureMaleFollowerMale)
		bCrMFolAssMal = !bCrMFolAssMal
		SetToggleOptionValue(oCreatureMaleFollowerMale, bCrMFolAssMal)
	ElseIf(option == oCreatureMaleFollowerFemale)
		bCrMFolAssFem = !bCrMFolAssFem
		SetToggleOptionValue(oCreatureMaleFollowerFemale, bCrMFolAssFem)
	ElseIf(option == oCreatureMaleFollowerFuta)
		bCrMFolAssFut = !bCrMFolAssFut
		SetToggleOptionValue(oCreatureMaleFollowerFuta, bCrMFolAssFut)
	ElseIf(option == oCreatureMaleFollowerCreatureMale)
		bCrMFolAssCrM = !bCrMFolAssCrM
		SetToggleOptionValue(oCreatureMaleFollowerCreatureMale, bCrMFolAssCrM)
	ElseIf(option == oCreatureMaleFollowerCreatureFemale)
		bCrMFolAssCrF = !bCrMFolAssCrF
		SetToggleOptionValue(oCreatureMaleFollowerCreatureFemale, bCrMFolAssCrF)
		; Female Creature Followers
	ElseIf(option == oCreatureFemaleFollowerPlayer)
		bCrFFolAssPl = !bCrFFolAssPl
		SetToggleOptionValue(oCreatureFemaleFollowerPlayer, bCrFFolAssPl)
	ElseIf(option == oCreatureFemaleFollowerFollower)
		bCrFFolAssFol = !bCrFFolAssFol
		SetToggleOptionValue(oCreatureFemaleFollowerFollower, bCrFFolAssFol)
	ElseIf(option == oCreatureFemaleFollowerMale)
		bCrFFolAssMal = !bCrFFolAssMal
		SetToggleOptionValue(oCreatureFemaleFollowerMale, bCrFFolAssMal)
	ElseIf(option == oCreatureFemaleFollowerFemale)
		bCrFFolAssFem = !bCrFFolAssFem
		SetToggleOptionValue(oCreatureFemaleFollowerFemale, bCrFFolAssFem)
	ElseIf(option == oCreatureFemaleFollowerFuta)
		bCrFFolAssFut = !bCrFFolAssFut
		SetToggleOptionValue(oCreatureFemaleFollowerFuta, bCrFFolAssFut)
	ElseIf(option == oCreatureFemaleFollowerCreatureMale)
		bCrFFolAssCrM = !bCrFFolAssCrM
		SetToggleOptionValue(oCreatureFemaleFollowerCreatureMale, bCrFFolAssCrM)
	ElseIf(option == oCreatureFemaleFollowerCreatureFemale)
		bCrFFolAssCrF = !bCrFFolAssCrF
		SetToggleOptionValue(oCreatureFemaleFollowerCreatureFemale, bCrFFolAssCrF)
		; ======================== NPC/Creatures ========================
		; Male NPCs
	ElseIf(option == oMaleNPCPlayer)
		bAssMalPl = !bAssMalPl
		SetToggleOptionValue(oMaleNPCPlayer, bAssMalPl)
	ElseIf(option == oMaleNPCFollower)
		bAssMalFol = !bAssMalFol
		SetToggleOptionValue(oMaleNPCFollower, bAssMalFol)
	ElseIf(option == oMaleNPCMale)
		bAssMalMal = !bAssMalMal
		SetToggleOptionValue(oMaleNPCMale, bAssMalMal)
	ElseIf(option == oMaleNPCFemale)
		bAssMalFem = !bAssMalFem
		SetToggleOptionValue(oMaleNPCFemale, bAssMalFem)
	ElseIf(option == oMaleNPCFuta)
		bAssMalFut = !bAssMalFut
		SetToggleOptionValue(oMaleNPCFuta, bAssMalFut)
	ElseIf(option == oMaleNPCCreatureMale)
		bAssMalCreat = !bAssMalCreat
		SetToggleOptionValue(oMaleNPCCreatureMale, bAssMalCreat)
	ElseIf(option == oMaleNPCCreatureFemale)
		bAssMalFemCreat = !bAssMalFemCreat
		SetToggleOptionValue(oMaleNPCCreatureFemale, bAssMalFemCreat)
		; Female NPCs
	ElseIf(option == oFemaleNPCPlayer)
		bAssFemPl = !bAssFemPl
		SetToggleOptionValue(oFemaleNPCPlayer, bAssFemPl)
	ElseIf(option == oFemaleNPCFollower)
		bAssFemFol = !bAssFemFol
		SetToggleOptionValue(oFemaleNPCFollower, bAssFemFol)
	ElseIf(option == oFemaleNPCMale)
		bAssFemMal = !bAssFemMal
		SetToggleOptionValue(oFemaleNPCMale, bAssFemMal)
	ElseIf(option == oFemaleNPCFemale)
		bAssFemFem = !bAssFemFem
		SetToggleOptionValue(oFemaleNPCFemale, bAssFemFem)
	ElseIf(option == oFemaleNPCFuta)
		bAssFemFut = !bAssFemFut
		SetToggleOptionValue(oFemaleNPCFuta, bAssFemFut)
	ElseIf(option == oFemaleNPCCreatureMale)
		bAssFemCreat = !bAssFemCreat
		SetToggleOptionValue(oFemaleNPCCreatureMale, bAssFemCreat)
	ElseIf(option == oFemaleNPCCreatureFemale)
		bAssFemFemCreat = !bAssFemFemCreat
		SetToggleOptionValue(oFemaleNPCCreatureFemale, bAssFemFemCreat)
		; Futa NPCs
	ElseIf(option == oFutaNPCPlayer)
		bAssFutPl = !bAssFutPl
		SetToggleOptionValue(oFutaNPCPlayer, bAssFutPl)
	ElseIf(option == oFutaNPCFollower)
		bAssFutFol = !bAssFutFol
		SetToggleOptionValue(oFutaNPCFollower, bAssFutFol)
	ElseIf(option == oFutaNPCMale)
		bAssFutMal = !bAssFutMal
		SetToggleOptionValue(oFutaNPCMale, bAssFutMal)
	ElseIf(option == oFutaNPCFemale)
		bAssFutFem = !bAssFutFem
		SetToggleOptionValue(oFutaNPCFemale, bAssFutFem)
	ElseIf(option == oFutaNPCFuta)
		bAssFutFut = !bAssFutFut
		SetToggleOptionValue(oFutaNPCFuta, bAssFutFut)
	ElseIf(option == oFutaNPCCreatureMale)
		bAssFutCreat = !bAssFutCreat
		SetToggleOptionValue(oFutaNPCCreatureMale, bAssFutCreat)
	ElseIf(option == oFutaNPCCreatureFemale)
		bAssFutFemCreat = !bAssFutFemCreat
		SetToggleOptionValue(oFutaNPCCreatureFemale, bAssFutFemCreat)
		; (Male) Creatures
	ElseIf(option == oCreatureMaleNPCPlayer)
		bAssMalCrPl = !bAssMalCrPl
		SetToggleOptionValue(oCreatureMaleNPCPlayer, bAssMalCrPl)
	ElseIf(option == oCreatureMaleNPCFollower)
		bAssMalCrFol = !bAssMalCrFol
		SetToggleOptionValue(oCreatureMaleNPCFollower, bAssMalCrFol)
	ElseIf(option == oCreatureMaleNPCMale)
		bAssMalCrMal = !bAssMalCrMal
		SetToggleOptionValue(oCreatureMaleNPCMale, bAssMalCrMal)
	ElseIf(option == oCreatureMaleNPCFemale)
		bAssMalCrFem = !bAssMalCrFem
		SetToggleOptionValue(oCreatureMaleNPCFemale, bAssMalCrFem)
	ElseIf(option == oCreatureMaleNPCFuta)
		bAssMalCrFut = !bAssMalCrFut
		SetToggleOptionValue(oCreatureMaleNPCFuta, bAssMalCrFut)
	ElseIf(option == oCreatureMaleNPCCreatureMale)
		bAssMalCrCreat = !bAssMalCrCreat
		SetToggleOptionValue(oCreatureMaleNPCCreatureMale, bAssMalCrCreat)
	ElseIf(option == oCreatureMaleNPCCreatureFemale)
		bAssMalCrFemCreat = !bAssMalCrFemCreat
		SetToggleOptionValue(oCreatureMaleNPCCreatureFemale, bAssMalCrFemCreat)
		; Female Creatures
	ElseIf(option == oCreatureFemaleNPCPlayer)
		bAssFemCrPl = !bAssFemCrPl
		SetToggleOptionValue(oCreatureFemaleNPCPlayer, bAssFemCrPl)
	ElseIf(option == oCreatureFemaleNPCFollower)
		bAssFemCrFol = !bAssFemCrFol
		SetToggleOptionValue(oCreatureFemaleNPCFollower, bAssFemCrFol)
	ElseIf(option == oCreatureFemaleNPCMale)
		bAssFemCrMal = !bAssFemCrMal
		SetToggleOptionValue(oCreatureFemaleNPCMale, bAssFemCrMal)
	ElseIf(option == oCreatureFemaleNPCFemale)
		bAssFemCrFem = !bAssFemCrFem
		SetToggleOptionValue(oCreatureFemaleNPCFemale, bAssFemCrFem)
	ElseIf(option == oCreatureFemaleNPCFuta)
		bAssFemCrFut = !bAssFemCrFut
		SetToggleOptionValue(oCreatureFemaleNPCFuta, bAssFemCrFut)
	ElseIf(option == oCreatureFemaleNPCCreatureMale)
		bAssFemCrCreat = !bAssFemCrCreat
		SetToggleOptionValue(oCreatureFemaleNPCCreatureMale, bAssFemCrCreat)
	ElseIf(option == oCreatureFemaleNPCCreatureFemale)
		bAssFemCrFemCreat = !bAssFemCrFemCreat
		SetToggleOptionValue(oCreatureFemaleNPCCreatureFemale, bAssFemCrFemCreat)
	EndIf
EndEvent

Event OnOptionInputOpen(int option)
	If(option == o2PFemaleMale)
		SetInputDialogStartText(s2PFM)
	ElseIf(option == o2PMaleFemale)
		SetInputDialogStartText(s2PMF)
	ElseIf(option == o2PFemaleFemale)
		SetInputDialogStartText(s2PFF)
	ElseIf(option == o2PMaleMale)
		SetInputDialogStartText(s2PMM)
	ElseIf(option == o3PFemaleFirst)
		SetInputDialogStartText(s3PF)
	ElseIf(option == o3PMaleFirst)
		SetInputDialogStartText(s3PM)
	ElseIf(option == o4PFemaleFirst)
		SetInputDialogStartText(s4PM)
	ElseIf(option == o4PMaleFirst)
		SetInputDialogStartText(s4PF)
	ElseIf(option == o5PFemaleFirst)
		SetInputDialogStartText(s5PM)
	ElseIf(option == o5PMaleFirst)
		SetInputDialogStartText(s5PF)
	EndIf
EndEvent

Event OnOptionInputAccept(int option, string newString)
	If(option == o2PFemaleMale)
		s2PFM = newString
		SetInputOptionValue(o2PFemaleMale, s2PFM)
	ElseIf(option == o2PMaleFemale)
		s2PMF = newString
		SetInputOptionValue(o2PMaleFemale, s2PMF)
	ElseIf(option == o2PFemaleFemale)
		s2PFF = newString
		SetInputOptionValue(o2PFemaleFemale, s2PFF)
	ElseIf(option == o2PMaleMale)
		s2PMM = newString
		SetInputOptionValue(o2PMaleMale, s2PMM)
	ElseIf(option == o3PFemaleFirst)
		s3PF = newString
		SetInputOptionValue(o3PFemaleFirst, s3PF)
	ElseIf(option == o3PMaleFirst)
		s3PM = newString
		SetInputOptionValue(o3PMaleFirst, s3PM)
	ElseIf(option == o4PFemaleFirst)
		s4PM = newString
		SetInputOptionValue(o4PFemaleFirst, s4PM)
	ElseIf(option == o4PMaleFirst)
		s4PF = newString
		SetInputOptionValue(o4PMaleFirst, s4PF)
	ElseIf(option == o5PFemaleFirst)
		s5PM = newString
		SetInputOptionValue(o5PFemaleFirst, s5PM)
	ElseIf(option == o5PMaleFirst)
		s5PF = newString
		SetInputOptionValue(o5PMaleFirst, s5PF)
	EndIf
EndEvent

Event OnOptionMenuOpen(int option)
	If(option == oLocWild)
		SetMenuDialogStartIndex(iWildIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocCities)
		SetMenuDialogStartIndex(iCityIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocTowns)
		SetMenuDialogStartIndex(iTownIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocSettlement)
		SetMenuDialogStartIndex(iSettlementIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocPlayerHome)
		SetMenuDialogStartIndex(iPlayerHomeIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocInn)
		SetMenuDialogStartIndex(iInnIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocFriendlyLoc)
		SetMenuDialogStartIndex(iFriendLocIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocDragonLair)
		SetMenuDialogStartIndex(iDragonIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocNordicRuin)
		SetMenuDialogStartIndex(iNoridRuinIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocDwarvenRuin)
		SetMenuDialogStartIndex(iDwarvenRuinIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocCaves)
		SetMenuDialogStartIndex(iCavesIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocFalmerHive)
		SetMenuDialogStartIndex(iFalmerIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocFort)
		SetMenuDialogStartIndex(iFortIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocBanditCamp)
		SetMenuDialogStartIndex(iBanditIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocGiantCamp)
		SetMenuDialogStartIndex(iGiantIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocHagNest)
		SetMenuDialogStartIndex(iHagravenIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	ElseIf(option == oLocHostileLoc)
		SetMenuDialogStartIndex(iHostileLocIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ProfileList)
	EndIf
EndEvent

Event OnOptionMenuAccept(int option, int index)
	If(option == oLocWild)
		iWildIndex = index
		SetMenuOptionValue(oLocWild, ProfileList[iWildIndex])
	ElseIf(option == oLocCities)
		iCityIndex = index
		SetMenuOptionValueST(ProfileList[iCityIndex])
	ElseIf(option == oLocTowns)
		iTownIndex = index
		SetMenuOptionValueST(ProfileList[iTownIndex])
	ElseIf(option == oLocSettlement)
		iSettlementIndex = index
		SetMenuOptionValueST(ProfileList[iSettlementIndex])
	ElseIf(option == oLocPlayerHome)
		iPlayerHomeIndex = index
		SetMenuOptionValueST(ProfileList[iPlayerHomeIndex])
	ElseIf(option == oLocInn)
		iInnIndex = index
		SetMenuOptionValueST(ProfileList[iInnIndex])
	ElseIf(option == oLocFriendlyLoc)
		iFriendLocIndex = index
		SetMenuOptionValueST(ProfileList[iFriendLocIndex])
	ElseIf(option == oLocDragonLair)
		iDragonIndex = index
		SetMenuOptionValueST(ProfileList[iDragonIndex])
	ElseIf(option == oLocNordicRuin)
		iNoridRuinIndex = index
		SetMenuOptionValueST(ProfileList[iNoridRuinIndex])
	ElseIf(option == oLocDwarvenRuin)
		iDwarvenRuinIndex = index
		SetMenuOptionValueST(ProfileList[iDwarvenRuinIndex])
	ElseIf(option == oLocCaves)
		iCavesIndex = index
		SetMenuOptionValueST(ProfileList[iCavesIndex])
	ElseIf(option == oLocFalmerHive)
		iFalmerIndex = index
		SetMenuOptionValueST(ProfileList[iFalmerIndex])
	ElseIf(option == oLocFort)
		iFortIndex = index
		SetMenuOptionValueST(ProfileList[iFortIndex])
	ElseIf(option == oLocBanditCamp)
		iBanditIndex = index
		SetMenuOptionValueST(ProfileList[iBanditIndex])
	ElseIf(option == oLocGiantCamp)
		iGiantIndex = index
		SetMenuOptionValueST(ProfileList[iGiantIndex])
	ElseIf(option == oLocHagNest)
		iHagravenIndex = index
		SetMenuOptionValueST(ProfileList[iHagravenIndex])
	ElseIf(option == oLocHostileLoc)
		iHostileLocIndex = index
		SetMenuOptionValueST(ProfileList[iHostileLocIndex])
	EndIf
EndEvent
; ------------------------ Utility
; ----- Scan
int Function CheckFlag3p()
  If(iMaxActor < 3)
    return OPTION_FLAG_DISABLED
  else
    return OPTION_FLAG_NONE
  endIf
endFunction

int Function CheckFlag4p()
  If(iMaxActor < 4)
    return OPTION_FLAG_DISABLED
  Else
    return OPTION_FLAG_NONE
  endIf
endFunction

int Function CheckFlag5p()
  If(iMaxActor < 5)
    return OPTION_FLAG_DISABLED
  else
    return OPTION_FLAG_NONE
  EndIf
EndFunction

int Function getFlag(bool option, bool master = true)
	If(option && master)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
EndFunction

int Function getFlagOR(bool optionA, bool optionB, bool optionC = false)
	If(optionA || optionB || optionC)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
EndFunction
/;
