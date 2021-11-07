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
  While(i < MCM.iMaxScenes)
    Debug.Trace("[SMM] <Scan> Building Scene " + (i + 1) + "/" + MCM.iMaxScenes)
    ; Collect Initiator
    Actor init = GetInitiator(ColAct)
    If(!init)
      Debug.Trace("[SMM] <Scan> Found no Initiator")
      Stop()
      return
    EndIf
    Debug.Trace("[SMM] <Scan> Found Initiator: " + init)
    colAct = PapyrusUtil.RemoveActor(colAct, PlayerRef)
    int numActors = calcThreesome(colAct.Length + 1) - 1
    If(numActors < 1)
      Debug.Trace("[SMM] <Scan> Invalid Number of Actors")
      If(init != PlayerRef)
        bool f = init.IsInFaction(PlayerFollowerFaction) || init.IsPlayerTeammate()
        bool npc = init.HasKeyword(ActorTypeNPC)
        bool fA = f && Utility.RandomFloat(0, 99.5) < MCM.fAFMasturbateFol
        bool npcA = !f && Utility.RandomFloat(0, 99.5) < MCM.fAFMasturbateNPC
        bool CrtA = !npc && Utility.RandomFloat(0, 99.5) < MCM.fAFMasturbateCrt
        If(npc && (fA || npcA) || crtA)
          Debug.Trace("[SMM] <Scan> Attempt 1p Scene")
          ThreadKW.SendStoryEvent(akRef1 = init)
        EndIf
      EndIf
      Stop()
      return
    EndIf
    int jScene = JValue.retain(JArray.objectWithSize(numActors), "SMMThread")
    ; Collect Partners
    int n = 0
    int nn = 0
    While(n < ColAct.Length && nn < numActors)
      If(ValidPartner(ColAct[n]) && isValidGenderCombination(init, ColAct[n]) && ValidMatch(init, ColAct[n]))
        Debug.Trace("[SMM] <Scan> Adding Partner: " + ColAct[n] + " -> " + ColAct[n].GetLeveledActorBase().GetName())
        JArray.setForm(jScene, nn, ColAct[n])
        nn += 1
      EndIf
      n += 1
    EndWhile
    If(nn > 0)
      Debug.Trace("[SMM] <Scan> Attempting to start Scene with " + nn + " Participants")
      JArray.eraseForm(jScene, none)
      If(!ThreadKW.SendStoryEventAndWait(akRef1 = init, aiValue1 = jScene, aiValue2 = jProfile))
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
  Debug.Trace("[SMM] Valid Match; Checking: Init: " + init.GetLeveledActorBase().GetName() + "; Partner: " + partner.GetLeveledActorBase().GetName())
  If(partner.GetDistance(init) > JMap.getFlt(jProfile, "fDistance") * 70)
    Debug.Trace("[SMM] Valid Match -> Distance Too Great")
    return false
  EndIf
  bool consent = JMap.getInt(jProfile, "bConsent")
  If(JMap.getInt(jProfile, "bLOS") && !(partner.HasLOS(init) || consent && init.HasLOS(partner)))
    Debug.Trace("[SMM] Valid Match -> No LOS")
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
    Debug.Trace("[SMM] Valid Match -> Invalid Disposition")
    return false
  EndIf
  int incest = JMap.getInt(jProfile, "lIncest")
  If(incest == 0 && partner.HasFamilyRelationship(init) && !partner.HasAssociation(Spouse, init) || incest == 1 && partner.HasParentRelationship(init))
    Debug.Trace("[SMM] Valid Match -> Invalid Incest")
    return false
  EndIf
  Debug.Trace("[SMM] Valid Match -> TRUE")
  return true
EndFunction

