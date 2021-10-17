Scriptname SMMScan extends Quest
{Mainscript for Starting Animations}

SMMPlayer Property Player Auto
Keyword Property smThread Auto
{Keyword for Story Manager to start Quests from}
; --------------- Variables
SMMThread thisThread

; --------------- Code
Event OnInit()
  If(!IsRunning())
    return
  ElseIf(!smThread.SendStoryEventAndWait())
    GoToState("NoThread")
  EndIf
  RegisterForSingleUpdate(3)
EndEvent
State NoThread
  Event OnUpdate()
    Stop()
  EndEvent
EndState

Function SetReady(SMMThread thread)
  thisThread = thread
EndFunction

Event OnUpdate()
  Actor[] ColAct = GetActors()
EndEvent

Actor[] Function GetActors()
  int numAlias = GetNumAliases()
  Actor[] ret = PapyrusUtil.ActorArray(numAlias, none)
  int i = 0
  While(i < numAlias)
    ret[i] = (GetAlias(i) as ReferenceAlias).GetReference() as Actor
    i += 1
  EndWhile
  return PapyrusUtil.RemoveActor(ret, none)
EndFunction




;/ -------------------------- Properties
SexLabFramework Property SL Auto
slaFrameworkScr Property Aroused Auto
SMMPlayer Property PlayerScr Auto
SMMMCM Property MCM auto
Actor Property PlayerRef Auto
Faction Property currentfollowerfaction Auto
Spell Property CalmSpell Auto
Keyword Property ActorTypeNPC Auto
Faction Property FriendFaction Auto
Faction Property tmpTeam Auto
;Dont like not using an Array here but apparently Papyrus doesnt like Arrays here so I had to do it this way.. I cry
ReferenceAlias Property Player Auto
ReferenceAlias Property Follower1 Auto
ReferenceAlias Property Follower2 Auto
ReferenceAlias Property Follower3 Auto
ReferenceAlias Property Actor0 Auto
ReferenceAlias Property Actor1 Auto
ReferenceAlias Property Actor2 Auto
ReferenceAlias Property Actor3 Auto
ReferenceAlias Property Actor4 Auto
ReferenceAlias Property Actor5 Auto
ReferenceAlias Property Actor6 Auto
ReferenceAlias Property Actor7 Auto
ReferenceAlias Property Actor8 Auto
ReferenceAlias Property Actor9 Auto
ReferenceAlias Property Actor10 Auto
ReferenceAlias Property Actor11 Auto
ReferenceAlias Property Actor12 Auto
ReferenceAlias Property Actor13 Auto
ReferenceAlias Property Actor14 Auto

; -------------------------- Variables
Actor ToEngage
Actor[] PotentialAggressors
int ValidAggressor
Race vicRace
Race aggrRace

; -------------------------- Code
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

Actor[] Function GetFilledActors()
  Actor[] DummyArray = new Actor[20]
  int ActorCount = 0
  If(Player.GetReference() != none)
    DummyArray[ActorCount] = Player.GetReference() as Actor
    ActorCount += 1
  Endif
  If(Follower1.GetReference() != none)
    DummyArray[ActorCount] = Follower1.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Follower2.GetReference() != none)
    DummyArray[ActorCount] = Follower2.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Follower3.GetReference() != none)
    DummyArray[ActorCount] = Follower3.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor0.GetReference() != none)
    DummyArray[ActorCount] = Actor0.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor1.GetReference() != none)
    DummyArray[ActorCount] = Actor1.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor2.GetReference() != none)
    DummyArray[ActorCount] = Actor2.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor3.GetReference() != none)
    DummyArray[ActorCount] = Actor3.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor5.GetReference() != none)
    DummyArray[ActorCount] = Actor5.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor6.GetReference() != none)
    DummyArray[ActorCount] = Actor6.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor7.GetReference() != none)
    DummyArray[ActorCount] = Actor7.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor8.GetReference() != none)
    DummyArray[ActorCount] = Actor8.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor9.GetReference() != none)
    DummyArray[ActorCount] = Actor9.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor10.GetReference() != none)
    DummyArray[ActorCount] = Actor10.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor11.GetReference() != none)
    DummyArray[ActorCount] = Actor11.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor12.GetReference() != none)
    DummyArray[ActorCount] = Actor12.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor13.GetReference() != none)
    DummyArray[ActorCount] = Actor13.GetReference() as Actor
    ActorCount += 1
  EndIf
  If(Actor14.GetReference() != none)
    DummyArray[ActorCount] = Actor14.GetReference() as Actor
  EndIf
  return PapyrusUtil.RemoveActor(DummyArray, none)
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

