Scriptname SMMThread extends Quest Conditional
{Generic Thread Script. Takes on Aliases and starts a Scene once no more Aliases can be added anymore}

SMMMCM Property MCM Auto
SMMScan Property Scan Auto
Scene Property MyScene Auto
Spell Property GatherSurroundingActors Auto
; NOTE: Alias with ID 0 is considered the Initiator; Alias with ID 1+ are Partners
int Property consent Auto Conditional Hidden
int jCooldown     ; JMap storing new Cooldown Values
int jActors       ; Array of the original Actors
int jProfile      ; MCM Profile
Actor init        ; Center Actor for this Thread
Actor[] partners  ; Actors of the most recent animation

String Property filePathCooldown = "Data\\SKSE\\SMM\\Definition\\Cooldowns.json" AutoReadOnly Hidden

; =========================================================================
; ============================================ START UP
; ========================================================================
Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  jCooldown = JValue.retain(JMap.object())
  init = akRef1 as Actor
  jActors = aiValue1
  jProfile = JValue.retain(aiValue2)
  consent = JMap.getInt(jProfile, "bConsent")
  Debug.Trace("[SMM] <Thread> ID: " + self + " | Initiator = " + init)
  If(jActors > 0)
    Form[] jActorForms = SMMUtility.asJFormArray(jActors)
    partners = PapyrusUtil.ActorArray(jActorForms.Length)
    int i = 0
    While(i < partners.length)
      partners[i] = jActorForms[i] as Actor
      i += 1
    EndWhile
    partners = DefClosest(partners)
    int n = 0
    While(n < partners.Length)
      (GetNthAlias(n + 1) as ReferenceAlias).ForceRefTo(partners[n])
      partners[n].StopCombat()
      partners[n].StopCombatAlarm()
      partners[n].EvaluatePackage()
      n += 1
    EndWhile
  EndIf  

  MyScene.Start()
  If(!MyScene.IsPlaying())
    Debug.Trace("[SMM] " + self + " Scene Failed to Start")
    Stop()
  ElseIf(partners.Length)
    partners[0].EvaluatePackage()
  EndIf
EndEvent

Actor[] Function DefClosest(Actor[] akActors)
  float c = akActors[0].GetDistance(init)
  int slot0 = 0
  int i = 1
  While(i < akActors.Length)
    float d = akActors[i].GetDistance(init)
    If(d < c)
      c = d
      slot0 = i
    EndIf
    i += 1
  EndWhile
  If(slot0 != 0)
    Actor tmp = akActors[0]
    akActors[0] = akActors[slot0]
    akActors[slot0] = tmp
  EndIf
  return akActors
EndFunction

; Called from the Quest Scene after Init has been approached
Function StartScene()
  If(init == Game.GetPlayer())
    Game.SetPlayerAIDriven(true)
  Else
    init.SetRestrained(true)
  EndIf
  hook = GetID()
  RegisterForModEvent("HookAnimationEnd_" + hook, "AfterSceneSL")
  scenesPlayed = 1
  If(jActors == 0 || JArray.count(jActors) == 0) ; Empty Array, 1p Scene
    If(SMMAnimation.StartAnimationSingle(MCM, init, hook) == -1)
      Debug.Trace("[SMM] " + self + " Failed to create 1p scene")
      Stop()
      return
    EndIf
  Else ; 2p+ Scene
    Actor[] them = PapyrusUtil.ActorArray(partners.Length)
    int i = 0
    While(i < partners.Length)
      If(partners[i].GetDistance(init) < 650)
        them[i] = partners[i]
      EndIf
      i += 1
    EndWhile
    partners = PapyrusUtil.RemoveActor(them, none)
    If(SMMAnimation.StartAnimation(MCM, init, partners, (1 - consent), hook) == -1)
      Debug.Trace("[SMM] " + self + " Failed to create 2p+ scene | partners = " + partners)
      Stop()
      return
    EndIf
  EndIf
  init.AddSpell(GatherSurroundingActors, false)
EndFunction