; ===============================================================
; =============================  INITIATOR
; ===============================================================
Actor Function GetInitiator(Actor[] them)
  If(Utility.RandomFloat(0, 99.9) < JMap.getFlt(jProfile, "fPlayerInit", 0) && ValidInitiator(PlayerRef))
    return PlayerRef
  EndIf
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
  Debug.Trace("[SMM] Checking Initiator: " + that + " -> " + that.GetLeveledActorBase().GetName())
  bool fol = that.IsInFaction(PlayerFollowerFaction) || that.IsPlayerTeammate()
  int jTmp = JMap.getObj(jProfile, "bGenderInit")
  If(that != PlayerRef && (fol && !JArray.getInt(jTmp, 0) || !fol && !JArray.getInt(jTmp, GetActorType(that) + 1)))
    Debug.Trace("[SMM] Invalid Initiator Gender")
    return false
  EndIf
  int arousal = GetArousal(that)
  bool aroused
  If(that == PlayerRef)
    aroused = arousal >= JMap.getInt(jprofile, "iArousalInitPl")
  ElseIf(fol)
    aroused = arousal >= JMap.getInt(jprofile, "iArousalInitFol")
  Else
    aroused = arousal >= JMap.getInt(jprofile, "iArousalInit")
  EndIf
  Debug.Trace("[SMM] Aroused Check: " + aroused)
  int alg = JMap.getInt(jProfile, "lAdvInit", 0)
  If(alg != 0)
    Debug.Trace("[SMM] Advanced Algorithm: " + alg)
    int p = 0
    int[] v
    If(alg == 1)
      v = JArray.asIntArray(JMap.getObj(jProfile, "ReqAPoints"))
    Else
      v = JArray.asIntArray(JMap.getObj(jProfile, "cAChances"))
    EndIf
    bool[] c = new bool[13]
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
    c[11] = c[10] && that.WornHasKeyword(Keyword.GetKeyword("zad_DeviousHeavyBondage")) || that.WornHasKeyword(Keyword.GetKeyword("zbfEffectWrist")) || that.WornHasKeyword(Keyword.GetKeyword("ToysEffect_ArmBind")) || that.WornHasKeyword(Keyword.GetKeyword("ToysEffect_YokeBind"))
    c[12] = c[10] && that.WornHasKeyword(Keyword.GetKeyword("zad_DeviousCollar")) || that.WornHasKeyword(Keyword.GetKeyword("ToysType_Neck")) || that.WornHasKeyword(Keyword.GetKeyword("zbfWornCollar"))
    int i = 0
    While(i < c.Length)
      Debug.Trace("[SMM] Conditon " + i + ": " + c[i])
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
      Debug.Trace("[SMM] End Status: " + p + " Required: " + JMap.getInt(jProfile, "iReqPoints"))
      return p >= JMap.getInt(jProfile, "iReqPoints")
    Else
      Debug.Trace("[SMM] End Status: " + p + " Basechance: " + JMap.getInt(jProfile, "cBaseChance"))
      return Utility.RandomInt(0, 99) < p + JMap.getInt(jProfile, "cBaseChance")
    EndIf
  EndIf
  Debug.Trace("[SMM] Skip Advanced")
  return aroused
EndFunction

; ===============================================================
; =============================  PARTNER
; ===============================================================
bool Function ValidPartner(Actor that)
  Debug.Trace("[SMM] Checking Partner: " + that + " -> " + that.GetLeveledActorBase().GetName())
  bool fol = that.IsInFaction(PlayerFollowerFaction) || that.IsPlayerTeammate()
  int j = JMap.getObj(jProfile, "bGenderPartner")
  If(fol && !JArray.getInt(j, 0) || !fol && !JArray.getInt(j, GetActorType(that) + 1))
    Debug.Trace("[SMM] Invalid Partner Gender")
    return false
  EndIf
  int arousal = GetArousal(that)
  bool aroused
  If(fol)
    aroused = arousal >= JMap.getInt(jprofile, "iArousalPartnerFol")
  Else
    aroused = arousal >= JMap.getInt(jprofile, "iArousalPartner")
  EndIf
  Debug.Trace("[SMM] Aroused Check: " + aroused)
  return aroused
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
  bool sol = false
  bool followerInit = init.IsInFaction(PlayerFollowerFaction) || init.IsPlayerTeammate()
  If(partner.IsInFaction(PlayerFollowerFaction) || partner.IsPlayerTeammate())
    int row = GetActorType(partner) * 7
    If(init == PlayerRef)
      sol = MCM.bAssaultFol[row]
    ElseIf(followerInit)
      sol = MCM.bAssaultFol[row + 1]
    Else
      sol = MCM.bAssaultFol[row + GetActorType(init) + 2]
    EndIf
  Else
    int row = GetActorType(partner) * 7
    If(init == PlayerRef)
      sol = MCM.bAssaultNPC[row]
    ElseIf(followerInit)
      sol = MCM.bAssaultNPC[row + 1]
    Else
      sol = MCM.bAssaultNPC[row + GetActorType(init) + 2]
    EndIf
  EndIf
  Debug.Trace("[SMM] Gender Combination -> " + sol + " => " + init.GetLeveledActorBase().GetName() + "<->" + partner.GetLeveledActorBase().GetName())
  return sol
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
  Alias[] aliases = GetAliases()
  Actor[] ret = PapyrusUtil.ActorArray(aliases.length, none)
  int jCooldowns = JValue.readFromFile(filePath + "Definition\\Cooldowns.json")
  int i = 0
  While(i < aliases.length)
    Actor tmp = (aliases[i] as ReferenceAlias).GetReference() as Actor
    bool accept = false
    If(!tmp)
      ;
    ElseIf(JMap.getFlt(jCooldowns, tmp.GetFormID()) > GameDaysPassed.Value + (JMap.getFlt(jProfile, "fEngageCooldown", 1) * 1/24))
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
    PlayerScr.RegisterForSingleUpdate(MCM.iTickInterval)
    Parent.Stop()
    GoToState("")
  EndEvent
EndState

; 70unit = 1m
