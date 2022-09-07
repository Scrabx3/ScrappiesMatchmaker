Scriptname SMMThread extends Quest Conditional
{Generic Thread Script. Takes on Aliases and starts a Scene once no more Aliases can be added anymore}

SMMMCM Property MCM Auto
SMMScan Property Scan Auto
Scene Property MyScene Auto
Spell Property GatherSurroundingActors Auto
; NOTE: Alias with ID 0 is considered the Initiator; Alias with ID 1+ are Partners
int Property consent Auto Conditional Hidden
int jCooldown
int jActors
int jProfile
Actor init
Actor[] partners
; NOTE: partners includes a Set of Actors which participated in the previous Animation. They are also always an Alias in this Thread
; After an Animation ended there will be a quick Check if a Partner should stay interested, otherwise they are sorted out of the Array and Quest
; New Actors may be added to the Quest during an Animation and will be added to this Partners Array if possible
String Property filePathCooldown = "Data\\SKSE\\SMM\\Definition\\Cooldowns.json" AutoReadOnly Hidden

; =========================================================================
; ============================================ START UP
; ========================================================================
Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  jCooldown = JValue.retain(JValue.readFromFile(filePathCooldown))
  init = akRef1 as Actor
  jActors = aiValue1
  jProfile = JValue.retain(aiValue2)
  consent = JMap.getInt(jProfile, "bConsent")
  Debug.Trace("[SMM] <Thread> ID: " + self + " | Initiator = " + init)
  ; Collect the Actors to start the Scene with
  If(jActors != 0)
    Form[] jActorForms = SMMUtility.asJFormArray(jActors)
    partners = PapyrusUtil.ActorArray(jActorForms.Length)
    int i = 0
    While(i < partners.length)
      partners[i] = jActorForms[i] as Actor
      i += 1
    EndWhile
    DefClosest(partners)
    int n = 0
    While(n < partners.Length)
      (GetNthAlias(n + 1) as ReferenceAlias).ForceRefTo(partners[n])
      partners[n].StopCombat()
      partners[n].StopCombatAlarm()
      partners[n].EvaluatePackage()
      n += 1
    EndWhile
  EndIf
  ; Start Scene
  MyScene.Start()
  If(!MyScene.IsPlaying())
    Debug.Trace("[SMM] " + self + " Scene Failed to Start")
    Stop()
  Else
    partners[0].EvaluatePackage()
  EndIf
EndEvent

Function DefClosest(Actor[] them)
  float c = them[0].GetDistance(init)
  int slot0 = 0
  int i = 1
  While(i < them.Length)
    float d = them[i].GetDistance(init)
    If(d < c)
      c = d
      slot0 = i
    EndIf
    i += 1
  EndWhile
  If(slot0 != 0)
    Actor tmp = them[0]
    them[0] = them[slot0]
    them[slot0] = tmp
  EndIf
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
  RegisterForModEvent("ostim_end", "AfterSceneOStim")
  scenesPlayed = 1
  If(jActors == 0 || JArray.count(jActors) == 0) ; Empty Array, 1p Scene
    If(SMMAnimation.StartAnimationSingle(MCM, init, hook) == -1)
      Debug.Trace("[SMM] " + self + " Failed to start 1p Animation | Initiator = " + init)
      Stop()
      return
    EndIf
    Debug.Trace("[SMM] " + self + " Successfully started 1p Animation | Initiator = " + init)
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
    StartAnimation()
  EndIf
  init.AddSpell(GatherSurroundingActors, false)
EndFunction

; =========================================================================
; ============================================ ANIMATIONS
; ========================================================================
int scenesPlayed
String hook

Function StartAnimation()
  If(SMMAnimation.StartAnimation(MCM, init, partners, (1 - consent), hook) == -1)
    Debug.Trace("[SMM] " + self + " Failed to Start 2p+ Animation " + scenesPlayed + " | Initiator: " + init)
    Stop()
    return
  EndIf
  Debug.Trace("[SMM] " + self + " Successfully started 2p+ Animation " + scenesPlayed + " | Initiator: " + init)
EndFunction
Event AfterSceneSL(int tid, bool hasPlayer)
  Debug.Trace("[SMM] " + self + " Animation End (SL)")
  PostScene(-2)
EndEvent
Event AfterSceneOStim(string asEventName, string asStringArg, float afNumArg, form akSender)
  Debug.Trace("[SMM] " + self + " Animation End (OStim)")
  PostScene(afNumArg as int)
EndEvent
Function PostScene(int ID)
  If(ID > -2)
    Actor[] positions = SMMAnimationOStim.GetPositions(ID)
    If(positions.find(init) == -1)
      return
    EndIf
  EndIf
  If(!playNextScene())
    SetStage(5)
  Else
    ; Start another Scene
    scenesPlayed += 1
    ; Remove Partners which arent staying
    int n = 0
    While(n < partners.Length)
      If(Utility.RandomFloat(0, 99.9) >= MCM.fResNextRoundChance)
        JMap.setFlt(jCooldown, partners[n].GetFormID(), Scan.GameDaysPassed.Value)
        ClearActor(partners[n])
        partners[n] = none
      EndIf
      n += 1
    EndWhile
    ; Update Partner Array
    int maxPartners = SMMAnimation.GetAllowedParticipants(5)
    If(maxPartners != partners.Length)
      ; If we got more Partners than currently allowed, remove the ones too much
      If(maxPartners < partners.Length)
        int i = partners.Length
        While(i > maxPartners)
          i -= 1
          JMap.setFlt(jCooldown, partners[i].GetFormID(), Scan.GameDaysPassed.Value)
        EndWhile
      EndIf
      partners = PapyrusUtil.ResizeActorArray(partners, maxPartners)
    EndIf
    Alias[] them = GetAliases()
    int i = 1 ; 0 is Init
    int ii = 0
    While(i < them.Length && ii < maxPartners)
      Actor tmp = (them[i] as ReferenceAlias).GetReference() as Actor
      If(tmp && partners.Find(tmp) == -1 && Utility.RandomFloat(0, 99.9) < MCM.fAddActorChance)
        int empty = partners.Find(none)
        If(empty > -1)
          If(Scan.isValidGenderCombination(init, tmp) && Scan.IsValidRace(tmp) && Scan.ValidPartner(tmp, jProfile) && Scan.ValidMatch(init, tmp, jProfile))
            partners[empty] = tmp
            ii += 1
          EndIf
        Else
          ii = maxPartners
        EndIf
      EndIf
      i += 1
    EndWhile
    partners = PapyrusUtil.RemoveActor(partners, none)
    If(partners.Length)
      StartAnimation()
    Else
      SetStage(5)
    EndIf
  EndIf
EndFunction
bool Function playNextScene()
	return MCM.iResMaxRounds == 0 || scenesPlayed < MCM.iResMaxRounds
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
  JValue.writeToFile(jCooldown, filePathCooldown)
  jCooldown = JValue.release(jCooldown)
  jActors = JValue.release(jActors)
  jProfile = JValue.release(jProfile)
EndFunction
Actor Function GetInit()
  If(!partners.Length)
    return none
  EndIf
  return partners[0]
EndFunction