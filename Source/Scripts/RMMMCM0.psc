Scriptname RMMMCM0 extends RMMMCM
; -------------------------- Variables
; ------------ Wolf
bool Property bCombatSkipWolf = true Auto Hidden
int Property iEngageChanceWolf = 40 Auto Hidden
;Engage
int Property EngageOptionWolf = 1 Auto Hidden
bool Property bHostVicWolf = false Auto Hidden
bool Property bHostOnFriendWolf = false Auto Hidden
bool Property bEngagePlWolf = false Auto Hidden
int Property iPrefPlWolf = 33 Auto Hidden
bool Property bEngageFolWolf = true Auto Hidden
bool Property bRespFolGenWolf = true Auto Hidden
bool Property bEngageMaleWolf = true Auto Hidden
bool Property bEngageFemaleWolf = true Auto Hidden
bool Property bEngageFutaWolf = true Auto Hidden
bool Property bEngageCreatureWolf = false Auto Hidden
bool Property bUseArousalWolf = true Auto Hidden Conditional
int Property iArousalThreshWolf = 60 Auto Hidden
bool Property bIgnoreVicArousalWolf = false Auto Hidden
bool Property bUseDistWolf = true Auto Hidden
float Property fMaxDistanceWolf = 12.0 Auto Hidden
bool Property bUseLoSWolf = false Auto Hidden
bool Property bUseDispotionWolf = false Auto Hidden
int Property iMinDispPlWolf = 1 Auto Hidden
int Property iMinDispFolWolf = 1 Auto Hidden
int Property iMinDispNPCWolf = 0 Auto Hidden
; -- Filter
; Follower
bool Property bFolEngageWolf = true Auto Hidden
bool Property bRespFolGenAggrWolf = false Auto Hidden
; Male
bool Property bEngMalPlWolf = false Auto Hidden
bool Property bEngMalFolWolf = true Auto Hidden
int Property iEngMalFolWolf = 6 Auto Hidden
bool Property bEngMalMalWolf = true Auto Hidden
bool Property bEngMalFemWolf = true Auto Hidden
bool Property bEngMalFutWolf = false Auto Hidden
bool Property bEngMalCreaWolf = false Auto Hidden
; Female
bool Property bEngFemPlWolf = false Auto Hidden
bool Property bEngFemFolWolf = true Auto Hidden
int Property iEngFemFolWolf = 6 Auto Hidden
bool Property bEngFemMalWolf = true Auto Hidden
bool Property bEngFemFemWolf = true Auto Hidden
bool Property bEngFemFutWolf = false Auto Hidden
bool Property bEngFemCreaWolf = false Auto Hidden
; Futa
bool Property bEngFutPlWolf = false Auto Hidden
bool Property bEngFutFolWolf = true Auto Hidden
int Property iEngFutFolWolf = 6 Auto Hidden
bool Property bEngFutMalWolf = true Auto Hidden
bool Property bEngFutFemWolf = true Auto Hidden
bool Property bEngFutFutWolf = false Auto Hidden
bool Property bEngFutCreaWolf = false Auto Hidden
; Creature
bool Property bEngCreaPlWolf = false Auto Hidden
bool Property bEngCreaFolWolf = true Auto Hidden
int Property iEngCreaFolWolf = 6 Auto Hidden
bool Property bEngCreaMalWolf = true Auto Hidden
bool Property bEngCreaFemWolf = true Auto Hidden
bool Property bEngCreaFutWolf = false Auto Hidden
bool Property bEngCreaCreaWolf = false Auto Hidden

; ------------ Bunny
bool Property bCombatSkipBunny = true Auto Hidden
int Property iEngageChanceBunny = 40 Auto Hidden
;Engage
int Property EngageOptionBunny = 1 Auto Hidden
bool Property bHostVicBunny = false Auto Hidden
bool Property bHostOnFriendBunny = false Auto Hidden
bool Property bEngagePlBunny = false Auto Hidden
int Property iPrefPlBunny = 33 Auto Hidden
bool Property bEngageFolBunny = true Auto Hidden
bool Property bRespFolGenBunny = true Auto Hidden
bool Property bEngageMaleBunny = true Auto Hidden
bool Property bEngageFemaleBunny = true Auto Hidden
bool Property bEngageFutaBunny = true Auto Hidden
bool Property bEngageCreatureBunny = false Auto Hidden
bool Property bUseArousalBunny = true Auto Hidden Conditional
int Property iArousalThreshBunny = 60 Auto Hidden
bool Property bIgnoreVicArousalBunny = false Auto Hidden
bool Property bUseDistBunny = true Auto Hidden
float Property fMaxDistanceBunny = 12.0 Auto Hidden
bool Property bUseLoSBunny = false Auto Hidden
bool Property bUseDispotionBunny = false Auto Hidden
int Property iMinDispPlBunny = 1 Auto Hidden
int Property iMinDispFolBunny = 1 Auto Hidden
int Property iMinDispNPCBunny = 0 Auto Hidden
; -- Filter
; Follower
bool Property bFolEngageBunny = true Auto Hidden
bool Property bRespFolGenAggrBunny = false Auto Hidden
; Male
bool Property bEngMalPlBunny = false Auto Hidden
bool Property bEngMalFolBunny = true Auto Hidden
int Property iEngMalFolBunny = 6 Auto Hidden
bool Property bEngMalMalBunny = true Auto Hidden
bool Property bEngMalFemBunny = true Auto Hidden
bool Property bEngMalFutBunny = false Auto Hidden
bool Property bEngMalCreaBunny = false Auto Hidden
; Female
bool Property bEngFemPlBunny = false Auto Hidden
bool Property bEngFemFolBunny = true Auto Hidden
int Property iEngFemFolBunny = 6 Auto Hidden
bool Property bEngFemMalBunny = true Auto Hidden
bool Property bEngFemFemBunny = true Auto Hidden
bool Property bEngFemFutBunny = false Auto Hidden
bool Property bEngFemCreaBunny = false Auto Hidden
; Futa
bool Property bEngFutPlBunny = false Auto Hidden
bool Property bEngFutFolBunny = true Auto Hidden
int Property iEngFutFolBunny = 6 Auto Hidden
bool Property bEngFutMalBunny = true Auto Hidden
bool Property bEngFutFemBunny = true Auto Hidden
bool Property bEngFutFutBunny = false Auto Hidden
bool Property bEngFutCreaBunny = false Auto Hidden
; Creature
bool Property bEngCreaPlBunny = false Auto Hidden
bool Property bEngCreaFolBunny = true Auto Hidden
int Property iEngCreaFolBunny = 6 Auto Hidden
bool Property bEngCreaMalBunny = true Auto Hidden
bool Property bEngCreaFemBunny = true Auto Hidden
bool Property bEngCreaFutBunny = false Auto Hidden
bool Property bEngCreaCreaBunny = false Auto Hidden

