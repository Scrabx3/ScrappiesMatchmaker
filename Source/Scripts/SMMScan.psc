Scriptname SMMScan extends Quest
{Mainscript for Starting Animations}

SMMPlayer Property PlayerScr Auto
SMMMCM Property MCM Auto
FavorJarlsMakeFriendsScript Property ThaneVars Auto
Actor Property PlayerRef Auto
Faction Property PlayerFollowerFaction Auto
Faction Property GuardFaction Auto
Keyword Property ActorTypeNPC Auto
Keyword Property ArmorHeavy Auto
Keyword Property ArmorLight Auto
Keyword Property ArmorClothing Auto
Keyword Property ArmorHelmet Auto
Keyword Property ThreadKW Auto
GlobalVariable Property GameHour Auto
GlobalVariable Property GameDaysPassed Auto
AssociationType Property Spouse Auto
Race[] Property RaceList Auto
Location[] Property Holds Auto
{Reach, Rift, Haarfinger, Whiterun, Eastmarch, Hjaalmach, Pale, Winterhold, Falkreath}
; --------------- Variables
String filePath = "Data\\SKSE\\SMM\\"
int jProfile

; --------------- Code
Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  If(!IsRunning())
    return
  EndIf
  jProfile = aiValue1
  ; Create Scene
  Actor[] ColAct = GetActors()
  If(!colAct.Length)
    Debug.Trace("[SMM] <Scan> No Actors found to animate")
    Stop()
    return
  Else
    Debug.Trace("[SMM] <Scan> Actors collected: " + ColAct.Length)
  EndIf
  int i = 0
  While(i < MCM.iMaxScenese)
    Debug.Trace("[SMM] <Scan> Building Scene " + (i + 1) + "/" + MCM.iMaxScenese)
    ; Collect Initiator
    Actor init = GetInitiator(ColAct)
    If(!init)
      Debug.Trace("[SMM] <Scan> Found no Initiator")
      Stop()
      return
    EndIf
    Debug.Trace("[SMM] <Scan> Found Initiator: " + init)
    colAct = PapyrusUtil.RemoveActor(colAct, PlayerRef)
    int numActors = calcThreesome(colAct.Length + 1)
    If(numActors < 2)
      Debug.Trace("[SMM] <Scan> Invalid Number of Actors")
      If(Utility.RandomFloat(0, 99.5) < MCM.fAFMasturbate)
        ThreadKW.SendStoryEvent(akRef1 = init)
      EndIf
      Stop()
      return
    EndIf
    int jScene = JValue.retain(JArray.objectWithSize(numActors), "SMMThread")
    JArray.setForm(jScene, 0, init)
    ; Collect Partners
    int n = 0
    int nn = 1
    While(n < ColAct.Length && nn < numActors)
      If(ValidPartner(ColAct[n]) && isValidGenderCombination(init, ColAct[n]) && ValidMatch(init, ColAct[n]))
        JArray.setForm(jScene, nn, ColAct[n])
        nn += 1
      EndIf
      n += 1
    EndWhile
    If(nn > 1)
      Debug.Trace("[SMM] <Scan> Attempting to start Scene with " + nn + " Participants")
      If(!ThreadKW.SendStoryEventAndWait(aiValue1 = jScene))
        Debug.Trace("[SMM] <Scan> Failed to start Scene")
        JValue.release(jScene)
        Stop()
        return
      EndIf
    Else
      Debug.Trace("[SMM] <Scan> Not enough Participants found")
    EndIf
    i += 1
  EndWhile
  Stop()
EndEvent

bool Function ValidMatch(Actor init, Actor partner)
  If(partner.GetDistance(init) > JMap.getFlt(jProfile, "fDistance"))
    return false
  EndIf
  bool consent = JMap.getInt(jProfile, "bConsent")
  If(JMap.getInt(jProfile, "bLOS") && !(partner.HasLOS(init) || consent && init.HasLOS(partner)))
    return false
  EndIf
  bool unique = partner.GetLeveledActorBase().IsUnique() && init.GetLeveledActorBase().IsUnique()
  int dC
  int dI
  If(!unique)
    dC = 0
    dI = 0
  Else
    dC = partner.GetRelationshipRank(init)
    dI = init.GetRelationshipRank(partner)
  EndIf
  If(unique && dC < JMap.getInt(jProfile, "iDisposition") && dI < JMap.getInt(jProfile, "iDisposition"))
    return false
  EndIf
  int incest = JMap.getInt(jProfile, "lIncest")
  If(incest == 0 && partner.HasFamilyRelationship(init) && !partner.HasAssociation(Spouse, init) || incest == 1 && partner.HasParentRelationship(init))
    return false
  EndIf
  return false