State Wolf
  Actor Function GetValidVictim(Actor[] myActors)
    ; Debug.Trace("RMM: Checking for Victim.. ")
    If(Utility.RandomInt(1, 100) <= MCM.iPrefPlWolf && Player.GetReference() && IsValidVic(PlayerRef))
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
    If(MCM.bUseArousalWolf && !MCM.bIgnoreVicArousalWolf)
      If(Aroused.GetActorArousal(target) < MCM.iArousalThreshWolf)
        return false
      EndIf
    endif
    If(!MCM.bHostVicWolf)
      If(target != PlayerRef && target.IsHostileToActor(PlayerRef))
        return false
      EndIf
    EndIf
    If(Target == PlayerRef) ; Player
      If(MCM.bEngagePlWolf)
        return true
      else
        return false
      EndIf
    elseIf(Target.IsInFaction(currentfollowerfaction)) ; Follower
      If(!MCM.bEngageFolWolf)
        return false
      ElseIf(!MCM.bRestrictGenFolWolf)
        return true
      EndIf
    elseIf(target.HasKeyword(ActorTypeNPC)) ; NPC
      If(!MCM.bEngageNPCWolf)
        return false
      ElseIf(!MCM.bRestrictGenNPCWolf)
        return true
      EndIf
    else ; Creature
      If(!MCM.bEngageCreatureWolf)
        return false
      ElseIf(!MCM.bRestrictGenCrtWolf)
        return true
      EndIf
    EndIf
    ;0 - Male, 1 - Female, 2 - Futa, 3 - Creature Mal, 4 - Creature Fem
    int gender = GetActorType(target)
    If(gender == 0 && MCM.bEngageMaleWolf)
      return true
    ElseIf(gender == 1 && MCM.bEngageFemaleWolf)
      return true
    ElseIf(gender == 2 && MCM.bEngageFutaWolf)
      return true
    ElseIf(gender == 3 && MCM.bEngageCrMWolf)
      return true
    ElseIf(gender == 4 && MCM.bEngageCrFWolf)
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
    ; Gendercheck
    If(!checkFilter(GetActorType(target), target.IsInFaction(currentfollowerfaction)))
      return false
    EndIf
    ; Hostility & Combat Check
    If(target.IsInCombat())
      return false
    ElseIf(target.IsHostileToActor(ToEngage))
      If(!MCM.bHostOnFriendWolf)
        return false
      EndIf
    EndIf
    ; Engage Settings
    If(MCM.bUseArousalWolf)
      If(Aroused.GetActorArousal(target) < MCM.iArousalThreshWolf)
        return false
      EndIf
    EndIf
    If(MCM.bUseDistWolf)
      If(ToEngage.GetDistance(Target) > MCM.fMaxDistanceWolf*70)
        return false
      EndIf
    EndIf
    If(MCM.bUseLoSWolf)
      If(!Target.HasLOS(ToEngage))
        return false
      EndIf
    EndIf
    If(MCM.bUseDispotionWolf)
      If(ToEngage == PlayerRef && Target.GetRelationshipRank(PlayerRef) < MCM.iMinDispPlWolf)
        return false
      ElseIf(ToEngage.IsInFaction(currentfollowerfaction) && Target.GetRelationshipRank(PlayerRef) < MCM.iMinDispFolWolf)
        return false
      ElseIf(Target.GetRelationshipRank(ToEngage) < MCM.iMinDispNPCWolf)
        return false
      EndIf
    EndIf
    return true
  EndFunction