; ==================================
; 							MENU
; ==================================

Event OnPageReset(string Page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If(Page == "Profiles")
    AddMenuOptionST("ProfileView", "Active Profile: ", ProfileViewerList[ProfileViewerIndex])
    If(ProfileViewerList[ProfileViewerIndex] == "Wolf")
      AddHeaderOption("Wolf")
      AddToggleOptionST("CombatSkipWolf", "Allow engagement while in Combat", bCombatSkipWolf)
      AddSliderOptionST("EngChanceWolf", "Chance for Engagement", iEngageChanceWolf)
      int HostileFlag = ScanHostileFlag()
      AddToggleOptionST("HostileVictimWolf", "Allow Hostile Victms", bHostVicWolf, HostileFlag)
      ; AddToggleOptionST("HostileOnFriendlyWolf", "Hostiles engage Allies", bHostOnFriendWolf, HostileFlag)
      AddHeaderOption("Victim")
      AddToggleOptionST("EngagePlWolf", "Allow Player as Victim",bEngagePlWolf)
      AddSliderOptionST("PreferPlWolf", "Prefer Player-Engagements", iPrefPlWolf, "{0}%",PrefPlFlagWolf())
      AddToggleOptionST("EngageFolWolf", "Allow Followers to be engaged", bEngageFolWolf)
      AddToggleOptionST("RespectFollowerGenderWolf", "Respect Followers Gender", bRespFolGenWolf)
      AddToggleOptionST("EngageMaleWolf", "Allow Male Actors to be engaged", bEngageMaleWolf)
      AddToggleOptionST("EngageFemaleWolf", "Allow Female Actors to be engaged", bEngageFemaleWolf)
      AddToggleOptionST("EngageFutaWolf", "Allow Futa Actors to be engaged", bEngageFutaWolf)
      AddToggleOptionST("EngageCreatureWolf", "Allow Creatures to be engaged", bEngageCreatureWolf)
      AddHeaderOption("Engagement")
      AddToggleOptionST("UseArousalWolf", "Check for Arousal?", bUseArousalWolf)
      int ArousalFlagWolf = CheckFlagArousalWolf()
      AddSliderOptionST("ArousThreshWolf", "Arousal Threshhold", iArousalThreshWolf, "{0}", ArousalFlagWolf)
      AddToggleOptionST("IgnoreVicArousalWolf", "Ignore Victim Arousal", bIgnoreVicArousalWolf, ArousalFlagWolf)
      AddToggleOptionST("useDistanceWolf", "Check for Distance?", bUseDistWolf)
      AddSliderOptionST("maxDistanceWolf", "Maximum allowed Distance", fMaxDistanceWolf, "{0}m", CheckFlagDistanceWolf())
      AddToggleOptionST("UseLOSWolf", "Check for LoS?", bUseLoSWolf)
      AddToggleOptionST("UseDispWolf", "Check for Disposition?", bUseDispotionWolf)
      int DispFlagWolf = FlagDispWolf()
      AddSliderOptionST("PlDispositionWolf", "Min Disposition (Player)", iMinDispPlWolf, "{0}", DispFlagWolf)
      AddSliderOptionST("FolDispositionWolf", "Min Disposition (Follower)", iMinDispFolWolf, "{0}", DispFlagWolf)
      AddSliderOptionST("NPCDispositionWolf", "Min Disposition (NPC)", iMinDispNPCWolf, "{0}", DispFlagWolf)
      SetCursorPosition(3)
      ; --------------------------------------------------------------
      AddHeaderOption("Filter")
      AddToggleOptionST("FolEngageWolf", "Allow Followers to engage", bFolEngageWolf)
      AddToggleOptionST("RespFolGenAggrWolf", "Respect Follower Gender", bRespFolGenAggrWolf)
      ; --------------------------------------------------------------
      AddEmptyOption()
      AddTextOption("- A \"male\" Actor can engage...", none)
      AddToggleOptionST("MalePlayerEngageWolf", "..the Player", bEngMalPlWolf)
      AddToggleOptionST("MalFollowerEngageWolf", "..Followers", bEngMalFolWolf)
      ; AddMenuOptionST("MalFolEngageOption", "Follower Engagement Option", EngageOptionList[iEngMalFol], EngMalFolFlag())
      AddToggleOptionST("MaleMaleEngageWolf", "..male Actors.", bEngMalMalWolf)
      AddToggleOptionST("MaleFemEngageWolf", "..female Actors.", bEngMalFemWolf)
      AddToggleOptionST("MaleFutaEngageWolf", "..futa Actors.", bEngMalFutWolf)
      AddToggleOptionST("MaleCreatureEngageWolf", "..Creatures", bEngMalCreaWolf)
      ; --------------------------------------------------------------
      AddEmptyOption()
      AddTextOption("- A \"female\" Actor can engage...", none)
      AddToggleOptionST("FemalePlayerEngageWolf", "..the Player", bEngFemPlWolf)
      AddToggleOptionST("FemalFollowerEngageWolf", "..Followers", bEngFemFolWolf)
      ; AddMenuOptionST("FemalFolEngageOption", "Follower Engagement Option", EngageOptionList[iEngFemFol], EngFemFolFlag())
      AddToggleOptionST("FemaleMaleEngageWolf", "..male Actors.", bEngFemMalWolf)
      AddToggleOptionST("FemaleFemEngageWolf", "..female Actors.", bEngFemFemWolf)
      AddToggleOptionST("FemaleFutaEngageWolf", "..futa Actors.", bEngFemFutWolf)
      AddToggleOptionST("FemaleCreatEngageWolf", "..Creatures.", bEngFemCreaWolf)
      ; --------------------------------------------------------------
      AddEmptyOption()
      AddTextOption("- A \"futa\" Actor can engage...", none)
      AddToggleOptionST("FutaPlayerEngageWolf", "..the Player", bEngFutPlWolf)
      AddToggleOptionST("FutaFollowerEngageWolf", "..Followers", bEngFutFolWolf)
      ; AddMenuOptionST("FutaFolEngageOption", "Follower Engagement Option", EngageOptionList[iEngFutFol], EngFutFolFlag())
      AddToggleOptionST("FutaMaleEngageWolf", "..male Actors.", bEngFutMalWolf)
      AddToggleOptionST("FutaFemaleEngageWolf", "..female Actors.", bEngFutFemWolf)
      AddToggleOptionST("FutaFutaEngageWolf", "..futa Actors.", bEngFutFutWolf)
      AddToggleOptionST("FutaCreatureEngageWolf", "..Creatures.", bEngFutCreaWolf)
      ; --------------------------------------------------------------
      AddEmptyOption()
      AddTextOption("- A \"Creature\" can engage...", none)
      AddToggleOptionST("CreatPlayerEngageWolf", "..the Player", bEngCreaPlWolf)
      AddToggleOptionST("CreatFollowerEngageWolf", "..Followers", bEngCreaFolWolf)
      ; AddMenuOptionST("CreatFolEngageOption", "Follower Engagement Option", EngageOptionList[iEngCreaFol], EngFutFolFlag())
      AddToggleOptionST("CreatMaleEngageWolf", "..male Actors.", bEngCreaMalWolf)
      AddToggleOptionST("CreatFemaleEngageWolf", "..female Actors.", bEngCreaFemWolf)
      AddToggleOptionST("CreatFutaEngageWolf", "..Creat Actors.", bEngCreaFutWolf)
      AddToggleOptionST("CreatCreatureEngageWolf", "..Creatures.", bEngCreaCreaWolf)
    ElseIf(ProfileViewerList[ProfileViewerIndex] == "Bunny")
      AddHeaderOption("Bunny")
      AddToggleOptionST("CombatSkipBunny", "Allow engagement while in Combat", bCombatSkipBunny)
      AddSliderOptionST("EngChanceBunny", "Chance for Engagement", iEngageChanceBunny)
      int HostileFlag = ScanHostileFlag()
      AddToggleOptionST("HostileVictimBunny", "Allow Hostile Victms", bHostVicBunny, HostileFlag)
      ; AddToggleOptionST("HostileOnFriendlyBunny", "Hostiles engage Allies", bHostOnFriendBunny, HostileFlag)
      AddHeaderOption("Victim")
      AddToggleOptionST("EngagePlBunny", "Allow Player as Victim",bEngagePlBunny)
      AddSliderOptionST("PreferPlBunny", "Prefer Player-Engagements", iPrefPlBunny, "{0}%", PrefPlFlagBunny())
      AddToggleOptionST("EngageFolBunny", "Allow Followers to be engaged", bEngageFolBunny)
      AddToggleOptionST("RespectFollowerGenderBunny", "Respect Followers Gender", bRespFolGenBunny)
      AddToggleOptionST("EngageMaleBunny", "Allow Male Actors to be engaged", bEngageMaleBunny)
      AddToggleOptionST("EngageFemaleBunny", "Allow Female Actors to be engaged", bEngageFemaleBunny)
      AddToggleOptionST("EngageFutaBunny", "Allow Futa Actors to be engaged", bEngageFutaBunny)
      AddToggleOptionST("EngageCreatureBunny", "Allow Creatures to be engaged", bEngageCreatureBunny)
      AddHeaderOption("Engagement")
      AddToggleOptionST("UseArousalBunny", "Check for Arousal?", bUseArousalBunny)
      int ArousalFlagBunny = CheckFlagArousalBunny()
      AddSliderOptionST("ArousThreshBunny", "Arousal Threshhold", iArousalThreshBunny, "{0}", ArousalFlagBunny)
      AddToggleOptionST("IgnoreVicArousalBunny", "Ignore Victim Arousal", bIgnoreVicArousalBunny, ArousalFlagBunny)
      AddToggleOptionST("useDistanceBunny", "Check for Distance?", bUseDistBunny)
      AddSliderOptionST("maxDistanceBunny", "Maximum allowed Distance", fMaxDistanceBunny, "{0}m", CheckFlagDistanceBunny())
      AddToggleOptionST("UseLOSBunny", "Check for LoS?", bUseLoSBunny)
      AddToggleOptionST("UseDispBunny", "Check for Disposition?", bUseDispotionBunny)
      int DispFlagBunny = FlagDispBunny()
      AddSliderOptionST("PlDispositionBunny", "Min Disposition (Player)", iMinDispPlBunny, "{0}", DispFlagBunny)
      AddSliderOptionST("FolDispositionBunny", "Min Disposition (Follower)", iMinDispFolBunny, "{0}", DispFlagBunny)
      AddSliderOptionST("NPCDispositionBunny", "Min Disposition (NPC)", iMinDispNPCBunny, "{0}", DispFlagBunny)
      SetCursorPosition(3)
      ; --------------------------------------------------------------
      AddHeaderOption("Filter")
      AddToggleOptionST("FolEngageBunny", "Allow Followers to engage", bFolEngageBunny)
      AddToggleOptionST("RespFolGenAggrBunny", "Respect Follower Gender", bRespFolGenAggrBunny)
      ; --------------------------------------------------------------
      AddEmptyOption()
      AddTextOption("- A \"male\" Actor can engage...", none)
      AddToggleOptionST("MalePlayerEngageBunny", "..the Player", bEngMalPlBunny)
      AddToggleOptionST("MalFollowerEngageBunny", "..Followers", bEngMalFolBunny)
      ; AddMenuOptionST("MalFolEngageOption", "Follower Engagement Option", EngageOptionList[iEngMalFol], EngMalFolFlag())
      AddToggleOptionST("MaleMaleEngageBunny", "..male Actors.", bEngMalMalBunny)
      AddToggleOptionST("MaleFemEngageBunny", "..female Actors.", bEngMalFemBunny)
      AddToggleOptionST("MaleFutaEngageBunny", "..futa Actors.", bEngMalFutBunny)
      AddToggleOptionST("MaleCreatureEngageBunny", "..Creatures", bEngMalCreaBunny)
      ; --------------------------------------------------------------
      AddEmptyOption()
      AddTextOption("- A \"female\" Actor can engage...", none)
      AddToggleOptionST("FemalePlayerEngageBunny", "..the Player", bEngFemPlBunny)
      AddToggleOptionST("FemalFollowerEngageBunny", "..Followers", bEngFemFolBunny)
      ; AddMenuOptionST("FemalFolEngageOption", "Follower Engagement Option", EngageOptionList[iEngFemFol], EngFemFolFlag())
      AddToggleOptionST("FemaleMaleEngageBunny", "..male Actors.", bEngFemMalBunny)
      AddToggleOptionST("FemaleFemEngageBunny", "..female Actors.", bEngFemFemBunny)
      AddToggleOptionST("FemaleFutaEngageBunny", "..futa Actors.", bEngFemFutBunny)
      AddToggleOptionST("FemaleCreatEngageBunny", "..Creatures.", bEngFemCreaBunny)
      ; --------------------------------------------------------------
      AddEmptyOption()
      AddTextOption("- A \"futa\" Actor can engage...", none)
      AddToggleOptionST("FutaPlayerEngageBunny", "..the Player", bEngFutPlBunny)
      AddToggleOptionST("FutaFollowerEngageBunny", "..Followers", bEngFutFolBunny)
      ; AddMenuOptionST("FutaFolEngageOption", "Follower Engagement Option", EngageOptionList[iEngFutFol], EngFutFolFlag())
      AddToggleOptionST("FutaMaleEngageBunny", "..male Actors.", bEngFutMalBunny)
      AddToggleOptionST("FutaFemaleEngageBunny", "..female Actors.", bEngFutFemBunny)
      AddToggleOptionST("FutaFutaEngageBunny", "..futa Actors.", bEngFutFutBunny)
      AddToggleOptionST("FutaCreatureEngageBunny", "..Creatures.", bEngFutCreaBunny)
      ; --------------------------------------------------------------
      AddEmptyOption()
      AddTextOption("- A \"Creature\" can engage...", none)
      AddToggleOptionST("CreatPlayerEngageBunny", "..the Player", bEngCreaPlBunny)
      AddToggleOptionST("CreatFollowerEngageBunny", "..Followers", bEngCreaFolBunny)
      ; AddMenuOptionST("CreatFolEngageOption", "Follower Engagement Option", EngageOptionList[iEngCreaFol], EngFutFolFlag())
      AddToggleOptionST("CreatMaleEngageBunny", "..male Actors.", bEngCreaMalBunny)
      AddToggleOptionST("CreatFemaleEngageBunny", "..female Actors.", bEngCreaFemBunny)
      AddToggleOptionST("CreatFutaEngageBunny", "..Creat Actors.", bEngCreaFutBunny)
      AddToggleOptionST("CreatCreatureEngageBunny", "..Creatures.", bEngCreaCreaBunny)
    else
      Parent.OnPageReset("Profiles")
    endIf
  else
    Parent.OnPageReset(Page)
  endIf
endEvent

; Event OnConfigClose()
;   RMM_MaxRadius.Value = fMaxRadius*70
;   If(bAllowHostiles)
;     RMM_AllowHostiles.Value = 1
;   else
;     RMM_AllowHostiles.Value = 0
;   EndIf
;   If(bAllowCreatures)
;     RMM_AllowCreatures.Value = 1
;   else
;     RMM_AllowCreatures.Value = 0
;   EndIf
; EndEvent


; --------- Wolf
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
State EngagePlWolf
  Event OnSelectST()
    bEngagePlWolf = !bEngagePlWolf
    SetToggleOptionValueST(bEngagePlWolf)
    If(bEngagePlWolf)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "PreferPlWolf")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "PreferPlWolf")
    EndIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("Allow the Player to be engaged by other NPCs.\nThis Setting will evaluate the Player as a valid engagement Target even when their Gender doesnt match the Gender Condition set in \"Engage Options\" above.")
  EndEvent