EndFunction

; ===============================================================
; =============================  INITIATOR
; ===============================================================
Actor Function GetInitiator(Actor[] them)
  int i = 0
  While(i < them.Length)
    If(ValidInitiator(them[i]))
      Actor ret = them[i]
      them = PapyrusUtil.RemoveActor(them, ret)
      return ret
    EndIf
    i += 1
  EndWhile
  return none
EndFunction

bool Function ValidInitiator(Actor that)
  bool fol = that.IsInFaction(PlayerFollowerFaction) || that.IsPlayerTeammate()
  int jTmp = JMap.getObj(jProfile, "bGenderPartner")
  If(fol && !JArray.getInt(jTmp, 0) || !fol && !JArray.getInt(jTmp, GetActorType(that) + 1))
    return false
  EndIf
  int arousal = GetArousal(that)
  bool aroused = that == PlayerRef && arousal >= JMap.getInt(jprofile, "iArousalInitPl") || fol && arousal >= JMap.getInt(jprofile, "iArousalInitFol") || arousal >= JMap.getInt(jprofile, "iArousalInit")
  int alg = JMap.getInt(jProfile, "lAdvInit", 0)
  If(alg != 0)
    int p = 0
    int[] v
    If(alg == 1)
      v = JArray.asIntArray(JMap.getObj(jProfile, "ReqAPoints"))
    Else
      v = JArray.asIntArray(JMap.getObj(jProfile, "cAChances"))
    EndIf
    bool[] c = new bool[14]
    c[0] = GameHour.Value >= MCM.fDuskTime || GameHour.Value < MCM.fDawnTime
    c[1] = IsThane(that)
    c[2] = aroused
    c[3] = !(that.WornHasKeyword(ArmorLight) || that.WornHasKeyword(ArmorHeavy) || that.WornHasKeyword(ArmorClothing))
    c[4] = !that.WornHasKeyword(ArmorHelmet)
    c[5] = !that.GetEquippedObject(0) && !that.GetEquippedObject(1)
    c[6] = !that.IsWeaponDrawn()
    c[7] = MiscUtil.ScanCellNPCsByFaction(GuardFaction, that).Length == 0
    c[8] = that.GetActorValuePercentage("Health") < JMap.getFlt(jProfile, "rHealthThresh")
    c[9] = that.GetActorValuePercentage("Stamina") < JMap.getFlt(jProfile, "rStaminaThresh") || that.GetActorValuePercentage("Magicka") < JMap.getFlt(jProfile, "rMagickaThresh")
    c[10] = that.WornHasKeyword(Keyword.GetKeyword("zad_lockable")) || that.WornHasKeyword(Keyword.GetKeyword("ToysToy")) || that.WornHasKeyword(Keyword.GetKeyword("zbfWornDevice"))
    c[11] = c[10] && that.WornHasKeyword(Keyword.GetKeyword("zad_DeviousHeavyBondage")) || (Quest.GetQuest("toysframework") as ToysFramework).RestrainedActive || that.WornHasKeyword(Keyword.GetKeyword("zbfEffectWrist"))
    c[12] = c[10] && that.WornHasKeyword(Keyword.GetKeyword("zad_DeviousCollar")) || that.WornHasKeyword(Keyword.GetKeyword("ToysType_Neck")) || that.WornHasKeyword(Keyword.GetKeyword("zbfWornCollar"))
    int i = 0
    While(i < c.Length)
      If(c[i])
        If(alg == 2) ; Chance Adjust
          p += v[i]
        ElseIf(v[i] == 0) ; Overwrite
          return true
        ElseIf(v[i] != 1) ; Points Adjust (1 <=> Mandatory)
          p += 5 - v[i]
        EndIf
      ElseIf(alg == 1 && v[i] == 1) ; Mandatory False
        return false
      EndIf
      i += 1
    EndWhile
    If(alg == 1)
      return p >= JMap.getInt(jProfile, "iReqPoints")
    Else
      return Utility.RandomInt(0, 99) < p + JMap.getInt(jProfile, "cBaseChance")
    EndIf
  EndIf
  return aroused
