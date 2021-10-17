Scriptname SMMPlayer extends ReferenceAlias
{Polling Script}

SMMMCM Property MCM Auto
Quest Property Scan Auto
FormList Property FriendList Auto
Faction Property FriendFaction Auto
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
String Property locProfile = "" Auto Hidden

; =============================================================
; ===================================== START UP
; =============================================================
Event OnInit()
	OnPlayerLoadGame()
EndEvent

Event OnPlayerLoadGame()
	Utility.Wait(3)
	ContinueScan()
	RegisterForKey(MCM.iPauseKey)
	int i = 0
  While(i < FriendList.GetSize())
    Faction tmpFac = FriendList.GetAt(i) as Faction
    tmpFac.SetAlly(FriendFaction, true, true)
		i += 1
  EndWhile
EndEvent

Event OnKeyDown(int keyCode)
	MCM.bPaused = !MCM.bPaused
	ContinueScan()
EndEvent

Function ResetKey(int newKeyCode)
	UnregisterForAllKeys()
	RegisterForKey(newKeyCode)
EndFunction

; =============================================================
; ===================================== CYCLE
; =============================================================

Event OnUpdate()
	If(locProfile == "")
		return
	ElseIf(Scan.Start())
		UnregisterForUpdate()
		Debug.Trace("[Scrappies] Checking Engagement")
	EndIf
EndEvent

Function ContinueScan()
	If(DoScan())
		RegisterForUpdate(MCM.iTickIntervall)
	Else
		UnregisterForUpdate()
	EndIf
EndFunction

bool Function DoScan()
	return !(MCM.bPaused || locProfile == "" || UI.IsMenuOpen("Dialogue Menu") || Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled())
EndFunction

; =============================================================
; ===================================== LOCATION
; =============================================================

; Update the Profile for this Location. Index for Location in Translation Files
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	int p
	If(!akNewLoc) ; Wilderness
		p = 0
	ElseIf(akNewLoc.HasKeyword(LocTypeDwelling)) ; Friendly Loc
		If(akNewLoc.HasKeyword(LocTypeJail))
			locprofile =  ""
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
		ElseIf(akNewLoc.HasKeyword(LocTypeHouse))
			p = 12
		ElseIf(akNewLoc.HasKeyword(LocTypeOrcStronghold))
			p = 8
		ElseIf(akNewLoc.HasKeyword(LocTypeCity))
			p = 2
		ElseIf(akNewLoc.HasKeyword(LocTypeTown))
			p = 4
		ElseIf(akNewLoc.HasKeyword(LocTypeSettlement))
			p = 6
		Else
			p = 26
		EndIf
	Else ; Considering everything here Hostile
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
	EndIf
	Debug.Trace("[ScrappiesMM] Changed Location <Index " + p + " >")
	locProfile = MCM.lProfiles[p]
EndEvent

;/ -------------------------- SMM V2
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
/;