EndState

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

State EngageFolWolf
  Event OnSelectST()
    bEngageFolWolf = !bEngageFolWolf
    SetToggleOptionValueST(bEngageFolWolf)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Allow Followers to be engaged by other NPCs.")
  EndEvent
EndState

State RespectFollowerGenderWolf
	Event OnSelectST()
		bRespFolGenWolf = !bRespFolGenWolf
		SetToggleOptionValueST(bRespFolGenWolf)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, Followers will ignore the Gender Setting below.")
	EndEvent
EndState

State EngageMaleWolf
	Event OnSelectST()
		bEngageMaleWolf = !bEngageMaleWolf
		SetToggleOptionValueST(bEngageMaleWolf)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Allow male Actors to be engaged.")
	EndEvent
EndState

State EngageFemaleWolf
	Event OnSelectST()
		bEngageFemaleWolf = !bEngageFemaleWolf
		SetToggleOptionValueST(bEngageFemaleWolf)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Allow female Actors to be engaged.")
	EndEvent
EndState

State EngageFutaWolf
	Event OnSelectST()
		bEngageFutaWolf = !bEngageFutaWolf
		SetToggleOptionValueST(bEngageFutaWolf)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Allow futa Actors to be engaged.")
	EndEvent
EndState

State EngageCreatureWolf
	Event OnSelectST()
		bEngageCreatureWolf = !bEngageCreatureWolf
		SetToggleOptionValueST(bEngageCreatureWolf)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Allow futa Actors to be engaged.")
	EndEvent