EndFunction

; ===============================================================
; =============================  PARTNER
; ===============================================================
bool Function ValidPartner(Actor that)
  bool fol = that.IsInFaction(PlayerFollowerFaction) || that.IsPlayerTeammate()
  int j = JMap.getObj(jProfile, "bGenderPartner")
  If(fol && !JArray.getInt(j, 0) || !fol && !JArray.getInt(j, GetActorType(that) + 1))
    return false
  EndIf
  int arousal = GetArousal(that)
  If(fol)
    return arousal >= JMap.getInt(jprofile, "iArousalPartnerFol")
  Else
    return arousal >= JMap.getInt(jprofile, "iArousalPartner")
  EndIf
  return false
EndFunction

; ===============================================================
; =============================  ADVANCED CONDITIONING
; ===============================================================
bool Function IsThane(Actor that)
  If(that != PlayerRef)
    return false
  EndIf
  If(that.IsInLocation(Holds[0]))
    return ThaneVars.ReachImpGetOutofJail > 0 || ThaneVars.ReachSonsGetOutofJail > 0
  ElseIf(that.IsInLocation(Holds[1]))
    return ThaneVars.RiftImpGetoutofJail > 0 || ThaneVars.RiftSonsGetOutofJail > 0
  ElseIf(that.IsInLocation(Holds[2]))
    return ThaneVars.HaafingarImpGetOutofJail > 0 || ThaneVars.HaafingarSonsGetOutofJail > 0
  ElseIf(that.IsInLocation(Holds[3]))
    return ThaneVars.WhiterunImpGetOutofJail > 0 || ThaneVars.WhiterunSonsGetOutofJail > 0
  ElseIf(that.IsInLocation(Holds[4]))
    return ThaneVars.EastmarchImpGetOutofJail > 0 || ThaneVars.EastmarchSonsGetOutofJail > 0
  ElseIf(that.IsInLocation(Holds[5]))
    return ThaneVars.HjaalmarchImpGetOutofJail > 0 || ThaneVars.HjaalmarchSonsGetOutofJail > 0
  ElseIf(that.IsInLocation(Holds[6]))
    return ThaneVars.PaleImpGetOutofJail > 0 || ThaneVars.PaleSonsGetOutofJail > 0
  ElseIf(that.IsInLocation(Holds[7]))
    return ThaneVars.WinterholdImpGetOutofJail > 0 || ThaneVars.WinterholdSonsGetOutofJail > 0
  ElseIf(that.IsInLocation(Holds[8]))
    return ThaneVars.FalkreathImpGetOutofJail > 0 || ThaneVars.FalkreathSonsGetOutofJail > 0
  EndIf
  return false
EndFunction

bool Function IsBound(Actor that)
  return false
EndFunction
; ===============================================================
; =============================  UTILITY
; ===============================================================
int Function calcThreesome(int cap)
  If(cap < 3)
    Debug.Trace("[SMM] <Scan> Allowed Number of Participants: " + i + "; Cap: " + cap)
    return cap
  EndIf
  int[] weights = MCM.getXsomeWeight()
  int allCells = 0
  int i = 0
  While(i < weights.length && i < cap)
    allCells += weights[i]
    i += 1
  EndWhile
  int thisCell = Utility.RandomInt(1, allCells)
  int sol = 0
  i = 0
  While(sol < thisCell)
    sol += weights[i]
    i += 1
  EndWhile
  i += 1 ; Return number of partners not chamber. (1st Chamber <=> 2some, 2nd chamber <=> 3some, ...)
  Debug.Trace("[SMM] <Scan> Allowed Number of Participants: " + i + "; Cap: " + cap)
  return i
EndFunction

