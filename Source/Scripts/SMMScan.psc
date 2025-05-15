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

Keyword zad_Lockable
Keyword ToysToy
Keyword zbfWornDevice
Keyword zad_DeviousHeavyBondage
Keyword zbfEffectWrist
Keyword ToysEffect_ArmBind
Keyword ToysEffect_YokeBind
Keyword zad_DeviousCollar
Keyword ToysType_Neck
Keyword zbfWornCollar
; --------------- Code
Event OnInit()
  Debug.Trace("[SMM] Defining Keywords")
  zad_Lockable = Keyword.GetKeyword("zad_Lockable")
  ToysToy = Keyword.GetKeyword("ToysToy")
  zbfWornDevice = Keyword.GetKeyword("zbfWornDevice")
  zad_DeviousHeavyBondage = Keyword.GetKeyword("zad_DeviousHeavyBondage")
  zbfEffectWrist = Keyword.GetKeyword("zbfEffectWrist")
  ToysEffect_ArmBind = Keyword.GetKeyword("ToysEffect_ArmBind")
  ToysEffect_YokeBind = Keyword.GetKeyword("ToysEffect_YokeBind")
  zad_DeviousCollar = Keyword.GetKeyword("zad_DeviousCollar")
  ToysType_Neck = Keyword.GetKeyword("ToysType_Neck")
  zbfWornCollar = Keyword.GetKeyword("zbfWornCollar")
EndEvent

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  jProfile = JValue.retain(aiValue1)
  ; Get all actors collected by the initial Scan. Assume them to be valid for animation
  Actor[] ColAct = GetActors()
  If(!colAct.Length)
    Debug.Trace("[SMM] <Scan> No Actors to match")
    Stop()
    return
  EndIf
  int i = 0
  While(i < MCM.iMaxScenes)
    Debug.Trace("[SMM] <Scan> Building Scene " + (i + 1) + "/" + MCM.iMaxScenes)
    ; Collect Initiator
    Actor init = GetInitiator(ColAct)
    If(!init)
      Debug.Trace("[SMM] <Scan> No Initiator")
      Stop()
      return
    EndIf
    Debug.Trace("[SMM] <Scan> Initiator = " + init)
    colAct = PapyrusUtil.RemoveActor(colAct, init)
    ; Figure out maximum Number of Partners
    int numPartners = SMMAnimation.GetAllowedParticipants(colAct.Length + 1) - 1
    If(numPartners < 1)
      Debug.Trace("[SMM] <Scan> Invalid Number of Partners")
      If(init != PlayerRef && init.HasKeyword(ActorTypeNPC))
        bool isfollower = init.IsInFaction(PlayerFollowerFaction) || init.IsPlayerTeammate()
        If(isfollower && Utility.RandomFloat(0, 99.5) < MCM.fAFMasturbateFol || !isfollower && Utility.RandomFloat(0, 99.5) < MCM.fAFMasturbateNPC)
          Debug.Trace("[SMM] <Scan> Attempt 1p Scene")
          ThreadKW.SendStoryEvent(akRef1 = init)
        EndIf
      EndIf
      Stop()
      return
    EndIf
    ; Collect Partners
    int jScene = JValue.retain(JArray.object())
    int n = ColAct.Length
    int nn = 0
    While(n > 0 && nn < numPartners)
      n -= 1
      Debug.Trace("[SMM] Checking Partner: " + ColAct[n] + " (" + ColAct[n].GetLeveledActorBase().GetName() + ")")
      If(ValidPartner(ColAct[n], jProfile) && isValidGenderCombination(init, ColAct[n]) && ValidMatch(init, ColAct[n], jProfile))
        Debug.Trace("[SMM] Adding Partner " + ColAct[n])
        JArray.addForm(jScene, ColAct[n])
        ColAct = PapyrusUtil.RemoveActor(ColAct, ColAct[n])
        nn += 1
      EndIf
    EndWhile
    If(nn > 0)
      Debug.Trace("[SMM] <Scan> Attempting to start Scene with " + nn + " Participants")
      If(!ThreadKW.SendStoryEventAndWait(akRef1 = init, aiValue1 = jScene, aiValue2 = JValue.deepCopy(jProfile)))
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

