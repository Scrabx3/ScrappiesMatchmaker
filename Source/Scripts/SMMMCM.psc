Scriptname SMMMCM extends SKI_ConfigBase Conditional

SMMPlayer Property PlayerScr Auto
; ----------------------- Variables
String[] classColors
; ---- General
; Scan
bool Property bPaused = true Auto Hidden
int Property iPauseKey = -1 Auto Hidden
int Property iTickInterval = 20 Auto Hidden
GlobalVariable Property gScanRadius Auto
int Property iMaxScenes = 1 Auto Hidden
; Day Time
float Property fDuskTime = 19.00 Auto Hidden
float Property fDawnTime = 5.00 Auto Hidden
; Miscealleneous
float Property fEngageCooldown = 6.0 Auto Hidden
bool Property bNotifyAF = false Auto Hidden
bool Property bNotifyColor = false Auto Hidden
int iNotifyColor = 0xFF0000
string Property sNotifyColor = "#FF0000" Auto Hidden
; ---- Locations
String[] Property lProfiles Auto Hidden

; ---- Profiles
; Use JContainer to handle Profiles.. Most variables will be stored in .jsons
String filePath = "Data\\SKSE\\SMM\\"
String[] smmProfiles
int smmProfileIndex
;
String[] lConsiderList
String[] lConsiderListCrt
String[] lIncestList
String[] lAdvancedInitList
String[] lReqList

; --- Threading
int Property iResMaxRounds = 4 Auto Hidden
float Property fResNextRoundChance = 15.0 Auto Hidden
float Property fAddActorChance = 50.0 Auto Hidden

int Property iStalkTime = 20 Auto Hidden
bool Property bStalkNotify = false Auto Hidden
bool Property bStalkNotifyName = false Auto Hidden

float Property fSpecChance = 82.0 Auto Hidden
bool Property bSpecGender = false Auto Hidden
bool Property bSpecCrt = false Auto Hidden