EndState
;	--------- Engagement Settings
State UseArousalWolf
  Event OnSelectST()
    bUseArousalWolf = !bUseArousalWolf
    SetToggleOptionValueST(bUseArousalWolf)
    If(bUseArousalWolf)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "ArousThreshWolf")
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "IgnoreVicArousalWolf")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "ArousThreshWolf")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "IgnoreVicArousalWolf")
    EndIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("If false, the Scan will pick up Actors without checking for their Arousal.")
  EndEvent
EndState

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

State useDistanceWolf
  Event OnSelectST()
    bUseDistWolf = !bUseDistWolf
    SetToggleOptionValueST(bUseDistWolf)
    If(bUseDistWolf)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "maxDistanceWolf")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "maxDistanceWolf")
    EndIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("If true, the mod wont match Actors that are too far away from each other.")
  EndEvent
endState

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

State UseLOSWolf
  Event OnSelectST()
    bUseLoSWolf = !bUseLoSWolf
    SetToggleOptionValueST(bUseLoSWolf)
  EndEvent
  Event OnHighlightST()
    SetInfoText("If false, Actors need to see each other in order to start a Scene.")
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
; --------- Filter
;Follower
State FolEngageWolf
  Event OnSelectST()
    bFolEngageWolf = !bFolEngageWolf
    SetToggleOptionValueST(bFolEngageWolf)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Allow Followers to engage others (based on the Settings below).")
  EndEvent