; =========================================================================
; ============================================ ANIMATIONS
; ========================================================================
int scenesPlayed
String hook

Event AfterSceneSL(int tid, bool hasPlayer)
  If(MCM.iResMaxRounds > 0 && scenesPlayed >= MCM.iResMaxRounds)
    SetStage(5)
    return
  EndIf
  scenesPlayed += 1

  ; Remove 'satisfied' partners
  int n = 0
  While(n < partners.Length)
    If(Utility.RandomFloat(0, 99.9) >= MCM.fResNextRoundChance)
      JMap.setFlt(jCooldown, partners[n].GetFormID(), Scan.GameDaysPassed.Value)
      ClearActor(partners[n])
    EndIf
    n += 1
  EndWhile

  CreateNewPartners()
  If(partners.Length)
    If(SMMAnimation.StartAnimation(MCM, init, partners, (1 - consent), hook) > -1)
      return
    EndIf
    Debug.Trace("[SMM] " + self + " Failed to create 2p+ scene | partners = " + partners)
  EndIf
  SetStage(5)
EndEvent

Function CreateNewPartners()
  Actor[] previous = PapyrusUtil.RemoveActor(partners, none)
  int maxPartners = SMMAnimation.GetAllowedParticipants(5) - 1
  partners = PapyrusUtil.ActorArray(maxPartners)

  Alias[] aliases = GetAliases()
  int timeout = 50 ; 0 is Init
  While(timeout)
    timeout -= 1
    int where = Utility.RandomInt(1, aliases.length)
    Actor it = (aliases[where] as ReferenceAlias).GetReference() as Actor
    If(it && partners.Find(it) == -1 && (previous.Find(it) || Utility.RandomFloat(0, 99.9) < MCM.fAddActorChance))
      If(Scan.isValidGenderCombination(init, it) && Scan.IsValidRace(it) && Scan.ValidPartner(it, jProfile) && Scan.ValidMatch(init, it, jProfile))
        int n = partners.RFind(none)
        partners[n] = it
        If(n == 0)
          return
        EndIf
      EndIf
    EndIf
  EndWhile
  partners = PapyrusUtil.RemoveActor(partners, none)
EndFunction

bool Function AddActor(Actor that)
  Alias[] them = GetAliases()
  int i = 1
  While(i < them.Length)
    ReferenceAlias tmp = them[i] as ReferenceAlias
    If(tmp.ForceRefIfEmpty(that))
      that.EvaluatePackage()
      return true
    EndIf
    i += 1
  EndWhile
  return false
EndFunction

bool Function ClearActor(ObjectReference that)
  Alias[] them = GetAliases()
  int i = 1
  While(i < them.Length)
    ReferenceAlias tmp = them[i] as ReferenceAlias
    If(tmp.GetReference() == that)
      tmp.Clear()
      return true
    EndIf
    i += 1
  EndWhile
  return false
EndFunction

Function CleanUp()
  Debug.Trace("[SMM] " + Self + " Thread Stopped with Initiator: " + init + " (" + init.GetLeveledActorBase().GetName() + ")")
  SMMAnimation.StopAnimating(init)
  If(init == Game.GetPlayer())
    Game.SetPlayerAIDriven(false)
  Else
    init.SetRestrained(false)
  EndIf
  init.RemoveSpell(GatherSurroundingActors)
  StorageUtil.SetFormValue(init, "Thread", none)

  JMap.setFlt(jCooldown, init.GetFormID(), Scan.GameDaysPassed.Value)
  int i = 0
  While(i < partners.Length)
    JMap.setFlt(jCooldown, partners[i].GetFormID(), Scan.GameDaysPassed.Value)
    i += 1
  EndWhile
  int jCdFile = JValue.readFromFile(filePathCooldown)
  JMap.addPairs(jCdFile, jCooldown, true)
  JValue.writeToFile(jCooldown, filePathCooldown)
  jActors = JValue.release(jActors)
  jProfile = JValue.release(jProfile)
  jCooldown = JValue.release(jCooldown)
EndFunction
Actor Function GetInit()
  return init
EndFunction