bool Function ValidMatch(Actor init, Actor partner, int jTmp)
  ; Distance
  If(partner.GetDistance(init) > JMap.getFlt(jTmp, "fDistance") * 70)
    Debug.Trace("[SMM] <Match> Distance Too Great")
    return false
  EndIf
  ; Consent
  bool consent = JMap.getInt(jTmp, "bConsent")
  If(JMap.getInt(jTmp, "bLOS") && !(partner.HasLOS(init) || consent && init.HasLOS(partner)))
    Debug.Trace("[SMM] <Match> No LOS")
    return false
  EndIf
  ; Disposition
  int disReq = JMap.getInt(jTmp, "iDisposition")
  If(partner.GetRelationshipRank(init) < disReq || consent && init.GetRelationshipRank(partner) < disReq)
    Debug.Trace("[SMM] <Match> Invalid Disposition")
    return false
  EndIf
  ; Incest
  int incest = JMap.getInt(jTmp, "lIncest")
  If(incest == 0 && partner.HasFamilyRelationship(init) && !partner.HasAssociation(Spouse, init) || incest == 1 && partner.HasParentRelationship(init))
    Debug.Trace("[SMM] <Match> Invalid Incest")
    return false
  EndIf
  return true
EndFunction

; ===============================================================
; =============================  INITIATOR
; ===============================================================
Actor Function GetInitiator(Actor[] them)
  ; If(!PlayerRef.HasKeywordString("SMM_ThreadActor") && Utility.RandomFloat(0, 99.9) < JMAp.getFlt(jProfile, "fPlayerInit") && ValidInitiator(PlayerRef))
  ;   return PlayerRef
  ; EndIf
  int i = 0 
  While(i < them.Length)
    If(ValidInitiator(them[i]))
      return them[i]
    EndIf
    i += 1
  EndWhile
  return none
EndFunction
bool Function ValidInitiator(Actor that)
  Debug.Trace("[SMM] Checking Initiator: " + that + " (" + that.GetLeveledActorBase().GetName() + ")")
  If(that != PlayerRef)
    bool fol = that.IsInFaction(PlayerFollowerFaction) || that.IsPlayerTeammate()
    int jTmp = JMap.getObj(jProfile, "bGenderInit")
    If(that != PlayerRef && (fol && !JArray.getInt(jTmp, 0) || !fol && !JArray.getInt(jTmp, GetActorType(that) + 1)))
      Debug.Trace("[SMM] Invalid Initiator Gender")
      return false
    EndIf
  EndIf
  bool ret
  int alg = JMap.getInt(jProfile, "lAdvInit", 0)
  If(alg != 0)
    Debug.Trace("[SMM] Advanced Algorithm: " + alg)
    int p = 0
    int[] v
    If(alg == 2)
      v = SMMUtility.asJIntArray(JMap.getObj(jProfile, "reqAPoints"))
    Else
      v = SMMUtility.asJIntArray(JMap.getObj(jProfile, "cAChances"))
    EndIf    
    int i = 0
    While(i < v.Length)
      If(AdvCon(that, i))
        If(alg == 1) ; Chance Adjust
          p += v[i]
        ElseIf(v[i] == 0) ; Overwrite
          return true
        ElseIf(v[i] != 1) ; Points Adjust (1 <=> Mandatory)
          p += 5 - v[i]
        EndIf
      ElseIf(alg == 2 && v[i] == 1) ; Mandatory False
        return false
      EndIf
      i += 1
    EndWhile
    If(alg == 2)
      Debug.Trace("[SMM] End Status: " + p + " Required: " + JMap.getInt(jProfile, "iReqPoints"))
      ret = p >= JMap.getInt(jProfile, "iReqPoints")
    Else
      Debug.Trace("[SMM] End Status: " + p + " Basechance: " + JMap.getInt(jProfile, "cBaseChance"))
      ret = Utility.RandomInt(0, 99) < p + JMap.getInt(jProfile, "cBaseChance")
    EndIf
  Else
    Debug.Trace("[SMM] Skip Advanced")
    ret = AdvCon(that, 2)
  EndIf
  Debug.Trace("[SMM] Returning " + ret)
  return ret
