Scriptname SMMPlayer extends ReferenceAlias
{Polling Script}

SMMMCM Property MCM Auto
Quest Property Scan Auto
Actor Property PlayerRef Auto
GlobalVariable Property GameHour Auto
FormList Property FriendList Auto
Faction Property FriendFaction Auto
Keyword Property ScanThread Auto
; -- LocTypes
; Dwellings
Keyword Property LocTypeDwelling Auto
Keyword Property LocTypeCastle Auto
Keyword Property LocTypeCemetery Auto
Keyword Property LocTypeCity Auto
Keyword Property LocTypeGuild Auto
Keyword Property LocTypeHouse Auto
Keyword Property LocTypeInn Auto
Keyword Property LocTypeMine Auto
Keyword Property LocTypeOrcStronghold Auto
Keyword Property LocTypePlayerHouse Auto
Keyword Property LocTypeSettlement Auto
Keyword Property LocTypeTemple Auto
Keyword Property LocTypeTown Auto
Keyword Property LocTypeJail Auto ; <- Natively excluded to avoid Guards unlocking Cell Doors
; Dungeons
Keyword Property LocTypeDungeon Auto
Keyword Property LocTypeAnimalDen Auto
Keyword Property LocTypeBanditCamp Auto
Keyword Property LocTypeDraugrCrypt Auto
Keyword Property LocTypeDwarvenAutomatons Auto
Keyword Property LocTypeFalmerHive Auto
Keyword Property LocTypeForswornCamp Auto
Keyword Property LocTypeHagravenNest Auto
Keyword Property LocTypeMilitaryFort Auto
Keyword Property LocTypeSprigganGrove Auto
Keyword Property LocTypeVampireLair Auto
Keyword Property LocTypeWarlockLair Auto
Keyword Property LocTypeWerebearLair Auto
Keyword Property LocTypeWerewolfLair Auto
; --------------- Variables
String locProfile = "$SMM_Disabled"

; =============================================================
; ===================================== START UP
; =============================================================
Event OnInit()
  OnPlayerLoadGame()
EndEvent

Event OnPlayerLoadGame()
  If(!MCM.bPaused)
    RegisterForSingleUpdate(MCM.iTickInterval)
  EndIf
  RegisterForKey(MCM.iPauseKey)

  ; Check Mods
 	If(Game.GetModByName("SexLab.esm") == 255)
    MCM.bSLAllowed = false
    MCM.bBestiality = false
    MCM.bSupportFilter = false
  EndIf
	If(Game.GetModByName("OStim.esp") == 255)
    MCM.bOStimAllowed = false
  ElseIf(SMMOstim.GetVersion() < 26)
    MCM.bOStimAllowed = false
    Debug.MessageBox("ScRappies Matchmaker requires OStim API Version 26 or higher. Your Version is: " + SMMOstim.GetVersion())
  EndIf
  If(!MCM.bSLAllowed && !MCM.bOStimAllowed)
    Debug.MessageBox("ScRappies Matchmaker requires either SexLab Framework or OStim to be installed.")
  EndIf

  ; Reset Cooldowns
  ; JValue.writeToFile(JValue.readFromFile("Data\\SKSE\\SMM\\Definition\\Blank.json"), "Data\\SKSE\\SMM\\Definition\\Cooldowns.json")

  ; Friend Faction
  int i = 0
  While(i < FriendList.GetSize())
    Faction tmpFac = FriendList.GetAt(i) as Faction
    tmpFac.SetAlly(FriendFaction, true, true)
    i += 1
  EndWhile

  RegisterForModEvent("dhlp-Suspend", "SuspendMod")
  RegisterForModEvent("dhlp-Resume", "ResumeMod")
EndEvent

Event OnKeyDown(int keyCode)
  MCM.bPaused = !MCM.bPaused
  If(MCM.bPaused)
    Debug.Notification("ScRappies Matchmaker paused")
  Else
    Debug.Notification("ScRappies Matchmaker enabled")
    RegisterForSingleUpdate(MCM.iTickInterval)
  EndIf
EndEvent

Function ResetKey(int newKeyCode)
  UnregisterForAllKeys()
  RegisterForKey(newKeyCode)
EndFunction