; --- Adult Frames
bool Property bSLAllowed = true Auto Hidden Conditional
bool Property bOStimAllowed = true Auto Hidden Conditional
bool Property bCrtOnly = false Auto Hidden
; SexLab
bool Property bBestiality = false Auto Hidden
bool Property bSupportFilter = false Auto Hidden
String[] Property SLTags Auto Hidden
{F<-M // M<-M // M<-F // F<-F // M<-* // F<-*}
; 3p+ Weights
float Property fAFMasturbateFol = 0.0 Auto Hidden
float Property fAFMasturbateNPC = 10.0 Auto Hidden
int[] Property iSceneTypeWeight Auto Hidden
; Utility
bool Property FrameCreature
	bool Function Get()
		return bSLAllowed
	EndFunction
EndProperty
bool Property FrameAny
	bool Function Get()
		return bSLAllowed || bOStimAllowed
	EndFunction
EndProperty

; --- Filterr
bool[] Property bAssaultNPC Auto Hidden
bool[] Property bAssaultFol Auto Hidden

; --- Filter Creature
string[] crtFilterMethodList
int Property iCrtFilterMethod = 0 Auto Hidden
bool[] Property bValidRace Auto Hidden

; ===============================================================
; =============================  STARTUP // UTILITY
; ===============================================================
int Function GetVersion()
  return 3
EndFunction

Event OnVersionUpdate(int newVers)
  OnConfigInit()
EndEvent

Event OnConfigInit()
  Pages = new string[7]
  Pages[0] = "$SMM_General"
  Pages[1] = "$SMM_Locs"
  Pages[2] = "$SMM_Profiles"
  Pages[3] = "$SMM_Threading"
  Pages[4] = "$SMM_AnimFrame"
  Pages[5] = "$SMM_Filter"
  Pages[6] = "$SMM_FilterCrt"

  ; Colors
  classColors = new String[8]
  classColors[0] = "<font color = '#ffff00'>" ; Player - Yellow
  classColors[1] = "<font color = '#00c707'>" ; Follower - Green
  classColors[2] = "<font color = '#f536ff'>"  ; NPC - Magnetta
  ; - Profiling
  classColors[3] = "<font color = '#db4040'>" ; Base Chance - Light Red
  classColors[4] = "<font color = '#cfdfff'>" ; System/Consideration - White Blue
  classColors[5] = "<font color = '#d6c13a'>" ; Initiator - Yellow
  classColors[6] = "<font color = '#de8f28'>" ; Partner - Orange
  classColors[7] = "<font color = '#4121c2'>" ; Matching - Blue Purple

  lConsiderList = new String[3]
  lConsiderList[0] = "$SMM_considerEither" ; Either
  lConsiderList[1] = "$SMM_considerFriendly" ; Friendly Only
  lConsiderList[2] = "$SMM_considerHostile" ; Hostile Only

  lConsiderListCrt = new String[3]
  lConsiderListCrt[0] = "$SMM_considerEither" ; Either
  lConsiderListCrt[1] = "$SMM_considerHuman" ; Human only
  lConsiderListCrt[2] = "$SMM_considerCreature" ; Creature only

  lIncestList = new String[3]
  lIncestList[0] = "$SMM_Incest_0" ; Disable
  lIncestList[1] = "$SMM_Incest_1" ; No Parental
  lIncestList[2] = "$SMM_Incest_2" ; Anything

  lAdvancedInitList = new String[3]
  lAdvancedInitList[0] = "$SMM_AdvInit_0" ; No Conditioning
  lAdvancedInitList[1] = "$SMM_AdvInit_1" ; Chance
  lAdvancedInitList[2] = "$SMM_AdvInit_2" ; Points

  lReqList = new String[9]
  lReqList[0] = "$SMM_RequirementList_0" ; Overwrite
  lReqList[1] = "$SMM_RequirementList_1" ; Mandatory
  lReqList[2] = "$SMM_RequirementList_2" ; +3
  lReqList[3] = "$SMM_RequirementList_3" ; +2
  lReqList[4] = "$SMM_RequirementList_4" ; +1
  lReqList[5] = "$SMM_RequirementList_5" ; Ignore
  lReqList[6] = "$SMM_RequirementList_6" ; -1
  lReqList[7] = "$SMM_RequirementList_7" ; -2
  lReqList[8] = "$SMM_RequirementList_8" ; -3

  crtFilterMethodList = new string[4]
	crtFilterMethodList[0] = "$SMM_scrFilterMethod_0" ; All Creatures
	crtFilterMethodList[1] = "$SMM_scrFilterMethod_1" ; No Creatures
	crtFilterMethodList[2] = "$SMM_scrFilterMethod_2" ; Use List
	crtFilterMethodList[3] = "$SMM_scrFilterMethod_3" ; Use List Reverse

  lProfiles = Utility.CreateStringArray(28, "$SMM_Disabled")
  bAssaultNPC = Utility.CreateBoolArray(35)
  bAssaultFol = Utility.CreateBoolArray(35)
  int i = 0
  While(i < bAssaultNPC.Length)
    If(i % 7 == 2 || i % 7 == 3)
      bAssaultNPC[i] = true
      bAssaultFol[i] = true
    EndIf
    i += 1
  EndWhile

  iSceneTypeWeight = new int[4]
  iSceneTypeWeight[0] = 75 
  iSceneTypeWeight[1] = 60
  iSceneTypeWeight[2] = 35
  iSceneTypeWeight[3] = 20
  SLTags = new String[6]
  bValidRace = new bool[52]
EndEvent

; ===============================================================
; =============================  MENU
; ===============================================================
int jProfile = 0

Event OnPageReset(string Page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If(Page == "")
    Page = "$SMM_General"
  ELseIf(jProfile != 0)
    SaveJson()
  EndIf
  If(Page == "$SMM_General")
    AddHeaderOption("$SMM_Scan")
    AddToggleOptionST("Enabled", "$SMM_Enabled", !bPaused)
    AddKeyMapOptionST("PauseKey", "$SMM_PauseHotkey", iPauseKey)
    AddSliderOptionST("TickInterval", "$SMM_Interval", iTickInterval, "{0}s")
    AddSliderOptionST("ScanRadius", "$SMM_ScanRadius", gScanRadius.Value/70, "{0}m")
    AddSliderOptionST("ScenesPerScan", "$SMM_ScenesPerScan", iMaxScenes, "{0}")
    SetCursorPosition(1)
    AddHeaderOption("$SMM_DayTime")
    AddSliderOptionST("DefDuskTime", "$SMM_DuskTime", fDuskTime, "{1}0")
    AddSliderOptionST("DefDawnTime", "$SMM_DawnTime", fDawnTime, "{1}0")
    AddHeaderOption("$SMM_Misc")
    AddSliderOptionST("EngageCooldown", "$SMM_EngageCooldown", fEngageCooldown, "{1}h")
		AddToggleOptionST("afNotify", "$SMM_EngageNotify", bNotifyAF)
		AddToggleOptionST("notifycolored", "$SMM_EngageNotifyColor", bNotifyColor, getFlag(bNotifyAF))
    AddColorOptionST("notifycolorchoice", "$SMM_EngageNofityColorChoice", iNotifyColor, getFlag(bNotifyAF && bNotifyColor))
    SetCursorPosition(17) ; 23 is bottom right without scrolling
    AddHeaderOption("$SMM_Debug")
    AddTextOptionST("shutdownThreads", "$SMM_ShutDown", "")
    AddTextOptionST("savemcm", "$SMM_Save", "")
    AddTextOptionST("loadmcm", "$SMM_Load", "")

  ElseIf(Page == "$SMM_Locs")
    CreateMenuProfiles(1)
    SetCursorFillMode(LEFT_TO_RIGHT)
    AddMenuOptionST("ApplyLocProfile", "$SMM_ApplyLocProfile", "")
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
    AddEmptyOption()
    ; AddTextOptionST("ProfilesHelp", "$SMM_Help", none)
    AddTextOptionST("ProfileDefinition", "$SMM_Definition", none)
    SetCursorPosition(4)
    If(thisProfile == "")
      AddEmptyOption()
      AddTextOption("$SMM_NoProfileError", "", OPTION_FLAG_DISABLED)
      return
    EndIf
    ; ======================== SYSTEM
    AddHeaderOption(classColors[4] + "$SMM_System")
    AddToggleOptionST("combatSkip", "$SMM_combatSkip", JMap.getInt(jProfile, "bCombatSkip"))
    AddSliderOptionST("EngageChance", "$SMM_EngageChance", JMap.getFlt(jProfile, "fEngageChance"), "{1}%")
    AddSliderOptionST("EngageTimeMax", "$SMM_EngageTimeMax", JMap.getFlt(jProfile, "fEngageTimeMax"), "{2}")
    AddSliderOptionST("EngageTimeMin", "$SMM_EngageTimeMin", JMap.getFlt(jProfile, "fEngageTimeMin"), "{2}")
    SetCursorPosition(5)
    ; ======================== CONSIDERATION
    AddHeaderOption(classColors[4] + "$SMM_Consideration")
    AddMenuOptionST("consider", "$SMM_Consider", lConsiderList[JMap.getInt(jProfile, "lConsider")])
    AddMenuOptionST("considerCrt", "$SMM_ConsiderCrt", lConsiderListCrt[JMap.getInt(jProfile, "lConsiderCreature")])
    AddToggleOptionST("considerFollower", "$SMM_ConsiderFollower", JMap.getInt(jProfile, "bConsiderFollowers"))
    AddEmptyOption()
    AddEmptyOption()
    SetCursorPosition(14)
    ; ======================== INITIATOR
    AddHeaderOption(classColors[5] + "$SMM_Initiator")
    int aca = JMap.getInt(jProfile, "lAdvInit")
    AddSliderOptionST("ArousalInit", "$SMM_Arousal", JMap.getInt(jProfile, "iArousalInit"), "{0}")
    AddSliderOptionST("ArousalInitPl", "$SMM_ArousalPl", JMap.getInt(jProfile, "iArousalInitPl"), "{0}")
    AddSliderOptionST("ArousalInitFol", "$SMM_ArousalFol", JMap.getInt(jProfile, "iArousalInitFol"), "{0}")
    AddEmptyOption()
    AddSliderOptionST("InitHealth", "$SMM_HealthThresh", JMap.getInt(jProfile, "rHealthThresh") * 100, "{0}%", getFlag(aca > 0))
    AddSliderOptionST("InitStamina", "$SMM_StaminaThresh", JMap.getInt(jProfile, "rStaminaThresh") * 100, "{0}%", getFlag(aca > 0))
    AddSliderOptionST("InitMagicka", "$SMM_MagickaThresh", JMap.getInt(jProfile, "rMagickaThresh") * 100, "{0}%", getFlag(aca > 0))
    SetCursorPosition(15)
    AddHeaderOption("")
    AddSliderOptionST("PlayerInit", "$SMM_PlayerInitiator", JMap.getInt(jProfile, "fPlayerInit"), "{1}%")
    int jTmp = JMap.getObj(jProfile, "bGenderInit")
    int i = 0
    While(i < JArray.count(jTmp))
      If((i != 3 || bSupportFilter) && (i != 4 || bBestiality) && (i != 5 || bSupportFilter && bBestiality))
        AddToggleOptionST("GenderInit_" + i, "$SMM_GenderAllow_" + i, JArray.getInt(jTmp, i))
      EndIf
      i += 1
    EndWhile
    SetCursorPosition(30)
    ; ---------------------------
    AddHeaderOption("$SMM_ReqConditioning")
    AddMenuOptionST("AdvConAlg", "$SMM_AdvConAlg", lAdvancedInitList[aca])
    i = 0
    If(aca == 2) ; Points
      AddSliderOptionST("ReqPointsBase", classColors[3] + "$SMM_ReqPoints</color>", JMap.getInt(jProfile, "iReqPoints"), "{0}")
      int[] c = SMMUtility.asJIntArray(JMap.getObj(jProfile, "reqAPoints"))
      While(i < c.Length)
        AddMenuOptionST("reqPoints_" + i, "$SMM_AdvCon_" + i, lReqList[c[i]])
        If(i == 6)
          SetCursorPosition(35)
          AddTextOptionST("AdvCondition", "$SMM_Help", none)
        EndIf
        i += 1
      EndWhile
    Else ; Chance (or none)
      AddSliderOptionST("chanceBase", classColors[3] + "$SMM_BaseChance", JMap.getInt(jProfile, "cBaseChance"), "{1}%", getFlag(aca == 1))
      int[] c = SMMUtility.asJIntArray(JMap.getObj(jProfile, "cAChances"))
      While(i < c.Length)
        AddSliderOptionST("aChances_" + i, "$SMM_AdvCon_" + i, c[i], "{1}%", getFlag(aca == 1))
        If(i == 6)
          SetCursorPosition(35)
          AddTextOptionST("AdvCondition", "$SMM_Help", none)
        EndIf
        i += 1
      EndWhile
    EndIf
    SetCursorPosition(50)
    ; ======================== PARTNER
    AddHeaderOption(classColors[6] + "$SMM_Partner")
    AddSliderOptionST("ArousalPartner", "$SMM_Arousal", JMap.getInt(jProfile, "iArousalPartner"), "{0}")
    AddSliderOptionST("ArousalPartnerFol", "$SMM_ArousalFol", JMap.getInt(jProfile, "iArousalPartnerFol"), "{0}")
    jTmp = JMap.getObj(jProfile, "bGenderPartner")
    i = 0
    While(i < JArray.count(jTmp) - 1)
      If((i != 3 || bSupportFilter) && (i != 4 || bBestiality) && (i != 5 || bSupportFilter && bBestiality))
        AddToggleOptionST("GenderPartner_" + i, "$SMM_GenderAllow_" + i, JArray.getInt(jTmp, i))
      EndIf
      i += 1
    EndWhile
    AddSliderOptionST("GenderPartner_" + i, "$SMM_GenderAllow_" + i, JArray.getInt(jTmp, i), "{1}%")
    SetCursorPosition(51)
    ; ======================== MATCHING
    AddHeaderOption(classColors[7] + "$SMM_Matching")
    AddToggleOptionST("NonConsent", "$SMM_NonConsent", JMap.getInt(jProfile, "bConsent"))
    AddSliderOptionST("Distance", "$SMM_Distance", JMap.getInt(jProfile, "fDistance"), "{1}m")
    AddToggleOptionST("LineOfSight", "$SMM_LineOfSight", JMap.getInt(jProfile, "bLOS"))
    AddSliderOptionST("Disposition", "$SMM_Disposition", JMap.getInt(jProfile, "iDisposition"), "{0}")
    AddMenuOptionST("Incest", "$SMM_Incest", lIncestList[JMap.getInt(jProfile, "lIncest")])

  ElseIf(Page == "$SMM_Threading")
    AddHeaderOption("$SMM_Threading")
    AddSliderOptionST("TMaxRounds", "$SMM_TMaxRounds", iResMaxRounds, "{0}")
    AddSliderOptionST("TNextRound", "$SMM_TNextRound", fResNextRoundChance, "{1}%")
    AddSliderOptionST("TAddActor", "$SMM_TAddActor", fAddActorChance, "{1}%")
    AddHeaderOption("$SMM_PlayerThread")
    AddSliderOptionST("TStalkTime", "$SMM_TStalkTime", iStalkTime, "{0}s")
    AddToggleOptionST("TStalkNotify", "$SMM_TStalkNotify", bStalkNotify)
    AddToggleOptionST("TStalkNotifyName", "$SMM_TStalkNotifyName", bStalkNotifyName, getFlag(bStalkNotify))
    
    SetCursorPosition(1)
    AddHeaderOption("$SMM_Spectators")
    AddSliderOptionST("SpecChance", "$SMM_SpectatorChance", fSpecChance, "{1}%")
    AddToggleOptionST("SpecGender", "$SMM_SpectatorGender", bSpecGender)
    AddToggleOptionST("SpecCrt", "$SMM_SpectatorCreature", bSpecCrt)

	ElseIf(Page == "$SMM_AnimFrame")
		bool SLThere = Game.GetModByName("SexLab.esm") != 255
		bool OStimThere = Game.GetModByName("OStim.esp") != 255
		AddHeaderOption("$SMM_afFramesLoaded")
		AddToggleOptionST("SLAllowed", "$SMM_afFrameSexLab", bSLAllowed, getFlag(SLThere))
		AddToggleOptionST("OStimAllowed", "$SMM_afFrameOStim", bOStimAllowed, getFlag(OStimThere))
		AddEmptyOption()
		AddToggleOptionST("SLCrtOnly", "$SMM_afFrameSexLabCrtOnly", bCrtOnly, getFlag(SLThere && OStimThere))
		AddHeaderOption("$SMM_Solo")
		AddSliderOptionST("af1pWeightFol", "$SMM_af1pWeightFol", fAFMasturbateFol, "{0}%")
		AddSliderOptionST("af1pWeightNPC", "$SMM_af1pWeightNPC", fAFMasturbateNPC, "{0}%")
    AddEmptyOption()
    AddHeaderOption("$SMM_SceneTypes")
    int n = 0
    While(n < iSceneTypeWeight.Length)
      AddSliderOptionST("scenetype_" + n, "$SMM_SceneType_" + n, iSceneTypeWeight[n], "{0}", getFlag(SLThere || OStimThere))
      n += 1
    EndWhile
		; ===============================================
		SetCursorPosition(1)
		AddToggleOptionST("SLSupportFilter", "$SMM_SLFilterOption", bSupportFilter, getFlag(SLThere))
		AddHeaderOption("$SMM_afFrameSexLab")
		AddTextOptionST("SLTaggingReadMe", "", "$SMM_Help", getFlag(SLThere))
		AddToggleOptionST("SupBestiality", "$SMM_SupBestiality", bBestiality, getFlag(SLThere))
		int i = 0
		While(i < SLTags.length)
			AddInputOptionST("SLTag_" + i, "$SMM_SLTags_" + i, SLTags[i], getFlag(SLThere))
			i += 1
		EndWhile

  ElseIf(Page == "$SMM_Filter")
    int i = 0
    While(i < 5)
      AddHeaderOption(classColors[2] + "$SMM_filterNPC_" + i)
      ; Male, Female, Futa, Creature, Fem Creature
      int n = 0
      While(n < 7)
        ; Player, Follower, Male, Female, Futa, Creature, Fem Creature
        int j = i * 7 + n
        If((n != 4 || bSupportFilter) && (n != 5 || bBestiality) && (n != 6 || bSupportFilter && bBestiality))
          AddToggleOptionST("filterNPC_" + j, "$SMM_FilterClass_" + n, bAssaultNPC[j])
        EndIf
        n += 1
      EndWhile
      i += 1
    EndWhile
    SetCursorPosition(1)
    i = 0
    While(i < 5)
      AddHeaderOption(classColors[1] + "$SMM_filterFollower_" + i)
      ; Male, Female, Futa, Creature, Fem Creature
      int n = 0
      While(n < 7)
        ; Player, Follower, Male, Female, Futa, Creature, Fem Creature
        int j = i * 7 + n
        If((n != 4 || bSupportFilter) && (n != 5 || bBestiality) && (n != 6 || bSupportFilter && bBestiality))
          AddToggleOptionST("filterFol_" + j, "$SMM_FilterClass_" + n, bAssaultFol[j])
        EndIf
        n += 1
      EndWhile
      i += 1
    EndWhile

  ElseIf(Page == "$SMM_FilterCrt")
		SetCursorFillMode(LEFT_TO_RIGHT)
		AddTextOptionST("crtFilterReadMe", "$SMM_Help", "")
		AddMenuOptionST("crtFilterMethod", "$SMM_scrFilterMethod", crtFilterMethodList[iCrtFilterMethod])
		AddHeaderOption("")
		AddHeaderOption("")
		int i = 0
		While(i < 52)
			AddToggleOptionST("creatureFilter_" + i, "$SMM_crtFilter_Creature_" + i, bValidRace[i])
			i += 1
		EndWhile

  EndIf
endEvent

Event OnConfigClose()
  If(jProfile != 0)
    SaveJson()
  EndIf
  JValue.releaseObjectsWithTag("SMM")
EndEvent

; ===============================================================
; =============================  SELECTION STATES
; ===============================================================
Event OnSelectST()
  String[] option = PapyrusUtil.StringSplit(GetState(), "_")
  If(option[0] == "shutdownThreads") ; General/Debug
    Quest.GetQuest("SMM_ThreadPlayer").Stop()
    int i = 0
    While(i < 10)
      Quest.GetQuest("SMM_Thread0" + i).Stop()
      i += 1
    EndWhile
    ShowMessage("$SMM_shutdownThreadsDone", false, "$SMM_Ok")
  ElseIf(option[0] == "afNotify")
    bNotifyAF = !bNotifyAF
		SetToggleOptionValueST(bNotifyAF)
		SetOptionFlagsST(getFlag(bNotifyAF), true, "notifycolored")
		SetOptionFlagsST(getFlag(bNotifyAF && bNotifyColor), false, "notifycolorchoice")
  ElseIf(option[0] == "notifycolored")
		bNotifyColor = !bNotifyColor
		SetToggleOptionValueST(bNotifyColor)
		SetOptionFlagsST(getFlag(bNotifyAF && bNotifyColor), false, "notifycolorchoice")
  ElseIf(option[0] == "savemcm")
    SaveMCM()
    ShowMessage("$SMM_Done", false, "$SMM_Ok")
  ElseIf(option[0] == "loadmcm")
    LoadMCM()
    ShowMessage("$SMM_Done", false, "$SMM_Ok")
    ForcePageReset()

  ElseIf(option[0] == "considerFollower")  ; Profiles
    int val = JMap.getInt(jProfile, "bConsiderFollowers")
    JMap.setInt(jProfile, "bConsiderFollowers", Math.abs(val - 1) as int)
    SetToggleOptionValueST(JMap.getInt(jProfile, "bConsiderFollowers"))
  ElseIf(option[0] == "GenderInit")
    int jTmp = JMap.getObj(jProfile, "bGenderInit") 
    int i = option[1] as int
    JArray.setInt(jTmp, i, Math.abs(JArray.getInt(jTmp, i) - 1) as int)
    JMap.setObj(jProfile, "bGenderInit", jTmp)
    SetToggleOptionValueST(JArray.getInt(jTmp, i))
  ElseIf(option[0] == "GenderPartner")
    int jTmp = JMap.getObj(jProfile, "bGenderPartner") 
    int i = option[1] as int
    JArray.setInt(jTmp, i, Math.abs(JArray.getInt(jTmp, i) - 1) as int)
    JMap.setObj(jProfile, "bGenderPartner", jTmp)
    SetToggleOptionValueST(JArray.getInt(jTmp, i))
  ElseIf(option[0] == "combatSkip")
    int val = JMap.getInt(jProfile, "bCombatSkip")
    JMap.setInt(jProfile, "bCombatSkip", Math.abs(val - 1) as int)
    SetToggleOptionValueST(JMap.getInt(jProfile, "bCombatSkip"))
  ElseIf(option[0] == "NonConsent")
    int val = JMap.getInt(jProfile, "bConsent")
    JMap.setInt(jProfile, "bConsent", Math.abs(val - 1) as int)
    SetToggleOptionValueST(JMap.getInt(jProfile, "bConsent"))
  ElseIf(option[0] == "LineOfSight")
    int val = JMap.getInt(jProfile, "bLOS")
    JMap.setInt(jProfile, "bLOS", Math.abs(val - 1) as int)
    SetToggleOptionValueST(JMap.getInt(jProfile, "bLOS"))

  ElseIf(option[0] == "TStalkNotify") ; Threading
    bStalkNotify = !bStalkNotify
    SetToggleOptionValueST(bStalkNotify)
    SetOptionFlagsST(getFlag(bStalkNotify), a_stateName = "TStalkNotifyName")
  ElseIf(option[0] == "TStalkNotifyName")
    bStalkNotifyName = !bStalkNotifyName
    SetToggleOptionValueST(bStalkNotifyName)
	ElseIf(option[0] == "SpecGender")
		bSpecGender = !bSpecGender
		SetToggleOptionValueST(bSpecGender)
	ElseIf(option[0] == "SpecCrt")
		bSpecCrt = !bSpecCrt
		SetToggleOptionValueST(bSpecCrt)

	ElseIf(option[0] == "SLSupportFilter") ; Adult Frames
		bSupportFilter = !bSupportFilter
		SetToggleOptionValueST(bSupportFilter)
  ElseIf(option[0] == "SupBestiality")
    bBestiality = !bBestiality
    SetToggleOptionValueST(bBestiality)
	ElseIf(option[0] == "SLAllowed")
		bSLAllowed = !bSLAllowed
		SetToggleOptionValueST(bSLAllowed)
	ElseIf(option[0] == "OStimAllowed")
		bOStimAllowed = !bOStimAllowed
		SetToggleOptionValueST(bOStimAllowed)
  ElseIf(option[0] == "SLCrtOnly")
    bCrtOnly = !bCrtOnly
    SetToggleOptionValueST(bCrtOnly)

  ElseIf(option[0] == "filterNPC") ; Filter
    int i = option[1] as int
		bAssaultNPC[i] = !bAssaultNPC[i]
		SetToggleOptionValueST(bAssaultNPC[i])
  ElseIf(option[0] == "filterFol")
    int i = option[1] as int
    bAssaultFol[i] = !bAssaultFol[i]
    SetToggleOptionValueST(bAssaultFol[i])

  ElseIf(option[0] == "creatureFilter") ; Creature Filter
		int i = option[1] as int
		bValidRace[i] = !bValidRace[i]
		SetToggleOptionValueST(bValidRace[i])

  ElseIf(option[0] == "locProfileHelp")
    ShowMessage("$SMM_ProfileHelp", false, "$SMM_Ok")
  ElseIf(option[0] == "AdvCondition")
    ShowMessage("$SMM_ReqConditioningHelp0", false, "$SMM_Ok")
  ElseIf(option[0] == "ProfileDefinition")
    ShowMessage("$SMM_DefinitionHelp", false, "$SMM_Ok")
  ElseIf(option[0] == "crtFilterReadMe")
    ShowMessage("$SMM_crtFilterReadMe", false, "$SMM_Ok")
  ElseIf(option[0] == "SLTaggingReadMe")
    ShowMessage("$SMM_SLTagsReadMe", false, "$SMM_Ok")
  EndIf
EndEvent

; ===============================================================
; =============================  SLIDER STATES
; ===============================================================
Event OnSliderOpenST()
  String[] option = PapyrusUtil.StringSplit(GetState(), "_")
  If(option[0] == "TickInterval") ; General
    SetSliderDialogStartValue(iTickInterval)
    SetSliderDialogDefaultValue(20)
    SetSliderDialogRange(5, 300)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "ScenesPerScan")
    SetSliderDialogStartValue(iMaxScenes)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(1, 5)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "ScanRadius")
    SetSliderDialogStartValue(gScanRadius.Value/70)
    SetSliderDialogDefaultValue(110)
    SetSliderDialogRange(60, 150)
    SetSliderDialogInterval(0.1)
  ElseIf(option[0] == "DefDuskTime")
    SetSliderDialogStartValue(fDuskTime)
    SetSliderDialogDefaultValue(19.0)
    SetSliderDialogRange(18, 22)
    SetSliderDialogInterval(0.5)
  ElseIf(option[0] == "DefDawnTime")
    SetSliderDialogStartValue(fDawnTime)
    SetSliderDialogDefaultValue(5.0)
    SetSliderDialogRange(4, 8)
    SetSliderDialogInterval(0.5)
  ElseIf(option[0] == "EngageCooldown")
    SetSliderDialogStartValue(fEngageCooldown)
    SetSliderDialogDefaultValue(70)
    SetSliderDialogRange(0, 48)
    SetSliderDialogInterval(0.5)

  ElseIf(option[0] == "ArousalInit") ; Profile
    SetSliderDialogStartValue(JMap.getInt(jProfile, "iArousalInit"))
    SetSliderDialogDefaultValue(60)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "ArousalInitPl")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "iArousalInitPl"))
    SetSliderDialogDefaultValue(75)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "ArousalInitFol")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "iArousalInitFol"))
    SetSliderDialogDefaultValue(75)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "PlayerInit")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "fPlayerInit"))
    SetSliderDialogDefaultValue(5)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(0.1)    
  ElseIf(option[0] == "ArousalPartner")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "iArousalPartner"))
    SetSliderDialogDefaultValue(40)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "ArousalPartnerFol")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "iArousalPartnerFol"))
    SetSliderDialogDefaultValue(70)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "EngageChance")
    SetSliderDialogStartValue(JMap.getFlt(jProfile, "fEngageChance"))
    SetSliderDialogDefaultValue(60)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(0.1)
  ElseIf(option[0] == "EngageTimeMin")
    SetSliderDialogStartValue(JMap.getFlt(jProfile, "fEngageTimeMin"))
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 24)
    SetSliderDialogInterval(0.05)
  ElseIf(option[0] == "EngageTimeMax")
    SetSliderDialogStartValue(JMap.getFlt(jProfile, "fEngageTimeMax"))
    SetSliderDialogDefaultValue(70)
    SetSliderDialogRange(0, 24)
    SetSliderDialogInterval(0.05)
  ElseIf(option[0] == "Distance")
    SetSliderDialogStartValue(JMap.getFlt(jProfile, "fDistance"))
    SetSliderDialogDefaultValue(60)
    SetSliderDialogRange(30, 250)
    SetSliderDialogInterval(0.1)
  ElseIf(option[0] == "Disposition")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "iDisposition"))
    SetSliderDialogDefaultValue(-2)
    SetSliderDialogRange(-2, 4)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "ReqPointsBase")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "iReqPoints"))
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 15)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "chanceBase")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "cBaseChance"))
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "aChances")
    int i = option[1] as int
    int[] c = SMMUtility.asJIntArray(JMap.getObj(jProfile, "cAChances"))
    SetSliderDialogStartValue(c[i])
    SetSliderDialogDefaultValue(0)
    SetSliderDialogRange(-100, 100)
    SetSliderDialogInterval(0.5)
  ElseIf(option[0] == "InitHealth")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "rHealthThresh"))
    SetSliderDialogDefaultValue(60)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "InitStamina")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "rStaminaThresh"))
    SetSliderDialogDefaultValue(40)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "InitMagicka")
    SetSliderDialogStartValue(JMap.getInt(jProfile, "rMagickaThresh"))
    SetSliderDialogDefaultValue(40)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "GenderPartner")
    int i = option[1] as int
    SetSliderDialogStartValue(JArray.getInt(JMap.getObj(jProfile, "bGenderPartner"), i))
    SetSliderDialogDefaultValue(40)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "TMaxRounds") ; Threading
    SetSliderDialogStartValue(iResMaxRounds)
    SetSliderDialogDefaultValue(4)
    SetSliderDialogRange(0, 30)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "TNextRound")
    SetSliderDialogStartValue(fResNextRoundChance)
    SetSliderDialogDefaultValue(15)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(0.1)
  ElseIf(option[0] == "TAddActor")
    SetSliderDialogStartValue(fAddActorChance)
    SetSliderDialogDefaultValue(50)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(0.1)
  ElseIf(option[0] == "TStalkTime")
    SetSliderDialogStartValue(iStalkTime)
    SetSliderDialogDefaultValue(20)
    SetSliderDialogRange(0, 180)
    SetSliderDialogInterval(1)
  ElseIf(option[0] == "SpecChance")
    SetSliderDialogStartValue(fSpecChance)
    SetSliderDialogDefaultValue(82)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(0.1)

	ElseIf(option[0] == "scenetype")  ; Animation Frame
    int i = option[1] as int
		SetSliderDialogStartValue(iSceneTypeWeight[i])
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)   
	ElseIf(option[0] == "af1pWeightFol")
		SetSliderDialogStartValue(fAFMasturbateFol)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(option[0] == "af1pWeightNPC")
		SetSliderDialogStartValue(fAFMasturbateNPC)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
  EndIf
