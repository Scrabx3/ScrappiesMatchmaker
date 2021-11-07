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

; =========================================================================
; ============================================ START UP
; ========================================================================
Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  jCd = JValue.retain(JValue.readFromFile("Data\\SKSE\\SMM\\Definition\\Cooldowns.json"))
  init = akRef1 as Actor
  jActors = aiValue1
  jProfile = aiValue2
  consent = JMap.getInt(jProfile, "bConsent")
  Debug.Trace("[SMM] Started Thread. ID: " + Self + " | Initiator: " + init + "| Name: " + init.GetLeveledActorBase().GetName())
  If(jActors > 0)
    ; Fill Aliases
    Form[] jActorForms = JArray.asFormArray(jActors)
    partners = PapyrusUtil.ActorArray(jActorForms.Length)
    int i = 0
    While(i < partners.length)
      partners[i] = jActorForms[i] as Actor
      i += 1
    EndWhile
    SortByDistance(partners, partners.Length)
    int n = 0
    While(n < partners.Length)
      (GetNthAlias(n + 1) as ReferenceAlias).ForceRefTo(partners[n])
      partners[n].StopCombat()
      partners[n].StopCombatAlarm()
      n += 1
    EndWhile
  EndIf
  ; Start Scene
  MyScene.Start()
  If(!MyScene.IsPlaying())
    Debug.Trace("[SMM] <Thread> Scene Failed to Start")
    Stop()
  EndIf
EndEvent
Function SortByDistance(Actor[] them, int n)
  If(n <= 1)
    return
  EndIf
  SortByDistance(them, n - 1)
  Actor final = them[n - 1]
  int i = n - 2
  While(i >= 0 && them[i].GetDistance(init) > final.GetDistance(init))
    them[i + 1] = them[i]
    i -= 1
  EndWhile
  them[i + 1] = final
EndFunction

; =========================================================================
; ============================================ ANIMATIONS
; ========================================================================
int scenesPlayed
String hook

Function StartScene()
  hook = GetFormID()
  scenesPlayed = 1
  If(jActors == 0) ; Empty Array, 1p Scene
    int s = SMMAnimFrame.StartAnimationSingle(MCM, init, hook)
    String initName = init.GetLeveledActorBase().GetName()
    If(s == -1)
      Debug.Trace("[SMM] Failed to start 1p Animation on Thread " + Self + " | Initiator: " + init + " | Name: " + initName)
      Stop()
      return
    ElseIf(s == 0)
      RegisterForModEvent("HookAnimationEnd_" + hook, "AfterSceneSL")
    ElseIf(s == 1)
      RegisterForModEvent("ostim_end", "AfterSceneOStim")
    EndIf
    Debug.Trace("[SMM] Successfully started 1p Animation on Thread " + Self + " | Initiator: " + init + " | Name: " + initName)
  Else ; 2p+ Scene
    Actor[] them = PapyrusUtil.ActorArray(partners.Length)
    int i = 0
    int ii = 0
    While(i < partners.Length)
      If(partners[i].GetDistance(init) < 650)
        ClearActor(partners[i])
        them[ii] = partners[i]
        ii += 1        
      EndIf
      i += 1
    EndWhile
    partners = them
    StartAnimation()
  EndIf
  StorageUtil.SetFormValue(init, "Thread", Self)
  init.AddSpell(GatherSurroundingActors, false)
EndFunction

Function StartAnimation()
  String initName = init.GetLeveledActorBase().GetName()
  int s = SMMAnimFrame.StartAnimation(MCM, init, partners, consent, hook)
  If(s == -1)
    Debug.Trace("[SMM] Failed to start Thread Animation " + scenesPlayed + " | Thread ID:" + Self + " | Initiator: " + init + " | Name: " + initName)
    Stop()
    return
  ElseIf(s == 0)
    RegisterForModEvent("HookAnimationEnd_" + hook, "AfterSceneSL")
  ElseIf(s == 1)
    RegisterForModEvent("ostim_end", "AfterSceneOStim")
  EndIf
  Debug.Trace("[SMM] Successfully started Thread Animation " + scenesPlayed + " | Thread ID:" + Self + " | Initiator: " + init + " | Name: " + initName)
EndFunction
Event AfterSceneSL(int tid, bool hasPlayer)
  PostScene(-2)
EndEvent
Event AfterSceneOStim(string asEventName, string asStringArg, float afNumArg, form akSender)
  PostScene(afNumArg as int)
EndEvent
Function PostScene(int ID)
  If(ID > -2)
    If(SMMOstim.FindInit(init, ID) == false)
      return
    EndIf
  EndIf
  String initName = init.GetLeveledActorBase().GetName()
  Debug.Trace("[SMM] Post Scene on Thread " + Self + " | Animations: " + scenesPlayed + " | Initiator: " + init + " | Name: " + initName)
  return
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
    int maxPartners = Scan.calcThreesome(5) - 1
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
    int i = 1
    int ii = 0
    While(i < them.Length && ii < maxPartners)
      Actor tmp = (them[i] as ReferenceAlias).GetReference() as Actor
      If(tmp && partners.Find(tmp) == -1 && Utility.RandomFloat(0, 99.9) < MCM.fAddActorChance)
        int empty = partners.Find(none)
        If(empty > -1)
          If(Scan.isValidGenderCombination(init, tmp) && Scan.IsValidRace(tmp) && Scan.ValidPartner(tmp) && Scan.ValidMatch(init, tmp))
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
    StartAnimation()
  EndIf
EndFunction
bool Function playNextScene()
	return MCM.iResMaxRounds > scenesPlayed || MCM.iResMaxRounds == 0
EndFunction

bool Function AddActor(ObjectReference that)
  Alias[] them = GetAliases()
  int i = 1
  While(i < them.Length)
    ReferenceAlias tmp = them[i] as ReferenceAlias
    If(tmp.ForceRefIfEmpty(that))
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

Function Stop()
  Debug.Trace("Thread Stopped with Initiator: " + init + "/" + init.GetLeveledActorBase().GetName())
  init.RemoveSpell(GatherSurroundingActors)
  StorageUtil.SetFormValue(init, "Thread", none)
  JMap.setFlt(jCd, init.GetFormID(), Scan.GameDaysPassed.Value)
  int i = 0
  While(i < partners.Length)
    JMap.setFlt(jCd, partners[i].GetFormID(), Scan.GameDaysPassed.Value)
    i += 1
  EndWhile
  JValue.writeToFile(jCd, "Data\\SKSE\\SMM\\Definition\\Cooldowns.json")
  jCd = JValue.release(jCd)
  jActors = JValue.release(jActors)
  jProfile = JValue.release(jProfile)
  Parent.Stop()
EndFunction
Actor Function GetInit()
  return init
EndFunction