EndState

State RespFolGenAggrWolf
  Event OnSelectST()
    bRespFolGenAggrWolf = !bRespFolGenAggrWolf
    SetToggleOptionValueST(bRespFolGenAggrWolf)
  EndEvent
EndState
;Male
State MalePlayerEngageWolf
  Event OnSelectST()
    bEngMalPlWolf = !bEngMalPlWolf
    SetToggleOptionValueST(bEngMalPlWolf)
  EndEvent
EndState

State MalFollowerEngageWolf
  Event OnSelectST()
    bEngMalFolWolf = !bEngMalFolWolf
    SetToggleOptionValueST(bEngMalFolWolf)
    If(bEngMalFolWolf)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "MalFolEngageOptionWolf")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "MalFolEngageOptionWolf")
    EndIf
  EndEvent
EndState

; State MalFolEngageOption
;   Event OnMenuOpenST()
;     SetMenuDialogStartIndex(iEngMalFol)
;     SetMenuDialogDefaultIndex(6)
;     SetMenuDialogOptions(EngageOptionList)
;   EndEvent
;   Event OnMenuAcceptST(int index)
;     iEngMalFol = index
;     SetMenuOptionValueST(EngageOptionList[iEngMalFol])
;   EndEvent
;   Event OnDefaultST()
;     iEngMalFol = 6
;     SetMenuOptionValueST(EngageOptionList[iEngMalFol])
;   EndEvent
;   Event OnHighlightST()
;     SetInfoText("When a male engages a Follower, the Follower needs to be of this Gender.")
;   EndEvent
; EndState

State MaleMaleEngageWolf
  Event OnSelectST()
    bEngMalMalWolf = !bEngMalMalWolf
    SetToggleOptionValueST(bEngMalMalWolf)
  EndEvent
EndState

State MaleFemEngageWolf
  Event OnSelectST()
    bEngMalFemWolf = !bEngMalFemWolf
    SetToggleOptionValueST(bEngMalFemWolf)
  EndEvent
EndState

State MaleFutaEngageWolf
  Event OnSelectST()
    bEngMalFutWolf = !bEngMalFutWolf
    SetToggleOptionValueST(bEngMalFutWolf)
  EndEvent
EndState

State MaleCreatureEngageWolf
  Event OnSelectST()
    bEngMalCreaWolf = !bEngMalCreaWolf
    SetToggleOptionValueST(bEngMalCreaWolf)
  EndEvent
EndState
;Female
State FemalePlayerEngageWolf
  Event OnSelectST()
    bEngFemPlWolf = !bEngFemPlWolf
    SetToggleOptionValueST(bEngFemPlWolf)
  EndEvent
EndState

State FemalFollowerEngageWolf
  Event OnSelectST()
    bEngFemFolWolf = !bEngFemFolWolf
    SetToggleOptionValueST(bEngFemFolWolf)
    If(bEngFemFolWolf)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "FemalFolEngageOptionWolf")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "FemalFolEngageOptionWolf")
    EndIf
  EndEvent
EndState

; State FemalFolEngageOption
;   Event OnMenuOpenST()
;     SetMenuDialogStartIndex(iEngFemFol)
;     SetMenuDialogDefaultIndex(6)
;     SetMenuDialogOptions(EngageOptionList)
;   EndEvent
;   Event OnMenuAcceptST(int index)
;     iEngFemFol = index
;     SetMenuOptionValueST(EngageOptionList[iEngFemFol])
;   EndEvent
;   Event OnDefaultST()
;     iEngFemFol = 6
;     SetMenuOptionValueST(EngageOptionList[iEngFemFol])
;   EndEvent
;   Event OnHighlightST()
;     SetInfoText("When a female engages a Follower, the Follower needs to be of this Gender.")
;   EndEvent
; EndState

State FemaleMaleEngageWolf
  Event OnSelectST()
    bEngFemMalWolf = !bEngFemMalWolf
    SetToggleOptionValueST(bEngFemMalWolf)
  EndEvent
EndState

State FemaleFemEngageWolf
  Event OnSelectST()
    bEngFemFemWolf = !bEngFemFemWolf
    SetToggleOptionValueST(bEngFemFemWolf)
  EndEvent
EndState

State FemaleFutaEngageWolf
  Event OnSelectST()
    bEngFemFutWolf = !bEngFemFutWolf
    SetToggleOptionValueST(bEngFemFutWolf)
  EndEvent
EndState

State FemaleCreatEngageWolf
  Event OnSelectST()
    bEngFemCreaWolf = !bEngFemCreaWolf
    SetToggleOptionValueST(bEngFemCreaWolf)
  EndEvent