int Function GetArousal(Actor that)
  If(MCM.bSLAllowed)
    return SMMSexlab.GetArousal(that)
  ElseIf(that.HasKeyword(ActorTypeNPC) && MCM.bOStimAllowed)
    return SMMOstim.GetArousal(that)
  EndIf
  return -1
EndFunction

;0 - Male, 1 - Female, 2 - Futa, 3 - Male Creature, 4 - Female Creature
int Function GetActorType(Actor me)
  If(MCM.bSLAllowed)
    return SMMSexLab.getActorType(me)
  else
    If(me.HasKeyword(ActorTypeNPC))
      return me.GetLeveledActorBase().GetSex()
    else
      return 3
    EndIf
  EndIf
endFunction

bool Function isFollower(Actor that)
  return that.IsInFaction(PlayerFollowerFaction)
EndFunction

bool Function isValidGenderCombination(Actor init, Actor partner)
  bool isFolI = init.IsInFaction(PlayerFollowerFaction) || init.IsPlayerTeammate()
  If(partner.IsInFaction(PlayerFollowerFaction) || partner.IsPlayerTeammate())
    int row = GetActorType(partner) * 7
    If(init == PlayerRef)
      return MCM.bAssaultFol[row]
    ElseIf(isFolI)
      return MCM.bAssaultFol[row + 1]
    Else
      return MCM.bAssaultFol[row + GetActorType(init) + 2]
    EndIf
  Else
    int row = GetActorType(partner) * 7
    If(init == PlayerRef)
      return MCM.bAssaultNPC[row]
    ElseIf(isFolI)
      return MCM.bAssaultNPC[row + 1]
    Else
      return MCM.bAssaultNPC[row + GetActorType(init) + 2]
    EndIf
  EndIf
EndFunction

bool Function IsValidRace(Actor that)
  If(MCM.iCrtFilterMethod == 0 || that.HasKeyword(ActorTypeNPC)) ; Any or NPC
    return true
  ElseIf(MCM.iCrtFilterMethod == 1) ; None
    return false
  EndIf
  bool allow = false
	Race myRace = that.GetRace()
  int myPlace = RaceList.Find(myRace)
  If(myPlace < 0)
    Debug.Trace("[Yamete] isValidCreature() -> Race " + myRace + " returned outside the Valid Range: " + myPlace)
  Else
    If(myPlace > 51)
      If(myPlace == 81 || myPlace == 82) ; Bear
        myPlace = 2
      ElseIf(myPlace == 80) ; Chaurus
        myPlace = 5
      ElseIf(myPlace == 79) ; Death Hound
        myPlace = 10
      ElseIf(myPlace == 78) ; Deer
        myPlace = 11
      ElseIf(myPlace <= 77 && myPlace > 71) ; Dog
        myPlace = 12
      ElseIf(myPlace <= 71 && myPlace > 68) ; Dragon
        myPlace = 13
      Elseif(myPlace == 68 || myPlace == 67) ; Draugr
        myPlace = 15
      ElseIf(myPlace == 66) ; Falmer
        myPlace = 20
      ElseIf(myPlace == 65 || myPlace == 64) ; Gargoyles
        myPlace = 24
      ElseIf(myPlace == 63) ; Giant
        myPlace = 25
      ElseIf(myPlace == 62) ; Horse
        myPlace = 29
      ElseIf(myPlace == 61) ; Netch
        myPlace = 34
      ElseIf(myPlace == 60) ; Riekling
        myPlace = 36
      ElseIf(myPlace == 59 || myPlace == 58) ; Sabre Cat
        myPlace = 37
      ElseIf(myPlace == 57) ; Storm Atronach
        myPlace = 45
      ElseIf(myPlace <= 56 && myPlace > 53) ; Spriggan
        myPlace = 44
      ElseIf(myPlace == 53) ; Troll
        myPlace = 46
      ElseIf(myPlace == 52) ; Werewolf
        myPlace = 49
      else
        Debug.Trace("[Yamete] isValidCreature() -> Race " + myRace + " returned outside the Valid Range: " + myPlace)
      EndIf
    EndIf
    allow = MCM.bValidRace[myPlace]
  EndIf
  If(MCM.iCrtFilterMethod == 2) ; Use List
    return allow
  else ; Use List Reverse
    return !allow
  EndIf