EndEvent

Event OnSliderAcceptST(Float afValue)
  String[] option = PapyrusUtil.StringSplit(GetState(), "_")
  If(option[0] == "TickInterval") ; General
    iTickInterval = afValue as Int
    SetSliderOptionValueST(iTickInterval, "{0}s")
  ElseIf(option[0] == "ScenesPerScan")
    iMaxScenes = afValue as Int
    SetSliderOptionValueST(iMaxScenes, "{0}")
  ElseIf(option[0] == "ScanRadius")
    gScanRadius.Value = afValue * 70
    SetSliderOptionValueST(gScanRadius.Value/70, "{0}m")
  ElseIf(option[0] == "DefDuskTime")
    fDuskTime = afValue as Int
    SetSliderOptionValueST(fDuskTime, "{1}0")
  ElseIf(option[0] == "DefDawnTime")
    fDawnTime = afValue as Int
    SetSliderOptionValueST(fDawnTime, "{1}0")
  ElseIf(option[0] == "EngageCooldown")
    fEngageCooldown = afValue
    SetSliderOptionValueST(afValue, "{1}h")
    
  ElseIf(option[0] == "ArousalInit") ; Profile
    JMap.setInt(jProfile, "iArousalInit", afValue as int)
    SetSliderOptionValueST(afValue, "{0}")
  ElseIf(option[0] == "ArousalInitPl")
    JMap.setInt(jProfile, "iArousalInitPl", afValue as int)
    SetSliderOptionValueST(afValue, "{0}")
  ElseIf(option[0] == "ArousalInitFol")
    JMap.setInt(jProfile, "iArousalInitFol", afValue as int)
    SetSliderOptionValueST(afValue, "{0}")
  ElseIf(option[0] == "PlayerInit")
    JMap.setInt(jProfile, "fPlayerInit", afValue as int)
    SetSliderOptionValueST(afValue, "{1}%")
  ElseIf(option[0] == "ArousalPartner")
    JMap.setInt(jProfile, "iArousalPartner", afValue as int)
    SetSliderOptionValueST(afValue, "{0}")
  ElseIf(option[0] == "ArousalPartnerFol")
    JMap.setInt(jProfile, "iArousalPartnerFol", afValue as int)
    SetSliderOptionValueST(afValue, "{0}")
  ElseIf(option[0] == "EngageChance")
    JMap.setFlt(jProfile, "fEngageChance", afValue)
    SetSliderOptionValueST(afValue, "{1}%")
  ElseIf(option[0] == "EngageTimeMin")
    JMap.setFlt(jProfile, "fEngageTimeMin", afValue)
    SetSliderOptionValueST(afValue, "{2}")
  ElseIf(option[0] == "EngageTimeMax")
    JMap.setFlt(jProfile, "fEngageTimeMax", afValue)
    SetSliderOptionValueST(afValue, "{2}")
  ElseIf(option[0] == "Distance")
    JMap.setFlt(jProfile, "fDistance", afValue)
    SetSliderOptionValueST(afValue, "{1}m")
  ElseIf(option[0] == "Disposition")
    JMap.setInt(jProfile, "iDisposition", afValue as int)
    SetSliderOptionValueST(afValue, "{0}")
  ElseIf(option[0] == "ReqPointsBase")
    JMap.setInt(jProfile, "iReqPoints", afValue as int)
    SetSliderOptionValueST(afValue, "{0}")
  ElseIf(option[0] == "chanceBase")
    JMap.setInt(jProfile, "cBaseChance", afValue as int)
    SetSliderOptionValueST(afValue, "{1}%")
  ElseIf(option[0] == "aChances")
    int i = option[1] as int
    int jTmp = JMap.getObj(jProfile, "cAChances")
    JArray.setFlt(jTmp, i, afValue)
    JMap.setObj(jProfile, "cAChances", jTmp)
    SetSliderOptionValueST(afValue, "{1}%")
  ElseIf(option[0] == "InitHealth")
    JMap.setFlt(jProfile, "rHealthThresh", afValue/100)
    SetSliderOptionValueST(afValue, "{0}%")
  ElseIf(option[0] == "InitStamina")
    JMap.setFlt(jProfile, "rStaminaThresh", afValue/100)
    SetSliderOptionValueST(afValue, "{0}%")
  ElseIf(option[0] == "InitMagicka")
    JMap.setFlt(jProfile, "rMagickaThresh", afValue/100)
    SetSliderOptionValueST(afValue, "{0}%")
  ElseIf(option[0] == "GenderPartner")
    int i = option[1] as int
    int jTmp = JMap.getObj(jProfile, "bGenderPartner")
    JArray.setFlt(jTmp, i, afValue)
    JMap.setObj(jProfile, "bGenderPartner", jTmp)
    SetSliderOptionValueST(afValue, "{0}%")

	ElseIf(option[0] == "TMaxRounds") ; Threading
		iResMaxRounds = afValue as int
		SetSliderOptionValueST(iResMaxRounds)
	ElseIf(option[0] == "TNextRound")
		fResNextRoundChance = afValue
		SetSliderOptionValueST(fResNextRoundChance, "{1}%")
	ElseIf(option[0] == "TAddActor")
		fAddActorChance = afValue
		SetSliderOptionValueST(fAddActorChance, "{1}%")
	ElseIf(option[0] == "TStalkTime")
		iStalkTime = afValue as int
		SetSliderOptionValueST(iStalkTime, "{0}s")
	ElseIf(option[0] == "SpecChance")
		fSpecChance = afValue
		SetSliderOptionValueST(fSpecChance, "{1}%")    

	ElseIf(option[0] == "af1pWeightFol")  ; Animation Frame
		fAFMasturbateFol = afValue
		SetSliderOptionValueST(fAFMasturbateFol, "{1}%")
	ElseIf(option[0] == "af1pWeightNPC")
		fAFMasturbateNPC = afValue
		SetSliderOptionValueST(fAFMasturbateNPC, "{1}%")
	ElseIf(option[0] == "scenetype")
    int i = option[1] as int
		iSceneTypeWeight[i] = afValue as int
		SetSliderOptionValueST(iSceneTypeWeight[i], "{1}")
  EndIf