EndFunction

bool Function AdvCon(Actor that, int i)
  If(i == 0)
    return GameHour.Value >= MCM.fDuskTime || GameHour.Value < MCM.fDawnTime
  ElseIf(i == 1)
    return IsThane(that)
  ElseIf(i == 2)
    int arousal = SMMAnimation.GetArousal(that)
    bool aroused
    If(that == PlayerRef)
      aroused = arousal >= JMap.getInt(jprofile, "iArousalInitPl")
    ElseIf(that.IsInFaction(PlayerFollowerFaction) || that.IsPlayerTeammate())
      aroused = arousal >= JMap.getInt(jprofile, "iArousalInitFol")
    Else
      aroused = arousal >= JMap.getInt(jprofile, "iArousalInit")
    EndIf
    return aroused
  ElseIf(i == 3)
    return !(that.WornHasKeyword(ArmorLight) || that.WornHasKeyword(ArmorHeavy) || that.WornHasKeyword(ArmorClothing))
  ElseIf(i == 4)
    return !that.WornHasKeyword(ArmorHelmet)
  ElseIf(i == 5)
    return !that.GetEquippedObject(0) && !that.GetEquippedObject(1)
  ElseIf(i == 6)
    return !that.IsWeaponDrawn()
  ElseIf(i == 7)
    return MiscUtil.ScanCellNPCsByFaction(GuardFaction, that).Length == 0
  ElseIf(i == 8)
    return that.GetActorValuePercentage("Health") < JMap.getFlt(jProfile, "rHealthThresh")
  ElseIf(i == 9)
    return that.GetActorValuePercentage("Stamina") < JMap.getFlt(jProfile, "rStaminaThresh") || that.GetActorValuePercentage("Magicka") < JMap.getFlt(jProfile, "rMagickaThresh")
  ElseIf(i == 10)
    If(Game.GetModByName("YameteKudasai.esp") != 255)
      return SMMYameteKudasai.IsActorDefeated(that)
    EndIf
  ElseIf(i == 11)
    bool b = false
    If(zad_Lockable != none)
      b = that.WornHasKeyword(zad_Lockable)
    EndIf
    If(!b && zbfWornDevice != none)
      b = that.WornHasKeyword(zbfWornDevice)
    EndIf
    If(!b && ToysToy != none)
      b = that.WornHasKeyword(ToysToy)
    EndIf
    return b
  ElseIf(i == 12)
    bool b = false
    If(zad_Lockable != none)
      b = that.WornHasKeyword(zad_DeviousHeavyBondage)
    EndIf
    If(!b && zbfWornDevice != none)
      b = that.WornHasKeyword(zbfEffectWrist)
    EndIf
    If(!b && ToysToy != none)
      b = that.WornHasKeyword(ToysEffect_ArmBind) || that.WornHasKeyword(ToysEffect_YokeBind)
    EndIf
    return b
  ElseIf(i == 13)
    bool b = false
    If(zad_Lockable != none)
      b = that.WornHasKeyword(zad_DeviousCollar)
    EndIf
    If(!b && zbfWornDevice != none)
      b = that.WornHasKeyword(zbfWornCollar)
    EndIf
    If(!b && ToysToy != none)
      b = that.WornHasKeyword(ToysType_Neck)
    EndIf
    return b
  EndIf
EndFunction

