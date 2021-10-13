Scriptname SMMPlayer extends ReferenceAlias
{Polling Script}
; --------------- Properties
SMMMCM Property MCM Auto
Quest Property ScanQ Auto
Faction Property FriendFaction Auto
FormList Property FriendList Auto
Keyword[] Property LocationFriendly Auto
Keyword[] Property LocationHostile Auto
Keyword Property LocTypeDwelling Auto
Keyword Property LocTypeDungeon Auto
; --------------- Variables
int Property locProfile = -1 Auto Hidden
; --------------- Code
; =============================================================
; ===================================== CYCLE
; =============================================================
Event OnUpdate()
	If(DoScan())
		If(!ScanQ.Start())
			RegisterForSingleUpdate(MCM.iTickIntervall)
		else
			Debug.Debug.TraceConditional("[Scrappies] Checking Engagement", MCM.bPrintTraces)
			If(MCM.bPrintTraces)
				Debug.Notification("Checking Engagement..")
			EndIf
		EndIf
		;/ TODO create the Threading System here /;
	EndIf
EndEvent

bool Function DoScan()
	return !(MCM.bPaused || locProfile == -1 || MCM.locationTable[locProfile] == 0 || UI.IsMenuOpen("Dialogue Menu") || Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled())
EndFunction

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	If(!akNewLoc) ; Neutral Loc (Wilderness)
		locProfile = 0
	Else
		If(akNewLoc.HasKeyword(LocTypeDwelling)) ; Friendly Loc
			int i = 0
			While(!akNewLoc.HasKeyword(Locations[i]) && i < (LocationFriendly.length - 1))
				i += 1
			EndWhile
			locProfile = i + 1
		ElseIf(akNewLoc.HasKeyword(LocTypeDungeon)) ; Hostile Loc
			int i = 0
			While(!akNewLoc.HasKeyword(Locations[i]) && i < (LocationHostile.length - 1))
				i += 1
			EndWhile
			locProfile = i + 1 + LocationFriendly.length
		else
			locProfile = -1
		EndIf
	EndIf
EndEvent

; =============================================================
; ===================================== START UP
; =============================================================
Event OnInit()
	OnPlayerLoadGame()
EndEvent

Event OnPlayerLoadGame()
	If(!MCM.bPaused)
		RegisterForSingleUpdate(MCM.iTickIntervall)
	EndIf
	RegisterForKey(MCM.iPauseKey)
	int i = 0
  While(i < FriendList.GetSize())
    Faction tmpFac = FriendList.GetAt(i) as Faction
    tmpFac.SetAlly(FriendFaction, true, true)
		i += 1
  EndWhile
EndEvent

Event OnKeyDown(int keyCode)
	If(MCM.bPaused)
		MCM.bPaused = false
		RegisterForSingleUpdate(MCM.iTickIntervall)
	else
		MCM.bPaused = true
		UnregisterForUpdate()
	EndIf
EndEvent

Function ResetKey(int newKeyCode)
	UnregisterForAllKeys()
	RegisterForKey(newKeyCode)
EndFunction




;/ -------------------------- Properties
RMMMCM Property MCM Auto
RMMScan Property Scan Auto

Actor Property PlayerRef Auto
Quest Property ScanQ Auto
Faction Property FriendFaction Auto
Formlist Property FriendList Auto
Spell Property RemoveFriendFac Auto

Keyword Property LocTypeSettlement Auto
Keyword Property LocTypeDungeon Auto

Keyword Property LocTypeDragonLair Auto
Keyword Property LocTypeBanditCamp Auto
Keyword Property LocTypeGiantCamp Auto
Keyword Property LocTypeMilitaryFort Auto
Keyword Property LocTypeClearable Auto
Keyword Property LocSetNordicRuin Auto
Keyword Property LocSetDwarvenRuin Auto
Keyword Property LocSetCave Auto
Keyword Property LocTypeFalmerHive Auto
Keyword Property LocTypeHagravenNest Auto