EndState
;Futa
State FutaPlayerEngageWolf
  Event OnSelectST()
    bEngFutPlWolf = !bEngFutPlWolf
    SetToggleOptionValueST(bEngFutPlWolf)
  EndEvent
EndState

State FutaFollowerEngageWolf
  Event OnSelectST()
    bEngFutFolWolf = !bEngFutFolWolf
    SetToggleOptionValueST(bEngFutFolWolf)
    If(bEngFutFolWolf)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "FutaFolEngageOptionWolf")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "FutaFolEngageOptionWolf")
    EndIf
  EndEvent
EndState

; State FutaFolEngageOption
;   Event OnMenuOpenST()
;     SetMenuDialogStartIndex(iEngFutFol)
;     SetMenuDialogDefaultIndex(6)
;     SetMenuDialogOptions(EngageOptionList)
;   EndEvent
;   Event OnMenuAcceptST(int index)
;     iEngFutFol = index
;     SetMenuOptionValueST(EngageOptionList[iEngFutFol])
;   EndEvent
;   Event OnDefaultST()
;     iEngFutFol = 6
;     SetMenuOptionValueST(EngageOptionList[iEngFutFol])
;   EndEvent
;   Event OnHighlightST()
;     SetInfoText("When a futa engages a Follower, the Follower needs to be of this Gender.")
;   EndEvent
; EndState

State FutaMaleEngageWolf
  Event OnSelectST()
    bEngFutMalWolf = !bEngFutMalWolf
    SetToggleOptionValueST(bEngFutMalWolf)
  EndEvent
EndState

State FutaFemaleEngageWolf
  Event OnSelectST()
    bEngFutFemWolf = !bEngFutFemWolf
    SetToggleOptionValueST(bEngFutFemWolf)
  EndEvent
EndState

State FutaFutaEngageWolf
  Event OnSelectST()
    bEngFutFutWolf = !bEngFutFutWolf
    SetToggleOptionValueST(bEngFutFutWolf)
  EndEvent
EndState

State FutaCreatureEngageWolf
  Event OnSelectST()
    bEngFutCreaWolf = !bEngFutCreaWolf
    SetToggleOptionValueST(bEngFutCreaWolf)
  EndEvent
EndState
; -- Creature
State CreatPlayerEngageWolf
  Event OnSelectST()
    bEngCreaPlWolf = !bEngCreaPlWolf
    SetToggleOptionValueST(bEngCreaPlWolf)
  EndEvent
EndState

State CreatFollowerEngageWolf
  Event OnSelectST()
    bEngCreaFolWolf = !bEngCreaFolWolf
    SetToggleOptionValueST(bEngCreaFolWolf)
    If(bEngCreaFol)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "CreatFolEngageOptionWolf")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "CreatFolEngageOptionWolf")
    EndIf
  EndEvent
EndState

; State CreatFolEngageOption
;   Event OnMenuOpenST()
;     SetMenuDialogStartIndex(iEngCreaFol)
;     SetMenuDialogDefaultIndex(6)
;     SetMenuDialogOptions(EngageOptionList)
;   EndEvent
;   Event OnMenuAcceptST(int index)
;     iEngCreaFol = index
;     SetMenuOptionValueST(EngageOptionList[iEngCreaFol])
;   EndEvent
;   Event OnDefaultST()
;     iEngCreaFol = 6
;     SetMenuOptionValueST(EngageOptionList[iEngCreaFol])
;   EndEvent
;   Event OnHighlightST()
;     SetInfoText("When a Creat engages a Follower, the Follower needs to be of this Gender.")
;   EndEvent
; EndState

State CreatMaleEngageWolf
  Event OnSelectST()
    bEngCreaMalWolf = !bEngCreaMalWolf
    SetToggleOptionValueST(bEngCreaMalWolf)
  EndEvent
EndState

State CreatFemaleEngageWolf
  Event OnSelectST()
    bEngCreaFemWolf = !bEngCreaFemWolf
    SetToggleOptionValueST(bEngCreaFemWolf)
  EndEvent
EndState

State CreatFutaEngageWolf
  Event OnSelectST()
    bEngCreaFutWolf = !bEngCreaFutWolf
    SetToggleOptionValueST(bEngCreaFutWolf)
  EndEvent
EndState

State CreatCreatureEngageWolf
  Event OnSelectST()
    bEngCreaCreaWolf = !bEngCreaCreaWolf
    SetToggleOptionValueST(bEngCreaCreaWolf)
  EndEvent
EndState

; --------- Bunny
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
State EngagePlBunny
  Event OnSelectST()
    bEngagePlBunny = !bEngagePlBunny
    SetToggleOptionValueST(bEngagePlBunny)
    If(bEngagePlBunny)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "PreferPlBunny")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "PreferPlBunny")
    EndIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("Allow the Player to be engaged by other NPCs.\nThis Setting will evaluate the Player as a valid engagement Target even when their Gender doesnt match the Gender Condition set in \"Engage Options\" above.")
  EndEvent
EndState

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

State EngageFolBunny
  Event OnSelectST()
    bEngageFolBunny = !bEngageFolBunny
    SetToggleOptionValueST(bEngageFolBunny)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Allow Followers to be engaged by other NPCs.")
  EndEvent
EndState