EndFunction

Actor[] Function GetActors()
  int numAlias = GetNumAliases()
  Actor[] ret = PapyrusUtil.ActorArray(numAlias, none)
  int jCooldowns = JValue.readFromFile(filePath + "Definition\\Cooldowns.json")
  int i = 0
  While(i < numAlias)
    Actor tmp = (GetAlias(i) as ReferenceAlias).GetReference() as Actor
    bool accept = false
    If(!tmp)
      ;
    ElseIf(JMap.getFlt(jCooldowns, tmp.GetFormID()) > GameDaysPassed.Value)
      ;
    ElseIf(tmp == PlayerRef)
      accept = JMap.getInt(jProfile, "bConsiderPlayer")
    ElseIf(tmp.IsInFaction(PlayerFollowerFaction) || tmp.IsPlayerTeammate())
      accept = JMap.getInt(jProfile, "bConsiderFollowers")
    ElseIf(!IsValidRace(tmp))
      ;
    Else
      int cC = JMap.getInt(jProfile, "lConsiderCreature")
      bool npc = tmp.HasKeyword(ActorTypeNPC)
      If(cC == 0 || (cC == 1 && npc) || (cC == 2 && !npc))
        int cH = JMap.getInt(jProfile, "lConsider")
        bool hostile = tmp.IsHostileToActor(PlayerRef)
        If(cH == 0 || (cH == 1 && !hostile) || (cH == 2 && hostile))
          accept = true
        EndIf
      EndIf
    EndIf
    If(accept)
      ret[i] = tmp
    EndIf
    i += 1
  EndWhile
  ret = PapyrusUtil.RemoveActor(ret, none)
  return ret
EndFunction

Function Stop()
  JValue.releaseObjectsWithTag("SMMScan")
  GoToState("Abandon")
  RegisterForSingleUpdate(1.1)
EndFunction
State Abandon
  Event OnUpdate()
    PlayerScr.ContinueScan()
    Parent.Stop()
    GoToState("")
  EndEvent
EndState

;/ -------------------------- Code
int Function CheckForEngagement()
  GoToState(StringUtil.Substring(PlayerScr.Profile, 1))
  ;Gathering every non-empty Alias in this Array
  Actor[] AliasArray = GetFilledActors()
  If(!AliasArray.Length)
    Debug.Trace("RMM: Found 0 Valid Actors, abandon")
    return -1
  EndIf
  ;Collecting Valid Actors ("Valid" as in defined by MCM):
  ToEngage = GetValidVictim(AliasArray)
  If(ToEngage == none)
    Debug.Trace("RMM: No Victim found, abandon.")
    return -1
  else
    ToEngage.AddToFaction(FriendFaction)
    If(toEngage.IsPlayerTeammate())
      toEngage.AddToFaction(tmpTeam)
      toEngage.SetPlayerTeammate(false, false)
    EndIf
    ToEngage.StopCombat()
    ToEngage.StopCombatAlarm()
    PotentialAggressors = GetAggressors(AliasArray)
    int count = PotentialAggressors.Length
    While(count)
      count -= 1
      PotentialAggressors[count].AddToFaction(FriendFaction)
      If(toEngage.IsPlayerTeammate())
        toEngage.AddToFaction(tmpTeam)
        toEngage.SetPlayerTeammate(false, false)
      EndIf
      PotentialAggressors[count].StopCombat()
      PotentialAggressors[count].StopCombatAlarm()
    EndWhile
    Debug.Trace("RMM: Trying to start Scene with Victim: " + ToEngage.GetLeveledActorBase().GetName() + " and " + ValidAggressor + " Aggressors.")
    ; int Count = ValidAggressor
    ; While(Count)
    ;   Count -= 1
    ;   CalmSpell.Cast(PotentialAggressors[Count])
    ; EndWhile
    If(ValidAggressor == 1) ;Only 1 Aggressor => 2some
      return SLScene(2)
    elseif(ValidAggressor == 2)
      int Scenario = Utility.RandomInt(1, MCM.iTwoCh + MCM.iThreeCh)
      If(Scenario <= MCM.iTwoCh)
        return SLScene(2)
      else
        return SLScene(3)
      EndIf
    ElseIf(ValidAggressor == 3)
      int Scenario = Utility.RandomInt(1,MCM.iTwoCh + MCM.iThreeCh + MCM.iFourCh)
      If(Scenario <= MCM.iTwoCh)
        return SLScene(2)
      elseIf(Scenario <= MCM.iThreeCh)
        return SLScene(3)
      else
        return SLScene(4)
      EndIf
    ElseIf(ValidAggressor == 4)
      int Scenario = Utility.RandomInt(1, MCM.iTwoCh + MCM.iThreeCh + MCM.iFourCh + MCM.iFiveCh)
      If(Scenario <= MCM.iTwoCh)
        return SLScene(2)
      elseIf(Scenario <= MCM.iThreeCh)
        return SLScene(3)
      elseif(Scenario <= MCM.iFourCh)
        return SLScene(4)
      else
        return SLScene(5)
      EndIf
    else
      Debug.Trace("RMM: Invalid aggressors passed, abandoned.")
    EndIf
  EndIf
  return -1