EndEvent

; ===============================================================
; =============================  MENU STATES
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
  ElseIf(option[0] == "Incest")
    SetMenuDialogStartIndex(JMap.getInt(jProfile, "lIncest"))
    SetMenuDialogDefaultIndex(1)
    SetMenuDialogOptions(lIncestList)
  ElseIf(option[0] == "AdvConAlg")
    SetMenuDialogStartIndex(JMap.getInt(jProfile, "lAdvInit"))
    SetMenuDialogDefaultIndex(1)
    SetMenuDialogOptions(lAdvancedInitList)
  ElseIf(option[0] == "reqPoints")
    int i = option[1] as int
    int jA = JMap.getObj(jProfile, "reqAPoints")
    SetMenuDialogStartIndex(lReqList.Find(JArray.getInt(jA, i)))
    SetMenuDialogDefaultIndex(5)
    SetMenuDialogOptions(lReqList)

  ElseIf(option[0] == "locProfile") ; Location
    int i = option[1] as int
    int c = smmProfiles.Find(lProfiles[i])
    SetMenuDialogStartIndex(c)
    SetMenuDialogDefaultIndex(0)
    SetMenuDialogOptions(smmProfiles)
  ElseIf(option[0] == "ApplyLocProfile")
    SetMenuDialogStartIndex(0)
    SetMenuDialogDefaultIndex(0)
    SetMenuDialogOptions(smmProfiles)

  ElseIf(option[0] == "crtFilterMethod") ; Creature Filter
		SetMenuDialogStartIndex(iCrtFilterMethod)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(crtFilterMethodList)
  EndIf