State RespectFollowerGenderBunny
	Event OnSelectST()
		bRespFolGenBunny = !bRespFolGenBunny
		SetToggleOptionValueST(bRespFolGenBunny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("If enabled, Followers will ignore the Gender Setting below.")
	EndEvent
EndState

State EngageMaleBunny
	Event OnSelectST()
		bEngageMaleBunny = !bEngageMaleBunny
		SetToggleOptionValueST(bEngageMaleBunny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Allow male Actors to be engaged.")
	EndEvent
EndState

State EngageFemaleBunny
	Event OnSelectST()
		bEngageFemaleBunny = !bEngageFemaleBunny
		SetToggleOptionValueST(bEngageFemaleBunny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Allow female Actors to be engaged.")
	EndEvent
EndState

State EngageFutaBunny
	Event OnSelectST()
		bEngageFutaBunny = !bEngageFutaBunny
		SetToggleOptionValueST(bEngageFutaBunny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Allow futa Actors to be engaged.")
	EndEvent
EndState

State EngageCreatureBunny
	Event OnSelectST()
		bEngageCreatureBunny = !bEngageCreatureBunny
		SetToggleOptionValueST(bEngageCreatureBunny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Allow futa Actors to be engaged.")
	EndEvent
EndState
;	--------- Engagement Settings
State UseArousalBunny
  Event OnSelectST()
    bUseArousalBunny = !bUseArousalBunny
    SetToggleOptionValueST(bUseArousalBunny)
    If(bUseArousalBunny)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "ArousThreshBunny")
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "IgnoreVicArousalBunny")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "ArousThreshBunny")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "IgnoreVicArousalBunny")
    EndIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("If false, the Scan will pick up Actors without checking for their Arousal.")
  EndEvent
EndState

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

State useDistanceBunny
  Event OnSelectST()
    bUseDistBunny = !bUseDistBunny
    SetToggleOptionValueST(bUseDistBunny)
    If(bUseDistBunny)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "maxDistanceBunny")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "maxDistanceBunny")
    EndIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("If true, the mod wont match Actors that are too far away from each other.")
  EndEvent
endState

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

State UseLOSBunny
  Event OnSelectST()
    bUseLoSBunny = !bUseLoSBunny
    SetToggleOptionValueST(bUseLoSBunny)
  EndEvent
  Event OnHighlightST()
    SetInfoText("If false, Actors need to see each other in order to start a Scene.")
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
; --------- Filter
;Follower
State FolEngageBunny
  Event OnSelectST()
    bFolEngageBunny = !bFolEngageBunny
    SetToggleOptionValueST(bFolEngageBunny)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Allow Followers to engage others (based on the Settings below).")
  EndEvent
EndState

State RespFolGenAggrBunny
  Event OnSelectST()
    bRespFolGenAggrBunny = !bRespFolGenAggrBunny
    SetToggleOptionValueST(bRespFolGenAggrBunny)
  EndEvent
EndState
;Male
State MalePlayerEngageBunny
  Event OnSelectST()
    bEngMalPlBunny = !bEngMalPlBunny
    SetToggleOptionValueST(bEngMalPlBunny)
  EndEvent
EndState

State MalFollowerEngageBunny
  Event OnSelectST()
    bEngMalFolBunny = !bEngMalFolBunny
    SetToggleOptionValueST(bEngMalFolBunny)
    If(bEngMalFolBunny)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "MalFolEngageOptionBunny")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "MalFolEngageOptionBunny")
    EndIf
  EndEvent
EndState

; State MalFolEngageOption
;   Event OnMenuOpenST()
;     SetMenuDialogStartIndex(iEngMalFol)
;     SetMenuDialogDefaultIndex(6)
;     SetMenuDialogOptions(EngageOptionList)
;   EndEvent
;   Event OnMenuAcceptST(int index)
;     iEngMalFol = index
;     SetMenuOptionValueST(EngageOptionList[iEngMalFol])
;   EndEvent
;   Event OnDefaultST()
;     iEngMalFol = 6
;     SetMenuOptionValueST(EngageOptionList[iEngMalFol])
;   EndEvent
;   Event OnHighlightST()
;     SetInfoText("When a male engages a Follower, the Follower needs to be of this Gender.")
;   EndEvent
; EndState

State MaleMaleEngageBunny
  Event OnSelectST()
    bEngMalMalBunny = !bEngMalMalBunny
    SetToggleOptionValueST(bEngMalMalBunny)
  EndEvent
EndState

State MaleFemEngageBunny
  Event OnSelectST()
    bEngMalFemBunny = !bEngMalFemBunny
    SetToggleOptionValueST(bEngMalFemBunny)
  EndEvent
EndState

State MaleFutaEngageBunny
  Event OnSelectST()
    bEngMalFutBunny = !bEngMalFutBunny
    SetToggleOptionValueST(bEngMalFutBunny)
  EndEvent
EndState

State MaleCreatureEngageBunny
  Event OnSelectST()
    bEngMalCreaBunny = !bEngMalCreaBunny
    SetToggleOptionValueST(bEngMalCreaBunny)
  EndEvent
EndState
;Female
State FemalePlayerEngageBunny
  Event OnSelectST()
    bEngFemPlBunny = !bEngFemPlBunny
    SetToggleOptionValueST(bEngFemPlBunny)
  EndEvent
EndState

State FemalFollowerEngageBunny
  Event OnSelectST()
    bEngFemFolBunny = !bEngFemFolBunny
    SetToggleOptionValueST(bEngFemFolBunny)
    If(bEngFemFolBunny)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "FemalFolEngageOptionBunny")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "FemalFolEngageOptionBunny")
    EndIf
  EndEvent
EndState

; State FemalFolEngageOption
;   Event OnMenuOpenST()
;     SetMenuDialogStartIndex(iEngFemFol)
;     SetMenuDialogDefaultIndex(6)
;     SetMenuDialogOptions(EngageOptionList)
;   EndEvent
;   Event OnMenuAcceptST(int index)
;     iEngFemFol = index
;     SetMenuOptionValueST(EngageOptionList[iEngFemFol])
;   EndEvent
;   Event OnDefaultST()
;     iEngFemFol = 6
;     SetMenuOptionValueST(EngageOptionList[iEngFemFol])
;   EndEvent
;   Event OnHighlightST()
;     SetInfoText("When a female engages a Follower, the Follower needs to be of this Gender.")
;   EndEvent
; EndState

State FemaleMaleEngageBunny
  Event OnSelectST()
    bEngFemMalBunny = !bEngFemMalBunny
    SetToggleOptionValueST(bEngFemMalBunny)
  EndEvent
EndState

State FemaleFemEngageBunny
  Event OnSelectST()
    bEngFemFemBunny = !bEngFemFemBunny
    SetToggleOptionValueST(bEngFemFemBunny)
  EndEvent
EndState

State FemaleFutaEngageBunny
  Event OnSelectST()
    bEngFemFutBunny = !bEngFemFutBunny
    SetToggleOptionValueST(bEngFemFutBunny)
  EndEvent
EndState

