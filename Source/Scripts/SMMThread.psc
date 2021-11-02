Scriptname SMMThread extends Quest Conditional
{Generic Thread Script. Takes on Aliases and starts a Scene once no more Aliases can be added anymore}

SMMMCM Property MCM Auto
SMMScan Property Scan Auto
Scene Property MyScene Auto
; NOTE: Alias with ID 0 is considered the Initiator; Alias with ID 1+ are Partners
int jActors
int jProfile
Actor init
Actor[] partners

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  init = akRef1 as Actor
  jActors = aiValue1
  jProfile = aiValue2
  Debug.Notification("Thread Started with Initiator: " + init.GetLeveledActorBase().GetName())
  Debug.Trace("Thread Started with Initiator: " + init + "/" + init.GetLeveledActorBase().GetName())
  ; Fill Aliases
  Form[] jActorForms = JArray.asFormArray(jActors)
  partners = PapyrusUtil.ActorArray(jActorForms.length)
  int i = 0
  While(i < partners.length)
    partners[i] = jActorForms[i] as Actor
    (GetNthAlias(i + 1) as ReferenceAlias).ForceRefTo(partners[i])
    partners[i].StopCombat()
    partners[i].StopCombatAlarm()
    i += 1
  EndWhile
  ; Start Scene
  MyScene.Start()
  If(!MyScene.IsPlaying())
    Debug.Trace("[SMM] <Thread> Scene Failed to Start")
    Stop()
  EndIf
EndEvent

Function StartScene()
  String h = GetFormID()
  int s
  If(jActors == 0) ; Empty Array, 1p Scene
    s = SMMAnimFrame.StartAnimationSingle(MCM, init, h)
  Else ; 2p+ Scene
    s = SMMAnimFrame.StartAnimation(MCM, init, partners, JMap.getInt(jProfile, "bConsent"), h)
  EndIf
  If(s == -1)
    Debug.MessageBox("Failed to start Animation on Thread with Initiator: " + init.GetLeveledActorBase().GetName())
    Debug.Trace("Failed to start Animation on Thread with Initiator: " + init + "/" + init.GetLeveledActorBase().GetName())
    Stop()
    return
  ElseIf(s == 0)
    RegisterForModEvent("HookAnimationEnd_" + h, "AfterSceneSL")
  ElseIf(s == 1)
    RegisterForModEvent("ostim_end", "AfterSceneOStim")
  EndIf
  int jCd = JValue.readFromFile("Data\\SKSE\\SMM\\Definition\\Cooldowns.json")
  JMap.setFlt(jCd, init.GetFormID(), Scan.GameHour.Value)
  int i = 0
  While(i < partners.Length)
    JMap.setFlt(jCd, partners[i].GetFormID(), Scan.GameHour.Value)
    i += 1
  EndWhile
  JValue.writeToFile(jCd, "Data\\SKSE\\SMM\\Cooldowns.json")
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
  ; Assuming the Adult Scene ended here
  SetStage(5)
EndFunction

Function Stop()
  Debug.Notification("Thread Stopped with Initiator: " + init.GetLeveledActorBase().GetName())
  Debug.Trace("Thread Stopped with Initiator: " + init + "/" + init.GetLeveledActorBase().GetName())
  jActors = JValue.release(jActors)
  jProfile = JValue.release(jProfile)
  Parent.Stop()
EndFunction