EndEvent

Event OnMenuAcceptST(Int aiIndex)
  If(aiIndex == -1)
    return
  EndIf
  String[] option = PapyrusUtil.StringSplit(GetState(), "_")
  If(option[0] == "consider") ; Profiles
    JMap.setInt(jProfile, "lConsider", aiIndex)
    SetMenuOptionValueST(lConsiderList[aiIndex])
  ElseIf(option[0] == "considerCrt")
    JMap.setInt(jProfile, "lConsiderCreature", aiIndex)
    SetMenuOptionValueST(lConsiderListCrt[aiIndex])
  ElseIf(option[0] == "Incest")
    JMap.setInt(jProfile, "lIncest", aiIndex)
    SetMenuOptionValueST(lIncestList[aiIndex])
  ElseIf(option[0] == "AdvConAlg")
    JMap.setInt(jProfile, "lAdvInit", aiIndex)
    ForcePageReset()
  ElseIf(option[0] == "reqPoints")
    int i = option[1] as int
    int jA = JMap.getObj(jProfile, "reqAPoints")
    JArray.setInt(jA, i, aiIndex)
    JMap.setObj(jProfile, "reqAPoints", jA)
    SetMenuOptionValueST(lReqList[aiIndex])

  ElseIf(option[0] == "locProfile") ; Location
    int i = option[1] as int
    lProfiles[i] = smmProfiles[aiIndex]
    SetMenuOptionValueST(lProfiles[i])
  ElseIf(option[0] == "ApplyLocProfile")
    int i = 0
    While(i < lProfiles.Length)
      lProfiles[i] = smmProfiles[aiIndex]
      i += 1
    EndWhile
    ForcePageReset()

  ElseIf(option[0] == "crtFilterMethod") ; Creature Filter
		iCrtFilterMethod = aiIndex
		SetMenuOptionValueST(crtFilterMethodList[aiIndex])
  EndIf