; =============================================================
; ===================================== CYCLE
; =============================================================
Event OnUpdate()
  ; Debug.Notification("<SMM> Scanning with Profile: { " + locProfile + " }")
  If(MCM.bPaused || locProfile == "$SMM_Disabled")
    Debug.Trace("[SMM] <Player> Mod Paused or Location disabled")
    return
  ElseIf(UI.IsMenuOpen("Dialogue Menu") || Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled())
    Debug.Trace("[SMM] <Player> Player in Menu")
    return
  EndIf
  ; Get Profile for the current Location
  Debug.Trace("[SMM] <Player> OnUpdate with Profile: " + locProfile)
  int jProfile = JValue.readFromFile("Data\\SKSE\\SMM\\" + locProfile + ".json")
  float gh = GameHour.Value
  If(Utility.RandomFloat(0, 99.9) >= JMap.getInt(jProfile, "fEngageChance") || JMap.getInt(jProfile, "bCombatSkip") && PlayerRef.IsInCombat() || JMap.getFlt(jProfile, "fEngageTimeMin") > gh || JMap.getFlt(jProfile, "fEngageTimeMax") < gh)
    Debug.Trace("[SMM] <Player> Invalid System Checks")
    return
  EndIf
  ; Base checks done, Scan for near NPC & hand over to Thread, otherwise register for next Poll
  If(ScanThread.SendStoryEventAndWait(aiValue1 = jProfile))
    Debug.Trace("[SMM] <Player> Checking Engagement")
  Else
    RegisterForSingleUpdate(MCM.iTickInterval)
  EndIf
EndEvent

; =============================================================
; ===================================== LOCATION
; =============================================================
; Update the Profile for this Location. Index for Location in Translation Files
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
  If(akOldLoc == akNewLoc)
    return
  EndIf
  int p
  If(!akNewLoc) ; Wilderness
    p = 0
  ElseIf(akNewLoc.HasKeyword(LocTypeDungeon)) ; Friendly Loc
    If(akNewLoc.HasKeyword(LocTypeWerebearLair))
      p = 25
    ElseIf(akNewLoc.HasKeyword(LocTypeWerewolfLair))
      p = 23
    ElseIf(akNewLoc.HasKeyword(LocTypeHagravenNest))
      p = 21
    ElseIf(akNewLoc.HasKeyword(LocTypeSprigganGrove))
      p = 19
    ElseIf(akNewLoc.HasKeyword(LocTypeAnimalDen))
      p = 17
    ElseIf(akNewLoc.HasKeyword(LocTypeMilitaryFort))
      p = 9
    ElseIf(akNewLoc.HasKeyword(LocTypeBanditCamp))
      p = 1
    ElseIf(akNewLoc.HasKeyword(LocTypeForswornCamp))
      p = 3
    ElseIf(akNewLoc.HasKeyword(LocTypeWarlockLair))
      p = 5
    ElseIf(akNewLoc.HasKeyword(LocTypeVampireLair))
      p = 7
    ElseIf(akNewLoc.HasKeyword(LocTypeFalmerHive))
      p = 15
    ElseIf(akNewLoc.HasKeyword(LocTypeDraugrCrypt))
      p = 11
    ElseIf(akNewLoc.HasKeyword(LocTypeDwarvenAutomatons))
      p = 13
    Else
      p = 27
    EndIf
  Else ; Considering everything here Friendly
    If(akNewLoc.HasKeyword(LocTypeJail))
      locprofile =  "$SMM_Disabled"
    ElseIf(akNewLoc.HasKeyword(LocTypeInn))
      p = 14
    ElseIf(akNewLoc.HasKeyword(LocTypePlayerHouse))
      p = 16
    ElseIf(akNewLoc.HasKeyword(LocTypeGuild))
      p = 20
    ElseIf(akNewLoc.HasKeyword(LocTypeCemetery))
      p = 22
    ElseIf(akNewLoc.HasKeyword(LocTypeMine))
      p = 24
    ElseIf(akNewLoc.HasKeyword(LocTypeTemple))
      p = 18
    ElseIf(akNewLoc.HasKeyword(LocTypeCastle))
      p = 10
    ElseIf(akNewLoc.HasKeyword(LocTypeOrcStronghold))
      p = 8
    ElseIf(akNewLoc.HasKeyword(LocTypeCity))
      p = 2
    ElseIf(akNewLoc.HasKeyword(LocTypeTown))
      p = 4
    ElseIf(akNewLoc.HasKeyword(LocTypeSettlement))
      p = 6
    ElseIf(akNewLoc.HasKeyword(LocTypeHouse) || PlayerRef.GetParentCell().IsInterior()) 
      p = 12
    Else
      p = 26
    EndIf
  EndIf
  Debug.Trace("[SMM] Changed Location <Index " + p + " >")
  locProfile = MCM.lProfiles[p]
  If(MCM.bLocationScan)
    OnUpdate()
  EndIf
EndEvent

Event SuspendMod(string asEventName, string asStringArg, float afNumArg, form akSender)
  MCM.bPaused = true
EndEvent

Event ResumeMod(string asEventName, string asStringArg, float afNumArg, form akSender)
  MCM.bPaused = false
  RegisterForSingleUpdate(MCM.iTickInterval)
EndEvent