endState

State Bunny
  Actor Function GetValidVictim(Actor[] myActors)
    ; Debug.Trace("RMM: Checking for Victim.. ")
    If(Utility.RandomInt(1, 100) <= MCM.iPrefPlBunny && Player.GetReference() && IsValidVic(PlayerRef))
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
    If(MCM.bUseArousalBunny && !MCM.bIgnoreVicArousalBunny)
      If(Aroused.GetActorArousal(target) < MCM.iArousalThreshBunny)
        return false
      EndIf
    endif
    If(!MCM.bHostVicBunny)
      If(target != PlayerRef && target.IsHostileToActor(PlayerRef))
        return false
      EndIf
    EndIf
    If(Target == PlayerRef) ; Player
      If(MCM.bEngagePlBunny)
        return true
      else
        return false
      EndIf
    elseIf(Target.IsInFaction(currentfollowerfaction)) ; Follower
      If(!MCM.bEngageFolBunny)
        return false
      ElseIf(!MCM.bRestrictGenFolBunny)
        return true
      EndIf
    elseIf(target.HasKeyword(ActorTypeNPC)) ; NPC
      If(!MCM.bEngageNPCBunny)
        return false
      ElseIf(!MCM.bRestrictGenNPCBunny)
        return true
      EndIf
    else ; Creature
      If(!MCM.bEngageCreatureBunny)
        return false
      ElseIf(!MCM.bRestrictGenCrtBunny)
        return true
      EndIf
    EndIf
    ;0 - Male, 1 - Female, 2 - Futa, 3 - Creature Mal, 4 - Creature Fem
    int gender = GetActorType(target)
    If(gender == 0 && MCM.bEngageMaleBunny)
      return true
    ElseIf(gender == 1 && MCM.bEngageFemaleBunny)
      return true
    ElseIf(gender == 2 && MCM.bEngageFutaBunny)
      return true
    ElseIf(gender == 3 && MCM.bEngageCrMBunny)
      return true
    ElseIf(gender == 4 && MCM.bEngageCrFBunny)
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
    ; Gendercheck
    If(!checkFilter(GetActorType(target), target.IsInFaction(currentfollowerfaction)))
      return false
    EndIf
    ; Hostility & Combat Check
    If(target.IsInCombat())
      return false
    ElseIf(target.IsHostileToActor(ToEngage))
      If(!MCM.bHostOnFriendBunny)
        return false
      EndIf
    EndIf
    ; Engage Settings
    If(MCM.bUseArousalBunny)
      If(Aroused.GetActorArousal(target) < MCM.iArousalThreshBunny)
        return false
      EndIf
    EndIf
    If(MCM.bUseDistBunny)
      If(ToEngage.GetDistance(Target) > MCM.fMaxDistanceBunny*70)
        return false
      EndIf
    EndIf
    If(MCM.bUseLoSBunny)
      If(!Target.HasLOS(ToEngage))
        return false
      EndIf
    EndIf
    If(MCM.bUseDispotionBunny)
      If(ToEngage == PlayerRef && Target.GetRelationshipRank(PlayerRef) < MCM.iMinDispPlBunny)
        return false
      ElseIf(ToEngage.IsInFaction(currentfollowerfaction) && Target.GetRelationshipRank(PlayerRef) < MCM.iMinDispFolBunny)
        return false
      ElseIf(Target.GetRelationshipRank(ToEngage) < MCM.iMinDispNPCBunny)
        return false
      EndIf
    EndIf
    return true
  EndFunction
endState