EndEvent

; ===============================================================
; =============================  INPUTS
; ===============================================================
Event OnInputOpenST()
	string[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "SLTag")
		int i = option[1] as int
		SetInputDialogStartText(SLTags[i])
	EndIf
EndEvent

Event OnInputAcceptST(string a_input)
	string[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "SLTag")
		int i = option[1] as int
		SLTags[i] = a_input
		SetInputOptionValueST(SLTags[i])
	EndIf
EndEvent

; ===============================================================
; =============================  HIGHLIGHTS
; ===============================================================
Event OnHighlightST()
  String[] option = PapyrusUtil.StringSplit(GetState(), "_")
  If(option[0] == "TickInterval") ; General
    SetInfoText("$SMM_IntervalHighlight")
  ElseIf(option[0] == "LocScan")
    SetInfoText("$SMM_LocScanHighlight")
  ElseIf(option[0] == "ScanRadius")
    SetInfoText("$SMM_ScanRadiusHighlight")
  ElseIf(option[0] == "ScenesPerScan")
    SetInfoText("$SMM_ScenesPerScanHighlight")
  ElseIf(option[0] == "DefDuskTime")
    SetInfoText("$SMM_DuskTimeHighlight")
  ElseIf(option[0] == "DefDawnTime")
    SetInfoText("$SMM_DawnTimeHighlight")
  ElseIf(option[0] == "afNotify")
    SetInfoText("$SMM_EngageNotifyHighlight")
	ElseIf(option[0] == "notifycolored")
		SetInfoText("$SMM_EngageNofifyColorHighlight")

  ElseIf(option[0] == "shutdownThreads") ; General/Debug
    SetInfoText("$SMM_ShutDownHighlight")

  ElseIf(option[0] == "ApplyLocProfile") ; location
    SetInfoText("$SMM_ApplyLocProfileHighlight")

  ElseIf(option[0] == "combatSkip") ; Profile
    SetInfoText("$SMM_combatSkipHighlight")
  ElseIf(option[0] == "EngageChance")
    SetInfoText("$SMM_EngageChanceHighlight")
  ElseIf(option[0] == "EngageTimeMin")
    SetInfoText("$SMM_EngageTimeMinHighlight")
  ElseIf(option[0] == "EngageTimeMax")
    SetInfoText("$SMM_EngageTimeMaxHighlight")
  ElseIf(option[0] == "EngageCooldown")
    SetInfoText("$SMM_EngageCooldownHighlight")
  ElseIf(option[0] == "NonConsent")
    SetInfoText("$SMM_NonConsentHighlight")
  ElseIf(option[0] == "Distance")
    SetInfoText("$SMM_DistanceHighlight")
  ElseIf(option[0] == "LineOfSight")
    SetInfoText("$SMM_LineOfSightHighlight")
  ElseIf(option[0] == "Disposition")
    SetInfoText("$SMM_DispositionHighlight")
  ElseIf(option[0] == "Incest")
    SetInfoText("$SMM_IncestHighlight")
  ElseIf(option[0] == "consider")
    SetInfoText("$SMM_ConsiderHighlight")
  ElseIf(option[0] == "considerCrt")
    SetInfoText("$SMM_ConsiderCrtHighlight")
  ElseIf(option[0] == "considerFollower")
    SetInfoText("$SMM_ConsiderFollowerHighlight")
  ElseIf(option[0] == "ArousalInit")
    SetInfoText("$SMM_ArousalInitHighlight")
  ElseIf(option[0] == "ArousalInitPl")
    SetInfoText("$SMM_ArousalInitPlHighlight")
  ElseIf(option[0] == "ArousalInitFol")
    SetInfoText("$SMM_ArousalInitFolHighlight")
  ElseIf(option[0] == "PlayerInit")
    SetInfoText("$SMM_PlayerInitiatorHighlight")
  ElseIf(option[0] == "GenderInit")
    SetInfoText("$SMM_GenderAllowInitHighlight_" + option[1])
  ElseIf(option[0] == "ArousalPartner")
    SetInfoText("$SMM_ArousalPartnerHighlight")
  ElseIf(option[0] == "ArousalPartnerFol")
    SetInfoText("$SMM_ArousalPartnerFolHighlight")
  ElseIf(option[0] == "GenderPartner")
    SetInfoText("$SMM_GenderAllowPartnerHighlight_" + option[1])
  ElseIf(option[0] == "InitHealth")
    SetInfoText("$SMM_HealthThreshHighlight")
  ElseIf(option[0] == "InitStamina")
    SetInfoText("$SMM_StaminaThreshHighlight")
  ElseIf(option[0] == "InitMagicka")
    SetInfoText("$SMM_MagickaThreshHighlight")
  ElseIf(option[0] == "ReqPointsBase")
    SetInfoText("$SMM_ReqPointsHighlight")
  ElseIf(option[0] == "chanceBase")
    SetInfoText("$SMM_BaseChanceHighlight")
  ElseIf(option[0] == "reqPoints" || option[0] == "aChances")
    SetInfoText("$SMM_AdvConHighlight_" + option[1])

	ElseIf(option[0] == "TMaxRounds") ; Threading
		SetInfoText("$SMM_TMaxRoundsHighlight")
	ElseIf(option[0] == "TNextRound")
		SetInfoText("$SMM_TNextRoundHighlight")
	ElseIf(option[0] == "TAddActor")
		SetInfoText("$SMM_TAddActorHighlight")
  ElseIf(option[0] == "TStalkTime")
		SetInfoText("$SMM_TStalkTimeHighlight")
  ElseIf(option[0] == "TStalkNotify")
		SetInfoText("$SMM_TStalkNotifyHighlight")
  ElseIf(option[0] == "TStalkNotifyName")
		SetInfoText("$SMM_TStalkNotifyHighlightName")
  ElseIf(option[0] == "SpecChance")
		SetInfoText("$SMM_SpectatorChanceHighlight")
  ElseIf(option[0] == "SpecGender")
		SetInfoText("$SMM_SpectatorGenderHighlight")
  ElseIf(option[0] == "SpecCrt")
		SetInfoText("$SMM_SpectatorCreatureHighlight")

  ElseIf(option[0] == "SLAllowed")  ; Anim Frames
		SetInfoText("$SMM_afFrameSexLabHighlight")
	ElseIf(option[0] == "OStimAllowed")
		SetInfoText("$SMM_afFrameOStimHighlight")
	ElseIf(option[0] == "SLCrtOnly")
		SetInfoText("$SMM_afFrameSexLabCrtOnlyHighlight")
	ElseIf(option[0] == "SLTreatVictim")
		SetInfoText("$SMM_SLTreatVictimHighlight")
	ElseIf(option[0] == "SLSupportFilter")
		SetInfoText("$SMM_SLFilterOptionHighlight")
	ElseIf(option[0] == "ostimMinD" || option[0] == "ostimMaxD")
		SetInfoText("$SMM_afOStimMinMaxDurHighlight")
  ElseIf(option[0] == "af1pWeightFol" || option[0] == "af1pWeightNPC")
    SetInfoText("$SMM_af1pWeightHighlight")

  ElseIf(option[0] == "crtFilterMethod") ; Creature Filter
		SetInfoText("$SMM_scrFilterMethodHighlight")
  EndIf