EndFunction

int Function SLScene(int howMany)
  ObjectReference myBed = none
  bool UseBed = false
  ; Get Bed if enabled
  If(MCM.bUseBed && PlayerScr.SaveLoc)
    myBed = SL.FindBed(ToEngage)
    If(myBed)
      UseBed = true
    EndIf
  EndIf
  ; Get Num of Actors
  Actor[] acteurs = PapyrusUtil.ActorArray(howMany)
  sslBaseAnimation[] Anims
  ;0 - Male, 1 - Female, 2+ - Creature
  If(howMany == 2) ;2P
    acteurs[0] = toEngage
    acteurs[1] = potentialAggressors[0]
    ; Get those Tags figures out
    int vicGen = SL.GetGender(toEngage)
    int aggrGen = SL.GetGender(potentialAggressors[0])
    If(vicGen > 1 || aggrGen > 1) ; If either of them is a Creature, just play the Anim
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive")
      else
        Anims = SL.PickAnimationsByActors(acteurs)
      EndIf
    ElseIf(vicGen == 1 && aggrGen == 0) ; Female vic with Male aggr
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive, " + MCM.s2PFM)
      else
        Anims = SL.GetAnimationsByTags(howMany + 1, MCM.s2PFM)
      EndIf
    ElseIf(vicGen == 0 && aggrGen == 1) ; Male vic with Female aggr
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive, " + MCM.s2PMF)
      else
        Anims = SL.GetAnimationsByTags(howMany + 1, MCM.s2PMF)
      EndIf
    ElseIf(vicGen == 1 && aggrGen == 1) ; Female vic with Female aggr
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive, " + MCM.s2PFF)
      else
        Anims = SL.GetAnimationsByTags(howMany + 1, MCM.s2PFF)
      EndIf
    Else ; Female vic with Male aggr
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive, " + MCM.s2PMM)
      else
        Anims = SL.GetAnimationsByTags(howMany + 1, MCM.s2PMM)
      EndIf
    EndIf
  ElseIf(howMany == 3) ; 3p
    acteurs[0] = toEngage
    acteurs[1] = potentialAggressors[0]
    acteurs[2] = potentialAggressors[1]
    ; Tags..
    If(SL.GetGender(toEngage) == 0) ; Male vic
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive, " + MCM.s3PM)
      else
        Anims = SL.GetAnimationsByTags(howMany + 1, MCM.s3PM)
      EndIf
    else ; Female Vic
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive, " + MCM.s3PF)
      else
        Anims = SL.GetAnimationsByTags(howMany + 1, MCM.s3PF)
      EndIf
    EndIf
  ElseIf(howMany == 4) ; 4p
    acteurs[0] = toEngage
    acteurs[1] = potentialAggressors[0]
    acteurs[2] = potentialAggressors[1]
    acteurs[3] = potentialAggressors[2]
    ; Tags..
    If(SL.GetGender(toEngage) == 0) ; Male vic
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive, " + MCM.s4PM)
      else
        Anims = SL.GetAnimationsByTags(howMany + 1, MCM.s4PM)
      EndIf
    else ; Female Vic
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive, " + MCM.s4PF)
      else
        Anims = SL.GetAnimationsByTags(howMany + 1, MCM.s4PF)
      EndIf
    EndIf
  ElseIf(howMany == 5) ; 5p
    acteurs[0] = toEngage
    acteurs[1] = potentialAggressors[0]
    acteurs[2] = potentialAggressors[1]
    acteurs[3] = potentialAggressors[2]
    acteurs[4] = potentialAggressors[3]
    ; Tags..
    If(SL.GetGender(toEngage) == 0) ; Male vic
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive, " + MCM.s5PM)
      else
        Anims = SL.GetAnimationsByTags(howMany + 1, MCM.s5PM)
      EndIf
    else ; Female Vic
      If(MCM.bUseAggressive)
        Anims = SL.GetAnimationsByTags(howMany + 1, "Aggressive, " + MCM.s5PF)
      else
        Anims = SL.GetAnimationsByTags(howMany + 1, MCM.s5PF)
      EndIf
    EndIf
  EndIf
  ; Show Message if enabled
  If(MCM.bNotify)
    Debug.Notification(potentialAggressors[0].GetLeveledActorBase().GetName() + " engages " + toEngage.GetLeveledActorBase().GetName())
  EndIf
  ; Start Scene
  If(MCM.bTreatAsVictim)
    return SL.StartSex(Acteurs, Anims, Victim = ToEngage, CenterOn = myBed, AllowBed = UseBed, hook = "ScrappieMM")
  else
    return SL.StartSex(Acteurs, Anims, CenterOn = myBed, AllowBed = UseBed, hook = "ScrappieMM")
  EndIf
  return -1
