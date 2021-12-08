Scriptname SMMThread extends Quest Conditional
{Generic Thread Script. Takes on Aliases and starts a Scene once no more Aliases can be added anymore}

SMMMCM Property MCM Auto
SMMScan Property Scan Auto
Scene Property MyScene Auto
Spell Property GatherSurroundingActors Auto
; NOTE: Alias with ID 0 is considered the Initiator; Alias with ID 1+ are Partners
int Property consent Auto Conditional Hidden
int jCd
int jActors
int jProfile
Actor init
Actor[] partners
; NOTE: partners includes a Set of Actors which participated in the previous Animation. They are also always an Alias in this Thread
; After an Animation ended there will be a quick Check if a Partner should stay interested, otherwise they are sorted out of the Array and Quest
; New Actors may be added to the Quest during an Animation and will be added to this Partners Array if possible
String filePathCooldown = "Data\\SKSE\\SMM\\Definition\\Cooldowns.json"

; =========================================================================
; ============================================ START UP
; ========================================================================
Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  jCd = JValue.retain(JValue.readFromFile(filePathCooldown))
  init = akRef1 as Actor
  jActors = aiValue1
  jProfile = JValue.retain(aiValue2)
  consent = JMap.getInt(jProfile, "bConsent")
  Debug.Trace("[SMM] Started Thread. ID: " + Self + " | Initiator: " + init + "| Name: " + init.GetLeveledActorBase().GetName())
  If(jActors != 0)
    ; Fill Aliases
    Form[] jActorForms = JArray.asFormArray(jActors)
    ; Form[] jActorForms = SMMMCM.asJFormArray(jActors)
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
    Debug.Trace("[SMM] " + Self + " Scene Failed to Start")
    Stop()
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
  If(jActors == 0) ; Empty Array, 1p Scene
    int s = SMMAnimFrame.StartAnimationSingle(MCM, init, hook)
    String initName = init.GetLeveledActorBase().GetName()
    If(s == -1)
      Debug.Trace("[SMM] " + Self + " Failed to start 1p Animation | Initiator: " + init + " | Name: " + initName)
      Stop()
      return
    EndIf
    Debug.Trace("[SMM] " + Self + " Successfully started 1p Animation | Initiator: " + init + " | Name: " + initName)
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
  StorageUtil.SetFormValue(init, "SMMThread", Self)
  init.AddSpell(GatherSurroundingActors, false)
EndFunction

; =========================================================================
; ============================================ ANIMATIONS
; ========================================================================
int scenesPlayed
String hook

Function StartAnimation()
  String initName = init.GetLeveledActorBase().GetName()
  int s = SMMAnimFrame.StartAnimation(MCM, init, partners, Math.abs(consent - 1) as int, hook)
  If(s == -1)
    Debug.Trace("[SMM] " + Self + " Failed to Start 2p+ Animation " + scenesPlayed + " | Initiator: " + init + " | Name: " + initName)
    Stop()
    return
  EndIf
  Debug.Trace("[SMM] " + Self + " Successfully started 2p+ Animation " + scenesPlayed + " | Initiator: " + init + " | Name: " + initName)
EndFunction
Event AfterSceneSL(int tid, bool hasPlayer)
  Debug.Trace("[SMM] " + Self + " Animation End (SL) on Thread ")
  PostScene(-2)
EndEvent
Event AfterSceneOStim(string asEventName, string asStringArg, float afNumArg, form akSender)
  Debug.Trace("[SMM] " + Self + " Animation End (OStim) on Thread ")
  PostScene(afNumArg as int)
EndEvent
Function PostScene(int ID)
  If(ID > -2)
    If(SMMOstim.FindInit(init, ID) == false)
      Debug.Trace("[SMM] " + Self + " Unrelated OStim End")
      return
    EndIf
  EndIf
  String initName = init.GetLeveledActorBase().GetName()
  If(jActors == 0 || !playNextScene())
    ; Only 1 1p Scene or max Multi Scenes reached
    SetStage(5)
  Else
    ; Start another Scene
    scenesPlayed += 1
    ; Remove Partners which arent staying
    int n = 0
    While(n < partners.Length)
      If(Utility.RandomFloat(0, 99.9) >= MCM.fResNextRoundChance)
        JMap.setFlt(jCd, partners[n].GetFormID(), Scan.GameDaysPassed.Value)
        ClearActor(partners[n])
        partners[n] = none
      EndIf
      n += 1
    EndWhile
    ; Update Partner Array
    int maxPartners = Scan.GetNumPartners(4)
    If(maxPartners != partners.Length)
      If(maxPartners < partners.Length)
        int i = partners.Length
        While(i > maxPartners)
          i -= 1
          JMap.setFlt(jCd, partners[i].GetFormID(), Scan.GameDaysPassed.Value)
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
  If(init == Game.GetPlayer())
    Game.SetPlayerAIDriven(false)
  Else
    init.SetRestrained(false)
  EndIf
  init.RemoveSpell(GatherSurroundingActors)
  StorageUtil.SetFormValue(init, "Thread", none)
  JMap.setFlt(jCd, init.GetFormID(), Scan.GameDaysPassed.Value)
  int i = 0
  While(i < partners.Length)
    JMap.setFlt(jCd, partners[i].GetFormID(), Scan.GameDaysPassed.Value)
    i += 1
  EndWhile
  JValue.writeToFile(jCd, filePathCooldown)
  jCd = JValue.release(jCd)
  jActors = JValue.release(jActors)
  jProfile = JValue.release(jProfile)
EndFunction
Actor Function GetInit()
  return partners[0]
EndFunction