EndEvent

; ===============================================================
; =============================  FULL STATES
; ===============================================================

State Enabled
  Event OnSelectST()
    bPaused = !bPaused
    SetToggleOptionValueST(!bPaused)
    If(!bPaused)
      PlayerScr.RegisterForSingleUpdate(iTickInterval)
    EndIf
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
    iPauseKey = -1
    SetKeyMapOptionValueST(iPauseKey)
    PlayerScr.ResetKey(iPauseKey)
  EndEvent
  Event OnHighlightST()
    SetInfoText("$SMM_PauseHotkeyHighlight")
  EndEvent
EndState

State notifycolorchoice
	Event OnColorOpenST()
		SetColorDialogStartColor(iNotifyColor)
		SetColorDialogDefaultColor(0xFF0000)
	EndEvent
	Event OnColorAcceptST(int color)
		iNotifyColor = color
		SetColorOptionValueST(iNotifyColor)
    ; Convert the color code into a hex string for display in notifications
    String hex = ""
    While(color != 0)
      int c = color % 16
      If(c < 10)
        hex = c + hex
      Else
        hex = StringUtil.AsChar(55 + c) + hex
      EndIf
      color /= 16
    EndWhile
    While(StringUtil.GetLength(hex) < 6)
      hex = "0" + hex
    EndWhile
    sNotifyColor = "#" + hex
	EndEvent
EndState

; ===============================================================
; =============================  PROFILE SYSTEM
; ===============================================================
Function SaveJson()
  If(!smmProfiles.Length || smmProfiles.Length <= smmProfileIndex)
    return
  EndIf
  JValue.writeToFile(jProfile, filePath + smmProfiles[smmProfileIndex] + ".json")
  jProfile = JValue.release(jProfile)
EndFunction