State FemaleCreatEngageBunny
  Event OnSelectST()
    bEngFemCreaBunny = !bEngFemCreaBunny
    SetToggleOptionValueST(bEngFemCreaBunny)
  EndEvent
EndState
;Futa
State FutaPlayerEngageBunny
  Event OnSelectST()
    bEngFutPlBunny = !bEngFutPlBunny
    SetToggleOptionValueST(bEngFutPlBunny)
  EndEvent
EndState

State FutaFollowerEngageBunny
  Event OnSelectST()
    bEngFutFolBunny = !bEngFutFolBunny
    SetToggleOptionValueST(bEngFutFolBunny)
    If(bEngFutFolBunny)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "FutaFolEngageOptionBunny")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "FutaFolEngageOptionBunny")
    EndIf
  EndEvent
EndState

; State FutaFolEngageOption
;   Event OnMenuOpenST()
;     SetMenuDialogStartIndex(iEngFutFol)
;     SetMenuDialogDefaultIndex(6)
;     SetMenuDialogOptions(EngageOptionList)
;   EndEvent
;   Event OnMenuAcceptST(int index)
;     iEngFutFol = index
;     SetMenuOptionValueST(EngageOptionList[iEngFutFol])
;   EndEvent
;   Event OnDefaultST()
;     iEngFutFol = 6
;     SetMenuOptionValueST(EngageOptionList[iEngFutFol])
;   EndEvent
;   Event OnHighlightST()
;     SetInfoText("When a futa engages a Follower, the Follower needs to be of this Gender.")
;   EndEvent
; EndState

State FutaMaleEngageBunny
  Event OnSelectST()
    bEngFutMalBunny = !bEngFutMalBunny
    SetToggleOptionValueST(bEngFutMalBunny)
  EndEvent
EndState

State FutaFemaleEngageBunny
  Event OnSelectST()
    bEngFutFemBunny = !bEngFutFemBunny
    SetToggleOptionValueST(bEngFutFemBunny)
  EndEvent
EndState

State FutaFutaEngageBunny
  Event OnSelectST()
    bEngFutFutBunny = !bEngFutFutBunny
    SetToggleOptionValueST(bEngFutFutBunny)
  EndEvent
EndState

State FutaCreatureEngageBunny
  Event OnSelectST()
    bEngFutCreaBunny = !bEngFutCreaBunny
    SetToggleOptionValueST(bEngFutCreaBunny)
  EndEvent
EndState
; -- Creature
State CreatPlayerEngageBunny
  Event OnSelectST()
    bEngCreaPlBunny = !bEngCreaPlBunny
    SetToggleOptionValueST(bEngCreaPlBunny)
  EndEvent
EndState

State CreatFollowerEngageBunny
  Event OnSelectST()
    bEngCreaFolBunny = !bEngCreaFolBunny
    SetToggleOptionValueST(bEngCreaFolBunny)
    If(bEngCreaFol)
      SetOptionFlagsST(OPTION_FLAG_NONE, false, "CreatFolEngageOptionBunny")
    else
      SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "CreatFolEngageOptionBunny")
    EndIf
  EndEvent
EndState

; State CreatFolEngageOption
;   Event OnMenuOpenST()
;     SetMenuDialogStartIndex(iEngCreaFol)
;     SetMenuDialogDefaultIndex(6)
;     SetMenuDialogOptions(EngageOptionList)
;   EndEvent
;   Event OnMenuAcceptST(int index)
;     iEngCreaFol = index
;     SetMenuOptionValueST(EngageOptionList[iEngCreaFol])
;   EndEvent
;   Event OnDefaultST()
;     iEngCreaFol = 6
;     SetMenuOptionValueST(EngageOptionList[iEngCreaFol])
;   EndEvent
;   Event OnHighlightST()
;     SetInfoText("When a Creat engages a Follower, the Follower needs to be of this Gender.")
;   EndEvent
; EndState

State CreatMaleEngageBunny
  Event OnSelectST()
    bEngCreaMalBunny = !bEngCreaMalBunny
    SetToggleOptionValueST(bEngCreaMalBunny)
  EndEvent
EndState

State CreatFemaleEngageBunny
  Event OnSelectST()
    bEngCreaFemBunny = !bEngCreaFemBunny
    SetToggleOptionValueST(bEngCreaFemBunny)
  EndEvent
EndState

State CreatFutaEngageBunny
  Event OnSelectST()
    bEngCreaFutBunny = !bEngCreaFutBunny
    SetToggleOptionValueST(bEngCreaFutBunny)
  EndEvent
EndState

State CreatCreatureEngageBunny
  Event OnSelectST()
    bEngCreaCreaBunny = !bEngCreaCreaBunny
    SetToggleOptionValueST(bEngCreaCreaBunny)
  EndEvent
EndState


; ------------------------ Utility
; ----- Wolf
int Function CheckFlagArousalWolf()
  If(bUseArousalWolf)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

int Function CheckFlagDistanceWolf()
  If(bUseDistWolf)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

int Function PrefPlFlagWolf()
  If(bEngagePlWolf)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
EndFunction

int Function FlagDispWolf()
  If(bUseDispotionWolf)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

int Function EngMalFolFlagWolf()
  If(bEngMalFolWolf)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

int Function EngFemFolFlagWolf()
  If(bEngFemFolWolf)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

int Function EngFutFolFlagWolf()
  If(bEngFutFolWolf)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

; ----- Bunny
int Function CheckFlagArousalBunny()
  If(bUseArousalBunny)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

int Function CheckFlagDistanceBunny()
  If(bUseDistBunny)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

int Function PrefPlFlagBunny()
  If(bEngagePlBunny)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
EndFunction

int Function FlagDispBunny()
  If(bUseDispotionBunny)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

int Function EngMalFolFlagBunny()
  If(bEngMalFolBunny)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

int Function EngFemFolFlagBunny()
  If(bEngFemFolBunny)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction

int Function EngFutFolFlagBunny()
  If(bEngFutFolBunny)
    return OPTION_FLAG_NONE
  else
    return OPTION_FLAG_DISABLED
  EndIf
endFunction
