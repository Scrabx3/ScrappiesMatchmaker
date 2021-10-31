Scriptname SMMThread extends Quest Conditional
{Generic Thread Script. Takes on Aliases and starts a Scene once no more Aliases can be added anymore}

SMMMCM Property MCM Auto
SMMScan Property Scan Auto
Scene Property MyScene Auto
; NOTE: Alias with ID 0 is considered the Initiator; Alias with ID 1+ are
;/ TODO: Split 2p+ Scenes:
The StoryScript Event should only prepare everything & start the Scene; in 2p+ Scenes, Actors will close in one everyone first before starting the Scene
/;
Actor init
int jProfile

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  String h = GetFormID()
  int s
  If(aiValue1 == 0) ; Empty Array, 1p Scene
    s = SMMAnimFrame.StartAnimationSingle(MCM, akRef1 as Actor, h)
  Else ; 2p+ Scene
    Form[] p = JArray.asFormArray(aiValue1)
    Actor[] them = PapyrusUtil.ActorArray(p.length)
    int cd = JValue.readFromFile("Data\\SKSE\\SMM\\Cooldowns.json")
    int i = 0
    While(i < them.length)
      them[i] = p[i] as Actor
      (GetNthAlias(i + 1) as ReferenceAlias).ForceRefTo(them[i])
      them[i].StopCombat()
      them[i].StopCombatAlarm()
      JMap.setFlt(cd, them[i].GetFormID(), Scan.GameHour.Value)
      i += 1
    EndWhile
    JMap.setFlt(cd, akRef1.GetFormID(), Scan.GameHour.Value)
    JValue.writeToFile(cd, "Data\\SKSE\\SMM\\Cooldowns.json")
    s = SMMAnimFrame.StartAnimation(MCM, akRef1 as Actor, them, JMap.getInt(aiValue2, "bConsent"), h)
  EndIf
  If(s == -1)
    RegisterForSingleUpdate(0.05)
  ElseIf(s == 0)
    RegisterForModEvent("HookAnimationEnd_" + h, "AfterSceneSL")
  ElseIf(s == 1)
    RegisterForModEvent("ostim_end", "AfterSceneOStim")
  EndIf
  init = akRef1 as Actor
  jProfile = aiValue2
  SetStage(20)
EndEvent

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
  Stop()
EndFunction

Event OnUpdate()
  JValue.release(jProfile)
  Stop()
EndEvent