Function CreateMenuProfiles(int append0 = 0)
  int jFiles = JValue.readFromDirectory(filePath, ".json")
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
    SaveJson()  ; Save potential changes to the currently slected json
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
    SetMenuDialogDefaultIndex(0)
    SetMenuDialogOptions(smmProfiles)
  EndEvent
  Event OnMenuAcceptST(Int aiIndex)
    SaveJson()
    If(aiIndex != -1)
      smmProfileIndex = aiIndex
      ForcePageReset() 
    EndIf
  EndEvent
  Event OnDefaultST()
    smmProfileIndex = 0
    ForcePageReset()
  EndEvent
  Event OnHighlightST()
    SetInfoText("$SMM_ProfileLoadHighlight")
  EndEvent
EndState

; =============================================================
; ===================================== MISC UTILITY
; =============================================================
int Function getFlag(bool option)
	If(option)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
endFunction

Function SaveMCM()
  int obj = JMap.object()
  JMap.setInt(obj, "iPauseKey", iPauseKey)
  JMap.setInt(obj, "iTickInterval", iTickInterval)
  JMap.setFlt(obj, "gScanRadius", gScanRadius.Value)
  JMap.setInt(obj, "iMaxScenes", iMaxScenes)
  JMap.setFlt(obj, "fDuskTime", fDuskTime)
  JMap.setFlt(obj, "fDawnTime", fDawnTime)
  JMap.setFlt(obj, "fEngageCooldown", fEngageCooldown)
  JMap.setObj(obj, "lProfiles", JArray.objectWithStrings(lProfiles))
  JMap.setInt(obj, "iResMaxRounds", iResMaxRounds)
  JMap.setFlt(obj, "fResNextRoundChance", fResNextRoundChance)
  JMap.setFlt(obj, "fAddActorChance", fAddActorChance)
  JMap.setInt(obj, "iStalkTime", iStalkTime)
  JMap.setInt(obj, "bStalkNotify", bStalkNotify as int)
  JMap.setInt(obj, "bStalkNotifyName", bStalkNotifyName as int)
  JMap.setFlt(obj, "fSpecChance", fSpecChance)
  JMap.setInt(obj, "bSpecGender", bSpecGender as int)
  JMap.setInt(obj, "bSpecCrt", bSpecCrt as int)
  JMap.setInt(obj, "bNotifyAF", bNotifyAF as int)
  JMap.setInt(obj, "bNotifyColor", bNotifyColor as int)
  JMap.setInt(obj, "iNotifyColor", iNotifyColor)
  JMap.setStr(obj, "sNotifyColor", sNotifyColor)
  JMap.setInt(obj, "bBestiality", bBestiality as int)
  JMap.setInt(obj, "bSupportFilter", bSupportFilter as int)
  JMap.setObj(obj, "SLTags", JArray.objectWithStrings(SLTags))
  JMap.setFlt(obj, "fAFMasturbateFol", fAFMasturbateFol)
  JMap.setFlt(obj, "fAFMasturbateNPC", fAFMasturbateNPC)
  JMap.setObj(obj, "iSceneTypeWeight", JArray.objectWithInts(iSceneTypeWeight))
  JMap.setObj(obj, "bAssaultNPC", JArray.objectWithBooleans(bAssaultNPC))
  JMap.setObj(obj, "bAssaultFol", JArray.objectWithBooleans(bAssaultFol))
  JMap.setInt(obj, "iCrtFilterMethod", iCrtFilterMethod)
  JMap.setObj(obj, "JbValidRace", JArray.objectWithBooleans(bValidRace))
  JValue.writeToFile(obj, filePath + "Definition\\MCM.json")
EndFunction

Function LoadMCM()
  int obj = JValue.readFromFile(filePath + "Definition\\MCM.json")
  If(obj == 0)
    return
  EndIf
  iPauseKey = JMap.getInt(obj, "iPauseKey", -1)
  iTickInterval = JMap.getInt(obj, "iTickInterval", 20)
  gScanRadius.Value = JMap.getFlt(obj, "gScanRadius", 7700)
  iMaxScenes = JMap.getInt(obj, "iMaxScenes", 1)
  fDuskTime = JMap.getFlt(obj, "fDuskTime", 19.00)
  fDawnTime = JMap.getFlt(obj, "fDawnTime", 5.00)
  fEngageCooldown = JMap.getFlt(obj, "fEngageCooldown", 6.0)
  int objProfiles = JMap.getObj(obj, "lProfiles")
  If(objProfiles == 0)
    lProfiles = Utility.CreateStringArray(28, "$SMM_Disabled")
  Else
    lProfiles = SMMUtility.asJStringArray(objProfiles)
  EndIf
  iResMaxRounds = JMap.getInt(obj, "iResMaxRounds", 4)
  fResNextRoundChance = JMap.getFlt(obj, "fResNextRoundChance", 15.0)
  fAddActorChance = JMap.getFlt(obj, "fAddActorChance", 50.0)
  iStalkTime = JMap.getInt(obj, "iStalkTime", 20)
  bStalkNotify = JMap.getInt(obj, "bStalkNotify", 0)
  bStalkNotifyName = JMap.getInt(obj, "bStalkNotifyName", 0)
  fSpecChance = JMap.getFlt(obj, "fSpecChance", 82.00)
  bSpecGender = JMap.getInt(obj, "bSpecGender", 0)
  bSpecCrt = JMap.getInt(obj, "bSpecCrt", 0)
  bNotifyAF = JMap.getInt(obj, "bNotifyAF", 0)
  bNotifyColor = JMap.getInt(obj, "bNotifyColor", 0)
  iNotifyColor = JMap.getInt(obj, "iNotifyColor", 0xFF0000)
  sNotifyColor = JMap.getStr(obj, "sNotifyColor", "#FF0000")
  bBestiality = JMap.getInt(obj, "bBestiality", 0)
  bSupportFilter = JMap.getInt(obj, "bSupportFilter", 0)
  int objTags = JMap.getObj(obj, "SLTags")
  If(objTags == 0)
    SLTags = Utility.CreateStringArray(6)
  Else
    SLTags = SMMUtility.asJStringArray(objTags)
  EndIf
  fAFMasturbateFol = JMap.getFlt(obj, "fAFMasturbateFol", 0.0)
  fAFMasturbateNPC = JMap.getFlt(obj, "fAFMasturbateNPC", 10.0)
  int objArray = JMap.getObj(obj, "iSceneTypeWeight")
  If(objArray == 0)
    iSceneTypeWeight = new int[4]
  Else
    iSceneTypeWeight = SMMUtility.asJIntArray(objArray)
  EndIf
  objArray = JMap.getObj(obj, "bAssaultNPC")
  If(objArray == 0)
    bAssaultNPC = new bool[35]
  Else
    bAssaultNPC = SMMUtility.asJBoolArray(objArray)
  EndIf
  objArray = JMap.getObj(obj, "bAssaultFol")
  If(objArray == 0)
    bAssaultFol = new bool[35]
  Else
    bAssaultFol = SMMUtility.asJBoolArray(objArray)
  EndIf
  iCrtFilterMethod = JMap.getInt(obj, "iCrtFilterMethod", 0)
  objArray = JMap.getObj(obj, "bValidRace")
  If(objArray == 0)
    bValidRace = new bool[52]
  Else
    bValidRace = SMMUtility.asJBoolArray(objArray)
  EndIf
EndFunction

; =============================================================
; ===================================== REDUNDANT
; =============================================================
bool Property bLocationScan = true Auto Hidden
float Property fAFMasturbateCrt = 0.0 Auto Hidden
int Property iAF2some = 70 Auto Hidden
int Property iAF3some = 50 Auto Hidden
int Property iAF4some = 40 Auto Hidden
int Property iAF5Some = 30 Auto Hidden