; Utility Functions
;0 - Male, 1 - Female, 2 - Futa, 3 - Male Creature, 4 - Female Creature
int Function GetActorType(Actor me)
  If(SL)
    int mySLGender = SL.GetGender(me)
    If(mySLGender == 3) ;Female Creature
      return 4
    ElseIf(mySLGender == 2) ;Male Creature
      return 3
    Else ;Humanoid
      int myVanillaGender = me.GetLeveledActorBase().GetSex()
      If(myVanillaGender == mySLGender) ;Either male or female
        return myVanillaGender
      Else ;Futa
        return 2
      EndIf
    EndIf
  else
    ; If SL isnt found, we just return the Vanilla Gender
    return me.GetLeveledActorBase().GetSex()
  EndIf
endFunction

bool Function checkFilter(int aggrGen, bool isFollower)
  If(ToEngage == PlayerRef)
    If(isFollower)
      If(aggrGen == 0 && MCM.bMalFolAssPl)
        return true
      ElseIf(aggrGen == 1 && MCM.bFemFolAssPl)
        return true
      ElseIf(aggrGen == 2 && MCM.bFutFolAssPl)
        return true
      ElseIf(aggrGen == 3 && MCM.bCrMFolAssPl)
        return true
      ElseIf(aggrGen == 4 && MCM.bCrFFolAssPl)
        return true
      EndIf
    else
      If(aggrGen == 0 && MCM.bAssMalPl)
        return true
      ElseIf(aggrGen == 1 && MCM.bAssFemPl)
        return true
      ElseIf(aggrGen == 2 && MCM.bAssFutPl)
        return true
      ElseIf(aggrGen == 3 && MCM.bAssMalCrPl)
        return true
      ElseIf(aggrGen == 4 && MCM.bAssFemCrPl)
        return true
      EndIf
    EndIf
  ElseIf(ToEngage.IsInFaction(currentfollowerfaction))
    If(isFollower)
      If(aggrGen == 0 && MCM.bMalFolAssFol)
        return true
      ElseIf(aggrGen == 1 && MCM.bFemFolAssFol)
        return true
      ElseIf(aggrGen == 2 && MCM.bFutFolAssFol)
        return true
      ElseIf(aggrGen == 3 && MCM.bCrMFolAssFol)
        return true
      ElseIf(aggrGen == 4 && MCM.bCrFFolAssFol)
        return true
      EndIf
    else
      If(aggrGen == 0 && MCM.bAssMalFol)
        return true
      ElseIf(aggrGen == 1 && MCM.bAssFemFol)
        return true
      ElseIf(aggrGen == 2 && MCM.bAssFutFol)
        return true
      ElseIf(aggrGen == 3 && MCM.bAssMalCrFol)
        return true
      ElseIf(aggrGen == 4 && MCM.bAssFemCrFol)
        return true
      EndIf
    EndIf
  Else
    int vicGen = GetActorType(ToEngage)
    If(vicGen == 0)
      If(isFollower)
        If(aggrGen == 0 && MCM.bMalFolAssMal)
          return true
        ElseIf(aggrGen == 1 && MCM.bFemFolAssMal)
          return true
        ElseIf(aggrGen == 3 && MCM.bCrMFolAssMal)
          return true
        ElseIf(aggrGen == 2 && MCM.bFutFolAssMal)
          return true
        ElseIf(aggrGen == 4 && MCM.bCrFFolAssMal)
          return true
        EndIf
      else
        If(aggrGen == 0 && MCM.bAssMalMal)
          return true
        ElseIf(aggrGen == 1 && MCM.bAssFemMal)
          return true
        ElseIf(aggrGen == 3 && MCM.bAssMalCrMal)
          return true
        ElseIf(aggrGen == 2 && MCM.bAssFutMal)
          return true
        ElseIf(aggrGen == 4 && MCM.bAssFemCrMal)
          return true
        EndIf
      EndIf
    ElseIf(vicGen == 1)
      If(isFollower)
        If(aggrGen == 0 && MCM.bMalFolAssFem)
          return true
        ElseIf(aggrGen == 1 && MCM.bFemFolAssFem)
          return true
        ElseIf(aggrGen == 3 && MCM.bCrMFolAssFem)
          return true
        ElseIf(aggrGen == 2 && MCM.bFutFolAssFem)
          return true
        ElseIf(aggrGen == 4 && MCM.bCrFFolAssFem)
          return true
        EndIf
      else
        If(aggrGen == 0 && MCM.bAssMalFem)
          return true
        ElseIf(aggrGen == 1 && MCM.bAssFemFem)
          return true
        ElseIf(aggrGen == 3 && MCM.bAssMalCrFem)
          return true
        ElseIf(aggrGen == 2 && MCM.bAssFutFem)
          return true
        ElseIf(aggrGen == 4 && MCM.bAssFemCrFem)
          return true
        EndIf
      EndIf
    ElseIf(vicGen == 3)
      If(isFollower)
        If(aggrGen == 0 && MCM.bMalFolAssCrM)
          return true
        ElseIf(aggrGen == 1 && MCM.bFemFolAssCrM)
          return true
        ElseIf(aggrGen == 3 && MCM.bCrMFolAssCrM)
          return true
        ElseIf(aggrGen == 2 && MCM.bFutFolAssCrM)
          return true
        ElseIf(aggrGen == 4 && MCM.bCrFFolAssCrM)
          return true
        EndIf
      else
        If(aggrGen == 0 && MCM.bAssMalCreat)
          return true
        ElseIf(aggrGen == 1 && MCM.bAssFemCreat)
          return true
        ElseIf(aggrGen == 3 && MCM.bAssMalCrCreat)
          return true
        ElseIf(aggrGen == 2 && MCM.bAssFutCreat)
          return true
        ElseIf(aggrGen == 4 && MCM.bAssFemCrCreat)
          return true
        EndIf
      EndIf
    ElseIf(vicGen == 2)
      If(isFollower)
        If(aggrGen == 0 && MCM.bMalFolAssFut)
          return true
        ElseIf(aggrGen == 1 && MCM.bFemFolAssFut)
          return true
        ElseIf(aggrGen == 3 && MCM.bCrMFolAssFut)
          return true
        ElseIf(aggrGen == 2 && MCM.bFutFolAssFut)
          return true
        ElseIf(aggrGen == 4 && MCM.bCrFFolAssFut)
          return true
        EndIf
      else
        If(aggrGen == 0 && MCM.bAssMalFut)
          return true
        ElseIf(aggrGen == 1 && MCM.bAssFemFut)
          return true
        ElseIf(aggrGen == 3 && MCM.bAssMalCrFut)
          return true
        ElseIf(aggrGen == 2 && MCM.bAssFutFut)
          return true
        ElseIf(aggrGen == 4 && MCM.bAssFemCrFut)
          return true
        EndIf
      EndIf
    ElseIf(vicGen == 4)
      If(isFollower)
        If(aggrGen == 0 && MCM.bMalFolAssCrF)
          return true
        ElseIf(aggrGen == 1 && MCM.bFemFolAssCrF)
          return true
        ElseIf(aggrGen == 3 && MCM.bCrMFolAssCrF)
          return true
        ElseIf(aggrGen == 2 && MCM.bFutFolAssCrF)
          return true
        ElseIf(aggrGen == 4 && MCM.bCrFFolAssCrF)
          return true
        EndIf
      else
        If(aggrGen == 0 && MCM.bAssMalFemCreat)
          return true
        ElseIf(aggrGen == 1 && MCM.bAssFemFemCreat)
          return true
        ElseIf(aggrGen == 3 && MCM.bAssMalCrFemCreat)
          return true
        ElseIf(aggrGen == 2 && MCM.bAssFutFemCreat)
          return true
        ElseIf(aggrGen == 4 && MCM.bAssFemCrFemCreat)
          return true
        EndIf
      EndIf
    EndIf
  EndIf
  return false
EndFunction


; State Functions
Actor Function GetValidVictim(Actor[] myActors)
endFunction

bool Function IsValidVic(Actor Target)
endFunction

Actor[] Function GetAggressors(Actor[] myActors)
endFunction

bool Function IsValidAg(Actor Target)
endFunction
/; 

; 70unit = 1m