Keyword Property LocTypeCity Auto
Keyword Property LocTypeTown Auto
Keyword Property LocTypeDwelling Auto
Keyword Property LocTypeInn Auto
Keyword Property LocTypePlayerHouse Auto

; -------------------------- Variables
bool Property modPaused = true Auto Hidden
bool SkipScan = false
string Property Profile Auto Hidden
bool Property SaveLoc = false Auto Hidden

; -------------------------- Properties
Event OnInit()
	OnPlayerLoadGame()
EndEvent

Event OnPlayerLoadGame()
	If(!modPaused)
		RegisterForSingleUpdate(MCM.iTickIntervall)
	EndIf
	RegisterForKey(MCM.iPauseKey)
	RegisterForModEvent("HookAnimationEnding_ScrappieMM", "ClearFactions")
	int Count = FriendList.GetSize()
  While(Count)
    Count -= 1
    Faction tmpFac = FriendList.GetAt(Count) as Faction
    tmpFac.SetAlly(FriendFaction, true, true)
  EndWhile
EndEvent

Event OnKeyDown(int keyCode)
	If(modPaused)
		modPaused = false
		RegisterForSingleUpdate(MCM.iTickIntervall)
	else
		modPaused = true
		UnregisterForUpdate()
	EndIf
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	If(modPaused)
		return
	EndIf
	SaveLoc = false
	SkipScan = true
	If(akNewLoc == none)	;	Wilderness
		If(MCM.iWildIndex != 0)
			SkipScan = false
			Profile = MCM.ProfileList[MCM.iWildIndex]
		EndIf
	else	;	FriendlyLocs
		If(akNewLoc.HasKeyword(LocTypePlayerHouse))
			If(MCM.iPlayerHomeIndex != 0)
				SkipScan = false
				Profile = MCM.ProfileList[MCM.iPlayerHomeIndex]
				SaveLoc = true
			EndIf
		ElseIf(akNewLoc.HasKeyword(LocTypeInn))
			If(MCM.iInnIndex != 0)
				SkipScan = false
				Profile = MCM.ProfileList[MCM.iInnIndex]
				SaveLoc = true
			EndIf
		ElseIf(akNewLoc.HasKeyword(LocTypeSettlement))
			If(MCM.iSettlementIndex != 0)
				SkipScan = false
				Profile = MCM.ProfileList[MCM.iSettlementIndex]
				SaveLoc = true
			EndIf
		ElseIf(akNewLoc.HasKeyword(LocTypeCity))
			If(MCM.iCityIndex != 0)
				SkipScan = false
				Profile = MCM.ProfileList[MCM.iCityIndex]
				SaveLoc = true
			EndIf
		ElseIf(akNewLoc.HasKeyword(LocTypeTown))
			If(MCM.iTownIndex != 0)
				SkipScan = false
				Profile = MCM.ProfileList[MCM.iTownIndex]
				SaveLoc = true
			EndIf
		ElseIf(akNewLoc.HasKeyword(LocTypeDwelling))
			If(MCM.iFriendLocIndex != 0)
				SkipScan = false
				Profile = MCM.ProfileList[MCM.iFriendLocIndex]
				SaveLoc = true
			EndIf
		ElseIf(akNewLoc.HasKeyword(LocTypeDungeon))	;	Hostile Locs
			If(akNewLoc.IsCleared())
				If(MCM.iIfClearedIndex != 0)
					SkipScan = false
					Profile = MCM.ProfileList[MCM.iTownIndex]
				EndIf
			ElseIf(akNewLoc.HasKeyword(LocTypeDragonLair))
				If(MCM.iDragonIndex != 0)
					SkipScan = false
					Profile = MCM.ProfileList[MCM.iDragonIndex]
				endIf
			ElseIf(akNewLoc.HasKeyword(LocTypeBanditCamp))
				If(MCM.iBanditIndex != 0)
					SkipScan = false
					Profile = MCM.ProfileList[MCM.iBanditIndex]
				endIf
			ElseIf(akNewLoc.HasKeyword(LocTypeGiantCamp))
				If(MCM.iGiantIndex != 0)
					SkipScan = false
					Profile = MCM.ProfileList[MCM.iGiantIndex]
				endIf
			ElseIf(akNewLoc.HasKeyword(LocTypeMilitaryFort))
				If(MCM.iFortIndex != 0)
					SkipScan = false
					Profile = MCM.ProfileList[MCM.iFortIndex]
				endIf
			ElseIf(akNewLoc.HasKeyword(LocSetNordicRuin))
				If(MCM.iNoridRuinIndex)
					SkipScan = false
					Profile = MCM.ProfileList[MCM.iNoridRuinIndex]
				endIf
			ElseIf(akNewLoc.HasKeyword(LocSetDwarvenRuin))
				If(MCM.iDwarvenRuinIndex != 0)
					SkipScan = false
					Profile = MCM.ProfileList[MCM.iDwarvenRuinIndex]
				endIf
			ElseIf(akNewLoc.HasKeyword(LocSetCave))
				If(MCM.iCavesIndex != 0)
					SkipScan = false
					Profile = MCM.ProfileList[MCM.iCavesIndex]
				endIf
			ElseIf(akNewLoc.HasKeyword(LocTypeFalmerHive))
				If(MCM.iFalmerIndex != 0)
					SkipScan = false
					Profile = MCM.ProfileList[MCM.iFalmerIndex]
				endIf
			ElseIf(akNewLoc.HasKeyword(LocTypeHagravenNest))
				If(MCM.iHagravenIndex != 0)
					SkipScan = false
					Profile = MCM.ProfileList[MCM.iHagravenIndex]
				endIf
			EndIf
		endIf
	endIf
	RegisterForSingleUpdate(MCM.iTickIntervall)
