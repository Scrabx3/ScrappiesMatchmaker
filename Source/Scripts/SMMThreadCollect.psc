Scriptname SMMThreadCollect extends ActiveMagicEffect  

SMMMCM Property MCM Auto
SMMScan Property Scan Auto
Keyword Property ActorTypeNPC Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  Debug.Trace("[SMM] <ThreadCollect> akTarget = " + akTarget + "; akCaster = " + akCaster)
  If(Utility.RandomFloat(0, 99.9) < MCM.fSpecChance)
    If(!akTarget.HasKeyword(ActorTypeNPC) && !MCM.bSpecCrt)
      return
    ElseIf(MCM.bSpecGender && !Scan.isValidGenderCombination(akCaster, akTarget))
      return
    EndIf
    
    SMMThread thread = GetThread(akCaster)
    Debug.Trace("[SMM] Found Thread for Caster = " + akCaster + " = " + thread)
    If(thread != none)
      thread.AddActor(akTarget)
    EndIf
  EndIf  
EndEvent

SMMThread Function GetThread(Actor subject)
  If(subject == Game.GetPlayer())
    return Quest.GetQuest("SMM_ThreadPlayer") as SMMThread
  Else
    int i = 0
    While(i < 10)
      SMMThread thread = Quest.GetQuest("SMM_Thread0" + i) as SMMThread
      If(thread.GetInit() == subject)
         return thread
      EndIf
      i += 1
    EndWhile
  EndIf
  return none
EndFunction