endFunction

State Sheep
  Actor Function GetValidVictim(Actor[] myActors)
    ; Debug.Trace("RMM: Checking for Victim.. ")
    If(Utility.RandomInt(1, 100) <= MCM.iPrefPlSheep && Player.GetReference() && IsValidVic(PlayerRef))
        return PlayerRef
    EndIf
    Actor[] DummyArray = PapyrusUtil.ActorArray(myActors.Length)
    int ValidVictim = 0
    int Count = myActors.Length
    While(Count > 0)
      Count -= 1
      If(IsValidVic(myActors[Count]))
        DummyArray[ValidVictim] = myActors[Count]
        ValidVictim += 1
      EndIf
      Utility.Wait(0.05)
    EndWhile
    If(MCM.bPrintTraces)
      Debug.Trace("RMM: Found " + ValidVictim + " Victims")
    EndIf
    If(ValidVictim > 0)
      int RandomActor = Utility.RandomInt(0, (ValidVictim - 1))
      return DummyArray[RandomActor]
    EndIf
    return none
  endFunction

  bool Function IsValidVic(Actor target)
    If(!target)
      Debug.Trace("RMM: Invalid Actor pushed to IsValidVic, abandon")
      return false
    endIf
    If(MCM.bPrintTraces)
      Debug.Trace("RMM: Actor pushed to IsValidVic: " + target.GetLeveledActorBase().GetName())
    EndIf
    If(!SL.IsValidActor(target))
      return false
    else
      vicRace = target.GetLeveledActorBase().GetRace()
    EndIf
    If(MCM.bUseArousalSheep && !MCM.bIgnoreVicArousalSheep)
      If(Aroused.GetActorArousal(target) < MCM.iArousalThreshSheep)
        return false
      EndIf
    endif
    If(!MCM.bHostVicSheep)
      If(target != PlayerRef && target.IsHostileToActor(PlayerRef))
        return false
      EndIf
    EndIf
    If(Target == PlayerRef) ; Player
      If(MCM.bEngagePlSheep)
        return true
      else
        return false
      EndIf
    elseIf(Target.IsInFaction(currentfollowerfaction)) ; Follower
      If(!MCM.bEngageFolSheep)
        return false
      ElseIf(!MCM.bRestrictGenFolSheep)
        return true
      EndIf
    elseIf(target.HasKeyword(ActorTypeNPC)) ; NPC
      If(!MCM.bEngageNPCSheep)
        return false
      ElseIf(!MCM.bRestrictGenNPCSheep)
        return true
      EndIf
    else ; Creature
      If(!MCM.bEngageCreatureSheep)
        return false
      ElseIf(!MCM.bRestrictGenCrtSheep)
        return true
      EndIf
    EndIf
    ;0 - Male, 1 - Female, 2 - Futa, 3 - Creature Mal, 4 - Creature Fem
    int gender = GetActorType(target)
    If(gender == 0 && MCM.bEngageMaleSheep)
      return true
    ElseIf(gender == 1 && MCM.bEngageFemaleSheep)
      return true
    ElseIf(gender == 2 && MCM.bEngageFutaSheep)
      return true
    ElseIf(gender == 3 && MCM.bEngageCrMSheep)
      return true
    ElseIf(gender == 4 && MCM.bEngageCrFSheep)
      return true
    EndIf
    return false
  EndFunction

  Actor[] Function GetAggressors(Actor[] myActors)
    ; Debug.Trace("RMM: Checking for Aggressors...")
    Actor[] DummyArray = PapyrusUtil.ActorArray(myActors.Length)
    ValidAggressor = 0
    int Count = myActors.Length
    While(Count && ValidAggressor < (MCM.iMaxActor - 1))
      Count -= 1
      If(IsValidAg(myActors[Count]) == true)
        DummyArray[ValidAggressor] = myActors[Count]
        ValidAggressor += 1
      EndIf
      Utility.Wait(0.05)
    EndWhile
    If(MCM.bPrintTraces)
      Debug.Trace("RMM: Found " + ValidAggressor + " Aggressors.")
    endIf
    return PapyrusUtil.RemoveActor(DummyArray, none)
  endFunction

  bool Function IsValidAg(Actor Target)
    ; Base
    If(target == none)
      Debug.Trace("RMM: Invalid Actor pushed to IsValidAg, abandon")
      return false
    ElseIf(Target == ToEngage || Target == PlayerRef)
      return false
    EndIf
    If(MCM.bPrintTraces)
      Debug.Trace("RMM: Actor pushed to IsValidAg: " + Target.GetLeveledActorBase().GetName())
    EndIf
    ; Genderchecks
    If(!checkFilter(GetActorType(target), target.IsInFaction(currentfollowerfaction)))
      return false
    EndIf
    ; Racecheck
    If(!target.HasKeyword(ActorTypeNPC))
      If(ValidAggressor == 0)
        aggrRace = target.GetLeveledActorBase().GetRace()
        If(!SL.AllowedCreature(aggrRace))
          return false
        endIf
      else
        If(!aggrRace)
          return false
        ElseIf(SL.AllowedCreatureCombination(aggrRace,  target.GetLeveledActorBase().GetRace()))
          return false
        EndIf
      EndIf
    EndIf
    ; Hostility & Combat Check
    If(target.IsInCombat())
      return false
    ElseIf(target.IsHostileToActor(ToEngage))
      If(!MCM.bHostOnFriendSheep)
        return false
      EndIf
    EndIf
    ; Engage Settings
    If(MCM.bUseArousalSheep)
      If(Aroused.GetActorArousal(target) < MCM.iArousalThreshSheep)
        return false
      EndIf
    EndIf
    If(MCM.bUseDistSheep)
      If(ToEngage.GetDistance(Target) > MCM.fMaxDistanceSheep*70)
        return false
      EndIf
    EndIf
    If(MCM.bUseLoSSheep)
      If(!Target.HasLOS(ToEngage))
        return false
      EndIf
    EndIf
    If(MCM.bUseDispotionSheep)
      If(ToEngage == PlayerRef && Target.GetRelationshipRank(PlayerRef) < MCM.iMinDispPlSheep)
        return false
      ElseIf(ToEngage.IsInFaction(currentfollowerfaction) && Target.GetRelationshipRank(PlayerRef) < MCM.iMinDispFolSheep)
        return false
      ElseIf(Target.GetRelationshipRank(ToEngage) < MCM.iMinDispNPCSheep)
        return false
      EndIf
    EndIf
    return true
  EndFunction
endState
/; 

; 70unit = 1m