EndEvent

Event OnUpdate()
	If(DoScan())
		If(ScanQ.Start())
			If(MCM.bPrintTraces)
				Debug.Notification("Checking Engagement..")
			EndIf
			If(Scan.CheckForEngagement() > -1)
				If(MCM.iScanCooldown > 0)
					RegisterForSingleUpdateGameTime(MCM.iScanCooldown)
				else
					RegisterForSingleUpdate(MCM.iTickIntervall)
				EndIf
			else
				RegisterForSingleUpdate(MCM.iTickIntervall*2)
			EndIf
			Utility.Wait(0.5)
			ScanQ.Stop()
		else
			RegisterForSingleUpdate(MCM.iTickIntervall)
		EndIf
	else
		RegisterForSingleUpdate(MCM.iTickIntervall*1.5)
	EndIf
endEvent

Event OnUpdateGameTime()
	If(!modPaused)
		RegisterForSingleUpdate(MCM.iTickIntervall)
	EndIf
EndEvent

bool Function DoScan()
	If(SkipScan)
		return false
		;/ COMBAK wait for pinkfuffs response. Ayah.. ;
	ElseIf(UI.IsMenuOpen("Dialogue Menu") || Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled())
		return false
	EndIf
	If(Profile == "Sheep")
		If((Utility.RandomInt(1, 100) > MCM.iEngageChanceSheep))
			return false
		ElseIf(MCM.bCombatSkipSheep && PlayerRef.IsInCombat())
			return false
		endIf
	ElseIf(Profile == "Wolf")
		If((Utility.RandomInt(1, 100) > MCM.iEngageChanceWolf))
			return false
		ElseIf(MCM.bCombatSkipWolf && PlayerRef.IsInCombat())
			return false
		endIf
	ElseIf(Profile == "Bunny")
		If((Utility.RandomInt(1, 100) > MCM.iEngageChanceBunny))
			return false
		ElseIf(MCM.bCombatSkipBunny && PlayerRef.IsInCombat())
			return false
		endIf
	EndIf
	return true
endFunction

Event ClearFactions(int tid, bool hasPlayer)
	Debug.Notification("SL Event fired")
	sslThreadController Thread = Scan.SL.GetController(tid)
	Actor[] Acteurs = Thread.Positions
	int count = Acteurs.Length
	Debug.Notification(Count)
	While(Count)
		Count -= 1
		RemoveFriendFac.Cast(Acteurs[Count])
	EndWhile
EndEvent
/;
