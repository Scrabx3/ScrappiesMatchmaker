Scriptname SMMThreadCollect extends ActiveMagicEffect  

SMMMCM Property MCM Auto
SMMScan Property Scan Auto
Keyword Property ActorTypeNPC Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  Debug.Trace("[SMM] <ThreadCollect> akTarget = " + akTarget + "; akCaster = " + akCaster)
  If(Utility.RandomFloat(0, 99.9) >= MCM.fSpecChance)
    Debug.Trace("[SMM] <ThreadCollect> Chance failed")
    return
  EndIf
  
  bool npc = akTarget.HasKeyword(ActorTypeNPC)
  If(!npc)
    If(!MCM.bSpecCrt)
      Debug.Trace("[SMM] <ThreadCollect> Target is Creature but Creatures arent allowed")
      return
    EndIf
  Else 
    If(MCM.bSpecGender && !Scan.isValidGenderCombination(akCaster, akTarget))
      Debug.Trace("[SMM] <ThreadCollect> Gender doesnt match")
      return
    EndIf
  EndIf

  SMMThread thread = StorageUtil.GetFormValue(akCaster, "SMMThread") as SMMThread
  If(thread == none)
    If(akCaster == Game.GetPlayer())
      thread = Quest.GetQuest("SMM_ThreadPlayer") as SMMThread
    Else
      int i = 0
      While(i < 10)
        SMMThread tmp = Quest.GetQuest("SMM_Thread0" + i) as SMMThread
        If(tmp.GetInit() == akCaster)
          thread = tmp
        EndIf
        i += 1
      EndWhile
    EndIf
  EndIf
  Debug.Trace("[SMM] <ThreadCollect> Found Thread = " + thread)
  If(thread != none)
    thread.AddActor(akTarget)
  EndIf
EndEvent