; ===============================================================
; =============================  PARTNER
; ===============================================================
bool Function ValidPartner(Actor that, int jTmp)
  bool fol = that.IsInFaction(PlayerFollowerFaction) || that.IsPlayerTeammate()
  int j = JMap.getObj(jTmp, "bGenderPartner")
  If(fol && !JArray.getInt(j, 0) || !fol && !JArray.getInt(j, GetActorType(that) + 1))
    Debug.Trace("[SMM] Invalid Partner Gender")
    return false
  EndIf
  int arousal = SMMAnimation.GetArousal(that)
  bool aroused
  If(fol)
    aroused = arousal >= JMap.getInt(jTmp, "iArousalPartnerFol")
  Else
    aroused = arousal >= JMap.getInt(jTmp, "iArousalPartner")
  EndIf
  Debug.TraceConditional("[SMM] Invalid Partner Arousal", !aroused)
  return aroused
EndFunction

bool Function isValidGenderCombination(Actor init, Actor partner)
  bool ret = false
  bool followerInit = init.IsInFaction(PlayerFollowerFaction) || init.IsPlayerTeammate()
  If(partner.IsInFaction(PlayerFollowerFaction) || partner.IsPlayerTeammate())
    int row = GetActorType(partner) * 7
    If(init == PlayerRef)
      ret = MCM.bAssaultFol[row]
    ElseIf(followerInit)
      ret = MCM.bAssaultFol[row + 1]
    Else
      ret = MCM.bAssaultFol[row + GetActorType(init) + 2]
    EndIf
  Else
    int row = GetActorType(partner) * 7
    If(init == PlayerRef)
      ret = MCM.bAssaultNPC[row]
    ElseIf(followerInit)
      ret = MCM.bAssaultNPC[row + 1]
    Else
      ret = MCM.bAssaultNPC[row + GetActorType(init) + 2]
    EndIf
  EndIf
  Debug.TraceConditional("[SMM] Invalid Gender Combination", !ret)
  return ret
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
;0 - Male, 1 - Female, 2 - Futa, 3 - Male Creature, 4 - Female Creature
int Function GetActorType(Actor me)
  return SexLabUtil.GetAPI().GetSex(me)
endFunction

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
    Debug.Trace("[SMM] <IsValidRace> " + myRace + " returned outside the Valid Range: " + myPlace)
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
        Debug.Trace("[SMM] <IsValidRace> " + myRace + " returned outside the Valid Range: " + myPlace)
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
    Actor subject = (aliases[i] as ReferenceAlias).GetReference() as Actor
    If(subject && JMap.getFlt(jCooldowns, subject.GetFormID() as String) + (MCM.fEngageCooldown / 24) < GameDaysPassed.Value)
      bool accept = false
      bool npc = subject.HasKeyword(ActorTypeNPC)
      If(!npc && (!MCM.bSLAllowed || !IsValidRace(subject)))
        ;
      ElseIf(subject.IsInFaction(PlayerFollowerFaction) || subject.IsPlayerTeammate())
        accept = JMap.getInt(jProfile, "bConsiderFollowers")
      Else
        int considerRace = JMap.getInt(jProfile, "lConsiderCreature")
        If(considerRace == 0 || npc && considerRace == 1 || !npc && considerRace == 2)
          bool hostile = subject.IsHostileToActor(PlayerRef)
          int considerAlly = JMap.getInt(jProfile, "lConsider")
          accept = considerAlly == 0 || !hostile && considerAlly == 1 || hostile && considerAlly == 2
        EndiF
      EndIf
      If(accept)
        ret[i] = subject
      EndIf
    EndIf
    i += 1
  EndWhile
  return PapyrusUtil.RemoveActor(ret, none)
EndFunction

Function ShutDown()
  jProfile = JValue.release(jProfile)
  PlayerScr.RegisterForSingleUpdate(MCM.iTickInterval)
EndFunction

; 70unit = 1m
